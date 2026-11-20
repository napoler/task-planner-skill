# Task Plan: 指针切换设计缺陷修复
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- template-lineage: level=base spec_version=1 -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「目前这个技能当然还是存在一个严重的问题，就是每次执行任务的时候都会去扫描其他的技能，同步开发的技能没有问题，但是我发现每次都提示指针错误，这是不是当时当前技能的设置缺陷？因为当前设计缺陷导致的就是每次都会来回的切换指针，是不是存在问题？  因为这样的话，你导致的明确的每次都在浪费在这个时间上。我感觉应该是设计缺陷，以下是存在的缺陷的一些，就是说绘画中的一些片段，我希望你可以理解，然后帮我修正这个问题，不希望再出现这种低级错误。」<sub>（[目标]）</sub>

> 来源锚：`plans/task-pointer-switch-defect-20261120/user-session-log.md#1`（逐字原文与会话片段）；本 R1 为用户核心诉求原文抄录，冲突以专档逐字条目为准。

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-4, VC-5 | 同 sid 在途 claimant 场景下 init 一次写入 side 指针且输出通告无 skip（VC-1）；set-active-plan skip 路径输出明确「指针未切换」且调用点影响评估留痕（VC-2）；in_progress 守卫锚定状态控制行不误命中模板字样（VC-3）；SKILL D/E 切换清单释放旧 `.session-owner` 口径落盘（VC-4）；既有 selftest 基线+新增场景断言通过且无新脚本文件（VC-5） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-pointer-switch-defect-20261120/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧭 指令理解迭代草稿（Rule 28.2.2 — 执行前方向对齐｜粗稿非定稿）
- **① 原始指令复述（锚）**：用户报告 task-planner 在新任务 init 或 D 类意图切换时反复提示「指针仍被旧计划声明，需 --force 覆盖」，导致 2-3 次交互才切换成功、浪费时间；用户判断为设计缺陷，要求理解会话片段中的缺陷并修正，避免再现。冲突以 `user-session-log.md#1` 原话为准。
- **② 模型理解（理解1）**：目标=根治活跃计划 side 指针切换缺陷，使同会话明确切换意图（新计划 init / D 类切换）一次完成；对象=指针守卫与意图切换流程（init-session.sh、set-active-plan.sh、SKILL.md）及对应自测；范围=G1-G4 修复+场景重现验证+部署同步合并回；约束=只写计划文档阶段不改技能源文件、执行期改既有脚本/SKILL/selftest 断言不新建脚本/守护基建（文本优先铁律）、worktree 已建需隔离开发后合并回；验收=用户痛点场景一次切换成功可复现。**不做什么**：不改「扫描其他技能」行为（推断（理解镜像 #1，原话『同步开发的技能没有问题』））；不新增 hook/守护脚本/registry 基建；不改 user-session-log.md；不执行 init-session.sh/attest-plan.sh/set-active-plan.sh。
- **③ 思路与候选（思路2）**：根因已由 Explore 调研落盘 `findings.md`（三环缺陷+守卫误伤面）。候选路径：A) 最小修补仅 G1（推荐基础）→ 仍遗留 D 类未释放 `.session-owner` 与误命中面；B) G1+G2+G3+G4 四件套闭环（**推荐**）——同时消除守卫误判、流程未释放占用、skip 语义含糊，满足「不再出现」；C) 改为全局 force/放宽守卫→破坏防沿袭互踩安全性（否决）。歧义门控：`明确-按默认路径`（B，用户已给缺陷方向与根治意图，方案骨架确定）。
- **④ 大体执行方向（思路3/4）**：Phase 1 在 worktree 修复脚本 G1+G3+G4（init 同 sid 在途 claimant 改为明确通告+直接写；in_progress 判定锚定状态控制行；set-active-plan skip 输出明确「指针未切换」前缀并评估 exit code 调用点）；Phase 2 修 SKILL.md G2（D 类①释放旧 `.session-owner`，E 类/Rule 94 同步）；Phase 3 扩展既有 `selftest-pointer-lifecycle.sh` 并跑场景重现 bash 验证；Phase 4 部署同步+合并回主仓+回归。验收以 VC-1 场景重现一次通过为核心判据。

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 新计划 init 写 side 指针 | 同 sid 在途 claimant（旧计划 in_progress）命中守卫→`SKIP_SIDE_WRITE=1` 静默失切，无 force 通道，与「init 于新计划目录=明确切换意图」冲突（`init-session.sh:1229-1256`）；且 freshness fallback 抢用他会话哨兵 sid（`init-session.sh:1205-1207`）时直写会覆盖他会话 side 键（D3 事故路径） | P1/S1：init 该分支改为明确通告+直接写（内置 force 语义），通告含旧 claimant 名与挂起/恢复提示；保留 claimant 不存在/已 complete 的 fail-open。G1 门控：fallback 抢用分支置 `_sid_fallback=1`，通告+直写仅在 SIDKEY 来自 env/sidmap（身份确定）时生效，fallback 时保留 skip+WARN（提示会话 id 未确定） | VC-1, VC-3 |
| 手动切指针 `set-active-plan.sh set` | 同类守卫 skip 时 exit 0 且文案易误判成功；in_progress 全文 grep 可误命中模板字样（`set-active-plan.sh:259-278` 守卫整体，`:203-209` gc 已锚定但 claimant 未锚定） | P1/S2：skip 路径（`:265` 文案/`:266` `SKIP_SIDE_WRITE`/`:278` skip exit 0）输出明确「指针未切换」前缀；评估调用点后决定 exit code（默认保持 0 仅强文案）；claimant in_progress 判定收窄为状态控制行锚定（兼容非加粗形态） | VC-2, VC-3 |
| D 类意图切换流程 | 清单①仅挂起登记不删旧计划 `.session-owner`、不改 Status，守卫必然再命中（`SKILL.md:220`）；E 类/Rule 94 隔离处置未声明释放占用（`SKILL.md:227`）；删 owner 后回切首轮 Edit 不触发重锁（`zcode-posttooluse.sh:154-156` 前置 `owner==SID`），下次 prompt 报 PLAN TAMPERED | P2/S3：D 类①追加删除旧 `.session-owner`（挂起=会话不再认领，回切时 hook 自动重建）；补口径「回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md」并纳入 VC-4 文本锚点；E 类/Rule 94 同步补口径 | VC-4 |
| 守卫匹配面 | `grep -qi 'Status.*in_progress'` 扫全文，模板示例/注释/散文含字样即误伤，扩大无谓拦截；真实样本存在非加粗形态（如 `plans/task-goal-autonomous-20261117/task_plan.md:7`） | P1/S1,S2：统一锚定为状态控制行，兼容非加粗形态 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`（与 gc anchored 风格一致，覆盖非加粗不漏判） | VC-3 |
| 回归与交付 | 修复后场景未被自动化守护、既有指针生命周期基线可能回退、部署位不同步 | P3/S4：既有 `selftest-pointer-lifecycle.sh` 扩展+场景重现 bash；P4/S5：部署同步/合并回与回归留痕 | VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1 用户诉求（一次切换、不再反复报指针错误/多次 --force）；Goal 与 VC-1~VC-5 判据；防沿袭互踩的所有权语义不得退化为全局无条件放行；既有 fail-open 方向（claimant complete/不存在时继续）不回退；`user-session-log.md` 只写不改 | `## R1` / `## Goal` / `## Verification Contract` / user-session-log.md 头部铁律 |
| 🔀 可变量 | G1/G3/G4 的具体正则细节与通告文案措辞（须保持语义等价且可测）；S-unit 内部拆分与执行顺序微调；G4 exit code 最终取值（经调用点评估后在 Decisions 登记） | 本计划 Phases/S-units/Decisions |
| 📈 学得量 | 执行期发现的额外调用点、selftest 兼容性细节、部署位差异与回归证据→`findings.md`/`progress.md`/`notepad-learnings.md`；禁反向改写已锁 R/Goal/VC | findings.md, progress.md, notepad-learnings.md |

