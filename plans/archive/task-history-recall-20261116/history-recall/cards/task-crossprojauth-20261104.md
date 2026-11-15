# 经验卡：task-crossprojauth-20261104

| 字段 | 内容 | 证据锚 |
|------|------|--------|
| task_id | task-crossprojauth-20261104 | plans/task-crossprojauth-20261104/task_plan.md:1 |
| outcome | partial/未归档（mini stub，81.3 归档拒绝 reason=status-none；按 81.3 保持原位；收口提交与部署已完成） | plans/task-crossprojauth-20261104/task_plan.md:14-15; commit 6583f14 |
| goal_摘要 | 在 task-discipline 落 Rule 99 跨项目/跨目录操作授权纪律；同任务 R2/R3/R5/R6 链路落地 Rule 100「临时目录与 worktree 统一落 <project-root>/tmp/worktrees/<task-id>」与 Rule 101「起点原始数据固定提交+终点 worktree 主动合并/冲突收口义务」，并级联纪元/索引/selftest 零回归。 | plans/task-crossprojauth-20261104/task_plan.md:1-13; commit ec72683; commit 2f4540d |
| 关键决策 | L0-T 主仓直改（无 worktree）=11-03 用户裁决 L0-lite 最小 stub 先例；部署位同步属生效闭环非越权；新编号经 rule-reserve reserve→land；Rule 101 将 smart-merge-back V6 消息语义翻转为冲突=收口义务（41.1 消解链全解+复验，非乱解）。 | plans/task-crossprojauth-20261104/task_plan.md:13-14; commit ec72683; commit 8db66b8 |
| 成功要素 | 规则落地与 worktree/合并纪律条文化（worktree 路径 SOP、合并冲突消解义务）配套 selftest/纪元级联与三部署位对账闭环；fresh 回归 94/94（commit 证据）。 | commit ec72683 ("fresh 回归 94/94 FAIL=0"); commit 2f4540d ("fresh 回归 94/94"); plans/task-crossprojauth-20261104/task_plan.md:20 |
| 失败教训 | 未查到（无 progress.md/findings.md Error Log 可审计）。已查：plans/task-crossprojauth-20261104/ 目录文件清单（仅 .plan-attestation/.session-owner/subagent-state/task_plan.md）及 task_plan.md 全文预览+git 提交信息。 | plans/task-crossprojauth-20261104/task_plan.md:1-23; commit 6583f14; commit 1105240 |
| 可复用资产 | Rule 100/101 纪律条款与级联（worktree-isolation/dispatch/smart-merge-back 随动）、rule-reserve land 流程、三位部署 diff=0 收口模式（文本规则落地）。 | commit ec72683; commit 2f4540d; commit 8db66b8; plans/task-crossprojauth-20261104/task_plan.md:20 |
| 用户偏好信号 | 未查到（无 user-session-log.md）。已查：plans/task-crossprojauth-20261104/ 目录与 task_plan.md；task_plan.md 记录原话锚“对技能进行跨目录 约束…”但非专档逐字裁决摘录。 | plans/task-crossprojauth-20261104/task_plan.md:11 |
| 证据锚 | plans/task-crossprojauth-20261104/task_plan.md:1-23; commit b935480; commit 6583f14; commit ec72683; commit 1105240; commit 2f4540d; commit 8db66b8。弱相关说明：本任务执行 lane=L0-T 未实际创建 worktree，但主题“worktree 隔离与合并回”相关的 Rule 100/101 由本任务落地（路径规范+合并冲突收口义务），属制度/规则层经验。 | 同左 |
