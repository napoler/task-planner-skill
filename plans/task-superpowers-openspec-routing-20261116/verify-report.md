# Verify Report — task-superpowers-openspec-routing-20261116

- 复检时间：2026-11-16
- 隔离区（worktree）：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116`
- 分支/提交：`wt/task-superpowers-openspec-routing-20261116` @ `54ec525`
- 受检文件：`skills/task-planner/SKILL.md`、`skills/task-planner/references/spec-mode.md`、`skills/plan-collab-router/references/skill-collaboration.md`
- 约束：只读受检产物；仅写本报告；未修改三受管文件/部署位/plans 其他文件

## 1) VC 机械面实测（worktree 内）

| VC | 命令 | 输出摘要 | 退出码 | 判定 |
|---|---|---|---|---|
| VC-1a | `cd <wt> && grep -q "复杂度分档→族选择" skills/task-planner/references/spec-mode.md` | (无输出，匹配命中) | 0 | PASS |
| VC-1b | `cd <wt> && grep -q "L1（中等）且无规格留存需求" skills/task-planner/references/spec-mode.md` | (无输出，匹配命中) | 0 | PASS |
| VC-1c | `cd <wt> && grep -q "L2+ 或规格留存需求" skills/task-planner/references/spec-mode.md` | (无输出，匹配命中) | 0 | PASS |
| VC-1d | `cd <wt> && grep -q "择一语义" skills/task-planner/references/spec-mode.md` | (无输出，匹配命中) | 0 | PASS |
| VC-2a | `cd <wt> && grep -q "复杂度主轴初筛" skills/plan-collab-router/references/skill-collaboration.md` | (无输出，匹配命中) | 0 | PASS |
| VC-2b | `cd <wt> && grep -q "覆盖复杂度初判" skills/plan-collab-router/references/skill-collaboration.md` | (无输出，匹配命中) | 0 | PASS |
| VC-3 | `cd <wt> && grep -q 'spec-mode.md` §1b' skills/task-planner/SKILL.md` | (无输出，匹配命中) | 0 | PASS |

**VC 机械面总判定：PASS（7/7）**

## 2) 语义面复核（基于 Read 的 file:line 证据）

### 2.1 与权威源一致
- **判定：PASS**
- 证据：
  - `skills/task-planner/references/spec-mode.md:18`：`### 1b. 复杂度分档→族选择决策表...`
  - `skills/task-planner/references/spec-mode.md:19`：`> 判据裁决... 本表与 plan-collab-router 权威源 \`skill-collaboration.md\` §二触发矩阵同构互引，冲突以权威源为准。`
  - `skills/plan-collab-router/references/skill-collaboration.md:51`：`## §二 协同路由触发矩阵（D1）`（spec-mode 指向的权威源 §二真实存在）
  - `skills/plan-collab-router/references/skill-collaboration.md:55`：`**复杂度主轴初筛...** ... 分档细则与择一语义见 task-planner \`references/spec-mode.md\` §1b（同构互引，冲突以本表为准）。`
  - 双向互指成立：`spec-mode.md:19` → 权威源 `skill-collaboration.md §二`；`skill-collaboration.md:55` → `spec-mode.md §1b`；且各自声明冲突裁决方向（spec-mode 侧“冲突以权威源为准”，权威源侧“冲突以本表为准”用于初筛段）互指真实、无悬空引用。

