# 共享内容认领追踪区块模板（Rule 30 — task-v071）
<!--
  WHAT: 涉及可枚举共享资源（页面/内容/功能/部署位/文章）且本次只认领一部分的任务，
        在 task_plan.md 中引用本区块（拷贝本模板到 task_plan.md），并登记认领到
        项目级共享追踪账本（权威源 = progress-tracker 技能，账本 = 项目根平台配置目录
        `.zcode/ledger/` 或 `.claude/ledger/` 跟随既有，JSONL schema 见 progress-tracker SKILL.md）。
  WHY: 多任务部分认领同一批资源时，无共享追踪 → 后期重复混乱（已维护的功能又被手工重做/重写文档）。
  WHEN: 设计期（计划创建后 D1 批准前，Rule 30.1 识别命中时填写）；执行期按 30.3 翻状态。
  开关键: config.json#shared_tracker_enforce（默认 warn）。
-->

## 🔗 共享内容追踪（Rule 30）

| 字段 | 值 |
|------|-----|
| `shared_tracker` | `applied` / `not-applicable`（不命中 30.1 时填 + Decisions 记理由） |
| `ledger_path` | `<项目根>/<.zcode 或 .claude>/ledger/<topic>/<topic>.jsonl`（绝对路径） |
| `topic` | `kebab-case 主题名`（如 site-maintenance / feature-roadmap / content-batch） |
| `ledger_state` | `reused`（已存在账本，先查后写）/ `created`（本任务创建） |
| `claimed_targets` | 本次认领的资源项清单（target 1, target 2, …） |
| `claimed_status` | 各 target 当前状态（in_progress / done / blocked） |

**执行期维护（30.3）**：认领条目完成并验证后，账本对应 target 追加 `status=done` + 实际 `effect`，本区块 `claimed_status` 同步更新；悬挂条目（in_progress 超 1 个会话无进展）→ 收尾 Todo 提醒处置。
**防冲突（30.4）**：target 已被他 task 认领且 in_progress → D4 询问（等待/改认/接管登记），禁止静默重复认领。
