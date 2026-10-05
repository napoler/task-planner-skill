# Task Plan: 技能修复普及化机制 — 案例抽象为通用规则

## 🎯 用户需求原文

- **R1**: 「当前技能在运行过程中还是存在一个严重性的缺陷。比如说在运行，在针对于技能的修正中，没有能做到真正的普及化，就是说，举个例子来说吧。我发现在撰写技能的撰写，就是剧本的技能中存在着某一个缺陷。我提示了这个这种是一个非常明确的缺陷了之后，在修改并要求修改到技能固化，确保后期不会出现问题的时候，他只是嗯他会将这个缺陷案例记录到技能中，却没有作为就是将这个案例做大众化的适用性匹配。这种嗯这种操作导致的后果就是，实际在你在测试这种情况是否调用新的技能之后是否会存在还是存在问题的时候，显示已经解决了，但实际遇到类似稍微改变一些的问题，可能说就不具有不具有解决的能力了。因为非常明显，你将一个将一个非常明确的错误案例记录在案，但是并没有做适配性的普及化处理，导致的结果就是，在解决这个案例类相关性极强的事情的时候，可以解决的非常好，但是稍微做普及稍微改变一下，可能说就已经没有解决能力了。所以你现在需要处理一下这种情况，确保在执行的时候不会出现这种低级的错误。就是我的针对做普及性处理。」

### R→VC 映射
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-4, VC-5 | 普及化机制已建立 + 具体案例已抽象为通用规则 + 消费侧可消费 + 回归验证通过 + 无功能回退 |

## 🧮 根源覆盖表

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 缺陷记录（Rule 31.4） | 只记录具体案例，未抽象为通用规则 | 增加"普及化抽象"步骤 | VC-1 |
| 沉淀格式（notepad-learnings） | "触发条件+防线一句话"过于具体 | 增加"通用规则"段落 | VC-2 |
| 消费侧（Rule 31.5） | 消费时只读具体案例，无通用规则可匹配 | 消费时优先匹配通用规则 | VC-3 |
| 技能修改（Rule 36） | 修改时只针对具体案例，未考虑普及化 | 修改前必须完成普及化抽象 | VC-1, VC-2 |
| 跨任务模式提取 | 无机制汇总多个任务的 learnings | 建立跨任务模式提取机制 | VC-2 |

## Goal