## 🔒 规范基线（Spec-Baseline，Rule 51.15 — 含已确立硬约束时必填）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 |
|---------|-------------------|------------------|-----------|------------|
| SPEC-SCOPE-01 | 你只写计划文档，不执行 Phase 不改技能源文件。 | `plans/task-pointer-switch-defect-20261120/user-session-log.md`（本轮任务委派指令，2026-11-20） | 计划编写阶段仅改 task_plan/findings/knowledge-brief/progress/verification；技能源文件改动=FAIL | n/a(文本片段) |
| SPEC-NO-INFRA-01 | 计划里不得要求新增 hook/守护基建（文本优先铁律：修复=改既有脚本分支+SKILL 条款+selftest 断言，不新建脚本文件；selftest 断言可加入既有 selftest 文件） | 同上委派指令 | 执行计划不得包含新建脚本/hook/守护文件动作；仅既有文件修改/既有 selftest 扩展=PASS | n/a(文本片段) |

## 📦 进度产出基线（Rule 111 进度产出防倒退）
| 基线项 | 动工前快照 | 关键产出/指标 | 禁倒退清单 | 状态 |
|--------|------------|---------------|------------|------|
| B-01 指针守卫 fail-open 语义 | `init-session.sh:1239-1245` claimant complete/不存在→INFO fail-open 继续；`set-active-plan.sh:279-281` 同语义；gc anchored completed-ttl `set-active-plan.sh:203-209` | 明确切换可一次成功，但 claimant 已 complete/不存在场景仍 fail-open；完成态 gc 仍按锚定状态行判定 | 禁删除 fail-open 分支；禁回退 gc completed-ttl 锚定逻辑；禁把守卫改为无条件全放行 | 已登记 |
| B-02 指针生命周期 selftest 基线 | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（PL-01..PL-10，静态7+行为3，exit 0=10 PASS） | PL-01..PL-10 断言与行为夹具持续通过 | 禁降低既有 PL-01..PL-10 断言强度/数量（可因 G4 文案微调做兼容性调整须保语义）；禁移除行为夹具隔离性（/tmp mktemp） | 已登记 |
| B-03 前任务收口与 worktree 基线 | 主仓 master `f4dc96b`（遗留 18M+9untracked 收口）；worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120` 分支 `wt/task-pointer-switch-defect-20261120` | 合并回后不回退 f4dc96b 收口内容；修复限定 skills/task-planner 指针相关既有文件 | 禁回退 f4dc96b；禁扩大 scope 到与指针切换无关文件 | 已登记 |
| B-04 源仓/部署位指针脚本同构认知 | findings.md：源仓与 `~/.zcode` 部署位 5 个指针脚本 diff 为空（调研结论）；执行期需按实际复核 | 合并回后主仓修复落盘，部署同步按项目既有机制对齐（不在计划编写期臆断） | 禁遗漏部署同步步骤；禁凭空声称已同步而无证据 | 已登记 |

> 无候选时：在上表填一行 `none-justified | <理由> | n/a | n/a | 已登记`（禁止留空/静默省略）。

## Goal
根治 task-planner 新任务 init 与 D 类意图切换场景下活跃计划 side 指针被旧在途 claimant 误拦、需多次 `--force` 交互的问题，使同会话明确切换意图下一次写入成功并输出清晰通告与正确流程释放。

**边界声明（I-3）**：本任务保证 init 新计划与收口后回切一次成功；同会话多在途计划间手动切换（两计划皆 in_progress）依设计仍走 `--force`（VC-2 仅验收提示清晰，非放行该类手动切换）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `task-pointer-switch-defect-20261120` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-planner/scripts/init-session.sh, skills/task-planner/scripts/set-active-plan.sh, skills/task-planner/SKILL.md, skills/task-planner/scripts/selftest-pointer-lifecycle.sh` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `silent`（缺省可按 config；执行期关键阻塞仍 STOP） | Rule 28 交互模式 |
| `对齐审查` | `[登记]` 交付前对 SKILL.md 流程条款与脚本行为/VC 证据做 alignment-review 对齐检查（standard 档） | Rule 42.6 消费 |
| `自动超时默认项` | `G4 exit code 策略: 默认保持 exit 0 仅改文案(推荐)/5min；如调用点评估显示可安全升级再改码` | Rule 44 消费 |
| `new_rule` | 留空 | Rule 20.6：无新增 Rule 编号 |
| `质量审查工具` | `code-quality-review(脚本改动)、verification-gate(VC/run-verification 口径)、既有 selftest-pointer-lifecycle.sh 作为回归基线；缺口通过扩展既有 selftest 文件覆盖（不新建脚本）` | Rule 42 消费登记 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 场景重现：伪造旧计划 `in_progress` + `.session-owner` 占用同 sid，新建计划目录后运行 `init-session.sh`（worktree 版）→ side 指针一次写入新计划、输出含旧 claimant 与挂起/恢复提示的通告行、无 `skip 写入`/无 `--force` 需求 | 运行 `verification.md` 中 VC-1 可执行 bash（/tmp 隔离夹具） | `verification.md` VC-1 Verify command + 终验输出摘录 |
| VC-2 | `set-active-plan.sh set` 在被在途 claimant 拦截且未带 `--force` 时，输出明确含「指针未切换」前缀（stderr/stdout 可观测）且文案不再可误读为成功；同会话多在途计划间手动切换（两计划皆 in_progress）依设计仍走 `--force`，本 VC 仅验收提示清晰。exit code 策略经调用点评估登记（默认保持 0，除非评估通过） | 静态检查脚本 skip 分支文案 + 行为夹具断言输出；调用点评估记录见 findings/progress | `verification.md` VC-2 Verify command |
| VC-3 | `init-session.sh` 与 `set-active-plan.sh` 的 claimant in_progress 判定锚定状态控制行，兼容非加粗形态 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`，不再全文裸匹配 `Status.*in_progress` 导致模板散文/注释误命中 | 正向锚定调用行+反向剥注释无裸匹配（对规范修复可绿、未修复现状红）；补非加粗不漏判夹具 | `verification.md` VC-3 Verify command |
| VC-4 | `SKILL.md` D 类意图切换执行清单①明确包含删除旧计划 `.session-owner`（挂起=会话不再认领，回切时 hook 自动重建）步骤，并补「回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md」口径；E 类/Rule 94 隔离处置段同步补对应释放占用口径 | 文本锚点 grep（D 类块与 Rule 94 段边界至下一个 `###`） | `verification.md` VC-4 Verify command |
| VC-5 | 无新增脚本/守护基建文件；`skills/task-planner/scripts/selftest-pointer-lifecycle.sh` 基线 PL-01..PL-10 语义保留且通过，新增场景断言（init 一次切换/通告/fallback 门控/非加粗不漏判）通过；worktree 改动限 scope_files | `git status --porcelain --untracked-files=all` 全量判别（修复前红/后绿）+ 运行 selftest 脚本（worktree） | `verification.md` VC-5 Verify command |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认全适用：P1(S1,S2)、P2(S3)、P3(S4)、P4(S5) 均为派发型/实质产出单元（脚本/SKILL/selftest/合并同步与证据） |
| 豁免登记 | none |
| 多文件变更集预判 | P1 预计触发（init-session.sh + set-active-plan.sh 同改守卫语义）；P3 若扩展 selftest 与 P1 联动亦属多文件集；各 Phase 翻转前执行 Rule 103.6 同步核对清单（脚本↔SKILL↔selftest↔文案/exit 语义关联面） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 |
| **裁决** | 待终验填写（`solved` / `partial` / `not-solved`） |
| **解决证据锚** | 待终验回填（VC-1 场景重现输出+指针文件证据、VC-2~VC-5 证据） |
| **未解决面+原因** | 待终验回填（如有） |
| **已排除路径** | 待终验回填（如 not-solved） |
| **下一步建议** | 待终验回填（如 not-solved） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | init直写切换 | init 遇同 sid 在途 claimant 且身份确定（env/sidmap）时通告并一次写入新计划 side 指针；fallback 抢用 sid 时保留 skip+WARN 防 D3 覆写 | VC-1 bash 场景重现：指针文件内容=新计划且输出含通告无 skip；CA-6 补 fallback 夹具 | S1/Phase 1 | done |
| G2 | set提示清晰 | set-active-plan 被拦截时明确提示指针未切换且语义不误导 | VC-2 行为夹具+文案锚点；调用点评估记录 | S2/Phase 1 | done |
| G3 | 守卫防误伤 | in_progress 判定仅命中状态控制行，兼容非加粗形态 | VC-3 正向锚定调用行+反向剥注释无裸匹配；CA-6 补非加粗不漏判夹具 | S1,S2/Phase 1 | done |
| G4 | 流程释占用 | D/E 切换流程释放旧 `.session-owner` 并同步口径，回切前补 attest/prompt 重建 owner 避免 PLAN TAMPERED | VC-4 SKILL.md 锚点命中（D 类①含回切 attest 口径+Rule 94） | S3/Phase 2 | done |
| G5 | 回归可证 | 既有基线不降且场景断言落地 | VC-5 selftest 运行通过+git diff 范围检查 | S4,S5/Phase 3,4 | done |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | `skills/task-planner/scripts/init-session.sh`, `skills/task-planner/scripts/set-active-plan.sh`, `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（worktree 内对应路径） | 其他脚本/新增脚本文件/hook |
| 技能文档 | `skills/task-planner/SKILL.md`（worktree 内） | 其他技能文件、`~/.zcode` 保护区直接改写 |
| 计划文档 | `plans/task-pointer-switch-defect-20261120/{task_plan,findings,knowledge-brief,progress,verification,notepad-learnings}.md`（主仓计划目录，本阶段已写） | `user-session-log.md`（append-only 专档，禁改） |
| 配置 | 无 | `package.json`/CI/守卫配置/registry 等非必要配置 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | `skills/task-planner/scripts/init-session.sh:1205-1207,1229-1256`（sidmap/freshness fallback 与同 sid claimant in_progress→SKIP_SIDE_WRITE 守卫/side 写入） | 修改 | 替代（四条件满足：明确切换意图下 skip 语义错误/冗余，通告+直写可验证替代） | 「帮我修正这个问题，不希望再出现这种低级错误。」 | findings.md 缺陷①；实读代码锚 | 将 claimant 在途分支改为明确通告+直接写 side 指针（通告含旧 claimant 与挂起/恢复提示）；保留 fail-open。G1 门控：fallback 抢用分支置 `_sid_fallback=1`，通告+直写仅在 SIDKEY 来自 env/sidmap（身份确定）时生效，fallback 时保留 skip+WARN（提示会话 id 未确定），防覆盖他会话 side 键（D3 路径）；CA-6/selftest 扩展项补该夹具断言 |
| CA-2 | `skills/task-planner/scripts/init-session.sh:1235`、`skills/task-planner/scripts/set-active-plan.sh:273`（claimant in_progress 判定） | 修改 | 替代（全文裸匹配误伤，锚定判定等价且更安全） | 同上 | findings.md 守卫误伤面；模板 Status 行 `- **Status:** in_progress`（templates/task_plan.md:315）；非加粗样本 `plans/task-goal-autonomous-20261117/task_plan.md:7` | 统一改为锚定状态控制行正则，兼容非加粗形态 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`；可选增强（登记）：阻塞者选取从 glob 首命中改为 owner mtime 最新（降低并发残留误选概率） |
| CA-3 | `skills/task-planner/scripts/set-active-plan.sh:259-278`（守卫整体，`:265` skip 文案 / `:266` `SKIP_SIDE_WRITE` / `:278` skip exit 0） | 修改 | 替代（文案误导成功） | 同上 | findings.md 缺陷③；实读代码锚 | skip 输出增加明确「指针未切换」前缀；评估调用点后决定 exit code（默认保持 0 并登记） |
| CA-4 | `skills/task-planner/SKILL.md:220`（D 类意图切换执行清单①） | 修改 | 更新（增量补充步骤，保留原清单结构） | 同上 | findings.md 缺陷②；实读 SKILL 锚；`zcode-posttooluse.sh:154-156` owner 前置重锁行为 | ①追加删除旧计划 `.session-owner`（挂起释占用，回切 hook 自动重建）；并补口径「回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md」，避免 owner 缺失导致首轮 Edit 后 prompt 报 PLAN TAMPERED；该口径纳入 VC-4 文本锚点断言 |
| CA-5 | `skills/task-planner/SKILL.md:227`（E 类/Rule 94 隔离处置） | 修改 | 更新（口径同步） | 同上 | findings.md G2；实读 SKILL 锚 | 补充隔离/封存时释放旧 `.session-owner` 以避免指针切换被误拦 |
| CA-6 | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（行为断言扩展） | 修改 | 增量（新增断言，不削弱 PL-01..PL-10） | 同上 | VC-1/VC-5；既有 selftest 结构实读 | 新增 init 场景断言（同 sid 在途 claimant→新 init 一次写入+通告无 skip），保持 /tmp 夹具隔离；并补 I-1 fallback 抢用 sid（`_sid_fallback=1`）时保留 skip+WARN 不直写的夹具断言，以及 W-1 非加粗 `Status: in_progress` 不漏判夹具断言 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 本任务根因调研结论 | `/mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/findings.md:48-75` | 必读 | ☑ |
| 项目内部文档/知识库 | 既有指针生命周期自测 | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（worktree，PL-01..PL-10） | 必读 | ☑ |
| 项目内部文档/知识库 | 指针/side 解析与守卫实现 | `skills/task-planner/scripts/init-session.sh:1160-1295`、`skills/task-planner/scripts/set-active-plan.sh:180-320`（worktree） | 必读 | ☑ |
| 项目内部文档/知识库 | 意图切换流程契约 | `skills/task-planner/SKILL.md:220,227`（worktree） | 必读 | ☑ |
| 项目内部文档/知识库 | Status 行格式基准 | `skills/task-planner/templates/task_plan.md:315,333,346,376,397`（worktree） | 必读 | ☑ |
| 规范/标准 | 指针竞态历史知识 | `knowledge/entries/worktree-parallel-pointer-race.md` | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 修复 side 指针所有权守卫与 D 类切换流程，使同会话明确切换意图（新计划 init / 意图切换）一次写入成功且不再产生误导性 skip/--force 循环，问题解决后用户可无额外交互完成计划切换。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？（VC-1 场景可复现一次成功即交付用户痛点修复）
- [x] 核心问题不解决，其他工作都白费吗？（不修守卫/流程则 D 类切换仍需 2-3 次交互）
- [x] 核心问题的解决方法是清晰的、可执行的？（G1-G4 四点对应明确代码/文案/流程落点与回归测试）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1 init 守卫修复 | LOCAL-ONLY | `SKIP_SIDE_WRITE`, `.session-owner claimant in_progress` | 本地代码/历史知识条目 | 代码分支修改+通告文案 | 否 |
| S2 set-active-plan 守卫与 skip 语义 | LOCAL-ONLY | `set-active-plan skip`, `set-active-plan callers` | 本地 grep/代码阅读 | 文案+exit 策略登记 | 否 |
| S3 SKILL D/E 流程 | LOCAL-ONLY | `意图切换执行清单`, `Rule 94 隔离` | 本地 SKILL.md | 流程条款更新 | 否 |
| S4 自测与场景重现 | LOCAL-ONLY | `selftest-pointer-lifecycle`, `init side pointer fixture` | 本地既有 selftest + bash 夹具 | 断言扩展+VC 证据 | 否 |
| S5 部署同步/合并回 | LOCAL-ONLY | `smart-merge-back`, `deploy sync` | 本地 git/脚本 | 合并与同步证据 | 否 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决；NET-RESEARCH/NET-DATA-DEPENDENT 本任务无。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）——本表显式全 LOCAL-ONLY，满足“有登记”。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | `init-session.sh:1229-1256`、`set-active-plan.sh:263-291`、`SKILL.md:220,227`、`selftest-pointer-lifecycle.sh`（PL-10） | Read + grep 行号锚定 | `findings.md:48-75`、本计划 CA-1~CA-6 | ☑ |
| ② 对标样本（58.2 强制） | 历史指针竞态修复与约束：`knowledge/entries/worktree-parallel-pointer-race.md`、`selftest-pointer-lifecycle.sh` 既有 PL 设计（fail-open/--force 语义） | Read 历史知识与既有守护断言 | `knowledge-brief.md §4`、B-01/B-02 基线 | ☑ |
| ③ 外部约束 | task-planner 指针体系事实（side/sid/TTL/resolve 优先级）与 hook 重建 `.session-owner` 行为（调研结论） | Explore 调研结论回填 + 本地脚注释/行为 | `findings.md:64-68` | ☑ |

