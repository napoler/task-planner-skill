# checkpoint 027-code-assistant-s10n（task-v070/Phase 4 S10n：selftest epoch 断言扩围 1-81）

任务锚: R2「必须添加归档。」；S-unit=S10n [parallel-group:g-cascade2]，Rule 46.1 单任务。
worktree 路径裁决：提示词给的 task-v070 worktree 路径不存在，实存即 task-v170-archive-completed-plans 仓（与 020 checkpoint 路径裁决一致），全部操作在该仓内执行。

## T1 里程碑（时间戳）
- 2026-10-12 02:30 读入两目标文件 + 020 失败证据（第 13/14 条=SRV-03/SRV-12、第 15 条=TS-05）+ research-first.sh:75 扩围范式（ERE '1-(7[0-9]|81)' cntE 通道先例）
- 2026-10-12 02:31 实态探针：SKILL.md `Critical Rules 1-8[01]`=2（L314/L406）、`1-(7[4-9]|8[01])`=3、`1-39`=0、`1-82`=0；负样本 echo 'Critical Rules 1-82'|grep -cE 'Critical Rules 1-(7[4-9]|8[01])'=0（不命中）；正样本 '1-81'=1
- 2026-10-12 02:32 Edit#1 summary-readability.sh:71-77 SRV-03：cntE '1-7[4-9]'→'1-(7[4-9]|8[01])'（注释头:10 同步），附 Rule 45 扩围注释（Why=task-v170 落地 Rule 81）
- 2026-10-12 02:33 Edit#2 tool-selection.sh:56-69 TS-05：主锚 grep -cE 'Critical Rules 1-7[4-9]'→'Critical Rules 1-(7[4-9]|8[01])'，保留负断言 b='1-39'=0；头部断言清单注释与 [级联] 历史注释同步，附 Rule 45 注释
- 2026-10-12 02:34 验证：bash -n 两文件通过；负样本 '1-82' 对新 ERE=0（不命中）；实跑 summary-readability → SRV-03 PASS / SRV-12 FAIL(pass=8 fail=1) / Total PASS=12 FAIL=1 rc=1；实跑 tool-selection → TS-05 PASS / Total 12 PASS=12 FAIL=0 rc=0
- 2026-10-12 02:35 SRV-12 连带定位：9 脚本逐一单跑=8 PASS + selftest-absorption-discipline FAIL（AD-12 pinning 漂移：其 _pin_lit 期望 tool-selection.sh 内字面 'Critical Rules 1-7[4-9]'，本单元扩围后计数=0）。lane-advancement 单跑 rc=0（3 次复跑稳定，020 的 LA-12 由同批单元修复）
- 2026-10-12 02:37 git add 两文件 + commit ebe21ac（一次成功，无 index.lock 冲突；worktree status 空）

## SRV-12 连带清单（如实记录，本单元不越权修）
| 脚本 | 状态 | 根因锚 |
|---|---|---|
| selftest-absorption-discipline | FAIL (AD-12) | selftest-absorption-discipline.sh:73 `_pin_lit "$SCRIPTS/selftest-tool-selection.sh" 'Critical Rules 1-7[4-9]'` —— 本单元 TS-05 主锚扩围后该字面在 tool-selection.sh 计数=0（grep -cF=0 实测），AD-12 的 11 处 pin 第 1 处破 |
| 其余 8 脚本 | PASS | context-pressure 9/9、lane-advancement 14/14、tool-selection 12/12、requirement-coverage 23/23、research-first 12/12、self-resolution 13/13、source-anchor-discipline 12/0、root-resolution 17/17 |
需后续单元扩 absorption-discipline.sh AD-12 的 pin 字面至 'Critical Rules 1-(7[4-9]|8[01])'（或宽容族）后 SRV-12 才能 9/9。

## 负结果与边界
- 未改本单元两文件之外任何文件（020 名单 15 脚本中其余 13 脚本未触碰）；未改 config.json；未在真实 plans/ 数据执行命令（只读 grep 均在 worktree 内）
- 未发现与 SRV-03/TS-05 之外断言的冲突；lane-advancement 单跑 3 次 rc=0 稳定，无输出漂移
- 未验证项：AD-12 修复后的 SRV-12 终态（本单元范围外，需后续单元）

## 最终结论（T5，=§7 同块）
status: done
acceptance: 3/3 pass（AC1 两断言实跑 PASS + 负样本 echo '1-82' 不命中已贴证；AC2 bash -n 两文件通过 + Rule 45 注释附入两文件；AC3 evidence 齐备：diff 行+两脚本 Total 行均已贴，SRV-12 连带状态如实记录未越权修）
files: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/selftest-summary-readability.sh(+8/-3) /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/selftest-tool-selection.sh(+6/-2)（commit ebe21ac，2 files changed, 11 insertions(+), 8 deletions(-)）
evidence: selftest-summary-readability.sh:72 cntE '1-7[4-9]'→'1-(7[4-9]|8[01])'（diff 头:10/71-77）；selftest-tool-selection.sh:67 grep -cE 'Critical Rules 1-(7[4-9]|8[01])'（diff :9/56-69，负断言 b='1-39' 保留）；实跑 `bash selftest-summary-readability.sh`→'SRV-03 PASS: SKILL 接线锚(1-(7[4-9]|8[01])≥3)'+'SRV-12 FAIL: 9 级联脚本(pass=8 fail=1 expect 9/9)'+'Total: PASS=12 FAIL=1'；`bash selftest-tool-selection.sh`→'TS-05 PASS SKILL.md 字面锚 Critical Rules 1-(7[4-9]|8[01])≥1 且 1-39=0'+'Total: 12 PASS=12 FAIL=0' rc=0；负样本 `echo 'Critical Rules 1-82'|grep -cE 'Critical Rules 1-(7[4-9]|8[01])'`→0（不命中）；bash -n 两文件无输出（通过）；git commit ebe21ac
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v070-archive-completed-plans/subagent-state/027-code-assistant-s10n.md (status: done)
findings_written: none
blockers: SRV-12 连带 FAIL——selftest-absorption-discipline AD-12 pin 期望字面 'Critical Rules 1-7[4-9]' 被本单元扩围破除，需后续单元扩 AD-12 pin 字面
confidence: HIGH
