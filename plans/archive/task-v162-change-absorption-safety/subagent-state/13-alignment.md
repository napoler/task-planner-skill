# Checkpoint: 13-alignment（Phase 7 / S13 worktree 全部 .md 改动对齐审查）

- 时间：2026-10-10
- 执行体：alignment-review（本子代理，只读审查，未修改任何文件）
- verdict：**CHANGES_REQUESTED**（P1 ×2 + P2 ×6；无 P0）
- 审查区：/home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/
- 审查 SOP：skills/task-planner/review-library/alignment-review/SKILL.md

## 审查对象总清单（Rule 70① —— 绝对路径+一句话）

| # | 文件（worktree 内绝对路径） | 审了什么 |
|---|---------------------------|---------|
| 1 | /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/references/critical-rules.md | 4 处 .md 改动：8.1 尾追加 74 语义门句、36.5 尾追加特化定位句、56.1 句中插入 74.2 括注、EOF 追加 Rule 74 全文（74.1-74.6） |
| 2 | /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/SKILL.md | 8 个 diff hunk（归并 7 接线面）：frontmatter 全集行 1-69+70→1-74、Rules 列表 Rule 74 bullet、「详见」行 1-71→1-74、References 用途表行 1-71→1-74、B 扩展行加 74 指引、用户新指令处理段新增「变更吸收三判门」段、退出检查区新增 Rule 74 bullet、合规清单 C51 新行 |
| 3 | /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/templates/task_plan.md | 新增「## 📋 变更标注表（Rule 74.3）」区块（说明段+6 列表+CA-1 示例行），位于执行范围限制段与必要知识储备段之间 |
| 4 | /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/templates/subagent_dispatch.md | 文件尾新增「## 定稿可行性判别模式（Rule 74.4）」段（契约段） |

改动规模：`git diff --stat` → 4 files, 31 insertions(+), 7 deletions(-)。

## 通过项（附机器可复现证据）

1. **条文↔既有规则一致（Rule 74 vs 8.1/36.5/51.1/56/69.1/71）**：74.5 分界陈述（8.1=入口层判新建 vs 改；本条=语义层管怎么改）与 8.1 既有语义正交；74.2(b)① 授权形态与 Rule 32 禁令追踪衔接；74.4(b) 与 43.2「最小可承载档位」一致；74.4(f) 豁免与 38.3 mini 档白名单一致；74.4(e) 与 69.1 T1 分工（T1 判候选孰优/本门判定稿能否落地）互补不重叠；74.1 与 36.5 互相定位一致（技能保护区特化，冲突时 36.5 更严）。引用锚存在性全部 grep 验证：`8.1`@crit:29、`22.5`@crit:186、`36.4`@crit:373、`38.3`@crit:397、`43.2`@crit:470、`51.1`@crit:578、`56.1`@crit:644、`69.1`@crit:896、`### 32`@crit:323、`### 26`@crit:239 均命中。
2. **SKILL.md 接线完整性**：7 接线面全在位（见对象清单 #2）。旧值清账：`grep -c '1-71' SKILL.md` → 0（AD-11 同款断言前提成立）；'1-74' 出现 ≥3 处（frontmatter:9/详见:299/References 表行）与 selftest 注释所称「三处」吻合。
3. **模板区块格式一致性**：task_plan.md 新段为同级 `##` + emoji 前缀（📋，与既有 🎯🧮🔍✅⚠️📚 同风格），表格 `| col |` 空格+尾管风格与既有一致，插入点为两段之间空行分隔规范；subagent_dispatch.md 新段与「## 10. 防幻觉契约（Rule 71.5 — 派发默认段，禁删）」同「## 名（Rule 号 — 描述）」命名风格，置于文件尾。
4. **守卫锚级联（佐证，scripts 非本审查范围但其状态佐证 .md 声明）**：selftest-source-anchor-discipline.sh SA-07 已演进为 `'1-74' 计数 ≥2`（:38，注释明记 task-v162 A 类机械替换）；selftest-context-pressure.sh CP-07 锚族已扩 `1-(69|71|74)`（:100）；selftest-absorption-discipline.sh 已建且 registry 自登记（selftest-registry.tsv:73，列表面与 74.6① 声明一致）；config.json 未改动（`git status --short` 无 config.json 行）→ 74.6「零新 config 键」声明属实。
5. **越界自检**：`git status --short` 中 .md 改动恰为上述 4 个预期文件；其余改动为 scripts/（任务既定范围）；未触碰其他 worktree。

## 问题清单

