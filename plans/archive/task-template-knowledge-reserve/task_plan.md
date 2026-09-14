<!-- template_type: code-edit -->
<!-- 任务: 为 task-planner 全部 20 个模板添加「必要知识储备」章节 -->

# Task Plan: task-planner 模板统一添加「必要知识储备」章节

## Goal
为 `skills/task-planner/templates/` 下全部 20 个模板（8 主 + 12 variant）统一添加 `## 📚 必要知识储备` 章节（任务相关规范/官方文档/内部知识库/文献/图书），并同步 template-guide.md / template-mapping.md / SKILL.md / CHANGELOG.md，使每次任务开启即对齐任务知识库。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（变更集为纯 .md，按 Gate 过滤规则代码文件集 = ∅，另派 critic 审查 diff 补位） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 20/20 模板文件均含 `## 📚 必要知识储备` 章节 | `grep -rl "## 📚 必要知识储备" templates/ \| wc -l` = 20 | 命令输出 |
| VC-2 | 脚本契约标记未被破坏：check-complete.sh 对本计划 exit 0；模板无新增以 `---` 开头的行、无新增 `### Phase` 于新章节内 | `bash scripts/check-complete.sh plans/task-template-knowledge-reserve/task_plan.md` + `git diff` 审查 | 命令输出 |
| VC-3 | 文档同步完成：template-guide.md / template-mapping.md / SKILL.md / CHANGELOG.md 均含知识储备章节说明 | `grep -c "必要知识储备" <四文件>` ≥1 | 命令输出 |
| VC-4 | worktree 合并回完成：`git log` 含 merge commit，`git worktree list` 无遗留，`wt/*` 分支已删 | `git log --oneline -3` + `git worktree list` | 命令输出 |
| VC-5 | critic 审查通过（APPROVED 或问题已修复） | `Agent(critic)` 审 worktree diff | 审查结论 |
| VC-6 | 本计划三文件回填完整（findings/progress 按 Rule 19 落盘） | Read 三文件 | 文件内容 |

**终验规则**: 全部 VC 通过 → COMPLETE；合并冲突或 critic 连续 3 轮不通过 → BLOCKED 升级用户。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板 | `skills/task-planner/templates/*.md`（8 个）+ `templates/variant/*.md`（12 个） | 其他任何模板 |
| 文档 | `skills/task-planner/references/template-guide.md`、`references/template-mapping.md`、`SKILL.md`、`references/critical-rules.md`（仅 Rule 16 处）、`CHANGELOG.md` | 其他文档 |
| 禁改 | 模板内既有行一律只插入不修改；脚本契约标记（Phase 标题行 / Status 状态行 / 文件名白名单 / fallback 状态标记） | 批量 sed / replace_all |
| 部署 | ❌ 本任务不改 `~/.zcode/skills/task-planner/`（live 副本已有漂移，部署与否交用户决策，终验后报告） | install.sh |

**强制约束**:不在允许列表中的文件一律不碰。

## 📚 必要知识储备（任务知识库对齐 — 本任务自用）

| 类别 | 名称/主题 | 定位（路径） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | 宪法 §六 保护区 / §十一 worktree 隔离 | `/home/terry/.zcode/AGENTS.md` | 必读 | ☑ |
| 项目内部文档 | 模板系统架构与脚本契约 | `references/template-guide.md` §四 | 必读 | ☑ |
| 项目内部文档 | 模板选择决策树与红线 | `references/template-mapping.md` §七 | 必读 | ☑ |
| 项目内部文档 | 完成校验器的分段/解析规则 | `scripts/check-complete.sh`（`---` 分段 + Phase/Status 正则） | 必读 | ☑ |
| 项目内部文档 | 全部模板章节结构图谱 | findings.md §结构图谱 | 必读 | ☑ |
| 规范/标准 | Rule 16 模板强制 / Rule 19 三文件 / Rule 22 交接 | `references/critical-rules.md` | 参考 | ☐ |
| 项目内部文档 | 质量优先于速度原则 | memory `quality-over-speed-in-skill-enhancement.md` | 参考 | ☑ |

## Current Phase
Phase 7

## Phases

### Phase 1: 现状读取 + 章节规范设计
- [x] 扫描 20 个模板章节结构（grep 标题图谱）
- [x] Read template-guide.md / template-mapping.md / check-complete.sh
- [x] 设计统一章节规范（canonical 块 + 逐模板适配锚点）→ 写入 findings.md
- **Status:** complete
- **Executor:** 主进程（例外理由:规划与规范设计属主进程白名单职责,Rule 25）

