## F-3 completed (2026-09-13)
- critical-rules.md 22.7 换档语义 + 22.7.1 STOP 上报最小集(P0) 已落盘
- SKILL.md 五档触发条件第 4 条同步为「强制换档重试(穷尽 ①-④ 前禁止 STOP)」
- git diff 确认:critical-rules.md +2/-1 行,SKILL.md +1/-1 行
## F-4 completed (2026-09-13)
- 22.7.1 条款在 F-3 中随 22.7 一并落盘(同一次 Edit)
- templates/subagent_dispatch.md 末尾新增「STOP 上报模板」附录(6 字段,对齐 resume_from 附录风格,+16 行)
## F-5 completed (2026-09-13)
- templates/task_plan.md Handoff 表头+示例行+列说明 增加 rescue/retry_count 列,rescue 列口径=档位/结果/时间(failed|timeout 行必填),状态枚举补 scaling-redispatch
- critical-rules.md 22.5 列定义同步:状态枚举补 scaling-redispatch + 增 checkpoint 路径/rescue/retry_count 列
## F-8 completed (2026-09-13)
- critical-rules.md 28.4 后新增 28.4.1「D6 的 silent 例外(禁静默空等)」降级交付四步(原句未动,+1 行)
- SKILL.md 第 5 档行:「D6 硬停点除外」→「D6 触发时按 28.4.1 降级交付(推荐项=拆细后主进程接管 ≤300 行子集,剩余登记未完成清单)，禁静默空等」
## F-9 completed (2026-09-13)
- critical-rules.md 28.2 D3 追加「(Recommended=按序继续降档,保持挽救链推进;silent 模式按推荐项继续不中断)」
## S-2 Complete (2026-09-13)
- 交叉引用 grep:22.7 refs(22.3.1/D6/28.4.1/SKILL:394)语义一致;rescue 口径与 check-rescue-chain.sh(认列名 rescue,子串匹配「rescue(档位/结果/时间)」兼容)一致;五档 refs(SKILL:380/task_plan:223)无矛盾
- 追加 D6 例外联动修正:critical-rules.md 28.2 D6「两模式一致,不可静默豁免」→「ask 模式硬停不可静默豁免;silent 模式按 28.4.1 降级交付不空等」(F-8 一致性要求,避免 28.2 与 28.4.1 矛盾)
- commit 38d6ced,worktree 分支 wt/task-v065-subagent-failure-rescue,status 干净,4 files +28/-11
