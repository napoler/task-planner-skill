# Task Plan: task-planner 智能拆分分析机制（Phase 2.5）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「当前所谓的子代理拆分还是存在严重的缺陷。比如说完成对一，比如说现在存在的情况就是将一个很大的任务拆分到一个单独的子代理去解决。这样会导致的就是，看上去很少，其实是很大。比如说对于短剧剧本创作的时候，一个子代理执行的任务是完成这一集剧本的创作。这是看，这件事看上去很少，但实际上工作起来可能说远远都很大。」
- **R2**: 「这些完全可以拆成更加细致的，比如说上面第一个提示词，第一个提示词的重构上，完全可以写成第一段的重构或者第二段的重构这样的。还有第二个关键帧的重抽，也可以改成第一段的关键帧重抽，第二段的关键帧重抽。但是你现在的是一股脑的全部丢给一个代理去做，尤其像关键帧重抽这种，也许可能一集包含几十段，那么几十段就可能说明每一段都需要可能需要几十次的重抽，那么整体算下来的工作量极其庞大。」
- **R3**: 「而且还有就是从成本来考虑的话，子代理分段执行也是更加合理的。比如说我上面提到的这个任务中，剧本创作分多段的情况下，完成第一段的创作之后，然后你在后面的创作中，会不断地携带是第一段创作、第二段创作之前的，这样不断地累积上下文，其实是没有意义的，所以需要进行拆分式，在不同的子代理中运行，可以更加节省」
- **R4**: 「我发现你拆分就是拆分子代理竟然使用的是完全依赖于脚本，为什么不能耗费一些一些算力，直接用子代理进行拆分任务呢？难道说子代理去分析这些任务的工作量会很复杂吗？」
- **R5**: 「我的核，我的核心需要表达的就是呃子代理和脚本相互配合」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | Phase 2.5 智能拆分分析环节已定义（critical-rules.md Rule 21.1c） |
| R2 | VC-2 | 内容创作类任务按内容单元拆分（段落/镜头/关键帧） |
| R3 | VC-3 | 拆分到不同子代理中运行，避免上下文累积 |
| R4 | VC-4 | 用子代理（LLM）智能分析任务工作量 |
| R5 | VC-5 | 子代理和脚本相互配合（子代理分析+脚本校验） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划期拆分 | 拆分决策静态，预估时长只是简单预估，无详细分析 | Phase 2.5 智能拆分分析环节 | VC-1 |
| 执行期派发 | 内容创作类任务无特殊处理，30 镜头视频生成可能只含 1 个"步骤"而通过检测 | 内容创作类任务按内容单元拆分 | VC-2 |
| 上下文管理 | 连续创作多段内容时上下文不断累积，造成 token 浪费 | 拆分到不同子代理中运行 | VC-3 |
| 拆分判断 | 拆分判断归模型（LLM 自律），机器守卫只做机械校验 | 用子代理（LLM）智能分析任务工作量 | VC-4 |
| 子代理+脚本配合 | 当前机制缺乏子代理和脚本的配合 | 子代理分析+脚本校验 | VC-5 |

## Goal

