# 计划独立审计 r1 — task-session-regression-20261124

- 审计体：独立上下文 / 只读 / Rule 109 裁决面
- 审计时间：2026-11-24
- 权威输入：`plans/task-session-regression-20261124/plan-state.json`、`task_plan.md`、`verification.md`、`findings.md`、`progress.md`、`knowledge-brief.md`、`user-session-log.md`（#1-#6 逐字）；`tmp/forensics/task-session-regression-20261124/E-design-git-baseline.md` 及 A/B/C/D 报告；`skills/**` 以 `git show HEAD:` 为准（主工作树 4 脚本有他人未提交改动）
- 只读声明：本次仅执行 grep/jq/git show/git ls-tree/diff 等只读命令；除本文件外未写任何文件；未执行任何 git 写命令

## 裁决

**REJECTED** — 2 CRITICAL + 6 IMPORTANT（规则：0 CRITICAL 且 0 IMPORTANT 才 APPROVED）

计数：C=2 / I=6 / W=7 / Q=2，共 17 项。

---

## 事故链套演（findings F14 逐环）

把本方案放回 01:03→03:14 那次事故，逐环判定：

| # | 事发环节（F14） | 本方案对应机关 | 判定 | 靠什么 |
|---|---|---|---|---|
| 1 | 01:03 R1 材料包列出「必须保留的事实锚」 | B9 `MUSTKEEP-EMPTY`（修改型必须非空或 MK-NA）+ 派发 22.4e 文本「未携带基线清单=派发无效」 | **半拦** | 只有「非空」是机器点；「材料包条目是否全部登记为 MK」无机器点（`check-dispatch.sh` 只校验结构，F16②）；MK-NA 可自证放过（见 I-1） |
| 2 | 01:45:12 上下文压缩 | SessionStart hook 注入 `[compact-recovery]`（本会话 side 指针命中即可；事故会话 side 指针在案，F17） | **拦得住** | 注入 user-session-log 绝对路径 + task_plan + MK；但「注入≠已读」，无读后确认（残余风险未登记） |
| 3 | 02:22:33 主进程写 R3 材料包（把事实写成要删） | 无 | **不拦（且不应拦）** | R3 是新建文档；此环的正解由第 4/5 环兜底 |
| 4 | 02:25:42 执行体删除 EP001-小说.md:10 | B10 checkpoint + B11 增量 diff → `unresolved>0` 拒翻 Phase | **本方案下拦不住**（C-1：基线/检查点锚主工作树，改动在工作树 → diff 恒空） | 修复 C-1 后：靠 B11 删除行 + MK `mustkeep_lost` 拦 |
| 5 | 11 条 VC 全绿 | `check-complete.sh` 新增 GIT-BASELINE GATE（独立于 VC 设计） | **本方案下拦不住**（同上，门读的 sidecar 来自主工作树） | 修复 C-1 后拦得住 |
| 6 | critic r3 复审通过 | P5 critic 读 B11 报告/sidecar | **拦得住（前提同 4）** | B11 报告在审查面 |
| 7 | 02:46 才首次 git show HEAD 排查 | B9/B10 在首写前已建 ref + checkpoint | **改善** | 不再需要事后翻找；可逐字节 restore |

结论：链路设计方向正确（第 2/6/7 环成立，第 3 环本不需要），但**第 4/5 环被 C-1 破坏**（worktree 模式下门禁空转），第 1 环只有「非空」是机器点。C-1 修复后，事故链在「改文件」当拍即被 B11 捕获，终验门二次兜底——这是用户要的「识别出来即可还原」。另：若实施者用 `fixed` 自证处置，第 4/5 环会再次失效（I-1）。

---

## CRITICAL

### [C-1] 基线/检查点锚定主工作树，交付改动在工作树 → B11 在 P1–P5 全程空转；改锚则与 A1 脏基线冲突
- **维度**：机制设计合理性 / 既有 worktree 流程冲突 / 可执行性
- **位置**：`plan-state.json` → `config.worktree_path`、`isolation.path`、`actions[0] (A1)`、`vcs[VC-2].command`、`vcs[VC-3].command`、`s_units[S2/S4/S5].actions`；`E-design-git-baseline.md:158`（worktree 模式行）
- **原文**：
  - `A1`：「对主仓工作树做非侵入式基线快照 refs/task-baseline/task-session-regression-20261124 = 1bef5ea…（4823 个文件；相对 HEAD：269 files changed, 592842 insertions(+), 2052 deletions(-)）」
  - `VC-2`：「cd /mnt/data/dev/task-planner-skill && … bash "$SK/git-baseline.sh" snapshot /mnt/data/dev/task-planner-skill/plans/task-session-regression-20261124 --session vc-probe」
  - `VC-3`：「cd /mnt/data/dev/task-planner-skill && bash "$SK/git-baseline.sh" checkpoint …」
  - 设计 C 节：「worktree 模式 | 基线锚定**被修改的工作树**：`--repo <worktree绝对路径>` 或 env `TASK_GIT_BASELINE_ROOT`」
