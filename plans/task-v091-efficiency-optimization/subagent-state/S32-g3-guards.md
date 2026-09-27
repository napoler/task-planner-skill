# S32-g3-guards 检查点（g3 验证组：C-2/C-3/C-4/C-5/A-3，干净上下文子代理）

> 更新纪律：每完成一项立即追加。验证对象= /mnt/data/dev/task-planner-skill-worktrees/task-v091（HEAD a05bd5e）。
> 约定：只读 worktree + /tmp 夹具；不改 worktree 内任何文件。

## 已完成

### C-2 六步夹具（/tmp/c2verify，2026-09-27）— PASS 6/6
驱动方式：/tmp/c2verify/skill = worktree skill 整树拷贝；/tmp/c2verify/plans/t1 最小计划（git init 仓，模板 frontmatter template_type: general + plan_tier: standard + Phase complete + 主进程 Executor + FMEA 段 + VC×5 + 执行范围限制 + findings/progress 三件套），attest 锁定成功（SHA 0534d1ad...e9e）。
- **step① attest --verify 原样**：`verify_rc=0`，锁定输出 `[attest] ✅ 计划已锁定 ... SHA-256: 0534d1ad68487a831d5dc24caf2c2e6994f07eb782de74a5f4bc5e8c18143e9e`
- **step② sed 改计划一字节**（`sed -i 's/低/中/' task_plan.md`，FMEA 影响列 低→中）：`attest --verify` rc=1（TAMPERED 抓出，verify_rc=1）
- **step③ touch -r 恢复 mtime**（`touch -r ref task_plan.md`，ref=2020-01-01）：仍 TAMPERED，`verify_rc_after_touchr=1`（内容哈希闭合 mtime 绕过，符合提案护栏）
- **恢复现场**：`git checkout -- task_plan.md` 还原后 sha256 与 state 锁定键一致（SAME=0534d1ad...），verify rc=0
- **step④ 未变计划跑 check-complete 两轮**：第 1 轮全量（rc=0，`[plan-dispatch] fail-open: 无派发型 Phase` + `[fmea-gate] OK`，state 落 fg_key）；第 2 轮 SKIP-BY-HASH 两门原文：
  - `[plan] PLAN-DISPATCH GATE SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果)`
  - `[fmea-gate] SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果, fmea_enforce=warn)`
  - 其余门照跑在证：DELEGATION GATE PASSED / VC-GATE WARNING / LEARNING-GATE PASSED / REFLECT-GATE SKIPPED / SKILL-MODIFY GATE SKIPPED / [compliance] WARNING，终态 rc=0 与全量轮一致
  - 注：全量轮 `[plan-dispatch] fail-open: 无派发型 Phase` = cpd 实跑证据（本夹具主进程唯一无派发型 Phase，cpd 走 fail-open 分支仍属「该门实跑」，selftest-final-gate-hash 夹具同口径）
- **step⑤ cpd 加一行再复原**（`echo probe >> check-plan-dispatch.sh`，随后 cp 复原）：加行轮 SKIP 行数=0、cpd 实跑（`[plan-dispatch] fail-open...` 在出）；复原轮全量重锁（fg_key 重写，SKIP=0）→ 键②门脚本哈希变化正确不 SKIP
- **step⑥ config 改消费键**：`jq '.fmea_enforce="enforce"'` → SKIP=0，`[fmea-gate] OK (fmea_enforce=enforce)` 实跑；附加 `jq '.plan_tier_enforce="enforce"'` → 同样 SKIP=0。键④ config 键生效证据齐
- 六步原文存 /tmp/c2verify/{baseline,s4a,s4b,s5,s5r,s6,s6b}.out
- 附加证据：selftest-final-gate-hash.sh 内建六夹具+键④五键完整性程序化守护（读码确认 L141 指定断言在 L48-61 pre_key4_integrity）

