<!-- template_type: mini-lite -->
execution_lane: L0（L0-T 纯文本档，Rule 38.7——规则类诉求落 .md 文本即告完成，零新增脚本/零 config 键/零 hook）
<!-- plan_tier: mini -->
<!-- auto_tier: mini -->
<!-- 适用场景: 轻量任务（≤2 文件 ∧ 预估 ≤15min ∧ 单模块）——跳过中/重仪式区块，中/重任务禁用本模板（Rule 38.2） -->
<!-- 触发关键词: 轻量/小改/单文件/快修/微调/15 分钟/小任务 -->
<!-- 推荐 subagent: 主进程直做（白名单②）或 executor(haiku) 单文件小改；无强制派发 -->
<!-- 38.3 区块白名单: 仅 Goal/VC/执行范围限制表/单 Phase/Handoff 表, 增其他仪式区块=模板违约(selftest-plan-tier 断言); [task-v094 T-B2] 2 Phase→单 Phase(实施+验收合一) -->
<!-- Rule 40.2 豁免声明（task-v097）: mini 档不加「🧰 工具选择与编排」区块——Rule 38.3 轻量模板区块白名单的自然延伸,mini 免计划期工具分析仪式;显式声明以防误判缺区块为违约 -->
<!-- Rule 42.5 豁免声明（task-v099）: mini 档不含「质量审查工具」配置行——Rule 38.3 轻量模板契约的自然延伸（同 40.2 豁免行范式） -->
<!-- Rule 42.6 豁免声明（task-v102）: mini 档不含「对齐审查」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5 豁免行范式） -->
<!-- Rule 44 豁免声明（task-v103）: mini 档不含「自动超时默认项」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5/42.6 豁免行范式） -->

# Task Plan: Rule 31.8 诉求层级契约（制度层诉求禁降维为实例修复）

## Goal
把用户裁决的执行偏差（「修正 skill 确保某类 bug 不再出现」的制度层诉求被执行偏差为「修具体 bug 现场」的实例层动作）制度化为 skill 条款——Rule 31 新增 31.8 子条（纯增量，既有子条零改动），确保今后同类偏差被规则拦截。「预估 ≤15min」。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 31.8 条款在位：`skills/task-discipline/references/critical-rules-discipline.md` 含「31.8 **诉求层级契约」标题行+制度层/实例层/双层/存疑/31.3 衔接五段完整内容 | `grep -c "31\.8" <file>` ≥5 + Read 复核 | critical-rules-discipline.md |
| VC-2 | 纯增量零回归：既有 31.1-31.7 子条文本零改动（`git diff` 仅含新增行，无删除/修改既有行）；相关既有 selftest 子集 PASS | `git diff --stat` + `bash scripts/selftest-error-loop.sh` 等 | git 输出+test 输出 |
| VC-3 | 交付前单波 fresh 全量 selftest 零新增 FAIL（对照 master 基线） | `bash scripts/run-selftests.sh` | 终端输出 |

**终验规则**: 全部 VC 通过 → COMPLETE（VC ≥2，无 V-N 映射表；mini 档免逐 Phase V-N 映射，Rule 38.4②）

## ⚠️ 执行范围限制

| 改什么（scope_files ≤2） | 禁碰什么 |
|-------|------|
| `skills/task-discipline/references/critical-rules-discipline.md`（仅 Rule 31 段末追加 31.8） | 禁改任何具体业务 bug/实例代码（用户否定方向）；禁改核心 critical-rules.md/SKILL.md/其他卫星；禁动 `~/.zcode/` 部署位（部署同步待用户单独授权）；禁新增 selftest/脚本/机器门（L0-T 守护 opt-in） |

约束: 单模块；任一机器条件不满足 → [plan-tier] MISMATCH 提示，改回 standard 全量模板

## 🔀 隔离决策
L0-T 纯文本单文件追加 → 按 task-v177 先例（4bbc1f6，纯文本改动主仓 master 直接提交，未开 worktree）直接主仓操作；worktree 完整流程开销与本变更体量不成比例（宪法 §四.6）。

## Phases（固定 1：实施+验收合一，[task-v094 T-B2]；3-File 双条件在本 Phase 照常一次，Rule 19.2 降档）

### Phase 1: 实施+验收（合一）
- Edit critical-rules-discipline.md：Rule 31 段末（31.6 机制段后）追加 31.8 诉求层级契约子条（五段：制度层判定/实例层判定/双层并存/存疑询问/31.3 衔接，含用户裁决判例锚）
- Read 回填复核 + git diff 纯增量核验
- 跑 selftest-error-loop.sh + run-selftests.sh fresh 全量，对照基线零新增 FAIL
- commit（单 commit，Rule 27）+ check-complete + 归档
- **V-N:** VC-1, VC-2, VC-3（总计 ≥2，允许集中映射）
- **Status:** complete
- **Executor:** 主进程（白名单②⑥登记——L0-T 单文件纯文本，无强制派发）

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 1 | 无（全程主进程，L0-T 轻量档） | | - | | |

## new_rule
无新 Rule 编号——并入既有 Rule 31 作 31.8 子条（纯增量，避免编号级联；编号预留台账不涉及）
