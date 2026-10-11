#### [sub:CR修复] Executor CR 修复单元 — 2026-10-10

**范围**: 按 CR 报告（4-code-reviewer-CR.md）修复 worktree 四处文件，共 5 改点（BLOCKER×1 + MAJOR×2 + MINOR×2）。

**修复落位**:

| 级别 | 改点 | 文件:行 | 修法 |
|------|------|---------|------|
| BLOCKER F1 | completed-ttl 误清在途计划 | set-active-plan.sh:175-185 | 整体完成判定：无 in_progress 行且存在 complete 行（排除 incomplete 子串）+ mtime>24h 条件保持 |
| MAJOR F3 | owner 匹配漏裸 uuid 形态 | set-active-plan.sh:218 + init-session.sh:808 | `grep -qE "^(sess)?${SID}$"` 兼容双形态，整行锚定实现 norm 后比较 |
| MAJOR 测试 | selftest grep 计注释致腐化 | selftest-pointer-lifecycle.sh:22 cnt() + PL-03..07 | cnt() 管道 `grep -v '^\s*#'` 剥注释行；PL-05 移除 SKIP 分支改硬断言 |
| MINOR-6 | smart-merge OK 文案无条件打印 | smart-merge-back.sh:764-770 | 条件化：仅当无 DRIFT/SWAP_FAIL/VERIFY_FAIL 且 slot 非空时才打印 |
| MINOR-7 | F2 巡检双命名空间 | set-active-plan.sh:193-199 | 同时查 `${sidkey}` 与 `sess${sidkey}` 两形态 side 指针 |

**验收结果**（逐项原文行见返回消息 acceptance 字段）:
- `bash -n` 四脚本全 exit 0
- BLOCKER 夹具：多阶段计划（阶段一 complete+阶段二 in_progress, mtime 25h）→ gc 不置空；纯 complete 计划（25h）→ 置空
- F3 夹具：裸 uuid owner 行 → 守卫触发 skip+WARN；sess 前缀 owner → 仍触发
- PL 复验：`Total: 10 PASS=10 FAIL=0`；负例（删码留注释）→ PL-03 FAIL + PL-10 FAIL
- smart-merge：`Total: 17 PASS=17 FAIL=0`
- `git diff --stat HEAD -- skills/task-planner/`：5 文件（4 本次修改 + 1 基线已有 selftest-smart-merge.sh），无越界新文件

**净改动行数**: 约 31 行（4 文件合计）
**自证通过项数**: 9 项
**open_issues**: none
