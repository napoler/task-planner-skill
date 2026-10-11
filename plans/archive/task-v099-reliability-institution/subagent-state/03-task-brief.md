# P2-S1 任务书: critical-rules.md EOF 纯追加 Rule 42+43 九子条（task-v099）

任务: worktree 内 critical-rules.md 末尾纯追加 Rule 42「质量审查技能主动检测与补充」（五子条）+ Rule 43「执行可靠性制度化」（四子条）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/task_plan.md（只读: VC-1 判定标准+Phase 2 S1 验收列）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/progress.md（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution/skills/task-planner/references/critical-rules.md（当前 413 行,EOF=41.x 末条,先 wc -l 确认）

## 硬约束
只在该文件 EOF 后追加,L1-413 一个字符不动（VC-6 边界）;禁写其他任何文件;既有 Rule 1-41 原文零触碰。

## 必读材料
1. 该文件 L383-413（Rule 40/41 全节）——格式范式必须同构: 节头 `### 42 …（P0 — task-v099，目标：…）`,子条行首 `42.1 **标题**：内容`（行首直接 42.N/43.N,不加星号前缀,保证 `grep -c '^42\.'`=5、`grep -c '^43\.'`=4）
2. /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/01-task-brief.md 的「主进程 D2 已裁方案骨架」段（Rule 42 五子条+Rule 43 四子条完整定义,权威源,逐条据此撰写）
3. /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/knowledge-brief.md §1/§4

## 撰写要求（语言风格对齐 Rule 39/40/41,可适度扩写不偏离骨架语义）
- 每节前置引言 1-2 句: 42=质量审查从「临时起意」变「检测+补充+登记」制度;43=可靠性从「相信模型阐述」变「证据先行+档位经济+候选预验证」制度;二者为后置制度层,既有 22.3/28/35.6/Rule 25/41 原文零改动。
- 42.5 与 43.4 机制收尾必须各含「零新 config 键」+「selftest-reliability-institution.sh 静态断言」+「C30/C31 消费侧」措辞。
- 42.3 必须含「补充动作本身作为一个 S-unit 登记进计划（禁无登记私建技能）」;43.1 必须含「未验证内容只能以『未验证』显式登记」+「子代理 8 字段返回的 evidence 列无证据=该项视为未完成」;43.2 必须含「取可承载该步的最小档位」;43.3 必须含「候选对比表」;42.2 三级检测顺序=项目级（.zcode/skills、.agents/skills 工作区级）→用户级（~/.zcode、~/.agents）→环境既有 agents（code-reviewer/critic 类）,均未命中=缺口。

## acceptance: 验收标准
1) `grep -c '^42\.' <目标文件>` = 5 且 `grep -c '^43\.'` = 4
2) `git -C <wt> diff --numstat` 该文件纯增（deletions=0）,L1-413 零变化
3) 上列 8 个必须含措辞逐条 grep 命中
4) 新增文本禁出现「Rules 1-4x」越界数字子串形态（「1-40」「1-41」等字面禁用,如需引用既有规则写全名「Rule 40」式）
5) `wc -l` 记录新行数

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/03-executor-p2s1.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
