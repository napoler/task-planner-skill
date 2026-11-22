<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-template-json-compat-20261122

- task_id: `task-template-json-compat-20261122`
- 时间: created_at=2026-11-21T23:24:11Z / updated_at=2026-11-22T00:16:06Z

## Goal (1 sentence)
- 完成旧模板体系与 JSON 体系三路取证并给出部分兼容结论与断裂清单
- schema/planctl/init/render 全链支持 template_body 可选字段：init 写入 variant 领域段原文，render 以标题降级附录吐出
- 修 VC-GATE 表格计数假绿 + V-N 映射真断；全量 selftest 零新增 FAIL + 四位部署 diff=0 + 存量 fixture 行为不变

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | 三路取证结论落 findings：旧模板体系与 JSON 部分兼容，三类断裂（variant 领域段丢失/VC-GATE 假绿/V-N 真断）逐条附证据行号 | grep -c 'P0\\|R-1\\|VC-GATE' /mnt/data/dev/task-planner-skill/plans/task-template-json-compat-20261122/findings.md | findings.md | compat |
| VC-2 | pass | schema+planctl+init+render 四处 template_body 链路打通，init --template-body-from 写入、render 标题降级附录吐出 | grep -c template_body /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/planctl.py /mnt/data/dev/task-planner-skill/skills/task-planner/schemas/plan-state.schema.json | worktree 4 文件 | upgrade |
| VC-3 | pass | tmp 全链实弹 5 项：4 MD GENERATED_HEADER + 领域附录标题降级 + VC-GATE 正确计数 + check-complete 不因 V-N 拒锁 + 51.1/66.5 未误判 | test -f /tmp/tjcompat-smoke/plans/task-smoke-001/task_plan.md && grep -c '勿直接编辑' /tmp/tjcompat-smoke/plans/task-smoke-001/task_plan.md | tmp smoke | smoke |
| VC-4 | pass | attest VC-GATE 增认 render 表格行且保留旧 checklist 识别（存量红线）；V-N 由 phases[].v_checks 派生吐出 | grep -c 'VC-[0-9]' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh | attest-plan.sh:313-328 | gate |
| VC-5 | pass | 全量 selftest 双跑（master vs worktree）FAIL 集零新增（基线 8 集） | bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 \| tail -3 | selftest 输出 | regression |
| VC-6 | pass | 四位部署逐文件 diff=0（base=家目录根，禁双重嵌套）+ 存量 fixture 行为不变 | cd /mnt/data/dev/task-planner-skill && git ls-files skills/task-planner \| while read f; do for base in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do cmp -s "$f" "$base/$f" \|\| { echo DIFF-$base/$f; exit 1; }; done; done && echo DEPLOY-DIFF-0 | 四位 cmp | deploy |

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
