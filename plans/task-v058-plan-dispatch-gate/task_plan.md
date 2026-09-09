# Task Plan: task-v058 计划期子代理规划门控 — S-unit 执行体列 + check-plan-dispatch 机械校验

## Goal
让"用子代理处理任务"在**计划阶段**就被明确写出并被机器校验：S-unit 表新增「执行体」列（每步声明 subagent_type(model)），新增 `check-plan-dispatch.sh` 在计划锁定（attest）与终验（check-complete）两处强制校验"派发型 Phase 必附带执行体的 S-unit 表"——补齐 v056/v057 只有文本约束的缺口；完成后部署 9 位并 push GitHub。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新增 shell 脚本 + attest/check-complete 接入） |
| `session_id` | sesse6240c6794f0479b9803f00676539b6b |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v058-plan-dispatch-gate` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`, `skills/task-planner/templates/task_plan.md`, `skills/task-planner/companion/agents/plan-writer.md`, `skills/task-planner/scripts/check-plan-dispatch.sh`, `skills/task-planner/scripts/selftest-plan-dispatch.sh`, `skills/task-planner/scripts/attest-plan.sh`, `skills/task-planner/scripts/check-complete.sh`, `skills/task-planner/SKILL.md`, `skills/task-planner/INSTALL.md` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 22.6 S-unit 表定义含「执行体」列（默认继承 Phase Executor，可逐行覆盖）；25.1 联动"每行执行体非空"；模板 task_plan.md 与 plan-writer.md 的 S-unit 表头同步为 7 列 | grep | critical-rules.md / templates/task_plan.md / plan-writer.md |
| VC-2 | `scripts/check-plan-dispatch.sh <task_plan.md>`：派发型 Phase（Executor≠主进程）缺 S-unit 表 / 数据行为 0 / 任一行执行体为空 → stdout 列违规 + exit 1；全合规 exit 0；主进程 Phase 不要求表；解析异常 exit 0（fail-open） | selftest ≥6 用例全过 | scripts/selftest-plan-dispatch.sh |
| VC-3 | attest-plan.sh 锁定前调用 check-plan-dispatch（exit 1 → 打印违规并拒绝锁定，`--skip-dispatch-check` 可跳过且 stderr 告警）；check-complete.sh 终验调用（exit 1 → 阻断，与委派门控同级） | 手测 + selftest | attest-plan.sh / check-complete.sh |
| VC-4 | SKILL.md 净零 500 行、P0 不减：「计划确认」步与 Rule 25 摘要提及 check-plan-dispatch；INSTALL 记一句 | wc/grep | SKILL.md / INSTALL.md |
| VC-5 | 本计划自身（v058）的 S-unit 表带执行体列且 `check-plan-dispatch.sh` 对本计划 exit 0（dogfood）；对旧计划 v056 exit 0 且打印「legacy plan 跳过」说明行（旧计划无执行体标记 = 向后兼容，不因新门控回退已交付计划）；对"含执行体标记但派发型 Phase 缺表"的夹具 exit 1（检出能力） | 命令 | 本目录 task_plan.md / plans/task-v056-…/task_plan.md / selftest 夹具 |
| VC-6 | selftest-delegation 38 / selftest-dispatch 12 / selftest-fallback 21 / selftest-plan-dispatch 全过；verify.sh 仅 drift；Code Review APPROVED | 命令 | progress |
| VC-7 | merge master → 部署 9 位 diff 总计 0 + verify 25/0 ×3 + agent 副本 → `git push origin master` 成功且 origin/master = HEAD | 命令 | progress Phase 6 |