### 2.2 择一语义无歧义
- **判定：PASS**
- 证据（均来自 `skills/task-planner/references/spec-mode.md` §1b）：
  - 同任务同阶段择一主导：`:28` `**择一语义**：同任务同阶段在 Superpowers 与 OpenSpec 之间**择一主导**（防双真源双计划）；`
  - 跨阶段可切换：`:28` `跨阶段可切换（brainstorming 收敛后转 \`openspec-propose\`，即 §1 既有路由）。`
  - L0 豁免：`:23` `| L0/mini（小任务） | 不路由，直执行 | 现行豁免不变 | 免仪式（§1 触发判定同口径） |`，且 `:7` 触发判定亦声明 `mini / L0-T / L0-E 豁免`。
  - 信号修正可覆盖初判：`:26` `| 信号修正（覆盖复杂度初判） | 触及已有 spec→OpenSpec；bug 排查→systematic-debugging（superpowers 单技能嵌入）；跨会话托管→comet | 按修正信号路由 | 多族命中=叠加协同；判定顺序 comet→OpenSpec→superpowers（权威源 §二） |`
  - 四档映射互斥覆盖：`:23` L0/mini 不路由；`:24` L1 且无规格留存需求→Superpowers 嵌入；`:25` L2+ 或规格留存需求→OpenSpec 移交；`:26` 信号修正覆盖初判。与权威源 `skill-collaboration.md:55` 初筛口径一致（L0/mini 直执行；L1 无规格留存→superpowers 嵌入；L2+ 或规格留存→OpenSpec 移交；跨会话托管→comet；信号修正可覆盖）。

### 2.3 调用形态一致
- **判定：PASS**
- 证据：
  - `skills/task-planner/references/spec-mode.md` 引用成员：`:12` `brainstorming`/`writing-plans`；`:13` `openspec-propose`；`:14` `openspec-explore`；`:15` `openspec-apply-change`/`openspec-verify-change`；`:16` `writing-plans`；`:24` `brainstorming→writing-plans→executing-plans/TDD/systematic-debugging/审查`；`:25` `openspec-propose→apply→verify→archive`；`:26` `systematic-debugging`；`:33` `using-superpowers`/`brainstorming`。
  - `skills/task-planner/SKILL.md:65`：`整理阶段路由专业执行体：\`Skill("brainstorming")\` 发散澄清 / \`Skill("openspec-propose")\` 规格化；... 按复杂度在两族间择一路由见 \`references/spec-mode.md\` §1b...`；`:266` 同样提及 `brainstorming`、`propose/apply/verify`。
  - `skills/plan-collab-router/references/skill-collaboration.md` 成员清单与触发矩阵：`:27` `openspec-propose`；`:38` `brainstorming → writing-plans → executing-plans / subagent-driven-development → test-driven-development → requesting/receiving-code-review → finishing-a-development-branch`；`:39,43` `using-superpowers`/`systematic-debugging` 等；`:49` `bug→systematic-debugging；TDD→test-driven-development；合并前→requesting-code-review`；`:61` `bug 排查→systematic-debugging；实现前需 TDD→test-driven-development；需求不清→brainstorming；按既有书面计划执行→executing-plans / subagent-driven-development；合并前→requesting-code-review + finishing-a-development-branch`；`:74,83` `openspec-propose`、`superpowers 对应成员技能`。
- 结论：spec-mode/SKILL.md 引用的成员技能名（brainstorming、writing-plans、executing-plans、test-driven-development、systematic-debugging、openspec-propose、openspec-apply-change、openspec-verify-change、openspec-explore 等）均在 `skill-collaboration.md` §一/§二/§三 的既有成员清单与触发表述中可对齐，未发现编造技能名。

## 3) 103.6 同步完整性清单（关联面四族）

| 项 | 检查内容 | 证据 | 判定 |
|---|---|---|---|
| (a) | 互引条款双向存在（§1b→权威源 §二；权威源初筛段→§1b） | `spec-mode.md:19` 引 `skill-collaboration.md` §二且“冲突以权威源为准”；`skill-collaboration.md:51` 存在 `## §二 协同路由触发矩阵（D1）`；`skill-collaboration.md:55` 引 `spec-mode.md` §1b 且“冲突以本表为准” | PASS |
| (b) | `SKILL.md:65` 指针指向的 `§1b` 小节标题真实存在 | `SKILL.md:65` 含 `references/spec-mode.md\` §1b...`；`spec-mode.md:18` 为 `### 1b. 复杂度分档→族选择决策表...` | PASS |
| (c) | 实跑单脚本 selftest-skill-collab.sh | 命令：`cd <wt> && bash skills/task-planner/scripts/selftest-skill-collab.sh 2>&1 \| tail -20`；尾部：`[PASS] T12a collab 矩阵 research-assistant 行` / `[PASS] T12b collab 矩阵 browser-use 行` / `Total: 25  PASS=25  FAIL=0`；退出码：`0` | PASS |
| (d) | 部署位影响面（4 位 × 3 文件） | 逐位检查结果见下表 | PASS（存在性核对完成；内容一致性未比对） |

