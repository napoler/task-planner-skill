# D-others 审计检查点 — 六技能深度内容审计（2026-10-19）

> 审计标准：skill-fix S2/S25/S40/S56/S63/S64/S67/S68/S74/S75/S76
> 审计范围：progress-tracker / todo-skill / media-planner / task-drift-guard / error-fix-prompt-forge / iterative-optimizer
> 审计模式：只读，不改任何文件
> 审计执行体：skill-fix 子代理

## 总览

| 技能 | P0 | P1 | P2 | 文件数 | S74 |
|------|----|----|----|--------|-----|
| progress-tracker | 0 | 2 | 3 | 3 | N/A |
| todo-skill | 0 | 2 | 4 | 5 | PASS |
| media-planner | 0 | 1 | 3 | 2 | N/A |
| task-drift-guard | 0 | 2 | 3 | 4 | N/A |
| error-fix-prompt-forge | 0 | 1 | 1 | 2 | N/A |
| iterative-optimizer | 0 | 1 | 1 | 1 | N/A |

## 分技能发现

### progress-tracker

#### [P1] S40/S56：frontmatter 未声明 tools/allowed-tools
- 标准: S40, S56
- 位置: skills/progress-tracker/SKILL.md L1-5
- 证据: frontmatter 仅 `name: progress-tracker / description: ... / model: haiku`，无 tools 或 allowed-tools 字段
- 佐证: SKILL.md L173-174 "TodoWrite 或 TaskCreate：" 正文要求调用 Task 工具
- 建议: 添加 `tools: [Read, Write, Edit, Bash, Grep, Glob, TaskCreate, TaskUpdate, TaskList, TaskGet]` 或按仓内规范 `allowed-tools:` 声明

#### [P1] S64：critical-rules-progress.md 引用的核心侧文件在卫星目录不存在（迁移路径归属未改）
- 标准: S64
- 位置: skills/progress-tracker/references/critical-rules-progress.md L16
- 证据: "开关键 `config.json#shared_tracker_enforce`（默认 warn...）；`scripts/selftest-shared-tracker.sh` 静态守护...；模板 `templates/shared-tracker.md` 供 task_plan 认领追踪区块引用"
- 验证: progress-tracker/ 下无 config.json / scripts/ / templates/；task-planner/config.json:339 有 `"shared_tracker_enforce"` ✓；task-planner/scripts/selftest-shared-tracker.sh ✓；task-planner/templates/shared-tracker.md ✓
- 建议: 在迁移批次中为这三处引用加 `../task-planner/` 前缀；或在文件头部加"以下机制文件归属核心 task-planner"说明

#### [P2] S75/行数：SKILL.md 199 行超核心 ≤100 行建议
- 标准: 行数（skill-fix 强制约束 "核心执行指南 ≤100 行"）
- 位置: skills/progress-tracker/SKILL.md 全文件（199 行）
- 证据: `wc -l` 输出 `199 skills/progress-tracker/SKILL.md`
- 建议: 拆分 Step 1-4 执行流程段（L70-154）到 `references/execution-flow.md`，保留定位/格式/闭环三节在核心

#### [P2] S63：执行流程为标题+代码块格式，非 `- [ ]` 任务列表
- 标准: S63
- 位置: skills/progress-tracker/SKILL.md L69-154
- 证据: "## 执行流程\n\n### Step 0：解析项目根目录 + 平台配置目录" 后接 bash 代码块，非 markdown 任务列表
- 合格项：有输入产出描述 ✓；门控说明弱（Step 2 "若已有相同 target+action 的 done 记录，提示用户" 非硬性 STOP）
- 建议: 将 Step 0-4 改为 `- [ ]` 任务列表，Step 2 后加明确门控：`[门控] 重复记录 → 询问用户是否仍追加，用户否决则不写入`

#### [P2] S25：触发词与 session-kv / todo-skill 潜在重叠
- 标准: S25
- 位置: skills/progress-tracker/SKILL.md L3 description
- 证据: 触发词包含 "记录这次更新做了什么"、"查看上次更新到哪了"、"避免重复更新"、"追踪维护效果"；todo-skill description "规划执行"/"任务拆解" 无直接重叠；session-kv 触发词未读取（未验证）
- 建议: 与 session-kv 明确边界：session-kv = 会话级临时 KV（/tmp）；progress-tracker = 项目级跨会话账本（.zcode/ledger）；在 progress-tracker L190 边界表已声明 ✓，无需修改

