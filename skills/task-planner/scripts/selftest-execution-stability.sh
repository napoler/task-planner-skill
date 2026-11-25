#!/usr/bin/env bash
# [2026-09-13 task-v068-execution-stability] selftest-execution-stability.sh — 环境级中断自愈面守护套件
# 守护 task-v068 自愈矩阵 6 行已落地机制清单 + 新键 config.json#hook_self_heal_enforce
# (check-scope memories 豁免 / plan-created 兜底清除 / PostToolUse 自动重锁 / attest-plan
#  attested_by_sid / UPS env sid 兜底 / check-delegation observe 节流 / config 键 / SKILL.md 条款
# / 跨文件键名一致 / v067 回归哨兵) 一致性。
# 12 组用例 T1-T13 (T13 为 task-v078 S5 行为用例, 含 T11 同款 fixture 手法 + 因果对照),
# 全 PASS exit 0, 任一 FAIL exit 1。T1-T10 纯 grep/python3 机械断言, 无 fixture; T11/T13 行为级。
# 结构/style 照抄 scripts/selftest-knowledge-brief.sh (set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit)。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                        # <repo-root>/skills/task-planner
SKILL="$ROOT/SKILL.md"
CONFIG="$ROOT/config.json"
SCOPE="$SCRIPT_DIR/check-scope.sh"
PLANCREATED="$SCRIPT_DIR/plan-created.cjs"
POSTTOOL="$SCRIPT_DIR/zcode-posttooluse.sh"
ATTEST="$SCRIPT_DIR/attest-plan.sh"
UPS="$SCRIPT_DIR/zcode-userpromptsubmit.sh"
DELEG="$SCRIPT_DIR/check-delegation.sh"
INIT="$SCRIPT_DIR/init-session.sh"
BRIEF="$ROOT/templates/knowledge-brief.md"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# [2026-11-26 task-spec-consumption-chain 回归修复 C 段] What: 为 T11a/b 的 legacy 夹具补规范基线新契约最小实物
#   （9 列基线表 1 条 SPEC + 真实来源锚 sha + 零 must 收据 + plan-state.json 同构 + 核验表 PASS + 正文点名）。
# Why: 基线 attest 与 posttooluse 自动重锁都会走 attest 计划期 spec-gate（C1..C9）；夹具只有四锚会被拒锁，
#   T11a/T11b 的哈希链路与归属护栏断言本身无需改动。口径同 S23/S24；只写夹具目录、零 git 触碰。
spec_fixture_scaffold() {
  local d="$1" src="$1/spec-source.md" sha abs
  printf '%s\n' '# spec fixture source' 'alpha constraint line.' 'beta constraint line.' > "$src"
  sha="$(sha256sum "$src" | awk '{print substr($1,1,12)}')"
  abs="$(cd "$d" && pwd)"
  {
    printf '\n## 🔒 规范基线（Spec-Baseline）\n\n'
    printf '| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 | 槽 | 校验命令 | 适用S-unit | 结果 |\n'
    printf '|---|---|---|---|---|---|---|---|---|\n'
    printf '| SPEC-1 | selftest 夹具约束 | %s/spec-source.md:2 | grep -c alpha %s/spec-source.md = 1 | %s | check | grep -c alpha %s/spec-source.md | * | 待终验 |\n' "$abs" "$abs" "$sha" "$abs"
    printf '\n## ✅ 规范消费点（selftest 夹具）\nSPEC-1 在本节由 VC-1 判据点名（Rule 84.15 / C9）\n'
  } >> "$d/task_plan.md"
  printf '{"at":"2026-11-26T00:00:00Z","project_root":"%s","must":0,"ref":"selftest-fixture","candidates":[]}\n' "$abs" > "$d/.spec-scan.json"
  cat > "$d/plan-state.json" <<EOF
{"schema_version":1,"task_id":"selftest-spec-fixture","plan_tier":"mini","execution_lane":"L0-T","created_at":"2026-11-26T00:00:00Z","updated_at":"2026-11-26T00:00:00Z","requirements":[],"goals":[],"vcs":[],"phases":[],"findings":[],"audits":[],"delegations":[],"tags":[],"template_type":"mini-lite","output_examples":[{"id":"EX-1","deliverable":"task_plan.md","example":"{\"id\":1,\"name\":\"alpha\"}","template":"{\"id\":<INT>,\"name\":<STRING>}","format":"JSON","vc_refs":["VC-1"],"tags":["selftest"]}],"spec_baseline":[{"id":"SPEC-1","verbatim":"selftest 夹具约束","anchor":"$abs/spec-source.md:2","rule":"grep -c alpha $abs/spec-source.md = 1","sha":"$sha","kind":"check","check":"grep -c alpha $abs/spec-source.md","applies":"*","src":""}]}
EOF
  cat > "$d/verification.md" <<EOF
# Verification: selftest fixture

## 基线-产物逐条核验表（Rule 84.15）
| spec_id | 双向判定式 | 校验命令 | 观测 | 证据锚(path:line 或回执) | 结论 |
|---|---|---|---|---|---|
| SPEC-1 | grep -c alpha $abs/spec-source.md = 1 | grep -c alpha | 1 hit (实测) | spec-source.md:2 | PASS |
EOF
}

