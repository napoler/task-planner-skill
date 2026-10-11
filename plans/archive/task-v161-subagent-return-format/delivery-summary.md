# Delivery Summary — task-v161-subagent-return-format（子代理返回 8 字段格式纪律修复）

> **定位栏（Rule 48.2）**: 机器档案=`/mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/` ｜ 仓库=`/mnt/data/dev/task-planner-skill` ｜ 交付基线=`merge commit a578531（feature commit f454a51）` ｜ 部署位=`~/.zcode/skills/task-planner（+ ~/.agents 共享位/其他部署副本）——未同步（待用户授权，见 §4 待裁决）`

## 1. 任务说明
- **Goal 回顾**: 修复子代理返回格式污染——派发子代理返回必须严格遵循 8 字段固定列表格式（status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence），消除「任务结束总结式格式」对返回数据的污染
- **执行过程摘要**: Phase 1 双 Explore 并行定位三层根因（58 份历史检查点实证合规率仅 24%）→ 用户 mid-turn 提供关键判例（派发 prompt「## 返回格式」段被填 ①②③ 任务清单）→ Phase 3 六个 S-unit（pg1 并行组+串行收口）+ 主进程逐件复验 → Phase 4 双轮独立回归（72 脚本 FAIL=0）+ 独立 VC 复验 7/7 → Phase 5 合并清理。关键裁决点：①agent 定义层（~/.zcode/agents）越界不修改、以契约优先级声明覆盖+待授权登记 ②verifier provider 拒请按 22.3.1 改派 general-purpose ③S5 任务书验收口径内部矛盾主进程裁决实质合规
- **行为面变化**: 下次派发子代理时——派发 prompt 的「返回格式」段若被填成 ①②③ 任务清单或标题重复，check-dispatch.sh 在 enforce 档直接阻断（rc=2 点名段结构违规）；子代理 agent 定义里的输出模板（步骤进度/交付报告/发现列表）被 §7 优先级声明显式压过；主进程收到返回可过 check-subagent-return.sh 机械判定合规性（VIOLATION=partial+打回+检查点兜底已成文闭环）；新 selftest 11 断言守护上述全部面
- **交付结论**: COMPLETE（verification.md Goal Gate: VC-1..7 全 PASS，委派 stats verdict=ok）
- **真实进展对照（Rule 54.1③/50.3）**: 用户三条原话——「返回≠总结阶段」=VC-1/VC-2 条款成文（covered）;「现在返回和正常任务格式一样非常差」=VC-3 机械校验+实证合规率 24% 诊断（covered）;「要求按固定列表格式返回」=VC-3/VC-4/VC-6 五层落地（covered）。推迟项：内置 agent 定义输出模板根治（未授权）——不表述为需求推进，如实列待裁决

## 需求覆盖核对（Rule 51.3 — 交付必载）
| 需求# | 用户原话（摘） | 判定 | 证据路径 |
|-------|--------------|------|---------|
| R1 | 「子代理中，返回数据应该和总结阶段应该不大一样……固定的格式，更利于主代理去了解」 | covered | subagent_dispatch.md:79-83 优先级声明+点名禁令;critical-rules.md:185 |
| R2 | 「现在返回了和正常执行任务返回一样的格式，而且这一样的格式其实是非常差的」 | covered | findings.md 三层根因+58 份实证;check-dispatch.sh return_section_check |
| R3 | 「要求规划子代理中返回的数据，按照……固定的列表格式」 | covered | check-subagent-return.sh+selftest-subagent-return.sh 11/11+SKILL 级联 |

