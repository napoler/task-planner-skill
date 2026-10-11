# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [目标] 继续优化 task-planner 的任务拆分能力（终验裁决=58.5 三态）
- R2 [手段] 集成池内已有 skill 的拆分实践（吸收式集成，不重复造轮子）
- R3 [约束] 拆分细致更利于解决问题——落为 21.6.2/21.6.3 定性判据
- /goal 锚定（2026-10-08）：低质量模型执行也要取得明确效果；执行时必有明确目标与方案；简单高效——设计契约硬约束=模式须声明对低档模型执行明确性的贡献；任务书双明确（目标+方案）为必选模式
- R4 [截断] 「还有就是拆分非」语义不完整，交付时呈报请求澄清，不扩范围

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| writing-plans | /home/terry/.zcode/skills/writing-plans/SKILL.md（176 行） | ☑ Explore 盘点 | §R2 对标面 P1/P2/P4/P9 |
| subagent-driven-development | /home/terry/.agents/skills/subagent-driven-development/SKILL.md（419 行） | ☑ | §R2 对标面 P10 |
| dispatching-parallel-agents | /home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md（186 行） | ☑ | §R2 对标面 P5/P6 |
| brainstorming | /home/terry/.zcode/skills/brainstorming/SKILL.md（161 行） | ☑ | §R2 对标面 P3/P9 |
| sub-agent-protocol | /home/terry/.zcode/skills/sub-agent-protocol/SKILL.md（204 行） | ☑ | §R2 对标面 P7/P8 |
| task-drift-guard / skill-handoff / skill-skill-tool | 各自 SKILL.md（86/116/125 行） | ☑ | §未吸收登记（管辖二分） |
| 本体 Rule 21 区段 | skills/task-planner/references/critical-rules.md:142-159 | ☑ 主进程 Read | §R1 自身面 |

## Research Findings

### §R2 对标面（Explore#1，2026-10-08，22 技能扫描→8 高价值源）
- **P1 任务边界三判据**（writing-plans §Task Right-Sizing + brainstorming §Design for isolation）：S-unit 边界=独立可测试+评审者可独立否决；单元边界=独立理解+独立测试+接口清晰
- **P2 Bite-Sized 步级粒度**（writing-plans §Bite-Sized Task Granularity）：每步 2-5 分钟一个动作（写失败测试/跑/实现/验证/提交）
- **P3 子系统拆分法**（brainstorming §Understanding the idea）：多独立子系统→各自 spec→plan→impl
- **P4 No-Placeholder 双明确**（writing-plans §No Placeholders + /goal 锚定）：禁 TBD/占位符；执行者无需追问即知目标+方案+验收
- **P5 独立性判定法**（dispatching-parallel-agents §Identify Independent Domains）：多任务按根因分组，独立域才并行——拆分期域划分，与 21.4 派发期四问互补
- **P6 派发 Prompt 四要素**（dispatching-parallel-agents §Agent Prompt Structure）：Focused/Self-contained/Specific output/Constraints——映射 22.4 九字段
- **P7 嵌套≤2 层+超时档位**（sub-agent-protocol）：嵌套硬限；搜索/编辑 ≤600s、构建/测试 ≤1200s
- **P8 简单任务禁 spawn**（sub-agent-protocol）：≤60s 可完成→主进程直做——衔接 Rule 38.7 L0 通道
- **P9 Spec 自审四查**（brainstorming §Spec Self-Review）：占位符/一致性/范围/歧义——挂 21.5 拆分自检
- **P10 拆细先于升档+模型四档**（subagent-driven-development §Model Selection + 本体 22.3）：库内收编为索引条目，标注「本体已有」防重复定义
- **未吸收登记（53.3 管辖二分）**：task-drift-guard 量化漂移阈值（5%/20%）→ 执行期漂移检测归 Rule 61/64 管辖；skill-handoff Skill() 降级协议 → 派发容错面，以伴飞候选承载不入模式；executing-plans/workflow-gate/todo-skill 等 → 本体已有更完整机制

