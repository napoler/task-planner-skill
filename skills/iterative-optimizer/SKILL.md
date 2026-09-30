---
name: iterative-optimizer
description: 循环迭代优化器——对提示词精修(prompt refinement)/参数调优(parameter tuning)/缺陷修正(defect correction)及同类优化任务执行「评估→诊断弱点→定向改进→门控判定」闭环,每轮自动评估产出/定位最弱项/施加最小定向改进/判定是否续轮,达到预定义质量标准或最大轮次即收敛,输出迭代摘要(改了什么/为什么/是否解决)。适用:可重复评估且有客观质量标准的多轮优化任务;单次可完成且无评估标准的任务不适用。
---

# iterative-optimizer · 循环迭代优化

loop-based iterative mode: 固定五步 + 状态文件,轮次执行 stable repeatable。
闭环结构: evaluate → diagnose weaknesses (identify weaknesses) → 定向改进 (apply targeted improvements) → gate 判定 (decide whether another round),全部达标或达最大轮次即收敛。

**Goal** (loop-based iterative mode): 给定任务目标 + 初始产出位置 + 质量标准 (predefined quality criteria) + 最大轮次 (maximum iteration limit),输出三项:

- **满足质量标准的优化后产出**: 就地更新,位置 <最终产出路径>
- **迭代摘要表**: 逐轮三列「改了什么 / 为什么 / 门控结果」(模板见「输出合约」段)
- **状态文件**: `plans/loop-<task-id>-state.md`, 含逐轮 QC 证据,支持跨会话断点续跑

每轮必须附机器可复现证据(命令 + 关键输出);收敛判定基于证据而非主观感觉。

## 触发条件

- 用户要求循环/迭代优化: 提示词精修/prompt refinement、参数调优/parameter tuning、缺陷修正/defect correction、文案打磨、迭代改进
- 任务可重复评估且能定义客观质量标准
- /goal 目标驱动模式下的多轮收敛任务
- 不触发: 单次执行即可完成且无评估标准的一次性任务——直接做,勿套循环;循环套一次性任务 = 过度工程化
- 不触发: 无判定标准的开放式探索任务

## 执行前输入契约

| 输入 | 要求 | 缺省 |
|------|------|------|
| 任务目标 + 初始产出位置 | 必填 | — |
| 质量标准 QC-1..N (predefined quality criteria) | ≥3 条;其中 ≥1 条必须机器可检查(grep/数值阈值/schema/测试命令);禁止纯主观判定词 | 缺失 → 与用户协商出再启动,协商不成 → 不启动 |
| max_iterations (maximum iteration limit) | 上限轮次 | 默认 5 |
| 改进约束(可选) | 禁改区域/必须保留要素 | 无 |

契约规则:
- 缺任一必填项 → STOP,按默认项 + 自动超时规则(task-planner Rule 44)与用户协商;协商不成 → 不启动
- QC 条款禁止含不可机械判定的主观判定词;只允许机器可检查或客观可定义的判据

## 执行流程(每轮五步,门控推进)

- [ ] **Step 0 初始化**: 建状态文件 `plans/loop-<task-id>-state.md`, 内容:
  - 轮次表: 轮次 / 动作 / 证据 / 门控结果
  - QC-1..N 登记,标注机器可检查项及其检查命令
  - 已有状态文件 → Read 断点续跑(接上轮次,不重头)
- [ ] **Step 1 评估 (evaluate)**: 当前产出逐条核验 QC-1..N
  - 机器可检查项必须实际跑检查命令并附输出,禁止替代性推断
  - 每条记 PASS/FAIL + 证据;全 PASS → 跳至 Step 4 情形①
- [ ] **Step 2 诊断弱点 (diagnose · identify weaknesses)**:
  - 列全部 FAIL 项,按影响排序
  - 选定本轮最弱项 1-2 个(单 focus: 每轮只治最弱项,禁止一次全改——多改致归因失效)
- [ ] **Step 3 定向改进 (improve · apply targeted improvements)**:
  - 对选定弱点做最小定向修改;改前 Read 现文,改后附 diff/命令证据
  - 禁止顺带修改未诊断项(Scope Lock)
  - 若改动可能影响已 PASS 项 → Step 1 全量重跑(回归面)
- [ ] **Step 4 门控判定 (gate · decide whether another round)**,三态:
  - ① QC 全 PASS → 收敛,输出摘要,结论 RESOLVED
  - ② 有 FAIL 且轮次 < max_iterations → 回 Step 1
  - ③ 轮次 ≥ max_iterations → 停止,输出摘要 + 遗留 FAIL 清单,结论 PARTIAL
  - 补充出口: 同一 FAIL 连续 2 轮无改善(门控铁律 P1)→ 随时停止,结论 BLOCKED

每轮执行纪律:
- 每轮结束必须回写状态文件(轮次表 + QC 证据 + 门控结果)
- 跨会话凭状态文件续跑;无状态文件不得盲续

## 门控铁律

- [P0] Gate 判定必须逐条 QC 附证据,禁止以主观感觉自报过关、无命令证据的自报——无证据 = 未验证
- [P0] 达到 max_iterations 未达标 → 结论 PARTIAL + 遗留清单,禁止宣称 RESOLVED
- [P0] 每轮改进最小定向,禁止大重写(归因失效 + 回归风险)
- [P1] 连续 2 轮同一 FAIL 项无改善 → 停止重试,诊断根因/换策略/呈报(无效循环 = token 失控)
- [P1] 改进不得破坏已 PASS 项;可能影响 → 全量重跑 QC

## 输出合约: 迭代摘要

| 轮次 | 改了什么 (what) | 为什么 (why → 对应 FAIL 项) | 门控结果 (PASS/总数) |
|------|----------------|-----------------------------|----------------------|
| 1 | … | … | … |
| 2 | … | … | … |

(空轮无变更不列)

**任务结论**(三枚举):
- RESOLVED — QC 全 PASS,质量标准达成
- PARTIAL — 达 max_iterations 上限,遗留 FAIL 项如实列出
- BLOCKED — 同一 FAIL 项连续 2 轮无改善,根因未解

**总轮次**: N / max_iterations; **状态文件**: <path>; **最终产出**: <path>

## 反模式

- ❌ 无质量标准就开跑 / ✅ 先协商出 ≥3 条 QC(含机器可检查)再启动
- ❌ Gate 靠 AI 自报「已达标」/ ✅ 逐条 QC 附命令输出为证
- ❌ 一轮改五个问题 / ✅ 单 focus,每轮 1-2 个最弱项
- ❌ 达上限仍宣称优化成功 / ✅ PARTIAL + 遗留清单如实交付

<!-- task-v106-iterative-optimizer;顶层执行型工作流 skill;S54 Loop 元件=State(状态文件)+Gate(QC 逐条证据),Automation 可选;install-companion 顶层分发 -->
