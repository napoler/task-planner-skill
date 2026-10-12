# task-planner 性能诊断与优化报告

> **日期**：2026-10-13  
> **范围**：task-planner 技能体系流程性能审计 + 重量级脚本 wall-clock 实测 + 制度性强制开销审计  
> **状态**：诊断完成，优化方案已实施于 worktree `wt/perf-opt-20261012`（commit `a0c5a03`），待合并回 master

---

## 1. TL;DR

### 用户痛点

用户反馈：**"一个最简单的问题需要执行十几小时……严重违背了正常的运行机制"**（2026-10-13）。

这是同一投诉的第二次复发——2026-10-02 用户曾投诉"好几个小时解决一个最简单的问题"，催生了 Rule 38.7 L0 轻量通道。11 天后烈度升级，因为 **L0 通道的设计边界恰好不覆盖代码修复**。

### 核心结论

| 维度 | 结论 |
|------|------|
| **根因性质** | 制度性放大（流程结构排除最常见简单场景），非钩子延迟 |
| **决定性根因** | L0 轻量通道禁滥用条款将代码文件改动一律排除 → "看下 bug 第 10 行"永远拿不到 L0 → 被迫走 L1 全流程 |
| **直接耗时** | 双轮全量 selftest fresh=204.4s/轮（缓存后 1.26s），attest-plan 9.29s/任务——均已被缓存机制大幅缓解 |
| **优化效果** | 12 项优化已实施，全量回归 77/77 PASS=0 FAIL，trivial 代码修复档（≤3 行 ∧ 单文件 ∧ 代码文件）可走 L0 薄验证通道 |
| **待办** | worktree `wt/perf-opt-20261012` 需合并回 master 并清理 |

---

## 2. 执行链路全景

以"帮我看下 X 文件第 10 行的 bug"为例，完整执行链路如下：

```
用户提问
  │
  ├─ SessionStart hook（每次会话启动）
  │   ├─ task-plan-init.cjs 写入 .plan-required 哨兵
  │   ├─ 注入触发条件块（"用户未说简单"即命中）
  │   └─ 注入 3 个未完成任务 resume 列表
  │
  ├─ UserPromptSubmit hook（每次用户提问）
  │   ├─ 活跃计划存在 → 注入 plan-data 复诵块（Goal/Phase/Decisions/progress）
  │   ├─ 每 10 条 prompt 注入 [plan-note] D/A/B/C 影响判定
  │   └─ attest-plan.sh --verify（SHA-256 校验）+ check-conflicts.sh
  │
  ├─ 用户尝试 Edit 修复 bug
  │   └─ PreToolUse hook 拦截：
  │       ├─ check-scope.sh：哨兵存在 → exit 1 → zcode-pretooluse.sh exit 2 阻断
  │       └─ 文案："请先调用 Skill(skill='task-planner') 创建计划"
  │
  ├─ 建计划（init-session.sh，889 行）
  │   ├─ 落 7 文件（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief/user-session-log）
  │   ├─ 模板选型 + plan_tier 定级 + execution_lane 写入
  │   ├─ S1 Todo 同步 + conflict 扫描
  │   └─ lane-detect.sh 判定：代码文件改动 → 禁滥用命中 → L1 全流程
  │
  ├─ 用户显式 yes + attest SHA-256 锁（attest-plan.sh，9.29s）
  │
  ├─ 执行期（L1 全流程）
  │   ├─ 每个 Write/Edit 过四重门：
  │   │   ① check-delegation（白名单外主进程直做 exit 2）
  │   │   ② check-skill-modify（技能文件写入授权）
  │   │   ③ check-dispatch（Agent() prompt 契约守卫）
  │   │   ④ Rule 23 并发冲突扫描
  │   ├─ 代码编辑须派子代理（九字段 S-unit 契约 + 8 字段返回 + 检查点落盘）
  │   └─ 或用户在终端跑 allow-direct.sh（一次性、30 分钟窗）
  │
  ├─ PostToolUse hook（每次工具调用）
  │   ├─ drift-rhythm 状态读写 + config.json 7×jq + /tmp state 读写
  │   ├─ 每 10 次调用注入 [plan-sync]
  │   └─ 每 10 次注入 [drift-rhythm]+[context-pressure]+[judge] 三连
  │
  └─ 收尾（check-complete.sh，1707 行，20+ 门）
      ├─ LANE-L0 GATE（即使 L0 也强制 fresh 全量终验）
      ├─ DELEGATION GATE / VC-GATE / SESSION-LOG GATE 等
      ├─ run-selftests.sh 双轮全量回归（fresh 204.4s/轮，缓存 1.26s/轮）
      ├─ archive-plan.sh 归档 + ledger-append
      └─ user-session-log 逐字记录
```

**关键结构性问题**：钩子延迟本身（0.2-0.35s/次）不是十几小时的主因。主因是流程结构——触发倒置 + 哨兵阻断 + 强制委派 + L0 边界排除代码变更 + 双轮全量回归。

