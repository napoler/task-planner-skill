#!/usr/bin/env bash
# selftest-media-dispatch.sh — task-v122 S4: Rule 47 媒体制作任务派发纪律静态守护（自写 Rule 47.4 机器面）
# 范式对齐 selftest-reliability-institution.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构）。
# 用途：静态断言 Rule 47 四子条（critical-rules.md）+ SKILL.md 路由表媒体行/摘要 bullet + template-mapping.md §九兜底注/§十特化行
#      全部在位且既有锚未破坏（Rule 36.5 纯增量守护），并确认零新 config 键（properties=42 [2026-10-08 task-v144 合并级联: v145 新增 2 键(config=42),FF 守护 42 为准,旧定数 40→42]，与 43.4/44.4 同口径）。
# 输入：task-planner/references/critical-rules.md、task-planner/SKILL.md、task-planner/config.json、
#      ../plan-template-kit/references/template-mapping.md（只读，grep/jq，零写入）。
# 输出：MD-01..MD-09 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 MD-08 打 SKIPPED 不 FAIL，
#      与 selftest-reliability-institution.sh R-12 先例一致）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 SKIPPED，fail-open 非静默——打印提示行）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# [task-v171 回归修复 2026-10-12 规则分层搬迁] Rule 47 归属 media-planner(CRIT_M)、Rule 21.1b 归属 task-dispatch(CRIT_DP)；
#   MD-03/04/05 旧 SKILL.md 子代理路由表三行随 S33 瘦身移除, 分别改指:
#   MD-03→新 SKILL.md 卫星路由表 media-planner 行; MD-04→media-planner SKILL.md 具名执行体路由段;
#   MD-05→新 SKILL.md 卫星路由表 media-planner 域名+Rule 47 列(摘要 bullet 入口职能由卫星路由行承接)
CRIT_M="$SKILL_ROOT/../media-planner/references/critical-rules-media.md"
CRIT_DP="$SKILL_ROOT/../task-dispatch/references/critical-rules-dispatch.md"
MP_SKILL="$SKILL_ROOT/../media-planner/SKILL.md"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TMAP="$SKILL_ROOT/../plan-template-kit/references/template-mapping.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'MD-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'MD-%s FAIL %s\n' "$1" "$2"; }

# MD-01 Rule 47 四子条锚 `grep -c '^47\.'` ≥ 4（[task-v171 2026-10-12] Rule 47 归属 media-planner）
# What：断言 critical-rules-media.md 47.1-47.4 四条子条主体行（行首 '47.N'）在位。
# Why：锁 Rule 47 条款本体未被裁剪/重排——子条是 47.1 拆分轴/47.2 具名路由/47.3 试点先行/47.4 机制层的唯一文本落点，
#      缺任一子条 = 媒体派发纪律条款失守（防 drift：后续任务改写 critical-rules-media.md 时误删 47.x 段）。
n="$(grep -c '^47\.' "$CRIT_M" || true)"
if [ "$n" -ge 4 ]; then ok 01 "critical-rules-media.md Rule 47 子条锚 $n ≥4"; else bad 01 "critical-rules-media.md Rule 47 子条数 $n（应 ≥4）"; fi

# MD-02 Rule 47 标题锚 `grep -q '^### 47 '`（[task-v171 2026-10-12] 目标同迁 CRIT_M）
# What：断言 '### 47 ' 章节标题行在位。
# Why：标题行是 44/45/46 范式（章节标题+子条）的识别锚——丢了标题，Rule 47 会退化为无主条款（防章节误删/标题降级为普通段落）。
if grep -q '^### 47 ' "$CRIT_M"; then
  ok 02 "critical-rules-media.md Rule 47 标题锚在位"
else
  bad 02 "critical-rules-media.md Rule 47 标题锚缺失（### 47 未命中）"
fi

# MD-03 SKILL.md 卫星路由表 media-planner 行 ≥1
# What：断言 SKILL.md 卫星路由表含 media-planner 行（媒体轴拆分与执行体路由调用条件）。
# Why：该行是 47 媒体派发在新架构的总入口——S33 后旧「子代理路由表媒体行」由卫星路由表承接，行丢=媒体任务
#      路由回退到 general-purpose 兜底（防"路由重构时媒体入口被当冗余删除"的漂移）。
n="$(grep -c '视频/图片/剧集创作媒体轴拆分与执行体路由' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 03 "SKILL.md 卫星路由表 media-planner 行 $n ≥1"; else bad 03 "SKILL.md 卫星路由表 media-planner 行缺失（命中 $n 应 ≥1）"; fi

# MD-04 media-planner SKILL.md 具名执行体路由段 ≥1
# What：断言 media-planner SKILL.md 卫星路由段含「具名执行体路由」措辞。
# Why：47.2 具名执行体路由（executor+工序模板 SOP+生成技能）的权威展开面随 Rule 47 落卫星 media-planner——
#      该段是被删即 47.2 消费面失守（防"卫星瘦身时路由段落被裁"的漂移）。
n="$(grep -c '具名执行体路由' "$MP_SKILL" || true)"
if [ "$n" -ge 1 ]; then ok 04 "media-planner SKILL.md 具名执行体路由段 $n ≥1"; else bad 04 "media-planner SKILL.md 具名执行体路由段缺失（命中 $n 应 ≥1）"; fi

