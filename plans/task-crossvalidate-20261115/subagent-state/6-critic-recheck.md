# 6-critic-recheck — Phase 3-S2 critic 独立复检（Rule 103.3 / 103.3a 全文回读）

**对象**：worktree `8097063` 五文件终态文本（规则文 108 段 / verification-gate SKILL / task-planner SKILL 四锚 / verification 模板 CV 区块 / selftest-cross-validation.sh）+ 旁证 enumerate-first.sh、user-session-log.md #1
**回读证据**：5 文件全文逐行 Read（rule 70 行全读 / vg-SKILL 96 行 / tp-SKILL 283 行 / 模板 148 行 / CV 脚本 27 行）+ 旁证 2 文件全文 + 108 段与 clause-drafts.md §1 逐字 diff（IDENTICAL）
**维度**：A R 覆盖性 / B 条款质量 / C 级联完整性 / D 守护有效性 / E test-gaming

## A. R 覆盖性
- R1（方法论识别执行错误）= 108.1 定义+触发面（:62）、108.3 双视角（:66）在位 PASS
- R3（识别效率）= 108.5 抽样→全量（:70）部分承载；无时效/成本维度 → NIT
- R4（反虚构）= 108.2 独立重推导+untrusted 标注+判例锚（:64）、108.5 造假信号（:70）PASS
- R5（技能与步骤）= SKILL 双级联+模板区块在位 PASS
- **[MINOR-m2]** R2「不是说必须使用多高的模型」负向约束 108 全文无载体：`sed -n '60,70p' ... | grep -c '模型'` = 0。缺「路径独立性不得以模型升档替代」类反例句；108.3「视角互异+信息源不共用」可间接拦截 → 定 MINOR

## B. 条款质量
- 五子条行首锚可 grep（`^108\.[1-5] `），与 84.4/84.7/103 分工句在 108.1 末句（:62「互补不复写」）PASS
- **[MINOR-m1]** 108 块缺「机制」声明段：`sed -n '60,70p' | grep -c '机制'` = 0，而同文件 84.14:58 收尾有「机制（文本优先 L0-T…判定面/机器面/零新 config 键）」。后果=规则自无机器面声明，守护退化为纯文本自证
- **[MINOR-m3]** verification-gate SKILL 执行步骤（Step1:36 / Step2:50 / Step3a:58 / Step3b:64）无 108 步骤，仅调用时机第 7 项（:32）+References（:92）→ 「触发有、步骤无」不对称（R5 步骤面靠模板区块独撑）
- **[NIT-m4]** task-planner/SKILL.md:224 枚举句「…（均 task-discipline 卫星））、Rule 108 交叉验证纪律域（verification-gate 卫星）」：全角括号 7 开 7 闭=配对无误，但顿号悬垂于闭合括号后、108 域落在「含…」枚举之外，与同行「其余 94 条」口径割裂

## C. 级联完整性
- 四锚全改实锤：:9（frontmatter 1-108+94）、:220（Rule 84,108）、:224（索引段）、:267（References 1-108）；`grep -c '1-107'` SKILL.md = 0 PASS
- 引用真实性抽验：103.3a（critical-rules-dispatch.md:235）与 decision-arbiter（~/.zcode/agents/decision-arbiter.md）均真实存在，非幻锚 PASS
- **[MAJOR-M1]** 「其余 94 条」计数错，正确=91：SKILL.md:9 与 :224 两处。算式=108−14 核心−3 未落地预留号（critical-rules.md:182「Rule 77/78/79 为 task-v168 预留未落地号」；:141 同口径）；先例算式 1-106→89、1-107→90（plans/archive/task-serial-sync-20261115/progress.md:88、:107）；clause-drafts.md:39 草案本就写「其余 91 条」。实现偏离草案 +1，findings.md:55 的「顺带修正陈旧计数」为无据声称（旧值 90 并非陈旧，先例任务显式设定）
- **[MINOR-m5]** 无「1-107 残留=0」负断言：EN-07（enumerate-first.sh:103）只护 1-105；纪元演进后 SKILL.md 的 1-107 清零面零守护
- **[MINOR-m7]** 计划簿记漂移：task_plan.md:225 Phase2 Status=complete 而 :229-233 五个 S-unit 状态列仍 `pending`；Handoff #8/#9/#10（:365-367）仍 `queued` 而 checkpoint 3d-enumerate-epoch.md / 5-regression.md 已在位

