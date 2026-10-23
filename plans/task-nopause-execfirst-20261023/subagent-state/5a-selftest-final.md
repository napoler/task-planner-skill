# 5a — 并集合并后 selftest 终验轮（b3f7c04）

## 执行事实
- 工作目录：`/mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023`
- HEAD：`b3f7c04 merge: 并集解 master(e319ee3 Rule 96)——SKILL.md 五 hunk union+全文档级联 1-96/79 条（CA-13 并集解）`
- `git status --short`：干净（无输出）
- 命令原文：`cd /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023 && bash skills/task-planner/scripts/run-selftests.sh --fresh`
- 退出码：`1`（PIPESTATUS[0]=1，两次独立执行一致）
- 末行统计：`Total: 93 PASS=91 FAIL=2 (run=93 reused=0)`
- `Failed: selftest-rule-reserve-pairing selftest-subagent-activation`

## 并集一致性断言（附加项）
- 命令：`grep -rn "其余 78 条\|Rules 1-95 全集" skills/task-planner/SKILL.md CLAUDE.md README_zh.md skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md | grep -v "→"`
- 输出：空（grep exit=1）→ **PASS（符合期望空）**
- 佐证：`grep -cF '其余 78 条' SKILL.md` = 0；`grep -cF '其余 79 条' SKILL.md` = 2（line 9 / line 209）

## FAIL 明细（逐条）

### FAIL-1 selftest-rule-reserve-pairing.sh — PR-02（rc=1，Total: 3 PASS=2 FAIL=1）
- 断言原文（脚本 scripts/selftest-rule-reserve-pairing.sh:10-11 定义，L69-79 判定）：
  ```
  PR-02 配对方向二（reserved 有 landed）: 同 rule 有 reserved 但无 landed 的悬空项；
         EXEMPT_DANGLING 豁免表 = 57 60 80 82（历史悬空预留），非豁免 FAIL
  ```
- 实际输出原文：`PR-02 FAIL reserved 无对应 landed（非豁免悬空编号:95 96；豁免表=57 60 80 82，历史悬空须 land 配对或仲裁作废，不得扩表）`
- 证据：`plans/.rule-reservations.jsonl:84-85`（唯一 95/96 行，均为 reserved，全账本无对应 landed 行；`grep -c landed` = 43，且 `grep '"rule":9[56]'` 仅命中这 2 行）
  ```
  {"rule":95,"status":"reserved","task_id":"task-nopause-execfirst-20261023","ts":"2026-10-23","note":""}
  {"rule":96,"status":"reserved","task_id":"task-subagent-boost-20261023","ts":"2026-10-24","note":""}
  ```
- 合并前后对比：`b3f7c04^1`(a95de42) 账本无 95/96 行；`b3f7c04^2`(96a8b5c) 引入两条 reserved；`b3f7c04` 结果仍只有 reserved → 两侧的 `rule-reserve.sh land` 均未执行/未落账。
- 分类：**Rule 95/96 并集相关**（非存量：PR-01/PR-03 均 PASS，历史豁免表未变）。本任务 task_plan VC-6 与 verification.md:31 均要求 `"rule":95 ... "status":"landed"`，当前未满足。

### FAIL-2 selftest-subagent-activation.sh — SA-12（rc=1，Total: 15 PASS=14 FAIL=1）
- 断言定义原文（脚本 scripts/selftest-subagent-activation.sh:15, L67-69）：
  ```
  # SA-12 SKILL.md 卫星枚举 ,96 ≥2 处（frontmatter 卫星行+正文路由表 task-dispatch 行）∧ 其余 78 条 ≥2 处
  sa12a="$(cnt '52,59,68,96' "$SKILLMD")"; sa12b="$(cnt '其余 78 条' "$SKILLMD")"
  ```
- 实际输出原文：`SA-12 FAIL SKILL.md 级联随动缺失（,96=2/78 条=0, 各需 ≥2）`
- 证据：
  - `skills/task-planner/SKILL.md:9` 与 `:209` 均为 `其余 79 条`（并集解已把 78→79 级联到位；commit message 亦写 `级联 1-96/79 条`）
  - 合并前 `b3f7c04^2:skills/task-planner/SKILL.md` 为 `其余 78 条`（2 处），新脚本锚即按该基线写成
  - b3f7c04 新增了 `selftest-subagent-activation.sh`（90 行）但锚字面未随 1-96/79 同步 → 断言与文档脱节
  - `52,59,68,96` 计数 = 2（前半条件满足）
- 分类：**Rule 96 并集相关（新脚本锚字面陈旧）**，非 Rule 95/96 正文缺陷；配套 grep 断言（期望空）已证明 79 才是并集目标值。

## 未发现（负结果）
- 其余 91 个脚本全 PASS，无 rc≠0、无 PASS=0 异常（`selftest-source-anchor-discipline` / `selftest-verify-io` / `selftest-user-instruction-priority` PASS=0 FAIL=0 为既有"零断言"形态，rc=0，非本轮回退）
- registry 双向配对（selftest-registry.sh）、sync-index、doc-script-paths 均 PASS → 93 脚本数量与登记无缺
- 无超时、无 `[TRUNCATED]`、无磁盘/权限类 I/O 失败

## 结论
- 判定标准（末行 `FAIL=0`）**未达成**：`Total: 93 PASS=91 FAIL=2`。
- 两处 FAIL 均属并集收口遗留，可修且面窄：
  1. 需执行 `rule-reserve.sh land 95 <task-id>` 与 `land 96 <task-id>`（或由持有方补登记）→ 解 PR-02
  2. `selftest-subagent-activation.sh` SA-12 锚字面 `其余 78 条` → `其余 79 条`（同步并集决议）→ 解 SA-12
- 未改任何仓库文件、未执行 git 写操作。