# MD-05 SKILL.md 卫星路由表 media-planner 域名+Rule 47 列 ≥1
# What：断言 SKILL.md 卫星路由表 media-planner 行的域名列与规则列（含 Rule 47）在位。
# Why：旧「Critical Rules 摘要 bullet Rule 47」是 SKILL.md 内 Rule 47 的入口索引——S33 后该职能由卫星路由表
#      行承接（域名+规则编号列），丢 bullet 不丢入口：行或规则列缺失=摘要与条款脱钩（防级联断链）。
n="$(grep -c 'media-planner | 媒体制作任务派发' "$SKILLMD" || true)"
n47="$(grep -c 'Rule 47,49,50' "$SKILLMD" || true)"
if [ "$n" -ge 1 ] && [ "$n47" -ge 1 ]; then ok 05 "SKILL.md 卫星路由 media-planner 行 $n ≥1 且规则列含 Rule 47 ($n47)"; else bad 05 "SKILL.md 卫星路由 media-planner 行缺失（行=$n 规则列=$n47，应各 ≥1）"; fi

# MD-06 template-mapping.md §九兜底注锚「Rule 47.2」≥1
# What：断言画像矩阵 §九兜底注（路由组列项目专属资产缺位时的通用兜底路由注）在位。
# Why：该注是 47.2「资产缺位→executor(sonnet-1)+工序模板 SOP+生成技能」兜底路由的画像层落点（防画像层与派发层脱节再发——
#      Rule 47 归因根因即"画像有类型、路由无行"；删注 = 兜底路由失去权威源锚定）。
n="$(grep -c 'Rule 47.2' "$TMAP" || true)"
if [ "$n" -ge 1 ]; then ok 06 "template-mapping.md §九兜底注「Rule 47.2」$n ≥1"; else bad 06 "template-mapping.md 兜底注缺失（Rule 47.2 命中 $n 应 ≥1）"; fi

# MD-07 template-mapping.md §十特化行锚「媒体制作族」≥1
# What：断言 §十机制矩阵含「媒体制作族」特化行（自内容组拆出）。
# Why：§十矩阵是机制组→并行/串行/验证面的权威映射；特化行缺失 = 媒体任务回落到内容组泛行，47.1 并行面声明（同参批量可组并行）失去消费面
#      （防矩阵重构时特化行被合并回内容组而丢失纪律锚）。
n="$(grep -c '媒体制作族' "$TMAP" || true)"
if [ "$n" -ge 1 ]; then ok 07 "template-mapping.md §十「媒体制作族」特化行 $n ≥1"; else bad 07 "template-mapping.md「媒体制作族」特化行缺失（命中 $n 应 ≥1）"; fi

# MD-08 零新 config 键——properties 键数 = 42（同 reliability-institution R-12 口径；jq 缺失打 SKIPPED 不 FAIL）
# [2026-10-08 task-v144 合并级联: v145 新增 2 键(config=42),FF 守护 42 为准,旧定数 40→42]
# What：断言 config.json .properties 顶层键数保持 42（Rule 47 判定面纯 LLM 行为 + 静态守护，零机器触发面，故不得新增 config 键）。
# Why：47.4 承诺"零新 config 键"——键数膨胀 = 有人给媒体派发加了机器门控键，突破 43.4/44.4 既定零新键范式，属机制漂移（需走 36 条款流程）。
#      jq 缺失 fail-open 打 SKIPPED（沿用 R-12 先例：无 jq 属环境降级非内容漂移，不误报 FAIL）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "42" ]; then ok 08 "config.json properties 键数 42（零新增）"; else bad 08 "config.json properties 键数=$keys（应 42，Rule 47 零新键被破坏）"; fi
else
  printf 'MD-08 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

# MD-09 既有锚守护：critical-rules-dispatch.md '^21\.1b' 在位 + SKILL.md '代码编辑隔离' ≥1
# What：双锚并存断言——21.1b（拆分轴条款，task-dispatch 域）行在位，且 SKILL.md 既有「代码编辑隔离」路由入口未被删。
# Why：Rule 47 是 36.5 纯增量（衔接 21.1b 原文零改动），本断言把"增量不破坏存量"机器化——防后续改写 Rule 21.1b 拆分轴
#      或路由删既有入口的非对称修改（只新增媒体行/删旧行 = 路由面失守）。
a="$(grep -c '^21\.1b' "$CRIT_DP" || true)"
b="$(grep -c '代码编辑隔离' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 09 "既有锚守护 21.1b=$a ≥1(dispatch) 且 SKILL.md 代码编辑隔离行 $b ≥1"; else bad 09 "既有锚漂移（critical-rules-dispatch 21.1b=$a 应 ≥1 / SKILL.md 代码编辑隔离行=$b 应 ≥1）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
