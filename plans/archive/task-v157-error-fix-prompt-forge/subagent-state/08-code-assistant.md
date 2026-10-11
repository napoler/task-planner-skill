# Checkpoint — sub:08-code-assistant（CR 修复:断言加固）task-v157

## 修复对象
/mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh

## Milestones
- M1 (P1-1 FP-06): 槽位词循环 6 词宽 BRE → 候选 7 词（问题陈述/根因+证据/复现/禁改区/验证判据/回滚/参考材料）逐词 grep -qF 双文件互现, 阈值 ≥5 不变; 修复前已 grep 验证 7 词在 SKILL/TPL 两侧全部命中 → 实测 7/7 PASS
- M2 (P1-2 FP-05): 宽 OR 累计 grep -c（8 模式阈值 8, 近似恒真）→ 8 关键词（根因/复现/禁改区/验收/回滚/未验证假设区/DoD/验证命令）逐词 grep -qF 独立判定, 要求 8/8; n=0 兜底（P2-1 前半）; 修复前已验证 8 词在模板全部命中 → 实测 8/8 PASS
- M3 (P1-3 FP-04): grep -c 'QC-FP-'（实测 8=表行 6+正文引用 2）→ 锚定表行 grep -c '^| QC-FP-'（实测=6）, 阈值 ≥6 不变 → PASS
- M4 (P2-1 FP-07): FAIL 分支附 registry 末行快照 `$(tail -1 "$REG" 2>/dev/null | cut -c1-60)`
- M5 (P2-2 注释口径): 头注 L14/FP-05 代码注释/FP-05 ok 消息共 3 处「九槽位」→「八槽位锚, 逐词各 ≥1」
- M6 (Nit-1 FP-01): name=目录名做实——head -5 grep -m1 '^name:' 取值 sed 归一, 与 SKILL.md 所在目录 basename 字符串相等比对; FAIL 分支附 name/dir 双值诊断
- M7 回归: bash -n OK; wc -l=85(≤90); 三脚本复跑命令与输出:
  - `bash .../scripts/selftest-error-fix-prompt-forge.sh` → FP-01..08 全 PASS, `Total: 8 PASS=8 FAIL=0`, exit=0
  - `bash .../scripts/selftest-registry.sh` → T01-T05 PASS, `Total: 5 PASS=5 FAIL=0`, exit=0
  - `bash .../scripts/selftest-self-resolution.sh` → SR-01..13 PASS, `Total: 13 PASS=13 FAIL=0`, exit=0
- M8 契约落盘: findings.md 追加 `#### [sub:08-code-assistant] CR 修复:断言加固` 段; progress.md Phase 4「Actions taken」追加 `  - [sub:08] CR 修复:FP 断言加固,8/8 PASS`
- 负结果报告: 检查了 SKILL.md/模板/QC-FP 表行/registry/config.json 五个断言对象, 全部锚点 grep 实测在位, 未发现冲突; 改动限于被修脚本单文件（§4 禁改清单零违反）; 无 git 写操作/网络/主仓越界

## 最终结论
status: done
acceptance: 7/7 pass — [1:PASS P1-1 FP-06 grep -qF 互现 7/7 2:PASS P1-2 FP-05 逐词 8/8 3:PASS P1-3 FP-04 ^| QC-FP- 表行=6 4:PASS P2-1 n=0 兜底+FP-07 末行快照 5:PASS P2-2 三处注释改八槽位口径 6:PASS Nit-1 name=目录名比对 7:PASS 8/8 PASS exit 0+两脚本回归 exit 0]
files: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh(+15/-13, 净 +2 行→85 行); /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md(+1 段); /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md(+1 行)
evidence: bash 三脚本复跑→`Total: 8 PASS=8 FAIL=0`/`5 PASS=5`/`13 PASS=13` 全 exit 0; bash -n OK; wc -l=85≤90; grep -qF 逐词预验证 7/7+8/8 命中; grep -c '^| QC-FP-' SKILL.md=6
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/08-code-assistant.md (status: done)
findings_written: #### [sub:08-code-assistant] CR 修复:断言加固
blockers: none
confidence: HIGH
