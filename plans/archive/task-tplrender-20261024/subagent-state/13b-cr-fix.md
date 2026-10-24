# 13b CR-fix：BLOCKER-1 + NIT-1/2/3/4 修复检查点

- 单元：CR 回炉修复（General Coder）
- 时间：2026-10-24
- worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024`
- 状态：**完成**（改动未提交，留交主进程按 §11.3 合并）

## 0. 事实核查：copy_template 现状行为

`copy_template()` 本体是裸 `cp`（无存在性判断），但**三个调用点全部有前置守卫**：

| 调用点 | 守卫 | 目标已存在时行为 |
|--------|------|------------------|
| `_init_files` for 循环 | `if [ -f "$file" ]; then echo "already exists, skipping"` | 跳过（不覆盖） |
| task_plan.md 独立块 | `if [ -f "task_plan.md" ]; then ... skipping` | 跳过（不覆盖） |
| user-session-log.md 独立块 | `if [ -f "user-session-log.md" ]; then ... skipping` | 跳过（不覆盖） |

结论：**现状是「跳过」而非「覆盖」**，不存在改写风险，无需 STOP 上报范围扩张。
故「本轮新建」== 「进入 cp 分支」== 「目标原不存在」，三者等价。

## 1. BLOCKER-1 修复

根因：渲染循环 `for _rf in *.md` 无新建过滤 → 重复 init 对既有文件重跑 8 条旧形态映射，
改写 user-session-log.md 逐字记录（`[DATE]`→日期、`<task-id>`→目录名），并因记录内
`{{FOO}}` 触发残留校验 rc=1；`.session-log-baseline` sha 随之失配。

修法：
1. 新增 `_created_this_round=()`（声明于 `_init_files` 循环前，附 Rule 45 三要素注释）。
2. 四处投递点入列：
   - `_init_files` 循环内 `copy_template` 成功后
   - task_plan.md variant/通用分支（`esac` 之后）
   - task_plan.md 的 `elif copy_template "task_plan.md"` 通用分支
     （*首轮遗漏点*：初次实现只加了 variant 分支，实弹测试 1 发现 task_plan.md 未被渲染，
      trace 定位后补齐）
   - user-session-log.md `copy_template` 成功后
3. 渲染循环改为 `for _rf in "${_created_this_round[@]}"`；重复 init 时列表为空 → 零迭代。

## 2. NIT 修复

| NIT | 位置 | 内容 |
|-----|------|------|
| NIT-1 | `_strip_html_comments` 头注释 | 补已知局限：未闭合 `<!--` 吞余文（漏拦不误拦）、现网 7 模板注释均配平、不在助手内做配平探测 |
| NIT-2 | `_sed_escape_repl` 头注释 / render_template 实现取舍 | 「L694」硬编码行号漂移 → 改为「lane 定级写入段」函数/描述引用（两处） |
| NIT-3 | render_template 替换序注释 | 改写「`<task>` 吃掉 `<task-id` 前缀」的错误理据：两 pattern 各带闭合 `>`，互不为前缀，顺序非正确性约束 |
| NIT-4 | 渲染循环守卫 | `[ -e "$_rf" ]` → `[ -f "$_rf" ]` |

## 3. 实弹验证数字

### 测试 1 新建场景（`/tmp/crfix1/plans/task-crfix`）
```
RC=0
task_plan.md 中 'task-crfix' 出现次数 = 5
task_plan.md 中 'CR修复验证' 出现次数 = 1
非注释区 {{TOKEN}} 残留 = 0（7 个 .md 全扫）
head -1 task_plan.md = "# Task Plan: CR修复验证"
```

### 测试 2 重复 init（BLOCKER 复验）
前置：向 user-session-log.md append 假条目（含 `[DATE]` / `<task-id>` / `{{TEST_KEEP}}`）、
task_plan.md Goal 值手改为 `CR手改哨兵值ZZZ`。
```
RC2=0                       （不误 fail-closed；修复前此值为 1）
user-session-log.md sha: before == after（SHA_UNCHANGED）
假条目原文逐字匹配 count = 1
Goal 手改哨兵 count = 2（改前改后一致）
二次 init 日志中 FAIL/残留未定义 count = 0
```

### 修复前代码回归复现（护栏捕获力实证）
把渲染循环人为还原成 `for _rf in *.md` 后跑同一场景：
```
rc1=0, rc2=1                      （fail-closed 误阻断恢复）
user-session-log.md sha = CHANGED （BLOCKER 复现）
假条目原文 count = 0              （[DATE]/<task-id> 被映射改写）
{{TEST_KEEP}} 仍残留             （触发残留校验 → rc=1）
```

### 全量 selftest
```
cd <worktree> && bash skills/task-planner/scripts/run-selftests.sh
Total: 93 PASS=93 FAIL=0 (run=93 reused=0)
[reused] selftest-session-log (rc=0 PASS=13 FAIL=0)   ← 含新增 SL-12
```

## 4. SL-12 新增断言（selftest-session-log.sh）

自然挂点：该脚本已有 SL-11 动态 fixture（mktemp + trap EXIT）范式，复用同一 mktemp 根
（`$SL11_TMP/plans/task-sl12`，trap 已覆盖清理），未新增 selftest 脚本文件。

断言：二次 init 后 user-session-log.md sha 不变 ∧ 假条目原文仍在 ∧ Goal 手改保留 ∧ 两次 rc=0。
带 Rule 45 三要素注释（What/Why/时间）。原 11 组 → 12 组（suite 级 PASS 12→13）。
`run-selftests` 的 `Total: 93` 是 **suite 数**（非断言数），故总数不变。

## 5. 遗留风险（≤3）

1. **空 `_created_this_round` 依赖非 `set -u`**：脚本当前仅 `set -e`，空数组展开为 0 次迭代正常；
   若未来加 `set -u` 且 bash < 4.4，需改写 `${arr[@]+"${arr[@]}"}` 形态。
2. **trivial 档未单独实弹**：`TRIVIAL_CODE_TIER=1` 路径入列 progress/verification/task_plan 三文件；
   selftest-tier-b 等套件全绿，但未做 trivail 档两次 init 的手工复验。
3. **渲染面收窄的副作用**：若未来新增第 8 类计划文件、且不经 copy_template 创建，
   将不再被自动渲染（需显式入列）——这是有意的显式契约，但存在静默漏渲染的理论面。

## 6. 变更文件

| 文件 | 变更 |
|------|------|
| `skills/task-planner/scripts/init-session.sh` | +50 / -14 |
| `skills/task-planner/scripts/selftest-session-log.sh` | +28 / -0 |

`git status --short` 仅上述 2 文件（禁触面未破）。
