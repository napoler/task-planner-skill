# QC-report — task-todo-default-engine-20261123（双轮质检·只读审查）

- 审查对象：commit f55507e（9 文件）+ 部署位 ~/.zcode/skills、~/.agents/skills
- 审查方式：全部维度实跑命令取证，贴原始输出；禁采信声明/checkpoint 转述
- 边界：只读审查；唯一写入 = 本 QC-report.md
- 结论：**PASS**（7/7 维度通过；0 BLOCKER / 0 MAJOR / 0 MINOR；1 INFO）

---

## 维度结论速览

| 维度 | 主题 | 结论 |
|---|---|---|
| 1 | 守正 B1-B5 逐字保留 | PASS |
| 2 | B6/B7/B8 四锚齐备 + SKILL.md 行数 | PASS |
| 3 | 三层载体真实性（脚本/模板/守护） | PASS |
| 4 | 冲突补救 SOP §6.4 | PASS |
| 5 | 越界残留 / 占位 | PASS |
| 6 | 部署一致性（18 位 diff=0） | PASS |
| 7 | 计划自洽（vcs/phases/decisions/attest） | PASS |

---

## 维度 1 — 守正：B1-B5 逐字保留（最高优先）— PASS

取证命令（old=f55507e^，new=f55507e）：

```
git show f55507e^:skills/task-planner/references/todo-sync.md | grep '基线组生命周期' | sed 's/；B6 建 todo.*//' > /tmp/old_ts.txt
git show f55507e:skills/task-planner/references/todo-sync.md | grep '基线组生命周期' | sed 's/；B6 建 todo.*//' > /tmp/new_ts.txt
diff /tmp/old_ts.txt /tmp/new_ts.txt
```

原始输出（todo-sync.md:36 基线组生命周期行，B1-B5 段）：

```
--- OLD --- / --- NEW ---（两行完全一致）
2. 基线组生命周期：B1 持续项（开启即 in_progress，终验翻 complete，判据=progress 全部 [recheck] 行）；B2 每 Phase 翻转前勾检；B3/B4 终验期；B5 收尾。；基线组独立计数：B1 持续 in_progress 不受「同时只允许一条 in_progress」约束（该唯一性约束限任务组/Phase 映射条目）
DIFF_EXIT=0
```

Rule 106.5（critical-rules-discipline.md:748）逐字对比（截到 B5 句末，剥离追加的 B6 后半）：

```
OLD: ...；**B4** 收尾回读梳理（Rule 84.14，连续一轮零新发现）；**B5** Todo 终态同步（S4，含基线组自身）。
NEW: ...；**B4** 收尾回读梳理（Rule 84.14，连续一轮零新发现）；**B5** Todo 终态同步（S4，含基线组自身）
```

结论：B1-B5 五条定义在 todo-sync.md 与 critical-rules-discipline.md **逐字保留，无删改**。唯一字符级差异是 Rule 106.5 的 B5 句末 `。`→`；`，为追加 `；**B6**...` 的语法连接符替换（五条定义本体零变动），记为 INFO-1，不构成缺陷。commit diff 亦显示 B1-B5 原句全部只做尾部追加，未改字面。

## 维度 2 — B6/B7/B8 四锚齐备 + 行数 — PASS

四处锚逐位实跑：

```
grep -n '固定八项 B1-B8\|基线组生命周期' skills/task-planner/references/todo-sync.md
→ 35: 固定八项 B1-B8（B1-B5 逐字保留 + B6 引擎检测/B7 对齐/B8 worktree 核验）
→ 36: ...；B6 建 todo 时检测引擎适配性（OpenSpec 规格化/Superpowers 方法论）...；B7 对齐核查...；B8 实现类任务 worktree 隔离核验

grep -n '通用基线组.*B1' skills/task-discipline/references/critical-rules-discipline.md
→ 748: ...；**B6** 引擎适配性检测...；**B7** 对齐核查...；**B8** worktree 隔离核验（实现类任务强制隔离）。

grep -n '基线组 B1-B8，Rule 106.5' skills/task-planner/SKILL.md
→ 256: ...S1 两组结构（任务组+基线组 B1-B8，Rule 106.5）详见 references/todo-sync.md

grep -n '两组 todo B1-B8' skills/task-discipline/SKILL.md
→ 86: | 106 | ...两组 todo B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验））· task-docmod... |

wc -l skills/task-planner/SKILL.md skills/task-discipline/SKILL.md
→ 461 skills/task-planner/SKILL.md（≤470，应 461 ✓）
→  103 skills/task-discipline/SKILL.md
```