# T1: check-scope.sh memory 写入豁免在位 (E1)
t "T1 check-scope.sh 'memories' 豁免 ≥1" bash -c "[ \"\$(grep -c 'memories' '$SCOPE')\" -ge 1 ]"

# T2: plan-created.cjs 无 sid 兜底清除在位 (E1'/KQ1) + 保留旧文案行为注释在位
#     现行为=零残留才打印旧文案('无残留哨兵需兜底清除'), 注释行 :211 处 grep '无残留哨兵' 锚定
t "T2a plan-created.cjs '兜底清除' ≥1" bash -c "[ \"\$(grep -c '兜底清除' '$PLANCREATED')\" -ge 1 ]"
t "T2b plan-created.cjs 假成功旧文案行为注释在位 ('无残留哨兵' ≥1)" bash -c "[ \"\$(grep -c '无残留哨兵' '$PLANCREATED')\" -ge 1 ]"

# T3: zcode-posttooluse.sh 本会话自动重锁分支在位 (E2)
t "T3 zcode-posttooluse.sh 'attested_by_sid|自动重锁' ≥1" bash -c "[ \"\$(grep -c 'attested_by_sid\|自动重锁' '$POSTTOOL')\" -ge 1 ]"

# T4: attest-plan.sh attested_by_sid 字段在位 (E2)
t "T4 attest-plan.sh 'attested_by_sid' ≥1" bash -c "[ \"\$(grep -c 'attested_by_sid' '$ATTEST')\" -ge 1 ]"

# T5: zcode-userpromptsubmit.sh env sid 兜底链在位 (E3)
t "T5 zcode-userpromptsubmit.sh 'CLAUDE_CODE_SESSION_ID' ≥1" bash -c "[ \"\$(grep -c 'CLAUDE_CODE_SESSION_ID' '$UPS')\" -ge 1 ]"

# T6: check-delegation.sh observe 会话级节流 flag 在位 (E3/E4)
t "T6 check-delegation.sh 'task-planner-observe' 节流 flag ≥1" bash -c "[ \"\$(grep -c 'task-planner-observe' '$DELEG')\" -ge 1 ]"

# T7: config.json hook_self_heal_enforce 存在 + default=warn + enum 三值
#     可移植性: 有 python3 走 JSON 断言; 无 python3 降级 grep 断言 (双路径风格照抄 selftest-knowledge-brief.sh T9)
if command -v python3 >/dev/null 2>&1; then
    t "T7 config hook_self_heal_enforce=warn (python3)" python3 -c "
