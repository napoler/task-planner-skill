# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法 -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->

用户 R1-R5 五条原话见 task_plan.md「🎯 用户需求原文」区（Rule 51.1 逐字抄录）。逐条问题定性：

- **R1 幻觉/长程漂移**（[目标]）：执行期无任何机器面把「用户最初指令/不变量/Goal」重新呈现给主进程。病灶链：smart 注入仅在用户发言轮 + Goal 只取首行 + R 条目/不变量段不在任何注入字段集（zcode-userpromptsubmit.sh:113,151）；PostToolUse 执行期零回注（zcode-posttooluse.sh:245-366）。
- **R2 确定性+偏移拦截**（[目标]）：drift 提醒全软提醒（Rule 64.3 自述 :821「拦截力由 64.2 承载」），唯一硬门在 Phase complete 时刻（check-3file-gate.sh:269-282）；触发时机（Rule 15.1 五时机）无机器计数。
- **R3 周期检查计划文件**（[目标]）：Rule 65 周期回顾无任何触发载体——4 个 zcode hook 零调用 periodic-review.sh；`periodic_review_interval_calls`/`periodic_review_enforce` 唯一读者=selftest 断键存在（selftest-periodic-review.sh:76-86）；Rule 67 自证「未接 hook」（critical-rules.md:878）。
- **R4 执行错误及时纠正**（[目标]）：Rule 31.1 四触发条件全为用户侧信号（critical-rules.md:322）；执行期机器可观察错误（工具 exit≠0/测试 FAIL/hook 拦截）零条款零 hook 感知（zcode-posttooluse.sh:1-370 与 zcode-pretooluse.sh:1-158 grep is_error/exit_code 零命中）。
- **R5 三方技能主动激活**（[目标]）：Rule 59.3（critical-rules.md:782）只规定「计划期扫描入 knowledge-brief §6」，纯 LLM 行为面无脚本、无 ledger 事件、无门控；179 个技能中 175 个 model-invocable 但实战从未激活（用户原话实证）。红线：3 个 disable-model-invocation:true 技能（comet-any/comet-memory/comet-review）禁自动代激活。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 仓内调研报告 01（漂移/回顾/纠错机制全景） | plans/task-v168-session-anchor-skill-activation/subagent-state/01-explore-drift-mechanisms.md | ☑ | Research Findings §1-§3、缺口定级 |
| 仓内调研报告 02（技能激活面盘点） | subagent-state/02-explore-skill-activation.md | ☑ | Research Findings §4、缺口定级 |
| 仓内调研报告 03（执行错误面盘点） | subagent-state/03-explore-error-correction.md | ☑ | Research Findings §5、缺口定级 |
| critical-rules.md Rule 15/20/31/33/59/64/65/67/75 原文 | skills/task-planner/references/critical-rules.md | ☑ | Research Findings 各节（行号锚） |
| 四个 zcode hook 脚本 + check-complete/check-3file-gate/ledger-append/config.json | skills/task-planner/scripts/ + skills/task-planner/config.json | ☑ | Research Findings §1-§5 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### §1 周期性回顾（Rule 65）现状（Report 01 §1）
- 间隔 N=8 次工具调用（Rule 65.1，critical-rules.md:837），但**无任何 hook 调用 periodic-review.sh**；引用点仅 SKILL.md:223,362 + selftest。
- periodic-review.sh 行为（:61-161）：只读启发式对照——findings↔progress 关键词前 20 字符+否定词匹配判 CONCLUSION-CONTRADICTION/ASSUMPTION-CONTRADICTION；Goal 前 5 关键词在 progress 出现 0 次 → GOAL-DRIFT；输出单行 JSON（:169-185），exit 0/1/2。**无消费方、无语义理解**。
- 65.4 矛盾后强制动作（标 [corrected]→回错误步重执行→报告用户）纯 LLM 行为面，无格式锚机检。
- 65.6 档位 periodic_review_enforce 默认 warn——无 hook 消费 exit 1，enforce 空转。

### §2 偏移检查（drift）机制（Report 01 §2）
- 主载体 drift-checker 子代理（Rule 61，:743-752）：haiku-1、三锚判定（Rule 64.4）、三态裁决 ALIGNED/DRIFT/BLOCKED。
- 留痕三件套（Rule 64.1，:817）：检查点 + ledger drift_check 事件 + Drift Log 行；缺一=未执行。
- 唯一硬门 = check-3file-gate.sh 第 6 条件（:251-282）：Phase complete 窗口必须有 drift 痕迹。
- PostToolUse 每 N=10 次工具调用注入软提醒（zcode-posttooluse.sh:334-366）：[drift-rhythm]/[context-pressure]/[judge] 三条均 additionalContext 无拦截力。
- 历史执行率实证：task-v141~v145 共 25 Phase drift-check 执行率 0%（critical-rules.md:815）。
- 降级链（61.5）：drift-checker 失败→检查点→重试 1 次→check-drift.sh（只读降级佐证）+登记债务。

