# S7 材料包：DG-01..07 断言规格（selftest-decision-grading.sh 上半）

> 供 executor 实现 worktree 内 `skills/task-planner/scripts/selftest-decision-grading.sh`（DG-01..07）。DG-08..12 属下一单元，本脚本预留断言函数骨架与 TODO 注释即可。技能根 = `$(cd "$(dirname "$0")/.." && pwd)`（脚本位于 skills/task-planner/scripts/ 下）。

## 脚本结构要求
- bash；头注释四要素（用途/消费方=终验与 CI 回归/断言面=Rule 72 决策分级静态锚/依据=task-v160 计划）。
- PASS/FAIL/WARN 计数与输出风格同构于 `skills/task-planner/scripts/selftest-report-reviewability.sh`（先 Read 它对齐格式）。
- 每条断言输出一行 `DG-NN PASS/FAIL/WARN: <一句话>`；末行 `Total: PASS=N FAIL=N WARN=N`；FAIL>0 → exit 1，否则 exit 0。
- **禁硬编码行号**（断言目标用 grep 文本锚；脚本自身文本同样禁 `:数字` 引用形态）。
- What+Why 双层注释（Rule 45）。

## DG 断言（对象路径均相对技能根）
- DG-01 条款锚：`references/critical-rules.md` 中 grep -c "^## Rule 72" = 1；`grep -c "^### 72\.[1-6]"` ≥6（六子条 72.1 分级表/72.2 A 级呈报禁令/72.3 琐碎上抛禁令/72.4 基础质检硬门/72.5 与既有规则关系/72.6 机制）。
- DG-02 三级关键词：同文件 grep -c "A 级必须询问" ≥1、"C 级禁止询问" ≥1、"基础质检硬门" ≥1（文件级计数即可）。
- DG-03 行号锚禁令：提取 `^## Rule 72` 起至文件尾的片段（sed -n '/^## Rule 72/,$p'），片段内 grep -E ':\s?[0-9]+' 命中即 FAIL（条文不得引用行号，防级联漂移——v148 判例）。
- DG-04 SKILL 接线锚：`SKILL.md` grep -c "Rule 72" ≥5 且 grep -c "C49" ≥1（C49 行含「A 级」与「C 级」字样）。
- DG-05 触点锚：6 文件清单（相对技能根）逐一断言——
  1. references/critical-rules.md：grep -c "Rule 72" ≥5（28.3/41.2/41.3/44.2/44.5 五处）
  2. templates/variant/image-type.md：grep -c "Rule 72" ≥1
  3. templates/variant/multiview-ref-type.md：grep -c "Rule 72" ≥1
  4. companion/agents/article-batch-publisher.md：grep -c "Rule 72" ≥2
  5. companion/agents/article-field-fixer.md：grep -c "Rule 72" ≥1
  （critical-rules 按文件级计数，其余按文件级计数；任一缺失=FAIL）
- DG-06（WARN 档默认）registry 登记：`scripts/selftest-registry.tsv` grep "selftest-decision-grading" ≥1——registry 行由下一单元登记，**本条默认 WARN**（env `DG_REGISTRY_STRICT=1` 时升 FAIL），注释写明「中间态宽限，登记完成后由下一单元改为常驻 FAIL 档」。
- DG-07 config 零新键：`config.json` grep -c "decision_grading_enforce" = 0（恒 FAIL 档，违反零新键=FAIL）。

## 验收（回到任务书 §3）
bash -n 通过；自跑 exit 0 且逐条 DG 输出；chmod +x；脚本自身无 `:数字` 引用形态。
