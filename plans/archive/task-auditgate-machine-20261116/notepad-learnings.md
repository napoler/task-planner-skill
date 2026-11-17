# Notepad & Learnings — task-auditgate-machine-20261116

## New Requests (追加区，执行期持续更新)

| Date | Request | Source | Notes |
|------|---------|--------|-------|
| 2026-11-16 | 对 task-planaudit-20261116「三、未完成项与风险」执行：1 授权（CA-6 机器面→attest [audit-gate]+checker+selftest）2 测试（正负例+走门实证） | user-session-log.md #1（逐字锚「1 授权 2 测试」「三、未完成项与风险」） | 仅计划审计门机器化+测试，不扩其他机器面；worktree 隔离+合并后 deploy/push |

## What Worked

- 先 Read 基线文件再落计划：`attest-plan.sh` 门链锚点、`check-tier-consistency.sh` rc 契约、selftest/registry 范式、Rule 109/SKILL 现文、先例 APPROVED 留痕均有 file:line 证据，避免设计猜测。
- 采用独立 checker + attest shell-out 同构（tier-consistency/vc-nonvacuous 先例），可独立 fixture 测试并降低门链内联漂移。
- 将判别性绑定在新增 token/文件（`[audit-gate]`、`--skip-audit-check`、新 checker/selftest、registry 新行），避开既有 `[plan-audit-skip]` 计数噪声。
- 计划期显式登记 env-only enforce、skip 入缓存键、109.7 保留+109.8 追加，提前覆盖已知高风险面（FMEA RPN 160/192）。
- R1 独立审计（14 发现）修复轮：以 F8 自举时序为设计级矛盾，冻结方案 a（D1 走既有文本审计链路，机器门 Phase 5 自举实测）；同步收紧 cksum 三项、skip 语义、VC 执行被验证物、checker 形态/rc 语义。
- R2 独立审计（6 新发现）修复轮：把自举实测归主进程 merge-back 后主仓路径并加 `[audit-gate]` 实质断言；VC-6 范围断言改 worktree+untracked+merge-back 前；VC-1/VC-2 增正向 rc0 用例。
- R3 独立审计（I1+W1/N7/N8）修复轮：VC-6 命令改 fail-closed（worktree 缺失/git 失败即 exit1、越界非空即 FAIL），并把 merge-back 前 `[scope-check]` 留痕定为唯一权威证据；Phase 5 V-N 与终验时点统一；VC-2 负例前清缓存；VC-1 措辞对齐实测 rc。
- R4 独立审计（C-1/I-1/W-1/W-2/N-1/N-2）修复轮：先盘上复现 C-1 双零陷阱（`grep -c ... || echo 0` → `0\n0` → test rc=2）再改 `test -f && ! grep -q`；VC-6 改**两段式**（留痕断言+live 复跑分离），把范围断言本体下沉到 Phase 5 S2 内嵌命令，彻底消除「live worktree 断言 vs S2 强制清理」互斥；白名单补 `$` 尾锚并以合成仓双态实测证明旧正则确实放行 `SKILL.md.bak`；grep rc 显式捕获并以非法正则实测 rc=2 → exit1；:269 残留矛盾清理为两段式口径；VC-1 补 r2（mini×L1 冲突负向）枚举。
- **R6a 单点加固（主进程 /tmp 一手实测）**：先用两形态 mock checker 在 `/tmp/r6a` 做六态判别性实测（终态/中间态/真实截断态/追加簿记块/段内元引用/真实终态），确认「旧形态假 PASS、加固形态真 FAIL、终态无假阴性」三面后才动计划文件；加固手段=① 聚合边界止下一个 H2 ② 结论行 ERE 行首结构锚定 ③ 中间态假阳性负例进 VC-1 Verify command（r4 用例实测：新形态 rc=0 / 旧形态 rc=1，证明 r4 承重）。

## What Didn't Work