### §3 错误纠正机制（Report 01 §3 + Report 03 §1-§4）
- Rule 31.1 四触发条件全部用户侧（:322）；31.2 4 维归因；31.4 Prevention 翻占位；31.6 error_loop_enforce 默认 warn + selftest-error-loop.sh。
- Rule 33.1 触发=「问题解决动作完成后」（:344），**不覆盖"问题出现时"**；REFLECT-GATE 仅 required 计划+默认 warn（check-complete.sh:1213-1258）。
- Learning Gate（check-complete.sh:1103-1211）：终验校验 Error Log Root Cause 非 `<待沉淀>`；默认 warn=仅 stderr。
- hook 层零错误信号感知：zcode-posttooluse.sh 与 zcode-pretooluse.sh 对 is_error/exit_code/tool_result/stderr grep 零命中；PreToolUse 拦截只走 stderr+exit 2 不落盘不计数（zcode-pretooluse.sh:20-23,:42-54）。
- Rule 6/7/22.3/57：记账/三击/五档兜底/测试落盘均纯 LLM 行为面，触发点不含工具报错。

### §4 技能主动激活面（Report 02 全文）
- 技能库：~/.zcode/skills 130 + ~/.agents/skills 49 = 179 目录；disable-model-invocation:true 仅 3 个（comet-any/comet-memory/comet-review，各自 SKILL.md:4）；user-invocable:false 1 个（sub-agents:5）；model-invocable=175。spike 技能不存在。
- superpowers 族 13 副本全无 disable 声明 → 理论可自动激活但从未激活（R5 实证）→ 病灶=无扫描机制非 frontmatter。
- Rule 59.3（:782）：计划期扫描→knowledge-brief §6 四列；红线=user-trigger 型禁自动代激活。⚠ 措辞把「comet 族」整体归 user-trigger，与 frontmatter 事实（3/13）不符——本任务按「逐个 frontmatter 判定」精确化，不动红线语义本身。
- check-dispatch.sh 伴飞路径校验（:566-599）fail-closed 但无 disable 判定。
- ledger VALID_EVENTS（ledger-append.sh:30）无 skill_activation；selftest SG-15 仅锁 brief §6 段锚存在不校验内容（selftest-subagent-granularity-skill-escort.sh:164）。
- zcode cli config.json skills 键仅 atomcode/agentcore 禁用两条（:160-165），无激活白名单。

