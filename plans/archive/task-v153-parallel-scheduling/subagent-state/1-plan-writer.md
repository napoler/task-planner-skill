# plan-writer Checkpoint — task-v153-parallel-scheduling

## 里程碑：frontmatter+需求区
- frontmatter 键齐（template_type/new_rule/isolation/code_review/interaction_mode/parallel_groups/session_id/plan_tier）
- 用户需求原文 R1-R7 逐条抄录含 [目标] 标注
- R→VC 映射表 7 行完整

## 里程碑：VC 表
- VC-a 至 VC-h 八条判定标准+验证方式+证据路径
- 终验规则三态（COMPLETE/PARTIAL/BLOCKED）
- 核心目标裁决区块（58.5）占位

## 里程碑：Phase 骨架
- Phase 1-5 各有 Status+Executor 字段
- Phase 1 plan-writer(sonnet-1) / Phase 2 主进程 / Phase 3 主进程 / Phase 4 code-runner-agent+Code Reviewer+alignment-review / Phase 5 主进程
- 每 Phase ≥2 条 V-N 映射 VC 编号

## 里程碑：S-unit 表
- 7 行（S1-S7）列全：ID/目标/执行体/输入/验收/预估时长/粒度三值/伴飞技能/状态
- p3-core={S1,S2,S3} / p3-guard={S4,S5} / p3-docs={S6} / S7 串行尾
- 组内异构：p3-core sonnet-1+haiku-1 混；p3-guard sonnet-1+haiku-1 混
- 组域写隔离协议行（68.4）在位
- 单元组标记段落含依赖推导说明

## 里程碑：尾部区块
- 隔离决策/FMEA/原生 Todo 同步/Key Questions/Decisions Made/Errors/Notes/Drift Log/Batch Report/委派统计/Handoff 表/Chain 区块/模板感知 全部在位
- FMEA 7 行含 RPN>100 兜底动作
- Decisions Made 6 行含 p3-guard 异构修正说明

## 完成状态
- 行数=361（≤700 PASS）
- 圆圈序号/行首编号/step类字样=0（PASS）
- 验收逐项自检全部 PASS
- task_plan.md 产出完毕
