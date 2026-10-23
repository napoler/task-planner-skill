# 06-impl-s4 checkpoint — CLAUDE.md + README_zh.md 纪元字面 1-93→1-94 级联

task: task-focus-plan-split-20261023 / Phase 2 / S-unit S4
executor: 子代理（隔离上下文）
date: 2026-10-23
status: **DONE**（3/3 验收 PASS）
前置: S2/S3/S3b 已完成（03-impl-s2 / 04-impl-s3 / 05-impl-s3b 检查点在案）
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023（只改本 worktree 内两文件）

## 改前登记（行号 / 改前原文 / 改后原文 / 判定）

| # | 文件 | 行号 | 改前原文（关键 span） | 改后原文（关键 span） | 判定 |
|---|------|------|----------------------|----------------------|------|
| 1 | CLAUDE.md | L33 | `    ├── critical-rules.md ← Rules 1-93 核心执行约束` + 行尾 7 段 HTML 注释 | `    ├── critical-rules.md ← Rules 1-94 核心执行约束` + 行尾 7 段 HTML 注释（逐字未动） | 活跃正文 → 改 |
| 2 | README_zh.md | L136 | `        ├── critical-rules.md      ← Rules 1-93 核心执行约束` + 行尾 7 段 HTML 注释 | `        ├── critical-rules.md      ← Rules 1-94 核心执行约束` + 行尾注释未动 | 活跃正文 → 改 |
| 3 | README_zh.md | L229 | `| `skills/task-planner/references/critical-rules.md` | Rules 1-93 —— 自定义前必读` + 行尾 7 段 HTML 注释 | `| `skills/task-planner/references/critical-rules.md` | Rules 1-94 —— 自定义前必读` + 行尾注释未动 | 活跃正文 → 改 |

方法: grep -n "1-93" 定位 → Read 目标行 ±3 行判语境 → 精确 Edit（old_string 仅含活跃正文 span，天然不触碰行尾注释）；git diff -U0 复验：3 行 diff 中注释段两侧逐字一致。

## 注释保留清单（一律未动）

- 3 个目标行行尾的 7 段 HTML 注释（task-v152/v153/v158/v163/v191/v195 演进记录，含历史字面 `1-69→1-71`、`1-72→1-75`、`1-75→1-83`、`1-91→1-92`、`1-92→1-93`）——selftest WF-10 锚依赖，保留。
- 改后 grep 残余 1-93 全部位于 HTML 注释内：
  - CLAUDE.md L33: 注释 `2026-10-21 task-v195 演进 1-92→1-93` → 注释保留 ✓
  - README_zh.md L136: 同上注释字面 → 注释保留 ✓
  - README_zh.md L229: 同上注释字面 → 注释保留 ✓
  - 无注释外 1-93 活跃字面残留。

## 侦察结果

预期「CLAUDE.md L33 附近 1 处；README_zh.md L136/L229 附近 2 处」——实际 grep 全量命中即此 3 处（每处 1 个活跃 span + 1 个注释内历史字面），无多余活跃命中，无遗漏。

## 验收结果（原文输出）

AC-1 `grep -c "Rules 1-94"`：
```
A(Rules 1-94 count): 1
B(Rules 1-94 count): 2
```
→ CLAUDE.md ≥1 ✓；README_zh.md ≥1 ✓

AC-2 残余 1-93 判定（grep -n "1-93" CLAUDE.md README_zh.md）：
```
CLAUDE.md:33: ...← Rules 1-94 核心执行约束 ... <!-- ... 1-92→1-93（Rule 93 规范再召回落地...） -->
README_zh.md:136: ...← Rules 1-94 核心执行约束 <!-- ... 1-92→1-93 ... -->
README_zh.md:229: ...Rules 1-94 —— 自定义前必读 <!-- ... 1-92→1-93 ... -->
```
3 条命中全部在 `<!-- -->` 注释行内（活跃正文已 1-94 化）✓

AC-3 `git -C <worktree> diff -- CLAUDE.md README_zh.md`：
```
 CLAUDE.md    | 2 +-
 README_zh.md | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)
```
逻辑改动行数 = 3（CLAUDE.md L33 + README_zh.md L136/L229），≤4 预算内 ✓；diff -U0 复验仅 1-93→1-94 单 span 替换，零范围外改动。

## 负结果声明

无新增 1-93 活跃字面；未发现 S4 范围外的级联遗漏（本 unit 仅负责 CLAUDE.md + README_zh.md 两文件；SKILL.md/planner README/docs 等属 S5-S7 其他 unit，未触碰）。
