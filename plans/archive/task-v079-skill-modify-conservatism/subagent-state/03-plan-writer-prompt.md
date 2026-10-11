# task-v079 plan-writer 任务书（35.3 落盘引用版）
> 本文件=派发任务书全文。执行体按本文件逐条执行；不确定处 Read 输入文件核实，禁止编造。

## 角色
plan-writer：为 task-v079-skill-modify-conservatism 撰写计划文档。仓库 /mnt/data/dev/task-planner-skill。

## 必读输入（按序 Read，先读再动笔）
1. subagent-state/01-explore-conventions.md（同目录；仓库结构侦察：Rule 31/32 原文范式、config 键模式、check-complete GATE 顺序、SKILL.md 联动锚、variant 模板骨架、hook 接线）
2. subagent-state/02-rule36-design-brief.md（同目录；设计裁定全文：Rule 36 七子条、SKILL 联动四处、不改动清单、Phases、VC-1..5、frontmatter 要求）

## 产出（仅以下两文件可写，其余零写入）
### A. <plan-dir>/task_plan.md
先 Read 现文件（init 已按 rule-enhancement variant 生成骨架），在骨架上填充，保留全部 variant 区块（隔离决策/执行范围限制/S-unit 表/必要知识储备/FMEA 预演）。
- frontmatter：template_type: rule-enhancement、code_review: required、interaction_mode: ask、reflect_verify: required
- VC-1..5 按简报具体化（判定标准+验证方式+证据路径列）
- 执行范围限制表逐文件：critical-rules.md(追加 Rule 36 ~25 行)/config.json(+1 键)/scripts/check-skill-modify.sh(新建)/scripts/zcode-pretooluse.sh(接线)/scripts/check-complete.sh(+SKILL-MODIFY GATE)/scripts/selftest-skill-modify.sh(新建)/SKILL.md(净增≤10 行)/README.md 与 references/batch-quality-gate.md(锚级联 1-35→1-36)
- 不动清单：Rule 28/31/32/35 既有语义、templates/variant/rule-enhancement-type.md(v077 遗留 diff 保持原样)
- Phase 1-5 对齐简报：P1 主进程白名单①+code-runner-agent；P2 executor(sonnet-1) 严格串行（S-unit ID 纯数字，步级≤2 文件/≤100 行/≤15min：S1 条款/S2 config 键/S3 check-skill-modify.sh+pretooluse 接线/S4 GATE）；P3 executor；P4 executor；P5 主进程白名单①②
- Handoff 登记表预填一行已完成侦察：Explore/结构侦察/status=done/checkpoint=subagent-state/01-explore-conventions.md/findings 落点=Research Findings
- 必要知识储备表：两个检查点文件+critical-rules.md Rule 31/32 锚（已确认可获取）
- Decisions Made 预登记 3 行：①Rule 36 设计裁定=用户 2026-09-17 诉求+文章优化技能流量分级功能静默移除事故 ②保守化示范=引用 D6/31.3 不改既有条款语义 ③skill_modify_enforce 默认 warn
- 隔离决策=worktree /mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism 分支 wt/task-v079-skill-modify-conservatism 基于 master

### B. <plan-dir>/knowledge-brief.md
五段：速览 / 已验证事实(引 01 检查点关键行+节号) / 文件锚点(每将改文件绝对路径+插入位置) / 易错点(config additionalProperties:false 新键必须进 properties；改 Rules 1-N 前 grep -rn "Rules 1-" scripts/ 全修齐；check-delegation 对子代理 exit 0 放行故新守卫需独立覆盖子代理；S-unit ID 纯数字；Explore 无 Write 教训=检查点主进程代落盘) / S-unit 材料包索引(指向两检查点文件节号)

## 里程碑落盘（22.8）
每完成一步（读完输入/写完 A/写完 B）立即追加写入 subagent-state/02-plan-writer.md（同目录）：已完成步骤+产出路径+字数。
