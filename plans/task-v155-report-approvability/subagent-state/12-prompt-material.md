# S12 材料包：RRV-01..07 断言规格（selftest-report-reviewability.sh 上半）

> 供 executor 实现 worktree 内 `skills/task-planner/scripts/selftest-report-reviewability.sh`（RRV-01..07）。RRV-08..13 属下一单元，本脚本预留断言函数骨架与 TODO 注释即可。技能根 = `$(cd "$(dirname "$0")/.." && pwd)`（脚本位于 skills/task-planner/scripts/ 下）。

## 脚本结构要求
- bash；头注释四要素（用途/消费方=终验与 CI 回归/断言面=Rule 70 呈报可审批性静态锚/依据=task-v155 计划+Rule 70 条文）。
- PASS/FAIL/WARN 计数与输出风格同构于 `skills/task-planner/scripts/selftest-research-first.sh`（先 Read 它对齐格式）。
- 每条断言输出一行 `RRV-NN PASS/FAIL/WARN: <一句话>`；末行 `Total: PASS=N FAIL=N WARN=N`；FAIL>0 → exit 1，否则 exit 0。
- **禁硬编码行号**（断言目标用 grep 文本锚；脚本自身文本同样禁 `:数字` 引用形态）。
- What+Why 双层注释（Rule 45）。

## RRV 断言（对象路径均相对技能根）
- RRV-01 条款锚：`references/critical-rules.md` 中 grep -c "^## Rule 70（" = 1；`grep -c "^### 70\.[1-6]"` ≥6（六子条 70.1 适用范围/70.2 最小信息集/70.3 强度分级/70.4 单一权威源/70.5 与既有规则关系/70.6 机制）。
- RRV-02 四要素词：同文件 grep -c "待审项清单" ≥1、"可定位地址" ≥1、"看点" ≥1、"动作" ≥1（文件级计数即可）。
- RRV-03 行号锚禁令：提取 `^## Rule 70（` 起至文件尾的片段（sed -n '/^## Rule 70（/,$p'），片段内 grep -E ':\s?[0-9]+' 命中即 FAIL（条文不得引用行号，防级联漂移——v148 判例）。
- RRV-04 SKILL 接线锚：`SKILL.md` grep -c "Rule 70" ≥4 且 grep -c "C46" ≥1（C46 行含「待审项清单」与「可定位地址」字样）。
- RRV-05 触点锚：13 文件清单（相对技能根）逐一 grep "Rule 70" ≥1，任一缺失=FAIL：
  1. SKILL.md
  2. reference.md
  3. references/worktree-isolation.md
  4. references/batch-quality-gate.md
  5. templates/task_plan.md
  6. templates/batch_report.md
  7. templates/variant/image-type.md
  8. templates/variant/multiview-ref-type.md
  9. review-library/general-review/SKILL.md
  10. review-library/alignment-review/SKILL.md
  11. review-library/code-quality-review/SKILL.md
  12. companion/agents/article-batch-publisher.md
  13. companion/agents/article-field-fixer.md
  （注：companion/agents/plan-writer.md 已并入 4 号相邻补丁——以 13 文件清单为准执行；若 grep plan-writer.md 也命中属正常，不参与断言。）
- RRV-06（WARN 档默认）registry 登记：`scripts/selftest-registry.tsv` grep "selftest-report-reviewability" ≥1；config 零新键：`config.json` grep -c "report_lint\|reviewability_enforce" = 0（恒 FAIL 档，违反零新键=FAIL）。registry 行由下一单元登记——**本条 registry 子项默认 WARN**（env `RRVV_REGISTRY_STRICT=1` 时升 FAIL），注释写明「中间态宽限，登记完成后由下一单元改为常驻 FAIL 档」。
- RRV-07（WARN 档默认）lint 段锚：`scripts/check-complete.sh` grep -c "report-lint" ≥1——该段由下一单元插入，本条默认 WARN（同 env 升级），注释同上。

## 验收（回到任务书 §3）
bash -n 通过；自跑 exit 0 且逐条 RRV 输出；chmod +x；脚本自身无 `:数字` 引用形态。
