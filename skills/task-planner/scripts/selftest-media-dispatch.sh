#!/usr/bin/env bash
# selftest-media-dispatch.sh — task-v122 S4: Rule 47 媒体制作任务派发纪律静态守护（自写 Rule 47.4 机器面）
# 范式对齐 selftest-reliability-institution.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构）。
# 用途：静态断言 Rule 47 四子条（critical-rules.md）+ SKILL.md 路由表媒体行/摘要 bullet + template-mapping.md §九兜底注/§十特化行
#      全部在位且既有锚未破坏（Rule 36.5 纯增量守护），并确认零新 config 键（properties=40，与 43.4/44.4 同口径）。
# 输入：task-planner/references/critical-rules.md、task-planner/SKILL.md、task-planner/config.json、
#      ../plan-template-kit/references/template-mapping.md（只读，grep/jq，零写入）。
# 输出：MD-01..MD-09 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 MD-08 打 SKIPPED 不 FAIL，
#      与 selftest-reliability-institution.sh R-12 先例一致）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 SKIPPED，fail-open 非静默——打印提示行）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TMAP="$SKILL_ROOT/../plan-template-kit/references/template-mapping.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'MD-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'MD-%s FAIL %s\n' "$1" "$2"; }

# MD-01 Rule 47 四子条锚 `grep -c '^47\.'` ≥ 4
# What：断言 47.1-47.4 四条子条主体行（行首 '47.N'）在位。
# Why：锁 Rule 47 条款本体未被裁剪/重排——子条是 47.1 拆分轴/47.2 具名路由/47.3 试点先行/47.4 机制层的唯一文本落点，
#      缺任一子条 = 媒体派发纪律条款失守（防 drift：后续任务改写 critical-rules.md 时误删 47.x 段）。
n="$(grep -c '^47\.' "$CRIT" || true)"
if [ "$n" -ge 4 ]; then ok 01 "critical-rules.md Rule 47 子条锚 $n ≥4"; else bad 01 "critical-rules.md Rule 47 子条数 $n（应 ≥4）"; fi

# MD-02 Rule 47 标题锚 `grep -q '^### 47 '`
# What：断言 '### 47 ' 章节标题行在位。
# Why：标题行是 44/45/46 范式（章节标题+子条）的识别锚——丢了标题，Rule 47 会退化为无主条款（防章节误删/标题降级为普通段落）。
if grep -q '^### 47 ' "$CRIT"; then
  ok 02 "critical-rules.md Rule 47 标题锚在位"
else
  bad 02 "critical-rules.md Rule 47 标题锚缺失（### 47 未命中）"
fi

# MD-03 SKILL.md 路由表行 1「媒体生成工序」≥1
# What：断言 SKILL.md 子代理路由表含「媒体生成工序」行。
# Why：该表行是 47.2 具名执行体路由（executor+工序模板 SOP+生成技能）的消费面落点——路由表无媒体行是本缺陷（Rule 47 归因）根因之一，
#      此行被删 = 路由回退到 general-purpose 兜底（防"路由表重构时媒体行被当冗余删除"的漂移）。
n="$(grep -c '媒体生成工序' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 03 "SKILL.md 路由表「媒体生成工序」行 $n ≥1"; else bad 03 "SKILL.md 路由表「媒体生成工序」行缺失（命中 $n 应 ≥1）"; fi

# MD-04 SKILL.md 路由表行 2「剧集创作管线」≥1
# What：断言 SKILL.md 路由表含「剧集创作管线」行。
# Why：剧集=多集/多镜整链，是媒体拆分轴（47.1 集→场→镜逐级拆）的专属消费面；与 MD-03 构成媒体两行完整路由（防只删其一的部分漂移）。
n="$(grep -c '剧集创作管线' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 04 "SKILL.md 路由表「剧集创作管线」行 $n ≥1"; else bad 04 "SKILL.md 路由表「剧集创作管线」行缺失（命中 $n 应 ≥1）"; fi

# MD-05 SKILL.md 摘要 bullet「Rule 47（媒体制作任务派发纪律」≥1
# What：断言 SKILL.md Critical Rules 摘要段含 Rule 47 bullet。
# Why：摘要是 SKILL.md 内 Rule 47 的入口索引（LLM 读 SKILL.md 时先见摘要后查 critical-rules.md）——丢 bullet = 摘要与条款脱钩
#      （防"条款扩到 47 但摘要停摆 44"的级联断链；v121 1-4[5-9] 预扩位已确认追加 47 名不触发）。
n="$(grep -c 'Rule 47（媒体制作任务派发纪律' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 05 "SKILL.md Rule 47 摘要 bullet $n ≥1"; else bad 05 "SKILL.md Rule 47 摘要 bullet 缺失（命中 $n 应 ≥1）"; fi

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

# MD-08 零新 config 键——properties 键数 = 40（同 reliability-institution R-12 口径；jq 缺失打 SKIPPED 不 FAIL）
# What：断言 config.json .properties 顶层键数保持 40（Rule 47 判定面纯 LLM 行为 + 静态守护，零机器触发面，故不得新增 config 键）。
# Why：47.4 承诺"零新 config 键"——键数膨胀 = 有人给媒体派发加了机器门控键，突破 43.4/44.4 既定零新键范式，属机制漂移（需走 36 条款流程）。
#      jq 缺失 fail-open 打 SKIPPED（沿用 R-12 先例：无 jq 属环境降级非内容漂移，不误报 FAIL）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 08 "config.json properties 键数 40（零新增）"; else bad 08 "config.json properties 键数=$keys（应 40，Rule 47 零新键被破坏）"; fi
else
  printf 'MD-08 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

# MD-09 既有锚守护：critical-rules.md '^21\.1b' 在位 + SKILL.md '代码编辑（单文件' ≥1
# What：双锚并存断言——21.1b（拆分轴条款）行在位，且 SKILL.md 路由表既有行「代码编辑（单文件…」未被删。
# Why：Rule 47 是 36.5 纯增量（衔接 21.1b 原文零改动），本断言把"增量不破坏存量"机器化——防后续改写 Rule 21.1b 拆分轴
#      或路由表删既有行的非对称修改（只新增媒体行/删旧行 = 路由面失守）。
a="$(grep -c '^21\.1b' "$CRIT" || true)"
b="$(grep -c '代码编辑（单文件' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 09 "既有锚守护 21.1b=$a ≥1 且 SKILL.md「代码编辑（单文件」行 $b ≥1"; else bad 09 "既有锚漂移（critical-rules 21.1b=$a 应 ≥1 / SKILL.md 代码编辑行=$b 应 ≥1）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
