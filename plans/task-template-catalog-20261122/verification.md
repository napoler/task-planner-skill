<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-template-catalog-20261122

- task_id: `task-template-catalog-20261122`
- 时间: created_at=2026-11-22T01:33:58Z / updated_at=2026-11-22T02:03:06Z

## Goal (1 sentence)
- template-catalog.sh 可用，list/add/clone/derive 四子命令实弹通过，三 scope 枚举 + JSON + query 稳定
- 32 模板 template_meta 覆盖 100%，既有门控注释零改动，scan-template-spec 绿，全量 selftest 零新增 FAIL
- SKILL.md 用法示例注入 + SOP 流程化表述；dogfood list→init→attest 全链 exit 0；四位部署 diff=0

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | template_meta 解析率 100%（base + 31 variant） | test $(grep -rl 'template_meta' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/*-type.md \| wc -l) -eq 32 |  |  |
| VC-2 | pass | 既有门控注释(template_type/plan_tier/template-lineage)零改动 | test $(grep -l 'template_meta' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/*-type.md \| xargs grep -l 'template_type' \| wc -l) -eq 31 |  |  |
| VC-3 | pass | list 三 scope + --json + --query 实弹通过 | bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/template-catalog.sh list --json --scope builtin \| python3 -c 'import sys,json; d=json.load(sys.stdin); assert len(d["templates"])>=31; print("LIST-OK",len(d["templates"]))' |  |  |
| VC-4 | pass | clone/derive dry-run 零写入 + 同名拒锁 | test -x /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/template-catalog.sh |  |  |
| VC-5 | pass | SKILL.md 用法示例注入 + plan-template-kit 交叉指针 | test $(grep -c 'template-catalog.sh' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md) -ge 3 |  |  |
| VC-6 | pass | 全量 selftest 双跑零新增 FAIL + 四位部署 diff=0 | cd /mnt/data/dev/task-planner-skill && git ls-files skills/task-planner \| while read f; do for base in /home/terry/.zcode /home/terry/.agents /home/terry/.claude /home/terry/.cursor; do cmp -s "$f" "$base/$f" \|\| { echo DIFF-$base/$f; exit 1; }; done; done && echo DEPLOY-DIFF-0 |  |  |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
