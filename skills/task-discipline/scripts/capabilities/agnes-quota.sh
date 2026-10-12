#!/usr/bin/env bash
# =============================================================================
# agnes-quota.sh — Agnes 账户额度/计费层直查（Rule 55「可复用能力落盘纪律」首个落盘实例）
#
# What（做什么 / 怎么用 / 退出码）：
#   用途：直查 Agnes 账户计费层（subscription + usage 原始字段），供「查剩余生成额度」
#         这类高频、可复用操作复用。内置：key 候选链解析 + 零成本鉴权校准 + 强制绕 CDN 缓存。
#   用法：bash agnes-quota.sh          # 人读形态（分节输出：key_source / endpoints / 原始字段 / 判定行）
#         bash agnes-quota.sh --json   # 机读形态（stdout 仅纯 JSON，无任何附加文本）
#   退出码：0 = 取到数据（subscription 与 usage 均 HTTP 200；含「计费层未填充」的显式判定行）
#           2 = 用法错误（未知参数）
#           3 = 全部 key 候选均鉴权无效（控制组返回 HTTP 401）
#           4 = 端点不可达（控制组 /agnesapi 对全部 key 候选连续连接失败，http_code=000）
#           5 = 计费端点未返回有效数据（subscription/usage 任一非 HTTP 200，含 000/4xx/5xx）：
#               无法判定计费层状态，禁按返回值解读（2026-10-05 F1 修复新增；任务号见注册表任务来源列）
#
# Why（为什么存在 / 关键取舍，Rule 45 What+Why 双层）：
#   本脚本是 Rule 55「可复用能力落盘纪律」的首个落盘实例（2026-10-05，任务号见
#   references/capability-registry.md 的「任务来源」列）。立法动机来自用户需求 R3 原话
#   （逐字见 plans/ 下本任务的 task_plan.md 🎯 区块）：
#     「像获取视频额度、视频剩余视频生成剩余额度，这种非常常用的功能……正常应该是直接
#      通过API继续获取……他做的时候是每次将莫名其妙，第一次消耗了几秒，第二次消耗了几秒，
#      然后统计出来，最终产出的结果就是一个莫名其妙的完全不对的结果」
#   判例一（反模式，Rule 55.2 的立法对象）：耗时累计推算——用「两次操作各耗几秒」反推剩余
#     额度，产出完全错误的结果。本脚本一律改走权威端点直查，并明确禁止用额度上限字段与用量
#     字段相减等二次推算冒充「剩余额度」（禁推算，只呈现原始字段）。
#   判例二（前序探针教训）：探针发现「CDN 缓存态 200 冒充鉴权证据」——计费端点响应头为
#     cache-control: public, max-age=14400（可被 CDN 缓存），陈旧/他人态会冒充实时数据。
#     故本脚本全请求强制绕缓存（Cache-Control/Pragma: no-cache + 随机 ?_=<epoch_ns>），
#     且必须先做 /agnesapi 鉴权校准（有效 key→404 任务不存在 / 无效 key→401）再采信计费值。
#   判例三（2026-10-05，F1 缺陷修复 — 原行为→新行为，Rule 45 三要素）：
#     现象：计费端点返回非 200（4xx/5xx，如文档化的 429 限流、401 鉴权失败、5xx 服务端错误）时，
#           curl -f 抑制错误体 → body 为空，而旧判定逻辑把「http_code != 000」（非连接失败）当作端点
#           「可达」→ 落入默认成功 verdict「计费层已回传数值」且 exit 0——失败被伪报为成功
#           （正是用户 R3 要根除的「完全不对的结果」/「不可信产出」）。
#     根因：成功判据误用「非 000 = 可达」而非「HTTP 200 = 有效数据」；非 2xx 响应体为空却仍被当成有效直查结果。
#     新行为：以 code=200 为唯一成功判据；subscription/usage 任一非 200（含 000/4xx/5xx）一律判失败，
#           输出显式失败 verdict 并 exit 5（不再有伪成功 exit 0 路径）；仅两码均 200 才进入
#           「已回传数值 / 未填充」二态判定与 exit 0。回归钉=selftest-capability-persistence.sh CP-19/CP-20（本地 mock）。
#   事实来源：plans/ 下本任务 findings.md 的探针第三/四波块（2026-10-05，计费层未回传有效配额）。
#   禁止：硬编码密钥（key 从 env 与 ~/.bashrc 同源解析，候选链与 agnes_api.py 的 get_api_key()
#         一致）；使用已知错误域（恒 401 陷阱，base 唯一取 https://api.agnes-ai.cn）。
#   注：本文件刻意不书写任务目录的全字面——其中含与密钥前缀扫描形态重合的子串，会被静态
#       密钥扫描误报；任务号以 capability-registry.md 的「任务来源」列为准。
# =============================================================================

