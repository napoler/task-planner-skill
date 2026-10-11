# [sub:21-code-assistant-S13] S13 Code Review 修复波 1（2 文件最小修改）

状态：done（2026-10-09）

## 改动清单
1. `skills/task-planner/scripts/selftest-split-pattern-library.sh`
   - SP-04（:41-43）：`grep -cE '21\.6\.[1-5]'` → `21\.6\.[1-6]`，阈值 ≥5 → ≥6；断言文本改「21.6 子条锚(1-6)」；SP-04 注释同步为「21.6.1-21.6.6 六子条锚 ≥6」
   - SP-03（:28-39）：伴飞表阈值 ≥7 → ≥6（对齐 21.6.5 条款「≥6 行」，守卫不得严于契约）；注释/ok/bad 文本同步
   - 文件头守护面注释（:5）：「21.6 五子条」→「21.6.1-21.6.6 六子条」
2. `skills/task-planner/scripts/selftest-registry.tsv` :64
   - 描述列「critical-rules 21.6 五子条与」→「critical-rules 21.6.1-21.6.6 与」（仅描述文本，tab 列数 4 不变，已验证）

## 验证证据
- `bash skills/task-planner/scripts/selftest-split-pattern-library.sh` → Total: 13 PASS=13 FAIL=0，rc=0
  - 现库值核对：SP-02 模式数=11、SP-03 伴飞表=8 行(≥6 通过) 路径 7 条 0 缺失、SP-04 21.6.x 命中=6、SP-10 来源=12、SP-11 贡献行=11
- `bash skills/task-planner/scripts/selftest-registry.sh` → Total: 5 PASS=5 FAIL=0 (registry rows=63, actual selftest=63)，rc=0
- `git diff`：仅 2 文件，10+/10-，纯数值/描述文本改动，断言总数保持 13，结构零改动，未触及其他文件/worktree

## 负结果
- 检查了 selftest-registry.tsv 表头与 :64 行列数（均 4 列）→ 无结构破坏
- 未发现其他文件对 SP-03/SP-04 阈值或「五子条」措辞的依赖冲突（改动范围限 2 文件）
