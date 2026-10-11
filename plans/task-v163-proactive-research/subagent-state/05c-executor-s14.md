# Checkpoint — S14 SKILL 级联与全仓宽容锚修齐（sub:05c-executor）

- status: done（S14 scope 内全部完成）
- task-id: task-v163-proactive-research
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research
- 完成时间: 2026-10-10
- 需求锚（Rule 51.1a）: R6「本地模型的能力是有限的，但是接入网络之后能力会有瞬间的暴涨」

## ① SKILL.md 级联（完成）

| 项 | 证据 |
|----|------|
| 三处计数位 1-72→1-75 | `grep -c "1-75"` = 3（行 9 / 299 / 387）；`grep -c "1-72"` = 0 |
| 行 9（frontmatter references） | `Critical Rules 全集 1-75（…72=决策分级…，75=网络调研主动激活与外部数据依赖纪律）` |
| 行 299（Critical Rules 章节引言） | `Critical Rules 1-75（含 Rule 40-71 全集 … + Rule 75 网络调研主动激活与外部数据依赖纪律）` |
| 行 387（References 表） | `Critical Rules 1-75（… +Rule 72（task-v160）+Rule 75 网络调研主动激活与外部数据依赖纪律（task-v163））` |
| Rule 75 摘要 bullet | 行 363（Rule 72 bullet 后）逐字取自落盘 prompt §4 ①b |
| 合规清单行 | 行 235 `| C52 | 网络调研主动激活自查（Rule 75）… | ☐ |` |
| 行数 | wc -l = 540（原 538，净 +2 = bullet + C 行；三处计数位为行位替换零净增） |

### 偏差（B 类事实修正 — 合规清单编号 C51→C52）
- 落盘 prompt / dispatch 写「追加 C51 行」，task_plan 强制约束写「合规清单接续最大 C 编号（当前 C50 → C51）」。
- worktree 基线（master ba5ee1c，含 v160 合流）实测：C51 已被 **Rule 72（task-v160）** 占用（SKILL.md:234），最大 C 编号 = C51。
- 依 task_plan「接续最大 C 编号」总则，S14 追加 **C52**（避免重复编号=缺陷）。C51（Rule 72）行原样保留在位。
- 证据：`grep -oE '^\| C[0-9]+ \|' SKILL.md | grep -oE '[0-9]+' | sort -n | tail -1` = 51。

## ② 全仓宽容锚扩展（完成，11 脚本）

按 findings S3 清单 + 新增发现（selftest-source-anchor-discipline.sh SA-07）：

| 脚本 | 锚变更 | 覆盖验证（对 SKILL.md grep -cE） |
|------|--------|-------------------------------|
| selftest-self-resolution.sh:83 | `1-(6[0-9]|7[0-2])`→`1-(6[0-9]|7[0-5])` | 2（≥1） |
| selftest-tool-selection.sh:65 | `1-(6[0-9]|7[0-2])`→`1-(6[0-9]|7[0-5])` | 2（≥1） |
| selftest-root-resolution.sh:111 | `1-(5[3-9]|6[0-9]|7[0-2])`→`…|7[0-5])` | 1（=1） |
| selftest-research-first.sh:76 | `1-(69|71|72)`→`1-(69|71|72|75)` | 1（≥1） |
| selftest-requirement-coverage.sh:135 | `1-(6[0-9]|7[0-2])`→`1-(6[0-9]|7[0-5])` | 2（≥1） |
| selftest-lane-advancement.sh:138 | `1-(6[0-9]|7[0-2])`→`1-(6[0-9]|7[0-5])` | 2（≥1） |
| selftest-context-pressure.sh:101-102 | c1 `1-(69|71)`→`1-(69|71|75)`；c2 `1-(69|71|72)`→`1-(69|71|72|75)` | 4（≥2）/ 2（≥1） |
| selftest-workflow-orchestration.sh:73 | 族 `1-(68|69|71)`→`1-(68|69|71|75)` | 族合计 9（≥3） |
| selftest-source-anchor-discipline.sh:39 | `1-7[12]`→`1-7[125]`（新增发现，S3 清单未列） | 3（≥2） |
| selftest-conclusion-discipline.sh:75 | 活跃锚 `1-[4-7][0-9]` 已覆盖 75（1-7[5]），仅补注释 | 3（≥3） |
| selftest-parallel-scheduling.sh:111 | 动态断言 skill_max==crit_max 自动随动=75，仅补注释 | P-05 由 FAIL→PASS |
| selftest-research-first.sh:75 / veto:13 / skill-split:80 / reflect-verify:61 | `[4-7][0-9]` 已覆盖 75，未动 | 已覆盖 ✓ |

