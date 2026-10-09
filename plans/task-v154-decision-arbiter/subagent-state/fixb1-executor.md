# Fix-B1 检查点 — RF-06 宽容锚化 + DCS-11 头注同步

- 时间: 2026-10-10 (task-v154 S8 回归修复第二批；串行槽 executor)
- 单元: Fix-B1（A: RF-06 宽容锚 + 行尾注释演进史；B: DCS-11 line 55 头注 40-65→40-69）
- 工作树: /mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter (branch wt/v154-decision-arbiter)
- 状态: done — 两脚本全 PASS exit 0

## 基线（编辑前）
- selftest-research-first.sh: `FAIL RF-06 SKILL 1-69 计数≥3(三处联动) (got=1 expect>=3)` / `Total: 12 PASS=11 FAIL=1` / exit=1
- selftest-drift-check-subagent.sh: `Total: 20 PASS=20 FAIL=0` / exit=0
- SKILL.md 锚分布实测: 精确 `1-69`=1（line 286）; `1-66`=2（line 9 / line 368）; 宽容 `1-6[0-9]`=3

## 本单元改动（增量，每文件 1 行）
### A. skills/task-planner/scripts/selftest-research-first.sh（line 72）
- 说明文字 `SKILL 1-69 计数` → `SKILL 1-6X 计数（宽容锚）`
- grep 模式 `cnt '1-69'` → `cnt '1-6[0-9]'`（BRE 方括号，维持 ≥3 三处联动语义）
- 行尾注释追加: `# 2026-10-10 task-v154 S5/S8 接线演进 '1-69 精确锚'→'1-6[0-9] 宽容锚'：286 行 Rule 69 修正先行而 9/368 行维持 1-66（六守卫依赖，禁动），精确锚三处同值暂不可达→宽容化保联动语义不失`

### B. skills/task-planner/scripts/selftest-drift-check-subagent.sh（line 55 头注）
- `# DCS-11: SKILL.md 含 Rule 40-65 全集 ...` → `# DCS-11: SKILL.md 含 Rule 40-69 全集 ...`（与 56-59 行演进史一致）

> 注: `git diff` vs HEAD 中 research-first 另含 line 73（RF-07）、drift-check 另含 line 59-60 的改动，系本单元之前 S5 接线演进既有变更，非 Fix-B1 增量；Fix-B1 每文件增量 = 1 行。

## 验证（编辑后）
- `bash -n` 两脚本语法均 OK
- `bash selftest-research-first.sh` → `Total: 12 PASS=12 FAIL=0` / exit=0（RF-06 转 PASS，RF-07..RF-12 无回退）
- `bash selftest-drift-check-subagent.sh` → `Total: 20 PASS=20 FAIL=0` / exit=0（无回退）
- `git status --short -- skills/task-planner/SKILL.md` = 空（SKILL.md 未被本单元触碰）
- 未触碰 critical-rules.md / SKILL.md / 其他任何文件

## 运行尾部原文
```
RF-06 PASS SKILL 1-6X 计数（宽容锚）≥3(三处联动)
Total: 12 PASS=12 FAIL=0
RF_exit=0
DCS-11 PASS 索引括注 40-69 全集+Rule 61 偏移检查子代理化 保全+Rule 61 摘要 bullet
Total: 20 PASS=20 FAIL=0
DCS_exit=0
```
