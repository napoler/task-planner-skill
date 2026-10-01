# Task Plan: task-v109 记忆整理模板增补+记忆可用性治理
<!-- 记忆卫生模板 — 新增 memory-hygiene variant + dogfood 整理现有记忆 -->

<!-- template_type: refactor -->
<!-- plan_tier: standard -->

## Goal

在模板体系中新增「记忆整理」variant 模板（memory-hygiene-type），固化「写入带验证锚/消费前校验/定期整理」三道防线，防止错误与落伍记忆被当作正确内容使用；并用新模板 dogfood 整理本仓现有 57 条记忆（MEMORY.md 45.4KB 超限、42 条含易过时声明），全部验证动作由全新独立子代理执行。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（修改面=模板 .md+卫星文档+selftest 锚级联+记忆目录 .md，无代码功能变更） |
| `session_id` | `subagentagente2c5fbff464f4431aa1eaae` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v109`（§11.2） |
| `scope_files` | 新增 `skills/task-planner/templates/variant/memory-hygiene-type.md`；级联面 `template-mapping.md/template-guide.md/plan-writer.md/SKILL.md:274/critical-rules.md:348,361/selftest-template-lifecycle.sh(TL 锚)`；dogfood 面 `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/**`；写入面 `plans/task-v109/*` |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前由**独立子代理**按 alignment-review 审查（42.6.2）；变更记录三要素落盘（42.6.3） |
| `自动超时默认项` | D1 批准默认项超时 5 分钟（44.3）；记忆「删除类」处置一律不自动执行——仅列建议清单交用户（保守策略，D6 精神） |
| `质量审查工具` | alignment-review（独立子代理执行）+ documentation-review（模板面）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 模板增补+级联后全量 selftest 回归 0 FAIL（**独立子代理**，主仓 master 合并后终验场） | fresh 子代理 42 脚本逐项 rc | subagent-state/ checkpoint |
| VC-2 | 新模板形态合规+17 variant 计数全链一致（mapping §一/§六/§九+plan-writer+SKILL+critical-rules+guide+TL 锚级联后自洽） | **独立子代理** grep 实测 | checkpoint+findings |
| VC-3 | 干净上下文实测：**fresh 子代理**用新模板对 ≥3 条抽样记忆执行校验流程跑通（四维校验+处置产出） | checkpoint 8 字段回报 | subagent-state/ |
| VC-4 | dogfood 整理产出：57 条逐条处置记录（verified/updated/stale-marked/删除建议四态）落盘+MEMORY.md 修正版落 plans/task-v109/（**不直接覆盖**，主进程抽验 ≥5 条证据后才应用）+每条处置附验证锚证据 | 整理报告 Read+抽验 | plans/task-v109/memory-hygiene-report.md |
| VC-5 | worktree 合并回成功+三宿主对账结论+主仓 porcelain 干净 | 合并输出+diff+porcelain | progress.md |
| VC-6 | 对齐审查通过（独立子代理）+变更记录三要素 | checkpoint+变更记录 | findings+verification |

> **验证独立性铁律（延续 v108 用户 P0）**：全部验证由全新独立子代理执行；主进程仅编排/簿记/Read 结论。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板新增（worktree） | `skills/task-planner/templates/variant/memory-hygiene-type.md`（新建） | 其他 variant 修改 |
| 级联面（worktree，仅计数/锚） | template-mapping.md（§一/§六/§九 补行）、template-guide.md（§2.2 补行）、plan-writer.md（映射表补行）、SKILL.md:274（16→17）、critical-rules.md:348,361（17 variant/18 行）、selftest-template-lifecycle.sh（TL-17「16 个」锚→17） | 级联面外任何改动 |
| dogfood 面（非仓库） | `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/` 的 topic 文件更新与 MEMORY.md **修正版先落 plans/task-v109/**（主进程抽验后才应用） | 直接删除任何记忆文件（删除仅列建议） |
| 计划系统文件 | `plans/task-v109/*` | 其他 plan 目录 |
| 明确排除 | v107 R 系列遗留项、部署位写入 | 未授权扩围 |

**执行前自我检查:**
- [x] 用户指令显式授权：模板增补+记忆可用性治理；记忆目录非 §六保护区且属 §八记忆系统职责面
- [x] 删除类处置不自动执行（保守策略）；MEMORY.md 修正版先落计划目录抽验后应用

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档 | v108 模板新范式（23 文件修复后：Drift Log/Handoff/配置 3 行/🧰 区块/验证独立性行） | merge 5a30382 后 variant 范式，参照 bugfix-type.md | 必读 | ☑ |
| 平台机制 | 记忆系统契约（frontmatter name/description/metadata.type；一事一文件；MEMORY.md 索引行 ≤200 字符；消费侧「验证仍存在」义务） | 宪法 §八+系统提示 Memory 段 | 必读 | ☑ |
| 项目内部文档 | 现有记忆体系痛点实测：57 文件/45.4KB 索引/42 条含易过时声明 | 本会话 Phase 0 勘察（ls/grep 实测） | 必读 | ☑ |
| 项目内部文档 | TL-17 锚断言现状（guide「16 个」串） | selftest-template-lifecycle.sh | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 记忆会随任务推进而过时（基线被替代/遗留被清账/路径变更），且当前无「写入时带验证锚、消费前校验、定期整理」的机制承载——错误落伍记忆会被新会话当作正确内容使用（本会话 v107 已实证：按记忆假设三部署位 IDENTICAL 而 .zcode 位实际已漂移）。需要：①模板化的记忆整理任务类型（可反复执行）②一轮真实整理（dogfood）恢复现有记忆可用性。

**核心问题判断**:
- [x] 解决后能交付吗？——能：模板入库+四点同步+dogfood 修正产出+验证链完整
- [x] 不解决其他工作白费吗？——是：记忆是跨会话执行的事实源，错误记忆直接污染后续所有任务决策
- [x] 方法清晰可执行？——是：盘点→模板→验证→dogfood→合并，全部机制有先例承载

## Current Phase

Phase 1

## Next Step

派 fresh executor 盘点 57 条记忆出过时风险清单+模板设计稿

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) fresh | 记忆盘点判断型只读；独立上下文防主上下文记忆偏见（本任务主题自反性） |
| Phase 2 | Agent 子代理 executor(sonnet-1) + worktree | 模板编写+级联，隔离实施 |
| Phase 3 | Agent 子代理 executor ×3 fresh | 回归/形态+干净上下文/对齐审查 全独立（用户 P0） |
| Phase 4 | Agent 子代理 executor fresh（dogfood）+ 主进程抽验 | 记忆整理执行独立上下文；删除类仅建议；MEMORY.md 修正版抽验后应用 |
| Phase 5 | Agent 子代理 executor(对账) + 主进程（① git+② 簿记） | 白名单编排 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——盘点→模板→验证→dogfood→合并串行依赖链，维持 21.4 串行
**/goal 对齐（Rule 40.3）**: 用户未使用 /goal；Goal+VC 即目标锚

