# 01 Explore 考古检查点（2026-09-16，主进程回填）

> 用途：本文件是 plan-writer/后续 S-unit 的材料包锚点源。行号基于 master@a182aed。

## 结论速览
- critical-rules.md 共 290 行，Rule 34 段止于 L290 → **Rule 35 插入点 = L290 之后**
- 全文件无既有「能力否定/先读完整接口文档」类条款（grep 无法|不可能|接口文档 仅 4 处无关命中）→ 不重复立法
- SKILL.md 共 535 行（selftest-knowledge-brief.sh:38 断言 ≤540，净增预算 ≤5 行）
- 全量 selftest 口径：`for f in scripts/selftest-*.sh` 逐个跑、逐 `Total:` 行求和；现 19 脚本基线 313/0（plans/task-v075.../progress.md:152）
- config.json：本任务目标零新键

## 精确锚点
| 锚点 | 位置 |
|---|---|
| Rule 34 段末（Rule 35 插入点） | critical-rules.md L281-290 |
| Rule 22.4 单行条款（超限补救追加处） | critical-rules.md L127（末句含"机器校验已生效：check-dispatch.sh…"） |
| Rule 22.7 换档 | critical-rules.md L133-134 |
| Rule 31 段（31.5 消费侧 L257） | critical-rules.md L249-258 |
| SKILL.md Critical Rules 列表 Rule 33/34 行（35 行插入点） | SKILL.md L300/L301 |
| SKILL.md C22 行（C23 插入点）/ C19 行 | SKILL.md L196 / L193 |
| SKILL.md "Rules 1-34" 三处 | L9（frontmatter）/ L277 / L325 |
| SKILL.md 五档兜底表 | L401 表头，表体 L403-409（兜底注行插 L409 后） |
| SKILL.md prompt_max_chars 提及 | L397 |
| check-dispatch.sh prompt 长度警告 | L258 `echo "[dispatch-guard] ⚠ prompt 长度 $pchar > $pmax"` |
| check-dispatch.sh 打包检测警告 | L266；阻断 L285 |
| selftest-dispatch.sh 用例 | T01-T12=L77-135；TS-01..06=L137-207；FG-01..04=L209-276（末例 L276）；Total 行 L278（现 22 断言）；FG 断言用 `grep -qF 'prompt 长度'` |
| selftest 断言 "Rules 1-34" 锚 | selftest-reflect-verify.sh:60（+头注释 L13）；selftest-error-loop.sh:14 / selftest-veto.sh:13（宽容锚 `Rules 1-3[1-4]`） |
| SKILL.md 行数上限断言 | selftest-knowledge-brief.sh:38 `≤540（task-v074 扩充）` |
| subagent_dispatch.md §9 上下文预算 | L91-94（L92 现行解法=拆细，**无落盘表述**，补救行插 L92 后）；材料包小节 L25-29 |
| CHANGELOG 条目样式 | L8 [Unreleased] → L10 ### 新增 → L12-15 `- **特性（task-vNNN 子项）** — 描述` |
| rule-enhancement 模板 S-unit 7 列表头 | templates/variant/rule-enhancement-type.md L55（L54 注释：attest 校验时长/输入列） |
| 模板 Phase 骨架 | 同文件 L47/51/60/64/68（P1 隔离基线→P5 合并部署） |
| notepad 被否决方案段名 | templates/notepad-learnings.md:14 `## 🚫 被否决方案（User Rejected — Rule 32）` |

## 防回归级联（改 "Rules 1-34" 前必读）
templates/variant/rule-enhancement-type.md:41 指令：改 SKILL.md "Rules 1-N" 字样前先 `grep -rn "Rules 1-" scripts/` 扫全部锚断言一次修齐。已知锚 = 上表 selftest 三处 + SKILL.md 三处。
