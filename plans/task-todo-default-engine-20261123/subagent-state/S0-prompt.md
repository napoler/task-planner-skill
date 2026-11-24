# S0 Plan Writer 完整任务书（Rule 35.3 大内容落盘，prompt 只放路径）

## 1. 目标
把方案A（todo基线组 B1-B5→B1-B8 扩展）结构化录入 plan-state.json 并 render 出 4 个派生视图。本会话只执行本 S-unit。

需求锚（Rule 51.1a 双锚）：
- R1 引擎检测设为 todo 默认项 — user-session-log.md #2「在todo的默认选项中加入到检测是否引入Open Spec和Superpowers来执行任务」
- R2 对齐落地 — 旧计划 task-align-mandatory-step 交付物吸收
- R3 worktree 隔离核验入默认项
- R4 三层载体（产出器+模板+守护）
- R5 定位守正（不推翻既有/核心定位/硬门仅登记）

## 2. 输入（绝对路径，必读）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/task_plan.md — 只读
- findings: 同目录/findings.md — 可追加 `#### [sub:S0-plan] ...`
- progress: 同目录/progress.md — 可追加 Actions 行
- knowledge-brief: 同目录/knowledge-brief.md — 只读
- user-session-log: 同目录/user-session-log.md — #1 #2 逐字原话+理解镜像（需求锚唯一事实源，必读）
- planctl: /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/planctl.py
- 速查: /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md「结构化状态操作 SOP」段
- 派发模板: /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md §7 §8
- 变更类型：增量（既有 B1-B5 逐字保留，只叠加 B6-B8）

## 3. 验收（可观察）
1. `python3 <planctl> status --plan-dir <PD>` 显示 phases=5 / vcs=6 齐备
2. `python3 <planctl> check vc-nonvacuous --plan-dir <PD>` 输出 PASS
3. 6 个 VC 的 command 均为可执行纯命令（禁反引号/127伪FAIL）；VC-4 须真实断言 sync-todos 输出含 B6/B7/B8
4. `python3 <planctl> render --plan-dir <PD>` 后 4 MD 派生视图刷新

## 4. Scope 禁改
禁改计划目录外任何文件（尤其 skills/，那是 worktree 的活）；禁 git 写操作；禁手工 Edit 4 个 MD 派生视图；禁新增脚本/hook/机器门；禁虚构命令输出；伴飞技能=无。

## 录入内容（已定案，照抄禁缩水）
方案A：todo 基线组 B1-B5→B1-B8；B6 引擎检测（建todo默认检测 OpenSpec/Superpowers 适配性，结论落 Decisions）；B7 对齐核查（吸收旧计划 task-align 交付物不丢弃）；B8 worktree 隔离核验；产出器 sync-todos.sh --json 输出 B 组；模板 task_plan.md Todo 段列 B1-B8；守护 selftest-skill-collab.sh + selftest-registry.tsv 加锚断言。边界：不推翻既有功能、机器硬门仅登记不实施、核心定位=知识/记忆体系守正。

根因（录入 root_causes）：
- RC1 worktree 宪法纯文本无 exit 硬门（AGENTS.md:151-210）
- RC2 冲突无事后补救路径（worktree-isolation.md/check-conflicts.sh）
- RC3 引擎软路由 enforce 仅语义预留（skill-collaboration.md:4-10/todo-sync.md:34-40）
- RC4 对齐从未落地（4 锚 NOT-FOUND / sync-todos --json 输出 [] / templates 无 B 组）

精确改动锚（录入 resources）：
- skills/task-planner/references/todo-sync.md:34-40
- skills/task-discipline/references/critical-rules-discipline.md:747-750
- skills/task-planner/SKILL.md:256
- skills/task-planner/templates/task_plan.md:455-470
- skills/task-discipline/SKILL.md:86
- skills/plan-collab-router/references/skill-collaboration.md:53-109
- skills/task-planner/scripts/{sync-todos.sh,selftest-skill-collab.sh,selftest-registry.tsv}

结构（planctl 录入）：
- requirements R1-R5（type=目标，vc 映射 R1→VC1 R2→VC2 R3→VC3 R4→VC4,VC5 R5→VC6）
- goals G1-G5（text 对应 R，evidence=[goal:GN]）
- vcs VC-1..VC-6（每项 criterion+command，command 可执行纯命令）：
  - VC-1: `grep -Fq 'B6' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '引擎检测' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS`
  - VC-2: `grep -Fq 'B7' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS`
  - VC-3: `grep -Fq 'B8' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq 'worktree' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS`
  - VC-4: `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 | grep -q 'B6' && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 | grep -q 'B7' && echo PASS`（若 sync-todos 需 --plan-dir 参数请查 --help 后修正为真实可执行命令）
  - VC-5: `grep -Fq 'B6' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && grep -Fq '引擎检测' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh && echo PASS`
  - VC-6: `for a in B1 B2 B3 B4 B5; do grep -Fq "$a" /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md || exit 1; done; bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh >/dev/null 2>&1 && echo PASS`
- phases P1-P5：P1设计锚定(S1) / P2契约与规则锚落地(S2,S3) / P3产出器+模板+守护(S4) / P4合并回+部署同步(S5) / P5验证交付(S6)
- s_units S1-S6（执行体用 subagent_type 名禁"主进程"，时长裸 NNmin，粒度三值如 3f/40l/10min，伴飞=no，前置依赖，状态pending）：
  - S1 [P1] R锚定复核+三处锚点精确文案草稿 → general-doc-processor
  - S2 [P2] todo-sync.md 契约扩 B1-B8 → general-doc-processor
  - S3 [P2] critical-rules-discipline.md+SKILL.md+task-discipline/SKILL.md 规则锚同步 → general-doc-processor
  - S4 [P3] sync-todos.sh 产出器+模板露出+selftest 守护 → general-coder
  - S5 [P4] 合并回+部署位同步（主仓执行，worktree 内只标记） → general-ops
  - S6 [P5] VC 全量复验 → Verifier
- root_causes RC1-RC4（add --section root_causes）
- decisions D1（goal自治选A / B1-B5保留叠加 / 硬门仅登记 / 对齐从旧计划吸收）
- fmea ≥1 条（standard 档必须，否则 attest 拒锁）
- 顶层 goal 行：「通过 todo 默认基线项 B6/B7/B8 使引擎检测/对齐/worktree 检查自动带出，修复软契约无载体根因」

## 7. 返回格式（8 字段固定，之后无任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:S0-plan]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘
文件：/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S0-plan-writer.md
每完成一文件落盘追加里程碑行（带时间戳）；结束写「最终结论」段=第7节同一8字段块并置 status: done。格式：头部status行+里程碑(append-only)+进行中+产出清单+错误与受阻+最终结论；纯markdown无frontmatter。
