# 04-fix-round — Phase 4 critic CHANGES_REQUESTED 修复轮

- 时间: 2026-11-07
- 执行体: General Coder (subagent)
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106`
- 约束遵守: 仅动 R1-R4 指定文件；R4 在主仓 `plans/`；R1-R3 全在 worktree；主仓 `skills/` 未碰。

## R1（I-1 计数级联）task-discipline/SKILL.md 三处 `52 条` → `53 条`
- 文件: `skills/task-discipline/SKILL.md` (worktree)
- 修改点:
  1. `:15` 域边界描述句：`共 52 条（全文见规则索引）` → `共 53 条（全文见规则索引）`
  2. `:86` 落盘状态句尾：`本索引现共 52 条全文可消费` → `本索引现共 53 条全文可消费`
  3. `:97` 参考文档：`52 条规则全文...` → `53 条规则全文...`
- 自审: `grep -n "52 条" skills/task-discipline/SKILL.md` 在 worktree 内无命中（仅目标三处语境改动；其余文字零改动）。

## R2（W-1 双阈值互斥）critical-rules-discipline.md 105.1/105.4 口径统一
- 文件: `skills/task-discipline/references/critical-rules-discipline.md` (worktree, 105 段 :707-719)
- 修改点:
  1. `105.1` 判据句：`（判据=单层目录或名称清单 ≤200 项，如素材库/...）` → `（判据=单层目录或名称清单 ≤200 项为默认经验值，可按目录实况放宽，但放宽前提=仍能一次列出完整清单供人工一屏目检；如素材库/资产目录/命名族/配置项清单）`
  2. `105.4` 边界判据句：`边界判据=候选集合能否一次列出完整清单（≤200 项经验值，可按目录实况放宽但须能一屏人工目检）。` → `边界判据=候选集合能否一次列出完整清单供人工目检（数值口径同 105.1）。`
- 自审: 105.2/105.3/105.5 及段外文字零改动；105.1/105.4 均包含「一次列出完整清单供人工目检」统一口径。

## R3（I-2 空壳可过 + N-1）selftest-enumerate-first.sh 断言锚定强化
- 文件: `skills/task-planner/scripts/selftest-enumerate-first.sh` (worktree)
- 根因修复:
  - 头部增加 `SEC105` 提取（awk 从 `^### 105 ` 到下一个 `^### ` 前/EOF；实现等价于“105 段局部文本”，并修正 `sed -n ... | sed '$d'` 在 EOF 末节会误删 105.5 的边界问题，保证末节完整）。
  - `EN-01..05` 全部锚定 `SEC105`（EN-01 检查 SEC105 非空+含 `^### 105 `；EN-02 对 SEC105 计数 `^105\.[1-5] ` =5；EN-03/04/05 对 SEC105 断言关键词/反例锚/交叉引用）。
  - `EN-04/05` 改为直接 shell 测试（避免 `bash -c` 子进程中 `SEC105` 变量作用域丢失导致误 FAIL）。
  - `EN-06/EN-07` 保持对 `SKILL.md` 全文（级联登记/旧锚清零语义不变）。
  - `N-1`：头注释 `全量枚举 ≥5` → `≥4`（与代码阈值一致）。
  - 头注释增加 R3 修复说明与 VC-4 自指例外说明。
- 验证:
  - `bash -n skills/task-planner/scripts/selftest-enumerate-first.sh` → `bash -n OK`
  - worktree 运行：`cd /mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106 && bash skills/task-planner/scripts/selftest-enumerate-first.sh` → **Total 7 PASS=7 FAIL=0 exit=0**
- 空壳态推理（I-2 逻辑验证）：
  - 用不存在段 `SEC105="$(sed -n '/^### 999/,/^### /p' ...)"` 模拟空壳：`SEC105_EMPTY=YES` → `EN01_would=FAIL`（`[ -n "$SEC105" ]` 为假）；`SUB_COUNT=0` → `EN02_would=FAIL (<5)`；EN-03 计数全 0 → FAIL；EN-04/05 对空 SEC105 → FAIL。**结论：SEC105 为空/105 段缺失时 EN-01..05 必 FAIL，空壳不可过。**

## R4（Q-1 自指例外登记）VC-4 口径注记
- 文件: `/mnt/data/dev/task-planner-skill/plans/task-enumerate-first-20261106/verification.md` (主仓 plans/，允许)
- 修改点: VC-4 条目 Evidence 行追加 `注：selftest-enumerate-first.sh 自身含 '1-104' 字面（EN-07 负断言实现所需，自指例外）——grep 清零验收范围=skills/**+scripts/** 排除该脚本自身`
- 自审: VC-4 Verify command/结构未改，仅追加注记；符合“追加 Evidence 注”口径。

## 汇总
- R1: PASS（3 处 52→53）
- R2: PASS（105.1/105.4 口径统一，零其余改动）
- R3: PASS（SEC105 锚定 EN-01..05；N-1 对齐；bash -n OK；7/7 PASS exit=0；空壳态 EN-01..05 必 FAIL 推理+模拟成立）
- R4: PASS（VC-4 自指例外注记追加）
- 残余风险: worktree 内 `selftest-enumerate-first.sh` 路径为 `skills/task-planner/scripts/`（主仓尚无该脚本副本，本轮未触碰主仓 skills/）；主仓全量/合并后需按计划 Phase 收口。
