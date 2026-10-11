# Task Plan: task-v068 执行稳定性增强——环境级中断自愈（哨兵/tamper/observe）

<!--
  template_type: skill-fix
  cost_estimate:
    main_process_opus: 1
    subagent_calls:
      explore: 1            # mini
      executor: 4           # sonnet-1（S1-S4,worktree 串行）
      code-runner-agent: 1  # mini
    estimated_opus_equivalent: 2.0   # ≈ 1 + 0.05×1 + 0.1×4 + 0.02×1
    estimated_savings_vs_naive: 0.40
-->

## Goal
让 task-planner 技能族的 hook 链路具备「环境级中断自愈」能力:本会话产生的 5 类中断事件(E1-E5)在满足 sid 护栏的前提下自动自愈或降噪,使执行不被中途打断,且全量 selftest 无回归。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `7faf38a5235e4337b64241edd6a4b690` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v068-execution-stability` |
| `scope_files` | `[skills/task-planner/scripts/zcode-pretooluse.sh, skills/task-planner/scripts/zcode-posttooluse.sh, skills/task-planner/scripts/zcode-userpromptsubmit.sh, skills/task-planner/scripts/check-scope.sh, skills/task-planner/scripts/plan-created.cjs, skills/task-planner/scripts/attest-plan.sh, skills/task-planner/SKILL.md, skills/task-planner/config.json, skills/task-planner/scripts/selftest-execution-stability.sh]` |
| `interaction_mode` | `silent` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
-->

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 哨兵自愈落地:非交互 Bash(env 无 sid)模拟 plan-created 后,本会话哨兵被自动清除,`~/.zcode/cli/memories/**` 写入不再被拦 | 端到端实测:临时 plan 目录 + `env -u SID bash ...` 模拟非交互清哨兵 + memory 写入白名单放行 | `subagent-state/04-runner-evidence.md` §E1 + 仓内 `plans/task-v068-execution-stability/verification.md` |
| VC-2 | tamper 自愈落地:本会话编辑 task_plan.md 后重锁自动完成(自动重锁或 `attest-plan.sh --if-mine`),TAMPERED 不再出现;外部篡改(非本 sid)仍被拒(护栏) | 端到端实测:本 sid 编辑→重锁成功 + 负例:伪造他 sid 编辑→仍 TAMPERED 拒绝 | 同上 §E2 |
| VC-3 | observe 降噪落地:`.session-owner` 认领链路修复(E3 根因:首次交互后写入未发生),delegation-observe 注入降频(初始化完成前仅首次注入) | 代码 diff 审读 + 新会话模拟 UserPromptSubmit 触发链路实测 | 同上 §E3 |
| VC-4 | SKILL「中断自愈优先」条款落地 + 新 config 键(如 `hook_self_heal_enforce`,warn 范式,兼容既有 28 键无冲突) | SKILL.md diff + config.json 键数核对 + check-doc-sync/grep 一致 | SKILL.md 对应条款行号(写入时记录) |
| VC-5 | 新 selftest `selftest-execution-stability.sh` 全绿,全量 selftest(12 套件基线 196 例)0 fail 无回归 | 在 worktree 内跑全量 selftest,输出统计 | `verification.md` selftest 统计表 |
| VC-6 | 跨文件一致性:新 config 键名/SKILL 条款/白名单路径在 scripts 与 SKILL/config/selftest 中 grep 一致,无孤儿引用 | `grep -rn "hook_self_heal"` + 白名单路径 grep,0 不一致 | grep 输出存档 `verification.md` |
| VC-7 | Code Review Gate APPROVED + `merge_back=merged(<commit>)` + 部署 3 位(~/.zcode、~/.claude、~/.config/opencode)对账 | smart-merge-back --deploy 输出 + 3 位 diff 对账 | `progress.md` Phase 5 段 + 隔离决策表 merge_back 字段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`,终验前必须先通过 Code Review Gate,否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!--
  🚫 只操作本列表中明确列出的文件;未在列表中的文件一律不碰;扩展范围须用户授权。
  全部路径相对 canonical 仓 /mnt/data/dev/task-planner-skill/(实现期在 worktree 内,路径同构)。
  "按勘察" = 最终是否触及以 Phase 1 勘察结论为准,不新增超出列名范围的文件。
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码(hook 脚本) | `skills/task-planner/scripts/zcode-pretooluse.sh`、`zcode-posttooluse.sh`、`zcode-userpromptsubmit.sh`、`check-scope.sh`、`plan-created.cjs`、`attest-plan.sh`、`check-delegation.sh`(Phase 2 修订补入:S3b observe 节流+tr 规范对齐) | 其他 scripts/*.sh/*.cjs(含 register-hooks-cj.ts、resolve-plan-dir.sh、set-active-plan.sh、resolve-interaction-mode.sh) |
| 测试 | `skills/task-planner/scripts/selftest-execution-stability.sh`(新增) | 其他 selftest-*.sh(只读运行,不修改) |
| 配置 | `skills/task-planner/config.json` | `~/.zcode/cli/config.json`(hooks 注册表,不碰)、其他配置 |
| 文档 | `skills/task-planner/SKILL.md`(中断自愈条款+净增 ≤10 行约束) | 其他 SKILL/agent/references 文档 |
| 计划簿记 | `plans/task-v068-execution-stability/**`(findings/progress/verification/notepad-learnings/subagent-state) | 其他 plans/* |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户(silent 模式下记 findings.md 待用户确认项)

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | hook 仓内收编脚本全集(v059/v060 批) | `skills/task-planner/scripts/{zcode-pretooluse.sh,zcode-posttooluse.sh,zcode-userpromptsubmit.sh,check-scope.sh,plan-created.cjs,attest-plan.sh}` @ master 9dacc9d | 必读 | ☐ |
| 项目内部文档/知识库 | 哨兵机制与 `.plan_required_side/` 布局 | `plans/.plan_required_side/`(E1 手动 rm 路径) + plan-created.cjs 清除逻辑 | 必读 | ☐ |
| 项目内部文档/知识库 | attestation 机制(.plan-attestation SHA) | `scripts/attest-plan.sh` + 各 hook 的 TAMPERED 检测点 | 必读 | ☐ |
| 项目内部文档/知识库 | SKILL 现行条款(Rule 22.3.3 技能族接管 / 28.4.1 silent 降级 / 26.3 提醒升级) | `skills/task-planner/SKILL.md` @ 9dacc9d(513 行基线) | 必读 | ☐ |
| 项目内部文档/知识库 | 中断事件设计输入 E1-E5(勿改写) | 本计划 Phase 段上方 E1-E5 记录 + `subagent-state/` 勘察回填 | 必读 | ☑ |
| 官方文档 | ZCode hook 事件模型(UserPromptSubmit/PreToolUse/PostToolUse 执行时序) | 仓内 `register-hooks-cj.ts` + `~/.zcode/cli/config.json` hooks.events 注册 | 参考 | ☐ |

**填写规则**：① 定位必须可唯一定位;② 必读项缺失 → 停止执行并记 findings.md Errors;③ Phase 1 开工前逐项确认勾选。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: hook 链路 5 类环境级中断(哨兵误拦 E1 / TAMPERED 摩擦 E2 / observe 未初始化注入 E3 / 慢注入 E4 / 密集提醒叠加 E5)是否能在「sid 匹配护栏」前提下全部实现自动自愈或降噪,使执行稳定性达到「不靠手动 rm/重锁兜底」?

**核心问题判断**:
- [x] 核心问题解决后,结果能交付吗?(能——自愈矩阵+全量 selftest 无回归+部署 3 位即交付)
- [x] 核心问题不解决,其他工作都白费吗?(是——不定位 E1-E4 根因,实现期改的就是猜测)
- [x] 核心问题的解决方法是清晰的、可执行的?(是——Phase 1 勘察→Phase 2 裁定→S1-S4 实现→端到端实测,路径明确)

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
已交付（COMPLETE, merge f783880, 2026-09-14）

## Next Step
无挂账;D-1..D-5 已登记 verification.md（off 档守卫/E4 性能轮/allow-direct canon 清扫等后续候选）

## 设计输入：本会话实锤中断事件（勿改写,实现期根因对照表）

| 事件 | 现象 | 初步定位 |
|------|------|---------|
| E1 | 会话哨兵复活误拦 memory 写入 ×2:非交互 Bash 无 sid env 时 plan-created.cjs 清不掉本会话哨兵(显示成功实未删),须手动 `rm plans/.plan_required_side/<sidkey>.plan_required`(v065 D-12 + v060 缺陷复现) | plan-created.cjs 清除逻辑依赖 sid env |
| E2 | PLAN TAMPERED 摩擦 ×3:计划期合法修订(设计定稿/簿记回填)后未立即重锁 → hook 拒绝注入计划 → 手动重跑 attest-plan.sh;批量编辑+派发前定锁可缓解但未机制化 | .plan-attestation SHA 比对点 |
| E3 | delegation-observe 行每次工具调用注入:`.session-owner` 未初始化(plan_dir=...,sid=sess7faf...) 提示反复出现 → UserPromptSubmit「首次交互后写入」未发生或写入后仍判未初始化 | zcode-userpromptsubmit.sh 认领链路 |
| E4 | Edit 超时 30s ×1(hook 处理慢,写入实际已生效) | 疑似 observe/重活注入逻辑,与 E3 可能同根 |
| E5 | [plan-sync]/[plan-compass] 密集提醒(10 次调用/20-25min 阈值)+ 二次未响应升级警告(Rule 26.3 PARTIAL 扣压) | 提醒本身合理,与 E3/E4 叠加放大打断感,本任务只做降噪不删 |

## Phases

### Phase 1: 调研——hook 链路勘察
<!-- 目标:定位 E1-E4 全部根因,产出 Phase 2 裁定所需的全部事实。 -->
- [x] ① 哨兵拦截点:zcode-pretooluse.sh(或 check-scope.sh)哪段 gate 非 plans/ 写入、现有白名单清单、memory 目录(`~/.zcode/cli/memories/**`)是否在列
- [x] ② plan-created.cjs 的 sid env 依赖与清除逻辑,定位 v060 缺陷行(显示成功实未删的确切原因)
- [x] ③ `.session-owner` 认领链路:zcode-userpromptsubmit.sh 写入条件、为何本会话未初始化(E3 根因)
- [x] ④ TAMPERED 检测点:哪个脚本比对 `.plan-attestation` SHA、PostToolUse 可挂点(为 S2 裁定提供可行性事实)
- [x] ⑤ E4 慢源:delegation-observe 注入逻辑是否每次重跑 check-delegation stats 等重活(验证 KQ3)
- [x] ⑥ 相关 config 键与提醒阈值键盘点(为 S4 新键避免撞 28 键)
- [x] 勘察结论写入 checkpoint,主进程 Read 后回填 findings.md「Research Findings」
- **V-N:** VC-1, VC-2, VC-3, VC-6
- **Status:** complete（证据: subagent-state/01-explore-hooks.md 六项锚点+S1-S3 改动点清单+风险注记 5 条; findings 回填）
- **Executor:** explore（mini）
- **checkpoint:** `plans/task-v068-execution-stability/subagent-state/01-explore-hooks.md`

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | hook 链路六项勘察 | explore（mini） | `skills/task-planner/scripts/`{zcode-pretooluse.sh, zcode-posttooluse.sh, zcode-userpromptsubmit.sh, check-scope.sh, plan-created.cjs, attest-plan.sh}(@9dacc9d;摘要:哨兵 gate 段/白名单/attest 比对/owner 写入条件/observe 注入逻辑/阈值键)+本计划 E1-E5 表 | checkpoint 文件含六项逐项结论+file:line 锚点,主进程 Read 复核 | ≤15min | pending |

### Phase 2: 设计——自愈矩阵裁定
<!-- 目标:基于 Phase 1 事实,为每类中断裁定「自愈动作 + sid 护栏」,定改动面清单。 -->
- [x] 逐类裁定:哨兵自愈(S1 方案细则)/tamper 自愈(PostToolUse 自动重锁 vs `attest-plan.sh --if-mine` + SKILL 指引,二选一,KQ2)/observe 修复+降噪(S3 细则)/SKILL 条款+config 键(S4 键名与语义)
- [x] 护栏统一裁定:sid 匹配才自愈,防外部篡改被自动重锁/哨兵误删(回答 KQ1/KQ2)
- [x] 改动面清单固化(确认 scope_files 无需扩展)→ 结论写入 `findings.md` Technical Decisions
- [x] 更新 S-unit 表:按裁定结果定 Phase 3 的 S-unit 数与材料包
- **V-N:** VC-2, VC-4, VC-6
- **Status:** complete（证据: findings「Phase 2 设计定稿」自愈矩阵 6 行+KQ1-4 裁定; scope 修订补 check-delegation.sh; S-unit 维持 S1-S4）
- **Executor:** 主进程（例外理由:② 调度/设计本职——Rule 25.3 白名单,自愈矩阵是设计决策不是实现动作,须主进程全局视角裁定）

### Phase 3: 实现（worktree 串行,S-unit 数按 Phase 2 裁定,预划 4）
<!-- 目标:在 worktree 内落地 S1-S4,每步独立可验收。 -->
- [x] S1-S4 逐项实现(见 S-unit 表),每步完成后跑对应 selftest 子集
- [x] SKILL.md 净增 ≤10 行约束(基线 513 行,条款行数计入预算)
- [x] 全部 S-unit 完成后 `git status` 干净提交(分 S-unit 提交,便于回滚定位)
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete（证据: S1-S4 全 done 各自主进程一手复验 PASS（S1 双向正负例/S2 by_sid 翻转+负例/S3 owner 写入/S4 14+16+18 三套绿）; 9 文件 7 改 2 新; commit 见 wt 分支）
- **Executor:** executor（sonnet-1,worktree 串行）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 哨兵自愈:gate 白名单加 `~/.zcode/cli/memories/**`(修 D-12 本体)+ plan-created.cjs 无 sid env 时兜底清除(清「同仓无对应 active side 指针」或「>24h」的哨兵;护栏:指针存在性校验防误删他会话活跃哨兵) | 继承 | worktree `skills/task-planner/scripts/{check-scope.sh 或 zcode-pretooluse.sh(按 Phase 1 ①), plan-created.cjs}` + Phase 1 checkpoint §①②(v060 缺陷行定位) | 临时目录模拟:env 无 sid 时哨兵被清(有 active 指针的活跃哨兵负例不被清)+ memory 写入放行 + selftest 子集绿 | ≤15min | done（check-scope.sh:63-68+plan-created.cjs:175-212;主进程双向复验 PASS） |
| S2 | tamper 自愈:按 Phase 2 裁定落地——(A) zcode-posttooluse.sh 检测 task_plan.md 被本会话编辑后自动重跑 attest 重锁(仅 sid 匹配才自动,否则维持拒绝);或 (B) attest-plan.sh 加 `--if-mine` 模式 + SKILL 指引 | 继承 | worktree `skills/task-planner/scripts/{zcode-posttooluse.sh, attest-plan.sh, SKILL.md(指引句)}` + Phase 1 checkpoint §④(TAMPERED 检测点+PostToolUse 挂点可行性) | 本 sid 编辑后重锁自动成功(负例:他 sid 编辑仍 TAMPERED 拒绝)+ selftest 子集绿 | ≤15min | done（方案 A' 落地:posttooluse:46-70+attest :68-70 attested_by_sid;主进程 by_sid 翻转+负例复验 PASS） |
| S3 | observe/session-owner 修复+降噪:修 `.session-owner` 首次交互后写入链路(E3 根因)+ delegation-observe 初始化完成前仅首次注入(不每次重跑重活,E4 缓解) | 继承 | worktree `skills/task-planner/scripts/{zcode-userpromptsubmit.sh, observe 注入所在脚本(按 Phase 1 ③⑤)}` + checkpoint §③⑤ | 模拟新会话:owner 写入成功+注入仅一次(代码 diff+实测日志) | ≤15min | done（userpromptsubmit:24-32 env 兜底+check-delegation:260-265 节流+tr 规范对齐;主进程 owner 写入复验 PASS） |
| S4 | SKILL「中断自愈优先」条款 + 新 config 键(如 `hook_self_heal_enforce`,warn 范式,Phase 2 定键名)+ 新建 `selftest-execution-stability.sh` | 继承 | worktree `skills/task-planner/{SKILL.md, config.json, scripts/selftest-execution-stability.sh}` + Phase 2 findings 裁定结论 + checkpoint §⑥(键盘点避撞 28 键) | SKILL 条款净增 ≤10 行 + 新 selftest 可运行全绿 + grep 键名跨文件一致 | ≤15min | done（SKILL:409 净+3+config :111-121 29 键+selftest 14/14;主进程复验 PASS） |

> S-unit 串行顺序 S1→S2→S3→S4(S2 依赖 Phase 2 裁定、S4 依赖前三者稳定后统一挂新键);Phase 2 若裁定需要拆细,在上表追加 S5,不升档。

### Phase 4: 验证
<!-- 目标:全量回归 + 端到端实测 + 一致性 + CR Gate。 -->
- [x] 全量 selftest(基线 12 套件 196 例,0 fail)+ 新 selftest-execution-stability.sh
- [x] hook 端到端实测:模拟非交互清哨兵(VC-1)/tamper 自愈+负例护栏(VC-2)/observe 降噪(VC-3),证据落 `verification.md`
- [x] 跨文件一致性 grep(键名/条款/白名单路径,VC-6)
- [x] Code Review Gate(`code_review: required`)→ APPROVED
- **V-N:** VC-5, VC-6, VC-7
- **Status:** complete（证据: 全量 13 套件 213 例 0 fail; CR 首轮 CHANGES_REQUESTED 2×P0→修复轮 A/B/补修/C/D 全核销→复审 APPROVED; verification.md 7/7 VC）
- **Executor:** code-runner-agent（mini）+ 主进程白名单③(CR 汇总与裁决)

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S5 | 全量 selftest + 端到端实测 + 一致性 grep | 继承(code-runner-agent, mini) | worktree `skills/task-planner/scripts/selftest-*.sh`(全量)+ VC-1/2/3 端到端模拟脚本(临时目录,不污染真实 plans/.plan_required_side)+ grep 清单 | `verification.md` 三节实测证据 + selftest 统计 0 fail + grep 0 不一致 | ≤15min | pending |

> KQ4 口径:hook 行为改动对新会话生效(部署 3 位后),本会话实测仅限临时目录模拟;实测结论按「新会话为准」登记。

### Phase 5: 合并部署交付
<!-- 目标:合并回 master,部署 3 位,清理 worktree,交付报告。 -->
- [x] `smart-merge-back --deploy`(skills 3 实体位:~/.zcode、~/.claude、~/.config/opencode;hook 脚本随位生效于新会话)
- [x] 合并回合约:worktree 内全 Phase complete + VC 逐条复验 + `git status` 干净 + 主仓无重叠未提交变更 + `git merge --no-ff` + Read 关键文件复验
- [x] 清理:worktree remove + branch -d `wt/task-v068-execution-stability`(不留 wt/* 分支)
- [x] 更新隔离决策表 `merge_back=merged(<commit>)` + 交付报告(progress.md + 本计划终验)
- **V-N:** VC-7
- **Status:** complete（证据: merge f783880 + skills 3 位 IDENTICAL（本轮无 agent 改动）+ worktree list 干净 + 主仓复验 17/17 + check-complete exit 0）
- **Executor:** 主进程（例外理由:① git 编排+② 簿记+③ 部署交付——Rule 25.3 白名单,合并回合约本身要求主进程执行)

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（skills 为运行中基础设施,hook 脚本被所有 ZCode 会话实时加载,直接改 = 半残风险;P0-§十一 命中第 1/5 条） |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v068-execution-stability` |
| `branch` | `wt/task-v068-execution-stability`（基于 master 9dacc9d,已建） |
| `merge_back` | `merged(f783880)`（smart-merge-back V1-V6 全 OK + skills 3 位 IDENTICAL + worktree/分支已清理;本轮无 companion agent 改动） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`;并行开发期间遵守 §11.4(禁切主仓分支、禁 reset --hard、只读查询允许)。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | hook 改坏既有拦截链(白名单过宽/重锁时序错),静默放行本应拦截的写入 | 9 | 4 | 6 | 216 | ②拆细+护栏:每 S-unit 独立提交,先跑全量 selftest 196 例 0 fail 再下一步;临时目录负例 smoke(外部篡改/他会话哨兵不得放行);失败 → ⑤ AskUserQuestion 升级或 ④ 主进程接管该 S-unit |
| Phase 3(S2) | 自动重锁被外部篡改滥用:攻击者伪造 sid 触发自动 attest 重锁 | 8 | 3 | 7 | 168 | sid 护栏:重锁前校验编辑会话 sid == attestation sid,负例实测(他 sid 编辑必须仍 TAMPERED);失败 → 降级为 `--if-mine` 手动模式(Phase 2 备选方案) |
| Phase 3(S1) | plan-created 兜底清除误删他会话活跃哨兵 | 8 | 3 | 6 | 144 | 指针存在性校验:仅清「无对应 active side 指针 或 >24h」的哨兵;负例实测(活跃指针存在时兜底不动作);失败 → 收窄兜底为「仅 >24h」单条件 |
| Phase 4 | 部署 3 位 diff 不一致(3 实体位版本漂移) | 5 | 2 | 4 | 40 | 部署后 3 位逐一 `diff -r` 对账,不一致即重部署(≤100,登记不强制) |
| Phase 1 | 勘察遗漏根因(如 E4 与 E3 不同根) | 4 | 3 | 5 | 60 | checkpoint 六项缺项 → 补派 explore 第二轮(≤100,登记) |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填;本表是规划期预演,执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions（Phase 2 已裁定）
1. **KQ1** → 哨兵兜底护栏=「active side 指针不存在 OR mtime>24h」双条件；活跃指针存在且 <24h 不清（负例实测）
2. **KQ2** → **方案 A'：PostToolUse 自动重锁**；护栏=编辑会话 sid==.session-owner（计划认领者）+attestation 补 attested_by_sid；负例（他会话编辑不重锁）必测；失败降级 --if-mine（FMEA 168 兜底）
3. **KQ3** → E4 与 E3 **不同根**（真慢源=Rule 23 O(N) 循环+7 级盲找,勘察⑤）；S3 只修 E3；E4 登记 deferred 本任务不动
4. **KQ4** → hook 改动新会话生效；本会话仅临时目录模拟实测,证据标注「模拟」口径

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 隔离=worktree(不 direct) | skills 为运行中基础设施,§十一 P0 命中;worktree 已建(基于 9dacc9d) |
| Phase 2 由主进程直做 | 设计调度本职,Rule 25.3 白名单②;自愈矩阵需全局视角,不宜降档委派 |
| S-unit 预划 4(S1-S4)+验证 S5 | 单步 ≤2 文件/≤100 行/≤15min;S2 方案二选一留 Phase 2 裁定,不定死改动面 |
| 新 config 键走 warn 范式 | 对齐既有 `vc_gate_enforce` 等键范式,避免 enforce 直上造成新会话行为突变 |
| E5(密集提醒)不做删除只做降噪 | 提醒本身合理(Rule 26.3 机制有效),本任务定位「环境级中断自愈」非「决策停车点」,删提醒 = 超范围 |
| E1 修双层：check-scope 白名单加 memories（gate 本体）+ plan-created 兜底清除 | 勘察①：memories 豁免仅在 check-delegation（另一套机制），哨兵 gate 层缺位才是拦截根因 |
| E2 选 PostToolUse 自动重锁（方案 A'） | 勘察④挂点可行+护栏借 .session-owner；自动重锁仅限计划认领者自己的编辑，外部篡改语义完整保留 |
| E4 不修仅登记 deferred | Rule 23 O(N) 优化=FMEA 216 削链风险 >> 收益；噪声源 E3/E4 叠加中先修 E3 观察残余 |
| S3 顺带对齐 owner tr 规范（'a-zA-Z0-9_-'） | 勘察风险注记 5：sid 含 _- 时 owner 永远 mismatch 的休眠地雷 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| （Phase 1 勘察前无错误;E1-E5 为设计输入,非本任务执行错误） | - | - |

## Notes
<!-- REMINDERS: 随进度更新 phase status;重大决策前重读本计划;所有错误立即登记 -->
- E1-E5 表是设计输入:实现期每步对照根因,禁止改写事件描述
- SKILL.md 513 行基线,本任务净增 ≤10 行——S4 动手前先 `wc -l` 记账
- hook 改动不热加载:Phase 4 实测限临时目录,Phase 5 交付口径见 KQ4
- 3 实体位部署 diff 对账是 VC-7 硬条件,缺一位 = PARTIAL

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 5 |
| 主进程直做 Phase 清单 | Phase 2(例外②设计调度)、Phase 5(例外①③ git 编排+簿记+部署) |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL;预计 3/5=0.6+Phase 4 混合执行,终验时核算） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 00 | 2026-09-14 | plan-writer | 撰写 task-v068 执行稳定性增强计划（覆盖 stub） | done | 5 Phase/S1-S5/7 VC/FMEA 3 行 RPN>100 带 sid 护栏负例实测预演;E1-E5 设计输入表; 主进程 Read 复核通过(注:计划称 worktree 已建系 plan-writer 预写,实际由主进程 Phase 1 前创建) | task_plan.md:107-115,205-212 | E1-E5 表 | plans/task-v068-execution-stability/subagent-state/00-plan-writer.md | | 0 | ☑ |
| 01 | 2026-09-14 | explore | Phase 1 调研：hook 链路六项勘察（哨兵/tamper/observe/慢源/键盘点） | done | 六项根因全落点(E1=check-scope 白名单缺 memories+E1'=plan-created L169-177;E3=userpromptsubmit 无 env 兜底;KQ3 不同根=Rule 23 O(N)); 主进程落盘 checkpoint+findings 回填 | subagent-state/01-explore-hooks.md | Research Findings | plans/task-v068-execution-stability/subagent-state/01-explore-hooks.md | | 0 | ☑ |
| 02 | 2026-09-14 | executor | S1 哨兵自愈：check-scope 白名单加 memories+plan-created 兜底清除 | done | 6/6 含护栏负例 A; 主进程一手复验:memory 放行 exit0+真实 E1 场景清零+活跃指针<24h 保留 | check-scope.sh:63-68, plan-created.cjs:175-212 | [sub:02-executor] S1 产出 | plans/task-v068-execution-stability/subagent-state/02-executor-s1.md | | 0 | ☑ |
| 03 | 2026-09-14 | executor | S2 tamper 自愈：posttooluse 自动重锁+attest attested_by_sid | done | 5/5 含 owner 不匹配负例;顺带修 owner 缺失 tr stderr 缺陷; 主进程一手复验 by_sid SIDA 翻转+负例不变 PASS(依赖 stdin .cwd,生产恒有) | attest-plan.sh:68-70, zcode-posttooluse.sh:46-70 | [sub:03-executor] S2 产出 | plans/task-v068-execution-stability/subagent-state/03-executor-s2.md | | 0 | ☑ |
| 04 | 2026-09-14 | executor | S3 owner env 兜底+observe 节流+tr 规范对齐 | done | 5/5; env-only sid 写 owner 实测(主进程复验 sessTEST123)+节流 run1/run2(执行器)+tr 清单对齐(地雷顺修) | zcode-userpromptsubmit.sh:24-32,106; check-delegation.sh:260-265 | [sub:04-executor] S3 产出 | plans/task-v068-execution-stability/subagent-state/04-executor-s3.md | | 0 | ☑ |
| 05 | 2026-09-14 | executor | S4 SKILL 自愈条款+config hook_self_heal_enforce+selftest-execution-stability | done | SKILL 516 净+3(五机制+键名+护栏+E4 deferred 齐)+config :111-121(29 键)+selftest 14/14(T10 回归哨兵含 v067 机制); 主进程一手复验 PASS | SKILL.md:409, config.json:111-121 | [sub:05-executor] S4 产出 | plans/task-v068-execution-stability/subagent-state/05-executor-s4.md | | 0 | ☑ |
| 06 | 2026-09-14 | executor | CR 修复轮 A：P0-1 重锁路径归一化+P0-2 UPS tr 回归剥除 canon（env 链保留） | done | 6/6 行为级:相对路径重锁 FIXA 落盘+owner 负例不变+canon 逐字节一致+E3 回归; 遗留注记 check-delegation '_-' 反向失配→Fix-B 统一 | zcode-posttooluse.sh:57-69, zcode-userpromptsubmit.sh:34-35,110 | [sub:06-executor] S5a 产出 | plans/task-v068-execution-stability/subagent-state/06-executor-fix-a.md | | 0 | ☑ |
| 07 | 2026-09-14 | executor | CR 修复轮 B：P1-2 同步重锁+P2-1 existsSync 缓存+check-delegation canon 统一 | queued | | | [sub:07-executor] S5b 产出 | plans/task-v068-execution-stability/subagent-state/07-executor-fix-b.md | | 0 | ☐ |
| 2 | | | | | | | | | | 0 | ☐ |