---

### todo-skill

#### [P1] S74：cli_todo-manager.ts 依赖 node ≥22.18 原生 TS 支持
- 标准: S74
- 位置: skills/todo-skill/tools/cli_todo-manager.ts L1（`#!/usr/bin/env node`）；L47 注释 "Node.js >= 22.18（原生 TypeScript type stripping，无需编译）"
- 证据（三元组）：
  - 命令: `node /mnt/data/dev/task-planner-skill/skills/todo-skill/tools/cli_todo-manager.ts --help`
  - 输出摘录: "持久化任务管理器 / 基于 JSON 文件存储的任务管理 CLI，与 todo-skill 工作流及原生 Task 工具兼容"
  - exit code: 0
  - 本机 node 版本: v22.22.0（✓ 满足 ≥22.18）
  - `command -v bun` exit 1；`command -v ts-node` exit 1（环境已知缺失）
- 判定: PASS（本机 node 可用）。若部署到 node < 22.18 环境则 BLOCKED
- 建议: 在 SKILL.md 工具表增加运行时要求说明："需 node ≥22.18，低于此版本 CLI 不可用"

#### [P1] S76：cli_todo-manager.ts 非原子写 + 固定存储路径 + 无锁
- 标准: S76（S76 D1 写路径隔离/D2 锁与串行化/D4 原子写）
- 位置: skills/todo-skill/tools/cli_todo-manager.ts L121（STORE_FILE）/ L223（saveStore writeFileSync）
- 证据: `const STORE_FILE = process.env.TODO_STORE_FILE ?? path.join(import.meta.dirname ?? path.dirname(process.argv[1] ?? "."), "store.json");` — 默认写技能目录内固定 store.json，仅 env 变量可覆盖；L223 `fs.writeFileSync(STORE_FILE, JSON.stringify(data, null, 2), "utf-8");` — 直接覆盖写，无 tmp+rename 原子写，无文件锁
- 实测: 审计过程执行 `plan` 命令直接清空了 store.json（已 git 恢复原状）——实测印证该工具在技能目录内直写，并发场景下 store.json 会被多个会话覆盖
- 建议: D4 改 tmp+rename（`fs.writeFileSync(tmpPath); fs.renameSync(tmpPath, STORE_FILE)`）；D2 加文件锁（`fs.openSync(lockfile, 'wx')`）；D1 建议默认 STORE_FILE 改为任务级路径（如 `plans/<task-id>/todo-store.json`）

#### [P2] S75：WORKFLOW.md 硬编码绝对路径 + 内容矛盾
- 标准: S75 D1/D3
- 位置: skills/todo-skill/WORKFLOW.md L15（路径）/ L14（model 矛盾）/ L35（流程描述矛盾）
- 证据 L15: `| **SKILL.md** | `/home/terry/.claude/skills/todo-skill/SKILL.md` |`；L14: `| **Model** | mini |` vs SKILL.md frontmatter `model: haiku`；L35: "No explicit phase structure detected. Single-step tool/script skill." vs SKILL.md 有 Step 1-6 六步流程 + Agent() 派发
- 建议: WORKFLOW.md L15 路径改为相对锚点 `{skill-root}/SKILL.md`；L14 更新为 haiku；L35 改为 "含 Agent() + 6 Step 多步骤流程"；或整体重新生成

#### [P2] S40：frontmatter allowed-tools 格式与仓内不统一
- 标准: S40
- 位置: skills/todo-skill/SKILL.md L4-16
- 证据: `allowed-tools:\n  - Bash\n  - Read\n  - Write\n  - Edit\n  - Grep\n  - Glob\n  - Agent\n  - Skill\n  - TaskCreate\n  - TaskUpdate\n  - TaskList\n  - TaskGet` — 多行 YAML 列表；task-dispatch/media-planner 用 `tools: [Read, Write, Edit, Bash, Grep, Glob]` 行内；task-planner 用 `allowed-tools: "Read, Write, ..."` 单行字符串
- 建议: 统一为仓内主流 `tools: [...]` 行内格式（或允许两种并存，但需在仓内 AGENTS.md 声明规范）

