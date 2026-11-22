# 立项：task-planner 核心能力优化（记忆连续性 / 性能提速 / 子代理有效并行）

## Context（为什么做）

用户核心诉求：当前技能最核心的任务是**对项目过程中发现的问题、查询、分析出的知识点做提取→存储→定期回顾**，确保会话间**记忆连续性**、防止上下文窗口过大导致重要信息丢失（强调"核心知识记忆"，反对什么都存）；同时抱怨**执行很慢**、怀疑**子代理没被有效利用**（本可并行的任务被串行阻塞），要求立项优化。

三路只读勘察（结论交叉印证，均带磁盘路径实证）关键发现：

1. **记忆**：机制多（10+ 技能）但真问题是——`MEMORY.md` 膨胀至 **275 行/83KB** 且 200+ 主题文件，核心知识与流水未分层；**无统一"定期主动回顾"调度**（用户明确要的"隔一段时间回顾"目前空白）；压缩/切换的连续性靠文本纪律，`session-kv`(/tmp 易失)、`memory-consolidate`(目标分裂)、`dna-memory`(独立路径) 契约不统一。
2. **性能**：慢是**流程结构性放大**——`sess_ba603cf5` 判例（54 子代理 / 9~21h，1797 调用来自子代理）根因是无全局预算+返工无上限+上下文重复读，非"并行不够"；Hook 每轮注入复利（UserPromptSubmit ~1KB/轮、PostToolUse 0.34s/次）、fresh 自测 204s、SKILL.md 72KB+refs 134KB。
3. **⚠️ 快赢**：`perf-diagnosis` 的 12 项提速补丁已在孤立 worktree（`a0c5a03`，29 files，77/77 PASS）落地但**从未合并 master**——用户一直在跑未优化主线。
4. **并行**：规则已完善（Rule 96/59/104），但 `check-dispatch.sh` 仅单一串行槽、不做"独立性四问"机器校验；串行多来自正确性门（真实依赖）。**盲目加宽并行会放大慢速**。

用户裁决：分阶段实施；边界仅 task-planner 仓 + 直接部署位。

## 实施约束（P0）

- **worktree 隔离**：改 skill 定义属保护区，先在 `<repo>/tmp/worktrees/task-core-opt-20261122`（分支 `wt/task-core-opt-20261122`）实施，逐 Phase 验证后合并回 master 并清理 worktree。
- **范围守恒**：不动全局 `~/.zcode/AGENTS.md`（P0 保护区，需另行授权）；不改 memory-\*/session-kv/dna-memory 等跨技能生态（超边界）。记忆机制落 task-planner 仓内 + 该项目 MEMORY 目录。
- **文本优先**：规则/偏好以条款文本落地即完成，禁升级为脚本/hook 基建工程（除非勘察证明现有机制不足且用户授权）。
- 旧计划 `task-cli-help-examples-20261122` 挂起（D 类意图切换，登记不删条目）。

## 方案（按 Phase，推荐顺序）

**Phase 0 — 快赢清障：核实并合入 perf 提速补丁**
- 核实 worktree `a0c5a03` / `wt/perf-opt-20261012` 是否仍存在且可合并；`git log` + 关键文件 diff 比对主仓。
- 可合并则并集解冲突、跑 77/77 selftest、部署位 diff=0 后合入；不可合并则提取仍适用的补丁项（attest 缓存、selftest 指纹、CA-1 限频已落地，重点核对其余项）手工重放。
- 产出：性能前后基线数据（hook 注入字节/轮、fresh 时长、attest 时长）。