### C-3 不变性（/tmp/c3verify，进行中）
- 已拷主仓 plans/ → /tmp/c3verify/plans（find -maxdepth 2 task_plan.md = 37 个，与 progress S21 记载 37 计划一致）
- 已存快照：INDEX.a05bd5e.md = `git show a05bd5e:plans/INDEX.md`；INDEX.snapshot-A.md = 新版 sync-todos --index 跑一遍输出
- 待办（下一步）：① 用 C-3 前旧版脚本（git show 216e912:skills/task-planner/scripts/sync-todos.sh，d3a787c 的父提交）对同一 plans 拷贝跑 --index → 与新版输出 diff（剔除 Last refreshed 时间戳行）期待为空 ② mv 归档一个计划目录 → 新版重跑期待仅该行消失+汇总计数联动 ③ 贴 diff 原文。注意：cp -r 未带 -p 重置 mtime → 与 git 存储 INDEX 的 mtime 列不可直接逐字对，对拍基准改用「同份 plans 拷贝上旧脚本 vs 新脚本」
- 已 `git worktree add /tmp/c3verify/wt-old a05bd5e`（收尾需 `git worktree remove /tmp/c3verify/wt-old`）

### 实施记录已读（progress.md 关键行）
- S20(C-2,216e912)/S21(C-3,d3a787c)「37 计划对拍 INDEX 逐字节一致+归档夹具行消失;execve 861→8」/S25(C-4,3cdab78,registry 32 行=31+守护自登记,子集 23.7s≤25s)/S26(A-3 SKILL 53ff783,drift 保留 skill 删 C4a 双跑)/S27(A-3 COMPLIANCE :963-1025 a243253)/S30(C-5 a05bd5e,L1+L2+≥3 抽检+空清单保守回退,裁量：porcelain→git diff 程序化清单/删文件不入 targets/确定性前 3/清单空回退全交集)

## 进行中
- [x] C-2 / C-3 / C-4 / C-5 / A-3 全部完成

### C-3 不变性（续完）— PASS 2/2
- **C3-1 旧版 vs 新版对拍**：旧版脚本 = `git show 216e912:skills/task-planner/scripts/sync-todos.sh`（C-3 前父提交）存 /tmp/c3verify/sync-todos-OLD.sh；对同一份 /tmp/c3verify/plans（37 计划）先后跑旧/新脚本，`diff <(grep -v 'Last refreshed' INDEX.old-run.md) <(grep -v 'Last refreshed' INDEX.new-run.md)` 输出为空 → **37 计划内容行逐字节一致**（仅 Last refreshed 时间戳行差异，脚本自刷新时间戳非内容）。注：旧脚本执行 exit 1（exit 语义非 C-3 验收面，S21 主进程同口径记载「37 计划对拍一致」互证；INDEX 文件实际写出且可 diff）
- **C3-2 归档夹具**：`mv plans/task-v055-scheduler-enforce plans/archive/` → 新版重跑输出 `[index] Wrote /tmp/c3verify/plans/INDEX.md (in_progress=1 pending=0 complete=35)`；diff 前一轮仅 3 处变化：①主表行 `| task-v055-scheduler-enforce | complete | 5/5 | …` 消失 ②已完成清单行 `- task-v055-scheduler-enforce ✓ (5/5) — 2026-09-27` 消失 ③汇总 `complete: 36`→`35`。**仅该行消失+计数联动，符合提案归档夹具期待（29.6 防回归特性成立）**。已复原（mv 回+重跑，task-v055 行数 2 恢复）

### C-4 守护 — PASS 3/3
- **C4-1 一致性**：worktree 实跑 `bash scripts/selftest-registry.sh` → `T01 PASS / T02 PASS / T03 PASS / T04 PASS / T05 PASS / Total: 5 PASS=5 FAIL=0 (registry rows=32, actual selftest=32)`，rc=0（32=31 实际+守护自登记，与 S25 记载一致）
- **C4-2 负例（/tmp/c4verify 副本，未动 worktree）**：tsv 中 `selftest-dispatch.sh`→`selftest-distrib.sh`（一个脚本名改错值）+ 实际目录仍含真名 → 守护 `T02 FAIL 未登记: selftest-dispatch.sh`、`T03 FAIL 孤儿行: selftest-distrib.sh`、`Total: 5 PASS=3 FAIL=2`、rc=1 → **守护断言 FAIL 咬住，符合提案验证设计③**
- **C4-3 子集计时**：registry 反查「改 check-dispatch.sh」= 3 脚本（selftest-conclusion-discipline / selftest-dispatch / selftest-fine-grain-steps，dep_anchors 列含 check-dispatch.sh）；实跑 3 脚本 rc 全 0（Total 行：dispatch `Total: 29 PASS=29 FAIL=0`），`time` 实测 **real 0m7.104s ≤ 25s 达标**（≤40% 基线 26s 亦达标；3/32 子集 7.1s，全量 65.7s 基线下省 ~58.6s/轮）
- 佐证：critical-rules.md:318 Rule 36.6a 原文「开发过程中间轮次只跑改动域子集；**交付终验必须全量 selftest 0 FAIL，全量总门不降**（36.6 原句原文保留）」——36.6 原句 :317 未动，纯增补子条成立

