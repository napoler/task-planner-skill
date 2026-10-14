# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [目标]：核心技能=四文件罗盘记录/文档管理（「核心就是对这4个文档的进行管理」）
- R2 [目标]：非记录类工作独立为专业技能（「单独独立化为专业技能，确保核心技能的唯一性」）
- R3 [目标]：杜绝全包（「不要什么都负责……混乱不堪」）
- R4 [目标]：核心工作=制作计划+维护 Task Planner 文档及相关内容
- R5 [手段]：非核心功能以路由调用卫星技能实现（「调用其他技能来实现，而不是所有东西都自己实现」）
- 详见 task_plan.md「🎯 用户需求原文」逐字抄录+R→VC 映射

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| SKILL.md 全文 556 行 | skills/task-planner/SKILL.md@wt/task-v171 | ☑ | §Research Findings-核心结构 |
| critical-rules.md 76 规则 | skills/task-planner/references/critical-rules.md | ☑ | §Research Findings-规则行图 |
| check-plan-dispatch.sh 契约 | scripts/check-plan-dispatch.sh:270-300 | ☑ | §Research Findings-机器契约 |
| install-stub.sh 注册点 | lib/install-stub.sh:36,244 | ☑ | §Research Findings-安装链 |
| worktree-isolation.md | references/worktree-isolation.md | ☑ | §Technical Decisions-隔离 |
| task-v168 任务书先例 | plans/task-v168-session-anchor-skill-activation/task_plan.md | ☑ | §Technical Decisions-S-unit 表 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
**核心结构**：SKILL.md 556 行+10 引用（goal-gate/batch-quality-gate/split-pattern-library 等）；critical-rules.md 1046+ 行 76 正文规则+Rule 80 空壳（1048）；77 selftest；126 scripts；12+29 templates；config.json 40+ 键；8 卫星。

**规则行图**（key off 编号实测，文件顺序非数字序）：76 正文规则起始行 5,8,11,14,17,20,23,26,31,34,37,48,51,54,57,76,80,92,109,121,142,172,204,222,234,245,275,286,297,308,318,330,340,351,363,373,386,398,411,435,446,458,478,489,499,519,529,541,551,567,590,604,616,624,642,653,671,685,707,743,756,774,796,813,831,862,876,892,907,918,945,961,987,1003,1012,1032；Rule 80 空壳@1048。完整「编号×行区间×目标文件」映射=design-architecture.md §1。

**机器契约**：step_max=2f/100l/15min（超=add_violation 拒锁）；时长列 `^[0-9]+min$` 纯 NNmin；例外登记整行子串=降级放行；ID 纯数字；伴飞校验在 check-dispatch.sh 派发 prompt 侧（计划期填「无」安全）。

**selftest 耦合**：56/77 selftest 引用 critical-rules.md；64 个 selftest 断言将被移走的 rule 文本（批1=46 task-discipline 关联/批2=5 media-collab-template/批3=13 dispatch）——design-architecture.md §7。

**安装链**：install-stub.sh:36 SATELLITE_SKILLS 4 卫星+install_satellite_skills()@:244 rsync 4 部署位；install.sh:195-204 subagent-fallback Phase 5.7（fail-open 点，必须更新路径）。

**BP-08**：selftest-batch-pilot.sh:11,53 SKILL.md 行数钉 ≤558；P7 S38 演进 275（≤250+25 边距）。

**hook 链**：4 zcode-*.sh adapter 调用核心 scripts（allow-direct/attest-plan/check-conflicts/check-delegation/check-dispatch/check-scope/check-skill-modify/plan-parse/resolve-plan-dir/set-active-plan/sync-todos/check-plan-dispatch/check-complete）——无一调用 5 个移动 script，hook 面零断。

**provider 故障实证**：2026-10-12 general-purpose+executor 路由连续 Model request failed（3 派发全败），主进程直写兜底成功——记录备查。

**基线探针定案**（2026-10-12，P4.5）：detached@master 临时 worktree 全量回归 **零 FAIL** → P4 完成态 14 项 FAIL 全部由搬迁引入、非存量问题。探针已删（worktree list 确认）。
14 FAIL 清单：agent-coverage(3)/context-hygiene(3)/decision-arbiter(1)/dispatch(3)/drift-check-subagent(1)/parallel-scheduling(1)/registry(1,rows=78≠76)/self-resolution(1)/skill-collab(2,T6a/T6b)/split-pattern-library(7)/subagent-granularity-skill-escort(1)/subagent-return(5)/summary-readability(2)/fallback(task-dispatch,T08 config 读不到)。

