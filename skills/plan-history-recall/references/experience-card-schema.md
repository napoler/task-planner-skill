# 经验卡 schema（experience-card）

history-miner 子代理产出的单任务经验卡契约，用于跨任务历史经验挖掘的证据化提炼。

## 落盘契约

- 路径：`cards/<task-id>.md`（由派发方指定目录下，随本轮调研产物落盘）
- 上限：**60 行/卡**（超限须压缩摘要，不得扩写）

## 九字段表

列定义为 字段 / 来源 / 说明（逐行来自 `plans/task-history-recall-20261116/design.md` §5）：

| 字段 | 来源 | 说明 |
|------|------|------|
| task_id | 目录名 | 全局连接键 |
| outcome | task_plan.md frontmatter/progress | complete/pending/in_progress/cancelled |
| goal_摘要 | task_plan.md Goal 段 | ≤3 句 |
| 关键决策 | Decisions Made 表 | 决策+理由，保留用户裁决原话要点 |
| 成功要素 | progress [goal:Gn] 证据行+VC 通过记录 | 什么做对了 |
| 失败教训 | progress Error Log（Root Cause/Prevention 列） | 犯错+根因+防复发 |
| 可复用资产 | progress/交付记录 | 脚本/模板/规则条款/技能产出 |
| 用户偏好信号 | user-session-log.md | 逐字裁决摘录 |
| 证据锚 | 全部来源 | 文件路径+行号/commit 列表 |

## 证据锚格式

- 统一使用相对仓根路径：`plans/.../<file>.md:<行号>`（单点）或 `plans/.../<file>.md:<起>-<止>`（区间）；git 提交证据写 `commit <8位sha>`。
- 每个字段必须给出对应证据锚；派发方将盘上抽查，路径与行号须可定位到真实内容。
- 多来源用 `; ` 分隔，同一字段内证据锚与结论一一对应。

## 禁脑补条款

- 无锚字段不得编造，须明确标注「未查到」并写明已查范围（查过哪些文件/grep 关键词/commit 范围）。
- 所有摘要必须摘录或压缩自源文档原文/结构化记录，禁凭目录名、task_id 命名或常识脑补内容。
- 任务与本次调研主题弱相关时，须在卡内注明「弱相关」及判定依据（证据锚），不得强行拔高为成功/失败样本。

消费方=plan-history-recall 技能（引用路径 skills/plan-history-recall/SKILL.md）