### 3(d) 部署位存在性明细

| 位置 | task-planner/SKILL.md | task-planner/references/spec-mode.md | plan-collab-router/references/skill-collaboration.md |
|---|---|---|---|
| `/home/terry/.zcode/skills` | EXISTS | EXISTS | EXISTS |
| `/home/terry/.agents/skills` | EXISTS | MISSING | MISSING |
| `/home/terry/.claude/skills` | EXISTS | EXISTS | EXISTS |
| `/home/terry/.cursor/skills` | EXISTS | EXISTS | EXISTS |

命令：逐位 `test -f` 检查，输出：`.zcode` 三者 EXISTS；`.agents` 仅 `task-planner/SKILL.md` EXISTS，其余 MISSING；`.claude` 三者 EXISTS；`.cursor` 三者 EXISTS。

## 4) selftest 基线对照（VC-4 预核）

### 4.1 master 基线（实跑）
- 命令：`cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -E 'Total:'`
- 结果：`Total: 98 PASS=96 FAIL=2 (run=98 reused=96)`（退出码 0）
- 失败项识别：`grep -v 'PASS=[0-9]* FAIL=0'` 显示 `[FAIL] selftest-active-plan (rc=1)`、`[FAIL] selftest-execution-stability (rc=1)`

### 4.2 worktree 侧
- 日志：`/tmp/spr-wt-selftest.log` 存在，但尾部无 `Total:` 终行。
- 证据：`tail -20 /tmp/spr-wt-selftest.log` 末行为 `[run] selftest-template-lifecycle (rc=0 PASS=24 FAIL=0)`；`grep -n 'Total:' /tmp/spr-wt-selftest.log` 无匹配。
- 重试：按要求 `sleep 90` 后重读，最多重试 4 次（attempt 1-4 均 `no Total yet`）后仍无终行；最终 tail 末尾停在 `[run] selftest-user-instruction-priority (rc=0 PASS=0 FAIL=0)`。
- 补充实跑（按指引）：`cd <wt> && bash skills/task-planner/scripts/selftest-skill-collab.sh 2>&1 | tail -20` → `Total: 25  PASS=25  FAIL=0`，退出码 0。
- 标注：**worktree 全量 run-selftests.sh 终数未在 `/tmp/spr-wt-selftest.log` 落地（4 次重试后仍无 `Total:`），全量终数以主进程后续登记为准。**

### 4.3 基线对照判定
- master FAIL=2：`selftest-active-plan`、`selftest-execution-stability`。
- 改动面：本次仅改动 `skills/task-planner/SKILL.md`、`skills/task-planner/references/spec-mode.md`、`skills/plan-collab-router/references/skill-collaboration.md` 三文件。
- 相关性判断：上述两个失败用例名称/作用域与本次三文件改动面（Spec 模式路由/复杂度分档条款扩展）无直接对应；worktree 侧针对改动关联面的 `selftest-skill-collab.sh` 为 `PASS=25 FAIL=0`。
- 判定：**无法完成“worktree FAIL 数 ≤ master FAIL 数”的全量数值对照（worktree 全量终数缺失）**；在可观测证据范围内，改动关联 selftest（skill-collab）无新增失败迹象，master 既有 2 FAIL 与本次改动面无直接关联。

## 总判定

- VC-1/2/3 机械面：**PASS**
- 语义三性（权威源一致/择一语义无歧义/调用形态一致）：**PASS**
- 103.6 同步完整性：**PASS（含部署位存在性核对；`.agents` 部署位缺 spec-mode 与 skill-collaboration 两文件已记录）**
- VC-4 基线对照：**分歧/未闭合**（master=`98 PASS=96 FAIL=2`；worktree 全量 Total 未产出，仅确认 `selftest-skill-collab PASS=25 FAIL=0`）

**总体：分歧（非实现语义分歧；VC-4 全量终数证据缺失待主进程后续登记闭合）**。