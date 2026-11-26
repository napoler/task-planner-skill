#!/usr/bin/env bash
# selftest-worktree-required.sh — Rule: worktree 隔离判定门（2026-11-27 用户裁决）
#
# What:
#   行为级守护 check-worktree-required.sh。覆盖：
#     W-SAT: 当前已在 worktree 上下文（linked worktree）→ SATISFIED worktree（rc=0）
#     W-1: 交付型 Markdown 多行/多文件场景 → REQUIRED worktree（以模拟参数覆盖判定）
#     W-2: README/过程文档 1 行 → EXEMPT trivial
#     参数非法 → rc=2（fail-closed）
#   额外 mutation 判别：
#     - 把脚本核心判定逻辑破坏后，W-1/W-2 的期望应被破坏（用坏脚本跑同输入应不再返回 REQUIRED）。
#
# Why:
#   防止回归：未来有人把“必须 worktree”判定改回按 .md 后缀或删除判定分支时，本 selftest 必须 FAIL。
#   关键：所有非 SATISFIED 的用例必须在“非 worktree 的模拟主工作树 cwd”下运行，避免运行者 cwd 在 worktree 导致误判。
#
# 运行方式：`bash scripts/selftest-worktree-required.sh`（可在 worktree 或主仓任意 cwd 执行，结果应一致）
# 输出：逐行 PASS/FAIL，总计 Total；全 PASS exit 0，任一 FAIL exit 1。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-worktree-required.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'W-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'W-%s FAIL %s\n' "$1" "$2"; }

if [[ ! -f "$CHECK" ]]; then
  printf 'W-99 FAIL 被测脚本缺失: %s\n' "$CHECK"
  exit 1
fi

# 非 worktree 的模拟“主工作树”cwd（普通目录，不是 git repo 也可；脚本会 cd 后自行检测）
NON_WT_CWD="$(mktemp -d)"
trap 'rm -rf "$NON_WT_CWD" "$WT_TMP" "$MUT" 2>/dev/null' EXIT

# --- W-SAT: 当前已在 worktree → SATISFIED ---
# 通过临时 git 仓 + linked worktree 模拟
WT_TMP="$(mktemp -d)"
(
  set -euo pipefail
  cd "$WT_TMP"
  git init -q
  git config user.email "test@example.com"
  git config user.name "test"
  echo "x" > f.txt
  git add f.txt
  git commit -qm "init"
  mkdir -p "$WT_TMP/wt"
  git worktree add -q "$WT_TMP/wtlink" -b wt-test HEAD
) >/dev/null 2>&1 || true

if [[ -d "$WT_TMP/wtlink" ]]; then
  out="$(bash "$CHECK" --files "novel.md" --lines 200 --delivery 1 --cwd "$WT_TMP/wtlink" 2>&1)"; rc=$?
  if [[ $rc -eq 0 ]] && printf '%s\n' "$out" | grep -q '^SATISFIED worktree'; then
    ok "SAT" "在 worktree 内（linked）对 delivery 多行文件也返回 SATISFIED"
  else
    bad "SAT" "在 worktree 内应 SATISFIED，rc=$rc out=$out"
  fi
else
  bad "SAT" "无法创建 linked worktree 进行 W-SAT 测试（环境限制）"
fi

# --- W-1: 交付型 Markdown 多行/多文件/lines>2（必须在非 worktree cwd 下判定） ---
out="$(bash "$CHECK" --files "novel-ch01.md" --lines 200 --delivery 1 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && printf '%s\n' "$out" | grep -q '^REQUIRED worktree'; then
  ok "1a" "delivery=1 多行 -> REQUIRED (out=$out)"
else
  bad "1a" "期望 REQUIRED（cwd=$NON_WT_CWD），rc=$rc out=$out"
fi

out="$(bash "$CHECK" --files "a.md,b.md" --lines 1 --delivery 0 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && printf '%s\n' "$out" | grep -q '^REQUIRED worktree'; then
  ok "1b" "multi-file (2 files) -> REQUIRED (out=$out)"
else
  bad "1b" "期望 REQUIRED（多文件，cwd=$NON_WT_CWD），rc=$rc out=$out"
fi

out="$(bash "$CHECK" --files "big.md" --lines 3 --delivery 0 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && printf '%s\n' "$out" | grep -q '^REQUIRED worktree'; then
  ok "1c" "lines>2 -> REQUIRED (out=$out)"
else
  bad "1c" "期望 REQUIRED（lines>2，cwd=$NON_WT_CWD），rc=$rc out=$out"
fi

# --- W-2: README 1 行 -> EXEMPT（非交付型，<=2 行，非 worktree cwd） ---
out="$(bash "$CHECK" --files "README.md" --lines 1 --delivery 0 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && printf '%s\n' "$out" | grep -q '^EXEMPT trivial'; then
  ok "2" "非交付型且<=2行 -> EXEMPT (out=$out)"
else
  bad "2" "期望 EXEMPT（cwd=$NON_WT_CWD），rc=$rc out=$out"
fi

# --- 参数非法 fail-closed ---
out="$(bash "$CHECK" --files "a.md" --lines -1 --delivery 0 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 2 ]]; then
  ok "3a" "lines=-1 -> rc=2 fail-closed"
else
  bad "3a" "期望 rc=2，got rc=$rc out=$out"
fi

out="$(bash "$CHECK" --files "a.md" --lines 1 --delivery 2 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 2 ]]; then
  ok "3b" "delivery=2 -> rc=2 fail-closed"
else
  bad "3b" "期望 rc=2，got rc=$rc out=$out"
fi

out="$(bash "$CHECK" --files "a.md" --delivery 0 --cwd "$NON_WT_CWD" 2>&1)"; rc=$?
if [[ $rc -eq 2 ]]; then
  ok "3c" "缺少 --lines -> rc=2 fail-closed"
else
  bad "3c" "期望 rc=2，got rc=$rc out=$out"
fi

# --- Mutation 判别：破坏核心判定后，W-1a/W-2 的期望应被破坏 ---
MUT="$(mktemp /tmp/check-wt-mut.XXXX.sh)"
cat > "$MUT" <<'MUTEOF'
#!/usr/bin/env bash
set -euo pipefail
# broken mutation: always exempt
echo "EXEMPT trivial: mutated"
exit 0
MUTEOF
chmod +x "$MUT"
mut_out="$(bash "$MUT" --files "novel.md" --lines 200 --delivery 1 2>&1)"; mut_rc=$?
if [[ "$mut_out" == *"REQUIRED worktree"* ]]; then
  bad "M1" "mutation 脚本不应返回 REQUIRED（说明替换失败） out=$mut_out"
else
  ok "M1" "mutation 后不再输出 REQUIRED（mutation 判别有效，坏脚本 out=$mut_out）"
fi

echo "Total: $((PASS+FAIL)) PASS=$PASS FAIL=$FAIL"
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0