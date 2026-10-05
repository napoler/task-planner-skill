# Knowledge Brief — task-v136（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出（理由见 findings.md Technical Decisions），执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：落地 Rule 54「执行诚实性与即时执行纪律」（54.0 有依据原则总则+54.1-54.6 条款+selftest 守护+SKILL/模板/companion 联动），因果链全链分析驱动，全量 selftest 0 FAIL 后合并部署 3 位。
- 背景/动机：用户提供 EP8 会话错误示例——skill 现有条款有相邻覆盖但五缺陷面（F1-F5）各缺直接条款；用户 R4 升级=因果链分析驱动+一切声称有依据；用户 R5 扩展=决策依据数据及时落盘知识库文件并消费落盘锚。初稿分析漏 F4/F5 已入 Error Log。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| F1 代理产物冒充完成 | 准备物/中间产物（spec 文件、cron 设定）完成被表述成需求推进——「就绪」语义越界 |
| F2 未阻塞工作连带推迟 | 单资源窗口（额度）阻塞→全部工作推迟，未逐项举证哪些真的被阻塞 |
| F3 仪式性进展冒充实质进展 | 建文件/设自动化等仪式动作被包装成里程碑汇报 |
| F4 资源状态造谣 | 无第一手验证断言外部资源状态（额度耗尽/容量/可用性）——用户官方核实 EP8 声称的"额度超顶"实际不足一半；F4→F2 因果链（造谣的阻塞依据支撑连带推迟） |
| F5 决策依据数据未落盘 | 查询到的数据（额度剩余等）只存于会话表述未落盘知识库文件——事后不可审计，是 F4 造谣的前置使能条件（用户 R5 指令登记） |
| 有依据原则（54.0） | 一切对外声称（状态/资源/阻塞/里程碑/完成/统计）必须可回溯第一手证据（时间戳+来源），无依据声称=造谣禁令——43.1 的汇报域收窄补位 |
| 决策依据落盘（54.5） | 查询/核实数据及时落盘 findings.md 结论段+knowledge-brief §2（带时间戳+来源锚）；决策/汇报引用落盘锚（file#锚点），禁引用仅存会话记忆的数据——Rule 19.1 写侧义务之上的决策侧消费绑定 |
| 因果链证据表 | findings.md 专段：EP8 因果链逐节点=原文锚 T#（ep8-transcript.md）+行为定性+现行条款锚 file:line+反事实检查；无锚声称=0（VC-6） |
| 阻塞影响矩阵 | 54.2 要求的逐 S-unit/逐需求条目「阻塞/未阻塞」判定表，资源窗口类必须列精确受影响子集 |
| 推迟举证四要素 | 54.4：①阻塞证据（资源/依赖/权限+解除时点）②未阻塞子集清单③立即可执行项执行记录④恢复触发器 |
| 通用化条款 | 措辞任务类型无关（对齐 v134 普及化方向），EP8/媒体词只准出现在 notepad 案例登记，禁入条款正文 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 43.5(:459)/43.6(:460)/51.8(:573)/51.3(:568)/43.1(:455) 覆盖「未测试禁声称完成」，但无「准备物完成≠需求推进」条款（行号=2026-10-05 S0 复核值，01 检查点旧行号 +2 漂移作废） | subagent-state/03-causal-chain.md §〇 | 54.1 是 F1 的唯一新载体，禁与 51.8 语义重复（写差异面：51.8 管"测试没做"，54.1 管"测试对象搞错——准备物冒充交付物"） |
| Rule 23.10(:197)/49.2(:530)/49.3(:532) 覆盖额度冲突与 lane 推进，但无阻塞传播纪律 | 同上 | 54.2/54.4 写「阻塞影响举证」视角，禁重写 49.2 推进三条件 |
| Rule 43.6(:460) 禁未验证优点宣传，53.3(:591) 反推诿，但无仪式性动作禁令 | 同上 | 54.3 里程碑只绑定 Rule 50 原子条目状态翻转 |
| image-generation-executor.md:36 已有静默执行纪律 | companion/agents/ | companion 只加 1 行指针引用 Rule 54，禁重写既有行（双权威源漂移） |
| Rule 43.1(:453) 证据先行反幻觉枚举"已完成/正确/通过"，但资源状态声称（额度/容量/可用性）未列举 | subagent-state/01-explore-rule-coverage.md + 用户 2026-10-05 官方核实 | 54.1 加资源状态声称子句+54.2 阻塞证据含第一手查询（时间戳+来源）；禁与 43.1 语义重复（54 收窄到资源状态类高误报声称） |
| v133 最近同型交付=条款+Q/C 登记+selftest 断言；C37 已被 v133 占用 | plans/task-v133/（memory task-v133 行） | 合规行接续需执行时 grep 复核实际最大 C 号再定（防并行会话已占） |
| v134 在途（31.7 普及化，scope 含 critical-rules/SKILL）；v135 在途 | plans/task-v134/task_plan.md 头部 | 只追加不改动其区域行；合并前重读 master 基点 |
| EP8 实录档案在位（T1-T4 逐字保真+provenance+初步因果链假设标注"待验证"） | plans/task-v136/ep8-transcript.md | S0 分析唯一证据源；条款设计每节点须回锚 T# 或现行条款 file:line，假设未经 S0 验证禁入条款 |
| 新规则编号接续：Rule 53 已 landed（v131），账本无 54 占用 | plans/.rule-reservations.jsonl 尾 4 行 | new_rule: 54，attest 自动登记 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :453-470 | Rule 43.5/43.6 区域（54.1 措辞参照系，禁动） |
| skills/task-planner/references/critical-rules.md | :520-535 | Rule 49.2/49.3 区域（54.2 参照系，禁动） |
| skills/task-planner/references/critical-rules.md | Rule 53 块尾 | Rule 54 新块插入点（S1 目标锚） |
| skills/task-planner/references/critical-rules.md | :565-572 | Rule 51.3/51.5/51.8（54.1 差异化参照） |
| skills/task-planner/SKILL.md | :300-310 | Critical Rules 摘要区（Rule 54 摘要行插入点） |
| skills/task-planner/SKILL.md | 合规检查清单表 | C38 行插入点（grep 复核接续号） |
| skills/task-planner/scripts/selftest-veto.sh | 全文 | selftest 范式（S4 参照） |
| skills/task-planner/templates/delivery-summary.md | 五要素区 | +1 行「真实进展对照按 Rule 50 条目表（54.1）」 |
| skills/task-planner/companion/agents/{image,video}-generation-executor.md | :36 附近 | 静默纪律行附近 +1 指针行 |

## §4 易错点与禁止假设清单
1. 禁止条款正文出现 EP8/视频/额度数字/媒体专属措辞——通用化是硬验收（VC-1），案例原文只进 notepad-learnings 登记
2. 禁止与 51.8/43.5/49.2 语义重叠：54 各子条写「差异面」（准备物 vs 交付物、阻塞传播 vs lane 推进、仪式动作 vs 未验证宣传），交叉引用用「互补非替代」措辞
3. 锚定级联：改 SKILL.md "Rules 1-5x" 前先 `grep -rn "Rules 1-" skills/task-planner/scripts/` 全扫一次修齐（v118/v131/v132 三次教训）
4. SKILL.md 净增 ≤10 行 + wc -l 复核 + 行数上限断言上调带 v136 label（先例 ≤540 task-v074 演进链，当前值以 worktree 内实际断言为准 grep 定位）
5. executor prompt ≤3000 字符 + 三文件绝对路径 + 8 字段标签（check-dispatch 逐字校验）；任务书禁 S\d+ 跨单元引用字样（v127 三禁）
6. 全量 selftest 总数=主进程逐脚本 Total 行求和，禁采信子代理自报（VC-4 硬验收）
7. 禁触碰 plans/task-v134/、plans/task-v135/ 任何文件；worktree 内禁 git checkout/reset --hard
- FMEA RPN>100 兜底指针：锚级联断言 FAIL → 先全扫 grep 修齐断言再继续（勿回退条款）；合并冲突 → 重读 master 基点后行内追加策略解，STOP 仅当语义冲突

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S0 | §1 §2（全） | /mnt/data/dev/task-planner-skill/plans/task-v136/ep8-transcript.md + subagent-state/01-explore-rule-coverage.md |
| S1 | §1 §2 §4（1-2 条） | /mnt/data/dev/task-planner-skill/plans/task-v136/findings.md（因果链证据表段） |
| S2 | §2 §3 §4（3-4 条） | worktree SKILL.md + /mnt/data/dev/task-planner-skill/plans/task-v136/findings.md |
| S3 | §2 §4（companion 条） | worktree 模板与 companion 文件 + findings.md |
| S4 | §3 §4（6 条） | worktree scripts/selftest-veto.sh |
