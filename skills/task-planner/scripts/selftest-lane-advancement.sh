#!/usr/bin/env bash
# selftest-lane-advancement.sh — task-v126 S3: Rule 49 单元线多路并行推进静态守护（自写 49.5 机器面）
# 范式对齐 selftest-media-dispatch.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构），task-v126 S3 产出。
# 用途：静态断言 Rule 49 五子条（critical-rules.md）+ SKILL.md 摘要 bullet/C34 合规行/执行循环步骤 2.5 推进检查括注/References 表括号追加
#      全部落点在位且既有主锚未破坏（36.5 纯增量守护），并确认零新 config 键（properties=40，与 43.4/44.4/47.4 同口径）。
# 输入：task-planner/references/critical-rules.md、task-planner/SKILL.md、task-planner/config.json（只读，grep/jq，零写入）。
# 输出：LA-01..LA-14 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 LA-14 打 SKIPPED 不 FAIL，
#      与 selftest-media-dispatch.sh MD-08 / reliability-institution R-12 先例一致）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 SKIPPED，fail-open 非静默——打印提示行）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'LA-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'LA-%s FAIL %s\n' "$1" "$2"; }

# LA-01 Rule 49 五子条锚 `grep -c '^49\.'` ≥5
# What：断言 49.1-49.5 五条子条主体行（行首 '49.N'）在位。
# Why：锁 Rule 49 条款本体未被裁剪/重排——子条是 49.1 适用模型/49.2 推进三条件/49.3 推进登记/49.4 不干扰边界/49.5 机制层的唯一文本落点，
#      缺任一子条 = 单元线推进纪律条款失守（防后续任务改写 critical-rules.md 时误删 49.x 段）。
n="$(grep -c '^49\.' "$CRIT" || true)"
if [ "$n" -ge 5 ]; then ok 01 "critical-rules.md Rule 49 子条锚 $n ≥5"; else bad 01 "critical-rules.md Rule 49 子条数 $n（应 ≥5）"; fi

# LA-02 Rule 49 标题锚 `grep -q '^### 49 '`
# What：断言 '### 49 ' 章节标题行在位。
# Why：标题行是 44/45/46/47 范式（章节标题+子条）的识别锚——丢了标题，Rule 49 会退化为无主条款（防章节误删/标题降级为普通段落）。
if grep -q '^### 49 ' "$CRIT"; then
  ok 02 "critical-rules.md Rule 49 标题锚在位"
else
  bad 02 "critical-rules.md Rule 49 标题锚缺失（### 49 未命中）"
fi

# LA-03 Rule 49.2 核心语义锚 `grep -q '推进三条件'`
# What：断言「推进三条件」判定语义在 critical-rules.md 在位。
# Why：49.2 是本条的心脏（已验收+前置在位+互不干扰三证据全满足才派发下一工序）——语义锚缺失 = 推进判定标准被裁剪（防 49.2 降格为无判定泛文）。
if grep -q '推进三条件' "$CRIT"; then
  ok 03 "critical-rules.md「推进三条件」语义锚在位"
else
  bad 03 "critical-rules.md「推进三条件」缺失（49.2 核心判定语义失守）"
fi

# LA-04 Rule 49.3 推进合法性锚 `grep -q '跨 Phase 前移合法'`
# What：断言「跨 Phase 前移合法」推进合法性落点在 critical-rules.md 在位。
# Why：跨 Phase 前移是 Rule 49 相对 21.4（仅批次内空间并行）的独有增量语义（已验收单元不等批），缺失 = 49 与 21.4 语义回退重合（防条款价值被稀释）。
if grep -q '跨 Phase 前移合法' "$CRIT"; then
  ok 04 "critical-rules.md「跨 Phase 前移合法」语义锚在位"
else
  bad 04 "critical-rules.md「跨 Phase 前移合法」缺失（49.3 推进合法性落点失守）"
fi

