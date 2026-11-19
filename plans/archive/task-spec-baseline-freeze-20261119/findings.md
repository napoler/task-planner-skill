# Findings & Decisions

## Requirements
- R1（用户原话要点，2026-11-19 /goal）：解决倒退行为——sess_ba603cf5 编写剧本时，33 集之前严格遵守模型 4-12s 视频生成限制（每个分镜都在范围内），该会话执行中产出多次 3s、15s 严重偏移模型能力的分镜，导致工作无法使用。
- R2（用户裁决）：这是倒退式开发——原来可用的规范被（恶意）篡改；要求修正当前 skill 运行中避免倒退式开发，已有规范不会被篡改。

## Research Findings

### F1 — 项目层根因（sess_ba603cf5 / StoryLab，只读取证，已证实）
- 4-12s 双界数值定义在弧规格与 script-craft M0 模板：`/mnt/data/dev/StoryLab/docs/series/jipin-nvdiaoshou/_arcs/罗布湖线/ep16plus-tarim-arc-plan.md:5`、`.../shennvhu-station-design.md:8`（"单集约 10-12 个 4-12s 生成段"）；`/mnt/data/dev/StoryLab/.zcode/skills/script-craft/references/story-outline-template.md:53` 写 `[4,12]s`（V59 生成单元时长下限锁）。
- **从未下沉到 storyboard-craft 技能层**：`/mnt/data/dev/StoryLab/.zcode/skills/storyboard-craft/SKILL.md:11` 明确"时长字段仅表示叙事时长建议…不作为任何制作流程的门控条件"；`references/storyboard-format.md:25` 示例"2-3秒"且无上下限。
- C87 无正式定义（`.zcode/skills/**`、`docs/standards/**` grep 无命中）；实作只写 `C87时长=3s≤12s`（缺 ≥4s 下限，EP33 `episodes/ep33/EP33-分镜-clean.md:69`、EP34 `:69`），`>12s` 可"超拍登记/待 QC-G4 复核"（EP33 `:199`）、"C87 NOTE登记"（EP44 `:100,:463` 汇总 `通过(NOTE)`）放行；QC-G4（`creation-sop/references/qc-gates.md:115-128`）无时长硬门。
- 实测分布：EP17-EP32 全部 215 镜标题时长 0 违规（4-12s），可见 `〔C87 拆分〕` 把超段压回 ≤12s（EP17 `:69`）；EP33-EP44 共 59 镜违规（3s/13s/15s/25s）。
- git blame：storyboard-craft 时长"非门控"语义自 2026-11-14 引入起即如此（`d655ff20`），4-12s 始终停留在弧规格/M0 模板层。**未发现"硬门被某次单点篡改成宽松"的证据**；真实机制是"硬约束从未固化为技能/QC 强制门"——结果上即规范被逐步丢弃的倒退。

### F2 — 通用 skill 层缺口（task-planner 仓，已证实）
- 现有冻结机制保护对象均非"项目业务规范基线"：attest-plan.sh 只锁 `task_plan.md`（`critical-rules.md:36` Rule 20.1）；判据冻结协议锁 verification.md 判据行（`verification-gate/SKILL.md:94,97`）；RefSet 冻结锁引用资产（`critical-rules-dispatch.md:99` Rule 23.12）；①-校验锁规则文件版本（`worktree-isolation.md:60`）；47.6a 只对可视觉判定硬约束逐条核验（`critical-rules-media.md:23`）。
- 派发侧 22.4d（`critical-rules-dispatch.md:64`）强制携带"连续性资产/台账/前序产出"，但无"规范基线路径+hash+逐条约束原文"字段；QC 侧 103.3a（`:237`）四维回读、106.3（`critical-rules-discipline.md:741`）全文档不变量回归，均不对"冻结的业务规范基线"逐条核验。
- 机器门（check-complete.sh / attest-plan.sh / run-verification.sh）以流程/结构为主；仅当约束被显式编码为 VC `Verify command` 时才可能检出，无通用"产物违反已确立硬约束"检测。
- **结论**：缺 Spec-Baseline Freeze 闭环（定义→冻结→派发携带→QC 回归→终验绑定），长序列中业务硬约束可被静默降级而不触发任何门控。这是通用能力缺口，与项目层"未下沉"互为因果。

