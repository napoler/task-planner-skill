# Checkpoint: 2-executor — Phase 2 扩档级联（task-v113）
status: done

## 里程碑
- [M1] 方案 A 扩档落地：critical-rules.md 22.3.0+22.3.0b 插入 + 21.4/22.7/22.7.1/41.1/41.4/413 七处扩档 + SKILL.md 3 处 + templates/dispatch-examples 各 1 处
- [M2] 级联断言面完成：selftest-self-resolution.sh 新增 SR-13 静态锚（^22.3.0 行存在 + 资料先行/换道评估顺序/官方文档 关键词各 ≥1）；偏差披露 2 处（基线 pre-existing SR-11 FAIL 修复；SKILL.md ≤444 行硬锚净 0 行控）
- [M3] 验证通过：4 验收 selftest + selftest-skill-split 全 PASS；grep -c "22\.3\.0" = 9 ≥2；diff --stat 5 文件与级联清单一致；findings/progress 追加完成

## 逐处落地（全内容锚定位，实测无行号偏移）

| # | 文件:锚 | 改法 |
|---|--------|------|
| 1 | critical-rules.md:158（22.3 行尾） | 加「任一档位连续失败 ≥2 次 → 先走 22.3.0 资料先行档评估换道（task-v113）」，①-⑤ 原文不动 |
| 2 | critical-rules.md:158-159 之间（插入） | 22.3.0 资料先行档全文（本地帮助面 --help 全文/man/官方文档/README → 网络现成方案 research-assistant/Doc Search Agent/web-search，宪法 §七 衔接声明 + 35.2/35.6 分工声明 + 引用化零重复定义 + 尾注「前置评估动作档，五机械档 ①-⑤ 序号不变，不进 tier_order」）+ 22.3.0b 换道义务（≥2 次强制换道；评估顺序 ①现成方案 ②子代理隔离 ③拆解逐个击破；连续 3 次失败禁第 4 次同法 + [switch-path] 登记 Handoff rescue 列/progress Error Log；Rule 7 本体不动引用化） |
| 3 | critical-rules.md:149（21.4 行尾） | 加「换道评估顺序=现成方案(22.3.0)→子代理隔离→拆解逐个击破(22.3.0b)[task-v113]」 |
| 4 | critical-rules.md:167（22.7） | 「22.3 ①-④ 档位与 22.3.3」→「22.3 ①-④（含 22.3.0 评估）档位与 22.3.3」 |
| 5 | critical-rules.md:415（41.1 ⑤） | 「替代路径检索（Rule 35.2 三关）」→「替代路径检索（Rule 22.3.0 资料先行档：官方文档/网络现成方案 + Rule 35.2 三关）」 |
| 6 | critical-rules.md:418（41.4 清单） | ② →「22.3 ①-④（含 22.3.0 资料先行档评估）全试」；⑤ →「替代路径检索（22.3.0 官方文档/网络现成方案 + 35.2 三关）」 |
| 7 | critical-rules.md:413 | 「Rule 22.3 已定义五档兜底链（怎么兜底）」→ 加演进注「task-v113 扩 22.3.0 资料先行档后为六档语义，五机械档 ①-⑤ 序号不变」 |
| 8 | SKILL.md:385 | 「五档兜底」标题行加 22.3.0 资料先行前置评估演进注（并入标题行，表体 387-393 不动，控 ≤444 行） |
| 9 | SKILL.md:278 | Rule 41 摘要「替代路径」→「替代路径(含 22.3.0 官方文档/网络现成方案)」 |
| 10 | SKILL.md:406 | 反模式行追加「；同法失败 ≥2 次第 3 次仍同法且不登记换道理由(违反 22.3.0b 换道义务,task-v113)」（并入既有行） |
| 11 | templates/task_plan.md:261 | 「对齐 Rule 22.3 五档兜底链」→ 加「task-v113 后含 22.3.0 资料先行档」注 |
| 12 | references/dispatch-examples.md:33 | 「22.3 ①-④ 与 22.3.3 逐档」→「22.3 ①-④ 含 22.3.0 评估记录 与 22.3.3 逐档」（与 critical-rules.md:168 22.7.1 ②字段同口径，22.7.1 已同步改） |
| 13 | 零改动确认 | subagent-fallback.sh hint 串/tier_order 6 项（T10a 精确串全绿）、selftest-skill-collab T4-T5、selftest-fallback 全序、selftest-rescue-chain、check-rescue-chain、verify.sh:248、README:143、completion-gate:30、Rule 42-43 历史「零改动」声明（:422/:424/:430/:435/:437）全部未触碰 |
| 14 | selftest-self-resolution.sh | 新增 SR-13 静态锚（^22\.3\.0 行 ≥1 + 资料先行/换道评估顺序/官方文档 各 ≥1；零新 config 键由既有 SR-09 properties=40 守护）；header 注释 SR-01..SR-12 → SR-01..SR-13 |

