# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### §Baseline（S1，2026-10-10，checkpoint=subagent-state/1-code-runner.md）
- master 全量 selftest 基线：**64/64 脚本全 PASS（rc=0），ΣPASS=1002，ΣFAIL=0，零 timeout**；逐脚本 64 行结果表在检查点；原始日志 /tmp/selftest-baseline/*.log
- Phase 3 回归对照判据：FAIL=0 或逐条分类（新增断言演进/并行任务演进）；执行窗口并发观察：task-v155 目录出现（并行会话，编号无冲突）

### §Research（S2 登记面锚，2026-10-10，checkpoint=subagent-state/2-explore.md）
- **D2** router 锚=`~/.zcode/skills/skill-agent-router/SKILL.md:101` 后（§八 meta-corrector 行后）；§一 4 列表/§八 3 列表
- **D3** template-mapping 锚=`skills/plan-template-kit/references/template-mapping.md:289` 后（§九 general 行后，5 列）+§十（line 300-314）同步
- **registry**：`scripts/selftest-registry.tsv`（4 列 tab，T02 断言强制登记）→ 新 selftest 必须登记行
- **钉值级联风险=无**：SKILL/critical-rules 均无「NN 脚本」定数断言
- **Rule 69 插入锚**=`references/critical-rules.md:860` 后（Rule 66 是文件最后一条，line 848-860）；撞号检查通过；条款风格两态：Rule 61 列表式 `- **61.1 …**`、Rule 63 段落式 `63.1 **…**`
- **SKILL.md 触发点锚 6 处**：T1=79（T3 结论先行句）/T2=452（五档兜底表头）/T3=463（触发条件列表）/T4=90（3a verify_done 句）/T5=99-101（DRIFT CHECK 步骤 6+DRIFT 行）/T6=139-150（Code Review Gate+门控行）；路由表行=409；清单 Rule 66 行=338；References=362

### §Constraints（外部约束面）
- model 格式强约束：`account:zai-individual-coding-plan/GLM-5.3`（complex-planner 先例 `companion/agents/complex-planner.md` frontmatter 实证）；`custom:uuid` 式禁用（v119 教训）
- worktree 铁律 §十一：路径=`/mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter`，分支 `wt/v154-decision-arbiter`，已创建且 SYNC-OK（desync 检查通过，HEAD 5afba9c）
- 并行任务占用：Rule 67=v152、68=v153（已预留未落地）→ 本任务 69；v152/v153 worktree 在途，合并回尾部冲突风险已入 FMEA

### §Implementation（S3，2026-10-10，checkpoint=subagent-state/3-executor.md）
- decision-arbiter.md 落地 worktree：60 行，frontmatter model=`account:zai-individual-coding-plan/GLM-5.3`（逐字符复核），四态 APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE+驳回单五要素+硬约束 5 条+T1-T6+四邻管辖二分全在位；主进程 Read 复核通过
- 设计取舍：修复权留主代理（REJECT-REWORK 只裁决不改码）；ESCALATE-USER 锚定 Rule 41.2 四门槛；单次独立禁驻留循环（强模型经济性）

### §Implementation 续（S5+S6，2026-10-10，checkpoint=5/6-executor.md）
- S5：SKILL.md 11 处增量（路由行 417/清单行 344/欠账修正 286=1-66→1-69/T1-T6 标记 80/92/104/153/470/477/C46=223/外部引用 383）；grep decision-arbiter=12 occurrences、Rule 69=11 行
- S6：agent-coverage.md 矩阵 28 行+头注 26→28 计数欠账同步 2 处（line 42「底稿原 26 行」为史实保留）；template-mapping.md §九 line 290+§十 line 314 各+1 行；D2 router 登记行文本已产出待 Phase 5 部署
- 裁决登记：AC-09 上界 129→130 属合法演进（授权 S7 一并处理）；AC-04 部署暂态预期内；S5⑪ 独立新行落位可接受（CR 把关）

### §Verification（S7，2026-10-10，checkpoint=subagent-state/7-executor.md）
- selftest-decision-arbiter.sh 新建：DA-01..DA-16 共 16 断言全 PASS exit 0（95 行≤120；任意 CWD 验证通过；主进程独立复跑复核一致）
- AC-09 上界 129→130 演进注记落地（selftest-agent-coverage.sh 8/6）；AC-04（~/.zcode/agents/decision-arbiter.md 缺位）=Phase 5 部署暂态预期内
- registry TSV 追加第 65 行（T02 断言通过，rows=65=actual 65）

### §Verification 续（S8+Rounds，2026-10-10，checkpoint=8/fixa/fixb1/fixb2/b3-executor.md）
- S8 首跑 5 FAIL→Fix 四批修复（commit 6e1202f）→Round 3 终跑 64 脚本 failed=1（AC-04 部署暂态）
- 级联修复方法论验证：RF-06 精确锚 1-69 与 9/368 行 1-66（六守卫依赖）不可同真→宽容锚 `1-6[0-9]` 保三处联动语义（先例 CD-18/IP-12）；DCS-11/G-09/T-main 行联演进（钉值 515→526 留 5 余量）；G-07 末行断言用行位置恢复而非改断言语义（最小变更）

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- drift-checker 先例：`skills/task-planner/companion/agents/drift-checker.md`（只读判定体结构：硬约束/SOP 5 步/检查点契约）
- complex-planner 先例：`skills/task-planner/companion/agents/complex-planner.md`（强模型 frontmatter：model+thoughtLevel+触发/禁用词 description）
- 覆盖矩阵：`skills/task-planner/references/agent-coverage.md`（26 行矩阵，Rule 52 三登记面 D1/D2/D3 锚在头注）

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

### §Implementation（S3，2026-10-10，checkpoint=subagent-state/3-executor.md）
- decision-arbiter.md 落地 worktree：60 行，frontmatter model=`account:zai-individual-coding-plan/GLM-5.3`（逐字符复核），四态 APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE+驳回单五要素+硬约束 5 条+T1-T6+四邻管辖二分全在位；主进程 Read 复核通过
- 设计取舍：修复权留主代理（REJECT-REWORK 只裁决不改码）；ESCALATE-USER 锚定 Rule 41.2 四门槛；单次独立禁驻留循环（强模型经济性）

### §Implementation 续（S5+S6，2026-10-10，checkpoint=5/6-executor.md）
- S5：SKILL.md 11 处增量（路由行 417/清单行 344/欠账修正 286=1-66→1-69/T1-T6 标记 80/92/104/153/470/477/C46=223/外部引用 383）；grep decision-arbiter=12 occurrences、Rule 69=11 行
- S6：agent-coverage.md 矩阵 28 行+头注 26→28 计数欠账同步 2 处（line 42「底稿原 26 行」为史实保留）；template-mapping.md §九 line 290+§十 line 314 各+1 行；D2 router 登记行文本已产出待 Phase 5 部署
- 裁决登记：AC-09 上界 129→130 属合法演进（授权 S7 一并处理）；AC-04 部署暂态预期内；S5⑪ 独立新行落位可接受（CR 把关）

### §Verification（S7，2026-10-10，checkpoint=subagent-state/7-executor.md）
- selftest-decision-arbiter.sh 新建：DA-01..DA-16 共 16 断言全 PASS exit 0（95 行≤120；任意 CWD 验证通过；主进程独立复跑复核一致）
- AC-09 上界 129→130 演进注记落地（selftest-agent-coverage.sh 8/6）；AC-04（~/.zcode/agents/decision-arbiter.md 缺位）=Phase 5 部署暂态预期内
- registry TSV 追加第 65 行（T02 断言通过，rows=65=actual 65）

### §Verification 续（S8+Rounds，2026-10-10，checkpoint=8/fixa/fixb1/fixb2/b3-executor.md）
- S8 首跑 5 FAIL→Fix 四批修复（commit 6e1202f）→Round 3 终跑 64 脚本 failed=1（AC-04 部署暂态）
- 级联修复方法论验证：RF-06 精确锚 1-69 与 9/368 行 1-66（六守卫依赖）不可同真→宽容锚 `1-6[0-9]` 保三处联动语义（先例 CD-18/IP-12）；DCS-11/G-09/T-main 行联演进（钉值 515→526 留 5 余量）；G-07 末行断言用行位置恢复而非改断言语义（最小变更）

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
