# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 引入交叉验证方法论识别执行错误（[目标]）/ R2 隔离上下文+多角度保产出稳定（[手段]）/ R3 更快识别产出错误缺陷（[手段]）/ R4 不信模型自我虚构，伪造须及时识别（[目标]）/ R5 固化到技能与步骤（[手段]）——逐字原文见 user-session-log.md #1，映射见 task_plan.md R→VC 表

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### F1 落点文件结构（Explore 侦察 2026-11-15）
- critical-rules-verification.md 共 58 行；条款形态=`### 84 <标题>`(:11) 块+正文行首编号子条（84.1:15/84.2:17/84.3:19/84.4:27/84.5:35/84.6:46/84.7:48/84.14:58=EOF，无 ####）；**Rule 108 追加锚=EOF(:58 后)新 `### 108 <标题>` 块**，前锚 :58 原文不改
- verification-gate/SKILL.md 94 行：description :4（触发面）/调用时机 :24-31/执行步骤 :33（Step1:35/2:49/3a:57/3b:63）/脚本索引 :74/References :87
- 影响：108 追加 EOF+SKILL 三处补触发与指针，零破坏既有 84.x 锚

### F2 selftest 注册与运行机制
- registry.tsv 4 列=script/domain/trigger_scenarios/dep_anchors（:1 表头；样本 :2/:3）；98 行
- run-selftests.sh **glob 遍历 selftest-*.sh 自动发现**（:55/:113/:118），非读 registry；新增 selftest 无需改 run-selftests.sh，**但必须登记 registry.tsv 否则 selftest-registry.sh 一致性检查失败**（:34 该脚本自身亦登记）

### F3 「1-107」纪元级联族（全枚举，排除 .backup）
- SKILL.md :9/:224/:267 三处 '1-107' 字面
- selftest-enumerate-first.sh EN-06（:9/:92/:93/:95/:97）：断言 SKILL.md 含 '1-107'≥3 且 discipline 路由行含 ',107'
- 结论：纪元演进 1-107→1-108 需改 SKILL.md 三处+EN-06 五处字面（阈值 -ge 3 不变）；**',107' 断言不受影响**（Rule 108 归 verification-gate 不属 task-discipline，SKILL.md:210 的 ",105,106,107" 不动）；另 SKILL.md:220 verification-gate 路由行当前仅 "Rule 84" 需加 108

### F4 触发面档位现状
- 51.14 L1-L4 条款实际在 **skills/task-planner/references/critical-rules.md:107**（task-discipline 无 51.14 命中），消费点 SKILL.md:230+execution-recall-card.md:7
- Rule 103 双轮质检在 critical-rules-dispatch.md:225（103.1 :229/103.2 :231）
- Rule 84 子条：84.1:15/84.2:17/84.3:19/84.4:27/84.5:35/84.6:46/84.7:48/84.14:58
- 防撞车：verification-gate 域内 '交叉' 仅 templates/verification.md:97「Handoff 交叉校验」既有用语，Rule 108 需避开歧义措辞
- 影响：108.1 触发面对齐 51.14 档位口径（core :107），与 84.4/84.7/103 构成互补框架不复写

### F5 verification 模板与守护面
- task-planner/templates/verification.md 140 行：VC 段 :10-31/Phase Gates :34-78/知识储备 :80/委派统计 :87/质量门控 :103/Goal Gate :109-128/5Q :131-140
- **CV 区块安全插入点=:127（验证独立性引用行）后、:131（5-Question 标题）前**，段尾追加式不触碰 VC/Phase/Gate 既有锚
- 守护面：仅 selftest-verification-gate.sh 引用 templates/verification.md（:23 SAT_TPL=**卫星**模板 skills/verification-gate/templates/verification.md；VG-03 :52-58 断言卫星模板 Verify command 串；VG-13 :148-156 守护 84.7）——主模板段尾追加风险低

### F6 判例锚格式先例
- 实例1 execution-recall-card.md:7 `（task-drift-fakeqc-20261115 判例锚）`；实例2 core critical-rules.md:107 `判例锚：…（判例=task-drift-fakeqc-20261115 判例）`
- Rule 108 判例锚沿用：`（判例=subagent-verifier-fabricated-output-20261103 判例）`同款格式

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
