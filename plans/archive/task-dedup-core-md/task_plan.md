# Task Plan: 三核心文档去重（SKILL.md / reference.md / WORKFLOW.md）

## Goal

消除 task-planner skill 核心文档间的重复知识：Chain Handoff Contract 与 Read-vs-Write 决策矩阵各收敛到唯一权威源，删除过期失效的 WORKFLOW.md 生成物并清理其引用点；全程在 worktree 隔离区完成，合并回 master。

> 授权来源：用户本轮明确指示"如果是冗余的话，需要进行优化掉"（会话内预授权，无需再等 yes 门控；计划仍全文落盘留痕）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 .md 文档去重，无业务代码变更） |
| `session_id` | dedup-core-md-20260905 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-dedup-core-md` |
| `scope_files` | `skills/task-planner/SKILL.md`, `skills/task-planner/reference.md`, `skills/task-planner/WORKFLOW.md`(删), `skills/task-planner/README.md`, `skills/task-planner/docs/ARCHITECTURE.md`, `skills/task-planner/lib/install-stub.sh` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Chain Handoff Contract 规范全文（字段表+交接条件+重规划触发）仅存 reference.md § Chain Handoff Contract；SKILL.md 同名节收缩为 ≤4 行指针且锚点指向真实标题 | grep 验证 | `grep -n "verification_cmd" skills/task-planner/SKILL.md` 无表格行残留；`grep -n "Chain Handoff" skills/task-planner/reference.md` 节仍在 |
| VC-2 | Read vs Write 决策矩阵全文表仅存 SKILL.md §Rule 20.5；reference.md 的「§ 决策矩阵：何时读/写文件」节已删 | grep 验证 | `grep -n "何时读/写文件" skills/task-planner/reference.md` = 0；SKILL.md 决策矩阵节仍在 |
| VC-3 | WORKFLOW.md 已删除；README.md / docs/ARCHITECTURE.md / lib/install-stub.sh 无对 WORKFLOW.md 的活引用 | grep 验证 | `grep -rn "WORKFLOW" skills/task-planner/{README.md,docs/ARCHITECTURE.md,lib/install-stub.sh}` = 0 命中 |
| VC-4 | SKILL.md frontmatter（references 列表行）与 References 表中对 reference.md 的描述与该文件实际内容一致（不再声称含 决策矩阵/Scope Guard） | Read 复核 | SKILL.md 两处描述行 |
| VC-5 | 主仓 master 收到 --no-ff 合并；worktree 目录与 wt/task-dedup-core-md 分支已清理；主仓无本任务范围未提交变更 | git 验证 | `git log --merges -1`；`git worktree list`；`git branch --list "wt/task-dedup*"`；`git status --short` |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留（如部署未执行）→ PARTIAL 并列出。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| skill 文档 | `skills/task-planner/SKILL.md`、`reference.md`、`WORKFLOW.md`（删除） | 其他任何 skill 文件（templates/、references/ 其余、scripts/） |
| 引用清理 | `skills/task-planner/README.md`（目录树一行）、`skills/task-planner/docs/ARCHITECTURE.md`（目录树一行）、`skills/task-planner/lib/install-stub.sh`（仅 2 处字符串字面量去掉 `WORKFLOW.md`） | install-stub.sh 其他任何逻辑 |
| 仓根 | 无 | `progress.md`（仓根旧会话遗留）、`.zcode/`、`.plan-required`（由 hook 管理） |

**执行前自我检查**:本任务 6 个文件均在上方列表内；修改均直接服务于去重目标；用户已预授权冗余优化。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | SKILL.md 全文（619 行,去重对象与注册表模式依据） | skills/task-planner/SKILL.md @ master ad7900d | 必读 | ☑ 本会话已通读 |
| 项目内部文档/知识库 | reference.md 全文（295 行,去重对象,保留 Handoff 权威源） | skills/task-planner/reference.md @ master ad7900d | 必读 | ☑ 本会话已通读 |
| 项目内部文档/知识库 | WORKFLOW.md（82 行,判定过期）+ critical-rules.md（192 行,注册表模式对照） | skills/task-planner/WORKFLOW.md; references/critical-rules.md | 必读 | ☑ 本会话已通读 |
| 项目内部文档/知识库 | worktree-isolation.md（隔离 SOP/合并回合约） | skills/task-planner/references/worktree-isolation.md | 必读 | ☑ 本会话已通读 |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 三核心文档存在"同一规范双份全文"（Chain Handoff Contract、Read-vs-Write 决策矩阵）与过期生成物（WORKFLOW.md），造成双维护漂移与误导——去掉冗余后各规范是否都有唯一权威源？

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？（每规范唯一源 + 无悬空引用 = 可交付）
- [x] 核心问题不解决，其他工作都白费吗？（是——双源漂移会持续腐蚀 skill 一致性）
- [x] 核心问题的解决方法是清晰的、可执行的？（收敛指针/删重复节/删过期文件,已逐行定位）

## Current Phase

已交付（无活跃 Phase — outcome: **COMPLETE**,2026-09-05）

## Next Step

无后续动作。遗留决策项：① 9 实体部署副本仍为 ad7900d,是否重部署由用户决定;② 4 项范围外发现（frontmatter 清单缺 2 条/Rule 10 悬空指针/模板决策树双源分化/Rule 14 清单缺 .sh）见 verification.md 遗留清单。

## Phases

### Phase 1: 隔离区建立与计划初始化
- [x] init-session.sh 生成 5 计划文件（plans/task-dedup-core-md/）
- [x] check-conflicts.sh 扫描（结果:仅信号①计划类未跟踪文件,exit 0 安全）
- [x] 创建 worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-dedup-core-md`（分支 `wt/task-dedup-core-md`,基于 master）
- [x] plan-created.cjs 清哨兵 + attest-plan.sh 锁定计划
- [x] S1:sync-todos.sh --json + 原生 Todo 建立 Phase 映射
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排与计划文档操作属主进程白名单,SKILL.md §代码编辑强制隔离·例外）

