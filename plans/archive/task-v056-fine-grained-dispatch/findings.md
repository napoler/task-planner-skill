# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（09-09）：子代理一次性分配的任务过大执行过久，小模型负担过重；希望提高拆分细分度，小步快跑；计划阶段细致、后期小模型执行；子代理完全不需要大模型，只要有完整计划小模型就能执行好；小模型短上下文 vs 长上下文质量差异巨大，以此为杠杆提质量

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
### R1 拆分机制现状盘点（09-09，Explore → subagent-state/01-explore.md，主进程已 Read 复核 critical-rules.md:110-167 / 模板 / config）
1. **现行拆分约束全挂 Phase 层**：Rule 21.1 单 Phase ≤3 文件 ≤300 行（critical-rules.md:113）；Rule 22.1 单派发 ≤3 文件 ≤300 行、每 Phase 派发 ≤5 次（:121）——Phase 与单次派发上限同值 = 默认"一 Phase 一派发"，无更细步级
2. **Subtasks 二级拆分已存在但形同虚设**：Rule 22.6 触发条件"Phase 含 ≥3 子任务"（:127），模板中只是 HTML 注释示例（templates/task_plan.md:152-160），12 个 variant 全部 0 命中
3. **兜底顺序"升档优先于拆细"**：22.3 四档 = 改派→降档→接管→AskUser（:123），无"拆细"档；21.4 的"拆得更细"要等失败 ≥2 次才触发（:116）——与用户"失败先拆细不先升档"理念相反
4. **八字段模板有上下文最小化雏形**：输入 findings ≤10 行、目标 1 句、返回 ≤3 行（22.4，:125），但无 prompt 总量预算；config 无时长预估/prompt 预算键（config.json:154-220，additionalProperties:false）
5. **plan-writer 无拆步指令**：仅"3-7 Phase/>7 过细/单 Phase >3 文件禁止"（companion/agents/plan-writer.md，model=sonnet-1）
6. Rule 21 已宣告"小步快跑"理念（:110-111 大模型拆分/小模型执行）——**理念在、步级机制缺**，本次优化 = 机制补全而非理念新增

### R2 Phase 3 规则落地结论（09-09，3 个 executor S-unit 串行，worktree commit 3164591）
- 落地位置（worktree critical-rules.md）：21.1b@114 步级上限 / 21.4@117 首败评估 / 22.3@124 拆细=② / 22.3.1@125 编号 ④⑤ / 22.4@126 九字段 / 22.6@128 S-unit 必填 / 25.1@163 / 25.2@164
- **编号联动发现**：22.3 插档后旧"③/④"引用只在 22.3.1 一处（已同步）；文件内"八字段"另有 81/180 两处属 Batch Report（Rule 18），不得误改——**Phase 5 改 SKILL.md 时同样要区分派发八字段 vs Batch 八字段，且 SKILL.md「四档兜底」表需改为五档**
- 小步快跑实测：3 步各 52s/57s/111s、6-8 次工具调用、每步 ≤3 行改动，sonnet-1 零追问一次通过；主进程每步 Read 复核 ≤10 行——验证了"计划期给全 old→new 精确指令 → 执行期照单"的可行性

### R3 Phase 4 落地 + dogfooding 发现（09-09，worktree commit 61a0238）
- config.json subagent.default 现为 9 键（5 原 + 4 步级）；派发模板 §9@71；task_plan 模板 S-unit 表@174-177 可见
- **规则缺口（本任务自身执行中发现）**：Phase 4 三个 S-unit 改 3 个不同文件、互不依赖，按宪法 §一 并行派发（3 个 executor 同时跑，墙钟 ≈217s 而非串行 ≈533s）。但 Phase 3 写入的 25.2 措辞"串行验收后再派下一行"字面上禁止这种并行 → **需在 25.2 补例外句**：有依赖/同文件的 S-unit 串行；互不依赖（不同文件、无输入引用）的 S-unit 可并行派发，但每个仍须独立 Read 复核 + 独立 Handoff 行。纳入 Phase 5 S3（critical-rules.md 单行改，≤5min）
- 并行派发的上下文成本观察：3 个子代理各自 95K-126K token（sonnet-1 读文件 + 自检），主进程只消费 3 条 ≤3 行返回 + 1 次 sed 复核——主上下文增量 <2K token，符合"主进程=调度器"定位

