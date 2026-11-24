# 37 final-readthrough R2（修复后重读）2026-11-24（只读审查）

## 读到行范围（11 份全读）
1 user-session-log.md 1-68（未变，工具判 unchanged+mtime 00:48<attest 05:31）
2 plan-brief.md 1-209（未变，02:13）
3 edit-spec.md 1-241（未变，04:19）
4 drill-prompts.md 1-32（未变，03:16）
5 drill-report.md 1-40（未变，05:16）
6 drill-skeleton.md 1-91（未变，05:15）
7 deploy-runbook.md 1-73（未变，04:48）
8 task_plan.md 1-273（重读，re-render）
9 findings.md 1-95（重读，re-render）
10 progress.md 1-177（重读，re-render）
11 verification.md 1-54（重读，re-render）
plan-state.json：decisions=22(末D-21)/errors=10(末E10)/audits=7(末round7 APPROVED)/vcs=9(末VC-9 pass, VC-8 fail)/actions=28(末A28)/isolation.merge_back="merged(d9f68655)"（其余3字段原样）。

## 四项确认
① MINOR-1/MINOR-2 已消失：merge_back 在 plan-state.json isolation 与 task_plan.md:215 均为 merged(d9f68655)；D-20 在 plan-state.json decisions、task_plan.md:250、findings.md:79 三处均改为「第 3 个工具调用（第 2 条 shell 命令）」+ 限定「（仅同会话模拟中）」，旧表述「首个工具调用即被权限模式拦下」在 decisions/D-20 面已无。无新矛盾：余下 3 处「首个工具调用即被拦截」均位于「曾写…与事实不符/后更正」的历史更正叙述，非现行断言。
② VC-8 仍 fail：plan-state vcs、verification.md:23、drill-report.md:3、drill-skeleton.md:91 一致；无文档称其通过（D-20 的 PASS 已限定模拟中，D-21 紧接声明 fail）。
③ attest 一致：sha256sum(task_plan.md)=3494b7f21ada3357faec84656d7ddf76405bb46d5847df76c6cf5bc96c587564 == .plan-attestation.plan_sha256；state_sha256 亦与 plan-state.json 实值相等。（哈希存于 .plan-attestation，非 task_plan.md 正文顶部；plan_file 指向 task_plan.md，机制正常。）
④ 五维仍互洽：三裁决落实不扩大、规格/证据一致、证据链自洽、VC-8 口径清晰、跨文件术语编号时间统一；无残留 TODO/占位。

## 问题清单
无（PASS）。
