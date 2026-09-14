# Task Plan: task-planner 三文件罗盘强制（findings/progress 及时回填 + task_plan 瘦身）

## Goal
让 task-planner 技能对每个任务强制、及时地维护 findings.md/progress.md（三文件罗盘），并治理 task_plan.md 单文件膨胀——通过终验门硬校验 + PostToolUse 提醒链路 + 规则条款（Rule 19.5/19.6/19.7）三层落地。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（变更全部为 .md/.sh/.json 技能配置文件，非业务代码） |
| `session_id` | `tfc-20260904-a1` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-three-file-compass` |
| `scope_files` | `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/scripts/check-complete.sh`, `skills/task-planner/scripts/init-session.sh`, `skills/task-planner/scripts/zcode-posttooluse.sh`, `skills/task-planner/config.json`, `CHANGELOG.md` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | check-complete.sh 三文件门生效：fixture ①缺 findings/progress → exit 1 且报缺失；②stub 模板未回填 → exit 1 且报 stub；③已回填 → 正常判定 | 构造 3 个 fixture plan 目录运行脚本对照 exit code | `bash skills/task-planner/scripts/check-complete.sh <fixture>/task_plan.md` |
| VC-2 | init-session.sh 在空目录运行后 5 文件全部存在且非空，并输出 `5/5` 复核行；任一文件创建失败 → exit 1 | 空临时目录运行 + 检查输出与文件 | `bash .../init-session.sh t && ls` |
| VC-3 | zcode-posttooluse.sh 输出含 findings/progress 罗盘提醒：findings.md 陈旧 fixture → JSON additionalContext 含 `[plan-compass]` 与 findings 关键词；新鲜 → 无该提醒 | 模拟 stdin JSON 运行 hook | `echo '{"cwd":"<fixture>"}' \| bash .../zcode-posttooluse.sh` |
| VC-4 | 规则层一致：SKILL.md 含 C16 条目、终验 3-File Gate 步骤、Rule 19.5/19.6/19.7 引用；critical-rules.md 含 19.5/19.6/19.7 条款；`[plan-compass]` 标签跨文件一致 | grep 对照两文件与脚本标签 | `grep -n "19\.[567]\|C16\|plan-compass" <files>` |
| VC-5 | 无回归：bash -n 三脚本零输出；config.json jq 解析合法；check-complete.sh 对既有 plans/task-quality-over-speed（含回填三文件）判定不误伤 | 运行语法检查 + 对旧 plan 目录跑门控 | `bash -n ... && jq . config.json` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> `code_review: n/a`，不触发 Code Review Gate。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文档 | `skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md` | 其他 references/*.md、README、examples |
| 脚本 | `skills/task-planner/scripts/{check-complete,init-session,zcode-posttooluse}.sh` | 其他 scripts/*（含 .ps1、check-drift.sh） |
| 配置 | `skills/task-planner/config.json` | `~/.zcode/cli/config.json`（hook 注册不在本任务范围） |
| 仓库文档 | `CHANGELOG.md` | README_zh.md、INSTALL_zh.md |
| 计划文件 | `plans/task-three-file-compass/*` | 其他 plans/* 目录 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 三文件体系"模板/规则存在但执行链路无强制"——终验门(check-complete.sh)不查 findings/progress 存在性与回填度，PostToolUse 提醒不覆盖 findings/progress，导致执行中信息滞留上下文产生漂移、内容全部涌入 task_plan.md。解决后即交付：门控 + 提醒 + 规则三层闭环，执行期不回填 = 终验无法通过。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？（VC-1~5 全可判定）
- [x] 核心问题不解决，其他工作都白费吗？（用户核心诉求即"确保及时补充"）
- [x] 核心问题的解决方法是清晰的、可执行的？（诊断已完成，见 findings.md）

## Current Phase
Phase 5（收尾：合并 + 部署同步）

## Next Step
主仓 merge --no-ff wt/task-three-file-compass → 清理 worktree/分支 → 部署副本同步 7 文件 → 终验汇报

## Phases

### Phase 1: 现状诊断与设计定稿
- [x] 摸清三文件体系现有接线（init/check-complete/posttooluse/SKILL.md/规则/模板）
- [x] 定位执行缺口根因（终验门无校验 + hook 提醒缺口 + 规则无瘦身条款）
- [x] 诊断结论与设计定稿落盘 findings.md
- **Status:** complete
- **Executor:** 主进程（例外理由:调研对象即本次必编辑的 6 个已知小文件（≤616 行），宪法 §一.5 勿过度委派；诊断结论直接服务 Phase 2/3 规格）

### Phase 2: 规则层修改（SKILL.md + critical-rules.md）
- [x] critical-rules.md 新增 Rule 19.5（三文件终验门）/19.6（task_plan 瘦身）/19.7（及时性提醒链路）
- [x] SKILL.md：合规清单加 C16、终验交付加 3-File Gate 步骤、Rule 19 索引行更新、Phase 循环 3d 加 [plan-compass] 响应、References 表同步
- **Status:** complete
- **Executor:** executor（sonnet-1）（实际执行:计划期为 .md 白名单改主进程,执行期为省主上下文改派 executor,5 处精确插入验收达标）

### Phase 3: 脚本层修改（4 文件，>3 → executor）
- [x] check-complete.sh 加 3-File Gate（存在性 + stub 判定 + task_plan.md 膨胀 WARNING）
- [x] zcode-posttooluse.sh 加 [plan-compass] findings/progress 陈旧提醒（独立冷却，单次最多一条）
- [x] init-session.sh 加 5 文件存在性复核（缺失/为空 → exit 1）
- [x] config.json 加 findings_stale_minutes/progress_stale_minutes 阈值
- **Status:** complete
- **Executor:** executor（sonnet-1）（>3 文件按 Rule 14 路由表）

### Phase 4: 回归验证（VC-1~5）
- [x] bash -n 三脚本 + jq config.json
- [x] check-complete.sh 三场景 fixture + 旧 plan 回归
- [x] posttooluse 四场景冒烟（陈旧/新鲜/progress陈旧/旧state兼容）
- [x] init-session.sh 空目录冒烟
- [x] 跨文件一致性 grep（19.5/19.6/19.7/C16/plan-compass）
- **Status:** complete
- **Executor:** 主进程（例外理由:验证为 ≤8 条确定性命令，输出均可直接判定，委派开销>收益，宪法 §一.5）

### Phase 5: 合并交付与部署同步
- [x] worktree 内 commit（2da450c）+ 合并回 master（--no-ff）+ 清理 worktree/分支
- [x] 同步部署副本 ~/.zcode/skills/task-planner（含补齐落后的 Rule 26 增量）
- [x] CHANGELOG.md 记条目 + 终验 + 汇报
- **Status:** complete
- **Executor:** 主进程（例外理由:纯 git 编排与部署同步属主进程白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅信号①:未提交变更均为本任务自身产物 .plan-required/.zcode/plans/；无 ②③④⑤） |
| `isolation` | `worktree`（skill 保护区文件命中宪法 §11.1.1） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-three-file-compass`（宪法 §11.2 集中目录新规） |
| `branch` | `wt/task-three-file-compass` |
| `merge_back` | `merged(9929883)` |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-04 21:30 | S2 completed |
| Phase 2 | ☑ | 2026-09-04 21:30 | S2 completed（executor 承载） |
| Phase 3 | ☑ | 2026-09-04 21:30 | S2 completed（executor 承载） |
| Phase 4 | ☑ | 2026-09-04 21:30 | S2 completed |
| Phase 5 | ☑ | 2026-09-04 21:30 | S2 in_progress |

## Key Questions
1. 为什么 init 正常但执行时只有 task_plan.md？→ 答：init 5 文件齐全；缺口在执行期提醒与终验门，见 findings.md §诊断
2. stub 判定会不会误伤简短回填？→ 答：用「扣除模板行后实质内容行数」而非字节阈值，≥3 行实质内容即视为已回填

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 新条款挂 Rule 19 下（19.5-19.7），不开顶层 Rule 27 | 用户痛点是 Rule 19 执行不力，集中修订避免规则碎片化 → 论证见 findings.md §技术决策 |
| stub 判定 = 扣除模板行后 <3 行实质内容 | 字节阈值会被 3-4KB 模板自身干扰；行集合扣除法可判定且无误伤 |
| task_plan.md 膨胀 >500 行仅 WARNING 不阻断 | 硬阻断会 brick 长任务；回填缺失才是硬门（对齐 Rule 26 惩罚哲学） |
| hook 提醒独立冷却（state 扩展字段） | 三类提醒共用一个冷却会互相吞掉；向后兼容旧 state 格式 |
| 不改 ~/.zcode/cli/config.json hook 注册 | PostToolUse hook 已注册（zcode-posttooluse.sh 在用），仅增强脚本内容，无需动注册表 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| （暂无） | 1 | |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-04 21:00 | 纠偏(自查) | 全部 | 计划曾误标 Phase 2-5 complete（未发生），已回退为真实状态并落盘本条；三证据铁律（§三） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（Phase 2、Phase 3 由 executor 承载） |
| 主进程直做 Phase 清单 | Phase 1（已知小文件调研，宪法 §一.5）/ Phase 4（≤8 条确定性验证命令）/ Phase 5（git 编排+部署同步）——均已登记例外理由 |
| 委派率 | 40%（<50% 但主进程直做均有登记理由，Rule 25.4 合规） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|-------------|
| 1 | 2026-09-04 21:15 | executor | worktree 内按规格改 SKILL.md+critical-rules.md（5 处插入） | done | 19.5-19.7/C16/3-File Gate 全部落地，grep 验收达标 | worktree SKILL.md:117,184,213,298; critical-rules.md:94-96 | ☑ |
| 2 | 2026-09-04 21:16 | executor | worktree 内按规格改 3 个脚本（三文件门/罗盘提醒/init 复核） | done | 三场景门控+冒烟+兼容实测全过，bash -n 通过 | worktree check-complete.sh:184-226; zcode-posttooluse.sh:40-120; init-session.sh:112-127 | ☑ |
