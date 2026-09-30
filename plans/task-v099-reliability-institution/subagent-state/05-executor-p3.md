# 05 executor P3 checkpoint（task-v099-reliability-institution）

时间: 2026-09-30 | 执行体: executor | 任务: P3-S3/S4 模板+契约行+新 selftest+registry

## 完成面（5 文件，worktree /mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution）

1. templates/task_plan.md:30 后 +1「质量审查工具」行（`interaction_mode` 行之后,任务书①逐字文本）
2. templates/variant/mini-lite-type.md:7 后 +1「Rule 42.5 豁免声明（task-v099）」行（任务书②逐字文本）
3. companion/agents/plan-writer.md:45 后 +1 义务行（任务书③逐字文本,「掌握的技能」bullet 区末尾,既有 bullet 零改动）
4. 新建 scripts/selftest-reliability-institution.sh（R-01..R-12 共 12 条,SR 范式同构:SCRIPT_DIR/SKILL_ROOT 解析+ok()/bad()+编号断言+Total 行+exit 语义;断言锚全部先 grep 实测存在再写入）
5. scripts/selftest-registry.tsv 末行 +1 行（四列: script/domain/trigger_scenarios/dep_anchors,与既有行 tab 分隔格式对齐）

## 验收 7 条逐条实测输出（worktree 内 skills/task-planner 下）

| # | 标准 | 实测 | 判定 |
|---|------|------|------|
| 1 | selftest-reliability-institution.sh Total 12/0 | `Total: 12 PASS=12 FAIL=0` rc=0 | ✅ |
| 2 | bash -n rc=0 | rc=0 | ✅ |
| 3 | selftest-registry.sh 0 FAIL 且 rows=actual=39 | `Total: 5 PASS=5 FAIL=0 (registry rows=39, actual selftest=39)` rc=0 | ✅ |
| 4 | tsv wc -l = 40 | `40 scripts/selftest-registry.tsv` | ✅ |
| 5 | plan-writer 既有锚保全 | 改前 `问题解构四问`=1、`纯数字`=1;改后 1/1（diff=纯增 1 行） | ✅ |
| 6 | 三锚 grep 命中 | 模板`质量审查工具`=1 / mini-lite`Rule 42.5 豁免`=1 / plan-writer`质量审查工具检测登记`=1 | ✅ |
| 7 | git diff --stat 本步面=5 文件 | 4 modified（plan-writer/tsv/模板×2）+1 untracked（新 .sh）=5;critical-rules.md/SKILL.md/skill-split 为 P2 已提交存量,本步 diff 零出现 | ✅ |

## 改前锚实测记录（断言防假依据）

- critical-rules.md: `^42.`=5 / `^43.`=4;42.2 含「均未命中=缺口」=1;42.3 含「S-unit」=1;43.1 含「未验证」=1;43.2 含「最小档位」=1;43.3 含「候选对比表」=1（均实测 grep 后写入 R-01..R-07）
- SKILL.md: `| C30 |`=1 / `| C31 |`=1;`含 Rule 40/41/42/43`=1;`1-40`=0（P2 存量,实测）
- config.json: `jq -r '.properties|keys|length'`=40（R-12 同 WF-12 口径）
- 改前 registry wc -l=39（末行 selftest-self-resolution）;改后 40

## R-12 判裁说明

任务书 R 断言清单第 12 条=config.json properties 键数=40（零新键,同 WF-12 口径,jq 缺失打 SKIPPED 不 FAIL）;plan-writer 义务行断言并入 R-10（模板「质量审查工具」行 + plan-writer「质量审查工具检测登记」双锚同断言）,12 条总数与编号齐。

## 遗留

- 无。全量回归求和（39 脚本双形态 Total）按 task_plan P3 S-unit 属主进程白名单③面,不在 executor 本步范围。

## 后续修正（主进程,2026-09-30,非子代理写入面）
- 全量回归发现 selftest-self-resolution.sh（v098 存量守护）SR-11/SR-12 锚值随 v099 级联漂移: SR-11 锚 token task-v098→task-v099（skill-split label 已改 v099）,SR-12 registry 行数 39→40（v099 新脚本登记 +1）。主进程白名单③修正两处锚值（断言语义零改动,行内注释标注 B 类扩围）,复跑 12/0+语法过。scope 扩围已登记 task_plan.md 范围表+Decisions。
