# Task Learnings: {task-name}

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
-

## What Worked
-

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
-

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

## 教训沉淀（Rule 31.4，2026-10-04）
- **守卫口径预扫**：含圈号 ①-⑤ 或行首 "NN.M" 编号的条款草案/长文若被 prompt 以 subagent-state/ 路径引用，check-dispatch 任务书模式会把它们计入步骤枚举序号（F4 同源）——正文类草案放 plans 根目录（守卫只扫 subagent-state/ 引用），任务书动作列表用破折号。
- **Edit 恢复纪律**：误删恢复时 old_string 禁携带目标行之外的后续块；先 Read 精确区间再最小化编辑，恢复后立即结构复验（grep 标题/Status 行序）。
- **统计解析探针先行**：汇总类循环先单跑一个样本看输出原文格式（`Total: N PASS=N FAIL=N` 等号语义），再写提取正则。
