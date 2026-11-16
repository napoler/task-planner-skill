# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1[目标]: D1 前计划独立审计（独立上下文）+ REJECTED 打回修正再审迭代直至达标，未审计/未达标不得交用户（user-session-log.md #1）
- R2[目标]: “未经审计产出禁交用户”贯彻全流程，任何需审核产出交付前独立审计确保完整性与可靠性（已识别覆盖面非穷尽，未列面默认简版复核）
- R3[手段]: 融入当前技能创作/优化（增量落地 SKILL.md + critical-rules.md 等）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-planner SKILL 流程 | `skills/task-planner/SKILL.md:38-75,118-150` | ☑ 计划期 | Research Findings / Technical Decisions |
| 核心 critical-rules | `skills/task-planner/references/critical-rules.md:1-208` | ☑ 计划期 | Research Findings / Resources |
| critic agent | `/home/terry/.zcode/agents/critic.md:1-70` | ☑ 计划期 | Research Findings |
| R1 审计留痕 | `plans/task-planaudit-20261116/progress.md:102-123` | ☑ 修订期 | Research Findings / Issues Encountered |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 2026-11-16 计划期基线核实（plan-writer，来源=本地 Read/Grep 已验证）

| 面（已识别覆盖面，非穷尽） | 现状/已覆盖 | 缺口（相对 R1/R2） | 拟落点/映射 |
|----|-------------|-------------------|-------------|
| 计划面（D1 前） | `[A] 初始化首动作委派` 产出计划后主进程盘上复核并进入 `[A] 计划确认`（D1 展示/授权/attest）（`skills/task-planner/SKILL.md:50-75`） | **缺口**：盘上复核≠独立上下文审计；无“审计→打回修正→再审→达标才交用户”强制循环与轮次留痕；未分档 | 在智能子动作完成后、D1 展示前插入 `计划独立审计门`（L1+ 强制，轻量档豁免/轻量复核；主审计体 critic `/home/terry/.zcode/agents/critic.md:4-6`），通过后才展示/确认（VC-1/VC-2/VC-6） |
| 执行产物面 | Rule 103 双轮质检：自审+全新子代理独立复检、升档、同步核对清单（`SKILL.md:118,120,142,247`） | 原则未在“未经审计产出禁交用户”总则中显式收口（覆盖存在但未统一表述） | R2 总则中映射 Rule 103 为执行产物面已识别独立审计覆盖（VC-3）；声明计划面逃逸 103.3 由审计门承载、执行期产物由 103 承载、二者不叠加 |
| 终验面 | verification-gate/Rule 84：VC 可执行化/V-N/终验复验/子代理验证/统一入口（`SKILL.md:139-145,247,262,267`）；Rule 108 交叉验证（`SKILL.md:247`） | 同上，缺统一“交付前独立审计/验证”原则映射 | R2 总则映射 Rule 84/108 为终验面已识别覆盖（VC-3） |
| 报告/总结面 | 交付总结五要素与模板 `templates/delivery-summary.md`（`SKILL.md:145,299`）；终验流程要求证据/复核但未显式“独立审计后再交用户”通用表述 | **缺口候选**：需审核报告/总结交付前独立审计要求未制度化 | Rule 109/流程增量要求“需审核报告/总结交付前独立审计”并最小联动模板提示（CA-5 条件式，VC-3） |
| 上抛裁决面 | decision-arbiter/Rule 69 裁决与分歧处理触点；CR 分歧锚 `SKILL.md:129`（“CR 分歧（Rule 69.1 T6）→decision-arbiter”）；规则索引含 Rule 108/69（`SKILL.md:247`） | 缺“未经独立审计/证据整理不上抛”总则化表述 | R2 总则映射 Rule 69/独立仲裁与证据面要求为已识别覆盖（VC-3） |

- **未列面判定规则（F1）**：上表为已识别覆盖面，非穷尽枚举。凡属于“需审核后交付用户”的产出且未显式列入上表，按全流程总则默认适用**简版独立复核**（独立上下文核对完整性/可靠性与需求覆盖，结论与证据留痕），不得以“未列出”作为免审理由（防 51.9 自缩水）。
- **编号核实**：全仓活跃代码未发现 `^### 109` 定义（计划期 grep：命中仅 `plans/archive/task-initdelegation-20261115/*` 历史候选讨论），Rule 109 可作为增量候选（执行期按 Rule 20.6 reserve/land）。
- **约束核实**：Rule 74 增量默认、Rule 82 核心域边界（`references/critical-rules.md:176-182` 建制/边界/回归防线）、文本优先铁律（未授权禁增脚本/守卫/机器门）——机器面列 CA-6 待授权候选。证据：`SKILL.md:26`。

