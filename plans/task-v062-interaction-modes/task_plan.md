# Task Plan: task-v062-interaction-modes — 交互双模式（静默/询问用户）+ 询问门控机制化

## Goal
给 task-planner 新增两种交互模式——**ask（默认：关键决策点给选项供用户选）**与 **silent（静默：自主决策+登记静默决策清单）**——覆盖 D1-D6 六类询问点（计划批准/方案分叉/兜底前移/范围外/歧义指令/硬停点），以 Rule 28 + config.json 键 + resolve-interaction-mode.sh 解析脚本 + selftest-interaction.sh 守护落地，全联动面（SKILL/模板/plan-writer companion/README）同步更新，合并回 master 后重部署 3 位 + plan-writer agent 2 位对齐；核心目标 = 减少重复返工。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新增 shell 逻辑：resolve 脚本 + selftest 套件） |
| `session_id` | 980c720af6794511a6ceb88f5289be17 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v062-interaction-modes` |
| `interaction_mode` | `silent`（用户直接下令的确定性构建任务,分叉点唯一且已由用户指定;静默决策逐条登记） |
| `scope_files` | `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/config.json`, `skills/task-planner/scripts/resolve-interaction-mode.sh`(新), `skills/task-planner/scripts/selftest-interaction.sh`(新), `skills/task-planner/templates/task_plan.md`, `skills/task-planner/companion/agents/plan-writer.md`, `skills/task-planner/README.md` |
| `template_type` | bugfix（技能增强——交互模式机制化,v059-v062 维护范式同构） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 28 成文：critical-rules.md 含 28.1-28.5（模式定义/解析优先级/D1-D6/询问规范/silent 语义+机制），D6 硬停点两模式一致不可豁免 | Read 复核对照 findings 设计 | findings 设计段 + Read 结果 |
| VC-2 | SKILL.md 联动：计划确认门接 Rule 28（silent 自动通过+登记，ask 保持）；既有 AskUserQuestion 点（:148/:291/:382 区）注记交互语义；摘要区含 Rule 28 行 | grep + Read 逐处 | grep 输出 + progress |
| VC-3 | 机制解析：resolve-interaction-mode.sh 优先级链 env > plan 配置表 > config > 默认 ask，非法值降级、缺 config fail-safe 到 ask；selftest-interaction.sh ≥7 用例全过 | `bash scripts/selftest-interaction.sh` EXIT=0 | selftest 输出 |
| VC-4 | 无回归：5 套既有 selftest 全量 fail=0（≥96 用例）+ 新增套件全过 + verify.sh 无新增 fail | 6 套件全跑 | 输出记 progress |
| VC-5 | 联动完整：模板配置表 + plan-writer companion 配置表含 interaction_mode 行；README 键说明 18→19；SKILL/Rule 28/脚本三者口径一致（宽口径"模式\|询问\|AskUser"联动扫描无失效引用） | grep 联动扫描逐条核对 | 分类表入 verification |
| VC-6 | 合并回 + 部署对账：task-planner 3 位 diff IDENTICAL + verify 25/0×3；**plan-writer agent 2 位对齐**（companion 变更联动,memory v057 陷阱）；companion 技能 6 位无新差异 | diff -rq + verify + agent diff | verification 终验段 |
| VC-7 | 全程隔离与簿记：全程串行派发、worktree 清理、Rule 27 逐 Phase 提交、INDEX/attest/ledger 齐备、静默决策清单登记 | git + Handoff 表 | git 输出 + Decisions 表 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 三试无效 → BLOCKED。
> `code_review: required`：终验前必须过 Code Review Gate（scope 内 .sh）。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | worktree 内 `scripts/resolve-interaction-mode.sh`(新)、`scripts/selftest-interaction.sh`(新)、`config.json` | 其他脚本 |
| 文档 | worktree 内 `SKILL.md`、`references/critical-rules.md`、`templates/task_plan.md`、`companion/agents/plan-writer.md`、`README.md` | variant 模板（决策:不改,见 Decisions）、其他文档 |
| 部署位 | 写目标：3 位 task-planner 部署位 + plan-writer agent 2 位（Phase 8）；只读：companion 技能 6 位 | 其他任何技能目录 |
| plans | 本计划三件套 + INDEX + ledger/attest | 其他计划目录 |

**执行前自我检查**：[x] 在列表内 [x] 必要 [x] 用户明确要求（"添加两种模式…静默…询问用户…减少重复返工"）

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | 交互模式设计（Rule 28 全文/D1-D6/解析优先级/联动面 12 项清单） | 本目录 `findings.md` | 必读 | ☑ |
| 项目内部 | config.json 键范式与 README 键说明段 | `skills/task-planner/config.json` + `README.md:119` | 必读 | ☑ |
| 项目内部 | companion→agent 2 位对齐陷阱 | memory task-planner-repo-deploy-flow.md | 必读 | ☑ |
| 项目内部 | 同构流程先例 | plans/task-v061-serial-dispatch/ | 参考 | ☑ |
| 项目内部 | 既有询问点（22.3⑤/escalation/drift BLOCKED/opus 门控） | critical-rules.md:30-124 | 参考 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: task-planner 执行要么全程不问（方向错了执行到底=大返工），要么既有询问点散落且无统一口径（何时该问/怎么问/答案不留痕）——用户要求双模式：ask 在关键分叉给选项拦截方向错误，silent 自主但登记决策清单供复核；目标是机制化地减少重复返工。

**核心问题判断**:
- [x] 解决后能交付吗？（ask/silent 语义清晰、解析有机制、联动无失效）
- [x] 不解决其他都白费吗？（返工是用户点名要消除的核心痛点）
- [x] 方法清晰可执行？（Rule 28+config 键+resolve 脚本+selftest+联动面已全部盘点）

## Current Phase
Phase 5

## Next Step
Phase 5 selftest-interaction.sh 修复（当前 2/4 FAIL：TI-05 空输出 rc=1、TI-06 期望 silent 实得 ask；TI-01..04 仅注释无代码）→ 派 code-assistant 在 worktree 内补全 8 用例。

## Phases

### Phase 1: worktree 创建与基线复核
- [x] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v062-interaction-modes`（branch `wt/task-v062-interaction-modes`，基线 master d7fab2a）
- [x] 核对 findings 联动清单（config 0 命中/README:119 18 键/plan-writer:129/5 套 selftest —— 全部一致）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排 + ③ 机械验证命令——Rule 25.3 白名单）

