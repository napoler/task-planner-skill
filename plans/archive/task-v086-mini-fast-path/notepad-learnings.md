# Task Learnings: task-v086-mini-fast-path

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-09-21 用户「一个项目下支持多个模板，每次只加载一个，不用过于复杂」→ S6 扩围（init-session --list/项目 default 指针/env TASK_TEMPLATE_DEFAULT/frontmatter 插入；极简=零注册表零新目录，只改 1 文件）；并入 P3 执行非独立任务

## What Worked
- 门控豁免走 frontmatter 机器标记（`grep -qm1 'plan_tier: mini'` 计划文件）而非模板名判定：防手搓计划绕过，非 mini 路径 if 前置零 diff（master 三方对照实证）
- CR 抓「写入侧形态 vs 读取侧提取链」双端契约缺口（BLOCKER）：功能新增时先 grep 全部消费侧提取点，PT-28 双端闭环断言范式可复用
- S5 全仓终扫 1-37 字面残留=0 一次修齐（宽容正则 1-3[5-8] 扩围），未复现 v085 漏 3 处 FAIL
- 子代理截断（S2 首派 status=done 产出缺半）→ SendMessage resume 补齐成功，勿盲重派

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
- 初版 selftest 样例手造双形态 plan_tier 标记（表格行+注释）偏离真实 init 产物（注释单形态）→ 4 条行为断言代表性打折（类别=假设未验）；修法=样例改真实模板 cp 基座
- check-template-type 提取链补形态前，init frontmatter 插入注释形态对 gate=死代码（mini 主路径 enforce 档拒锁）（类别=契约对齐缺位）；修法=gate 补第三形态+PT-28 钉住
- 主进程验收缺位一次：S2 首派未做「Read 检查点尾部+git status 双证」即放行（类别=执行偏差）；教训=子代理 status=done 不代表完整，必双证

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
-

## Files Modified
-

## Verification Results
- Verified: [specific change confirmed]
- Failed: [specific issue and resolution]

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
-