---

## 3. 实测数据

### 3.1 钩子延迟实测（/tmp/ups-timing 沙箱，3 次取中位）

| 脚本 | 场景 | 耗时 | 备注 |
|------|------|------|------|
| zcode-userpromptsubmit.sh | 无活跃计划 | 0.07-0.08s | exit-early 路径有效 |
| zcode-userpromptsubmit.sh | 有活跃计划 | 0.22-0.26s | +1165 字节注入；含 resolve-plan-dir+attest+awk+tail+config jq+owner/side 指针写+/tmp state+check-conflicts |
| zcode-posttooluse.sh | 无活跃计划 | 0.07-0.08s | Read 调用基线 |
| zcode-posttooluse.sh | 有活跃计划 | 0.34-0.36s | 含 drift-rhythm 状态读写+config.json 7×jq+/tmp state 读写 |

### 3.2 重量级脚本 wall-clock 实测（36 核 Linux，load≈4）

| 脚本 | 耗时 | 备注 |
|------|------|------|
| run-selftests.sh --fresh（全量 77 脚本） | **204.42s** | 77 PASS=0 FAIL=0；日志 /tmp/tp-perf-fresh.log |
| run-selftests.sh 第二轮（缓存命中） | **1.26s** | 77/77 reused，162× 加速 |
| attest-plan.sh（完整门链） | **9.29s** | plan-dispatch+template+requirement(四锚)+fmea+rule-reserve+SHA-256 |
| init-session.sh（mini 档） | 0.89s | /tmp 隔离目录，6+1 文件+attestation |
| check-complete.sh（完整路径） | 0.77s | porcelain clean + python3 段解析 + Batch Report 门 |
| check-complete.sh（porcelain 预检早退） | 0.12s | 未提交变更早退 |
| check-dispatch.sh（check 路径） | 0.09s | 合成 prompt 缺三文件路径 rc=1 |
| resolve-interaction-mode.sh | 0.03s | env→config→兜底 ask 全链 |
| selftest-final-gate-hash.sh | 21.96s | 全量最重脚本（305 行） |
| selftest-requirement-coverage.sh | 20.10s | 538 行 |
| selftest-vc-gate.sh | 18.63s | 189 行 |
| selftest-plan-tier.sh | 14.48s | 387 行 |
| selftest-smart-merge.sh | 11.06s | 550 行（最大） |

### 3.3 耗时构成分析

| 类别 | 占比 | 说明 |
|------|------|------|
| top-5 重脚本 | 86.2s / 204.4s = **42%** | final-gate-hash + requirement-coverage + vc-gate + plan-tier + smart-merge |
| 其余 72 脚本 | 118.2s / 204.4s = 58% | 均 1.64s |
| 简单任务端到端固定开销 | ≈14s | init-session 0.89 + attest 9.29 + resolve 0.03 + check-complete 0.12-0.77 + check-dispatch 0.09×N + 缓存 selftest 2.5s |
| 若两轮 selftest 全 fresh | ≈7min | +408s |

### 3.4 投诉复发时间线

| 日期 | 事件 | 烈度 |
|------|------|------|
| 2026-10-02 | 用户投诉"好几个小时解决一个最简单的问题" | 催生 Rule 38.7/L0 通道 |
| 2026-10-02 | v111 实证：2 文件 15 行耗时约 1h | 流程开销为变更本体的数十倍 |
| 2026-10-02 | L0 首证 15min | 但该定级口径下任何代码修复都拿不到 L0 |
| 2026-10-13 | 用户反馈"一个最简单的问题需要执行十几小时" | **烈度升级，同一投诉复发** |

---

## 4. 根因（按影响排序）

### Rank 1：L0 通道禁滥用条款排除代码文件改动（决定性）

| 项 | 内容 |
|----|------|
| **位置** | `lane-detect.sh:83-85`（禁滥用三条件）、`:86-89`（L0 三条件）；`critical-rules-template.md:52-54`（Rule 38.7 原文） |
| **问题** | L0 触发条件=≤3 文件 ∧ ≤20 行 ∧ 全 .md 无代码；禁滥用条款"代码文件改动(.sh/.ts/.cjs/.js/.py/.json)"任一命中即 L1。"看下 bug 第 10 行"必然涉及代码文件改动 → 禁滥用命中 → L1 全流程 |
| **影响** | 决定性：若 L0 覆盖 ≤3 文件 ≤20 行的代码修复，同样任务从 L1 全流程降至 L0 薄验证（~15 分钟级），差距 10-50× |
| **杠杆点** | 扩展 L0 禁滥用条款，将 CODE_HIT 禁滥用条件从"所有代码文件"收窄为"跨文件语义级联/新机制引入"的代码变更，单文件单函数修复不命中 |

### Rank 2：触发倒置 + 哨兵阻断（决定性）