### Phase 2: critical-rules.md 新增 Rule 28
- [x] 按 findings 设计写入 `### 28 交互模式与询问门控`（28.1-28.5，:216-221，D6 不可豁免句在位）
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | Rule 28 全文新增（1 文件） | 继承 | worktree 内 critical-rules.md + findings「Rule 28 设计」段 | grep "### 28 交互模式" =1、28.1-28.5 各=1、D6 不可豁免句在位 | ≤15min | pending |

### Phase 3: SKILL.md 联动
- [x] 计划确认门（:77-79 区）接 Rule 28：ask 保持；silent 自动通过（attest 后直执行+静默决策清单）
- [x] 既有询问点注记（:148 fix-phase/:382 表⑤ 行）+ Critical Rules 摘要加 Rule 28 行
- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **完成记录**: 2026-09-12 06:25-06:28 commit `063f988`（SKILL.md:80/149/280/293 四处 Rule 28 在位，主进程 Read 复核）；簿记 06:28 漏回滚（progress/ledger tick2 误标 Phase2+3 complete 但 task_plan 未勾），本次 17:35 补勾

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 计划确认门+摘要行+询问点注记（1 文件 4 处） | 继承 | worktree 内 SKILL.md + findings 设计 | grep "Rule 28" SKILL.md ≥3；确认门含 silent 分支语义 | ≤15min | pending |

