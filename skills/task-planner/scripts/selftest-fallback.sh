#!/usr/bin/env bash
# [2026-09-08 task-v055-fallback] selftest-fallback.sh — subagent-fallback.sh 自测（fixture 全量覆盖，不依赖真实 ~/.zcode 与网络）
# 断言 T01-T08;全 PASS exit 0,任一 FAIL exit 1
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/subagent-fallback.sh"
WORKTREE_ROOT="$SCRIPT_DIR/../../.."   # <repo-root>/skills/task-planner/scripts → 上三级
CONFIG_JSON="$SCRIPT_DIR/../config.json"
FAKE="$(mktemp -d /tmp/fb-selftest.XXXXXX)"
trap 'rm -rf "$FAKE"' EXIT

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# ── fixture: 假 ZCODE_HOME ──
mkdir -p "$FAKE/v2" "$FAKE/agents"
cat > "$FAKE/v2/config.json" <<'EOF'
{
  "provider": {
    "pk-agg": {
      "name": "agg-test",
      "kind": "anthropic",
      "options": { "baseURL": "https://fake.agg.test/v1", "apiKey": "sk-fake-agg" },
      "models": { "agnes-2.5-flash": {} }
    },
    "pk-other": {
      "name": "other-test",
      "kind": "anthropic",
      "options": { "baseURL": "https://fake.other.test", "apiKey": "sk-fake-other" },
      "models": { "agnes-2.5-flash": {} }
    }
  }
}
EOF
cat > "$FAKE/agents/executor.md" <<'EOF'
---


name: executor
description: test executor agent
tools: Read, Write, Edit, Bash
model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"
---

# Executor body
You are a test executor.
EOF
cat > "$FAKE/agents/explore.md" <<'EOF'
---


name: Explore
description: test explore agent
tools: Read, Grep, Glob
model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:haiku-1"
---

# Explore body
EOF

# T01: probe --no-network → health.json 存在, 2 条 entries 全 skipped
ZCODE_HOME="$FAKE" bash "$TARGET" probe --no-network --out "$FAKE/health.json" > /dev/null
t "T01a probe(no-network) health.json 存在" test -f "$FAKE/health.json"
t "T01b entries=2" bash -c "[ \"\$(jq '.entries | length' '$FAKE/health.json')\" = 2 ]"
t "T01c 全 skipped" jq -e '[.entries[].status] | all(. == "skipped")' "$FAKE/health.json"

# T02: next 无 health → dispatch_as=null + no_health_file
out2="$(ZCODE_HOME="$FAKE" bash "$TARGET" next executor provider --out "$FAKE/no-such-health.json")"
t "T02a dispatch_as=null" bash -c "echo '$out2' | jq -e '.dispatch_as == null' >/dev/null"
t "T02b 含 no_health_file" bash -c "echo '$out2' | grep -q no_health_file"

# T03: 手写健康 health(1 条 ok) → next 返回 executor-fb + custom:pk-agg:agnes-2.5-flash
cat > "$FAKE/health-ok.json" <<'EOF'
{"ts":"2026-09-08T00:00:00Z","entries":[{"provider":"pk-agg","provider_name":"agg-test","model":"agnes-2.5-flash","status":"ok","error":""}]}
EOF
out3="$(ZCODE_HOME="$FAKE" bash "$TARGET" next executor provider --out "$FAKE/health-ok.json")"
t "T03a dispatch_as=executor-fb" bash -c "echo '$out3' | jq -e '.dispatch_as == \"executor-fb\"' >/dev/null"
t "T03b model=custom:pk-agg:agnes-2.5-flash" bash -c "echo '$out3' | jq -e '.model == \"custom:pk-agg:agnes-2.5-flash\"' >/dev/null"
t "T03c zero_cost=true" bash -c "echo '$out3' | jq -e '.zero_cost == true' >/dev/null"

# T04: 非 provider err_kind → non_provider_error
out4="$(ZCODE_HOME="$FAKE" bash "$TARGET" next executor logic --out "$FAKE/health-ok.json")"
t "T04 dispatch_as=null + non_provider_error" bash -c "echo '$out4' | jq -e '.dispatch_as == null' >/dev/null && echo '$out4' | grep -q non_provider_error"

# T05: bind（健康 health + 2 源 agent）→ created=[executor,explore]; failures 含 code-assistant/general-purpose
out5="$(ZCODE_HOME="$FAKE" bash "$TARGET" bind --zcode-home "$FAKE" --out "$FAKE/health-ok.json")"
t "T05a created 含 executor+explore" bash -c "echo '$out5' | jq -e '.created | sort == [\"executor\",\"explore\"]' >/dev/null"
t "T05b failures 含 code-assistant" bash -c "echo '$out5' | jq -r '.failures[]' | grep -q 'code-assistant'"
t "T05c failures 含 general-purpose" bash -c "echo '$out5' | jq -r '.failures[]' | grep -q 'general-purpose'"

# T06: 生成的 executor-fb.md frontmatter 正确
FB="$FAKE/agents/executor-fb.md"
t "T06a executor-fb.md 存在" test -f "$FB"
t "T06b 含 name_suffix 登记" grep -q 'name_suffix: task-planner-fallback-variant' "$FB"
t "T06c model 行=custom:pk-agg:agnes-2.5-flash" grep -q 'model: "custom:pk-agg:agnes-2.5-flash"' "$FB"
t "T06d 原键保留(name/description/tools)" bash -c "grep -q '^name: executor' '$FB' && grep -q '^description:' '$FB' && grep -q '^tools:' '$FB'"
t "T06e ccr uuid 不残留" bash -c "! grep -q '9e221f47' '$FB'"

# T07: 幂等 — 再 bind 一次 → skipped 含 executor, created 空, meta hash 不变
h1="$(jq -r '.files[\"executor-fb.md\"].hash' "$FAKE/agents/.task-planner-fallback-meta.json")"
out7="$(ZCODE_HOME="$FAKE" bash "$TARGET" bind --zcode-home "$FAKE" --out "$FAKE/health-ok.json")"
h2="$(jq -r '.files[\"executor-fb.md\"].hash' "$FAKE/agents/.task-planner-fallback-meta.json")"
t "T07a skipped 含 executor" bash -c "echo '$out7' | jq -r '.skipped[]' | grep -q '^executor$'"
t "T07b created 为空" bash -c "echo '$out7' | jq -e '.created | length == 0' >/dev/null"
t "T07c meta hash 不变" test "$h1" = "$h2"

# T08: config.json provider_fallback 键
t "T08 config.json provider_fallback.enabled=true" jq -e '.properties.provider_fallback.default.enabled == true' "$CONFIG_JSON"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