| 项 | 内容 |
|----|------|
| **位置** | `task-plan-init.cjs:92`（触发条件"用户未说简单"）；`zcode-pretooluse.sh:18-23`（哨兵阻断） |
| **问题** | 触发条件倒置（"用户未说简单"即命中）+ 哨兵机制（会话开始即写 .plan-required，哨兵存续期间 PreToolUse 对 plans/ 之外所有 Write/Edit exit 2 硬阻断）= 用户在结构上无法直接改一行代码 |
| **影响** | 决定性：即使用户只想改 1 行，也必须先走 init-session 全流程，否则连编辑入口都没有 |
| **杠杆点** | 哨兵豁免——当用户指令明确指向单文件单行修复时，首个 Write/Edit 应放行至只读排查完成后的定点修复 |

### Rank 3：强制委派 + 子代理仪式（大）

| 项 | 内容 |
|----|------|
| **位置** | `config.json:43-51`（delegation_enforce 默认 enforce）；`zcode-pretooluse.sh:40-54`（check-delegation）；`:77`（check-dispatch）；`SKILL.md:62`（"禁止先自己干再派"） |
| **问题** | 执行期四重机器门叠加在每次 Write/Edit/Agent 上。简单修复路径：主进程改→①阻断；派子代理→③契约门槛+九字段 S-unit+检查点落盘 |
| **影响** | 大：将"改 1 行"从 1 次 Edit 变为 1 次子代理派发，单次开销从 <1s 升至 10-30s |
| **杠杆点** | 为 ≤3 行 trivial 修复增设主进程直通白名单 |

### Rank 4：双轮全量回归（中等，已被缓存大幅缓解）

| 项 | 内容 |
|----|------|
| **位置** | `check-complete.sh:1550-1583`（LANE-L0 GATE ①）；`run-selftests.sh:11-12`（头注病灶记载） |
| **问题** | 收尾链强制"交付前单波 fresh 全量终验"——verification.md 必须含"全量终验"+Total 行（77 脚本全量重跑） |
| **影响** | 中等（直接计时）：fresh 模式下 7min/任务；但缓存机制已将其压缩至 ~2.5s |
| **杠杆点** | 缓存已解决大头，残余优化=top-5 重脚本可并行化 |

### Rank 5：每轮 prompt 无条件注入计划复诵块（中等，复利放大）

| 项 | 内容 |
|----|------|
| **位置** | `zcode-userpromptsubmit.sh:48,52,55`（三个 exit 0 豁免条件）；`:164`（"smart 注入每轮进行"）；`:216-230`（组装注入无相关性门控） |
| **问题** | 活跃计划存在时，每次用户提问都注入结构感知计划复诵块（~1000-1500 字符/次），不判断相关性 |
| **影响** | 中等（复利放大）：50 轮对话累积 ~55KB 额外上下文，持续消耗模型推理 token 与延迟 |
| **杠杆点** | 按问题相关性门控——hook 可读取当前 prompt 首句，若与计划 Goal/Phase 关键词无交集则跳过 |

### Rank 6：[plan-note] D 类升级（中等）

| 项 | 内容 |
|----|------|
| **位置** | `zcode-userpromptsubmit.sh:164-202`（[plan-note] 节流注入）；`SKILL.md:130-139`（四分类表） |
| **问题** | 每 10 条 prompt 注入 [plan-note] D/A/B/C 影响判定指令：D 类=与当前计划无关联→强制"开新计划"。简单追问被升级为计划级决策 |
| **影响** | 中等：使用户在活跃计划期的任何新问题都被结构化地推向"重规划或新建计划"评审 |
| **杠杆点** | 对 D 类判定增设"同文件邻近行追问"豁免 |

### Rank 7：init-session 7 文件固定仪式（中等）

| 项 | 内容 |
|----|------|
| **位置** | `init-session.sh:37-45`（初始化循环）、`:575-577`（第 7 文件 user-session-log）、`:580-596`（lane-detect 接线） |
| **问题** | 新建计划=init-session.sh（889 行）落 7 文件+模板选型+plan_tier 定级+execution_lane 写入+S1 Todo 同步+conflict 扫描+哨清除。即使 1 行修复，计划侧固定产出 7 文件+Todo 映射 |
| **影响** | 中等：每次计划创建固定 ~0.89s 脚本开销+主进程构造 7 文件内容的 token 开销 |
| **杠杆点** | 为 trivial 修复档缩减为 3 文件（task_plan/progress/verification） |

### Rank 8：PostToolUse 同步链（低-中等）

| 项 | 内容 |
|----|------|
| **位置** | `zcode-posttooluse.sh:198-215`（7 个 jq 读 config.json）；`:248-256`（plan 超 15min 注入）；`:337-365`（三连注入） |
| **问题** | 活跃计划期每次工具调用 0.34-0.36s（含 drift-rhythm 状态读写、config.json 7 次 jq、/tmp state 读写） |
| **影响** | 低-中等：20 次工具调用的简单排查≈7s 纯 hook 开销+2 组注入 |
| **杠杆点** | 异步化/降频——drift-rhythm 状态读写可降频，config.json 7 次 jq 可合并为 1 次 |

