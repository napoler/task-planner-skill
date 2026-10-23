# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- **R1（激活率）**：制定计划/调研分析等类别应默认派发子代理，主进程亲自执行应为例外；子代理可按复杂度切大/小模型提质省成本（task_plan.md「🎯 用户需求原文」R1）
- **R2（并行率）**：无互相依赖的任务应组成并行组、同消息并发派发；实践中经常只开 1 个并行子代理（同上 R2）
- **R3（手段）**：计划期即明确哪些可子代理/可并行，按依赖关系定并行组（同上 R3）——由 Rule 96 六子条+模板承载落实

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules.md Rule 21.4/22/46/52/59 | skills/task-dispatch/references/critical-rules-dispatch.md（卫星全文） | ☑ | Research Findings·勘察 |
| Rule 94 部署先例 | plans/archive/task-deploy-rule94-20261023/progress.md:21-38 | ☑ | Research Findings·部署 |
| selftest 脚本族与 registry 约定 | skills/task-planner/scripts/selftest-registry.tsv（93 行） | ☑ | Research Findings·实现 |
| worktree-isolation.md / §十一 | skills/task-planner/references/worktree-isolation.md | ☑ | Technical Decisions |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 勘察（Phase 1，检查点 subagent-state/1-rule-mapper.md / 2-anchor-mapper.md / 3-deploy-reserve.md）
- **落点校正（关键架构事实）**：任务书字面路径 `skills/task-planner/critical-rules.md` 不存在；核心文件实为 `references/critical-rules.md`（203 行，仅 :193 卫星路由枚举含规则编号），委派/并行权威全文在卫星 `skills/task-dispatch/references/critical-rules-dispatch.md`（185 行）→ Rule 96 正文落卫星、核心只动 :193 枚举（1-rule-mapper.md §一；4-draft-rule96.md acceptance-1）
- **缺口定位**：①激活面无「任务类别→默认派发」正清单，Rule 13 强制类别仅 4 类（dispatch.md:10-11），25.3 白名单②出口覆盖面宽、25.4 只统计 Phase 级占比（1-rule-mapper.md §二）；②并行语义止于「组内可并行」（21.4:25-32），68.2 仅约束「零声明需论证」，无「应声明而未声明」正向硬条款、无同消息并发形态条款（1-rule-mapper.md §一并行推进面）
- **级联面**：scripts/ 纪元锚已全部「宽容正则」化，96 纪元下 63 条可执行断言免改仍 PASS；必改面=SKILL.md 三处字面 1-94→1-96+run-selftests.sh 两处注释钉（2-anchor-mapper.md §0 结论速览）
- **部署位**：zcode 根=/home/terry/.zcode/skills/、cursor 根=/home/terry/.cursor/skills/，相对路径=根下直拼（3-deploy-reserve.md §1，承 Rule 94 先例 14 cp 口径）

### 起草（Phase 2，draft-rule96.md + subagent-state/4-draft-rule96.md）
- Rule 96 六子条定稿：96.1 激活默认档矩阵（A1 制定计划~A7 创作七类可判定触发+主进程窄白名单例外须登记理由）/ 96.2 模型分档（计划期正向三档：轻 haiku-1、中 sonnet-1、重 GLM5.3·Opus 级既有通道）/ 96.3 计划期并行硬标注（≥2 无依赖必须声明组，未声明未论证=计划缺陷）/ 96.4 执行期同消息并发派发 / 96.5 指标留痕（激活子代理数+最大并行宽度）/ 96.6 管辖边界（执行强化层，冲突以被引条款为准）
- 增量立法合规四条既有语义零改写：21.4「未声明者默认串行」/68.2「不新建机器门 opt-in」/59.4「超档拆细不升档」/22.3「拆细先于升档」（4-draft-rule96.md acceptance-3）

### 实现（Phase 3，subagent-state/5-text-editor.md / 6-machine-gate.md）
- 8 文件 +135/-10（worktree 提交 e319ee3）：dispatch.md 尾纯追加 29 行 Rule 96 全文（:186-214，wc -l=214）+核心 :193 枚举 `,96`+SKILL.md 纪元 1-96×3/枚举 ,96×2/:245 指针句+两模板锚定行+新 selftest（SA-01..15）+registry 登记（rows=93/actual=93）+run-selftests.sh 注释钉 :11/:79
- 21.4(:25-32)/22(:48-79)/46(:112-130)/52(:133-143) 权威区间零 hunk（8a-cr-alignment.md §一.1 git diff 实证）

