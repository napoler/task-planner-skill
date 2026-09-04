#!/usr/bin/env bash
# sync-companion.sh — 反向同步:把 ~/.zcode(或 ~/.claude)中的伴随文件修改拉回 canonical
#
# 用途:在 ~/.zcode/agents/plan-writer.md 或顶层外围 skill(如 ~/.zcode/skills/plan-resume/)
# 等文件上做了修改后,运行本脚本把最新版同步回 canonical 仓(companion/agents/ 与顶层 skills/<name>/),commit 后新机器即可一键安装到最新版。
#
# Usage:
#   bash scripts/sync-companion.sh [--dry-run] [--diff]
#
#   --dry-run   只显示差异,不写 companion/
#   --diff      对有差异的文件输出完整 diff
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
COMPAANION_DIR="${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion"
# 外围 skill 回同步目标 = 仓库顶层 skills/(2026-09-04 自 companion/skills/ 迁移,排除 task-planner 本体)
# SKILL_ROOT = <repo>/skills/task-planner → 上两级才是仓根
REPO_ROOT="$(dirname "$(dirname "$SKILL_ROOT")")"
REPO_SKILLS="$REPO_ROOT/skills"
DRY_RUN=0
SHOW_DIFF=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --diff) SHOW_DIFF=1; shift ;;
    --target) TARGET_ROOT="$2"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# 源 root 探测独立于 TASK_PLANNER_ROOT(后者只定位 companion;探测被其短路会导致纯 Claude 机器全 missing)
if [ -z "${TARGET_ROOT:-}" ]; then
  for cand in "$HOME/.zcode" "$HOME/.claude"; do
    [ -d "$cand" ] && TARGET_ROOT="$cand" && break
  done
fi
TARGET_ROOT="${TARGET_ROOT:-$HOME/.zcode}"

[ -d "$COMPAANION_DIR" ] || { echo "[sync] ERROR: companion dir missing: $COMPAANION_DIR" >&2; exit 1; }
# 顶层 skills/ 合理性校验:防止从已部署副本运行时把部署目录误当回同步目标(canonical 仓根必含 CHANGELOG.md)
[ -f "$REPO_ROOT/CHANGELOG.md" ] && [ -d "$REPO_SKILLS/task-planner" ] || { echo "[sync] ERROR: $REPO_SKILLS 不是 canonical 仓顶层 skills/" >&2; exit 1; }

echo "[sync] source root: $TARGET_ROOT"
echo "[sync] companion:   $COMPAANION_DIR"

changed=0; same=0; missing=0

# ─── 平台 model 行适配(v2.2.2)─────────────────────────────────────────
# companion/ 统一存 ZCode 格式(custom:<uuid>:<slug>)。
# 源是 ~/.claude 时,agent 的 model 行是纯名格式 → 拉回前须转回 ZCode 格式。
# 本机 provider UUID 从 ~/.zcode/agents 现有文件提取(apply-model-providers.mjs 重绑机制保证其正确)。
ZCODE_UUID=""
detect_zcode_uuid() {
  local probe
  # 优先从本机 ZCode agents 提取;纯 Claude 机器无 ~/.zcode → 从 companion 自身兜底(companion 存 ZCode 格式)
  for probe in "$HOME/.zcode/agents/"*.md "$COMPAANION_DIR"/agents/*.md; do
    [ -e "$probe" ] || continue
    ZCODE_UUID="$(grep -m1 -o '[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}' "$probe" 2>/dev/null)"
    [ -n "$ZCODE_UUID" ] && return 0
  done
  return 1
}

# claude_model_to_zcode <纯名值> <uuid> → stdout;未知格式返回空(调用方保留原值)
claude_model_to_zcode() {
  local m="$1" uuid="$2"
  local clean="${m//\"/}"
  case "$clean" in
    sonnet) echo "custom:$uuid:sonnet-1" ;;
    haiku)  echo "custom:$uuid:haiku-1" ;;
    opus)   echo "custom:$uuid:opus-1" ;;
    mini)   echo "custom:$uuid:mini" ;;
    */*)    echo "custom:$uuid:${clean//\//%2F}" ;;
    *)      echo "" ;;
  esac
}

# pull_one <companion-file> <src-file>
pull_one() {
  local cfile="$1" src="$2"
  if [ ! -f "$src" ]; then
    echo "  MISSING in source: $src (companion 保留不动)"; missing=$((missing+1)); return
  fi
  # agent 文件且源是 Claude 平台:先把源转成 ZCode 格式再做比较/拉回
  local cmp_src="$src" tmp_conv=""
  if [[ "${src}" == */agents/*.md ]] && [[ "$TARGET_ROOT" == *.claude ]]; then
    [ -z "$ZCODE_UUID" ] && detect_zcode_uuid
    if [ -n "$ZCODE_UUID" ] && grep -q '^model:' "$src"; then
      local old_m new_m
      old_m="$(grep '^model:' "$src" | head -1 | sed 's/^model:[[:space:]]*//')"
      new_m="$(claude_model_to_zcode "$old_m" "$ZCODE_UUID")"
      if [ -n "$new_m" ] && [ "$new_m" != "$old_m" ]; then
        tmp_conv="$(mktemp)"
        sed "s|^model:.*|model: $new_m|" "$src" > "$tmp_conv"
        cmp_src="$tmp_conv"
      fi
    fi
  fi
  if cmp -s "$cfile" "$cmp_src"; then
    echo "  = ${cfile#$COMPAANION_DIR/} (no change)"
    same=$((same+1))
    [ -n "$tmp_conv" ] && rm -f "$tmp_conv"
    return
  fi
  echo "  ← ${cfile#$COMPAANION_DIR/} (source newer/different)"
  [ "$SHOW_DIFF" -eq 1 ] && diff -u "$cfile" "$cmp_src" | head -60
  if [ "$DRY_RUN" -eq 0 ]; then
    cp "$cmp_src" "$cfile"
  fi
  [ -n "$tmp_conv" ] && rm -f "$tmp_conv"
  changed=$((changed+1))
}

for f in "$COMPAANION_DIR"/agents/*.md; do
  [ -e "$f" ] || continue
  pull_one "$f" "$TARGET_ROOT/agents/$(basename "$f")"
done

for skill_dir in "$REPO_SKILLS"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  [ "$skill_name" = "task-planner" ] && continue
  [ -f "$skill_dir/SKILL.md" ] || continue
  # 用 find -maxdepth 2 扫 skill 目录下一层子目录(支持 scripts/ 子目录结构)
  # 排除 .git / .DS_Store / tests/ 等非同步内容
  while IFS= read -r -d '' f; do
    [ -e "$f" ] || continue
    rel="${f#$skill_dir}"          # scripts/scan-plans.sh
    pull_one "$f" "$TARGET_ROOT/skills/$skill_name/$rel"
  done < <(find "$skill_dir" -mindepth 1 -maxdepth 2 -type f -not -path '*/.git/*' \
                              -not -path '*/tests/*' \
                              -not -name '*.pyc' -not -name '*.md.bak' \
                              -print0)
done

echo "[sync] summary: $changed pulled, $same unchanged, $missing missing-in-source (dry_run=$DRY_RUN)"
if [ "$changed" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  echo "[sync] next: git add companion/ && git commit — 之后 install.sh 一键安装即为最新版"
fi
exit 0