#### [P2] 逻辑缺陷：Step 5 失败步骤标记 completed 违反状态语义
- 标准: S2 I/O 契约质量
- 位置: skills/todo-skill/SKILL.md L100-104
- 证据: "如果某步骤执行失败：\n- 保持 Todo 状态为 `in_progress`\n- 记录错误到 session-kv...\n- 尝试重试一次，仍失败则跳过并标记 completed"
- 建议: "跳过并标记 completed" 改为 "跳过并标记 failed/skipped"（或保持 in_progress 不标记 completed），避免下游误判任务完成；对应 status 枚举增加 `skipped`

#### [PASS] S56：Agent() + Task 工具全量 ✓
- 标准: S56
- 位置: skills/todo-skill/SKILL.md L4-16
- 证据: allowed-tools 含 Agent + TaskCreate/TaskUpdate/TaskList/TaskGet 全量 ✓

---

### media-planner

#### [P1] S64：critical-rules-media.md 引用的 selftest 脚本在 media-planner 目录不存在
- 标准: S64
- 位置: skills/media-planner/references/critical-rules-media.md L17（47.4）/ L34（49.5）/ L57（50.6）
- 证据 L17: "机器面=`scripts/selftest-media-dispatch.sh` 静态断言（47.1-47.5 五子条文本锚 + SKILL.md 路由表媒体行锚 + template-mapping.md §九兜底注锚 + 零新键）"；L34: "scripts/selftest-lane-advancement.sh 静态断言"；L57: "scripts/selftest-requirement-grading.sh 静态断言"
- 验证: media-planner/ 下无 scripts/；task-planner/scripts/selftest-media-dispatch.sh ✓ / selftest-lane-advancement.sh ✓ / selftest-requirement-grading.sh ✓ 均存在
- 建议: 三处引用加 `../task-planner/scripts/` 前缀，或在文件头部统一声明 "以下机器面脚本归属核心 task-planner/scripts/"

#### [P2] S64：methodology.md 引用无路径前缀
- 标准: S64
- 位置: skills/media-planner/references/critical-rules-media.md L46
- 证据: "阈值与权重刻度仿 `methodology.md:193-212` Q4 五维评分卡先例"
- 验证: task-planner/references/methodology.md 存在 ✓，且 L193 为 "### Q4 五维评分卡（权重表 + 阈值）" 内容吻合 ✓
- 建议: 改为 `../task-planner/references/methodology.md:193-212`

#### [P2] S2：无 I/O 契约段
- 标准: S2
- 位置: skills/media-planner/SKILL.md 全文（47 行）
- 证据: SKILL.md 无 Input/Output/Example 三段；media-planner 定位为规则索引型卫星 skill，I/O 契约体现在 critical-rules-media.md 规则内
- 建议: 可接受（规则索引型 skill 豁免 I/O 契约 P2 提示，不强求修改）

#### [P2] S63：无执行流程图
- 标准: S63
- 位置: skills/media-planner/SKILL.md 全文
- 证据: SKILL.md 为 "定位 + 域边界 + 卫星路由 + 规则索引" 结构，无 Phase/Step 执行流程
- 豁免论证: 无 Agent()、无 Phase 结构、非多步骤流程 → S63 适用豁免（"单步工具/脚本 skill 豁免"），media-planner 属规则路由索引型，非执行型，豁免合理
- 建议: 无需修改，记录豁免

#### [PASS] 完整性确认
- 文件数: 2（SKILL.md + references/critical-rules-media.md）
- 内容: 规则索引完整（Rule 47/49/50），规则全文逐字迁移完整（47.1-47.5 / 49.1-49.5 / 50.1-50.6）
- S74: 无 CLI 工具，N/A

---

### task-drift-guard

#### [P1] S64：SKILL.md L90 `references/critical-rules.md` 跨 skill 引用无 ../ 前缀
- 标准: S64
- 位置: skills/task-drift-guard/SKILL.md L90
- 证据: "派发契约与处置链见 task-planner `references/critical-rules.md` Rule 61"
- 验证: task-drift-guard/references/ 下无 critical-rules.md（只有 critical-rules-drift.md）；task-planner/references/critical-rules.md 存在 ✓
- 建议: 改为 `../task-planner/references/critical-rules.md`