### C-5 四场景 — PASS 4/4
驱动方法（V 预检环境不可独立跑，说明在案）：从 worktree smart-merge-back.sh **原样提取** `_re_lines`（:519 单行函数）+ `deploy_reconcile`（:520-557）两函数零改动，注入与脚本 :355/:359/:537 同口径变量 DEPLOY_SRC=/tmp/c5verify/mainrepo/skills/task-planner（≥8 文件：scripts/4 + docs/4）、MAIN_REPO、MB=`git merge-base master wt/c5test`（真实 git 仓，git diff 清单含 a.sh）；slot=DEPLOY_SRC 的 cp -rL 全量拷贝（第二棵树）。
- **①清单内内容差异**（a.sh ∈ git 清单，slot 侧追加 1 行热改）→ `[DEPLOY] DRIFT-L2: /tmp/c5verify/slot (内容差异: scripts/a.sh)` → `[DEPLOY] DRIFT` rc=6 ✅ L2 定向 diff 报出
- **②部署位多文件**（slot 多 extra-file.md + rogue.txt）→ `[DEPLOY] DRIFT-L1: /tmp/c5verify/slot (文件集合差: 缺/多如下) 多余: extra-file.md rogue.txt` rc=6 ✅ L1 集合差确定性报出
- **③仓侧已删残留**（mainrepo 删 docs/e.json，slot 保留）→ `[DEPLOY] DRIFT-L1 … 多余: docs/e.json` rc=6 ✅ L1 集合差报出（「仓侧已删」在集合差中现形为部署位「多余」侧，即提案期待的「L1 报」，确定性断言非概率抽检）
- **④全一致**（slot=仓侧原样拷贝）→ `[DEPLOY] IDENTICAL: /tmp/c5verify/slot (基准=主仓 skills/task-planner)` rc=0 ✅
- 判定行字节兼容在证：IDENTICAL/DRIFT 行措辞与脚本 :609/:618 原文一致；DRIFT-L1/L2 明细行先行打印（C-5 新行为，:530-531/:552 注释在案）；清单空保守回退（:545-548 targets=$common 全交集 cmp）未在本四场景触发（本场景 git 清单非空），逻辑读码确认

### A-3 等价性 — PASS 3/3（流程层+机器层+三态）
- **甲 流程层（SKILL 三处核对，git diff 53ff783 前后）**：
  - drift 触发点：Phase 循环 Step 6 `[DRIFT CHECK]`（:102）唯一，二选一**留 Skill(task-drift-guard)、删 check-drift.sh 双跑**（:102 注「本触发点唯一检测载体——check-drift.sh 仅作可选佐证，不双跑；C4」；旧版 C4a 行「Phase 完成后已运行 check-drift.sh --json」整行删除，新版无 C4a；grep 全 SKILL `check-drift` 仅 :102/:179 佐证提及 2 处）
  - plan-resume：旧版 Phase 循环 Step 6 后「PLAN-RESUME 被动扫描（Phase complete 后，在 DRIFT CHECK 之前调）」+ Step 5「调用 plan-resume 被动扫描」全删；新版仅存 :136（Chain 交接 Step 5「恢复触发点（交付终态/会话恢复）按 Rule 24.5 自主续推（per-block 扫描已收敛）」）、C13（:188 终态/恢复触发点）、Rule 24 摘要行 :301「交付终态/会话恢复触发点扫中断任务（task-v091 A-3 收敛，不再每 Phase 扫）」——**只在终态/恢复点，且 24.7 ≤3 Phase 豁免保留（C13「24.7 豁免场景登记跳过」）**
  - C 表：C1-C27 全部加「机器门承载/人工保留不收敛」标注（C15/C20「人工保留不收敛」）；旧版 4 处 N/A/PASS 强制记行条款（C19/C20/C24/C27 行末「→ 本项 N/A 记一行 / PASS 记一行」）全删，改写为条件式「未命中…则不触发，无需记行」（C19/C20/C27 新版原文在案）；C 表 28 行（C4a 删 1）
