# S4 executor checkpoint（2026-09-27）

## 状态
- status: done（全部 6 步完成；findings.md/progress.md 回填为最后落盘动作；仓内零修改，纯只读实测）

## 已完成里程碑
1. Read template-guide.md:40-90 三节全文，摘录 7 处数字声明（:22 主模板 5 / :32 variant 13 / :52 辅助 3 / :60 总数 21 / :62 统一含 21 / :66 应为 21 / :74 维持 20 + ":65" 行号锚）✅
2. 实测三数：`ls templates/*.md|wc -l`=10（5 核心+3 辅助+knowledge-brief+shared-tracker）；`ls variant/*.md|wc -l`=15（文档 13+mini-lite+video）；grep 锚=22（无锚 3 文件=knowledge-brief/shared-tracker/mini-lite-type）；目录实数 25 ✅
3. git 归因：variant 13→15 = d6a0f76（v086 mini-lite, 09-21）+51ca883（video 重建, 09-22；首建 v085 期曾丢失，提交信息自证「v085 对齐声称 15 但磁盘 14」）；guide 末改=db7e724（09-20）后未回写；「维持 20」双重过时=92f933c（rule-enhancement 带锚→应 21）+10ba3d1（P8 改 :66 应为 21 却漏改 :74，pickaxe 实证「维持 20 不变」仅 b21eaff 引入）+51ca883（→22）；「:65」锚 b21eaff 写入时正确（=「统一标题…应为 20」验收行），10ba3d1 插行后漂移至 :66 ✅
4. template-mapping.md 同型漂移（只登记不修）：:26「既有 13 类」+§六速查表 :132-144 缺 mini-lite/video 两行；:168 白名单 6 无漂移；:191 措辞「应包含」轻微 ✅
5. :69 归因定案：:69=§2.4 契约安全行，引用的状态机正则 `/^## ⚠️…/{f=1;next} /^## /{f=0}` 与两脚本现状均不符（check-conflicts 73730f7 已接 lib plan_parse_scope inscope 形态；check-drift:205 为区间式非状态机）→ v091 deferred「:69 文档锚过时」成立；defect-evidence 缺陷 4 自身锚「:69（§2.5 段）」亦不精确（被引文本在 :74）✅
6. findings.md 追加 `### S4 template-guide 计数与锚归因`（含声明清单表 + Phase 4 修正指令 6 条）；progress.md Phase 1 追加 1 行 ✅

## 关键结论（供 Phase 4）
- 终值三数（若 Phase 2/3 不新增模板）：grep 锚=22、口径内模板=23（5+3+15）、templates/ 实数=25
- 修正面 6 处：guide :32/:60/:62/:66/:67/:74（+ :69 脚本引用如实化）；「:65」→「§2.4「统一标题」条」章节锚形态
- template-mapping :26+§六表漂移留后续任务（本 scope 禁改）
- 修正后复跑三件套对账：ls ×2 + grep 锚

## 证据路径
- findings.md `### S4 template-guide 计数与锚归因`（声明清单表+归因+修正指令）
- git show b21eaff/10ba3d1/db7e724:skills/task-planner/references/template-guide.md（:65 历史形态三 snapshots）
- skills/task-planner/scripts/lib/plan-parse.sh:34 / check-drift.sh:205 / check-conflicts.sh:134（:69 失配实证）
