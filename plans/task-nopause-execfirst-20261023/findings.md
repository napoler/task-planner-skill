# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1-R7 全录 task_plan.md「用户需求原文」区；逐字全文=本目录 user-session-log.md #1
- 需求本质（58.4 [目标] 归并）：泛化禁止「零报错+有直接推进路径+用户零收益且资源流失」类暂停；额度不可查询时执行即探测；时间衰减额度禁空置；质检处置自主化

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Rule 94 落地形态（追加格式锚） | skills/task-discipline/references/critical-rules-discipline.md:605-615 | ☑（经 Explore 检查点②） | Research Findings-2 |
| 编号账本 | plans/.rule-reservations.jsonl | ☑ | Research Findings-5 |
| worktree/部署通道 | skills/task-planner/scripts/smart-merge-back.sh:370,385-388 | ☑（经检查点④） | Research Findings-4 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[Phase 1/Explore 检查点](subagent-state/1-explore.md)（HIGH，四节全）**
- **1. 执行体额度停等措辞面**：两执行体**无显式「询问用户是否有额度」条款**，诱导停等的是三处成本语义：video L19「成本纪律:…配额警示后再批量」（主根因——读作"先向用户警示配额再批量"即恶意暂停）、video L58「❌ 超配额无警示批量扩散」、video L43/image L42 逐字同款「额度/配额查询复用（Rule 55.1/55.5）→agnes-quota.sh…计费层未填充时如实呈报脚本 verdict，HTTP 402=配额耗尽事后信号」（缺"不可查询时怎么办"分支——即执行即探测）。image L18 试水门/重抽≤20 本身健康；两体质检处置均为「只建议不裁决/归主进程」；合法 STOP 仅限既定负结果（video L70：连续 2 镜同型 FAIL/轮询超时/配额拒绝；image L69：重抽超限冻结/连续 2 件同维度 FAIL）。前端 frontmatter description（video L3）含「G1 放行前置」——放行门本身是用户已批准设计（草稿侧隔离铁律），本次不动其门，只杀额度预询问语义。
- **2. Rule 94 尾部形态（追加格式锚）**：critical-rules-discipline.md 共 615 行，Rule 94=末条（605-615）。格式=`### 94 <名>（P0 — <task-id>，目标：<一句话>；判定面=LLM 行为+本条款文本锚、零新 config 键、零新增守护脚本；衔接 Rule …，既有规则条目原文零改动）`+空行+`**建制（为什么有这条）**：用户 <日期> /goal 指令（逐字锚 plans/<task>/user-session-log.md #1）：「…」根因=…`+空行+`**<协议名>（P0）**：`+加粗子弹 `- **NN.N <名>**：…`。Rule 95 从 L616 追加。
- **3. 级联面=文档非 selftest**：selftest i 类=**0 行/0 文件**（15 个 live 纪元 selftest 全用覆盖 9[0-9] 的宽容锚，1-95 天然命中；3 处 "1-9[0-9]" 命中全为注释/负样本 ii；WF-10 靠历史注释解耦、BP-09 锚 batch-quality-gate.md:138「隶属 Rules 1-36」非 live 纪元**勿动**）。真级联=5 文件 22 行文档纪元声明：SKILL.md:9/17/196/209/251、README.md:4/36/81/123/127、docs/ARCHITECTURE.md:4/13/42/113/114/115/135/137（:121-123 纪元注释链追加一行）、CLAUDE.md:33、README_zh.md:136/229（1-94→1-95、77 条→78 条、纪律域列表补 95）。references/critical-rules.md:175 为历史叙述不改。
- **4. 部署位**：rule94 先例=源 skills/{task-planner,task-discipline} 7 文件 → zcode `~/.zcode/skills/*` + cursor `~/.cursor/skills/*`（文件级 cp，2 位）；smart-merge-back --deploy 默认 3 位（zcode/claude-code/opencode，不含 cursor），env `TASK_PLANNER_DEPLOY_SLOTS` 可覆盖 → 本次设 `TASK_PLANNER_DEPLOY_SLOTS="$HOME/.zcode/skills/task-planner:$HOME/.cursor/skills/task-planner"` 对齐先例。
- **5. 编号与回归入口**：Rule 95 已由 attest 自动 reserve（账本 jsonl rule:95 reserved）；全量回归=`bash skills/task-planner/scripts/run-selftests.sh --fresh`（期望末行 FAIL=0，92 selftest）。
- **6. 并行会话事实**：全局活跃指针已被并行会话 task-subagent-boost-20261023 抢占（hook 提示串台实证）；本会话 sid 侧指针正确；合并前须按 §11.3 复核 master 未被对端推进到本任务 scope 文件。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 修正对象=video L19/L58/L43 + image L42/QC自主条款（非新造询问门删除） | 措辞诱导（"配额警示后再批量"）是停等根因；执行即探测补"不可查询"分支 |
| 级联走文档 22 行（selftest 零级联） | Explore 实证宽容锚已覆盖；BP-09 行明确勿动 |
| 部署用 TASK_PLANNER_DEPLOY_SLOTS=zcode+cursor | 对齐 rule94 先例 2 位，避免误写未登记位 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| Agent 派发连续 2 次 provider 限流 | 90s 退避后第 3 次成功；未降级换模型（宪法口径） |
| attest 四连拦（时长格式/粒度>2f/Phase4 缺表/VC 无命令/占位步骤） | 逐一按脚本源码口径修 plan 后锁定成功；教训=计划期先读 attest 源码再写表 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 检查点：plans/task-nopause-execfirst-20261023/subagent-state/1-explore.md（四节全，含逐字行级摘录）
- 回归入口：bash skills/task-planner/scripts/run-selftests.sh --fresh
- 部署机制锚：smart-merge-back.sh:370/385-388；detect-tools.sh:18-24

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