```text
[P1] skills/task-planner/references/critical-rules.md:942（Rule 71.7）— 「机器面=selftest-source-anchor-discipline.sh …/SKILL 登记行+计数 1-71/…」与事实不符：SA-07 实际已断言 '1-74'（scripts/selftest-source-anchor-discipline.sh:38，chk "…+ '1-74' 计数 ≥2"）。v162 同步了 SKILL 三处与脚本锚，但未级联 critical-rules.md 自身的描述字面（计数同步应为全量 A 类机械替换，cf. selftest-absorption-discipline.sh:55 AD-11「SKILL.md『1-71』字面残留=0」只查 $SKILL 未覆盖 $RULES）。建议修法：71.7 内「计数 1-71」→「计数 1-74（[2026-10-10 task-v162 合并演进] 全集锚 1-71→1-74）」。
[P1] skills/task-planner/references/critical-rules.md:875（Rule 67.6）— 「SKILL「Critical Rules 1-69」三处（v150 期 1-65 → … → v154 期 1-69，锚演进并集终态）」过时：SKILL.md 现行 1-74 且 CP-07 计数锚已扩为宽容族 1-(69|71|74)（scripts/selftest-context-pressure.sh:98-100）。根因部分 pre-existing：v158 Rule 71 落地时即未级联 67.6 描述，v162 再度加剧；按 v162 自身「字面锚同步」纪律应一并扫除。建议修法：句末补「；[2026-10-10 task-v162/v158 合并演进] 全集再演进 1-71→1-74，CP-07 锚族扩为 1-(69|71|74)」。
[P2] skills/task-planner/SKILL.md:111 — HTML 注释内历史记录「（master 1-69 不变）」为 task-v159 期事实陈述（带日期+task tag），属合法历史留痕而非现行声明；从严可按 Rule 45 补「当时」限定。不阻断。
[P2] skills/task-planner/SKILL.md:9 — frontmatter「Critical Rules 全集 1-74（67-71 均经并行任务合流落地）」：74 本身亦来自并行任务合流却未入括注；且 72/73 为空号无说明（编号由 scripts/rule-reserve.sh 账本管理）。建议括注补「67-71/74 」，并对 72/73 空号加一句预占说明，避免读者误判断号连续性。
[P2] skills/task-planner/templates/task_plan.md:140 — 变更标注表列名「增量或替代」与类型枚举「新增·修改·删除·更新」不对齐：「类型=删除」的行在判定列无落点（critical-rules.md 74.3(a) 同构同缺口）。建议列名改「吸收判定（增量·替代·删除）」并在 74.3(a) 同步（改列名需同步重跑 selftest-absorption-discipline.sh 锚）。
[P2] skills/task-planner/references/critical-rules.md:953（74.3(d)）— 「（Rule 8 A 类流程入口）」措辞歧义：易误读为一切新指令（含 A 类无影响）必建标注表，与 74.1 五场景及 B/C 定位存在张力。建议改为「（Rule 8 判定为 B/C 类后）」。
[P2] skills/task-planner/references/critical-rules.md:375（36.5）vs :955（74.1）— 36.5 新句「同位实现」与 74.1「特化（冲突时 36.5 更严）」措辞不完全同构（同位 vs 层级更严）；结论一致、无语义互斥。建议统一为「特化实现」单一措辞。
[P2] skills/task-planner/templates/task_plan.md:137 — 新段缺 Rule 45 What+Why 注释块；但既有段中「执行范围限制/必要知识储备/Verification Contract」等亦无紧随注释，属既有方差，非本次新增违约。
```

## 观察（非问题，登记备用）

- SKILL.md:360 Rule 74 bullet 插在 Rule 71 bullet 之后、Rule 69/70 之前（非升序）。经 `git show HEAD:skills/task-planner/SKILL.md` 验证：HEAD 版顺序即 67,68,71,69,70（v158 同样插在 69 前），v162 沿袭既有插入点惯例，非本次新引入的缺陷。

## 结论

- 7 接线面/4 .md 文件全部在位，引用锚零失效，守卫脚本已同步，格式与既有风格对齐，无越界改动。
- 命中 2 条 P1（均在 critical-rules.md 描述性文本：守卫计数字面未随 v162 级联；一处根因 pre-existing 自 v158）。均为一行 documentary 修复，不影响任何机器守护当前绿灯（SA-07/CP-07/AD-11 实际断言均已为 1-74 系）。
- **CHANGES_REQUESTED**：建议主进程在合并回主仓前对上述 2 条 P1 做一行级联替换（属 36.5/74.2 允许的纯增量文字修订，不动条文语义），P2 可随下一轮维护处理。

## 返回契约
- status: done
- acceptance: CHANGES_REQUESTED（P1×2+P2×6）；P1=critical-rules.md:942「计数 1-71」声明与 SA-07 实际 1-74 不符 + critical-rules.md:875「1-69 终态」过时；P2×6 见问题清单；通过项 5 类（条文一致性/SKILL 七接线/模板格式/守卫级联/越界自检）附 grep 证据
- checkpoint: 本文件