set -u

# BASE：生产端点为唯一合法默认值。AGNES_QUOTA_BASE 仅测试用途（2026-10-05 新增可测试性缝）：
#   允许 selftest 用本地 mock（127.0.0.1）注入 base 以覆盖非 200 失败路径（F1 回归钉）；
#   未设该变量时取生产默认值，行为与既有一致（默认行为不变）。
BASE="${AGNES_QUOTA_BASE:-https://api.agnes-ai.cn}"
MAX_TIME=15
JSON_MODE=0

usage() {
  printf '%s\n' \
    '用法: bash agnes-quota.sh [--json]' \
    '  无参数   人读形态（分节输出）' \
    '  --json   机读形态（stdout 仅纯 JSON）' \
    '退出码: 0=取到数据(两计费端点均200) / 2=用法错误 / 3=全部 key 无效 / 4=控制组端点不可达 / 5=计费端点非200(无法判定)'
}

for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'agnes-quota.sh: 未知参数: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

# ---- 临时文件登记（退出时清理；创建在宿主 shell，避免命令替换子 shell 丢登记） ----
TMPFILES=()
TMP_OUT=''
cleanup() {
  local f
  if [ "${#TMPFILES[@]}" -gt 0 ]; then
    for f in "${TMPFILES[@]}"; do rm -f "$f"; done
  fi
}
trap cleanup EXIT
mk_tmp() { TMP_OUT="$(mktemp)"; TMPFILES+=("$TMP_OUT"); }

ns() { date +%s%N; }

