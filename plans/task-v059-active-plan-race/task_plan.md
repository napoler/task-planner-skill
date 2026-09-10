# Task Plan: task-v059-active-plan-race — 收编 zcode 部署侧两处未入库更新回 canonical

## Goal
将 `~/.zcode/skills/task-planner` 侧 2026-09-10 产生、canonical 仓库未收录的 2 处更新（① active-plan-race 会话私有指针注册表 ② check-complete Rule 25.4 白名单豁免）以 10 文件全量拷入 + 三件套文档净零联动收编回 `/mnt/data/dev/task-planner-skill` master，并在部署 9 位完成重部署对账（task-planner 3 位 diff=0），无回归。

## 用户原话（P0-1 复述）
"我在其他的，就是说在 zcode 中更新了新版本内容，没有被当前项目收录，我希望可以收录回来。"

## 现状核实（2026-09-10，diff 方向：zcopy 比仓库新）
- `diff -rq` 排除 `.git` 后恰好 10 文件 differ，无其他杂音；10 文件仓库侧独有行 0-29 条（多为被替换的旧注释/旧逻辑行，逐文件 diff 已核，全部属预期变更）
- `~/.zcode/skills/task-planner` 自带 git：`e429b5a` baseline + `6685a93` active-plan-race（工作区干净）；check-complete.sh 的白名单块**未入该仓 git**（属部署侧直接改动）
- zcopy 的 check-complete.sh 保留 v058 check-plan-dispatch 门控（grep 命中 2 处），收编方向是前向的，无倒退风险

## 收编内容（两项）
1. **active-plan-race 会话私有指针注册表**（zcopy git 6685a93，9 文件）：`plans/.active_plan_side/<sid>.active_plan` 会话层 + legacy 全局层兜底；`resolve-plan-dir.sh` 新增第 2 可选参 SID；`set-active-plan.sh` 重写（set/gc/--show，原子 mktemp+mv）；init-session/UserPromptSubmit 按 CLAUDE_CODE_SESSION_ID 分支；4 个 zcode-*.sh hook 传 SID；check-dispatch 传 TASK_PLANNER_SID。根因：全局单文件指针被并行会话后写者赢互顶，09-09 实锤 7 次 [dispatch-block] 误拦。
2. **check-complete.sh Rule 25.4 白名单豁免**（zcopy 侧直接改动，未入 git）：rate < floor 时 main_direct 全空或每条 reason 命中白名单关键词 → 放行（DELEGATION RATE WHITELIST-EXEMPT 标记）；任一未命中保持 FAILED；jq 缺失 fail-closed 不放行。

## 附带事项（主进程直做，不在 worktree 范围）
- 主树 `plans/` v058 交付后残留簿记（INDEX 翻 complete、.active_plan 指针、.plan-attestation、ledger）已单独 commit `d3f44f0` 入 master（纯计划簿记，§十一 11.5 例外 2），避免 worktree 合并冲突。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 10 文件收编落盘且零差异 | worktree 内 `diff -rq` zcopy↔worktree/skills/task-planner -x .git 仅剩 .git 噪音 | 命令输出 0 differ |
| VC-2 | 既有 selftest 无回归 | worktree 内 selftest-dispatch / selftest-delegation / selftest-plan-dispatch / selftest-fallback 全过 | exit 0 + pass 计数 |
| VC-3 | zcopy 自带测试过 | zcopy git 6685a93 提交信息声称的 selftest（含新写自测）在 worktree 内可复跑全过 | 命令输出 |
| VC-4 | 三件套/README 文档对齐净零 | 新增机制在 README/INSTALL/SKILL/references 有对应说明且无悬空指针 | grep 命中 |
| VC-5 | 部署重部署后 task-planner 3 位 diff=0 | zcode/claude/opencode 3 位 rm+cp -rL + `diff -rq -x .git` | 3×diff 输出 |
| VC-6 | worktree 合并+清理 | `git merge --no-ff` 入 master + `git worktree remove` + `git branch -d`，master `git status` 干净 | git 命令输出 |
| VC-7 | 白名单豁免逻辑行为正确 | check-complete 在白名单内理由场景放行 / 非白名单场景保持 FAILED（构造用例跑） | 命令输出 |

**终验规则**：全部 VC → COMPLETE；≥1 VC 失败且重试 3 次无效 → BLOCKED 升级用户。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | worktree `skills/task-planner/scripts/{check-complete.sh, check-dispatch.sh, init-session.sh, resolve-plan-dir.sh, set-active-plan.sh, zcode-posttooluse.sh, zcode-pretooluse.sh, zcode-sessionstart.sh, zcode-userpromptsubmit.sh}` | 其他 scripts |
| 文档 | worktree `skills/task-planner/{README.md, INSTALL.md, SKILL.md, references/**}`（净零联动最小改） | 其他文档 |
| 测试 | 按需新增 `skills/task-planner/scripts/selftest-active-plan.sh` 等 + 既有 4 selftest 可重跑 | 其他测试 |
| 计划 | 本任务三文件 + plans/INDEX.md + .active_plan | — |

