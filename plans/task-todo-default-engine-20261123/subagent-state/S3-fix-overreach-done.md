# S3-fix-overreach checkpoint

## status
done

## action
- Target: `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`
- Read boundary: lines 355-375 (cat -n) confirmed overreach block starts at "默认文件系统读写对照表..." and ends at "一句话规则..." (lines 358-372 in original numbering context, block removed).
- Edit: deleted the full unauthorized "默认文件系统读写对照表（唯一权威，2026-11-23...）" section including table and trailing "一句话规则" blockquote.
- Preserved: line 256 `B1-B8` replacement untouched.

## acceptance
- `wc -l` = 461 (<=470, target 461) PASS
- `grep -n '默认文件系统读写对照表\|一句话规则'` => exit 1, no output PASS
- `grep -n 'B1-B8'` => line 256 hit PASS
- Read-back lines 352-362 show clean paragraph join, no anchor swallowed PASS

## evidence
```text
$ wc -l /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
461 /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md

$ grep -n '默认文件系统读写对照表\|一句话规则' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md; echo "---exit:$?---"
---exit:1---

$ grep -n 'B1-B8' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
256:计划文档=唯一事实源，原生 Todo（`TodoWrite`/Task）=执行视图。五个强制同步时机：**S1** 计划创建后建映射→**S2** Phase 状态变更后紧邻同步→**S3** `[plan-sync]` hook 提醒立即回写→**S4** 会话结束前终态同步+`--index`→**S5** 用户新指令影响计划后先改计划再重映射。映射规则与响应协议详见 `references/todo-sync.md`。S1 两组结构（任务组+基线组 B1-B8，Rule 106.5）详见 references/todo-sync.md

$ sed -n '352,362p' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
## 结构化状态操作 SOP（JSON 权威源）

> [2026-11-21 task-json-state-20261121] 结构化状态升级硬条款；与上文「派发与执行纪律指针」并列，适用于所有使用 task-planner 的计划目录。

- **权威源声明**：`<plan-dir>/plan-state.json` 是任务状态**唯一权威源**，承载全部语义数据（Phase/VC/审计/派发 + Actions/Error Log/Test Results/Research/Decisions/Issues/S-units/FMEA 等全部语义段，2026-11-22 task-jsonderive-deploy-20261122 全量扩张）；`task_plan.md` / `progress.md` / `verification.md` / `findings.md` 是由 `planctl.py render` 从 JSON **全量派生**的只读视图。
- **硬规则（违反=流程无效）**：所有状态与语义数据变更**必须**通过 `python3 <skill>/scripts/planctl.py <subcommand>` 完成（`<skill>` = 本技能根目录，脚本绝对路径 `scripts/planctl.py`）；**四个 MD 视图一律不得手工 Edit/Write**——手工编辑会在下一次 `render` 被全量覆盖（软堵：render 覆盖使直接编辑无效，用户裁决 2026-11-22）。语义内容（动作/错误/测试/结论/决策/证据）同样走 CLI 入 JSON 再 `render` 同步视图。
- **常用命令速查**（每条均需追加 `--plan-dir <plan-dir>`）：
  - 初始化：`init --task-id <id> --tier standard --lane L1 [--template-body-from <模板文件>]`（tier 可选 standard/mini；lane 可选 L0/L1/L2；state 已存在则拒绝覆盖；init 只建权威源不 render，首次数据写入后必须 render；`--template-body-from` 把所选 variant 模板正文写入 plan-state.json 的 `template_body` 可选字段，供 render 领域段附录消费，mini 档豁免）
  - 读取：`get`（整份）/ `get --section <section> --id <id>` / `status` / `validate`
  - 改字段 / 增条目：`set --section <s> --id <id> --field <f> --value <v>` / `add --section <s> --json '<JSON>'`（另有 `update` / `delete`；`set` 不带 `--section` 可写顶层标量/对象字段）
```

## files
- `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` (modified, overreach table removed)
- `/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S3-fix-overreach-done.md` (checkpoint written)

## findings_written
- `/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S3-fix-overreach-done.md`

## blockers
none

## confidence
high
