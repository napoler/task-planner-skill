# 检查点: 4-code-assistant — selftest-subagent-return.sh + registry 行（task-v161 S4）

## 里程碑
- 2026-10-10 读材料包 4-prompt-material.md + 风格参照 selftest-dispatch.sh + 四被断言文件关键段（check-subagent-return.sh 全读 / check-dispatch.sh return_section_check:193-214 / 模板 §7:62-83 / critical-rules 22.4b:184-185）
- 2026-10-10 首版脚本 bash -n 失败两次（长行引号嵌套、awk 单引号与 shell 引号冲突）→ 重写：断言六/七计数先入变量、awk 正则放变量、断言行全部单行化 → 语法通过
- 2026-10-10 首轮运行 A10 FAIL（§7 段含「返回前必做 1.-4.」步骤枚举 5 步触 fine_grain ④ 门 + 缺 subagent-state/ 字面）→ 夹具改为「模板 §7 代码围栏 8 字段行 + checkpoint 路径行 + 需求锚」，并前置清锁（A9 写新锁会致 A10 撞串行槽 exit 2）
- 2026-10-10 registry 首版 printf %s 追加留字面 \t（NF=1）→ 修正为 printf %b 真实 tab 并删损坏行重写；A11 现走「已在位」分支
- 2026-10-10 收尾发现 A10 放行会令 serial_slot_check 重写瞬态锁 .dispatch-inflight（主仓脏 diff）→ 脚本尾加锁备份/回写段（cp 实现，零 VCS 命令），恢复锁到提交态后复验 git status 干净
- 2026-10-10 行数收敛：91 行 → 注释合并压缩至 90 行（材料包硬约束 ≤90 行达标）
- 2026-10-10 最终全量自跑 Total: 11 PASS=11 FAIL=0 rc=0；脚本 grep 无 git 命令/无 git 字面（注释改「零 VCS 命令」「纯 cp/rm」表述）；bash -n rc=0；registry 尾行 NF=4 真实 tab；TASK_PLANNER_PLAN_DIR 跑后 unset 验证未泄漏

## 最终结论
status: done
acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/selftest-subagent-return.sh(+90/-0); /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/selftest-registry.tsv(+1/-0)
evidence: bash -n selftest-subagent-return.sh→rc=0; bash selftest-subagent-return.sh→Total: 11 PASS=11 FAIL=0 rc=0; git diff --numstat→1 0 skills/task-planner/scripts/selftest-registry.tsv 且新脚本 untracked +90/-0; registry 尾行 awk -F'\t' NF=4 首列 selftest-subagent-return.sh; grep git 脚本→0 命中; 锁 .dispatch-inflight 运行后 git status 干净（备份回写零残留）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/subagent-state/4-code-assistant.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
