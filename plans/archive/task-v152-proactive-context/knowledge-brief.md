# Knowledge Brief — task-v152-proactive-context（任务知识简略要点）
<!--
  本文件由 scripts/init-session.sh 复制（第 6 计划文件）。
  定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
  计划期产出，执行期回填 §2/§3。
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：task-planner 技能新增「主动上下文评估与优化」机制——执行中主动评估上下文过长/混乱信号，命中主动压缩整理，穷尽后写会话交接文档转新会话；验收=新 Rule 条款+模板+守卫 selftest 全 PASS+回归零新增 FAIL+部署位 IDENTICAL
- 背景/动机：用户 2026-10-09 提出（R1-R4 见 findings.md Requirements）；既有 Rule 29 只有事件驱动触发+行数代理指标、无 hook 承载、无会话级交接文档——三空白（findings A/C/G）

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| Rule 67（本任务拟新增） | 上下文压力主动评估与会话交接纪律；编号 67 已避让并行 v151 的 66 |
| 上下文压力三态 verdict | HEALTHY（继续）/ PRESSURE（主动压缩整理）/ CONFUSED（交接兜底）——设计核心，待 Phase 1 定稿 |
| env 降档 | 零新 config 键先例：用 TASK_PLANNER_* 环境变量覆盖默认值（Rule 64.5/64.6） |
| worktree | git 隔离开发区，本任务实现类必须在其中开发（宪法 §十一） |
| 三部署位 | ~/.zcode、~/.claude、cursor 等技能部署副本，终验须 diff=0 对账 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 29 触发仅三档（Phase complete 每 2 个/会话恢复/用户显式），全事件驱动 | critical-rules.md:294 | 「主动评估」是真空白，新条款有立足点 |
| check-context-hygiene.sh 4 项检查全是行数/结构代理指标 | scripts/check-context-hygiene.sh:46,56 | 评估信号需新设计（失败/矛盾/轮数代理） |
| Rule 29.5 自述「hook 未接读取」 | critical-rules.md:298 | hook 承载是增量增强，非改既有语义 |
| Rule 65 周期回顾未接 hook（posttooluse 只有 drift-rhythm N=10） | scripts/zcode-posttooluse.sh:46-107,321-344 | hook 接线有既有节奏块可复用，免新计数器 |
| 会话级交接文档机制/模板全仓零命中 | Explore G 节 grep 结论（agent_9c951ea4） | templates/session-handoff.md 为纯新增 |
| 编号账本最高 landed=65，66/67 无记录；并行 v151 声明 new_rule:66 | plans/.rule-reservations.jsonl:33 + plans/task-v151-goal-mode/task_plan.md | 本任务 attest 声明 new_rule:67 避撞号 |
| SKILL.md :9,:280,:360 三处钉「Critical Rules 1-65」 | skills/task-planner/SKILL.md:9,280,360 | 新增 Rule 后须级联 1-67（三处+references 表） |
| 大量 selftest 钉 config properties=42 | selftest-research-first.sh / selftest-four-file-dataflow.sh / selftest-execution-honesty.sh | **零新 config 键为硬约束**（env 降档） |
| selftest-registry.tsv 4 列 63 行=63 脚本实测一致 | scripts/selftest-registry.tsv（表头+63 行） | 新 selftest 必同步加行，SR-12 动态断言自动跟随 |
| hooks 四事件：SessionStart/PreToolUse/PostToolUse/UserPromptSubmit | /home/terry/.zcode/cli/config.json hooks.events | hook 接线只动技能侧 zcode-posttooluse.sh，不动 config.json |
| Rule 64.5/64.6 env 降档先例 | critical-rules.md Rule 64.5/64.6（task-v148） | 新机制开关设计照此范式 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :290-299 | Rule 29 全条款（触发/退场/压缩/整理/配置/反模式）——新条款扩展面 |
| skills/task-planner/references/critical-rules.md | :816-846 | Rule 65 条款（当前文末最后一条）——**Rule 67 插入点=其后（供料 2026-10-09，实施日重验）** |
| skills/task-planner/SKILL.md | :9,:280,:360 | 「Critical Rules 1-65」三处钉值——改 1-67 级联点 |
| skills/task-planner/scripts/zcode-posttooluse.sh | :46-107,:321-344 | drift-rhythm 节奏计数块（N=10）——评估提醒接线候选载体 |
| skills/task-planner/scripts/check-context-hygiene.sh | :1-145 | 29.2 检查器 4 项——评估动作可复用其 exit 码语义 |
| skills/task-planner/scripts/selftest-registry.tsv | 全表 | 4 列表头+63 行——新 selftest 登记面 |
| skills/task-planner/templates/ | 目录 | 10 主模板+29 variant，无 handoff 类——纯新增模板 |
| plans/.rule-reservations.jsonl | :33 | 末行 landed=65——attest 时 67 查重源 |
| /home/terry/.zcode/cli/config.json | hooks.events | 四事件挂载表——改 hook 脚本不改本文件 |

