# 修订轮 R6a 任务书 — task-auditgate-machine-20261116（R6 APPROVED 后的单点加固修订）

你是本计划的 Plan Writer（修订轮 R6a）。工作目录 /mnt/data/dev/task-planner-skill。只修改计划文档，禁碰 skills/**，禁创建仓库脚本。本轮=**单主题**：checker 末段聚合的中间态假阳性加固（主进程 2026-11-17 /tmp 一手实测发现）。

## 背景（自包含）

- 用户需求逐字锚（user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」；R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。plan_tier=standard / execution_lane=L1。
- R1-R6 审计已收敛（R6 APPROVED 0C/0I，progress.md [plan-audit-R6] 段）。
- **新发现（主进程一手实测，非 critic 提出）**：checker 既定聚合形态（kb:27「awk 只认 `^## \[plan-audit-R[0-9]+\] ` 段聚合 + `grep -q "结论: \*\*APPROVED\*\*"`」）在**中间态**假阳性——末段聚合 buf 从最后一个 `[plan-audit-RN]` 头延伸到 EOF，会吞进后随修复轮块中**反引号内的元引用**（如修复轮收据自证行「③ 无审计段级 `结论: **APPROVED**` 预写」）。实测：`head -304 progress.md` 截断到 R5 段+R5 修复轮块时，聚合后 `grep -c "结论: \*\*APPROVED\*\*"`=1（命中 :295 元引用行）→ 伪 PASS。而修复轮收据天然引用三 token 格式（checker 自身强制的最小形态），未来计划必然复现。先例（task-planaudit-20261116）同形态未暴露，因其验证时点终态恰好一致。

## 修订指令（单主题三落点，全部实际 Edit 落盘）

1. **task_plan.md Phase 3 S1 验收（:275 附近）+ CA-7 行（:141 附近）+ 门控判定器行（:38 附近）**：checker 聚合判定补两条硬约束（写进验收判据）：
   - ① **聚合边界**：末段 buf 必须止于下一个 `## `（H2）级标题行（含修复轮块 `## 2026-11-17 R<N> 修复轮`、`## 审计留痕占位` 等任何 H2），而非仅下一个 `[plan-audit-RN]` 头——防吞后随块的元引用；
   - ② **结论行锚定**：APPROVED/REJECTED 判定必须匹配行首结构 `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*`（ERE 锚定），禁匹配反引号内/行中的元引用串。
   - 验收增负例：**中间态假阳性用例**——fixture 模拟「REJECTED 审计段 + 后随含反引号 `结论: **APPROVED**` 元引用的修复轮块」→ checker 必须 rc=1。
2. **verification.md VC-1 判据（:15）与 VC-3 fixture 清单（:23）**：同步增上述中间态负例与两约束（VC-3 fixture 清单加「中间态假阳性（REJECTED 段+元引用修复轮块）」一项）。
3. **knowledge-brief.md:27（先例聚合命令行）**：补加固说明——先例命令在中间态假阳性（主进程 /tmp 实测 head 截断态命中元引用行）；checker 实现须按①②加固；存量先例档案不改写。

## 约束（不变）

逐字锚 R1-R3 task_plan.md:16-18 与 user-session-log.md 冻结不动；禁预写 APPROVED（progress.md [plan-audit-R6] 段保持为最后审计段，本轮**不新增** [plan-audit-RN] 段——修订登记由主进程在 R7 复审时一并处理）；实际 Edit 落盘+真实输出收据；机械门重跑（至少 check-rvc-coverage/check-vc-nonvacuous/check-tier-consistency/check-plan-dispatch）贴真实 rc；/tmp 验证两约束的判别性（构造含元引用的 fixture：旧形态假 PASS/新形态真 FAIL）。

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/fix-R6a.md — 动工前写，完成后回填。

## 输入材料

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/{task_plan.md,verification.md,progress.md,knowledge-brief.md,findings.md,notepad-learnings.md}
- progress.md [plan-audit-R6] 段（收敛态参照）

## 完成后追加

findings.md 补本发现（主进程实测来源）与修订对照；kb:27 加固；notepad-learnings.md 同步；progress.md 末尾追加「## 2026-11-17 R6a 修订轮（R6 APPROVED 后单点加固——checker 聚合中间态假阳性）」段（不含 [plan-audit-RN] 头格式）。

## 输出格式（8 字段返回模板）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