### §5 长会话幻觉治本面（Report 01 §4）
- 周期性重注用户原话的唯一渠道 = Rule 20 smart 注入，三重收窄：① 仅用户发言轮 ② Goal 只取 `## Goal` 节首个非空行（zcode-userpromptsubmit.sh:113，多行截断）③ 字段集不含 R 条目/不变量声明区（Rule 73.3，critical-rules.md:989）/否决禁令段/deprecated。
- attest 防篡改 ≠ 防丢失（SHA 不符只注入 [PLAN TAMPERED] 拒注入，hook :64-82）。
- PostToolUse 全链路无任何 Goal/用户原话载荷（zcode-posttooluse.sh:245-366）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 三波次落 Rule 77/78/79（编号已 rule-reserve，账本 77/78/79 reserved to task-v168） | 用户五条需求天然分三组机器面病灶：R1/R3=回注与周期接地（77）、R5=技能激活（78）、R4=错误即时纠正（79）；一组一波避免单波过大 |
| 全部档位走 env 降档（TASK_PLANNER_*_ENFORCE），零新 config 键 | 沿 Rule 64.6/67.6/59.7 先例；config.json 键数有 selftest 钉值（selftest-iteration-persistence.sh:194 config 键数 42），加键必级联 |
| 锚点卡由 scripts/plan-anchor.sh 生成（不做 awk 内联） | smart 注入现有 awk 字段提取在 zcode-userpromptsubmit.sh:84-162，扩展字段集=改 awk；多行字段+表格提取用独立脚本更可测（selftest 可直接跑），且 hook 只读缓存 O(1) |
| 技能扫描脚本 scripts/scan-skills.sh 读两目录 SKILL.md frontmatter | 59.3 无机器面是 R5 直接根因；frontmatter description+disable-model-invocation 是唯一可机读匹配源；扫描结果落 knowledge-brief §6（既有出口）,不新建落点 |
| error_correction 门档不新增 config 键，仅 env | 同零新键决策；Report 03 建议 3 的 config 键方案被本次裁决改为 env-only |
| Rule 59.3「comet 族」措辞按 frontmatter 事实精确化（逐个判定） | Report 02 §6 P1-7：3/13 vs 整族归类矛盾；精确化不改红线语义（disable 技能仍禁自动激活） |
| 不改 zcode-pretooluse.sh exit 2 阻断语义、不改 Learning/REFLECT-GATE、不改 Rule 31.1/33.1 既有触发语义 | 全部纯增量（Rule 74.2 增量默认）；Report 03§7 禁止越界清单 + Rule 74.3 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 会话中断后计划目录误落主仓未跟踪区而 worktree 空置（中断前调研产出在主仓 plans/task-v168/） | `mv` 计划目录入 worktree（主仓未跟踪无冲突），主仓 git status 恢复既有 transient churn 状态 |
| rule-reserve.sh 从 plans/ 子目录内运行 exit 5（账本解析只认「祖先含 plans/ 子目录」） | 从 worktree 根运行成功；reserve 第 4 参须 --note 否则 usage exit 2 |
| Report 03 建议新增 error_correction config 键 | 裁决 env-only（零新键），登记 Technical Decisions |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 部署位 skills 真源：/home/terry/.zcode/skills/task-planner/（hook 注册指向此；终验对账）
- hook 注册：/home/terry/.zcode/cli/config.json（SessionStart/PreToolUse/PostToolUse/UserPromptSubmit 四事件）
- Rule 编号账本：plans/.rule-reservations.jsonl（77/78/79 已 reserved by task-v168）

## Visual/Browser Findings
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位 -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据；全部证据为仓内代码/grep 锚点）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

---

## §7 S4 调研追加发现（2026-10-11，S4 子代理实证）

- **periodic-review.sh:89 `tr -d '*-#'` range 反向 bug**：在 C/C.utf8/en_US.utf8/zh_CN.utf8 全 locale 下报 range 反向错，导致该行恒失败 → exit 1（矛盾信号）**恒不可达**，Rule 65 的 CONCLUSION-CONTRADICTION/ASSUMPTION-CONTRADICTION/GOAL-DRIFT 三类矛盾检测实为死代码。S4 因只读约束未修，改用 fixture 桩覆盖三态。**本任务 S5 后须修复此 bug**（一行 tr 范围修正），否则 [periodic-ground] 注入的矛盾告警永不可能触发。
- 修复方案：`tr -d '*-#'` → `tr -d '*#-'` 或 `tr -d '[:punct:]'`（以实测 locale 行为为准），修复后须验证 exit 1 可达。

---

## §8 终验阶段事实（2026-10-11，CR+合并+回归后回填）

- **CR 独立审查结论**（subagent-state/21-cr-code-review.md）：CHANGES-REQUESTED（1 BLOCKER+2 MAJOR+1 MINOR+2 NIT）→ F1-F5 修复轮全闭环（22-cr-fixes.md）。关键实证：Learning Gate 存在**既有 off-by-one**（`cell=a[c+1]` 读 Prevention 列而消息称 Root Cause），被 enforce 翻档升级为硬阻断级后必修——已改双列校验 a[c]+a[c+1] 并豁免模板占位行。
- **v166×v168 合流面**（并行会话在本任务执行期落地 master）：唯一交互=SKILL.md 行数钉触顶（555→556）→ G-09/T-主 两断言按先例演进 555→581/558→584（该断言自带 v112→v155 十余次上调史，实值+25 边距口径）。v166 的 Rule 76/C55 成果与五锚点并存无损（diff 实证）。
- **最终组合态回归**：master 77 脚本（v166 新增 selftest-summary-readability 后总数）`Total: 77 PASS=77 FAIL=0`。
- **编号账本状态**：77/78/79 保持 task-v168 landed 态（内容随机器面封存于 wt/task-v168-machine-parked）——占位是为防 revival 合流时与他任务撞号；release 仅接受 reserved 态故未释放，记为已知簿记项。
- **部署未做**：§六 保护区需用户授权；仓库态改动（merge cdf437e/618df79/9fce0ff）待授权后 rm+cp 对账。
