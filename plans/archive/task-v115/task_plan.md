# Task Plan: task-v115 回流收编+宪法对齐+存量注释补强（用户四项授权复合执行）
<!-- template_type: migration -->
<!-- plan_tier: standard -->
<!-- parallel_groups: backport, comment-audit -->

## Goal

执行用户 2026-10-02 四项授权：①**videop1 回流收编**——12 个 video/image 家族 variant+3 分叉文件增量收进主仓（17→29 计数全链级联，收编后 zcode 位单轨化）②**宪法对齐**——~/.zcode/AGENTS.md §一（并行调度演进口径）与 §九（注释条款对齐 Rule 45）③**存量注释补强**——v111 清单可执行项（check-complete 头注释四要素+gate Why/attest 分步 Why/dispatch+delegation 分支取舍/三模板头填写指引）；全量回归+三宿主部署+终验由独立子代理执行。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（本任务含 .sh 脚本修改——check-complete/attest 注释补强属注释面，仍按轻 diff 单轮轻量审查） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v115`（§11.2） |
| `scope_files` | 回流面 `skills/task-planner/templates/variant/`（+12）+`plan-template-kit/references/{template-guide,template-mapping}.md`+`companion/agents/plan-writer.md`+计数级联面（Phase 1 grep 全集：SKILL/critical-rules/README/selftest×2/knowledge-brief 锚）；宪法面 `~/.zcode/AGENTS.md` §一§九（用户授权④）；注释面 `scripts/{check-complete,attest-plan,check-dispatch,check-delegation}.sh`+`templates/{subagent_dispatch,knowledge-brief}.md`+`references/dispatch-examples.md` 头部；簿记 `plans/task-v115/*` |
| `interaction_mode` | `ask` |
| `对齐审查` | 独立子代理 alignment-review 收尾 |
| `自动超时默认项` | D1 已获用户显式授权（「1回收 2授权 3 注释增强 4 ok」），无需超时裁决 |
| `质量审查工具` | alignment-review（独立）+code-review 轻量单轮（脚本 diff） |

## ✅ Verification Contract

| # | 判定标准 | 验证 |
|---|----------|------|
| VC-1 | 回流后主仓 variant=29 且 12 收编文件头部 template_type 注释合规（29/29）；计数全链级联一致（Phase 1 清单 grep 复验零残留）；全量 selftest 0 FAIL（独立子代理） | fresh grep+42 rc |
| VC-2 | 3 分叉文件合并质量：主仓演进内容（v108-v114 修复/17 口径新结构）与 videop1 增量（12 variant 行+28 体系描述）**并存无丢失**（收编前后语义点清单对照） | 对照表+fresh 复核 |
| VC-3 | 宪法 §一/§九 对齐落地且原语义不丢失（改前/改后对照），消费方 memory 边界段同步清账 | diff+Read |
| VC-4 | 注释补强按 v111 清单执行（check-complete/attest/dispatch/delegation/三模板头），Rule 45 合规（What+Why 双层），selftest 零破坏 | fresh 审查 |
| VC-5 | 合并回 master+三宿主部署（zcode 位首次**单轨化**：29 variant 全量同步）+对账零意外差异 | diff+探针 |
| VC-6 | 对齐审查通过+memory 更新（部署基线/双轨清账）+变更记录三要素 | checkpoint+memory |

> 验证独立性铁律延续；Phase 2 三线并行（backport 组/注释组声明制+宪法主进程白名单④——用户显式授权）。

## ⚠️ 执行范围限制

| 类别 | 允许 | 禁止 |
|-------|------|------|
| 回流（worktree） | Phase 1 清单内文件 | 清单外 |
| 宪法（主进程直做） | ~/.zcode/AGENTS.md §一相关行+§九注释行（用户授权④） | 宪法其他节 |
| 注释（worktree） | 清单 5 脚本+3 模板头部注释 | 逻辑变更 |
| 部署 | 三宿主 skills/（收编后含 zcode variant 单轨化） | 部署位其他文件 |
| 计划文件 | plans/task-v115/* | 其他 plan 目录 |

## 📚 必要知识储备

| 知识源 | 定位 | 级别 |
|------|------|------|
| videop1 资产清单 | ~/.zcode/skills/task-planner/templates/variant/ 12 独有文件+3 分叉文件 diff | 必读 |
| v111 补强清单 | plans/task-v111/subagent-state/1-executor.md :54-71 | 必读 |
| 级联先例 | v108/v109 两轮 16→17 全链（grep 集合可复用） | 必读 |
| 宪法现行 | ~/.zcode/AGENTS.md §一高频路由段+§九注释段 | 必读 |
| memory 边界段 | serial-dispatch-iron-rule.md「宪法未同步」段（VC-3 清账对象） | 参考 |

## ⚠️ 核心问题定义

**核心问题**：三宿主与主仓的 videop1 分叉使 skill 体系双轨演化（计数/规则互相冲突风险持续存在）；宪法与新规范两处脱节；存量注释密度不均（4%-44%）——用户四项授权一次性收敛：回流单轨化+宪法对齐+注释补强。
- [x] 能交付：三线独立文件集，全链有先例（v108/v109 级联+v110 实测+部署 SOP）
- [x] 不解决白费：双轨漂移每轮任务都在扩大
- [x] 方法清晰：普查→三线并行→回归→部署→簿记

## Current Phase

（全部 Phase complete — 终验 COMPLETE）

## Next Step

交付；部署已单轨化（三宿主 29 variant 全一致）

## 🧰 工具选择与编排（Rule 40）

| Phase | 工具面 | 理由 |
|-------|----------------------|---------|
| Phase 1 | executor fresh（普查） | 判断型只读 |
| Phase 2 | **并行组**：executor(backport)+executor(comment-audit) 同消息并行+主进程（宪法④） | Rule 21.4 新机制正式行使：三线文件集不相交/无输入依赖 |
| Phase 3 | executor fresh（回归+对账）+部署执行（主进程①+探针） | 机械面 |
| Phase 4 | 主进程（② 簿记+③ memory）+对齐审查 fresh | 白名单 |

**workflow 编排判定**：Phase 2 命中「独立并行子任务」——但保持 Agent 工具串行槽+声明组并行（21.4 新机制），不用 CreateWorkflow（用户未点名 /workflow）
**/goal 对齐**：未使用

