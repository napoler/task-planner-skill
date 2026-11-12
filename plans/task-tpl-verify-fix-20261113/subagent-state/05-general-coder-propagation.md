# 05-general-coder-propagation (CA-9/CA-10 旧口径传播面纠正)

- **任务目标**: 在隔离 worktree 纠正 task-dispatch Rule 104 条款与 SA-19 断言的「96 类别列」旧口径，迁移为「类别=目标列内（An）前缀」+ 10 列固定列序新口径。
- **worktree**: `/mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113`
- **时间戳**: 2026-11-13T02:45:00+08:00（执行记录）
- **范围限制遵守**: 仅改 `skills/task-dispatch/references/critical-rules-dispatch.md` 与 `skills/task-planner/scripts/selftest-subagent-activation.sh`；未触碰 templates/、plan-template-kit/、task-planner/SKILL.md；未 commit；未触碰主仓/其他 worktree。

## 变更锚行号（worktree 内）

### 文件 1: `skills/task-dispatch/references/critical-rules-dispatch.md`
- **:244 标题括注**（CA-9）：`计划期 96 类别列` → `计划期类别标注（An 前缀）`
  - 锚原文：`### 104 子代理使用点显式标注纪律（P0, ... +SKILL 就地速查+计划期类别标注（An 前缀）+失败隔离硬阈值；...）`
- **:256 速查表列头**（CA-9）：保留 `96 类别` 文字但加防歧义半句
  - 锚原文：`| 动作类型 | 触发特征（可观察判据） | 默认执行体 | 96 类别（类别落 S-unit 目标列（An）前缀，非独立列） |`
- **:278 条款 104.3.1**（CA-9）：整条改为 10 列固定列序 +（An）前缀 + 口径迁移标记
  - 锚原文：`1. task_plan 模板 S-unit 表为 10 列固定列序，类别以目标列内（An）前缀标注（A1-A7 / 47.2 具名 / LOCAL 纯执行），使派发决策在计划期显式化、可审计（task-tpl-verify-fix-20261113 口径迁移）。`

### 文件 2: `skills/task-planner/scripts/selftest-subagent-activation.sh`
- **:97-99 SA-19 断言块**（CA-10，翻转口径）
  - :97 注释：`# SA-19 模板类别（An）前缀口径`
  - :98 断言变量：`sa19a="$(cnt '(A' "$TPL_PLAN")"; sa19b="$(cnt '96 类别' "$TPL_PLAN")"`
  - :99 判定：`sa19a>=1 && sa19b==0` → PASS；输出含 `(A=.../96 类别=0)`；不符输出 bad 文案同步改为前缀口径
  - 旧口径移除：不再断言 `96 类别 >= 2`。

## 自检原文

### 1) SA-19 selftest（worktree, `cd ... && bash skills/task-planner/scripts/selftest-subagent-activation.sh 2>&1 | tail -3`）
```
SA-19 PASS task_plan.md 含类别（An）前缀示范且 96 类别 字面=0（(A=3/96 类别=0）
SA-20 PASS dispatch 中 markup-exempt ≥3 处（104.1.2/104.6.1 等）
Total: 20 PASS=20 FAIL=0
```

### 2) 残留计数（`grep -rn '96 类别' skills/ | grep -vE '禁「96 类别」|（An）前缀|口径迁移|已废止' | wc -l`）
```
1
```

残留逐行与归类：
| 文件:行 | 命中 | 归类 |
|---|---|---|
| `skills/task-planner/scripts/selftest-subagent-activation.sh:98` | `sa19a="$(cnt '(A' "$TPL_PLAN")"; sa19b="$(cnt '96 类别' "$TPL_PLAN")"` | **负面/守卫断言字面**：SA-19 负向检测用，显式计数模板中旧字面 `96 类别` 应为 0；非教学旧口径、非列名传播。保留合理。 |

**期望外（正向旧口径）残留：0**

### 3) git diff --stat（worktree）
```
 .../plan-template-kit/references/template-guide.md |  1 +
 .../references/template-mapping.md                 |  7 +++++
 .../references/critical-rules-dispatch.md          |  6 ++--
 .../scripts/selftest-subagent-activation.sh        |  6 ++--
 skills/task-planner/templates/task_plan.md         | 34 +++++++++++++---------
 skills/task-planner/templates/verification.md      | 22 ++++++++++----
 6 files changed, 50 insertions(+), 26 deletions(-)
```
- 本任务直接修改：`skills/task-dispatch/references/critical-rules-dispatch.md`、`skills/task-planner/scripts/selftest-subagent-activation.sh`（恰 2 文件）。
- 其余 4 文件为前序单元（S1/S2/S3）既有改动，合计 6 文件属正常。

## 自审（对验收标准）
- [PASS] dispatch 244 标题括注改为「计划期类别标注（An 前缀）」。
- [PASS] dispatch 256 速查表列头保留 `96 类别` 并加「（类别落 S-unit 目标列（An）前缀，非独立列）」防歧义半句。
- [PASS] dispatch 278 条款改为 10 列固定列序 +（An）前缀 + 口径迁移标记（task-tpl-verify-fix-20261113）。
- [PASS] SA-19 断言翻转为 `(A` 前缀示范≥1 且 `96 类别` 字面=0，注释同步改「SA-19 模板类别（An）前缀口径」，ok/bad 输出格式保留。
- [PASS] selftest-subagent-activation.sh 尾部：SA-19 PASS、Total 20 PASS=20 FAIL=0（FAIL 计数未增）。
- [PASS] 残留分类清单在案：仅 1 处为 SA-19 负向断言字面，正向旧口径残留 0。
- [风险/备注] SA-19 依赖模板存在 `(A` 字面；当前基准模板含 `(A6)/(A7)` 示例已满足。若未来模板示例前缀命名风格变化需同步维护断言（属既有守卫维护面，非本次引入）。