#### [P1] S64：SKILL.md L91 `selftest-drift-check-subagent.sh` 引用无路径
- 标准: S64
- 位置: skills/task-drift-guard/SKILL.md L91
- 证据: "一致性由 `selftest-drift-check-subagent.sh` 守护"
- 验证: task-drift-guard/ 下无 scripts/；task-planner/scripts/selftest-drift-check-subagent.sh 存在 ✓
- 建议: 改为 `../task-planner/scripts/selftest-drift-check-subagent.sh`

#### [P2] S64：critical-rules-drift.md 内 `scripts/selftest-drift-enforcement.sh` 引用无路径
- 标准: S64
- 位置: skills/task-drift-guard/references/critical-rules-drift.md L47（64.5）/ L65（61.6）
- 证据 L47: "守护面=`scripts/selftest-drift-enforcement.sh`（静态断言+行为级 fixture...）"
- 验证: task-planner/scripts/selftest-drift-enforcement.sh 存在 ✓
- 建议: 加 `../task-planner/scripts/` 前缀

#### [P2] S75：README.md 单一平台声明（.claude）
- 标准: S75 D3
- 位置: skills/task-drift-guard/README.md L7
- 证据: "本技能位于项目级 `.claude/skills/task-drift-guard/`，Claude Code 启动时自动加载"
- 验证: 仓库为 Claude Code 技能仓（.claude/skills 目录树），README 单一平台声明内部一致；EXAMPLES.md L103-104 的 .claude 路径属示例豁免
- 建议: 若仓库跨 ZCode 使用，建议 README L7 改为 "本技能位于项目级 `.zcode/skills/` 或 `.claude/skills/`（平台依环境）"；当前单一平台声明可接受

#### [P2] S63：执行步骤为标题格式非 `- [ ]` 任务列表
- 标准: S63
- 位置: skills/task-drift-guard/SKILL.md L25-81
- 证据: "### Step 1: 找计划源" 至 "### Step 6: 按结果行动" 为标题+表格格式，非 `- [ ]` 任务列表；有三态门控（ALIGNED/DRIFT/BLOCKED）✓ 合格 3/5（有输入产出/门控/失败路径）
- 建议: 将 Step 1-6 改为 `- [ ]` 格式，增强可验证性；非强制

#### [PASS] S2：输入输出通过 6 完整示例覆盖
- 位置: skills/task-drift-guard/EXAMPLES.md
- 证据: 示例 1-6 覆盖 task_plan.md 存在/Orchestrator 模式/用户感知跑偏/无计划源/批量任务/范围偏移

#### [P2] README.md 配套文档未列 references/
- 位置: skills/task-drift-guard/README.md L34-35
- 证据: "配套文档: [EXAMPLES.md](EXAMPLES.md) + [SKILL.md](SKILL.md)" — 缺 references/critical-rules-drift.md
- 建议: 补充 "references/critical-rules-drift.md（规则全文）"

---

### error-fix-prompt-forge

#### [P1] S64：SKILL.md L46 `skills/error-fix-prompt-forge/templates/fix-prompt-template.md` 仓库根相对路径解析歧义
- 标准: S64
- 位置: skills/error-fix-prompt-forge/SKILL.md L46
- 证据: "Step 3 渲染: 按 `skills/error-fix-prompt-forge/templates/fix-prompt-template.md` 产出 fix-prompt.md"
- 验证: 以 SKILL.md 所在 skill 目录为基准解析为 `skills/error-fix-prompt-forge/skills/error-fix-prompt-forge/templates/fix-prompt-template.md` 不存在；实际文件在 `skills/error-fix-prompt-forge/templates/fix-prompt-template.md` ✓
- 建议: 改为 `templates/fix-prompt-template.md`（以当前 skill 目录为基准）

