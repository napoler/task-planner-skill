# 04 Test Engineer — task-v059 Phase 4 checkpoint
<!-- subagent-state 检查点: 每完成一个里程碑 append 一段 -->

## 里程碑 1: 材料已读 (2026-09-10)
- 已 Read task_plan.md / findings.md / progress.md
- 已 Read 范式: selftest-dispatch.sh(12 用例 assert 风格/mktemp/trap/PASS-FAIL 计数/exit $((FAIL>0))) / selftest-plan-dispatch.sh(mk_root 夹具)
- 已 Read 被测: resolve-plan-dir.sh (双参 SID, side TTL 86400s, slug 校验, 解析链 side→legacy→mtime→根单文件, 恒 exit 0)
- 已 Read 被测: set-active-plan.sh (set --sid / 旧位置参数 legacy / --show 双视图 / gc -mmin +1440)
- 已 Read 被测: init-session.sh:138-157 (CLAUDE_CODE_SESSION_ID 有值→side, 无值→legacy; CWD 守卫要求父目录 basename=plans)

## 里程碑 2: 脚本设计与落盘
- 新建 /mnt/data/dev/task-planner-skill-worktrees/task-v059-active-plan-race/skills/task-planner/scripts/selftest-active-plan.sh（116 行）
- 9 项要求映射 13 计数（01/01b,02,03,04/04b,05a/05b,06,07,08a/08b,09）；T08 实测 init-session 根遍历（worktree 向上到 / 无 .claude/plan-templates 命中，find_project_templates return 1 不触 set -e，走 built-in 模板，安全）
- zcopy 6685a93 核实：git show --stat = 9 文件 diff 不含 selftest → 97/97 为提交时一次性记录，未入库

## 里程碑 3: 测试执行
- selftest-active-plan.sh 首跑：Total: 13 PASS=13 FAIL=0 EXIT=0
- 复跑 5 selftest（active-plan/dispatch/delegation/plan-dispatch/fallback）：EXIT 全 0；Total 13/12/38/6/21，合计 90 用例 fail=0
- 输出留存 /tmp/v059-<name>.out（仓外可弃）

## 里程碑 4: 收尾与污染核查
- git status（worktree）：13 M（Phase 1 的 9 源码 + Phase 3 的 4 文档，Phase 4 无增量 M）+ ?? selftest-active-plan.sh + ?? plans/.active_plan_side/ + ?? plans/task-v059-active-plan-race/（原排查记录遗留，非本 Phase 新增）
- /tmp/task-planner-dispatch-warn-selftest-* 无残留；plans/ 实体目录复测无污染
- 三文件回填 + checkpoint 完成；bash -n 语法 OK
