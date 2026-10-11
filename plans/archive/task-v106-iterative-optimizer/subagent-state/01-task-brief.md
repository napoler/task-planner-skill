# P2-S1 任务书: 新建 skills/iterative-optimizer/SKILL.md（task-v106）

任务: worktree 内新建顶层 skill `skills/iterative-optimizer/SKILL.md`——循环迭代优化器（loop-based iterative optimization）。禁 git commit/add。只创建该文件,不动任何既有文件。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v106-iterative-optimizer/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer/skills/iterative-optimizer/SKILL.md（新建目录+文件,90-120 行）

## 设计规格（逐段按此撰写,中文为主体,关键术语保留英文）

### ① frontmatter（YAML,恰两字段）:
```yaml
---
name: iterative-optimizer
description: 循环迭代优化器——对提示词精修(prompt refinement)/参数调优(parameter tuning)/缺陷修正(defect correction)及同类优化任务执行「评估→诊断弱点→定向改进→门控判定」闭环,每轮自动评估产出/定位最弱项/施加最小定向改进/判定是否续轮,达到预定义质量标准或最大轮次即收敛,输出迭代摘要(改了什么/为什么/是否解决)。适用:可重复评估且有客观质量标准的多轮优化任务;单次可完成且无评估标准的任务不适用。
---
```
### ② `# iterative-optimizer · 循环迭代优化` + 目标段:
Goal 语句（含交付物名词+形式+标准,禁模糊动词）: 给定任务+初始产出+质量标准+最大轮次,输出**满足质量标准的优化后产出**+**迭代摘要表**+**状态文件**,每轮附机器可复现证据（命令+关键输出）,收敛判定基于证据而非主观感觉。
### ③ `## 触发条件`（5 条左右）:
- 用户要求循环/迭代优化:提示词精修/prompt refinement/参数调优/parameter tuning/缺陷修正/defect correction/文案打磨/迭代改进
- 任务可重复评估且能定义客观质量标准
- /goal 目标驱动模式下的多轮收敛任务
- 不触发: 单次执行即可完成且无评估标准的一次性任务（直接做,勿套循环——循环套一次性任务=过度工程化）
- 不触发: 无判定标准的开放式探索任务
### ④ `## 执行前输入契约`（表格,缺任一必填项 STOP 按默认协商,呈现遵循 Rule 44 默认项+自动超时）:
| 输入 | 要求 | 缺省 |
| 任务目标+初始产出位置 | 必填 | — |
| 质量标准 QC-1..N | ≥3 条,其中 ≥1 条机器可检查(grep/数值/schema/测试命令);禁止纯主观判定词(更好/合理/大致/应该/足够) | 缺失→与用户协商出再启动,协商不成→不启动 |
| max_iterations | 上限轮次 | 默认 5 |
| 改进约束(可选) | 禁改区域/必须保留要素 | 无 |
### ⑤ `## 执行流程（每轮五步,门控推进）`（markdown 任务列表带门控,S63 形态）:
- [ ] **Step 0 初始化**: 建状态文件 `plans/loop-<task-id>-state.md`（轮次表:轮次/动作/证据/门控结果;QC 清单登记并标注机器可检查项;已有状态文件→Read 断点续跑）
- [ ] **Step 1 评估（evaluate）**: 当前产出逐条核验 QC-1..N——机器可检查项必须实际跑命令附输出;每条记 PASS/FAIL+证据。全 PASS→跳 Step 4
- [ ] **Step 2 诊断弱点（diagnose）**: 列全部 FAIL 项按影响排序;选定本轮最弱项 1-2 个（单 focus 原则:每轮只治最弱项,禁止一次全改——多改致归因失效）
- [ ] **Step 3 定向改进（improve）**: 对选定弱点做最小定向修改;改前 Read 现文,改后附 diff/命令证据;禁止顺带修改未诊断项（Scope Lock）;若改动可能影响已 PASS 项→Step 1 全量重跑（回归面）
- [ ] **Step 4 门控判定（gate）** 三态: ①QC 全 PASS→收敛,输出摘要,结论 RESOLVED;②有 FAIL 且轮次<max_iterations→回 Step 1;③轮次≥max_iterations→停止,输出摘要+遗留 FAIL 清单,结论 PARTIAL
- 每轮结束必须回写状态文件;跨会话凭状态文件续跑
### ⑥ `## 门控铁律`（5 条,标注 P0/P1）:
- [P0] Gate 判定必须逐条 QC 附证据,禁止「感觉更好/应该没问题」式自报——无证据=未验证
- [P0] 达到 max_iterations 未达标→结论 PARTIAL+遗留清单,禁止宣称 RESOLVED
- [P0] 每轮改进最小定向,禁止大重写(归因失效+回归)
- [P1] 连续 2 轮同一 FAIL 项无改善→停止重试,诊断根因/换策略/呈报（无效循环=token 失控）
- [P1] 改进不得破坏已 PASS 项;可能影响→全量重跑 QC
### ⑦ `## 输出合约：迭代摘要`（表格+结论枚举）:
| 轮次 | 改了什么（what） | 为什么（why→对应 FAIL 项） | 门控结果（PASS/总数） |
（空表示例行）
**任务结论**: RESOLVED（QC 全 PASS）/ PARTIAL（达上限,列遗留 FAIL）/ BLOCKED（连续无改善）
**总轮次**: N/max_iterations;**状态文件**: <path>;**最终产出**: <path>
### ⑧ `## 反模式`（3-4 条,❌→✅ 形态）:
- ❌ 无质量标准就开跑 / ✅ 先协商出 ≥3 条 QC（含机器可检查）再启动
- ❌ Gate 靠 AI 自报「已达标」/ ✅ 逐条 QC 附命令输出
- ❌ 一轮改五个问题 / ✅ 单 focus,每轮 1-2 最弱项
- ❌ 达上限仍宣称优化成功 / ✅ PARTIAL+遗留清单如实交付
### ⑨ 文末注释行:
`<!-- task-v106-iterative-optimizer;顶层执行型工作流 skill;S54 Loop 元件=State(状态文件)+Gate(QC 逐条证据),Automation 可选;install-companion 顶层分发 -->`