- 计划期尚未执行机械门与 D1 critic 审计；VC-5 行为面证据依赖执行期真实留痕，不可在计划期伪造。
- 无法在本轮验证 selftest/attest 实际运行结果（实现尚未在 worktree 落地）；receipt 中仅能给计划文档门控结果。
- 初版计划把 D1 时点走机器门写成实证，忽略新门 Phase 3 才创建（F8）；初版 cksum 只纳入 skip_audit，漏 enforce/progress 哈希（F3/F4）；初版 VC-3/VC-6 验证不执行被验证物（F13/F1）——R1 审计全部打回，已增量修订。
- R2 前 VC-6 断言在主仓工作树做，被他任务未提交修改误判且看不到 wt/ 分支改动（N1）；自举实测误放子代理且在 merge 前用主仓旧脚本，rc=0 可假通过（N2）；VC-1/VC-2 只有负例，恒拒锁桩也能过（N4）。
- R3 前 VC-6 scope 断言仍失败开放：worktree 缺失时 git 报错→stdout 空→`test -z ""` PASS；且 S2 验收含 worktree 清理，V-N 时必走真空路径（I1）——已改 fail-closed 并把证据前移到 merge-back 前留痕。
- **R3 的 fail-closed 改造本身引入回归（R4 C-1/I-1）**：① 只做「非真空」静态判定，未干跑命令本体 —— `test "$(grep -c ... || echo 0)" -eq 0` 零命中时变量为 `0\n0`，恒 rc=2；② 未核对**复跑时点资源存续** —— live `test -d "$WT"` 与 S2 强制清理互斥，终验必 FAIL；③ 白名单正则无 `$` 尾锚，`SKILL.md.bak` 类副产物静默放行。
- **存量基线未先量测 → R4b 已改判**：`run-selftests.sh --fresh` 实测 7 FAIL（存量，非本任务引入）。原 VC-6 写「全量 FAIL=0」属**绝对零判据**，在跨任务共享仓必然被击穿（Phase 5 必 FAIL → outcome 禁 COMPLETE）；微修轮 4b 已改为「同集零增量」并冻结基线集合（`task_plan.md` Phase 1「selftest 基线冻结」块）。教训：跨任务共享仓的回归 VC 不能写绝对零。
- **R6a mock 自测脚本自身有 bug（已修正）**：首版「加固形态」mock 在首个 `## ` 处 `exit`，只聚合了**首个**审计段 → 终态 fixture 假 FAIL（s4d NEW rc=1）；改 `inbuf=0; next`（置零后继续扫描后续审计头）后六态全对。教训：写「测试的测试」时要覆盖正例/负例/**多同类头**三面，否则 mock 会骗过自己。
- **R6a 表格内写转义管道导致机械门错列（已修正）**：把完整 ERE（含 `\|`）写进 Phase 3 S1 验收格 → `check-plan-dispatch.sh` 的 `awk -F'|'`（:246-305 未剔 `\|`）把 6/7/8 列错位，报「S1 时长不可解析 / 粒度三值格式不可解析 / 输入 3 个文件路径」。修正=表格内禁裸/转义管道：完整正则单点存 `verification.md` VC-1（列表项），表格内只写「三段结构 + 指路」。教训：**改表格单元格后必须复跑列敏感的机械门**，`rc=0` 不等于输出干净（本次 rc 仍 0，缺陷只体现在 SKIPPED 提示里）。

## 🚫 被否决方案（User Rejected — Rule 32）
- （暂无）

## Files Modified

| File | Changes |
|------|---------|
| `plans/task-auditgate-machine-20261116/task_plan.md` | 新建完整 rule-enhancement 计划 + R1（F1-F14）+ R2（N1-N6）+ R3（I1 留痕/W1 时点）+ R4（I-1 两段式与 :269 清理/W-2 token 形态/N-1 rc 捕获与白名单一致性/S2 内嵌命令块）+ **R4b（Phase 1「selftest 基线冻结」块 :241-253 + 判据六处同步 :24/:83/:120/:294/:305/:408 + Current Phase/Next Step 事实同步）** + **R5（:253 漂移双闸 / :296,:306,:310 与 :407 SCOPE-OK 定位改全文件 token 口径 / :205 Current Phase 与 :209 Next Step 同步 R5 态）** + **R6a（根源覆盖表「门控判定器实现」行 / CA-7 行 / Phase 3 S1 验收 / VC-1 判据与验证方式 / Phase 2 与 Phase 3 S1 checkbox：聚合边界止 H2 + 结论行 ERE 行首锚定 + 中间态假阳性负例；Current Phase/Next Step 同步 R6a 态）** + **R7（VC-1 判据：`问题清单` 容忍括注 + H2 前提 + rc2 口径；CA-7/S1 验收同步；Current Phase/Next Step 同步 R7 修复态；Handoff 新增 #17/#18 与派发算术 14 次）** |
| `plans/task-auditgate-machine-20261116/findings.md` | R1/R2/R3/R4/**R4b**/**R5**/**R6a** 修复轮处置对照、技术决策与基线更新（存量 7 FAIL 行由「待处置」改「已改判同集零增量」；**R6a 新增「checker 末段聚合中间态假阳性」段 + Issues 三行（R6 APPROVED / R6a 实测加固）** + **R7 修复轮处置对照表（I-1/I-2/W-2/Q-1/Q-2）+ R7 教训三条 + Issues 增 R7 行；技术决策/基线三处 token 定义同步容忍括注**） |
| `plans/task-auditgate-machine-20261116/knowledge-brief.md` | 同步自举/skip/cksum/形态/rc2/迁移、N1/N2/N6、R3 fail-closed、R4 双零陷阱/ugrep/存量 7 FAIL 事实与易错点；**R4b 新增 §8「回归判据设计」四条教训 + §2 基线行改判**；**R5 §4-13 改全文件 token 口径 + 新增 §9「断言时序与产出位置互洽」五条教训**；**R6a §2 先例聚合命令行补加固说明（六态实测证据 + 两硬约束 + 存量先例不改写）** + **R7 §2 补 I-1 容忍括注判据/I-2 独立负例/Q-1 H2 前提/Q-2 rc 口径 + §4-10 改写 + 新增 §4-16/17** |
| `plans/task-auditgate-machine-20261116/progress.md` | 追加 R1/R2/R3/R4/**R4b**/**R5**/**R6a** 修复轮记录；审计留痕占位按 N5 改写（仍无 APPROVED 预写）；**R5 追加 Phase 5 段 `[scope-check]` 槽位说明行 + N-2/N-3 行尾括注**；**R6a 追加末段段（不含 [plan-audit-RN] 头）：六态实测表 + 逐落点处置 + VC-1 命令收据 + 八门 rc + 自身两处缺陷披露 + 三约束自证** + **R7 追加 `## 2026-11-17 R7 修复轮` H2 段（H2 规范自证）+ 占位区写作规范行 + 复跑留痕** |
| `plans/task-auditgate-machine-20261116/verification.md` | VC-1/2/3/5/6、Phase 5 自举实测（merge 后主仓）、全量回归+部署 diff；VC-6 两段式 + C-1 config 断言重写 + N-2 r2 枚举；**R4b：VC-6 判据/Evidence/Verify command/Goal Gate 四处改「同集零增量」**；**R5：VC-2 断言时序重排（:21）+ VC-6 全文件严格 token 正则与漂移双闸（:35-37）+ V-1.1 时点注记（:53）+ 5-Question/交叉验证同步（:200,:207-211）**；**R6a：VC-1 判据两约束 + Verify command 增 r4 中间态负例（:15/:17）+ VC-3 fixture 清单（:23）+ 知识储备核验行 + 5-Question/交叉验证同步 R6a 态** + **R7：VC-1 判据容忍 token/H2 前提/rc 口径/r5-r7 枚举（:15）+ Verify command 增 r5/r6/r7（:17）+ Evidence 七例清单（:16）+ VC-3 用例与承重归属（:23）+ 知识储备核验行 + 交叉验证/5-Question 同步 R7 修复态** |
| `plans/task-auditgate-machine-20261116/notepad-learnings.md` | 记录 R1/R2/R3/R4/**R4b**/**R5**/**R6a** 审计教训与修复轮文件/验证结果（R6a 新增：mock 自身 bug、表格内管道错列两条 What Didn't Work + 三条通用规则） |
| `plans/task-auditgate-machine-20261116/subagent-state/fix-R4.md` | R4 轮 checkpoint（逐项处置与实测输出） |
| `plans/task-auditgate-machine-20261116/subagent-state/fix-R4b.md` | R4b checkpoint（动工前登记轮次/范围/开始时间，完成后回填逐项处置与实测输出） |
| `plans/task-auditgate-machine-20261116/subagent-state/fix-R5.md` | 本轮（R5）checkpoint（动工前登记轮次/范围/开始时间/环境事实，完成后回填逐项处置与实测输出） |
| `plans/task-auditgate-machine-20261116/subagent-state/fix-R6a.md` | R6a 单点加固轮 checkpoint（动工前登记范围/计划实测；完成后回填六态实测、落点处置、机械门 rc 与自身缺陷披露） |
| `plans/task-auditgate-machine-20261116/subagent-state/fix-R7.md` | R7 修复轮 checkpoint（动工前登记五项计划与约束自检；完成后回填处置、/tmp 判别性实测、八门 rc 与三约束自证） |
| `plans/task-auditgate-machine-20261116/user-session-log.md` | **未修改**（append-only 权威源，已含 #1 逐字原文与镜像） |

## Verification Results
- Verified: R1 审计 14 发现已逐项处置（F8 自举条款/ck 三项/skip 语义/VC 执行/checker 语义/迁移登记）。
- Verified: R2 审计 6 新发现已逐项处置（N1 worktree 范围断言/N2 主进程 merge 后自举+实质断言/N3 V-N/N4 正向用例/N5 占位改写/N6 缓存取舍）。
- Verified: R3 审计 I1+W1/N7/N8 已逐项处置（VC-6 fail-closed + S2 `[scope-check]` 留痕/V-N 时点统一/VC-2 清缓存/VC-1 措辞）。
- Verified: R4 审计 C-1/I-1/W-1/W-2/N-1/N-2 已逐项处置；C-1 双态实测（旧 rc=2 / 新真实 config rc=0 / 含键 fixture rc=1 / 缺文件 rc=1）；W-1 合成仓双态（控制组 rc=0，`SKILL.md.bak`/`attest-plan.sh.bak`/`other-script.sh` 各 rc=1，旧正则对照确证放行 `.bak`）；N-1 rc 捕获（非法正则 rc=2 → exit1；`|| true` 形态掩蔽 rc=0；rc=1 合法续行）；I-1 段锚 awk 正反态（Phase 5 段内 token rc=0；仅后续 `##`/`###` 段出现 token rc=1 不误判）〔该「段锚 awk」形态已被 R5 I-1 取代，见下 R5 Verification Results〕。
- Verified: `check-plan-dispatch.sh` rc=0（仅 2 条非阻断 WARN：plan-tier 提示、p1-baseline 组内执行体同质）；`check-delegation.sh stats` verdict=ok / rate=0.800 / violations=[]。
- Verified: `check-rvc-coverage.sh` rc=0（R=3 VC=6 映射行=3）；`check-vc-nonvacuous.sh` rc=0（6 条 VC 无真空命令）；`check-template-type.sh` rc=0（rule-enhancement）；`check-tier-consistency.sh` rc=0（standard/L1）；`check-step-placeholders.sh` rc=0；`check-goal-cjk.sh` rc=0。
- Verified（R4b，2026-11-17）: VC-6 改「同集零增量」并实测 8 项 —— TC-A 正向 rc=0（新判据 vs 真实基线 `FAIL=7` + 7 名单）；TC-B1 rc=1（真实基线 + 假 FAIL 名 `selftest-fake-new` 且 `FAIL=8`）；**TC-B2 rc=1（计数仍 `FAIL=7` 但名单被换 → 证明整行等值是承重的，只断言计数会被绕过）**；TC-C rc=1（旧判据 `FAIL=0` 对当前基线，冲突确证）；TC-D rc=0 / TC-E rc=1 / TC-F rc=1 / TC-G rc=0（VC-6 Verify command 端到端：抽取 `verification.md:37` 原文，仅替换 `P=` 与脚本路径字面量，注入/移除 Phase 5 `[scope-check]` 留痕分别验证通过/失败/对照）。
- Verified（R4b）: 八门真实 rc 全 0（`check-tier-consistency` lines=477 phases=5 —— 新增 `####` 小标题未扰动 Phase 计数；`check-step-placeholders` 扫描 22 行=原 21+新增 1）。**如实披露**：`check-complete.sh <plan>/task_plan.md` rc=1，原因=Rule 27.3 porcelain「scope 内存在未提交变更」（整个 plan-dir 仍为 untracked，计划期既有状态，非本轮引入），该门属 Phase 5 终验工具，不作本轮完备性证据。
- Failed: R1/R2/R3/R4 审计均 REJECTED → 已逐轮修复；实现/自测/Phase 5 自举实测尚未开始，不得声称通过。
- **Failed（存量基线，非本任务引入；R4b 已冻结为对照集合）**: `run-selftests.sh --fresh` → `Total: 99 PASS=92 FAIL=7 (run=99 reused=0)` + `Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability`；7 项均为他任务在途遗留。VC-6 判「`Failed:` 集合==冻结集合且 `FAIL=7`」（同集零增量），不再要求绝对 `FAIL=0`；合法漂移须 `[baseline-shift]` 留痕 + 同步字面量，禁静默放宽。
- Verified（R5，2026-11-17）: 八发现逐项处置落盘；**C-1 断言时序**（/tmp mock + 命令正文逐字取自 `verification.md:21`，仅替换 `A=` 路径）：旧形态 rc=1（插桩 `r1=1 n=1 r2=0 p=0`）/ 新形态 rc=0（`r1=1 n=0 r2=0 p=0`）/ 破坏变体（负例也建锁，应被 `test ! -f` 抓到）rc=1。
- Verified（R5）: **I-1 六态**（严格 token 正则）：现状无留痕 rc=1 / Phase 5 段末插入 rc=0 / EOF 追加 rc=0（S2 真实形态）/ 缺 SCOPE-OK rc=1 / 缺 `diff=N` rc=1 / 带项目符号前缀 rc=1；**端到端**（抽取 `verification.md:37` 原文，仅替换 `P=` 与 run-selftests 路径为 mock）：TC-A 正向 rc=0、TC-B 去留痕 rc=1、TC-C 假 FAIL 名 rc=1；`bash -n` vc6/vc2 均 rc=0。
- Verified（R5）: **N-1 config 三态**：含键 rc=1 / 真实 config 无键 rc=0 / chmod 000 不可读 rc=1（旧 `! grep -q` 形态同态 rc=0=fail-open，对照确证修复承重）；端到端不可读 config rc=1、真实 config rc=0。
- Verified（R5）: 三约束自证——R1-R3 逐字锚 `task_plan.md:16-18` 逐字未动；`user-session-log.md` mtime 仍 `2026-11-16 23:39:23.409788871 +0800`；`progress.md` 无审计段级 `结论: **APPROVED**` 预写（命中 4 行均为规则说明/自述句）。
- Verified（R5）: 八机械门真实 rc 全 0（check-plan-dispatch / check-delegation stats / check-rvc-coverage / check-vc-nonvacuous / check-template-type / check-tier-consistency / check-step-placeholders / check-goal-cjk）。
- Verified（R6a，2026-11-17）: **checker 聚合六态判别性**（`/tmp/r6a` 两形态 mock）——s1 终态 OLD 0/NEW 0；**s2 中间态（REJECTED 段 + 后随含反引号元引用修复轮块）OLD 0 假 PASS / NEW 1**；**s3 真实 `progress.md` `head -304` 截断态 OLD 0 假 PASS / NEW 1**；s4d 真实全文件+追加簿记块 OLD 0/NEW 0；s5 段内唯一 APPROVED 为行中元引用 NEW 1（锚定约束独立承重）；s6 真实全文件 OLD 0/NEW 0；s7 追加本轮 R6a 块后 NEW 0（终态聚合仍为 R6 结论行）。
- Verified（R6a）: **VC-1 Verify command 端到端**（从 `verification.md:17` 逐字提取，仅替换 `C=` 为 mock）：`bash -n` rc=0；新形态 RUN rc=0（SUBS r1=1 r2=1 r3=0 r4=1）；旧形态 RUN rc=1（SUBS r4=0 假 PASS 被抓 → 证明 r4 用例承重）；该行反引号计数=0。
- Verified（R6a）: 八机械门真实 rc 全 0，且修正后 `check-plan-dispatch.sh` 无本轮引入的 SKIPPED 噪声（仅余既有 2 条非阻断 WARN：plan-tier 提示 / p1-baseline 组内执行体同质）。
- Verified（R6a）: 三约束——R1-R3 逐字锚 `task_plan.md:16-18` 未动；`user-session-log.md` mtime `2026-11-16 23:39:23.409788871 +0800` / 4355 B / sha256 前 12 位 `d12cd51f8604`；`progress.md` 未锚定结论 token 计数=6（与写入前同值，均为规则说明/自述句）、**锚定形态计数=1（仅 R6 真实终态段）**、未新增 `[plan-audit-RN]` 段。
- Verified（R7，2026-11-17）: **I-1 token 新旧判据对照**（同一真实 R6 字节形态 fixture，`/tmp/r7t`）——字面 `问题清单:` 判据 rc=1（误拒真实 plan-dir）/ 容忍括注判据 rc=0；端到端 `TOKEN_MODE=strict` 时 VC-1 rc=1 且 `r7=1`（证明 r7 用例承重）。
- Verified（R7）: **I-2 四变体 × 五 fixture**（`full` 完全加固 / `onlyb` 仅边界 / `onlya` 仅锚定 / `old` 全缺）：`real_r6`=0/0/0/0、`spec`=0/0/0/0（无假阴性）；`mid(中间态)`=1/1/1/0；**`fxa`=1/0 假PASS/1/0**、**`fxb`=1/1/0 假PASS/0**（半加固各被对应 fixture 独立击穿，期望反转达成）。
- Verified（R7）: **VC-1 命令端到端七态**（`verification.md:17` 逐字提取，仅替换 `C=`；`bash -n` rc=0；反引号=0）：`full` rc=0（SUBS r1=1 r2=1 r3=0 r4=1 r5=1 r6=1 r7=0）/ `onlyb` rc=1（r5=0）/ `onlya` rc=1（r6=0）/ `old` rc=1（r4=r5=r6=0）/ `strict` rc=1（r7=1）。
- Verified（R7）: 补充行为态 mock 直测——`progress.md` 缺失 rc=2（WARN 判定器输入异常）/ 空文件 rc=1 / chmod 000 rc=2；无声明 legacy rc=0 且输出 `[audit-gate] SKIP legacy-no-decl`；mini×L1 rc=1；mini 单独 rc=0 SKIP；L1+ 写 skip 仍按 APPROVED 判定。
- Verified（R7）: 八机械门真实 rc 全 0（`check-tier-consistency` lines=491=489+Handoff 新增 2 行；`check-plan-dispatch` SKIPPED 计数=0）；三约束——R1-R3 锚未动、`user-session-log.md` sha `d12cd51f8604`/mtime 未变、`^## [plan-audit-R*]` 段数=7 且锚定 APPROVED=1（未新增审计段）。

## 📚 必要知识储备备注
- 本次新发现的知识源: `check-tier-consistency.sh` 的精确档位解析可直接作为 `check-plan-audit-gate.sh` L1+ 判定范式；`selftest-plan-dispatch.sh` 的 attest 集成 fixture 形态适配审计门正负例。
- 值得入库的书目/文献: （无外部文献；先例 `plans/archive/task-planaudit-20261116/` 与 `knowledge/entries/task-planaudit-20261116.md` 已是内部基线）
- 待补齐的知识缺口: 执行期需确认 `attest-plan.sh` 实际缓存键变量命名与 `check-plan-audit-gate.sh` 最终 CLI 签名是否与计划一致（以实现为准并回填）。

## Notes for Next Time
- 实现前必须先创建 worktree `tmp/worktrees/task-auditgate-machine-20261116`（分支 `wt/task-auditgate-machine-20261116`），在隔离区修改 `attest-plan.sh` 等运行中基础设施。
- 自举风险：D1 时新 `[audit-gate]` 尚未存在（bootstrap: gate-absent）；Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 自举实测（rc=0 + `grep [audit-gate]`），需先有 critic 写入的 APPROVED 留痕（含三 token 最小形态）。
- VC-6 **两段式**：范围断言本体在 merge-back 前于 worktree 执行（task_plan Phase 5「S2 内嵌命令」，含 `$` 尾锚与 grep rc 显式捕获），通过后写 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 入 progress.md（**文件末尾追加**）；终验 VC-6 只复核该留痕（**全文件严格 token 正则** `^\[scope-check\] <ISO8601> SCOPE-OK diff=N untracked=N$`——R5 I-1：段锚 awk 与 EOF 追加形态不兼容，已废弃），**不再 live 断言 worktree**（S2 清理后 worktree 已不存在，live 断言必败）。部署位 diff 在 merge-back 后由 V-5.2 验证。
- Phase 5 前先跑一次 `run-selftests.sh --fresh`，与 `task_plan.md` Phase 1 冻结的 `Total:`/`Failed:` 行逐字比对：`FAIL=7` 且名单一致=同集零增量 PASS；出现新的 FAIL 名=本任务回归（必须处置，禁改冻结块）；若因他任务收口导致基线合法变化，须重跑冻结 + `progress.md` 记 `[baseline-shift]` + 同步 VC-6 字面量，禁静默放宽。
- selftest fixture 全在 `/tmp` 并 trap 清理；严禁写真实 `plans/` 与 `.plan-attestation` 指针污染。
- 完成后 `--deploy` + push，并按 Rule 84.14/终验要求更新 verification 证据与 check-complete。
- **VC-1 现含七个 fixture（R7 后）**：r1 空 progress（rc1）/ r2 mini×L1（rc1）/ r3 规范示意形态（rc0）/ r4 中间态（rc1）/ r5 fixture a 段内裸文 APPROVED（rc1）/ r6 fixture b 后随 H2 块锚定 APPROVED（rc1）/ r7 真实生产形态（rc0）。实现 checker 时**七态必须同时满足**；若只实现对 r1-r4，r5/r6 会暴露半加固、r7 会暴露 token 形态脱钩。
- **聚合边界与 rc 口径两个写作/实现前提**：① 审计段后随块**必须 H2**（`## `）——本文件及 progress.md 的所有修复轮/登记块均按 H2 追加，禁止用 `### ` 或粗体标题；② `progress.md` 缺失/不可读→rc2（fail-open+WARN）、存在但空→rc1（无留痕），selftest 的 rc2 用例须**删除**文件。

## 通用规则（General Rules — Rule 31.7）
| 规则名称 | 适用条件 | 具体措施 |
|----------|----------|----------|
| 先基线后判别 | 为既有机制加机器门/新增自测 | 先记录改前 grep/ls/registry 计数与既有 token，再选“新增 token/文件”为 VC 判别面，避免与历史载体混淆 |
| 门链四点一致 | attest 类新增 skip/门控 | 同步变量声明、参数解析、缓存键、缓存回放 WARN；并将 checker 置于 hash/写 attestation 前 |
| 缓存键含证据面 | 审计/门控依赖 progress 留痕 | cksum 纳入 skip+enforce env+`sha256(progress.md)`；正负 fixture 独立内容/清缓存，防陈旧 PASS |
| 自举先分类 | 本计划自身要被新门校验 | 先判新门何时创建：D1 时不存在→登记 bootstrap: gate-absent，机器门证据放执行后期（Phase 5 自举实测），禁把“门不存在=默认通过”当实证 |
| 自举归主进程/merge 后 | 会话绑定脚本自举实测 | 执行体=主进程（SKILL.md:56 禁子代理跑 attest）；时点=merge-back 后主仓新脚本；断言=rc0+`grep [audit-gate]` 实质行，防旧脚本/缓存假通过 |
| 范围断言用 worktree | 隔离开发任务的范围校验 | 用 worktree `git diff --name-only master` + `ls-files --others`（untracked）；在 merge-back 前执行；部署位 diff 后置 |
| 范围断言 fail-closed | 范围/边界断言命令设计 | 前置存在性检查；git 每条命令单独捕获 rc 失败即 exit1；捕获输出后 `test -z` 非空即 FAIL；证据前移到不可逆操作（merge/清理）之前的留痕行 |
| 负例外补正例 | VC 关联拒锁/判定器 | 除负例（拒锁）外必须加合规 fixture 正向 rc0 用例，防“恒拒锁桩”通过 |
| skip 不越档 | 轻量豁免设计 | `[plan-audit-skip]` 仅轻量档生效；L1+ 写 skip 仍拒锁；唯一逃生=参数+WARN+披露，不扩授权 |
| Verify 执行被验证物 | VC 关联脚本/selftest | Verify command 直接执行产出脚本（exit 0 判），不用静态 grep/`bash -n` 代替行为验证 |
| 文本授权增量化 | Rule 文本已含“未经授权禁机器面” | 保留原文追加授权子条，限定范围与文件面，避免改写既有禁令语义 |
| 证据先落盘 | 交付收据/完成声称 | 仅报告已写磁盘文件与已执行命令的真实输出；未跑命令标 pending，不口头声称通过 |
| 断言先干跑 | 写「未新增键/未越界」类判定断言 | 计划期就用 fixture 双态实跑断言本体（正反态 rc 各实测一次），禁止只做静态「非真空/非占位」判定；`grep -c ... \|\| echo 0` 是双零陷阱，改 `test -f X && ! grep -q pat X` |
| 复跑时点资源存续 | fail-closed 断言与不可逆清理共存 | 断言复跑时点必须仍有被断言资源：若后续步骤会删除该资源（worktree/临时目录/分支），则终验断言改为**复核已落盘留痕 token**，命令本体前移到清理前执行 |
| 正则尾锚防副产物 | 白名单/范围正则匹配文件路径 | 文件级分支必须 `$` 尾锚（`SKILL\.md$`），否则 `.bak/.orig/.tmp` 副产物静默放行；目录分支保留尾 `/` 以覆盖子树 |
| rc 显式捕获 | 管道 + `grep -vE` 过滤 | 禁 `\|\| true`；写 `rc=0; out=$(...) \|\| rc=$?`，仅 rc 0/1 合法续行，rc≥2（模式/读错误）必须 exit 1 |
| 回归判据禁绝对零 | 跨任务共享仓的全量回归 VC | 禁写 `FAIL=0`；改「冻结基线集合 + 判无新增」（同集零增量），计划期把 `Total:`/`Failed:` 行原文冻结为对照块 |
| 同集断言含名单整行 | 回归断言只校验失败计数时 | 必须 `Total` 行 `FAIL=N` **且** `Failed:` 行两端锚整行等值；只断计数会被「同数不同集」静默绕过 |
| 冻结配漂移凭据 | 冻结了外部可变基线 | 写 `[baseline-shift] <ISO8601> <新 Total> | <新 Failed> | <原因>` 留痕条款 + 同步更新冻结块与 Verify command 字面量；「未留凭据而松动=违规」 |
| 判据变更扫同义面 | 修改散落多处的同一判据 | 先全量 grep 同义词（`FAIL=0`/`0 FAIL`/`回归`）列出全部落点，再逐处改；本次同一判据散在 6+4 处 |
| 断言捕获紧跟用例 | 单命令内含多个正负用例且共享 fixture | 每用例执行后**立即**捕获断言结果到独立变量（`n=$?`/`p=$?`），末尾只汇总变量；或用独立 `$T1/$T2`。禁把前一用例的断言拖到后一用例执行之后求值（共享状态被改写→恒假/恒真） |
| 产出位置配断言定位 | 留痕/证据类断言的 Verify command 设计 | 先确定产出的物理写入位置：文件末尾追加（`>>`）→ 全文件严格 token 正则；仅当产出定向插入某段时才用段锚 awk。S-unit 验收 grep 须与终验断言同形态，否则位置不敏感会掩盖不兼容 |
| 漂移双闸 | 冻结基线/判据字面量允许漂移 | ① 逐名归因：名单每个新增/消失条目指认他任务/提交锚，无法指认的新增 FAIL 不得吸收；② 漂移后重走独立文本审计（critic 简版复审+留痕），禁自裁 |
| 状态块四处同步 | 轮次推进（每轮修复后） | `task_plan` 的 Current Phase/Next Step 与 `verification` 的 5-Question Reboot Check/交叉验证记录**同时**更新；否则会话恢复读到过期断点 |
| 时点性 gate 标注 | 基线/产物存在性类断言 | 行尾注明「仅 <时点> 执行；产物落地后自然失效，终验不复跑本 gate」；注记写条目标签行而非 Verify command 行，保持命令可复跑 |
| 聚合边界止 H2 | 段聚合类判据（审计留痕/结论/证据段） | 末段聚合只以同族头（如 `[plan-audit-RN]`）为起点时，必须显式设**边界止于下一个同级/更高级标题（H2 `## `）**；否则后随修复轮/簿记块内的**元引用**被吞 → 伪 PASS（本次实测：`head` 截断中间态与「REJECTED 段+元引用修复轮块」两态旧形态 rc=0） |
| 结论 token 行首锚定 | grep 判「某结论词存在」 | 结论类 token 必有「审计结论」与「对结论的引用/自述」两种出现（后者常在反引号内/行中）；判据须用 ERE 锚定**完整结论行结构**（`^- 轮次: R<N> \| 审计体: … \| 结论: …`），禁裸 grep |
| 表格单元格禁管道 | 编辑 mechanical 门会解析的表格 | `awk -F'|'` 解析器（plan-dispatch 等）不剔除 `\|`：单元格内写裸/转义管道会错列并触发假 SKIPPED/假违规；完整正则/长表达式放到列表项或散文，表格内用「结构描述 + 指路」。改表后必须复跑列敏感门并**逐行读输出**（rc=0 不代表无 SKIPPED 噪声） |
| 生产形态双正例 | 判据 token 可能与真实留痕字节形态脱钩 | 判据类改动必须同时给「规范示意形态」与「真实生产形态」两个正例 fixture：只按 spec 示意图写会让 checker 对真实 plan-dir 恒拒（R7 I-1 实测：真实段 `- 问题清单（留档，不阻断）:` 对字面 `问题清单:` 判据 rc=1；tolerant 判据 rc=0） |
| 每约束独立负例 | 实现含多个独立约束（边界/锚定/形态…） | 每个约束须配一条「只有该约束缺失才会通过」的负例（fixture a 击穿锚定、fixture b 击穿边界）；仅一条「全缺」负例时，「只做其一」的半加固实现会全部假 PASS（R7 I-2 四变体实测：onlyb/onlya 原 rc=0，加 r5/r6 后各 rc=1） |
| 前提写进契约非注释 | 判据依赖写作规范（如「后随块须 H2」） | 行为前提只写在实现注释里等于未强制；须同时进 VC 判据 + kb 易错点 + S-unit 验收，并在被约束文件（progress 占位区）写写作规范提示，否则写作侧一变形判据即静默退化（R7 Q-1） |
| rc 口径按文件状态分层 | 判定器输入为「留痕文件」 | 明确定义**缺失/不可读=rc2（fail-open+WARN）**与**存在但空=无留痕 rc1**；selftest 的 rc2 用例必须删除文件而非清空文件，否则两个语义混同（R7 Q-2） |

## 必要知识储备符合性记录（终验结论）
| 必读知识源 | 结论 | 说明 |
|-----------|------|------|
| `skills/task-planner/scripts/attest-plan.sh` | 符合（计划期） | 设计按 :26-45/:84-99/:540-562 规划 skip/cksum/[audit-gate] 插入与缓存回放 |
| `skills/task-planner/references/critical-rules.md` Rule 109 | 符合（计划期） | 计划明确 109.7 原文保留、追加 109.8 授权范围限定 |
| `skills/task-planner/SKILL.md` 审计门 | 符合（计划期） | 计划包含机器面一行补充且保留 skip/留痕载体 |
| 先例 `plans/archive/task-planaudit-20261116/*` | 符合（计划期） | 复用末段 APPROVED awk 判据与“Verify 非真空/先负例”教训 |
| `knowledge/entries/task-planaudit-20261116.md` | 符合（计划期） | 三教训映射到 VC/Verify 设计与执行注意事项 |