### VC 判别性基线（F12，改动前快照 2026-11-16 计划期）
| 专有 token | 目标文件 | 基线计数（改动前） | 预期落地后 | 备注 |
|------------|----------|-------------------:|-----------:|------|
| `计划独立审计门` | `skills/task-planner/SKILL.md` | 0 | ≥1 | VC-1 判别性；计划期 grep 无命中 |
| `audit-before-delivery` | `skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md` | 0 | ≥1 | VC-3 判别性；计划期 grep 无命中 |
| `^### 109 ` | `skills/task-planner/references` | 0 | 1 | VC-4；活跃代码无定义 |
- 基线复核命令与实测（2026-11-16，修订期）：`grep -c "计划独立审计门" skills/task-planner/SKILL.md` → **0**；`grep -c "audit-before-delivery" skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md` → **0 / 0**；`grep -rn "^### 109 " skills/task-planner/references | wc -l` → **0**。判别性成立。

### R1 审计轮次（首例证据，F17）
- 轮次: R1（2026-11-16），审计体: critic（独立上下文），结论: **REJECTED**（18 发现：BLOCKER×2 / MAJOR×7 / MINOR×9）。完整问题清单与修复对照见 `plans/task-planaudit-20261116/progress.md:102-123`（`[plan-audit-R1]` 固定段）。
- 负向验证：R1=REJECTED 且本计划未获 APPROVED、未进入 D1 展示/确认（`task_plan.md` 仍处修订待最终达标轮复审（如 R3）状态），审计门“达标前阻断”在流程上已实证。
- 修订处置：F1-F18 已按增量修订落盘（见 task_plan/verification/knowledge-brief/progress 修订记录），待最终达标轮复审（如 R3）逐项闭环核验。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 109 归属定稿（F8） | 计划审计门属计划生命周期/制作域→核心 `references/critical-rules.md` 承载计划制作域条款+全流程原则总则；执行产物/终验/裁决细则分属卫星，仅引用映射不改写卫星语义，符合 Rule 82 |
| 达标判据与裁决转换定稿（F4/F5） | 可观察：0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）⇒APPROVED，否则 REJECTED；审计体出具，主进程只登记；争议→decision-arbiter，连续≥3 轮无实质进展→用户裁决（防死循环） |
| VC-1/2/3 判别性设计（F12） | 引入专有 token `计划独立审计门`/`audit-before-delivery` + 基线负断言记录 + Read 语义复核，避免基线即 PASS |
| 审计门分档与边界（F11/F3/F9/F10） | L1+ 强制，轻量档轻量复核/登记豁免，L0-E 豁免；再展示简版审计；103 不叠加；44.3 不适用+降级链 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| R1 critic 审计 REJECTED（18 发现） | 已按 F1-F18 增量修订计划文档并记录修订收据；Handoff#10 与 progress `[plan-audit-R1]` 已真实留痕；待最终达标轮复审（如 R3） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- `skills/task-planner/SKILL.md:50-75,61-75,118,129,142,247,299`
- `skills/task-planner/references/critical-rules.md:1-10,140-208,176-182`
- `/home/terry/.zcode/agents/critic.md:1-70`
- `plans/task-planaudit-20261116/user-session-log.md:11-16`
- `plans/archive/task-initdelegation-20261115/*`（Rule 109 历史候选讨论，仅参考）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7) -->

## Research Findings — P1 现状核实与覆盖面盘点（R 锚定：本 Phase 服务 R1/R2「计划审计门+全流程独立审计」——三路 explore 并行核实，2026-11-16）

