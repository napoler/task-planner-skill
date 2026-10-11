# S11 可行性判别门实战（Rule 74.4 dogfood — 本计划即首批 consumer）

- **判别者**：general-purpose(sonnet-1)，独立子代理（推理上下文与主会话隔离）
- **判别对象**：本定稿方案 = plans/task-v162-change-absorption-safety/task_plan.md（计划全文）+ worktree /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety 全部改动（git diff --stat + git status 全貌 + 逐文件 diff 全文核阅）
- **判别时间**：2026-10-10（Phase 7 in_progress 期间）
- **材料包**：计划路径+worktree 路径+改动收集命令由派发 prompt 完整传入；diff 原文/锚点 grep/回归跑批均由本子代理第一手执行

## 三态结论（verdict）

> **verdict: PASS-WITH-RISKS**（登记风险项 R1-R4 + 缓解措施后放行）

未触发 FAIL 条件（无可执行性硬缺口/引用锚全部真实/回滚路径存在）。

## 逐维证据

### 1. 可执行性 — PASS（附 1 项簿记漂移登记 R2）

- 8 个 Phase 均有内容实体：Phase 1-6 已 complete 且有 S-unit 表（目标/执行体/输入/验收/时长/粒度/前置依赖/状态九列全填，无空段占位，Rule 71.1 合规）；Phase 7 in_progress（S11 即本条，S12/S13/S14 表行完整）；Phase 8 为 Rule 25.3 白名单主进程直做，bullet 五项具体可检（smart-merge-back/rule-reserve land 74/verification 复验/部署对账/delivery-summary），无空段占位。
- 材料包逐字化到位：T1-T7 触点/模板、CA-1..14 变更标注、AD-01..14 守护断言均有落盘文本；G 单元表 G1-G9 ↔ S-unit/Phase 映射完整。
- **R2（簿记漂移）**：Phase 6/7/8 的 V-N 列标注与 VC 定义错位——Phase 6（回归）标 "VC-4, VC-3" 应为 VC-7；Phase 7（可行性门+双审查）标 "VC-7, VC-4" 应为 VC-5（+VC-8 审查面）；Phase 8（合并回+终验）标 "VC-5, VC-6, VC-7" 应为 VC-8；VC-8 无任何 Phase V-N 落点。S-unit 活动实体覆盖全部 VC-1~8（G8/G9 映射正确），属标注层漂移而非活动缺失；终验由 verification.md 逐 VC 复验兜底。缓解=Phase 8 终验前修正 V-N 列（主进程三文件回写权）。

### 2. 相容性 — PASS

- 引用锚真实性（本子代理 grep 第一手核验，worktree 版）：
  - Rule 74 六子条 `^74\.[1-6] `=6，标题 `### 74 变更吸收三判纪律`=1，位于 Rule 71 段后 EOF（diff @@ -940,3 +940,12 @@ 实证）
  - 三档关键词「增量（默认且优先）」/「四条件全满足才可」/「删除（最高门槛）」各=1，判据句「先问是补充还是替代」=1
  - 74.4/74.5 引用锚全部真实存在：8.1(critical-rules.md:81 段)、36.5(L374 段)、56.1(L644 段)、51.1、69.1(L896，T1 矩阵=「计划期方案终裁 43.3 候选对比」——与 74.4「单定稿方案能否安全落地」确为互补不重叠)、71.1(L930)、38.3(L397)、43.2(L470)
