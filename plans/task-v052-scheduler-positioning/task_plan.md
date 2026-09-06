# Task Plan: task-planner 技能定位收敛——主进程=纯调度管理器（skill-fix 审查+优化）

## Goal

消除 task-planner 技能中「主进程亲自执行」的定位矛盾与例外面漏洞：① Goal 区补「主进程=调度管理器」P0 定位声明；② L33「鼓励使用，非强制」措辞对齐 P0 强制条款；③ 主进程 Edit 白名单从「全部 .md/.json/.yaml」收窄为「计划系统文件+原生 Todo+≤3 行 trivial」；④ 委派率阈值外置 `config.json#delegation_rate_floor`（默认 0.7）+ 例外理由白名单化；⑤ 兜底接管绑定 Rule 25.3 登记。worktree 内实施，smoke 回归后合并回 master。

> 授权来源：用户 2026-09-06 原话「/skill-fix 可以调用该技能做技能审查以及优化」+ 定位要求「主进程的核心目标就是调度管理，而不是要将所有任务都由主进程去执行」。走 skill-fix 标准诊断流程（用户只描述目标，未给具体方案）。
> **范围锁定**：仅 canonical 仓 `skills/task-planner/` 5 个文件 + plans/ 簿记。**不含 9 个部署位重部署**（用户未授权部署，交付后给建议命令）。范围外发现 → deferred-issues.log。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯规则文档文本精修,无代码文件;smoke+grep 断言兜底） |
| `session_id` | v052-scheduler-positioning-20260906 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v052-scheduler-positioning` |
| `scope_files` | `skills/task-planner/{SKILL.md,references/critical-rules.md,config.json,templates/task_plan.md,templates/verification.md}`、`plans/task-v052-scheduler-positioning/**` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | SKILL.md 含「主进程 = 调度管理器」P0 定位行,且「鼓励使用，非强制」零残留 | grep 断言 ×2 | 输出留 progress.md |
| VC-2 | 主进程 Edit 例外收敛为「计划系统文件/原生 Todo/≤3 行 trivial」三件;「.md/.json/.yaml」全类白名单措辞在 SKILL.md+critical-rules.md 零残留 | grep 断言 | 输出留 progress.md |
| VC-3 | config.json 含 `delegation_rate_floor`(default 0.7)且 JSON 可解析;`<50%` 在技能文档 5 处全部改为 floor 引用 | python3 json.load + grep '<50%' 零命中 | 输出留 progress.md |
| VC-4 | Rule 25.3 含六项例外理由白名单;SKILL.md 兜底表#3 含「按 Rule 25.3 登记例外理由」;模板 canned 理由对齐白名单 | grep + Read | 输出留 progress.md |
| VC-5 | worktree 内 `bash tests/smoke.sh` exit 0;主仓 merge --no-ff;worktree+分支清理;git log 复验 | 命令输出 | smoke 输出+git log |

**终验规则**：全部 VC 通过 → COMPLETE。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| canonical 技能 | 上列 5 文件（worktree 内 Edit） | 其他技能文件;9 个部署位;companion/lib/scripts/tests |
| 计划系统 | plans/task-v052-scheduler-positioning/** | 其他 plans/ 目录 |
| 顺带修复 | 无（deferred-issues.log 制） | 任何"发现就修" |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读 | 已确认 |
|------|-----------|------|------|--------|
| 项目内部 | skills/task-planner/SKILL.md 全文（607 行） | canonical 仓 | 必读 | ☑ 已全文 Read |
| 项目内部 | references/critical-rules.md 全文（209 行） | canonical 仓 | 必读 | ☑ 已全文 Read |
| 项目内部 | templates/task_plan.md+verification.md+config.json | canonical 仓 | 必读 | ☑ 已 Read/grep 定位 |
| 用户级 | 宪法 §一/§六/§十一 + skill-fix 标准 S47-62/S64/S74 | 会话已加载 | 必读 | ☑ |
| 项目内部 | memory: deploy-flow / known-defects-20260905（deferred 缺陷清单） | 记忆目录 | 参考 | ☑ |

## ⚠️ 核心问题定义

**核心问题**：技能已有 Rule 13/14/21/22/25/26 委派体系,但四处漏洞使「主进程=调度器」名存实亡——定位声明自相矛盾（一处非强制 vs 三处 P0）、主进程 Edit 例外面覆盖全部 .md/.json/.yaml（对文档型仓库=全部放行）、委派率 50% 低阈值+例外理由无白名单（v051 实测 0% 委派仍 COMPLETE）、兜底接管不绑定登记。收口这四处,定位即可落地。

**核心问题判断**: [x] 能交付 [x] 不解决则定位持续名存实亡 [x] 方法清晰（文本精修+阈值外置,无逻辑重设计）

## Current Phase

已交付（无活跃 Phase — outcome: **COMPLETE**,2026-09-06;VC-1~VC-5 全过,证据 verification.md）

## Next Step

无后续动作。master=89a29ae=部署 9 位（2026-09-06 20:3x 用户授权部署,9/9 diff -rq IDENTICAL;回滚点 /tmp/deploy-backup-task-v052/）。

## Phases

### Phase 1: 计划初始化与诊断取证
- [x] init-session 5 文件 + plan-created 清哨兵
- [x] worktree 建立（wt/task-v052-scheduler-positioning @ master 5016e3e,集中目录规范）
- [x] S64 路径验证器 + 误报取证（3 条 P0 = 解析基准误报,三文件实际存在）
- [x] subagent_skill_auditor（40 文件 0 问题）+ S61 跨调用方扫描 + S62 的 `<50%` 分布定位
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 计划系统文件维护——Rule 25.3 白名单）

### Phase 2: 诊断收口与修复设计
- [x] SKILL.md（607 行）+ critical-rules.md（209 行）全文 Read,委派定位漏洞 F1-F7 收口
- [x] 诊断报告+修复计划输出（展示给用户,授权来源=用户指令）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护;诊断结论已在主上下文,结论落 findings.md）

### Phase 3: 修复实施（worktree 内 5 文件 20 处）
- [x] SKILL.md: 定位声明/措辞对齐/白名单收窄/兜底登记/委派率 floor/反模式补条（9 处）
- [x] critical-rules.md: Rule 14 白名单/25.1 示例对齐/25.3 白名单枚举/25.4+Q5 floor（5 处）
- [x] config.json: +delegation_rate_floor（schema 同步,json.load 通过）
- [x] templates/task_plan.md+verification.md: floor 引用+canned 理由对齐（6 处）
- **Status:** complete
- **Executor:** 主进程（例外理由:④ 用户显式授权本次技能审查优化;技能规则文本须逐字精修,子代理转写高误改风险——skill-fix 反曲解要求）

### Phase 4: 验证回归
- [x] code-runner-agent 跑 worktree 内 tests/smoke.sh（VC-5 回归:exit 0,17 pass/0 fail）
- [x] 主进程一致性 grep 断言 VC-1~VC-4（证据 progress.md Phase 3）
- **Status:** complete
- **Executor:** code-runner-agent（mini,Handoff#1,检查点已 Read 复核）+ 主进程 grep（例外理由:③ 机械验证命令白名单）

### Phase 5: 合并回+簿记+交付
- [x] worktree status 干净（porcelain=0）→ 主仓 merge --no-ff → Read 复验（定位声明/delegation_rate_floor 均命中）→ worktree+分支清理（VC-5）
- [x] INDEX 刷新+记忆基线更新+S58 交付报告（含部署建议命令,不执行部署）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①=plans/ 簿记非本任务范围;③ 无遗留 wt 分支;⑤ 无运行中基础设施改动;④ task-active-plan 为旧任务且 scope 不相交） |
| `isolation` | `worktree`（技能源码变更,§十一 强制隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v052-scheduler-positioning` |
| `branch` | `wt/task-v052-scheduler-positioning` |
| `merge_back` | `merged(89a29ae)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-06 | S1 |
| Phase 2 | ☑ | 2026-09-06 | S1 |
| Phase 3 | ☑ | 2026-09-06 | S1 |
| Phase 4 | ☑ | 2026-09-06 | S1 |
| Phase 5 | ☑ | 2026-09-06 | S1 |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 收口而非新建委派规则 | Rule 13/14/21/25 体系已存在,漏洞在措辞矛盾/例外面/阈值/白名单,新立规则会加重复 |
| 委派率阈值外置 config.json | S9/S10 配置外置原则;`additionalProperties:false` 需同步 schema |
| 主进程 Edit 白名单收窄保留「≤3 行 trivial」 | 对齐宪法 §11.5.4 例外,避免微修也强制派发的过度工程 |
| 不部署 9 位 | 用户未授权部署;部署位=仓外基础设施（§五 跨项目隔离）,列为交付后建议 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| path_existence_validator 3 条 P0 MISSING | 1 | 取证为解析基准误报（三文件实际存在,ls 证据）;记 findings,不修工具（范围外） |

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-06 | 范围自检:仅 5 文件+plans/;S61/S62 扫描完毕;诊断→设计→实施顺序未偏离 | 全部 | ALIGNED |

## 📊 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0.5 / 5（Phase 4 smoke 由 code-runner-agent 执行） |
| 主进程直做 Phase 清单 | P1 编排②①;P2 计划文件②+诊断;P3 技能文本精修④;P5 合并簿记②①——均白名单 |
| 委派率 | 10%（终验复算:全部直做理由在 Rule 25.3 白名单内 → 按 25.4 不降级,编排/簿记型任务属正常形态） |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|-------------|
| 1 | 2026-09-06 | code-runner-agent | worktree 内跑 tests/smoke.sh 回归 | done | PASS exit 0,17 pass/0 fail;检查点已 Read 复核 | worktree tests/smoke.sh 输出+subagent-state/1-code-runner-agent.md | findings#Technical Decisions | plans/task-v052-scheduler-positioning/subagent-state/1-code-runner-agent.md | ☑ |
