# [sub:16-code-assistant] 锚长尾清账 checkpoint（status: done）

> task-v144 S16：7 个 selftest 的 SKILL.md 旧锚宽容正则扩展（1-5x 纪元→含 6x 纪元，适配 References 行已演进的「Critical Rules 1-62」）
> 工作路径：/mnt/data/dev/task-planner-skill-worktrees/task-v144（禁触其他 worktree）
> 日期：2026-10-08

## 基线（改前实跑，FAIL 锚定位）
- selftest-conclusion-discipline.sh：CD-12 FAIL（编号错位显示，实为 CD-11 宽容锚断言）`SKILL.md 宽容锚「1-3[5-9]」0 +「1-4[5-9]|1-5[0-9]」1 合计 ≥3` → Total 24 PASS=23 FAIL=1
- selftest-error-loop.sh：EL-11 FAIL `SKILL.md 缺 Rules 1-3x` → Total 16 PASS=15 FAIL=1
- selftest-execution-honesty.sh：EH-09 FAIL `「Rule 40-5[3-9]」=0（应 ≥1，级联漏改）` → Total 14 PASS=13 FAIL=1
- selftest-reflect-verify.sh：RV-10 FAIL `缺 'Rules 1-3[5-9]' 宽容锚` → Total 12 PASS=11 FAIL=1
- selftest-skill-split.sh：T-锚 FAIL `Rules 1-3 计数锚 ≥1` → Total 41 PASS=40 FAIL=1
- selftest-veto.sh：VT-10 FAIL `SKILL.md 缺 Rules 1-3x` → Total 13 PASS=12 FAIL=1
- selftest-root-resolution.sh：RR-09 + RR-16 双 FAIL → Total 17 PASS=15 FAIL=2

根因：SKILL.md 全集声明已演进 1-62（58/59/60/62 落地），7 脚本旧宽容正则（4x/5x 纪元）判定面失配。

## 修改（7 文件，三同步=断言+docblock+诊断串，级联注释 `[2026-10-08 task-v144 合并级联]`）
1. selftest-conclusion-discipline.sh（CD-11 L9 docblock + n45 断言 + 诊断串）：`1-4[5-9]|1-5[0-9]` → `1-[4-6][0-9]`（单锚合并扩面，旧 4x/5x 保留兼容 + 6[0-2] 纳入，合计 ≥3 语义零改动；现状命中 4≥3）
2. selftest-error-loop.sh（EL-11）：`Rules 1-3[1-9]` → `Rules 1-(3[1-9]|[4-6][0-9])`（SKILL.md 现状命中 L274 Rules 1-12 + L290 Rule 1-28 语义面）
3. selftest-execution-honesty.sh（EH-09，同 SR-08 范式）：`Rule 40-5[3-9]` → `Rule 40-(5[3-9]|6[0-9])`（现状 40-62 命中=1）
4. selftest-reflect-verify.sh（RV-10）：`Rules 1-3[5-9]` → `Rules 1-(3[5-9]|[4-6][0-9])`
5. selftest-skill-split.sh（T-锚）：固定字面 `grep -c 'Rules 1-3'` → 宽容 `grep -cE 'Rules 1-(3[0-9]|[4-6][0-9])'`（1-62 纪元旧字面零命中=级联漏改面；3[0-9] 全 3x 兜底保留）
6. selftest-veto.sh（VT-10）：`Rules 1-3[1-9]` → `Rules 1-(3[1-9]|[4-6][0-9])`（同 EL-11 范式）
7. selftest-root-resolution.sh（RR-09 主断言 `Critical Rules 全集 1-5[3-9]` → `1-(5[3-9]|6[0-9])`（现状 1-62 命中=1）+ 负断言旧纪元清单 `1-(51|53)` → `1-(51|53|55)`（并入 1-55，强度不减弱）；RR-16 定位字面 `'（Rules 1-39'`（1-62 纪元零命中）改 `'详见 `references/critical-rules.md`（Critical Rules'`（=1），主断言 `Rule 40-5[3-9]` → `40-(5[3-9]|6[0-9])`，逐号式兜底判定（50 与 53）保留）

## 验证（改后实跑，全 FAIL=0 exit 0）
- `bash selftest-conclusion-discipline.sh` → `Total: 24 PASS=24 FAIL=0`
- `bash selftest-error-loop.sh` → `Total: 16 PASS=16 FAIL=0`
- `bash selftest-execution-honesty.sh` → `Total: 14 PASS=14 FAIL=0`
- `bash selftest-reflect-verify.sh` → `Total: 12 PASS=12 FAIL=0`
- `bash selftest-skill-split.sh` → `Total: 41  PASS=41  FAIL=0`
- `bash selftest-veto.sh` → `Total: 13 PASS=13 FAIL=0`
- `bash selftest-root-resolution.sh` → `Total: 17 PASS=17 FAIL=0`

git diff 复核：本单元仅触碰上述 7 文件（worktree 其余 M 文件=前序 S1-S15 既有产物零触碰；periodic-review.sh PR-03/04/05 登记遗留禁修面未触碰）。未 git add/commit，未 git stash。

## 负结果记录
- 检查依赖面：SKILL.md（grep 实测：`Critical Rules 全集 1-(5[3-9]|6[0-9])`=1、`(全集|Rules) 1-(51|53|55)`=0、`详见 `references/critical-rules.md`（Critical Rules``=1、`Rule 40-(5[3-9]|6[0-9])`=1、`Rules 1-(3[1-9]|[4-6][0-9])`=2、`Rules 1-(3[5-9]|[4-6][0-9])`=2、`1-[4-6][0-9]`=4、`Rules 1-(3[0-9]|[4-6][0-9])`=2）
- 未发现冲突：7 脚本断言互不依赖，各自 SKILL.md 判定面独立；SR-08（selftest-self-resolution.sh）已先行落 6x 范式本单元仅对齐，零触碰
- 排除风险：RR-16 定位改字面后 idxn=1 唯一性已实测（grep -cF=1）；SPLIT 兜底面 3[0-9] 宽于原 1-3 前缀（原 `grep -c 'Rules 1-3'` 是前缀子串匹配，新正则是纪元族匹配——判定面同语义不缩）

## 落盘
- findings.md §`[sub:16-code-assistant]` 已追加（## Research Findings 段末）
- progress.md Phase 3「Actions taken」已追加 `[sub:16]` 行
- 本 checkpoint = 最终结论