在 task-planner 技能的 Phase 2（Planning）和 Phase 3（Implementation）之间插入 Phase 2.5（智能拆分分析）环节，用子代理（LLM）智能分析任务工作量，用脚本做机械校验，解决当前拆分粒度太粗的问题。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v135` |
| `scope_files` | `references/critical-rules.md, SKILL.md, scripts/check-dispatch.sh, scripts/analyze-splits.sh, references/dispatch-examples.md` |
| `interaction_mode` | `silent` |
| `对齐审查` | `任务完成后运行 alignment-review` |
| `自动超时默认项` | `无 2+ 选项询问点` |
| `new_rule` | `21.1c` |
| `质量审查工具` | `n/a（技能文件修改任务，不涉及质量审查面）` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Phase 2.5 智能拆分分析环节已定义 | Read critical-rules.md 确认 Rule 21.1c 存在 | `grep "21.1c" references/critical-rules.md` |
| VC-2 | 内容创作类任务按内容单元拆分 | Read critical-rules.md 确认内容单元拆分策略 | `grep "内容单元" references/critical-rules.md` |
| VC-3 | 拆分到不同子代理中运行，避免上下文累积 | Read critical-rules.md 确认上下文累积避免策略 | `grep "上下文累积" references/critical-rules.md` |
| VC-4 | 用子代理（LLM）智能分析任务工作量 | Read critical-rules.md 确认子代理分析策略 | `grep "子代理.*分析" references/critical-rules.md` |
| VC-5 | 子代理和脚本相互配合 | Read critical-rules.md 确认子代理+脚本配合策略 | `grep "子代理.*脚本" references/critical-rules.md` |
| VC-6 | SKILL.md 已更新 Phase 2.5 描述 | Read SKILL.md 确认 Phase 2.5 描述存在 | `grep "Phase 2.5" SKILL.md` |
| VC-7 | analyze-splits.sh 脚本已创建 | Read scripts/analyze-splits.sh 确认脚本存在 | `test -f scripts/analyze-splits.sh` |
| VC-8 | check-dispatch.sh 已更新内容创作类任务校验 | Read scripts/check-dispatch.sh 确认内容创作类任务校验存在 | `grep "内容创作" scripts/check-dispatch.sh` |
| VC-9 | dispatch-examples.md 已更新内容创作任务派发示例 | Read references/dispatch-examples.md 确认内容创作任务派发示例存在 | `grep "内容创作" references/dispatch-examples.md` |
| VC-10 | selftest 通过无回归 | 运行 selftest 脚本确认无回归 | `bash scripts/selftest.sh` |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | `scripts/check-dispatch.sh`, `scripts/analyze-splits.sh` | 其他 .sh 文件 |
| 文档 | `references/critical-rules.md`, `SKILL.md`, `references/dispatch-examples.md` | 其他文档 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | task-planner critical-rules.md | `~/.zcode/skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 项目内部文档/知识库 | task-planner SKILL.md | `~/.zcode/skills/task-planner/SKILL.md` | 必读 | ☑ |
| 项目内部文档/知识库 | task-planner check-dispatch.sh | `~/.zcode/skills/task-planner/scripts/check-dispatch.sh` | 必读 | ☑ |
| 项目内部文档/知识库 | task-planner dispatch-examples.md | `~/.zcode/skills/task-planner/references/dispatch-examples.md` | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 当前 task-planner 的子代理拆分机制存在粒度缺陷，大任务被整体分配给一个子代理，没有细化到更小的可执行单元。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是，拆分粒度细化后，子代理执行质量提升
- [x] 核心问题不解决，其他工作都白费吗？— 是，拆分粒度太粗导致子代理执行质量下降
- [x] 核心问题的解决方法是清晰的、可执行的？— 是，插入 Phase 2.5 智能拆分分析环节

## Current Phase

Phase 1

## Next Step

完成 Phase 1 调研，进入 Phase 2 规划

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（mini） | 调研当前拆分机制 |
| Phase 2 | 主进程（例外理由:② 计划系统文件维护） | 规划 Phase 2.5 方案 |
| Phase 3 | Agent 子代理 code-assistant（haiku-1） | 修改技能文件 |
| Phase 4 | Agent 子代理 code-runner-agent（mini） | 运行 selftest 验证 |
| Phase 5 | 主进程（例外理由:① git 编排+② 簿记） | 终验交付 |

## Phases

### Phase 1: Requirements & Discovery
- [x] Understand user intent
- [x] Identify constraints and requirements
- [x] Document findings in findings.md
- [x] 知识储备必读项已确认可获取
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** explore（mini）

### Phase 2: Planning & Structure
- [x] Define technical approach
- [x] Create project structure if needed
- [x] Document decisions with rationale
- **V-N:** VC-1, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation
- [ ] 新增 Rule 21.1c 定义智能拆分分析（critical-rules.md）
- [ ] 修改 SKILL.md 插入 Phase 2.5 描述
- [ ] 新增 analyze-splits.sh 脚本（子代理+脚本配合）
- [ ] 修改 check-dispatch.sh 增加内容创作类任务校验
- [ ] 更新 dispatch-examples.md 补充内容创作任务派发示例
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6, VC-7, VC-8, VC-9
- **Status:** in_progress
- **Executor:** code-assistant（haiku-1）

### Phase 4: Testing & Verification
- [ ] 运行 selftest 验证修改无回归
- [ ] 验证所有 VC 通过
- **V-N:** VC-10
- **Status:** pending
- **Executor:** code-runner-agent（mini）

### Phase 5: Delivery
- [ ] Review all output files
- [ ] Ensure deliverables are complete
- [ ] Deliver to user
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6, VC-7, VC-8, VC-9, VC-10
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（技能文件修改，属于运行中基础设施） |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v135` |
| `branch` | `wt/task-v135` |
| `merge_back` | `pending` |

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | 技能文件修改导致回归 | 8 | 3 | 4 | 96 | 拆细重派 |
| Phase 4 | selftest 失败 | 7 | 3 | 3 | 63 | 拆细重派 |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 插入 Phase 2.5 智能拆分分析环节 | 解决当前拆分粒度太粗的问题 |
| 用子代理（LLM）智能分析任务工作量 | 内容创作类任务的实际工作量难以用文件数/行数机械衡量 |
| 用脚本做机械校验 | 机械校验拆分后的 S-unit 表是否满足 21.1b 上限 |
| 内容创作类任务按内容单元拆分 | 避免上下文累积造成的 token 浪费 |
| 走 worktree 隔离 | 技能文件修改属于运行中基础设施 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead
