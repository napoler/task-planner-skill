# 执行规范召回卡（execution-recall-card）
> **性质**：非权威摘要——一行级蒸馏+规则编号锚。权威原文=各 `critical-rules-*.md`（核心域=../../task-planner/references/critical-rules.md），冲突以原文为准；卡内禁新增规则正文（Rule 82 防镜像）。
> **用法**：Rule 93.2——每完成 3 个 S-unit 或 Phase 翻转 complete，主进程亲自 Read 本卡，progress.md 留 `[recall]` 行；Rule 93.3——compaction 恢复/会话恢复/[assess]≥PRESSURE 后第一动作先读本卡。
> **维护**：规则 landing/修订任务触及本卡已收条目时同步更新该行（Rule 93.1 同步义务）；本卡 ≤120 行。

## A. 执行红线（高频违规）
- 完成声称三条件：执行证据+产出证据+验证证据缺一不可；未实测禁声称完成；禁裸 COMPLETE（Rule 51.8/26.3；Q3 证据不实=BLOCKED）
- 对外声称可回溯第一手证据：就绪不越界、阻塞不连带、推迟必举证（Rule 54）
- 结论必带锚：file:line 或命令输出；无锚结论标「未验证」（Rule 54.5/71 无源不写）
- 需求原文逐字锚：R 行禁转译/缩写/合并；纠正=追加新 R 行禁改旧行（Rule 51.1/51.7）
- 自缩水禁令：挂起/降级/暂不类处置须用户确认，禁自报完成（Rule 51.4）

## B. 变更与范围
- 三判门：增量默认/替代四条件/删除须逐项授权；未三判写入=P0（Rule 74.2）
- 射程契约：动作域+呈报域收敛到指令点名内容域；每行 diff 可追溯用户请求（Rule 88）
- 精准改动：最小最可验证改动；不顺手改无关代码；匹配既有风格（Rule 87）
- 注释：What+Why 双层；修改注明原因/时间/原行为；禁为美观删注释（Rule 45）
- 技能/指令文件=保护区：先归因再动刀、默认纯增量、删除须授权（Rule 36）
- 文件尺寸：产出前评估体量，优先沿内聚边界拆分（Rule 92）

## C. 落盘与推进
- 四文件=Disk：结论禁只留会话记忆；子代理返回后紧邻回填 findings（Rule 19.1/62.1）
- 翻转门控：Phase complete 前 progress 回填+findings 增量（check-3file-gate exit 0）+V-N 实跑全 PASS（Rule 19.2/84.3）
- goal 驱动：逐 goal「验证实跑+[goal:Gn] 证据行」才翻格；禁跨 goal 连做（Rule 66.3/46.1）
- 测试轮次即时落盘；错误立即 Error Log+四问归因，未完禁下一动作（Rule 57/19.4/31.2）
- 编号预留：新 Rule 先 rule-reserve 声明预留，合并后 land（Rule 20.6）
- 逐 Phase commit：只 add scope 文件，禁 git add -A（Rule 27）

## D. 派发与委派
- 委派优先：Executor≠主进程即派发；主进程只编排/回填/验收 Read（Rule 25）
- prompt 自包含+检查点：绝对路径+验收标准+checkpoint 路径；产出必须 Read 复核（Rule 22.4/22.8）
- 契约不可收窄：禁「只写检查点」类措辞收窄 findings 自写义务（Rule 62.2）
- 并行四问：文件集/资源/输入/验收任一相关→串行；并行须声明 parallel_groups（Rule 21.4）
- 单任务专注：单会话单 S-unit，禁批次连做（Rule 46.1）
- 同法失败 ≥2 次强制换道：改派→拆细→降档→接管（Rule 22.3）

## E. 上下文与节奏
- 规范召回：每 3 个 S-unit/Phase 翻转主进程 Read 本卡留 [recall]；压缩/恢复/PRESSURE 后第一动作（Rule 93）
- 专注隔离：目标重大偏差（A→B）不就地吸收——主动询问拆分新 Task Plan，单计划单垂直域防污染（Rule 94）
- 执行优先：零报错+有直推路径=禁停等——额度不可查询即执行探测；按日重置额度禁空置；质检处置自主化；暂停前三问（Rule 95）
- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）
- 上下文压力：[assess] 三态；PRESSURE→主动压缩；CONFUSED→session-handoff 转新会话（Rule 67）
- 恢复读序：user-session-log→task_plan→progress→findings→knowledge-brief（Rule 19.3/80.4/62.1）
- 上下文卫生：每 2 Phase 跑 check-context-hygiene（Rule 29）

## F. 决策与呈报
- 判断类问题（方案终裁/失败定级/验收争议/CR 分歧）→ decision-arbiter 独立裁决，禁硬决（Rule 69.1）
- 呈报四要素：对象路径+看点+动作+结论，禁模糊呈报（Rule 70.2）
- 决策分级：A 级变更必呈报；琐碎禁上抛；可测问题禁问用户（Rule 72/86）
- 已确立事实禁反言：短窗口内无新证据禁结论反复横跳（Rule 89）
- 用户否决的方案禁无验证重提（Rule 32）
- 文本优先：规则类诉求=文本条款落最贴近载体；新增脚本/守护=范围扩张须显式授权（Rule 38.7）
- 通道快速失败：不可用禁 ≥2 次同法重试，给三选项（Rule 83）