## 2. 产出清单（文件级）
| 文件（仓内路径） | 变更摘要 | 验证状态 |
|------|------|------|
| skills/task-planner/scripts/check-dispatch.sh | +31/-0：新增 return_section_check()（标题唯一/段含四 key/段内禁序号清单），挂 :306/:321/:358 三路径，复用 enforce/warn 档位 | 污染夹具 rc=2 点名+干净 rc=0+selftest-dispatch 31/31 不破 |
| skills/task-planner/scripts/check-subagent-return.sh | 新写 93 行：返回侧四判据（字段齐全/契约外字段/块尾无附加/值域）+--selftest 4 夹具 | --selftest 4/4;summary 污染 rc=1 点名 |
| skills/task-planner/scripts/selftest-subagent-return.sh | 新写 90 行：A1-A11 断言（含双夹具集成） | Total: 11 PASS=11 FAIL=0（master 复跑） |
| skills/task-planner/scripts/selftest-registry.tsv | +1/-0：登记行 4 列 tab | selftest-registry.sh 5/5（rows=72） |
| skills/task-planner/templates/subagent_dispatch.md | +6/-0：§7 三反污染 blockquote（优先级声明/点名禁令/段填写禁令） | grep 三条款在位;:62-77 零改动 |
| skills/task-planner/references/critical-rules.md | +1/-0：Rule 22.4b 污染三面+主进程动作闭环 | awk 段内截取命中 |
| skills/task-planner/SKILL.md | +1/-1：Rule 22 摘要行内级联 prompt 侧/返回侧校验措辞 | grep 双短语在位 |
| skills/task-planner/references/dispatch-examples.md | +2/-0：§1 示例后 task-v161 注记 | grep 注记在位 |
| plans/task-v161-subagent-return-format/** | 计划六文件+3 材料包+10 Handoff 行+10 检查点+delivery-summary | check-complete 口径：progress/findings/verification 齐全 |

## 3. 审查信息
- **VC 复验**: 7/7 PASS（独立子代理 general-purpose 执行,首轮 6/7——VC-5 FAIL=progress 回填欠账,主进程回填后闭环;checkpoint: subagent-state/8-verifier.md）
- **回归**: 72 个 selftest rc0=72 fail=0 **双轮独立**（子代理 code-runner-agent 轮+主进程同 worktree 复跑轮;含新增 selftest-subagent-return.sh 11/11、改造后 selftest-dispatch.sh 31/31、selftest-registry.sh rows=72=actual 72）
- **委派统计**: rate=0.6 verdict=ok violations=[]（初跑 3 条 unverified_delegation=Handoff 类型名带 (haiku-1) 后缀——v150 已知坑复发,裸名化+补 pg0 行后复跑清零）
- **验证独立性**: VC 复验与回归跑批均由独立子代理执行+主进程第二轮独立复跑;主进程未以自测替代验收（主进程复跑本身即第二独立轮次）
- **实战证据**: general-purpose（其 agent 定义内置「任务交付报告」输出模板=污染主源之一）在本任务任务书 §7 优先级声明下返回纯 8 字段块零模板形态——S1 条款在冲突 agent 上生效的首例实证（登记 progress.md Phase 4）

## 4. 风险点（必须列举）
- **已知遗留**: ①内置 agent 定义层污染源（~/.zcode/agents/executor.md:45 步骤进度模板、general-purpose.md:31-48 任务交付报告、explore.md:33 发现列表）未修改——属 §六/§11.1 越界未授权,当前以派发契约优先级声明+机械校验覆盖;agent 定义改动需新会话生效（快照语义） ②S1 条款与 S6 段结构校验的行为面覆盖率需后续派发实战数据验证（本任务内 general-purpose 一例为正面样本）
- **待裁决（需用户拍板）**: ①**是否授权修改 ~/.zcode/agents/ 内置 agent 定义的输出模板**（executor/general-purpose/explore）——根治层,授权后可走 worktree 流程;对象: /home/terry/.zcode/agents/{executor.md:45,general-purpose.md:31-48,explore.md:33} ｜ 看点: 各「输出模板」段 ｜ 动作: 授权后改为「按派发 prompt 8 字段模板返回」（drift-checker.md:29 范式）②**部署位同步**——master a578531 未同步至 ~/.zcode/skills/task-planner;对象: /home/terry/.zcode/skills/task-planner/scripts/{check-subagent-return.sh,selftest-subagent-return.sh} 等 8 面 ｜ 看点: diff master vs 部署位 ｜ 动作: 授权后跑部署脚本或手动 cp+对账 diff=0
- **失效条件**: ①「72 脚本 FAIL=0」基线在任一 selftest 脚本增删或 scripts/ 变更后失效;重验: `cd /mnt/data/dev/task-planner-skill && for f in skills/task-planner/scripts/selftest-*.sh; do bash $f; done` ②「污染夹具 rc=2」在 check-dispatch.sh 段结构函数被改时失效;重验: `bash skills/task-planner/scripts/selftest-subagent-return.sh`（A9/A10 断言自含双夹具）③「委派 stats ok」在计划 Executor/Handoff 再变更时失效;重验: `bash skills/task-planner/scripts/check-delegation.sh stats plans/task-v161-subagent-return-format`
- **回滚方式**: `cd /mnt/data/dev/task-planner-skill && git revert -m 1 a578531`（纯增量变更,revert 无副作用;部署位若已同步需同步回滚）

## 5. 下一步建议（按推荐排序）
1. **[推荐] 授权修改内置 agent 定义输出模板** ｜ 对象: `/home/terry/.zcode/agents/executor.md`（:45）、`general-purpose.md`（:31-48）、`explore.md`（:33）｜ 看点: 三处「## 输出模板」段与 8 字段契约的竞争关系 ｜ 动作: 授权后开新 worktree 任务按 drift-checker.md:29 范式改写为「按派发 prompt 8 字段模板返回」——预期反馈: 同意/指定范围/暂不处理
2. **[推荐] 部署位同步** ｜ 对象: `~/.zcode/skills/task-planner/` ｜ 看点: scripts/{check-subagent-return.sh,selftest-subagent-return.sh} 与 check-dispatch.sh/subagent_dispatch.md 8 面对账 ｜ 动作: 授权后从 master 副本同步并 diff=0 验证 ｜ 预期反馈: 同意/自行处理
3. **行为面实战观察** ｜ 对象: 后续任意派发子代理的返回消息 ｜ 看点: 是否保持 8 字段块（尤其 provider 波动期改派的 general-purpose 轮次） ｜ 动作: 下次派发时顺手核对;若再发总结式返回,把返回原文贴回本任务 findings 追加判例
4. **可选: 检查点文件全集扫描** ｜ 对象: `plans/*`/subagent-state/ ｜ 看点: task-v161 之后新产生的检查点「最终结论」段是否 8 字段 ｜ 动作: `grep -rL "status:" plans/*/subagent-state/*.md` 一类粗扫（细粒度判定以 check-subagent-return.sh 为准）

[多待决项按 Rule 41.5 打包呈报: ①+② 为授权类打包上呈,③④ 为用户侧观察/自办项]