### Rank 9：attest-plan.sh 9.29s（低）

| 项 | 内容 |
|----|------|
| **位置** | `attest-plan.sh:342`（SHA-256 计算） |
| **问题** | 对每个新建计划执行完整门链（plan-dispatch+template-gate+requirement-gate 四锚+fmea-gate+rule-reserve+SHA-256 锁定），实测 9.29s |
| **影响** | 低（直接计时）：9.29s/任务，在缓存命中 selftest 的场景下是最大单项固定开销 |
| **杠杆点** | 门结果缓存——同计划内容未变时复用门结果 |

### Rank 10：投诉复发=体系未自纠正（元根因）

| 项 | 内容 |
|----|------|
| **位置** | 记忆文件 `execution-lane-proportionality.md:11-24` vs 本会话用户原话（2026-10-13） |
| **问题** | 2026-10-02 投诉催生 L0 通道；2026-10-13 同一投诉以"十几小时"烈度复发——因为 L0 通道的设计边界不覆盖代码修复。记忆锚 `grep '^38.7' critical-rules.md=1` 已失效（v171 分层后 38.7 迁至 plan-template-kit:45） |
| **影响** | 元根因：前 9 项根因的共同上游——体系的规则演进速度快于簿记同步，且每次修补都在既有边界上叠加而非扩展边界覆盖 |
| **杠杆点** | 建立"投诉→根因→边界扩展"的闭环机制；L0 通道应设置定期边界审查 |

### Rank 11：top-5 重脚本占全量 42%（低）

| 项 | 内容 |
|----|------|
| **位置** | `run-selftests.sh` 全量 204.4s 中 top-5 占 86.2s |
| **问题** | final-gate-hash 21.96s + requirement-coverage 20.10s + vc-gate 18.63s + plan-tier 14.48s + smart-merge 11.06s = 86.2s（42%） |
| **影响** | 低（直接计时）：仅在 fresh 模式下有意义，缓存命中后全量仅 1.26s |
| **杠杆点** | 优先级低（缓存已兜底）——若需优化，5 个重脚本并行化 |

### Rank 12：安装副本与源仓漂移（低）

| 项 | 内容 |
|----|------|
| **位置** | `diff -rq` 实测 `~/.zcode/skills/task-planner` 与仓库不一致 |
| **问题** | SKILL.md differ + 5 个仅安装位存在的脚本（analyze-splits.sh/capabilities/check-resume-chain.sh/check-subagent-return.sh/plan-hygiene.sh） |
| **影响** | 低（不影响用户耗时，但影响审计可信度与维护成本） |
| **杠杆点** | 统一安装副本与源仓——install 同步脚本改为 rsync --delete 或符号链接 |

---

## 5. 优化方案（逐项）

### Change #1：init-session.sh auto-tier 新增 trivial 代码修复档

| 项 | 内容 |
|----|------|
| **目标** | `init-session.sh:407-419`（auto-tier 块）+ `check-complete.sh:1571`（L0 GATE ③）+ `SKILL.md`（env 变量文档） |
| **改动** | ①新增 `TASK_SCOPE_FILE_LIST`（逗号分隔文件名列表）和 `TASK_EST_LINES`（预估行数）两个 env 变量；②主进程调用 init-session.sh 前设置这两个 env 变量；③auto-tier 块增加第四条件分支——单文件代码 ∧ ≤3 行 ∧ ≤15min ∧ 单模块 → `PLAN_TIER=mini` + `execution_lane: L0` + `TRIVIAL_CODE_TIER=1`；④修复 `check-complete.sh:1571` commit 前缀 `feat` → `feat\|fix`；⑤SKILL.md 增加 env 变量文档 |
| **回归风险** | 中——①env 变量可能传递失败（fail-safe 保持缺省档）；②auto-tier 可能误判（fail-safe 兜底）；③worktree 开销未消除（§十一 铁律不变） |
| **改动量** | init-session.sh 8-10 行 + check-complete.sh 1 行 + SKILL.md 3 行 |

### Change #2：触发条件扩展 + 轻量档关键词检测

| 项 | 内容 |
|----|------|
| **目标** | `task-plan-init.cjs:92`（触发条件）+ `zcode-pretooluse.sh:20`（哨兵文案） |
| **改动** | ①触发条件从"用户未说简单"扩展为"用户未声明轻量档（简单/简单修复/就改一行/改一下/fix/typo）"；②哨兵阻断文案增加"简单修复/就改一行"跳过提示；③task-plan-init.cjs 增加轻量档关键词检测逻辑（从 stdin JSON 多字段名尽力提取 prompt，fail-open） |
| **回归风险** | 中——①触发条件扩展可能使用户误声明轻量档（但触发条件只是提示，哨兵才是强制阻断）；②关键词检测可能误判（误判后果仅为跳过提示） |
| **评审修正** | 评审指出方案只改哨兵文案未解决触发倒置根本问题 → 已同时修改触发条件本身 |

