# Task Plan: task-v110 子代理并行调度规范化（Rule 21.4 演进：独立性守门）
<!-- 规范演进模板 — 用户裁决沉淀：并行默认允许 + 互不影响/互不依赖守门 -->

<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard -->
<!-- parallel_groups: verify-tpl, verify-mem, verify-idx -->
<!-- [2026-10-02 task-v110] 并行组声明（Rule 21.4 新机制自证）：Phase 3 双代理并行实测用——verify-tpl=模板面核查/verify-mem=记忆治理核查（已完成）/verify-idx=INDEX 核查；三组文件集不相交、互不依赖，符合独立性四问 -->

## Goal

将用户 2026-10-02 裁决「子代理调度可以并行运行，但必须确保互不影响、互不依赖（否则错误资料/未就绪依赖只会产出错误内容）」沉淀为技能规范：Rule 21.4 从「串行铁律」演进为「并行默认允许 + 独立性四问守门」，含 check-dispatch 守卫适配、selftest 级联、dispatch 模板行、memory 演进记录；全部验证由全新独立子代理执行（含并行行为实测）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（修改面=规范 .md+check-dispatch.sh 守卫逻辑+selftest 断言——脚本面由全量回归+守卫行为实测兜底） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v110`（§11.2） |
| `scope_files` | `skills/task-planner/references/critical-rules.md`（Rule 21.4 重写+引用面）、`scripts/check-dispatch.sh`（serial_slot_check 适配）、`scripts/selftest-*.sh`（断言级联，以 Phase 1 普查为准）、`templates/subagent_dispatch.md`（工具面提示行）；写入面 `plans/task-v110/*`；memory `serial-dispatch-iron-rule.md`（演进记录） |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前**独立子代理**按 alignment-review 审查（42.6.2）；变更记录三要素（42.6.3） |
| `自动超时默认项` | D1 批准默认超时 5 分钟（44.3）；方案取舍按 44.2 低区分度直接裁决登记 |
| `质量审查工具` | alignment-review（独立子代理）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 修订后全量 selftest 回归 0 FAIL（**独立子代理**，主仓合并后终验场） | fresh 子代理 42 脚本逐项 rc | subagent-state/ checkpoint |
| VC-2 | Rule 21.4 新语义全库一致：grep 旧措辞（「串行铁律」无演进标注的硬性表述/「至多 1 个活跃子代理」绝对化表述）残留=0 或均已挂「[EVOLVED 2026-10-02]」演进标注；「21.4」引用面与新语义一致 | **独立子代理** grep 全库 | checkpoint+findings |
| VC-3 | 并行行为实测：**同时**派发 2 个互不依赖的 fresh 子代理（如 A=扫 variant 计数/B=扫记忆条目数），两者真并行完成且产出正确、互不干扰 | 双 Agent 同消息派发+双 checkpoint 时间线+产出交叉核验 | subagent-state/ |
| VC-4 | 串行保留场景仍被约束：无独立性声明/存在依赖的写类 S-unit 场景，守卫与新规则文本均要求串行（守卫行为或规则文本实测） | fresh 子代理实测或 grep 断言 | checkpoint |
| VC-5 | worktree 合并回+三宿主对账结论+主仓 porcelain 干净 | 合并输出+diff+porcelain | progress.md |
| VC-6 | 对齐审查通过（独立子代理）+memory 演进记录（serial-dispatch-iron-rule.md 更新，三要素：演进链 09-12→09-28→10-02+验证锚+失效条件） | checkpoint+memory Read | findings+memory |

> **验证独立性铁律（延续 v108/v109 用户 P0）**：全部验证由全新独立子代理执行。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规范面（worktree） | `references/critical-rules.md`（Rule 21.4+全库「21.4」引用面级联） | 其他 Rule 语义改动 |
| 守卫面（worktree） | `scripts/check-dispatch.sh`（serial_slot_check 适配，最小改动） | 其他脚本 |
| 断言面（worktree） | selftest 脚本中断言「21.4/串行」的行（Phase 1 普查清单为准） | 清单外断言 |
| 模板面（worktree） | `templates/subagent_dispatch.md` 工具面提示行 | 其他模板 |
| memory 面（非仓库） | `~/.zcode/cli/memories/.../serial-dispatch-iron-rule.md`（演进记录） | 其他记忆文件 |
| 计划系统文件 | `plans/task-v110/*` | 其他 plan 目录 |
| 明确排除 | 宪法 `~/.zcode/AGENTS.md` §一（用户级保护区，不擅动——交付时提醒用户自行同步或另行授权） | 宪法任何文件 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 用户裁决链 | 09-12 串行铁律裁决→09-28 只读分槽豁免（7 项）→10-02 并行默认+独立性守门 | memory serial-dispatch-iron-rule.md + critical-rules.md Rule 21.4 | 必读 | ☑ |
| 项目内部文档 | Rule 21.4 现行全文+「只读分槽豁免」机制（parallel_readonly/[readonly-parallel]/serial_slot_check 第④参） | critical-rules.md:144 一带 | 必读 | ☑ |
| 项目内部文档 | 「21.4」全库引用面（v109 盘点实测 critical-rules 内 grep=7） | Phase 1 普查 | 必读 | ☑ |
| 项目内部文档 | Rule 23 并行任务检测与冲突规避（fan-out Aggregator 硬校验——并行化的既有安全网） | critical-rules.md Rule 23 | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 现行 Rule 21.4 串行铁律（09-12 裁决）要求逐个派发逐个验收，互不依赖的子任务被迫排队，拉长执行链；用户 10-02 裁决演进为「可并行但必须互不影响+互不依赖」——需要把裁决沉淀为可执行规范（语义清晰/守卫适配/断言级联/记录演进），防止「有依赖的任务被并行 → 用错误资料产出错误内容」。

**核心问题判断**:
- [x] 解决后能交付吗？——能：新 Rule 21.4+守卫适配+级联+并行实测=可交付
- [x] 不解决白费吗？——是：裁决不落规范则执行层无所适从（21.4 旧文 vs 用户新裁决冲突），或被误用为「任意并行」引入错误依赖
- [x] 方法清晰可执行？——是：普查→修订→验证（含并行实测）→合并，全链有先例

## Current Phase

（全部 Phase complete — 终验 COMPLETE）

## Next Step

交付；部署同步（v108-v110 三批积压）待用户裁决；宪法 §一 同步待用户授权

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) fresh | 影响面普查判断型只读 |
| Phase 2 | Agent 子代理 executor(sonnet-1) + worktree | 规范重写+守卫适配，隔离实施 |
| Phase 3 | Agent 子代理 executor ×3 fresh（含**双代理同消息并行实测**——本任务自证并行机制） | 用户 P0 验证独立化+VC-3 并行实证 |
| Phase 4 | Agent 子代理 executor(对账) + 主进程（① git+② 簿记+memory 演进③记忆系统职责面） | 白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——普查→修订→验证→合并串行依赖链（Phase 3 内部双代理并行属 VC-3 实测设计，非编排需求）
**/goal 对齐（Rule 40.3）**: 用户未使用 /goal

