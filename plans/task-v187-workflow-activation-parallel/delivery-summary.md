# Delivery Summary — task-v187 工作流主动激活+模型分级+并行度三缺陷修复

> 2026-10-18 · outcome: **COMPLETE** · CR APPROVED · 91/91 回归双跑绿 · 3 部署位同步

## 1. 做了什么（说明）

用户实证三缺陷（工作流激活率 0/模型分级空转/并行率低）根因全部确诊为**规则文本结构性锁死**并修订：

1. **R1 工作流主动激活**：Rule 39.1 从「仅用户显式点名」演进为「显式点名 ∨ 常设授权命中」；新增 39.8 常设授权主动激活子条（三条件：≥3 独立可并行 S-unit / ≥3 阶段编排型 / 用户点名；三件套：留痕+分档+环境探测；回落边界保住轻量通道）；40.4 从「建议登记」升级为「主动路由义务」；授权锚=user-session-log #1，用户一句「收回工作流授权」可整体回退——官方红线原文披露保留（Rule 35.2），用「用户主权常设授权覆盖」论证而非掩埋冲突。
2. **R2 模型分级**：新增 91.12 主动激活联动（CreateWorkflow 按任务难度声明 run 级 subagent_model、按 91.1 CCR 四档映射、禁全流统一 heavy 档衔接 91.8 既有条款）。
3. **R3 并行度**：新增 21.4.2 执行期扩组协议（四步：Decisions 登记→补组标记→重锁→并行派发；只读豁免通道保持）；68.2 增惰性全串行论证义务（S-unit ≥3 且零并行组须论证否则回炉）。

## 2. 产出（可定位）

| 产出 | 绝对路径 | 看点 |
|------|---------|------|
| Rule 39.1/39.8/40.4/91.12 修订 | /mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/critical-rules-collab.md | :5/:24/:33/:79 |
| Rule 21.4.2/68.2 修订 | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | :34/:165 |
| SKILL.md 消费侧 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :207 |
| 模板镜像×4 | skills/task-planner/templates/task_plan.md:262 + skills/plan-template-kit/references/{template-guide.md:254,template-mapping.md:312/321} + companion/agents/plan-writer.md:45 | 40.4 语义同步 |
| selftest 锚级联×2 | skills/task-planner/scripts/{selftest-workflow-orchestration.sh,selftest-tool-selection.sh} | WF-09/TS-03/TS-06 |
| 计划三文件 | /mnt/data/dev/task-planner-skill/plans/task-v187-workflow-activation-parallel/{task_plan,findings,progress,verification}.md | 全程留痕 |
| master 合并 | commit 55fa43ca（merge）← 4 worktree commits（3004687/902610a/4941250/059b65c） | git log 可溯 |
| 部署同步 | ~/.zcode/skills、~/.claude/skills、~/.cursor/skills（9 文件×3 位 0 差异） | 新会话即生效 |

## 3. 审查详细

- **CR Gate**：critic 七项审查（官方红线披露/不变量③④⑤⑦/39.8 门槛/91 衔接/可操作性/scope 纪律）——首轮 CHANGES_REQUESTED（M-1：collab:28 引言与 40.4 本体矛盾）→ cr-fix 修复 → 复评 **APPROVED**（critic 实跑 selftest 22/22 复核；检查点 /mnt/data/dev/task-planner-skill/plans/task-v187-workflow-activation-parallel/subagent-state/16-critic.md）
- **偏移检查×3**：Phase 1/2/3 各一次 drift-checker 全 ✅ALIGNED（检查点 1/10/15-drift-checker.md）
- **回归**：全量 selftest 双跑（worktree ΣPASS=1304 ΣFAIL=0 + 主仓合并后 91/91 红=0）
- **锚清零**：旧措辞四形态族全仓 0 残留（唯一合法保留=collab:5 官方红线废止引语披露）

## 4. 风险（必须列举）

1. **行为面冒烟未做**：规则已生效于 3 部署位，但「下一会话实际主动创建工作流」需新会话验证（技能文件新会话加载，本会话不可自证）——裁决 solved 的依据是规则文本+机器回归，非端到端行为实证。
2. **NIT×3（critic 提出，可选后续）**：撤销机制口头非持久（建议 [workflow-authorization-revoked] 登记）/授权锚在任务级目录的跨会话持久性/回落边界未显式排除用户点名路径。
3. **cursor 位历史漂移**：~/.cursor/skills/task-planner 有 35 处非本次范围的既有差异（本次只精准同步 9 文件），全量对齐待用户裁决。
4. **91/91 绿基于现行断言集**：39.8 三条件的行为正确性（如「≥3 S-unit」判定准度）无机器断言（LLM 行为面），依赖执行期留痕审计。
5. 遗留分支 wt/task-v168-machine-parked（历史遗留，非本任务产物，开场已报告）。

## 5. 下一步建议

1. **新会话冒烟**（对象：~/.zcode/skills/plan-collab-router/references/critical-rules-collab.md §39.8；动作：任给 ≥3 独立子任务的编排型指令，观察主动路由+三件套留痕）。
2. NIT×3 与 cursor 位全量对齐可立后续小任务（L0-T 档）。
3. 本任务 21.4.2 扩组协议首用（D10）与 S10 改派判例已可入 notepad 复用。