### §R1 自身面（Explore#2，master 21f7e6b）
- critical-rules.md 共 800 行；Rule 21 区段 :142-159（21.1:145 / 21.1b:146 / 21.2:147 / 21.2.1:148 / 21.3:149 / 21.4:150-158 / 21.5:159）；`### 22` 起于 :160；Rule 64 为末条（794 行止）
- 拆分判定现状=纯数值：21.1b 步级 ≤2f/100l/15min + 59.1 粒度三值硬门 + analyze-splits.sh（198 行，59.6 机器面）——**缺定性判据层（「拆得对」）**
- SKILL.md 锚点：委派检查点 2.5 在 :86；C43 在 :213；Rule 59 注释 :265；Rule 21 摘要 :287；Rule 59 摘要 :322
- check-plan-dispatch.sh 粒度三值校验 :274-301（$8 列）；templates/subagent_dispatch.md 85 行（§1 目标:15/§2 输入:22/伴飞:34/kb 包:39/§3 验收:47/§4 Scope:50/§5 路径:53/§6 时长:56/§7 返回:59/§8 checkpoint:76/§9 预算:82）
- selftest 相关先例：selftest-dispatch-grain.sh / selftest-plan-dispatch.sh / selftest-subagent-granularity-skill-escort.sh / selftest-skill-split.sh / selftest-media-dispatch.sh

### §约束面
- plans/.rule-reservations.jsonl：59/60/61/62/63/64/65 已占（65=task-v149 预留未 land）→ 本任务走 Rule 21.6 子条扩展，零新顶层 Rule
- v149 worktree 在飞：`/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit`（HEAD a234369 领先 master），其审计 scope 与本任务载体面有交集风险 → 合并序策略入 FMEA
- attest template-gate 白名单实值=`rule-enhancement`（variant 文件名带 -type 后缀但白名单值无后缀），已修正计划 frontmatter 重锁
- check-plan-dispatch 对本计划 S5-S9 打「时长/粒度格式不可解析」SKIPPED（advisory 不阻断；模板自身示例即「≤15min+1f/30l/15min」格式）——如实登记：59.1 enforce 门对这些行未实际校验，人工核对全部声明值在上限内（≤2f/≤95l/≤15min）

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| （与 task_plan.md Decisions Made 表同步，不双写论证） | 见 task_plan.md：吸收式+引用式双轨 / Rule 21.6 而非新 Rule / silent 模式 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| attest 首轮 template-gate INVALID（rule-enhancement-type 不在白名单） | frontmatter 改 rule-enhancement（warn 档本不阻断，按 C22 如实修正）+ 重锁 SHA afc4673d |

## Resources
- 源技能池盘点报告：本会话 Explore agent#1 返回（22 技能/Top10 排序表）
- 仓内载体锚点清单：本会话 Explore agent#2 返回（12 项锚点）
- 基线：plans/task-v150-split-skill-integration/baseline-selftest.log（后台跑批，Phase 1 收口时归档摘要）

## Visual/Browser Findings
- （无多模态产出）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3) -->

#### [sub:05-executor-S3] S3 Rule 21.6 插入完成
- 在 critical-rules.md :159（21.5 行）后、:160（`### 22`）前纯增量插入 Rule 21.6（导语+21.6.1-21.6.5 五子条+机制句），新增 9 行
- 验证：`git diff` 零删除行；`grep -c '21\.6\.'` = 5 命中；21.1-21.5 与 `### 22` 后内容零改动
- 证据：worktree 内 `skills/task-planner/references/critical-rules.md` :160-:168；checkpoint=subagent-state/05-executor-S3.md

#### [sub:07-executor-S5] S5 dispatch 模板契约行完成
- subagent_dispatch.md §3 验收标准段追加 No-Placeholder 契约行（1 主行+2 子行=3 行），git diff 验证仅追加零删除
- 契约要点：禁 TBD/占位符；低档模型无需追问即知目标+方案+验收；材料实指绝对路径+摘要

#### [sub:04-executor-S1] S1 模式库上半完成
- 创建 split-pattern-library.md 上半部（60 行）：头部（定位+消费契约+来源技能总表 8 行）+ 模式 P1-P5（每模式五要素齐全）
- 验收：grep -c '^### P' = 5，行数 60 <= 95，中文，无占位符
- 文件：/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration/skills/task-planner/references/split-pattern-library.md

