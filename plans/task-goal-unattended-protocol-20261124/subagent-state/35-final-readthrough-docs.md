# 35 final-readthrough（交付前通读与五维互洽）2026-11-24（只读审查）

## 实际读到行范围（均第1行读到末行）
1 user-session-log.md 1-68（全）
2 plan-brief.md 1-209（全）
3 edit-spec.md 1-241（全）
4 drill-prompts.md 1-32（全）
5 drill-report.md 1-40（全）
6 drill-skeleton.md 1-91（全）
7 deploy-runbook.md 1-73（全）
8 task_plan.md 1-273（全）
9 findings.md 1-95（全）
10 progress.md 1-177（全）
11 verification.md 1-54（全）
附：权威需求锚 .zcode/plans/plan-sess_18af15b1-d11e-45ab-8597-ca72e1b32c1c.md 1-85（全）。
plan-state.json（1904 行）未按行通读；核对范围=decisions(22,末 D-21)/errors(10,末 E10)/audits(7,末 round7 APPROVED drift-checker 0/0/0)/vcs(9,末 VC-9 pass)/actions(28,末 A28) 的条目数与末条，VC-8=fail。

## 五维判定
① 三裁决落实不扩大：PASS（裁决一→E25/28.9②/VC-7；裁决二→5位部署/VC-5；裁决三→E23-24/VC-6/VC-9；D-9/D-10/D-11 显式收窄，无越权扩张）
② 计划/规格 vs 执行证据：PASS（edit-spec E0-E35 与 progress 动作、提交哈希 17705c1/c8cc87b1/ee254abd/e39d8997/fb47cea6/79e9a9de/d9f68655 逐一对得上；基线 9e42c0b 存在）
③ 证据链自洽：有条件（提交/检查点/备份/骨架一致；但见 MINOR-1）
④ VC-8 口径：PASS（verification.md:23、drill-report.md:3、drill-skeleton.md:91、D-21 均为 fail；同会话演练仅作补充证据，无文档称 VC-8 通过）
⑤ 跨文件术语/编号/时间/无残留：有条件（见 MINOR-2；模板示例行 #N/YYYY-MM-DD 为显式非计数范式，非残留占位）

## 问题清单
- MINOR-1 | plan-state.json:848 与 task_plan.md:215 | merge_back 仍为 "pending"，但合并已完成（d9f68655，VC-4 pass，worktree/分支已清）。建议：改为 merged(d9f68655)；若因计划暂不归档而有意保留，须在 decisions 注明，避免权威源与仓库实态矛盾。
- MINOR-2 | task_plan.md:250 与 findings.md:79（D-20） | D-20 仍写「全新会话首个工具调用即被权限模式拦下」，与已更正事实「第 3 个工具调用」(drill-report.md:3、drill-skeleton.md:21、progress.md:141、E10) 矛盾。建议：按更正后表述改写 D-20 该句（结论不受影响）。

## 总评
交付物主体（规则文本+证据文档）成立，三裁决落实到位、VC-8=fail 口径清晰、证据链可追溯。两项均为历史/元数据字段的残留表述，不影响交付口径，不需阻断发布，但交付前应修正。