### Phase 4: config.json 键 + resolve 脚本
- [x] config.json 新增 `interaction_mode`（enum ask\|silent，default ask）
- [x] 新建 `scripts/resolve-interaction-mode.sh`：优先级 env > plan 配置表 > config > 默认 ask；非法值降级；缺 config fail-safe ask
- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **完成记录**: 2026-09-12 06:28 commit `b82f2be`（config.json:52-61 键 18→19 + resolve 脚本 93 行，主进程 Read 复核）；同批 Phase 3/4 漏回滚簿记，本次 17:35 补勾

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | config 键 + resolve 脚本（2 文件） | 继承 | worktree 内 config.json + findings 设计 28.1/28.5 | bash -n 过；手工 4 场景（env/plan/config/默认）输出正确 | ≤15min | done |

### Phase 5: selftest-interaction.sh 新套件
- [x] 新建 `scripts/selftest-interaction.sh`：≥7 用例覆盖优先级链/非法值降级/缺 config fail-safe/plan 表解析
- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **完成记录**: 17:38 commit `f7e2a14`（补全 TI-01..04 + 修 TI-05/06 对齐 resolve 实际接口 `<script_dir>/../config.json`，hermetic fixture），主进程 17:40 复跑 8/8 PASS EXIT=0（两遍一致）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 新套件编写（1 文件） | 继承 | worktree 内 selftest-dispatch.sh 风格 + resolve 脚本接口 + findings 设计 28.1 | 裸跑 EXIT=0 全 PASS；连跑两遍一致 | ≤15min | done |

### Phase 6: 模板 + companion + README 联动
- [x] templates/task_plan.md 配置表加 `interaction_mode` 行；companion/agents/plan-writer.md 配置表同步加行
- [x] README.md 键说明 18→19 + 新键说明
- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **完成记录**: commit `58ae695`（续跑执行）；主进程事后探针复验：模板/companion/README 三文件各含 interaction_mode 行 + config 键在位，宽口径扫描 6 文件引用一致无悬空

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 模板+companion 配置表（2 文件各 1 行） | 继承 | worktree 内两文件配置表区 + findings 联动表 #6/#8 | grep interaction_mode 两文件各 ≥1 | ≤10min | done |
| S2 | README 键说明（1 文件） | 继承 | worktree 内 README.md:119 区 + config 键语义 | "19 键" + 新键行在位 | ≤10min | done |

### Phase 7: 全量自测 + Code Review Gate
- [x] 6 套 selftest 全量 fail=0 + verify.sh（主进程复跑：dispatch 18 + active-plan 13 + delegation 38 + plan-dispatch 6 + fallback 21 + interaction 10 = **106 用例 fail=0** + verify 25/0）
- [x] Code Review Gate：续跑执行修复轮（commit `16f051b`：resolve token 提取+stderr 诊断 / selftest +2 用例 / SKILL:384 注记 / README 键标题），合并消息记录 APPROVED 复验；主进程复验修复后实质状态（套件全绿+部署位 10/10）
- **Status:** complete
- **Executor:** code-runner-agent（mini）
- **偏差登记**: Gate 执行过程主进程未实时见证（续跑期间），以修复后第一手复验替代采信——记入 verification.md 质量门控段

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 全量自测 | code-runner-agent(mini) | worktree 内 6 套件清单 | 各 EXIT=0 fail=0 | ≤15min | done |
| S2 | Code Review Gate | code-reviewer(sonnet) | 改动 .sh diff | APPROVED（P1/P2 → 串行修复轮） | ≤15min | done |