### Change #3：check-delegation.sh mini 直做通道扩展

| 项 | 内容 |
|----|------|
| **目标** | `check-delegation.sh:299-318`（mini 直做通道） |
| **改动** | 在 mini 直做通道前增加前置分支——无活跃计划 ∧ tool=Edit ∧ new_string 行数 ≤3 ∧ 单文件 ∧ file 不在保护区 → exit 0 放行。复用既有 mini 通道的保护区排除逻辑 |
| **回归风险** | 中——评审指出"无活跃计划 ∧ Edit ≤3 行 → exit 0"绕过了计划创建流程，与 §十一 worktree 铁律冲突。缓解：仅对无活跃计划场景生效；仅 Edit ≤3 行；复用保护区排除 |
| **评审修正** | 评审指出既有 mini 通道已覆盖 `plan_tier: mini ∧ 非保护区 → exit 0`，方案应扩展 mini 通道条件而非新增 trivial 阈值 |

### Change #4：check-complete.sh L0 GATE ① 注释澄清

| 项 | 内容 |
|----|------|
| **目标** | `check-complete.sh:1555-1562`（L0 GATE ① Total 校验） |
| **改动** | 仅修改注释，不改代码逻辑。澄清 Total 行格式=`Total: N PASS=x FAIL=y（+可选 reused=z）`，GATE 只 grep `Total:`，缓存命中时 reused 合法 |
| **回归风险** | 极低——仅修改注释 |
| **评审修正** | 评审指出方案基于对 L0 GATE 的误读——实测确认只检查 `grep -qE 'Total:'`，不校验 PASS=/reused=，当前 GATE 已接受任何含"Total:"的行 |

### Change #5：smart 注入 prompt 类型门控

| 项 | 内容 |
|----|------|
| **目标** | `zcode-userpromptsubmit.sh:150-160`（smart 注入） |
| **改动** | ①放弃会话级去重（评审指出 Goal+Next Step 通常不变，去重效果有限）；②改为 prompt 类型门控——prompt 长度 <50 字符 ∧ 不含 Goal 关键 token → 跳过 smart 注入块；③config.json 增加 `smart_inject_type_gate`（default: off, opt-in） |
| **回归风险** | 中——prompt 类型检测可能误判，但误判后果仅为跳过一次 smart 注入 |
| **评审修正** | 评审指出 100+ 停用词列表维护成本高 → 改用 Goal 关键 token 匹配；评审指出 <50 字符阈值武断 → 保留但仅作 opt-in |

### Change #6：[plan-note] D 类文案增加邻近行引用例外

| 项 | 内容 |
|----|------|
| **目标** | `zcode-userpromptsubmit.sh:201`（[plan-note] D 类文案） |
| **改动** | ①D 类描述前增加"例外：若新 prompt 引用当前计划 scope 内同一文件的相邻行，归为 B 类而非 D 类"；②增加邻近引用词正则检测（第N行/上一句/刚才那个/继续/接着 → 命中加 `[邻近引用→B 类]` 前缀） |
| **回归风险** | 低——仅影响 [plan-note] 分类文案，不影响实际执行逻辑 |

### Change #7：init-session.sh trivial 档缩减为 3 文件

| 项 | 内容 |
|----|------|
| **目标** | `init-session.sh:501`（7 文件创建） |
| **改动** | ①trivial 档（`TRIVIAL_CODE_TIER=1`）只创建 task_plan.md + progress.md + verification.md 三个文件，跳过 findings/notepad-learnings/knowledge-brief；②user-session-log.md 改为按需创建；③头部注释增加 trivial 档说明 |
| **回归风险** | 中——3 文件可能不够承载某些 trivial 修复的簿记需求。缓解：仅对 Change #1 统一的条件生效；verification.md 仍创建（LANE-L0 GATE 依赖） |
| **评审修正** | 评审指出 Change #7 条件应与 Change #1 统一（代码文件 ∧ ≤3 行），不能所有 auto-tier mini 档都缩减为 3 文件 |

### Change #8：zcode-posttooluse.sh jq 合并

| 项 | 内容 |
|----|------|
| **目标** | `zcode-posttooluse.sh:198-215`（jq 合并） |
| **改动** | ①将 6 次 jq 读 config.json 合并为 1 次多键 @tsv 调用；②drift-rhythm 状态读写降频（每 5 次工具调用而非每次） |
| **回归风险** | 低——纯性能优化，不改变逻辑 |
| **实施修正** | drift-rhythm 降频因破坏 DCE-22/DCE-23 N1 节奏守护已回退，仅保留 6×jq→1×@tsv 合并（零逻辑变化） |

### Change #9：attest-plan.sh 门结果缓存

