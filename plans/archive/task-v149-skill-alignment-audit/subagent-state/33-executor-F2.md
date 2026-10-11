# S33 executor-F2 对齐修复检查点（P1-1/P1-2）

- 执行时间：2026-10-09
- 工作区：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 修复对象：alignment-review（CHANGES_REQUESTED）P1-1/P1-2
- 需求锚：R2「没有对齐的以及落后的内容全部帮我对齐」（Rule 51.1a）

---

## P1-1：examples/full-workflow.md:192 残留 session-catchup.py

- **修改**：`session-catchup.py` → `session-catchup.ts`
- **位置**：examples/full-workflow.md:192
- **实态依据**：`ls skills/task-planner/scripts/session-catchup*` = `session-catchup.ts`（无 .py 文件）
- **自验**：`grep -n "session-catchup.py" examples/full-workflow.md` = 0 命中（exit=1）
- **确认**：`grep -n "session-catchup.ts" examples/full-workflow.md` = :41 + :192 两处在位

---

## P1-2：skills/task-planner/README.md 陈旧计数对齐

### 实态实测数据

| 维度 | 实测命令 | 实测值 |
|------|----------|--------|
| scripts 条目 | `ls scripts/ \| wc -l` | 106 |
| scripts 文件 | `find scripts -maxdepth 1 -type f` | 104 |
| .sh 文件 | `find scripts -maxdepth 1 -name '*.sh'` | 96 |
| selftest | `ls scripts/selftest-*.sh \| wc -l` | 62 |
| 非 selftest .sh | `ls scripts/*.sh \| grep -v selftest \| wc -l` | 34 |
| references | `find references -maxdepth 1 -type f` | 10 |
| templates 核心 | `find templates -maxdepth 1 -type f` | 10 |
| templates variant | `find templates/variant -maxdepth 1 -type f` | 29 |
| companion | `ls companion/agents/` | 7 |
| config 键 | `node -e "Object.keys(require('./config.json').properties).length"` | 42 |
| 顶层文件 | `find . -maxdepth 1 -type f` | 10 |
| 顶层目录 | `find . -maxdepth 1 -type d`（含 .） | 9（8 目录 + .） |
| lib .sh | `ls lib/*.sh` | 6 |
| smoke 测试项 | smoke.sh 结构分析 | 17（7 canonical + 6 lib + 2 install + 1 check-complete + 1 verify） |

### 修改清单

| 行 | 修改前 | 修改后 | 实态依据 |
|----|--------|--------|----------|
| :32 | `41 文件, 4 commits` | `18 顶层条目` | 10 文件 + 8 目录 = 18 |
| :34 | `8 篇规则` | `10 篇规则` | references 10 |
| :35 | `5 核心 + 3 辅助 + 29 variant` | `10 核心 + 29 variant` | templates 10 + 29 |
| :36 | `17 个工具脚本` | `96 个 .sh 含 62 selftest` | .sh 96 = 62 selftest + 34 非 selftest |
| :38 | `smoke.sh 16/16 pass` | `smoke.sh 17/17 pass` | smoke.sh 17 测试项 |
| :86 | `17 个工具脚本` | `96 个 .sh（含 62 selftest）` | 同 :36 |

### 互洽验证

- :35「10 核心 + 29 variant」= :79「10 核心 + 29 个 variant」
- :36「96 个 .sh 含 62 selftest」= :86「96 个 .sh（含 62 selftest）」
- :32-38 架构图块与 :79-86 文件结构块计数完全一致

---

## 自验输出

```
=== P1-1 自验 ===
grep -n "session-catchup.py" examples/full-workflow.md
exit=1（无匹配）

grep -n "session-catchup.ts" examples/full-workflow.md
41:1. session-catchup.ts — no leftover plans found.
192:On the next session, Claude runs `session-catchup.ts` first. ...

=== P1-2 自验 :32-38 ===
│   (独立 git 仓库, 18 顶层条目)                           │
│   - references/  (10 篇规则)                             │
│   - templates/   (10 核心 + 29 variant)                  │
│   - scripts/     (96 个 .sh 含 62 selftest)              │
│   - lib/         (6 个 installer 脚本)                   │
│   - tests/       (smoke.sh 17/17 pass)                   │

=== P1-2 自验 :79-86 ===
├── templates/                               ← 10 核心 + 29 个 variant
├── scripts/                                 ← 96 个 .sh（含 62 selftest）
```

---

## 未修改文件确认

- 仅修改 examples/full-workflow.md + skills/task-planner/README.md
- 未 git commit
- 未触碰其他文件
