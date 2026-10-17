# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 主动发现问题能力（诊断：当前技能核心偏记录/收集——运行数据、日志、记录）→ VC-2
- R2 主动发现偏差/偏移/错误+及时纠正 → VC-2, VC-5
- R3 内容错误及时审查、所有错误可审查、**内容审查能力最核心**（用户原话明示）→ VC-3, VC-4
- 范围界定=报告 §5/§5.1/§7 遗留（接线批次 P-02/03/06/08/09 + 语义层）+ v183 交付总结风险①③

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 审计报告提案+终审修订 | plans/verification-upgrade-2026-10-16/report.md §5/§5.1/§7 | 是 | Research Findings |
| v183 交付态+5 风险 | plans/task-v183-verif-closeout/delivery-summary.md | 是 | Research Findings |
| v183 收口实测（本会话 Phase 1） | plans/task-v184-proactive-error-review/progress.md + git log b83ad92..  | 是 | Research Findings（六轮拦截链） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **接线点权威清单**（report.md:316-324 落地方式列）：P-02→attest VC 门+check-complete VC-GATE；P-03→attest 锁定门（硬占位 enforce/软模糊 warn 分档）；P-06→check-3file-gate 第 6 条件+≥30 中文 Goal 语料校准；P-08→attest VC 链+check-complete VC-GATE；P-09→attest 档位复核+plan_tier 声明行格式规范化。
- **验收统一标准**（report.md:333 §5.1 修订 3）：每门验收=「注入缺陷计划→走真实 hook/终验链 exit 1」——只交付脚本+registry+selftest=「检测器发货即死」（P-05 自己诊断的失效模式）。
- **语义层缺口定位**（report.md:457 §7.3）：全部机器检查止于格式/计数/存在性/词法/路径归属层；P-01 只到路径归属（report.md:366 未收敛面披露）；内容级张冠李戴不在判定面——本任务 S6 CLAIM_MATCH 层收窄第一层（声明串↔证据文件内容核对），纯语义面走 S8 Rule 84.6 规则条款（独立内容审查子代理门）。
- **【Phase 1 实测·对本任务核心论证】v183「已交付」计划过终验门需六轮补账**：v183 会话已写 delivery-summary 声称交付，但本会话代行收口时 check-complete 连续拦出 6 处簿记缺口——①Rule 27.3 未提交→②Batch Report 六字段空→③Handoff 表零回填（委派门交叉校验）→④Phase 1 Executor 白名单关键词字面缺失→⑤Rule 66.3 [goal:Gn] 证据行 9 行全缺→⑥v168 R 锚定行 4 段全缺。逐项补齐（git b83ad92/88284d7/+2 笔）后 exit 0。**两面性**：机器门逐个拦出=检测力在位且有效（正面）；但 v183 会话自己从未跑终验门=「门不被自动调用」的又一实证——正是 Phase 2 接线要根治的失效模式（R1 的活证据）。
- **归档守卫拒绝（Rule 81.3 fail-closed 合规路径）**：archive-plan.sh 两次拒绝 v183——active-pointer（死会话 ff9004a side 指针残留，已用 set-active-plan --clear --sid 清除）→ live-owner（.session-owner mtime 01:46<24h）。处置=保持原位+拒绝理由登记（commit 88284d7 message + 本行）；重试窗口=2026-10-18 01:46 后或 --batch。
- **p05 判例细节**（findings v183 传承）：`tr -d '*#-'` 尾连字符=字面删除；`*-#` 为反向区间（`*`=0x2A>`#`=0x23）tr 报错→keyword 恒空→检测器死。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 全部门 warn 起步 | 双先例实证：P-01 词表初版误报 63/90 需 8 轮调优（report.md:365）；P-04 enforce 撞存量 73/145≈50%（report.md:378）。enforce 翻档凭 146 存量零误报基线逐门执行（§5.1 修订 2） |
| 84.6 子条而非新 Rule 编号 | 1-91→1-92 纪元锚级联会炸 ~23 脚本（execution-lane 记忆：每纪元必炸）；84.6 落管辖域 verification-gate（Rule 84 验证域延伸），语义归属正确 |
| CLAIM_MATCH 四形态起步（Total/exit=/PASS=/FAIL=） | 可判面最窄起步控误报；Phase 3 由 146 存量实测定收窄/扩面（Key Question 1） |
| 注入式验收统一入 selftest-gate-injection.sh | §5.1 修订 3 标准；避免每门自测夹具≠真实链的假阳性（v183 六轮拦截链=真实链检测力实证） |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| attest 三轮拒锁（S-unit 表缺/VC 伪行/Goal 表头列名） | 拆 Phase 3/4 各自 S-unit 表+Goal Gate 块去复选框伪行+表头「对应 S-unit」对齐 |
| set-active-plan --clear 连带清了全局指针 | side 指针（e9716e）完好即解析正确；重设全局指针恢复 |
| Edit 连发被「文件已修改」拦（heredoc 追加后状态过期） | 重新 Read 后再 Edit（工具契约） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 接线范式先例：skills/task-planner/scripts/check-complete.sh:431（DELEGATION shell-out 前置块+fail-open+档位键）
- 判定器范式：skills/task-planner/scripts/check-evidence-anchor.sh（PATH_TOKEN_RULES 词表+8 轮调优留痕头注）
- v183 收口提交链：git log b83ad92→88284d7→（Handoff/白名单/goal 行/R 锚定四笔补录）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
