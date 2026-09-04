# plan-resume

> Companion skill — 与 task-planner 协同:扫描中断/过期的 `task_plan.md`,产出报告让用户决策。

## 是什么

工作区里堆积的 `plans/<id>/task_plan.md` / `.zcode/plans/plan-sess_*.md` / `skills/*/plans/task-*/task_plan.md`,哪些该续推、哪些该放弃、哪些其实已被顺便完成 — 本 skill 用「时间衰减 / 代码环境失效 / 目标已被取代」三维判定,产出报告 + 推荐动作,**绝不替用户 resume/archive/drop**(宪法 §四)。

## 文件清单

```
plan-resume/
├── SKILL.md                  # 主文档(触发条件、工作流、报告模板、与其他 skill 关系)
├── scripts/
│   ├── scan-plans.sh         # 扫描三处存储位置,支持 --only / --time-threshold
│   ├── extract-meta.sh       # 单文件元数据提取(task_id/goal/phase_status/...)
│   ├── score-plans.py        # v0.4 综合加权打分(出度/git 关键词/失败次数)
│   └── select-and-resume.sh  # v0.4 智能推进编排(--auto-push 需显式授权)
└── tests/
    └── smoke.sh              # 自检(语法 / --help / 扫到 / 过滤 / 提取)
```

## 与 task-planner 的关系

- 同一 canonical 仓 `napoler/task-planner-skill`(本仓库)
- 位于仓库顶层 `skills/plan-resume/`(2026-09-04 自 `companion/skills/` 迁移,与 task-planner 同级),由 `install.sh` 自动分发到 `~/.zcode/skills/plan-resume/` 与 `~/.claude/skills/plan-resume/`,或由用户软链直连
- 运行时只**读** task-plan 文件,不调 task-planner 的 hooks;续推时由用户/主进程显式调 task-planner 新建 task_plan.md
- 与 `task-drift-guard`(执行中漂移检测)、`session-catchup`(Claude Code session 上下文恢复)互补,不互替

## 维护

- 不动 SKILL.md frontmatter(无 hooks,只有 name + description)
- 改 `scripts/*.sh` 后跑 `bash tests/smoke.sh` 5/5
- CHANGELOG.md 由父仓维护
