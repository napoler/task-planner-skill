# S7 执行规格 — selftest-dual-qc.sh + registry 登记（task-dualqc-20261104）

## 任务
1. 新建 `/mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104/skills/task-planner/scripts/selftest-dual-qc.sh`
2. 向同目录 `selftest-registry.tsv` 追加一行登记（见 §3）

## 1. 脚本风格与结构
- 先 Read 同目录 exemplar `selftest-anti-deferral.sh`：照抄其头部注释断言清单格式（`#   AD-xx …` → 你用 `#   DQ-xx …`）、cnt/cntE 助手形态、SKILLMD 等路径解析方式（相对脚本目录解析，worktree 与主仓通用）、PASS/FAIL 计数与 exit 码约定。
- 头部首行注释：`#   DQ 断言族（task-dualqc-20261104 Rule 103 守护）`，随后逐条 DQ 清单注释。

## 2. 断言清单（DQ-01..DQ-14；目标文件均按 exemplar 方式从脚本所在树解析）
| ID | 目标文件 | 断言 |
|----|---------|------|
| DQ-01 | task-dispatch/references/critical-rules-dispatch.md | `^103\.[1-8]` 计数 = 8（cntE） |
| DQ-02 | 同上 | `^### 103 双轮质检与同步完整性审查` ≥1 |
| DQ-03 | 同上 | '同步完整性'≥1 ∧ '核对清单'≥2 ∧ '关联面'≥1 |
| DQ-04 | 同上（103.4 面） | '升一档'≥1 ∧ '封顶'≥1 ∧ 'decision-arbiter'≥1 |
| DQ-05 | 同上（103.5 面） | '只读不改'≥1 ∧ '不重做'≥1 ∧ '输出精简'≥1 |
| DQ-06 | 同上 | '复检升档衔接（Rule 103.4）' =1 |
| DQ-07 | verification-gate/references/critical-rules-verification.md | '衔接（Rule 103，task-dualqc-20261104）'=1 ∧ '84.7.2 为其先例面'=1 |
| DQ-08 | task-planner/SKILL.md | '1-103'≥3 ∧ '其余 86 条'=2 ∧ 'Rule 103 双轮质检与同步完整性域'=1 |
| DQ-09 | 同上 | '3h 双轮质检（Rule 103）'=1 ∧ '103.6 同步核对清单'≥2 |
| DQ-10 | 同上 | '统一收口序列'=1 ∧ `grep -A6 '统一收口序列'` 输出含 'user-session-log' |
| DQ-11 | templates/subagent_dispatch.md | '### 3b. 双轮质检与同步完整性'=1 ∧ '第一轮·自审'=1 ∧ '同步核对清单（103.6）'=1 ∧ 行首 '## 7. 返回格式' 仍在 |
| DQ-12 | templates/task_plan.md | '双轮质检与同步完整性声明'=1 ∧ '多文件变更集预判'=1 |
| DQ-13 | 负断言（契约保全） | 派发模板 '不得增删' ≥1（22.4b 八字段契约字面仍在） |
| DQ-14 | scripts/selftest-registry.tsv | 含 'selftest-dual-qc' ≥1 |

## 3. registry 登记行（tab 分隔 4 列；先 Read TSV 末行确认列形态再追加）
`selftest-dual-qc.sh` ⇥ `DQ` ⇥ `双轮质检与同步完整性(Rule 103)守护：八子条/双向衔接/SKILL 接线/统一收口序列/模板承载/契约保全负断言` ⇥ `103.x 子条锚/96.2 衔接/84.7 衔接/SKILL 3h+统一收口序列/模板 3b+声明区块/selftest-registry.tsv 自登记`

## 4. 验收标准（acceptance）
- `bash <worktree>/skills/task-planner/scripts/selftest-dual-qc.sh` exit 0，DQ-01..DQ-14 全 PASS
- `bash <worktree>/skills/task-planner/scripts/run-selftests.sh 2>&1 | grep 'dual-qc'` 证明新脚本被跑（可只跑到出现该行为止，无需等全量终判）
- 若存在 `scripts/selftest-registry.sh` 自检则 exit 0

## 5. 禁止
- 修改其他文件；跑全量 run-selftests.sh 终判（终判=主进程动作）
- 触碰并行检查体的文件（drift 检查点在 subagent-state/08-*.md，勿写）

## 6. checkpoint
/mnt/data/dev/task-planner-skill/plans/task-dualqc-20261104/subagent-state/09-general-coder-s7.md（操作摘要+自审段：逐条 acceptance→自核结果+证据）
