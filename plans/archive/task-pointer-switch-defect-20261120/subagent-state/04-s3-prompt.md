# S3 派发指令：SKILL.md D/E 类切换清单释放占用+回切 attest 口径（G2）

## 执行区（只改 worktree 内单文件）
- /mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/SKILL.md
- 禁碰其他文件；插入段守 Rule 106.1a（Edit 前 grep 段清单锚点，new_string 含锚行）

## 背景（自包含）
脚本层已修（init 一次切换+守卫锚定）。本单元修流程层：SKILL.md D 类意图切换清单①只写「挂起登记（[intent-switch] 行+断点检查点）」不释放旧计划 `.session-owner`，守卫仍会拦手动 set；且删 owner 后回切首轮 Edit task_plan.md 不触发重锁（zcode-posttooluse.sh:154-156 前置 owner==本会话 SID），下次 prompt 哈希校验报 PLAN TAMPERED——需补「回切先 attest」口径。

## 修改要求（先 Read SKILL.md 210-230 段定位三个锚块）
1. **D 类意图切换执行清单①**（约 :220，整句在「**意图切换执行清单（D 类定案后按序执行）**：」行内）：在「① 旧计划挂起登记（其 progress.md 追加 [intent-switch] 行+在途单元断点检查点）」后追加「+释放旧计划会话占用（删除其 `.session-owner`——挂起=会话不再认领；回切时 userpromptsubmit hook 自动重建）+回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md，防 PLAN TAMPERED 误报」
2. **E 类/Rule 94 隔离处置段**（约 :227，「确认切换后的处置（Rule 94…）」句内）：在「旧计划封存待 plan-resume、新目标独立 init、跨计划禁交叉写入」处同步补「封存=挂起登记+删除旧计划 `.session-owner` 释放会话占用（回切 attest 口径同 D 类①）」
3. 保持段落结构与其他条款不动；改动嵌在既有句子内（最小增量），禁重排段落
4. 注意：修改后的 D 类块（「意图切换执行清单」起到「回切通告模板」前）须含 `.session-owner` 与 `attest-plan.sh` 字样（VC-4 断言依赖）；E 类块（「目标切换判定（E 类」起到下一个 `###` 标题）须含 `.session-owner`

## 自验
- VC-4 官方命令复跑 rc=0（worktree 内）：
  `awk "/意图切换执行清单/{flag=1} flag{print} /回切通告模板/{exit}" SKILL.md` 内 grep 到 `.session-owner` 与 `attest-plan.sh`；E 块 awk 内 grep 到 `.session-owner`

## acceptance
- VC-4 官方命令 rc=0；git diff 仅 SKILL.md 且改动限于 D/E 两处条款；无段落重排
