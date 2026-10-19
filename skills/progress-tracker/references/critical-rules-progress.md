# Critical Rules — progress-tracker（共享内容认领）

> 域=共享内容认领。
> 本文件为 progress-tracker 卫星技能规则全文，从核心 task-planner `skills/task-planner/references/critical-rules.md` 逐字迁移（标题统一为 `### N 标题`，正文一字未改）；源行区间以 `plans/task-v171-skill-specialization/design-architecture.md` §1 progress-tracker 表为准。
> 本批次（task-v171 S29）落盘 1 条：Rule 30（源行区间 308-317）。
> 源文件核心 critical-rules.md 原文在本批次不删（删除由后续「核心瘦身」阶段统一执行）。

### 30 共享内容认领追踪（P0 — task-v071，目标：跨任务复用进度，杜绝重复混乱）

「缺→补」（Rule 19）与「多→退场」（Rule 29）之外，补齐「共→认领」链路：涉及可枚举共享资源（页面/内容/功能/部署位/文章）且本次只认领一部分的任务，须在项目级共享追踪账本上登记认领，后续同类任务先查账本复用而非重建。

30.1 **识别条件（设计期，计划创建后 D1 前）**：目标资源可枚举（维护 N 个页面/内容/功能/部署位/文章）且本次任务只认领其中一部分 → 命中共享追踪场景；同类任务已发生 ≥3 次（可查 plans/INDEX 或账本）亦命中。命中 → 执行 30.2；未命中（一次性/资源不可枚举）→ 记录 Decisions Made 一行 `共享追踪不适用,<理由>`,跳过本 Rule。
30.2 **创建/复用（权威源 = progress-tracker 账本，不另造文件）**：账本位置 = 项目根平台配置目录（跟随既有 `.zcode/` 或 `.claude/`，皆无默认 `.zcode/`）下 `ledger/<topic>/<topic>.jsonl`（topic=kebab-case，如 site-maintenance）。**存在** → 先 Read 该主题账本（先查后写，grep 本次认领 target 最近记录），只追加/更新本次认领行，禁止覆盖历史；**不存在** → 按 `Skill("progress-tracker")` Step 1-4 创建（INDEX.md + 主题目录 + JSONL 首条）。账本被项目 gitignore 忽略 → 记「账本未入库」一行提醒，不阻塞。
30.3 **认领登记**：本次认领的每个 target 追加一条 `status=in_progress` 条目（`note` 字段写认领 task-id），并创建收尾 Todo（progress-tracker 闭环保障）；该 target 完成并验证后 → 追加 `status=done` + 实际 `effect`，完成 Todo。禁止认领后静默悬挂（悬挂条目 = 后期误判"未完成"重复做的根因）。
30.4 **防冲突**：发现 target 已被其他 task 认领且 `status=in_progress`（note 含他 task-id 且 ts 更新）→ 不静默重复认领，按 Rule 28 D4 询问（选项：等待/改认领其他/确认接管并登记）；ts 最早 + task-id 为归属依据。
30.5 **机制**：开关键 `../../task-planner/config.json#shared_tracker_enforce`（默认 warn：设计期检查点注入提醒；off 不触发；enforce 预留）；`../../task-planner/scripts/selftest-shared-tracker.sh` 静态守护（30.x 条款存在性 + 语义锚点 + config 键 + 模板 + progress-tracker 技能探针）；模板 `../../task-planner/templates/shared-tracker.md` 供 task_plan 认领追踪区块引用。协同契约详见 `../../plan-collab-router/references/skill-collaboration.md` progress-tracker 行。
