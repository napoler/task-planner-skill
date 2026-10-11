# S7-re 复审检查点 — task-v148 防偏移加强（fix-phase 后复审）
# worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce (branch wt/task-v148-drift-enforce, 基点 master e54973d)

verdict: CHANGES_REQUESTED
复审对象: worktree `git diff master` 全量（8 改 1 新：CHANGELOG/SKILL/drift-checker.md/critical-rules.md/check-3file-gate.sh/ledger-append.sh/selftest-registry.tsv/zcode-posttooluse.sh + 新文件 selftest-drift-enforcement.sh）
只读复审；除本检查点零写入；无 git 写操作。
实测: 4 脚本 bash -n 全 OK；selftest-drift-enforcement 18/18；selftest-drift-check-subagent 20/20；selftest-four-file-dataflow 18/18；selftest-registry 5/5（rows=61=actual）。config.json drift 键 grep=0（零新键）。

## 上轮 F1-F7 消解对照表

| 项 | 上轮问题 | 修复落点 | 判定 | 证据 |
|----|---------|---------|------|------|
| F1 | gate 缺 plan_tier:mini 豁免出口 | check-3file-gate.sh:262-268 插入 elif（exempt 之后、env 之前） | ✅ RESOLVED | 判定序 = ledger→checkpoint→exempt→mini→env；probe1b 真 ledger 痕迹+mini 同存→命中 ledger 分支（无 mini 文案）；probe2 无痕迹+mini→exit 0；probe6 exempt+mini→命中 exempt；probe3 off→exit0；probe4 warn→exit0(stderr)；probe5 默认→exit1。plan_tier grep 与 38.4 既有 check-plan-dispatch.sh:69 同口径 |
| F2 | 缺 off 档/mimi 档断言 | selftest DCE-17(off)/DCE-18(mini) | ✅ RESOLVED | :48-55 两断言；实跑 Total 18 PASS=18（DCE-17/18 均 PASS） |
| F3 | fixture Started 硬编码墙钟 | selftest :35 改 `date -d '-1 hour'` | ✅ RESOLVED | 实跑 18/18 通过；Started=运行前一小时，消除墙钟耦合（DCE-16 内 hook fixture 仍硬编码 2026-10-08 12:00，但 hook 不读 Started，无害，见 OBS-1） |
| F4 | DCE-16 固定 SID /tmp 碰撞 | selftest DCE16_SID="dce16$$" + 隔离目录 | ✅ RESOLVED | :56-59 SID=PID 唯一化；实跑 PASS |
| F5 | drift 计数被提前 return 吞 | hook 函数+调用前移至 :44 后（plan 解析后、任何早退前） | ⚠️ PARTIAL（功能达标但引入新缺陷 F9/F10） | probe(P1/P4): 陈旧计划命中优先级1 + rhythm count 9→10 时两者均自增；rhythm state 1→2。计数自增语义已达成，但见下 F9/F10 |
| F6 | ledger docblock 枚举陈旧 | ledger-append.sh:9 行尾补 `| drift_check` | ✅ RESOLVED | grep :9 = "... kb_distill | drift_check"；:29 VALID_EVENTS 含 drift_check |
| F7 | drift-checker.md 追加行破列表 | drift-checker.md:35 前置空行 + `- ` 前缀 | ✅ RESOLVED | grep :36（文件实际行）="- 判定输入三锚（Rule 64.4）：..."；前缀+空行齐备 |

结论：F1/F2/F3/F4/F6/F7 已正确消解；F5 目标语义（计数不再被早退吞）达成，但其"前移到所有早退之前"的实现方式引入 2 项新缺陷（F9 Blocker / F10 Suggestion）。

## 新发现（F5 移动的副作用）

### F9 [BLOCKER] F5 前移后 hook 可能输出两行 JSON → 违反 hook 严格 JSON 约定
- 位置: skills/task-planner/scripts/zcode-posttooluse.sh:86（rhythm emit）与 :282（优先级4 emit）同轮并存
- 原文: :86 `emit "[drift-rhythm] 距上次偏移检查已 ≥${n} 次工具调用：..."` + :282 `emit "[plan-sync] 🔄 已 ${count} 次工具调用未同步：..."`
- 证据（实测复现）: 默认节奏下 drift N=10 与主 todo_n=10 完全同频——同一会话第 10 次工具调用时 rhythm 与优先级4 同时命中，hook stdout 为 **2 行 JSON**：
  `{"additionalContext": "[drift-rhythm]..."}` 换行 `{"additionalContext": "[plan-sync]..."}`
  12 次循环实测：call 10 → json_lines=2；其余 0。master（F5 前）同 fixture 10 次 → call 10 仅 json_lines=1（从无 2 行）。master 版优先级4 独占出口，rhythm 量在 :94 前移后新增了一条独立 emit 通道。
