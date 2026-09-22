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
- Verified: Rule 39 六子条追加 critical-rules.md L343-361（grep 六锚点全命中，+20 行零删除）；SKILL.md 558 行（净增 3）；全量 27 selftest 453/0（基线 441+12 WF）；config 键数恒 40；三位部署 diff -r 全 IDENTICAL
- Failed: 全量首跑暴露 4 selftest 宽容锚 1-3[5-8]/1-3[1-8] 上界 8 不命中（v085 级联漏网）→ 扩 9（5 处）；plan-tier PT-08 字面锚 1-38→1-39；SKILL L9 frontmatter 行 1-38→1-39（P5 补全）

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源: dynamic-workflows 官方技能文档 /opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SKILL.md（1521 行，工具契约+facade+终态语义+dwfq 升级+SaveWorkflow 沉淀）
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: workflow 内 subagent 是否受 check-dispatch hook 约束=官方文档未提及（Rule 39.5 已如实披露，待 harness 实测确认）

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
- 触发：升级 Rules 1-N 索引（本次 1-38→1-39） | 防线：级联 grep 清单必须含三层——①字面 `Rules 1-N` 文档索引（SKILL frontmatter L9+正文 2 处/CLAUDE/README_zh/skills README）②宽容正则锚 `1-3[5-8]`/`1-3[1-8]` 的 N 上界（4 selftest 共 5 处）③字面数字锚 PT-08 式 `1-38`（selftest-plan-tier 等）。本次 P5 全量兜底抓到第 ②③ 层漏网（v085 同型教训第 2 次）——索引级联 PR 前必跑 `grep -rn "1-38" scripts/*.sh` 全量清单
- 触发：Rule 39 /workflow 编排 | 防线：只有用户显式点名才路由 CreateWorkflow（39.1 官方红线）；未点名=21.4 串行零改动；errored run 只能 AmendWorkflow（不可 resume）；cache 命中要求 subagent 名稳定+可调常数不进 ask 文本；SaveWorkflow 绝不主动保存（34.3 触发才沉淀）
