# 任务书 S6：task-v151 全量 Code Review

## 1. 目标
对 task-v151 worktree 实现（commit 101475f，16 文件 +354/-35）做全量 CR，输出 APPROVED / CHANGES_REQUESTED（逐条编号）。
- 需求锚（Rule 51.1a）：R2「核心说法就是将任务分解拆解为固定的，分析明确之后设定为目标，然后并且设定目标之后包含完整的验证，然后使用 goal 来进行任务的推进，确保整个任务执行的可靠性」

## 2. 输入
- 计划三文件（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/{task_plan.md,findings.md,progress.md}
- 设计蓝本：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/design-draft.md（§2 条款草案/§4 守卫伪码/§5 钉值清单=实现对照基准）
- 审查对象=worktree commit 101475f 的完整 diff：
  - 仓库=/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode（分支 wt/v151-goal-mode）
  - 命令：`git -C <worktree> show 101475f --stat` 与 `git -C <worktree> diff master..wt/v151-goal-mode`（或 `git show 101475f` 全量）
- 变更面清单（16 文件）：
  - skills/task-planner/references/critical-rules.md（Rule 66 六子条，行 848-860 + S4b 66.5 档位行）
  - skills/task-planner/SKILL.md（1-66 三处计数 + Rule 66 摘要行 + C45 合规行）
  - skills/task-planner/templates/task_plan.md（🎯 Goal 单元表区块，行 104 起）
  - skills/task-planner/scripts/check-plan-dispatch.sh（66.5 校验段，行 314 起，含档位三分支）
  - skills/task-planner/scripts/check-complete.sh（[goal-gate] 终验对照段，行 1212-1255）
  - skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh（新，G-01..G-09）
  - skills/task-planner/scripts/selftest-registry.tsv（+1 行）
  - 钉值级联 9 脚本：selftest-skill-split（510→515）/ selftest-evidence-goal-gate（EG-16 演进）/ selftest-lane-advancement / selftest-self-resolution / selftest-tool-selection / selftest-requirement-coverage / selftest-research-first / selftest-iteration-persistence / selftest-four-file-dataflow
- 背景裁决（审查时勿再质疑，已登记）：① 66.5 档位三分支=主进程 D2 裁决方案①（无 plan_tier 标记=缺省档跳过不拒锁，legacy 兼容；仅显式 standard/full 硬拒锁）② /goal=用户侧内置命令不可代调，技能层只做映射供料（66.2 口径，40.3 延伸）
- 伴飞技能：无；并行组：无
- 检索优先契约（Rule 63）：判断既有脚本范式（awk 状态机/--skip-* 惯例）时先 grep 脚本内同类实现对照，勿凭记忆；发现疑点先 Read 上下文再下结论

## 3. 验收标准（审查维度，逐维给结论）
- V1 正确性：66.5 段档位三分支逻辑无漏档（standard/full/mini/无标记四态全覆盖）；awk 状态机无区间 next 坍缩陷阱；check-complete [goal-gate] 段三语义（complete 无证据 exit1 / pending 提示 / 缺区块跳过）实现与 66.3 条款一致
- V2 一致性：critical-rules 66 子条 ↔ 模板区块 ↔ 两脚本 ↔ SKILL 摘要 ↔ 新 selftest 断言，五面口径无矛盾（如六列契约、黑名单词、[goal:Gn] 行格式）
- V3 零回归/纯增量：既有 1-65 条款正文零改写（git diff 判定）；钉值级联 9 脚本改动仅钉值行与同法演进（D2 区块化/计数 1-65→1-66），无语义越改
- V4 可维护性：注释 What+Why 完整（Rule 45）；新 selftest 骨架与既有范式一致；registry 行列齐
- V5 运行面：worktree 内 `bash scripts/selftest-goal-unit-goal-mode.sh` exit 0 亲跑复核 + `bash -n` 两守卫脚本语法 + check-plan-dispatch.sh 对本计划正样本（/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/task_plan.md）零 66.5 违规
- 结论：全维 PASS=APPROVED；任一维 FAIL 逐条列 CHANGES_REQUESTED（编号 F1..，含文件:行+修建议）

## 4. Scope 禁改
- 只读审查；禁止修改任何文件、禁止 git 写操作；CHANGES 只列不改

## 5. 工作路径
worktree=/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode（不切 CWD）

## 6. 时长预算
重 diff CR → 30 分钟；超时返回 partial 列已完成维度

## 7. 返回格式（严格 8 字段，字段后无内容）
```
status: done | partial | failed
acceptance: <n>/5 pass — [V1:PASS V2:PASS V3:PASS V4:PASS V5:PASS]
files: none（只读）
evidence: <命令→关键输出行>; 结论=APPROVED 或 CHANGES_REQUESTED(F 清单行号锚)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/11-code-reviewer-S6.md
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
CHANGES_REQUESTED 时 F 清单全文写入检查点「审查明细」段。

## 8. checkpoint
/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/11-code-reviewer-S6.md：逐维度审查过程+运行面输出原文；结束写「最终结论」=同一 8 字段块

## 9. 上下文预算
diff 全文需读（审查对象本身）；计划三文件只 Read §R/VC 相关段；回归跑 1 条新 selftest+2 条 bash -n+1 条正样本即可，不重跑全量 64
