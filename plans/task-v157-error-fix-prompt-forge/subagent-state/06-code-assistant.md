# sub:06-code-assistant — 级联修复:selftest 位置平移 (task-v157 Phase 4 S3 提前执行)

## 里程碑记录

- [M1] Read 被移脚本(82行, 路径块 L17-22)+范式参考 selftest-iterative-optimizer.sh(L18-20) → 路径解析范式确认: SCRIPT_DIR→SKILL_ROOT=脚本目录/..→TARGET=SKILL_ROOT/../<skill-name>/SKILL.md
- [M2] 前置诊断: registry.tsv 事实核对 — TSV 67行(表头1+数据66, 末行=[sub:03b] 追加的本脚本登记行, 文件内以 \n 结尾, wc -l=67 与 awk NR=67 一致), task-planner/scripts 内 selftest-*.sh 实际 65 个(平移后=66)
- [M3] `mv error-fix-prompt-forge/scripts/selftest-error-fix-prompt-forge.sh task-planner/scripts/`(保留 +x, 4703 字节) + `rmdir error-fix-prompt-forge/scripts` → error-fix-prompt-forge/ 剩余 SKILL.md + templates/
- [M4] Edit 修正路径解析(仅路径块+头注释, 断言逻辑零改动):
  - SKILL="$SKILL_ROOT/../error-fix-prompt-forge/SKILL.md"; TPL 同型 ../error-fix-prompt-forge/templates/fix-prompt-template.md
  - REG="$SCRIPT_DIR/selftest-registry.tsv"; CFG="$SKILL_ROOT/config.json"(平移前=SKILL_ROOT/../task-planner/*, 平移后脚本自身即在 task-planner/scripts)
  - 头注释追加 [2026-10-10 task-v157 级联修复 S3 提前执行] 位置平移说明 + SCRIPT_DIR 新位置口径说明
- [M5] 三脚本回归(worktree 内, bash 直跑):
  - `bash selftest-error-fix-prompt-forge.sh` → FP-01..08 全 PASS; `Total: 8 PASS=8 FAIL=0`; EXIT=0(FP-02 命中7 / FP-03 BLOCKED=6 根因未定位=6 / FP-04 QC-FP 8 机器可检查4 / FP-05 命中18 / FP-06 互现6 / FP-07 registry 末行命中 / FP-08 config 命中0)
  - `bash selftest-registry.sh` → T01 PASS / T02 PASS / T03 PASS / T04 PASS / T05 PASS; `Total: 5 PASS=5 FAIL=0 (registry rows=66, actual selftest=66)`; EXIT=0(修复前 T03 FAIL 孤儿行已消除: 新脚本进入 actual 计数集, 与 registry 末行双向对齐)
  - `bash selftest-self-resolution.sh` → SR-01..SR-13 全 PASS(含 SR-12 PASS `总行数 67=脚本数+表头(动态)`: 67 = ls selftest-*.sh 66 + 表头 1); EXIT=0
- [M6] progress.md Phase 3「Actions taken」下追加 `  - [sub:06] 级联修复:selftest 平移至 task-planner/scripts,3 脚本回归 PASS`(逐字按契约)
- [M7] findings.md 追加 `#### [sub:06-code-assistant] 级联修复:selftest 位置平移` 小节(平移/路径修正/三脚本回归输出/git 面)

## 验收核销

- [x] 新位置存在 task-planner/scripts/selftest-error-fix-prompt-forge.sh; 旧位置 scripts/ 目录已 rmdir
- [x] 路径解析按 iterative-optimizer 惯例修正, 无写死绝对路径
- [x] 三脚本全 PASS: self 8/8 + registry T01-05 + self-resolution SR-12(全 13 条 PASS)
- [x] 断言逻辑零改动(仅路径块 4 行 + 头注释 3 行变更, FP-01..08 原样)

## Scope 核销

- 未触碰: registry.tsv(保持 [sub:03b] 追加态)/其他 selftest/SKILL.md/模板/config.json; 无 git 写操作、无 rm -rf、无网络、无主仓写入; 全部操作限 worktree /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge

## 最终结论

```
status: done
acceptance: 4/4 pass — [1:PASS 新位置存在且旧 scripts/ 目录移除, rmdir 成功且 error-fix-prompt-forge/ 余 SKILL.md+templates/ 2:PASS 路径解析按 iterative-optimizer 惯例修正, 无写死绝对路径 3:PASS 三脚本全 PASS(self 8/8 + registry T01-05 + self-resolution 13/13 含 SR-12) 4:PASS 断言逻辑零改动, 仅路径块+头注释变更]
files: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh(+1, 平移落点+路径块/头注释修正, 断言零改动); /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/error-fix-prompt-forge/scripts/selftest-error-fix-prompt-forge.sh(-1, 旧位置 mv 移走, 空目录 scripts/ rmdir 移除); /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md(+1 行, Phase 3 Actions taken 追加 [sub:06] 行); /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md(+16 行, 追加 [sub:06-code-assistant] 小节)
evidence: bash selftest-error-fix-prompt-forge.sh→"Total: 8 PASS=8 FAIL=0" EXIT=0; bash selftest-registry.sh→"T03 PASS"+"Total: 5 PASS=5 FAIL=0 (registry rows=66, actual selftest=66)" EXIT=0; bash selftest-self-resolution.sh→"SR-12 PASS registry ... 总行数 67=脚本数+表头(动态)""Total: 13 PASS=13 FAIL=0" EXIT=0; ls error-fix-prompt-forge/→仅 SKILL.md+templates/
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/06-code-assistant.md (status: done)
findings_written: #### [sub:06-code-assistant] 级联修复:selftest 位置平移
blockers: none
confidence: HIGH
```