**终验规则**：全部 VC 通过 → COMPLETE；VC-7 push 失败 → PARTIAL；≥1 VC 失败 3 次 → BLOCKED。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则/模板/agent | critical-rules.md（22.6/25.1 行内）、templates/task_plan.md（S-unit 表头 + 头注）、plan-writer.md（契约/骨架/证据 3 处） | variant/*、其他 references |
| 脚本 | check-plan-dispatch.sh（新）、selftest-plan-dispatch.sh（新）、attest-plan.sh（接入 ≤15 行）、check-complete.sh（接入 ≤15 行） | 其他 scripts |
| 文档 | SKILL.md（净零）、INSTALL.md（≤3 行） | — |
| 部署/发布 | 9 位 rm+cp -rL、agent 副本 2、push origin master | 不动 origin/main |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | 现状核实（缺口 2 项） | findings R1 | 必读 | ☑ |
| 项目内部 | attest-plan.sh 结构（mode 解析 :20；写 .plan-attestation） | scripts/attest-plan.sh:1-30 | 必读 | ☑ |
| 项目内部 | check-complete.sh 门控段（Rule 27.3 预检 :14；委派门控 ~:396-425） | scripts/check-complete.sh | 必读 | ☑ |
| 项目内部 | task_plan 解析陷阱（awk 区间 bug → 状态机式） | memory task-planner-awk-scope-extraction-bug | 必读 | ☑ |
| 项目内部 | 部署拓扑 9 位 + agent 2 位 + 发布教训 | memory task-planner-repo-deploy-flow | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: "计划期规划子代理"目前是文本规则（22.6/25.1）——没有执行体列可写、没有脚本在计划锁定时校验；v055-v057 反复证明纯文本约束不被遵守。解决 = 结构（执行体列）+ 机制（attest/终验双门控）。

**核心问题判断**:
- [x] 解决后能交付（计划锁定前即拦住"没规划子代理"的计划）
- [x] 不解决其他工作白费（v056 步级拆分、v057 派发契约的前提都是计划里真的写了子代理步骤）
- [x] 方法清晰（bash 解析 Phase 段 + 表格行，状态机式，≤150 行）

## 设计方案

### D1 S-unit 表加「执行体」列
表头统一为：`| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |`。执行体可写 `继承`（= Phase Executor）或具体类型（如 `explore(mini)` / `executor(sonnet-1)`）；Phase Executor 仍必填作为默认。Rule 22.6 文案、模板 Phase 3 示范、plan-writer 骨架/契约/证据要求同步。

### D2 check-plan-dispatch.sh（计划期机械校验）
`bash check-plan-dispatch.sh <task_plan.md>`：状态机逐行扫描——`### Phase N:` 开段；段内读 `- **Executor:**`（含"主进程"= 免检）；段内找 S-unit 表头（`| ID |` 且含 `执行体`）→ 计数数据行（`| S\d+ |`）并检查执行体列非空（非空白且非 `|`）；输出每条违规 `[plan-dispatch] ✗ Phase N: <缺 S-unit 表 | 表无执行体列 | 数据行 0 | 行 Sx 执行体为空>`；有违规 exit 1；全合规打印 ✓ 行 exit 0；文件不存在/无 Phase → exit 0（fail-open）。
**legacy 兼容（Phase 3 设计补充）**：计划全文无"执行体"字样 = 旧模板计划 → 打印 `[plan-dispatch] legacy plan（无执行体列），跳过门控` 并 exit 0（已交付计划不因新门控回退）；有执行体标记则全量严格校验。attest 锁定与 check-complete 终验共用该判定。
接入：attest-plan.sh 锁定模式（默认）先跑校验，exit 1 → 打印违规 + `[attest] ✗ 拒绝锁定：派发型 Phase 未规划子代理（Rule 22.6/25.1）` exit 1；`--skip-dispatch-check` 跳过并 stderr 告警。check-complete.sh 在委派门控段之后调用，exit 1 → `[plan] PLAN-DISPATCH GATE FAILED` exit 1。

### D3 selftest-plan-dispatch.sh（≥6 用例）
合规 / 缺表 / 无执行体列 / 数据行 0 / 某行执行体空 / 主进程 Phase 无表合规 / 文件不存在 fail-open / attest --skip 告警。

### D4 SKILL.md 净零 + INSTALL
「计划确认」步一句：attest 前 `check-plan-dispatch.sh` 校验；Rule 25 摘要一句。INSTALL §5.1a 后补一行。

### D5 发布
merge → 9 位部署（先 diff 看方向）→ verify → push origin master。

### 明确不做
不改 check-delegation stats 的归属算法；不回填 v056/v057 旧计划的执行体列（历史计划只读）；不做 S-unit 级委派率统计（后续）。

## Current Phase
Phase 3

## Next Step
派发 P3-S1（新建 check-plan-dispatch.sh，含 legacy 兼容判定）→ S2（attest/check-complete 接入）→ S3（selftest ≥6 用例）

## Phases

### Phase 1: 核实 + 计划
- [x] 核实缺口 2 项（findings R1）
- [x] 用户确认（09-09 yes；明示指令：改完后部署到各平台 + push GitHub）
- **Status:** complete（2026-09-09）
- **Executor:** 主进程（例外理由:② 计划系统文件维护 + ③ 只读 grep——Rule 25.3 白名单）

### Phase 2: 规则 + 模板 + plan-writer（worktree）
- [x] S-unit 全部 complete（3/3 并行；worktree commit ef8b24b）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|------------------------|-------------|---------|------|
| S1 | 22.6 文案加执行体列定义 + 25.1 加"每行执行体非空 + check-plan-dispatch 校验"联动（行内） | executor(sonnet-1) | critical-rules.md:131,166 + D1/D2 | grep "执行体" 22.6/25.1 各 ≥1 | 10min | pending |
| S2 | 模板 task_plan.md S-unit 表头改 7 列 + 示范行 + Phases 头注一句 | executor(sonnet-1) | templates/task_plan.md:130,173-177 + D1 | 表头含"执行体"；`grep -c "^| ID |"` = 1 | 10min | pending |
| S3 | plan-writer.md 骨架表头 7 列 + 产出契约列名 + 证据要求"每 S-unit 执行体已填" | executor(sonnet-1) | plan-writer.md:107,154-157,207 + D1 | grep -c "执行体" ≥ 3；frontmatter 不动 | 10min | pending |

### Phase 3: 校验脚本 + 接入 + selftest（worktree）
- [x] S-unit 全部 complete（S1 131 行 / S2 接入 / S3 selftest 6/6；commit d3d7da3 + a13a9a1 + bcc81ea）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|------------------------|-------------|---------|------|
| S1 | 新建 check-plan-dispatch.sh（≤150 行，bash while-read 状态机，fail-open，D2 规格含 legacy 兼容判定） | executor(sonnet-1) | D2 + memory awk 陷阱（用 bash 不用 awk 区间） | 对本计划 exit 0；对 v056 计划 exit 0 且打 legacy 说明；对缺表夹具 exit 1 | 15min | pending |
| S2 | attest-plan.sh 锁定前接入（≤15 行，`--skip-dispatch-check`）+ check-complete.sh 委派门控后接入（≤15 行） | executor(sonnet-1) | attest-plan.sh:15-30 / check-complete.sh 委派段 + D2 | 手测：违规计划 attest exit 1；--skip 告警后锁定；check-complete 集成 | 15min | pending |
| S3 | 新建 selftest-plan-dispatch.sh（≤6 用例/步：本步 6 用例 + 汇总行） | executor(sonnet-1) | selftest-dispatch.sh 风格 + D3 | `Total: N PASS=N FAIL=0` | 15min | pending |
| S4 | selftest 补 2 用例（attest --skip 告警 / check-complete 集成）— 若 S3 已含则本步取消并记行 | executor(sonnet-1) | S3 产物 | 8/8 | 10min | pending |

### Phase 4: SKILL.md 净零 + INSTALL（worktree）
- [x] S-unit 全部 complete（主进程白名单②直做；commit 038eaa8）
- **Status:** complete（2026-09-09）
- **Executor:** executor(sonnet-1) → **主进程直做（执行中新增例外，C14 回填登记：② 计划系统文件维护 + 文档 ≤6 行——Rule 25.3 白名单；理由：SKILL/INSTALL 各 1-2 行行内 Edit，派 executor 的读文件成本 > 改动本身，P4 已 complete 后补记）**

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|------------------------|-------------|---------|------|
| S1 | SKILL.md「计划确认」步 + Rule 25 摘要行内加 check-plan-dispatch（净零）；INSTALL 5.1a 后 +1 行 | executor(sonnet-1) | SKILL.md 计划确认段/Rule 25 行；INSTALL:182 | wc -l 500；grep check-plan-dispatch ≥2 | 10min | done(主进程,3 edits) |

### Phase 5: worktree 验证（selftest ×4 + verify + dogfood 校验）
- [x] selftest-delegation 38/38 / dispatch 12/12 / fallback 21/21 / plan-dispatch 6/6；verify 22/3（全 deploy drift）；check-plan-dispatch 对本计划 ✓0 / 对 v056 legacy 0
- **Status:** complete（2026-09-09；executor(haiku-1) 7/8，cmd2 由主进程补验 = 8/8）
- **Executor:** executor(haiku-1)— 验证类改派 executor 而非 mini runner（v057 R4）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|------------------------|-------------|---------|------|
| S1 | 按清单跑 8 条命令，每条 tail 截断只记汇总行，只跑一次 | executor(haiku-1) | 命令清单（派发时给全） | 8/8 汇总行 | 10min | pending |

### Phase 6: Code Review + 合并 + 部署 9 位 + push
- [x] Code Reviewer 6/6 APPROVED（2 nit 记录：selftest 局部变量/644 权限观察，git 记录 755 正确）
- [x] 主仓 merge --no-ff 1932144（9 文件 +272/−16）+ Read 复验（SKILL cpd×2 / rule 执行体 / selftest 6/6）；worktree remove + branch -d
- [x] 9 位部署 diff 看方向 → 3 位 task-planner rm+cp -rL（diff=0×3）+ agent 副本 ×2；verify 25/0 ×3；check-plan-dispatch 部署位可跑
- [x] attest 自验：新门控对本计划 `✓ 3 个派发型 Phase` exit 0 并重新锁定
- [x] `git push origin master` → origin/master = HEAD（见 progress Phase 6 尾行；push 后 fetch 复验）
- **Status:** complete（2026-09-09；push 结果以 progress.md 为据）
- **Executor:** 主进程（例外理由:① git/worktree 编排 + 部署 cp——Rule 25.3 白名单；Code Review 由 Code Reviewer 子代理执行）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|------------------------|-------------|---------|------|
| S1 | Code Review Gate：6 判据审新脚本与 2 处接入 | Code Reviewer(sonnet-1) | worktree diff master..HEAD -- scripts/ | 6/6 或列 CHANGES_REQUESTED | 15min | pending |

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type | 目标 | 状态 | 结论 | 证据 | findings 落点 | checkpoint 路径 | verify_done |
|------|--------------|------|------|------|------|--------------|----------------|-------------|
| 09-09 | executor | P2-S1 critical-rules 22.6/25.1 加执行体列与校验联动 | done | 22.6@131 执行体列 + 25.1@166 check-plan-dispatch 联动；212 行 | critical-rules.md:131,166 | findings [sub:01] | subagent-state/01-executor-p2s1.md | ☑ |
| 09-09 | executor | P2-S2 模板 task_plan.md S-unit 表 7 列 + 头注 | done | 表头@174 含执行体；S1/S2@176-177 继承；头注@130；383 行 | task_plan.md:130,174,176-177 | findings [sub:02] | subagent-state/02-executor-p2s2.md | ☑ |
| 09-09 | executor | P2-S3 plan-writer 契约/骨架/禁止/证据 4 处加执行体 | done | 执行体×5；骨架表头 7 列@155；示范@157；261 行；frontmatter 未动 | plan-writer.md:40,107,155-157,207 | findings [sub:03] | subagent-state/03-executor-p2s3.md | ☑ |
| 09-09 | executor | P3-S1 新建 check-plan-dispatch.sh（状态机，fail-open） | done | 131 行 5/5（v058 ✓/v056 legacy/夹具 A·B·D ✗/C ✓） | worktree scripts/check-plan-dispatch.sh | findings [sub:04]（主进程复核 ✓） | subagent-state/04-executor-p3s1.md | ☑ |
| 09-09 | executor | P3-S2 attest 锁定前 + check-complete 终验后接入 | done | attest +9/check-complete +4；违规 exit1 / --skip WARN / 终验 0/1 | worktree 两脚本 | findings [sub:05]（主进程复核 ✓） | subagent-state/05-executor-p3s2.md | ☑ |
| 09-09 | executor | P3-S3 新建 selftest-plan-dispatch.sh（6 用例 hermetic） | done | 111 行 6/6（含 attest 集成 T06，S4 取消）；主进程 /tmp 复跑 6/6 | worktree scripts/selftest-plan-dispatch.sh | findings [sub:06]（主进程复核 ✓） | subagent-state/06-executor-p3s3.md | ☑ |
| 09-09 | 主进程 | P4-S1 SKILL.md 净零 + INSTALL 门控说明 | done | SKILL 500/P0 10/cpd×2；INSTALL 12 用例 + 门控行 | worktree SKILL.md:76,273 / INSTALL.md:181-182 | 白名单② 文档≤6 行 | n/a | ☑ |
| 09-09 | executor | P5-S1 worktree 全量验证（8 条命令 tail 截断只记汇总行） | done | 7/8→主进程补验 cmd2（38/38）= 8/8；verify 22/3 全 drift（部署后归零） | subagent-state/07-executor-p5s1.md + 主进程 grep | findings [sub:07]（主进程复核 ✓） | subagent-state/07-executor-p5s1.md | ☑ |
| 09-09 | Code Reviewer | P6-S1 Code Review Gate：check-plan-dispatch + 2 接入 + selftest 按 6 判据 | running | | | | subagent-state/08-code-reviewer-p6.md | ☐ |

## 🔀 隔离决策
- 主仓干净（v057 已交付并 push）；无 wt 分支
- **决策：worktree 隔离**（技能保护区 + attest/check-complete 为运行中门控脚本）
- 路径 `/mnt/data/dev/task-planner-skill-worktrees/task-v058-plan-dispatch-gate`，分支 `wt/task-v058-plan-dispatch-gate`，基于 master a9f0583
- merge_back: pending

## Decisions Made

| 时间 | 决策 | 理由/参考依据 |
|------|------|--------------|
| 09-09 | 新开 v058 补齐"计划期规划子代理"的结构+机制缺口 | 用户指令"确保技能已完成这些修改，未完成先完成再部署推送"；核实为部分完成（文本有、列无、校验无） |
| 09-09 | 校验挂在 attest（计划批准锁定）+ check-complete（终验）两处 | attest = 用户批准计划的时点，此时拦最有效；终验兜底防执行中改坏 |
| 09-09 | 执行体列可写"继承" | 大多数 Phase 单一执行体，避免重复；混合型 Phase 逐行覆盖 |
| 09-09 | 验证 Phase 改派 executor(haiku-1) | v057 R4：mini runner 契约违约 4 项且 token 2 倍 |
| 09-09 | 用户 yes：执行 v058，含部署 9 位 + push origin master（D5） | 用户原话："确保技能已完成这些修改，完成后部署到各个平台，然后提交修改到 GitHub" |

## Errors Encountered

| 时间 | 错误 | 处置 |
|------|------|------|
