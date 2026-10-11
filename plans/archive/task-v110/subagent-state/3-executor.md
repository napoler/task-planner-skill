# checkpoint 3-executor — 批次二：check-dispatch.sh 守卫最小适配 + selftest 断言级联（task-v110）
status: done

## 里程碑
- M1 (done) 方案件 3 权威源（1-executor.md「件 3 最小 diff 5 点」+维度 5 selftest 锚清单）+check-dispatch.sh/selftest-dispatch.sh/selftest-tier-b.sh/selftest-fine-grain-steps.sh 通读完成；基线 selftest 实测 29/18/11 全 PASS
- M2 (done) check-dispatch.sh 守卫最小 diff 落地（入口双路径 pg 检测 + serial_slot_check 第⑤参 + 组槽放行分支 + 函数头注释同步）；bash -n 过；无标记路径文案行（现 :381/:384）零改动
- M3 (done) selftest 断言级联完成（新增 TS-07/TS-08，TS-01..06 与 tier-b/fine-grain-steps 零改动）；三 selftest 全 PASS；findings/progress 追加；最终结论 8 字段块入本文件

## 件 3 五点对照（方案 → 实际落地）
| # | 方案锚 | 实际 | 状态 |
|---|--------|------|------|
| 1 | :199/:212 入口追加 pg 双条件检测 | warn 兜底路径 :199-200 + enforce 路径 :211-212 各加 `pg=0` 初始化 + `grep -qm1 'parallel_groups:' "$pd/task_plan.md" && grep -qm1 '\[parallel-group:' "$pf" && pg=1`（ro 检测行后同行体，与 T-B1 只读豁免 ro 检测同范式） | done |
| 2 | :351 函数签名 `pg="${5:-0}"` | 现 :353 `local ... ro="${4:-0}" pg="${5:-0}" lf now ts age` | done |
| 3 | :366 放行条件 + `[dispatch-parallel-group]` 文案 | ro 放行分支（:369-372）后新增 pg 分支（:375-378）：槽占用时 `[dispatch-parallel-group] 并行组标记命中(10-02 独立性守门), 槽占用(age=Ns)放行 — 组内四问责任在计划期声明, 组间串行不变`，不覆盖写类/组共享锁（与 T-B1 只读豁免同处理） | done |
| 4 | 无组标记路径零改动 | `git diff -U0` 删除行中「串行」文案行=0；warn :381 / enforce :384 两行 `Rule 21.4 串行派发铁律` 文案逐字保留（TS-02/03 grep '串行' 锚保护 + TS-08 回归实证） | done |
| 5 | selftest 新增 TS-07 + TS-08；tier-b 零改动 | selftest-dispatch.sh 在 TS-06 后新增 TS-07（夹具 task_plan 追加 `parallel_groups: [g1, g2]` 声明 + prompt 追加 `[parallel-group:g1]` + 新鲜锁 + enforce → rc=0 且 stderr 含 `dispatch-parallel-group`）+ TS-08（sed 撤声明 + 无标记 prompt + 新鲜锁 + enforce → rc=2 且 stderr 含「串行」，TS-02 语义防回归）；段头注释同步（TS-01..06 → TS-01..08）；tier-b/fine-grain-steps 0 改动 | done |

偏差披露：无行号偏移（内容锚 `local ro=0;` 定位与方案 :199/:212 一致）；唯一微调=TS-07 夹具用 HTML 注释 `<!-- parallel_groups: ... -->` 承载 frontmatter 声明（与 tier-b T-B1 夹具 `<!-- parallel_readonly: true -->` 同范式，守卫 grep 面只匹配字面 `parallel_groups:` 不区分注释/表格形态）。

## 验证证据（原始输出摘录）
- `bash -n check-dispatch.sh` → SYNTAX-OK；`bash -n selftest-dispatch.sh` → TS-SCRIPT-OK
- `bash selftest-dispatch.sh` → `Total: 31 PASS=31 FAIL=0`（基线 29 → +TS-07/+TS-08）；`TS-07 PASS (rc=0, 组标记槽占用放行)` / `TS-08 PASS (rc=2, 无标记仍按串行槽拦截)`
- `bash selftest-tier-b.sh` → `Total: 18 PASS=18 FAIL=0`（TB-18 `21.4 豁免子条在位` PASS，锚串 `只读分槽豁免（[task-v094 T-B1]` 逐字未动）
- `bash selftest-fine-grain-steps.sh` → `Total: 11 PASS=11 FAIL=0`
- `git diff --stat`（WT 全量 12 文件，批次一 10 + 批次二 2）：
  `skills/task-planner/scripts/check-dispatch.sh | 16 ++++++++---` / `skills/task-planner/scripts/selftest-dispatch.sh | 23 ++++++++`（批次二净 35 insertions / 4 deletions）
- 无标记路径文案零变化实证：`git diff -U0 check-dispatch.sh | grep -c '^-.*串行'` → 0；`grep -n '串行派发铁律' check-dispatch.sh` → 仅 :381/:384 两行（warn/enforce 拦截原文案，行号由改动前 :371/:374 平移）
- 未执行 git add/commit（scope 禁止）；worktree 外仅 plans/ 三文件追加（findings #### [sub:3-executor] 段 + progress [sub:3] 行 + 本 checkpoint）

## 最终结论
status: done
acceptance: 3/3 pass — ① check-dispatch 改动落地 + `bash -n` 语法过 + 无标记路径文案串（TS-02/03 grep 锚「串行」）零变化（diff 删除行 0 + :381/:384 逐字保留）② selftest 级联完成（TS-07/08 新增 PASS；TS-01..06 既有行零改动）；selftest-dispatch 31/0 + selftest-tier-b 18/0 + selftest-fine-grain-steps 11/0 全 PASS ③ `git diff --stat` 本批=2 文件（check-dispatch +16/-3 段、selftest-dispatch +23/-1）；checkpoint 含最终结论 8 字段块=本段
files: /mnt/data/dev/task-planner-skill-worktrees/task-v110/skills/task-planner/scripts/check-dispatch.sh (+12/-2 净 16 ins/4 del 计入 stat); /mnt/data/dev/task-planner-skill-worktrees/task-v110/skills/task-planner/scripts/selftest-dispatch.sh (+22/-1); /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/3-executor.md (+1); findings.md (追加 #### [sub:3-executor] 守卫适配); progress.md (Phase 2 Actions taken 追加 [sub:3] 行)
evidence: check-dispatch.sh:375-378 (pg 放行分支 `[dispatch-parallel-group] 并行组标记命中(10-02 独立性守门)`) + :353 (签名 `pg="${5:-0}"`) + :199-200/:211-212 (入口双路径 pg 双条件检测 `grep -qm1 'parallel_groups:' ∧ grep -qm1 '\[parallel-group:'`); selftest-dispatch.sh TS-07 `PASS (rc=0, 组标记槽占用放行)` / TS-08 `PASS (rc=2, 无标记仍按串行槽拦截)`; `bash selftest-dispatch.sh`→`Total: 31 PASS=31 FAIL=0` / tier-b→`18/18` / fgs→`11/11`; `git diff -U0 check-dispatch.sh | grep -c '^-.*串行'`→0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/3-executor.md (status: done)
findings_written: #### [sub:3-executor] 守卫适配
blockers: none
confidence: HIGH