import json
k = json.load(open('$CONFIG'))['properties']['hook_self_heal_enforce']
assert k['default'] == 'warn'
assert set(k['enum']) == {'enforce','warn','off'}"
else
    t "T7 config hook_self_heal_enforce=warn (grep-fallback)" bash -c "
        c=\$(sed -n '/\"hook_self_heal_enforce\"/,/^[[:space:]]*}/p' '$CONFIG')
        [ \$(grep -c '\"default\" *: *\"warn\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"enforce\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"off\"' <<<\"\$c\") -ge 1 ]"
fi

# T8: SKILL.md 「环境级中断自愈」条款在位 且 行数 ≤558 (task-v073 后基线 529, 净增 ≤9; [2026-09-17 task-v079] Rule 36 联动净增 3 行,上限 538→548(B 类扩围 Decisions ⑧); [2026-09-20 task-v085] 机制画像增量 548→549; [2026-09-22 task-v087] Rule 8.1 D 类联动 551→555, 上限 552→555; [2026-09-23 task-v088] Rule 39 联动 555→558, 上限 555→558)
# [task-v171 核心瘦身] T8a 重定向：SKILL.md「环境级中断自愈」文档段随瘦身移除（该段属 hook 运行机制文档、
#   非四文件罗盘内容，CA-1 瘦身规格未列入），SKILL.md 命中=0 恒 FAIL；自愈功能本体在 hook 脚本未动
#   （posttooluse '.session-owner' 重锁×3/TAMPERED×3、userpromptsubmit 'delegation-observe' 节流×1 实测在位），
#   改断言 hook 实现锚（防自愈功能被静默删除的守护意图不变；SKILL 文档面缺失如实登记 known-gap，不粉饰）。
t "T8a hook 自愈实现锚(posttooluse session-owner 重锁 + ups delegation-observe 节流)" bash -c "[ \"\$(grep -c 'session-owner' '$POSTTOOL')\" -ge 1 ] && [ \"\$(grep -c 'delegation-observe' '$UPS')\" -ge 1 ]"
t "T8b SKILL.md 行数 ≤558" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 558 ]"

# T9: 跨文件键名一致: hook_self_heal_enforce 出现在 config.json + SKILL.md (各 ≥1, 共 ≥2 文件)
#     且无拼写变体 hook-self-heal (两文件全 0)
# T9 [task-v171 核心瘦身] 跨文件键名一致重定向：config.json schema 键 + hook 实现面无拼写变体
#   现象：原断言 'hook_self_heal_enforce 出现在 config.json+SKILL.md ≥2 文件'——SKILL.md 文档段随瘦身移除，
#     命中文件数 2→1，T9a 恒 FAIL。
#   根因：同 T8a（开关键文档载体消失；hooks 尚未消费该键——原文档明载 off 档后续轮接读取，schema 先行）。
#   修法：改断言 config.json schema 键在位 + POSTTOOL/UPS 两 hook 无连字符拼写变体（schema-实现对等语义保持）；
#     T7 已守护 schema 默认 warn+enum 三档，此处不重复。T9b（config+SKILL 负断言）不变。
t "T9a config.json schema 键在位 + hook 面无拼写变体" bash -c "[ \"\$(grep -c 'hook_self_heal_enforce' '$CONFIG')\" -ge 1 ] && [ \"\$(grep -rc 'hook-self-heal' '$POSTTOOL' '$UPS' | awk -F: '{s+=\$2} END{print s+0}')\" -eq 0 ]"
t "T9b 无拼写变体 hook-self-heal (全 0)" bash -c "[ \"\$(grep -rc 'hook-self-heal' '$CONFIG' '$SKILL' | awk -F: '{s+=\$2} END{print s+0}')\" -eq 0 ]"

# T10: 回归哨兵 (v067 机制未被本次破坏): knowledge-brief 六段 = 6 且 init '6/6' ≥1
#     [2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3）
t "T10a knowledge-brief.md 六段 grep -c '^## §' = 6（[2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3））" bash -c "[ \"\$(grep -c '^## §' '$BRIEF')\" -eq 6 ]"
t "T10b init-session.sh '6/6' ≥1" bash -c "[ \"\$(grep -c '6/6' '$INIT')\" -ge 1 ]"

# T11: [2026-09-14 task-v068 Fix-C P2-2] 行为级断言 — 现有 T1-T10 全是 grep 字符串存在性,
#      P0 类行为 bug 在其面前全绿。此处真实执行 hook 子进程(bash 子进程,非 grep 源码)。
# T11=B1 (P0-1 回归: 相对含 slash 路径自动重锁 + 归属护栏):
#   临时目录 fixture: $T/plans/task-x/task_plan.md + .session-owner="sessabc123"(canon 剥除形态,
#   与 stdin sid "sess-abc123" 剥除后一致)。基线 attest(env 剥离 ZCODE_SESSION_ID → attested_by_sid 空)。
#   相对 file_path "plans/task-x/task_plan.md" 经 posttooluse P0-1 fix-B L62 CWD 直拼归一 → 重锁命中:
#   改 task_plan.md 内容后, .plan-attestation 更新为新 sha 且 attested_by_sid=sessabc123。
#   负例: 先改内容再把 .session-owner 换成 othersid999(剥除后仍非本 sid) → 重跑同 stdin,
#   归属护栏双条件: plan_sha256 仍为旧值(哈希不更新) 且 attested_by_sid 保持基线空串
#   (posttooluse 重锁未命中 → attest 未被调用, 不产生新归属写入, 不被洗白)。
#   每断言先跑一次真实 hook 再判定, 单条内 FAIL 可定位(正/负例分离计入 Total)。
b1_pos() {
	    local T P
	    T="$(mktemp -d)" || { echo "[B1] fixture mktemp failed"; return 1; }
	    P="$T/plans/task-x"
	    mkdir -p "$P"
	    # [2026-10-05 task-v131 回归清账 Rule 45] 原行为: 夹具计划=裸 'goal' 一行, 新增 Rule 51.1
	    #   四锚 fail-closed 门先拒基线/重锁 attest → T11a/T11b FAIL。修法: 夹具补四锚最小集
	    #   (标题+R1 行+R→VC 映射+🧮 根源覆盖表, 非结果级声明带定性理由), 测试目标(自动重锁/
	    #   归属护栏防洗白)不变。后续 append 'goal v2' 仍与锚区块共存, 哈希链路断言不受影响。
	    { echo "goal"
	      printf '%s\n' \
	        '## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）' \
	        '- **R1**: 「fixture」' \
	        '### R→VC 映射' \
	        '## 🧮 根源覆盖表' \
	        '> 不适用（非结果级需求）: 单点动作夹具, 无结果级需求需全链工序审计（Rule 53.1 口径）'
	    } > "$P/task_plan.md"
	    # [2026-11-26 task-spec-consumption-chain 回归修复 C 段] b1_pos/b1_neg 同源夹具补规范基线契约：
	    #   基线 attest 与 posttooluse 重锁共用该夹具，C1..C9 新门不再拒锁；h1/h2 在补完后计算，断言零改动。
	    spec_fixture_scaffold "$P"
	    printf 'sessabc123' > "$P/.session-owner"
	    rm -f "/tmp/task-planner-hook-sessabc123.state"
	    # [2026-11-23 task-fix-all-20261123] hermetic: 同时 scrub CLAUDE_SESSION_ID，防真实会话 env 泄漏写入 attested_by_sid 导致 T11b 假 FAIL
	    env -u ZCODE_SESSION_ID -u CLAUDE_SESSION_ID bash "$ATTEST" "$P/task_plan.md" --skip-dispatch-check --skip-vc-check >/dev/null 2>&1
	    local h1
    h1="$(sha256sum "$P/task_plan.md" | awk '{print $1}')"
    # 正例: 改内容 + 相对含 slash file_path 触发 posttooluse 自动重锁
    echo "goal v2" >> "$P/task_plan.md"
    printf '{"session_id":"sess-abc123","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"plans/task-x/task_plan.md"}}' "$T" \
        | env -u ZCODE_SESSION_ID bash "$POSTTOOL" >/dev/null 2>&1
    local h2
    h2="$(sha256sum "$P/task_plan.md" | awk '{print $1}')"
    local bysid
    bysid="$(grep '^attested_by_sid=' "$P/.plan-attestation" | cut -d= -f2)"
    local stored
    stored="$(grep '^plan_sha256=' "$P/.plan-attestation" | cut -d= -f2)"
    rm -rf "$T" "/tmp/task-planner-hook-sessabc123.state"
    [ "$h1" != "$h2" ] && [ "$bysid" = "sessabc123" ] && [ "$stored" = "$h2" ]
}
t "T11a B1 正例: 相对含 slash 路径 Edit → 自动重锁(attested_by_sid=sessabc123 且 plan_sha256=新文件哈希)" \
    b1_pos
b1_neg() {
	    local T P
	    T="$(mktemp -d)" || { echo "[B1-neg] fixture mktemp failed"; return 1; }
	    P="$T/plans/task-x"
	    mkdir -p "$P"
	    # [2026-10-05 task-v131 回归清账 Rule 45] 同 b1_pos: 裸 'goal' 夹具补 Rule 51.1 四锚最小集,
	    #   基线 attest 才能落锁; 负例语义(owner 换他会话后重锁不命中, attested_by_sid 保持基线值)
	    #   不变——基线值由基线 attest 写入, 本用例断言的是「未更新/不被洗白」。
	    { echo "goal"
	      printf '%s\n' \
	        '## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）' \
	        '- **R1**: 「fixture」' \
	        '### R→VC 映射' \
	        '## 🧮 根源覆盖表' \
	        '> 不适用（非结果级需求）: 单点动作夹具, 无结果级需求需全链工序审计（Rule 53.1 口径）'
	    } > "$P/task_plan.md"
	    # [2026-11-26 task-spec-consumption-chain 回归修复 C 段] b1_pos/b1_neg 同源夹具补规范基线契约：
	    #   基线 attest 与 posttooluse 重锁共用该夹具，C1..C9 新门不再拒锁；h1/h2 在补完后计算，断言零改动。
	    spec_fixture_scaffold "$P"
	    printf 'sessabc123' > "$P/.session-owner"
	    rm -f "/tmp/task-planner-hook-sessabc123.state"
	    # [2026-11-23 task-fix-all-20261123] hermetic: 同时 scrub CLAUDE_SESSION_ID（与 b1_pos 对齐）
	    env -u ZCODE_SESSION_ID -u CLAUDE_SESSION_ID bash "$ATTEST" "$P/task_plan.md" --skip-dispatch-check --skip-vc-check >/dev/null 2>&1
	    local h1
    h1="$(sha256sum "$P/task_plan.md" | awk '{print $1}')"
    # 负例: 先改内容, 再把 owner 换成他会话 → 同 stdin 重跑, 重锁必须不命中(归属护栏, P0-1 防洗白):
    #   plan_sha256 仍为旧值(不更新) 且 attested_by_sid 被 attest 重置为空串(非 sessabc123, 不被洗白)
    echo "goal v2" >> "$P/task_plan.md"
    printf 'othersid999' > "$P/.session-owner"
    printf '{"session_id":"sess-abc123","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"plans/task-x/task_plan.md"}}' "$T" \
        | env -u ZCODE_SESSION_ID bash "$POSTTOOL" >/dev/null 2>&1
    local stored bysid
    stored="$(grep '^plan_sha256=' "$P/.plan-attestation" | cut -d= -f2)"
    bysid="$(grep '^attested_by_sid=' "$P/.plan-attestation" | cut -d= -f2)"
    rm -rf "$T" "/tmp/task-planner-hook-sessabc123.state"
    [ "$stored" = "$h1" ] && [ "$bysid" = "" ]
}
t "T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(plan_sha256 仍为旧值 且 attested_by_sid 重置为空, 不被洗白)" \
    b1_neg

# T13: [2026-09-17 task-v078-guard-fp-fixes S5 → 2026-11-24 task-perf-default-mini] 行为级断言 — 已交付计划提醒豁免
#      (zcode-posttooluse.sh 完结判定, 原 verification.md outcome 兜底分支 VC-4):
#      本仓约定 outcome 落盘在 verification.md 而非 task_plan.md, 既有 outcome 检查(L100)
#      永不命中 → 已交付计划的 compass/plan-sync 陈旧提醒误报(v076/v077 连续误报)。
#      [2026-11-24 修复判例] 原宽松 grep 'outcome: *(COMPLETE|BLOCKED)' 会命中模板
#      verification.md:118 示例行 ' outcome: COMPLETE / PARTIAL / BLOCKED'(前导空格) → 新 init 计划
#      被误判已完结、陈旧提醒从不生效。完结判定改双源: 优先 plan-state.json 的 .outcome
#      (jq test("^(COMPLETE|BLOCKED)$") 权威源), 降级才用文本行首锚 ^outcome:, 示例行不再豁免。
#      fixture: 临时计划目录 $T/plans/task-y, task_plan.md 陈旧 mtime(无 outcome 字样,
#      满足 L100 不命中 → 陈旧提醒必然触发), verification.md 保留模板前导空格示例行
#      (模拟真实形态), plan-state.json 由用例分别注入 COMPLETE / 无 outcome, 唯一 sid=ST13_SID
#      (每次运行生成, canon sess 前缀剥除后=sfx<$$><RANDOM>, 不复用 T11 的
#      sessabc123 state 文件, 跨 suite 运行互不污染)。
#      执行手法照 T11a/b: stdin JSON(绝对 file_path → L62 case /* 不动, 与 T11 的相对
#      file_path 无关联) + env -u ZCODE_SESSION_ID。
#      T13a 正例(权威源豁免生效): plan-state.json.outcome=COMPLETE → 执行输出不含
#        plan-compass/plan-sync 提醒(权威源 jq 主路径早退, 模板示例行不再参与豁免)
#      T13b 因果对照: 同 fixture 但 plan-state.json 无 outcome → 输出含 plan-sync
#        陈旧提醒(证明模板示例行不再误判豁免; 与 T13a 同走 jq 主路径, 非降级分支巧合)
#      维护注记: sid 每次运行唯一(ST13_SID 含 $$/${RANDOM}; 见下方套件级变量), 保证同一次
#      suite 内 T13a/T13b 共用同一 sid(因果对照有效)且跨 suite 运行互不污染; 若用固定 sid,
#      hook 的 state 文件(/tmp/task-planner-hook-sfx12345.state)持久化, 重跑会落入 plan-sync
#      冷却窗口(cd_left≠0)不再提醒 → T13b 非密闭 FAIL(首跑 PASS/重跑必 FAIL, 主进程复跑实证)。
#      [2026-11-24] T13a 权威源早退发生在 /tmp state 写入(plan-sync 分支)之前, 共用 sid 下
#      T13b 的 cd_left 仍为 0, 因果对照密闭; 勿把夹具改回「T13a 触发提醒」形态。
st13_fixture() { # st13_fixture <tmpdir> <plan-state.json 内容>: 写陈旧 task_plan.md + 模板形态 verification.md + 完结判定权威源 plan-state.json
    local T="$1" state="$2" P
    P="$T/plans/task-y"
    mkdir -p "$P"
    echo "goal" > "$P/task_plan.md"
    printf ' outcome: COMPLETE / PARTIAL / BLOCKED\n' > "$P/verification.md"
    printf '%s\n' "$state" > "$P/plan-state.json"
    touch -d "2 hours ago" "$P/task_plan.md" "$P/verification.md" "$P/plan-state.json"
}
ST13_SID="sfx${$}${RANDOM}"   # T13 套件级唯一 sid(每次 suite 运行生成一次, T13a/T13b 共用)
st13_exec() { # st13_exec <tmpdir>: 照 T11a/b 手法执行 POSTTOOL hook(唯一 sid=ST13_SID), 输出到 stdout
    local T="$1" out
    out="$(printf '{"session_id":"sess-'${ST13_SID}'","cwd":"%s","tool_name":"Bash","tool_input":{"file_path":"plans/task-y/task_plan.md"}}' "$T" \
        | env -u ZCODE_SESSION_ID bash "$POSTTOOL" 2>/dev/null)"
    printf '%s' "$out"
}
st13_pos() {
    local T
    T="$(mktemp -d)" || { echo "[T13a] fixture mktemp failed"; return 1; }
    st13_fixture "$T" '{"task_id":"task-y","plan_tier":"mini","outcome":"COMPLETE"}'
    local out
    out="$(st13_exec "$T")"
    rm -rf "$T" "/tmp/task-planner-hook-${ST13_SID}.state"
    # 权威源豁免: plan-state.json.outcome=COMPLETE 命中 jq 双源主路径 → exit 0, 无任何 plan 提醒输出
    [ -z "$out" ]
}
t "T13a S5 正例: 陈旧计划+plan-state.json.outcome=COMPLETE(模板示例行在位) → POSTTOOL 输出无 plan-compass/plan-sync 提醒(权威源豁免生效)" \
    st13_pos
st13_neg() {
    local T
    T="$(mktemp -d)" || { echo "[T13b] fixture mktemp failed"; return 1; }
    st13_fixture "$T" '{"task_id":"task-y","plan_tier":"mini"}'
    local out
    out="$(st13_exec "$T")"
    rm -rf "$T" "/tmp/task-planner-hook-${ST13_SID}.state"
    # 对照因果: 同走 jq 主路径但 outcome 缺失 → 模板前导空格示例行不构成豁免 → 陈旧提醒必然触发
    case "$out" in
        *plan-compass*|*plan-sync*) return 0 ;;
        *) echo "[T13b-diag] plan-state.json 无 outcome 时未触发陈旧提醒, 实际输出='$out'"; return 1 ;;
    esac
}
t "T13b S5 因果对照: 同夹具但 plan-state.json 无 outcome(模板示例行在位) → 输出含 plan-compass/plan-sync 陈旧提醒(示例行不再误判豁免)" \
    st13_neg
