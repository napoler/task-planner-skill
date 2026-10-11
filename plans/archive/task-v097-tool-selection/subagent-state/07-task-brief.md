# P4-S1 任务书: template-mapping.md 加「工具选择映射」节（task-v097）

任务: worktree 内卫星文档 template-mapping.md 新增「§十 工具选择映射」节（Rule 40.1/40.2 权威消费点）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-4 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection 下）
skills/plan-template-kit/references/template-mapping.md（当前约 230 行;插入点=§九 机制适用性矩阵（约 L205-230）之后;若 §九 后还有尾注/附录内容则插在其后、文件内容真正结束前;以内容锚「§九」标题定位）

## 硬约束
- 只改该 1 文件,只做插入;§九 矩阵表本体零改动（改动前快照: `git diff` 中不得出现 §九 表行删改）。
- 文档内引用路径用相对引用（对齐该文档既有风格）;禁绝对路径。
- 不新增 frontmatter、不触其他节。

## 插入内容（逐字使用,标题序号「§十」若与既有章节冲突则顺延为下一可用序号）
```
## §十 工具选择映射（Rule 40.1/40.2 权威消费点 — task-v097）

> 消费方: plan-writer 计划撰写期（填写「🧰 工具选择与编排」区块的选型依据）。与 §九 机制画像互补——§九 裁剪"机制适用性",本节回答"用哪类工具执行"。mini 档豁免该区块（Rule 38.3）。

| 任务类型族（对齐 §九） | 默认执行体（对齐 SKILL 路由表） | 计划期工具面建议（Rule 40.1 六类） | 编排判定倾向（Rule 40.4） |
|----------------------|------------------------------|--------------------------------|------------------------|
| 代码组（code-edit/bugfix/refactor/performance/test-writing） | code-assistant / executor / build-error-resolver 子代理 | Agent 子代理为主;机械守卫脚本（selftest/编译/lint）为验证面 | 串行为主;≥3 个独立同构单元或独立模块并行可分析 → 建议 CreateWorkflow |
| 内容组（writing/research/publish/video） | 内容类执行体（article-writer 等）+plan-research-router 卫星 | 卫星技能+子代理;长任务建议用户 /goal 锚定会话目标（40.3 提示点） | 阶段链（研究→写作→审查）强串行;仅批量多文发布可 fan-out |
| 规则/模板组（rule-enhancement/schema-migration） | executor（worktree 隔离必须） | Agent 子代理+机械 selftest 面;主进程 git 编排（Rule 25.3 白名单①） | 串行;级联锚清单先行 |
| 迁移/部署组（migration/deployment） | 主进程 git 编排+executor | 机械守卫脚本+git 编排（白名单①③）;MCP 工具按需 | 串行;合并回走 smart-merge-back |
| 轻量档（mini-lite） | code-assistant 或主进程白名单 | 豁免「🧰」区块（Rule 38.3）;默认 21.4 串行 | 不判定 |
| 调研/诊断组（research/diagnostic） | Explore/web-search/debugger 子代理 | 子代理+MCP（web_reader/node_repl）+research 卫星 | 串行;多主题可拆多 explore |

**映射使用规则**: ① 本表是建议面非强制路由——Executor 字段仍是委派门控机器事实源（Rule 40.2,区块不替代）;② 编排判定倾向=命中才在「🧰」区块登记"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记,未命中维持 Rule 21.4 串行;③ 类型不在表中 → 按最近似族套用并在区块理由列注明。
```

## acceptance: 验收标准
1) `grep -c '工具选择映射' <目标文件>` ≥2（节标题+使用规则引用）
2) `git -C <wt> diff` 中 §九 矩阵表行零删改（插入纯增,deletions=0）
3) `wc -l` 实测记录（纪律 ≤300,当前 230+插入约 25）
4) 表格 6 行类型族齐全,每行 4 列
5) `git -C <wt> diff --stat` 仅该 1 文件

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/07-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P4-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
