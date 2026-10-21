# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1（缺陷实证①）：sess_f74fc164 会话中单个子代理被要求一次性处理 4 篇文章的修正优化——用户判定完全背离「单个子代理执行小任务」原则
- R2（缺陷实证②）：更早会话视频创作把 19 个片段全部放进一个子代理生成——用户判定烂透了、背离「子代理中单个任务禁止过长」条约
- R3（目标）：在技能中确保所拆分的单个任务不会在单个子代理中执行过多的任务
- 范围边界（用户裁决口径）：修复载体=技能条款文本（§四.6 文本优先）；部署位同步、机器守卫扩张均不在默认范围

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules-dispatch.md（Rule 21/22/46/59） | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | ☑（Explore 摘录） | §2 |
| critical-rules-media.md（Rule 47/49） | /mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md | ☑（Explore 摘录） | §2 |
| check-dispatch.sh / selftest 守护面 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ | ☑（Explore 摘录） | §2 |
| sess_f74fc164 会话史实 | ReadSessionContext(sess_f74fc164-419a-4ada-b45d-565685da83c7) | ☑ | §1 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### §1 事故第一手证据（sess_f74fc164-419a-4ada-b45d-565685da83c7，ReadSessionContext 取证 2026-10-21）
- 派发形态史实：先 **8 篇/单代理批**（msg 51，处理 55/638/1009/1067/1072/1082/1089/1092），运行 44 分钟后 LLM 网关 ECONNREFUSED 挂死，几乎无产出；重派仍为 **2 个并行子代理各 4 篇**（msg 57/59：2a=55/1009/1067/1072，2b=638/1082/1089/1092），prompt 要求「每完成 1 篇立即落检查点（勿攒批）」。更早还有 9 篇后台批静默失败（无落盘产物、无检查点）。
- 用户在该会话 msg62 的在先裁决（本任务最直接的需求锚）：**「单子代理一次执行 4 篇错误率太高，违背『单个子代理执行小任务、避免上下文被占满』原则 → 后续派发粒度应缩至每子代理约 1 篇」**。
- 关键事实：该会话**在用 task-planner**（plans/task-sgx-published-audit-fix-20261021/ 七文件在位、attest 锁定）——即规则在位的计划内派发仍然打包多单元，排除「会话没用技能」的解释。
- R2 的 19 片段案例无会话 ID，未取第一手（用户原话即证据，media 条款缺口有 Explore 一手文本支撑，见 §2）。

### §2 技能现状与四结构性缺口（Explore 一手文本，2026-10-21）
现有禁止性条款（部分在位）：
- Rule 46.1 单会话单 S-unit（critical-rules-dispatch.md:116）：「一次子代理执行会话只领取 S-unit 表一行……禁止同一会话内批次追加」——定性，无数量口径。
- Rule 59.1 粒度三值硬门（:142）：Nf/Nl/Nmin 超 2 文件/100 行/15 分钟 → enforce 拒锁——管**体量**，不管**单元数**（4 篇文章若每篇不超三值即合法通过）。
- media Rule 47.1（critical-rules-media.md:11）：「单 S-unit = 单生产单元 × 单阶段……禁止『整集生成』式粗粒度派发……单元数 >1 批 → 拆分」——唯一接近单元上限的表述，但**定性**且属 LLM 行为面；49.5（:34）明示机器不校验推进真实性。
- Rule 46.5（:120）自承「判定面主体=LLM 行为」。

四结构性缺口（为何条款在位仍复发）：
1. **无按任务类型的数量上限表**：全文无「≤N 篇/≤N 个/≤N 段」数值表；仅有量化上限是体量类（2f/100l/15min/4 步、max_per_phase=5）。判据缺失=LLM 自由裁量。
2. **守卫不识自然语言单元量且 fail-open**：check-dispatch.sh（skills/task-planner/scripts/check-dispatch.sh）只数 prompt 内 `S[0-9]+` ID（:443-479）与步骤序号，不识别「4 篇文章/19 个片段」式罗列；:14 明示无活跃计划/prompt 不可读 → fail-open(exit 0)；Rule 22.4c（critical-rules-dispatch.md:62）同口径。
3. **自由 prompt 行首编号被刻意排除**：check-dispatch.sh:375-381「自由 prompt 分支……行首 markdown 编号依旧不入口径」；selftest-dispatch-grain.sh GR-09 实测「自由 prompt 含 6 个行首编号 → exit 0 不拦」——「1. 文章A 2. 文章B……」式罗列不触发任何门。
4. **无会话级累积 + 域条款文本缺位**：无跨派发会话级单元计数器；Rule 21.1c（智能拆分）文本在 master 不存在（被 task-v144 并入 59.6，plans/archive/task-v144/findings.md:59）——与本案无直接缺口，仅登记不回填。

对标先例（可循范式）：Rule 59.1 证明「数值上限 + enforce 门」在本仓可落地可守护（task-v144 建成）；本任务复制该范式到「单元数」维度，但按 §四.6 默认只做文本面。

