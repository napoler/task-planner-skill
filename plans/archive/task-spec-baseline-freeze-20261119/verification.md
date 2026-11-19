# Verification Contract & Phase Gates

## Goal (1 sentence)
在 task-planner 技能体系建立 Spec-Baseline Freeze 闭环（定义→attest 冻结→派发携带→QC 回归→终验绑定），使长序列执行中已确立的业务硬约束（如 4-12s）无法被静默降级/篡改而不触发门控，零新脚本、纯文本条款。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 6 处条款逐字在位且编号无越界（51.15 / dispatch 22.4e+103.3b / 106.7 / 84.15 / subagent_dispatch spec_baseline / task_plan 规范基线区块）
  Evidence: worktree 内 7 文件 grep 锚点 + Read 复核
  **Verify command**: WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-spec-baseline-freeze-20261119; test "$(grep -c '^51.15 ' $WT/skills/task-planner/references/critical-rules.md)" -ge 1 && test "$(grep -c '^22.4e ' $WT/skills/task-dispatch/references/critical-rules-dispatch.md)" -ge 1 && test "$(grep -c '103.3b' $WT/skills/task-dispatch/references/critical-rules-dispatch.md)" -ge 1 && test "$(grep -c '^106.7 ' $WT/skills/task-discipline/references/critical-rules-discipline.md)" -ge 1 && test "$(grep -c '84.15' $WT/skills/verification-gate/references/critical-rules-verification.md)" -ge 1 && test "$(grep -c 'spec_baseline' $WT/skills/task-planner/templates/subagent_dispatch.md)" -ge 1 && test "$(grep -c '🔒 规范基线' $WT/skills/task-planner/templates/task_plan.md)" -ge 1
- [x] VC-2: 机器契约零回归——现有 selftest 全绿（SA-15 越界负断言、requirement-coverage 八子条、dual-qc 等未因新增条款破坏）
  Evidence: 2026-11-19 主仓实跑 4 脚本 = SA 20 + RC 28 + DQ 14 + final-gate-hash 22 = 84 PASS / 0 FAIL（原「110 断言」为另一脚本集口径，收敛到本次可复现实测值）
  **Verify command**: WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-spec-baseline-freeze-20261119; cd $WT/skills/task-planner/scripts && for s in selftest-subagent-activation.sh selftest-requirement-coverage.sh selftest-dual-qc.sh selftest-final-gate-hash.sh; do bash "$s" >/tmp/st-$$.out 2>&1 || { cat /tmp/st-$$.out; exit 1; }; done; echo ALL_SELFTEST_PASS
- [x] VC-3: Spec-Baseline 核心条款在 3 个部署位的现存文件逐条锚定到位（合并回 master 879fb48 后；2026-11-19 主进程盘上复核通过）
  Evidence: grep 锚点实跑——核心规则 4 文件（51.15/22.4e/106.7/84.15）× 3 位=12/12 到位；模板（🔒 规范基线 / spec_baseline）在 zcode+claude 位=4/4 到位。agents 位无 templates 目录=该位既有形态（非缺失缺陷）；zcode 位 task_plan.md 与他会话 task-intent-iter 的 Rule 28.2.2 草稿块 diff=预期保留（部署脚本按设计不覆盖他会话内容），本任务插入的「🔒 规范基线」区块在该位=1，共存无误。原「5 部署位 diff=0」「19 文件 64 锚」为夸大口径，已按实况收敛。（假门修正：原 Verify command 的 `$pos/$f` 多拼一层 skills/ 导致恒真，已改为正确路径的逐锚核验）
  **Verify command**: cd /mnt/data/dev/task-planner-skill; bad=0; for pos in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills; do for pair in "task-planner/references/critical-rules.md:^51.15 " "task-dispatch/references/critical-rules-dispatch.md:^22.4e " "task-discipline/references/critical-rules-discipline.md:^106.7 " "verification-gate/references/critical-rules-verification.md:84.15"; do f="${pair%%:*}"; pat="${pair#*:}"; [ -f "$pos/$f" ] && grep -q "$pat" "$pos/$f" || { echo "FAIL $pos/$f"; bad=1; }; done; done; for pos in /home/terry/.zcode/skills /home/terry/.claude/skills; do grep -q '🔒 规范基线' "$pos/task-planner/templates/task_plan.md" || { echo "FAIL $pos/task_plan.md"; bad=1; }; grep -q 'spec_baseline' "$pos/task-planner/templates/subagent_dispatch.md" || { echo "FAIL $pos/subagent_dispatch.md"; bad=1; }; done; test $bad -eq 0 && echo DEPLOY_ANCHORS_OK
- [x] VC-4: 4-12s 判例锚落在 51.15 条款文本内（可被机器检出，作为防倒退的具体示例）
  Evidence: 51.15 条款含 '4-12s' 与 'sess_ba603cf5'（注：原 VC 标题笔误写 51.14，条款实际编号为 51.15，Verify command 用 51.15 正确）
  **Verify command**: WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-spec-baseline-freeze-20261119; line=$(grep '^51.15 ' $WT/skills/task-planner/references/critical-rules.md); echo "$line" | grep -q '4-12s' && echo "$line" | grep -q 'sess_ba603cf5' && echo "$line" | grep -q 'SPEC-BASELINE TAMPERED'
- [x] VC-5: 他会话 staged 改动完整恢复（stash pop --index 后 17 文件 staged 状态保留）+ worktree 清理
  Evidence: git status staged 计数 + git worktree list
  **Verify command**: cd /mnt/data/dev/task-planner-skill; test "$(git -C . worktree list | grep -c 'task-spec-baseline-freeze-20261119')" -eq 0 && echo WT_CLEANED

---

## Phase Gates

### Phase 1: 取证与决策
**Done when**: findings F1/F2/F3 落盘 + D 类判定 + worktree ①-校验全绿
**Verification**: V-1.1 ①-校验 5 文件 SAME；V-1.2 worktree HEAD=be068da
Status: `complete` Last verified: 2026-11-19

### Phase 2: 实现条款闭环
**Done when**: VC-1 + VC-4 通过
Status: `complete` Last verified: 2026-11-19（VC-1/4 主仓 8 锚全=1+判例锚在位；VC-2 selftest 4 脚本 84 PASS/0 FAIL；VC-3 部署位核心规则锚 12/12+模板锚 4/4 到位）

### Phase 3: 验证+合并回+部署
**Done when**: VC-2 + VC-3 + VC-5 通过
Status: `complete` Last verified: 2026-11-19（merge 879fb48；stash pop --index 17 staged 完整；worktree 已清）
