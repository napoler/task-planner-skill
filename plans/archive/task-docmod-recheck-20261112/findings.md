# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
- R1（[目标]）：确认 sess_1378b365 会话缺陷=修改文档时无修改验证 → 低级错误（证据锚=用户引用的 G22-05a 三方时间口径矛盾）。
- R2（[目标]）：时间对齐/基础文档修正缺位 = 严重缺陷 → 必须纠正本仓相关 skill（文本条款层）。
- R3（[目标]）：验证机制失效——核心文件改完不复检就放行=设计缺陷 → 落过程期复检门。
- R4（[目标]）：回答并固化「同一文件二次修改是否需要流程优化」→ 落二次修改全量回归子条。
- R5（[目标]，2026-11-13 B 扩展）：todo 驱动强制对齐——两组原生 todo（通用基线组+任务步骤组），验证入通用步骤；必须同步到系统原生 todo 确保执行，防流程缺失/丢弃。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 用户宪法 §四/§六/§十一 | /home/terry/.zcode/AGENTS.md | ☑ | §3 决策（文本优先/worktree 集中目录） |
| task-planner SKILL.md | skills/task-planner/SKILL.md @ master(9126c3c) | ☑ | §2 审计对照 / §4 级联锚位 |
| sess_1378b365 会话上下文 | ReadSessionContext 取证(2026-11-13) | ☑ | §1 缺陷链 |
| discipline 规则全集 | skills/task-discipline/references/critical-rules-discipline.md | ☐（S1 执行体首动作 Read；本会话主进程仅消费审计摘要行号） | §2 A/C 行 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### §1 会话缺陷链取证（sess_1378b365，ReadSessionContext 2026-11-13，标题=重构罗布湖钓鱼点剧本大纲与剧情设计）
- **缺陷不是「完全没验证」，是「验证失效」三层叠加**：
  1. **派生值无基准**：C87 拆分轮按拆点 46s 拆 G22-05 → a/b 段，段标题改了（40-46s），台词双轨秒段〔全稿41-45s〕〔全稿46-49s〕未随拆点全链重算 → 镜内时间溢出镜长（6s 镜含 [镜内6-9s]），全站扫出 18 处同型溢出（会话 msgs 174-205 自述）。
  2. **修复器多轮翻车只做局部修补**：v4→v6 连续翻车（正则误入 map(int) 崩溃/贪婪正则吞坏块/行级操作静默未生效），每轮从整合版 v2.17 恢复 15 集，最终 8 组残组逐组硬编码——每轮只对局部，从未对单文档做全量不变量回归。
  3. **验证对象与交付物本体脱钩（两态定性，未验证）**：会话声称 ULTIMATE 终验全站 PASS（200 镜镜内溢出 0/台词守恒 203=203/整合版重建 v2.18），且声称「〔全稿46-49s〕来来来！移入 G22-05b」；但用户 2026-11-13 所见文档仍显示该句在 G22-05a（用户引用原文）。两态：① 修复只落整合版/某副本，用户消费的分镜稿本体未同步；② 终验虚报 PASS。**本体现状取证=未验证**：videop1 docs/prompts/plans/openspec 四目录 + output/tmp/assets + mkvides/LocalMiniDrama/kaifadiaoyan 邻接仓两轮检索（Explore 子代理 + 主进程兜底 rg）均未命中 `G22-05a` 字符串——文档本体在已检索范围内不存在，可能位于其他工作区（如 Toonflow 项目目录）。按 FMEA 兜底登记，不阻塞规则落地（106.4 两态兼容设计）。
- **佐证（文档自带自检字段）**：用户引用中 G22-05a 的「■自检：C76 PASS」在时间口径矛盾的情况下仍写 PASS——自检字段=声称而非验证，字段级不变量从未被机器比对。

