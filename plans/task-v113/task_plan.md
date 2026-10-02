# Task Plan: task-v113 问题解决灵活性规范（Rule 22.3/41 消解链扩「查资料档」+反死循环换道义务）
<!-- 规范演进模板 — 用户裁决沉淀：失败换道优先查现成方案/官方文档，禁止死磕 -->

<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard -->

## Goal

将用户 2026-10-02 裁决沉淀为技能规范：①Rule 22.3 兜底链前置**「资料档」**——工具持续报错先查 help/官方文档/帮助手册；反复失败优先查网络现成方案（research-assistant/Doc Search Agent/web-search）——弥合宪法 §七「调研驱动」与 skill 执行层的落差（用户实证：网络查资料使用率过低）；②Rule 41.1 消解优先链同步扩档；③**反死循环换道义务**——同法失败 ≥2 次（联动 Rule 7）必须换道且换道评估顺序=现成方案→子代理隔离→拆解逐个击破，连续 3 次失败禁止第 4 次同法；全部验证由全新独立子代理执行。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（修改面=规范 .md+selftest 断言，无代码逻辑变更） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v113`（§11.2） |
| `scope_files` | `references/critical-rules.md`（Rule 22.3/41.1 扩档+引用面级联）、`SKILL.md`（超时与失败兜底段指针同步）、selftest 断言（Phase 1 清单为准）；memory 新增 feedback 条目；写入面 `plans/task-v113/*` |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前**独立子代理**按 alignment-review 审查；变更记录三要素 |
| `自动超时默认项` | D1 批准默认超时 5 分钟（44.3） |
| `质量审查工具` | alignment-review（独立子代理）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 修订后全量 selftest 回归 0 FAIL（**独立子代理**） | fresh 42 脚本逐项 rc | subagent-state/ |
| VC-2 | 新链语义落地且全库一致：Rule 22.3 含资料档（官方文档/网络现成方案）+41.1 消解链同步+换道义务条款（≥2 次必须换道/3 次禁第 4 次同法）；「22.3」「41.1」引用面一致（grep 全集核对，旧「五档」表述已演进标注） | **独立子代理** grep 实测 | checkpoint |
| VC-3 | 语义自证：**fresh 子代理**按新链对 2 个真实历史失败案例（本会话 provider rejected×2/守卫误拦）走一遍新消解链推演，确认新档位可改变决策路径（灵活性实证） | 推演记录 checkpoint | subagent-state/ |
| VC-4 | 对齐审查通过（独立子代理） | checkpoint | subagent-state/ |
| VC-5 | worktree 合并回+对账结论+porcelain 干净 | 合并输出+porcelain | progress.md |
| VC-6 | memory feedback 条目（裁决原话+「网络查资料优先级提升」+失效条件）+变更记录三要素 | memory Read | memory+verification |

> **验证独立性铁律（延续 P0）**：全部验证由全新独立子代理执行。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规范面（worktree） | `references/critical-rules.md`（Rule 22.3/41.1 扩档+「22.3/41」引用面级联，普查清单为准） | 其他 Rule 语义 |
| 索引面（worktree） | `SKILL.md` 超时与失败兜底段同步行（最小） | 其他段落 |
| 断言面（worktree） | selftest 断言（Phase 1 清单；selftest-self-resolution/selftest-rescue-chain 预期为主） | 清单外 |
| memory 面（非仓库） | 新增 feedback 条目+MEMORY.md 索引行 | 其他记忆 |
| 计划系统文件 | `plans/task-v113/*` | 其他 plan 目录 |
| 明确排除 | 宪法 §七（用户级保护区不擅动——skill 层弥合后冲突消解，交付时说明）；plan-research-router 卫星本体（仅引用） | 未授权扩围 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 用户裁决 | 灵活性原话（多次失败换道/查网络现成方案优先/工具错误先查帮助与官方文档/禁死循环） | 本计划 Goal+Phase 1 存档 | 必读 | ☑ |
| 项目内部文档 | Rule 22.3 五档兜底现行全文+Rule 7 三击+Rule 41.1 消解优先链 | critical-rules.md（grep 定位） | 必读 | ☑ |
| 宪法落差 | §七「调研驱动：第一动作上网查资料，穷尽 ≥3 种策略」vs skill Rule 22.3 兜底链无资料档 | ~/.zcode/AGENTS.md §七（只读参照） | 必读 | ☑ |
| 项目内部文档 | 「22.3」「41」全库引用面+selftest 断言锚（rescue-chain/self-resolution） | Phase 1 普查 | 必读 | ☑ |
| 卫星 | plan-research-router（网络调研路由）/Doc Search Agent（官方文档） | 卫星 SKILL/宪法 §七路由表 | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: skill 执行层的失败兜底链（Rule 22.3 五档：改派/拆细/降档/接管/AskUser）与消解链（Rule 41.1）**均不含「查官方文档/查网络现成方案」动作**——尽管宪法 §七明确「第一动作上网查资料」，执行层机制缺位导致实际行为「网络查资料兴趣低」、同法重试、呆板卡死；用户要求失败后换道优先级=查现成方案/文档 最高，且大问题拆解逐个击破、善用子代理。

**核心问题判断**:
- [x] 解决后能交付吗？——能：22.3/41.1 扩档+换道义务+级联+推演实证=可交付
- [x] 不解决白费吗？——是：机制缺位则行为不会改变（用户已实证观察到）
- [x] 方法清晰可执行？——是：普查→扩档→级联→推演自证→合并

## Current Phase

（全部 Phase complete — 终验 COMPLETE）

## Next Step

交付；部署同步（五批积压）待用户裁决

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面 | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) fresh | 普查判断型只读 |
| Phase 2 | Agent 子代理 executor(sonnet-1) + worktree | 扩档修订+级联 |
| Phase 3 | Agent 子代理 executor fresh ×2 | 回归+推演自证与对齐审查 |
| Phase 4 | Agent 子代理 executor(对账) + 主进程（① git+② 簿记+③ memory） | 白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中（串行依赖链）；**/goal 对齐**: 用户未使用

