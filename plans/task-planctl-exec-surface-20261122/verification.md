<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-planctl-exec-surface-20261122

- task_id: `task-planctl-exec-surface-20261122`
- 时间: created_at=2026-11-21T20:32:16Z / updated_at=2026-11-21T21:43:17Z

## Goal (1 sentence)
- 4 个执行面（init-session 输出/模板契约行含 29 variant/hook 教学文案/attest 空壳 WARN）全部切换 planctl 口径，旧教学字面清零
- 全量 selftest 与基线对比零新增 FAIL；zcode/agents/claude/cursor 四位部署 diff=0 且部署位 selftest 复跑绿
- tmp 行为面冒烟：按 init 新输出指引走 planctl add→render→attest 全链 exit 0，4 MD 带 GENERATED_HEADER

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | init-session.sh JSON init 成功路径输出「下一步」CLI 指引块且脚本内 planctl.py 提及≥4 处 | test $(grep -c planctl.py /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh) -ge 4 |  |  |
| VC-2 | pass | 4 个派生视图模板（task_plan/findings/progress/verification）头部契约行改为 planctl 派生口径，「模型填写面」旧字面清零（notepad-learnings/user-session-log 为合法人工面保留除外）；variant 非 mini 档加派生警示行 | test $(grep -l 模型填写面 /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/findings.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/progress.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/verification.md 2>/dev/null \| wc -l) -eq 0 |  |  |
| VC-3 | pass | hook 旧教学清零：posttooluse 6 处「Edit task_plan.md/Edit 进 findings.md/Edit 进 progress.md」改 planctl+render 口径；task-plan-init.cjs/plan-created.cjs 追加 planctl 行 | test $(grep -c "Edit task_plan.md\\|Edit 进 findings.md\\|Edit 进 progress.md" /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-posttooluse.sh) -eq 0 |  |  |
| VC-4 | pass | attest-plan.sh 空壳 WARN：fixture（plan-state.json 业务全空+task_plan.md>2KB 手写）触发 SOFT_ONLY WARN 且 exit 0 不阻断 | cd /tmp/planctl-vc4-fixture && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh 2>&1 \| grep -c SOFT_ONLY |  |  |
| VC-5 | pass | 四位部署逐位 diff=0：源仓 254 个 git 跟踪文件（skills/task-planner）与 zcode/agents/claude/cursor 四位逐文件 cmp 全同（部署位含 .history/trash 运行期文件，整目录 diff-r 口径不可用） | cd /mnt/data/dev/task-planner-skill && git ls-files skills/task-planner \| while read f; do for base in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do cmp -s "$f" "$base/$f" \|\| { echo DIFF-$base/$f; exit 1; }; done; done && echo DEPLOY-DIFF-0 |  |  |
| VC-6 | pass | tmp 行为面冒烟：init→add(requirements/goals/vcs/phases)→render→attest 全链 exit 0，render 后 4 MD 首行为 GENERATED_HEADER | test $(head -1 /tmp/planctl-smoke-out/plans/task-smoke-001/task_plan.md \| grep -c 勿直接编辑) -eq 1 |  |  |

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