### F3 — 反思门判定（Rule 102.0）
- 活跃计划 `task-skill-loop-guard-20261118` Goal = 资源失控 6 缺口（预算/范围/返工/上下文/版本校验/提交豁免），已 merge be068da、VC 全 PASS、部署/推送完成；与本次"规范完整性防倒退"无交集 → **D 类新任务边界**：开新计划，旧计划已完成无需挂起。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 复用 attest-plan.sh SHA-256 锁作为规范基线机器强制力，零新脚本 | 宪法 §二文本优先铁律：规则/偏好以文本条款落入指令载体即完成；新增脚本/hook/守护断言属范围扩张，未经用户显式要求禁实施。把 Spec-Baseline 清单写入 task_plan.md 受管区块即自动受 `[PLAN TAMPERED]` 保护 |
| 新条款编号（最终落地）：critical-rules 51.15 / dispatch 22.4e+103.3b / discipline 106.7 / verification-gate 84.15 | 实测现有上界后调整：51.14 已被 task-drift-fakeqc 占用（`critical-rules.md` 内 `- **51.14 完成声称…`），宽松 grep 发现后升为 51.15；22.4d/103.3a 改 22.4e/103.3b 避碰；避开 SA-15 负断言 `^96\.[8-9]`。plan 表内旧编号系规划期口径，以最终落地为准 |
| 4-12s 作为条款内判例锚，不跨仓修改 StoryLab 文件 | 用户要求"修正当前 skill"；StoryLab 侧规范下沉与 EP33+ 违规产物修复属另一仓的 `task-storyboard-duration-fix-001`，跨项目修改需显式授权（宪法 §五） |
| worktree 从 master（非 main）创建 | main 为陈旧无关历史（记忆 main-master-unrelated-histories-branch-gotcha）；①-校验 5 文件 main=wt SAME 通过 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 主仓 17 个 staged 改动（他会话 goal 自治/worktree 免询问）与 3 个目标文件重叠 | 按 task-skill-loop-guard 已验证 SOP：stash → worktree(master) → 实现 → 合并回 → `git stash pop --index` → 锚点相邻处并集解；stash 仅暂存 tracked 改动，plans/forensics 等 untracked 保留 |

## Resources
- 取证报告（本仓）：`forensics/sess-ba603cf5-transcript-findings.md`、`...-project-findings.md`、`...-skill-gap-analysis.md`
- StoryLab 记忆：`/home/terry/.zcode/cli/memories/projects/storylab-5517faafd9f7fb5a/memory/storyboard-duration-constraint-defect-pending.md`
- 关联在途（另一仓）：StoryLab `plans/task-storyboard-duration-fix-001`（曾因 /mnt/data 满阻塞；现 df 31G 可用）

## 收尾复核结论（2026-11-19，drift-checker + 主进程盘上复核）
- **F4 — 独立偏移检查判定 ALIGNED（P0=无）**：drift-checker 只读复核 R→VC 映射、6 条款正文、commit 范围、部署锚、他会话 staged、预存 selftest FAIL 归因；结论目标对齐、核心闭环实质落盘、范围未扩散、他会话 17 staged 未污染。检查点 `subagent-state/drift-check-20261119.md`。
- **F5 — VC-3 验收命令恒真假门已修（P1，主进程发现并修复）**：原 verification.md VC-3 的 `for pos in ~/...skills; do for f in skills/...; do [ ! -f "$pos/$f" ]` 把 `$pos/$f` 拼成 `.../skills/skills/...`，全部 `[ ! -f ] && continue`，末尾 `echo DEPLOY_DIFF_ZERO` 恒真——从未真正比对，且标题「5 部署位 diff=0 / 19 文件 64 锚」夸大。**修正**：路径改为 `$pos/${f#skills/}` 逐锚核验，覆盖 3 位核心规则锚 12/12 + 模板锚 4/4；正负例实跑（正例 DEPLOY_ANCHORS_OK，负控制错锚被抓 FAIL）证明门非恒真。
- **F6 — VC-2 口径收敛**：主仓实跑 4 脚本 SA20+RC28+DQ14+hash22=84 PASS/0 FAIL（原「110 断言」为另一脚本集口径）；3 部署位核心规则 4 文件锚全=1，agents 位 templates 目录缺失=该位既有形态非缺陷；zcode 位 task_plan.md 与他会话 Rule 28.2.2 草稿块 diff=按设计保留他会话内容、本任务「🔒 规范基线」区块同位=1 共存无误。
- **结论**：所有 P1 簿记/验收门问题已修正并经正负例复验；核心实现（Spec-Baseline Freeze 闭环 7 文件、commit 7db7a25、merge 879fb48）无漂移，P0=无。
- **F7 — 收尾期完成门与委派统计**：知识提取入库实跑（draft→31 行正式条目→INDEX.md:25，子代理写+主进程盘上复核）；check-complete 全 5 Phase complete 后仍 exit=1，根因=委派门 `unverified_delegation`（Phase 1/3/4 的 Executor 为计划模板预填类型名 explore/code-assistant/code-runner-agent，Handoff 表空未登记）而非交付缺陷。处置：如实回填——Phase 1 explore 子代理（取证 2 只）登记 Handoff；Phase 3/4 实际主进程直做，Executor 改「主进程（白名单②）」并登记。证据路径：check-delegation.sh:480-526（Handoff 交叉校验正则 `| <type> |`）、progress.md Phase 3/4、subagent-state/drift-check-20261119.md。