### Phase 8: 合并回 master + 重部署对账
- [x] 合并回 master：merge commit `b0da240`（续跑执行，9 文件）+ worktree/分支已清理（git worktree list 仅主仓、wt/* 0 分支）
- [x] 重部署 task-planner 3 位：主进程复验 diff -rq ×3 **全 IDENTICAL** + 部署位 selftest-interaction 10/10 实测
- [x] plan-writer agent 2 位对齐：zcode 位逐字节一致；claude 位仅 model 行适配（diff 实证）+ companion 技能 6 位无新差异
- **Status:** complete
- **Executor:** executor（sonnet-1）
- **完成记录**: 续跑执行 + 主进程 18:1x 第一手复验（3 位 diff/agent 2 位/部署位套件）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 合并回 + worktree 清理 | 主进程（白名单①） | 全 VC 复验 + worktree 干净 | merge commit + 无残留 | ≤5min | done |
| S2 | 重部署 3 位 + verify ×3 + selftest 抽跑 | 继承(executor) | canonical → 3 部署位 SOP | diff IDENTICAL×3 + 25/0×3 + 18/18 | ≤15min | done |
| S3 | plan-writer agent 2 位对齐 + companion 6 位复验 | 继承(executor) | companion/agents/plan-writer.md → 2 agent 位（claude 位 model 行 sed 适配）；companion 技能 6 位只读 diff | agent zcode 位逐字节一致 + claude 位仅 model 行；6 位无新差异 | ≤15min | done |

### Phase 9: 簿记收尾与交付
- [x] verification.md 终验 VC-1..7 + 委派统计 + 联动扫描分类表
- [x] INDEX/attest/ledger + 簿记 commit + 记忆更新（interaction-modes 理念 + 中断恢复教训）
- [x] 交付报告：模式语义/询问点清单/切换方式 + 使用说明
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）
- **完成记录**: 簿记补齐于续跑合并之后（18:1x），全程第一手复验后才翻转状态

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（ plans/ 簿记残留,与 scope 零重叠） |
| `isolation` | `worktree`（改 canonical 技能源码+config,§十一 命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v062-interaction-modes` |
| `branch` | `wt/task-v062-interaction-modes` |
| `merge_back` | `merged(b0da240)`（worktree/分支已清理；主进程复验 3 位部署 IDENTICAL + agent 2 位对齐） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步 | 备注 |
|-------|-----------|---------|------|
| Phase 1-9 | ☑ | 2026-09-12 | S1 九条映射已建 |

## Key Questions
1. 默认模式为何是 ask？→ 用户核心目标=减少返工;分叉点拦截方向错误是最低成本的返工预防;silent 由用户显式选择（计划配置表/env/口头切换）。
2. silent 会不会失控？→ D6 硬停点不可豁免 + 静默决策清单强制登记 + 交付报告附清单复核;用户随时打断/切换。
3. 为什么计划确认门在 silent 下自动通过？→ 静默语义的自然延伸;计划全文落盘+attest 锁定可审计;用户指令即授权。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 默认 ask;D1-D6 六类询问点;D6 两模式一致 | 减少返工=用户核心目标;安全底线不豁免 |
| 解析优先级 env > plan 配置表 > config > 默认 | 会话级 > 任务级 > 全局默认,越具体的越优先 |
| 静默决策以 `silent:` 前缀登记 Decisions Made | 口头决策不留痕=返工源头之一;清单化才能复核 |
| variant 模板不加新行 | 可选字段缺省回落 config;12 处冗余非联动(见 findings 联动表 #7) |
| 本计划 `interaction_mode: silent` | 用户直接下令的确定性构建;静默决策逐条登记 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 9 |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （≥0.7 且 verdict=ok 不降级） |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|-------------|
| 1 | 2026-09-12 06:25 | code-assistant | critical-rules 新增 Rule 28（28.1-28.5） | done | 逐字落地+8/-0,4/4 PASS,HIGH;主进程 Read 复核 | critical-rules.md:216-221 | findings「Rule 28 设计」 | plans/task-v062-interaction-modes/subagent-state/02-code-assistant.md | ☑ |

## 🔗 Chain 区块配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
