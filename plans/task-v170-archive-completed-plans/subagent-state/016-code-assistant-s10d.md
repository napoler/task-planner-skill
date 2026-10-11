# 016-code-assistant S10d 检查点（selftest 内六处 SKILL.md 行号锚按实态校准）

- status: done
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans（分支 wt/task-v170-archive-completed-plans）
- 实态基准（grep 证据）：SKILL.md 现 559 行；`grep -n '含 Rule 40' SKILL.md` 唯一命中=L314（「Critical Rules 1-81（含 Rule 40-81 全集…）」）；L266/L278/L288/L289/L290 现值均无「含 Rule 40」括注内容（L267=「稳定性铁律」、L288=check-conflicts 步骤行，已逐行核对）→ S3 级联清单 267/279/289 算术建议已失效（S3 之后 v168/S10b-S10f 单元又在 288-313 区插入新行，L314 为 S10e commit dabf466 后的 1-81 epoch 行），按「先 grep 内容再定行号」协议六处统一校准为 314

## T1 里程碑（时间戳）
- 01:22 读入：006-code-assistant-s3.md 级联清单 A 段（六项）+ 两 selftest 全文 + SKILL.md grep 现值定位（含 Rule 40 唯一命中 L314；旧 622508a~1 SKILL.md L288≠括注行，证实 S3 算术建议 289 失准）
- 01:23 Edit #1 selftest-self-resolution.sh L18（SR-08 头注区）：SKILL.md:266→314，追加 S10d Rule 45 Why 括注
- 01:23 Edit #2 同文件 L91：(SKILL.md:266 括注演进)→(SKILL.md:314 括注演进)，追加 S10d 括注（S3 建议 267 失效说明）
- 01:24 Edit #3 同文件 L95：SKILL.md:288→314（v158 时点历史记录仅行号随实态校准，括注文本描述不改）
- 01:24 Edit #4 selftest-reliability-institution.sh L14：SKILL.md:278→314，追加 S10d Rule 45 Why 括注
- 01:24 Edit #5 同文件 L80：(SKILL.md:278 括注演进)→(SKILL.md:314)，追加 S10d 括注
- 01:25 Edit #6 同文件 L84：SKILL.md:288→314（v158 时点历史记录仅行号随实态校准）
- 01:26 验证：`grep -n 'SKILL.md:266\|SKILL.md:278\|SKILL.md:288'` 两文件 0 命中；`grep -c 'SKILL.md:314'` 各=3；bash -n 两文件 OK；实跑 baseline（commit 前）SR=11/13、RI=15/16，FAIL=SR-07/SR-08/R-09 三条——均为断言正则体（`Critical Rules 1-7[4-9]`/`40-(5[3-9]|6[0-9]|7[0-6])`/`40-[4567][0-9](\+[0-9]+)?`）不覆盖 1-81 epoch，与 S3 级联清单 C 段「epoch 断言属 S10 级联范围」登记一致，非本单元注释级改动引入（本单元 commit 前后 FAIL 集合完全不变）
- 01:28 git add 两文件 + commit 7ebc030 `fix(selftest): task-v170/Phase 4 S10d — SKILL.md 行号锚六处按实态校准`（2 files changed, 6 insertions(+), 6 deletions(-)，index.lock 一次成功，未触碰 SKILL.md/init-session.sh/registry.tsv 既有未提交变更——注：本 commit 时点 git status 显示三文件 M，add 仅限授权两文件）
- 01:30 复验：commit 后 `grep -n '含 Rule 40' SKILL.md`=L314 不变、wc -l=559 不变；重跑 SR/RI FAIL 集合与 commit 前一致（3 条既有 epoch FAIL，零新增）；worktree `git status` 干净

## 六处锚三步证据（校准前引用内容→grep 目标行现值→新行号）
1. selftest-self-resolution.sh:18 —— 原「SKILL.md:266 括注演进→（含 Rule 40-53 全集）」→ grep '含 Rule 40' SKILL.md 唯一命中 L314「含 Rule 40-81 全集」→ 314
2. selftest-self-resolution.sh:91 —— 原「(SKILL.md:266 括注演进)」→ 同上 L314 → 314
3. selftest-self-resolution.sh:95 —— 原「SKILL.md:288 实态=「含 Rule 40-71 全集」」→ L314（L288 现值=check-conflicts 步骤行，无括注）→ 314（v158 时点文字保留）
4. selftest-reliability-institution.sh:14 —— 原「SKILL.md:278 括注演进→（含 Rule 40-53 全集）」→ L314 → 314
5. selftest-reliability-institution.sh:80 —— 原「(SKILL.md:278 括注演进)」→ L314 → 314
6. selftest-reliability-institution.sh:84 —— 原「SKILL.md:288 全集声明实态=「Rule 40-71 全集」」→ L314 → 314（v158 时点文字保留）

## 最终结论（=§7 返回块）
status: done
acceptance: 3/5 pass
files: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/selftest-self-resolution.sh(+3/-3); /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/selftest-reliability-institution.sh(+3/-3)
evidence: commit 7ebc030 `2 files changed, 6 insertions(+), 6 deletions(-)`；grep -n 'SKILL.md:266\|SKILL.md:278\|SKILL.md:288' 两文件→0 命中（校准前残留清零）；grep -c 'SKILL.md:314' 两文件→各 3；grep -n '含 Rule 40' SKILL.md→L314「Critical Rules 1-81（含 Rule 40-81 全集）」（六处锚目标行唯一实态）；bash -n 两文件→OK；实跑 SR=11/13、RI=15/16，FAIL 仅 SR-07/SR-08/R-09 三条既有 epoch 断言正则（1-81 未覆盖，S3 级联清单 C 段登记=S10 epoch 范围，本单元前后 FAIL 集合零变化）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/016-code-assistant-s10d.md (status: done)
findings_written: none
blockers: 第二条验收「实跑两 selftest 对应断言 PASS」未达成——SR-07/SR-08/R-09 断言正则为 1-76 epoch 既值（`1-7[4-9]`/`40-(5[3-9]|6[0-9]|7[0-6])`/`40-[4567][0-9](+N)`），S10e 已将 SKILL.md epoch 推至 1-81，三断言需随动正则扩围（归 epoch 级联 S10e/S10f 或后续单元，非 S10d 注释级 scope；本单元六处注释锚全部完成且断言语义零变化）
confidence: HIGH
