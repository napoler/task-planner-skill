# Checkpoint 02-exec-p2s2（P2-S2: CRIT Rule 42 追加 42.6）

- 状态: done
- 时间: 2026-09-30
- 操作: 在 worktree 内 critical-rules.md 的 42.5 行后、`### 43` 节头前插入 42.6 主体+42.6.1~42.6.4 五段（逐字取自任务书 02-task-brief.md，无改写）；git 未 commit/add。

## 定位证据
- 插入前: `grep -n '^42.5'` = 行 423；`grep -n '^### 43'` = 行 425（其间 :424 为空行）；原文件 432 行。
- 插入后: 文件 437 行（432+5）。

## 验收自查
1. grep 五个措辞各 ≥1: `^42.6 `=1, `42.6.1`=1, `42.6.2`=1, `42.6.3`=1, `42.6.4`=1 — PASS
2. 「未经一致性校验，不直接追加新内容」=1；「完成前对齐标准流程」=1 — PASS
3. `git diff --numstat` 对 critical-rules.md: `5 0`（纯增, deletions=0）；diff 显示 42.5 行与 `### 43` 节头零变化 — PASS
4. `wc -l`: 432 → 437 — PASS（预期约 446 为估算偏差, 实际插入 5 行正文, 空行复用原有 :424）
5. `git -C <wt> status --short`: ` M skills/task-planner/references/critical-rules.md` 及 ` M skills/task-planner/review-library/alignment-review/SKILL.md`。
   - 注意: SKILL.md 的 M 态**非本次修改**——本次仅 Edit critical-rules.md 一个文件；该文件 M 态为 worktree 内前序步骤（P2-S1 或更早）已存在的工作区变更。CRIT 仅该文件 M 且纯增 — PASS。

## 硬约束核对
- 42.1-42.5/Rule 43 原文零改动: PASS（diff 全为 + 行）
- 未使用「1-4x」越界字面; 引用既有规则写全名（42.5/43.4 式）: PASS
- 只动该文件该插入位; 禁写其他文件: PASS（仅 1 次 Edit 目标文件）
- 禁 git commit/add: PASS（仅 git diff/status 只读操作）

## 恢复点
若需回滚: `git -C <wt> restore skills/task-planner/references/critical-rules.md`（会同时丢弃前序步骤对该仓其他文件的变更, 需按文件粒度 restore 本文件）。
