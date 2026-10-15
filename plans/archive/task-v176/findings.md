# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1[目标] 挖掘技能运行过程中存在的问题
- R2[目标] 核心=如实记录过程产出数据+锚定数据（记录/追踪/纠错/纠偏，其他皆辅助）
- R3[目标] 消除上下文偏移与幻觉；建立前后对照；解决遗忘
- R4[手段] 主动基于上下文审查发现不合理并改正（不只是报告）
- R5[目标] 提高整个运行准确性（可机器复验的提升）
- 逐字原文见同目录 user-session-log.md #1（Rule 80 权威源）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-planner SKILL.md（233 行） | skills/task-planner/SKILL.md | ✅（S1 全文读） | Research Findings S1 段 |
| 核心 critical-rules.md（14 条） | skills/task-planner/references/critical-rules.md | ✅（S1 全文读） | Research Findings S1 段 |
| selftest 全集（80 脚本） | skills/task-planner/scripts/run-selftests.sh | ✅（S2 实测跑） | Research Findings S2 段 |
| INDEX.md + rule-reservations 账本 | plans/INDEX.md、plans/.rule-reservations.jsonl | ✅（S3 对照） | Research Findings S3 段 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### S1 记录域机制审计（Explore，11 缺口，A/B/C/D 四类）— 全文 subagent-state/1-explore.md
- A 类（声称无承载）：① v168「R 锚定复诵」每 Phase 强制但 0 脚本断言；② Rule 81.6/83.4 声称 selftest 守护 C56/C57 行，对应脚本实际无此断言且 v171 瘦身后 C 行物理不存在（守卫虚标）
- B 类（文本/编号漂移）：① Rule 51.1a 写「三锚门」vs attest-plan.sh 实为四锚（+根源覆盖表）；② C56 编号三处争用（SKILL：C56=80 / critical-rules：C56=81；C57=81 vs 83）——前后对照基准自身污染；③ 脚本注释 Rule 60.2/60.5 应为 62.2/62.5；④ Rule 82 边界清单 12 条 vs 实际 14 条（81/83 落地未级联）
- C 类（记录强度倒挂）：① user-session-log「append-only」（80.2）无哈希链/基线 diff，改写不可检测，而 task_plan.md 有 SHA-256 锁——用户原话权威源反而是最弱载体；② ledger 仅 mtime 防伪，Phase 结束前批量补记可让 19.2 门放行；③ [goal:Gn] 证据行只 grep -q 存在性，66.3「实跑通过」退化为「写了行」
- D 类（前后对照缺位）：① 会话恢复（session-catchup）无「记录状态 vs git/文件系统」对照；② R-COVERAGE（51.3）不验证据路径真实存在，默认 warn 不阻断，L0 只查前 3 行

### S2 脚本验证基线与簿记脚本审计（code-runner-agent，基线 80/77/3 + 10 缺陷）— 全文 subagent-state/2-code-runner-agent.md
- **基线（2026-10-15 实测，复现命令 `bash skills/task-planner/scripts/run-selftests.sh --fresh`）**：Total=80 PASS=77 FAIL=3。根因单点：selftest-input-consistency.sh（task-v175 commit ddf6ede 新增）未登记 selftest-registry.tsv（79 数据行 vs 80 脚本）→ 3 个 selftest 连锁 FAIL。**task-v175 提交时全量回归未跑或带红入库**（Rule 27 违反实证）
- 假 PASS 通道（fixture 级实证，/tmp/s2-* 可复跑）：
  1. sync-todos.sh write_index contains 匹配——Phase2 `- **Status:** in_progress（前一轮 complete 判定已撤回）` → INDEX 记 `complete 2/2 ✓`（进行中→已完成失真）
  2. archive-plan.sh total（列表锚）vs ok（全文字串）口径不对称——无列表符样例行 `**Status:** complete（样例行）` → 假 PASS 归档 in_progress 任务；正文引用格式 → 假 FAIL 拒绝真完成任务
  3. archive-plan.sh 不校验 Phase 覆盖——缺 Status 行的 Phase 被整体忽略（task-C fixture）
  4. check-complete.sh「No phases found」（`## Phase 1:` 二级标题等变体）→ 全门链静默跳过 + **exit 0**（终验假 PASS 最恶劣通道）
  5. CR-GATE diff `-C <plan_dir>` 限死计划目录——仓内代码变更不可见；SKIPPED 与 PASS 同屏并存
  6. DELEGATION 豁免放行仍打印 `rate=0.000 >= floor=0.7` 假命题文案
  7. L0③ 用全仓 30 天 `--grep 'feat\|fix'` 计数 + 任意位置搜「单commit」字样豁免 → commit 惯性验证≈0