### Phase 2: 三处去重编辑（worktree 内）
- [x] E1 SKILL.md: § Chain Handoff Contract（325-345 行）收缩为指针 stub（权威源→reference.md;锚点指向真实标题）;同步修正 frontmatter references 行与 References 表两处描述（VC-4）
- [x] E2 reference.md: 删除「§ 决策矩阵：何时读/写文件」节（226-234 行,SKILL.md 六行版的子集）
- [x] E3 删除 WORKFLOW.md（过期生成物:生成器 workflow-gen.ts 已不在仓、model/脚本清单/引用索引全部失真）+ 清理 README.md:65、docs/ARCHITECTURE.md:40、lib/install-stub.sh:73/174 四处引用
- **Status:** complete
- **Executor:** 主进程（例外理由:全部为 .md 文档编辑（白名单明示"*.md(计划/文档)"）+ install-stub.sh 仅 2 处字面量微调（Rule 14 禁改清单不含 .sh）;总变更 <100 行）

### Phase 3: 复验、合并回与清理
- [x] worktree 内逐条复验 VC-1~VC-4（grep 证据落 findings.md）
- [x] 3-File Gate（check-3file-gate.sh）+ 分两个 commit 提交（①去重收敛 ②删 WORKFLOW.md 及引用清理）
- [x] 主仓 `git merge --no-ff wt/task-dedup-core-md` + Read 关键文件复验（VC-5）
- [x] `git worktree remove` + `git branch -d` + sync-todos.sh --index 刷新 INDEX
- [x] plan 更新 merge_back=merged(5228d06)
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排与终验属主进程白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅信号①:4 个未跟踪计划类文件 .plan-required/.zcode//plans//progress.md,与任务范围零重叠,exit 0） |
| `isolation` | `worktree`（实现类任务默认首选,用户未否决） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-dedup-core-md`（§11.2 集中目录规范） |
| `branch` | `wt/task-dedup-core-md` |
| `merge_back` | `merged(5228d06)` |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-05 | S1 映射于 worktree 创建时建立 |
| Phase 2 | ☑ | 2026-09-05 | 同上 |
| Phase 3 | ☑ | 2026-09-05 | 同上 |

## Key Questions

1. SKILL.md 与 critical-rules.md 的"规则摘要 ↔ 全文"重叠是否冗余？→ **否**（注册表/渐进披露模式,SKILL.md 摘要+指针,critical-rules.md 权威全文,保留）
2. SKILL.md §任务模板库 与 template-mapping.md 的决策树/互斥表部分重复？→ **部分重复但表述已分化**,本轮不动（超范围）,列入遗留报告

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Chain Handoff 权威源定在 reference.md（SKILL.md 收指针） | reference.md 版是超集（+登记表条件+重规划触发）;SKILL.md:345 本就声明"详见 reference.md";frontmatter 也声明 Handoff 归 reference.md |
| 决策矩阵权威源定在 SKILL.md（删 reference.md 版） | SKILL.md 版 6 行是超集（多"浏览器/搜索返回"行）且标注 Rule 20.5;critical-rules.md Rule 20.5 一行摘要保留作注册表索引 |
| WORKFLOW.md 选择删除而非修复 | 生成器 workflow-gen.ts 已不在仓,无法再生成;内容 4 处失真（model/路径/.ps1 脚本/单步结论）;活引用仅 3 文件 4 处,清理成本低;git 历史可回滚 |
| 计划确认门控以用户预授权代替 | 用户原话"如果是冗余的话，需要进行优化掉"= 本任务显式授权; autonomous 模式下阻塞等 yes 违背会话契约 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| check-conflicts.sh 首次调用 No such file（Bash cwd 因上一命令 cd 漂移） | 1 | 改用绝对路径重跑,成功 |

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-05 | 每 Phase 翻转前 3-File Gate 硬校验 ×2（exit 0）+ Phase 2 后 smoke 17/17 + 每 Phase 对照执行范围自检（全程仅触碰 scope 6 文件,无越界） | 全部 | ALIGNED（未单独跑 Skill("task-drift-guard"),以 3-File Gate+VC 复验+范围自检替代,如实记录） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 3 |
| 主进程直做 Phase 清单 | P1 git 编排+计划白名单;P2 .md 文档白名单+.sh 字面量例外（理由见各 Executor 字段）;P3 git 编排+终验白名单 |
| 委派率 | 0%（全部带登记例外理由,Rule 25.3;且本任务为文档去重,无代码编辑/调研类可委派单元） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

本任务无子代理派发（全部 Phase 主进程直做,例外理由已登记）,表格留空备查。

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|-------------|
| — | — | — | 无派发 | — | — | — | — | — |
