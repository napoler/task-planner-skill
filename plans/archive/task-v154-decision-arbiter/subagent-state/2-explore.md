# S2 登记面锚定位检查点（Explore 返回结论落盘，主进程代写 2026-10-10）

> Explore 子代理（agent_afdc920d）为只读角色未写检查点，本文件=主进程按其返回消息落盘兜底（Rule 22.8）。

## ① D2 登记面：skill-agent-router
- 文件：`/home/terry/.zcode/skills/skill-agent-router/SKILL.md`（单文件技能）
- 路由表格式：§一 4 列（Agent|触发场景|何时不该用|与相似 agent 区别）；§二至§九 3 列（无区别列）
- 插入锚：§八「其他通用类」末尾 **line 101（meta-corrector 行）之后**；建议新增「判断/裁决类」小节或 §八末尾插入
- 其他同步文件：无

## ② D3 登记面：template-mapping
- §九 机制适用性矩阵（line 254-289，5 列：类型|组别|默认适用机制|不适用机制|执行体路由组）
- 「判断/裁决」类现有行：无（29 类中无）
- 插入锚：**line 289（general 行）之后**
- §十 工具选择映射（line 300-314，4 列）也需同步一行

## ③ selftest registry 登记面
- TSV：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv`（4 列 tab：script|domain|trigger_scenarios|dep_anchors，65 行=表头+64）
- 样例行：`selftest-drift-check-subagent.sh	Rule 61 偏移检查子代理化	Rule 61 条款 / SKILL 路由表「漂移检测」行 / 覆盖矩阵行	SKILL.md;references/critical-rules.md;scripts/check-dispatch.sh`
- **新 selftest 必须登记**：是（selftest-registry.sh T02 断言：未登记→FAIL）
- 定数钉值断言：**无**（SKILL.md 与 critical-rules.md 均无「NN 脚本」类定数）→ 新增 selftest 不引发钉值级联

## ④ critical-rules.md Rule 69 插入锚与条款风格
- Rule 69 插入锚：**line 860（Rule 66.6 结尾）之后**（文件当前止于 Rule 66；67/68 是 v152/v153 预留未落地，合并时留意尾部冲突）
- 撞号检查：文件中无 "Rule 68/69" 字样 ✓
- 条款风格（Rule 61 样例）：
  - `- **61.1 载体强制**：……` 列表式加粗子条（61 用列表式）
  - Rule 63 用段落式：`63.1 **目标公理（…）**：…` 顶格子条
  - 子条编号 `NN.M`；每子条 1-3 句含 What/Why；末子条=机制声明（零新 config 键+selftest 守护）

## ⑤ SKILL.md 触发点插入锚（6 处）
| 触发点 | 行号 | 现有原文锚 |
|--------|------|-----------|
| T1 计划期方案终裁 | line 79 | 思维方法论段「方案候选与 D2 选项按 T3 结论先行并附 T4 推导链」 |
| T2 兜底链换道裁决 | line 452 | `**五档兜底(优先级顺序,Rule 22.3 — 拆细先于升档;…)**:` |
| T3 子代理失败复核定级 | line 463 | `**触发条件**(任一):` / `- 子代理返回 status: failed 或 partial 但关键产出缺失` |
| T4 验收完成度争议 | line 90 | 3a 段「回填完成才可勾 Handoff 登记表 verify_done（…见 22.5）」 |
| T5 DRIFT 处置裁决 | line 99-101 | `6. **[DRIFT CHECK]** 派发 drift-checker…` / `- ⚠️ DRIFT → 记录 progress.md，警觉继续` |
| T6 CR 分歧与终验边界 | line 139-150 | Code Review Gate 段；line 149 `- **门控**：code-review 输出 APPROVED 才允许进入终验交付；否则阻断` |
- 路由表「漂移检测」行：**line 409**（decision-arbiter 新行插入锚）
- Critical Rules 清单 Rule 66 行：**line 338**（Rule 69 清单行插入锚）
- References 表：**line 362**（critical-rules.md 行）

## 附：S1 基线（1-code-runner.md 摘要）
- 64/64 全 PASS，ΣPASS=1002，ΣFAIL=0，零 timeout；原始日志 /tmp/selftest-baseline/*.log
- 执行窗口并发观察：INDEX.md 刷新+task-v155 目录创建（并行会话动作，与本任务无关）