### §2 本仓条款缺口审计（Explore 子代理 2026-11-13，15 处 file:line 锚）
- **缺口 A（过程期写后回读复检）无通用条款**：现有门全在终验期——84.7 内容审查门（verification-gate/references/critical-rules-verification.md:48-55）、84.14 收尾回读（同文件:44,57-59，明示「仅限全部 Phase complete 后、outcome 判定前」）；drift-guard 是目标/范围对齐非字段级。grep `写后验证/修改后验证/re-read/verify after edit` 对通用文档修改零命中（仅代码组机制画像 template-mapping.md:262-276 与存量归档）。
- **缺口 B（文档内跨字段一致性校验）无条款**：alignment-review（review-library）覆盖跨文档/术语/引用同步，但「段标题时间 vs 台词秒段 vs 段末拆点」类同文档跨字段强制比对无显式条款；grep `跨字段/时间轴/cross-field` 全仓几乎零命中（仅 templates/variant/script-dev-type.md:40 把「时间轴」当产出项）。
- **缺口 C（同文件二次修改回归）无强制条款**：task-discipline Rule 67.1（critical-rules-discipline.md:372）仅把「同一文件 ≥3 次往复修改」当上下文压力信号档（触发评估），非一致性回归门；iterative-optimizer:58,80 有回归思路但非本仓强制条款。
- **反向冲突条款**：Rule 20.5 Read/Write 决策矩阵（SKILL.md 就地速查+critical-rules.md）规定「刚写完的文件→不要再 Read（内容还在上下文）」——省 token 前提是「确认写入成功」，与跨字段一致性复检需求直接冲突，需豁免口径。
- **验证门适用对象核查**：run-verification.sh（verification-gate/scripts:1-182）只执行 verification.md 的可执行命令（代码/脚本类）；attest-plan.sh=计划期合规；check-complete.sh=格式/证据/状态机。**无任何门覆盖「文档修改动作后即刻复检」的过程期场景。**

### §3 级联面侦察（主进程 grep 2026-11-13）
- 字面 `1-105` 全仓仅 2 文件 8 处：skills/task-planner/SKILL.md + skills/task-planner/scripts/selftest-enumerate-first.sh——级联面小；S3 另以 `grep 'Rule 105'` 扫 discipline/verification 卫星规则清单行。
- 规则号 106 未被预留（plans/.rule-reservations.jsonl 尾部 landed=105）。
- 冲突扫描（check-conflicts.sh 2026-11-13）：8 个未提交文件均属在途他任务（plan-resume/todo-skill/workflow-model-tiers + 2 plan 目录），与 scope 零重叠；遗留 wt/task-v168-machine-parked=已知封存分支不碰。

### §Rule106 草案（Phase 2 定稿面——四子条全文，S1 执行体逐字消费）
> 落点=skills/task-discipline/references/critical-rules-discipline.md Rule 105 段之后新增整段；措辞以此为准，执行体仅做格式对齐与锚位核实（首动作 Read 目标文件 Rule 105 段形态）。

**Rule 106 文档修改复检纪律**（task-docmod-recheck-20261112 落地；判例=sess_1378b365「G22-05a 三方时间口径不一致仍放行」——段标题 40-46s / 台词〔全稿41-45s〕〔全稿46-49s〕/ 段末 46s 拆点互相矛盾且自检字段仍写 PASS）

**106.1 写后回读门（过程期，P0）**：对仓库受管文档（.md/配置/数据/内容稿）的每次修改（Edit/Write/脚本批量改写均算），在该修改步声称完成前，必须完成两项复检：① 修改点落盘内容与意图一致（Edit 成功 ≠ 语义正确）；② 该文档的跨字段不变量链（时间轴/编号/ID/拆点/交叉引用等相互约束字段）未被本次修改破坏。复检一行留痕 progress.md（`[recheck] 对象×不变量×结论`）。与 Rule 20.5 边界：20.5 豁免「确认写入成功」型重读（内容仍在上下文），不豁免「跨字段一致性」型复检（校验对象在本次修改点之外、上下文中未必有）。判例：G22-05a 任一轮修改后做一次不变量回读即可当场拦截三方矛盾。

**106.2 派生值先定基准（P0）**：结构化文档中存在派生关系的字段（例：段标题时间区间 ⊇ 各台词秒段、拆点=相邻段公共边界、镜内秒段 ⊆ [0,镜长]），修改任一派生值前必须先锚定基准值（明确以哪一侧为准=source of truth），再沿派生链全链重算所有受影响字段；禁止只改一处、其余字段保留旧值。判例：C87 拆分只改段标题与拆点、台词双轨秒段未全链重算 → 18 处镜内溢出。