### CR（Phase 4，subagent-state/8a-cr-alignment.md / 8b-cr-critic.md）
- 8a alignment-review 视角 **VERDICT: APPROVED**（:8），nit 4 条不阻断；8b critic 视角 **VERDICT: APPROVED**（:41），问题清单 6 条均非 BLOCKER
- 遗留面（两 CR 共识）：①run-selftests.sh 注释钉 77/73 延续基线历史失真（实测 selftest-*.sh=93 个，基线本就失真、无门）；②96.3 对恰 2 个 S-unit 串行计划的例外通道与 68.2 门槛存在措辞歧义（96.6 可自愈，建议后续一行扩句）；③96.5 两指标无 delivery-summary 模板槽（指针式引用可满足，本次收口已按 96.5 口径报告：激活子代理数=10 执行子代理、最大并行宽度=3）；④README/docs 纪元级联欠账（skills/task-planner/README.md:36/:68/:81/:123 与 docs/ARCHITECTURE.md 六处仍 1-94，无 selftest 因此红，属既定部署 lane 移交项）
- 8b nit-6：selftest-dispatch.sh:238 共享 /tmp 固定路径计数文件（既有债，并行跑同 suite 必互踩，本次实证假阳性）

### 部署（Phase 5，subagent-state/9-merge-deploy.md）
- 合并链：worktree e319ee3 → master 6d60e02（reserve 台账）→ merge --no-ff = **cecacfb**（双亲 6d60e02+e319ee3，ort 零冲突；本收口会话亲跑 `git log --oneline -4` 顶部确认）
- 部署对账 **16/16 diff=0**（zcode+cursor × 8 文件，含新增 selftest-subagent-activation.sh）；锚复核两侧一致：dispatch.md 96.1 均 :192、core critical-rules.md `,96` 各 1 命中（task-planner 侧 :193）；`.drift-rhythm/` 零触碰
- **事故（如实曝光，检查点 9 §4）**：首次 cp 未剥离 `skills/` 前缀 → 误写入两部署位历史遗留镜像树 `$root/skills/`（非加载路径、运行影响=零）：7 个同名既有文件被覆盖（原内容无备份不可精确还原）、1 个误新建已 rm——待用户授权处置（正确位回写还原或整树清理），不做二次猜测式回写

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 96 正文落卫星 dispatch.md、核心只动 :193 枚举 | 核心 Rule 82 分层纪律+检查点 1 实测架构（塞核心=违反分层）；draft §0 落点校正 |
| 零新机器门/零新 config 键 | 96.3/96.4 判定面=LLM 行为+既有 check-plan-dispatch H3/W1/W2 锚；与宪法 §四.6 文本优先一致（8b §一） |
| SA-14 锚校正（保留设计锚+补 59.4 真实原文锚） | 设计稿凭记忆锚失配，实测 dispatch.md:158 原文为「先拆细再派」；守卫增强且断言总数不变=15 |
| 编辑 1 经 owner 升级裁决扩射程由 S6 补落 | S5/S6 ask 射程均不含 task-dispatch，孤儿面只有编排面可解；逐字节 diff=0 验收 |
| 纪元级联走宽容正则免改路径 | 检查点 2 §0：scripts/ 锚已宽容正则化天然覆盖 1-96，级联主体=改 SKILL.md 字面而非 selftest |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 编辑 1 孤儿面致新 selftest 首跑 10 红 | owner 裁决扩射程+S6 补落；复跑 15/15 全绿（progress.md Error Log 第 1 行） |
| 部署 cp 前缀错误伤及历史遗留镜像树 7 文件 | 误新建已 rm；7 覆盖文件待用户授权处置，正确位不受影响（Error Log 第 2 行+9-merge-deploy §4） |
| findings/progress 回填滞后触发 plan-compass 升级警告 | 本收口会话归并回填闭合；终验 outcome 按 Rule 26.3 帽=最高 PARTIAL（Error Log 第 5 行） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 规则正文：/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md:186-214（Rule 96 全文）
- 机器门：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-subagent-activation.sh（SA-01..15，本收口会话复跑 15 PASS=15 FAIL=0 EXIT=0）
- 检查点链：plans/task-subagent-boost-20261023/subagent-state/{1-rule-mapper,2-anchor-mapper,3-deploy-reserve,4-draft-rule96,5-text-editor,6-machine-gate,8a-cr-alignment,8b-cr-critic,9-merge-deploy}.md

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据；LOCAL-ONLY 豁免声明见 task_plan.md 调研需求表）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