## Phases

### Phase 1: 回流级联面普查+合并点甄别（fresh 只读）
- [ ] 12 个 videop1 独有 variant 逐个头部合规预检（template_type/plan_tier 注释在位性）
- [ ] 3 分叉文件三方对照：主仓版/videop1 版/共同祖先——逐段甄别「videop1 增量」（收编对象）vs「主仓演进」（保留对象）vs「冲突」（合并点），产出合并方案
- [ ] 计数级联面 grep 全集（17→29：variant 计数/「17 个」/「18 行」/「25 个 .md」/「34 行」矩阵/knowledge-brief 锚 22→34/TL-17/skill-split/SKILL:274/critical-rules:348,361/README）
- [ ] 产出收编清单+合并方案+级联清单
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标 | 执行体 | 输入 | 预估 | 状态 |
|----|------|--------|------|------|------|
| S1 | 普查+甄别+三清单 | 继承 | 部署位 videop1 面+主仓级联先例 | ≤15min | pending |

### Phase 2: 三线实施（并行组 backport/comment-audit + 主进程宪法）
- [ ] **线 A（backport 组）**：worktree 内 12 variant 收编（拷入+头部合规修正）+3 分叉文件按方案合并+计数级联全链执行
- [ ] **线 B（主进程④ 用户授权）**：宪法 §一相关行对齐并行调度演进（保守改法：改表述不改结构+演进标注）+§九注释行对齐 Rule 45；memory 边界段清账
- [ ] **线 C（comment-audit 组）**：v111 清单注释补强（5 脚本+3 模板头，Rule 45 合规）
- [ ] 三线各自 commit（worktree 内 A/C；宪法非 git 直改+备份）
- **V-N:** VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）×2 并行 + 主进程（④ 用户显式授权宪法修改——白名单）

| ID | 目标 | 执行体 | 输入 | 预估 | 状态 |
|----|------|--------|------|------|------|
| S1 | 线 A 回流+级联 | 继承 [parallel-group:backport] | Phase 1 三清单 | ≤15min | pending |
| S2 | 线 C 注释补强 | 继承 [parallel-group:comment-audit] | v111 清单 | ≤15min | pending |

