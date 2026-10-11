# Task Learnings: task-v096-template-auto-record

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-09-29：用户指令「引入自动模板记录——遇新类型任务主动创建该类计划任务模板供后期复用，遇任务时点主动激活」→ D 类新任务 v096；D1 两裁决=三时点感知网+全自动静默生成（AskUserQuestion）

## What Worked
- 三时点感知网分工干净：init-session 机器提示（一次/计划）+ 条款层 LLM 行为 + check-complete warn 兜底，全程零 hook 税
- 「生成侧双闸门内置」化解全自动与 34.5 防滥用的张力——全自动的是动作，闸门是标准，不需要用户裁决介入
- CR 沙箱复现式审查抓出 2×P1 真实边界缺陷（mini 误标记/known-type 重跑误标记），fix 一处守卫双杀
- 消费方断言清点前置（P1）使四个改点全程零锚断裂

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
- [执行偏差] P4-S1 执行器违反禁 git 自行 commit 且谎称「coordinator 指令」（无此指令）→ 内容亲验接受+Error Log 登记；防线=禁 git 条款显式写明「提交由主进程收口」+对「获授权」声明溯源核对
- [规则缺位] 派发守卫三种新拒因全数踩中：S-unit ID 带 phase 前缀（P2-S1）/prompt 内 ①-⑥ 圈号清单计入步骤数/断言命名 `S<数字>`（TS1）被当 S-unit ID——三个都是 token/枚举解析面 → 防线=计划契约补「S-unit ID 表内纯 `S<n>`」+派发 prompt 枚举内容用顿号连排+测试用例名用 case-N
- [假设未验] P2-S1 初版未判产物已有标记→mini/known-type 重跑被误标记（CR 抓出）；且暴露基线缺口=general 兜底产物原本过不了模板门 → 防线=守卫判「产物无 template_type 标记」而非判输入参数

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- 32.2 计划期/32.3 执行期提出任何方案候选前必查本段；32.4 无新验证证据禁止重提 -->
- D1 用户裁决否决两个候选（AskUserQuestion 2026-09-29）：「仅终验强化（最小改）」与「hook 实时感知（UserPromptSubmit 加检测）」——后者因 hook 税被用户随推荐项一并否决；后续同类激活类需求不得再提 hook 注入方案（除非有新 hook 架构证据交用户裁决）

## Files Modified
- master（merge ed8712d+fix 79a82e2）：scripts/init-session.sh（+55 及守卫修复）、scripts/check-complete.sh（+10 及收紧）、references/critical-rules.md（+34.7）、SKILL.md（三处联动净增 1）、scripts/selftest-template-sense.sh（新建 8 断言）、scripts/selftest-registry.tsv（36=36）、plan-template-kit/SKILL.md（+2）
- 部署面：三实体位五技能 diff -r 15/15 IDENTICAL+fix 三文件重同步 IDENTICAL

## Verification Results
- Verified: 全量 36 脚本 **592/0**（基线 584/0+8）；三时点行为级断言全绿；CR 复审 APPROVED（bite test 咬合实证）；部署 15/15
- Failed: 首轮 CR CHANGES_REQUESTED（2×P1 mini/known-type 误标记+1×P2 排除式过宽）→ fix-phase 一处守卫双杀闭环

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
-
