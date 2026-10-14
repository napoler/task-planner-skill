# Findings — task-v069 上下文与工作文件主动维护（Rule 29）

## Research Findings

### 调研结论（Explore 子代理，2026-09-14）

**现有"缺→补"链路完整，"多→删"链路完全空白**——这是本任务的设计依据。

| 机制 | 位置 | 判定 |
|------|------|------|
| Rule 19.7 [plan-compass] 陈旧回填链 | zcode-posttooluse.sh:171-226 | 部分覆盖（只管补写，不管退场/压缩）|
| check-doc-sync.sh task_plan 陈旧度 | check-doc-sync.sh:54-59 | 部分覆盖（手动检测器，无自动动作）|
| check-3file-gate.sh stale 阈值 | check-3file-gate.sh:62-63 | 部分覆盖（Phase complete 门控，非上下文卫生）|
| Rule 19.6 task_plan 瘦身 | critical-rules.md:95 | 部分覆盖（单文件膨胀，无机械检查器）|
| set-active-plan.sh gc 24h TTL | set-active-plan.sh:125-143 | 已覆盖（仅指针类小文件，不碰任务目录）|
| reference.md Compaction 段落 | reference.md:88-100 | 部分覆盖（纯文字描述，无机制）|
| plans/ 任务目录清扫 | 无 | **未覆盖**（plan-created.cjs:122 有 archive 前缀跳过约定，但无生成方）|
| INDEX.md 统计修正 | sync-todos.sh --index（全量重写） | 部分覆盖（无"修正"语义，归档后必须重跑）|
| worktree 遗留清扫 | check-conflicts.sh 信号②③（只检查不执行）| **未覆盖**（无 git worktree prune 调用）|

### 关键编号事实
- Rule 29 编号未被占用（全仓 grep "Rule 29" 零命中，critical-rules.md 止于 :226）
- Rule 19 子条款 19.7/19.8 顺序已乱（19.8 在 19.7 之前，:90-97），新追加放 19.7 行之后
- config.json 29 顶级键，additionalProperties:false（:347），新键必须注册进 .properties
- 13 个 selftest 基线 213/0（v068 后）
- plans/INDEX.md: complete=35, in_progress=0, pending=0（全部陈旧样本）

## Technical Decisions

| 决策 | 理由 |
|------|------|
| 机制化深度选 B 档 | 用户裁决；R29 + 2 脚本 + 3 config 键 + 1 selftest，约 4 Phase 40-60min |
| 归档策略"年龄阈值+手动确认" | 用户裁决；completed 且超过 plan_archive_age_days（默认 7 天）→ 建议归档；脚本默认 --dry-run |
| check-context-hygiene.sh exit code | 0=clean / 1=有退场建议（superseded 未压缩）/ 2=严重（stale 占比>50%）|
| plan-hygiene.sh 归档目标 | plans/archive/<task-id>/（plan-created.cjs:122 已有消费侧约定）|
| 部署 3 实体位用定向 cp | 记忆 sync-companion 反向拉回陷阱；部署后 diff -r 复验 |
| R29 子条款体系（29.1-29.6）| 29.1 触发时机 / 29.2 退场 SOP / 29.3 压缩 SOP / 29.4 工作文件整理 SOP / 29.5 配置键语义 / 29.6 反模式 |

## Resources

- references/critical-rules.md:218-226（Rule 28 末尾，Rule 29 追加位置）
- skills/task-planner/config.json:347（additionalProperties:false 行）
- scripts/plan-created.cjs:122（archive 前缀跳过约定）
- scripts/set-active-plan.sh:125-143（gc TTL 模式参考）
- scripts/selftest-methodology.sh:47-95（selftest 范本）
- plans/INDEX.md:10-44（35 completed 任务目录清单）

## Issues Encountered

| Issue | Resolution |
|-------|-----------|
| check-plan-dispatch.sh 报"缺 S-unit 表"（Phase 1/2/3）| 根因：S-unit 表头第一列必须叫 "ID" 而非 "S-ID"；脚本 :109-114 匹配字面量 `\| ID \|` 开头。已修正全部 4 处表头为 `| ID |`，重跑 exit 0 |
| init-session.sh 须在 plans/<task-id>/ 目录下运行 | cd 到目录后再运行，已解决 |

## 终验补充结论（09-14 Phase 5）

- Code Review Gate（agent_7e4493cd）APPROVED：P0/P1 零发现；P2×3 已修（commit 326f44f）
- 合并路径：主仓 config.json 未提交变更触发 smart-merge-back V3 SCOPE_OVERLAP → 先 commit 主仓 config（37c2107）→ git merge --no-ff 8778ff8（worktree 4 提交 08846a2/fade783/a9aa789/326f44f 一次并入）
- 部署 3 实体位定向 cp 后 diff -r 全一致（0 差异）；部署位实测 check-context-hygiene.sh exit=1（预期）
- 归档实跑：plans/ 下 35 completed 目录中 21 个 mtime>7d 归档入 plans/archive/，14 个（含 v059/v065-v068 近期）保留；INDEX.md 重刷 = in_progress:1（task-v069 自身）complete:14
- 全量回归终验：存量 13 selftest 213/0 + selftest-context-hygiene 12/0 = 225/0，无新增 FAIL