**Phase 1 — 记忆分层与定期回顾（用户第一核心）**
- 在 `MEMORY.md` 头部建「核心知识索引（CORE 区）」：仅收稳定/高频/决策级条目并设条数预算，流水归入主题文件；新增仓内 `references/memory-tiers.md` 定义 core/working/archive 分层与晋升/淘汰判据。
- 落"定期主动回顾"：复用 `progress-tracker` 的 JSONL 账本模式，新增 task-planner 侧回顾卡 + 触发条款（每 N 个 S-unit / 每 M 天复核 CORE 区），记 `reviewed_at`、对象、结论、下次到期；复用现有 `Rule 93/84.14` recall 触发点。
- 连续性契约：在 `references/critical-rules.md` 增"压缩/会话切换后必读 core 索引 + user-session-log，再决策"条款；明确 task-planner 侧权威层，避免依赖跨边界的 memory-consolidate。

**Phase 2 — 性能与上下文减负**
- Hook 瘦身：`zcode-userpromptsubmit.sh`/`zcode-posttooluse.sh` 注入去冗余（保留 plan-data 权威信息，压缩 plan-note/重复提醒），维持 CA-1 限频。
- 门控读取收敛：attest/check-complete 优先读 `plan-state.json`（4 MD 为 render 派生视图），减少 JSON↔MD↔hook 多次转换；用 manifest/hash 替代多部署位人工 diff。

**Phase 3 — 子代理有效并行（防失控）**
- 加全局预算闸门 + 返工上限（防 sess_ba603cf5 重演）：总子代理数/总轮次/单交付物返工轮次硬阈值，触发 STOP 上报。
- `check-dispatch.sh` 增强"独立性四问"机器校验（替代当前仅标记放行的单一串行槽）；产出可并行任务类型清单（只读勘察/多部署位对账/独立 VC/独立 CR=可并行；同文件写入/计划三文件状态=必须串行）。
- 公共上下文一次蒸馏传引用（`Rule 62.4b`），避免重复全量回读。

## 关键文件

- 源仓：`/mnt/data/dev/task-planner-skill/skills/task-planner/` — `SKILL.md`、`references/critical-rules.md`、`scripts/{zcode-userpromptsubmit.sh,zcode-posttooluse.sh,check-dispatch.sh,attest-plan.sh,check-complete.sh,planctl.py}`
- 记忆载体：`/home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/MEMORY.md`（+ 新增 CORE 区/回顾账本）
- 部署位（实施后文件级 cp 同步、diff=0）：`~/.zcode/skills/task-planner/`、`~/.agents/skills/task-planner/`（实施时 grep 确认 `~/.claude`、`~/.cursor` 是否为有效部署位，仅同步真实存在且一致的位）

## 复用（勿重造轮子）

- `progress-tracker` 的 `.zcode/ledger/*.jsonl` 账本模式 → 回顾账本
- `memory-cleanup` 的 T1/T2/T3 分级 → 记忆分层判据
- `Rule 93/84.14` recall、`plan-history-recall` → 回顾触发与跨任务召回
- perf 补丁已有实现（attest 缓存、selftest 指纹、`CA-1` 限频）→ Phase 0/2 直接复用
- `dispatching-parallel-agents` + `Rule 96/59/104` → Phase 3 并行基础

## 验证（每 Phase Exit 门）

1. selftest 全绿（用缓存，fresh 仅终验一次），与基线 FAIL 集同集零新增。
2. 部署位逐位 diff=0；worktree `git status` 干净后合并、清理 `wt/*`。
3. VC 逐条实弹（命令+PASS+绝对路径），CR 两轮收敛。
4. 性能量化对比：hook 注入字节/轮、fresh/attest 时长、工具调用次数 —— 证明"变快"而非声称。
5. 记忆连续性实测：模拟会话压缩/切换，验证 CORE 索引 + user-session-log 可恢复关键决策；回顾账本可被触发且防重复。
6. 并行实测：声明并行组的独立 S-unit 同消息并发成功、四问校验生效；全局预算超阈值时能 STOP。

## 范围外（明确不做）

不改全局 AGENTS.md、不改 memory-\*/session-kv/dna-memory 等跨技能生态、不扩张为脚本/hook 基建（除 Phase 0 合入既有补丁与 Phase 3 check-dispatch 最小增强）、不自动执行旧计划。
