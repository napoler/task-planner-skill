# 1-rule-mapper — 子代理激活/并行推进/委派条款承载面勘察（只读映射）

- status: done
- date: 2026-10-24
- 勘察范围：master @886f060（worktree wt/task-subagent-boost-20261023 同 commit、status 干净，行号两侧通用）
- 关键架构事实：task-v171 分层后，Rule 21/22/23/25/46/52/59/68 全文**不在** task-planner 核心 `references/critical-rules.md`（核心仅 14 条），权威全文在卫星 `skills/task-dispatch/references/critical-rules-dispatch.md`（核心路由锚 critical-rules.md:193）。任务书所述 `skills/task-planner/critical-rules.md` 路径不存在，实读 `skills/task-planner/references/critical-rules.md`（203 行）+ 卫星文件（185 行）。

## 一、承载表（carriers，全部 file:line 实读核实）

### 委派/激活面
- Rule 13 子代理隔离强制（强制类别窄列：调研/搜索/大文件读取/跨文件 Read）— task-dispatch/references/critical-rules-dispatch.md:10-11
- Rule 14 代码编辑必须派子代理（含 trivial ≤3 行/mini ≤30 行豁免）— dispatch.md:13-14
- Rule 21 子任务拆分与模型分工（header）— dispatch.md:17；21.1b 步级三值上限 :21；21.3 执行一律低档模型（机械型 haiku-1/判断型 sonnet-1）:24
- Rule 22 派发契约：22.4 九字段 :58；22.4a 三文件读写契约 :59；22.4b 8 字段返回 :60；22.4c PreToolUse hook 守卫 :62；22.6 S-unit 派发单元表（计划期必填）:64；22.8 检查点协议 :67-73
- Rule 25 委派门控（header 目标=主进程调度器）— dispatch.md:100-101；25.1 Executor 字段强制+check-plan-dispatch attest 拒锁 :103；25.2 执行期委派检查点「逐 S-unit 派发+禁先自己干再派」:104；25.3 白名单六项例外 :105；25.4 终验委派率 ≥delegation_rate_floor(0.7) :106；25.4a 白名单机械豁免 :107
- Rule 46 单会话单 S-unit（批次禁令）:116；46.6 单子代理生产单元上限表 :122-130
- Rule 52 执行体专业化优先（52.1 选型先查 agent-coverage.md 矩阵）:137-143
- Rule 59 粒度三值 enforce 硬门 :152；伴飞技能 :154；执行前技能扫描 :156；能力预防（超档拆细不升档）:158
- SKILL.md（task-planner）: 步骤 2.5 委派检查点「逐 S-unit 派发」:80；2.5b 技能激活 :81；委派率统计+L0-E 权重 0 :117；G3 合规行 :149；L0-E 纯执行档 :187；派发纪律指针 :241-244；attest 内置 check-plan-dispatch 拒锁 :56
- 模型分档真源：dispatch.md:24（21.3）+ skills/task-dispatch/references/agent-coverage.md:5（52.1 选型顺序，haiku-1/sonnet-1 锚 :37,:39,:57-58）

### 并行推进面
- Rule 21.4 调度铁律（并行默认+独立性四问+声明制）— dispatch.md:25-32；**「未声明者默认串行——守卫按串行槽拦截」:27**；串行保留场景五枚举 :28；验收纪律 :29；机器守护（check-dispatch.sh）:31；21.4.1 创作组声明面 :33；21.4.2 parallel-uplift 执行期扩组四步 :34
- Rule 23 并行任务检测（23.9-23.13 创作组/Lane/RefSet）— dispatch.md:93-97；**23.13 如实披露：serial_slot_check 单一全局锁、不区分组名、不做四问机器校验 :97**
- Rule 68 计划期依赖分析/并行分组 — 68.1 依赖分析+「前置依赖」列 :173；**68.2 分组推导+惰性全串行论证义务（S-unit≥3 且零声明须 attest 前登记论证；机器 WARN=opt-in「本条不新建机器门」）:175**；68.3 组内异构分摊 :177；68.4 组域写隔离 :179；68.5 fan-out playbook（先收窄/唯一 join/结果即落盘）:181；68.6 hard/advisory 守卫 :183；68.7 机制 :185
- SKILL.md: Chain fan-out 指针 :237；卫星路由行 :195
- 核心文件联动：Q5 委派率→25.4（critical-rules.md:63）；66.4 调度=Rule 21.4（critical-rules.md:133）；Rule 82 卫星路由锚（critical-rules.md:193）

### 机器面（脚本）
- check-plan-dispatch.sh：parallel_groups frontmatter 解析 :439-441；**「模板无『并行组』列，真实计划以注解形态承载」:425**；`[parallel-group:X] = ID列表` 注解解析 :503,:519-529；H3 组标记存在性 hard :618-622
- check-dispatch.sh：组标记双条件放行（plan frontmatter ∧ prompt 标记）:312-314,:327-329；serial_slot_check 单一全局锁 `.dispatch-inflight` :634,:642-665（锁文件 :646）
- config.json：delegation_rate_floor :36；dispatch_contract_enforce :61；subagent 上限键值（max_per_phase=5/step_max_files=2/step_max_lines=100/step_max_minutes=15/step_max_steps=4/prompt_max_chars=3000）:496-504

