# task-v131 交付总结 — 技能行为缺陷根源修复

**交付结论：COMPLETE**（2026-10-05；merge 17a06cf + 簿记提交；终态回归 51 脚本 PASS=770 FAIL=0 主进程求和）

## 一、任务说明
从根源修复 task-planner 四大行为缺陷（用户 /goal 原文锚定 R1-R7）：①解决问题流于表面不挖根源 ②执行偏差/指令改写（一个月→72h 判例）③把可自行判断的低风险决策恶意推给用户（惰性）④速度优先于质量导致返工。同步清账对齐审计 13 发现与 zcode 部署位领先内容回填，四位部署位对账 IDENTICAL。

## 二、产出清单（全部绝对路径，对象+看点）
- **Rule 53「根源解决与决策管辖」五子条**：/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:580-586 — 53.1 结果级需求全链工序审计（含用户 R5 原话判例反例）/53.2 根治判据（机制·守卫·载体三选一防复发）/53.3 决策管辖二分（41.2 四门槛唯一权威边界，反推诿 Q7）/53.4 返工成本核算（三元组量化，Q8）/53.5 机制零新键
- **Rule 51.1a 载体双机制**：同文件 :560 + scripts/init-session.sh（生成面注入：任何模板生成计划必含「🎯 用户需求原文」+「🧮 根源覆盖表」双区块，mini 豁免，fail-open，幂等）+ scripts/attest-plan.sh（锁定面四锚 fail-closed 硬门：标题/R 行/R→VC 映射/根源覆盖表，缺一拒锁）
- **派发需求锚**：skills/task-planner/templates/subagent_dispatch.md — 子代理 prompt 逐字引用治理 R 条目（直击一个月→72h 转译变异路径）+ scripts/check-dispatch.sh advisory 提醒（warn fail-open）
- **SKILL 联动**：skills/task-planner/SKILL.md（477 行；:9 全集 1-53/:204 C36/:266 索引 40-53 全集/:306 Rule 53 bullet/:86 Rule 52.1 括注）
- **新守卫**：scripts/selftest-root-resolution.sh（RR-01..17，17 用例）+ registry 登记（51 脚本）+ 级联锚演进（skill-split 477/RC-15 ^54/AC-09 -le/R-09/SR-08）
- **审计 13 发现全处置**：plans/task-v131/findings.md §审计处置表（3H+5M+5L 逐条证据）
- **回填**：task-v130「并行创作组」内容（SKILL 461→475/critical-rules 567→574）回真源 commit 92cab23
- **部署**：四位（~/.zcode ~/.claude ~/.config/opencode ~/.cursor 的 skills/task-planner）与真源 diff=0；备份 ~/skill-deploy-backups-v131-20261005-102841/（2.5MB）

## 三、审查详细信息
- Code Review（code-reviewer 两轮）：首轮 CHANGES_REQUESTED（P1×2+P2×4）→ 修复（P1-1 awk 重写+P1-1b 连带发现/P1-2 索引行/三 P2）→ 复审 **APPROVED**（独立回归求和 770/0 与主进程一致）。plans/task-v131/subagent-state/26-code-reviewer.md
- critic 条款挑刺（10 发现：P0×1+P1×5）全部当轮吸收（53.3「或」字自设第五出口=结构性推诿漏洞已收口）。subagent-state/10-critic.md
- alignment-review（9 清单实跑）：**APPROVED** P0=0 P1=0。subagent-state/30-executor.md
- 全量回归：51 脚本 PASS=770 FAIL=0（三轮：768/0→CR 修复后 770/2→级联锚演进后 770/0；求和口径=主进程逐脚本 Total 行）
- 委派统计：29 个子代理 S-unit（executor×24+critic+code-reviewer+改派 1+CR 复审续作 1+对齐 1），主进程直做=计划文件/git 编排/部署/簿记（白名单①②③全登记）

## 四、风险点（必须列举）
1. **行为面未实测**：Rule 53/51.1a 的新纪律是条款+机器锚级守护（生成/锁定/派发三层），但「LLM 实际执行时是否遵守管辖二分/全链审计」需真实任务行为验证（判例：媒体 agent 冒烟由 v130 单独承担）——建议下一个真实任务观察 C36 核查记录
2. **指令篡改取证在途**：dwfrun-6311f12f 孤儿态（两子代理停提问，属主会话已死）；结构根因已修但取证报告未出——接管路径=AmendWorkflow（缓存 1 已结算步骤）
3. **2 项无实害 Nit**（CR 复审）：R→VC 标题锚不认 #### 级标题（模板族全用 ###）；YAML frontmatter+无 Goal 插入点=第 2 行（39 模板全用 HTML 注释）——登记不阻塞
4. **install-stub/README heredoc 内「薄壳」生成物串残留**（alignment P2）：属脚本命名历史语境，改动引入部署噪声>收益，登记豁免
5. **四锚门对存量在途计划**：只影响新锁定（锁定时点校验）；mini 档豁免防误伤
6. 媒体凭证 401 的 automation-13c74ca0 计划任务（v130 遗留）与本任务无关，仍在待凭证状态

## 五、下一步建议（对象+看点+动作）
1. 行为冒烟：新会话创建任意计划 → 看 init 是否注入双区块+attest 四锚门表现（对象=plans/<新任务>/task_plan.md；动作=正常走 task-planner 流程）
2. 指令篡改取证接管：AmendWorkflow run dwfrun-6311f12f（脚本在 .zcode/workflow-drafts/指令篡改事故调查一个月72小时-2.dwf.ts）——产出事故报告入 plans/incident-reports/
3. 宪法 §一同步（若用户认可 53.3 管辖二分口径）：~/.zcode/AGENTS.md §四选项呈现规范可引用 Rule 53.3（对象=宪法文件；需用户显式授权）
4. Rule 53 消费侧观察：首次真实使用后按 Rule 33 反思循环回填 notepad（对象=plans/task-v131/notepad-learnings.md）

## 📋 需求覆盖核对表（Rule 51.3）
| R | 需求原文（缩引） | 覆盖 | 证据 |
|---|----------------|------|------|
| R1 | 从根源彻底解决、直指核心 | **covered** | 53.1+53.2 条款锚（critical-rules:580-583）+根因表（task_plan 核心问题定义）+RR-01..05 守护 |
| R2 | 解决问题存在严重偏差 | **covered** | 51.1a 载体双机制（init 注入+attest 四锚门 fail-closed）+派发需求锚+check-dispatch advisory；VC-2/3 负例实证 |
| R3 | 恶意将低风险选择推给用户=惰性 | **covered** | 53.3 决策管辖二分（41.2 唯一边界+Q7 触发面挂 26.3 惩罚）+critic P0 收口 |
| R4 | 所有问题从根源解决而非只基础 | **covered** | 审计 13 发现 3H+5M+5L 全处置（findings §审计处置表）+Rule 53 全条款+回归清账 12 脚本夹具 |
| R5 | 「确保内容质量」只修标题的反例 | **covered** | 53.1 判例反例逐字入条款（用户原话锚定）+根源覆盖表载体（模板区块+init 注入+attest 第 4 锚） |
| R6 | 产出质量>速度；返工比慢彻更无效 | **covered** | 53.4 返工成本核算（三元组量化口径）+本任务实证（critic 循环+CR 两轮+级联锚三修全在本轮完成而非留返工）；VC-5 三轮回归 |
| R7 | 易判断内容恶意推给用户（R3 重申） | **covered** | 同 R3；本任务全程 silent 模式 29 项代理裁决零推诿（Decisions Made 全登记） |

（无 uncovered/partial 项；无声明的需求缩水）
