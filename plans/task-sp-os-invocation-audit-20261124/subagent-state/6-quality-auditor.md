# Checkpoint — S6 quality-auditor（只读盘点）

- status: done
- task_id: task-sp-os-invocation-audit-20261124
- unit: S6（P2 驱动点缺口·执行与收口期 + 对照机制）
- executor: agent-quality-auditor(sonnet-1)
- parallel_group: g-ro

## 产物
- /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-2.md（+1 / -0；88 行）

## 验收对照
- DRIVER-GAP 行=8（≥1）：DRIVER-GAP-1..5 五条主缺口 + 文中引用。
- 5 时点覆盖：Phase 开启 / 派发前伴飞 / 执行中 / 完成声称前 / 收口归档 全部命中。
- 对照机制小节：以 sync-todos.sh 必选基线组 B1-B8 + hook 门链为稳定驱动对照面，列 6 环驱动链 + 逐点对比表；揭关键反讽 B6 点名 SP/OS 却只是一次性检测项。
- 子代理工具面清单：设计层断言（critical-rules-dispatch.md:157,161——全子代理有 Read、仅 3 个有 Skill）+ 本会话 frontmatter 复核（tools:.*Skill = 0 命中，降为未验证设计层断言）+ S-unit 伴飞列现状一手纠正。
- file:line：每条缺口/对照/工具面结论均带具体 file:line。

## 关键发现（供 S14 根因裁定 H5 参考）
- 一手新发现（C2 合规，指向技能缺陷）：伴飞技能列的字段载体结构性缺失——plan-brief.md:63 §F 表无此列、plan-state.json s_units 无 escort 字段（grep=0）、planctl.py:1271 把 parallel token 填进渲染表的「伴飞技能」列（部署位同病）。致 check-dispatch.sh:580 无 .md token 可提取、:586 门跳过。这是 H5「到达不了执行层」的可驱动根因锚，非执行方行为。
- 父任务书前提更正：「plan-brief §F 表有伴飞技能列、S3-S6 填了路径」与实测不符；实为渲染表 task_plan.md:94 有列但填 g-ro/无。已在报告 §3.2 记录。
- 对照机制缺口 6 环：时机锚/脚本带出/必选组/拦截门/恢复重建/计数面，SP/OS 全缺；B6 反讽说明「有基线组门链」≠「SP/OS 被主动调用」。
- 负结果：SP/OS 技能文本要求本身完整；hook 与 check-*.sh 中 SP/OS grep=0；未重跑 openspec PATH 探针（沿用 T/probe-path.txt，标未验证）。

## 写入范围
- 仅 T/report-driver-gap-2.md + 本 checkpoint + T/writes.txt（+1 行）；未改 plan-brief/plan-state/4 视图/他人产物/仓库受管文件。