rm -f "/tmp/task-planner-hook-${ST13_SID}.state"   # 清理 T13 两个用例的 state 文件(sid=ST13_SID, 每次运行唯一)

# T12: [2026-09-14 task-v068 Fix-C P2-2] B2 (P0-2 回归: 跨脚本 canon 一致性) —
#   三侧 sid 规范化必须逐字节一致(pretooluse L17 / UPS L34 / 复刻管道), 否则 sid 含连字符等
#   真实值时 owner 写/读/比较三方失配。行为式断言: 同一 sid 样本过三条管道, 输出两两相等;
#   任一侧不一致 FAIL, 诊断时输出三侧实际值(本断言自带 echo, 不复用 t() 的静默输出)。
b2_canon() {
    local SID="sess-abc123"
    # 三侧 sid 规范化管道, 逐字节一致性断言:
    #   A: 复刻 zcode-pretooluse.sh L17 同款管道 (jq -r '.session_id // empty' | tr -cd 'a-zA-Z0-9' | head -c 40)
    #   B: 复刻 zcode-userpromptsubmit.sh L34 同款管道 (stdin sid 直入 tr -cd 'a-zA-Z0-9' | head -c 40)
    #   C: 全链路 (JSON stdin → jq 提取 → 剥除), 等价 pretooluse L17 完整输入路径
    local A B C
    A="$(printf '{"session_id":"%s"}' "$SID" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
    B="$(printf '%s' "$SID" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    C="$(printf '{"session_id":"%s"}' "$SID" | bash -c "jq -r '.session_id // empty' | tr -cd 'a-zA-Z0-9' | head -c 40" 2>/dev/null)"
    if [ -n "$A" ] && [ "$A" = "$B" ] && [ "$A" = "$C" ]; then
        return 0
    fi
    echo "[B2-diag] pretooluse L17=$A UPS L34=$B jq-full-chain=$C"
    return 1
}
if b2_canon >/dev/null 2>&1; then
    PASS=$((PASS+1)); echo "[PASS] T12 B2 三侧 canon 一致 (pretooluse L17 / UPS L34 / jq 全链路, sid=sess-abc123)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] T12 B2 三侧 canon 一致 (sid=sess-abc123)"
    b2_canon   # 诊断: 输出两侧实际值
fi

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