- 跨脚本口径分裂：同一 `* **Status:** complete` 文件，sync-todos=complete / archive-plan=可归档 / check-complete=0/1 pending——三工具三结论
- 假 PASS 面无观测性：多处 `if [ -f ]` 无 else 零输出跳过（check-plan-dispatch/RESCUE/LEARNING-GATE）+ 默认全 warn 档不改 exit 码——exit 0 ≠ 验证通过

### S3 簿记失真对照（general-purpose，重派第二次成功）— 全文 subagent-state/3-general-purpose.md
- **事实修正（前后对照实证）**：INDEX 8 个未完成任务于 2026-10-15 09:50（commit 4287b7a）被并行会话 git mv 入 archive/ 并刷新 INDEX——「未完成 10 天」现状在会话中途自愈；失真窗口=merge 到归档的滞后期 1–10 天（v172 08-14 merge→10-14 归档）
- 编号账本双向失真：reserved 32 / landed 34——6 条 landed 无 reserved（46-50、75）+ 4 条 reserved 无 landed（57/60/80/82 悬空预留）；无 selftest 校验 reserve↔land 配对
- wt/task-v168-machine-parked 遗留分支（commit cdf437e「机器面封存不合入」属有意封存但无到期清扫机制）
- 结构性缺陷：① INDEX 翻转无强制钩子（config.json hooks 字段为空 {}，完成→归档→刷新全链靠代理纪律）；② 归档无自动触发（两次归档均手动 git mv 批处理）；③ 账本配对无机器门；④ wt/ 无清扫；⑤ selftest-sync-index.sh hermetic 夹具不触真实 plans/ →「INDEX vs git 真实状态」失真无机器检测面

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 修正范围聚焦 P0 记录失真面（sync-todos/archive-plan/check-complete 假 PASS 通道 + user-session-log 完整性锁 + goal-gate 证据三要素） | 直接对应用户 R2/R3「如实记录+防幻觉」；B 类文本漂移作 P1 第二批（改文本触发 selftest 钉值断言，需逐一 grep 级联） |
| 不新增 Rule 编号 | 任务定位=修既有机制缺陷；新条款建议入 findings 待裁决 |
| S3 重派第二次成功（第一次子代理 no-output 无落盘=事实失败） | Rule 22.8.4 checkpoint 缺失即重派，不采信自报 done |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| S3 首次派发返回丢失且检查点未落盘 | 全仓 find 双确认无产物 → 重派（prompt 强化「先 Write 后结束」铁律）→ 第二次成功 61 行落盘 |
| attest-plan 首轮拒锁（4 S-unit 粒度超 step_max 2f/15min + Goal 表头缺失） | Rule 59.1 回炉重拆为 1-2f/15min + 补表头后二次 attest PASS |
| Edit 工具两次 30s 超时但实际写入成功 | 以 grep/wc 复核落盘结果为准，未重发（防重复编辑） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 三路审计全文：plans/task-v176/subagent-state/{1-explore,2-code-runner-agent,3-general-purpose}.md
- fixture 复现目录（S2 建，/tmp）：/tmp/s2-idx（缺陷1）| /tmp/s2-arc（缺陷3/4/9）| /tmp/s2-cc（缺陷5 exit0）| /tmp/s2-git（缺陷6）
- 基线日志：/tmp/task-v176-selftest-baseline.log

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

## 🩹 问题清单与修正方案（Phase 2 分级，源自 S1/S2/S3 三路审计）
<!-- 分级标尺：P0=直接制造记录失真/假 PASS/幻觉通道且单点根因明确（本任务必修）；P1=文本级联漂移（安全子集可修，逐项 grep selftest 钉值后动手）；P2=结构性大改或需用户裁决（登记不修） -->

