# 03c-executor-t3 checkpoint (V-9 VC/V-N 终验门控)

## S1 现状勘察 ✅
- worktree git log 头部 7ad8ec0（T-2 已 commit），worktree 内 status 干净
- check-complete.sh 门控接入区 = python exit 0 后 shell 段 :444-460（plan-dispatch :446 / rescue-chain :452-460），新门插 rescue-chain 后
- 档位解析模式 = check-rescue-chain.sh:87-105 resolve_tier()（env > jq config > fail-open warn）
- config.json 已有 max_vc(5)/min_verification_per_phase(2) 阈值键 + rescue_chain_enforce 键块可参考
- VC 行格式（v065 真实计划 :20-27）= `| VC-1 |...` → 正则 `^\|[[:space:]]*VC-[0-9]+`
- V-N 目标格式 = templates/verification.md:39-57 `- [ ] V-1.1: [mapped to VC-? ...]` → 正则 `^[[:space:]]*- \[[ xX]\] V-[0-9]+\.[0-9]+`（占位 `[ ]` 也计条目，符合模板初始态；映射目标限 V-P. 前缀段内）
- 判定口径：VC≥5 且每个 Phase 段 V-N≥2 且映射目标 ∈ 已定义 VC 集合
- template stub 识别（对齐 check-complete.sh:298 tpl_lines 集合口径）：计划段内「实质」V-N 行 = 不在 templates/verification.md 行集合 且 非空 且 非 `<!--`；无实质映射行 → 占位不计（模板残留不算合规）
- 任务 3 模板改动：templates/task_plan.md 各 Phase `- **Status:**` 行前插 `- **V-N:**` 占位行；check-plan-dispatch 的 status-only 匹配（ls.startswith）不受影响

## S2 实施
（待写）

## S2 check-complete.sh VC-GATE 段 ✅
- 位置: rescue-chain 门（:452-460 区）之后、warn 计数段之前；plan 定位沿用 `"$PLAN_FILE"` 与 `PLAN_DIR_GUESS`，无新口径
- 新增: CONFIG_JSON 变量（:105 区，与 SKILL_ROOT 同处）、resolve_vc_gate_tier()、vcgate_grep_map()/vcgate_count_substantive() 函数、VC-GATE 主段
- 段切法: `grep -nE '^###[[:space:]]+Phase'` 取行号 → `sed -n start,(end-1)p` 逐段截取（首版用 awk 处理 title 列表，实测 f 状态恒 0 导致 vn_sub 全 0，已修；调试证据: "Segment 0: 2/2 phases (complete)" 后 vc_count 首版被 `grep -cE|grep -oE` 管道串扰输出 0，已加 `|| true`/清洗修）
- 判定: VC≥5（`grep -cE '^\|[[:space:]]*VC-[0-9]+'`）+ 每 Phase 实质 V-N 映射 ≥2（`- [x|X] V-P.N:` 行，P=Phase 序）且映射目标 ∈ 已定义 VC 集合；模板 verification.md 占位行（strip 后 ∈ 模板行集合）不计实质
- 档位: TASK_PLANNER_VC_GATE_ENFORCE > config.json vc_gate_enforce > fail-open warn；enforce 违规 → exit 1（`[plan] VC-GATE FAILED ...`）；warn 违规 → stderr `[plan] VC-GATE WARNING ...` + exit 不变；off 跳过；段在 python_rc=0 门链内，不影响现有各门 exit 语义

## S3 config.json ✅
- vc_gate_enforce 键块 10 行（enforce|warn|off，default warn），插在 fmea_enforce 与 rescue_chain_enforce 之间；`jq -e .properties.vc_gate_enforce` 通过

## S4 templates/task_plan.md ✅
- 5 个 `### Phase N` 段各在 `- **Status:**` 前补 1 行 `- **V-N:** VC-x, VC-y（本 Phase 验收映射的 VC 编号,≥2 条）`（:148/:166/:178/:196/:208）
- VC 表注释区（:32-41）加 V-N 填写说明（goal-gate 规则 + 落点 + 机械校验指向）

## S5 selftest-vc-gate.sh ✅ 新建 151 行
- 9 用例: T01 合规 PASSED / T02 vc3 warn / T02b vc3 enforce exit1 / T03 无VN warn / T03b 无VN enforce / T04 off 无输出 / T05 未定义VC 映射目标 / T06 模板占位残留不计 / T07 默认档（config warn）
- 夹具全在 mktemp，含 delegation/handoff/plan-dispatch 前置门合规底座，VC-GATE 为唯一变量
- 结果: Total: 9 PASS=9 FAIL=0, exit 0

## S6 验收 4 项 ✅
1. bash -n: check-complete.sh / selftest-vc-gate.sh / selftest-rescue-chain.sh / selftest-plan-dispatch.sh 全 rc=0；config.json jq 合法
2. selftest-vc-gate.sh 全绿 9/0
3. v065 真实计划: 直接跑 check-complete.sh 时 Phase4 in_progress → python 门 exit 1（既有语义，shell 门链不执行，rc=1 与改动前一致）；tmp 副本夹具（全 Phase complete + Batch 8 字段 + 3 S-unit 表 + Handoff 登记，8VC/0VN）: warn 档 rc=0 且 stderr `[plan] VC-GATE WARNING ... VC 表=8; Phase V-N 映射缺口: Phase1..6(V-N 映射 0 < 2)`；TASK_PLANNER_VC_GATE_ENFORCE=enforce 时 rc=1 且 stderr `[plan] VC-GATE FAILED ...`。未改真实计划
4. 既有 selftest 不回退: selftest-rescue-chain.sh 11/11 PASS rc=0；selftest-plan-dispatch.sh 8/8 PASS rc=0

## S7 提交 ✅
- worktree commit 7f1a0a9（4 files, +292/-5），git status 干净
- 仅 add 本批 4 文件，未 add -A

## 结论
- status: done; confidence: HIGH
- 风险: ① V-N 目标格式以 templates/verification.md 的 `- [ ] V-P.N: (mapped to VC-x)` 为基准，若实际计划写成其他变体（如 `V-1: VC-2,VC-3` 表格式）将计 0 映射 → warn 档误报，属预期观察期语义（default warn 不阻断）② 无 `### Phase` 标题的计划 p_no=0 → 仅 VC 数校验 ③ check-complete 在 delegation 等前置门 exit 1 时 VC-GATE 段不执行（gate 链语义，与 rescue-chain 同行为）
