# S14 独立终验（Verifier，全新上下文，只读验证）

- 时间: 2026-10-24
- 验证对象: worktree `/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024`（分支 wt/task-tplrender-20261024）
- HEAD: da7a3a43cf5d24042d6f2461630a54e08bc8ab5f（= da7a3a4，符合预期）
- 结论总览: 7/8 PASS（VC-2.4 为「规格期望 vs 环境」错配，非代码缺陷）；合并前置 PASS；范围自检 PASS

---

## VC-0 前置 / 合并前置
命令:
```
git rev-parse HEAD                                  -> da7a3a43cf5d24042d6f2461630a54e08bc8ab5f
git status --short                                  -> (空)
git log --oneline master..HEAD | wc -l              -> 3
git log --oneline master..HEAD                      -> da7a3a4 / dc426c1 / b983b3b
```
判定: **PASS** — HEAD=da7a3a4，工作树干净，3 提交符合预期。

## VC-1 初始化 + 无残留 token
命令: `bash <wt>/skills/task-planner/scripts/init-session.sh "S14终验任务"`（cwd=/tmp/tplrender-s14v/plans/task-s14vtest）
输出末行: `RC=0`；`6/6 planning files verified`；`user-session-log.md verified`；`active_plan 指针已指向: task-s14vtest`
残留检查: `grep -rE '\{\{[A-Z_]+\}\}|\[Brief Description\]|\{task-id\}|<task-id>|\{task-name\}|\[DATE\]|\[YYYY-MM-DD|\$\{TASK_PLANNER_ROOT:-' . | grep -v '<!--' | wc -l` -> **0**
判定: **PASS**（RC=0，残留 token 数=0）。