## D. 守护有效性
- 实跑复现：`bash skills/task-planner/scripts/selftest-cross-validation.sh` → Total 6 PASS=6 EXIT=0；enumerate-first → 7/7；selftest-registry.sh → 5/5（registry rows=98/actual=98）
- **[MAJOR-M2]** CV-01（:16）只断言 5 个 `^108\.N`，无 `^### 108 ` 段标题锚：删掉段标题则 108.1-108.5 静默并入 Rule 84 段，CV-01 仍 PASS。旁证先例 EN-01（enumerate-first.sh:47）明确断言「行首 `### 105 `」，且 EN-01..05 用 SEC105 局部化（:44 awk）消除全文空壳可过（注释 :13 记录 R3 修复动机）——CV-02/03/05（:18/:20/:24）退回全文 grep，空壳可过面回归
- 计数面守护缝隙（M1 放大器）：三处既有计数断言均为通配窗——selftest-dual-qc.sh:97 `其余 9[0-9] 条`、selftest-anti-deferral.sh:89 `其余 [89][0-9] 条`、selftest-subagent-activation.sh:68 同——94 落在窗内全部放行，错误计数不可检测
- **[MINOR-m6]** verification-gate/SKILL.md:5 `allowed-tools: "Read, Bash, Grep, Glob"` 无 Agent：108.3「并行派发」（:66）/108.4「decision-arbiter 派发」（:68）在卫星内不可执行（各有 Bash 分支兜底 → MINOR 非 MAJOR）

## E. test-gaming / 伪造排查
- 条款正文 vs 草案 §1 逐字 diff = IDENTICAL（未静默弱化）PASS
- CV-03 草案含 `|| grep -q '108'` 兜底（clause-drafts.md:68），落地删除（selftest:20）→ 收紧而非放水，方向 PASS
- EN-06 `,107` 保持不动（草案 clause-drafts.md:43 原拟 `,107`→`,108`）→ 属域归属正确修正（Rule 108 归 verification-gate，discipline 路由行 SKILL.md:210 真实未变），非放水 PASS
- 唯一实质偏离=**M1**（未验证的「陈旧计数」修正 + 未同步锁步计数断言窗）→ 归 MAJOR，见 C
- 排除（负结果）：未发现以删断言/放宽阈值为产出适配的其它迹象；四锚与特性文本无删减

## CR 结论
**CHANGES_REQUESTED** — 2 MAJOR（M1 计数 94→91 应改；M2 CV-01 补 `^### 108 ` 段标题锚 + CV-02/03/05 局部化到 SEC108）、5 MINOR（m1/m2/m3/m5/m6/m7）、2 NIT（m4 + R3 时效面）。
修复要求：① SKILL.md:9/:224 `其余 94 条`→`91 条`（并同步 findings.md:55 口径说明）② selftest-cross-validation.sh CV-01 增 `grep -qE '^### 108 '`、CV-02/03/05 改 SEC108 局部 awk ④（可选但建议）DQ-08/AD-10/SA-12 计数窗收紧为精确值。

## 最终结论（103.5 五要素 + 8 字段）
status: done
acceptance: 9/9 pass — [A:R1/R3/R4/R5 有载体、R2 负向约束缺（MINOR）; B:五子条可 grep、分工句在位，缺机制声明+步骤承载（MINOR×2）; C:四锚全改+残留清零+引用真实，但 94≠91（MAJOR）; D:两脚本非真空 exit0，段标题锚缺失+全文 grep 回归（MAJOR）; E:条款逐字未弱化、CV-03 收紧，实质偏离仅 M1] + CHANGES_REQUESTED
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/SKILL.md(+0/-0 只读); skills/verification-gate/references/critical-rules-verification.md(只读); skills/verification-gate/SKILL.md(只读); skills/task-planner/templates/verification.md(只读); skills/task-planner/scripts/selftest-cross-validation.sh(只读); skills/task-planner/scripts/selftest-enumerate-first.sh(只读)
evidence: SKILL.md:9、:224（其余 94 条）; critical-rules.md:141/:182（77/78/79 未落地）; plans/archive/task-serial-sync-20261115/progress.md:88/:107（89→90 先例）; clause-drafts.md:39（草案 91）; findings.md:55（陈旧计数声称）; selftest-cross-validation.sh:16/:18/:20/:24; selftest-enumerate-first.sh:44/:47/:103; selftest-dual-qc.sh:97; selftest-anti-deferral.sh:89; selftest-subagent-activation.sh:68; verification-gate/SKILL.md:5/:32; critical-rules-dispatch.md:235
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/6-critic-recheck.md (status: done)
findings_written: #### [sub:2-critic-recheck]（findings.md 仅追加节锚）
blockers: none
confidence: HIGH
