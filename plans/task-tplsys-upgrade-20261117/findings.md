# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71）
-->

## Requirements
- R1[目标] 升级 Task Planner 模板体系：更有效引导执行路径、提升模板生成/适配能力，支持按任务/项目/场景（剧本、小说、通用开发、应用开发、安卓等）更强适配。
- R2[目标][机制] 模板生成/制作流程调研前置：生成模板前必须先网络调研该领域有效做法/步骤/结构，再基于调研结果创建模板；严禁拍脑袋、不经调研；调研步骤纳入模板生成流程。
- R3[目标][机制] 模板扫描升级：执行时先分析任务→优先扫描项目模板目录→再扫描用户目录→匹配适配模板执行。
- R4[目标][机制] 派生机制：可从相似模板派生；派生/主动创建模板保存前必须询问用户，用户审核授权后才落盘。
- R5[纠正/约束] 目录按当前 Agent 对应（当前 ZCode 用 `.zcode` 体系）；明确指定升级事项直接推进，不再反问是否要做。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-planner 核心与模板卫星 | skills/task-planner/SKILL.md, references/critical-rules.md, scripts/init-session.sh, scripts/check-template-type.sh | 已消费（探索+直读+修改） | Research Findings/现状与差距；实现落地与验证 |
| plan-template-kit/advisor | skills/plan-template-kit/*, skills/plan-template-advisor/SKILL.md | 已消费（修改） | Research Findings/现状与差距；实现落地与验证 |
| 项目级模板现状 | .zcode/plan-templates/README.md, .zcode/plan-templates/*.md | 已消费 | Research Findings/现状与差距 |
| 用户纠正（权威） | plans/task-tplsys-upgrade-20261117/user-session-log.md #1-#3 | 已消费 | Requirements/Decisions/方案 |

## Research Findings

### 1) 现状架构（Phase 1 基线，证据：探索结论 + 直读脚本/文档）
- **模板位置**：内置 `skills/task-planner/templates/`（核心计划文件 + `variant/*-type.md`）；项目级 `.claude/.zcode/plan-templates`；**无用户级/home 模板目录扫描**。
- **发现/选型/复制**：项目+内置合并，但存在项目/用户层缺失与优先级不统一风险；variant 路由历史上有内置优先倾向。
- **校验门控**：`check-template-type.sh` 白名单仅内置 variant + general，与 init 可发现的项目自定义类型存在 enforce 失配风险。
- **规则/SOP**：Rule 34.7 曾含 silent/不询问自动生成落盘倾向，与 R4“保存前必审必授权”冲突；生成流程缺强制“网络调研前置”硬步骤与调研依据承载。

### 2) 实现落地（Phase 2-4，worktree `wt/tplsys-upgrade-20261117` commit `3b8a021`）
- **扫描与目录机制（R3/R5）**：`skills/task-planner/scripts/init-session.sh` 增加 `find_user_templates`/`resolve_template_path`，统一发现/`--list`/默认解析/VALID_TYPES/variant 选型/`copy_template` 为 **项目→用户→内置**；ZCode 优先 `<项目>/.zcode/plan-templates/` 与 `~/.zcode/plan-templates/`，`.claude` 仅兼容探测；路由输出标注 project/user/built-in。`skills/task-planner/scripts/check-template-type.sh` 白名单动态合并项目与用户 `*-type.md`，与 init/attest 选型一致。`template_priority` 配置与 README 同步为 `["project-level","user-level","built-in"]`。
- **生成流程调研前置与派生/审批（R2/R4）**：`skills/plan-template-kit/references/critical-rules-template.md` 重写 Rule 16/34（34.1 三层扫描；34.4 强制“任务与领域分析→相似模板扫描/派生基底→网络调研并记录依据→基于调研创建/派生候选→审查→用户审核授权后落盘”；34.7 改为研究前置/审后落盘合约，禁 silent 自动持久化；34.8/34.9 候选暂存与用户授权门禁/持久位）。`skills/plan-template-kit/SKILL.md`、`skills/plan-template-advisor/SKILL.md` SOP 同步（调研步骤、派生基底、候选展示、保存位置询问与授权后落盘，含用户级目录）。
- **文档/映射/指引同步（R1/R5）**：`skills/plan-template-kit/references/template-guide.md`、`template-mapping.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/companion/agents/plan-writer.md` 更新为三层优先级、ZCode 优先目录、调研前置与审后落盘约束；示例路径 ZCode-first。
- **自测/门禁文案对齐**：`skills/task-planner/scripts/check-complete.sh` 与 `selftest-template-sense.sh` 34.7 标签/锚对齐新合约。

### 3) 验证证据（Phase 4）
- 语法：`bash -n skills/task-planner/scripts/init-session.sh check-template-type.sh check-complete.sh selftest-template-sense.sh` → `SYNTAX_OK`。
- 自测：`bash skills/task-planner/scripts/selftest-template-sense.sh` → `Total: 8 PASS=8 FAIL=0`；`bash skills/task-planner/scripts/selftest-template-lifecycle.sh` → `Total: 24 PASS=24 FAIL=0`（worktree）。
- Smoke：`./skills/task-planner/scripts/init-session.sh --list` → 显示 `rule-clause-cascade (project)`、built-in 列表与 `[default] general`（三层发现/标注生效）。

### 4) 合并状态与风险
- 实现提交位于 worktree：`3b8a021 feat(tplsys): upgrade template system for ZCode agent-aware scan, research-preceded generation, and approval-gated persistence`（13 files, +218/-114）。
- 主仓工作树当前存在与本任务重叠的未提交修改（如 `M README_zh.md`、`M skills/task-planner/SKILL.md`、`M skills/task-planner/config.json` 等），未执行 `git merge --no-ff wt/tplsys-upgrade-20261117` 与 worktree 清理，以避免冲突/覆盖。待主仓对应改动收敛后执行合并与 `git worktree remove` + `git branch -d`。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 当前 agent=ZCode，优先采用 `.zcode`/`~/.zcode` 模板目录约定，`.claude` 仅兼容 | 用户 #3 明确裁决；避免 `.claude` 错配与脚本/语义错误 |
| 统一项目→用户→内置三层发现/白名单/复制优先级 | 满足 R3 并消除 init 与 enforce 门不一致 |
| “调研前置+审后落盘”落点为模板生成流程/SOP/规则与候选承载（34.4/34.7/34.8） | 用户 #2 机制化意图 + R4 授权约束 |
| 合并暂缓于主仓脏且重叠状态 | 遵守最小风险与工作树纪律，避免破坏并行未提交改动 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 前序误将“调研前置机制”理解为立即做领域调研并外显产出 | 按用户 #2/#3 纠正，停止偏离动作，改为机制化升级设计与落地 |
| init-session.sh 多点 Edit 破坏语法 | 以干净基底+整块替换重建并 `bash -n`/smoke 验证 |
| 主仓合并前置不满足（重叠未提交修改） | 记录阻塞，暂不合并/不清理 worktree |

## Resources
- skills/task-planner/scripts/init-session.sh
- skills/task-planner/scripts/check-template-type.sh
- skills/task-planner/scripts/attest-plan.sh
- skills/plan-template-kit/references/template-mapping.md
- skills/plan-template-kit/references/template-guide.md
- skills/plan-template-kit/references/critical-rules-template.md
- skills/plan-template-kit/SKILL.md
- skills/plan-template-advisor/SKILL.md
- skills/task-planner/companion/agents/plan-writer.md
- .zcode/plan-templates/README.md
- worktree commit: 3b8a021 (wt/tplsys-upgrade-20261117)

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