**106.3 同文件二次修改全量回归（P1）**：同一文件在本任务内被第 ≥2 次修改后，复检面自动升级为「全文档不变量回归」——对该文档全量重跑其不变量校验（非只看本次 diff、非只扫修改点），全绿才可放行；此后每轮修改均须全量回归，禁止「上一轮验过、本轮只看增量」。与 Rule 67.1 分工：67.1 管「≥3 次往复」的上下文压力评估与升级，106.3 管「≥2 次修改后」的一致性回归，互补不替代。判例：修复器 v4→v6 每轮局部修补，口径漂移累积到终验仍未收敛。

**106.4 验证对象=交付物本体（P0）**：放行/终验验证必须运行在用户实际消费的交付物本体上；存在多副本/整合版/中间产物（生成稿/缓存稿/重建版）时，先 diff 副本与本体一致性——任一字段不一致 = 验证未通过，禁止「验证了 A 副本、放行 B 本体」。判例：该会话对整合版 v2.18 终验声称全站 PASS，用户所见分镜文档仍含缺陷句（副本漂移或虚报两态其一——本体取证未验证，见 §1；无论何者，「验证未锁定交付物本体」均成立）。

**106.5 两组 todo 驱动对齐（P0，2026-11-13 用户 B 扩展指令）**：每个计划的执行视图由两组**原生 todo**（TodoWrite/Task 系统条目，禁止只存计划文档）构成，S1 建组缺一=计划不得进入执行：
- **通用基线组**（全任务恒存在，与任务类型无关，清单唯一事实源=todo-sync 契约）：**B1** 修改后验证与复检留痕（Rule 106.1/106.2/106.3，持续项：status=in_progress 直至终验，完成判据=期间全部 `[recheck]` 留痕齐备）；**B2** Phase 翻转前 V-N 校验（Rule 84.3，每 Phase 一次）；**B3** 终验 VC 全复验（Rule 84.5）；**B4** 收尾回读梳理（Rule 84.14，连续一轮零新发现）；**B5** Todo 终态同步（S4，含基线组自身）。
- **任务步骤组**：Phase/S-unit 映射（todo-sync S1 既有契约不变）。
基线组与门禁硬挂钩：B1 未勾=修改步不得声称完成；B2 未勾=Phase 不得翻 complete；B3/B4 未勾=不得出 outcome；S3 `[plan-sync]` 回写两组都要处理，基线组条目丢失=当次立即重建（防丢弃）。Why：todo=执行视图唯一事实，门禁挂 todo 使「流程缺失/丢弃」在下次同步时可见；B1 设计为持续项避免逐次修改的 todo 刷屏。

### §todo 两组结构契约草案（S4 执行体逐字消费；落点=skills/task-planner/references/todo-sync.md）
> 在 todo-sync.md「S1 计划创建后建映射」小节扩展（增量追加，不改既有 S1-S5 语义）：
> 1. S1 建立两组原生 todo：**任务组**（Phase 映射，既有规则）+**基线组**（固定五项 B1-B5，措辞以 Rule 106.5 为准）；两组必须同为原生条目。
> 2. 基线组生命周期：B1 持续项（开启即 in_progress，终验翻 complete，判据=progress 全部 [recheck] 行）；B2 每 Phase 翻转前勾检；B3/B4 终验期；B5 收尾。
> 3. 门禁挂钩（对齐 Rule 106.5）：B1 未完成留痕=该修改步禁声称完成；B2 未勾=Phase 禁 complete；B3/B4 未勾=禁出 outcome。
> 4. S3 `[plan-sync]` 回写协议：两组均回写；发现基线组条目丢失（hook 重映射/会话恢复后）=当次重建，禁止静默缺组运行。
> 5. mini 档豁免口径：B1 不豁免（修改后验证无小任务例外）；B2-B5 随 mini 档既有豁免面。
> 6. 同步段指针：SKILL.md「原生 Todo 同步（强制）」段尾加一句「S1 两组结构（任务组+基线组 B1-B5，Rule 106.5）详见 references/todo-sync.md」。