- 原因: 原设计每轮只允许一个 emit 后即 exit 0（单一 JSON 行）；F5 把 rhythm emit 提到早退链之前，"rhythm emit + 后续优先级 emit" 成为新组合 → 单轮多行 JSON。① 该 hook 头部自述约束（:13-14）"ZCode 对 hook stdout 做严格 JSON 校验"、:55-56 fail-open 注释亦称"杂输出会污染所有会话的 hook 链"；② 实测 node JSON.parse / python json.load 对该两行输出均 PARSE FAIL（"Unexpected non-whitespace character after JSON"/"Extra data"），即非严格合法单值 JSON。后果：平台按 documented strict schema 判输出非法 → 该轮 hook 整体 fail（提醒效果丢弃，含既有 plan-sync），或平台逐行容错 → 同一轮重复注入两条 additionalContext。任一结果均为非预期行为变更（回归）。
- 修复: rhythm 注入改为**合并进既有 additionalContext 单通道**（如把提醒文本累积到变量，由末尾唯一的 emit 输出；或 rhythm 命中时不早退、把文本与后续优先级文本用同一 emit 拼接），确保 hook 每轮 stdout 至多一行 JSON。次选：rhythm 命中后的优先级分支检测"本轮已 emit"则跳过自身 emit。改后须补一条断言：单轮 stdout 行数 ≤1。
- 置信度: HIGH（多行 JSON 实测；master 对照单行；hook 自述约束明文）

### F10 [SUGGESTION] F5 前移使 rhythm 注册在"24h/已完结计划静默"守卫之前
- 位置: zcode-posttooluse.sh:94（rhythm 调用）早于 :147 `[ "$age" -gt 86400 ] && exit 0` 与 :150 `outcome: COMPLETE|BLOCKED` 静默守卫
- 原文: :94 `drift_rhythm_check "$(dirname "$plan")" "$SID"` 前置于 :150 `grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan"`
- 证据（实测）: 计划 task_plan.md 含 `outcome: COMPLETE` + rhythm state count=9 → 调用后仍注入 `[drift-rhythm]`，且 rhythm state 被推进到 count 10/last_inject 10。而 master 版该计划在 :150 处静默、零输出。
- 原因: 原设计对 ">24h 历史任务 / 已完结计划" 一律静默（防误报，:5-6 职责注释明文）；F5 前移使 rhythm 绕过这两道守卫，对已交付计划仍可能每 10 次调用提示"派发 drift-checker"——语义陈旧 + 噪声。相比 master 属行为新增（该场景下 master 静默）。
- 修复: 将 drift_rhythm_check 调用移到 :152 与 :155 两道完结/历史静默守卫之后（:155 之后、:157 读阈值之前），既保留"优先级 1-4 命中仍自增"的 F5 意图，又不突破完结/历史静默；或在 drift_rhythm_check 内加前置：plan 含 outcome COMPLETE/BLOCKED 或 age>24h 则 return 0。
- 置信度: HIGH

### OBS-1 [观察/无动作] DCE-16 fixture 仍硬编码 Started（hook 不读，无害）
- 位置: selftest-drift-enforcement.sh:60 `printf '## Phase 2: test\n- **Started:** 2026-10-08 12:00\n'`
- 说明: F3 只改了 gate 用 fixture（:35）；DCE-16 的 hook 用 fixture 仍硬编码 Started。因 zcode-posttooluse.sh 全程不读 Started（rhythm 判定仅依赖计数），无害。仅记录，不阻断。

## 安全/负结果（本轮已查）
- F1 判定序语义: mini 出口置于 exempt 之后 → 既有 drift_exempt 语义优先、env 三档仅在全部未命中后生效；三档（off/warn/enforce）与既有豁免档语义零冲突（probe3/4/5 实测）。NEGATIVE（无回归）。
- F1 误拦面: mini 出口为放宽（新增放行），不会新增误拦；对非 mini 计划 grep 不命中，条件 6 语义零改动。NEGATIVE。
- F5 计数自增: 优先级 1-4 命中 exit 0 时 rhythm 计数确已前移自增（probe P1: 1；P4: 2），F5 原始诉求达成。NEGATIVE（诉求面）。
- 注入面: rhythm 注入为固定字面量、仅插值数字 n；state 内容只入算术不入 additionalContext；无注入。NEGATIVE。
- 零新 config 键: config.json grep drift_enforce/drift_rhythm/drift_exempt = 0（DCE-09 通过）。NEGATIVE。
- 回归: DCS 20/20、四文件 18/18、registry 5/5，均无回归。NEGATIVE。
- 引用原文 Grep 复现: 本检查点所有引用行号/原文均已 grep -n 复现（ledger :9/:29、gate :265、hook 调用点 :94、drift-checker :36）。VERIFIED。

## 判定
- F1/F2/F3/F4/F6/F7 消解 ✅；F5 目标语义达成但其实现引入 F9（BLOCKER：hook 单轮双行 JSON，破坏既有严格 JSON 约定，且默认节奏下第 10 次调用必现）+ F10（SUGGESTION：rhythm 越过完结/历史静默守卫）。
- F9 属"修复引入的新缺陷"，须修后方可 APPROVED：将 rhythm 提醒并入既有单 emit 通道，保证每轮至多一行 JSON；F10 建议一并修（rhythm 调用后移至静默守卫之后）。
verdict: CHANGES_REQUESTED