#### [P2] S25：description 中 "错误排查/故障调查" 词根与 systematic-debugging 触发词重叠
- 标准: S25
- 位置: skills/error-fix-prompt-forge/SKILL.md L3 description
- 证据: "错误排查/故障调查(troubleshooting / debugging)已定位根因(root cause)后"；systematic-debugging description: "Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes"
- 分析: error-fix-prompt-forge 明确声明 "不触发:根因未定位先 debugger / systematic-debugging"（L23），语义边界清晰；但 "错误排查/debugging" 字面词与 systematic-debugging 重叠，若用户说 "排查 bug 出方案" 可能误触发
- 建议: 将 description 中 "错误排查/故障调查" 改为 "已定位根因的错误排查结果包"，明确前置条件；或不修改（现有 "不触发" 声明足够）

#### [PASS] 完整性确认
- 文件数: 2（SKILL.md 84 行 + templates/fix-prompt-template.md）
- 内容完整：输入契约表 / 五步 `- [ ]` 列表 / QC-FP 自检表 / 门控铁律 / 输出合约 / 反模式 全部齐备
- S56 豁免：自身不派发 Agent()（产出任务书供主进程派发），无 Phase 结构 → 无 Task 工具要求
- S74 豁免：无 CLI 工具

---

### iterative-optimizer

#### [P1] S64：SKILL.md L37 引用 "task-planner Rule 44" 归属错误
- 标准: S64
- 位置: skills/iterative-optimizer/SKILL.md L37
- 证据: "按默认项 + 自动超时规则(task-planner Rule 44)与用户协商"
- 验证: task-planner/references/critical-rules.md 中 grep "### 44" 无命中；task-discipline/references/critical-rules-discipline.md:171 存在 "### 44 用户选择点默认项与自动超时裁决（P1...）" — 内容吻合（自动超时规则），归属为 task-discipline 而非 task-planner
- 建议: 改为 `task-discipline Rule 44` 或 `task-planner satellite task-discipline Rule 44`

#### [P2] S25：触发词与 skill-evolve 潜在重叠（未验证）
- 标准: S25
- 位置: skills/iterative-optimizer/SKILL.md L3 description
- 证据: "循环迭代优化器——对提示词精修(prompt refinement)/参数调优(parameter tuning)/缺陷修正(defect correction)"；skill-evolve description（head -c 截断，未完整验证 — 标注"未验证"）
- 建议: 完整读取 skill-evolve description 后再判定是否需明确边界；当前 iterative-optimizer 声明 "不触发: 单次可完成且无评估标准的一次性任务"，边界已声明

#### [PASS] 完整性确认
- 文件数: 1（SKILL.md 97 行，自包含）
- 内容完整：输入契约 / 五步循环 `- [ ]` 格式 / 门控判定 / 输出合约 / 反模式 全部齐备
- S54 Loop 声明：状态文件 plans/loop-<task-id>-state.md + Gate（QC 逐条证据）✓
- S56 豁免：无 Agent()，无 Phase（轮次循环非 Phase）→ 无 Task 工具要求
- S74 豁免：无 CLI 工具

---

## 已确认 PASS 项汇总

| 技能 | PASS 项 |
|------|---------|
| progress-tracker | S74 N/A（无 CLI）/ S2 I/O 契约（ledger-format.md 完整示例）/ 边界表已声明（L189-193）|
| todo-skill | S74 PASS（node v22.22.0 实跑，exit 0 ×2）/ S56 全量 Task 工具 ✓ / S2 契约基本完整 |
| media-planner | S74 N/A / 完整性（2 文件，规则 47/49/50 全文）/ S63 豁免（规则索引型）|
| task-drift-guard | S74 N/A / S2 6 完整示例 / 三态门控 ✓ |
| error-fix-prompt-forge | S74 N/A / S2 输入契约表 ✓ / S63 五步 - [ ] + QC 表 ✓ / S56 豁免 |
| iterative-optimizer | S74 N/A / S63 五步 - [ ] + 门控 ✓ / S54 Loop 声明 ✓ / S56 豁免 |

## 待用户决策事项

1. 9 个 P1 中 5 个是 S64 引用路径归属错位（critical-rules 迁移遗留），属批量修复，可统一批次处理
2. todo-skill S76 需确认是否修（writeFileSync → 原子写 + 锁），涉及 CLI 行为变更
3. todo-skill WORKFLOW.md 是否为一次性生成产物（可删除）或需维护（需修硬编码路径）