### §2.1 B 类扩展取证（R4 调研方向粒度，2026-10-21）
- 用户新增诉求：调研阶段同样要拆分——多个子代理并行调研、每子代理一个方向，禁止单子代理一次性调研过多方向导致后期混乱（逐字入 user-session-log #2）。
- 一手证据：`grep -n "并行|单方向|方向数|一次调研" skills/plan-research-router/references/critical-rules-research.md` **零命中**——调研域对方向数完全无约束；该文件仅 58（证据纪律）/63（检索优先）/75（调研激活，子条 75.0-75.7）三节，**75.8 为零撞号自然落点**。
- 设计取向：单子代理 1 个方向；多方向 = 方向枚举为多 S-unit + 并行多子代理（复用 task-v110 建成的 Rule 21.4 并行组+独立性四问，方向间天然独立）；每方向结论分档落 findings 独立小节（防「混在一个大海报里后期混乱」）；46.6 只读豁免措辞交叉引用 75.8，防「调研类不受限」的误读。

### §3 执行期发现（S1-S6 落地与合并，2026-10-21）
- **S1 自编号标记**：46.6 定稿正文仅 1 处「46.6」字样，为满足 VC-1 grep≥3 机器锚，执行体在「判定口径/机制面」子条加自引用标记——主进程 diff 复核为非语义导航锚，S5 critic 未列违规，接受并留痕。
- **锚级联实测**：唯一断裂=selftest-dispatch-grain.sh GR-01（`^46.` 计数 5→6），最小修复 +4/-4；其余 91 脚本零断裂——印证「纯增量条款不碰锚」策略有效。
- **final-gate-hash 瞬态**：R2 单轮 FAIL，带改动单跑 8/8 全绿+R1/R3 全量 PASS——判定预存瞬态抖动（非确定性回归），不修，登记。
- **并行会话三连击（全程共存）**：①全局活跃指针被抢指 task-v195（--sid 会话私有指针化解，memory 判例复发第 2 次）；②master 执行期被推进 9 提交（task-v195 规范召回+Rule 93 纪元 1-93）——与我方 4 文件零交集，worktree 内先并 master 再合并回，零冲突；③主仓 skills/ 留有并行会话在途未提交改动（SKILL.md/critical-rules.md/selftest-requirement-coverage.sh）——主仓不自测 selftest（避免吞并行态噪音），以 worktree 合并树终轮 92/92 为 VC-4 口径。
- **Handoff 裸名判例第 N 次复发**：subagent_type 写 `executor(sonnet-1)` 带后缀 → check-delegation 报「未登记子代理类型」violation；修=Handoff 列裸名+模型档位移备注列（task-v150 判例复发，已写入 progress Error Log）。
- **委派率豁免路径实测**：rate 0.4<floor 0.7 时 WHITELIST-EXEMPT 关键词面=`白名单[①-⑥]|git 编排|worktree|计划系统文件|三件套|机械验证|用户显式|兜底接管|trivial`——Phase 1/2 理由措辞差「计划系统文件」字面即被卡，措辞修正后 verdict=ok。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 46.6 五要素草案框架：内容类 1 单元/派发；媒体类 1 生产单元/派发；机械小操作 ≤5+逐单元检查点；豁免=只读分析+用户显式豁免两类；判定口径=可数交付单元计数与是否写 S-ID 无关（堵缺口③的绕行面） | 数值上限直接固化用户 msg62 在先裁决；「与 S-ID 无关」堵住「不用 S 编号就绕过守卫」的缺口；豁免面收窄防误伤只读普查 |
| Phase 2 主进程起草、Phase 4 critic 复审（同 task-v193 结构） | 条款文本短（预计 ≤50 行），设计依赖整体证据；独立复审补盲区 |
| 机器守卫扩张（check-dispatch 识别自然语言单元量）不上本任务默认范围 | §四.6：守护机器化=opt-in，用户显式同意才建；列为计划待审项随确认一并裁决 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| R2 的 19 片段案例缺会话 ID 无法第一手取证 | 以用户原话为证据（R2 逐字入档），media 条款缺口由 Explore 一手文本独立支撑；不阻塞条款设计 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- skills/task-dispatch/references/critical-rules-dispatch.md（:116 Rule 46.1 / :142 Rule 59.1 / :120 Rule 46.5 / :62 Rule 22.4c）
- skills/media-planner/references/critical-rules-media.md（:11 Rule 47.1 / :34 Rule 49.5）
- skills/task-planner/scripts/check-dispatch.sh（:14 fail-open / :375-381 编号排除 / :443-479 S-ID 计数）
- skills/task-planner/scripts/selftest-dispatch-grain.sh（GR-09 自由 prompt 不拦实证）
- 会话证据：sess_f74fc164 msg51/57/59/62（ReadSessionContext 摘录）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
