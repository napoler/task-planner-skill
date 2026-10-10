#### [sub:契约更新] selftest-smart-merge.sh SM-06/SM-14 断言对齐 F5 新 deploy 契约（2026-10-10 task-v159 F5 级联, 契约单元）
- 改动文件: worktree skills/task-planner/scripts/selftest-smart-merge.sh（唯一 scope 文件; 25 insertions / 10 deletions vs HEAD 2f27fcb）
- SM-06（原 :237-239）: 旧契约 rc=6 + `[DEPLOY] DRIFT: <s2-slot 变量值>` + `[DEPLOY] IDENTICAL: $T6/s1` → 新契约 rc=1(F5 staging-fail 语义) + `[DEPLOY] STAGE-FAIL: <s2-slot 变量值>`（stdout, smart-merge-back.sh :700）+ s1 目录存活 & SKILL_MARKER=v077-canonical（staging 整体失败不进入 swap → s1 未被触及, 非弱化: 失败路径仍断 rc≠0）
- SM-14（原 :433-437）: 旧终态 grep `[DEPLOY] IDENTICAL: $T14/slotB`（仅 legacy 分支 :671 打印）→ 新 F5 默认路径成功消息: 终行 `[DEPLOY] OK: 全部部署位 IDENTICAL`（:770）+ 逐 slot 换位证据 `[DEPLOY] SWAPPED: $T14/slotB`（:732, 即 per-slot 成功标记）; rc=0 与 slotB SKILL_MARKER==canonical-v077 双断言保留（成功路径仍断 IDENTICAL 语义, 非弱化）
- 头注释同步: SM-14 段 :9-10 契约描述改 F5 消息串; SM-06 段 :220-227 机制说明改 staging 阶段 cp ENOTDIR → STAGE-FAIL; SM-14 段 :420-431 用例注释 ④ 改 F5 成功消息; 新增 Rule 45 注释（F5 级联, 说明命中点/非弱化口径）
- 实测: `bash -n` exit 0; 全跑 `Total: 17 PASS=17 FAIL=0` exit 0（SM-06 PASS rc=1 STAGE-FAIL=在 s1 存活=是; SM-14 PASS 终行OK-串=在 slotB-SWAPPED=在 marker=canonical-v077）; 其余 15 断言 PASS 状态与改动前一致
- 计数: Total 口径不变（16 断言行 + SM-10 注入 =17）; 其余断言（SM-01..05/07..13/15a/15b）零改动
- 负结果面: `git diff --stat` 仅 1 文件; 全仓 grep `[DEPLOY] IDENTICAL/DRIFT/OK` 消费者仅本脚本（回归单元 checkpoint 已证）; SM-08/09/12/13 的 exit 6 断言对应 validate_slot REJECTED 路径（DRIFT 后置 exit 6, 契约未变）未受影响