### §级联锚位清单（S2/S3 执行体逐字消费）
1. SKILL.md：「Rules 1-105 全集索引」两处 → 1-106（grep 实测定精确行）。
2. SKILL.md 卫星路由表 task-discipline 行：规则清单尾追加 `106`（该行现尾=105）。
3. SKILL.md 核心规则指针段卫星归属括注（「Rule 105 可枚举集合…」所在清单句）追加 106 归属。
4. SKILL.md Phase 执行循环：3h 双轮质检行后新增一行「**3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106」。
5. SKILL.md Rule 20.5 就地速查行（「刚写完的文件→不要再 Read」）行尾追加：「（20.5 豁免写入确认型重读；跨字段一致性复检不豁免，见 Rule 106.1）」。
6. critical-rules-verification.md：84.7/84.14 段邻域新增一行「过程期文档修改复检（改后即刻）= Rule 106（task-discipline 卫星）；本域 84.x 仅覆盖终验期」。
7. selftest-enumerate-first.sh：'1-105' 锚 → '1-106'（8 处中属本任务者，以 fresh 跑实测 FAIL 清单为准逐处登记）。
8. critical-rules.md 核心域索引：无 '1-105' 字面；以 `grep -n 'Rule 105' skills/task-planner/references/critical-rules.md` 实测，有则按同口径追加 106，无则登记「无锚可改」。
9. SKILL.md「原生 Todo 同步（强制）」段尾：追加一句「S1 两组结构（任务组+基线组 B1-B5，Rule 106.5）详见 references/todo-sync.md」（CA-10，归 S2）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 106 归 task-discipline 卫星，verification-gate 仅一行互指 | 缺口=过程期执行纪律非终验门；Rule 82 禁回潮禁镜像副本 |
| 文本条款优先，零新脚本/hook/守护门（§四.6） | 用户宪法 2026-10-15 裁决：流程开销与变更体量成比例；selftest 仅维护既有 epoch 锚 |
| 106.4 两态兼容措辞（不依赖本体取证结论） | 本体取证两轮未命中（§1）；「对本体验证」在副本漂移/虚报两态下均成立 |
| worktree 用宪法 §11.2 集中目录 | §11.6 冲突裁决：宪法 §十一 优先于模板 tmp/worktrees 形态 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| G22-05a 文档本体两轮检索未命中（videop1 七目录+三邻接仓） | 按 FMEA 兜底登记「未验证+已检索位置清单」；规则 106.4 两态兼容设计不受阻；如用户指出文档实际路径可补定性 |
| videop1 全量 grep 连续超时 ×2（90s/45s） | 收窄目录+改派 Explore 子代理按文件名先筛（rg）——主进程不做大仓盲 grep |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 判例会话：sess_1378b365-f324-4ec0-b6ea-842163462b4e（标题：重构罗布湖钓鱼点剧本大纲与剧情设计）
- 审计锚：skills/verification-gate/references/critical-rules-verification.md:48-59；skills/task-discipline/references/critical-rules-discipline.md:372；skills/plan-template-kit/references/template-mapping.md:262-276
- 级联目标：skills/task-planner/SKILL.md；skills/task-planner/scripts/selftest-enumerate-first.sh

### §5 执行期结论（Phase 3，2026-11-13）
- **[implementation-only] 声明**：Phase 3 为纯实施 Phase（条款文本落地+级联+锚维护），设计增量已在 §Rule106 草案/§todo 契约草案承载。
- **selftest 基线定性（Q3 答案）**：master 基线**非全绿**——`selftest-active-plan` T11 与 `selftest-execution-stability` T11b 在 worktree 与主仓（master+他任务脏改）**失败形态完全一致**（28/1 与 18/1，同用例）→ 定性为 **master 既有基线问题**（attestation owner/重锁负例语义），与本任务纯 md 增量无关；按「报告不越权修」登记遗留（建议另立任务处置，锚=S5 检查点 06 两跑原文）。
- EN-06 断言纪元语义翻转=预期维护面（注释自带「级联依赖预期 FAIL」语义，翻转=断言跟epoch走，非改业务断言）。

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
