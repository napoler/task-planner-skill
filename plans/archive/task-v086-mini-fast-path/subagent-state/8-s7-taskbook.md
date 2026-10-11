# S7 任务书：task-v086 CR Gate 修复单元（P4 S7-1~S7-4）

你是 task-v086 P4 CR Gate 的 S7 修复单元执行体。P3 交付后 Code Review 首轮 CHANGES_REQUESTED，修复 4 项后才能进合并部署。

## 计划三文件（绝对路径；先 Read task_plan.md + progress.md）
- 计划: /mnt/data/dev/task-planner-skill/plans/task-v086-mini-fast-path/task_plan.md
- 发现: /mnt/data/dev/task-planner-skill/plans/task-v086-mini-fast-path/findings.md
- 进度: /mnt/data/dev/task-planner-skill/plans/task-v086-mini-fast-path/progress.md
- 检查点(必写, 新建): /mnt/data/dev/task-planner-skill/plans/task-v086-mini-fast-path/subagent-state/8-executor-s7.md（每完成一项即追加 [S7-N] 行，先落盘再干）
- CR 发现详情: /mnt/data/dev/task-planner-skill/plans/task-v086-mini-fast-path/subagent-state/7-code-reviewer.md（先 Read）

## 背景（自包含）
task-v086=难度分级轻量档+项目多模板。worktree=/home/terry/task-planner-skill-worktrees/task-v086-mini-fast-path（skills/task-planner/ 内 32 文件已暂存，勿提交——主进程 P4 统一 commit）。CR 首轮 1 个 BLOCKER+3 项条款/selftest 缺口。

## 具体动作

### S7-1 BLOCKER：check-template-type.sh 补第三形态提取（注释 form）
worktree scripts/check-template-type.sh 提取链=① 行首直书 `^template_type:` ② 表格行 `| template_type |`，不识别 `<!-- template_type: X -->` 注释形态 → 所有内置模板产物+init 插入产物在 gate 视角=「缺失」，mini 主路径在 template_gate enforce 档会被拒锁。修复=在表格行提取分支之后追加第三形态：
```bash
if [ -z "$tt" ]; then
  tt="$(grep -m1 -oE '<!--[[:space:]]*template_type:[[:space:]]*[A-Za-z0-9-]+' "$plan_file" 2>/dev/null | sed 's/.*template_type:[[:space:]]*//')"
fi
```
（对齐既有两形态代码风格；脚本头部注释「提取顺序」说明同步补第三形态。）必须实测写检查点：
- 临时目录跑 worktree 版 init-session.sh + TASK_PLAN_TIER=mini 产物 → `[template-gate] OK: template_type=mini-lite` exit 0
- 自造模板+default 场景 init 产物 → OK: template_type=my-custom（frontmatter 插入真正生效）
- standard 样例（任一内置 variant 复制）→ OK
- 无 template_type 标记的 legacy 计划 → 仍 INVALID 缺失（放行面不扩大）

### S7-2 条款措辞对齐（worktree references/critical-rules.md，2 处最小改，0 新机制）
- 38.4②：「每 Phase V-N 映射最低 2→1、无 V-N 映射行不阻断」→「无实质 V-N 映射行的 Phase 不阻断（mini 等效阈值 0）；有映射行时仍须全部映射到已定义 VC 编号」
- 38.2① 尾部「中/重任务误用 mini 模板 = check-template-type 范畴违规（34.1 白名单校验仍生效）」→「中/重任务误用 mini 模板 = 范畴违规（34.1 白名单校验仍生效；非机器阻断，指导层——误配 MISMATCH 条件时由 38.1 MISMATCH 提示兜底）」

### S7-3 selftest-plan-tier.sh 样例形态修复
PT 行为断言样例（构造 mini 计划处）当前手造双形态（`| plan_tier | mini |` 表格行+注释）偏离真实产物 → 改为 `cp` worktree templates/variant/mini-lite-type.md 为样例基座再最小改写占位，使 plan_tier 标记=注释单形态（与真实 init 产物一致）。涉及 PT-18~21 相关样例构造处。另尝试新增 PT-28：mini 样例在 template_gate enforce 档 attest 通过（若消费链无该 env 键则如实记负结果，不强造）。

### S7-4 回归定数
- selftest-plan-tier.sh 单跑全 PASS（Total 行更新含 PT-28 如成立）
- 全量回归: cd /home/terry/task-planner-skill-worktrees/task-v086-mini-fast-path/skills/task-planner/scripts && for f in selftest-*.sh 逐 Total 行求和，预期 429 或 430（+PT-28），0 FAIL
- 改动面 git status 自证：仅 check-template-type.sh / critical-rules.md / selftest-plan-tier.sh（+ 实测必需的少量调整，如实列）

## 约束
- 只改上述 3 文件；禁改其他 scripts/templates/config/SKILL（防扩散）
- 每项完成即写检查点；负结果如实记录（禁止虚构 PASS）

## 8 字段严格返回（最终消息逐字含标签）
status: done|partial|failed
acceptance: <S7-1 四场景实测输出摘要 + S7-2 diff + S7-3 样例改造+PT-28 结果 + S7-4 定数>
files_modified: <列表>
key_diff: <每文件一句话>
selftest_affected: <Total 行定数>
risk: <遗留>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v086-mini-fast-path/subagent-state/8-executor-s7.md
next_step: 交主进程做合并部署

预登记例外：若 executor 不可用/超时，主进程按 Rule 22.3④ 白名单② 接管（任务书已落盘，白名单2）。预估 12min。