四锚（todo-sync.md 唯一事实源 / Rule106.5 语义锚 / task-planner SKILL.md 指针 / task-discipline SKILL.md 索引）均含 B6/B7/B8；SKILL.md 461 行符合预期。

## 维度 3 — 三层载体真实性 — PASS

3.1 产出器 `sync-todos.sh --json` 实跑 + python3 解析：

```
OUT=$(bash skills/task-planner/scripts/sync-todos.sh --json plans/task-todo-default-engine-20261123)
python3 解析 → JSON_VALID=True total_entries= 13
B_GROUP_COUNT= 8
B1 0 baseline 修改后验证
B2 0 baseline Phase翻转校验
B3 0 baseline 终验VC复验
B4 0 baseline 收尾回读
B5 0 baseline Todo终态
B6 0 baseline 引擎检测
B7 0 baseline 对齐核查
B8 0 baseline worktree核验
HAS_B1_B8= True
```

3.2 模板露出（task_plan.md:469）：

```
469:**基线组 B1-B8（S1 建组必含，B1-B5 逐字保留）**：
B1 修改后验证 / ... / B6 引擎检测（OpenSpec/Superpowers）/ B7 对齐核查 / B8 worktree核验。
门禁：B6 未留痕不得声称按引擎推进；B8 未勾实现类不得直接改主树；缺失=S3 当次重建。
```

3.3 selftest B6 锚断言（selftest-skill-collab.sh:119-120）：

```
119:t "T13a todo-sync 含 B6 引擎检测" grep -q 'B6' "$ROOT/references/todo-sync.md"
120:t "T13b Rule106.5 含 B6" grep -q 'B6' "$ROOT/../task-discipline/references/critical-rules-discipline.md"
```

3.4 三个相关 selftest 实跑全 PASS（0 FAIL）：

```
--- selftest-skill-collab.sh ---
[PASS] T13a todo-sync 含 B6 引擎检测
[PASS] T13b Rule106.5 含 B6
Total: 27  PASS=27  FAIL=0   EXIT=0
--- selftest-doc-script-paths.sh ---
Total: 3 PASS=3 FAIL=0 (docs=59 tokens=191)   EXIT=0
--- selftest-session-log.sh ---
Total: 31  PASS=31  FAIL=0   EXIT=0
```

三层载体（产出器真出 8 条 B 组 JSON / 模板露出 B1-B8 / 守护含 B6 锚断言并实跑 PASS）全部属实。

## 维度 4 — 冲突补救 SOP §6.4 — PASS

```
grep -n '6.4 同写冲突\|同写冲突补救\|补救四步\|smart-merge-back.sh 合并回主树' skills/task-planner/references/worktree-isolation.md
189:### 6.4 同写冲突检出后的补救性隔离（用户缺陷①②，2026-11-23）
193:**补救四步**：① 立即补建 worktree 隔离后续改动（路径/命名按 §3）；② 将主树该文件的未提交改动迁移到隔离分支（git stash 或手工复制后 git restore 主树，按 §4.5 找回纪律）；③ 后续所有改动在 worktree 内进行；④ 完成后用 smart-merge-back.sh 合并回主树（按 §4 合并回合约）。
194:**锚点**：`同写冲突补救`（供 grep / 执行体定位）。
```

锚 `同写冲突补救` + 四步（补建隔离→迁移未提交改动→隔离内改→smart-merge-back 合并回主树）齐备，含禁止继续主树直写的否定条款。

## 维度 5 — 越界残留 / 占位 — PASS

