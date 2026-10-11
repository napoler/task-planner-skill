# S27 CR 修复批D 检查点（executor，worktree 内写）

- 工作区：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 修改文件：2 个（仅此两个）
  - skills/task-planner/docs/ARCHITECTURE.md
  - INSTALL_zh.md
- 需求锚：R2「没有对齐的以及落后的内容全部帮我对齐」
- CR 来源：subagent-state/25-code-reviewer-S14.md M-2 / M-4a

## 修改项与终态

### M-2 ARCHITECTURE.md scripts 计数口径统一

| 位置 | 修改前 | 修改后 |
|------|--------|--------|
| :17 | `106 个文件，...实测 find scripts -maxdepth 1 -type f \| wc -l → 106` | `106 个条目 = 104 个文件 + 2 个子目录（lib/、capabilities/），...实测 ls -1 scripts \| wc -l → 106，find scripts -maxdepth 1 -type f \| wc -l → 104` |
| :64 | `实测 106 文件，2026-10-08` | `实测 106 条目 = 104 文件 + 2 子目录，2026-10-08` |

- 口径：106 = ls -1 含 lib/ + capabilities/ 两个子目录；104 = find -type f 仅文件。两处一致。

### M-4a INSTALL_zh.md config 键数

| 位置 | 修改前 | 修改后 |
|------|--------|--------|
| :290 | `(JSON-Schema 阈值配置, 40 键)` | `(JSON-Schema 阈值配置, 42 键)` |

## 自验输出

1. ARCHITECTURE.md:17 读回 → `106 个条目 = 104 个文件 + 2 个子目录（lib/、capabilities/）` ✅
2. ARCHITECTURE.md:64 读回 → `实测 106 条目 = 104 文件 + 2 子目录` ✅
3. INSTALL_zh.md:290 读回 → `42 键` ✅
4. `grep -n "40 键\|40 个配置" INSTALL_zh.md` → 0 命中 ✅

## 证据

- skills/task-planner/docs/ARCHITECTURE.md:17,64
- INSTALL_zh.md:290
