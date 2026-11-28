# EX-1 A簇 实施报告（task-skill-fix-defs-20261128）

## 1) SKILL.md 瘦身（模板驱动）
- 目标文件：`skills/task-planner/SKILL.md`
- 实测：`175 行 / 27961 字节`（`wc -l`/`wc -c`）
- 保留锚面：frontmatter、`## 定位：核心 = planctl.py 驱动的四文件罗盘管理`（含锚注释 `## 核心执行引擎（P0 — 四文件罗盘唯一写入口）`）、内容引用表（frontmatter references）、卫星路由表、`## Critical Rules 指针（核心域）`、`## 计划制作循环` 主干。
- 迁出（逐字/原文保留为细节）：命令速查+JSON原生模板+init参数说明+SOP补充细节+计划制作循环完整细节 → `skills/task-planner/references/plan-workflow-details.md` 新增 `## 命令速查与脚本索引（2026-11-28 task-skill-fix-defs-20261128 自 SKILL.md 迁入）` 及后续细节小节；SKILL.md 命令速查位置留单行指针。
- 传播面锚同改：`skills/task-planner/scripts/init-session.sh:1471` 命令速查文案改指向 plan-workflow-details.md §命令速查与脚本索引（已加迁移注释）。

## 2) BP-08 双钉（selftest-batch-pilot.sh）
- 文件：`skills/task-planner/scripts/selftest-batch-pilot.sh`
- 行钉：`≤185`（实测 175+10 边距）
- 字节钉：`≤30734`（实测 27961*110% 向上取整）
- 注释链：追加 2026-11-28 task-skill-fix-defs-20261128（What/Why/原行为=行钉470单钉无字节门；根因=DEF-03 行钉逐次抬升失守，借 Superpowers tests/skill-size 字节门）。
- 自测：`bash skills/task-planner/scripts/selftest-batch-pilot.sh` → `Total: 11 PASS=11 FAIL=0` (rc=0)

## 3) planctl.py 三改
- 文件：`skills/task-planner/scripts/planctl.py`（`python3 -m py_compile` rc=0）
- ① `schema` 子命令：从 `ENTRY_DEFAULTS` 深拷贝派生每节合法字段表，输出 `{"sections":{...}}`；支持 `--section X` 过滤；`--help` 已注册。样例输出（3行）：
  ```json
  {
    "sections": {
      "evidence_binding": [
  ```
  （`schema --section vcs` 输出含 `"sections"` 与 `["id","criterion","command","status","evidence","tags"]`）
- ② cmd_add 重复 id 修复：`args.id` → `getattr(args,"id",None) or entry.get("id") or entry.get("path")`；报错文案保留「条目已存在」。冒烟：重复 add 返回 `planctl: requirements 条目已存在: R1` (rc=1)，非 AttributeError。
- ③ 管道转义：grep 发现 `_md_table` 及 spec-brief 全角管道相关锚在 selftest 中命中 19 文件/50 处（>5），按任务规则登记 backlog，本项未改 `_md_table`/展示文本转义，仅保留原行为；回执说明见下。

## 4) 自测结果
| 测试 | rc | 结果 |
|---|---:|---|
| `selftest-batch-pilot.sh` | 0 | 11 PASS / 0 FAIL（BP-08 双钉绿） |
| `selftest-dual-qc.sh` | 0 | 14 PASS / 0 FAIL |
| `selftest-antiregress.sh` | 1 | 8 PASS / 1 FAIL（AR-01 Rule 111 唯一性，非本任务文件；worktree 内 critical-rules.md 被其他执行体改动导致） |
| `selftest-plan-tier.sh` | 1 | 29 PASS / 3 FAIL（PT-18/PT-28 为其他执行体改动 attest-plan.sh SOFT_ONLY fail-closed 引入；PT-08 已修复；非本任务文件集引起） |

## 5) 范围与说明
- 仅改动分配文件集：SKILL.md、plan-workflow-details.md、planctl.py、selftest-batch-pilot.sh；传播面锚同改 init-session.sh（命令速查锚，已注释）。
- 未触碰：attest-plan.sh / check-dispatch.sh / verify.sh / critical-rules.md（属其他执行体）。worktree 中这些文件存在他人并行改动，本报告不覆盖。
- 管道转义 backlog：`_md_table` 全角→`\|` 标准转义因 selftest 锚>5 处暂缓，需后续专门任务统一改代码+19个selftest锚。