## Phases

### Phase 1: 影响面普查（fresh 只读）
- [ ] Rule 21.4 现行全文逐句拆解（哪些语义保留=验收纪律/兜底链；哪些演进=串行强制）
- [ ] 全库「21.4」引用面普查（critical-rules 内 7 处+SKILL.md+selftest+templates+hooks——grep 实测全集）
- [ ] check-dispatch.sh serial_slot_check 逻辑解剖（第④参放行机制/写类锁行为）
- [ ] selftest 断言锚清单（断言「串行/21.4/至多 1 个」的行）
- [x] 产出修订方案三件套（新文本草案含演进链+独立性四问+声明制+串行保留 5 场景/级联清单 12 文件含硬锚 :198,371,373,385,400/守卫最小 diff 5 点且无标记路径零改动）；越 scope 候选 2 处（config.json:343/CLAUDE.md:33）裁决不动登记
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 影响面普查+修订方案 | 继承 | critical-rules.md Rule 21.4+grep 21.4 全库+check-dispatch serial 段+selftest 锚 | ≤15min | pending |

### Phase 2: 规范修订与守卫适配（worktree）
- [ ] Rule 21.4 重写（保留历史演进链 09-12→09-28→10-02；新语义=并行默认允许+独立性四问守门：①文件集相交？②资源相争？③输入依赖他者产出？④验收依赖他者结果？任一 yes→串行；声明制：计划 frontmatter/S-unit 行 `[P]` 组标注；验收纪律与串行槽回收不变）
- [ ] 全库「21.4」引用面级联（普查清单逐处，旧措辞挂演进标注或改写）
- [x] check-dispatch.sh serial_slot_check 最小适配（+12/-4：第⑤参组标记分支，无标记路径零变化）
- [x] selftest 断言级联（TS-07/08 新增+T6 窗口）+templates/subagent_dispatch.md 提示行（批次一含）
- [x] 逐批 commit（Rule 27），worktree 干净
- **V-N:** VC-2, VC-4, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | Rule 21.4 重写+引用面级联 | 继承 | Phase 1 方案+级联清单 | ≤15min | pending |
| S2 | 守卫适配+selftest 级联+模板行 | 继承 | 守卫改动点+断言清单 | ≤15min | pending |