建立技能修复的普及化机制，确保缺陷修复时不仅记录具体案例，还抽象为通用规则，使修复对类似场景具有泛化能力。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v134` |
| `scope_files` | `["SKILL.md", "references/critical-rules.md", "templates/notepad-learnings.md", "references/methodology.md"]` |
| `interaction_mode` | `ask` |
| `对齐审查` | 任务产出文档完成前跑 alignment-review |
| `自动超时默认项` | 无 2+ 选项询问点 |
| `new_rule` | `31.7`（普及化抽象步骤，作为 Rule 31 的子条款） |
| `质量审查工具` | 无缺口（本任务为技能改进，不涉及外部质量审查工具） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 31 增加"普及化抽象"步骤，要求修复时不仅记录具体案例还抽象为通用规则 | grep "普及化" references/critical-rules.md | `grep -n "普及化" ~/.zcode/skills/task-planner/references/critical-rules.md` |
| VC-2 | notepad-learnings.md 模板增加"通用规则"段落 | Read templates/notepad-learnings.md 确认段落存在 | `grep -n "通用规则" ~/.zcode/skills/task-planner/templates/notepad-learnings.md` |
| VC-3 | 消费侧（Rule 31.5）增加"优先匹配通用规则"逻辑 | grep "通用规则" references/critical-rules.md | `grep -n "通用规则" ~/.zcode/skills/task-planner/references/critical-rules.md` |
| VC-4 | 具体案例已抽象为通用规则（以"剧本技能缺陷"为例） | Read notepad-learnings.md 确认通用规则已写入 | `grep -n "通用规则" plans/task-v134/notepad-learnings.md` |
| VC-5 | 回归验证通过，无功能回退 | selftest 全量 0 FAIL | `bash ~/.zcode/skills/task-planner/scripts/selftest-all.sh` |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能文件 | `~/.zcode/skills/task-planner/SKILL.md` | 其他技能文件 |
| 规则文件 | `~/.zcode/skills/task-planner/references/critical-rules.md` | 其他 references 文件 |
| 模板文件 | `~/.zcode/skills/task-planner/templates/notepad-learnings.md` | 其他模板文件 |
| 方法论 | `~/.zcode/skills/task-planner/references/methodology.md` | 其他方法论文件 |
| 计划文件 | `plans/task-v134/*` | 其他计划文件 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | Rule 31 错误学习闭环 | `~/.zcode/skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 规范/标准 | Rule 36 技能修改保守化 | `~/.zcode/skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 项目内部文档/知识库 | notepad-learnings 模板 | `~/.zcode/skills/task-planner/templates/notepad-learnings.md` | 必读 | ☑ |
| 项目内部文档/知识库 | SKILL.md 主文件 | `~/.zcode/skills/task-planner/SKILL.md` | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 技能修复时只记录具体案例，没有做普及化/泛化处理，导致修复只对特定案例有效，稍微变化场景就失效。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是，普及化机制建立后，修复将具有泛化能力
- [x] 核心问题不解决，其他工作都白费吗？— 是，每次修复都只解决具体案例，类似问题会反复出现
- [x] 核心问题的解决方法是清晰的、可执行的？— 是，在 Rule 31 增加普及化抽象步骤 + notepad 增加通用规则段落

## Current Phase

Phase 1

## Next Step

派发子代理完成 Phase 1：调研现有修复流程的详细实现，确认普及化机制的切入点。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) | 只读调研现有规则实现 |
| Phase 2 | Agent 子代理 plan-writer(sonnet-1) | 计划文件撰写 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) | 技能文件小改（≤3 文件 ≤300 行） |
| Phase 4 | Agent 子代理 code-runner-agent(mini) | 回归验证 selftest |
| Phase 5 | 主进程 | 簿记+交付（白名单②） |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源

## Phases

### Phase 1: Requirements & Discovery
- [x] 理解用户意图
- [x] 识别约束和需求
- [x] 调研现有修复流程规则
- [x] 知识储备必读项已确认可获取
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 调研现有修复流程规则 | 继承 | ~/.zcode/skills/task-planner/references/critical-rules.md | 规则摘要输出 | 10min | complete |

### Phase 2: Planning & Structure
- [x] 设计普及化机制的具体实现方案
- [x] 确定 Rule 31 新增子条款的内容
- [x] 确定 notepad-learnings 模板的修改
- [x] 确定消费侧的修改
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation
- [x] 修改 critical-rules.md — Rule 31 增加普及化抽象步骤
- [x] 修改 notepad-learnings.md 模板 — 增加通用规则段落
- [x] 修改 SKILL.md — 更新 Rule 31 描述
- [x] 修改 methodology.md — 增加普及化方法论
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 修改 critical-rules.md Rule 31 增加普及化抽象步骤 | 继承 | ~/.zcode/skills/task-planner/references/critical-rules.md | grep "普及化" 命中 | ≤15min | pending |
| S2 | 修改 notepad-learnings.md 模板增加通用规则段落 | 继承 | ~/.zcode/skills/task-planner/templates/notepad-learnings.md | grep "通用规则" 命中 | ≤15min | pending |
| S3 | 修改 SKILL.md 更新 Rule 31 描述 | 继承 | ~/.zcode/skills/task-planner/SKILL.md | grep "普及化" 命中 | ≤15min | pending |
| S4 | 修改 methodology.md 增加普及化方法论 | 继承 | ~/.zcode/skills/task-planner/references/methodology.md | grep "普及化" 命中 | ≤15min | pending |

### Phase 4: Testing & Verification
- [x] 运行 selftest 全量验证
- [x] 验证普及化机制的具体案例抽象
- [x] 确认无功能回退
- **V-N:** VC-5
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 运行 selftest 全量验证 | 继承 | ~/.zcode/skills/task-planner/scripts/selftest-all.sh | 0 FAIL | 10min | pending |
| S2 | 验证普及化机制的具体案例抽象 | 继承 | plans/task-v134/notepad-learnings.md | 通用规则段落存在 | 5min | pending |

### Phase 5: Delivery
- [x] 审查所有输出文件
- [x] 确保交付物完整
- [x] 交付给用户
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v134` |
| `branch` | `wt/task-v134` |
| `merge_back` | `merged(7950aac)` — 含 49603c3（普及化 4 文件）+ 44.5 配套 selftest 提交；worktree 已清理、分支已删 |

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|------------|---------------------------------------------|
| Phase 3 | 技能文件修改引入回归 | 7 | 3 | 4 | 84 | 拆细 S-unit |
| Phase 4 | selftest 失败 | 8 | 2 | 3 | 48 | 主进程接管修复 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-05 | 已完成 |
| Phase 2 | ☐ | | |
| Phase 3 | ☐ | | |
| Phase 4 | ☐ | | |
| Phase 5 | ☐ | | |

## Key Questions

1. 普及化抽象的具体格式是什么？（通用规则段落的结构）
2. 如何确保消费侧能正确匹配通用规则？
3. 是否需要建立跨任务的模式提取机制？

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 在 Rule 31 增加 31.7 普及化抽象步骤 | 作为错误学习闭环的延伸，确保修复具有泛化能力 |
| notepad-learnings 增加"通用规则"段落 | 将具体案例抽象为可复用的通用规则 |
| 消费侧优先匹配通用规则 | 确保通用规则被实际消费 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| | | | |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead
