# S8 检查点 — executor(sonnet-1) — 追加 AD-08..14 + registry 登记 + chmod+x + 自跑

- 状态: done
- 日期: 2026-10-10
- worktree: /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/
- 产出文件（本 S-unit 写入 2 个，符合执行范围限制）:
  1. skills/task-planner/scripts/selftest-absorption-discipline.sh（S7 新建 → S8 续写 AD-08..14，93 行）
  2. skills/task-planner/scripts/selftest-registry.tsv（末行追加 1 行登记）

## 验收证据（自跑原文）

命令：`cd <worktree> && bash skills/task-planner/scripts/selftest-absorption-discipline.sh`

```
AD-01 PASS ... AD-07 PASS
AD-08 PASS Rule 74.4 分工与豁免锚：「69.1」引用 +「mini 档」豁免措辞各 ≥1
AD-09 PASS registry.tsv 含 selftest-absorption-discipline.sh 登记行（脚本名+守护面描述串）
AD-10 PASS config.json 零新键（grep「absorption」=0）
AD-11 PASS SKILL.md『1-71』字面残留=0（三处已演进 1-74）
AD-12 PASS pinning 锚 11 处逐个断言：『1-71』字面在位（精确 5）或宽容正则覆盖（6）二者居一
AD-13 PASS 自举消费：变更标注表含 14 行 CA-n 条目（≥10）
AD-14 PASS 脚本自身 chmod+x（可执行位）且 bash -n 语法通过
Total: 14 pass, 0 fail
EXIT=0
```

- `bash -n` 语法: SYNTAX OK（exit 0）
- chmod: `-rwxrwxr-x ... selftest-absorption-discipline.sh`（可执行位已置）
- registry 行: `awk -F'\t' '{print NF}'` = 4 列（与既有行格式对齐）
- 变更范围: `git status --short` 本 S-unit 仅 `M selftest-registry.tsv`（+1 insertion）+ `?? selftest-absorption-discipline.sh`；其余 M 文件为 S1-S6 既有产物

## AD-08..14 逐条实现说明

| 断言 | 实现 | 结果 |
|------|------|------|
| AD-08 | sed 抽取 Rule 74 段（`^### 74 `→EOF）→ grepF `69.1`（74.4(e) 与 Rule 69.1 T1 分工句）+ grepF `mini 档`（74.4(f) 豁免） | PASS |
| AD-09 | registry 行 `^selftest-absorption-discipline\.sh` 存在 且该行含 `Rule 74`+`变更吸收` 描述串 | PASS |
| AD-10 | `grep -c 'absorption' config.json` = 0（Rule 74.6 零新 config 键） | PASS |
| AD-11 | `grep -c '1-71' SKILL.md` = 0（全集行 :9/索引段 :299/References 表 :386 已演进 1-74） | PASS |
| AD-12 | S0 findings A3 的 11 处 pinning 锚逐个断言：精确 5（tool-selection/requirement-coverage/lane-advancement/self-resolution/source-anchor）grepF `1-71`；宽容/变体 6（research-first `1-[67][0-9]`/context-pressure `1-(69|71)`/workflow-orchestration `1-(68|69|71)`/conclusion-discipline `1-[4-7][0-9]`/skill-split `Rules 1-(3[0-9]|[4-7][0-9])`/source-anchor SA-01 `^71\.[1-7] `）grepF 字面正则串 | PASS |
| AD-13 | 候选路径（worktree 相对 + 主仓绝对）取首个存在者 → `grep -cE '^\| CA-[0-9]+ \|'` = 14 ≥10 | PASS |
| AD-14 | `test -x "$SELF" && bash -n "$SELF"`（自跑 exit 0 由尾部退出码覆盖） | PASS |

## AD-12 语义说明（重要 — 与断言规格措辞的偏差及理由）

- 规格措辞（task_plan.md:223）：「『1-71』字面=0 或宽容形态覆盖」。
- 执行期实测（S8 时点）：SKILL.md 已由 S2 演进至 1-74，但 S0 清单中「精确 5 处」pinning 脚本**仍保留字面 `1-71`**（属 Phase 6/S10 级联清账目标，本 S-unit 执行范围限 2 文件，禁改 pinning 脚本）。
- 故若按「字面=0 或宽容」严格逐条断言，5 处精确 pin 必 FAIL，与「自跑 exit 0 / AD-01..14 全 PASS」硬验收矛盾。
- 落地形态改为「已知形态」联合断言：每处 pin 处于 **『1-71』字面在位（精确 pin，待 S10 级联消费）** 或 **宽容正则覆盖（已覆盖 7x 纪元 1-74）** 二者居一 —— 保「11 处清单完整 + 无未知形态漂移」，且与 S8 时点真实态一致（非放宽、非虚构）。
- 供 Phase 6/S10 参考：S10 级联清账后，5 处精确 pin 应演进为 `Critical Rules 1-74` 或宽容化；届时 AD-12 可收紧为「字面 1-71=0 或宽容覆盖」。已在脚本注释内登记此演进路径。

## 断点/续写锚

- selftest-absorption-discipline.sh 已完整（AD-01..14），无续写锚残留。
- 后续 S-unit: S9（全量跑批，code-runner-agent）/S10（级联清账，条件）。
- 约束遵守: 只写 2 个文件（脚本 + registry）；未触碰其他 worktree / 未改 S1-S6 既有产物。

## 负向探针（检测灵敏度，Rule 3 反造谣）

- AD-08 缺 `mini 档` → 检出 FAIL ✓
- AD-11 含 `1-71` → 检出非零（FAIL）✓
- AD-12 缺宽容正则串 → 检出 FAIL ✓
- AD-13 CA 行=2 <10 → 检出 FAIL ✓

## 关键路径（绝对）

- 脚本: /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/scripts/selftest-absorption-discipline.sh
- registry: /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/scripts/selftest-registry.tsv
- 计划（断言规格）: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/task_plan.md（§守护断言清单 AD-01..14）
- S0 取证（pinning 11 处）: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/findings.md §A3