### Phase 3: 回归+合并+部署单轨化
- [ ] worktree 全量 42 selftest（fresh）→ 合并回 master → 三宿主部署（zcode 位**全量含 variant 29**=单轨化）→ 探针对账（fresh 或机械）
- **V-N:** VC-1, VC-5
- **Status:** complete
- **Executor:** executor fresh（回归）+ 主进程（① git+部署编排——白名单）

### Phase 4: 对齐审查+终验簿记
- [ ] alignment-review（fresh）+code-review 轻量（脚本注释 diff）+memory 更新+verification+INDEX+commit
- **V-N:** VC-6
- **Status:** complete
- **Executor:** 主进程（② 簿记+③ memory）+ executor fresh（审查）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v114 簿记+本计划目录） |
| `isolation` | `worktree`（A/C 线）；宪法=用户级文件直改（④授权+备份先行） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v115` |
| `branch` | wt/task-v115 |
| `merge_back` | pending |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| Phase 2 | 3 分叉文件合并丢内容（videop1 段落或主仓修复丢失） | 8 | 3 | 3 | 72 | Phase 1 语义点清单对照+VC-2 fresh 复核 |
| Phase 2 | 计数级联漏网（29 全链第 3 次大级联） | 6 | 4 | 3 | 72 | Phase 1 grep 全集+Phase 3 回归+全库复验 |
| Phase 2 | 收编 variant 头部不合规 | 4 | 4 | 2 | 32 | Phase 1 预检+收编时修正 |
| Phase 2 | 宪法修改越界（动了非授权节） | 8 | 2 | 2 | 32 | 仅 §一/§九 两处；改前 diff 展示；备份先行 |
| Phase 3 | zcode 单轨化后 videop1 项目受影响 | 7 | 2 | 3 | 42 | 备份 tar 已有+回流=其资产入主仓双向可用；登记其侧知会建议 |

## 🔁 原生 Todo 同步

| Phase | 已建 | 时间 |
|-------|------|------|
| Phase 1 | ☐ |  |
| Phase 2 | ☐ |  |
| Phase 3 | ☐ |  |
| Phase 4 | ☐ |  |

## Key Questions

1. 12 variant 收编的头部合规差距？（Phase 1 预检）
2. 3 分叉文件的合并冲突点全集？（Phase 1 甄别）
3. 29 级联面比 17 级联面多出哪些新锚？（Phase 1 grep）
4. 宪法 §一 最小改动集？（Phase 2 线 B）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=migration | 回流收编=资产迁移语义 |
| 用户四项授权=同一授权包单计划 | 一条指令内四项相关裁决（Rule 8.1 同包不拆） |
| 并行组双代理（Rule 21.4 正式行使） | A/C 文件集不相交（templates+级联 vs scripts+模板头注释）无依赖；B 主进程白名单④ |
| 3 分叉文件=主仓基底+收编 videop1 增量 | 主仓有 v108-v114 演进（17 口径+新修复），videop1 版缺这些——基底选信息量大的主仓版，甄别收编其 12 variant 行与特有段落 |
| 收编后 zcode 位单轨化全量同步 | 回流后主仓=29 超集，双轨分叉根源消除 |
| 宪法备份先行+仅动两节 | 保护区最小改动纪律 |
| 执行通道=L1 | 回流=跨文件语义级联（38.7 禁 L0） |
| 思路复述已呈示 | 2026-10-02 按 28.2.1（ask） |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|-----------|
|       | 1       |            | → progress.md Error Log |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions
- Log ALL errors

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4（rate 0.75 verdict 预期 ok；Phase 2 线 B 宪法=④ 用户显式授权白名单） |
| 主进程直做 Phase 清单 | Phase 2 线 B（④ 宪法④用户授权）+Phase 3 部署编排（①）+Phase 4（② 簿记+③ memory）+checkpoint 代补（代理未回报按实物验证） |
| 委派率 | 0.75；验证独立性：五波 fresh 子代理 |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|----------------|------|
| 1 | | executor | Phase 1 回流普查 | queued | | | | plans/task-v115/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | 线 A 回流+级联 | queued | | | | plans/task-v115/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | 线 C 注释补强 | queued | | | | plans/task-v115/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 3 回归 | queued | | | | plans/task-v115/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 4 对齐审查 | queued | | | | plans/task-v115/subagent-state/5-executor.md | - / 0 / ☐ |
