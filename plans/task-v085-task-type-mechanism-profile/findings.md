# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话：「优化我的该技能（task-planner） 我希望可以区分任务 不是所有的任务都需要使用 比如 @Code Reviewer 在文章撰写任务完全不需要 这种skill的使用」
- R1：task-planner 按 template_type 区分任务类型，机制适用性随类型裁剪（非代码任务不适用 Code Review Gate / code-assistant 路由）
- R2：映射而非删除——机制本身保留，只在类型维度给出「机制画像」（适用/不适用/路由组）
- R3：通用守卫（3-File 罗盘/委派率/漂移检测等）全类型不变，仅裁剪类型组机制
- R4：改 .sh 与技能运行时文件 → worktree 隔离 + code_review: required 自律适用（材料包事实 7）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules.md Rule 25-26/34 | skills/task-planner/references/critical-rules.md | ✅（锚点核验） | Research Findings 3/Technical Decisions 2 |
| template-mapping.md | skills/task-planner/references/template-mapping.md | ✅（全文结构核验） | Research Findings 4/方案 B |
| config.json | skills/task-planner/config.json | ✅（L71-80/L305 核验） | Research Findings 2/方案 G |
| selftest-template-lifecycle.sh | skills/task-planner/scripts/selftest-template-lifecycle.sh | ✅（TL-17 L80-82 核验） | Research Findings 4/FMEA R2 |
| template-guide.md | skills/task-planner/references/template-guide.md | ✅（L32/L60 计数锚核验） | Research Findings 5/Phase 2 S5 |
| check-complete.sh | skills/task-planner/scripts/check-complete.sh | ✅（868 行/L509 档位语义核验） | 方案 E/FMEA R3 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **来源声明：以下 1-7 条 = Explore 子代理一手调研（2026-09-20，材料包「已验证事实」节），plan-writer 于计划期对关键行号逐条实测复核（标注 ✅ 实锤者均二次验证通过）。**
- 1.【缺口】writing/research/publish 三个内容类 variant 模板已干净（Executor 只指向 article-writer 等），但 SKILL.md §子代理路由表（L354 起，✅ 实锤：L355 强制约束「先按本表选择 subagent」、L357 表头）无类型适配注记；通用 templates/task_plan.md（416 行）L16-24 Code Review 配置节 n/a/required 二态无判定逻辑（✅ 实锤 L24 值行）、L180 Executor 示例 code-assistant（代码向）——非代码任务被通用模板引向代码机制。影响：本任务缺口确认，方案 C/D 的落点。
- 2.【先例】config.json 已有 content_quality_enforce（L71-80 ✅ 实锤）按 writing/research/publish 分档——机制按 template_type 分档有先例可仿；config.json 为 JSON Schema 形态、additionalProperties:false、当前 38 顶级键（✅ 实锤 grep 计数 38；文件 428 行）。
- 3.【gate 安全】check-template-type.sh 白名单=variant/ 动态派生+general（L15-17 ✅ 实锤：`ls "$SKILL_ROOT/templates/variant/"*-type.md` 动态构造），新增章节不破坏 gate；attest-plan.sh 已集成该 gate。
- 4.【selftest 守护】selftest-template-lifecycle.sh（85 行，17 断言 TL-01..17）守护 template-mapping.md 与 template-guide.md；TL-17 断言「13 个」计数在 L80-82（✅ 实锤 `grep -q '13 个' "$TGUIDE"`）；template-mapping.md 现 198 行、8 章节（✅ 实锤：§一 L7/§二 L47/§三 L67/§四 L89/§五 L111/§六 L125（互斥表 L145-154）/§七 L158/§八 L178）。影响：新 §九 须顺延编号且不碰 §七红线区。
- 5.【SKILL.md 约束】SKILL.md 现 545 行（✅ 实锤）；无行数硬断言但有 TL-14/15 等 grep 断言（C22 行、「模板选取门控与沉淀」段必须保留）。影响：三处增量须纯追加不改既有锚。
- 6.【禁令源核查】Rule 32 禁令源：plans/task-v083-batch-pilot-first/notepad-learnings.md 两条 veto（无试点批量/速度理由压缩验证），与本任务方案无冲突（本任务非批量、非验证压缩）。
- 7.【自查档】本任务改 .sh（check-complete.sh + 新 selftest），按 rule-enhancement-type 模板 code_review: required 自律适用——同时构成 Rule 37 判定的首个消费示例。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 「机制画像（mechanism profile）」映射层方案（A-G 七件套） | A. critical-rules.md 末尾新增 Rule 37（≤70 行纯追加）：37.1 画像表权威源=template-mapping.md §九（Rule 37 只放指针+判定规则）；37.2 判定时点=计划创建期选定 template_type 后立即套用；37.3 三类机制组（代码组=Code Review Gate+code-assistant 路由+修改后验证流程；内容组=content_quality 门控+article-writer 路由；通用组=全部守卫不变）；37.4 消费侧（Phase 步骤 2.5 委派检查点先查画像再定执行体；Code Review Gate 仅当 template_type∈代码组或计划显式 code_review: required）；37.5 机制（config 新键 mechanism_profile_enforce 默认 warn+selftest）。明示「仅裁剪类型组机制，3-File/委派率/漂移检测等通用守卫全类型不变」 |
| 否决备选：每机制加 per-type 开关键×N | config 键爆炸（N 机制×M 类型组合）、新机制必改 config；映射层一次收口于 template-mapping.md §九，新机制只需加一行矩阵。证据=config.json 已 38 键且 additionalProperties:false，键数膨胀加剧维护成本 |
| B. template-mapping.md 新增 §九 机制适用性矩阵（≤60 行） | 14 行（13 variant+general）×列（类型/默认适用机制/不适用机制/执行体路由组）；写作/调研/发布行明确「不适用：Code Review Gate、code-assistant/debugger/code-reviewer 路由」；§一决策树尾加一行指针注记。位置顺延于 §八 之后（既有章节编号无冲突，已实测 §八 L178 为末章） |
| C. SKILL.md 三处纯增量（≤10 行） | ①路由表头部加类型适配注记行指向 Rule 37+§九 ②合规检查清单加 C25 行 ③Critical Rules 列表加 Rule 37 一行。纯追加保 TL-14/15 grep 锚 |
| D. 通用 templates/task_plan.md 三处微调（≤8 行） | Code Review 配置节加自动判定句「默认按 template_type 机制画像判定，代码组外默认 n/a」；Executor 示例加注「按机制画像选执行体，非代码任务见 template-mapping §九」 |
| E+F+G. 守卫三件套 | E. check-complete.sh 画像抽查段（≤15 行，warn 不改 exit / enforce exit 1）；F. 新建 selftest-mechanism-profile.sh（12-15 断言含行为级 fake plan 双档）+ lifecycle 追加 TL-18；G. config.json 新增 mechanism_profile_enforce（enum warn/enforce/off 默认 warn，位置仿 template_gate_enforce L305 相邻） |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| attest 首跑拒锁：check-plan-dispatch 判 Phase 2/3「缺 S-unit 表或数据行」 | 根因=S-unit 数据行用了裸数字 ID（\| 1 \|），守卫正则要求 \| S<n> \|；记忆教训「S-unit ID 纯数字」被误转述为「省略 S 前缀」。Edit 修正 11 行后 attest 通过（SHA c0da109c…） |
| attest 警告 template_type 缺失+无 FMEA 段标题（warn 档放行） | 根因=计划配置表字段带反引号包裹（\`rule-enhancement\`）、FMEA 段标题写成「⚠️ FMEA」而 gate 找「📊 FMEA 预演」；不阻断，交付时按实质内容复核（反引号内值正确、FMEA 表 4 项在位） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 派发材料包：plans/task-v085-task-type-mechanism-profile/subagent-state/1-plan-writer-brief.md
- 锚点速查：SKILL.md:354（路由表）/ templates/task_plan.md:16-24（Code Review 节）/ template-mapping.md:145（§六互斥表）/ config.json:71（content_quality_enforce）/ config.json:305（template_gate_enforce）/ selftest-template-lifecycle.sh:80（TL-17）/ check-template-type.sh:15（动态白名单）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
- （本任务无浏览器/多模态调研）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