| 项 | 内容 |
|----|------|
| **目标** | `attest-plan.sh:342`（门结果缓存） |
| **改动** | ①复用现有 SHA-256 作为缓存键主分量+门控配置防 enforce 漂移；②缓存命中 → 直接输出缓存结果（含 rc=0 + 门链 PASS 行），跳过完整门链；③子 shell 包裹门链+仅捕获 stdout（stderr 实时透传保流语义）+缓存命中重放 skip WARN；④rc=0 才写缓存，失败不缓存 |
| **回归风险** | 中——缓存可能导致门结果过时。缓解：缓存键复用 attestation 的 SHA-256，任何 plan_file 变更都会导致缓存自动失效 |
| **评审修正** | 评审指出 SHA-256 只对 task_plan.md 求 hash，不包括其他计划文件 → 已补充门控配置防 enforce 漂移 |

### Change #10：SKILL.md 投诉响应协议 + 验证锚更新

| 项 | 内容 |
|----|------|
| **目标** | `SKILL.md`（投诉响应协议+验证锚更新+env 变量文档） |
| **改动** | ①增加"投诉响应协议"段——每次用户投诉"慢"时检查既有通道边界是否覆盖该场景；②L0 通道增加定期边界审查触发（每 10 个任务或每月）；③增加验证锚新位置说明（Rule 38.7 现位于 `critical-rules-template.md:45` + `critical-rules-discipline.md:191`）；④增加 env 变量文档；⑤不修改 `~/.zcode/` 下的记忆文件（§六 保护区约束） |
| **回归风险** | 低——纯文档更新，不影响运行时行为 |
| **约束** | SKILL.md 是技能文件，修改需走 §十一 worktree 铁律 |

### Change #11：run-selftests.sh top-5 重脚本并行化

| 项 | 内容 |
|----|------|
| **目标** | `run-selftests.sh`（top-5 重脚本并行化） |
| **改动** | ①top-5 重脚本（final-gate-hash/requirement-coverage/vc-gate/plan-tier/smart-merge）放入后台并行执行（& + wait），其余 72 脚本串行；②config.json 增加 `selftest_heavy_concurrent`（default: off, opt-in） |
| **回归风险** | 中——并行化可能引入竞态条件。缓解：默认 off；各 selftest 脚本独立写自己的输出文件，无共享状态 |

### Change #12：install.sh 安装副本统一

| 项 | 内容 |
|----|------|
| **目标** | `lib/install-stub.sh`（安装副本同步） |
| **改动** | ①将 install 同步改为 `rsync -a --delete`（确保安装位与源仓完全一致）；②同步前 dry-run `--itemize-changes` 记录差异范围；③记录同步时间戳与文件数（install.log 审计面） |
| **回归风险** | 中——rsync --delete 可能删除安装位的自定义文件。缓解：同步前先 dry-run 确认差异范围 |

---

## 6. 评审意见

### 已确认项

1. **v3 Change #1 新增 env 变量声明确认可行**：init-session.sh 当前只接收 `TASK_AUTO_TIER`/`TASK_TIER_EXCLUDE`（:407-408），不接收 `TASK_SCOPE_FILE_LIST`/`TASK_EST_LINES`（grep 确认无这两个变量）。方案新增这两个 env 变量并说明传递机制技术上可行。
2. **v3 Change #1 行号引用修正确认正确**：auto-tier 块实测在 :407-419，方案修正为 :407-419 正确。
3. **v3 Change #2 触发条件原文确认**：`task-plan-init.cjs:92` 实测确认触发条件是"用户未说简单"。
4. **v3 Change #9 SHA-256 复用确认正确**：`attest-plan.sh:342` 实测确认已有 SHA-256 计算，方案复用作为缓存键正确。
5. **v3 Change #7 条件统一确认正确**：方案将 Change #7 的条件统一为与 Change #1 一致。

### 问题与修正

| # | 问题 | 修正 |
|---|------|------|
| 1 | **Change #2 实现前提未确认**：SessionStart hook stdin 是否包含 prompt 字段。`task-plan-init.cjs:25-32` 实测只提取 `.session_id`，不读取 prompt 字段 | 实施时采用多字段名尽力提取（.prompt/.user_prompt/.message/.content），fail-open——读不到 prompt 时不命中轻量档关键词，保持原有行为 |
| 2 | **Change #2 未同时修改哨兵机制**：触发条件只是提示，哨兵才是强制阻断 | 实施时同时修改哨兵阻断文案（`zcode-pretooluse.sh:20`），增加"简单修复/就改一行"跳过提示 |
| 3 | **Change #5 实现前提未确认**：UserPromptSubmit hook stdin 是否包含 prompt 字段。`zcode-userpromptsubmit.sh:17-18,34` 实测只读取 `.cwd` 和 `.session_id` | 实施时从 stdin JSON 多字段名尽力提取 prompt，fail-open |
| 4 | **Change #5 停用词列表维护成本高**：100+ 个中文停用词需持续维护 | 评审简化：用 Goal 关键 token 匹配替代 100+ 停用词词袋 |
| 5 | **Change #5 prompt 长度阈值 <50 字符武断**：中文 50 字符可能包含完整问题描述 | 保留但仅作 opt-in（default off） |
| 6 | **Change #9 缓存键覆盖范围不足**：SHA-256 只对 task_plan.md 求 hash，不包括其他计划文件 | 实施时补充门控配置防 enforce 漂移；缓存键主分量复用 attestation SHA-256 |