> 归因类结论（指针反复报错原因）已在 ②③ 支撑下落盘（findings.md），执行修复不先于证据。

## Current Phase
Phase 1

## Next Step
获批后在 worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120` 执行 Phase 1：派 `general-coder` 完成 S1(init-session.sh G1+G3) 并主进程复核 diff/行号锚点。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 `general-coder`（代码/脚本修改）+ 主进程复核；机械守卫脚本（grep/bash 自检） | 脚本逻辑修改需精确编辑与可复核 diff，主进程控范围与证据 |
| Phase 2 | Agent 子代理 `general-coder` 或主进程受控编辑 + Read/grep | SKILL.md 流程条款小范围精准更新，需与脚本语义对齐 |
| Phase 3 | Agent 子代理 `Verifier`/`code-runner-agent`（验证）+ Bash（/tmp 夹具） | 场景重现与 selftest 需独立执行证据，避免主进程自测冒充验收 |
| Phase 4 | 主进程 git 编排 + 机械守卫脚本（diff/selftest/check-complete 视交付流程） | 合并/部署同步属簿记与编排，需最终一致性复核 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（无 ≥3 独立 fan-out 且非长链编排型，非用户点名）→ 采用 Rule 21.4 独立性守门调度（P1 内 S1/S2 可并行评估但共享同语义面，默认串行更稳；按 S-unit 前置依赖执行）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；未见用户侧 /goal 额外锚定命令。

## Phases

### Phase 1: 脚本修复（G1 + G3 + G4）
- [x] S1：修复 `init-session.sh` 同 sid 在途 claimant 分支为明确通告+直接写（内置 force 语义，限 env/sidmap 身份确定；fallback 抢用 sid 置 `_sid_fallback=1` 时保留 skip+WARN），并将 in_progress 判定锚定状态控制行（兼容非加粗形态）
- [x] S2：修复 `set-active-plan.sh` claimant in_progress 判定锚定（兼容非加粗形态）、skip 路径（`:259-278` 守卫整体，`:265` 文案/`:266` `SKIP_SIDE_WRITE`/`:278` exit 0）输出明确「指针未切换」前缀，并评估 exit code 调用点后登记策略（默认不改码）
- [x] 主进程复核 diff 与行号锚点、确认无全文裸 `Status.*in_progress` 残留于 claimant 守卫
- **V-N:** VC-1, VC-2, VC-3（本 Phase 验收映射的 VC 编号）
- **Status:** complete
- **Executor:** general-coder（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 在 init 中把同 sid 在途 claimant 从 skip 改为通告+直写并锚定 in_progress（含 G1 fallback 门控） | 继承 | `skills/task-planner/scripts/init-session.sh:1205-1207,1229-1256`（fallback/sidmap 与 claimant 守卫+side 写）；`findings.md:55-63`（G1/G3） | 身份确定（env/sidmap）时 claimant 分支通告+直写、不再置 `SKIP_SIDE_WRITE=1` 阻断同会话切换；fallback 抢用（`_sid_fallback=1`）时保留 skip+WARN 不覆盖他会话 side 键；输出含 claimant 与挂起/恢复提示；in_progress 用状态行锚定且兼容非加粗形态 | 15min | 1f/80l/15min | 无 | - | pending |
| S2 | (A6) 在 set-active-plan 中锚定 in_progress 并强化 skip 的「指针未切换」语义+调用点评估 | 继承 | `skills/task-planner/scripts/set-active-plan.sh:259-278`（守卫整体，`:265` 文案/`:266` `SKIP_SIDE_WRITE`/`:278` exit 0）；仓内 `set-active-plan.sh` 调用点 grep 结果 | claimant 判定锚定状态行且兼容非加粗形态；skip 文案含「指针未切换」；exit code 策略有评估记录（默认保持 0） | 15min | 1f/40l/15min | 无 | - | pending |

### Phase 2: SKILL 流程修复（G2）
- [x] S3：更新 `SKILL.md` D 类意图切换执行清单①，追加释放旧计划 `.session-owner` 步骤与回切自动重建说明
- [x] 同步更新 E 类/Rule 94 隔离处置段，保证挂起/封存不遗留 `.session-owner` 占用
- [x] 主进程复核条款与脚本语义一致（init 可直写 + 流程先释占用）
- **V-N:** VC-4, VC-1（本 Phase 验收映射的 VC 编号）
- **Status:** complete
- **Executor:** general-coder（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | (A6) 修改 D 类清单①与 E 类/Rule 94 口径，挂起时释放旧 `.session-owner` 并补回切 attest 口径 | 继承 | `skills/task-planner/SKILL.md:220`（D 类执行清单）、`:227`（E 类/Rule 94）；`findings.md:57,73`；`zcode-posttooluse.sh:154-156` | D 类①含删除旧计划 `.session-owner` 及回切 hook 重建说明，并含「回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md」口径（纳入 VC-4 锚点）；E 类/Rule 94 同步口径 | 10min | 1f/30l/10min | 无 | S1 | pending |

### Phase 3: 自测与场景重现验证（VC-1 核心）
- [x] S4：在既有 `selftest-pointer-lifecycle.sh` 中新增 init 场景断言（同 sid 在途 claimant→新 init 一次写入+通告无 skip），保持 /tmp 夹具隔离与既有 PL 语义
- [x] 运行 `verification.md` VC-1 场景重现 bash 与扩展后 selftest，收集证据
- [x] 核对 VC-2/VC-3/VC-4/VC-5 的静态与行为证据
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5（本 Phase 验收映射的 VC 编号）
- **Status:** complete
- **Executor:** Verifier（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S4 | (A7) 扩展 selftest-pointer-lifecycle 新增 PL-11+ 行为断言（四类场景） | 继承 | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（PL-01..PL-10 结构与 /tmp 夹具范式）；P1/P2 改动后脚本 | 新增断言落盘且 selftest 跑通 FAIL=0；覆盖 init 一次切换/通告输出/fallback `_sid_fallback=1` 保留 skip+WARN/非加粗 `Status: in_progress` 不漏判四类场景（每类≥1 条 PASS PL-1x） | 15min | 1f/80l/15min | 无 | S2, S3 | pending |
| S4b | (A7) 执行 VC-1~VC-5 全量证据采集与记录 | 继承 | `verification.md` VC 命令；worktree 修复后脚本与 SKILL | VC-1~VC-5 逐条 exit 0，输出/证据路径回填 verification.md 与 progress.md | 10min | 0f/10l/10min | 无 | S4 | pending |

### Phase 4: 部署同步、合并回与交付
- [x] 复核 worktree `git status/diff` 限 scope_files 且无新建脚本；全 VC 证据齐备
- [x] 按项目既有流程部署同步（源仓修复→部署位，实测对齐）并记录证据
- [x] 合并回主仓 master（`--no-ff` 或项目约定）并清理 worktree/分支，主仓 Read 复验关键锚点
- [x] 防倒退终检、收尾回读梳理记录、归档准备（按 Rule 81/111/84.14）
- **V-N:** VC-5, VC-1（本 Phase 验收映射的 VC 编号）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | (A6) 完成部署同步、合并回与终检交付记录 | 继承 | worktree 改动与 VC 证据；`git worktree`/merge 流程；部署位 `~/.zcode/skills/task-planner/` 同步约定（实测） | scope 合规、主仓含修复锚点、worktree 清理、B-01..B-04 无倒退证据 | 15min | 2f/20l/15min | 无 | S4 | pending |

### Phase 5: Delivery
- [x] Review all output files
- [x] Ensure deliverables are complete
- [x] Deliver to user
- [x] 全文档收尾回读梳理记录（Rule 84.14）：全量回读六文档体系→五维互洽→偏移迭代→收敛出口（连续一轮零新发现）后才出 outcome
- [x] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh task-pointer-switch-defect-20261120 --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
- [x] 知识提取入库（条件式：项目存在 scripts/kb-sync-from-plan.sh 知识库机制则必做；不存在则登记「跳过：无知识库机制」）：`bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft → 精炼改名（去 _draft- 前缀、补行号锚、主题化去重）→ `bash scripts/kb-rebuild-index.sh`；条目规范见 knowledge/README.md
- **V-N:** VC-1, VC-5（本 Phase 验收映射的 VC 编号）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🛡 防倒退终检（交付/合并前强制）
| 检查项 | 判定方法（机器/可复核） | 证据锚 | 结果 |
|--------|-------------------------|--------|------|
| 既有能力未削弱 | 对照 📦 基线 B-01~B-04：fail-open/gc anchored/selftest PL 语义/f4dc96b 不回退 | `grep -n` fail-open 分支、selftest 输出、`git show --name-only f4dc96b` 对照 | <PASS/FAIL> |
| 模板解析兼容 | 修改后脚本仍可被 bash 解析；SKILL 仍含意图切换清单锚点；模板 Status 格式未破坏守卫锚定 | `bash -n init-session.sh set-active-plan.sh`、VC-4 grep | <PASS/FAIL> |
| 净效果≥0 逐项对照 | 守卫收窄与流程释占用提升切换成功率；无受管能力删除/降级 | CA-1~CA-6 执行记录 | <PASS/FAIL/不适用> |
| selftest 同集零增量 | 与动工前 PL-01..PL-10 基线对比无新增 FAIL（新增断言应 PASS） | VC-5 selftest 输出 | <PASS/FAIL> |
| 部署位无漂移 | 源仓与 `~/.zcode/skills/task-planner/` 对应修复文件对齐（按实际部署机制实测） | `diff` 或部署脚本输出证据 | <PASS/FAIL/不适用> |

