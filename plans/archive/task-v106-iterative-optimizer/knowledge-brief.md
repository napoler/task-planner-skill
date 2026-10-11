# Knowledge Brief — task-v106-iterative-optimizer
## §1 速览
- 新建顶层 skills/iterative-optimizer/SKILL.md(五步迭代闭环+门控铁律+状态文件+迭代摘要)+selftest IL-01..08+registry;三宿主部署 push。
## §2 已验证事实
| 事实 | 证据 |
|------|------|
| master=e620a03;基线 41 脚本 652/0 | P1 实测 |
| SATELLITE_SKILLS 无守护锚 | grep 空 |
| install-companion 顶层循环分发非 task-planner 的 skills/* | :167-190 实证 |
| 名字 iterative-optimizer 无冲突 | 2026-10-01 审计 A' |
| registry 现 42 行(41 脚本+表头,SR-12 动态) | v105 后状态 |
## §3 文件锚点
| 路径 | 锚 |
|------|-----|
| skills/iterative-optimizer/SKILL.md | 新建(90-120 行) |
| task-planner/scripts/selftest-iterative-optimizer.sh | 新建(断言 ../iterative-optimizer 相对路径) |
| task-planner/scripts/selftest-registry.tsv | EOF +1 行 |
## §4 易错点
1. banned 主观词(更好/合理/大致/应该/足够)禁入 QC/门控上下文(S47/48)
2. selftest 断言对象路径=../iterative-optimizer(相对 task-planner/scripts),禁写死 /home/terry(S75-D1)
3. 用户原话八锚全部入对应段(见 task_plan Notes)
4. SKILL.md 90-120 行;四要素+流程图(markdown checklist 带门控,S63)
5. registry 行 4 列 TSV 形态;Total 8/8/0
## §5 材料包
| S-unit | 材料 |
|--------|------|
| P2-S1 | 任务书逐段设计规格(完整文本骨架) |
| P2-S2 | IL-01..08 断言定义+S1 产出实测 |
