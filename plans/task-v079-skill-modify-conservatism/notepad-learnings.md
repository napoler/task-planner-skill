# Task Learnings: task-v079 技能修改保守化（Rule 36）

## New Requests
- 2026-09-17 用户原始诉求：①执行期技能报错禁盲改技能（先归因）②防已有功能被静默移除（文章优化技能流量分级功能丢失事故）③技能修改默认保守、需修改时请求用户 → 已全部落地为 Rule 36（36.2/36.3+36.4/36.5+36.4）

## What Worked
- 守卫三档实测先行（warn 默认不扰民，enforce 可升级）；授权判定=计划 scope 表 token 子串匹配，与既有 check-scope/scope 机制同源，零新概念
- SM-08 两段断言（SKIP→自动转实）一次成型，避免 P3/P4 两阶段锚冲突
- 派发任务书 35.3 落盘（subagent-state/N-*.md）+ 主 prompt 只放路径：8 次派发全部过 check-dispatch，prompt 长度永不触顶

## What Didn't Work
<!-- [task-v072 Rule 31.4] 错误描述 + 类别标签 -->
- 快捷 awk 统计 `$4` 数值化陷阱：`fail+=$4` 对 "FAIL=1" 字符串取 0 → 假 0 FAIL，险些放行真实回归（类别=执行偏差）。修正=按 '=' 分列 `split($4,b,"="); fail+=b[2]`。**教训：统计 awk 一律按 '=' 分列取值，禁用 $N 数值化；P1 的"337 正确"只是 Total=PASS 的巧合**
- 计划基于 187194b 而 master 被并行会话 v078 推进（base 漂移）：合并回合约只查文件级重叠，不查「合并后语义回归」；本任务靠部署前 extra 全量重跑兜住（类别=信息缺失）。**教训：P5 应常态加「合并后 master 全量重跑」一步**（本轮已实践，建议后续轮次写入 worktree-isolation.md 合约）
- 会话开始 v078 目录被挂本会话 sid：实为并行会话同仓工作的指针串扰，当时误判为废弃残根差点覆盖（已避走 v077→v079 编号）。**教训：同仓并行开发期，开工前先 `git reflog --date=iso` 考古最近 30 分钟提交，再判目录归属**
- Edit 两次误覆盖既有行（findings v078 行、Decisions ⑤ 行）：old_string 锚定数据行导致替换语义（类别=执行偏差）。**教训：追加内容锚定「段落头或行尾唯一锚」并让 new_string 包含 old_string 全文**

## 🚫 被否决方案（User Rejected — Rule 32）
- （无用户当轮否决；历史禁令已查：32.2 扫描 plans/ 历史 notepad 无命中项进候选）

## Files Modified
- 见 progress.md 各 Phase 段与 CHANGELOG [Unreleased] task-v079 条（15 文件：条款/config/守卫/接线/GATE/selftest×6/SKILL/README/batch-gate）

## Verification Results
- Verified: 全量 21 脚本 349/0（合并后 master，主进程修正 awk）；三实体位 diff -r=0；check-complete rc=0 全门 PASSED（含新 SKILL-MODIFY GATE 首次自证）；CR APPROVED；origin/master=89a6e5f
- Failed: S10 首跑 344/2（行数断言越限）→ B 类扩围 538→548 → 终跑归零；VC-5 残留 grep 首查 1（自条款示例）→ 泛化 Rules 1-N→1-N+1 → 0

## 📚 必要知识储备备注
- 本次新发现的知识源: reflog 时间线考古是并行会话检测的最快手段；selftest 行数上限断言分布在 execution-stability/skill-collab 两处（variant 模板「行数纪律」提示已列但计划期易漏，建议后续把「grep -rn '≤5[0-9][0-9]' scripts/」纳入 P1 锚点复验清单）
