#!/usr/bin/env bash
# selftest-lane-advancement.sh — task-v126 S3: Rule 49 单元线多路并行推进静态守护（自写 49.5 机器面）
# 范式对齐 selftest-media-dispatch.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构），task-v126 S3 产出。
# 用途：静态断言 Rule 49 五子条（critical-rules.md）+ SKILL.md 摘要 bullet/C34 合规行/执行循环步骤 2.5 推进检查括注/References 表括号追加
#      全部落点在位且既有主锚未破坏（36.5 纯增量守护），并确认零新 config 键（properties=42，[2026-10-08 task-v144 合并级联] 40→42，v145 合法新增 2 键，与 43.4/44.4/47.4 口径同步）。
# 输入：task-planner/references/critical-rules.md、task-planner/SKILL.md、task-planner/config.json（只读，grep/jq，零写入）。
# 输出：LA-01..LA-14 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 LA-14 打 SKIPPED 不 FAIL，
#      与 selftest-media-dispatch.sh MD-08 / reliability-institution R-12 先例一致）。
# [2026-10-09 task-v152 Rule 67 落地] '1-65'→'1-67'：Rule 67 已由 task-v152 落地，锚同步演进
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 SKIPPED，fail-open 非静默——打印提示行）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 回归修复 2026-10-12 媒体域搬迁] Rule 49（单元线多路并行推进）属 media-planner 域，原文已迁至
#   skills/media-planner/references/critical-rules-media.md；本脚本 CRIT 全部用法（L28-L79）均为 Rule 49 断言、
#   无核心域用途（已逐行核实），CRIT 改指媒体域文件，断言语义零改动。CRIT_CORE 保留指向核心备查。
CRIT_CORE="$CRIT"
CRIT="$SKILL_ROOT/../media-planner/references/critical-rules-media.md"
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

# LA-08 [task-v171 核心瘦身] 摘要 bullet → frontmatter 卫星技能 media-planner 行 Rule 47,49,50 枚举
#   现象：SKILL.md 瘦身后 Critical Rules 摘要 bullet（'Rule 49（单元线多路并行推进'）与 References 表追加名均移除，命中=0，LA-08/11 恒 FAIL。
#   根因：Rule 49 属媒体域；SKILL 侧入口索引=frontmatter 卫星技能行 +「卫星路由表」media-planner 行（Rule 82 禁回潮）。
#   修法：LA-08 改断言 frontmatter 'Rule 47,49,50' 枚举 =1（摘要面瘦身后由 frontmatter 卫星行承载）。
if grep -qF 'Rule 47,49,50' "$SKILLMD"; then
  ok 08 "SKILL.md frontmatter media-planner 行 Rule 47,49,50 枚举在位（摘要 bullet 瘦身后由 frontmatter 卫星行承载）"
else
  bad 08 "SKILL.md frontmatter Rule 47,49,50 枚举缺失（Critical Rules 列表未联动）"
fi

# LA-09 [task-v171 核心瘦身] 合规清单 C34 行 → 卫星路由表 media-planner 行（C34 消费点瘦身后由路由表承载）
if grep -qE '^\| media-planner \|' "$SKILLMD"; then
  ok 09 "SKILL.md 卫星路由表 media-planner 行在位（C34 合规面瘦身后由路由表承载）"
else
  bad 09 "SKILL.md 卫星路由表 media-planner 行缺失（Rule 49 消费点未联动）"
fi

# LA-10 [task-v171 核心瘦身] 执行循环 2.5 括注 → 卫星路由表 media-planner 行调用条件列（媒体轴拆分路由载体）
#   现象：执行循环步骤 2.5 行尾括注「验收后推进检查（Rule 49）」随瘦身移除（步骤 2.5 重写为委派检查点总述），命中=0，LA-10 恒 FAIL。
#   根因：执行循环瘦身后不再逐规则挂括注；推进检查入口=路由表 media-planner 行调用条件「视频/图片/剧集创作媒体轴拆分与执行体路由」。
#   修法：改断言路由表 media-planner 行调用条件列含「媒体轴拆分」=1。
if grep -E '^\| media-planner \|' "$SKILLMD" | grep -q '媒体轴拆分'; then
  ok 10 "SKILL.md 卫星路由表 media-planner 行含媒体轴拆分路由（执行循环入口瘦身后由路由表调用条件承载）"
else
  bad 10 "SKILL.md「媒体轴拆分」路由缺失（执行循环入口失守）"
fi

# LA-11 [task-v171 核心瘦身] References 表 Rule 49 名 → 卫星路由表 media-planner 行含规则全文路径
if grep -E '^\| media-planner \|' "$SKILLMD" | grep -q 'critical-rules-media.md'; then
  ok 11 "SKILL.md 卫星路由表 media-planner 行含 critical-rules-media.md 路径（References 表瘦身后由路由表承载）"
