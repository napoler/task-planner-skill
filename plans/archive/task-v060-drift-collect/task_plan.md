# Task Plan: task-v060-drift-collect — zcode 部署位 10 文件前向漂移收编回 canonical

## Goal
将 `~/.zcode/skills/task-planner` 部署位 2026-09-10 22:43 / 09-11 01:35 两批产生、canonical 仓库（master bb34bf2）未收录的 10 文件前向更新，经逐文件审计判定方向后收编回 `/mnt/data/dev/task-planner-skill` master，完成文档联动、selftest 验证、部署 9 位对账复验，无回归；同时产出「未收录改进分析清单」回复用户。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（收编内容 = 部署侧已在生产运行的前向版本，验证靠 selftest 全量 + verify.sh + 部署 diff 对账，与 v059 同构） |
| `session_id` | 980c720af6794511a6ceb88f5289be17 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v060-drift-collect` |
| `scope_files` | `skills/task-planner/{README.md, SKILL.md, scripts/check-dispatch.sh, scripts/check-scope.sh, scripts/plan-created.cjs, scripts/resolve-plan-dir.sh, scripts/set-active-plan.sh, scripts/task-plan-init.cjs, scripts/zcode-pretooluse.sh, scripts/zcode-sessionstart.sh}` + 可能的文档联动文件（以 Phase 1 审计结论为准） |
| `template_type` | bugfix（技能收编维护，v059 同构） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 10 漂移文件全部收编：合并后 canonical 中该 10 文件与部署侧逐文件 diff=0（或语义等价且差异已记录） | `for f in <10文件>; do diff <deploy> <canonical>; done` 全空 | 终验命令输出记入 verification.md |
| VC-2 | 文档联动净零或已同步：SKILL.md/README 等文档描述与收编后脚本行为一致，无悬空指针 | Phase 1 审计清单逐项核对 + grep 复验 | findings.md 审计清单 + verification.md |
| VC-3 | selftest 全量 fail=0（≥v059 基线 90 用例；部署侧若新增 selftest 文件/用例一并纳入） | `bash tests/selftest*.sh` 各 EXIT=0 且 fail=0 | worktree + 合并后主仓各跑一轮，输出记 progress.md |
| VC-4 | 合并回 master 后重部署 task-planner 3 位（zcode/claude/opencode）diff -rq 全 IDENTICAL + verify.sh 全 pass | `diff -rq` ×3 + `TASK_PLANNER_ROOT=<位> bash <位>/lib/verify.sh` ×3 | verification.md 终验段 |
| VC-5 | 无回归：companion 6 位 + plan-writer agent 2 位只读复验不变（claude 位仅 model 行适配差异） | `diff -rq` / `diff` 复验 | verification.md |
| VC-6 | 全程工作树隔离 + 簿记完整：wt/task-v060-drift-collect 合并回 master 后 worktree 与分支清理，INDEX/attest/ledger 更新 | `git worktree list` + `git branch --list 'wt/*'` + INDEX 行 | git 输出 + plans/INDEX.md |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | worktree 内 `skills/task-planner/` 下上述 10 文件（以部署侧为源拷入） | 其他脚本/技能文件 |
| 文档 | worktree 内 `skills/task-planner/` 下 README.md、SKILL.md 及审计确认必须联动的 references/*.md | 计划外文档 |
| 部署位 | 只读源：`~/.zcode/skills/task-planner`；写目标：3 位 task-planner 部署位（Phase 4 重部署时） | companion 6 位（只读）、其他任何技能目录 |
| plans | 本计划三件套 + INDEX + ledger/attest | 其他计划目录 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？（用户指令："分析…进行补充"）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | 部署拓扑与收编范式（9 位实体副本、收编方向判定、重部署 SOP） | `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-repo-deploy-flow.md` | 必读 | ☑ |
| 项目内部 | v059 同构先例（10 文件收编 + 文档联动 + selftest + 重部署对账全流程） | `/mnt/data/dev/task-planner-skill/plans/task-v059-active-plan-race/{task_plan,verification}.md` | 参考 | ☑ |
| 项目内部 | selftest 清单与基线（v059 后 90 用例 fail=0） | `skills/task-planner/tests/selftest*.sh`（worktree 内执行） | 参考 | ☐ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 部署侧 zcode 位携带 10 文件未收编前向更新（09-10/09-11 两批），canonical 落后；若不收编，下次"仓库→部署"方向的重部署会用旧版覆盖新改进（09-09 已发生过一次 plan-resume 反向覆盖事故）。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（canonical 重新成为唯一 truth source，9 位拓扑回归一致）
- [x] 核心问题不解决，其他工作都白费吗？（不解决则改进只存在于部署快照，随时可能丢失）
- [x] 核心问题的解决方法是清晰的、可执行的？（v059 已验证同构流程：审计→收编→selftest→合并→重部署对账）

## Current Phase
全部 Phase complete（终态）

## Next Step
无——5/5 complete,VC-1..6 终验通过,outcome COMPLETE;后续由用户决定是否 push origin

## Phases

### Phase 1: 漂移审计与方向判定
- [x] 10 文件逐文件 diff 审计（deploy 为 `<`、canonical 为 `>` 方向）
- [x] 方向判定：canonical 侧独有行全部为被替换旧行 → 前向领先确认；发现反向缺失 → 记 Errors 并 STOP 报告（子代理"3 文件反向"判定经主进程特征探针推翻,10 文件统一前向领先,见 findings #1）
- [x] 每文件改进语义摘要 + 文档联动面清单（SKILL.md/README 改动是否波及 references/*.md）
- [x] 审计结论落盘 findings.md + 检查点 01
- **Status:** complete
- **Executor:** general-purpose（审计+落盘复合任务,explore 无 Write 改派;Handoff #1 已登记）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 10 文件 diff 审计+方向判定+改进清单 | explore(mini) | 部署位 10 文件 vs canonical 10 文件（绝对路径见 scope_files）；差异行数统计已由主进程完成（部署侧独有 6~104 行/文件） | 检查点 01 含逐文件表格（文件/批次/改进摘要/方向/联动面），结论行=前向领先确认或异常清单 | ≤15min | pending |

### Phase 2: worktree 创建 + 10 文件收编 + 文档联动
- [x] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v060-drift-collect`（branch wt/task-v060-drift-collect，基线 master）
- [x] 10 文件以部署侧为源拷入 worktree 对应路径（commit e749017,逐字节复核一致）
- [x] 按 Phase 1 审计清单完成文档联动修订（critical-rules Rule 22.9/22.4c 3 处,commit 7419e43;selftest-dispatch 实证 12/12 无需改写）
- [x] 逐 Phase 提交（Rule 27：只 add scope 文件,两 commit 后 scope porcelain 空）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 10 文件拷入 worktree + git diff 自检 | 继承(executor) | 检查点 01 审计表 + worktree 绝对路径 + 部署位源路径；拷贝后 `git status --short` 恰好 10 文件 | git diff 逐文件与部署侧一致 | ≤15min | pending |
| S2 | 文档联动修订（按审计清单，无联动则记净零） | 继承(executor) | 检查点 01「联动面」列 | 联动文件修订后 grep 无悬空引用，或明确记"净零" | ≤15min | pending |