## VC-2 产物变量注入
- VC-2.1 `grep -rl "task-s14vtest" --include='*.md' . | wc -l` -> **3**（≥1）PASS
- VC-2.2 `grep -rl "S14终验任务" . | wc -l` -> **2**（≥1）PASS
- VC-2.3 `grep -rl "$(date +%Y-%m-%d)" --include='*.md' . | wc -l` -> **1**（≥1）PASS
- VC-2.4 `grep -rl "$HOME/.zcode/skills/task-planner" --include='*.md' . | wc -l` -> **0**（期望 ≥1）**规格错配**
  实际渲染根路径 = 脚本自身位置派生: `/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024/skills/task-planner`
  `grep -rl "/mnt/data/.../task-tplrender-20261024/skills/task-planner" --include='*.md' . | wc -l` -> **2 文件 / 10 行**（≥1）
  根因: init-session.sh:186 `skill_root="$(cd "${SCRIPT_DIR}/.." && pwd)"`，L225/L234 以 e_root 替换 {{TASK_PLANNER_ROOT}} 与 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` 死串。设计为「由安装位置派生、平台无关」（L62 注释）。VC-2.4 硬编码 $HOME 安装路径，但本次是从 worktree 直跑脚本，故渲染 worktree 路径。
  判定: **FAIL(字面) / PASS(意图)** — 变量已正确渲染、无原生死串残留；非代码缺陷。

## VC-3 语义占位保留（脚本不越权替换语义占位）
- `grep -rc '<用户原话' --include='*.md' . | awk -F: '{s+=$2} END{print s}'` -> **2**（≥1）PASS
- `grep -rc '<按需增行>' --include='*.md' . | awk -F: '{s+=$2} END{print s}'` -> **1**（≥1）PASS
判定: **PASS**。

## VC-4 未定义 token fail-closed
操作: 向 verification.md 追加正文行 `TEST {{UNDEFINED_VAR_XYZ}}`（注释行外），重跑 init。
输出: `RC=1`
stderr:
```
[render] 残留未定义 token: {{UNDEFINED_VAR_XYZ}} （文件: verification.md，fail-closed）
[render] FAIL: verification.md 残留未定义 token: {{UNDEFINED_VAR_XYZ}}
[init] ERROR: 模板渲染未通过（残留未定义 token），init 终止（fail-closed, task-tplrender S4）
```
`grep -c "UNDEFINED_VAR_XYZ" /tmp/vc4.err` -> **2**
恢复: 从备份还原 verification.md，`grep -c UNDEFINED_VAR_XYZ verification.md` -> 0；重跑 init -> **RC=0**
判定: **PASS**（exit≠0 且 stderr 含 token；已恢复原状）。

## VC-5 全量 selftest
命令: `bash <wt>/skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -3`
输出: `Total: 93 PASS=93 FAIL=0 (run=93 reused=93)`
追加复验（消除陈旧缓存风险）: `run-selftests.sh --fresh 2>&1 | tail -3` -> `Total: 93 PASS=93 FAIL=0 (run=93 reused=0)`
判定: **PASS**（新鲜执行 93/93）。

## VC-6 SKILL.md 渲染层指示面
命令: `grep -n "渲染层" <wt>/skills/task-planner/SKILL.md`
输出: `41:  - **脚本侧渲染（tplrender 2026-10-24）**：init 渲染层自动替换模板机械占位符（{{TASK_ID}}/任务名/日期/路径 6 变量+8 旧形态兼容映射，含 ${TASK_PLANNER_ROOT:-…} 死串修复）；**模型禁手工修正机械占位**…残留 {{大写}} token 非注释行触发 fail-closed exit 1`
判定: **PASS**（命中行 41，位于前 60 行内）。

## 范围越界自检
`git diff --name-only master...HEAD`（三点=仅分支引入）-> **12 文件**，全部在枚举范围内:
1. `.zcode/plan-templates/knowledge-brief.md`
2. `skills/task-planner/SKILL.md`
3. `skills/task-planner/scripts/init-session.sh`
4. `skills/task-planner/scripts/selftest-plan-tier.sh`
5. `skills/task-planner/scripts/selftest-session-log.sh`
6-12. `skills/task-planner/templates/{findings,knowledge-brief,notepad-learnings,progress,task_plan,user-session-log,verification}.md`
- `templates/variant/` 命中数 -> **0**
- scripts 仅 3 个（init-session + 2 selftest），无其他 scripts
- 说明: 原始 `git diff master..HEAD --stat` 显示 22 项，其中 10 项 `plans/task-tplrender-20261024/*` 为 **master 侧新增**（master tip a39398a，晚于 merge-base c722261），在 wt 分支缺失故显示为删除——属分叉，非分支改动。分支实际改动=上述 12 文件。
- 备注: 父任务描述「共 11 文件」，但其枚举项求和实为 12；实际=12，与枚举一致（"11" 为父描述 off-by-one）。
判定: **PASS**（无越界；12 文件全部在枚举范围）。

---

## 汇总
| 项 | 判定 | 关键数字 |
|----|------|---------|
| VC-1 | PASS | RC=0; 残留 token=0 |
| VC-2.1 | PASS | 3 |
| VC-2.2 | PASS | 2 |
| VC-2.3 | PASS | 1 |
| VC-2.4 | FAIL(字面)/PASS(意图) | 字面 0；实际 worktree 根路径 2 文件/10 行；脚本 L186 由 SCRIPT_DIR 派生 |
| VC-3 | PASS | 用户原话=2; 按需增行=1 |
| VC-4 | PASS | RC=1; stderr 含 token x2; 已恢复 RC=0 |
| VC-5 | PASS | 93 PASS=93 FAIL=0（--fresh run=93 reused=0） |
| VC-6 | PASS | 行 41（<60） |
| 合并前置 | PASS | status 空; 3 提交; HEAD=da7a3a4 |
| 范围自检 | PASS | 12 文件全在范围; variant=0 |

总判定: **PASS**（唯一非 PASS 项 VC-2.4 为验证规格的环境错配，非实现缺陷；建议父任务修正 VC-2.4 期望为「脚本所在 skill 根路径」而非硬编码 $HOME）。
