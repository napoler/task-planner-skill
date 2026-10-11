# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- **用户原话缺陷案例**：「我同时存在两个要求：要求人物脸上有泪痣；不注意看不到。当前只关注有泪痣，完全忽略了后者（不注意看不到）。要求的限制大小被忽略导致人物设计缺陷」（"后期要钱的"按语音转写歧义理解为"后期要求的"）。
- **缺陷本质**：同一对象上复合要求 = 存在性约束（有泪痣）+ 程度/强度约束（不注意看不到=显隐度/大小上限）。当前验收只做存在性二元判定，强度约束在计划期（VC 表达）与执行期（QC 判定）双断链 → 生成侧为满足可检项把泪痣做得显眼 → 成品缺陷。
- **用户要求的能力**：对不同内容要求做**权重分级**（要求间有层级/权重差异）+ **评级**（分级评分而非二元判定）。
- **隐含子需求**：①计划期能识别强度类约束词（不注意看不到/不明显/轻微/小/淡/低调）并显式落 VC；②约束条目带类型（存在性/程度）与权重（硬约束必过 vs 评分项加权）；③验收输出=逐项评级（如 1-5 分/合格/部分/不合格）+ 加权总分判定，且程度项双向判（过大=违"不显眼"，过小到不可见=违"有泪痣"）。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

#### [sub:01-explore] 仓内现状（skills/task-planner 源，2026-10-04）
- **Rule 编号**：critical-rules.md 共 504 行，最后落地 Rule 48（:496-504）；无 Rule 49/50 任何内容；新块追加点=文尾 :504 后。Rule 49 为 pending task-v126 预留（撞号裁决=本体落地为准），**v127 取 Rule 50**。
- **Rule 47 媒体派发纪律**（:484-494，47.1-47.4）：拆分轴/具名路由/试点先行/机制守护——**零 QC 权重·强度·评级语义**；`grep -c '权重' critical-rules.md`=0。
- **VC 框架现状**：goal-gate.md:7-17 二元三态（COMPLETE/PARTIAL/BLOCKED），无分级/加权评分形态。
- **仓内既有加权评分先例**（新机制的形态模板）：methodology.md:193-212 Q4 五维内容评分卡——五维各 1-5 分、权重表 准确性25/相关20/可读20/原创20/SEO15（合计100）、加权 ≥4.0 放行/3.0-3.9 小修/<3.0 退回重写（:209）；挂载面 SKILL.md:153（content_quality_enforce 默认 warn，仅 writing/research/publish 三类）+ templates/variant/writing-type.md:81。
- **级联面**：SKILL.md:9 frontmatter 全集「1-48」→ 扩「1-50」后 selftest-plan-tier.sh:78（PT-08 `Critical Rules 全集 1-4[5-9]` 宽容锚）0 命中转 bad → 需同任务扩锚（先例=v117/v118/v121 口径预扩，如 `1-4[5-9]` → 含 `1-5[0-9]`）；selftest-conclusion-discipline.sh:66/69-70（CD-11）、selftest-ask-default-timeout.sh:66-69（RT-08 加白 1-45..1-49）需同步核查；`1-4[0-9]` 越界负断言（selftest-review-library.sh:103 等）对 "1-50" 字面天然不命中（首段 1-5x）；config.json properties=40 自守护（selftest-reliability-institution.sh:87 等）——**零新 config 键则无此级联**。
- **模板面**：templates/variant/ 30 个类型文件，含媒体族 image-type / video-type / qc-defect-type / character-design-type——评级能力的落点候选。
- **v124 接口点**（pending 0/5）：将新增 image/video-generation-executor 两个 companion agent + Rule 47.2 联动；v127 的评级规范将被这类执行体消费——v127 不动 v124 范围，在规范侧留消费点即可。

#### [sub:merge-phase5] 合流与交付发现（2026-10-04，Phase 5）
- **v129 撞点合流**：master 前进（v129 Rule 51 落地）致 smart-merge-back MASTER_AHEAD 中止一次；worktree 内 git merge master 产生 4 文件冲突（critical-rules.md 双方文尾追加/SKILL.md bullet 相邻行/registry 表尾双行/skill-split 行数锚 450 vs 451），解法=50/51 并存（编号序）+SKILL.md 全集 1-51 纪元（枚举含 50/51，references 行 Rule 51 乱序修正）+registry 双保留 48 行+T-主 锚按实测 452。
- **合流级联 5 FAIL 全为锚适配**（S12 修复归零）：PT-08/CD-11 `1-50`→`1-5[0-9]` 宽容式；RG-06 同；LA-11 References 尾「）」锁失效（49 名后已接 50）→去尾字符锁；**RC-15 负断言 `^50.`=0 被 Rule 50 合法落体打破 → 演进为 `^52.`=0**（下一个编号守卫自然演进，两任务合流的机制性联动实证）。
- **部署位自保护**：smart-merge-back 对 `~/.zcode/skills/task-planner`（本会话运行位）REJECTED（防热替换），claude/opencode 两位自动 IDENTICAL；zcode 位按 SOP 手动 rm+cp 后 3 位 0 差异。
- **终态**：47 脚本全绿（724 PASS/0 FAIL）；merged(38e562e)；VC-5 字面「1-50」因合流演进为「1-51」含 50——锚演进链 1-49→1-50→1-51 实证（与 task-v121 预扩同族）。