---

## 7. 实施与回归结果

### 实施状态

| 项 | 内容 |
|----|------|
| **worktree 路径** | `/mnt/data/dev/task-planner-skill-worktrees/perf-opt-20261012` |
| **分支** | `wt/perf-opt-20261012` |
| **commit** | `a0c5a03fc8e6801cc88844ca38ce20af9c3f4d82` |
| **变更规模** | 29 files changed, 388 insertions(+), 69 deletions(-) |
| **合并状态** | **未合并回 master**（留给主进程） |

### 12 项改动实施清单

| Change | 实施内容 |
|--------|----------|
| #1 | init-session.sh auto-tier 新增 trivial 代码修复第四条件分支（`TASK_SCOPE_FILE_LIST`/`TASK_EST_LINES` 两 env，单文件代码 ∧ ≤3 行 ∧ ≤15min ∧ 单模块 → mini+L0+`TRIVIAL_CODE_TIER=1`）+ lane-detect 块 L0 强制覆写；check-complete.sh LANE-L0 GATE ③ commit 前缀 `feat`→`feat\|fix`；SKILL.md 加 auto-tier env 变量文档 |
| #2 | task-plan-init.cjs 增加轻量档关键词检测（prompt 多字段名尽力提取 fail-open + `LIGHTWEIGHT_KW=[简单修复/就改一行/改一下/简单/fix/typo]`）+ 触发条件④文案扩展 + 命中时输出提示行；zcode-pretooluse.sh 哨兵阻断文案增加跳过提示 |
| #3 | check-delegation.sh mini 直做通道（④b）前增加 ④a trivial 前置分支（无活跃计划 ∧ Edit≤3 行 ∧ 单文件 ∧ 非保护区 → exit 0） |
| #4 | check-complete.sh L0 GATE ① Total 行校验口径注释澄清（仅注释，不改代码逻辑） |
| #5 | zcode-userpromptsubmit.sh smart 注入 prompt 类型门控（Goal 关键 token 匹配替代停用词词袋；prompt 长<50 且不含 Goal token → 跳过 smart 注入）；config.json 新增 `smart_inject_type_gate`（default off, opt-in） |
| #6 | zcode-userpromptsubmit.sh [plan-note] D 类文案增加同文件邻近行引用例外说明 + 邻近引用词正则检测 |
| #7 | init-session.sh trivial 档（`TRIVIAL_CODE_TIER=1`）7 文件缩减为 3 文件（task_plan/progress/verification）+ user-session-log.md 改按需创建 |
| #8 | zcode-posttooluse.sh 6 次 jq 读 config.json 合并为 1 次多键 @tsv；drift-rhythm 降频因破坏 DCE-22/DCE-23 已回退，仅保留 jq 合并 |
| #9 | attest-plan.sh 门结果缓存（复用现有 SHA-256 + 门控配置防 enforce 漂移；子 shell 包裹门链 + 仅捕获 stdout；rc=0 才写缓存；命中 0.042s vs 未命中 0.503s） |
| #10 | SKILL.md 新增"投诉响应协议与 L0 边界审查"段 + Rule 38.7 验证锚新位置说明 |
| #11 | run-selftests.sh top-5 重脚本并行化（config `selftest_heavy_concurrent`, default off） |
| #12 | lib/install-stub.sh 安装副本同步改 `rsync -a --delete` + dry-run + install.log |

### 回归测试结果

| 项 | 结果 |
|----|------|
| **全量 fresh 回归** | `bash scripts/run-selftests.sh --fresh` = **Total: 77 PASS=77 FAIL=0** (run=77 reused=0, EXIT=0) |
| **回归中修复的 3 类问题** | ①config.json 新增 2 键与 17 个 selftest 的"零新 config 键 properties=42"守护基线冲突 → 已同步 42→44；②attest-plan.sh 门结果缓存原用命令组 `{ }` 包裹门链，门链内 exit 1 会终止整个脚本 → 改为子 shell 包裹+仅捕获 stdout；③Change #8 drift-rhythm 降频破坏 DCE-22/DCE-23 N1 投递节奏守护 → 已回退降频，仅保留 jq 合并 |
| **attest 缓存手动实测** | miss 0.503s → hit 0.042s |
| **init-session trivial 档手动验证** | 3 文件+L0 与默认档 7 文件行为均正确 |
| **配套更新** | 17 个 selftest 的"零新 config 键 properties 键数=42"守护基线同步 42→44 |

