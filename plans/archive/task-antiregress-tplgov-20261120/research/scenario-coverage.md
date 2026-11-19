# 场景覆盖缺口盘点（VC-09 数据产物，2026-11-20 主进程 S7-数据侧）

> 数据源：plans/*/task_plan.md 与 plans/archive/*/task_plan.md 的 `template_type:` 行实测（grep+uniq）；variant 清单=templates/variant/ ls 实测。本文件为 S7 补缺候选的数据依据，不拍脑袋。

## 一、任务类型分布（实测计数）

| 来源 | template_type | 次数 |
|------|--------------|------|
| plans/ 活跃（14 计划） | general | 8 |
| plans/ 活跃 | rule-enhancement | 5 |
| plans/ 活跃 | l0-lite | 1 |
| archive（79 计划） | general | 51 |
| archive | rule-enhancement | 25 |
| archive | skill-enhancement | 1 |
| archive | refactor | 1 |
| archive | deployment | 1 |

**集中度**：general 59/93（63%）+ rule-enhancement 30/93（32%）= 95%。

## 二、31 variant 使用对照

- 本仓高频：rule-enhancement（30）✓有专用 variant；general（59）=兜底承载。
- 本仓零使用但存在（13 个媒体/剧本类：audio-voice/character-design/final-assembly/image/motion-camera/multiview-ref/physics-compliance/prompt-struct/storyboard/video-fix/video-prompt/video/writing）：服务其他项目（videop1 等）的项目级部署面，非本仓缺口，不入选。
- 有实配记录但**无专用 variant**：**skill-enhancement**（archive 1 次 + 本仓大量同类主题任务走 general/rule-enhancement 兜底）→ 唯一数据支持的补缺候选。

## 三、补缺候选登记（决策点，含依据）

| 候选 | 数据依据 | ROI 判定 | 本轮处置 |
|------|---------|---------|---------|
| skill-enhancement-type.md | archive 实配 1 次；本仓任务主题（技能治理/条款落地/机制升级）高频走 general 兜底——计划目录名 grep `task-(v1|tpl|skill|clause|auditgate|ctxcorrect|dualqc|finalrecall|subagent|drift|anticheat|antitamper)` 系列即 20+ 件同类主题 | 中高（复用 rule-enhancement 结构+技能面特化字段，≤100 行） | **候选入选待用户批准后实施**（新增模板=高影响面，遵循计划 R3 决策点：频率+ROI 达标，但新增仍属面扩张，用户批准后落 S7-S2） |
| 其余 30 variant | 无频率缺口证据 | — | 不新增 |
| general 兜底 59 次 | 缺口在选择机制不在缺模板 | — | 由 R3「general 须登记理由」链对症（S7-脚本侧） |

## 四、结论

1. 本仓 variant 覆盖面对历史任务分布的**真实缺口=1**（skill-enhancement）。
2. 主痛点=general 兜底占 63% 且静默无理由——R3 登记理由链（S7-脚本侧 init-session/check-complete/advisor 接线）是正解，已列 S7 范围。
3. skill-enhancement-type 新增遵循 Rule 34.4（≤100 行+Decisions 登记），**待用户批准**后作为 S7 附带交付；不批准则登记为后续建议（VC-10 要求的"登记非拍脑袋"已满足）。