每处修改均加 `[2026-10-10 task-v163 级联: …]` 注释行（Rule 45 双层注释）。

### 文档计数标签（grep "1-7" 命中才改）
- CLAUDE.md:33 `Rules 1-71`→`Rules 1-75`（+task-v163 注释）
- README_zh.md:136 / :229 `Rules 1-71`→`Rules 1-75`（+task-v163 注释）
- skills/task-planner/README.md:72 = `Rules 1-69`（无 "1-7" 命中 → 按规则不动；且被 selftest-conclusion-discipline CD-18 `Rules 1-6[0-9]` 断言，改则 FAIL）

## ③ 验证（完成）

- `bash -n` 全部 11 改动脚本 → 全 OK。
- 受影响 selftest 逐脚本复跑 → 全 PASS（含 parallel-scheduling 9/9、source-anchor-discipline 12/0、context-pressure 9/9、workflow-orchestration 16/16）。
- 全量回归：`for f in selftest-*.sh` → **pass=71 fail=2**（基线 pass=70 fail=3）。
  - 修复 1：selftest-parallel-scheduling.sh P-05（skill_max 72≠crit_max 75）→ 本 S14 级联后 =75 PASS。
  - 残留 2（**S14 scope 外**，见 blockers）：
    - selftest-decision-grading.sh DG-03（根因=S5 Rule 75 条文块含 `[sub:01a-explore]`，`:`+`0` 被 `sed -n '/^## Rule 72/,$p'` 段尾捕获命中）
    - selftest-plan-tier.sh PT-15（根因=S7 模板区块注释含字面 `plan_tier: mini`，general 源被误判为 mini）

## ④ 负结果报告（Rule 3）
- 检查了 SKILL.md 行数上限断言：多处 ≤555 / ≤558；SKILL.md=540 → **无需上调**（prompt 预期「同步上调」未触发；已核 knowledge-brief/skill-split/goal-unit/skill-collab/batch-pilot/execution-stability/drift-check-subagent 全部 PASS）。
- 检查了 5 处「已覆盖 75 的宽容锚」：research-first:75 / veto:13 / skill-split:80 / reflect-verify:61 实测命中 ≥1，确认无需扩锚（未动）。
- 检查了全仓 active 断言残留 `7[0-2]` 字面：0 处（除注释/消息文本）。
- 排除风险：无新增 config 键；未触碰 critical-rules.md / templates/（scope 外）。

## blockers（S14 scope 外，需主进程/其他 S-unit 处置）
1. **DG-03**：critical-rules.md Rule 75 条文块 `[sub:01a-explore]` 触发 `:\s?[0-9]+`。建议修法=改 Rule 75 文本（如 `[sub 01a-explore]`）或修 DG-03 sed 段界（`/^## Rule 72/,$p`→遇下一个 `^## Rule` 止）。属 S5 文件 / v160 脚本，S14 禁改。
2. **PT-15**：templates/task_plan.md:175 注释含字面 `plan_tier: mini`，init 缺省场景误判。建议修法=注释改写（如「mini 档任务整体豁免」）。属 S7 文件，S14 禁改。

## 返回
status: done | acceptance: 4/4（S14 验收）| files: 14（SKILL.md+11 scripts+CLAUDE.md+README_zh.md）| confidence: HIGH
