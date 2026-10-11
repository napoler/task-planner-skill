# S15 任务书：存量批量归档+INDEX 重生（task-v170 Phase 8）

## 1. 目标
在主仓执行存量批量归档：dry-run 确认→--batch 实做（显式 --root）→INDEX 重生→精确分期 git 提交→验证。
需求锚: R3:「确保所有的被使用完成的计划任务全部归档处理。」

## 2. 输入（绝对路径）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/task_plan.md（只读）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/findings.md（只读）
- progress: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/progress.md（只读）
- 移交清单: subagent-state/032-code-runner-s13.md（只读，Batch Report 供料）
- 机制脚本（主仓版已合并）: /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/archive-plan.sh
- INDEX 重生脚本: /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh
- 主仓 plans 根: /mnt/data/dev/task-planner-skill/plans

## 3. 验收标准（按序执行，每步输出贴 evidence）
- [ ] 第 1 步 dry-run: `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/archive-plan.sh --batch --dry-run --root /mnt/data/dev/task-planner-skill/plans` → BATCH 汇总行；候选数应≈100（task-v055 已试点归档）；与 032 清单核对差异并说明
- [ ] 第 2 步实做: 同命令去掉 --dry-run（--root 保持显式）→ 全部 ARCHIVED 行+BATCH 汇总；ok 数=候选数；fail=0
- [ ] 第 3 步 INDEX 重生: `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --index` → 输出行；重生后 INDEX 不含任何 archive/ 任务（grep 抽样 3 个已归档 id=0 命中）；在途任务（v142/v162/v165/v168/v169/v170/v171 等）仍在 INDEX
- [ ] 第 4 步验证: `find /mnt/data/dev/task-planner-skill/plans -maxdepth 1 -type d -name 'task-*' | wc -l` 与在途集合对账（根目录剩余=in_progress/active/异常目录，非 complete）；`git -C /mnt/data/dev/task-planner-skill status --porcelain | head -30` 贴出
- [ ] 第 5 步精确提交（关键）: 依次 `git -C /mnt/data/dev/task-planner-skill add -A plans/archive`、`git -C /mnt/data/dev/task-planner-skill add -u plans/`、然后 `git -C /mnt/data/dev/task-planner-skill restore --staged plans/.rule-reservations.jsonl plans/task-v152-proactive-context/.plan-attestation plans/task-v160-decision-grading/.plan-attestation`（并行会话未提交变更，禁入本提交）；确认暂存区无异常后 commit，message=`data(plans): task-v170 Phase 8 S15 — 存量批量归档 completed 计划入 archive/+INDEX 重生（archive-plan.sh --batch）`；提交后并行会话三项变更仍在工作区未提交（git status 实证）

## 4. Scope 禁改清单
- 禁动并行会话未提交文件与未跟踪目录（plans/task-v162、plans/task-v168、plans/task-v169、plans/task-v171、plans/task-v170 自身目录——不得 add/commit/mv）
- 禁改 archive-plan.sh 与 sync-todos 脚本本体；禁改 config.json
- batch 实做只跑一次；git 写操作仅授权第 5 步一次 add+commit+restore --staged

## 5. 工作路径
/mnt/data/dev/task-planner-skill（绝对路径，不切 CWD）

## 6. 时长预算
15 分钟；超时返回 partial 附已完成步

## 7. 返回格式（严格 8 字段，禁增删改序，8 字段后不得有任何内容）
status: done | partial | failed | timeout
acceptance: <n>/<total> pass
files: <绝对路径>(+N/-M)
evidence: <命令→关键输出行>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/040-executor-s15.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW

## 8. checkpoint（强制）
写 /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/040-executor-s15.md：五步输出+BATCH 汇总+归档计数+根目录剩余清单+commit sha+并行会话变更保全实证；T5 写「最终结论」段（=§7 同块）。
