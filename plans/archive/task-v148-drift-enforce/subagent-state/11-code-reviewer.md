# S7 Code Review 检查点 — task-v148 防偏移加强（worktree wt/task-v148-drift-enforce, 基点 master e54973d）

verdict: CHANGES_REQUESTED
审查对象: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce（9 文件，8 改 1 新）
只读审查；除本检查点零写入；无 git 写操作。已实测：4 脚本 bash -n 全通过；DCS 20/20 全绿（无回归）；新增 selftest 16/16 全绿；registry 5/5 全绿；条款 §1 与草案逐字 diff = VERBATIM-MATCH。

## 发现清单（逐条证据 + 判定）

### F1 [MAJOR] 契约不一致：条款 64.2 豁免出口 (b) `plan_tier: mini` 未在 gate 实现
- 位置: skills/task-planner/references/critical-rules.md:775 ↔ skills/task-planner/scripts/check-3file-gate.sh:256-279
- 原文: "豁免（满足其一）：(a) task_plan.md 声明行 `drift_exempt: <Phase 清单>`...；(b) `plan_tier: mini` 任务整体豁免（38.3 同口径）；(c) env `TASK_PLANNER_DRIFT_ENFORCE=warn`..."
- 证据: gate 全文 `grep -c 'plan_tier'` = 0；条件 6 分支仅 `drift_check_activity`/`drift_checkpoint_activity`/`drift_exempt_check` 三出口 + env 三档，缺 (b)。38.3 规定 mini 任务"每 Phase 照常一次 3-File 回填"→ mini 任务仍会调用本 gate，Phase complete 将被硬 exit 1 拦截。
- 原因: 落地 P0 条款明文承诺 mini 整体豁免，实现未兑现 → mini 任务被误拦（false positive），与条款"Why=三档豁免保轻任务零增负"自相矛盾。（注：草案 §2.2 接线规格亦遗漏 (b)，故为规格层遗留缺口；但条款为已落地的 P0 文本，实现须兑现）
- 修复: 在 gate 条件 6 降档前增加 mini 出口（与 38.4 范式一致）:
  `elif grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then DRIFT_OK=1; echo "[3file-gate] plan_tier=mini 豁免放行（Rule 64.2b）"`
  或（次选）将 64.2(b) 从条款移除并同步 §2.2；推荐前者。
- 置信度: HIGH

### F2 [MINOR] 测试缺口：env `off` 档未被 DCE 覆盖
- 位置: skills/task-planner/scripts/selftest-drift-enforcement.sh:48-49
- 原文: `TASK_PLANNER_DRIFT_ENFORCE=warn bash "$GATE" ... && ok "DCE-14 gate env warn exit 0"`（仅 warn）
- 证据: DCE-11 测默认 enforce(exit1)、DCE-14 测 warn(exit0)，无 off 档断言。实测 off 档行为正确（exit 0 + stdout 提示），但无回归守护，未来改动易静默破坏。
- 修复: 追加 DCE-17: `TASK_PLANNER_DRIFT_ENFORCE=off bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && ok ...`
- 置信度: HIGH

### F3 [MINOR] DCE-12/13/14 fixture 与墙钟耦合（硬编码 Started 时间戳）
- 位置: skills/task-planner/scripts/selftest-drift-enforcement.sh:35（DCE-12/13/14 复用）
- 原文: `printf '## Phase 2: test\n- **Started:** 2026-10-08 12:00\n' > "$TMP/plan/progress.md"`
- 证据: 实测将 Started 置为将来时间（2099）后 gate exit 1（条件 1-5 因 findings/progress mtime < 锚点 判"从未更新"）→ DCE-12/13/14 期望 exit 0 的场景会失败。fixture 依赖 "运行时墙钟 > 2026-10-08 12:00"，在 2026-10-08 当日 12:00 前运行必挂（且所有断言随锚点比较翻转）。
- 修复: Started 用相对时间（如 `$(date -d '-1 hour' '+%Y-%m-%d %H:%M')`）或动态过去值，消除墙钟依赖。
- 置信度: MEDIUM-HIGH

### F4 [MINOR] DCE-16 非封闭：依赖全局 /tmp 主 hook 状态，存在优先级 4 提前返回
- 位置: skills/task-planner/scripts/selftest-drift-enforcement.sh:52-59 ↔ skills/task-planner/scripts/zcode-posttooluse.sh:273-277,282
- 原文: `printf '{"cwd":"%s","session_id":"testsid"}\n' "$TMP" | bash "$HOOK" ...`（固定 SID=testsid，未隔离 /tmp/task-planner-hook-testsid.state）
- 证据: 实测预置 /tmp/task-planner-hook-testsid.state count=9 时，hook 走优先级 4（`if [ "$count" -ge "$todo_n" ]`）提前 `exit 0`，drift_rhythm_check 未执行 → stdout 无 drift-rhythm → DCE-16 FAIL。fixture 固定 SID 且跨运行累积主计数器，重复运行至某一轮必失败。
- 修复: SID 唯一化（如 `testsid$$`）；或 fixture 内 `rm -f /tmp/task-planner-hook-<sid>.state`；或注入独立 HOME/OPENCODE_SKILL_ROOT 隔离。
- 置信度: MEDIUM

