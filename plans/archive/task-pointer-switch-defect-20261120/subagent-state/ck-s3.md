# Checkpoint S3 — SKILL.md D 类意图切换清单释放占用 + 回切 attest 口径、E 类/Rule 94 同步（G2，VC-4）

## 1. task_id
task-pointer-switch-defect-20261120 / Phase 2 / S3

## 2. status
done

## 3. summary
在 worktree `wt/task-pointer-switch-defect-20261120` 内仅修改 `skills/task-planner/SKILL.md`（git diff：2 hunks，行 220、227，各为单行内联替换，无段落重排），完成两处口径补充：
1. D 类「意图切换执行清单①」在「旧计划挂起登记」后追加「释放旧计划会话占用（删除其 `.session-owner`——挂起=会话不再认领；回切时 userpromptsubmit hook 自动重建）」+ 回切前 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md，防 PLAN TAMPERED 误报；
2. E 类「确认切换后的处置（Rule 94）」在 94.4 隔离处置「跨计划禁交叉写入」后同步补「封存=挂起登记+删除旧计划 `.session-owner` 释放会话占用（回切 attest 口径同 D 类①）」。
按 106.1a 纪律执行：Edit 前 grep 两处锚点均唯一命中（:220 / :227），new_string 含锚行子串；改动嵌在既有句子内、最小增量，其余条款与段落结构未动。

## 4. findings（改动点+行号，worktree 内 SKILL.md）
- :220 「**意图切换执行清单（D 类定案后按序执行）**」句内①项后内联追加：`+释放旧计划会话占用（删除其 .session-owner——挂起=会话不再认领；回切时 userpromptsubmit hook 自动重建）+回切后首个工具动作前先 bash attest-plan.sh（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md，防 PLAN TAMPERED 误报`（`.session-owner`、`attest-plan.sh` 均以反引号包裹）。
- :227 「**目标切换判定（E 类，P0 铁律）**」句内 Rule 94 处置 94.4 括号后内联追加：`；封存=挂起登记+删除旧计划 .session-owner 释放会话占用（回切 attest 口径同 D 类①）`（`.session-owner` 以反引号包裹）。
- 两处均为单行内增量，未新增/删除段落，未改动显性通告模板/切换登记最小字段/回切通告模板/判定顺序等其他条款。
- VC-4 断言依赖满足：D 块（「意图切换执行清单」起至「回切通告模板」前）含 `.session-owner` 与 `attest-plan.sh`；E 块（「目标切换判定（E 类」起至下一个 `###`）含 `.session-owner`。

## 5. evidence（VC-4 官方命令原样复跑 + diff）
### VC-4 官方命令（取自 verification.md:73 V-2.1 / :75 V-2.2）+ prompt 附加锚
```
PASS V-2.1 rc=0   # awk D块 | grep -q ".session-owner"
PASS D-attest rc=0 # awk D块 | grep -q 'attest-plan.sh'（prompt 要求附加）
PASS V-2.2 rc=0   # awk E块 | grep -q ".session-owner"（段边界=至下一个 ###）
```
命令原文：
- V-2.1：`bash -lc 'set -euo pipefail; WT="..."; awk "/意图切换执行清单/{flag=1} flag{print} /回切通告模板/{exit}" "$WT/skills/task-planner/SKILL.md" | grep -q ".session-owner"'`
- V-2.2：`bash -lc 'set -euo pipefail; WT="..."; awk "/目标切换判定（E 类/{flag=1; print; next} flag&&/^### /{exit} flag{print}" "$WT/skills/task-planner/SKILL.md" | grep -q ".session-owner"'`

### git diff 核对
```
git status --short ->  M SKILL.md / M init-session.sh(S1既有) / M set-active-plan.sh(S2既有)；无新增/untracked
git diff --stat     ->  SKILL.md | 4 +-- ; init-session.sh | 34 ; set-active-plan.sh | 28
git diff --unified=0 -- SKILL.md | grep '^@@' -> @@ -220 +220 @@ / @@ -227 +227 @@（仅两处）
```
本单元 diff 仅 SKILL.md 且严格限于 :220、:227 两行内联替换，无段落重排；init-session.sh/set-active-plan.sh 为 Phase 1 S1/S2 既有变更，本单元未触碰。

## 6. next_steps
- 主进程复核本 diff 与行号锚，回填 progress.md Phase 2 / findings.md G2 结论。
- S4（Phase 3）扩展 selftest PL-11+；终验由独立 Verifier 复跑 VC-1~VC-5（含 VC-4 两条官方命令）。
- Phase 4 合并回时须一并带上 SKILL.md 改动（与 S1/S2 脚本同批）。

## 7. risks
- 回切 attest 口径为流程文本约定（非机器强制）：依赖操作者按 SKILL 条款在回切首个工具动作前执行 attest-plan.sh 或先触发 prompt 重建 owner；VC-4 仅验文本锚点，行为层由 P2 回切流程执行期验证（FMEA Phase 2 已登记兜底）。
- E 类断句将原 94.4 括号内列举后的「禁把新目标就地吸收进当前计划」前插入分号Clause，语义为并列补充，未改变原禁止性条款；若 plan-resume 恢复语义后续细化，需复核该 Clause 与新口径一致性。

## 8. handoff
checkpoint: yes — /mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/subagent-state/ck-s3.md