> 净效果判据（Rule 111）：既有产出的删除/降级/替换须登记消费方影响评估且**净效果≥0**，否则 `BLOCK`（禁止拆东墙补西墙，`[PROGRESS-REGRESSION]`）。

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    | 待执行期填写                 | 待执行期填写         |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（实现类改动触达 skills/task-planner 运行中脚本与 SKILL.md；需隔离开发） |
| `isolation` | `worktree`（已按默认首选创建并在此执行计划落盘） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120` (Rule 100:tmp/ 入 .gitignore) |
| `branch` | `wt/task-pointer-switch-defect-20261120` |
| `merge_back` | `pending` |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | G1 直写破坏并行会话防互踩（误判切换意图） | 8 | 4 | 5 | 160 | ① 保持“init 于目标计划目录”作为意图信号并保留 claimant complete/不存在 fail-open；② 夹具覆盖同 sid 旧在途与已完成两类；③ 复核 sidmap/fallback 逻辑未改；若仍误伤则拆细改派（22.3②）并 AskUserQuestion 确认边界 |
| Phase 1 | in_progress 锚定过严/过松导致漏判或误判 | 6 | 5 | 4 | 120 | ① 以模板真实状态行 `- **Status:** in_progress` 为基准定 regex；② 加误命中夹具（注释/散文含字样但无状态行）与正命中夹具；③ 回归 PL-09/PL-10 语义 |
| Phase 3 | 场景重现脚本依赖 init 环境变量/sid 解析导致假失败 | 5 | 5 | 4 | 100 | ① 夹具显式设置 `CLAUDE_CODE_SESSION_ID` 并在 /tmp 隔离 plans 根；② 先最小化手工跑通再固化断言；RPN=100 记录预案：拆细步骤并保留手工证据（22.3②） |
| Phase 4 | 部署位与源仓不同步或合并回冲突 | 6 | 4 | 4 | 96 | - |
| Phase 2 | D 类删除旧 `.session-owner` 后回切首轮 Edit 因 owner 缺失未重锁，下一次 prompt 报 PLAN TAMPERED（`zcode-posttooluse.sh:154-156`） | 6 | 5 | 4 | 120 | ① CA-4 明确回切后首个工具动作前先 `attest-plan.sh` 或先触发一次 prompt 重建 owner 再 Edit；② VC-4 文本锚点覆盖该口径；③ 执行期回切流程按序验证并记录证据 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
1. G4：`set-active-plan.sh` skip 路径改输出「指针未切换」后，是否需要将 exit code 从 0 调整为非 0？（需 grep 调用点确认无依赖成功码的自动化后再决定）
2. G3：状态行锚定覆盖模板加粗与历史非加粗形态（结论：采用 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`，兼容 `- **Status:** in_progress` 与 `- Status: in_progress` 等真实样本如 `plans/task-goal-autonomous-20261117/task_plan.md:7`；仍锚定状态控制行，不扩大到全文），并补非加粗不漏判夹具断言。
3. init 一次直写后，旧计划 `.session-owner` 是否应由 init 主动清理还是仅流程要求/通告提示？（当前方案：流程 G2 明确释放；init 通告给出建议路径，避免越权改他计划状态）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采用 G1-G4 四件套而非仅 G1 | 单点修补无法消除 D 类未释放 `.session-owner` 与守卫误伤/skip 误导，无法满足“根治不再出现”的目标（findings.md:70-75） |
| G1 将 init 同 sid 在途 claimant 场景视为明确切换意图（通告+直写） | init 在 `plans/<new-task-id>/` 内执行且 CWD 守卫已成立，属于强意图信号；继续 skip 违背 SKILL.md:220 “指针自动切换”承诺并造成用户多次交互 |
| G3 守卫锚定状态控制行而非全文 grep | 模板与计划文本中“in_progress”字样可出现在注释/说明，全文匹配误伤；锚定 `- **Status:**` 行与 gc anchored 判定风格一致且可测 |
| G4 默认仅强化文案、exit code 暂保持 0（待调用点评估） | 任务明确要求“exit code 是否改非 0 需先 grep 调用点评估影响面再定”；计划期先登记评估与保守默认，避免破坏未知调用方 |
| G1 fallback 身份门控（I-1） | init freshness fallback 抢用他会话哨兵 sid（:1205-1207, D3 路径）时身份未确定，直写会覆盖他会话 side 键；仅 env/sidmap 身份确定时允许通告+直写，fallback 置 `_sid_fallback=1` 保留 skip+WARN |
| G2 回切重锁口径（I-2） | 删旧 `.session-owner` 后 posttooluse:154-156 因 owner 前置不重锁，回切首轮 Edit 会触发后续 PLAN TAMPERED；D 类清单补回切前 attest 或先 prompt 重建 owner，纳入 VC-4 锚点 |
| 手动多在途切换边界（I-3） | 本任务保证 init 新计划与收口后回切一次成功；同会话两计划皆 in_progress 的手动切换依设计仍走 `--force`，VC-2 仅验收提示清晰，避免将守卫安全语义退化 |
| G3 锚定正则兼容非加粗（W-1） | 真实样本存在非加粗 `Status:`（task-goal-autonomous-20261117:7），锚定正则采用 `(\*\*)?` 兼容形态并补不漏判夹具，不扩大到全文 |
| 自测扩展限制在既有 `selftest-pointer-lifecycle.sh` | 遵守文本优先铁律与“selftest 断言可加入既有 selftest 文件”约束，不新建脚本/守护基建 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务或填写实际数量） |
| `success` | n/a（非批量任务或填写实际数量） |
| `failed` | n/a（非批量任务或填写实际数量） |
| `failure_rate` | n/a（非批量任务；批量时填实际比率，>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | n/a（非批量任务；批量时填运行后抽 10% 结果） |
| `sampled_fail` | n/a（非批量任务；批量时填运行前抽 2 结果，>0 → 整批熔断） |
| `pre_check` | n/a（非批量任务；批量时填 Q1:否/Q2:有/Q3:能） |
| `rollback_point` | n/a（非批量任务；批量时填回滚点，为空 → 禁止批量） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |
| 激活子代理数（Rule 96.5） | （Agent() 派发总次数） |
| 最大并行宽度（Rule 96.5） | （并行组数 / 最宽组宽,如 2 组 / 最宽 3） |
| 串行化例外理由（Rule 96.4） | （逐组一句话;无则写 none） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-20 | Explore (调研) | 查明指针切换缺陷根因与修复方案骨架 | done | 三环缺陷+守卫误伤面；G1-G4 方向确定；side/.session-owner/init/set-active-plan/SKILL 关键锚点已落盘 | `findings.md:48-75` | findings.md Research Findings | n/a | - / 0 / ☑ |
| 2 | 2026-11-20 | Plan Writer (本轮) | 填写标准 task_plan/verification/knowledge-brief/progress 计划文档 | done | 4 Phase/S1-S5、VC-1~VC-5、场景重现命令、隔离与基线登记完成 | `task_plan.md`,`verification.md`,`knowledge-brief.md`,`progress.md` | progress.md 本轮条目 | n/a | - / 0 / ☑ |
| 3 | | | | queued | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 指针切换缺陷根治（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | 修复 init/set-active-plan/SKILL 指针切换缺陷并通过场景重现与回归验证 |
| **depends_on** | none |
| **passes_to** | none |
| **status** | in_progress |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | `plans/task-pointer-switch-defect-20261120/{task_plan,verification,knowledge-brief,progress,findings}.md` | 见 verification.md VC-1~VC-5 | - |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP

