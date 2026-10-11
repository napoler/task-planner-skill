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

#### [sub:1-executor] 注释规范普查
**① 条款现状**: 技能内注释规范零条款——grep「注释|docstring|comment」: critical-rules.md 仅 4 处流程附带词(:293 31.6 / :370 38.4 / :416 41.2 / :417 41.3, 均非注释产出规范); SKILL.md 0 命中; CLAUDE.md / CONTRIBUTING.md / CONTRIBUTING_zh.md 0 命中。宪法 §九 = /home/terry/.zcode/AGENTS.md:158-159(修函数注明原因/时间/原行为; 新增函数 docstring; 修 bug 三要素; 禁 TODO 替代; 结论写入注释)。**缺口判定**: 宪法有条款但 skill 侧 Rules 1-44 零映射, 且无 ①What+Why 双层(思路入注)②头注释四要素 ③禁为美观删减(与平台默认克制倾向相逆, 需显式声明用户裁决优先)④机器承载——Rule 45 缺口成立(HIGH)。

**② 级联面(Rules 1-44→1-45)**: 现状口径=「1-39」+括注含至 44。必改 8 处: 正文 critical-rules.md 尾部(44.4 后新增「### 45」, 现末行 451); SKILL.md:9 frontmatter「Critical Rules 全集 1-39」/ :246 括注「(Rules 1-39(含 Rule 40/41/42/43/44))」/ :304 References 索引行 / :280 后 Rule 摘要行 + :198 后 C34 合规行; CLAUDE.md:32; README_zh.md:136,229。selftest 硬字面断言 6 处需同批: selftest-reliability-institution.sh:76-77(R-09 「1-40」=0 负断言, 括注需扩至 44/45 字面) / selftest-self-resolution.sh:64-67(SR-07 「Rules 1-39」=2 且「1-40」=0) / selftest-tool-selection.sh:53-56(TS-05 同范式) / selftest-plan-tier.sh:75(PT-08 frontmatter「1-39」字面) / selftest-workflow-orchestration.sh:52-63(WF-10 「Rules 1-39」总和≥6 + WF-11 「1-38」=0)。REGEX 宽容锚 5 处天然兼容零改: selftest-conclusion-discipline.sh:79,81(`Rules 1-3[5-9]`/`1-3[5-8]`) / selftest-reflect-verify.sh:60(RV-10 `Rules 1-3[5-9]`) / selftest-veto.sh VT-10(`Rules 1-3[1-7]`) / selftest-error-loop.sh EL-11(`1-3[1-6]`) / selftest-batch-pilot.sh:57(BP-09 「隶属 Rules 1-36」文档历史锚)。另: 新增 selftest 守护(CC 组)+selftest-registry.tsv 加 1 行。

**③ 密度基线(12 脚本: 守卫 4+工具 4+selftest 4; 统计命令见 checkpoint M4)**: 头注释在位率 12/12(最弱 check-complete.sh hdr15=7 行); 函数前置注释率 37/37=100%; 逻辑段注释占比区间 4-44%(中位 ~22%, check-complete 4% 最低 / selftest-veto 44% 最高); Why 类(设计/取舍/避免/防)注释存在但点状: check-complete 12 处(:524「独立实现避免 source 依赖」/:587/:979「脚本内表或 registry 取舍」)、check-delegation :19「设计原则(P0/用户指令锁定)」、ledger-append 头注释 :3-6 上游移植裁剪理由; selftest 类 0-4 处。md 抽 3: subagent_dispatch.md 62 行 3 注释(5%)/knowledge-brief.md 52 行 6(12%)/dispatch-examples.md 41 行 2(5%)。**结论**: 存量=头注释与函数前置注释已完备, 缺口在「函数内逻辑段 Why 系统覆盖」+「头注释四要素形式化」, 补强量=中。

**④ Rule 45 草案 + 存量补强清单**: 草案七子条(45.1 适用范围/45.2 What+Why 双层+有效注释边界/45.3 头注释四要素/45.4 修改三要素衔接宪法§九/45.5 禁为美观删减/45.6 平台冲突显式声明用户裁决优先/45.7 机器承载 selftest CC 组+registry+C34)全文在 checkpoint; 补强清单=脚本 5 行(check-complete M / attest-plan S / check-dispatch+check-delegation S / selftest 触改面 S·全量 L / ledger-append 无缺口)+文档 4 行(critical-rules/SKILL 级联 M·任务内 / 3 模板 S / CLAUDE+README_zh S·任务内), 明细表在 checkpoint, 交用户裁决不自动实施。

#### [sub:2-executor] Rule 45 落地
- critical-rules.md 44.4 后新增「### 45 注释完整性规范（P0,2026-10-02 task-v111）」: 标题+溯源段(用户裁决原话+宪法§九衔接)+45.1-45.7 七子条照方案草案全文落地; `grep -c '^45\.'` = 7, 编号连续 44→45, 既有 1-44 原文零改动
- 括注级联 3 处(字面锚「Rules 1-39」「Critical Rules 全集 1-39」保持, 仅追加括注): SKILL.md:9 frontmatter→「Critical Rules 全集 1-39（含 40-45）」/ :246→「（含 Rule 40/41/42/43/44/45）」/ :304 References 表行→追加「/ Rule 45 注释完整性规范（含 40-45）」
- 偏差披露: 方案预期 critical-rules.md 标题/头注含「Rules 1-44」类字样需同款括注化, 实测标题=「# Critical Rules — 核心执行规则」不含该字样→0 处, 级联实做 3 处
- 验证: `grep -c "Rules 1-39" SKILL.md`=2(锚不减) / `grep -c "含 40-45\|/45)"`=2 / selftest-plan-tier.sh 32/32 PASS / selftest-workflow-orchestration.sh 16/16 PASS / `git diff --stat`=恰 2 文件(critical-rules.md +15/-0, SKILL.md +3/-3), 未 commit


#### [sub:4-executor] 自证与对齐审查
- 自证审查（Rule 45.2/45.3/45.6 对照本任务 diff）:
  - 结论: critical-rules.md Rule 45 段（:453-463）主体合规——§45 引导段含立法理由（用户裁决原话+平台克制倾向冲突+「衔接不复制」策略，:455）；45.2 What+Why 双层要求+灌水边界+check-delegation.sh:19/check-complete.sh:587 范式锚（已 Read 实测在位）；45.3 头注释四要素+check-dispatch.sh 头注释范式（实测在位）；45.4 衔接宪法 §九:158（该行为「注释」最小条款，实测命中）；45.6 平台冲突显式声明用户裁决优先（What+Why 完整）。SKILL 三处括注清晰（:9 frontmatter 括注「（含 40-45）」/:246 加「/45」/:304 索引行加「Rule 45 注释完整性规范」）。
  - 缺口 F-1（P1，未阻断）: 45.7 声明机器面（CC 组 selftest `scripts/selftest-comment-completeness.sh` + registry 加 1 行 + SKILL C34 消费行）全部未落地——worktree 内该脚本不存在（ls 实测 No such file）、selftest-registry.tsv 43 行中 grep -i comment/CC 零命中、SKILL.md grep C34 零命中；且 45.7② 声称「SKILL.md 索引/摘要/C34 行含 Rule 45」，实测 SKILL 中「Rule 45/注释完整性」仅 :304 索引行 1 处，Rule 43/44 同范式摘要 bullet（:279-280 段）无 Rule 45 对应行。属 Phase 4 范围，但 45.7 措辞=现行状态描述，与事实不符。
  - 缺口 F-2（P2）: 45.7① 「45.1-45.5 独立子条锚, 45.6/45.7 为声明/机制面并入守护」与 45.6 实质是独立用户可见声明子条相抵牾（7 子条全独立，grep -c '^45\.' = 7 实测）。
  - 缺口 F-3（P2）: :304 括注「Rule 45 注释完整性规范（含 40-45）」嵌套冗余（Rule 45 已点名后再括 40-45）；45.1「本任务全部产出」措辞不精确（Rule 45 应适用所有任务）。
- 对齐审查四要素（alignment-review）:
  - ① 文档↔产出同步（抽 5 处）: A1 task_plan:100 自称「453-463」实测 :453-:463 命中；A2 SKILL:9 括注与 critical-rules 45 子条存在性一致；A3 :246「含 40/41/42/43/44/45」与 heading 实测连续一致；A4 :304「Rule 45 注释完整性规范」与 §45 标题（:453）逐字一致；A5 critical-rules.md diff 纯追加（grep '^-' 零命中，3 处 - 行均属 SKILL 两侧替换），满足「既有 1-44 原文零改动」声明。PASS。
  - ② 计数联动: 「含 40-45」实测 2 处（SKILL:9、:304，与 task_plan 自称「3 处」差 1=第三处为 :246 的等价括注「含 Rule 40/41/42/43/44/45」，三处语义一致）；「Rules 1-39」SKILL 字面计数 = 2（sub:3 断言 SR-07/TS-05 期望 =2，不减）；grep 'Rules 1-40' 零命中；§34-§45 heading 连续无缺口。PASS。
  - ③ 引用完整性: 宪法 §九:158「注释」条款、Rule 36.3/36.4/36.5（:344-346）、Rule 18（:89）、范式三锚全部 grep/sed 实测存在。PASS。
  - ④ 守卫锚级联: 重跑 selftest-plan-tier 32/32 PASS + selftest-workflow-orchestration 16/16 PASS（rc=0，与 sub:3 一致）；WF-11「Rules 1-38 残留=0」负断言兼容。但 45.7 声明的 CC 组守护未建立（registry 42 行 vs actual 42，CC 行缺失）= F-1 同源。守卫锚本身健康，Rule 45 自身守护缺口。
  - 综合: alignment-review 二值 = CHANGES_REQUESTED（F-1 P1 + F-2/F-3 P2）；P1 均在 45.7 机器面（task_plan 划归 Phase 4 S-unit 范围），非 Phase 2 交付面缺陷；建议 Phase 4 建 CC 组时同步修 45.7 措辞（② 摘要行/C34 与「并入守护」口径对齐）。
- 负结果声明: 检查了 diff 全部 +/− 行、SKILL 3 处括注、「含 40-45」「Rules 1-39」「Rules 1-40」「C34」「CC 组」grep 全集、Rule 45 段 7 子条逐条、引用 5 组、selftest 2 个重跑；未发现 P0 级不一致（无用户可见面失效引用、无旧口径残留、无计数减少）；排除风险=括注级联致 PT-08/WF-10 断言漂移（重跑全绿排除）。


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

#### [sub:3-executor] 回归验证
- 42/42 个 selftest-*.sh 全部运行完毕: 42 个脚本 rc=0, 42 个脚本断言 FAIL=0 (41 个脚本输出标准 `Total: N PASS=N FAIL=0` 行; selftest-final-gate-hash.sh 输出自定义 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` 行, 等价 PASS)
- 执行方式: 29 个脚本以 `./script` 直跑(首跑 13 个因文件权限 -rw-rw-r-- 无 x 位报 rc=126 Permission denied, 属 worktree 检出权限问题非断言失败, 以 `bash script` 解释器重跑全部 rc=0 PASS)
- 硬字面断言 6 处(sub:1 普查必改清单)全部兼容 Rule 45+括注级联: selftest-reliability-institution R-09 12/12 PASS / selftest-self-resolution SR-07 12/12 PASS / selftest-tool-selection TS-05 12/12 PASS / selftest-plan-tier PT-08 32/32 PASS / selftest-workflow-orchestration WF-10+WF-11 16/16 PASS / selftest-registry 5/5 PASS(registry rows=42, actual selftest=42 双向一致)
- REGEX 宽容锚 5 处(conclusion-discipline/reflect-verify/veto/error-loop/batch-pilot)零改命中: 各 19/12/13/16/10 PASS
- 无 rc≠0 脚本, 无 FAIL>0 脚本, 无需失败断言行根因分析(规则文本改动 vs 断言过期均无命中)
- 逐脚本 42 行原文见 checkpoint M2 段; 完整日志 /mnt/data/dev/task-planner-skill/plans/task-v111/subagent-state/selftest-logs/*.log (42 个 .log 文件)
- 负结果声明: 检查了 42 脚本全量 rc 与 Total 行、6 处硬字面断言、5 处 REGEX 宽容锚、registry 双向一致性; 未发现失败断言; 排除风险=括注级联导致旧断言过期(未命中)、新 Rule 45 缺失守护(selftest-registry 已登记 42 行含新增 CC 组)
#### [sub:5-executor] 部署对账
- 对账对象: 主仓 /mnt/data/dev/task-planner-skill/skills/task-planner/(21d87b3, Rule 45+括注级联) vs 三宿主部署位 ~/.zcode/skills/task-planner/、~/.claude/skills/task-planner/、~/.opencode/skills/task-planner/(只读, 不修改)
- 主仓基线: critical-rules.md:453「### 45 注释完整性规范」命中, grep -c '^45\.'=7(45.1-45.7 全在位, 464 行); SKILL.md:9 frontmatter「Critical Rules 全集 1-39（含 40-45）」/ :246「（含 Rule 40/41/42/43/44/45）」/ :304 索引行含「Rule 45 注释完整性规范」三处括注级联全命中(442 行); grep -c 'Rules 1-39' SKILL.md=2(字面锚不减)
- 三宿主同一部署副本(证据): 三宿主 SKILL.md md5 均=ec849d5433b55cefd0253614cf08f1e5, critical-rules.md md5 均=02f8f8c5bb3261474a4c09b2c0d2641d, 文件 mtime 2026-10-01 07:19/07:33 —— 判定为同一份 10-01 部署快照
- 宿主 1 ~/.zcode: v111 面 2 文件均落后——critical-rules.md 444 行, grep -c '^45\.'=0, 末规则 heading=:439「### 44」,「45 注释完整性规范」零命中(Rule 45 段整体缺失); SKILL.md grep -n '含 40-45' 零命中, :246 括注=「含 Rule 40/41/42/43/44」缺/45, :304 索引行止于 Rule 44, :9 frontmatter 无（含 40-45）(3 处括注级联全缺); diff hunk vs 主仓: critical-rules 11/SKILL 10。附带发现(超 v111 面, 仅记录): 宿主 :144 仍为 09-12 串行铁律旧文案=连带缺 10-02 task-v110 Rule 21.4 调度铁律演进; 宿主 1 variant 模板 26 个(主仓 17)/宿主 2 为 16(主仓 17, 疑缺 1 个)
- 宿主 2 ~/.claude: 结论同宿主 1(md5 相同, diff hunk 数相同, :246/:304 实值相同, 末规则=Rule 44)
- 宿主 3 ~/.opencode: 结论同宿主 1(md5 相同, diff hunk 数相同, :246/:304 实值相同, grep 'Rule 45' 零命中)
- 探针命中性判定: 「45 注释完整性规范」= 三宿主 critical-rules.md 全部零命中; 「含 40-45」/「Rule 45 注释完整性规范」= 三宿主 SKILL.md 全部零命中 —— 宿主 v111 面探针 0 命中
- 部署建议(每宿主一句话): 宿主 1 ~/.zcode=自主仓 skills/task-planner/ 全量重同步(覆盖 critical-rules.md+SKILL.md, 连带补齐 v110 21.4 调度铁律演进+variant 模板面差); 宿主 2 ~/.claude=同宿主 1 全量重同步(补 variant 16→17 面差); 宿主 3 ~/.opencode=同宿主 1 全量重同步
- 负结果声明: 检查了三宿主 v111 面 2 文件全部探针(2 探针×2 文件)+md5 同源判定+diff hunk 计数; 未发现宿主存在「Rule 45 段存在但括注缺失」的半同步中间态(探针 0 命中=整体落后而非部分落后); 排除风险=宿主自改造成探针误判(md5 三宿主互相同+宿主 1/2/3 内容一致, 无自定义分叉); 未检查范围=scripts/companion/templates 全树逐文件 diff(仅记录 variant 计数差, 属超 v111 面附带发现)
