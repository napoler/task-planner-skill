# S7 Code Review Gate — checkpoint (status: done)

- 范围：worktree /home/terry/task-planner-skill-worktrees/task-v084-thinking-methodology，`git diff master..HEAD` = 5 文件 +115/-10（CHANGELOG.md / SKILL.md / companion/agents/plan-writer.md / references/methodology.md / scripts/selftest-methodology.sh）；只读审查，零文件修改（本检查点+findings 追加为委派指令要求）
- 审查手法：git diff 全文逐行 + 关键文件全文 Read + grep 复现每条发现 + 突变测试（改动副本跑真脚本）反向验证断言可失败性

## 逐维度结论
- correctness：PASS
  - 断言语法/口径无误：M-12..M-16 用 $FIX 绝对路径（脚本 :114 `cd "$TMP"` 后仍绝对），`grep -c` 无匹配时 `${TCNT:-0}` 兜底，`set -u` 无 `set -e` 下 rc 赋值行（:186/:193/:200/:207/:213）正确；fixture 增 `mkdir -p "$FIX/companion/agents"` + cp（:53-55）与 M-16 目标一致；实跑 rc=0 无报错
  - 突变实测：删整节 §思维方法论 → M-12/M-13 变红（断言有效）；删 SKILL bullet → M-15 红；删 plan-writer 契约行 → M-16 红
- consistency：ISSUE
  - (a) methodology.md:11 定位声明 3「全部失败惩罚引用 Rule 26.3 确定性惩罚表」+ :230 关系表「惩罚统一 | 全部失败惩罚引用 Rule 26.3…」与 :126 T3「**显式例外（不进 Rule 26.3 硬门）**」字面自相矛盾；全文 grep「例外」仅 :126 一处 —— task_plan.md:55 强制约束「写入 methodology 定位声明注记」+ findings.md:22「文档定位声明补一句例外注记优于假装硬门」均未落实
  - (b) selftest-methodology.sh:7/:76 注释仍「9 条方法名关键词」；findings.md:10 冻结联动清单「selftest-methodology.sh:7 注释「9 条」——共 6 处改「14 条」」、findings.md:100 表第 4 行、findings.md:131「L7 注释…→「14 条」（注释联动）」均声称已改 = 6 处机械联动 1 处未执行（M-14 只 grep methodology.md，无断言可捕获）
  - (c) MED：methodology.md:111 T2「连问为什么 ≥5 层（对齐 Rule 31.2 上限语义…）」vs methodology.md:85 R4「（现象 → 直接原因 → … → 根因，≤5 层）」与 critical-rules.md:257「5 Whys 逐层追问 ≤5 层」——同一方法出现下限/上限两口径，且「对齐上限语义」措辞牵强（用户原话「不少于五个为什么」= 下限）
  - 正向一致项：T1-T5 七字段结构与既有 R/Q 范式同构；§思维方法论章标题与 SKILL:81/:83/:299 三处指针字面匹配；T2 与 31.2 的「同法不同时」交叉引用成立（问题侧前置 vs 错误侧归因）；Rule 32.2 / 19.6 / 22.6 引用均在 critical-rules.md 实存
- pure-increment：PASS
  - 10 条删除行逐条核对，全部为「原句保留 + 追加/改数」的联动改写（SKILL:81/:297、methodology:3/:4/:5/:13/:229/:232/:233、selftest「11 用例→16 用例」），零语义删除、零既有条款改写、critical-rules.md 零触碰（diff --stat 仅 5 文件）
- test-quality：ISSUE
  - 突变实测：仅删 T3+T4+T5 三节（含 VC-1 点名的 Minto 出处与 T5 五个消费点）后，16 条断言无一条变红 —— M-12 的 `grep -c "问题先行\|问题解构四问\|金字塔原理\|逐步推导剖析\|消费点"`（selftest-methodology.sh:184）非条目/章节限定，T1+T2 文本即可凑满阈值；建议补个别锚（如 `^### T3 金字塔原理`=1 + `Minto` + `五个消费点`）
  - 可失败性另三项已实测成立（整节删除 / M-15 / M-16）
- changelog：PASS
  - CHANGELOG.md:11 条目与实际改动逐项对齐：5 文件、M-12..16（11→16）、plan-writer 契约行、§思维方法论五条、定位声明联动、零新 config 键、零新 Rule、不改 critical-rules 一行；「终态 545≤548」实测 wc -l=545 ✓

## 最终结论
REVIEW_VERDICT: CHANGES_REQUESTED
理由：无 Blocker（无安全/数据/功能破坏；16 条断言实跑全绿、纯增量成立、指针与 CHANGELOG 对齐）。但本任务交付物即文档本体，存在两处「冻结设计已写明却未落地 / 文档内部自相矛盾」的合规缺口：(a) 定位声明「全部引用 Rule 26.3」与 T3 显式例外矛盾（plan 强制约束 + 决策均要求补注记）；(b) selftest 头注释「9 条」漏改且 findings 已自报完成。两项修复各 ≤1 行。另附 test-quality 建议（补 T3/T4/T5 个别锚）与 5 Whys 层数口径澄清建议，均在 Phase 4「FAIL 修复 ≤3 轮」可闭环。

## 修复建议（精确到行，供 Phase 4 执行）
1. selftest-methodology.sh:7（及 :76 注释）「含 9 条方法名关键词」→ 按冻结清单改「14 条」，或写「含 ≥9 条方法名关键词（v063 九条锚点；v084 后全文 14 条，见 M-12..M-16）」以保 M-03 语义准确
2. methodology.md:11 定位声明 3 追加「（T3 风格类为显式例外，不进硬门，见 §思维方法论 T3）」；:230「惩罚统一」行同步一句
3. selftest-methodology.sh M-12 段增 T3/T4/T5 个别锚（`^### T3 金字塔原理`=1、`Minto`≥1、`五个消费点`≥1）
4. methodology.md:111 T2 ② 补一句下限澄清（用户指令「不少于五个为什么」= 下限；31.2/R4「≤5 层」为错误侧上限口径，两者不互斥）