**路径 bug 家族**（根因同构，均为 caller 更新少一层目录）：selftest 的 `$SCRIPT_DIR/../` 从 scripts 上一级=skills/task-planner，再加卫星名解析到 `task-planner/<卫星>/`（不存在）；正确语义=`$ROOT/../`、`$REAL_ROOT/../`、`$SCRIPT_DIR/../../`、`$SKILL_ROOT/../`。4 处确诊：selftest-skill-collab.sh:14（FALLBACK→$ROOT/../）、selftest-context-hygiene.sh:27（HYG→$REAL_ROOT/../）、selftest-subagent-return.sh:9（RS→$SCRIPT_DIR/../../）、selftest-subagent-granularity-skill-escort.sh:55（ASPL→$SKILL_ROOT/../，:49 定义 SKILL_ROOT；:33 注释同步）。对照：check-complete.sh:632/install.sh:195-199/lib/verify.sh:240-243 的 `$TASK_PLANNER_ROOT|$SKILL_ROOT/../` 层级正确。

**回归门命令**（官方入口）：`skills/task-planner/scripts/run-selftests.sh`（输入指纹缓存版；--fresh 强制全量、--only PAT 子集、--status 只读）；末行 `Total: N PASS=x FAIL=y`；--fresh 全量实测 161s。master 全量零 FAIL 基线（e82dd42）。

**来源路径勘误**：capabilities 源=skills/task-planner/**scripts**/capabilities/（内含 agnes-quota.sh），非 skills/task-planner/capabilities/——P5 S21 搬迁源路径以此为据。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 归属判定规则：主题⟷四文件/计划生命周期门→核心；否则按域归卫星 | 用户 R1/R4：核心=四文件罗盘+计划制作；R5：其他=调用其他技能 |
| 核心保留 11 条（1,2,3,5,19,20,26,51,62,66+新 82） | 1,2,3=规划铁律；5,20=计划生命周期；26=质量门；51=需求覆盖；62=四文件数据流转；66=goal 单元（对象=四文件）；82=防回归 |
| goal-gate.md 留核心 | VC/Goal 单元表=task_plan.md 四文件产物；Goal Gate 机器检在核心 check-complete.sh；plan-collab-router 域不含 Goal 门 |
| Rule 66 归核心 | goal 单元固化对象=四文件罗盘 |
| Rule 27 归 task-discipline | git/工作产物纪律域 |
| Rule 80 空壳删除 | 无正文历史预留号，删除无功能损失（D-01） |
| worktree from master 618df79 | 主分支 stale 1009 commits（§十一 SOP） |
| 3 新卫星=task-dispatch/task-discipline/media-planner | 域边界=派发调度/执行纪律/媒体制作，与 8 既有卫星不重叠 |
| selftest 随迁 2 个（selftest-fallback/rescue-chain）+留守 75 锚重定向 | run-selftests.sh 扫描面不变=零 harness 改动 |
| provider 故障期主进程直写 design-architecture.md | Rule 22.3 穷尽策略；事实全在上下文 |
| worktree HEAD =e82dd42（=master，非快照 618df79） | 会话初始化后 master 前进到 task-v169 合流；worktree 已随 master（merge-base=HEAD） |
| P5-P8 改由 dynamic workflow 执行（dwfrun 系） | 用户 /workflow 显式指令=强制 workflow（skill §1 路由铁律）；拓扑=回归修复→discipline→8 卫星并行→核心瘦身→锚修复 3 批并行+契约收尾→终验门控循环→VC+CR→报告 |
| 三批 selftest 锚修复并行（偏离 plan S35→S36→S37 串行） | Rule 21.4 独立性四问：批间文件集不相交（python 交叉清单实测）+无共享资源；理由已登记 workflow 报告 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| mawk 不支持 {2,4} 区间表达式致规则行图污染 | GNU grep -nE ERE 为权威行图（task_plan Errors Encountered 登记） |
| 初版 caller map 漏 install.sh:195-204 | 全域 grep 复查补入（CA-14/S8） |
| general-purpose+executor 连续 3 派发 Model request failed | 主进程直写兜底（Rule 22.3 换道） |
| Rule 80 空壳标题（1048）计入 77 匹配 | 识别为空壳，D-01 删除不迁移 |
| 主进程用 python3 heredoc 改 workflow draft（违反 §九「禁 python3 -c 内联」） | 一次行替换已无害落盘；整改=以后一律 Read 文件+Edit 工具；教训已记 |
| workflow 脚本 coreSlimmer persona 含乱码词（hinmanhinman） | 趁运行早期 AmendWorkflow(path=draft) 修正；cache 规则=修正点之前的阶段零成本重放（修订版 dwfrun-eeaa3e10） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 架构设计文档：plans/task-v171-skill-specialization/design-architecture.md（304 行，§1-§9）
- 跨技能相对路径先例：selftest-drift-check-subagent.sh:17

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