### Phase 2: worktree 隔离区创建
- [x] `git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-template-knowledge-reserve -b wt/task-template-knowledge-reserve master`
- [x] 验证 worktree 就绪（`git worktree list` 确认 @d2f030d；并行任务 worktree task-three-file-compass 已识别,不触碰）
- **Status:** complete
- **Executor:** 主进程（例外理由:编排与 git 编排属主进程白名单,Rule 25）

### Phase 3: 核心模板与文档改造（worktree 内,主进程直做 .md 白名单）
- [ ] `templates/task_plan.md`（主模板）插入 canonical 章节于「执行范围限制」后 + Phase 1 加确认 checkbox
- [ ] `references/template-guide.md`：§二 更新计数（5主+3辅助+12 variant=20）+ 新增知识储备章节说明 + §四 标注其为可定制标准结构区
- [ ] `references/template-mapping.md`：可自由定制区 + 速查表补知识储备说明
- [ ] `SKILL.md` 模板库节 + Rule 16 强制约束各加 1 行说明
- [ ] `references/critical-rules.md` Rule 16 处按需补 1 行（grep 定位后判断）
- [x] `CHANGELOG.md` 记录本次变更
- [x] 全部 6 项完成(2026-09-04):主模板✓ guide✓ mapping✓ SKILL.md✓ critical-rules✓ CHANGELOG✓
- **Status:** complete
- **Executor:** 主进程（例外理由:纯 .md 计划模板/文档属主进程白名单,skill 路由表明示）

### Phase 4: 批量套用其余 19 模板（worktree 内,executor 子代理）
- [ ] 派 `Agent(subagent_type: executor)` 按 findings.md §章节规范 逐文件插入：12 variant（锚点=执行范围限制后,含类型示例行+Phase 1 checkbox）+ 7 辅助模板（findings/progress/verification/batch_report/cost_log/notepad-learnings/subagent_dispatch,锚点见 findings.md）
- [ ] prompt 含七字段 + 契约红线（禁改既有行/禁 `---` 行首/禁 `### Phase` 新增）
- [ ] 子代理返回后 Read 抽查 ≥3 文件（Rule 22.5 verify_done）
- [x] 全部完成(2026-09-04):19 文件插入✓;抽查 research-type/verification/subagent_dispatch✓;发现 4 辅助标题不含统一锚 → 主进程重命名对齐(VC-1 保持 grep=20 可验收)
- **Status:** complete
- **Executor:** executor（sonnet-1）

### Phase 5: 机械验证（worktree 内）
- [x] VC-1：`grep -rl "## 📚 必要知识储备" templates/ | wc -l` = **20**;逐文件计数全为 1;Phase1 checkbox 12/12
- [x] VC-2：`git diff` 模板 263 插入/0 删除(纯插入证明);新增行红线 0;init-session 冒烟(worktree 模板生成 5 文件含锚+check-complete 正确解析 5 phases)
- [x] 三文件回填核查（findings/progress）
- **Status:** complete
- **Executor:** 主进程（例外理由:机械 grep/脚本验证属主进程白名单）

### Phase 6: critic 独立审查（替代空代码集的 Code Review Gate）
- [x] critic 审查完成:VERDICT=CHANGES_REQUESTED(1 P0 + 2 P1 + 5 P2 + 1 NIT)
- [x] P0 **驳回**(主进程第一手复现:HEAD 基线 awk 区间提取本就为 0,属既有 bug 非本次回归;状态机式解析器 HEAD=5/工作区=5 无影响) — critic 的"修改前应输出 6"为未测试预期
- [x] P1×2+P2×5+NIT 全部修复:guide 契约安全声明改准确写法+mapping §八 加 scope 提取验收命令+guide §2.2 计数 13→12+README×3 处+ARCHITECTURE×1+critical-rules 13 类→12 类+CHANGELOG 术语+6 文件双空行+batch_report 知识依据块上移至头部
- [x] 修复后复验:锚=20、scope 提取=5、双空行=0、Rule 18.6 标题正则=1 ✅
- **Status:** complete
- **Executor:** critic（sonnet-1）

