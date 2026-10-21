---
id: planflow-template-verification-contract
title: "模板与验证契约"
tags: [模板生命周期, 验证契约, VC门控, 断言级联, 交付契约]
sources:
  - plans/archive/task-v096-template-auto-record/knowledge-brief.md
  - plans/archive/task-v074-template-matrix-reflect-loop/knowledge-brief.md
  - plans/archive/task-v074-template-matrix-reflect-loop/findings.md
  - plans/archive/task-v160-decision-grading/findings.md
  - plans/archive/task-v166-summary-readability/findings.md
  - plans/archive/task-v081-fine-grain-step-gate/knowledge-brief.md
  - plans/archive/task-v156-drift-shield/findings.md
updated: 2026-10-22
---

# 模板与验证契约

## 结论（可直接复用）

1. **模板生命周期=Rule 34 六子条。** 34.1 选取门控（白名单=variant/ 目录动态派生 + general，禁第三份硬编码副本）/ 34.2 四点同步（template-mapping.md、plan-writer.md、SKILL.md 模板节、template-guide.md）/ 34.3 沉淀触发三条件 / 34.4 沉淀流程（≤100 行 variant + 四点登记 + selftest）/ 34.5 防滥用（先查重 + 泛化性评估；一次性/不可泛化 → 登记不沉淀理由收场而非硬生成）/ 34.6 机制 template_gate_enforce 三档默认 warn。【源：task-v074-template-matrix-reflect-loop / task-v096-template-auto-record】
2. **三点感知网 + 全自动生成合约（34.7）。** T1 = init-session.sh 机器提示（emit 提示行 token `[template-sense]` + 运行时追加「模板感知」区块）/ T2 = critical-rules 34.7 的 LLM 行为条款 / T3 = check-complete.sh 终验 warn 兜底；终验命中 34.3 且 COMPLETE → 主进程直接派执行体生成新 variant，不再询问用户；生成侧内置 34.5 查重 + 泛化性闸门。【源：task-v096-template-auto-record】
3. **单一权威源裁定：白名单一律动态派生。** init-session.sh 的 VALID_TYPES 与 check-template-type.sh 的白名单同源自 `templates/variant/` 目录派生（+general），禁止出现第三份硬编码副本；否则门控判定与 init 路由漂移。【源：task-v074-template-matrix-reflect-loop】
4. **计数级联必须双锚同改。** 新沉淀一个 variant 时，template-guide.md 的「N 个」计数行与 selftest-template-lifecycle.sh 的 TL-17 断言必须同时改（v093 教训：同源锚必须同改）；同理四点同步里 template-guide.md 曾被漏列，文档计数/变体数漂移即回归 FAIL。【源：task-v096-template-auto-record / task-v074-template-matrix-reflect-loop】
5. **VC 门控必须与现行计划格式对齐（真空命令判定）。** VC-GATE 解析器只认 `- [x] V-P.N:` 行，而 v065 以来全部计划改用 `- **V-N:** VC-x` 紧凑格式 → 映射数恒为 0、warn 恒触发（"映射 0 < 2"），门控对现行格式零效力=真实缺陷；修法=计数器兼容含 `VC-\d+` token 的紧凑行，映射目标校验复用 vc_defs 逻辑；另需修 progress.md 顶部 `<待沉淀>` 桩行被解析成「未回填」而真实 Error Log 节不在扫描面的脱节。【源：task-v074-template-matrix-reflect-loop】
6. **需求覆盖映射 = 双向。** 反向：需求 R → 必须有对应 VC（映射数 < 阈值即 warn）；正向：VC → 必须能追回需求行；映射目标校验源是 vc_defs，不是行号。【源：task-v074-template-matrix-reflect-loop】
7. **行数与计数断言级联（定数断言）。** SKILL.md 行数上限被多处 selftest 钉死（≤548 两处、≤540 等），净增须同批扩围两处断言，漏一处=全量回归 FAIL；同理 SKILL.md「Critical Rules 1-N」全集计数锚一旦改写（如 `1-69+70`→`1-72`、`1-71+73`），会击穿既有守护脚本的宽容锚邻接匹配，实测一次改动炸 5 个脚本（DC-11/P-05/R-09/RF-07/RR-09）——改 SKILL.md 前必须全仓 grep 消费方断言并随动扩围。【源：task-v081-fine-grain-step-gate / task-v156-drift-shield】
8. **上界解析要兼容两种规则标题形态。** P-05 用 grep 抽 SKILL.md 的 Rule 上界，须用 `^(## Rule|###) [0-9]+` 并集（旧 `### N` 与新 `## Rule N`），单形态会采样收窄导致上界失衡 FAIL。【源：task-v160-decision-grading】
9. **决策分级契约（A/B/C）。** A 级必须询问（推翻已确认计划要素/不可逆/对外）、B 级默认项+自动超时、C 级禁问自动消解+登记；基础性质检（物理常识错误）必须由执行体机检留证据，禁上抛代审；分级要与既有升级四门槛（G1-G4）对齐，段末补指针时不得写成 `NN.x` 新子条形态（会触发子条计数断言 FAIL）。【源：task-v160-decision-grading】
10. **交付总结五要素 + 列表格式。** 交付总结必须含执行任务总结/需审查数据总结/建议/风险/下一步；列表一律 `1. 2. 3.` 数字列表，禁 ①②③ 圆圈枚举混用，审查类内容必须实体化为表格（文件名/路径/简单描述）；但 Rule 70 ①-④ 属子条编号引用（合法引用），不受禁圈号约束——禁改条文子串。【源：task-v166-summary-readability】
11. **断言写法两条纪律。** ①用内容锚替代绝对编号锚（`^| C<N> | .*决策分级` 而非硬断言 `C49`），防编号让位造成 false-positive；②计数 helper 必须对不可读文件返回 `0` 而非空串（空串进 `[ "" -lt N ]` 会报整数告警并静默吞错）。【源：task-v160-decision-grading】
12. **基线口径纪律。** 子代理自报的 selftest 总数一律不采信，主进程逐脚本 `Total:` 行求和入账（实测子代理报 235/293 等均为算术误差）；registry 行数必须等于实存脚本数（机器不变量）；全量回归前须确认无并发 selftest 在跑，否则 /tmp 夹具碰撞产生假 FAIL。【源：task-v074-template-matrix-reflect-loop / task-v160-decision-grading】