- **乙 机器层（compliance warn/mini 夹具，/tmp/c2verify 三件套扩展）**：
  - standard 缺项（t2：verification.md 无委派统计段）→ `[compliance] WARNING (task-v091 A-3 终验抽查, warn 档不阻断, tier=standard 分域): 抽查缺项点名 —  verification.md 委派统计段缺失(C14/Rule 25)`，rc=0（warn 不阻断，exit 码=python_rc 未变）
  - mini 不误报（t3：plan_tier: mini，VC=2，无委派统计段）→ `[compliance] OK (task-v091 A-3 终验抽查通过, tier=mini 分域: 3-File/VC 行数降档阈值/委派统计段豁免跳过/Handoff verify_done豁免跳过)`，VC-GATE PASSED（VC 表=2 ≥2 降档）+ fmea-gate MINI-TIER 豁免面未误伤（t3 无 FMEA 段出 warn 属既有 v086 行为，非 A-3 面），rc=0 → **tier 感知分域生效，终审 #8 互锁成立**
  - 附加（G5 不削弱证据）：t2 先缺 progress.md 跑 → `3-File Gate failed (Rule 19.5) — progress.md missing` rc=1，既有 3-File 硬门原样咬住
- **丙 三态等价性**：保留侧=task-drift-guard skill（~/.zcode/skills/task-drift-guard/SKILL.md:52-54 三态表 ALIGNED→继续 / DRIFT→询问用户 / BLOCKED→STOP 等决策，:75「🔴 → STOP 所有写入，等用户决策」）；SKILL.md :102-104 与 critical-rules Rule 15（:38-46）语义一致——**BLOCKED→STOP 语义未缩水**（skill 本体零改动，删的只是同点 check-drift.sh 双跑；check-drift.sh 脚本本体未删，降级为可选佐证=提案 36.4 清单②口径「同点双跑删一」）

## 8 字段返回
- **status**: 成功（5/5 验证项全 PASS，无 FAIL；发现 2 处非阻断注记，见 risks）
- **files_written**: 仅检查点 /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-g3-guards.md + /tmp 夹具（/tmp/c2verify /tmp/c3verify /tmp/c4verify /tmp/c5verify /tmp/a3-*.out /tmp/c4run-*.out）；**worktree 零写入**（git status 复验：/mnt/data/dev/task-planner-skill-worktrees/task-v091 干净）；主仓仅 worktree add/remove 一次 /tmp/c3verify/wt-old（已 remove）
- **acceptance**（逐项）: C-2 6/6（verify rc=0 / sed 一字节 rc=1 / touch -r 仍 rc=1 / SKIP×2 原文 / cpd 加行不 SKIP / fmea_enforce+plan_tier_enforce 不 SKIP）；C-3 2/2（旧 vs 新 diff 空 + 归档仅该行消失 36→35）；C-4 3/3（Total PASS=5 FAIL=0 / 负例 T02+T03 FAIL rc=1 / 子集 7.1s≤25s 3 脚本全 PASS）；C-5 4/4（DRIFT-L2 a.sh / DRIFT-L1 多余 2 文件 / DRIFT-L1 e.json / IDENTICAL rc=0）；A-3 3/3（SKILL 三处 diff 在案 / compliance standard 点名+mini OK 原文 / 三态表 :52-54 + BLOCKED→STOP 原文）——共 18/18
- **key_decisions**: ① C-2 六步按提案原文在 /tmp 最小可跑夹具（主进程 Executor 无派发型 Phase，cpd 走 fail-open 分支=实跑，与 selftest-final-gate-hash 同口径）② C-3 对拍基准改用「同份 plans 拷贝上 216e912 旧脚本 vs worktree 新脚本」（cp 重置 mtime 致与 git 存储 INDEX 的 mtime 列不可逐字对，内容行零 diff 为准）③ C-5 用函数级最小驱动（提取 _re_lines+deploy_reconcile 原样+同口径变量注入，未跑 V 预检段——对账段与其无耦合）④ A-3 甲项用 git diff 53ff783 前后 grep 全量核对，非仅 Read 新版
- **risks**: ① C-3 旧脚本（216e912 版）对 37 计划跑时 exit 1（INDEX 已写出且可 diff，exit 语义未追溯根因——不在 C-3 验收面，S21 主进程记载同结论互证，判 LOW）② C-5 场景④「全一致」中仓侧 mainrepo 的 a.sh=master 基线内容、git 清单标 a.sh 已改（BRANCH 侧），slot 与 mainrepo cmp 一致 → IDENTICAL 正确（对账基准=mainrepo 非 BRANCH，与 :359 DEPLOY_SRC 口径一致）；残留面（清单外同名文件带外热改靠 ≥3 抽检）按 S30 裁量记录在案，未构造「清单外热改恰好漏抽」负场景（提案明示可接受）③ t2 夹具的 fmea-gate warn（无 FMEA 段）属 v086 既有行为非 A-3 面
- **next**: 主进程按进度门：G3/G5/G6/G8 护栏回归（selftest 全量 27 脚本 0 FAIL，双侧）→ 36.4 清单用户确认 → 合入合约（§11.3 六条）
- **fallback_used**: 无（各验证项一次跑通；C-5 驱动脚本 awk 提取区间 2 次语法修正属夹具自身问题，非被测对象行为）
- **checkpoint**: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-g3-guards.md