## Phases

### Phase 1: 记忆体系全量盘点+模板设计（fresh 只读）
- [ ] 57 条记忆逐条四维预检：①定位实存（引用的文件/规则号/数字锚 grep 实证）②时效性（绝对日期+失效条件评估）③冲突检测（与其他记忆/仓内现状矛盾）④消费风险分级（高=会被直接执行的断言/低）
- [x] 产出过时风险清单（33 条）+处置预判+设计稿（M1-M5）——子代理「43 脚本 655 PASS」数字错误已由主进程第一手证伪（实 42 脚本+selftest-registry.tsv 误计），以 v108 终验 42/660 为准
- **V-N:** VC-4, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 记忆全量盘点+设计稿 | 继承 | 记忆目录绝对路径+盘点四维定义+仓内现状参照（skills/ 关键锚） | ≤15min | pending |

### Phase 2: 模板编写+四点同步级联（worktree）
- [ ] 新建 memory-hygiene-type.md（对齐 v108 新范式区块；核心区块：记忆盘点表/四维校验清单/处置枚举/验证锚规范/整理报告契约；template_type: memory-hygiene）
- [ ] 四点同步级联：mapping §一/§六/§九+plan-writer+SKILL:274+critical-rules:348,361+guide §2.2 补行至 17；selftest-template-lifecycle TL-17「16 个」锚→17
- [ ] 逐批 commit（Rule 27），worktree 干净
- **V-N:** VC-2, VC-6
- **Status:** in_progress
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 新模板+级联+TL 锚 | 继承 | 设计稿+worktree 路径+级联面清单（7 文件） | ≤15min | pending |

### Phase 3: 独立子代理验证（fresh ×3）
- [ ] 全量 42 selftest 回归（worktree，含 TL 级联后）
- [ ] 形态核查（17/17 声明+计数全链一致）+ 干净上下文实测（新模板对 ≥3 条抽样记忆跑校验流程）
- [ ] alignment-review 对齐审查（模板变更面）；CHANGES_REQUESTED 项处置
- **V-N:** VC-1, VC-2, VC-3, VC-6
- **Status:** pending
- **Executor:** executor（sonnet-1）fresh ×3

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 回归 | 继承 | worktree selftest 42 个 | ≤15min | pending |
| S2 | 形态+干净上下文抽样校验 | 继承 | worktree templates/ + 抽样记忆 3 条 | ≤15min | pending |
| S3 | 对齐审查 | 继承 | worktree diff+alignment-review SKILL | ≤15min | pending |

