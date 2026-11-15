# [sub:3-fix-cr] 复检修复执行记录（M1/M2/m2）

- 时间：2026-11-15T13:40:33Z（UTC）
- 目标：按 [sub:2-critic-recheck] CHANGES_REQUESTED 修复 M1/M2/m2，仅改 worktree 指定三文件并跑验收

## T1 M1 — SKILL.md 计数修正（94→91）
- 文件：`tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/SKILL.md`
- 操作：两处 `其余 94 条` → `其余 91 条`（:9 索引行、:224 纪元/全集索引行），Edit 精确替换
- 验证：
  - `grep -c '其余 94 条' .../SKILL.md` → `0`
  - `grep -c '其余 91 条' .../SKILL.md` → `2`
- 结果：PASS

## T2 m2 — 规则文 108.3 增补档位声明
- 文件：`tmp/worktrees/task-crossvalidate-20261115/skills/verification-gate/references/critical-rules-verification.md`
- 操作：108.3 段末「单路径结论禁标「已交叉验证」。」后追加：`交叉验证的识别力来自隔离上下文与视角互异，不要求更高模型档位。`
- 验证：
  - `grep -c '交叉验证的识别力来自隔离上下文与视角互异，不要求更高模型档位' .../critical-rules-verification.md` → `1`
- 结果：PASS

## T3 M2 — selftest-cross-validation.sh 断言强化
- 文件：`tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-cross-validation.sh`
- 操作：保持 PASS/FAIL 计数与退出码形态不变，强化判据范围
  - CV-01：新增 `grep -q '^### 108 '` 块标题锚，仍校验 108.1-108.5 子条
  - CV-02：改为 `sed -n '/^### 108 /,/^### /p'` 提取 108 块后在块内判定判例锚 `subagent-verifier-fabricated-output-20261103`
  - CV-03：改为 `sed -n '/^## 调用时机/,/^## /p'` 提取段后在段内判定 `Rule 108`
  - CV-04：保持 `Rule 108` 且路由 `Rule 84,108` 判定
  - CV-05：断言串改为 `^## 交叉验证记录（Rule 108）`（标题行锚）
  - CV-06：保持 registry 行判定
- 验证：
  - `grep -c '^### 108 ' .../critical-rules-verification.md` → `1`（CV-01 锚对象在位）
  - `grep -c '^## 交叉验证记录（Rule 108）' .../templates/verification.md` → `1`（CV-05 锚对象在位）
  - `bash .../selftest-cross-validation.sh` → `Total: 6  PASS=6  FAIL=0` `EXIT_CV=0`
- 结果：PASS

## T4 全量验收命令与五脚本实跑
- A1: `grep -c '其余 94 条' SKILL.md`=0, `grep -c '其余 91 条' SKILL.md`=2 → PASS
- A2: `grep -c '^### 108 ' critical-rules-verification.md`=1, `grep -c '^## 交叉验证记录（Rule 108）' templates/verification.md`=1 → PASS
- A3: `grep -c '交叉验证的识别力来自隔离上下文与视角互异，不要求更高模型档位' critical-rules-verification.md`=1 → PASS
- A4 五脚本实跑（worktree 根执行）：
  - `selftest-cross-validation.sh` → `Total: 6  PASS=6  FAIL=0` EXIT=0
  - `selftest-enumerate-first.sh` → `Total: 7  PASS=7  FAIL=0` EXIT=0
  - `selftest-dual-qc.sh` → `Total: 14 PASS=14 FAIL=0` EXIT=0
  - `selftest-anti-deferral.sh` → `Total: 12 PASS=12 FAIL=0` EXIT=0
  - `selftest-subagent-activation.sh` → `Total: 20 PASS=20 FAIL=0` EXIT=0
- 结果：PASS（4/4 验收组 + 5/5 脚本 exit 0）

## T5 范围与约束确认
- 仅写 worktree 三文件：`skills/task-planner/SKILL.md`、`skills/task-planner/scripts/selftest-cross-validation.sh`、`skills/verification-gate/references/critical-rules-verification.md`
- 主仓与 worktree 其他文件未改；既有行零删除（纯字面替换 + 108.3 句尾追加 + 断言强化改写同一脚本内判据）

## 最终结论
status: done
acceptance: 4/4 pass — [1:PASS 2:PASS 3:PASS 4:PASS (CV Total:6 PASS=6 FAIL=0, EN Total:7 PASS=7 FAIL=0, DQ Total:14 PASS=14 FAIL=0, AD Total:12 PASS=12 FAIL=0, SA Total:20 PASS=20 FAIL=0)]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/SKILL.md(+2/-2); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-cross-validation.sh(+30/-18); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/verification-gate/references/critical-rules-verification.md(+1/-1)
evidence: grep -c '其余 94 条' SKILL.md→0; grep -c '其余 91 条' SKILL.md→2; grep -c '^### 108 ' critical-rules-verification.md→1; grep -c '^## 交叉验证记录（Rule 108）' templates/verification.md→1; grep -c '交叉验证的识别力来自隔离上下文与视角互异，不要求更高模型档位' critical-rules-verification.md→1; selftest-cross-validation.sh→Total: 6  PASS=6  FAIL=0 EXIT=0; selftest-enumerate-first.sh→Total: 7  PASS=7  FAIL=0 EXIT=0; selftest-dual-qc.sh→Total: 14 PASS=14 FAIL=0 EXIT=0; selftest-anti-deferral.sh→Total: 12 PASS=12 FAIL=0 EXIT=0; selftest-subagent-activation.sh→Total: 20 PASS=20 FAIL=0 EXIT=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/7-fix-cr.md (status: done)
findings_written: findings.md #### [sub:3-fix-cr] | none
blockers: none
confidence: HIGH