```
git show --format= f55507e | grep -n '默认文件系统读写对照表' → ABSENT in commit diff
grep -rn '默认文件系统读写对照表' [3 文件] → ABSENT in source files
git show --format= f55507e | grep '^+' | grep -vi '^+++' | grep -nE 'TODO|FIXME|占位|placeholder|TBD|XXX' → NO placeholder/TODO in added lines
```

已知 S3 越界「默认文件系统读写对照表」未复活；新增行无 TODO/占位/placeholder。9 文件改动严格限于任务书范围（B 组扩展/四处锚/三层载体/§6.4 SOP）。

## 维度 6 — 部署一致性 — PASS

9 文件 × 2 部署位逐位 diff：

```
DEPLOY DIFF vs ~/.zcode/skills：9×EQ，zcode_diff_count=0
DEPLOY DIFF vs ~/.agents/skills：9×EQ，agents_diff_count=0
```

18 位全部 diff=0。另核 9 文件对 HEAD 无未提交漂移：`git diff --stat HEAD -- [9 文件]` 输出为空（clean）。

## 维度 7 — 计划自洽 — PASS

```
jq '.vcs[]|"\(.id) \(.status)"' → VC-1 pass / VC-2 pass / VC-3 pass / VC-4 pass / VC-5 pass / VC-6 pass / VC-7 pass
jq 汇总 → vcs_count=7, vcs_fail=[], phases_count=5, phases_not_complete=[], decision_ids=[D1, D-WT, D-DEPLOY]
bash skills/task-planner/scripts/attest-plan.sh --verify plans/task-todo-default-engine-20261123/task_plan.md → ATTEST_EXIT=0
```

vcs 7 条全 pass、phases 5 条全 complete、decisions 含 D-WT 与 D-DEPLOY、attest --verify exit 0（未因改动失效）。

---

## 意见清单

- **BLOCKER**：无
- **MAJOR**：无
- **MINOR**：无
- **INFO-1**（非缺陷，透明记录）：Rule 106.5（skills/task-discipline/references/critical-rules-discipline.md:748）B5 句末标点 `。`→`；`，为追加 B6 的语法连接；B1-B5 五条定义本体逐字未变，todo-sync.md 侧 DIFF_EXIT=0 完全逐字一致。

## 总评

7/7 维度实跑取证全部通过，00 缺陷；B1-B5 逐字保留（最高优先）已用 old/new 原句 diff 直接证明，三层载体均真跑而非声明。唯一记项为标点语法连接 INFO，不影响判定。结论 PASS。

## 8 字段返回契约

- **status**：PASS（通过）
- **acceptance**：维1 PASS（B1-B5 逐字保留，todo-sync DIFF_EXIT=0；critical-rules 仅 B5 句末 `。`→`；` 语法连接）；维2 PASS（四锚齐备，SKILL.md=461≤470）；维3 PASS（--json 真出 8 条 B 组 JSON、模板露 B1-B8、T13a/T13b 锚断言、3 selftest 全 0 FAIL）；维4 PASS（§6.4 锚+四步齐备）；维5 PASS（越界未复活、无 TODO/占位）；维6 PASS（18 位 diff=0）；维7 PASS（vcs7 pass/phases5 complete/D-WT+D-DEPLOY/attest exit0）
- **files**：/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/QC-task.md；/mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md；/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md；/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md；/mnt/data/dev/task-planner-skill/skills/task-discipline/SKILL.md；/mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md；/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh；/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh；/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv；/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md；/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh；/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/plan-state.json；/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/.plan-attestation；/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/verification.md；/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S9-selftest-anchor.md；~/.zcode/skills 与 ~/.agents/skills 对应 9 位
- **evidence**：见上各维度「原始输出」段（git show old/new diff、wc -l、grep -n 行锚、python3 JSON 解析、3 selftest Total 行、attest ATTEST_EXIT=0、jq 汇总、18 位 diff EQ）
- **checkpoint**：/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/QC-report.md（本文件，完整记录）
- **findings_written**：是（本 QC-report.md 已写完整 7 维记录 + 8 字段；INFO-1 透明记录）
- **blockers**：无
- **confidence**：高（0.97）——所有维度命令实跑、原始输出贴附、无采信声明；扣 0.03 因 SC 侧 B5 句末标点变化需人工确认是否接受 INFO 定性
