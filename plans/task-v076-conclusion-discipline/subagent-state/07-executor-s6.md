# 检查点 07: executor S6 — selftest-conclusion-discipline.sh

## 任务
task-v076 S6: 在 worktree 新建 scripts/selftest-conclusion-discipline.sh（Rule 35 条款存在性静态断言），仅新增 1 文件。

## 状态: 完成

## 产出文件（唯一新建）
/mnt/data/dev/task-planner-skill-worktrees/task-v076-conclusion-discipline/skills/task-planner/scripts/selftest-conclusion-discipline.sh
- 17 断言 CD-01~CD-17，风格照 selftest-veto.sh（宽容锚、total/ok/bad 计数、末行 printf Total、FAIL>0 exit 1）
- 路径解析: SCRIPT_DIR 基于 BASH_SOURCE 自身位置；SKILL/RULES/DISPATCH/TMPL/NOTEPAD_TPL 全部相对 SCRIPT_DIR，任意 cwd 可跑
- 头注释: 用途（task-v076 Rule 35 静态守护）+ 维护注记（S-unit ID 契约=纯数字，check-plan-dispatch.sh 正则 ^\|\s*S[0-9]+\s*\| 不认字母后缀，task-v076 attest 拒锁教训）
- CD 清单: CD-01 ### 35 标题 / CD-02~07 35.1-35.6 各一条 / CD-08 22.4 行含 Rule 35.3 大输入落盘引用 / CD-09 SKILL Rule 35（P0）列表行 / CD-10 | C23 | / CD-11 1-35 计数≥3 / CD-12 1-34 零命中 / CD-13 五档兜底引用注 / CD-14 check-dispatch 补救(Rule 35.3) / CD-15 仍含 ⚠ prompt 长度 / CD-16 模板 超限补救(Rule 35.3) / CD-17 notepad 🚫 被否决方案

## 自验证据（2026-09-16）
- bash -n: SYNTAX_OK
- bash <脚本>（cwd=/tmp 与 / 双跑）: Total: 17 PASS=17 FAIL=0, rc=0
- git -C <worktree> status --short: 仅 `?? skills/task-planner/scripts/selftest-conclusion-discipline.sh`
- 邻接回归: selftest-veto.sh（worktree）12/13（VT-10 FAIL 为 S4 升级 1-35 后既有残留，master 13/13，非 S6 引入）；selftest-dispatch.sh 22/22 PASS

## 踩坑记录
- 初版 CD-11/CD-12 把 grep -c 计数展开进 eval 字符串: ① 输出消息中 $(...) 原样不展开（字面）② 第二版 eval 字符串未带 2>/dev/null 导致 0 命中时 grep 报错串入输出；修法=预计算 n35/n34 变量（`|| true` 防 set -u），check 内直接用数字字面。
- grep -c 0 命中时退出码 1 且输出 "0"，`|| echo 0` 会产生 "0\n0" 两行，必须用 `|| true`。

## 簿记
- progress.md 已追加 P3 段 [S6][executor] 动作行
- 未改其他任何文件（worktree git status 仅新脚本 untracked）