## 证据锚

- Rule 34 六子条：plans/archive/task-v074-template-matrix-reflect-loop/findings.md:66；plans/archive/task-v096-template-auto-record/knowledge-brief.md:52
- 三时点感知网 + 34.7 自动合约：plans/archive/task-v096-template-auto-record/knowledge-brief.md:15,21,24-26
- 单一权威源裁定：plans/archive/task-v074-template-matrix-reflect-loop/findings.md:40,66
- 计数/四点同步级联：plans/archive/task-v096-template-auto-record/knowledge-brief.md:26,41,73；plans/archive/task-v074-template-matrix-reflect-loop/findings.md:109,118
- VC-GATE 格式失配与修法：plans/archive/task-v074-template-matrix-reflect-loop/findings.md:100,101,112
- 行数/计数断言级联：plans/archive/task-v081-fine-grain-step-gate/knowledge-brief.md:26；plans/archive/task-v156-drift-shield/findings.md:96-99
- P-05 上界并集形态：plans/archive/task-v160-decision-grading/findings.md:109,122
- Rule 72 A/B/C 与基础质检硬门：plans/archive/task-v160-decision-grading/findings.md:21,55,69-72
- 交付总结五要素 + 圈号规则：plans/archive/task-v166-summary-readability/findings.md:35-37,62-64,142
- 内容锚 / cnt 空串防护：plans/archive/task-v160-decision-grading/findings.md:129-130
- 基线口径与并发回归：plans/archive/task-v074-template-matrix-reflect-loop/findings.md:80,114；plans/archive/task-v160-decision-grading/findings.md:99

## 易错点

1. 白名单硬编码副本：init 用动态派生、门控脚本用硬编码（或反之）→ 双权威源漂移，门控与 init 判定不一致。【源：task-v074-template-matrix-reflect-loop】
2. 只改 SKILL.md 不级联消费方断言：改行数上限 / 规则全集计数 / 括号注数字，须全仓 grep 消费方 selftest 一并随动，否则全量回归 FAIL（历史已发生 6 例）。【源：task-v156-drift-shield / task-v160-decision-grading】
3. 计数「N 个」与对应 TL-17 断言不同步：新增 variant 后 template-guide.md 与 selftest-template-lifecycle.sh 必须同批改。【源：task-v096-template-auto-record】
4. VC 门控解析器只认旧行格式：对现行紧凑格式恒计 0，门控形同虚设且 warn 噪声持续；断言「映射数达标」前先确认解析器认得现行格式。【源：task-v074-template-matrix-reflect-loop】
5. 采信子代理自报的回归总数：必须主进程逐脚本 Total 行求和；另查 registry rows 是否等于实存脚本数。【源：task-v074-template-matrix-reflect-loop】
6. 并发跑批造成的假 FAIL：与滞留后台 agent 同跑 selftest 会撞 /tmp 夹具，全量回归前先确认无并发 selftest。【源：task-v074-template-matrix-reflect-loop】
7. 硬断言绝对编号（C49）：编号让位即 false-positive，一律改内容锚。【源：task-v160-decision-grading】
8. 段末补指针写成 `44.2.1` 形态：会新增子条锚并触发子条计数断言 FAIL——应写成不带子条编号的普通续行。【源：task-v160-decision-grading】

## 适用场景

- 新增/修改计划主模板或 variant 模板，判定是否触发沉淀与四点同步时。
- 给 check-complete.sh 增加新的门控段（REFLECT-GATE / judge-gate 等三档范式）时。
- 写或改 VC 验证条款、需求→VC 映射、selftest 断言组时。
- 改 SKILL.md（加规则 / 加行 / 改计数括注）并预估回归影响面时。
- 写交付总结模板、审查清单表格或决策呈报面时。
