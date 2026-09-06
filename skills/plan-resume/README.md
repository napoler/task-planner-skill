# plan-resume

> Companion skill — 与 task-planner 协同:扫描中断/过期的 `task_plan.md`;恢复场景下自主选最值得推进的 1 个计划续推,执行中扫描只报告。

## 是什么

工作区里堆积的 `plans/<id>/task_plan.md` / `.zcode/plans/plan-sess_*.md` / `skills/*/plans/task-*/task_plan.md`,哪些该续推、哪些该放弃、哪些其实已被顺便完成 — 本 skill 用「时间衰减 / 代码环境失效 / 目标已被取代」三维判定 + 加权打分决策。

**v0.6 (2026-09-06) 决策自主化契约**:恢复触发点(会话启动无活跃计划 / 用户说"继续上次任务"类 / 当前计划交付终态后)默认**自主推进**——打分选 Top 1 并立即续推**至交付**;途中执行级决策点(HANDOFF"待你决策"/二选一/[awaiting-user])按 SKILL.md §7.10 四项测试(可逆性/范围/宪法P0/先例)自主裁决并记录,**不停车等用户**(`config.json#autonomous_resume`,说"不要自动续推"可会话级关闭);当前计划执行中的被动扫描(task-planner Rule 24)保持**只报告**。守卫:跨仓候选只报告、blocked/[hold]/[user-vetoed] 硬排除(awaiting-user 已移出——它是裁决对象非死端)、单次最多 1 个、circuit-break 熔断。

## 文件清单

```
plan-resume/
├── SKILL.md                  # 主文档(触发条件、工作流、§7 自主推进模式、报告模板)
├── config.json               # v0.5 自主推进开关与守卫阈值(autonomous_resume 等)
├── scripts/
│   ├── scan-plans.sh         # 扫描三处存储位置,支持 --only / --time-threshold
│   ├── extract-meta.sh       # 单文件元数据提取(task_id/goal/phase_status/...)
│   ├── score-plans.py        # 综合加权打分(出度/git 关键词/失败次数)
│   └── select-and-resume.sh  # v0.5 自主推进编排(config 驱动;--dry-run/--auto-push 显式覆盖)
└── tests/
    └── smoke.sh              # 自检(语法 / --help / 扫到 / 过滤 / 提取 / v0.5 config)
```

## 与 task-planner 的关系

- 同一 canonical 仓 `napoler/task-planner-skill`(本仓库)
- 位于仓库顶层 `skills/plan-resume/`(2026-09-04 自 `companion/skills/` 迁移,与 task-planner 同级),发现根以软链直连 canonical(实际部署位以 `install.sh`/软链现状为准)
- 运行时只**读** task-plan 文件,不调 task-planner 的 hooks;自主续推的 Phase 执行由调用方按 task-planner 协议进行
- 与 `task-drift-guard`(执行中漂移检测)、`session-catchup`(session 上下文恢复)互补,不互替

## 维护

- 不动 SKILL.md frontmatter(无 hooks,只有 name + description)
- 改 `scripts/*.sh` 后跑 `bash tests/smoke.sh`
- CHANGELOG.md 由父仓维护