mask_key() {
  # 密钥全程脱敏输出：前 6 后 4；过短只报长度
  local k="$1" n=${#1}
  if [ "$n" -le 10 ]; then printf '<masked len=%s>' "$n"; else printf '%s...%s' "${k:0:6}" "${k: -4}"; fi
}

# http_get URL OUTFILE KEY -> 输出 http_code（传输失败时输出 000）
# 全请求绕缓存 + 鉴权头；curl 失败不静默——由调用方对 000/401/其他 显式分支
http_get() {
  local url="$1" out="$2" key="$3" code
  code="$(curl -fsS --max-time "$MAX_TIME" \
    -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' \
    -H "Authorization: Bearer $key" \
    -o "$out" -w '%{http_code}' "$url" 2>/dev/null)" || true
  [ -n "$code" ] || code='000'
  printf '%s' "$code"
}

# ---- key 候选链（按序；与 agnes_api.py get_api_key() 同源语义） ----
CAND_SRC=(); CAND_VAL=()
add_cand() { [ -n "$2" ] && { CAND_SRC+=("$1"); CAND_VAL+=("$2"); }; }
add_cand 'env:AGNES_API_KEY' "${AGNES_API_KEY:-}"
add_cand 'env:AGNES_API_TOKEN' "${AGNES_API_TOKEN:-}"
add_cand 'env:APIHUB_AGNES_API_KEY' "${APIHUB_AGNES_API_KEY:-}"
BASHRC_RAW="$(grep -E '^export AGNES_API_KEY=' "$HOME/.bashrc" 2>/dev/null | head -1)"
BASHRC_VAL="$(printf '%s' "$BASHRC_RAW" | sed -E "s/^export AGNES_API_KEY=//; s/^['\"]//; s/['\"]\$//")"
add_cand 'bashrc:export' "$BASHRC_VAL"

TOTAL=${#CAND_SRC[@]}
if [ "$TOTAL" -eq 0 ]; then
  printf 'agnes-quota.sh: 未发现任何 key 候选（env 三键与 ~/.bashrc export AGNES_API_KEY 均为空）\n' >&2
  printf '指引: 在 ~/.bashrc 添加 export AGNES_API_KEY=<KEY>，或更新当前 env 后重试\n' >&2
  exit 3
fi

# ---- 零成本鉴权校准（控制组：/agnesapi + 不存在的 video_id；每候选一请求） ----
#   401 = 鉴权拒绝 → 该候选无效；任何非 401（预期 404 任务不存在）= 通过鉴权；000 = 连接失败
WORK_KEY=''; WORK_SRC=''; NET_FAIL=0
for i in "${!CAND_SRC[@]}"; do
  src="${CAND_SRC[$i]}"; val="${CAND_VAL[$i]}"
  mk_tmp; cal_out="$TMP_OUT"
  cal_url="$BASE/agnesapi?video_id=probe-nonexist-$(ns)&model_name=agnes-video-2.5-flash&_=$(ns)"
  code="$(http_get "$cal_url" "$cal_out" "$val")"
  if [ "$code" = '000' ]; then NET_FAIL=$((NET_FAIL + 1)); continue; fi
  if [ "$code" = '401' ]; then continue; fi
  WORK_KEY="$val"; WORK_SRC="$src"; break
done

if [ -z "$WORK_KEY" ]; then
  if [ "$NET_FAIL" -eq "$TOTAL" ]; then
    printf 'agnes-quota.sh: 端点不可达（/agnesapi 对全部 %s 个 key 候选均连接失败）\n' "$TOTAL" >&2
    exit 4
  fi
  printf 'agnes-quota.sh: 全部 key 候选鉴权无效（控制组 HTTP 401）\n' >&2
  printf '指引: 检查 ~/.bashrc 的 export AGNES_API_KEY，或更新 env AGNES_API_KEY/AGNES_API_TOKEN/APIHUB_AGNES_API_KEY\n' >&2
  exit 3
fi

# ---- 计费层直查（校准通过的 key，≤2 请求；全请求绕缓存） ----
TODAY="$(date +%F)"
TOMORROW="$(date -d tomorrow +%F 2>/dev/null || date +%F)"

mk_tmp; sub_out="$TMP_OUT"
sub_url="$BASE/v1/dashboard/billing/subscription?_=$(ns)"
sub_code="$(http_get "$sub_url" "$sub_out" "$WORK_KEY")"

mk_tmp; use_out="$TMP_OUT"
use_url="$BASE/v1/dashboard/billing/usage?start_date=$TODAY&end_date=$TOMORROW&_=$(ns)"
use_code="$(http_get "$use_url" "$use_out" "$WORK_KEY")"

sub_body="$(<"$sub_out")"
use_body="$(<"$use_out")"

# ---- 成功判据（2026-10-05 F1 修复）----
# What：以 HTTP 200 为唯一成功判据计算 ok_sub/ok_use（旧逻辑的 reach_* 按「非 000」计，已废弃）。
# Why（F1 现象+根因+原行为→新行为）：curl -f 在 4xx/5xx 时抑制错误体（body 为空）但仍回传 http_code；
#   旧逻辑把「http_code != 000」（非连接失败）当作端点「可达」→ 非 2xx 失败码（429 限流/401 鉴权失败/5xx）
#   落入默认成功 verdict「计费层已回传数值」且 exit 0——失败被伪报成功（R3「完全不对的结果」根因）。
#   新行为：非 200（含 000/4xx/5xx）一律 ok=0；任一非 200 → 显式失败 verdict + exit 5；仅两码均 200 才
#   进入「已回传数值 / 未填充」二态判定与 exit 0。
ok_sub=0; [ "$sub_code" = '200' ] && ok_sub=1
ok_use=0; [ "$use_code" = '200' ] && ok_use=1

# ---- 判定行（Rule 55.2：只直查、不推算；非 200 一律显式失败，禁伪成功） ----
if [ "$ok_sub" -eq 0 ] || [ "$ok_use" -eq 0 ]; then
  # 任一计费端点非 200 → 失败语义 + exit 5（双失败 / 单失败两种 verdict，均含两端点 HTTP 码）
  if [ "$ok_sub" -eq 0 ] && [ "$ok_use" -eq 0 ]; then
    verdict="计费端点均未返回有效数据（subscription=HTTP $sub_code, usage=HTTP $use_code）：两个端点均非 HTTP 200，无法判定计费层状态（鉴权/限流/服务端错误/不可达）；禁按返回值解读"
  else
    verdict="计费端点部分不可达（subscription=$sub_code usage=$use_code）：本次无法判定计费层状态；请重试或登录仪表板 Usage/Billing"
  fi
  VERDICT_FAIL=1
else
  VERDICT_FAIL=0
  verdict='计费层已回传数值（本脚本仅直查原始字段，不推算剩余额度；权威面=登录仪表板 Usage/Billing）'
  if printf '%s' "$sub_body" | grep -q '100000000' \
    || printf '%s' "$use_body" | grep -qE '"total_usage"[[:space:]]*:[[:space:]]*0([^0-9]|$)'; then
    verdict='计费层数据未填充：剩余额度不可由本 API 推出；权威面=登录仪表板 Usage/Billing；HTTP 402=配额耗尽事后信号'
  fi
fi

tf() { [ "$1" -eq 1 ] && printf 'yes' || printf 'no'; }
jb() { [ "$1" -eq 1 ] && printf 'true' || printf 'false'; }
jstr() { local s="$1"; s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; printf '"%s"' "$s"; }
jraw() { case "$1" in \{*) printf '%s' "$1" ;; *) printf 'null' ;; esac; }

if [ "$JSON_MODE" -eq 0 ]; then
  printf 'Agnes 额度直查（agnes-quota.sh · Rule 55 首个落盘实例）\n'
  printf 'key_source: %s (%s)\n' "$WORK_SRC" "$(mask_key "$WORK_KEY")"
  printf 'endpoints_reachable: /agnesapi=yes subscription=%s usage=%s\n' "$(tf "$ok_sub")" "$(tf "$ok_use")"
  printf '\n--- subscription（原始字段，直查未加工）---\n%s\n' "${sub_body:-<空>}"
  printf '\n--- usage（原始字段，直查未加工）---\n%s\n' "${use_body:-<空>}"
  printf '\n--- verdict ---\n%s\n' "$verdict"
else
  printf '{\n'
  printf '  "key_source": %s,\n' "$(jstr "$WORK_SRC")"
  printf '  "key_masked": %s,\n' "$(jstr "$(mask_key "$WORK_KEY")")"
  printf '  "endpoints_reachable": {"agnesapi": true, "subscription": %s, "usage": %s},\n' "$(jb "$ok_sub")" "$(jb "$ok_use")"
  printf '  "subscription": %s,\n' "$(jraw "$sub_body")"
  printf '  "usage": %s,\n' "$(jraw "$use_body")"
  printf '  "verdict": %s\n' "$(jstr "$verdict")"
  printf '}\n'
fi

if [ "$VERDICT_FAIL" -eq 1 ]; then exit 5; fi
exit 0
