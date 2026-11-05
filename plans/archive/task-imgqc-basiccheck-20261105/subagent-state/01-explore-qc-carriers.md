# 检查点 01 · 图片 QC 门载体盘点与条款提取（sub:01-explore）
状态：完整（盘点→提取→缺口三段全落盘）

## 1. 文件清单 + 部署位对账
源仓 canonical：
- SRC /mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/image-generation-executor.md (md5 5a5810c6) — **无 47.6 QC 强制抽检门段**
- SRC video-generation-executor.md (md5 3caf3143) — 无 47.6 段
- media-planner/references/critical-rules-media.md 第21行 = Rule 47.6 全文（规则层载体，P0）
- media-planner/SKILL.md:32 指针行「47 媒体制作任务派发纪律 P0 → references/critical-rules-media.md」；SKILL.md 无 47.6 独立行
消费面定性（一句话）：
- image-review/SKILL.md = 图片质量门技能（十维度+AI 生成伪迹面「手指/文字乱码/结构错乱 P0」），47.6 质量门消费方，仅质量层，无常识层
- image-understand/SKILL.md = 视觉判读/取证工具（Read 读图），50.5 取证消费方，非判定器
部署位（逐位 grep 'QC 强制抽检门' 计数）：
- .zcode/agents、.claude/agents、.cursor/agents 各 image+video executor：含 47.6 段（计数=1）；与 SRC 漂移（md5 cd3f/60ea/2044；diff = 47.6 段 + 缺少 SRC 的 Rule 95.1/95.3 增量 + frontmatter 引号差异）
- .zcode/.claude/.cursor 的 skills/task-planner/companion/agents 副本：md5 与 SRC 一致（无 47.6 段，与 SRC 同源）
- 各仓 .backup/claude-stub-* 备份：与 2026-10-12 快照对齐，非现行消费面
结论：现行生效部署位=各 agents/ 目录（含 47.6 段）；SRC 落后于部署位；双向漂移。

## 2. 现行 QC 判定段逐字引用（锚）
(a) 部署位 image-generation-executor.md L67-73「QC 强制抽检门（Rule 47.6）」：
- 「图片交付前必须逐单元抽检：按 Rule 50.5 原子验收条目表判读 + 常识缺陷抽检：缺陷清单（H 级=禁交付）：解剖/透视（多肢体、手形畸变、透视崩坏）/ 文字乱码 / 主体错位」
- 「命中任一 H 级缺陷→按 47.5 自主迭代环重做（3 轮换一维），禁带病交付；3 轮不达标按 47.5 尾端带三件套上抛」
- 「抽检未完成=返回消息禁称 COMPLETE（Rule 51.2）」
(b) SRC image-generation-executor.md L17「三检闭环: 合规 / 一致性（逐字溯源，无法溯源=编造=FAIL）/ 质量（事实逻辑+解剖双硬+水印乱码+风格漂移）；缺检=不得验收/入台账/进下游」
(c) critical-rules-media.md L21 Rule 47.6 全文：图片常识缺陷清单=「解剖透视（多肢体/手形畸变/透视崩坏）/文字乱码/主体错位」；「命中任一 H 级缺陷=47.5 自主迭代环重做…抽检未完成禁交付」；规则层自注「SOP 文件侧联动属 §六 保护区，改动另需用户授权」
(d) L51 Rule 50.5：「image-understand 对生成产物取证（描述图中可见特征，不做判定）后由消费方按条目表逐条评级」

## 3. 缺口表 Q1-Q5
Q1 硬约束→可视觉判定检查项清单：部分。50.5 原子验收条目表机制存在（判读输入），但 47.6 图侧缺陷清单为封闭式 3 项（解剖/透视、乱码、主体错位），未强制「用户硬约束逐条转检查项+逐条核验」；「场景无人物」不在清单内→无强制覆盖。
Q2 常识/认知合理性检查：部分。47.6 有「常识缺陷抽检」之名，但图侧清单无「物理常识/空间布局/物件功能（门数/位置）」类目；「房车入户门两侧都有」=空间布局类，不在解剖/透视、乱码、主体错位任何一项→缺。
Q3 独立视角：无。QC=生成执行体自检（executor 自己 Read 图判读+自检三检）；image-understand 仅取证不做判定，无独立 QC 子代理/独立调用要求。
Q4 硬约束不满足=FAIL 禁放行：无明确条款。47.6 只有「H 级缺陷→47.5 重做」；「场景无人物」类硬约束的逐条判定与 FAIL 语义未成文（仅 50.5 条目表评级机制可借道，未强制接入 47.6 门）。
Q5 FAIL 后处置闭环：有（强制级）。47.5 自主迭代环（3 轮换一维→三件套上抛）+ 47.6「禁带病交付」+ 51.2「抽检未完成禁称 COMPLETE」+ image-executor L70「负结果报告：连续 2 件同维度 FAIL→HARD_BLOCK」。

## 4. 最终结论
- 缺陷 a（门两侧都有，空间布局常识）：**完全无覆盖**。47.6 图侧常识清单 3 项均不含空间布局/物件功能类；Q2 缺口直接命中。
- 缺陷 b（场景无人物，硬约束未满足判通过）：**无强制覆盖**。Q1/Q4 缺口——硬约束未转成逐条视觉核验项，47.6 门只把封闭式 H 级清单当闸口；50.5 条目表是借道通道但 47.6 未强制「条目表逐条 PASS 才放行」。
- 处置闭环（Q5）不是问题点，改造集中在：图侧常识清单扩容（空间布局/物件功能/场景约束类）+ 50.5 硬约束逐条核验强制接入 47.6 放行门。
- 改动注意：47.6 自注「agent SOP 文件侧联动属 §六 保护区，规则层以本条承载，SOP 文件改动另需用户授权」→计划改文件需注明授权前提；且 SRC 落后部署位（双向漂移），改后需重刷 6 个 agents/ 部署位 + skills/ 同源副本。
