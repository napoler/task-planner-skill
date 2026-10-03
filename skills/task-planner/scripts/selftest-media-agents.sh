#!/usr/bin/env bash
# selftest-media-agents.sh — task-v124 S6: Rule 47.2 媒体双专业执行体（image/video-generation-executor）静态守护
# 范式对齐 selftest-media-dispatch.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构）。
# 用途：静态断言 companion/agents 双媒体 agent 产物在位、frontmatter 格式规范（name/触发/MUST BE USED/model）、
#      SKILL.md 路由表媒体两行联动、template-mapping.md §九注+§十行联动、README_zh/INSTALL_zh 6 个计数口径、
#      INSTALL.md 双 agent 表行、install.sh 注释 6 名清单，并确认零新 config 键（properties=40，与 43.4/44.4/47 同口径）。
# 输入：task-planner/companion/agents/{image,video}-generation-executor.md、task-planner/SKILL.md、task-planner/config.json、
#      task-planner/install.sh、README_zh.md、INSTALL_zh.md、INSTALL.md、../plan-template-kit/references/template-mapping.md（只读，grep/test/jq，零写入）。
# 输出：MA-01..MA-10 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 MA-10 打 SKIPPED 不 FAIL，
#      与 selftest-media-dispatch.sh MD-08 / selftest-reliability-institution.sh R-12 先例一致）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 SKIPPED，fail-open 非静默——打印提示行）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG="$SKILL_ROOT/companion/agents/image-generation-executor.md"
VID="$SKILL_ROOT/companion/agents/video-generation-executor.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
INSTALLSH="$SKILL_ROOT/install.sh"
READMEZH="$SKILL_ROOT/../../README_zh.md"
INSTALLZH="$SKILL_ROOT/../../INSTALL_zh.md"
INSTALLMD="$SKILL_ROOT/INSTALL.md"
TMAP="$SKILL_ROOT/../plan-template-kit/references/template-mapping.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'MA-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'MA-%s FAIL %s\n' "$1" "$2"; }

# MA-01 双 agent 文件存在
# What：断言 image/video-generation-executor.md 两文件在 companion/agents/ 下存在且非空。
# Why：本守护的全部后续断言（格式/联动/文档）都以双文件在位为前提——install-companion.sh glob 分发（零机制改动）
#      只认目录内文件，缺文件 = 双位部署静默漏 agent（防"文件被误删/重命名"的物理面漂移）。
if [ -s "$IMG" ] && [ -s "$VID" ]; then
  ok 01 "双 agent 文件在位 image=$(wc -c < "$IMG")B video=$(wc -c < "$VID")B"
else
  bad 01 "双 agent 文件缺失/空（image $([ -s "$IMG" ] && echo 在位 || echo 缺失) / video $([ -s "$VID" ] && echo 在位 || echo 缺失)）"
fi

# MA-02 frontmatter name=文件名（image）
# What：断言 image agent frontmatter `name: image-generation-executor` 与文件名逐字一致。
# Why：install-companion.sh 以文件名落 ~/.zcode/agents/，name 字段是 agent 被具名路由（Rule 47.2 grep 命中）的
#      标识锚——name 与文件名漂移 = 路由点名与在位文件对不上（防改名不联动 frontmatter 的不对称修改）。
if grep -q '^name: image-generation-executor$' "$IMG"; then
  ok 02 "image frontmatter name=文件名一致"
else
  bad 02 "image frontmatter name 行缺失或与文件名不一致（应 'name: image-generation-executor'）"
fi

