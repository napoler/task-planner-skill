# Delivery Summary — task-v168 会话锚定与技能激活/错误纠正（逻辑/设置层）

## 1. 执行总结

用户 R1-R5 五条需求（幻觉/长程漂移、确定性+偏移拦截、周期检查计划文件、执行错误及时纠正、三方技能主动激活）的修复，中途经用户 piv⊙ 裁定「明明是逻辑上或者说技能的设置问题，一直在改代码是严重偏差」后**整体转向技能逻辑层+既有设置层**：已写的 16 文件机器面（hook 锚点卡/技能扫描/错误信号检测/三门控/三 selftest + Rule 77/78/79）整体封存到分支 `wt/task-v168-machine-parked`（保留未合并未部署），主交付改为五处行为锚点植入 SKILL.md 执行循环 + Rule 31.1/33.1 触发条件扩展 + config 两个既有开关翻 enforce。最终 master 组合态回归 77/77 FAIL=0，CR 独立审查 1 BLOCKER+2 MAJOR 全部闭环。

**一句话结果**：漂移防护从「外围机器代码」回到「技能自身逻辑与设置」——执行循环每个 Phase 开工先复诵用户原话、每个动作过相关性三问、派发前确认技能激活、错误同轮四步闭环、每 S-unit 对照三文件；两个既有 warn 门升 enforce；零新 hook、零新脚本、零新 config 键。

## 2. 产出清单

1. `skills/task-planner/SKILL.md`（+5/-1）：执行循环植入 1.1 R 锚定复诵 / 2.5c 动作相关性三问 / 2.5b 技能激活确认 / 3c 错误同轮四步 / 3f 周期性三文件对照，每块带 [task-v168 逻辑层锚点] 注释+Why
2. `skills/task-planner/references/critical-rules.md`（+2/-2）：Rule 31.1 增第 5 触发条件（执行期机器可观察错误，收窄为「预期成功的动作实际失败」+良性非零豁免+22.3 交叉引用）；Rule 33.1 增第 4 触发点（问题出现即时）
3. `skills/task-planner/templates/progress.md`（+6/-4）：Error Log 增「触发命令/工具」列
4. `skills/task-planner/config.json`（+3/-3）：error_loop_enforce/reflect_verify_enforce 默认 warn→enforce
5. `skills/task-planner/scripts/check-complete.sh`（+13/-4）：Learning Gate 修既有 off-by-one（Root Cause=a[c] 双列校验）+ 模板占位行豁免（ enforce 翻档连带必修）
6. `skills/task-planner/scripts/selftest-error-loop.sh`、`selftest-reflect-verify.sh`：config 钉值演进 warn→enforce
7. `skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh`、`selftest-skill-split.sh`：SKILL.md 行数钉演进 555→581/558→584（v166×v168 合流面）
8. `plans/task-v168-session-anchor-skill-activation/`：计划全文件（三报告调研+9 个子代理检查点+CR 记录+verification+本总结）
9. 分支：master 合入 cdf437e/9fce0ff/618df79；`wt/task-v168-machine-parked`=封存机器面（ revival 备选）

## 3. 审查详细

1. 独立 Code Review 子代理（21-cr-code-review.md）：首轮 CHANGES-REQUESTED——BLOCKER（两 selftest 钉住 default=='warn' 致翻档后回归 FAIL=2）、MAJOR×2（31.1⑤ 触发过宽；Learning Gate off-by-one 被 enforce 升级为硬阻断级）、MINOR（三问 bullet 易滑过）、NIT×2。
2. 修复轮 F1-F5 全闭环并经主进程逐项复核（不信自报）：钉演进+⑤ 收窄+双列校验+模板豁免+2.5c 升级，fixture A/B/C 三态实证（不阻断/exit1 含行号/静默）。
3. 回归三轮：wt 分支 76/76 → master 组合态首轮 75/77（行数钉触顶，v166 合流面）→ 钉演进后 77/77。
4. 合并期发现并行会话 v166 落地 master（Rule 76），diff 实证并存无损。
5. 委派统计：子代理执行 5/6 Phase（Explore×3+code-assistant×14+Code Reviewer×1），委派率≈0.83≥0.7。

## 4. 待审数据清单

| 文件 | 路径 | 简单描述 |
|------|------|---------|
| task_plan.md | /mnt/data/dev/task-planner-skill/plans/task-v168-session-anchor-skill-activation/task_plan.md |  piv⊙ 后重写的方向/VC/Phase（SHA 2a9656a1 锁定） |
| verification.md | 同目录 | VC-1~6 证据链+核心目标裁决 partial |
| CR 记录 | 同目录/subagent-state/21-cr-code-review.md | 独立审查 6 条发现+修复判定 |
| 封存分支 | git branch wt/task-v168-machine-parked | 16 文件机器面（未合并未部署） |
| 合并 commit | git log master：cdf437e/9fce0ff/618df79 | 三批合并记录 |

## 5. 建议

1. **部署已完成（2026-10-11 用户授权）**：9 文件 rm+cp 同步，diff=0 对账，部署位四 selftest 冒烟全 PASS——五锚点+enforce 已对真实会话生效。
2. **观察行为面执行率**：下一两个真实任务里看 progress.md 是否出现「R 锚定」行与 3f 对照行——这是逻辑层修复是否生效的唯一实证。
3. ** revival 决策**：若行为面仍失效（历史上有 v141-v145 drift-check 0% 执行的失败前科），再评估封存分支的机器面；届时前车之修已记档（emit 组装勿嵌在 re-anchor if 内）。

## 6. 风险（含失效条件）

1. **行为锚点可能被执行体滑过**（失效条件=遇到不读 SKILL.md 主流程的 subagent 上下文）——以 §5.2 观察为门，失效则 revival。
2. **enforce 翻档首次硬阻断**（失效条件=存量计划 Error Log  Reformation 不全时终验 exit 1）——已修 off-by-one+模板豁免；若仍有误挡可 env TASK_PLANNER_ERROR_LOOP_ENFORCE=warn 单次降级。
3. **机器面封存=编号账本 77/78/79 占位**（失效条件=他任务抢注同号后 revival 撞号）——release 仅接受 reserved 态故保留 landed 占位，revival 时先 re-reserve 仲裁。
4. **部署未做**（失效条件=用户认为已生效）——本总结明示：仓库态≠生效态。