## Phases

### Phase 1: 消解链影响面普查（fresh 只读）
- [ ] Rule 22.3 五档现行全文+22.3.1 Provider Scaling+22.3.2 拆细上限——扩档插入点设计（资料档位置：建议 22.3 前置第①档前=「先查后动」，或独立 22.3.0）
- [ ] Rule 41.1 消解优先链现行全文——同步扩档点
- [ ] 全库「22.3」「41.1」「五档」引用面普查（grep 实测全集 file:line）
- [ ] selftest 断言锚（selftest-rescue-chain/selftest-self-resolution/selftest-fallback 相关断言行）
- [x] 修订方案三件：资料档=22.3.0 前置（序号不变零冲突，skill-collab T4 实证无既有断言）+换道义务=22.3.0b+级联清单 14 项（含 selftest-fallback T10a 全序断言级联）；宪法 §七落差确认
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 普查+修订方案 | 继承 | critical-rules Rule 22.3/41+grep 引用面+selftest 锚 | ≤15min | pending |

### Phase 2: 扩档修订与级联（worktree）
- [x] 22.3.0 资料先行档+22.3.0b 换道义务落地+41.1⑤ 扩档引用+级联 14 项（5 文件 +29/-17）
- [x] selftest 级联：fallback 31/31+rescue-chain 11/11+self-resolution 13/13（含新 SR-13）+skill-collab 25/25；偏差披露 2 处（SR-11 基线 pre-existing 正则修复+SKILL 444 满额处置=演进注净 0 行）
- [x] worktree commit 干净
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 扩档+级联+断言 | 继承 | Phase 1 方案+级联清单 | ≤15min | pending |