### 台账（编号预留，实读核实）
- plans/.rule-reservations.jsonl 尾两行：`{"rule":95,"status":"reserved","task_id":"task-nopause-execfirst-20261023","ts":"2026-10-23"}` + `{"rule":96,"status":"reserved","task_id":"task-subagent-boost-20261023","ts":"2026-10-24"}` —— 与共享背景一致：96 已预留可用，95 被占用禁用

## 二、机制缺口（对照用户两点诉求）

**诉求① 激活率低：**
- G1 无「任务类别→默认派发子代理」正清单：Rule 13 强制类别仅 调研/搜索/大文件读取/跨文件 Read（dispatch.md:11）；计划制定/方案分析设计类无默认派发条款；主进程直做出口=25.3 白名单六项（dispatch.md:105），②计划系统文件维护/①git 编排/③机械验证覆盖面宽；且 25.4 只统计 **Phase 级**占比（dispatch.md:106），无 S-unit/类别级激活率度量。
- G2 复杂度→模型档位无计划期正向判定：21.3 仅两档缺省（机械 haiku-1/判断 sonnet-1，dispatch.md:24）；升档只出现在失败后兜底 22.3③（dispatch.md:53）；59.4 超档只拆细不升档（dispatch.md:158）——无「按预估复杂度选大/小模型」的缺省档判据。
- G3 陈旧锚：Rule 13（dispatch.md:11）与 task_plan.md 模板注释（:270）引用的「SKILL.md §子代理路由与模型分级」在现行两 SKILL.md **零命中**（grep 实证，task-v171 分层后失锚）；选型真源实为 agent-coverage.md:5——起草者加激活矩阵时不可锚死节名。

**诉求② 并行推进率低：**
- G4 默认串行+惰性论证无机器门：声明制「未声明者默认串行」（dispatch.md:27）；68.2 惰性全串行论证机器面=opt-in WARN、自认「本条不新建机器门」（dispatch.md:175）——全串行计划无论证仍可过 attest（仅人工核查）。
- G5 无「同消息并发派发」执行期硬条款：21.4 语义止于「组内可并行」；25.2「逐 S-unit 派发」（dispatch.md:104）与 SKILL.md:80 步骤 2.5「逐 S-unit 派发」均为串行倾向措辞；68.5 playbook 无派发动作形态规定——实践中开 1 个并行子代理不违任何现行条款。
- G6 声明面载体缺位：通用 task_plan.md 模板 frontmatter（:6-8）无 `parallel_groups:` 键、S-unit 表头（:328）无「并行组」列——check-plan-dispatch.sh:425 自认「模板无并行组列，注解形态承载」；声明全靠计划者自觉加注解行。
- G7 无并行宽度度量面：委派统计区块（task_plan.md:483-493）只数 Phase 占比；Handoff 表（:505）无组标记列；serial_slot_check 单一全局锁不分組名（check-dispatch.sh:646；23.13 dispatch.md:97 如实披露）——运行态与终验均无「并行组数/组宽/并发派发数」数据面。
- G8 parallel-uplift（21.4.2，dispatch.md:34）执行期扩组协议仅存规则文本，无 SKILL.md 执行循环/模板消费锚。

## 三、模板路径（起草者要改的承载面；实现须落 worktree 同路径，禁 commit）
- subagent_dispatch 模板：/mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md（worktree: /mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/templates/subagent_dispatch.md）
- task_plan 模板：/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md（worktree 同理）
- 规则全文：/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md（仓内唯一源；无第二部署副本，find 实证排除 .backup）
- 注意：~/.zcode/ 运行时部署位不在本仓，属 install/sync 范畴，非本任务改写面

## 四、全量 selftest 跑法
- **有聚合 runner**：`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh`（枚举 92 个 selftest-*.sh，指纹缓存复用；用法见该脚本 :30-33：`--fresh` 全量重跑 / `--only PAT` 子集 / `--status` 只读）
- 实测：`run-selftests.sh --status` → 输出 `fingerprint=6fb44c66beb1a37ff0efcbf262fe759cadccf89e22464b5c79a3ff281d0368cc cache_dir=/home/terry/.cache/task-planner-selftest`（本次只读勘察未跑全量套件）
- selftest 计数：`ls skills/task-planner/scripts/selftest-*.sh | wc -l` = 92
- worktree 内验证用 worktree 副本路径跑（脚本按 SKILL_ROOT 自定位）

## 最终结论
见上四节；已按 schema 回传 carriers/gaps/templatePaths/suiteCommand。
