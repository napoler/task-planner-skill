# Subagent Dispatch Prompt — task-v157 Phase 1 S1（explore 存量能力侦察）

## 1. 目标
摸清本仓与 live 环境中既有的「错误排查/提示词生成」能力，为新 skill `error-fix-prompt-forge`（把已定位根因的排查结果转化为可派发的专业修正提示词）划定边界，输出能力清单+差异化边界+fixture 形态摘要。
> 本会话只执行本 S-unit：完成后交回主进程验收，禁止本会话内领取多个 S-unit 或批次追加（Rule 46.1）。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」——本 S-unit 回答「仓内是否已有同类能力、新 skill 边界划在哪」。

## 2. 输入(计划三文件必传,绝对路径 — 只读三文件,仅按契约追加)
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读(禁止修改)
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:01-explore] 存量能力侦察结论` 到 `## Research Findings` 段末(`## Technical Decisions` 前),禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 1 段「Actions taken」下追加 `  - [sub:01] 侦察完成:边界N条`,禁改 Status/Started
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/knowledge-brief.md — 只读(先读 §1/§2/§3/§6 对齐任务上下文)
- 材料包(只读): /mnt/data/dev/task-planner-skill/skills/(仓库 skill 全清单)、/home/terry/.zcode/skills/ 与 /home/terry/.agents/skills/(live 能力清单,含 systematic-debugging)、/home/terry/.zcode/agents/(是否存在 debugger 类 agent 定义)、/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md(真实排查调研 fixture 形态)
- findings.md 相关摘要(≤10 行): findings.md 为新建文件,按上方契约写即可;任务背景见 knowledge-brief §1(排查结论→修正任务书断层,新 skill=error-fix-prompt-forge 五步闭环:输入校验→结构化抽取→缺口分析→模板渲染→自包含自检)
- 工具面提示: 本 S-unit 执行工具面=Explore 只读搜索;禁 Network/WebFetch(纯本地盘点)
- 并行组声明: 未声明组=串行槽

### 伴飞技能
无（纯机械侦察单元）。

## 3. 验收标准
- [ ] checkpoint 文件含①能力清单表(名称/位置/职责一句话)②边界清单(新 skill 不得做什么,≥4 条,每条指名对应既有能力)③fix-prompts.md 形态摘要(≤10 行)
- [ ] findings.md `## Research Findings` 段末出现 `#### [sub:01-explore]` 小节且结论与 checkpoint 一致
- [ ] 无 Network 调用记录;未修改 task_plan.md/progress Status

## 4. Scope 禁改清单
- 禁止修改: 三文件除 §2 契约追加外的任何内容、skills/ 下任何文件、其他 worktree 与 plans/ 其他任务目录 | 禁止操作: git 写操作(add/commit/checkout/reset)、rm、安装依赖

## 5. 工作路径
- 只读仓库内容用绝对路径 /mnt/data/dev/task-planner-skill(或 worktree /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge,内容一致);不切换 CWD

## 6. 时长预算
- 任务类型: 只读侦察 → 超时阈值 15 分钟;超过阈值:立即返回 partial,报告未完成部分

## 7. 返回格式(严格 — 8 个固定字段,逐字段填写,字段名与顺序不得改、不得增删,无内容填 none;8 字段之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:01-explore]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/01-explore.md
- 落盘纪律: T1 每完成一文件 Write → 追加里程碑行(带时间戳);T2 搜索调研得结论 → 追加;T5 任务结束 → 写「最终结论」段(= 第 7 节同一 8 字段块),置 status: done(必做)
- 文件格式: 头部 status 行 + 已完成里程碑(append-only 带时间戳) + 进行中 + 产出文件清单 + 错误与受阻 + 最终结论;纯 markdown,无 frontmatter

## 9. 上下文预算
- 只读 §2 列出的路径,不做计划外探索;结论先落 checkpoint 再返回消息

**执行步骤(3 步,按序)**:
Step 1: Read knowledge-brief.md §1-§3/§6 + 列目录(仓库 skills/、~/.zcode/skills、~/.agents/skills、~/.zcode/agents)建能力清单
Step 2: 比对边界——读 systematic-debugging SKILL.md 头部与 debugger 类 agent 定义头部(≤各 30 行),读 task-v153 fix-prompts.md 归纳 fixture 形态
Step 3: 写 checkpoint(能力清单+边界≥4条+fixture 摘要)并按 §2 契约追加 findings/progress,返回 8 字段
