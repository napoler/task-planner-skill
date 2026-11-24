# S13 阶段 B 检查点 — 28-general-ops

status: failed

## 已完成里程碑（append-only）

- [2026-11-24] Step1 完成：Read deploy-runbook.md 全文（59 行）与阶段 A 检查点 27；确认固定量、阶段 B 的 B1/B1-特殊/B2/B3/B4 与「禁止事项」；§7 八字段返回格式取自 templates/subagent_dispatch.md（references/dispatch-examples.md 路径不存在，与阶段 A 记录一致）。
- [2026-11-24] 只读预检：BK 内 9 份补丁 + 45 备份齐全；dry-run-summary.txt 45 行（OK=44 / FAIL=1，唯一 FAIL 为 opencode 位 dispatch 文件）；pre-diff.txt 45 行；专用补丁 site-opencode_critical-rules-dispatch.md.patch 存在且 `--dry-run` rc=0；既有 .orig 3 个（均不在 9 文件清单内）记入 orig-baseline.txt。
- [2026-11-24] Step2 完成：B1 对 44 项预演 OK 项执行原补丁，B1-特殊对 opencode 位 dispatch 文件执行专用补丁；共 45 项全部 rc=0，完整输出 145 行写入 apply.txt，apply-failures.txt 为空。无整文件覆盖、无 cp（除 B4 恢复）、无 git 写操作、未派发子代理。
- [2026-11-24] Step3 触发 B4：B2 第 1 项（.zcode discipline）三项校验全达标（改后差异 0、新锚 7、硬校验 1）；第 2 项（.zcode SKILL.md）改后差异 0、新锚 6、硬校验 0（要求 1）→ 立即停止后续项，按 B4 `cp -p` 从 $BK/pre 恢复该文件，cmp_rc=0。post-diff.txt 仅 2 行、b2-results.tsv 2 行、b2-failures.txt 1 行。
- [2026-11-24] 根因只读交叉验证：对权威源 HEAD 的 6 个条款载体执行同一硬校验命令，计数为 1/0/0/0/0/0——除 discipline 自身外，HEAD 源文件均不含整条 28.9 条款行；手册 B2「第 1-6 载体硬校验=1」口径不可满足。失败文件改后差异=0（与 HEAD 源逐字节一致），补丁落位正确。未手工修补、未续验、未回滚其他文件。
- [2026-11-24] Step4 完成：B3 报告段追加到 deploy-report.md（执行概况 + 专用补丁 apply 输出原文 + 2 行已验证明细 + B4 停止/恢复 + 43 项未验证清单 + 残留核对）；明确标注 45 行明细表与 post-diff 45 行未达成。

## 进行中

none（B4 停止，等待主进程裁决：修订硬校验口径后续验，或整体回滚）

## 产出文件清单

- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/apply.txt`（+145 行，45 APPLY 块 / 45 RC=0）
- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/apply-failures.txt`（空）
- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/post-diff.txt`（+2 行；要求 45 行，因 B4 停未达）
- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/b2-results.tsv`（+2 行）
- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/b2-failures.txt`（+1 行）
- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/orig-baseline.txt`、`orig-final.txt`（各 3 行，diff 为空→无新增残留）
- `/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/deploy-report.md`（追加「阶段 B」段）
- 运行位 45 个清单文件：44 个已打补丁未验证；`/home/terry/.zcode/skills/task-planner/SKILL.md` 已按 B4 恢复至部署前状态
- 检查点自身：`/mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/28-general-ops.md`

## 错误与受阻

- B2 第 2 项硬校验不符（hard=0，要求=1）→ 已按 B4 停止并恢复该文件，未手工修补。
- 根因：手册硬校验命令提取 discipline 文件的整条 28.9 条款行并要求在 6 个载体中各出现 1 次；但权威源 HEAD 上仅 discipline 自身满足（计数 1/0/0/0/0/0），SKILL.md 等只写短引用不含整条条款行。属手册校验口径缺陷，非补丁落位错误（改后差异=0）。需主进程裁决校验口径或回滚。
- 已尝试方案：只读复核专用补丁 dry-run（rc=0）、复核改后差异与锚计数、对 HEAD 源 6 载体复算硬校验；未尝试放宽校验后继续（B4 禁止手工修补）。

## 最终结论

status: failed
acceptance: 1/45 项校验通过 — [1:PASS 2:FAIL(B4恢复) 3-45:NOT_VALIDATED(B4停)]；B1 45/45 patch rc=0
files: /mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/apply.txt(+145行); apply-failures.txt(空); post-diff.txt(+2行); b2-results.tsv(+2行); b2-failures.txt(+1行); orig-baseline.txt(+3行); orig-final.txt(+3行); deploy-report.md(+阶段B段); 运行位44文件已打补丁未验证; /home/terry/.zcode/skills/task-planner/SKILL.md 已按B4恢复; /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/28-general-ops.md(+1)
evidence: B1 执行数=45（原补丁44+专用1），45/45 rc=0；apply.txt 145行/45 APPLY块/45 `===== RC=0`，apply-failures.txt 空。B2 达标统计：改后差异 2/2 达标（均=改前0）；新锚 2/2 达标（第1项=7≥1，第2项=6≥1）；硬校验 1/2 达标（第1项=1，第2项=0不符）；bash 校验 n/a。不符项清单=[/home/terry/.zcode/skills/task-planner/SKILL.md 硬校验=0，已 B4 恢复 cmp_rc=0]。HEAD 源 6 载体同一硬校验计数=1/0/0/0/0/0。post-diff.txt=2行（要求45未达）；报告 45 行明细表未达（B4 停止）。无新增 .rej/.orig；既有 3 个 .orig 均在清单外。git status --short -- skills 与阶段 A 基线一致。opencode 位专用补丁 apply 输出原文：`===== APPLY [SPECIAL] /home/terry/.config/opencode/skills/task-dispatch/references/critical-rules-dispatch.md =====` / `patching file skills/task-dispatch/references/critical-rules-dispatch.md` / `===== RC=0 /home/terry/.config/opencode/skills/task-dispatch/references/critical-rules-dispatch.md =====`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/28-general-ops.md (status: failed)
findings_written: none
blockers: B2 硬校验口径缺陷——手册要求第1-6载体硬校验=1，权威源 HEAD 上仅 discipline 自身为1、其余5个为0；第2项触发 B4 已停止并恢复，需主进程裁决修订口径续验或整体回滚
confidence: HIGH
