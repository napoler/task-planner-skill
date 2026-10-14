# 12-s3-3 技能激活机器门（S3 执行子代理 code-assistant）

> task-v168 Phase 3 S3 检查点。工作目录: /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation
> 落盘文件（3 个, 禁止触碰其他文件纪律遵守）: check-dispatch.sh / check-complete.sh / templates/task_plan.md

- [14:19] M1 读取 explore 02 §4/§6 P0-5/§7.2 + check-dispatch.sh ⑦ 段 + check-complete.sh Learning Gate 范式 + templates/task_plan.md「工具选择与编排」后段
- [14:19] M2 check-dispatch.sh 追加 ⑧ 伴飞 disable-model-invocation 判定（Rule 78, ⑦ 提取路径去重逐个读 frontmatter; 文件/目录双形态; fail-open 边界; 挂既有 get_mode 管线 enforce=exit 2）+ 头部 ⑧ 注释（Rule 45 What/Why/边界）
- [14:19] M3 check-dispatch.sh 新增 --test（5 断言: T1 disable 伴飞 rc=2 命中 / T2 model-invocable 零命中 / T3 ⑦ 路径不存在回归 / T4 双违规同现 / T5 无声明静默）全 PASS
- [14:19] M4 check-complete.sh Learning Gate 段后新增 SKILL-ACTIVATION GATE（档位 env TASK_PLANNER_SKILL_ACTIVATION_ENFORCE > config skill_activation_enforce > warn; L0 skip; 校验 task_plan 含「激活计划」区块 ∧ brief §6 数据行 ≥1）
- [14:19] M5 check-complete.sh 新增 --test（3 断言: T1 GATE 段在位+模板激活计划区块锚 / T2 缺区块默认 warn 不阻断 / T3 全在案 OK）全 PASS（首跑发现 T2 被既有 DELEGATION GATE 白名单⑥ 拦截致 rc=1 → 夹具 Executor 改白名单⑥ 措辞修复; T1 首跑 n3 锚精确计数被 --test 段自引用注释污染 → 改 ≥1 口径修复; M6 落盘后 T1 追加任务书第 5 项「templates/task_plan.md 含激活计划区块」ntpl 断言, T1-T3 标签沿用原编号）
- [14:19] M6 templates/task_plan.md「工具选择与编排」后插入「## 🧰 激活计划（Rule 78）」区块（4 列表 + scan-skills.sh 填充占位）
- [14:19] M7 回归: bash -n 双脚本 OK; check-complete 相关 selftest（final-gate-hash 22/22 / vc-gate 11/11 / error-loop 16/16）+ check-dispatch 相关（granularity-skill-escort 23/23 / dispatch 31/31）全 PASS; grep 验证既有 ⑦「Rule 59.2 伴飞路径不存在」/「LEARNING-GATE」/scan_contract_narrowing/return_section_check 语义锚仍在

## 负结果排查记录（诚实面）
- 检查过依赖面: check-delegation.sh 白名单编号判定（⑥/trivial 命中即豁免）——T2 夹具措辞据此调整; selftest-final-gate-hash 键④ 六键枚举——新 GATE 经 TASK_PLANNER_SKILL_ACTIVATION_ENFORCE env 读 config（未新增 .properties.* jq 消费 → 键④ 零扰动, 实跑 22/22 在证）
- 未排除风险: ⑧ 对伴飞路径只判 `<dir>/SKILL.md` 双形态, 若未来模板把伴飞列改为纯技能名（无路径）则 ⑦⑧ 均 fail-open（无路径 token 不提取）——与 ⑦ 既有口径一致, 非本 S3 扩大面
- 模板区块 grep 判据用的是字面子串「激活计划」（GATE 区块判=放宽容错取舍, 注释已如实登记误报面）

## 最终结论

status: done
acceptance: 4/4 pass — [1:PASS 三文件修改落盘 git diff 可见（261 insertions）2:PASS --test 全 PASS（dispatch 5/5 + complete 3/3, T1 内含任务书第 5 项模板区块断言）3:PASS 既有校验逻辑未破坏（grep 锚 + 6 个相关 selftest 回归 103/103）4:PASS 未触碰其他文件]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation/skills/task-planner/scripts/check-dispatch.sh(+108/-1); /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation/skills/task-planner/scripts/check-complete.sh(+147/-0); /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation/skills/task-planner/templates/task_plan.md(+6/-0)
evidence: check-dispatch.sh:599 ⑧ 段「Rule 78 伴飞技能为用户触发型」提示串; check-dispatch.sh --test → 「全部 5 项断言 PASS」RC=0; check-complete.sh SKILL-ACTIVATION GATE 段（resolve_skill_activation_tier + [skill-activation-gate] 前缀, Learning Gate 后）; check-complete.sh --test → T1(模板区块=1)/T2(warn WARNING rc=0)/T3(OK rc=0) 全 PASS; git diff --stat 仅 3 文件
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v168-session-anchor-skill-activation/subagent-state/12-s3-3-skill-activation-gate.md (status: done)
findings_written: 02-explore-skill-activation.md §6 P0-5/§7.2（本任务为机器门落地方, 未新增 findings 节）
blockers: none
confidence: HIGH