#### [sub:wave1-impl] 波 1 实现产出（S1-S4，2026-10-04，worktree 基线 48c6952）
- **S1 Rule 50 条款块**：worktree critical-rules.md :522 起追加 23 行纯增量——溯源段（用户泪痣原话）+ 50.1 原子条目表五列结构（P/E × H/S × 权重 × 判定刻度）+ 50.2 程度约束词显式成条默认 H + 50.3 逐条评级与程度双向判 + 50.4 加权判定（全 H 过 + S 加权≥阈值，仿 Q4 先例）+ 50.5 QC 链消费（image-understand 取证/消费方评级/image-review 质量门）+ 50.6 机制（零新键+selftest 守护）+ 泪痣 P/H+E/H 样例表。
- **S2 SKILL.md 联动**：:9 全集 1-49→**1-50**（枚举括注补「50 内容要求权重分级与评级」）+ :285 Rule 50 bullet（六子条摘要）+ :359 媒体路由行内追加「+评级契约（Rule 50）」；wc -l 449→450（净增 1 ≤10）；「Rules 1-39」计数锚（:248/:309）零变化。
- **S3 两媒体模板**：image-type.md / character-design-type.md 各 +12 行「📐 评级契约（Rule 50）」区块（条目表 5 列头+双向判+加权判定+泪痣样例），位置=VC 区后/Phases 前，纯追加 0 删除。
- **S4**：qc-defect-type.md +12 行同形态区块（:28）；goal-gate.md :18 +1 行「VC 分级语义（Rule 50）」——既有 17 行与五条 VC 规则零改动。
- **worktree 全量 diff**：6 文件 +63/-2（仅 S2 的 2 行替换），与 scope 完全一致。
- **执行守卫实测（3 次拦截，佐证复盘 F4 守卫摩擦）**：①prompt 内 `{findings,progress}.md` 花括号缩写不认（须逐行完整路径）；②任务书引用他 S-unit ID（「那是 S4 的」「同 S3 形态」）触发 Rule 46.2 打包拦截——v123 教训第 2 次实证，任务书禁跨 S-unit 编号引用；③并行组 [parallel-group:impl-wave1] 标记 + 计划声明双条件放行实测有效（4 子代理同 worktree 并行写入无冲突，文件集隔离）。

#### [sub:02-explore] 外部技能面（~/.zcode/skills 图像链，2026-10-04）
- **现行 QC 链路**：agnes-ai-generation-skill 生成图（SKILL.md:50）→ image-attachment 持久化（:46）→ image-review 固定 10 维质量门，输出**二值** APPROVED/CHANGES_REQUESTED + P0/P1/P2 缺陷级（image-review SKILL.md:9,43-46）。
- **7 技能逐查**（image-review/image-understand/prompt-master/agnes/restriction-patterns/image-attachment/prompt-corrector）：**无一**具备「需求清单输入→逐项判定」能力。image-understand 纯描述无判定（:82-96）；prompt-master 刻意二值化（:60 "binary where possible"、:317），SD (word:weight) 属**生成侧**权重非验收侧（:237）；image-review P0/P1/P2=缺陷严重度非需求权重（:46）。
- **缺口清单（六项）**：①需求结构化——无技能把复合需求拆为原子约束条目（存在性条目+程度条目）；②程度维度——全部检查项为存在性/合规性，1-5 显隐度/强度刻度零命中；③per-requirement 权重；④评分刻度——无「逐项 合格/部分/不合格 + 加权总分」；⑤需求输入契约——无机读需求清单格式（属性+类型[存在/程度]+权重+容差）；⑥断链环节——「需求清单+生成图→逐需求判定」在整个链路中不存在。
- **落点结论**：评级能力应落在 **task-planner 编排层**（计划期把需求拆解为带类型/权重/刻度的验收结构，产出机读验收契约），下游 image-understand（取描述证据）/image-review（质量门）作为判定执行工具被新 SOP 消费——不重复造轮子，补的是编排层断链。

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
- 仓内调研检查点：/mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/01-explore-repo.md（Rule 编号/级联面/先例）
- 外部技能调研检查点：/mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/02-explore-skills.md（7 技能 QC 现状+六缺口）
- 五维评分卡先例：/mnt/data/dev/task-planner-skill/skills/task-planner/references/methodology.md:193-212
- Rule 47 现文：/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:484-494；Rule 48 文尾=新块追加点 :504
- 级联锚点：selftest-plan-tier.sh:78（PT-08）/ selftest-conclusion-discipline.sh:66,69-70（CD-11）/ selftest-ask-default-timeout.sh:66-69（RT-08）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