- **问题**：D.0 的快照实现以 `git -C "$plan_dir" rev-parse --show-toplevel` 定仓根；plan_dir 在主工作树，故 snapshot/checkpoint/diff 全部锚定主工作树。而本任务的 17 个交付文件只在 `tmp/worktrees/task-session-regression-20261124` 内被改。全文检索 plan-state 无 `--repo` / `TASK_GIT_BASELINE_ROOT`（仅 E 文档 C 表出现过）。后果二选一：① 门照 S-unit 现状跑 → 主工作树在 P1–P5 无本任务改动，`last_diff.unresolved==0` 恒真，B11/两门在实现期**空转**（正是要杜绝的「全绿却无保全判据」）；② 改成锚工作树 → 基线仍是 A1 的主工作树脏树（含他会话 269 文件 / 592k 行），diff 会把 `attest-plan.sh`/`init-session.sh`/`planctl.py`/`task-plan-init.cjs` 等（SL1 deny 面）与全部他会话未提交改动报成「删除」，首个 Phase 门即被 269 文件级虚假删除堵死；且 ref 名按 task-id 固定、`snapshot` 幂等（B.2「重复 snapshot 幂等返回 0」），工作树内再 snapshot 会直接返回 A1 的 sha，`--force` 又会毁掉 PB1/AR6（sha==1bef5ea）与 §11 的建树前备份。宪法 §11 要求实现类任务必须走 worktree → 该机制恰在强制模式下失效。
- **修法**：① 明确 ref/锚点分层：`refs/task-baseline/<task-id>` 保留 A1 作 §11 建树前备份（只读，不参与 B11）；B9 在工作树内另建 `refs/task-baseline/<task-id>@wt-<branch>`（或 sidecar 记 `repo_root`+`worktree` 并用独立 ref 名），B10/B11 一律 `--repo <worktree>`；② VC-2/VC-3 改为在 worktree 内断言（并保留一条「主仓 A1 sha 未变」的独立断言，替代 AR6）；③ 新增 VC：worktree 内删除既有行 → 两门拒绝；④ 同步 E C 节 worktree 行与 S2/S4/S5 的 `--repo` 参数。

