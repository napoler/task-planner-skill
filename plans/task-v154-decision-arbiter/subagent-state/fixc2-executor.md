# Fix-C2 检查点 — 守卫主锚演进 1-68→1-69（RC-11 / TS-05）

- 时间: 2026-10-10
- 任务: task-v154 合并冲突后修复第二批（R4 回归防护，守卫锚随内容演进，v147/v153 先例同款；前置 Fix-C1 已完成 SR-07/LA-12）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter
- status: done

## 背景事实（实测）
- SKILL.md 主锚实测: `Critical Rules 1-69` = 1（L287 章节引言行），`Critical Rules 1-68` = 0，`1-39` = 0
- 四守卫中本批 2 个（RC-11 / TS-05）仍断言 v153 时代 `Critical Rules 1-68`≥1 → 修复前 FAIL

## 改动（2 文件，仅断言模式 + 注释演进，无逻辑改写）
### A skills/task-planner/scripts/selftest-requirement-coverage.sh (RC-11)
- L129 grep 模式 `'Critical Rules 1-68'` → `'Critical Rules 1-69'`
- L131/L133 ok/bad 诊断串 1-68 → 1-69（含「SR-07 同步演进」「SR-07 主锚被改动」联动文字保留）
- L129 上方追加演进注释行（对齐 v144-v153 既有格式）:
  `# [2026-10-10 task-v154 合并并集演进] '1-68'→'1-69'：task-v153 Rule 68 与 task-v154 Rule 69 合流落地，SKILL 章节引言行最终态 1-69`

### B skills/task-planner/scripts/selftest-tool-selection.sh (TS-05)
- L62 grep 模式 `'Critical Rules 1-68'` → `'Critical Rules 1-69'`
- L64 ok/bad 诊断串 1-68 → 1-69
- L62 上方追加同款演进注释行

> RC-11 对 SR-07 的「文件间联动引用」实测=纯注释/诊断层文字（L120/L122/L123/L131/L133），**无代码级 grep self-resolution 脚本 / 调用其输出**——联动机制=与 SR-07/LA-12/TS-05 对同一 SKILL.md 主锚的并行断言（同一字面锚），故无额外代码引用需改。此点已 Read 确认（grep `self-resolution|SR-07|selftest-self` 仅命中注释行）。
> 历史遗留描述性注释中的 `1-65`（L118/L119/L9）未改写——沿用 v144-v153 既有最小改法「补注演进史行」（v153 同款，未回改描述行）。

## git diff（摘要）
```
 selftest-requirement-coverage.sh | L129 grep 1-68→1-69 + L131/L133 诊断串 + 演进注释行
 selftest-tool-selection.sh       | L62  grep 1-68→1-69 + L64 诊断串 + 演进注释行
 2 files changed (纯断言模式 + 注释演进)
```
`git status --short`: 本批仅上述 2 文件 `M`；另 selftest-self-resolution.sh / selftest-lane-advancement.sh 为前置 Fix-C1 既有 `M`（非本批触碰）。其他文件零触碰。

## 运行尾部
### A bash selftest-requirement-coverage.sh  → exit 0
```
RC-11 PASS SKILL.md 主锚 'Critical Rules 1-69' ≥1 且 '1-39' 变体 0（SR-07 同步演进）
Total: 23 PASS=23 FAIL=0
EXIT=0
```
### B bash selftest-tool-selection.sh  → exit 0
```
TS-05 PASS SKILL.md 字面锚 Critical Rules 1-69≥1 且 1-39=0
Total: 12 PASS=12 FAIL=0
EXIT=0
```

## 1-68 残留检查（四守卫）
- `grep -c 'Critical Rules 1-68'`：self-resolution=0 / lane-advancement=0 / requirement-coverage=0 / tool-selection=0 → 全部 =0
- 仅存于演进注释内（`'1-66'→'1-68'` 历史行 + `'1-68'→'1-69'` 新行），不含 "Critical Rules" 前缀，符合验收口径

## 验收自查
- [x] bash selftest-requirement-coverage.sh 全 PASS exit 0（RC-11 转 PASS 且 SR-07 联动不回退）
- [x] bash selftest-tool-selection.sh 全 PASS exit 0（TS-05 转 PASS）
- [x] `grep -c 'Critical Rules 1-68'` 四守卫文件 =0
- [x] diff 仅断言模式+注释演进，无逻辑改写
- [x] 其他文件零触碰

## next_step
主进程复跑全量回归（预期仅剩 AC-04 部署暂态）后 smart-merge-back --deploy 收口
