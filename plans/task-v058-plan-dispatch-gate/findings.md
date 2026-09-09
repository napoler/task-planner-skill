# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（09-09）："在计划阶段就明确的表示，需要用子代理处理任务。这样的话应该会好一些，确保当前的技能已经完成了这些的修改。如果已经完成了，在计划阶段就完成要求规划子代理的使用之后，那么就推送部署到各个平台，然后提交修改到 GitHub"
- 解读：① 核实"计划期规划子代理"是否已落地（结构 + 机制）；② 未完成则补齐；③ 完成后部署 9 位 + push origin master

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1);子代理按 22.4a 自写小节 #### [sub:…] 追加于本段末尾 -->
### R1 现状核实（09-09，主进程只读 grep，白名单③）
- **已落地**：Rule 25.1（每 Phase `**Executor:**` 强制 + 派发型 Phase 缺 S-unit 表 = 计划无效）@critical-rules.md:166；Rule 22.6（S-unit 计划期必填）@:131；模板 task_plan.md 5 个 Phase 的 Executor 默认值 = explore/主进程②/code-assistant/code-runner/主进程①（子代理优先）@:143-199；plan-writer 契约/骨架/禁止行为/证据要求均含 Executor 与 S-unit @:40,107,153-154,185,188,229；check-delegation.sh 对 Executor 字段做占位检测与 Handoff 交叉校验（stats）
- **缺口 1（结构）**：S-unit 表头 `| ID | 目标 | 输入 | 验收 | 预估时长 | 状态 |`（模板 :174、plan-writer :155）**无执行体列**——无法在计划里逐步声明 subagent_type；v057 Phase 7 用 Code Reviewer 子代理但 Phase Executor 写主进程，统计按 Phase 归主进程
- **缺口 2（机制）**：`grep -l "S-unit\|Subtasks" scripts/*.sh *.cjs` = 空 → 无任何脚本校验 S-unit 表；attest-plan.sh（计划批准锁定）不做校验 → "计划期必填"是纯文本约束，与 v055-v057 反复证明的失效模式同类
- 接入点：attest-plan.sh 模式解析 :20（锁定为默认模式）；check-complete.sh 委派门控段 ~:396-425（`DELEGATION GATE PASSED` 之后接入）；解析 task_plan 须用状态机式（memory：awk 区间 bug）
-

#### [sub:01-executor] 22.6/25.1 执行体列落地
- critical-rules.md:131(22.6) S-unit 表定义已加「执行体」列(继承=Phase Executor,或逐行 explore(mini)/executor(sonnet-1));wc -l = 212 不变
- critical-rules.md:166(25.1) 行末追加:执行体列非空 + 计划批准时 `bash scripts/check-plan-dispatch.sh <task_plan.md>` 机械校验(缺表/缺列/执行体空 → 拒绝锁定 attest)
- 验收 5/5 PASS(grep 行号 131/166,wc 212,git diff 2+/2-,「Subtasks 转正」=1)

#### [sub:03-executor] plan-writer 执行体列落地
- plan-writer.md 4 处修改(:40 任务分解行/:107 S-unit 表列定义/:155-157 骨架表头+示范行/:208 证据要求行)S-unit 表加「执行体」列;验收 5/5 PASS(grep 执行体=5,示范行含占位符,check-plan-dispatch.sh=1,wc 261 不变,frontmatter 逐字未动)
- :79 八字段(Batch Report)未动;git diff 6+/6-

#### [sub:02-executor] 模板 S-unit 表 7 列落地
- task_plan.md 4 处修改(:130 Phases 头注加「执行体」列默认继承说明/:173 S-unit 注释加「执行体」列可写说明/:174 表头 6→7 列加「执行体(subagent_type(model))」/:176-177 S1/S2 示范行执行体填「继承」);验收 5/5 PASS(A1 表头含执行体,A2 示范行=2,A3 头注默认继承=1,A4 注释行末含具体 subagent_type,A5 wc=383 不变)
- A4 注:grep "S-unit 派发单元表(Rule 22.6"(无空格,无空格锚定 :173 注释行) 在 :130 头注内亦命中(=2),因 :130 新增说明引用同锚;严格「单行末尾」判定 PASS(:173 行末确含 `具体 subagent_type(model)`);git diff 5+/5-

#### [sub:04-executor] check-plan-dispatch.sh 落地
- 131 行（≤150），纯 bash while-read 状态机；接口 `bash check-plan-dispatch.sh <task_plan.md>`：exit 0 合规/fail-open（无参/不可读/legacy/无派发型 Phase），exit 1 违规（stdout 每行 `[plan-dispatch] ✗ Phase N: <原因>`）；legacy 判定 = 全文 grep 无「执行体」
- 执行体列取 `awk -F'|' '{print $4}'` 第 4 字段（列结构 空,ID,目标,执行体,输入,验收,预估,状态），trim 后空或 `-` 判「行 Sx 执行体为空」；Phase 头只认 `### Phase` 避免误配「## Current Phase」裸行；`**Executor:**` 匹配用未转义通配 `*'**Executor:**'*`（转义 `"\*\*…"` 在 bash 通配中不识别，自测第一轮暴露）
- 自测 5/5：bash -n PASS（131 行）；v058 dogfood exit 0 含 `✓ 4 个派发型 Phase`；v056 legacy exit 0 含 `legacy`；夹具 A（缺表）/B（S2 执行体列 `-`）/D（表头无「执行体」字样）exit 1 含 `✗` 且 B 指向 S2；夹具 C（主进程 Phase 无表 + 派发型合规表）exit 0