## R2 复验（干净上下文第二次独立执行，2026-09-27 10:5x）

### V1=C-2 六步（/tmp/c2v-r2，独立重建，未复用前轮 /tmp/c2verify）— PASS 6/6
- 夹具=skill 整树拷 /tmp/c2v-r2/skill + /tmp/c2v-r2/plans/t1 最小计划（git init；attest 锁定 SHA ee8bc81b...）
- ① `attest --verify` 原样 s1_rc=0
- ② `sed s/低/中/` 一字节 → s2_rc=1（TAMPERED）
- ③ `touch -r` 2020 mtime → s3_rc=1 仍 TAMPERED（内容哈希闭合 mtime 绕过）
- ④ 复原（sed 逆操作，sha256 与 plan_sha256 一致）→ check-complete 第1轮全量 s4a_rc=0 SKIP=0 状态落 fg_key；第2轮 s4b_rc=0，原文：
  - `[plan] PLAN-DISPATCH GATE SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果)`
  - `[fmea-gate] SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果, fmea_enforce=warn)`
  - 余门照跑原文：DELEGATION GATE PASSED / VC-GATE WARNING / LEARNING-GATE PASSED / REFLECT-GATE SKIPPED / SKILL-MODIFY GATE SKIPPED / [compliance] WARNING，终态 rc=0 两轮一致
- ⑤ cpd 追加 `# r2-key2-probe` 轮：skip=0、`[plan-dispatch] fail-open: 无派发型 Phase` 实跑（s5_rc=0）；复原轮全量重锁 s5r_rc=0 skip=0 → 键②闭合
- ⑥ config `.fmea_enforce="enforce"` → skip=0 且 `[fmea-gate] OK (fmea_enforce=enforce)` 实跑；`.plan_tier_enforce="enforce"` → 同不 SKIP；复原后全量重锁→次轮 SKIP=2 复效。键④闭合
- 附加：`bash scripts/selftest-final-gate-hash.sh` 独立复跑 `==== PASS=22 FAIL=0 ====` rc=0（内建六夹具+键④五键完整性守护）

### V2=C-3 sync-todos 单 awk 全量重算（/tmp/c3v-r2）— PASS 4/4
- 主仓 plans/ 拷贝 37 计划（find -maxdepth 2 task_plan.md = 37，与 S21 记载一致）；INDEX.md 先行删除保证双方从零生成
- C3-1 旧版(216e912) vs 新版对拍：旧脚本+旧 scripts/lib/plan-parse.sh（216e912 时点在 scripts/lib/，本轮修正前轮误取 lib/ 的路径）→ 新脚本（worktree HEAD）；`diff <(grep -v 'Last refreshed' INDEX.old) <(grep -v 'Last refreshed' INDEX.new)` = **空（diff_rc=0, 0 行）**，双方摘要同为 in_progress=1 pending=0 complete=36
- C3-2 归档夹具：`mv plans/task-v055-scheduler-enforce archive/` → 新版重跑 `[index] Wrote ... (in_progress=1 pending=0 complete=35)`；diff 恰 3 处=主表行消失/已完成清单行消失/汇总 36→35；v055 行残留计数=0。复原后行数 2 恢复，rc=0
- C3-3 实现确认：worktree sync-todos.sh:195-240 = `find -printf '%p\t%TY-%Tm-%Td' | sort -t$'\t' -k1,1 | awk（单流式 getline 解析全部计划）`，bash 仅聚合数组+写 INDEX；旧版每计划 fork 子进程链
- C3-4 execve 对比（strace -f -c）：旧脚本 **total forks=930 / execve=259** vs 新脚本 **total forks=930 / execve=6**（strace 进程 fork 数相同、execve 259→6，与 S21「execve 861→8」同量级）