#### [sub:06-executor-S4] S4 SKILL 接线完成
- SKILL.md 四点接线：References 表加库行、委派检查点 2.5 后插入模式库对照句、C43a 补自查项、Rule 21.6 摘要行插入 21.6 提及
- 验收：grep -c 'split-pattern-library' = 4（>= 3）；git diff 仅 4 处新增、0 处删除
- 文件：/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration/skills/task-planner/SKILL.md

#### [sub:09-executor-S2] S2 模式库下半完成
- 同文件追加 P6-P10 五模式（五要素齐全）+ 伴飞映射表 7 行（路径全部 -f 验证存在）+ 未吸收登记 3 行，新增 55 行（S1 60 行基础上）
- 验收：grep -c '^### P' = 10；无占位符/TBD；既有 60 行零改动（纯新增）
- 文件：/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration/skills/task-planner/references/split-pattern-library.md

#### [sub:11-code-assistant-S6] S6 selftest 守卫完成
- 新建 scripts/selftest-split-pattern-library.sh（78 行，SP-01..SP-13 全量覆盖 kb §5④，负断言锚经 Read 确认原文）
- 自跑 Total: 13 PASS=13 FAIL=0 exit 0，幂等；SP-03 伴飞表 8 数据行、7 路径逐一 [ -f ] 通过

#### [sub:14-executor-S8] S8 术语锚定扩展完成
- split-pattern-library.md 追加 P11 术语语义锚定与理解复述（五要素齐全，+9/-0 零删除行）
- critical-rules.md 插入 21.6.6 术语锚定与反幻觉（+3/-0 零删除行，位于 21.6.5 后、机制句前）
- 验收：两个 git diff --numstat 均零删除行；P11 格式对齐前 10 模式；21.6.6 文体对齐 21.6.1-21.6.5

#### [sub:15-code-assistant-S9] S9 断言同步完成
- selftest-split-pattern-library.sh 三处 10→11（SP-02 模式数、SP-11 贡献行断言及对应描述、头部守护面注释），仅改数值常量与文本
- 复跑 Total: 13 PASS=13 FAIL=0 exit 0；SP-10 来源锚 =12 ≥10 不受影响（≥ 断言无需改）

#### [sub:16-code-runner-S7] S7 全量回归完成
- 63 脚本全跑对照基线（regression-worktree.log）：新增 FAIL 3 个——selftest-registry.sh rc=1（T02 未登记 selftest-split-pattern-library.sh）、selftest-self-resolution.sh rc=1（SR-12 registry 行数 63 应 64=脚本数+表头）、selftest-skill-split.sh rc=1（SKILL.md 502 行 > 钉值 500，d4fb622 +4 行 498→502）
- 新脚本 selftest-split-pattern-library.sh rc=0 | Total: 13 PASS=13 FAIL=0；periodic-review rc=1 FAIL=4 与基线逐字一致（已知基线）；registry 系 2 FAIL 同源=新脚本未登记 tsv，留主进程裁决

#### [sub:17-code-assistant-S10] S10 锚级联修复完成
- 2 文件最小修改：selftest-registry.tsv 末行追加登记行（tab 4 列同构，rows=63）+ selftest-skill-split.sh 钉值 500→510（-le 558 总上限不动，级联 label 按先例补注）
- 4 脚本复跑全 rc=0：registry 5/5（rows=63）| self-resolution 13/13（SR-12 行数 64=63+表头 自愈）| skill-split 41/41 | split-pattern-library 13/13（无回归）

#### [sub:20-alignment-S12] 对齐审查 ISSUES_FOUND（2×P1 + 3×P2）
- P1 计数漂移：「10 模式」见 critical-rules.md:161 + SKILL.md:354，库实际 11 模式（P1-P11，registry/selftest SP-02 冻结 11）；P1 CHANGELOG.md 在 task_plan scope_files:49/:95 声明为交付物但 diff 缺失、Phase 6 簿记未列
- P2：SKILL.md:215 C43a 合规行格式与 C30-C44 不一致；registry:64「21.6 五子条」vs 实际 21.6.1-21.6.6（21.6.6 无守护）；库文件无尾换行 + :120-121 表格→标题缺空行。伴飞表 7 路径 `[ -f ]` 全 OK、59.2/59.3/63.2 互引语义匹配、死引用 0；新 selftest 13/13 PASS