## 偏差披露（2 处，超 14 项清单边界，均属基线修复）
1. **基线 pre-existing FAIL**：f549958 上 selftest-self-resolution.sh SR-11 已 FAIL（clean HEAD 树 git archive 复现实测：Total 12 PASS=11 FAIL=1）。根因=SR-11 宽容正则 `task-v099|task-v10[0-9]` 不匹配 selftest-skill-split.sh 已演进至 task-v112 的 label token。修复=正则扩 `task-v1[0-1][0-9]`（沿用 SR-11 既有宽容化先例，断言语义不变），非 14 项清单内容但为验收「selftest-self-resolution 全 PASS」必要。
2. **SKILL.md ≤444 行硬锚（selftest-skill-split T-主）**：基线 444 行满额。方案 8 的独立说明行（+2 行）与方案 10 的独立反模式行（+1 行）叠加会触发 T-主 FAIL。处置=22.3.0 说明并入 :385 标题行、22.3.0b 反模式并入 :406 既有行，净 0 行，T-主 恢复 PASS。级联清单 T10a hint 全序串未加 22.3.0（方案 13 项 13 明确 tier_order 机械面 6 项不动 + 零改动确认，T10a 保持全绿）。

## 验证证据
- `grep -c "22\.3\.0" critical-rules.md` = 9（≥2 PASS）；「官方文档」×4 /「现成方案」（网络现成方案）/「资料先行」×6 在位
- 4 验收 selftest：selftest-fallback.sh Total 31 PASS=31 FAIL=0 / selftest-rescue-chain.sh 11/11/0 / selftest-self-resolution.sh 13/13/0（含新 SR-13）/ selftest-skill-collab.sh 25/25/0；另 selftest-skill-split.sh 41/41/0
- `git diff --stat` 5 文件：SKILL.md(+3/-3)、critical-rules.md(+9/-7)、dispatch-examples.md(+1/-1)、selftest-self-resolution.sh(+15/-5)、task_plan.md(+1/-1)——与级联清单文件集一致，无清单外文件改动
- 未 git add/commit，worktree 外零写入（findings/progress/checkpoint 仅写入 plans/task-v113/ 指定路径）

## 最终结论（8 字段）

status: done
acceptance: 3/3 pass — ①22.3.0/22.3.0b 落地+41.1 扩档+级联 14 项逐处完成：22.3.0/22.3.0b 双行插入 critical-rules.md:159-160，21.4/22.7/22.7.1/41.1⑤/41.4②⑤/413/SKILL.md:385/:278/:406/templates:261/dispatch-examples:33 逐处原文在位，41.1⑤ 现读为「替代路径检索（Rule 22.3.0 资料先行档：官方文档/网络现成方案 + Rule 35.2 三关）」②验收命令实测：`grep -c "22\.3\.0" critical-rules.md`→9（≥2）；「官方文档」×4「资料先行」×6 在位；`bash WT/skills/task-planner/scripts/selftest-fallback.sh`→Total: 31 PASS=31 FAIL=0、`selftest-rescue-chain.sh`→11/11/0、`selftest-self-resolution.sh`→13/13/0（含新 SR-13）、`selftest-skill-collab.sh`→25/25/0 全 PASS（另 skill-split 41/41/0）③`git -C WT diff --stat`→5 files changed, 29 insertions(+), 17 deletions(-)（文件集与级联清单一致）；checkpoint 落盘含最终结论 8 字段块（本文件）
files: /mnt/data/dev/task-planner-skill-worktrees/task-v113/skills/task-planner/references/critical-rules.md(+9/-7); /mnt/data/dev/task-planner-skill-worktrees/task-v113/skills/task-planner/SKILL.md(+3/-3); /mnt/data/dev/task-planner-skill-worktrees/task-v113/skills/task-planner/templates/task_plan.md(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/task-v113/skills/task-planner/references/dispatch-examples.md(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/task-v113/skills/task-planner/scripts/selftest-self-resolution.sh(+15/-5); /mnt/data/dev/task-planner-skill/plans/task-v113/findings.md(+1 小节); /mnt/data/dev/task-planner-skill/plans/task-v113/progress.md(+1 行)
evidence: critical-rules.md:159→「22.3.0 **资料先行档（research-first rescue，task-v113…：工具持续报错或同一方法/档位连续失败（≥2 次…；:160→「22.3.0b **换道义务（anti-stall，task-v113）**：同一方法/档位失败 ≥2 次 = Rule 7 三击第 2 击强制换道——禁止第 3 次同法」；:417（原 415）→「⑤ 替代路径检索（Rule 22.3.0 资料先行档：官方文档/网络现成方案 + Rule 35.2 三关）」；SKILL.md:385→「五档兜底(优先级顺序,Rule 22.3 — 拆细先于升档;任一档连续失败 ≥2 次先走 22.3.0 资料先行前置评估…五机械档 ①-⑤ 序号不变)」；grep -c "22\.3\.0"→9；bash selftest-self-resolution.sh→「SR-13 PASS 22.3.0 资料先行档行存在 + 资料先行/换道评估顺序/官方文档 关键词在位 / Total: 13 PASS=13 FAIL=0」；git diff --stat→「5 files changed, 29 insertions(+), 17 deletions(-)」
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v113/subagent-state/2-executor.md (status: done)
findings_written: findings.md #### [sub:2-executor] 扩档级联
blockers: none
confidence: HIGH