**执行前自我检查**: worktree 内只动上表；部署 3 位只 rm+cp -rL 整目录快照，不逐文件手术；不动 companion/ 与 plan-writer agent 2 位（无内容变更）。

## 📚 必要知识储备
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档/知识库 | 部署拓扑 9 位 + 重部署 SOP + verify.sh 用法 | memory `task-planner-repo-deploy-flow` | 必读 | ☑ |
| 项目内部文档/知识库 | 待收编源码 | `~/.zcode/skills/task-planner`（git 6685a93 + 未提交白名单块） | 必读 | ☑ |
| 项目内部文档/知识库 | worktree 生命周期 SOP | `skills/task-planner/references/worktree-isolation.md` | 参考 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 部署侧 zcopy 领先仓库的 2 项更新（竞态根治 + 白名单豁免）收编回 canonical 且全链（文档/测试/部署 9 位）无回归。
- [x] 核心问题解决后可交付（仓库=部署源恢复一致）
- [x] 不解决则并行会话误拦问题持续 + 下次全量部署会把白名单豁免覆盖丢
- [x] 方法清晰：10 文件全量拷入 + 净零文档联动 + selftest 回归 + 重部署 3 位 + 9 位对账

## 执行体决策
各 Phase Executor 已写入 Phases 段；主进程直做项均写例外理由；Executor≠主进程的 Phase 附 S-unit 表（Rule 22.6）。

## Current Phase
Phase 4

## Next Step
Phase 5: 主进程 commit 收编+文档+测试改动 → git merge --no-ff wt/task-v059-active-plan-race 入 master → 清理 worktree

## 排查记录（2026-09-10 会话内发生，非收编内容）
- 现象：会话早期 3 次 Agent() 派发被 [dispatch-block] 误拦（旧版 hook 链路：主仓旧 resolver + 主仓 .active_plan 指向 v058，prompt 指向 worktree 计划目录 → 三文件缺项）。根因=本任务要收编的 active-plan-race 缺陷实锤（全局指针+无 sid 解析）
- 处置：主仓 plans/task-v059-active-plan-race 建为指向 worktree 计划目录的符号链接（主仓 git 仅跟踪该链接文件，worktree 内三文件为实体）；set-active-plan.sh set --sid 980... 写主仓 side 指针；主仓 legacy .active_plan 改指 task-v059-active-plan-race。旧 hook 链路复测 CHECK_EXIT=0；新 zcopy 链路复测 PRETOOL_EXIT=0。两链路均放行

## Phases

### Phase 1: 收编落盘（worktree 内 10 文件全量拷入 + 对账）
- Executor: 主进程直做 — 例外理由：单目录 cp 批量文件操作 + 逐项 diff 对账，trivial 机械操作，材料已在本会话 Read 过（10 文件逐文件 diff 已核）
- S-units:
  | ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
  |----|------------|--------|------|------|----------|------|
  | P1-S1 | 10 文件全量拷入 worktree | 继承 | 材料包：`/home/terry/.zcode/skills/task-planner/{README.md, scripts/9 个 sh}` 逐文件 cp -f 至 worktree 对应路径；本计划文件 | `diff -rq -x .git` zcopy↔worktree 0 differ | 5min | complete |
  | P1-S2 | 三件套登记 + git status 范围确认 | 继承 | 材料包：worktree `plans/task-v059-active-plan-race/{findings,progress}.md` 回填 Phase 1；`git status --short` | 仅 skills/task-planner 10 文件 + 计划三文件 modified，无越界 | 5min | complete
- 验收: VC-1 ✓ (diff -rq EXIT=0)
- 状态: complete（2026-09-10，diff -rq -x .git 0 differ，证据见 findings.md Phase 1 段）

### Phase 2: 回归与新增测试
- Executor: executor — 机械跑 4 既有 selftest + 构造白名单豁免行为用例（VC-7），步骤明确可照单执行
- S-units:
  | ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
  |----|------------|--------|------|------|----------|------|
  | P2-S1 | 4 既有 selftest 全过（dispatch/delegation/plan-dispatch/fallback，在 worktree 跑） | 继承 | 材料包：worktree 路径 + 各 selftest 脚本名；checkpoint 路径 `plans/task-v059-active-plan-race/subagent-state/02-executor.md` | 4×exit 0 + pass/fail 计数（fail=0） | 10min | complete |
  | P2-S2 | VC-7 白名单豁免行为验证（白名单内理由放行 / 非白名单保持 FAILED / jq 缺失 fail-closed 三用例，构造假 ledger 跑 check-complete 25.4 段） | 继承 | 材料包：同 02-executor.md + check-complete.sh 白名单段逻辑（reason 关键词 grep 白名单[①②③④⑤⑥] 等） | 三用例行为与 25.4 语义一致，输出含 EXEMPT 或 FAILED 对应标记 | 10min | complete |
- 验收: VC-2 VC-3 VC-7
- 状态: complete（2026-09-10，4 selftest 全 exit 0 共 77 用例 fail=0；VC-7 三用例 3/3 一致，判定命令与证据见 findings.md Phase 2 段 + 02-executor.md）