#### [sub:05-executor] attest/check-complete 接入落地
- attest-plan.sh：参数解析加 `--skip-dispatch-check`；attest 分支写 .plan-attestation 前调 check-plan-dispatch.sh，脚本缺失则静默跳过（fail-open），违规 exit 1 且 stderr 含 ✗；+9 行
- check-complete.sh：委派门控 PASSED/SKIPPED 之后、warn 计数之前插 4 行：check-plan-dispatch.sh 存在时调其校验 $PLAN_FILE，失败输出 `PLAN-DISPATCH GATE FAILED` 并 exit 1（位于最终 exit 前）
- 实测：违规夹具 attest 直接跑 exit 1（stderr ✗）/ `--skip-dispatch-check` WARN+锁定成功；v058 合规计划直接 attest exit 0 且 ✓ 4 派发型 Phase；check-complete 全 complete 合规夹具出 `PLAN-DISPATCH GATE PASSED`，违规夹具出 `PLAN-DISPATCH GATE FAILED` exit 1；legacy v056 全 complete 仍 exit 0 无新增失败

#### [sub:06-executor] selftest-plan-dispatch.sh 落地
- 111 行（≤120），6 用例 hermetic（$TMP+trap）：T01 合规✓/T02 缺表✗/T03 执行体为空/legacy/无文件 fail-open/attest 集成（T02 夹具 exit 1；--skip-dispatch-check WARN+.plan-attestation）
- 关键点：check-plan-dispatch.sh:30 legacy 判定为全文级 grep「执行体」，故 T02 缺表夹具须含一个合规 Phase 2 表（带执行体列）才不被误判 legacy 放行；运行 Total: 6 PASS=6 FAIL=0，exit 0
- 反验通过：临时把 T02 夹具改合规 → T02 FAIL（证明用例非恒真），已还原

#### [sub:07-executor] Phase 5 验证结果
1. selftest-plan-dispatch PASS — `Total: 6 PASS=6 FAIL=0`
2. selftest-delegation FAIL(未证实) — tail -1 记录行 = `========================================`（分隔线，非期望的 Total: 38 汇总行；禁重跑故无法确认）
3. selftest-dispatch PASS — `Total: 12 PASS=12 FAIL=0`
4. selftest-fallback PASS — `Total: 21  PASS=21  FAIL=0`
5. verify.sh PASS — 3 条 ✗ 全为 deploy drift（claude-code/zcode/opencode）+ `summary: 22 pass / 3 fail`（fail 数=✗ 行数 3，全 deploy drift）
6. bash -n PASS — 输出 `check-plan-dispatch selftest-plan-dispatch attest-plan check-complete`（4 个名字全出）
7. check-plan-dispatch PASS — `[plan-dispatch] ✓ 3 个派发型 Phase 均有带执行体的 S-unit 表` rc=0
8. worktree 干净 PASS — `git -C $W/../.. status --porcelain | wc -l` = `0`

#### [sub:08-code-reviewer] Code Review 结论
5/6 pass（判据 1-5 全 PASS；无代码 FAIL 项。T05/T06 非恒真已核实：T05 无夹具文件必走 fail-open，T06 夹具=T02 缺表必触发 exit 1）
- 判据1 状态机: PASS — check-plan-dispatch.sh:79-117 Phase 开闭/Executor/S 表识别对模板格式无误判；legacy=全文 grep「执行体」不误伤不漏放
- 判据2 fail-open: PASS — :24-27 不可读跳过 / :30 legacy 跳过 / attest 仅 [ -x ] 时调用(缺失静默跳过, attest-plan.sh:48)
- 判据3 attest 接入: PASS — 锁定前 :45-51 校验、违规 exit 1、--skip-dispatch-check WARN 逃生；show/verify/clear 模式未触碰
- 判据4 check-complete 接入: PASS — :429-431 位于委派门控后、exit $python_rc(446)前；脚本缺失 fail-open；exit 1 语义与 420-422 一致
- 判据5 selftest: PASS — 6 用例独立夹具、trap 清理无 /mnt|/home 硬编码、T06 真调 attest-plan.sh:8-9,99；selftest 运行 6 PASS，plans/ 与 /tmp 无残留
- 判据6 脚本卫生: PASS（含 2 处 nit 不阻断）— 两新脚本均 set -u、无 set -e、输出前缀统一 [plan-dispatch]/[attest]/[plan]；nit: selftest COUT/CERR 未 local（:79-102 全局）、check-plan-dispatch:112 逐行 fork awk（小 N 可接受）
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
