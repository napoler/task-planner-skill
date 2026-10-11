# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:1-executor] 交付面普查（Phase 1 S1，2026-10-02）

现状（证据指针，全文结论落 checkpoint `plans/task-v112/subagent-state/1-executor.md`）：
- SKILL.md:147-160 终验交付段 8 步流程（VC 复验/委派统计/3-File/质量门控/内容质量/Read 产出/合并回/结论+check-complete），L157 交付结论三态与 L158 退出前 check-complete 之间**无用户面交付总结格式约束**——交付消息=自由格式，五要素无结构承载（旁证：SKILL.md:74 silent 交付报告须附静默决策清单但无区块）。
- verification.md（模板 129 行）=机器面档案：VC/Phase Gates/委派统计 25.4/质量门控 26/Goal Gate（L112 PARTIAL「列出+建议后续」）/5Q Reboot（Q2 承载遗留，如 v109:126「部署同步待用户裁决」）；用户面总结缺位，与 task_plan Decisions（L175 划界）一致。
- check-complete.sh 输出=机器信号行（L453 DELEGATION/L761 VC-GATE/L850 LEARNING/L895 REFLECT/L1038 compliance），可作模板第 3 区块指针源，脚本本身不动。
- 五要素覆盖度（v107/v108/v109 三任务对照）：任务说明=Goal 总是有/执行摘要常缺；产出清单=progress.md「Files created/modified」数据齐备但三列表（路径+变更摘要+验证状态）常缺；审查信息=机器面总是有/用户面常缺透传；风险点=常缺（仅 v107 report §4/§5 有遗留+待裁决；失效条件先例 memory-hygiene-type.md:162；回滚方式零提及，仅 merge hash 散在 VC 证据）；下一步建议=常缺（5Q Q2 一行遗留提示有，无排序/无推荐标注）。