### P1-S1 插入锚点（worktree SKILL.md=307 行，与部署位字节一致）
- 精确插入点：「[A] 初始化（哨兵机制）— 智能子动作」区块结束=SKILL.md:66（Spec 模式触发判定行）→「[A] 计划确认」标题=SKILL.md:68；两行间仅空行 :67，无其他步骤。审计门插入为计划确认区块首个子项（:68 后、:69 展示前）
- 计划确认门控序列：:69 展示（Rule 70 四要素）→ :70 门控（yes/44.3 超时自动通过/attest 锁定）→ :71 目标绑定确认（D1 升级 P0，禁确认前清哨兵）→ :72 Spec 前置 → :73 交互模式 → :74 编号预留
- G1 合规清单=SKILL.md:174（「计划已展示并获用户显式授权」前置补审计达标）
- 44.3=SKILL.md:70-71（审计门不适用声明挂 :70 排除+新门条款内声明）；:206 意图切换登记字段确认=yes|44.3自动 不受影响
- 22.4a/62.2 计划期单写者=SKILL.md:53；critic 引用=SKILL.md:98（检查验证审查行）、decision-arbiter 引用=:78,101,111,123,129
- 索引联动面（108→109）：SKILL.md:9（frontmatter）、:247（Critical Rules 指针：核心 14 条+其余 91 条+Rule 108 描述）、:291（references 表）+ critical-rules.md:180（核心在位 14 条清单）、:194-207（卫星路由索引）

### P1-S2 五面覆盖矩阵（缺口=计划面+报告总结面；部分缺口=终验面/直做豁免面/上抛面）
| 面 | 已覆盖机制（file:line） | 缺口/弱点 | 拟映射 |
|---|---|---|---|
| 计划面 | SKILL.md:68-71,174（D1 展示+yes+attest）；:53-56（单写者起草+主进程盘上复核） | 产出→D1 前无独立审计；84.4 主进程读验非独立 | **Rule 109 新增强制门** |
| 执行产物面 | SKILL.md:118,120（103 双轮质检）；dispatch 卫星:225-245（103.1/103.3/103.3a/103.5/103.6/103.7）；discipline:727,731（106 复检） | 覆盖限派发型 S-unit；主进程直做/103.7 豁免面未经第二轮 | 引用既有 103/84.4/106；109 扩面兜底 |
| 终验面 | SKILL.md:139-144（84.14+终验 SOP）；verification 卫星:35-43（84.5+33.3 独立性）、:48-53（84.7 内容型独立审查）、:60-70（108 交叉验证） | VC 复验主进程执行；84.7 仅内容型触发；终验结论→交付前无统一独立签核 | 引用 33.3/84.5/84.7/108；109 统一签核 |
| 报告/总结面 | SKILL.md:145,299+discipline:216,395-400,413（Rule 48/70） | 交付总结产出后无独立审计要求（⚠️ S2 报 worktree templates/delivery-summary.md 疑似缺失——P4 执行期实测，若缺失则 CA-5 按模板补齐路径处理） | **Rule 109 新增交付前审计** |
| 上抛裁决面 | SKILL.md:78,101,111,123,129+discipline:384-393（Rule 69 T1-T6 四态） | 仅覆盖判断类争议；非全量上抛审计 | 引用 Rule 69；109 上抛包纳入 |

- 未列面候选（10 项，供 109.5 判定规则参考）：D1/D2-D6 选项呈报、B/C 新旧对比呈报、drift BLOCKED 升级呈报、worktree 冲突 STOP 呈报、否定结论上报、CR/对齐矛盾报告、媒体送审清单、静默决策清单/diff 逐项确认、意图切换/回切通告、AskUserQuestion 证据包（file:line 见 explore 原始返回）

### P1-S3 Rule 109 落点与边界（编号可用）
- `rule-reserve.sh next`=109（水位一致）；全仓 skills/ `^### 109 `/`Rule 109`/`audit-before-delivery|独立审计门` 基线=0
- 追加位置=critical-rules.md:192（83.4 末行）之后、:194 卫星路由索引之前（空行分隔）；格式范式=`### <N> <标题>（<任务/目标/判定面/衔接>）`+`N.x **小标题**：`+Why/建制段（:162-192 先例）
- 索引同步清单（109 落核心 → 核心 14→15 条、全集 1-108→1-109、其余 91→90 条）：critical-rules.md:180（核心清单+计数）、:194-207（卫星路由索引头部）；SKILL.md:9、:247（核心在位/其余条数/108 描述）、:291
- 约束锚：Rule 82=critical-rules.md:176-182（核心只留核心域+禁镜像+新规则先过 20.6 查重）；Rule 74=discipline:481-486（增量默认+74.3 逐条标注）；Rule 20.6=SKILL.md:74+rule-reserve.sh:8-14（reserve/land 形态；attest 曾报 new_rule 解析失败 fail-open——执行期手动 `rule-reserve.sh reserve 109 task-planaudit-20261116` 补登记）
