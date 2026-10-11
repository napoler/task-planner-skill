# [sub:06-executor] Fix-A (CR round, P0-1 + P0-2) checkpoint

status: done
agent: executor
task: Code Review Gate (CHANGES_REQUESTED) 修复轮 A
worktree: /home/terry/task-planner-skill-worktrees/task-v068-execution-stability

## 修改摘要（仅 2 文件，worktree 内）

### P0-1 zcode-posttooluse.sh（scripts/zcode-posttooluse.sh）
- 原 L57（`case ... *) [ -n "$fp" ] && [ -f "$CWD/$fp" ] && fp="$CWD/$fp" ;; esac`）存在两个盲区：
  1. 含 slash 相对路径（如 `plans/task-x/task_plan.md`）不命中该分支 → 比较永不等 → 重锁静默 no-op
  2. 纯文件名（`task_plan.md`）的 `[ -f "$CWD/$fp" ]` 探测在 plan 三件套布局（$CWD/plans/task-x/）下也 false
- 修复：`case "$fp" in */*) ;; *)` 分支内：
  - 先试 `CWD/$fp`（常态纯文件名直拼）
  - 再试 glob `CWD/plans/*/$fp`（plan 三件套布局常态）
  - 仅当候选**在 CWD 侧真实存在**才采用（`[ -f "$cand" ]`），零子进程短路（未命中 case `*/*` 时仍零子进程，纯 bash test）
- owner==SID 护栏（L73-78）零子进程短路均保留
- 位置：scripts/zcode-posttooluse.sh:57-69（新增 12 行，替换原 1 行）

### P0-2 zcode-userpromptsubmit.sh（scripts/zcode-userpromptsubmit.sh）
- 原 L32 `tr -cd 'a-zA-Z0-9_-'` 与 L106 `tr -cd 'a-zA-Z0-9_-'` 与全仓 canon `tr -cd 'a-zA-Z0-9'` 失配：
  - 含 `-` 的真实 sid（如 `sess-abc123`）→ 本 hook 侧 UPS_SID/owner 含 `-` 保留，pretooluse/check-scope/check-delegation 侧剥离 `-` → 永失配 → 委派门控被无声解除
- 修复：
  1. L32（现 L34）`tr -cd 'a-zA-Z0-9_-'` → `tr -cd 'a-zA-Z0-9'`
  2. L106（现 L110）`tr -cd 'a-zA-Z0-9_-'` → `tr -cd 'a-zA-Z0-9'`
  3. 补 P2-3：`[ -z "$UPS_SID" ] && UPS_SID="default"`（全非法字符剥空时防裸空串，紧接 L34 之后）
- env 兜底链（E3）本身保留不动（stdin → CLAUDE_CODE_SESSION_ID → ZCODE_SESSION_ID → default）
- 位置：scripts/zcode-userpromptsubmit.sh:24-37（UPS_SID 链）、:107-111（owner 读）

## 验收结果（逐项）

| # | 验收项 | 结果 | 证据 |
|---|--------|------|------|
| ① | `bash -n` 两脚本 | PASS | `bash -n zcode-posttooluse.sh && bash -n zcode-userpromptsubmit.sh` → `SYNTAX OK` |
| ② | P0-1 正例：相对路径 `plans/task-x/task_plan.md` + owner=FIXA + sid=FIXA → `.plan-attestation` 出现且 `attested_by_sid=FIXA` | PASS | `/tmp/verify-p01.sh` 输出 `POS PASS: attested_by_sid=FIXA`；手动复现：`/tmp/p01test-a` 下跑 hook 后 `grep attested_by_sid .plan-attestation` → `attested_by_sid=FIXA` |
| ③ | P0-1 负例：owner=FIXB + sid=FIXA → `.plan-attestation` 不变 | PASS | `NEG PASS: .plan-attestation 不存在 (owner=FIXB 与 sid=FIXA 失配, 未重锁)` |
| ④ | P0-2 canon 逐字节一致性：`sid="sess-abc123"` 经 pretooluse:30 与 userpromptsubmit:34 规范化 → 输出一致 | PASS | `/tmp/verify-canon.sh`：两侧均 → `sessabc123`；`CANON PASS: 逐字节一致` |
| ⑤ | E3 回归：env-only sid `CLAUDE_CODE_SESSION_ID=sessTEST123`，stdin 无 session_id → owner 写入 | PASS | `/tmp/verify-e3.sh`：`E3 PASS: owner=sessTEST123 (env-only sid, 剥除 '-')` |
| ⑥ | `git diff` 恰 2 文件 | PASS | `git status --short` 显示 `M skills/task-planner/scripts/zcode-posttooluse.sh` 与 `M skills/task-planner/scripts/zcode-userpromptsubmit.sh` 恰好两行；`git diff --stat` → `2 files changed, 21 insertions(+), 4 deletions(-)` |

## git diff 摘要
```
skills/task-planner/scripts/zcode-posttooluse.sh      | 15 ++++++++++++++-
skills/task-planner/scripts/zcode-userpromptsubmit.sh | 10 +++++++---
2 files changed, 21 insertions(+), 4 deletions(-)
```

## 已知残余风险（报告给 orchestrator）

1. **check-delegation.sh 仍保留 `a-zA-Z0-9_-` 剥除口径**（L96 `raw=... tr -cd 'a-zA-Z0-9_-'`、L255 `sid_norm=... tr -cd 'a-zA-Z0-9_-'`），与本 hook 本次修复后的 `a-zA-Z0-9` canon **反向失配**：
   - 本次修复：hook 侧 owner/UPS_SID 剥除 `-`，含 `-` 真实 sid → 两侧输出一致（见验收 ④）
   - 但 check-delegation.sh 侧 L96/L255 仍剥除 `a-zA-Z0-9_-`（保留 `-`），与 pretooluse/check-scope/posttooluse/userpromptsubmit 侧 `a-zA-Z0-9` 形成新失配
   - **CR 指令未授权修改 check-delegation.sh**（scope 禁改），此残余风险需 orchestrator 判定：下一轮 CR（Fix-B）是否扩 scope 修 check-delegation.sh L96/L255 或另起任务
   - 注：check-delegation.sh L84 注释 `仅保留 [a-zA-Z0-9_-]` 亦与本次 canon 声明矛盾，属文档层偏差

2. **P0-1 修复后 `fp` 为相对路径仍保留 slash 的输入**（如 `plans/task-x/task_plan.md`）由 `case "$fp" in */*)` 分支直接匹配 `*/*` → 不进入新增的纯文件名分支 → 比较式 `$(dirname "$fp")/$(basename "$fp")` 用相对 `plans/task-x` 目录解析（依赖 CWD 上下文，由 hook 调用方保证 CWD 正确）→ 行为正确（验收 ② 已验证）

## 测试环境路径
- `/tmp/p01test-a`、`/tmp/p01test-b`：P0-1 正/负例验证目录（临时，可删）
- `/tmp/e3test`：E3 回归验证目录（临时，可删）
- `/tmp/verify-p01.sh`、`/tmp/verify-canon.sh`、`/tmp/verify-e3.sh`：验证脚本（保留，供 orchestrator 复核）

## files 统计
- `skills/task-planner/scripts/zcode-posttooluse.sh`：+12/-1（case `*/*` 分支新增纯文件名 CWD 直拼 + glob `plans/*/` 探测）
- `skills/task-planner/scripts/zcode-userpromptsubmit.sh`：+7/-3（UPS_SID tr canon 修复、P2-3 补 default、owner tr canon 修复）
- 合计 `git diff --stat`：2 files, +21/-4