### P0 修正集（Phase 3 落地，共 6 项）
- **D1 | sync-todos 状态判定分裂（S2-1/2/9）**：write_index contains 匹配无词界/无行首锚，fwd/idx 两入口口径不一，跨三脚本三结论。修法：统一行首锚 `^- \*\*Status:\*\*`+全词状态词（complete|in_progress|pending）+剥括号注记；游离 Status 行不参与计数。守护：selftest-sync-index.sh 新增 T08（撤回注记 fixture）+T09（星号列表符 fixture）。
- **D2 | archive-plan Status 门口径不对称+Phase 覆盖缺失（S2-3/4）**：total（列表锚）≠ok（全文字串）→假 PASS 归档 in_progress + 假 FAIL 拒真完成；缺 Status 行 Phase 被忽略。修法：total/ok 同用列表锚+全词 complete；新增「Phase 标题数 vs Status 行数」覆盖校验，缺号 fail-closed。守护：selftest-archive-plan.sh 新增 AP-17/18/19（假 PASS×2+覆盖 fixture）。
- **D3 | check-complete「No phases found」→exit 0（S2-5）**：Phase 标题变体（`## Phase N:`）→ 全门链跳过+终验假 PASS。修法：total==0 → fail-closed exit 1+明确报错文案。守护：新增 fixture 断言（header 变体=拒）。
- **D4 | user-session-log 完整性无载体（S1-7）**：append-only（80.2）无哈希链，历史改写不可检测，而 task_plan 有 SHA 锁=记录强度倒挂。修法：init-session.sh 创建专档时生成基线 `.session-log-baseline`（首条目 sha256+条目数），check-complete SESSION-LOG GATE enforce 档校验「条目数≥基线 ∧ 首条目 sha 未变」（禁删条/禁改首条；append 合法）。
- **D5 | goal-gate 证据行仅存在性检查（S1-9）**：`grep -q "[goal:Gn]"` 一条空行使 66.3 实跑语义退化为写行。修法：证据行须同体含三要素信号（验证命令词 bash/bun/node｜PASS/✅｜FAIL=0/路径）至少其一命中。守护：新增 fixture 空行断言。
- **D6 | selftest-input-consistency.sh 未登记 registry（基线 3 FAIL 根因，task-v175 带红入库）**：selftest-registry.tsv 79 数据行 vs 80 脚本。修法：追加登记 1 行 → 基线 80/80 PASS。守护：registry T02 已在岗（报警正确，是提交纪律放它进来）。

### P1 文本级联子集（Phase 3 顺手修，每处改前 grep selftest 钉值；钉着的先级联后改）
- D7（S1-1）：Rule 51.1a「三锚门」→ attest 实为四锚——critical-rules.md:88 文本更正
- D8（S1-4）：C56/C57 编号三处争用（SKILL:124/125 vs critical-rules:147/177 vs selftest-knowledge-brief:42）——以「C56=80 域原编号」为准对齐另两处注释
- D9（S1-5）：check-dispatch.sh:90/172 注释 Rule 60.2→62.2；check-3file-gate.sh:141 注释 60.5→62.5
- D10（S1-6）：Rule 82 边界清单 12 条→14 条（critical-rules.md:165）
- D11（S1-3）：Rule 81.6/83.4 声称 selftest 守护 C56/C57 行——文本改为实况（G9/G10 承载）或删虚标
- D12（S1-2）：R 锚定复诵补机器面：check-complete 增加「progress.md Phase 段含 `- **R 锚定**：」行存在性断言（对齐 Phase 数）
- D13（S3-3）：rule-reserve land/reserve 配对 selftest（allowed landed 旁路 46-50/75 登记豁免表）

### P2 不修登记（本任务范围外，转建议区）
- D14（S2-10）fail-open 可观测性重构：check-complete 全门显式输出「ran/skipped」+各门默认 enforce 化=结构性改动，涉及存量 warn 语义与大量 selftest 预期，超出单任务安全半径——建议独立任务
- D15（S2-6/7/8）CR-GATE diff 范围修复/DELEGATION 文案/L0③ 全仓计数改 pathspec——需逐个设计+回归，列入后续
- D16（S1-10/11）会话恢复 git 对照校验+R-COVERAGE 证据路径实存+enforce 化——机制新增，独立任务
- D17（S3-1/2/4）INDEX 翻转钩子/归档自动触发/wt 清扫机制——涉及 hooks 配置（config.json hooks={}）与基础设施，需用户裁决；且 4287b7a 已证明人工批处理路径有效，机制化价值/风险比另行评估
- D18（S1-8）ledger 内容完整性链——哈希链设计影响高频追加路径性能，独立评估

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
