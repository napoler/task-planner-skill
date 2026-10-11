# Task Learnings: task-v122（Rule 47 媒体制作任务派发纪律）

## New Requests
- 无中途新指令（唯一输入=开场用户反馈，见 findings Requirements 段）。

## What Worked
- **fresh 独立验证两连中**：S6 fresh 全量复跑抓获 src/锚级联第 2 例（SR-11 正则域），m7 修复后 fresh 复跑给出终局 0 FAIL——「不信执行期自报」再次证明价值（本次是 fresh 会话而非同一执行者发现）。
- **计划期 FMEA 预登记分支直接兑现**：两处锚级联（≤444 紧锚、SR-11 正则域）均在 FMEA 表预置的「锚过窄→宽容化」分支内，执行期零临时决策；修复范式（label 注明 task 代号+演进链）有 v071→v074/v112/v100/v102/v113 明文先例。
- **并行组 G-p2**：三文件互斥 S-unit 并行，全程零写冲突（dispatch-guard 46.2 计数误报的修法=组声明只写组名不写成员 ID）。
- **smart-merge-back --deploy 一次通过**：3 部署位 IDENTICAL + 11 池成员 LINK-OK，合并/部署/对账全自动。

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环与三击协议 -->
- code-runner-agent(mini) provider 被拒，两轮（基线/S5）同象 → 类别:环境（档位供给波动）；处置=22.3① 改派 executor 直通（Handoff #10/#7 rescue 留痕）。
- 计划期锚扫描 `grep ... | head -12` 输出截断，漏掉 skill-split 紧行数锚（字母序在截断点后）→ 类别:执行偏差（工具用法）；处置=全量回归对基线对比捕获（S5）。
- m5b 锚演进 label 改 task-v122 后，未跨脚本 grep 旧 label 文本，漏掉 self-resolution SR-11 的匹配正则 → 类别:执行偏差（核对清单缺项）；处置=fresh 复跑捕获（m6）+ m6b 单正则扩域修复。

## 🚫 被否决方案（User Rejected — Rule 32）
- 无（本任务用户未发出否决；D2 候选 B「新建媒体 agent 族」未被否决，属计划期未选方案，如重提需按 43.3 补候选预验证）。

## Files Modified
- 主仓合并产物（bf9bb97，7 文件）：skills/task-planner/references/critical-rules.md（+11）、skills/task-planner/SKILL.md（+4/−1）、skills/plan-template-kit/references/template-mapping.md（+2）、skills/task-planner/scripts/selftest-media-dispatch.sh（新建 95 行）、selftest-registry.tsv（+1）、selftest-skill-split.sh（±1）、selftest-self-resolution.sh（+2/−2）
- 部署位 3 处（.zcode/.claude/.config/opencode）同源同步

## Verification Results
- Verified: m7 fresh 44/44 rc=0 FAIL=0（685 用例）；alignment-review APPROVED；code-quality-review 14 维 APPROVED；3 部署位 IDENTICAL；VC-1..5 全 PASS
- Failed→Resolved: skill-split 行数锚 444 越界（→447 演进）；SR-11 正则域 v1[0-1]x 零命中（→v1[0-2]x 扩域）

## 📚 必要知识储备备注
- 本次新发现的知识源: selftest-registry.tsv 是「新增 selftest 必须同步登记」的机器门（T02 无缺失），新脚本类 S-unit 的输入材料必须包含它；review-library 池成员实名为 code-quality-review（SKILL.md 正文的 "code-review" 是命名漂移）。
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: SKILL.md:306「Critical Rules 1-39」前缀旧文案刷新（P2）；selftest 脚本权限位统一（P2）

## Notes for Next Time
<!-- 消费侧契约（Rule 31.5）：条目格式 = 触发条件 + 防线一句话；下一 Phase 开工前 / 新任务 init-session 后 Read 命中即执行并记 [learn-apply] -->
- 触发=技能类修改任务计划期做锚/断言扫描：**不过滤、不截断、按文件全列**（grep 输出禁 head 截断；行数类紧锚、正则类跨锚都要列）——防线：防「改动越过未列出的紧断言」。
- 触发=修复单要改 selftest label/断言文本/正则域：先 `grep -rn "<旧 label 文本>" scripts/` 跨脚本扫全会匹配它的正则/断言，一并联修——防线：防「修一处断另一处」的二次级联（本次 SR-11 实证）。
- 触发=派发 code-runner-agent/其他 mini 档被 provider 拒：直接按 22.3① 改派 executor（agnes 系 provider），勿同法重试；rescue 记 Handoff。
- 触发=派发守卫生成「多 S-unit 打包」误报：检查 prompt 是否出现多个 `S\d+` 字面量（组声明 `[S1,S2,S3]`、他行 ID 引用），只保留本行 ID。