### Phase 4: dogfood 记忆整理（fresh 执行+主进程抽验）
- [ ] fresh executor 按新模板整理 57 条：逐条处置记录（verified/updated/stale-marked/删除建议）+每条验证锚证据
- [ ] MEMORY.md 修正版落 `plans/task-v109/MEMORY.md.proposed`（索引行精简至 ≤200 字符+验证戳）；**不直接覆盖**真实 MEMORY.md
- [ ] 主进程抽验 ≥5 条处置证据 → 通过后主进程应用（updated/stale 标注类直接应用；删除建议类留待用户裁决）
- **V-N:** VC-4
- **Status:** pending
- **Executor:** executor（sonnet-1）fresh（整理执行）+ 主进程（抽验+应用——② 簿记面）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 57 条整理执行+修正版产出 | 继承 | Phase 1 清单+新模板+记忆目录 | ≤15min | pending |

### Phase 5: 合并回与终验簿记
- [ ] smart-merge-back 合并回+清理+主仓 Read 复验
- [ ] 部署对账（fresh）+结论登记（部署待用户指令）
- [ ] verification.md 全量+check-complete+INDEX+簿记 commit
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 主进程（① git 编排+② 簿记——白名单）

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v108 notepad+本计划目录未提交，属预期） |
| `isolation` | `worktree`（模板文件修改=保护区；记忆目录 dogfood 为非仓库直改但保守策略兜底） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v109` |
| `branch` | wt/task-v109 |
| `merge_back` | pending |

## 📊 FMEA 预演（规划期 — 指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|-----------------------------|
| Phase 1 | 盘点子代理被记忆目录体量压垮（57 条全读） | 4 | 4 | 3 | 48 | 分批（索引先行→topic 抽查）+超时拆细 22.3② |
| Phase 2 | TL-17 锚级联漏改致 selftest 断 | 6 | 4 | 3 | 72 | 级联清单含 selftest 面；Phase 3 回归兜底 |
| Phase 2 | 新 variant 区块遗漏（v108 范式 5 要素） | 5 | 3 | 3 | 45 | 设计稿列区块清单；Phase 3 形态核查兜底 |
| Phase 4 | dogfood 误删有效记忆 | 8 | 2 | 2 | 32 | 删除类仅建议不执行；MEMORY.md 修正版抽验后应用；topic 文件更新前原内容留存于报告 |
| Phase 4 | 子代理把「未验证」当「已验证」产出 | 6 | 3 | 3 | 54 | 处置记录强制验证锚证据列；主进程抽验 ≥5 条 |
| Phase 5 | 合并冲突（并行会话） | 6 | 2 | 2 | 24 | 合并前预检；冲突即 STOP |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

## Key Questions

1. 57 条记忆中真正过时/错误的比例与分布？（Phase 1 盘点）
2. 记忆整理模板的最小必备区块集？（Phase 1 设计稿）
3. dogfood 整理能否在不删除任何记忆的前提下恢复可用性？（Phase 4 保守策略验证）
4. 级联后 TL 锚是否自洽？（Phase 3 回归）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=memory-hygiene（新建 variant） | 记忆整理为可反复执行的标准任务类型；白名单动态派生合法 |
| D 类新任务 task-v109 | v108 已终态 COMPLETE；本指令为新模板类型增补+记忆治理（Rule 8.1） |
| dogfood 删除类处置仅列建议不执行 | 记忆目录无 git 不可逆；保守策略（D6 精神）；用户裁决后另行执行 |
| MEMORY.md 修正版先落计划目录抽验后应用 | 防止整理产出本身成为新的错误源；主进程第一手抽验 ≥5 条 |
| 验证全部独立子代理（延续 v108 用户 P0） | 用户上轮明示+9-26 裁决；本任务主题（防记忆偏见）更具自反性——主进程含大量本仓记忆上下文，恰恰不可信 |
| 思路复述已呈示 | 2026-10-02 计划展示时按 28.2.1 复述 |
| silent: 自动裁决 D1 批准（Rule 44.3：超时 5min/默认批准/触发 2026-10-02/理由=用户指令明确且删除类已保守化+修正版抽验后应用/被覆盖=等显式 yes） | D6（真删除记忆）不适用自动裁决 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 5 |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 |  |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | executor | Phase 1 记忆盘点+设计稿 | queued | | | | plans/task-v109/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 2 新模板+级联 | queued | | | | plans/task-v109/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | Phase 3 回归 | queued | | | | plans/task-v109/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 3 形态+干净上下文 | queued | | | | plans/task-v109/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 3 对齐审查 | queued | | | | plans/task-v109/subagent-state/5-executor.md | - / 0 / ☐ |
| 6 | | executor | Phase 4 dogfood 整理 | queued | | | | plans/task-v109/subagent-state/6-executor.md | - / 0 / ☐ |
| 7 | | executor | Phase 5 部署对账 | queued | | | | plans/task-v109/subagent-state/7-executor.md | - / 0 / ☐ |