### Phase 3: 独立验证（fresh ×2，含推演自证）
- [x] 全量 42 selftest 回归全绿（sub:3，666 PASS=基线 660+SR-13 新增）
- [x] **语义推演自证（VC-3）**：案例二（守卫连续误拦）HIGH 差异——22.3.0b 第 2 次失败强制换道，评估序①=读守卫源码+方案集（O(1) 对齐）替代 O(n) 试错；案例一 MEDIUM；对齐审查 APPROVED（sub:4）
- **V-N:** VC-1, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 回归 | 继承 | worktree selftest 42 个 | ≤15min | pending |
| S2 | 推演自证+对齐审查 | 继承 | 新链文本+2 个失败案例描述 | ≤15min | pending |

### Phase 4: 合并回与终验簿记
- [x] smart-merge-back（V5 预案→MERGED 7e82231）+清理+主仓复验
- [x] 部署对账：三宿主积压延续（v108-v113 五批），随交付报告呈报待裁决
- [x] memory feedback 条目（flexible-problem-solving-2230）+MEMORY.md 索引（62 行 14.1KB）
- [x] verification.md 全量（6/6 PASS）+check-complete+INDEX+簿记 commit
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（① git+② 簿记+③ memory——白名单）

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v112 notepad+本计划目录，属预期） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v113` |
| `branch` | wt/task-v113 |
| `merge_back` | pending |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底 |
|-------|---------|---|---|---|-----|---------|
| Phase 2 | 资料档插入位与既有 22.3.1/22.3.2 子条编号冲突 | 6 | 4 | 3 | 72 | 普查先行定位；编号方案（22.3.0 前置 or 重排）Phase 1 定 |
| Phase 2 | 「五档」引用面级联漏改 | 6 | 4 | 3 | 72 | grep 全集清单+Phase 3 全库复验（v110 行号窗口教训） |
| Phase 2 | 换道义务与 Rule 7 三击/41.4 消解清单语义重叠冲突 | 5 | 3 | 3 | 45 | 引用联动而非重复定义（普查确认边界） |
| Phase 3 | 推演自证流于形式 | 4 | 3 | 3 | 36 | 推演必须给出「旧链 vs 新链决策差异点」才合格 |
| Phase 5 | 合并冲突 | 6 | 2 | 2 | 24 | V5 预案（五轮先例） |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |

## Key Questions

1. 资料档插入位置（22.3.0 前置 vs 重排五档）？（Phase 1 定）
2. 换道义务与 Rule 7/41.4 的边界如何不重复定义？（Phase 1）
3. 新链对真实失败案例是否真有决策差异？（Phase 3 推演）
4. 「五档」字面引用面多大？（Phase 1 grep）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=rule-enhancement | 规范演进；白名单合法值 |
| D 类新任务 task-v113 | 问题解决策略=独立规范变更（Rule 8.1） |
| 资料档前置（先查后动）而非末位追加 | 用户原话「首先想的是到网上查找」——查资料是失败后高优先动作非末位兜底；位置 Phase 1 结合编号冲突定 |
| 换道义务引用 Rule 7/41.4 联动 | 不重复定义（普查确认边界后引用化） |
| 验证全部独立子代理（延续 P0） | v108-v112 用户明示 |
| 思路复述已呈示 | 2026-10-02 按 28.2.1 |
| silent: 自动裁决 D1 批准（Rule 44.3：超时 5min/默认批准/触发 2026-10-02/理由=用户裁决指令明确+worktree+独立验证兜底/被覆盖=等显式 yes） | — |

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
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4（rate 0.75 verdict=ok violations=0） |
| 主进程直做 Phase 清单 | Phase 4（① git+② 簿记+③ memory）——全白名单 |
| 委派率 | 0.75 ≥ floor；验证独立性：四波 fresh 子代理 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | executor | Phase 1 消解链普查+方案 | queued | | | | plans/task-v113/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 2 扩档+级联 | queued | | | | plans/task-v113/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | Phase 3 回归 | queued | | | | plans/task-v113/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 3 推演自证+对齐审查 | queued | | | | plans/task-v113/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 4 部署对账 | queued | | | | plans/task-v113/subagent-state/5-executor.md | - / 0 / ☐ |