# LA-05 progress 前移登记锚 `grep -qF '[advance]'`
# What：断言「[advance] 登记行格式」在 49.3 条款内声明在位（固定字符串匹配，防方括号被当正则）。
# Why：49.3 双登记的第二腿是 progress.md 追加 [advance] 行（无 Lane 表任务唯一登记面）——格式未在条款内声明 = 登记行为失去权威源锚定（防 49.3 登记语义被裁剪）。
if grep -qF '[advance]' "$CRIT"; then
  ok 05 "critical-rules.md「[advance]」登记锚在位"
else
  bad 05 "critical-rules.md「[advance]」登记锚缺失（49.3 progress 登记行格式失守）"
fi

# LA-06 不干扰边界锚 `grep -q '汇合点强串行'`
# What：断言「汇合点强串行」边界条款第一条在 critical-rules.md 在位。
# Why：49.4① 是多路推进的安全阀（消费多单元线产物的工序必须等齐上游）——缺失 = 推进纪律失去最强约束（防 49.4 负向清单被裁剪成纯声明）。
if grep -q '汇合点强串行' "$CRIT"; then
  ok 06 "critical-rules.md「汇合点强串行」边界锚在位"
else
  bad 06 "critical-rules.md「汇合点强串行」缺失（49.4 不干扰边界第一条失守）"
fi

# LA-07 门控不弱化承诺锚 `grep -q 'Phase complete 翻转语义不变'`
# What：断言「Phase complete 翻转语义不变」门控承诺文本在 critical-rules.md 在位。
# Why：Rule 49 只加推进层、不弱化既有 Phase 终态门控（3-File Gate/19.2）——该承诺文本缺失 = 推进语义可能被误读为门控放行（防 49.3 尾段语义漂移）。
if grep -q 'Phase complete 翻转语义不变' "$CRIT"; then
  ok 07 "critical-rules.md「Phase complete 翻转语义不变」门控锚在位"
else
  bad 07 "critical-rules.md「Phase complete 翻转语义不变」缺失（门控不弱化承诺失守）"
fi

# LA-08 SKILL.md 摘要 bullet 锚 `grep -q 'Rule 49（单元线多路并行推进'`
# What：断言 SKILL.md Critical Rules 摘要段含 Rule 49 bullet。
# Why：摘要是 SKILL.md 内 Rule 49 的入口索引（LLM 读 SKILL.md 时先见摘要后查 critical-rules.md）——丢 bullet = 摘要与条款脱钩
#      （防"条款扩到 49 但摘要停摆 48"的级联断链；v121 1-4[5-9] 预扩位追加 49 名不触发）。
if grep -q 'Rule 49（单元线多路并行推进' "$SKILLMD"; then
  ok 08 "SKILL.md Rule 49 摘要 bullet 在位"
else
  bad 08 "SKILL.md Rule 49 摘要 bullet 缺失（Critical Rules 列表未联动）"
fi

# LA-09 SKILL.md 合规清单行锚 `grep -q '^| C34 |'`
# What：断言合规清单 C34 行（行首 '| C34 |'）在位。
# Why：C34 是 Rule 49 的合规清单消费点（多单元线任务跨 Phase 前移必须过推进三条件并双登记）——丢 C34 行 = 合规检查面与条款脱钩（防 C33 后行被误删）。
if grep -q '^| C34 |' "$SKILLMD"; then
  ok 09 "SKILL.md 合规清单 C34 行在位"
else
  bad 09 "SKILL.md 合规清单 C34 行缺失（Rule 49 消费点未联动）"
fi

# LA-10 SKILL.md 执行循环锚 `grep -q '验收后推进检查（Rule 49）'`
# What：断言执行循环步骤 2.5 行尾括注「验收后推进检查（Rule 49）」在位。
# Why：步骤 2.5 是委派检查点的执行落点（每 S-unit 验收后立即核对推进三条件、满足即派发不等批）——括注缺失 = 推进检查失去执行循环入口（防步骤 2.5 行被重构裁掉括注）。
if grep -q '验收后推进检查（Rule 49）' "$SKILLMD"; then
  ok 10 "SKILL.md 执行循环步骤 2.5 推进检查括注在位"
