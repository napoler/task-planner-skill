# 检查点 15c-ss-rf — 2 个 selftest 宽容锚（7x 纪元）

状态: **complete**
S-unit: task-v158-source-anchor-discipline / ss-rf
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline

## 改动（仅 2 文件，与 git diff --stat 核对一致）

1. `skills/task-planner/scripts/selftest-skill-split.sh:78-79`
   - 原: `grep -cE 'Rules 1-(3[0-9]|[4-6][0-9])'` + 标签 `T-锚 Rules 1-3..6 宽容计数锚 ≥1`
   - 改: `grep -cE 'Rules 1-(3[0-9]|[4-7][0-9])'` + 标签 `T-锚 Rules 1-3..7 宽容计数锚 ≥1`
   - 新增 7x 纪元说明注释（覆盖 3x/4x/5x/6x/7x，历史语义不变）

2. `skills/task-planner/scripts/selftest-research-first.sh`
   - :52-53 新增 `cntE()` ERE 助手（grep -cE，全集字面宽容化需交替 (a|b|c)，grep 默认 BRE 不支持）
   - RF-06 (:74): 断言参数 `cnt '1-6[0-9]'` → `cnt '1-[67][0-9]'`（计数族覆盖 6x+7x，历史 1-65/1-66/1-71 字面均命中）
   - RF-07 (:75): 头注双锚第二锚 `cnt 'Critical Rules 1-71（含 Rule 40-69 全集'` → `cntE 'Critical Rules 1-71（含 Rule 40-(65|69|71) 全集'`（保历史纪元 65/69 兼容 + 覆盖现状 71）
   - 行尾追加 task-v158 级联注释（防下次漏改）

## 定位证据（改动前 grep 实态）

- `grep -n '40-69 全集\|40-65 全集\|40-71 全集' SKILL.md` → SKILL.md:288 实态 = `Critical Rules 1-71（含 Rule 40-71 全集`（与任务书描述一致）
- 改前 `grep -cE 'Rules 1-(3[0-9]|[4-6][0-9])' SKILL.md` = 0（旧锚零命中，原 FAIL 根因确认）
- 改后 `grep -cE 'Rules 1-(3[0-9]|[4-7][0-9])' SKILL.md` = 2

## 验收结果

| 验收项 | 结果 |
|--------|------|
| bash selftest-skill-split.sh | PASS=41 FAIL=0, exit 0 |
| bash selftest-research-first.sh | PASS=12 FAIL=0（RF-06/RF-07 均 PASS）, exit 0 |
| bash -n 双过 | SYNTAX OK |
| 本 S-unit diff 仅两文件 | git diff --stat（限定两路径）= research-first 6 行 / skill-split 3 行，无越界 |

## 负结果/风险排除

- worktree 内另有 11 个 selftest 脚本处于 M 态——系 task-v158 前序 S-unit（S12/S13 级联等）遗留，非本 S-unit 产出，未触碰
- 交替语法 `(65|69|71)` 在 BRE `grep -c -e` 下不生效 → 故新增 cntE ERE 通道，未改既有 cnt/cntf 语义
- 未改 SKILL.md / critical-rules.md / registry / config.json 任何文件

confidence: HIGH