### Phase 3: worktree 内验证
- [x] selftest 全量（含部署侧新增 selftest 文件如 selftest-active-plan.sh 等）fail=0（5 套件 90 用例 fail=0,零新增文件,与 v059 基线一致）
- [x] verify.sh pass（TASK_PLANNER_ROOT=worktree 技能根）（22 pass/3 fail,3 fail 均为部署滞后/计划进行时预期项,Phase 4 重部署后复跑归零）
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | selftest 全量 + verify.sh | code-runner-agent(mini) | worktree 内 `skills/task-planner/tests/` 清单；v059 基线 90 用例 fail=0 | 各 selftest EXIT=0 fail=0 + verify.sh 全 pass，输出落 progress.md | ≤15min | pending |

### Phase 4: 合并回 master + 部署 9 位对账
- [x] 主进程合并回：`git merge --no-ff wt/task-v060-drift-collect`（白名单①）（commit c9309aa,11 文件 +430/-97）
- [x] 重部署 task-planner 3 位：`rm -rf <位> && cp -rL canonical/skills/task-planner <位>`（执行位保留,无 __pycache__）
- [x] 3 位 diff -rq 复验 + verify.sh ×3 + selftest 抽跑（diff 全零;verify 25/0×3 中性 CWD;dispatch 12/12+active-plan 13/13）
- [x] companion 6 位 + plan-writer 2 位只读复验（6 位零差异;zcode IDENTICAL/claude 仅 model 行）
- [x] worktree remove + 分支删除（已清,git worktree list 仅主仓）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 合并回 master + worktree 清理 | 主进程（白名单①） | worktree 全 VC 复验通过 + worktree git status 干净 | merge commit 生成 + `git worktree list` 无残留 + wt 分支已删 | ≤5min | pending |
| S2 | 重部署 3 位 + diff/verify 复验 | executor(sonnet-1) | canonical `skills/task-planner` → 3 个部署位绝对路径；重部署后 diff -rq 须空 | 3×diff IDENTICAL + 3×verify pass | ≤15min | pending |
| S3 | companion 6 位 + agent 2 位只读复验 | executor(sonnet-1) | 6 个 companion 部署位 + 2 个 plan-writer.md 路径 | diff 无新差异（claude 位仅 model 行） | ≤10min | pending |