### F5 [MINOR] drift 计数器在所有提前返回路径被跳过 → 计数偏低，"≥N 次"语义不准
- 位置: skills/task-planner/scripts/zcode-posttooluse.sh:282（唯一调用点）↔ :200-277（优先级 1-4 各 `exit 0`）
- 原文: `drift_rhythm_check "$plan_dir" "$SID"`（置于脚本末尾 fall-through）
- 证据: 优先级 1-4 命中即 exit 0（:207,:235,:240,:263,:268,:276），前置 drift 计数不自增。优先级 4（todo_n 默认 10）每 10 次调用命中一轮并重置主计数，那一轮 drift 计数被吞。稳态下 drift 每 10 次工具调用仅自增 ~9 次，N=10 实际约需 11+ 次调用触发。
- 原因: 影响有限（提醒为软注入，仍会触发），但与 64.3"每满 N 次工具调用"字面有偏差。
- 修复: 将 drift_rhythm_check 调用前移至 `input` 解析后、任何早退之前（emit 输出与早退的其它提醒可并存于 additionalContext 合并，或至少先自增计数）。
- 置信度: MEDIUM

### F6 [MINOR] ledger-append.sh 用法 docblock 事件枚举未同步 drift_check（注释陈旧）
- 位置: skills/task-planner/scripts/ledger-append.sh:9
- 原文: `#   <event> 枚举: progress | phase_complete | error | gate_block | attest | note | kb_distill`
- 证据: :30 `VALID_EVENTS="... kb_distill drift_check"` 已含 drift_check，但 :9 仍止于 kb_distill（kb_distill 当初已同步 :9，本次 drift_check 未同步）→ 头部用法注释与实际枚举不一致。
- 修复: :9 行尾追加 `| drift_check`。
- 置信度: HIGH

### F7 [MINOR] drift-checker.md 追加行格式破坏列表结构（无 `-`、无空行）
- 位置: skills/task-planner/companion/agents/drift-checker.md:35
- 原文: `判定输入三锚（Rule 64.4）：任务书必须内嵌 ① Goal 原文锚 ② progress.md 尾部动作清单锚 ③ scope 文件集锚；...`
- 证据: :31-34 为"## 判定纪律"下的 `-` 列表；:35 紧贴 :34 无空行且无 `-` 前缀，Markdown 会将其渲染为最后一项的 lazy continuation，视觉上并入上一 bullet，风格与本节不一致（草案 §4.2 要求"判定纪律段之后追加"）。
- 修复: 前置空行 + `- ` 前缀，如 `- 判定输入三锚（Rule 64.4）：...`（或独立子标题）。
- 置信度: HIGH

### F8 [MINOR/观察] 条款命名与门控粒度（规格固有，非落地错误）
- 位置: critical-rules.md:775（64.2 标题"Phase complete 第三条件门控" vs 正文"追加第 6 条件"）；check-3file-gate.sh:258-265
- 原文: `64.2 **Phase complete 第三条件门控（machine gate）**...追加第 6 条件`
- 说明: ①标题"第三条件"与正文"第 6 条件"措辞不一致（易致读者误映射 gate 条件序）；②64.1 要求三痕迹齐备，而 gate 通过判据为"≥1 条痕迹"，Drift Log 表行永不被机器校验（gate 无法检出缺 Drift Log）。②与草案 §2.2 定义一致，属规格设计取舍，非实现偏差。
- 修复: 建议将标题措辞与正文统一（如"Phase complete 第 6 条件门控"），并在 64.1 注明 gate 为"≥1 痕迹"粗判、三痕迹完整由 LLM 合规清单 C4 承载（已在 C4 追加句体现）。
- 置信度: MEDIUM（②LOW，属规格固有）

## 安全/负结果（已查项）
- 注入面: drift-rhythm 注入为固定字面量，仅插值 `${n}`（`case ... *[!0-9]*` 校验为纯数字）；state 文件内容仅入算术、绝不入 additionalContext → 无注入。NEGATIVE（通过）
- hook 静默路径零 stdout: drift_rhythm_check 所有 fail-open 返回 `return 0`，mkdir/sed/printf 错误均 `2>/dev/null`；仅阈值命中时 emit。实测无输出污染。NEGATIVE（通过）
- fail-open 完整性: zcode-posttooluse.sh 无 `set -e`；函数内所有异常分支 return 0；缺 jq/目录不可写/解析失败均静默。NEGATIVE（通过）
- 并发: state 文件按 SID 分文件（`${sid}.state`），sid 经 `tr -cd 'a-zA-Z0-9' | head -c 40` 净化；hook 链会话内串行 → 并发写风险低（`>` 截断写非原子，与既有主 state 同款，未单列）。
- set -e/-u: gate 中 `[ ... ] && var=...`、`[ ... ] && return 0` 属 && 列表非末位命令，不触发 set -e；stat 均有 [ -f ] 前置。NEGATIVE（通过）
- 条款逐字: §1（§0 块头+注释+64.1~64.6）与草案 diff = VERBATIM-MATCH；DCS-01~20 20/20 无回归。
- 零新 config 键: config.json 无 drift_enforce（DCE-09）；仅 env 两键 + 计划声明行，符合 64.6。

## 判定
- F1 MAJOR（条款承诺的 mini 豁免未实现 → 误拦）→ 必须修复后方可 APPROVED。
- F2/F3/F4/F5/F6/F7 MINOR、F8 观察项 → 建议随 F1 一并修（F3/F4 直接决定 selftest 稳定性）。
verdict: CHANGES_REQUESTED