## §4 易错点与禁止假设清单
1. 禁止新增 config 键（properties=42 被多 selftest 钉死）——开关一律 env 降档；违反=大面积回归
2. 禁止占 Rule 66（并行 task-v151 已声明 new_rule:66 在途）——撞号=历史级联事故（v143/v142 判例）
3. SKILL.md 行数/计数断言随增行必级联（skill-split 钉值、1-N 计数、C-list 编号）——改 SKILL 前先 grep 钉值清单
4. v151 在 wt/v151-goal-mode 并行改同批文件（critical-rules/SKILL/registry）——我的 worktree 从 master 建，合并顺序冲突预期=文尾追加点并集解
5. 部署位同步不能漏（历史教训：部署 cp 对账必做）——终验 smart-merge-back.sh --deploy + diff 对账
6. Explore 是只读模式不会写检查点——结论已在 findings.md，勿再等检查点文件
7. 计划文件 ENOSPC 截断风险：写前 df 检查（memory 判例，<50MB 暂停）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「hook 接线失败」「SKILL 钉值级联漏网」行（计划产出后回填）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2 + §3 | plans/task-v152-proactive-context/design-draft.md §1（六子条草案全文） |
| S2 | §3 + §4 | design-draft.md §4（钉值级联清单 8 项） |
| S3 | §1 + §3 | design-draft.md §2（五段模板草案全文） |
| S4 | §3 + §4 | design-draft.md §3（hook 施工图）；worktree 内 zcode-posttooluse.sh 实况（插入位实施日重验） |
| S5 | §2 + §3 | design-draft.md §1(67.6 断言面) + §4#7 |
| S8, S9 | §3 + §4 | design-draft.md §4#5（标签级联）+ v149 对齐注先例（CLAUDE.md:33 的 2026-10-08 注） |
| S10, S11, S12 | §2 + §3 + §4 | design-draft.md §4#5 + v149 同构判例 plans/task-v149-skill-alignment-audit/subagent-state/12-executor-S18.md（锚演进批范式） |
| S13 | §3 | worktree 内 scripts/selftest-skill-split.sh:44-46 演进注释链（钉值先例） |
| S6 | §2 | plans/task-v152-proactive-context/baseline-selftest.log（63/63/0 基线） |
| S7 | §1 + §3 | design-draft.md 全文（设计意图对照） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| alignment-review | ~/.zcode/skills/alignment-review/SKILL.md | 42.6.2 标准收尾：全部产出对齐审查 | 主进程 Skill 调用（终验前） |
| plan-resume | ~/.zcode/skills/plan-resume/SKILL.md | 交接文档的恢复消费侧（Rule 24.5） | 新机制引用其恢复链（只读参考） |
| task-drift-guard | ~/.zcode/skills/task-drift-guard/SKILL.md | 「混乱」信号与 drift 判定互补关系 | 只读参考（条款互引措辞对齐） |