### V3=C-4 selftest 分域 registry（/tmp/c4v-r2 /tmp/c4v-neg）— PASS 3/3
- C4-1 一致性：worktree 实跑 `bash scripts/selftest-registry.sh` → `T01..T05 全 PASS / Total: 5 PASS=5 FAIL=0 (registry rows=32, actual selftest=32)` rc=0（32=31 实际+守护自登记，与 S25 记载一致）
- C4-2 子集计时：registry dep_anchors 反查「改 check-dispatch.sh」= selftest-dispatch / selftest-fine-grain-steps / selftest-conclusion-discipline 三脚本；实跑全 PASS（Total 29+24+11，rc=0），`time` real **7.155s ≤ 25s 达标**（3/32 子集；S31 全量 32 脚本一轮 ~65s 基线下省 ≈58s/轮）
- C4-3 改名负例（/tmp/c4v-neg 副本，未动 worktree）：目录 `mv selftest-dispatch.sh selftest-distrib.sh` + tsv 首列值改错（保持指向 selftest-dispatch.sh）→ 守护 `T02 FAIL 未登记: selftest-distrib.sh`、`T03 FAIL 孤儿行: selftest-dispatch.sh`、`Total: 5 PASS=3 FAIL=2` rc=1 → **改名负例咬住，符合提案验证设计③「改名场景期待守护断言 FAIL」**
- 佐证（前轮已录）：critical-rules.md Rule 36.6a 纯增补「终验全量总门不降」，36.6 原句零改动

### V4=C-5 部署对账两级化（/tmp/c5v-r2）— PASS 4/4
- 驱动方式：smart-merge-back.sh HEAD a05bd5e **原样提取** `_re_lines`+`deploy_reconcile`（39 行，零改动）+ 同口径变量注入（DEPLOY_SRC=最小主仓 skills/task-planner 8 文件：scripts/4+docs/4；MAIN_REPO/MB=master/BRANCH=wt/c5test 真实 git 仓，branch 侧 a.sh 带 hotfix）；slot=cp -rL 第二棵树。驱动脚本首跑 slots 目录缺失致 cp 失败全部误 DRIFT，夹具自身问题修正后（mkdir slots）四场景：
  - ①清单内内容差异（slot 侧 a.sh 追加热改，a.sh ∈ git MB..BRANCH 清单）→ `[DEPLOY] DRIFT-L2: /tmp/c5v-r2/slots/s1 (内容差异: scripts/a.sh)` → DRIFT rc=6 ✅ L2 定向 diff 报出
  - ②部署位多文件（slot 多 extra-file.md + rogue.txt）→ `[DEPLOY] DRIFT-L1 … 多余: extra-file.md rogue.txt` → DRIFT rc=6 ✅ L1 集合差确定性报出
  - ③仓侧已删残留（主仓删 docs/e.json，slot 保留）→ `[DEPLOY] DRIFT-L1 … 多余: docs/e.json` → DRIFT rc=6 ✅ 仓侧已删在集合差现形为部署位「多余」侧（确定性断言）
  - ④全一致（slot=仓侧原样拷贝）→ `[DEPLOY] IDENTICAL: /tmp/c5v-r2/slots/s4 (基准=主仓 skills/task-planner)` rc=0 ✅
- 附加：`bash scripts/selftest-smart-merge.sh` 独立复跑 `Total: 15 PASS=15 FAIL=0` rc=0（部署位 selftest 全量不裁保持）
- 残留面如实说明：清单外同名文件带外热改靠 ≥3 确定性前 3 抽检兜底（未抽中漏检=提案明示可接受，未构造负场景）；空清单保守回退全交集 cmp 本四场景未触发（git 清单非空），逻辑读码确认在 :545-548