## 硬约束
- 90-120 行;纯文档零 scripts/config 引用;frontmatter 恰两字段
- Goal/QC 上下文禁主观判定词:更好/合理/大致/应该/足够/良好（S47/48）
- 用户原话八锚入位: loop-based iterative mode→标题与目标段;prompt refinement/parameter tuning/defect correction→触发与描述;evaluate/identify weaknesses/apply targeted improvements/decide whether another round→五步;predefined quality criteria→QC 契约;maximum iteration limit→max_iterations;stable repeatable→固定五步+状态文件;what changed/why/resolved→摘要表+结论枚举

## acceptance: 验收标准
1) 文件存在 90-120 行;frontmatter 两字段 name=iterative-optimizer
2) 五步锚各≥1: 评估（evaluate）/诊断弱点（diagnose）/定向改进（improve）/门控判定（gate）/收敛;Step 0 状态文件锚 plans/loop-<task-id>-state.md
3) 输入契约表含「≥3 条」「机器可检查」「max_iterations」「默认 5」
4) 门控铁律 5 条含「禁止」≥3;「PARTIAL」禁止宣称 RESOLVED 锚在位
5) 摘要表头「改了什么」「为什么」「门控结果」+结论三枚举 RESOLVED/PARTIAL/BLOCKED
6) banned 词扫描: `grep -n '更好\|大致\|应该\|足够' SKILL.md` 在 QC/门控上下文零命中（触发条件中描述「不触发」段引用不违规——以实际判定为准,拿不准就避开）
7) `bash -n` 不适用（无脚本）;`git status --short` 仅新增该文件

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v106-iterative-optimizer/subagent-state/01-exec-p2s1.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
