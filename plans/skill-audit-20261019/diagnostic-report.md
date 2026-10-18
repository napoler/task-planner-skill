# task-planner-skill 仓技能审计诊断报告（skill-fix 标准）

- 审计时间: 2026-10-19
- 审计对象: `/mnt/data/dev/task-planner-skill/skills/`（15 个技能，核心 task-planner + 11 卫星 + 3 轻量）
- 方法: 主上下文机械扫描（S56/S64/S74/S75 批量 grep）+ 4 个隔离子代理深度 Read 审计（A 核心 / B 派发纪律验证 / C 计划卫星 / D 其余）
- 审计标准: skill-fix S40/S56/S64/S2/S25/S63/S67/S75/S68/S74/S76
- 运行环境实证: bun=缺失 / ts-node=缺失 / tsx=缺失 / node=v22.22.0 可用 / python3=3.12.3 可用 / bash=5.2
- 范围: 只读诊断，未修改任何技能文件（git status 仅本审计产物 plans/skill-audit-20261019/）

---

## 0. 发现总览

| 等级 | 数量 | 说明 |
|------|------|------|
| P0/BLOCKED | 1 | bun 缺失致 task-planner 工作流第一步不可运行 |
| P1 | 9 | 迁移性硬编码 / 跨技能引用歧义 / I-O 无机器契约 / 自我纠正无分层 |
| P2 | 12 | 索引漏条 / frontmatter 风格分裂 / 触发词交叠 / 超长 / 行号锚漂移 |
| PASS/不适用 | 多项 | S40/S56/S63/S2 核心满足；三卫星 S74 无 TS 依赖 |

**整体健康度**：核心 task-planner 结构合规（frontmatter/流程图/I-O 三要素齐），主要缺陷集中在**迁移性（S75）**与**跨技能引用一致性（S64）**两大系统性面上，属文本面低风险修复；**唯一 P0 是运行时缺失（bun）**，需基础设施决策。

---

## 1. P0 / BLOCKED

### [P0] F1 — session-catchup.ts（工作流第一步）依赖 bun，bun 未安装 → 初始化检测不可运行
- 标准: S74（运行时实证）
- 位置: `skills/task-planner/scripts/session-catchup.ts:1` + `SKILL.md:40`
- 证据:
  - `session-catchup.ts:1` `#!/usr/bin/env bun`（sha256=3ade7fb1, 274行）
  - `SKILL.md:40` `运行 bun scripts/session-catchup.ts 检测中断恢复点`（sha256=350615d6, 237行）
  - `command -v bun` 实测无输出；`command -v node` → v22.22.0 可用
- 说明: session-catchup.ts 是「计划制作循环 → 初始化」第一步（跨会话中断恢复点检测）。register-hooks-cj.ts:1 同用 bun shebang，但 install.sh:164 有「bun not found, skipping」降级，影响较小。sync-ide-folders.ts:1 用 `npx ts-node`（ts-node 亦缺失）。
- 建议（按 S74 优先级「可用 > 合规」）: ① 首选将 3 个 .ts 改写为 node 可运行（node v22 普遍可用，纯 TS 改写为 .mjs 或 `#!/usr/bin/env node` 加类型剥离）；② 或提供 bash 等价降级路径（SKILL.md:40 改为「bun 可用则跑，缺失降级 5Q Reboot 读三文件」）；③ 若目标部署机有 bun 则判 BLOCKED 是环境级，需登记「安装 bun」为前提。

---

## 2. P1（9 条）

### [P1] F3 — 模板+selftest 层硬编码 `/mnt/data/dev/task-planner-skill/` 回退默认（S75 D1 迁移性破洞）
- 标准: S75（D1 硬编码路径）
- 位置: `templates/verification.md:77` / `templates/task_plan.md:3,29,90` / `scripts/selftest-subagent-return.sh:29` / `scripts/selftest-decision-drift.sh:98`
- 证据:
  - `verification.md:77` `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats`（sha256=e7bda625）
  - `task_plan.md:3` `白名单=${TASK_PLANNER_ROOT:-/mnt/data/...}/templates/variant/*-type.md`（sha256=831527d9, 555行）
  - `selftest-subagent-return.sh:29` 写死 `PLAN="/mnt/data/dev/task-planner-skill/plans/archive/task-v161-subagent-return-format"`
  - `selftest-decision-drift.sh:98` 写死 `plans/task-v156-drift-shield/task_plan.md`