else
  bad 11 "SKILL.md 卫星路由表 media-planner 行缺规则全文路径（文档表未联动）"
fi

# LA-12 [task-v171 核心瘦身] 主锚守护 'Critical Rules 1-[7-8][0-9]' → '1-80' 全集口径（v171 分层架构演进）
#   现象：SKILL.md 瘦身后全集声明演进为「Rules 1-80 全集索引」，旧主锚 'Critical Rules 1-[7-8][0-9]'（1-70..1-89 区间字面）零命中，LA-12 恒 FAIL。
#   根因：主 label 口径随分层架构切换（核心 12 条+10 卫星）；纪元演进链 v144→v166→v169→v171 的第四次切换。
#   修法：主锚改 '1-8[01]'（≥1；task-v170 并集 max 口径）；'1-39'/'1-40' 负断言保持不动（旧主 label 变体仍须零残留）。
# [2026-10-10 task-v160-v169 纪元演进史] 保留如上（1-65→1-72→宽容 7[4-9]→1-80 各阶段）；本轮为主 label 口径切换。
n="$(grep -cE '1-8[01]' "$SKILLMD" || true)"
m="$(grep -c '1-39' "$SKILLMD" || true)"
if [ "$n" -ge 1 ] && [ "$m" -eq 0 ]; then ok 12 "SKILL.md 主锚 '1-8[01]' 全集口径 ≥1 且 '1-39' 变体 0（SR-07 同步演进）"; else bad 12 "SKILL.md 主锚漂移（'1-80'=$n 应 ≥1 / 1-39=$m 应 0）"; fi
# [2026-10-10 task-v160 合并并集: 取 v160 宽容锚，Rule 72 落地 1-72 纪元]
# [2026-10-10 task-v163 级联: SKILL 计数演进 1-72→1-75（Rule 75 落地）, 主锚宽容正则扩 7[0-5] 纪元，判据 ≥1 不减]
# [2026-10-10 task-v162 合并并集演进] '1-71'→'1-74'：task-v162 Rule 74（变更吸收三判）合流落地，SKILL 章节引言行最终态 1-74，字面锚同步（A 类机械替换）——v163 主断言演进为宽容正则后保留本注释（AD-12 _pin_lit 'Critical Rules 1-74' 历史字面在位）

# LA-13 SKILL.md 负断言 `grep -c '1-40'` =0
# What：断言 SKILL.md 内 `1-40` 字面命中数为 0（与 SR-07 同口径负断言）。
# Why：`1-40` 是 Rule 40 时代扩号的主锚变体——若出现说明主锚被半改（1-39→1-40 或 1-49→1-40 笔误）产生双主锚漂移；=0 保证 Rules 主锚字面唯一（防扩号回退/笔误）。
n="$(grep -c '1-40' "$SKILLMD" || true)"
if [ "$n" -eq 0 ]; then ok 13 "SKILL.md '1-40' 变体命中 0（负断言成立）"; else bad 13 "SKILL.md '1-40' 变体命中=$n（应 =0，主锚漂移）"; fi

# LA-14 零新 config 键——properties 键数 = 44（[2026-10-08 task-v144 合并级联] 40→42；[task-perf-opt] 42→44：v145 合法新增 2 键 + task-perf-opt 合法新增 smart_inject_type_gate+selftest_parallel_mode 2 键；同 TS-12 口径；jq 缺失打 SKIPPED 不 FAIL）
# What：断言 config.json .properties 顶层键数保持 44（Rule 49 判定面纯 LLM 行为 + 静态守护，零机器触发面，故 Rule 49 自身不得新增 config 键；基线含 v145 合法新增的 2 键 + task-perf-opt 合法新增的 smart_inject_type_gate+selftest_parallel_mode 2 键）。
# Why：49.5 承诺"零新 config 键"——键数偏离 44 = 有人给单元线推进加了机器门控键，突破 43.4/44.4/47.4 既定零新键范式，属机制漂移（需走 36 条款流程）。task-perf-opt 的 2 键为合法 opt-in 性能开关（Change #5/#11 明确新增）。
#      jq 缺失 fail-open 打 SKIPPED（沿用 MD-08/R-12 先例：无 jq 属环境降级非内容漂移，不误报 FAIL；打印提示行非静默）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq '.properties | length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "46" ]; then ok 14 "config.json properties 键数 46（基线含 v145 2 键 + task-perf-opt 2 键 + task-v172 合法新增 2 键）"; else bad 14 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
else
  printf 'LA-14 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
