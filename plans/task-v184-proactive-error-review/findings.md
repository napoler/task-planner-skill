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

## Research Findings（续）
- **S1/P-02 接线完成（三投）**：attest-plan.sh VC 门段（:250-285 锁定期）+ check-complete.sh（resolve_vc_nonvacuous_tier/run_vc_nonvacuous :786-872 + VC-GATE 段尾调用）+ config `vc_nonvacuous_enforce=enforce`（47→48 键）+ 14 文件 16 处级联断言 48。**真实链拦截实证**：夹具 A（5 条 `Verify command: true`）check-complete rc=1 输出 `[vc-nonvacuous] ✗ VC-1 真空命令 ×5+VC-NONVACUOUS FAILED`；夹具 B（真实引用）rc=0；--only vc-gate/state-consistency/ask-default-timeout 全 PASS。checkpoint=subagent-state/S1-code-assistant.md（M1-M4）。
- **S8/Rule 84.7 内容审查门落地**：critical-rules-verification.md:45-53（84.7.1 触发面/84.7.2 独立性/84.7.3 审查输入与维度/84.7.4 结论落盘/84.7.5 与机器层分工+Why 用户原话）+ SKILL.md:60 消费行 + VG-13 静态锚（selftest 13/13 PASS）。**编号撞车判例**：84.6 已被 task-v173 占用（「84.6 机制·零新 config 键」+VG-02 ≥6 下界断言）→ 改 84.7（下界断言天然兼容 7 子条）。已知瑕疵=VG-02 文案仍写「84.1-84.6 六子条」（断言逻辑不受影响，S7 顺手修）。
- **执行体通道判例（重要）**：①Code Assistant 两投停摆（读后 narrate 即止，零落盘，1.23M/142K token 烧尽型）②委派守卫只拦主进程 Write/Edit（探针实证子代理双通道畅通）③第三投 general-purpose 收逐字编辑块任务书=84 工具调用全链完成且自愈一次 Edit 超时双插（dedup+grep 复核）。**结论=大编辑块任务书+general-purpose 是本仓 wiring 类任务可靠通道**；P-10 的「Bash+python 绕行」判例不需要（子代理 Write 本就畅通）。

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

## Research Findings（Phase 2 续）
- **S2/P-08+五键批**：rvc 双点接线（夹具 A `[rvc-coverage] ✗ R1/R2/R3 无 VC 覆盖` rc=1）；config 一次 +5 键（rvc/step_placeholder/tier_consistency=enforce，goal_cjk/claim_match=warn）级联 48→53 一轮 16 处——后续单元零级联（[align] 排程优化）。
- **S2b 八红清零**：3 个 RVC 交互回归（requirement-coverage/evidence-anchor/final-gate-hash 的旧夹具被新门先拦）以**单元隔离 env off** 修（各 selftest 测自身门）；4 个 stale-47 非引号形态断言升 53（S1 引号形态级联漏网教训=级联 grep 必须多形态）；summary-readability 元检为下游自愈。全量 90/90 绿。
- **S3+S4**：attest P-03 块（step-placeholder，plan-dir 契约）+P-09 块（tier-consistency，插 template-tier 解析段尾）；占位夹具「优化一下性能」rc=1、档位漂移夹具 rc=1/干净 rc=0。零 config 零级联。
- **S5/P-06**：148 项语料（143 archive+活计划+5 抽样）**0 误报**→数据驱动翻 enforce（goal_cjk_enforce warn→enforce）；3file-gate 第 6 条件接线（drift 门 6→7 重编号，全仓无外部引用）；门分支矩阵四态实证（enforce/warn/off/fail-open）。
- **登记债**：①门结果缓存 cksum 未纳新 5 env（warn→enforce 方向可能回放陈旧 PASS——S7 顺手补）②check-goal-cjk is_cjk E5 分支缺口（U+5F64-5FFF 含心得德律等常用字未判 CJK=潜伏保护缺口，一行修法已备查，需判定器授权面→独立任务）③S8 报的 VG-02 文案「84.1-84.6 六子条」措辞漂移（S7 顺手修）。

## 审查结论（Phase 4）
- **CR Gate**：Code Reviewer 裁决 **APPROVED**（0 P1/P2；P3×5 建议留档：GI-05/07 attest 侧 grep 锚可被注释残留骗过/PASS= 空格不归一/attest 三接线块同构重复可抽函数）——检查点 subagent-state/cr-gate.md
- **独立回归**：code-runner 执行体复现 **Total=91 PASS=91 FAIL=0**（run=91）+registry rows=91=actual——检查点 subagent-state/final-regression.md
- **独立复验**：Verifier VC-1..4 全 PASS+84.7 对齐四点 PASS+注入抽验 rc=1——检查点 subagent-state/final-verify.md；披露 D-1（task_plan VC-4 命令列反斜杠形态 84\.6 残留，已修）/D-2（cksum env+E5 缺口两登记债维持独立面）/D-3（knowledge-brief 占位→本批蒸馏回填）