### V5=A-3 重复检测合并（SKILL 走查 + /tmp/c2v-r2 t2/t3 夹具）— PASS 3/3
- **甲 流程层 2-Phase 走查**（worktree SKILL.md HEAD a05bd5e 实读）：
  - 2-Phase 样例（Phase 1/2 各 complete，Executor=主进程）逐 Phase 调用清单=每 Phase 恰好 1 次 `Skill("task-drift-guard")`（SKILL:102 Step 6 `[DRIFT CHECK]` 原文「本触发点唯一检测载体——`check-drift.sh` 仅作可选佐证，不双跑；C4」）→ **drift 每 Phase 恰 1 次、无 check-drift 双跑**（grep SKILL `check-drift` 仅 :102/:179 两处佐证提及）
  - **plan-resume 仅终态**：Phase 循环 6 步内无 plan-resume 调用；仅 C13（:188「计划交付终态/会话恢复触发点已按 Rule 24.5 调 Skill("plan-resume")…不再每 Phase 被动扫描；24.7 豁免场景登记跳过」）+ Rule 24 摘要（:301「交付终态/会话恢复触发点扫中断任务（task-v091 A-3 收敛，不再每 Phase 扫）」）+ Chain 交接 Step 5（:136「恢复触发点（交付终态/会话恢复）」）→ 与提案 36.4 清单①「移终态/恢复点」一致
  - C 表 27 项均带「机器门承载/人工保留不收敛」标注（:173-204），N/A 强制记行条款已删（前轮 grep 10 selftest C 锚 10 全绿互证）
- **乙 机器层缺项 warn**（/tmp/c2v-r2 独立构造，前轮 t2 同构重建）：
  - t2 standard（VC 表 5 行齐备、无 verification.md 委派统计段）→ rc=0 且原文 `[compliance] WARNING (task-v091 A-3 终验抽查, warn 档不阻断, tier=standard 分域): 抽查缺项点名 —  verification.md 委派统计段缺失(C14/Rule 25)` → **缺项点名生效，warn 不阻断**
  - t3 mini（plan_tier: mini、VC=2、无委派统计段）→ rc=0 且 `[compliance] OK (task-v091 A-3 终验抽查通过, tier=mini 分域: 3-File/VC 行数降档阈值/委派统计段豁免跳过/Handoff verify_done豁免跳过)` + `[plan] VC-GATE PASSED (VC 表=2, 1 个 Phase 各 ≥1 条 V-N 映射)` → **tier 感知分域不误报（终审 #8 互锁成立）**。注：t3 首跑 findings stub<3 行被 3-File 门 exit 1（既有硬门），补 3 行实质发现后通过=3-File Gate 未因 A-3 削弱（G5 不削弱旁证）
- **丙 三态等价**（保留侧=skill，验证方式如实说明）：
  - 保留侧 task-drift-guard skill 零改动：`/home/terry/.zcode/skills/task-drift-guard/SKILL.md` :52-54 三态表原文「ALIGNED→继续 / DRIFT→询问用户 / BLOCKED→STOP 等决策」+ :74-75「⚠️ → 问用户：纠正/继续/STOP；🔴 → STOP 所有写入，等用户决策」——**BLOCKED→STOP 语义完整未缩水**
  - 被删侧 check-drift.sh 降级为可选佐证（本体未删，:102/:179 明示），其输出经 grep 实证为计分制 `[DRIFT-CRIT/WARN/INFO]` 报告+JSON drift_score，与 skill 三态判定口径不同（skill 是判定层，脚本是佐证层）——「三态判定一致性」验证方式=保留侧 skill 三态表原文逐条对照 + Rule 15（critical-rules.md:38-46 三态）/SKILL:102-104 契约一致读码，非运行两侧对拍（skill 侧为 LLM 判定层不可脚本化对拍，如实说明）；被删双跑语义=同点不再双跑而非判定删减
- 附加（SKILL:106 触发时机原文在案）：「Phase 标记 complete 后立即 / 连续 ≥3 次工具调用后 / 切换文件/模块前 / 用户发出新指令时」——Rule 15 触发点全保留（提案质量风险①漂移频率降漏漂移面=同点二选一非删除，读码确认）