### Phase 3: 独立子代理验证（fresh ×3，含并行实测）
- [x] 全量 42 selftest 回归——抓 knowledge-brief T6 行号窗口漏网（22.4 行号 161 越界 160），已放宽 200 并复跑 16/16
- [x] **并行行为实测（VC-3）**：首轮无标记双派发=组 A 被守卫拦截（VC-4 实证）+组 B 完成；补 parallel_groups 声明后带标记双派发=真并行（A/C 时间线交叠 7s）+产出正确
- [x] 串行保留场景核验（VC-4）：TS-08 无标记拦截断言+实战拦截双态
- [x] alignment-review 对齐审查：APPROVED（P0/P1=0，P2×2 登记）
- **V-N:** VC-1, VC-3, VC-4, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 回归 | 继承 | worktree selftest 42 个 | ≤15min | pending |
| S2+S2' | 并行实测双代理（同消息派发） | 继承×2 | 互不相交的两个只读核查面 | ≤15min | pending |
| S3 | 串行保留核验+对齐审查 | 继承 | 守卫行为+alignment-review SKILL | ≤15min | pending |

### Phase 4: 合并回与终验簿记
- [x] smart-merge-back 合并回（V5 拦截→worktree merge master→MERGED e0527b6）+清理+主仓复验三项全过
- [x] 部署对账（fresh sub:10）：三宿主 v110 面 13/13 落后，zcode 累积 31 文件积压 → 待用户裁决
- [x] memory 演进记录更新（serial-dispatch-iron-rule.md 三段演进链+M5 三要素）+MEMORY.md 索引行同步
- [x] verification.md 全量（6/6 PASS）+check-complete+INDEX+簿记 commit
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（① git+② 簿记+③ 记忆系统职责面——白名单）

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v109 notepad+本计划目录，属预期） |
| `isolation` | `worktree`（规范+守卫脚本修改=运行中基础设施） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v110` |
| `branch` | wt/task-v110 |
| `merge_back` | pending |

## 📊 FMEA 预演（规划期 — 指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|-----------------------------|
| Phase 2 | Rule 21.4 重写语义歧义（并行边界模糊被滥用） | 8 | 3 | 3 | 72 | 独立性四问硬性化+串行保留场景显式枚举；对齐审查兜底 |
| Phase 2 | 「21.4」引用面级联漏改（v109 同型） | 6 | 5 | 3 | 90 | 普查 grep 实测全集为准；Phase 3 全库 grep 复验（VC-2） |
| Phase 2 | check-dispatch 改动破坏既有串行守卫 | 7 | 3 | 2 | 42 | 最小改动（仅声明组放行分支）；全量回归+VC-4 行为实测兜底 |
| Phase 3 | 并行实测双代理被串行槽守卫拦截 | 4 | 4 | 3 | 48 | 实测设计=只读核查面（既有只读分槽豁免覆盖）；若守卫拦截即证明守卫生效，调整声明后再测 |
| Phase 5 | 合并冲突（并行会话） | 6 | 2 | 2 | 24 | V5 拦截预案=worktree merge master（v109 实战先例） |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |

## Key Questions

1. 「21.4」全库引用面有多大、哪些是硬锚？（Phase 1）
2. 独立性四问在守卫层的机器承载最小改动是什么？（Phase 1 方案）
3. 并行默认化后，如何防止「有依赖任务被误并行」？（四问守门+声明制+验收兜底）
4. 双代理并行实测能否真跑通？（Phase 3 VC-3）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=rule-enhancement | 规范演进类；白名单合法值 |
| D 类新任务 task-v110 | 用户裁决属规范变更（非 v109 范围）；Rule 8.1 |
| 声明制并行（方案 A 折中）| 44.2 低区分度直接裁决：机器全量文件集比对（方案 B）实现复杂度高且收益边际小；声明制+四问守门+验收兜底覆盖 90% 场景，守卫最小改动 |
| 宪法 AGENTS.md 不擅动 | §六保护区用户级文件；交付报告提醒用户宪法 §一「串行派发铁律」条目需其自行同步或另行授权 |
| 验证全部独立子代理（延续 P0） | v108/v109 用户明示；并行实测本身即本任务验证对象 |
| 思路复述已呈示 | 2026-10-02 按 28.2.1 |
| silent: 自动裁决 D1 批准（Rule 44.3：超时 5min/默认批准/触发 2026-10-02/理由=用户裁决指令明确+改动全程 worktree+独立验证兜底/被覆盖=等显式 yes） | — |
| silent: 并行实测首轮=守卫拦截实证（组 A 无标记被串行槽拦截 age=0s<120s，组 B 独立完成）——构成 VC-4「无声明默认串行」行为实证；补 frontmatter parallel_groups 声明后带标记重派完成 VC-3 真并行（44.2 直接裁决登记） | 守卫「拦截-放行」双态实测=新机制完整证据链 |

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
| 主进程直做 Phase 清单 | Phase 4（① git 编排+② 簿记+③ 记忆系统职责面——白名单）；少量 ⑥ ≤3 行机械修正 |
| 委派率 | 0.75 ≥ floor；验证独立性：八波 fresh 子代理（含双代理并行实测） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | executor | Phase 1 影响面普查+方案 | queued | | | | plans/task-v110/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 2 规范重写+级联 | queued | | | | plans/task-v110/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | Phase 2 守卫适配+断言 | queued | | | | plans/task-v110/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 3 回归 | queued | | | | plans/task-v110/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 3 并行实测 A | queued | | | | plans/task-v110/subagent-state/5-executor.md | - / 0 / ☐ |
| 6 | | executor | Phase 3 并行实测 B | queued | | | | plans/task-v110/subagent-state/6-executor.md | - / 0 / ☐ |
| 7 | | executor | Phase 3 串行核验+对齐审查 | queued | | | | plans/task-v110/subagent-state/7-executor.md | - / 0 / ☐ |
| 8 | | executor | Phase 4 部署对账 | queued | | | | plans/task-v110/subagent-state/8-executor.md | - / 0 / ☐ |