### Phase 3: 文档净零联动
- Executor: Code Assistant — 小范围文档编辑（README/INSTALL/SKILL/references 补 active-plan-race 与 25.4 白名单说明，各 ≤15 行净零原则），≤3 文件硬限制内
- S-units:
  | ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
  |----|------------|--------|------|------|----------|------|
  | P3-S1 | README set-active-plan.sh 行描述对齐 zcopy 版（zcopy README 已含该改动，拷入后核对） + INSTALL/SKILL/references 补 active-plan-race 机制说明（.active_plan_side 会话层+legacy 兜底+gc） | 继承 | 材料包：zcopy 6685a93 提交说明 + worktree 当前文档现状 diff；checkpoint `plans/task-v059-active-plan-race/subagent-state/03-code-assistant.md` | grep `.active_plan_side` 在 README/SKILL/references 命中≥1；无悬空指针 | 15min | complete |
  | P3-S2 | check-complete 25.4 白名单豁免在 critical-rules.md / SKILL.md 摘要有对应（净零，改摘要不扩篇幅） | 继承 | 材料包：同 03-code-assistant.md + check-complete.sh 白名单块注释（2026-09-09 D6 / Rule 25.4 依据 critical-rules 25.4） | grep `WHITELIST-EXEMPT\|白名单豁免` 在 references/critical-rules.md 或 SKILL.md 命中 | 10min | complete
- 验收: VC-4 ✓ (grep 全过)
- 状态: complete（2026-09-10，README:94/SKILL:64,150/critical-rules:139+171/INSTALL:183 净零 +7/-3，证据见 findings.md Phase 3 段 + 03-code-assistant.md）

### Phase 4: 测试补件（active-plan-race 自测收编/适配）
- Executor: Test Engineer — zcopy 提交声称 4 selftest 97/97；核实其自测脚本是否已随 10 文件带过来（若未带则按 worktree 现有 selftest 范式补 hermetic 用例），步骤明确
- S-units:
  | ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
  |----|------------|--------|------|------|----------|------|
  | P4-S1 | 核实 zcopy 自测（4 selftest 97/97 指哪些脚本）在 worktree 可复跑；缺的自测（如 resolve-plan-dir side 指针 TTL/gc）补 hermetic 用例 | 继承 | 材料包：zcopy git log 6685a93 自测段 + worktree scripts/selftest-*.sh 现状；checkpoint `plans/task-v059-active-plan-race/subagent-state/04-test-engineer.md` | worktree selftest 全集跑通，含 side 指针新行为覆盖 | 15min | complete
- 验收: VC-2 VC-3
- 状态: complete（2026-09-10，新增 selftest-active-plan.sh 13/13 全过 + 既有 4 selftest 复跑全过，130 用例 fail=0，判定命令与证据见 findings.md Phase 4 段 + 04-test-engineer.md）

### Phase 5: worktree 合并回 master
- Executor: 主进程直做 — 例外理由：git 合并仪式（merge --no-ff + 清理），单命令序列
- 前置: Phase 1-4 全 complete + worktree `git status` 干净（先 commit 收编 + 文档 + 测试改动）
- 步骤: commit → `git merge --no-ff wt/task-v059-active-plan-race`（master）→ Read 关键文件 + git log 复验 → `git worktree remove` + `git branch -d`
- 验收: VC-6
- 状态: pending

### Phase 6: 部署重部署 3 位 + 9 位对账
- Executor: 主进程直做 — 例外理由：部署 SOP 为固定命令序列（memory 明文：rm+cp -rL + diff -rq），trivial 可逆
- 步骤:
  1. task-planner 3 位：`rm -rf ~/.zcode/skills/task-planner ~/.claude/skills/task-planner ~/.config/opencode/skills/task-planner && cp -rL <master>/skills/task-planner <位>`
  2. 3 位 `diff -rq -x .git` vs master 0 differ（VC-5）；注意 zcopy 位原自带 .git 仓，rm 后消失=预期（部署位不保留 git）
  3. 其余 6 位只读 `diff -rq` 复验（companion/plan-writer 无内容变更，应 diff=0）
  4. `TASK_PLANNER_ROOT=<位> bash <位>/lib/verify.sh` 3 位全过（VC 附加证据）
  5. plans/INDEX.md 翻 complete + 本任务三文件收尾
- 验收: VC-5 VC-6
- 状态: pending

## 风险与回滚
- 风险 1: 10 文件 cp 覆盖后仓库侧其他脚本调用 set-active-plan.sh 旧签名（位置参数）→ 白名单：zcopy 已做 set/global 位置参数兼容，P2 selftest 覆盖；回滚 = revert 本任务 commit
- 风险 2: check-complete 白名单块依赖 jq，无 jq 环境 fail-closed（保持旧行为），无回归面
- 回滚总纲: 本任务独立 commit 序列，`git revert -m 1` merge 即可全退；部署位重部署前留有当前 zcopy 快照可回拷