else
  bad 10 "SKILL.md「验收后推进检查（Rule 49）」缺失（执行循环入口失守）"
fi

# LA-11 SKILL.md References 表括号追加锚 `grep -q 'Rule 49 单元线多路并行推进）'`
# What：断言 References 表 critical-rules.md 行的括号追加「/ Rule 49 单元线多路并行推进）」在位。
# Why：References 表是 SKILL.md 引用面索引——括号追加缺失 = 文档表与条款脱钩（防 References 行重写时 49 名被丢；以追加尾字符「）」为锚锁括号完整闭合）。
if grep -q 'Rule 49 单元线多路并行推进）' "$SKILLMD"; then
  ok 11 "SKILL.md References 表 Rule 49 括号追加在位"
else
  bad 11 "SKILL.md References 表「Rule 49 单元线多路并行推进）」缺失（文档表未联动）"
fi

# LA-12 SKILL.md 主锚守护 `grep -c 'Rules 1-39'` =2
# What：断言 SKILL.md 内 `Rules 1-39` 字面命中数保持 2（SR-07 既有锚，v126 不动主锚的承诺）。
# Why：主锚字面是 selftest-self-resolution.sh SR-07 的断言对象——v126 全部联动采用"追加/括注"而非"改写"范式，主锚计数变动 = 有人动了 Rules 1-39 字面
#      或误写 1-40 变体（防误改破坏 SR-07 自守护；与 baseline 2 严格等值，非 ≥）。
n="$(grep -c 'Rules 1-39' "$SKILLMD" || true)"
if [ "$n" -eq 2 ]; then ok 12 "SKILL.md 主锚 'Rules 1-39' 命中 =2（SR-07 不变）"; else bad 12 "SKILL.md 主锚 'Rules 1-39' 命中=$n（应 =2，SR-07 主锚被改动）"; fi

# LA-13 SKILL.md 负断言 `grep -c '1-40'` =0
# What：断言 SKILL.md 内 `1-40` 字面命中数为 0（与 SR-07 同口径负断言）。
# Why：`1-40` 是 Rule 40 时代扩号的主锚变体——若出现说明主锚被半改（1-39→1-40 或 1-49→1-40 笔误）产生双主锚漂移；=0 保证 Rules 主锚字面唯一（防扩号回退/笔误）。
n="$(grep -c '1-40' "$SKILLMD" || true)"
if [ "$n" -eq 0 ]; then ok 13 "SKILL.md '1-40' 变体命中 0（负断言成立）"; else bad 13 "SKILL.md '1-40' 变体命中=$n（应 =0，主锚漂移）"; fi

# LA-14 零新 config 键——properties 键数 = 40（同 43.4/44.4/47.4 口径；jq 缺失打 SKIPPED 不 FAIL）
# What：断言 config.json .properties 顶层键数保持 40（Rule 49 判定面纯 LLM 行为 + 静态守护，零机器触发面，故不得新增 config 键）。
# Why：49.5 承诺"零新 config 键"——键数膨胀 = 有人给单元线推进加了机器门控键，突破 43.4/44.4/47.4 既定零新键范式，属机制漂移（需走 36 条款流程）。
#      jq 缺失 fail-open 打 SKIPPED（沿用 MD-08/R-12 先例：无 jq 属环境降级非内容漂移，不误报 FAIL；打印提示行非静默）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq '.properties | length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 14 "config.json properties 键数 40（零新增）"; else bad 14 "config.json properties 键数=$keys（应 40，Rule 49 零新键被破坏）"; fi
else
  printf 'LA-14 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
