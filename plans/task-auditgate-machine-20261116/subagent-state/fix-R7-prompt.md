# 修复轮 7 任务书 — task-auditgate-machine-20261116（R7 REJECTED 五项计划面修复）

你是本计划的 Plan Writer（修复轮 7）。工作目录 /mnt/data/dev/task-planner-skill。只修改计划文档（plans/task-auditgate-machine-20261116/ 计划文件+检查点），禁碰 skills/**，禁创建仓库脚本。

## 背景（自包含）

- 用户需求逐字锚（user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」；R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。plan_tier=standard / execution_lane=L1。
- 轨迹：R1×14→R2×6→R3×1→R4×2→R5×2 全修复；R6 APPROVED（0C/0I）；R6a 加固修订（checker 聚合两约束）已落盘；**R7 范围化复审 REJECTED（0C/2I/2W/2Q/2N）——完整发现清单见 progress.md [plan-audit-R7] 段（动工前必读）**。主进程登记时点已处置 W-1（5Q 刷新）/N-1（:440 算术）/N-2（复跑留痕），本轮只修计划面五项：I-1/I-2/W-2/Q-1/Q-2。

## 修复指令（逐项，全部实际 Edit 落盘）

### I-1[IMPORTANT] 最小形态 token 与真实 APPROVED 段字节形态脱钩

事实：R6 审计段（progress.md:316 附近）真实形态=`- 问题清单（留档，不阻断）:`（带括注）；spec 字面要求 `问题清单:` 连写冒号 → spec-literal checker 对真实 plan-dir 判 rc=1（critic 实测），Phase 5 自举必失败。

**修复（采 critic 推荐①）**：
1. 四处 token 定义统一为容忍括注形态：`问题清单` 后允许全角/半角括注再接冒号（判据正则：`^- 问题清单([（(][^）)]*[）)])?:`，ERE）。落点：verification.md:15（VC-1 判据）、task_plan.md:78（VC-1 行）与 :275（S1 验收，注意表格内禁管道字符——用散文指路 verification.md VC-1）、knowledge-brief.md 相关行（:27/:69 若有 token 定义）、progress.md:76 占位区说明。
2. **VC-1/VC-3 增真实形态 fixture**：以真实 R6 段字节形态为输入的正例（`- 轮次: R6 | 审计体: critic | 结论: **APPROVED**（…）` + `- 问题清单（留档，不阻断）:` + `- 审计体: critic` 等三 token 齐备）→ 必 rc=0；规范示意形态（`- 问题清单: 无`）正例保留 → rc=0。两正例都须过（防 spec 与生产形态脱钩再次发生）。
3. `审计体:`/`轮次:` token 若同样存在括注风险，一并评估容忍形态（当前真实段无括注，可维持字面，但 fixture 覆盖决定）。

### I-2[IMPORTANT] 两约束只测「全缺」抓不到「只做其一」→ 各自独立承重 fixture

critic 实测四变体：完全加固 rc=0/完全未加固 rc=1/**仅边界 rc=0 假 PASS**/**仅锚定 rc=0 假 PASS**；两条独立假 PASS 路径=fixture a（REJECTED 审计段内出现裸文 `结论: **APPROVED**`，如「缺少 结论: **APPROVED** 行」这类意见文本）与 fixture b（后随 H2 块内含正规锚定 `- 轮次: R9 | 审计体: critic | 结论: **APPROVED**` 行）。

**修复**：
1. verification.md VC-1 Verify command 增 **r5**（fixture a：REJECTED 段内裸文 APPROVED → 期望 rc=1）与 **r6**（fixture b：后随 H2 块锚定 APPROVED → 期望 rc=1）；末断言改 `test "$r1" -eq 1 && test "$r2" -eq 1 && test "$r3" -eq 0 && test "$r4" -eq 1 && test "$r5" -eq 1 && test "$r6" -eq 1`。
2. verification.md:23 VC-3 用例清单补 fixture a/b 两行为用例。
3. :23 判据句改写为逐约束承重归属：「① 聚合边界（止 H2）由 fixture b 独立承重（仅边界实现→r6 抓住）② 结论行锚定由 fixture a 独立承重（仅锚定实现→r5 抓住）；两约束全缺由 r4 抓住」。
4. 注意：r5/r6 的 awk 构造如需反引号，沿用 `%c` 96 技巧，整行 Verify command 禁反引号包裹。

### W-2[W] legacy SKIP 无可执行判据

VC-3 用例清单补一条：「无 plan_tier/execution_lane 声明 → rc=0 且输出含 `SKIP legacy-no-decl`」（防实现误判 rc1 锁死 9 个存量无声明计划）；VC-1 判据句同步提及该分支有 fixture 承重。

### Q-1[QUESTION] H2 边界依赖前提固化

knowledge-brief.md:27（加固说明处）+ verification.md VC-1 判据补一句契约说明：「聚合边界仅认 `^## `（H2）——**审计段后随块必须用 H2 标题**（写作规范依赖，写入 progress 占位区或 kb 写作规范）；后随块用 H3/粗体标题时约束静默退化，checker 注释须登记该前提」。progress.md「审计留痕占位」区如可追加一行写作规范提示（append-only 语义允许追加，禁改写既有行）。

### Q-2[QUESTION] 空文件 rc 口径固化

VC-1 判据 + checker 契约（task_plan S1 验收/CA-7）写明：「progress.md **文件缺失/不可读=rc2**（fail-open+WARN）；**存在但空=无留痕 rc1**」。VC-3 的「rc2 输入缺失」用例明确为删除文件（非空文件）。

## 约束（不变）

逐字锚 R1-R3 task_plan.md:16-18 与 user-session-log.md 冻结不动；**不新增 [plan-audit-RN] 段**（[plan-audit-R7] 为最后审计段；R8 裁决由主进程登记）；progress.md「R7 修复轮」段用 `## 2026-11-17 R7 修复轮` H2 头追加（**必须 H2**——Q-1 写作规范自证）；实际 Edit 落盘+真实输出收据；机械门重跑（八门）贴真实 rc；/tmp 判别性实测：
- I-1：真实 R6 段形态 fixture 经新旧 token 判据对照（旧=rc1 误拒/新=rc0）
- I-2：四变体复测（完全加固 rc0/仅边界 rc1/仅锚定 rc1/全缺 rc1）——注意期望值已反转（半加固被抓）
- 新 VC-1 命令端到端（逐字提取仅替换 C=，mock 实现）六态 rc 全符合

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/fix-R7.md — 动工前写，完成后回填。

## 输入材料

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/{task_plan.md,verification.md,progress.md,findings.md,knowledge-brief.md,notepad-learnings.md}
- progress.md [plan-audit-R7] 段+R7 登记时点同步段（本轮输入）
- subagent-state/audit-R7.md（critic R7 检查点，含其四变体/两 fixture 实测细节）

## 完成后追加

progress.md 末尾「## 2026-11-17 R7 修复轮（REJECTED → 增量修订，I-1/I-2/W-2/Q-1/Q-2）」段；findings/kb/notepad 同步；checklist：逐项处置+实测输出+机械门+三约束自证（含「后随块 H2」规范自证）。

## 输出格式（8 字段返回模板）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