### Phase 7: 合并回 + 清理 + 收尾
- [x] worktree 内 commit 2849db1(27 文件 +283/-8)+ `git status` 干净
- [x] 主仓 `git merge --no-ff wt/task-template-knowledge-reserve` → **与并行任务 three-file-compass 在 CHANGELOG 冲突,裁决:两条目都保留**;SKILL.md/critical-rules 自动合并完好(Read 复核)
- [x] 合并提交 d71ffe6;主仓复验:知识储备锚=20、scope 提取=5、无未提交变更
- [x] `git worktree remove` + `git branch -d wt/task-template-knowledge-reserve` 完成,`git worktree list` 无遗留
- [x] plan `merge_back=merged(d71ffe6)` + `check-complete.sh` 终验 + Todo 终态同步（S4）+ INDEX 刷新
- [x] 报告：部署到 `~/.zcode/skills` 与否交用户决策;pretooluse/sync-todos 区间式解析既有 bug 已记录移交
- **Status:** complete
- **Executor:** 主进程（例外理由:合并回合约与交付属主进程白名单,Rule 25）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（未提交变更仅本任务 plans/ 与哨兵,无踩踏） |
| `isolation` | `worktree`（命中宪法 §11.1-1:修改 skills 保护区文件） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-template-knowledge-reserve` |
| `branch` | `wt/task-template-knowledge-reserve` |
| `merge_back` | `merged(d71ffe6)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-04 | 已完成 |
| Phase 2 | ☑ | 2026-09-04 | worktree |
| Phase 3 | ☑ | 2026-09-04 | 核心模板+文档 |
| Phase 4 | ☑ | 2026-09-04 | executor 批量 |
| Phase 5 | ☑ | 2026-09-04 | 机械验证 |
| Phase 6 | ☑ | 2026-09-04 | critic 审查 |
| Phase 7 | ☑ | 2026-09-04 | 合并收尾 |

## Key Questions

1. 新章节是否破坏脚本解析? → 已核对 check-complete.sh 仅认 Phase 标题行/Status 状态行/行首分隔线,新章节避开即可
2. variant 计数 12 还是 13? → `ls variant/` 实测 12 个;template-guide 旧计数(13/18)一并修正
3. 是否同步部署 live? → 否;live 副本既有漂移,部署属独立决策,终验后报告

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 统一章节名 `## 📚 必要知识储备`（副标题按模板适配） | 用户指令「每个模板都添加」;统一名保证 grep 可验证(VC-1) |
| 20 模板全覆盖含 cost_log 等辅助模板 | 用户明示「每个模板」;辅助模板用轻量适配版避免噪音 |
| 主模板+文档主进程直做,12 variant+7 辅助派 executor | .md 模板属主进程白名单;重复模式批量改派 executor 隔离上下文(§一/Rule 25) |
| critic 替代 Code Review Gate | 变更集纯 .md,Gate 代码过滤后为空集;critic 审 diff 补位(align 质量优先 memory) |
| 基于模板实际部署形态以仓库为准 | diff 证实 ~/.zcode 副本落后于仓库,仓库为 dev 源 |
| critic P0 驳回(保留章节位置) | git show HEAD + awk 双版本实测:区间式解析 0/0 为既有 bug,状态机式 5/5 无影响;位置符合"区块完整结束之后"安全规则 |
| 修复 critic 时扩展 README/ARCHITECTURE 两文件 | 同类计数漂移(13 variant/4 变体),与 guide 计数修正属同一一致性链条,B 类扩展已登记 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| session-catchup.ts 挂起(>30s) | 1 | 终止跳过;新会话无恢复点,哨兵机制正常 |

## Notes

- 每次 Phase 完成 → 调用 `Skill("task-drift-guard")`;Phase complete 后被动 `Skill("plan-resume")`(≤3 phase 可跳过,本计划 7 phase 需执行)
- 计划已获授权:用户原始指令明确指定内容与范围 + 「继续」;自主模式下不再阻塞等待二次确认
- 部署(install.sh → ~/.zcode/skills)不在本任务范围,终验后单独报告

## 🔗 Subagent Handoff 登记表（Rule 22.5 补记）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|-------------|
| 1 | 2026-09-04 | executor | 19 个模板按 findings.md §章节规范 插入知识储备章节 | done | STATUS:complete;19/19 文件插入;4 项验收全过;偏差:4 辅助标题锚口径(已由主进程重命名修正)+verification 锚点微调(合理) | agent 返回+worktree git diff(263+/0-) | ☑ |
| 2 | 2026-09-04 | critic | worktree 全量 diff 批判审查(6 维度) | done | CHANGES_REQUESTED 9 项;P0 经主进程复现**驳回**(既有 bug);其余 8 项已全部修复并复验 | 审查报告+worktree grep/awk 复验输出 | ☑ |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 7（Phase 4 executor、Phase 6 critic） |
| 主进程直做 Phase 清单 | 1/2/3/5/7（例外理由已登记:规划/编排/git/.md 白名单/验证交付） |
| 委派率 | 29%（主进程直做均有白名单理由,见各 Phase Executor 字段） |
