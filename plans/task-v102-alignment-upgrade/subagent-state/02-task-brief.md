# P2-S2 任务书: CRIT Rule 42 追加 42.6（task-v102）

任务: worktree 内 critical-rules.md 的 Rule 42 节末尾（42.5 行后、### 43 节前）追加 42.6「对齐审查前置与收尾消费（写入前校验+标准流程）」四子条。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v102-alignment-upgrade/skills/task-planner/references/critical-rules.md
插入位=42.5 行（:423）之后、`### 43 执行可靠性制度化` 节头（:425）之前——插入 42.6 节（约 12-16 行）+1 空行

## 硬约束
- 42.1-42.5/Rule 43 全部原文零改动（diff 证明:插入纯增,42.5 行与 43 节头零变化）
- 禁「1-4x」越界字面;引用既有规则写全名「Rule 43.1」式
- 只动该文件该插入位;禁写其他文件

## 插入内容（逐字使用,格式同构 42.1-42.5）
```
42.6 **对齐审查前置与收尾消费（写入前校验 + 标准流程）**：alignment-review（兜底池成员 11）的消费制度化，两个时点强制消费——
42.6.1 **写入前校验纪律（验证优先闸门）**：任何对既有文档/文件的内容追加或更新，写入前必须按 alignment-review「写入前校验闸门」五步执行版本一致性校验（读最新态→对照→识别前后版本不一致/重复/过期→按最新有效版本合并并删除冗余→输出变更记录）；**未经一致性校验，不直接追加新内容**（验证优先——修正成本在写入前远低于写入后，流程初期即完成关键确认）。
42.6.2 **完成前对齐标准流程**：任务标记完成前，对本次任务产出与更新的全部文档跑一遍 alignment-review 对齐审查（跨文档/跨代码/跨配置/跨引用的同步一致性），确保「所有更新的同步更新」——对齐审查是标准收尾流程的固定环节，非可选项；审查结论与问题清单随交付物留痕。
42.6.3 **变更记录输出要求**：写入前校验与对齐整理均须输出变更记录（更新/合并/删除/依据版本/残留冲突五要素），随交付物落盘；禁止只执行不记录。
42.6.4 **机制（零新 config 键 — 与 42.5/43.4 同范式）**：判定面=LLM 行为（写入与收尾时点的自我审查）；机器面=`scripts/selftest-review-library.sh` RL-11 静态断言（alignment-review 写入前校验/变更记录/未经校验锚）；消费侧=SKILL.md 合规清单 C32；既有 22.3/28/35.6/Rule 41/42.1-42.5/43 原文零改动。
```

## acceptance: 验收标准
1) `grep -c '^42.6' CRIT`=4（42.6/42.6.1/42.6.2/42.6.3/42.6.4 中以行首 42.6 开头的行数=4:42.6 主体+42.6.4 两行+…以实际 grep 计数为准,预期 42.6 主体行+42.6.4 行=2 行行首,42.6.1/.2/.3 前有缩进或接排——**以「42.6 主体+42.6.1+42.6.2+42.6.3+42.6.4 五个措辞各 grep ≥1」为准**）
2) 「未经一致性校验，不直接追加新内容」在 CRIT ≥1;「完成前对齐标准流程」≥1
3) `git diff --numstat` CRIT 纯增（deletions=0）;42.5 行与 ### 43 节头零变化
4) `wc -l` 记录新行数（432→约 446）
5) `git -C <wt> status --short` 仅该文件 M

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/subagent-state/02-exec-p2s2.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