- 说明: `${VAR:-默认值}` 形式 env 可覆盖（缓解），但**模板/selftest 是机器行为面**——命令直贴复制即把某台开发机路径固化；selftest 写死具体 plans/archive 任务路径，换机即缺 fixture 致 selftest 假 FAIL。
- 建议: 模板层默认值改为 `${TASK_PLANNER_ROOT:-$(skill-root-detect)}` 运行时探测；selftest 改用 `$(repo-root)/plans/...` 相对解析或「无该 fixture 时 skip（fail-open）」。

### [P1] F5 — .claude 与 .zcode 平台路径混用（S75 D3，非纯示例）
- 标准: S75（D3 平台一致性）
- 位置: `SKILL.md:21,43,47` / `config.json:228,347` / `register-hooks-cj.ts:5` / `session-catchup.ts:5` / `init-session.sh:67`
- 证据: `SKILL.md:47` `清除哨兵：node ~/.zcode/skills/task-planner/scripts/plan-created.cjs`（正文写死 .zcode）；`init-session.sh:67` find_project_templates 只找 `.claude/plan-templates`，与 `SKILL.md:43`「.claude 或 .zcode 覆盖」承诺不符。
- 说明: install.sh/plan-doctor.sh/smart-merge-back.sh 双平台探测属合理多工具部署设计（有 .backup/claude-stub 佐证）；但 SKILL.md:47 正文把平台路径写进可执行指引、init-session.sh 平台覆盖与正文口径矛盾 = P1。
- 建议: 正文可执行指引改 `${TASK_PLANNER_ROOT}`；脚本双平台分支保留并注释属多工具模型；修正 init-session.sh 使其同时探测 .zcode 与 .claude，与 SKILL.md:43 对齐。

### [P1] F4 — 跨技能引用同内混用 `../卫星/` 与 `skills/卫星/` 两种形式（S64 歧义）
- 标准: S64（跨 skill 引用应统一 ../ 前缀）
- 位置: `SKILL.md:158` vs `:165-175`；`references/critical-rules.md:183-193`；`references/completion-gate.md:5`；`references/goal-gate.md:5`
- 证据: 正确 `SKILL.md:165` `../task-dispatch/references/critical-rules-dispatch.md`；歧义 `SKILL.md:158` `skills/plan-template-kit/references/critical-rules-template.md:45`（无 ../，须从仓根解析；相对本文件不存在）。
- 说明: 同一技能内两种写法并存，读者无法判断基准目录。references/ 下文件写 `skills/卫星/` 相对 references/ 目录不存在（须仓根相对），只有 `../卫星/` 才正确。
- 建议: 统一为 `../卫星/`，把 SKILL.md:158 / critical-rules.md:183-193 / completion-gate.md:5 / goal-gate.md:5 的 `skills/卫星/` 全改 `../卫星/`。

