# Checkpoint S2 — set-active-plan.sh claimant 判定锚定 + skip「指针未切换」+ claimant mtime 选取（G3+G4）

## 1. task_id
task-pointer-switch-defect-20261120 / Phase 1 / S2

## 2. status
done

## 3. summary
在 worktree `wt/task-pointer-switch-defect-20261120` 内仅修改 `skills/task-planner/scripts/set-active-plan.sh`（+28/-5 左右，见 git diff），完成三件事：
1. claimant in_progress 判定从全文裸匹配改为锚定状态控制行的正则（与 S1 的 init-session.sh:1255 同款，兼容加粗/非加粗两种真实形态）；
2. skip 路径 WARN 增加明确「指针未切换：」前缀，保持 stderr + exit 0（调用点影响评估已在 progress.md:19 留痕：zcode-sessionstart gc/selftest×2/plan-hygiene/plan-doctor 均提示性，无 hook 依赖 set 子命令退出码）；
3. claimant 扫描由 glob 字母序首命中 break 改为「owner 文件 mtime 最新者优先」（`stat -c %Y`，含空值/非数字兜底）。
gc 分支（:195-199）经 HEAD vs 当前逐行 diff 确认无变化；--force/--sid 解析、原子写、全局指针分支未动。

## 4. findings（改动点+行号，worktree 内 set-active-plan.sh）
- :244-250 新增 claimant 选取 mtime 优先的 What+Why 注释 + `claimant_mtime=0` 初始化。
- :261-266 原 `claimant=...; break` 改为：取 `stat -c %Y`（失败兜底 0）→ 数字合法性 case 守卫 → 仅当 claimant 为空或 mtime 更大时更新 claimant/claimant_mtime；不再 break。
- :270-275 新增 G3 锚定判定的 What+Why 注释（现象/根因/修法，注明 2026-11-20 task-pointer-switch-defect-20261120）；旧 grep 调用字面未写入注释，避免 VC-3 静态反向假红。
- :278 判定行 `grep -qi 'Status.*in_progress'` → `grep -Eq '^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress'`。
- :282-284 新增 G4 文案强化注释（含调用点评估结论与保持 exit 0 的理由）。
- :285 skip WARN 文案加前缀「指针未切换：」；:262-263 --force 分支文案原样未动；:286 `SKIP_SIDE_WRITE=1`、:295 `exit 0` 保持。
- 静态反向：剥全行注释后无 `grep -qi .Status.*in_progress.` 残留（VC-3 命令 rc=0）。

## 5. evidence（夹具输出与命令）
### /tmp 四夹具（脚本 /tmp/pts2-fixtures/run.sh，全 /tmp mktemp 隔离）
```
PASS B-exit0(rc=0)
PASS B-指针未切换
PASS B-side未写target-b
sessA rc=0 err=[active-plan] WARN: side 键 sid=pta3994 曾被计划 comment-only 声明（已 complete/不存在），fail-open 继续写入
PASS A-注释fail-open写side
PASS C-散文complete写side
D-WARN: [active-plan] WARN: 指针未切换：side 键 sid=ptd19638 已被在途计划 prose-claimant 声明，skip 写入防沿袭互踩；--force 可覆盖
PASS D-mtime最新claimant
PASS D-未误指认旧claimant

TOTAL PASS=7 FAIL=0
```
夹具 D 中 `a-claimant` 字母序在前但 mtime=2026-01-01，`prose-claimant` 字母序在后但 mtime=2026-06-01；WARN 指认后者，证明确为 mtime 选取而非 glob 顺序。

### 官方 VC 命令原样复跑（/tmp/pts2-fixtures/vc-check.sh，取自 verification.md）
```
PASS VC2 (rc=0)
PASS VC3 (rc=0)
PASS V11 (rc=0)
PASS V12 (rc=0)
```

### 语法/范围/回归
```
bash -n skills/task-planner/scripts/set-active-plan.sh -> OK
git status --short ->  M init-session.sh(S1既有) / M set-active-plan.sh(本单元)；无新增脚本/无 untracked
gc 段 195-199 HEAD vs 当前 diff -> empty（无变化）
裸 grep 残留(非注释) -> 无裸匹配残留
selftest-pointer-lifecycle.sh -> Total: 10 PASS=10 FAIL=0, SELFTEST_RC=0
```
git diff stat（worktree 全量）：`init-session.sh | 34 ++++`（S1）、`set-active-plan.sh | 28 ++++---`（本单元）；总计 2 文件、54 insertions/8 deletions。本单元 diff hunk 仅 `@@ -241,6 +241,13 @@` 与 `@@ -251,18 +258,31 @@`，不含 :195-199。

## 6. next_steps
- 主进程复核本 diff 与行号锚（findings.md/progress.md 回填 S2 结论）。
- S3（Phase 2）修 SKILL.md D/E 类释放 `.session-owner` 口径；S4 扩展 selftest PL-11+（含 mtime claimant 场景可选纳入）。
- 终验时由独立 Verifier 复跑 VC-1~VC-5。

## 7. risks
- mtime 选取依赖 GNU `stat -c %Y`（Linux 平台已确认可用）；同秒 mtime 并列时退化为 glob 字母序，属可接受边界（fixture 用不同日期规避）。
- exit 0 保持（G4 仅强文案）：若未来新增依赖 set 子命令退出码的自动化，需重新评估；当前调用点评估已留痕于 progress.md:19。
- S1 的 init-session.sh 改动为 worktree 既有变更，本单元未触碰；合并回时须一并带上。

## 8. handoff
checkpoint: yes — /mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/subagent-state/ck-s2.md