---

## 8. 后续建议

### 8.1 主进程需合并 worktree

**当前状态**：worktree `wt/perf-opt-20261012`（commit `a0c5a03`）已实施全部 12 项优化，全量回归 77/77 PASS=0 FAIL，但**尚未合并回 master**。

**合并步骤**（需主进程执行）：

```bash
# 1. 确认 worktree 内全部 Phase = complete，VC 逐条复验通过
cd /mnt/data/dev/task-planner-skill-worktrees/perf-opt-20261012
git status  # 应干净

# 2. 确认主仓无与任务范围重叠的未提交变更
cd /mnt/data/dev/task-planner-skill
git status --short

# 3. 合并回 master
git merge --no-ff wt/perf-opt-20261012

# 4. Read 关键文件 + git log 复验
git log --oneline -3

# 5. 清理 work树
git worktree remove /mnt/data/dev/task-planner-skill-worktrees/perf-opt-20261012
git branch -d wt/perf-opt-20261012
```

### 8.2 优化效果预期

| 场景 | 优化前 | 优化后 | 改善 |
|------|--------|--------|------|
| 单文件 ≤3 行代码修复 | L1 全流程（十几小时） | L0 薄验证（~15min 级） | **10-50×** |
| 简单任务固定开销 | ~14s + 7min fresh selftest | ~14s + 2.5s 缓存 selftest | selftest 开销降低 99% |
| attest-plan 门链 | 9.29s/任务 | 0.042s（缓存命中） | **220×** |
| PostToolUse jq 读取 | 7 次 jq/调用 | 1 次 jq/调用 | 减少 6 次子进程孵化 |
| smart 注入 | 每轮 1.1KB | 按相关性门控（opt-in） | 减少无关上下文注入 |

### 8.3 待观察项

1. **Change #2 轻量档关键词检测**：SessionStart hook stdin 是否含 prompt 字段取决于 ZCode 平台 hook 输入格式，实施采用多字段名尽力提取 fail-open。若平台不含 prompt 字段，需替代机制（如环境变量 `TASK_PLANNER_PROMPT` 或临时文件）。
2. **Change #5 prompt 类型门控**：default off（opt-in），需观察实际效果后决定是否默认开启。
3. **Change #11 top-5 并行化**：default off（opt-in），需观察竞态风险。
4. **L0 通道边界审查**：建议每 10 个任务或每月检查最常见简单场景是否被既有通道排除，防止投诉第三次复发。

### 8.4 元根因防范

**投诉响应协议**（已写入 SKILL.md）：每次用户投诉"慢"时，不仅修补当前症状，还检查既有通道边界（L0/mini/trivial）是否覆盖该场景，未覆盖则**扩展边界**而非叠加新门控。

**验证锚同步**：Rule 38.7 验证锚已从失效的 `critical-rules.md:468` 更新为 `critical-rules-template.md:45` + `critical-rules-discipline.md:191`。

---

## 附录：关键文件索引

| 文件 | 行号 | 内容 |
|------|------|------|
| `skills/task-planner/scripts/lane-detect.sh` | :83-89 | L0 三条件 + 禁滥用三条件 |
| `skills/task-planner/scripts/task-plan-init.cjs` | :88-92 | 哨兵写入 + 触发条件 |
| `skills/task-planner/scripts/zcode-pretooluse.sh` | :18-23,40-54,57-59,62-82,94-157 | 哨兵阻断 + 四重门 |
| `skills/task-planner/scripts/zcode-userpromptsubmit.sh` | :42-55,95-161,164-202,216-230 | 计划复诵块注入 + [plan-note] |
| `skills/task-planner/scripts/zcode-posttooluse.sh` | :29-35,70-113,115-161,198-215,245-325,337-365 | 串行槽 + drift-rhythm + jq 读取 |
| `skills/task-planner/scripts/check-complete.sh` | :421-494,645-816,1124-1182,1550-1583 | 20+ 门控 + LANE-L0 GATE |
| `skills/task-planner/scripts/run-selftests.sh` | :10-16,87-93 | 头注病灶 + 缓存机制 |
| `skills/task-planner/scripts/init-session.sh` | :37-45,407-419,501,575-596 | 初始化循环 + auto-tier + 7 文件 |
| `skills/task-planner/scripts/attest-plan.sh` | :342 | SHA-256 计算 |
| `skills/task-planner/scripts/check-delegation.sh` | :291-318 | trivial 豁免 + mini 直做通道 |
| `skills/task-planner/config.json` | :43-51,279-304,326-327 | 门控档位配置 |
| `skills/task-planner/SKILL.md` | :4,37-45,62,75,89-90,122,130-139,141-143,197 | 技能定义 + 合规清单 |
| `skills/plan-template-kit/references/critical-rules-template.md` | :45-54 | Rule 38.7 原文 |
| `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/execution-lane-proportionality.md` | :11-24 | 投诉复发证据链 |
