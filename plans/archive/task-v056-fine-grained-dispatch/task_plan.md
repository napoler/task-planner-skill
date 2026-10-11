# Task Plan: task-v056 子代理拆分粒度精细化（小步快跑/小模型短上下文友好）

## Goal
把 task-planner 技能的子代理任务拆分从 Phase 级细化到**步级（S-unit 派发单元）**：计划期强制步级拆分（每步短小、短上下文、自带材料包），执行期失败兜底**优先"拆细"而非"升模型档位"**——落实"计划做细 + 小模型短执行"理念，提高小模型执行可靠性。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 markdown 规则文本 + JSON 配置，无代码文件改动；verify.sh/selftest 由 Phase 6 承担质量门控） |
| `session_id` | sesse6240c6794f0479b9803f00676539b6b |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v056-fine-grained-dispatch`（§十一 集中目录规范） |
| `scope_files` | `skills/task-planner/references/critical-rules.md`, `skills/task-planner/config.json`, `skills/task-planner/templates/subagent_dispatch.md`, `skills/task-planner/templates/task_plan.md`, `skills/task-planner/companion/agents/plan-writer.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/scripts/verify.sh` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 22.3 兜底顺序含「拆细」档，且排在「降档（升模型）」之前；含防循环条款（每子任务拆细限 1 次） | grep + Read 复核 | `skills/task-planner/references/critical-rules.md` 22.3 节 |
| VC-2 | Rule 22.6 Subtasks 转正：Executor≠主进程的 Phase **计划期必填** S-unit 表；步级上限数值（≤2 文件 / ≤100 行 / 预估 ≤15min）写入规则文本；模板 task_plan.md 的 Subtasks 结构从 HTML 注释转正为可见结构 | grep + Read 复核 | critical-rules.md 22.6 + templates/task_plan.md |
| VC-3 | config.json `subagent` 新增步级键 `step_max_files`(2)/`step_max_lines`(100)/`step_max_minutes`(15)/`prompt_max_chars`(3000)，JSON 合法（jq 通过），默认值与规则文本一致 | `jq empty config.json && jq '.subagent' config.json` | config.json |
| VC-4 | subagent_dispatch.md 派发模板含「上下文预算」字段：prompt 总量 ≤`prompt_max_chars` + 输入材料最小化纪律（只注入本步所需，禁贴全文） | Read 复核 | templates/subagent_dispatch.md |
| VC-5 | plan-writer.md 含拆步纪律：派发型 Phase 必产出 S-unit 表 + 每步预写输入材料包 + 每步可观察验收 | Read 复核 | companion/agents/plan-writer.md |
| VC-6 | SKILL.md 收敛约束不回归（≤500 行）且 P0 标记计数不减少；verify.sh 全量 pass（0 fail） | `wc -l SKILL.md` + `bash scripts/verify.sh` | verify.sh 输出 |
| VC-7 | selftest 全 pass 无回归 | `bash scripts/selftest.sh`（以仓内实际名为准） | selftest 输出 |
| VC-8 | 合并回 master 后 9 位部署点 rm+cp -rL 重部署，diff -r 复验 =0 | `diff -r` 逐位复验 | Phase 7 progress 记录 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | skills/task-planner/references/critical-rules.md | 其他 references/* 文件 |
| 配置 | skills/task-planner/config.json | 其他 config |
| 模板 | skills/task-planner/templates/task_plan.md、templates/subagent_dispatch.md | templates/variant/*（本期不动 12 个变体，规则层 22.6 为结构权威） |
| agent | skills/task-planner/companion/agents/plan-writer.md | 其他 companion agent |
| 技能入口 | skills/task-planner/SKILL.md（联动最小改 + 行数收敛） | — |
| 脚本 | skills/task-planner/lib/verify.sh（如需增校验项；09-09 修正路径 scripts/→lib/，实际未触碰） | 其他 scripts |
| 部署点 | 9 位部署点仅 Phase 7 rm+cp 覆盖（deployment，非源码编辑） | 部署点内手工改文件 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | 拆分机制现状调研（10 项事实+行号） | plans/task-v056-fine-grained-dispatch/subagent-state/01-explore.md | 必读 | ☑ |
| 项目内部 | Rule 21-25 现行原文 | skills/task-planner/references/critical-rules.md:110-167 | 必读 | ☑ |
| 项目内部 | 模型档位约定 agent-model-tiering | ~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md | 参考 | ☑ |
| 项目内部 | worktree 隔离 SOP | skills/task-planner/references/worktree-isolation.md | 必读 | ☐ Phase 7 前确认 |
| 项目内部 | 9 位部署拓扑 | memory: task-planner-repo-deploy-flow | 必读 | ☐ Phase 7 前确认 |

## ⚠️ 核心问题定义

**核心问题**: 现行拆分约束全挂 Phase 层（≤3 文件/≤300 行）且兜底顺序"升档优先于拆细"，导致派发给子代理的任务过大、上下文过长，小模型执行质量差。解决后：计划期产出步级 S-unit 表（每步短小+材料包自足），执行期失败先拆细后升档，小模型短上下文可靠执行。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（技能行为改变：拆分更细、兜底更合理）
- [x] 核心问题不解决，其他工作都白费吗？（用户核心诉求 = 执行可靠性，依赖本问题）
- [x] 核心问题的解决方法是清晰的、可执行的？（规则文本 + config 键 + 模板结构，全部仓内可控）

## 设计方案（Phase 2 产出 — 用户确认后生效）

### D1 理念反转：兜底顺序插入「拆细」档（Rule 22.3 重排）
- 现行：① 改派 → ② 降档（haiku 失败升 sonnet）→ ③ 主进程接管 → ④ AskUser
- 改为：① 改派 → ② **拆细**（该子任务触及步级上限或预估超时 → 回计划层拆成更小 S-unit 重派，**不改模型档位**；每子任务拆细限 1 次，再失败走③）→ ③ 降档 → ④ 接管 → ⑤ AskUser
- 依据：子代理失败第一假设 = 任务太大/上下文太长，而非模型不够强；拆细治本且保持小模型低成本执行（用户 09-09 裁决理念）

### D2 步级结构转正（Rule 22.6 重写 + 模板转正）
- Executor ≠ 主进程的 Phase，**计划期必须**展开 Subtasks 派发单元表（每行 = 一次 Agent 派发）：`| ID | 目标(≤1句) | 输入(路径+≤10行摘要) | 验收(可观察) | 预估时长 | 状态 |`
- 步级上限（比 Phase 级更紧）：单步 ≤`step_max_files`(2) 文件、≤`step_max_lines`(100) 行、预估 ≤`step_max_minutes`(15) 分钟；超限 = 计划无效回炉再拆
- 触发下限：产出 >1 文件 或 预估 >30 分钟 的派发型 Phase 必拆步
- Rule 21.4 的"失败 ≥2 次才拆细"**提前到首次失败即评估**（联动 D1）

### D3 派发 prompt 上下文预算（Rule 22.4 增字段 + 模板同步）
- 八字段增加第 9 字段「上下文预算」：prompt 总长 ≤`prompt_max_chars`(3000 字符)；输入材料只注入本步所需（路径 + ≤10 行摘要），**禁止把计划/findings 全文贴进 prompt**
- S-unit 的输入列在计划期预写好材料包 → 执行期派发零调研零决策，小模型照单执行（"计划做细"的直接兑现）

### D4 config 新增步级键（默认值）
`subagent.step_max_files: 2` / `step_max_lines: 100` / `step_max_minutes: 15` / `prompt_max_chars: 3000`（规则文本引用 config，单一数值源）

### D5 plan-writer 拆步纪律 + SKILL.md 最小联动
- plan-writer.md：派发型 Phase 必产出 S-unit 表；每步预写材料包与可观察验收；"计划多花 1 倍时间拆细，执行省 3 倍返工"
- SKILL.md：仅联动兜底顺序表 + 委派检查点一句话（行数收敛 ≤500 不回归，细节全留 critical-rules.md）

### 明确不做（本期范围外）
- 12 个 variant 模板逐个加 S-unit 表（规则层 22.6 为结构权威，规则生效不依赖变体模板；避免面状改动）
- 拆细动作的脚本化/hook 强制（本期为规则文本层；机制化可作后续任务）
- 执行期自动测 prompt 字符数的工具（预算靠纪律 + 计划期材料包预写）

## Current Phase
Phase 7（complete — 已交付 COMPLETE）

## Next Step
无剩余 Phase；后续建议见 verification.md「已知非阻塞遗留」（install-companion 目标发现 / mini 运行器输出截断 / SKILL.md 500 行边界）

## Phases

### Phase 1: 调研现状（10 项机制盘点）
- [x] Explore 子代理盘点 Rule 21-25/模板/config/plan-writer 现状
- [x] 结论落盘检查点 + 主进程 Read 复核关键区段
- **Status:** complete（2026-09-09，subagent-state/01-explore.md）
- **Executor:** explore（mini）— 已完成，结论见 subagent-state/01-explore.md

### Phase 2: 方案设计与计划撰写
- [x] 设计 D1-D5 五项改动方案
- [x] 撰写本计划（含 VC/Phases/S-unit 示范）
- [x] 用户确认计划（09-09 yes；attest 403ae8d1）
- **Status:** complete（2026-09-09）
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: 规则文本重写 critical-rules.md（worktree 内）
- [x] S-unit 全部 complete（3/3 Read 复核通过；worktree commit 3164591）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径) | 验收(可观察) | 预估 | 状态 |
|----|------------|-----------|----------------|------|------|
| S1 | Rule 21 增 21.1b 步级上限条款 + 21.4 首败即评估拆细 | critical-rules.md:110-117 + 01-explore.md | grep "21.1b" 命中；数值与 config 一致 | 10min | done(52s) |
| S2 | Rule 22.3 兜底重排插入「拆细」档（限 1 次防循环）+ 22.6 Subtasks 转正必填 | critical-rules.md:118-134 + 方案 D1/D2 | grep 22.3 拆细先于降档；22.6 含"必填" | 15min | done(57s) |
| S3 | Rule 22.4 八字段增「上下文预算」第 9 字段 + Rule 25 联动句 | critical-rules.md:125/159-167 + 方案 D3 | grep "上下文预算"/"prompt_max_chars" 命中 | 10min | done(111s) |

### Phase 4: config + 双模板改动（worktree 内）
- [x] S-unit 全部 complete（3/3 并行派发，各自 Read 复核通过；worktree commit 61a0238）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径) | 验收(可观察) | 预估 | 状态 |
|----|------------|-----------|----------------|------|------|
| S1 | config.json subagent 增 4 个步级键 + default 块同步 | config.json:154-220 + 方案 D4 | jq empty 通过；4 键存在且值正确 | 5min | done(156s) |
| S2 | subagent_dispatch.md 增「上下文预算」字段与材料最小化纪律 | templates/subagent_dispatch.md + 方案 D3 | grep "上下文预算" 命中 | 10min | done(217s) |
| S3 | task_plan.md 模板 Subtasks 结构转正（注释→可见必填结构） | templates/task_plan.md:144-170 + 方案 D2 | 模板 Phase 区可见 S-unit 表结构 | 10min | done(160s) |

### Phase 5: plan-writer 拆步纪律 + SKILL.md 联动 + 25.2 并行例外（worktree 内）
- [x] S-unit 全部 complete（3/3 并行派发，各自 Read 复核通过；worktree commit 50450ea）
- **Status:** complete（2026-09-09）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 输入(路径) | 验收(可观察) | 预估 | 状态 |
|----|------------|-----------|----------------|------|------|
| S1 | plan-writer.md 增拆步纪律（S-unit 必产出+材料包预写） | companion/agents/plan-writer.md + 方案 D5 | grep "S-unit\|派发单元" 命中 | 10min | done(205s) |
| S2 | SKILL.md 兜底表四档→五档 + 检查点联动 + 八→九字段 并保 ≤500 行收敛 | SKILL.md 相关段 + 方案 D1/D2 | wc -l ≤500；grep 拆细命中 | 15min | done(142s，恰 500 行) |
| S3 | critical-rules.md 25.2 追加并行例外句（互不依赖 S-unit 可并行，各自独立复核）— 09-09 dogfooding 发现（findings R3） | critical-rules.md:164 | grep "互不依赖" 命中 | 5min | done(88s) |

### Phase 6: worktree 内全量验证
- [x] verify.sh：22 pass / 3 fail（3 = 部署副本 drift，部署前预期；Phase 7 部署后复跑归零）
- [x] selftest 全 pass（delegation 35/35，fallback 21/21）
- [x] worktree 内 git status 干净 + 3 次 Phase 提交（3164591/61a0238/50450ea）
- **Status:** complete（2026-09-09）
- **Executor:** code-runner-agent（mini）

### Phase 7: 合并回 + 9 位重部署 + 终验交付
- [x] 主仓 merge --no-ff wt/task-v056-fine-grained-dispatch → 2d3c017 + Read 复验 7 项关键串
- [x] worktree remove + branch -d 清理（worktrees=1，wt 分支 0）
- [x] 3 位 task-planner 重部署 diff=0 ×3 + verify.sh 25/0 ×3；plan-writer agent 副本 ×2 定向对齐（companion 6 位无源码变更）
- [x] 终验：VC 8/8 PASS + 委派率 0.714 ok + 3-File Gate + check-complete.sh（见 verification.md）
- **Status:** complete（2026-09-09，outcome COMPLETE）
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排——Rule 25.3 白名单）

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type | 目标 | 状态 | 结论 | 证据 | findings 落点 | checkpoint 路径 | verify_done |
|------|--------------|------|------|------|------|--------------|----------------|-------------|
| 09-09 | explore | 拆分机制 10 项现状盘点 | done | 约束全挂 Phase 层；Subtasks 仅注释示例；兜底升档优先于拆细 | critical-rules.md:110-167 等 | Research Findings/R1 | subagent-state/01-explore.md | ☑ |
| 09-09 | executor | P3-S1 Rule 21 增 21.1b 步级上限 + 21.4 首败评估拆细 | done | 21.1b@114 / 21.4@117，邻行未动，净 +1 行 | worktree critical-rules.md:114,117 | progress Phase 3 段 | subagent-state/02-executor-s1.md | ☑ |
| 09-09 | executor | P3-S2 Rule 22.3 插拆细档重排 + 22.3.1 编号同步 + 22.6 S-unit 转正 | done | 22.3@124 拆细=②先于③降档；22.3.1 ④/⑤；22.6@128 计划期必填；行数 209 不变 | worktree critical-rules.md:124,125,128 | progress Phase 3 段 | subagent-state/03-executor-s2.md | ☑ |
| 09-09 | executor | P3-S3 Rule 22.4 九字段上下文预算 + 25.1/25.2 S-unit 联动 | done | 22.4@126 九字段+prompt_max_chars；25.1@163 S-unit 表强制；25.2@164 逐 S-unit；Batch 八字段 81/180 未动 | worktree critical-rules.md:126,163,164 | findings R2 | subagent-state/04-executor-s3.md | ☑ |
| 09-09 | executor | P4-S1 config.json 增 4 步级键 + default 同步 | done | default 9 键 [2,100,15,3000]；jq 5/5 | worktree config.json | findings R3 | subagent-state/05-executor-p4s1.md | ☑ |
| 09-09 | executor | P4-S2 subagent_dispatch.md 第 9 节上下文预算 + 输入节材料最小化 | done | 九字段@2；材料包来源@19；§9@71-75；85 行 | worktree templates/subagent_dispatch.md:2,19,71 | findings R3 | subagent-state/06-executor-p4s2.md | ☑ |
| 09-09 | executor | P4-S3 task_plan.md 模板 S-unit 表转正（Phase 3 示范 + 头注） | done | 旧注释清零；S-unit 表@174-177 注释外；头注@130；383 行 | worktree templates/task_plan.md:130,173-177 | findings R3 | subagent-state/07-executor-p4s3.md | ☑ |
| 09-09 | executor | P5-S1 plan-writer.md 拆步纪律（6 处） | done | 6 处落地；S-unit 骨架@154-157；禁止 2 条@185-186；260 行；frontmatter 未动 | worktree plan-writer.md:40,107,154-157,185-186,195,207 | findings R4 | subagent-state/08-executor-p5s1.md | ☑ |
| 09-09 | executor | P5-S2 SKILL.md 四→五档兜底 + 八→九字段 + 2.5/21/22 摘要联动（≤500 行） | done | 500 行/P0 10；五档表@375-380 拆细=2；八字段仅 Batch@266 | worktree SKILL.md:37,81,269,270,372,376-380,392 | findings R4 | subagent-state/09-executor-p5s2.md | ☑ |
| 09-09 | executor | P5-S3 critical-rules.md 25.2 并行例外句 | done | 164 行内替换；209 行不变 | worktree critical-rules.md:164 | findings R4 | subagent-state/10-executor-p5s3.md | ☑ |
| 09-09 | code-runner-agent | P6 worktree 内全量验证（verify.sh/selftest×2/jq/init-session 模板流通） | done | selftest 35/35+21/21；jq 四键；模板流通 5/5；verify 22/3（3=部署前 drift 预期） | subagent-state/11-code-runner-p6.md | findings R5 | subagent-state/11-code-runner-p6.md | ☑ |
| 09-09 | executor | 交付后记忆落盘（2 新记忆 + MEMORY.md 索引；主进程 Write 被 check-delegation 误拦记忆目录） | done | 2 文件 + 索引 +2 行；目录 10→12 | ~/.zcode/cli/memories/…/memory/ | findings R7 末段 | subagent-state/12-executor-memory.md | ☑ |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

- **check-conflicts 结果**：信号① 3 个未提交项（.active_plan/.plan-required/本计划目录）均为计划系统自身文件，无踩踏；无 wt 分支遗留/额外 worktree 信号
- **决策**：**worktree 隔离**（命中宪法 §十一 11.1-1：修改 ~/.zcode/skills 仓库源码 = 保护区 + 运行中基础设施）
- 路径：`/mnt/data/dev/task-planner-skill-worktrees/task-v056-fine-grained-dispatch`，分支 `wt/task-v056-fine-grained-dispatch`，基于 master
- 计划文档留在主仓 plans/（会话级状态不进 worktree）；CWD 不迁移
- merge_back: **merged(2d3c017)**，worktree 已 remove，wt 分支已删；部署 3 位 diff=0 + agent 副本 ×2 对齐（09-09）

## Decisions Made

| 时间 | 决策 | 理由/参考依据 |
|------|------|--------------|
| 09-09 | 新开 task-v056 而非扩展 task-v055 | v055（机制性强制）已全 Phase complete；本任务为新方向（拆分粒度），Rule 9 新请求重规划 |
| 09-09 | 拆细优先于升档（方案 D1） | 用户理念：小模型+短上下文+完整计划 = 可靠执行；失败第一假设是任务太大而非模型弱 |
| 09-09 | 步级上限 2 文件/100 行/15min + prompt 3000 字符 | 比 Phase 级（3 文件/300 行）收紧一档；15min 内可完成的步骤上下文增长有限；数值进 config 单一数值源 |
| 09-09 | variant 12 模板本期不动 | 规则层 22.6 为结构权威；避免面状改动稀释审查精度（YAGNI） |
| 09-09 | 25.2 补"互不依赖 S-unit 可并行"例外（Phase 5 S3，B 类自发现） | Phase 4 dogfooding：三个不同文件的 S-unit 并行派发墙钟 217s vs 串行 533s；原措辞字面禁止并行与宪法 §一 冲突 |
| 09-09 | plan-writer agent 副本定向 cp 而非运行 install-companion.sh | dry-run 显示脚本会把 plan-resume 新装进 ~/.zcode/skills 造成同名遮蔽（计划外环境变更）；claude 侧手工复现其 model 适配（sonnet） |

## Errors Encountered

| 时间 | 错误 | 处置 |
|------|------|------|
| （暂无） | | |