# MA-03 frontmatter 格式三要素（image：触发: / MUST BE USED / model 行）
# What：断言 image description 含「触发:」显式段与「MUST BE USED」定位句，且 model 行在位。
# Why：「触发:」段是 companion agent 触发词路由惯例（v122 complex-planner 先例 5 词段），MUST BE USED 是启用门槛声明，
#      model 行是双位适配入口（custom:<uuid>:<slug> 经 adapt_model_line 转 claude 位纯档名）——三要素缺一 = 该 agent
#      不可被路由点名/不可被双位部署（防 description 裁剪时丢触发词或 model 行误删）。
n="$(grep -c '触发:' "$IMG" || true)"
m="$(grep -c 'MUST BE USED' "$IMG" || true)"
mdl="$(grep -c '^model:' "$IMG" || true)"
if [ "$n" -ge 1 ] && [ "$m" -ge 1 ] && [ "$mdl" -ge 1 ]; then
  ok 03 "image frontmatter 格式 触发:=$n ≥1 MUST BE USED=$m ≥1 model 行=$mdl ≥1"
else
  bad 03 "image frontmatter 格式漂移（触发:=$n / MUST BE USED=$m / model 行=$mdl，应各 ≥1）"
fi

# MA-04 frontmatter name=文件名（video）
# What：断言 video agent frontmatter `name: video-generation-executor` 与文件名逐字一致（同 MA-02 逻辑，video 侧）。
# Why：同 MA-02——具名路由标识锚；双 agent 分断言使 FAIL 定位到具体文件（防只查其一的部分守护）。
if grep -q '^name: video-generation-executor$' "$VID"; then
  ok 04 "video frontmatter name=文件名一致"
else
  bad 04 "video frontmatter name 行缺失或与文件名不一致（应 'name: video-generation-executor'）"
fi

# MA-05 frontmatter 格式三要素（video：触发: / MUST BE USED / model 行）
# What：断言 video description 含「触发:」显式段与「MUST BE USED」定位句，且 model 行在位（同 MA-03 逻辑，video 侧）。
# Why：同 MA-03——video agent 触发词路由与双位部署入口；G1 放行门/隔离铁律都在正文，但路由入口三要素丢了 agent 即失效。
n="$(grep -c '触发:' "$VID" || true)"
m="$(grep -c 'MUST BE USED' "$VID" || true)"
mdl="$(grep -c '^model:' "$VID" || true)"
if [ "$n" -ge 1 ] && [ "$m" -ge 1 ] && [ "$mdl" -ge 1 ]; then
  ok 05 "video frontmatter 格式 触发:=$n ≥1 MUST BE USED=$m ≥1 model 行=$mdl ≥1"
else
  bad 05 "video frontmatter 格式漂移（触发:=$n / MUST BE USED=$m / model 行=$mdl，应各 ≥1）"
fi

# MA-06 SKILL.md 路由表两媒体行含双 agent 名
# What：断言 SKILL.md「媒体生成工序」行与「剧集创作管线」行（:356/:357 区）各含 image/video-generation-executor。
# Why：SKILL.md 路由表是 Rule 47.2 具名路由的 LLM 消费面——S3 行内替换（在位优先/缺位回退）的落点，双行任一丢 agent 名
#      = 路由表回退到缺位时代措辞（防"文档重构还原旧行"的逆向漂移；与既有 media-dispatch MD-03/04 行数锚互补，本锚查 agent 名本身）。
a="$(grep '媒体生成工序' "$SKILLMD" | grep -c 'image-generation-executor' || true)"
b="$(grep '剧集创作管线' "$SKILLMD" | grep -c 'video-generation-executor' || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then
  ok 06 "SKILL.md 媒体两行 agent 名联动 媒体生成工序行 image=$a ≥1 / 剧集创作管线行 video=$b ≥1"
else
  bad 06 "SKILL.md 媒体两行 agent 名缺失（媒体生成工序行 image 名=$a / 剧集创作管线行 video 名=$b，应各 ≥1）"
fi