### [P1] F6 — task-dispatch / task-discipline 规则全文跨 skill 引用未加 ../task-planner/ 前缀（S64 歧义，40+ 处）
- 标准: S64
- 位置: `task-dispatch/references/critical-rules-dispatch.md:8,38,152`；`task-discipline/references/critical-rules-discipline.md` 全文（:15,29,30,40,43,46,52,54,64,65,77…）
- 证据: `critical-rules-dispatch.md:8` `合约见 references/worktree-isolation.md`（实际在 task-planner/references/，本卫星无此文件）；`critical-rules-discipline.md:29` `scripts/selftest-error-loop.sh 静态守护`（实际全在 task-planner/scripts/，本卫星只有 2 个脚本）。
- 说明: 已验证 35 个被引用脚本在 task-planner/scripts/ 实际 EXISTS（非缺失，是缺前缀）；同技能 SKILL.md 侧已正确带 `../task-planner/` 前缀，references 侧未带 → 两种写法并存误导。
- 建议: critical-rules-dispatch.md / critical-rules-discipline.md 内所有指向 task-planner 的 scripts/config/references 统一加 `../task-planner/`，或文件头加「本文件 scripts/* 与 config.json 均指 task-planner/ 侧」迁移注记。

### [P1] F7 — verification-gate 规则全文与 SKILL.md 对 selftest-verification-gate.sh 位置描述矛盾（S40/S64）
- 标准: S40/S64
- 位置: `verification-gate/references/critical-rules-verification.md:44` vs `verification-gate/SKILL.md:73`
- 证据: 规则全文 `:44` `selftest-verification-gate.sh（本卫星 scripts/）静态守护`；SKILL.md:73 `selftest-verification-gate.sh … ../task-planner/scripts/（机械层留守主技能）`。实测 verification-gate/scripts/ 只有 run-verification.sh，该脚本在 task-planner/scripts/。
- 说明: SKILL.md 正确、规则全文写错位置（漂移成「本卫星」）。
- 建议: critical-rules-verification.md:44 改「（task-planner/scripts/，机械层留守）」，与 SKILL.md:73 对齐。

### [P1] F8 — plan-resume / plan-template-kit / plan-cost-guard 双重拼接路径 + 缺 ../task-planner/ 前缀（S64）
- 标准: S64
- 位置: `plan-cost-guard/references/critical-rules-cost.md:9,18`；`plan-template-kit/references/critical-rules-template.md:8,16,27`；`plan-template-kit/SKILL.md:24,26`；`plan-cost-guard/SKILL.md:29`；`task-drift-guard/SKILL.md:90,91`
- 证据: critical-rules-cost.md:9 用 `../plan-cost-guard/references/critical-rules-cost.md`（解析为 `skills/plan-cost-guard/plan-cost-guard/...` 不存在，`test -f` 实测失败）——同目录引用应裸名，误加 `../<自身>/` 双重拼接；plan-template-kit/SKILL.md:24 裸 `scripts/selftest-template-lifecycle.sh`（文件在 task-planner/scripts/，缺 `../task-planner/` 前缀）。
- 建议: 双重拼接改裸名；跨技能引用补 `../task-planner/` 前缀。

### [P1] F9 — split-pattern-library.md 伴飞映射表硬编码 14 处 /home/terry/ 绝对路径（S75 D1）
- 标准: S75（D1 硬编码路径）
- 位置: `task-dispatch/references/split-pattern-library.md:13-20,124-130`
- 证据: `| writing-plans | /home/terry/.zcode/skills/writing-plans/SKILL.md |`（共 14 处 /home/terry/…，.zcode 与 .agents 双宿主混用）（sha256=799bd2a7, 136行）
- 说明: 这些是 Rule 59.2/59.3 要求的「SKILL.md 绝对路径」伴飞注入，但写死到当前部署者 home；换部署者/换宿主即失效。
- 建议: 用运行时探测（`$ZCODE_HOME/skills/<name>`）替代；或至少 `~/.zcode/`/`~/.agents/`（~ 展开）+ 宿主自适应。

### [P1] F10 — plan-template-kit 写死到其他项目 + plan-resume 测试脚本硬编码（S75 D1）
- 标准: S75（D1）
- 位置: `plan-template-kit/references/template-mapping.md:118`；`plan-resume/tests/smoke.sh`（8 处 /home/terry/）
- 证据: `template-mapping.md:118` `mkdir -p /mnt/data/dev/article-generation/.claude/plan-templates/`（写死到其他项目 article-generation，无豁免注）（sha256=62cde6c8, 321行）；`plan-resume/tests/smoke.sh` 8 处 /home/terry/。
- 建议: 改占位符 `<project>/.claude/plan-templates/`；smoke.sh 用 `$(repo-root)` 相对解析。

### [P1] F11 — task-planner I/O 契约无 JSON Schema + verify_io（S67）
- 标准: S67
- 位置: `SKILL.md:201-203`（## I/O 契约）
- 证据: `:203` 三要素齐（输入/输出/示例）但纯文本；四文件罗盘 7 文件产出契约 + check-complete 终验门控无机器可校验 schema。
- 说明: S2 满足，S67 要求有契约的子能力配 schema+verify_io。
- 建议（最低成本）: 给「7 文件产出契约」和「check-complete 输入/输出」配 JSON Schema + verify_io 断言，或登记为已知缺口。

---

## 3. P2（12 条）

| # | 发现 | 标准 | 位置 | 证据要点 | 建议 |
|---|------|------|------|---------|------|
| P2-1 | task-discipline 索引表漏 Rule 85-90 六行 + 计数 41/42 不一致 | S40 | task-discipline/SKILL.md:15,32-68,70,81 | 索引表 36 行 vs 域边界 42 条；:70「41」:81「42」互斥 | 补 85-90 六行 + 统一计数 42 |
| P2-2 | task-discipline 头部「暂不写」迁移注记已陈旧 | S40/文档 | critical-rules-discipline.md:5,7 | :5「剩余 17 条…暂不写」但实际 42 条全落盘 | 更新注记 |
| P2-3 | 三卫星 frontmatter 风格分裂 | S40 | task-dispatch/task-discipline 用 `tools:`（非 `allowed-tools:`）无 model；verification-gate 用 `model:haiku` 无 tools | 命名不统一；verification-gate 需 Bash 却未声明工具面 | 统一键名 + verification-gate 补 Bash |
| P2-4 | S25 触发词交叠未划界 | S25 | task-dispatch vs verification-gate「返回校验」；task-discipline vs task-dispatch「调研」 | 两 SKILL.md description 都含「返回」，未声明「格式归 dispatch / 内容归 verification-gate」 | description 加边界声明 |
| P2-5 | plan-resume SKILL.md 437 行 / progress-tracker 199 行超「核心 ≤100 行」 | 内容密度 | plan-resume/SKILL.md | 437 行密度高 | 抽 §7 到 references/ |
| P2-6 | plan-resume S63 六步工作流无 markdown 任务清单/门控 | S63 | plan-resume/SKILL.md | 有 6 步但非 `- [ ]` 格式 | 升级 markdown 任务列表 |
| P2-7 | error-fix-prompt-forge L46 仓库根相对路径歧义 | S64 | error-fix-prompt-forge/SKILL.md:46 | `skills/error-fix-prompt-forge/templates/...` 仓根相对，skill 内解析歧义 | 改相对 skill 根 |
| P2-8 | iterative-optimizer L37「task-planner Rule 44」归属错误 | S64 | iterative-optimizer/SKILL.md:37 | Rule 44 实为 task-discipline/references/critical-rules-discipline.md:171（「自动超时」） | 修正归属 |
| P2-9 | S68 task-planner/verification-gate 无 L1/L2/L3 自我纠正分层 | S68 | 全文 grep L1/L2/L3 零命中 | 有 Rule 83 快速失败/22.3 换道/decision-arbiter 但未按 L1/L2/L3 建模 | 补分层映射（如 skill-fix 强制） |
| P2-10 | check-conflicts.sh:17 拼写 + methodology.md:4 行号锚漂移 | 内容质量 | check-conflicts.sh:17；methodology.md:4 | `init-session.sh:385` 已自我标注「SKILL.md:505 已失真」，行号锚系统性漂移 | 改段落锚/关键词锚 |
| P2-11 | 四纯知识卫星无 I/O 契约 + 五卫星无 TaskCreate/Update/List | S2/S56 | plan-* 各 SKILL.md | 指针/规则集型卫星，是否豁免未验证 | 与 skill-fix 口径确认豁免性 |
| P2-12 | task-drift-guard README 单一 .claude 平台 + 未列 references/ | S75/文档 | task-drift-guard | README 只提 .claude | 补双平台 |

---

## 4. 按标准分类速查

| 标准 | 命中技能 | 等级 |
|------|---------|------|
| S74 运行时 | task-planner（bun 缺失 BLOCKED）；todo-skill PASS（node 可用） | P0 |
| S75 D1 硬编码 | task-planner templates+selftest；split-pattern-library；template-mapping；plan-resume smoke.sh | P1 |
| S75 D3 平台混用 | task-planner SKILL.md/config.json；install/uninstall/check-doc-sync/smart-merge-back | P1 |
| S64 跨 skill 引用 | task-planner（skills/ vs ../）；task-dispatch/discipline/verification-gate/plan-cost-guard/plan-template-kit/task-drift-guard/error-fix/iterative | P1/P2 |
| S56 allowed-tools | 13 技能未声明（卫星多属指针/规则集型）；task-planner/todo-skill 声明 | P2 |
| S40 frontmatter | task-dispatch/discipline 用 `tools:`；verification-gate 缺 tools；计数/索引漏条 | P2 |
| S67 I/O Schema | task-planner I-O 纯文本无 schema | P1 |
| S63 流程图 | task-planner PASS；plan-resume 非 `- [ ]`；四知识卫星无 | P2 |
| S25 触发词 | task-dispatch↔verification-gate「返回」；task-discipline↔task-dispatch「调研」 | P2 |
| S68 自我纠正 | task-planner/verification-gate 无 L1/L2/L3 分层 | P2 |
| S76 并行安全 | todo-skill cli_todo-manager.ts writeFileSync 非原子 + 固定 store.json 无锁（P1，子代理 D 报） | P1 |

---

## 5. 修复优先级建议（按风险/收益）

1. **立即（P0 基础设施）**: 处置 bun 缺失 —— ① 目标部署机若必须有 bun → 登记「安装 bun」为前提；② 否则把 session-catchup.ts/register-hooks-cj.ts/sync-ide-folders.ts 改 node 可运行（node v22 可用）或 bash 降级路径。
2. **高（P1 引用一致性，影响面最大）**: 统一跨技能引用 —— task-planner `skills/卫星/`→`../卫星/`；task-dispatch/discipline/plan-cost-guard/template-kit/drift-guard 补 `../task-planner/` 前缀；修 verification-gate 脚本位置矛盾；修双重拼接。属文本面低风险批量修。
3. **中（P1 硬编码）**: 模板/selftest/split-pattern-library/template-mapping/smoke.sh 去 `/mnt/`/`/home/terry/` 硬编码，改运行时探测。
4. **中（P1 I/O + 自我纠正）**: task-planner 补 JSON Schema+verify_io；补 L1/L2/L3 分层（若 skill-fix 强制）。
5. **低（P2 文档卫生）**: task-discipline 索引补 85-90 + 计数对齐；三卫星 frontmatter 统一；触发词边界声明；行号锚改段落锚。

---

## 6. 未验证项（诚实标注）

1. S25 触发词正交性需跨 11 卫星逐一对照实跑 trigger 命中测试（未实跑）。
2. S63/S2/S67 是否豁免「指针型/规则集型卫星」——取决于 skill-fix 判定口径（子代理保守标 P2，未强行判违规）。
3. S56「Step 1/2/3 是否构成 ≥3 Phase」判定口径未与 skill-fix 规范原文对齐。
4. S68 L1/L2/L3 具体语义定义未验证（task-planner 有 Rule 83/22.3/decision-arbiter 等价机制，仅术语面缺口）。
5. task-planner 36 个 .ts 的原始出处 —— 实测 active 仅 3 个脚本 .ts（+1 个 .zcode/workflow-drafts 非技能文件），「36」疑把 .backup/ 快照误计入。

---

## 7. 已验证合规项（回收）

- S40 核心 frontmatter name=目录名 ✓；task-planner allowed-tools 含 S56 要求的 Task 四件套 ✓
- S63 task-planner 计划制作循环为 markdown `- [ ]` 任务列表，含初始化/确认/执行/终验 ≥4 phase + 门控（attest/3-File Gate/VC-GATE/drift check）✓
- S2 I/O 契约三要素齐（Input/Output/Example）✓（S67 缺 schema）
- S64 引用的 11 卫星目录、references/6 文件、templates 均实际存在 ✓（仅引用形式不一致）
- config.json 为合法 JSON Schema draft-07，additionalProperties:false，required 完整 ✓
- 三卫星（dispatch/discipline/verification-gate）scripts 全 bash，零 TS 依赖，S74 不适用/通过 ✓

---

## ✅ 执行完成总结（中文，S58）

### 已完成事项
1. 结构盘点 15 技能规模/frontmatter —— 机械扫描（主上下文）
2. P0 机械扫描 S64/S74/S75/S56/S40 —— 主上下文批量 grep（114 处硬编码、136 .claude + 240 .zcode、bun 缺失等）
3. S74 运行时实证 —— `command -v bun` 无输出（BLOCKED），`command -v node` v22.22.0 可用
4. 派 4 隔离子代理深度 Read 审计 —— 各落检查点（A 120行/B 180行/C 140行/D 250行）
5. 主上下文 Read 复核 A/B 检查点 + 关键文件 sha256 取证（防子代理虚构）

### 产出文件清单
| 文件 | sha256(前8) | 行数 |
|------|-------------|------|
| plans/skill-audit-20261019/diagnostic-report.md | （本文件） | ~230 |
| plans/skill-audit-20261019/subagent-state/A-task-planner.md | — | 120 |
| plans/skill-audit-20261019/subagent-state/B-dispatch-discipline-verification.md | — | 180 |
| plans/skill-audit-20261019/subagent-state/C-plan-satellites.md | — | 140 |
| plans/skill-audit-20261019/subagent-state/D-others.md | — | 250 |

### 遗留问题 / 风险
- [P0] bun 缺失 = BLOCKED，修复需基础设施决策（装 bun vs 改 node vs bash 降级）
- [P1] 迁移性 + 跨技能引用两大系统性面（文本面低风险，但影响面广）
- [未验证] S25/S56/S63/S68 口径判定未与 skill-fix 原文逐条对齐（标 P2 未强行判违规）

### 下一步建议
1. P0 决策：`command -v bun || 登记「需装 bun」`，或派子代理把 3 个 .ts 改 `#!/usr/bin/env node` + 类型剥离（node v22 可用）。
2. P1 引用一致性批量修：统一 `../卫星/` 前缀（task-planner SKILL.md/critical-rules.md/completion-gate.md/goal-gate.md + 各卫星 references）——文本面低风险，可派 executor 批量执行。
3. 若需修复后落盘：按 skill-fix 阶段 2（用户确认）→ 阶段 3（修复实施，Standard 66 测试副本验证），先 `bun tools/cross_caller_aligner.ts`（S61）扫引用面再改。