### [C-2] VC-14 命令与自身判据矛盾：侧命中金样被要求逐字节相同，而该分支必然改变 → 该 VC 永远不可通过
- **维度**：可执行性 / 逻辑闭合
- **位置**：`plan-state.json → vcs[VC-14]`；`task_plan.md` VC-14 行
- **原文**：「侧命中金样仅作差异对照，不要求逐字节相同。」／命令：「`cmp -s "$FX/g13-golden.json" "$FX/g13-new.json" && test -f "$FX/g14-golden.json" && cmp -s "$FX/g14-golden.json" "$FX/g14-new.json"」／约束(c)：「有在途计划 side 命中两种输入各采一份…金样」
- **问题**：g14 = 「有在途计划 side 命中」输入。master 版该输入输出「新会话开场白 + [task-resume]」，新版本输出 `[compact-recovery]` 恢复包——两者**必然不同**，这正是本任务要做的改动。命令却要求 `cmp` 逐字节相等，等于要求功能不生效。VC-13 与 VC-14 因此不可同时通过；最省事的「解法」是删/弱化这条 VC——正是用户反复指责的自缩水路径。
- **修法**：VC-14 只对 g13（无在途计划）做 `cmp -s`；g14 改为「存在 + 含 `[compact-recovery]` + 不含 `[task-resume]` + 单行 JSON」的差异断言（与 VC-13 互补而非重复），删掉 `cmp -s g14`。

---

## IMPORTANT

### [I-1] 四态处置强度不对称 + 文件级粒度：`fixed` 可自证，实现「删事实→checkpoint→fixed→放行」两步绕过
- **维度**：机制设计合理性（防橡皮图章）/ 事故链第 4-5 环
- **位置**：`s_units[S5].actions`；`s_units[S26].actions`；`E-design-git-baseline.md:126`（B.3 防橡皮图章）、`:357-359`（G.1.C）
- **原文**：「fixed（附后续 checkpoint ref）；任一未满足=unresolved。」／「`state=restored` 必须附 `restore` 后的 `sha256`…`state=fixed` 必须附后续 checkpoint ref。`pending` 或未登记 = unresolved。」／「唯一自动合法出口 = `git-baseline.sh restore`」
- **问题**：`retained` 要逐片段固定串命中、`authorized` 要用户逐字授权锚 + 计划文档回读、`restored` 要 blob 一致——三态都有内容证据；`fixed` 只要求「后续 checkpoint ref」，而 checkpoint 是执行体自己随手就能打。sidecar 的 `disposal[]` 粒度是 `{path,kind,state,evidence}`（按文件+类别），不是按删除行：**一次 `fixed` 即可把整文件的全部删除行划掉**。叠加 G.3 的 `MK-NA`（只要求「具理由」，无机器判据），事故可复演为：删 EP001 事实 → `checkpoint` → `dispose --state fixed --evidence <ref>` → 两门放行。G.1.C 写「唯一自动出口=restore」，但**未禁止 `fixed` 清除 `mustkeep_lost`**，S26 也只写「restore 后自动重查清零」，语义留了口子。
- **修法**：① 明确 `mustkeep_lost` 只能由 `restored`/`authorized`（用户逐字锚+SB 更新重 attest）清除，`fixed` 对 `kind=mustkeep_lost` 一律无效；② `fixed` 必须附内容证据（被删行的既有事实词在「目标文件/声明后继文件」用 `grep -qF` 命中，与本文件命中的 facts 计数 ≥ 删除前），不是只附 checkpoint；③ 补一条变异断言：`dispose --state fixed` 后 MK 事实仍缺失 → 门仍 rc=1（并加入 VC-12）；④ `MK-NA` 需绑定机器判据（该任务基线差异内不得存在既有文件的 M/D），而非仅凭理由文本。

### [I-2] 范围四处不一致：17 / 13 / 12 三个数字并存；scope_limits 多 1 个文件；S33 引用 scope 外文件
- **维度**：一致性 / 完备性
- **位置**：`config.scope_files`（17，与 `files` 逐项相同——已 diff 验证 IDENTICAL）；`s_units[S1].verify`；`s_units[S17].verify`；`vcs[VC-9].evidence`；`scope_limits[SL2].allow`；`s_units[S33].files`；`dual_qc.scope`；`decisions[D7]`
- **原文**：「approved-scope.txt 13 行 == config.scope_files」（S1）／「changed-files 恰 13 行」（S17）／「approved-scope.txt（12 行）」（VC-9 evidence）／VC-9 criterion「17 项」／SL2 allow「…selftest-final-gate-hash.sh（仅门组锚复核，必要时同步）」／S33 files「…selftest-active-plan.sh」／dual_qc「13 项 scope_files 全覆盖…changes C1-C13」
- **问题**：S1 的自查条件自相矛盾（13 行 vs config=17），执行体无法判断 approved-scope.txt 该写几行；VC-9 用该文件做 `diff -u` 输入 → 若按 S1 写 13 行，VC-9 必 FAIL。SL2 允许的 `selftest-final-gate-hash.sh` 与 S33 的 `selftest-active-plan.sh` 都不在 17 项内：真改则 VC-9（changed-files == scope_files）FAIL，不改则 S14/S33 的验收（「必要时同步」「锁步复核」）落空。计划状态计数 4×「13 项」+2×「13 行」+3×「12 行」+2×「17 项」（`grep -o` 实测）。
- **修法**：全仓改口径为 17（S1/S17/dual_qc/D7/VC-9 evidence），并明确 `approved-scope.txt` = 17 行、由 S1 从 `config.scope_files` 机械生成；`selftest-final-gate-hash.sh` 与 `selftest-active-plan.sh` 二选一：纳入 scope 并补 changes/断言，或在 SL2/S33 写明「只读复核、禁止修改，若锚失配则 STOP 上报」。

### [I-3] P6/S20 的目标/动作被 S21（清哨兵前校验）整体覆盖，部署步骤无操作定义；「批准即授权部署」缺护栏断言
- **维度**：完备性 / 安全（保护区写操作）
- **位置**：`s_units[S20]`；`task_plan.md` P6 S20 行；`decisions[D11]`；`fmea[FM7]`（写「S20/VC-11」）
- **原文**：S20 名称「部署、对账、归档」，actions「在清哨兵之前插入校验：活跃计划非纯只读…→ 不清哨兵、非零退出、打印 B9 命令；哨兵不存在的会话退回事后门…」（= S21 原文）；D11「批准本计划即授权 P6/S20 部署步骤（install.sh / smart-merge-back.sh --deploy + verify.sh），但部署前逐位 diff 判向+备份、禁整文件盲覆盖」
- **问题**：S20 是唯一执行部署的单元，其动作是 S21 的哨兵校验 → 计划里**没有任何一步描述「怎么部署、部署哪些位、如何逐位 diff 判向、备份在哪」**。而部署目标是 `~/.zcode/skills/**`（宪法 §六 保护区），D11 把「计划批准」当作授权，却只有 VC-10（verify.sh 0 fail）一条断言，没有「备份已做」「逐位 diff 判向记录」「无整文件覆盖」的可验证证据。FM7 还把哨兵校验写成 S20，说明是串位而非笔误。
- **修法**：重写 S20：`install.sh`/`smart-merge-back.sh --deploy` 的实际命令 → 部署前 `cp -a` 备份（记路径）→ 逐位 `diff -u` 判向并落 `deploy-diff.txt` → `verify.sh` 总结 → `archive-plan.sh`；新增断言/VC：备份目录存在 + deploy-diff 每行方向合法 + 无「整文件覆盖」记录；S21 保留哨兵校验；FM7 的锚改 S21。

### [I-4] 压缩恢复船：在途判定双源（hook 用 resolve-plan-dir 带 24h TTL / cjs 无 TTL）+ 只注入不确认已读
- **维度**：机制设计合理性 / 用户 #6 需求覆盖
- **位置**：`s_units[S25].actions`；`decisions[D15]`；`zcode-sessionstart.sh`（HEAD）；`task-plan-init.cjs:201-229`（HEAD）；`resolve-plan-dir.sh`（SIDE_TTL=86400）
- **原文**：S25「调 resolve-plan-dir.sh；约束(a)仅本会话 side 指针命中才注入，mtime/全局 fallback 命中不得注入」；D15「(a) 恢复包防串台——仅 resolve-plan-dir.sh 命中本会话 side 指针才注入」；cjs「本会话已有有效计划(…)，哨兵不启用（resume 判定）」；resolve-plan-dir「SIDE_TTL=86400 # 会话指针 24h 过期」
- **问题**：① 同一次 SessionStart 里存在两个「在途判定」：node 的 resume 判定只读指针文件、**不查 mtime**；新 hook 走 resolve-plan-dir.sh、**查 24h TTL**。会话跨天（>24h）后压缩触发：node 认为「已有有效计划」并撤哨兵，新 hook 认为「无在途计划」→ 走原分支，注入「新会话开场白 + [task-resume] 25 条无关任务」——正是用户 #6 指控的「被带偏」。② 用户要求「每次上下文压缩后**先去读取**这些本地文档」；机制只到「注入必读指令」，没有读后确认/留痕点，也没有在任何位置登记这条残余风险。③ 金样只覆盖「无在途计划 / side 命中」两种输入，未覆盖「指针指向不存在计划」「legacy 根 task_plan.md」「指针过期」三条分支。
- **修法**：① 在途判定单一权威源：hook 的 side 判定与 `task-plan-init.cjs` 的 resume 判定同 canon（含 TTL 语义），或让 node 输出判定给 shell 复用；② >24h 但仍属本会话（`.session-owner` 匹配）时仍注入恢复包（TTL 只用于跨会话防串台，不用于本会话）；③ 在计划里显式登记「只注入不强制读」为残余风险（交付披露一行），可选：注入后要求 progress 记一行 `[compact-recovery] 已读` 并由 `[plan-sync]` 检查；④ 补上述三条分支的负例/金样。

### [I-5] 多条顶级 VC 不可执行或判别力不足（VC-5 夹具到不了第 8 条件；VC-1 传参与脚本契约不符；VC-8 基线树不一致）
- **维度**：可执行性 / 可测试性
- **位置**：`vcs[VC-5].command`；`vcs[VC-1].command`；`vcs[VC-8].criterion/command`；`s_units[S1].actions`；`E-design-git-baseline.md:186-195,225-228,257`
- **原文**：VC-5「grep -q '\[git-baseline\] FAIL' …/g3.log」；E T5 夹具只创建 `plan-state.json`/`task_plan.md`/`progress.md`；`check-3file-gate.sh` 头注「1. findings.md / progress.md 缺失 → exit 1」；`sync-todos.sh` 用法「sync-todos.sh /path/to/plans/dir」；S1「在 master HEAD 跑 run-selftests.sh --fresh 采集 FAIL 基线」
- **问题**：(a) T5 夹具没有 `findings.md`，check-3file-gate 必在第 1 条件退出，`[git-baseline] FAIL` 永不打印 → VC-5 命令不可达；E 文自认「若前置门先退出…改用注入桩夹具」，但 VC 未定义桩，也没断言「桩不改变门序」——用桩即可伪造通过。(b) VC-1 传的是**任务目录**，脚本契约是 **plans 目录**；且 B1-B8 组是无条件输出（`sync-todos.sh` 175-220 行），传错目录也照样打印 → 该断言对本计划无判别力（只要脚本里有字面量就 PASS）。(c) VC-8 的 master 基线在「master HEAD」采集，但主工作树含他人未提交改动（4 脚本 +154/−32）而 worktree 干净；两棵树跑 `--fresh` 的 FAIL 集合不可比，除非明确「两次都在同一棵树/同一 worktree 基线提交上跑」。
- **修法**：VC-5 改用「能在第 1-7 条件全通过的完整最小夹具」，或把 git 门断言改为直接调用 `git-baseline.sh status` + 门函数级 shell 测试（并保留一条端到端）；VC-1 传 `plans/` 目录并加断言「B9/B10/B11 的 subject/命令含本 plan-dir」；VC-8 明确两次 `--fresh` 都在 `wt/task-session-regression-20261124` 检出上、以同一 commit 为基线采集，并在 criterion 写明。

### [I-6] 本计划自身会撞上 `MUSTKEEP-EMPTY`：spec_baseline 只有 SB1-SB4（非 MK），未登记 MK/MK-NA
- **维度**：机制设计合理性（自应用）/ 一致性
- **位置**：`plan-state.json → spec_baseline`（SB1-SB4）；`s_units[S26].actions`；`E-design-git-baseline.md:369-375`
- **原文**：spec_baseline 四条 id 均为 `SB1..SB4`，`rule` = 「🔒 规范基线将被修改…」；S26「snapshot 增必保清单空检查（约束b：差异中 plans/ 外既有文件 M/D 即修改型需非空或 MK-NA）」；G.3「standard / L1+ 修改型任务 | 必保清单非空或 `MK-NA` 具理由 | …B11 门把它当 unresolved 阻断 Phase/终验」
- **问题**：本计划修改 16 个 plans/ 外既有文件（改既有行）→ 按设计属「修改型」；`mustkeep` 只取 `id ^MK`，而本计划无任何 MK 条目也无 MK-NA。于是本计划执行到 P2/S2 之后的第一个 Phase 门就会被自己的 `MUSTKEEP-EMPTY` 判为 unresolved 阻断（VC-16 正好把这个行为当「正确」），执行体唯一出路是补登 MK-NA 或 MK——但计划里没有这一步，且执行中补登 spec_baseline 需按 51.15 更新+重 attest（会卡在已锁计划上）。这是典型的「新门先卡死自己的首个用户」。
- **修法**：计划期就为本任务登记 MK 或 MK-NA 并写入 `files/changes` 的对应锁步项（例如 MK-NA：本任务只改规则文本与脚本，无「设定事实」需保留，理由登记）；并在 S1 验收里加「本计划必须自带 MK 或 MK-NA」；如决定登记 MK，须在 attest 前完成。

---

## WARNING

### [W-1] 约束(a)「只认 side 指针命中」缺实现路径：resolve-plan-dir.sh 不报告解析层，且不在 scope 内
- **位置**：`s_units[S25]`；`scope_files`（无 resolve-plan-dir.sh）；`resolve-plan-dir.sh`（HEAD，只输出 task_plan.md 路径）
- **原文**：「调 resolve-plan-dir.sh；约束(a)仅本会话 side 指针命中才注入，mtime/全局 fallback 命中不得注入」
- **问题**：resolve-plan-dir.sh 依次尝试 side→全局→mtime→legacy，只回一个路径，调用方无法知道命中的是哪一层；要在 hook 里实现约束(a)，只能自己重写 sid 规范化（剥 sess 前缀）、sidmap 转译、TTL、双命名空间四段逻辑——历史三次「指针抢占/写得出读不到」事故的根因正是这些 canon 不一致（cjs/check-scope/set-active-plan/resolve 四处对齐）。而该文件不在 17 项 scope，不能加 `--layer`。
- **修法**：把 side-only 解析收进 `lib/plan-recovery.sh`（本就在 scope），与 resolve-plan-dir.sh 共用同一 `norm_sid` 语义并在头注写「与四处 canon 同步」；把 sidmap 命中、TTL 过期、sess 前缀三条加入 T12/T13 断言（当前只有 fallback 负例）。
- **置信度**：HIGH

### [W-2] 钉值计数更新算错：`163→164 / selftest 103→104`，实际新增 4 个 scripts 文件、2 个 selftest；且 HEAD 现状已是 164/106
- **位置**：`changes[C9]`、`changes[C22]`、`s_units[S30].actions/verify`、`findings[F10]`
- **原文**：「基线组钉值+脚本计数 163→164/selftest 103→104+执行循环补 B9-B11」／「脚本文档计数脚本总数 +2（新脚本 git-baseline.sh + lib/plan-recovery.sh）」／S30 verify「grep -rn …（B1-B11、163、103）」
- **问题**：本任务在 `skills/task-planner/scripts/` 下新增 4 个文件（git-baseline.sh、lib/plan-recovery.sh、selftest-git-baseline.sh、selftest-compact-recovery.sh），其中 selftest 2 个。实测 HEAD：`git ls-tree -r HEAD --name-only skills/task-planner/scripts | wc -l` = **164**，`grep -c '/selftest-'` = **106**，而 SKILL.md 写 163/103（已陈旧）。按计划改完应为 168/108（若把 selftest 计 106+2），而不是 164/104。结果是文档继续错、S30 的复核 grep 断言 163/103 也会与真实值冲突。
- **修法**：S30 改为「改后由 `git ls-tree -r HEAD --name-only … | wc -l` 与 `grep -c '/selftest-'` 实采后写入」，不预填数字；同步修正 C9/C22/F10 的数字与「+2」表述（应为 +4 文件 / +2 selftest）。
- **置信度**：HIGH

### [W-3] 用户 #2 列举的「子分支/临时分支」未落为任何 todo/命令，VC-3 却声称覆盖
- **位置**：`requirements[R2b]`、`vcs[VC-3].criterion`、`decisions`（无对应取舍条目）
- **原文**：R2b「然后修改备份，这样的话，再配合子分支、临时分支、工作数」／VC-3「（R2/R2b 修改备份 + 子分支/临时分支组合）」，但其 command 只验 `refs/task-checkpoint/...`
- **问题**：用户逐条列举的手段之一（子分支/临时分支）既无 B9/B10/B11 命令、也无 decisions 记录说明「改用 ref + 既有 B8 worktree 已覆盖」的取舍。审查面无法区分「有意替代」与「漏做」，且 VC-3 的括注让人以为该手段已被验证。
- **修法**：在 Decisions 增一条「为何用非侵入 ref 而非临时分支（B8 worktree 已承载隔离；ref 不动工作树、可 fsck 审计）」，并把 VC-3 括注改为实际的「ref + 既有 worktree 隔离（B8）」。
- **置信度**：HIGH

### [W-4] 74.7 变更标注表缺「影响评估/处置」两列；spec_baseline SB1-SB4 无「改后更新+重 attest」步骤
- **位置**：`changes[C1-C23]`（列：对象/类型/吸收判定/用户原话/依据/执行动作）；`spec_baseline` SB1-SB4；`s_units[S9]`
- **原文**：Rule 74.7 要求「`变更对象+当前值(原文 verbatim) → 拟变更值 + 变更依据(证据/用户逐字授权) + 影响评估(破坏或放宽了哪些既有约束) + 处置(保留/等价替代/用户授权放宽)`」；SB1「🔒 规范基线将被修改：…规则编号不变」
- **问题**：C 表缺「影响评估」「处置」两列；SB1/SB2 的 verbatim 就是本任务要改掉的旧文本，但计划里没有任何一步在改后「更新 spec_baseline 为新文本 + 重跑 attest 重锁」（Rule 51.15/106.7 收口要求）。改完后 106.7 的「全部基线项逐条核验」会把 SB1/SB2 判为退化。
- **修法**：C 表补两列（或按 74.7 四元组重排）；在 P3 加一步「改后以新文本 update spec_baseline SB1/SB2 并重 attest」，并写进 VC（grep 新文本 + `.plan-attestation` sha 变化）。
- **置信度**：MEDIUM（机读面：全仓脚本只有 planctl.py 读写 spec_baseline，无自动回归断言；故影响主要体现在 106.7 人工/审查面）

### [W-5] VC-11/VC-12 用「脚本源码字面 grep」冒充行为断言
- **位置**：`vcs[VC-11].command`、`vcs[VC-12].command`
- **原文**：`grep -q 'late=1' "$SK/git-baseline.sh"`；`grep -q '"state":"retained"' "$SK/git-baseline.sh"`
- **问题**：只证明脚本里出现过该字符串，不证明 late 标记/四态逻辑行为正确；这两个 VC 的行为面另外依赖 `sentinel-gate.log`/`t6b.log`（由实现者自己生成，非独立复算）。
- **修法**：改为对 sidecar/报告的行为断言（例如 late 快照的 sidecar 含 `"late":1` 且报告含披露行；`dispose --state retained` 虚假声明后门 rc=1），静态锚只作辅助。
- **置信度**：HIGH

### [W-6] 事实性小漂移：worktree 计数、未提交文件数、Goal verdict 的 VC 范围
- **位置**：`isolation.conflict`；`progress_baseline[PB4]`；`verification.md` Goal 段
- **原文**：「信号①49 未提交文件；信号②3 个额外 worktree」／「evidence | 待 VC-1..VC-12 全通过后回填」
- **问题**：实测 `git worktree list` 共 3 条 = 主树 + **2** 个额外 worktree（非 3）；`git status --porcelain | wc -l` = 50（非 49，且会随他人会话变动）；verification 的 Goal 只提 VC-1..VC-12，实际 16 条。均为可修的事实漂移，不影响方案成立。
- **修法**：改为由命令实采（`git worktree list | tail -n +1 | wc -l` 减主树、`git status --porcelain | wc -l`），Goal 段写「VC-1..VC-16」。
- **置信度**：HIGH

### [W-7] 估时偏乐观：35 个 S-unit 合计 452min，其中 S12/S13/S32 各 15min 要写 90–100 行断言脚本
- **位置**：`s_units[*].duration` / `granularity`
- **原文**：S13「落 E 节 T1-T10 共 36 断言…新增 ≤90 行」duration=`15min`；S32「T12-T15 共 18 断言…新增 ≤100 行」duration=`15min`
- **问题**：36 条含草稿仓夹具、双门拒绝、四态处置的行为断言，15min 内完成并调试到全绿不现实；总估时 452min≈7.5h 对 4 个新脚本 + 2 个 selftest + 16 文件改写偏紧。偏乐观本身不阻断，但会诱导「压缩验收」。
- **修法**：S12+S13 合并或各给 30min；S32 给 25–30min；总时长按 1.5× 重估并在 Phase 门按实测回填。
- **置信度**：MEDIUM（估时为判断，非事实）

---

## QUESTION

### [Q-1] 执行体命名（Git Master / Verifier / critic / general-coder）无对应 agent 定义、也无 `(model)` 限定
- **位置**：`s_units[*].executor`；`task_plan.md` 各 Phase `**Executor:**`；`skills/task-planner/companion/agents/`（只有 9 个：article-batch-publisher、article-field-fixer、complex-planner、decision-arbiter、drift-checker、history-miner、image-generation-executor、plan-writer、video-generation-executor）
- **原文**：S19/S20 executor=`Git Master`；S16/S22/S34/S35=`Verifier`；S18=`critic`；模板列头「执行体(subagent_type(model))」
- **问题**：`check-plan-dispatch.sh` 只校验执行体列非空（实测逻辑），所以现状能过门；但真实派发时这 4 个名字若无对应 subagent_type，P2–P6 会在派发环节失败（"Git Master" 含空格，历史仅出现在一份 archive 计划的展示列）。需确认平台是否有这些执行体；若无，改用实际可派发的 type 并补 model。
- **待确认**：这 4 个执行体是否为可用 subagent_type？

### [Q-2] 「写入前拦截」（G.5）默认不做，是否需要在批准页作为显式选项让用户知情勾选？
- **位置**：`scope_limits[SL6]`、`decisions[D14]`、`E-design-git-baseline.md:441-449`
- **原文**：「G.5 写入前拦截（PreToolUse exit 2）：只覆盖 Write/Edit/ApplyPatch、误报停摆、B11 diff+restore 已全覆盖…仅用户点名时 env TASK_PLANNER_MUSTKEEP_PRETOOL=on opt-in（D14）」
- **问题**：该取舍有充分理由（漏面更大、会停摆、Rule 95），但它是「唯一能在删除发生前拦住」的通道，且计划把它放在「不做清单」而非批准单的显式勾选项。用户 #6 的核心诉求是「不被带偏/不被删」，是否知情放弃这条，应由用户在批准时裁决而非由计划内部决定。若用户已被「批准」流程覆盖则无需额外动作。
- **待确认**：批准页是否需要一行「[ ] 同时启用写入前拦截（默认不勾）」？

---

## 负结果报告（检查了但未发现问题）

1. **R 行逐字性**：R1、R3、R5 与 `user-session-log.md` 第 43/71/97 行做 `diff` 逐字节比对——**三行 IDENTICAL**；R2 为显式标注「节选」的分段引用，4 段均可在 #2 原文中 `grep -F` 命中（含省略号标注），未发现篡改/转译。R2a-d/R3a/R4a/R5a-c 均能在原话中定位。
2. **需求覆盖**：R1–R5c 每条均有 ≥1 VC（映射表实测 14 行全覆盖），未发现「R 行被悄悄丢 VC」；「调查为什么」由 root_causes RC1-RC9 + findings F1-F18 承载（无 VC，属调查产物，可接受）；「归因于技能」由 RC7 + D5 承载。
3. **范围集合本体**：`config.scope_files` 与 `files[].path` 集合 `diff` = **IDENTICAL（17 项）**；`changes` 覆盖全部 17（C17/C23 为合并行，属格式非遗漏）。
4. **S-unit 结构**：35 个 S-unit 在 6 个 Phase 中不重不漏（P1:1/P2:14/P3:11/P4:6/P5:1/P6:2=35）；时长均为 `NNmin`；粒度三值格式合规；`granularity` 行数均 ≤100（S2/S4/S5/S24/S32 恰 100）；无并行标注，故不构成并行冲突；依赖顺序与表序一致（S23 金样在 S25 改 hook 前、S24 库在 S26 前、S12 在 S13 前、S31/S32 在 S33 前）。
5. **hook 输出 JSON 契约**：HEAD 脚本用 `printf '{"additionalContext": %s}\n' "$(… | jq -Rs .)"`，`jq -Rs` 会把多行转义进单行 JSON —— 恢复包注入后仍可保持严格单行，FM9/VC-13 的断言方向正确；「无在途计划逐字节一致」在金样可确定性上成立（task-plan-init.cjs 的 stdout 不含时间戳，时间戳只写进哨兵文件内容，实测源码确认）。
6. **并发/串台面**：ref 命名 `refs/task-baseline/<task-id>`、`refs/task-checkpoint/<task-id>/<seq>-<label>` 按 plan 隔离（同一 .git 下互不覆盖）；sidecar 在各自 plan-dir；恢复包按 `\<sid\>.active_plan` 私有指针注入——未发现命名冲突或跨会话覆写路径。
7. **既有机制冲突面（除 C-1/C-2/W-4 外）**：Rule 27（逐 Phase commit）与 B10 checkpoint 互补不替代；Rule 111 机器面仅 warn，B9-B11 是更强机器面，无反转；Rule 90 首尾双提交与 B9/A1 同向；attest 锁定不受影响（sidecar 不入 schema、不进 attestation 哈希面——sidecar 在 plan-dir，`.plan-attestation` 只锁计划文档）；smart-merge-back V3-V6 未触碰；4 个重叠脚本在 SL1 明确 deny 且 VC-9 有断言。
8. **比例原则**：L0-E/纯只读 → `n/a`+reason、门 SKIP；L0/mini/trivial 有写 → `MUSTKEEP-EMPTY` 仅 warn、B10 降到 Phase 级、B11 只终验；非 git → `NO_GIT` degraded + 披露（非静默 PASS）；存量计划 → late 基线 + 披露。未发现「一档卡死所有档位」的硬伤（仪式偏重问题见 I-1 的 `fixed` 侧，不影响豁免面）。
9. **不做清单**本身恰当（G.5、G2-11、新 hook、planctl/schema/config/部署位），未发现计划里夹带用户没要求的新 hook/新 config 键/新 Rule 编号（new_rule 声明=不新增，config properties=54 实测一致）。

## 验证摘要

- 总发现：**17**（C2 / I6 / W7 / Q2）
- 已验证：**17**（每条均有 `file:line` 或 jq/grep/git 复现；实测项：R1/R3/R5 diff、scope_files↔files diff、脚本数 164/selftest 106、config properties=54、B1-B8 命中 5 文件/6 处、worktree 数 2 额外、status 50、sync-todos 用法与 B1-B8 无条件输出、check-3file-gate 第 1 条件、task-plan-init 无 TTL、resolve-plan-dir SIDE_TTL=86400、companion/agents 清单、SKILL.md 163/103 与 :433/:443 锚）
- 通过率：**100%**
- 未验证（如实标注）：W-7 的估时属判断非事实；Q-1 取决于平台实际 subagent_type 注册面；W-4 的机读面影响（目前无脚本自动核 spec_baseline verbatim，仅人工/106.7 规则面）。