模板草案（全文在 checkpoint M2）：templates/delivery-summary.md 五区块=任务说明（Goal+执行摘要+silent 裁决清单）/产出清单（文件级三列表）/审查信息（VC/回归/对齐/委派 JSON/质量门控/验证独立性，全指针）/风险点（已知遗留+待裁决+失效条件+回滚方式四子项，必须列举）/下一步建议（Rule 41.5 打包+44.1 推荐排序）；头部 HTML 注释指引（根模板惯例）；详略标准=用户可独立决策。
位置决策：templates/ 根目录（与 batch_report/knowledge-brief/shared-tracker 同列，零白名单影响）；否决 variant/（check-template-type.sh:17 白名单=general+variant/*-type.md 派生，入 variant 会造成「delivery-summary」成为合法 template_type 的语义错误或破坏 *-type.md 命名契约）。

级联清单（全文在 checkpoint M3）：① SKILL.md:157 与 :158 之间插入指针行 1 行（442→443 行，T2b 上限 558 余量充足）；② References 表 :314 行后加 1 行；③ plan-template-kit/template-guide.md:64 口径句句尾追加「/delivery-summary.md」1 处；④ selftest 最小方案=并入 selftest-template-lifecycle.sh 3 条静态断言（模板 5 区块/SKILL 引用 ≥2/口径句在位），不新增脚本=42 脚本数与 660 基线漂移面最小（SUM 断言 +3 若 660 有字面锚则 Phase 2 实测更新）；⑤ check-complete.sh/init-session.sh/check-template-type.sh 零改动。

#### [sub:2-executor] 模板落地（Phase 2 S1，2026-10-02）
- 新建 `skills/task-planner/templates/delivery-summary.md`（46 行，WT）：严格照 1-executor M2 草案五区块（任务说明/产出清单/审查信息/风险点/下一步建议）落地，每区块含填写指引+数据来源指针（verification.md/progress.md/subagent-state/、report.md 如有）；头部 HTML 注释说明区=定位（终验交付阶段用户面输出模板，主进程交付时消费，非 init-session 计划模板，无 template_type 头）+使用方式+详略标准（用户可独立决策）。
- SKILL.md 级联 2 处：终验段 L158 插入「交付总结（五要素）」指针行（交付结论行 L157 后、退出前 check-complete 行前，实测 442→444 行）；References 表 L316 追加模板行（shared-tracker 行后）。
- 口径句 1 处：plan-template-kit/references/template-guide.md:64 句尾追加「/delivery-summary.md（交付总结模板）」（同 knowledge-brief 先例「不入此口径」句式），25/17/3 辅助计数全部未动=零漂移。
- selftest=并入 selftest-template-lifecycle.sh 新 TL-19/20/21 三条静态 grep 断言（模板五区块=5 / SKILL delivery-summary ≥2 / 口径句在位），不新增脚本，42 脚本数不变。
- 660 基线漂移核查：`grep -rn "SUM-ASSERTIONS\|=660\| 660\|660/0" skills/task-planner/scripts/` 零命中 → 仓库内无 660 字面锚，SUM 断言无需更新（与 1-executor M3.4 预测一致；660 属任务基线记录不入仓库）。
- 回归实测：selftest-template-lifecycle.sh `Total: 21 PASS=21 FAIL=0` rc=0（既有 TL-01~18 全 PASS 零破坏+新增 TL-19/20/21 PASS）；selftest-knowledge-brief.sh `Total: 16 PASS=16 FAIL=0` rc=0。
- git diff --stat 文件集=方案级联清单 4 文件（template-guide.md 1 行改 / SKILL.md +2 / selftest-template-lifecycle.sh +12 / 新建 delivery-summary.md）；未 git add/commit，worktree 外零写入（本段+progress 行=计划三文件白名单）。

#### [sub:3-executor] 回归验证（Phase 3 S1，2026-10-02）

全量 42/42 脚本运行完毕（worktree `skills/task-planner/scripts/`，单脚本 timeout 90s 包裹，无超时触发；逐脚本日志 `/tmp/v112-selftest-logs/<name>.out|.rc`）。结果=41/42 rc=0，1 个失败：

42 行逐项原文（脚本名 | rc | Total/结果行原文）：
1. active-plan | rc=0 | `Total: 19 PASS=19 FAIL=0`
2. ask-default-timeout | rc=0 | `Total: 9 PASS=9 FAIL=0`
3. batch-pilot | rc=0 | `Total: 10 PASS=10 FAIL=0`
4. check-conflicts | rc=0 | `Total: 7 PASS=7 FAIL=0`
5. check-drift | rc=0 | `Total: 6 PASS=6 FAIL=0`
6. conclusion-discipline | rc=0 | `Total: 24 PASS=24 FAIL=0`
7. context-hygiene | rc=0 | `Total: 12 PASS=12 FAIL=0`
8. delegation | rc=0 | `Total: 38    PASS=38  FAIL=0`
9. dispatch | rc=0 | `Total: 31 PASS=31 FAIL=0`
10. error-loop | rc=0 | `Total: 16 PASS=16 FAIL=0`
11. execution-stability | rc=0 | `Total: 19  PASS=19  FAIL=0`
12. fallback | rc=0 | `Total: 31  PASS=31  FAIL=0`
13. final-gate-hash | rc=0 | `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`
14. fine-grain-steps | rc=0 | `Total: 11 PASS=11 FAIL=0`
15. interaction | rc=0 | `Total: 11 PASS=11 FAIL=0`
16. iterative-optimizer | rc=0 | `Total: 8 PASS=8 FAIL=0`
17. knowledge-brief | rc=0 | `Total: 16  PASS=16  FAIL=0`
18. mechanism-profile | rc=0 | `Total: 19 PASS=19 FAIL=0`
19. methodology | rc=0 | `Total: 16 PASS=16 FAIL=0`
20. plan-dispatch | rc=0 | `Total: 12 PASS=12 FAIL=0`
21. plan-tier | rc=0 | `Total: 32 PASS=32 FAIL=0`
22. reflect-verify | rc=0 | `Total: 12 PASS=12 FAIL=0`
23. registry | rc=0 | `Total: 5 PASS=5 FAIL=0 (registry rows=42, actual selftest=42)`
24. reliability-institution | rc=0 | `Total: 12 PASS=12 FAIL=0`
25. rescue-chain | rc=0 | `Total: 11 PASS=11 FAIL=0`
26. review-library | rc=0 | `Total: 15 PASS=15 FAIL=0`
27. rule23-conflict-scan | rc=0 | `Total: 3 PASS=3 FAIL=0`
28. self-resolution | rc=0 | `Total: 12 PASS=12 FAIL=0`
29. shared-tracker | rc=0 | `Total: 11 PASS=11 FAIL=0`
30. skill-collab | rc=0 | `Total: 25  PASS=25  FAIL=0`
31. skill-modify | rc=0 | `Total: 9 PASS=9 FAIL=0 (SKIP=0)`
32. skill-split | rc=1 | `Total: 41  PASS=40  FAIL=1`
33. smart-merge | rc=0 | `Total: 17 PASS=17 FAIL=0`
34. sync-index | rc=0 | `Total: 13 PASS=13 FAIL=0`
35. task-boundary | rc=0 | `Total: 11 PASS=11 FAIL=0`
36. template-lifecycle | rc=0 | `Total: 21 PASS=21 FAIL=0`
37. template-sense | rc=0 | `Total: 8 PASS=8 FAIL=0`
38. tier-b | rc=0 | `Total: 18 PASS=18 FAIL=0`
39. tool-selection | rc=0 | `Total: 12 PASS=12 FAIL=0`
40. vc-gate | rc=0 | `Total: 11 PASS=11 FAIL=0`
41. veto | rc=0 | `Total: 13 PASS=13 FAIL=0`
42. workflow-orchestration | rc=0 | `Total: 16 PASS=16 FAIL=0`

失败分析（唯一 1 项）：
- 失败断言行原文：`[FAIL] T-主 行数 ≤442（task-v103 C33/Rule44 摘要 440→442）且 ≤558 上限`（selftest-skill-split.sh:41）
- 根因：Phase 2 commit dec6196 向 SKILL.md 追加 +2 行（L158 交付总结指针行 + L316 References 表行），`git show` 实测 SKILL.md 行数 dec6196^=442 → dec6196=444（当前 worktree `wc -l`=444）。selftest-skill-split.sh:41 的 442 定数（task-v103 C33 级联 440→442 产物）未随 Phase 2 级联更新 → 444>442 断言失败。SKILL.md 仍远低于 558 硬上限，非红线破坏，属断言定数漏更新。
- 修复建议（供后续轮，本子代理零写入未动手）：selftest-skill-split.sh:41 上限 442→444，同步 T-主 文案括注；重跑 skill-split 全绿。
- TL-19/20/21（本次交付面断言）全部 PASS：template-lifecycle `Total: 21 PASS=21 FAIL=0` 内含 TL-19/20/21（selftest-template-lifecycle.sh:90-96 静态 grep 实测）。
- 负结果报告：已逐检 42 脚本 rc+Total 行+全部 `grep FAIL` 输出——除 skill-split 外 FAIL=0，无其他异常；排除风险=42 脚本数与 registry.tsv 一致性由 registry 脚本自证（rows=42, actual=42）。

#### [sub:4-executor] 自证与对齐（Phase 3 S2，2026-10-02）

**自证样例（VC-3）**：按 templates/delivery-summary.md 五区块撰写 task-v112 真实交付总结样例，落 `plans/task-v112/delivery-summary-sample.md`（五区块齐备：任务说明含 Goal 回顾+silent D1 裁决清单+PARTIAL 判定 / 产出清单 5 文件三列表+验证状态 / 审查信息含 42 行回归结果口径+对齐 APPROVED 四要素+委派 3/4=0.75 口径 / 风险点四子项逐条含失效判据+回滚路径 / 下一步 4 项推荐排序）。质量标准=用户不查其他文件即可独立决策（产出物在哪/哪些可信/风险/行动项四问可答）。

**对齐审查（alignment-review 四要素，verdict=APPROVED，P0=0/P1=0/P2=2）**：
1. diff↔意图 5 处对应（worktree `git diff master --stat -- skills/`=5 文件）：① delivery-summary.md +46（意图=模板新增，diff `46 +++++++` 全文新增）② SKILL.md +2（diff `:158` 终验段指针行+`:316` References 行原文逐字在位）③ template-guide.md :64 ±1（diff 原文仅句尾追加「/delivery-summary.md（交付总结模板）」，25/17/3 计数零动）④ selftest-template-lifecycle.sh +12/-1（diff 原文=TL-19/20/21 三断言+注释计数 18→21，断言语义与 1-executor M3 方案逐条一致）⑤ selftest-skill-split.sh :41 ±1（a3730c9 定数级联 442→444，意图=修 sub:3 抓出的唯一 FAIL）。越界自检：scope_files 外零触碰（plans/task-v112/* 白名单簿记除外，属预期）。
2. 口径联动：「不入此口径」句 template-guide.md:64 在位（sub:4 grep 原文）；TL-21 断言 `grep -q 'delivery-summary.md' TGUIDE` PASS；「25 个模板」计数引用面=README:35/74+template-guide:64/66 共 4 处全部未动=零漂移；TL-20 计数锚 `grep -c delivery-summary SKILL.md` = 2（:158/:316）健康。
3. 引用完整性：SKILL:158 引用的 `templates/delivery-summary.md` 实存（46 行，grep 五区块=5）；SKILL:316 References 行路径同实存；口径句引用 knowledge-brief/shared-tracker 均在位；样例引用的 subagent-state/1..4 全部实存。零失效引用。
4. 守卫锚级联重跑佐证（sub:4 独立重跑，worktree HEAD=a3730c9）：selftest-template-lifecycle `Total: 21 PASS=21 FAIL=0` rc=0 / selftest-knowledge-brief `Total: 16 PASS=16 FAIL=0` rc=0 / selftest-skill-split `Total: 41 PASS=41 FAIL=0` rc=0（修复前 FAIL=1）→ 既有锚（TL-01~18、T2b 558 上限、registry rows=42）零破坏，定数级联后 42 脚本面全绿于当前 HEAD。

**发现分级**：P2-1=verification.md 仍为 stub+委派统计/Todo 同步表未填（Phase 4 簿记面回填，非缺陷，不阻断）；P2-2=skill-split T-主 定数演进链 440→442→444 两连发（先例 SR-11/12 同型），建议后续 SKILL 加行时同步级联定数（已写入样例 §4 失效条件②，不阻断）。P0/P1=0。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