## 🎯 目标绑定确认锚（D1，2026-11-20）
- 本计划 Goal = 根治 task-planner 新任务 init 与 D 类意图切换场景下 side 指针被旧在途 claimant 误拦、需多次 `--force` 的缺陷，使同会话明确切换意图下一次写入成功并输出清晰通告与正确流程释放
- 服务用户指令 = user-session-log.md #1「帮我修正这个问题，不希望再出现这种低级错误」（指针被旧计划声明需 --force 反复切换浪费时间）
- 确认方式 = Rule 44.3 完成性指令自动裁决（用户明确修复指令+计划经 R1-R4 四轮独立审计 APPROVED）
- 自动裁决记录五要素：超时值=44.1 默认 5min（即时场景按完成性指令径行）/推荐项=按已展示计划执行/触发时间=2026-11-20/裁决理由=用户原话为完成性修复指令且计划审计达标/被覆盖的未决选项=无（方案骨架 G1-G4 无分叉）

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-20 | Explore | 指针切换缺陷根因全链路调查 | done | 三环根因（init 无 force 通道/D 类不释占用/skip exit 0 误判）+守卫误伤面 | findings.md Research Findings 段 | findings.md | subagent-state/（会话级） | - / 0 / ☑ |
| 2 | 2026-11-20 | plan-writer (sonnet-1, 派发尝试) | 撰写计划文档 | failed | provider reasoning-level-missing 配置错误 | progress.md 降级留痕段 | progress.md | subagent-state/ | - / 1 / ☐ |
| 3 | 2026-11-20 | general-purpose | 计划文档撰写（降级载体） | done | task_plan/verification/kb/progress 四文件语义填充 | 本文件+verification.md | findings.md | subagent-state/ | - / 0 / ☑ |
| 4 | 2026-11-20 | general-purpose | R1 审计修正（12 项） | done | C-1/C-2/I-1..I-4/W-1..W-5 落实 | progress.md [plan-audit-R1-fix] | progress.md | subagent-state/ck-audit-fix.md | - / 0 / ☑ |
| 5 | 2026-11-20 | critic | 计划独立审计 R1/R2/R3/R4 | done | 四轮裁决链 REJECTED×3→APPROVED（C=2/2/0/0） | progress.md [plan-audit-R1..R4] | progress.md | subagent-state/ck-audit-r1..r4.md | - / 0 / ☑ |
| 6 | 2026-11-20 | general-coder | S1 init-session.sh 守卫修复 | done | G1 直写+fallback 门控+G3 锚定（+30/-4，16/16 自验） | git 008e2be+findings S1 段 | findings.md | subagent-state/ck-s1.md | - / 0 / ☑ |
| 7 | 2026-11-20 | general-coder | S2 set-active-plan.sh 修复 | done | 锚定+指针未切换前缀+mtime 选取（+24/-4，四夹具过） | git 008e2be | findings.md | subagent-state/ck-s2.md | - / 0 / ☑ |
| 8 | 2026-11-20 | general-coder | S3 SKILL.md D/E 口径 | done | 释占用+回切 attest 两处条款（+2/-2，VC-4 绿） | git 008e2be | findings.md | subagent-state/ck-s3.md | - / 0 / ☑ |
| 9 | 2026-11-20 | Verifier | S4 selftest PL-11..14 | done | 四断言落地+变异测试非空转（14 PASS/FAIL=0） | git 008e2be+progress S4 段 | findings.md | subagent-state/ck-s4.md | - / 0 / ☑ |