# MA-07 template-mapping.md §九兜底注+§十媒体制作族行含双 agent 名
# What：断言 template-mapping.md「媒体族专用执行体」注行含双 agent 名（§九兜底注锚），
#      且全文件「image-generation-executor」与「video-generation-executor」各 ≥1。
# Why：mapping 是画像层路由权威源（Rule 47 归因根因即"画像有类型、路由无行"）——S3 两处行内替换（:298/:308）的落点，
#      丢 agent 名 = 画像层与派发层再次脱节（防画像矩阵重构时媒体族执行体列被裁回旧措辞）。
n="$(grep -c '媒体族专用执行体' "$TMAP" || true)"
i="$(grep -c 'image-generation-executor' "$TMAP" || true)"
v="$(grep -c 'video-generation-executor' "$TMAP" || true)"
if [ "$n" -ge 1 ] && [ "$i" -ge 1 ] && [ "$v" -ge 1 ]; then
  ok 07 "template-mapping.md 媒体族专用执行体注 $n ≥1 且双 agent 名 image=$i/video=$v 各 ≥1"
else
  bad 07 "template-mapping.md 联动漂移（媒体族专用执行体注=$n / image 名=$i / video 名=$v，应各 ≥1）"
fi

# MA-08 文档计数口径：README_zh「6 个伴生」+ INSTALL_zh「6 个配套」+ INSTALL.md 双 agent 表行
# What：三处文档锚并存断言——README_zh.md 树状图「6 个伴生 agent」、INSTALL_zh.md 树状图「6 个配套 agent」、
#      INSTALL.md 表内 image/video 两 agent 行各 1 命中。
# Why：S4/S5 已把 3→6 计数与 INSTALL.md 补行修正为 6 名口径（stale 欠账含 v119 漏 complex-planner）——
#      计数回退 3 或表行缺失 = 文档面与 companion/agents/ 实际 6 文件脱节（防文档重写回退旧计数）。
a="$(grep -c '6 个伴生' "$READMEZH" || true)"
b="$(grep -c '6 个配套' "$INSTALLZH" || true)"
c="$(grep -c 'companion/agents/image-generation-executor.md' "$INSTALLMD" || true)"
d="$(grep -c 'companion/agents/video-generation-executor.md' "$INSTALLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ] && [ "$d" -ge 1 ]; then
  ok 08 "文档计数口径 README 6 个伴生=$a / INSTALL_zh 6 个配套=$b / INSTALL.md 双 agent 行 image=$c video=$d 各 ≥1"
else
  bad 08 "文档计数/表行漂移（README 6 个伴生=$a / INSTALL_zh 6 个配套=$b / INSTALL.md image 行=$c video 行=$d，应各 ≥1）"
fi

# MA-09 install.sh 注释 6 名清单含双 agent 名
# What：断言 install.sh companion/agents 注释行（:179 区）同时含 image/video-generation-executor。
# Why：install.sh 注释是 agent 清单的部署面口径（S5 补全 3→6 名）——注释与目录实际 6 文件脱节会误导部署排查
#      （防注释回退到 3 名旧清单；与 MA-08 INSTALL.md 表行构成部署文档双锚）。
i="$(grep -c 'image-generation-executor' "$INSTALLSH" || true)"
v="$(grep -c 'video-generation-executor' "$INSTALLSH" || true)"
if [ "$i" -ge 1 ] && [ "$v" -ge 1 ]; then
  ok 09 "install.sh 注释双 agent 名 image=$i / video=$v 各 ≥1"
else
  bad 09 "install.sh 注释双 agent 名缺失（image=$i / video=$v，应各 ≥1）"
fi

# MA-10 零新 config 键——properties 键数 = 40（同 43.4/44.4/47 口径；jq 缺失打 SKIPPED 不 FAIL）
# What：断言 config.json .properties 顶层键数保持 40（媒体双执行体为 LLM 具名路由面，零机器触发面，不得新增 config 键）。
# Why：agent 新增承诺"零新键"——键数膨胀 = 有人给媒体执行体加了机器门控键，突破 43.4/44.4 既定零新键范式，
#      属机制漂移（需走 36 条款流程）；jq 缺失 fail-open 打 SKIPPED（沿用 MD-08/R-12 先例：无 jq 属环境降级非内容漂移）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 10 "config.json properties 键数 40（零新增）"; else bad 10 "config.json properties 键数=$keys（应 40，零新键承诺被破坏）"; fi
else
  printf 'MA-10 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
