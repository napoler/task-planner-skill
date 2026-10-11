# Drift Check — task-v150-split-skill-integration / Phase 1

**status:** done
**role:** drift-checker（Rule 61 载体的改派执行体；只读检测，未修改任何仓库文件）
**checked_at:** 2026-10-08
**scope:** Phase 1（调研落盘与基线）目标对齐三态判定

---

## 检查输入摘要（Rule 64.4 三锚）

### 锚 1 — Goal 原文（task_plan.md `## Goal`）
「将池内 8 个高价值技能（writing-plans / subagent-driven-development / dispatching-parallel-agents / brainstorming / sub-agent-protocol / task-drift-guard / skill-handoff / skill-skill-tool）中「任务拆分」相关已验证实践集成为 `references/split-pattern-library.md`，以 Rule 21.6（纯增量子条）接入计划期拆分决策链，使 S-unit 拆分从纯数值上限升级为「数值硬门 + 模式库定性判据」双层；回归无新增 FAIL，部署位同步 IDENTICAL。」

### 锚 2 — 近期动作（progress.md Phase 1 段）
- Explore#1 池内 22 技能盘点 → 8 高价值吸收源 + Top10 排序（Handoff#1，findings §R2）
- Explore#2 仓内拆分机制 12 项锚点盘点（Handoff#2，findings §R1）
- 主进程 Read critical-rules.md:130-204 复验 Rule 21 区段（21.5=:159，`### 22`=:160）
- attest 锁定（SHA afc4673d，四门控：template/requirement/fmea OK，rule-reserve fail-open）
- /goal 锚定登记（A 类）+ findings.md/knowledge-brief.md 回填（含设计契约 §5）
- 全量 selftest 基线：62 脚本，61 rc=0，periodic-review 4 FAIL（已知基线）→ baseline-selftest.log

### 锚 3 — scope 文件集（task_plan.md「执行范围限制」表）
`skills/task-planner/references/split-pattern-library.md`(新) / `references/critical-rules.md`(仅追加 21.6) / `SKILL.md`(≤4 锚) / `templates/subagent_dispatch.md`(+1 行) / `scripts/selftest-split-pattern-library.sh`(新) / `CHANGELOG.md`(+1 条)；簿记 `plans/task-v150-split-skill-integration/**`。Phase 1 实际写入 = 计划目录内文件（task_plan/findings/knowledge-brief/progress/baseline-selftest.log/ledger/attest）。

---

## 比对结论（三锚一致性）

| 比对项 | 证据 | 判定 |
|--------|------|------|
| Goal 方向 vs Phase 1 动作 | 动作=调研/锚点复验/契约冻结/基线，均为 Goal 落地的计划期前置；无方向分叉、无破坏性动作 | 一致 |
| Phase 1 声明 vs task_plan Phases | task_plan Phase 1 六条 [x] + Status=complete，与 progress.md Phase 1 段逐条对应 | 一致 |
| 基线数字 | `baseline-selftest.log`：rc=0 计 61、rc=1 计 1（selftest-periodic-review.sh PASS=6 FAIL=4）、末行 TOTAL=62 —— 与声称「62 脚本：61 rc=0 + periodic-review 4 FAIL」完全吻合 | 一致 |
| 调研证据面 | findings §R1/§R2/§约束面 三方证据面齐备；knowledge-brief §2/§3/§5 与 findings 行号锚一致 | 一致 |
| scope 交付文件是否被越界改写 | `git status --short skills/ CHANGELOG.md` 为空；master 内 critical-rules.md `21.6` 命中 0、split-pattern-library.md 不存在 —— 交付面文件按计划留待 Phase 3 worktree，Phase 1 未触碰 | 一致（无越界） |
| 编号纪律 | plans/.rule-reservations.jsonl 新增行=Rule 65 reserved by task-v149（非 v150）；v150 走 21.6 子条未占新号 | 一致 |
| 关键路径 | 调研→设计契约冻结→worktree 建前基线的路径未被跳过；Phase 2 已 in_progress | 一致 |

### 观察项（非漂移，登记备查）
1. **attest SHA 口径**：progress.md/findings.md 记「重锁 SHA afc4673d」，而 `.plan-attestation` 现值 `plan_sha256=bb163e15…`（attested_at=23:57:55）。系 afc4673d 锁定后计划文本又有编辑并再次 attest 所致；afc4673d 为历史中间锁，当前锁未在计划文本同步登记。属簿记口径滞后，非范围/方向问题。
2. **plan-system 系统文件变更**：`git status` 另见 `M plans/.active_plan`（切至 task-v150）与 `M plans/.rule-reservations.jsonl`（v149 的 Rule 65 预留行）。二者为 plans/ 根级计划系统登记文件（非「其他 plans/ 目录」），属计划系统常规操作，不在任务交付 scope 内，亦未触及任何实现面文件。

### 三态判据核对
- 改 scope 外**交付**文件：无（仅 plans/ 根系统文件 churn，属计划系统自有登记）
- 做的事与 VC 不符：无（Phase 1 动作对齐其声明的 VC-4 基线可对照 / VC-1 调研证据面齐备）
- 跳过关键路径：无（方向分叉/破坏性动作均未出现）

---

**verdict:** ALIGNED