- 与既有规则无冲突：74.5 显式分层（8.1=入口层/本规则=语义层；56 替代门不冲突的理由=(b)①授权形态）；36.5↔74.2 双向特化表述对称一致（「冲突时 36.5 更严」双向互证）；8.1/36.5/56.1 三处触点为行尾/段末追加形态，宿主旧文逐字未动（diff 实证）。
- 守护面：config.json 零改动（git status 实证+AD-10 PASS）；10 个改动 pinning 脚本+新脚本全绿（本子代理 spot 跑 11 个 + 全量 72 脚本复验 72/72 rc=0，独立于 Phase 6 自报）。
- **R3（机器边界微过claim）**：74.3(b)「无标注表=无效…selftest-absorption-discipline.sh 静态守护」措辞强于实际机器面——AD-06 只守护模板锚、AD-13 只守护本计划自举；任意其他计划的标注表存在性未机械化（C51 行已含「判别过程人工核查」披露，Rule 71.7 披露标准部分满足）。缓解=Phase 8 可将 74.3(b) 补一句机器边界披露（纯增量注释），或在 verification.md 登记已知限制。
- 无害观察（不构成风险）：SKILL.md 索引段 Rule 74 bullet 插在 Rule 71 与 Rule 69/70 行之间，时序序中断（仅排序观感，无语义影响）。

### 3. 风险性 — PASS-WITH-RISKS（R1/R4 需缓解后放行）

- 爆炸半径（git 实证）：worktree 15 文件（14 M + 1 ??）+ plans/ 6 文件 = 21；全部位于 skills/task-planner（所有会话实时加载，运行中基础设施权重=高）+ plans/ 本任务目录。
- 回滚路径存在且可执行（两段）：合并前=worktree 内未提交变更 `git restore .` + 删未跟踪新脚本 + `git worktree remove`（分支 wt/v162-change-absorption-safety 未合并，HEAD=7317455 基线清晰）；合并后=`git revert <merge-commit>`（Batch Report 已登记）。
- **R1（Phase 8 合并冲突暴露）**：`git worktree list` 实证 4 个同源活跃 worktree（v156/v161/v163/v164 均改 critical-rules.md/SKILL.md 同尾段面），合并回 master 撞冲突概率高。计划 FMEA Phase 8 RPN=84 已预演并预设并集解兜底（v149/v155 判例、禁 rebase 强推、重跑全量回归）。风险已知有兜底，但须在 Phase 8 严格执行并集解+回归，不得简化。
- **R4（部署债务）**：部署位（~/.zcode/skills 等）未同步（v158 遗留：部署位 1-69+70 vs 主仓 1-71）；Rule 74 需用户显式授权才部署（CA-14 deferred 登记）。本判别不阻塞——合并回 master 本身安全，部署属用户门。
- 未发现无回滚路径、无守护、运行中 config 破坏等高危项。

## 风险登记（放行条件）

| # | 风险 | 严重度 | 缓解措施 | 责任位 |
|---|------|--------|----------|--------|
| R1 | Phase 8 合并回与 4 个活跃 worktree 冲突 | 中 | 并集解逐 hunk（v149/v155 判例）+禁 rebase 强推+合并后重跑全量回归 | 主进程 Phase 8 |
| R2 | Phase 6/7/8 V-N 列与 VC 定义错位 | 低 | Phase 8 终验前修正标注；verification.md 逐 VC 复验不受影响 | 主进程 Phase 8 |
| R3 | 74.3(b) 机器边界措辞微过claim | 低 | Phase 8 补披露句（纯增量）或 verification.md 登记已知限制 | 主进程 Phase 8 |
| R4 | 部署位未同步（v158 债务+用户授权门） | 低（不阻塞合并） | deferred 已登记（CA-14）；部署待用户显式授权 | 用户门 |

## 独立复验记录（第一手证据，区别于子代理自报）

- `git diff --stat` + `git status --short`：14 M + 1 ??，71 insertions(+)/37 deletions(-)
- 全量回归独立复跑：`for f in scripts/selftest-*.sh` → TOTAL=72 GREEN=72 RED=0（2026-10-10，本子代理执行）
- selftest-absorption-discipline.sh 自跑：AD-01..14 全 PASS，exit 0，chmod +x 实证
- 锚点 grep：74.x=6/标题=1/8.1/36.5/56.1/51.1/69.1(L896)/71.1(L930)/38.3/43.2 均存在
- config.json：git status 零改动