#### [sub:19-code-reviewer-S11] Code Review CHANGES_REQUESTED
- 2 处 P1 计数漂移（critical-rules.md:161 + SKILL.md:354「10 模式」vs 库/registry/SP-02 冻结 11）+ 守卫缺口（SP-04 未锁 21.6.6）+ SP-03 阈值 ≥7 严于 21.6.5「≥6」+ 53.3 引用语义不匹配（决策管辖 vs 规则域管辖）；13/13 自测 PASS、P1-P11 五要素齐全、路径全在位、63 脚本回归仅 periodic-review 已知基线 FAIL
#### [sub:21-code-assistant-S13] S13 CR 修复波 1：selftest-split-pattern-library.sh SP-04 改守护 21.6.1-21.6.6 六子条（regex `[1-6]`、阈值 ≥6、文本「子条锚(1-6)」）+ SP-03 伴飞表阈值 ≥7→≥6 对齐 21.6.5「≥6 行」契约；registry.tsv:64 描述列「21.6 五子条」→「21.6.1-21.6.6」（列数 4 不变）
- 验证：SP 套件 13/13 PASS rc=0（现库值：模式=11/来源=12/伴飞表=8 行/21.6.x 命中=6），registry 5/5 PASS rc=0；git diff 仅 2 文件纯数值/描述改动，断言总数 13 不变
#### [sub:22-code-assistant-S14] S14 CR 修复波 2：critical-rules.md:161/170 + SKILL.md:354/215 四处措辞修复（10→11 模式 ×2；去 53.3 编号误引用改「两条线各自独立」直述；kb §5④ 瞬态指针→脚本头注释锚；C43a 补齐 C30-C44 同款结构含机器面/人工核查/mini 豁免）
- 验证：两文件 `grep -c '11 模式'` 各 =1；`sed -n '160,171p' critical-rules.md | grep -c '53\.3'` =0；C43a 行含「机器面=」；`wc -l SKILL.md` = 502 ≤510；git diff 仅 2 文件 +2/-2 ×2 纯措辞替换零删行；已核实库内 `grep -c '^### P'` =11 支撑「11 模式」措辞
#### [sub:23-code-assistant-S15] S15 CR 修复波 3：split-pattern-library.md 4 项文件卫生（trailing newline / 伴飞表末行与未吸收登记标题间补空行 / 标题 53.3 管辖二分→管辖边界说明 / P10 判据改「模型分档路由（mini/haiku-1/sonnet-1/opus 按任务取最小可承载档）」单行）+ CHANGELOG.md Unreleased 新增段追加 task-v150 条目（Rule 21.6 拆分模式库+伴飞映射表+21.6.1-21.6.6 + dispatch No-Placeholder 契约 + selftest 守卫 SP-01..13，与既有条目同构）
- 验证：SP 套件 13/13 PASS rc=0；`tail -c 1` =0x0a；awk 表末行后空行在位（121 空行/122 标题）；库内 `grep -c '53\.3'`=0；`grep -c 'task-v150' CHANGELOG.md`=1；git diff 仅 2 文件 +6/-3
#### [sub:24-code-reviewer-S16] S16 修复后 CR 复审：S11 全部 11 项闭环（11 模式×2/SP-04 扩 [1-6]≥6/SP-03 对齐 ≥6/53.3 错配清除×2/kb§5④→脚本头注释/C43a 结构补齐/库尾换行+空行/P10 分档措辞/CHANGELOG task-v150 条目/registry 21.6.1-21.6.6），fix commit 1e5dd98 六文件与清单一一对应
- 验证：SP 套件 13/13 PASS rc=0 + registry 5/5（63=63）+ skill-split 41/41 全 rc=0；全量回归 63 脚本仅 selftest-periodic-review.sh rc=1 与 master 同态（已知基线）；全仓残留 grep（'10 模式'/'四档'/'断言清单见 kb'/'21.6 五子条'）全 0 命中；VERDICT: APPROVED