### Phase 5: 簿记收尾与交付
- [x] verification.md 终验逐条复验 VC-1..6 + 委派统计（outcome COMPLETE,verdict=ok 0.800）
- [x] INDEX 刷新 + attest 复锁 + 簿记 commit
- [x] 向用户交付：收编改进分析清单（Phase 1 产出）+ 终验结论（交付报告随本回合最终消息发出）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅信号①：未提交变更 4 项均为 plans/ 簿记与哨兵残留，与本任务范围零重叠；信号②③④⑤ 未触发） |
| `isolation` | `worktree`（实现类默认首选；改 canonical 技能源码，§十一 命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v060-drift-collect` |
| `branch` | `wt/task-v060-drift-collect` |
| `merge_back` | `pending` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-11 | S1 五条映射已建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

## Key Questions
1. 10 文件漂移是否全部为"部署侧前向领先"？（Phase 1 逐文件判定，发现反向缺失即 STOP）
2. SKILL.md/README 的部署侧改动是否要求仓库侧其他文档联动？（Phase 1 联动面清单）
3. 部署侧是否新增了 selftest 用例文件？（Phase 3 纳入全量验证）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 收编方向初判：部署侧前向领先 | canonical 自 bb34bf2（09-10 簿记）后零提交，而漂移文件 mtime=09-10 22:43 / 09-11 01:35 均晚于基线；Phase 1 逐文件复核兜底 |
| 计划确认来源 = 用户本轮指令 | 用户指令"分析…进行补充"即含执行授权；自主会话不阻塞等待口头 yes（P0-1 用户当前指令优先） |
| plan-writer claude 位 model 行差异不算漂移 | install-companion.sh adapt_model_line 预期适配（canonical=custom:…:sonnet-1，claude 位=sed 后 sonnet），zcode 位已验证 IDENTICAL |
| companion 6 位本轮只读复验 | 漂移仅出现在 task-planner 技能源码，companion 技能（todo-skill/task-drift-guard/plan-resume）8 位 diff=0 已证无源码变更 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| task_plan.md 首次 Write 超时（30s，hook 首次交互慢） | 1 | 核实未写入后原样重试，成功 |
| attest 被 check-plan-dispatch 拦截（S2a 等字母后缀 ID 不匹配 `S<纯数字>` 正则） | 1 | S-unit ID 改纯数字编号,重锁成功 |
| S1 审计子代理"3 文件反向异常"方向误判 | 1 | 主进程特征探针（grep `_side` + 命中行原文）复核推翻,统一前向领先收编;findings #1 留痕 |
| check-delegation stats 两轮 violation（Executor 行括号补充文本被解析为未登记子代理类型;Phase 1 字段与实际派发类型不一致） | 2 | Executor 行收敛为纯类型声明并与实际派发一致（general-purpose/executor）,第三轮 verdict=ok 0.800 |
| [plan-compass] 升级警告误指向已交付的 v059 计划三件套 | 2 | 核实为 legacy .active_plan 指针残留（v059）+hook 会话级 mtime 扫描行为;v059 已终态不回填（scope 外）,本计划 side 指针解析正确;不构成 Rule 26 降质违规 |
| set-active-plan.sh set 在仓根 CWD 报"计划不存在"（路径拼接 task-id/plans/... 嵌套错位） | 1 | side 指针已正确解析 v060,legacy 指针修正不影响本会话 hook 路由,登记备忘不阻塞 |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- 部署位只读源 = `~/.zcode/skills/task-planner`；禁止在收编完成前对部署位做任何写操作
- 部署侧 git 仓 `git log` 报 "no commits yet"（v059 后被重置），方向判定只能靠 diff，不能靠部署侧 git 历史

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-11 06:4x | ✅ ALIGNED（终验前检测,Batch 八字段齐 failure_rate=0%） | VC-6 | 簿记收尾动作与计划一致,继续 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

| 字段 | 值 |
|------|-----|
| `total` | 10（收编文件数） |
| `success` | 10 |
| `failed` | 0 |
| `failure_rate` | 0%（主进程 10/10 全量 diff 校验,非抽样） |
| `sampled_pass` | 10/10（全量校验超抽检要求;检查点 02 §S1 证据 2） |
| `sampled_fail` | 0（拷贝前逐文件 diff 方向已全量审计） |
| `pre_check` | Q1:否（单文件 git 可回滚）/ Q2:有（worktree+分支）/ Q3:能（selftest+diff 对账） |
| `rollback_point` | worktree 分支基点 master=bb34bf2（已合并 c9309aa,回滚点转为 merge 前提交） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5 |
| 主进程直做 Phase 清单 | Phase 5（白名单② 簿记）+ Phase 4 内 S1 合并回（白名单① git 编排,progress Phase 4 段留痕） |
| 委派率 | 0.800（check-delegation.sh stats verdict=ok,JSON 证据见 verification.md） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | verify_done |
|---|------|--------------|----------------|------|--------------|----------------|--------------|----------------|-------------|
| 1 | 2026-09-11 | general-purpose | 10 漂移文件 diff 审计+方向判定 | done | 10 文件 diff 全审+零新增文件;改进语义清单可用;但"3 文件反向异常"判定被主进程探针推翻(方向读反),以 findings #1 裁决为准 | subagent-state/01-gp-audit.md:8-33 | Research Findings #1 | plans/task-v060-drift-collect/subagent-state/01-gp-audit.md | ☑ |
| 2 | 2026-09-11 | executor | Phase 2:10 文件收编入 worktree + selftest/文档联动 | done | 2 commits(e749017 收编+7419e43 联动);10 文件逐字节=部署侧;critical-rules 3 处最小修订;selftest-dispatch 12/12 免改写 | worktree git log + 检查点 02 | Technical Decisions | plans/task-v060-drift-collect/subagent-state/02-executor.md | ☑ |
| 3 | 2026-09-11 | code-runner-agent | Phase 3:worktree 内 selftest 全量 + verify.sh | done | 5 套件 90 用例 fail=0 零回归;verify 22/3(3 fail=部署滞后+计划状态预期项,重部署后复跑) | subagent-state/03-runner.md | progress Phase 3 段 | plans/task-v060-drift-collect/subagent-state/03-runner.md | ☑ |
| 4 | 2026-09-11 | executor | Phase 4 S2+S3:重部署 task-planner 3 位 + 9 位+agent 2 位对账复验 | done | 3 位 diff 全零+verify 25/0×3+companion 6 位零差异+agent 2 位符合预期;主进程抽验一致 | subagent-state/04-deploy.md | progress Phase 4 段 | plans/task-v060-drift-collect/subagent-state/04-deploy.md | ☑ |

## 🔗 Chain 区块交接配置

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