### R4 Phase 5 落地（09-09，worktree commit 50450ea）— 实现改动全部完成
- SKILL.md 落到 **500 行**（VC-6 边界值，v055 惯例 ≤500）；后续任何 SKILL.md 增行必须等量删行——记入 notepad 供未来任务参考
- 兜底表现为五档：改派 → **拆细** → 降档 → 接管 → AskUser；降档描述已删除与新理念矛盾的"短上下文失败→升 opus"（短上下文失败的正确动作是拆细）
- verify.sh 实际路径 `lib/verify.sh`（计划 scope 原写 scripts/verify.sh，本任务未触碰该文件；scope 表已修正为 lib/ 路径供 Phase 6 引用）；它检查字节数/硬编码路径等，不检查行数与 P0 计数
- 五个 Phase（3/4/5）实现改动累计：6 文件、3 次 worktree 提交、9 个 executor S-unit（3 串行 + 6 并行），全部一次通过、零改派零降档——本任务自身即"计划做细 + 小模型照单执行"的 dogfooding 样本

### R5 Phase 6 验证结论（09-09）
- selftest-delegation 35/35、selftest-fallback 21/21、jq 合法、init-session 模板流通（新 S-unit 表被正确复制进新计划）全过
- verify.sh 22 pass / 3 fail，3 fail 全为 `deploy drift: full-copy SKILL.md differs from canonical`（claude/zcode/opencode 三副本）= 未部署前的预期状态，非本次改动回归；Phase 7 部署后复跑应 25/0
- **子代理观察**：code-runner-agent（mini 档）跑 6 条命令耗 738K token / 28 次调用，远高于同批 executor（70K-200K）——mini 运行器把每条命令的完整输出回显进自己上下文并反复自检；后续派运行类任务应在 prompt 里强制 `| tail -N` 截断并要求"只记汇总行"（本次 prompt 已给 tail 但它仍多次重跑）。可作为下一轮优化点（不在本任务范围）
- 验收标准撰写教训：grep -c 是行数不是出现次数，写"≥N 次"类判据应用 `grep -o | wc -l`

### R6 Phase 7 部署发现（09-09，merge 2d3c017）
- **plan-writer agent 副本不在"9 位"部署拓扑内且此前已漂移**：~/.zcode/agents/plan-writer.md 停在 09-03 旧版（缺 v052/v055 加的 Executor 字段/Rule 25.1 禁止项/subagent_dispatch_hint），~/.claude/agents 版本较新但仍旧一版字段数。本次一并对齐到 master（zcode 逐字节；claude 保留平台 model 适配 `sonnet`）。**部署拓扑记忆应补充这 2 个 agent 副本位**
- **install-companion.sh 目标发现风险**：`--target ~/.zcode` 会把 plan-resume 技能（7 文件）新装进 ~/.zcode/skills/——而 ZCode 当前从 ~/.agents/skills/plan-resume 加载；按资源发现顺序（~/.zcode/skills 先于 ~/.agents/skills）新装副本将遮蔽原副本。本次未运行，改定向更新；建议后续立项核查该脚本的"companion skills 分发范围"是否应排除已在 ~/.agents 存在的技能
- 部署后 verify.sh 25/0 ×3 印证 Phase 6 的 3 fail 确为部署前 drift

### R7 终验发现 P1 缺陷：check-complete.sh 委派率门控比较反转（09-09，scope 外，未修）
- 位置：`skills/task-planner/scripts/check-complete.sh` ~L402 `if ! awk -v r=... -v f=... 'BEGIN{exit !(r+0 < f+0)}'; then rate_ok=0`；引入提交 4420c08（task-v055 Phase 3-4）；canonical + 3 部署位同款
- 实证（三组）：rate=0.714/floor=0.7 → FAIL（期望 PASS）；rate=0.5 → PASS（期望 FAIL）；rate=1.0 → FAIL（期望 PASS）——**达标判失败、不达标判通过**，与 Rule 25.4 意图完全相反
- 影响：任何委派率 ≥0.7 的合规计划在 check-complete.sh 都得 exit 1（stderr 打 "DELEGATION GATE FAILED" 但 verdict=ok）；委派率不达标的计划反而放行。本任务 7/7 complete、porcelain clean、verdict ok、rate 0.714 全部实质通过，exit 1 纯由此 bug 造成
- 修法（待授权，1 行）：`exit !(r+0 < f+0)` → `exit (r+0 < f+0)`（awk 在 r<f 时 exit 1 → `! awk` 真 → rate_ok=0；r≥f 时 exit 0 → rate_ok 保持 1）。须走 worktree + 3 位重部署 + selftest 复跑；建议补一条 selftest 用例覆盖 rate≥floor 与 rate<floor 两侧
- 为何 v055 交付时未暴露：v055 终验若也 exit 1 则应有记录；未核查，不推测

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
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
