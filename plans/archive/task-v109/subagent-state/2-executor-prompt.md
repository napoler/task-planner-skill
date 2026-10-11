# Phase 2 任务书（subagent-state/2-executor-prompt.md）

执行体：executor · WT = /mnt/data/dev/task-planner-skill-worktrees/task-v109
设计稿权威源：/mnt/data/dev/task-planner-skill/plans/task-v109/subagent-state/1-executor.md「设计稿」节（M1-M5 全文）
范式参照：WT/skills/task-planner/templates/variant/bugfix-type.md（v108 后标准区块集）

## 修复项（一新建+七级联）

**N-01 新建** `WT/skills/task-planner/templates/variant/memory-hygiene-type.md`：
- 头部：`# Task Plan: [记忆整理任务名称]` + `<!-- template_type: memory-hygiene -->` + `<!-- plan_tier: standard -->` + 适用场景注释
- 标准区块全集（对齐 bugfix-type.md 范式，v108 后）：Goal / 🔍 Code Review 配置（含 code_review/session_id/worktree_path/scope_files/interaction_mode/**对齐审查/自动超时默认项/质量审查工具** 3 行）/ ✅ Verification Contract（含**验证独立性**行——task_plan.md:48 同款）/ ⚠️ 执行范围限制（记忆目录盘点只读面/修正版落计划目录面/删除禁执行）/ 📚 必要知识储备 / ⚠️ 核心问题定义 / Current Phase / Next Step / 🧰 工具选择与编排（Rule 40） / Phases（Phase 1 盘点→Phase 2 处置执行→Phase 3 修正版产出→Phase 4 独立验证的通用四 Phase 骨架+S-unit 空表）/ 🔀 隔离决策 / 📊 FMEA 预演 / 🔁 Todo 同步 / Key Questions / Decisions Made / Errors Encountered / Notes / 🚨 Drift Log / 📊 委派统计 / 🔗 Subagent Handoff 登记表
- 记忆特有区块（设计稿 M1-M5 全文嵌入 Phases 区块后，作为「📋 记忆整理协议（本模板核心合约）」节）：M1 盘点表列定义 / M2 四维校验动作（机械命令范式）/ M3 处置枚举与守门（删除类仅建议）/ M4 验证锚规范+MEMORY.md.proposed 产出契约 / M5 写入规范三要素（绝对日期/验证锚/失效条件）
- 精炼原则：标准区块可精简注释但结构齐备；特有区块全量保留设计稿语义

**N-02 级联**（16→17 variant 口径，7 文件）：
- `WT/skills/plan-template-kit/references/template-mapping.md`：§一 清单补 1 行 `templates/variant/memory-hygiene-type.md`（16→17）；§六 速查表补 1 行（memory-hygiene｜记忆体系盘点/整理/治理｜通用组-记忆卫生）；§九 矩阵补 1 行（17 行：17 variant+general；memory-hygiene 标「通用组」画像）
- `WT/skills/task-planner/companion/agents/plan-writer.md` 映射表补 1 行（17 行）
- `WT/skills/task-planner/SKILL.md` :274「standard 16 variant」→「standard 17 variant」
- `WT/skills/task-planner/references/critical-rules.md` :348「17 行：16 variant+general」→「18 行：17 variant+general」；:361「现有 16 个 variant」→「现有 17 个 variant」
- `WT/skills/plan-template-kit/references/template-guide.md` §2.2 variant 表补 1 行（16→17 行）
- `WT/skills/task-planner/scripts/selftest-template-lifecycle.sh`：TL-17 断言与消息中「16 个」→「17 个」（两处：注释行 :20 与断言行 :84；其他 TL 断言不动）

## 验收
1. `git -C WT status --porcelain` 恰 8 文件（1 新建+7 级联）
2. 计数自洽：mapping §一=17、§六=17、§九=18 行；SKILL/critical-rules「17 variant」命中且「16 variant」零残留；guide §2.2=17 行；grep「16 个」TL-17 上下文已改 17
3. `bash WT/skills/task-planner/scripts/selftest-template-lifecycle.sh` → 18/18 PASS（TL-17 改后自洽）
4. 新模板 `bash WT/skills/task-planner/scripts/check-template-type.sh <新建模板路径>` exit 0（memory-hygiene 白名单动态派生）
5. checkpoint 落盘含最终结论 8 字段块

## Scope 禁改
只改上述 8 文件；其他 variant/selftest 不动；禁止 git add/commit；禁动 worktree 外文件

## 返回格式（8 字段，无内容填 none，8 字段后不得有任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<5> pass — 逐项原文行
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:2-executor]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
