status: done
summary: 审查完成。对 7 个文件 diff 逐文件核对：Rule 104 在 dispatch 新增（三级标题 ### 104、6 子条 104.1-104.6、15 行标注表）、SKILL.md 加入 2.5 速查表并更新卫星路由与纪元索引、模板新增「96 类别」列、自测新增 SA-16..20、dual-qc 切换到纪元窗 DQ-08、batch-pilot BP-08 上调至 285 并加演进注释、critical-rules 更新路由索引均与计划一致。
files: skills/task-dispatch/references/critical-rules-dispatch.md (+56/-0), skills/task-planner/SKILL.md (+17/-6), skills/task-planner/references/critical-rules.md (+1/-1), skills/task-planner/scripts/selftest-batch-pilot.sh (+5/-1), skills/task-planner/scripts/selftest-dual-qc.sh (+10/-6), skills/task-planner/scripts/selftest-subagent-activation.sh (+15/-0), skills/task-planner/templates/task_plan.md (+9/-4)
acceptance: | 维度 | 结论 | 证据 | | --- | --- | --- | | 正确性 | PASS | dispatch 中 ### 104 标题、104.1-104.6 完整；104.2 表 15 行动作类型含「媒体批量生成+质检循环」且映射到 image/video-generation-executor；104.5 阈值「同法失败≥2次」「单turn≥30次或同工具≥4次」；SKILL 2.5 就地速查与 104.2 一致；模板表头含「96 类别」列。 | | 完整性 | PASS | 插入位置在 Rule 103 后（Rule 104 从行 244 开始）；无 `## Rule 104` 残留（grep 计数 0），三级标题 `### 104` 仅 1 个；SKILL 新增卫星路由条目含 103,104，纪元索引更新至 1-104/87 条；模板表头+注释均已更新。 | | 风险 | PASS | 与既有规则无直接冲突：104.1 明确为默认建议软档且偏离需 `[markup-exempt]` 理由；未新增强制拒锁；与 Rule 95 平衡（104.5.3 强调登记不停摆）；BP-08 275→285、DQ-08 切换到宽容纪元窗且添加演进注释，符合「断言锚宽容性」要求。 | | 可维护性 | PASS | SA-16..20 覆盖标题形态/表格/速查/列名/markup-exempt；断言锚采用纪元窗 `1-1[0-9][0-9]` 和 `其余 8[0-9] 条`；路由指针路径相对仓库结构合理；守护锚已声明。 | 最终结论一行: APPROVED
issues: none
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-subagent-markup-20261105/subagent-state/S6-review.md
confidence: 高 + 所有预期文件变更已核对，diff 符合审查维度与自测新增断言预期
next: 可进入合并/收口流程（按工作树合并约定处理 wt/task-subagent-markup-20261105）
