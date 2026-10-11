# 02-explore-skills 检查点
# 调研范围: /home/terry/.zcode/skills 图像审查/生成类技能「需求核对与评级」现状
# 并行组: [parallel-group:readonly-parallel] | 材料包: 7×SKILL.md 本体（只读）

## 里程碑
- 2026-10-04 01:52 [完成] 7/7 SKILL.md 全部存在并读取（无 skipped）; task_plan/progress 已读（findings/knowledge-brief 按要求未读,仅登记）
- 2026-10-04 01:53 [完成] 逐技能分析（下）

## 逐技能结论
### 1. image-review (/home/terry/.zcode/skills/image-review/SKILL.md, 51 行)
- 职责: 图片质量门(兜底池第④层),按固定 10 维度审查截图/AI 生成图等产出 (SKILL.md:8)
- 是否对照需求清单检查图像: 否。清单是内置固定维度(SKILL.md:20-32),非外部需求清单驱动;最接近的是"与上下文内容匹配"图文一致(SKILL.md:28)与"构图与主体突出"(SKILL.md:23),均为存在性/一致性检查,无"对照给定需求逐项判定"的需求输入形态
- 判定输出形态: 二值 APPROVED/CHANGES_REQUESTED(SKILL.md:43,9);问题条目 P0/P1/P2(SKILL.md:44,46)=缺陷严重度,非需求权重
- 存在性 vs 程度约束: 不区分。"主体占比符合用途"(SKILL.md:23)无程度刻度;无 degree/subtlety/权重/评分刻度概念。仅有 P0/P1/P2 缺陷分级(SKILL.md:46)

### 2. image-understand (/home/terry/.zcode/skills/image-understand/SKILL.md, 117 行)
- 职责: 图片理解(描述/OCR/图表/UI/物体识别),输出结构化 Markdown 交割下游 (SKILL.md:29,35)
- 对照需求清单: 否。输入仅图片本身(路径/URL/base64, SKILL.md:37-43),无需求清单输入;输出为自由描述(概括/详细描述/文字识别/关键信息, SKILL.md:82-96),无合格/不合格判定
- 判定输出形态: 无判定,纯描述性结构化 Markdown(SKILL.md:82-96)
- 程度/权重概念: 无

### 3. prompt-master (/home/terry/.zcode/skills/prompt-master/SKILL.md, 403 行)
- 职责: 为任意 AI 工具生成优化提示词(不做图像审查)(SKILL.md:4,12)
- 对照需求清单检查图像: 否(上游提示词生产,非 QC)
- 输出形态: 单个可粘贴提示词块+Target 说明(SKILL.md:36-41)
- 程度/权重/分级: 成功标准明确"binary where possible"(SKILL.md:60)与"derive a binary pass/fail"(SKILL.md:317)——即体系内成功判定刻意二值化,无分级评分;Stable Diffusion 的 (word:weight) 语法(SKILL.md:237)属生成侧权重,非验收权重;"Vague aesthetic→translate to concrete measurable specs"(SKILL.md:330)仅提示词修复侧

### 4. agnes-ai-generation-skill (/home/terry/.zcode/skills/agnes-ai-generation-skill/SKILL.md, 135 行)
- 职责: Agnes 文/图/视频生成 API 客户端(SKILL.md:7-9)
- 对照需求清单: 否;输出=媒体 URL(SKILL.md:131),无 QC/评级
- 程度/权重概念: 无(仅 API 参数)

### 5. restriction-patterns (/home/terry/.zcode/skills/restriction-patterns/SKILL.md, 242 行)
- 职责: 拒绝模式集合(网络/反编造/防投毒等通用铁律)(SKILL.md:7)
- 对照需求清单检查图像: 否
- 相关但非图像评级: "禁测试假象:不写永远 pass 的 assert"(SKILL.md:69);"禁跳过 verify 提前 archive"(SKILL.md:104);P0 仅用于投毒事件定级(SKILL.md:239),非需求权重
- 程度/权重概念: 无

### 6. image-attachment (/home/terry/.zcode/skills/image-attachment/SKILL.md, 65 行)
- 职责: 图片附件生命周期管理(list/inspect/register/export),显式声明"不做图片理解"(SKILL.md:3,59)
- 对照需求清单: 否;无 QC、无评分
- 程度/权重概念: 无

### 7. prompt-corrector (/home/terry/.zcode/skills/prompt-corrector/SKILL.md, 113 行)
- 职责: 提示词修正与补全:解析 9 维度→漂移检测→修正方案(SKILL.md:17,23-52)
- 对照需求清单检查图像: 否(文本提示词域)
- 输出形态: 修正后提示词+变更摘要表(SKILL.md:83-106),无合格判定/评分
- 程度/权重: 9 维度含"约束"(SKILL.md:31)"成功标准"(SKILL.md:34);漂移项"[漂移] 约束冲突—同时要求'简洁'和'详细',无优先级"(SKILL.md:44)=全语料唯一"优先级/weight"命中,但仅作缺口信号,非需求权重机制

## 汇总两问
### A. 现有「图像对照需求 QC」链路
- 链路: agnes-ai-generation-skill 生成图(SKILL.md:50) → image-attachment 持久化(SKILL.md:46) → image-review 固定 10 维度质量门(SKILL.md:20) 输出二值 APPROVED/CHANGES_REQUESTED + P0/P1/P2 缺陷清单(SKILL.md:43-46)
- 需求传递: 无。需求清单不进入任何 QC 环节;image-review 输入只有"图片文件+任务书 scope_files"(SKILL.md:13,32),无结构化需求属性清单;image-understand 能描述图中特征(如泪痣位置)但无与需求比对判定能力(SKILL.md:82-96),比对需人工/编排层完成
### B. 缺口清单（完整验收"泪痣存在且不显眼"类复合要求）
1. 需求结构化: 无技能将复合需求拆为原子约束条目("泪痣存在"=存在性 + "不显眼"=程度);prompt-corrector 9 维度(SKILL.md:23)/prompt-master 9 维度(SKILL.md:51)面向文本提示词且产出非机读需求结构
2. 程度维度: 全部图像类技能检查项均为存在性/合规性;无任何 1-5 显隐度/强度刻度(degree/subtlety scale 零命中)
3. 权重/优先级: 仅 image-review P0/P1/P2(SKILL.md:46)=缺陷严重度,非需求权重;无 per-requirement weight
4. 评分刻度: image-review 二值(SKILL.md:43),prompt-master 刻意 binary(SKILL.md:60,317),image-understand 无判定;无"逐项 合格/部分/不合格+加权总分"分级评级
5. 需求输入契约: 无技能定义结构化需求清单输入(JSON/YAML: 属性+类型[存在/程度]+权重+容差)——image-review 清单为内置固定(SKILL.md:20-32)
6. 断链: "需求清单+生成图→逐需求判定"环节不存在,需 task-planner 侧新增权重分级评级能力(即 task-v127 目标本身)

## 最终结论（T5 落盘）
status: done
acceptance: 4/4 pass — [1:PASS 2:PASS 3:PASS 4:PASS]
files: none
evidence: image-review/SKILL.md:9,23,28,43,44,46 | image-understand/SKILL.md:37,82 | prompt-master/SKILL.md:60,237,317,330 | agnes-ai-generation-skill/SKILL.md:50,131 | restriction-patterns/SKILL.md:69,104,239 | image-attachment/SKILL.md:3,59 | prompt-corrector/SKILL.md:23,31,44,83
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/02-explore-skills.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