## R2 复验最终 8 字段返回（干净上下文第二次独立执行，2026-09-27）
- **status**: done
- **files_written**: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-g3-guards.md（本文件，追加 R2 段+本 8 字段）；/tmp 夹具=c2v-r2（含 t1/t2/t3 plans）/c3v-r2/c4v-r2/c4v-neg/c5v-r2。worktree 零写入（`git status --short` 空、HEAD 仍 a05bd5e 复验在案）
- **acceptance**（逐项）:
  - V1=C-2 六步 6/6 PASS：①verify s1_rc=0 ②sed 一字节 s2_rc=1 TAMPERED ③touch -r s3_rc=1 仍 TAMPERED ④未变两轮 SKIP×2 原文在案 终态 rc=0 不变 ⑤cpd 加行 skip=0 实跑 ⑥fmea_enforce/plan_tier_enforce 突变 skip=0，复原后 SKIP=2 复效；selftest-final-gate-hash 22/0 rc=0
  - V2=C-3 2/2 PASS：37 计划旧(216e912) vs 新 diff（剔 Last refreshed）=空；归档 mv 后 complete 36→35 仅 v055 主表行+清单行消失；实现确认=find|sort|单 awk getline（sync-todos.sh:195-240）；strace execve 旧 259→新 6
  - V3=C-4 3/3 PASS：守护 Total 5 PASS=5 FAIL=0 rc=0（rows=32=31+自登记）；check-dispatch 改动域 3 脚本 64 PASS `real 0m7.155s ≤25s`；改名负例 T02 FAIL 未登记+T03 FAIL 孤儿行 rc=1 咬住
  - V4=C-5 4/4 PASS：s1 清单内热改→DRIFT-L2 scripts/a.sh rc=6；s2 slot 多 2 文件→DRIFT-L1 多余 rc=6；s3 仓侧删 e.json slot 残留→DRIFT-L1 多余 rc=6；s4 全一致→IDENTICAL rc=0；selftest-smart-merge 15/0 rc=0
  - V5=A-3 3/3 PASS：drift 每 Phase 恰 1 次（skill 唯一载体）/plan-resume 仅终态恢复点（C13+Rule 24 摘要）/C 表机器门承载标注全在；t2 standard 缺项 `[compliance] WARNING…委派统计段缺失(C14/Rule 25)` rc=0 warn 点名；t3 mini `[compliance] OK…委派统计段豁免跳过` 不误报；三态=skill :52-54/:74-75 原文 BLOCKED→STOP 未缩水（验证方式=保留侧原文逐条对照+Rule 15 契约读码，skill 为 LLM 判定层不可脚本对拍，如实说明）
  - 共 18/18 全 PASS，与前轮 S32-g3 独立结论一致（双干净上下文互证）
- **evidence**: 关键输出原文均存 /tmp/c2v-r2/{s1..s6b,t2,t3}.out、/tmp/c3v-r2/{diff1.txt,strace-*.txt,new-run*.out}、/tmp/c4v-r2/{dispatch,concl,concl}.out、/tmp/c4v-neg（tsv+目录副本）、/tmp/c5v-r2/slots/s1-s4+driver.sh；file:line 锚=check-complete.sh:458-522(SKIP 段)/:1003-1025(compliance 段)、sync-todos.sh:195-240、smart-merge-back.sh:519-557、SKILL.md:102/:136/:188/:301、critical-rules.md:38-46
- **checkpoint**: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-g3-guards.md
- **findings_written**: none（本组=验证组，不写 findings）
- **blockers**: none
- **confidence**: HIGH（18/18 全 PASS；C-5 残留面/三态 skill 侧对拍边界两处如实披露为低风险，均与提案明示可接受面一致，不阻断）

## R2 负结果/风险披露区
- 未发现与提案验证设计矛盾的行为；无步骤异常
- 已排除风险：C-2 mtime 绕过（touch -r 仍 TAMPERED）/C-3 统计回归（归档行消失+计数联动）/C-4 改名漏登记（守护咬住）/C-5 清单内漏检（L2 定向 diff 报出）/A-3 mini 误报（分域豁免跳过）/三态缩水（BLOCKED→STOP 原文在案）
- 风险披露（LOW 不阻断，与前轮一致）：① C-5 未构造「清单外热改恰好漏抽」负场景（残留面提案明示可接受）② 三态等价验证限于保留侧 skill 原文对照+Rule 15 契约（skill 判定层不可脚本对拍）③ C-3 对拍基准=同一 plans 拷贝上旧脚本 vs 新脚本（cp 重置 mtime 致与 git 存储 INDEX mtime 列不可逐字对，内容行零 diff 为准）
