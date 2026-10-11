# sub:17-code-assistant-S10 checkpoint

status: completed

## 最终结论
全量回归 3 个新增 FAIL 的锚级联修复完成（2 文件最小修改，worktree 内）：

1. **T02 FAIL（registry rows=62 应 63）** — 根因：task-v150 S6 新增
   `scripts/selftest-split-pattern-library.sh` 未登记 registry。
   修复：`selftest-registry.tsv` 末行追加 1 行（tab 分隔 4 列同构，cat -A 校验 ^I 在位）：
   `selftest-split-pattern-library.sh` / domain「Rule 21.6 拆分模式库守卫（task-v150 S6，SP-01..13）」
   / trigger_scenarios（库文件 11 模式/伴飞表 21.6.5/既有锚/SKILL 接线/dispatch 契约行）
   / dep_anchors（`references/split-pattern-library.md;references/critical-rules.md;SKILL.md;templates/subagent_dispatch.md`）。

2. **SR-12 FAIL（总行数 63 应 64）** — 与 T02 同源（动态口径=脚本数 63+表头=64）。
   追加 registry 行后自愈，无独立修改。

3. **selftest-skill-split.sh T-主 钉值断言 FAIL（SKILL.md 498→502 > 钉值 500）** —
   `:44` 钉值 500→510（`-le 500`→`-le 510`），断言描述文本同步更新（演进链追加「task-v150 S10 …498→502，钉上调 500→510」，先例链追加 v150），
   并按脚本内「钉值随内容演进同步上调」先例追加 1 行带 label 注释（:44 上方）。`-le 558` 总上限与其他逻辑未动。

## 验证（4 脚本全 rc=0）
- `bash scripts/selftest-registry.sh` → Total: 5 PASS=5 FAIL=0（registry rows=63, actual selftest=63）rc=0
- `bash scripts/selftest-self-resolution.sh` → Total: 13 PASS=13 FAIL=0（SR-12: 总行数 64=脚本数+表头）rc=0
- `bash scripts/selftest-skill-split.sh` → Total: 41 PASS=41 FAIL=0 rc=0
- `bash scripts/selftest-split-pattern-library.sh` → Total: 13 PASS=13 FAIL=0（仍 rc=0，无回归）

## git diff 自查
- `selftest-registry.tsv`：+1 行（纯追加），0 删除
- `selftest-skill-split.sh`：`-le 500`→`-le 510` + 断言描述文本钉值同步 + 新增 1 行级联注释；零删除既有行
- 未触碰其他文件（worktree 内其余 M/?? 文件：critical-rules.md / split-pattern-library.md / selftest-split-pattern-library.sh 均为本任务 S6 已有产出，非本次修改）

## 排除了的风险
- tsv 行格式与既有行完全同构（tab 分隔，4 字段无空单元格，T05 通过）
- 未引入新 config 键；未改 `-le 558` 总上限；未触碰其他 worktree
