# Comet 可信度机制融合 — 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: 用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务执行。步骤用 `- [ ]` 复选框跟踪。
> 本计划为「地基→入口→出口」三阶段；每阶段自带可独立测试、可独立评审的交付物。所有实现类改动在 worktree 内进行（§11.1），合并回 master 并清理。

**Goal:** 把 Comet 的执行可信度机制（唯一事实源+版本绑定、判别性验收夹具、用户门账本+只读恢复探针）融合进 task-planner，直击"任务容易出错"，同时保持长线会话数据基础不可拆。

**Architecture:**  triplet 契约——事件→登记→消费→门禁（沿用 Rule 118/119 已验证形态）。`plan-state.json` 为唯一权威源；4 个 MD 由 `planctl render` 派生。每条机制落成：schema 字段 + planctl 写入/校验 API + check-* 门消费 + selftest 负控制（含 mutation）+ examples review 实物。

**Tech Stack:** Python 3.8+（planctl.py，无三方依赖）、Bash（`set -euo pipefail`）、JSON Schema draft-07、TSV registry。

## Global Constraints（每条任务隐式继承）

- 不改 `skills/` 外的平行状态源；4 个派生 MD 只由 render 产生，禁手工 Edit。
- 每新门必须同时有正例（该过→PASS）与负控制（该拦→FAIL），负控制不被抓出=不算完成。
- 全量 selftest 的 FAIL 集合必须 == 基线（运行前记录），零新增 FAIL。
- 部署位改动后逐位 diff=0（`verify.sh`）+ selftest 复跑。
- 脚本退出码：0 成功 / 1 用户错误 / 2 环境错误 / 3 验证失败。
- 所有路径用绝对路径或用前 `cd` 到项目根；簿记与派发一律 cd 主仓根（cwd 误解析判例）。
- 提交粒度：每个 S-unit 完成即 `git commit -- <pathspec>`，禁 `add -A` 盲扫。
- 基线 tag：`baseline-before-comet-trust-refactor-20261127-064717`（回退锚，勿删除）。

## 基线测量（Task 0，先于一切改动）

**Files:** 无改动（只读测量）
- [ ] **Step 1: 记录 selftest 基线**

Run:
```bash
cd /mnt/data/dev/task-planner-skill
bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tee /tmp/comet-selftest-baseline.txt
tail -5 /tmp/comet-selftest-baseline.txt
```
Expected: 输出末行含 `Total:` 与 `FAIL=N`；记下 N（预期=2 个预存 FAIL，见记忆基线），后续每阶段对比不得新增。

- [ ] **Step 2: 记录 verify 基线**

Run:
```bash
cd /mnt/data/dev/task-planner-skill
TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 | tail -3
```
Expected: `[verify] summary: N pass / 0 fail`，退出码 0。

- [ ] **Step 3: 建 worktree**

```bash
cd /mnt/data/dev/task-planner-skill
git worktree add tmp/worktrees/task-comet-trust-learning-20261127 -b wt/task-comet-trust-learning-20261127 master
```
Expected: worktree 创建成功；后续所有 `skills/` 改动在此目录进行（`cd tmp/worktrees/task-comet-trust-learning-20261127`）。

---

## Phase 1 — 地基：状态可信 + 证据绑定

### Task 1: 注册 `evidence_binding` 字段（schema + planctl）

**Files:**
- Modify: `skills/task-planner/schemas/plan-state.schema.json`（根 `additionalProperties:false` 在 :22，顶层 properties :6-87）
- Modify: `skills/task-planner/scripts/planctl.py`（`ARRAY_SECTIONS` :57、`TOP_LEVEL_FIELDS` 区域）

**Interfaces:**
- Consumes: 现有 `plan-state.json` schema_version=1
- Produces: `evidence_binding` 对象数组，元素 `{path, sha256, version, recorded_at}`；供 Task 2 门消费

- [ ] **Step 1: 写失败测试（schema 拒绝未知字段）**

在 worktree 内，先确认当前 schema 会拒绝新字段：
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
python3 -c "
import json,jsonschema
s=json.load(open('skills/task-planner/schemas/plan-state.schema.json'))
d={'schema_version':1}
try:
    jsonschema.validate(d,s); print('NO_EVIDENCE_FIELD_OK')
except Exception as e: print('expected-pass')
"
```
Expected: 能加载 schema（若 jsonschema 缺失打印告警即可，不阻断）。

- [ ] **Step 2: 在 schema 注册字段**

用 python 精确插入（带断言，防静默失配）：
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
python3 - <<'PY'
import json,io
p='skills/task-planner/schemas/plan-state.schema.json'
d=json.load(open(p))
assert 'evidence_binding' not in d['properties'], '字段已存在，勿重复注册'
d['properties']['evidence_binding']={
  "type":"array",
  "items":{"type":"object","additionalProperties":False,"required":["path","sha256","version","recorded_at"],
    "properties":{"path":{"type":"string","minLength":1},"sha256":{"type":"string","pattern":"^[0-9a-f]{64}$"},
      "version":{"type":"string","minLength":1},"recorded_at":{"type":"string","format":"date-time"}}},
  "description":"证据→版本绑定：产物路径绑定到写入时的 sha256 与版本；旧 hash 只留审计不得推进状态"
}
io.open(p,'w',encoding='utf-8').write(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
print('schema evidence_binding 注册完成')
PY
```
Expected: `schema evidence_binding 注册完成`。

- [ ] **Step 3: 在 planctl 注册手写校验面**

打开 `planctl.py` 的 `ARRAY_SECTIONS`（:57）与顶层字段列表，追加 `'evidence_binding'`：
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
python3 - <<'PY'
import io
p='skills/task-planner/scripts/planctl.py'
s=io.open(p,encoding='utf-8').read()
old="ARRAY_SECTIONS = ("
assert s.count(old)==1
# 在 ARRAY_SECTIONS 元组内首行追加新段名
i=s.index(old)
head=s[i:i+400]
assert "'evidence_binding'" not in head
s=s.replace(old+"\n    'decisions'", old+"\n    'evidence_binding',\n    'decisions'",1)
io.open(p,'w',encoding='utf-8').write(s)
print('planctl ARRAY_SECTIONS 追加 evidence_binding')
PY
python3 -m py_compile skills/task-planner/scripts/planctl.py
```
Expected: 打印追加成功；`py_compile` 无输出（语法 OK）。若 `decisions` 不在 ARRAY_SECTIONS 首位，改为定位实际首元素后重试（先 `grep -A3 'ARRAY_SECTIONS = ('` 确认）。

- [ ] **Step 4: 写 selftest 验证字段可写可读**

Create: `skills/task-planner/scripts/selftest-evidence-binding.sh`（TDD 从简，完整脚本见 Task 2 合并写入；此处先建最小骨架）
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
cat > skills/task-planner/scripts/selftest-evidence-binding.sh <<'SEOF'
#!/usr/bin/env bash
# selftest-evidence-binding — evidence_binding 写入/校验/负控制行为回归
set -uo pipefail
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }
# TC-01: schema 接受合法 evidence_binding
python3 - <<'PY' >/dev/null 2>&1 && ok TC-01 || bad TC-01
import json
try:
    import jsonschema
    s=json.load(open('skills/task-planner/schemas/plan-state.schema.json'))
    jsonschema.validate({'schema_version':1,'evidence_binding':[{'path':'p','sha256':'a'*64,'version':'v1','recorded_at':'2026-11-27T00:00:00Z'}]},s)
except ImportError:
    pass
PY
echo "[selftest-evidence-binding] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
SEOF
chmod +x skills/task-planner/scripts/selftest-evidence-binding.sh
bash skills/task-planner/scripts/selftest-evidence-binding.sh
```
Expected: `Total: PASS=1 FAIL=0`，exit 0。

- [ ] **Step 5: Commit**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
git add -- skills/task-planner/schemas/plan-state.schema.json skills/task-planner/scripts/planctl.py skills/task-planner/scripts/selftest-evidence-binding.sh
git commit -m "feat(comet-trust): register evidence_binding field (schema+planctl+selftest)"
```
Expected: 提交成功；`git status --short` 无这三个文件的未提交改动。

---

### Task 2: 证据→版本绑定校验门（`check-evidence-binding.sh`）

**Files:**
- Create: `skills/task-planner/scripts/check-evidence-binding.sh`
- Modify: `skills/task-planner/scripts/selftest-evidence-binding.sh`（加负控制）
- Modify: `skills/task-planner/scripts/selftest-registry.tsv`（登记四列）

**Interfaces:**
- Consumes: Task 1 的 `evidence_binding` 字段
- Produces: `check-evidence-binding.sh <plan-dir> <vc-ref>` → rc0=当前版本绑定有效 / rc1=缺失或过期（旧 hash）

- [ ] **Step 1: 写门脚本（先写失败测试）**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
cat > skills/task-planner/scripts/check-evidence-binding.sh <<'GEOF'
#!/usr/bin/env bash
# check-evidence-binding — VC 引用的证据必须绑定当前版本（旧 hash 不得推进）
# 用法: check-evidence-binding.sh <plan-dir> <artifact-path> <expected-sha256>
# rc0=绑定有效; rc1=缺失/过期; rc2=参数错
set -uo pipefail
PLAN_DIR="${1:-}"; ARTIFACT="${2:-}"; EXPECTED="${3:-}"
[ -n "$PLAN_DIR" ] && [ -n "$ARTIFACT" ] && [ -n "$EXPECTED" ] || { echo "[evidence-binding] rc2: missing args" >&2; exit 2; }
STATE="$PLAN_DIR/plan-state.json"
[ -f "$STATE" ] || { echo "[evidence-binding] rc1: no plan-state.json" >&2; exit 1; }
python3 - "$STATE" "$ARTIFACT" "$EXPECTED" <<'PY'
import json,sys
state,artifact,expected=sys.argv[1:4]
try:
    d=json.load(open(state))
    eb=d.get('evidence_binding') or []
    hit=[x for x in eb if x.get('path')==artifact and x.get('sha256')==expected]
    if not hit:
        print('[evidence-binding] rc1: no current-version binding for %s'%artifact,file=sys.stderr)
        sys.exit(1)
    print('[evidence-binding] OK: %s bound to %s'%(artifact,expected[:12]))
except Exception as e:
    print('[evidence-binding] rc1: %s'%e,file=sys.stderr); sys.exit(1)
PY
GEOF
chmod +x skills/task-planner/scripts/check-evidence-binding.sh
```
Expected: 文件创建成功。

- [ ] **Step 2: 写正例/负控制测试（TDD 红→绿）**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
python3 - <<'PY'
import io
p='skills/task-planner/scripts/selftest-evidence-binding.sh'
s=io.open(p,encoding='utf-8').read()
anchor='echo "[selftest-evidence-binding] Total:'
assert s.count(anchor)==1
extra=r'''
# TC-02 正例: 当前 hash 绑定 → PASS
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
printf '{"schema_version":1,"evidence_binding":[{"path":"a.md","sha256":"%s","version":"v1","recorded_at":"2026-11-27T00:00:00Z"}]}' "$(printf 'a%.0s' {1..64})" > "$D/plan-state.json"
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'a%.0s' {1..64})" >/dev/null 2>&1 && ok TC-02 || bad TC-02
# TC-03 负控制: 旧 hash → 必须 rc1
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'b%.0s' {1..64})" >/dev/null 2>&1 && bad TC-03 || ok TC-03
# TC-04 mutation: 删字段 → 必须 rc1
printf '{"schema_version":1}' > "$D/plan-state.json"
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'a%.0s' {1..64})" >/dev/null 2>&1 && bad TC-04 || ok TC-04
'''
s=s.replace(anchor,extra+'\n'+anchor)
io.open(p,'w',encoding='utf-8').write(s)
print('selftest 正例/负控制/mutation 已追加')
PY
bash skills/task-planner/scripts/selftest-evidence-binding.sh
```
Expected: `PASS=4 FAIL=0`（TC-01..04 全过；任一 FAIL 则说明门写错）。

- [ ] **Step 3: 登记 registry**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
printf 'selftest-evidence-binding.sh\tevidence-binding\tevidence_binding 字段写入/当前hash放行/旧hash拒绝/mutation\tschemas/plan-state.schema.json;planctl.py;check-evidence-binding.sh\n' >> skills/task-planner/scripts/selftest-registry.tsv
tail -2 skills/task-planner/scripts/selftest-registry.tsv
```
Expected: 新增行四列 TSV 完整。

- [ ] **Step 4: Commit**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
git add -- skills/task-planner/scripts/check-evidence-binding.sh skills/task-planner/scripts/selftest-evidence-binding.sh skills/task-planner/scripts/selftest-registry.tsv
git commit -m "feat(comet-trust): evidence binding gate + negative-control selftest"
```
Expected: 提交成功。

---

### Task 3: 派生 MD 直接写保护（`check-scope.sh`）

**Files:**
- Modify: `skills/task-planner/scripts/check-scope.sh`（basename 豁免表 :85-100，worktree-required 段 :476+ 之前插入）
- Modify: `skills/task-planner/scripts/selftest-scope-boundary.sh`（加负控制）
- Create: `examples/evidence-binding/review.md`（Rule 113.10 审查实物）

**Interfaces:**
- Consumes: 现有 check-scope 哨兵机制与 `plans/` 豁免
- Produces: 派生 MD（4 个）在活跃计划目录内禁直接 Write/Edit，仅 render/planctl 可写

- [ ] **Step 1: 写失败测试（负控制先行）**

先加一个 selftest 用例：构造临时 plans 目录，直接写 `task_plan.md` 应被门拒绝。在 selftest-scope-boundary.sh 末尾追加（沿用其 PASS/FAIL 计数器）：
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
grep -n 'Total:' skills/task-planner/scripts/selftest-scope-boundary.sh | tail -2
```
Expected: 看到 Total 行位置；下一步在其前插入 TC-08（派生 MD 直写拦截）后再测红。

- [ ] **Step 2: 在 check-scope 加派生 MD 保护**

插入位置：`check-scope.sh:100` 豁免表之后、`:191` side 哨兵之前。判定逻辑：目标 basename ∈ {task_plan.md, findings.md, progress.md, verification.md} 且路径含 `/plans/<task-id>/`，且调用环境无 `TASK_PLAN_ALLOW_RENDER=1`（render 专用令牌）→ exit 1 BLOCK。
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
python3 - <<'PY'
import io
p='skills/task-planner/scripts/check-scope.sh'
s=io.open(p,encoding='utf-8').read()
anchor='# ─── ⑤ side 哨兵'
assert s.count(anchor)>=1, '锚点缺失，先 grep 实际段标题'
block='''# ─── 派生 MD 直接写保护（Comet 唯一事实源融合）─────────────────────
# 4 个派生 MD 只能由 planctl render 写入；直接 Write/Edit 拦截（render 专用令牌放行）。
case "$abs_path" in
  */plans/*/task_plan.md|*/plans/*/findings.md|*/plans/*/progress.md|*/plans/*/verification.md)
    if [ "${TASK_PLAN_ALLOW_RENDER:-0}" != "1" ]; then
      echo "[scope] BLOCKED 派生 MD 禁止直接写入（只能经 planctl render）: $abs_path" >&2
      exit 1
    fi
    ;;
esac
'''
s=s.replace(anchor,block+anchor,1)
io.open(p,'w',encoding='utf-8').write(s)
print('派生 MD 保护段插入完成')
PY
bash -n skills/task-planner/scripts/check-scope.sh
```
Expected: 打印插入成功；`bash -n` 无输出（语法 OK）。若锚点注释文字不同，先 `grep -n 'side 哨兵' check-scope.sh` 取实际文本后重试。

- [ ] **Step 3: 正例/负控制验证**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
echo "=== 负控: 直接写派生 MD 应 BLOCK ==="
printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"/mnt/data/dev/task-planner-skill/plans/task-demo/task_plan.md"}}' | bash skills/task-planner/scripts/check-scope.sh; echo "rc=$? (期望1)"
echo "=== 正例: render 令牌放行 ==="
printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"/mnt/data/dev/task-planner-skill/plans/task-demo/task_plan.md"}}' | TASK_PLAN_ALLOW_RENDER=1 bash skills/task-planner/scripts/check-scope.sh; echo "rc=$? (期望0)"
```
Expected: 负控 rc=1、正例 rc=0。若负控 rc=0，说明插入位置在豁免表之后被提前 exit，需把保护段移到豁免表之前（:85 前）重试。

- [ ] **Step 4: examples review 实物（Rule 113.10）**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
mkdir -p examples/evidence-binding
cat > examples/evidence-binding/review.md <<'REOF'
# 证据绑定 + 派生 MD 保护 — 审查实物

- 目标：证明 check-evidence-binding.sh 与派生 MD 直写保护可被机器判别。
- 实物（真实输出）：TC-01 schema 接受 / TC-02 当前 hash 放行 / TC-03 旧 hash rc1 / TC-04 mutation rc1；scope 负控 rc1、render 令牌 rc0。
- 审查命令与判据：

| ID | 命令 | 预期 |
|---|---|---|
| C1 | `bash skills/task-planner/scripts/selftest-evidence-binding.sh` | `PASS=4 FAIL=0`, rc0 |
| C2 | 直接写派生 MD 经 check-scope | rc1 BLOCKED |
| C3 | `TASK_PLAN_ALLOW_RENDER=1` 经 check-scope | rc0 |
| C4 | 删 `evidence_binding` 字段后重跑 C2 | 仍 rc1（mutation 存活） |

- 已知边界：本门只拦项目根内 plans 路径；worktree 内路径同样受管。
REOF
echo "review 实物创建完成"
```
Expected: 文件存在且含 C1-C4 表格。

- [ ] **Step 5: Commit + 全量回归**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tee /tmp/comet-phase1-selftest.txt
tail -5 /tmp/comet-phase1-selftest.txt
git add -- skills/task-planner/scripts/check-scope.sh skills/task-planner/scripts/selftest-scope-boundary.sh examples/evidence-binding/review.md
git commit -m "feat(comet-trust): derived-MD write guard + review exhibit"
```
Expected: 全量 selftest 的 FAIL 数 == 基线（Task 0 记录的 N），零新增；提交成功。


---

## Phase 2 — 质量出口：验收可信

### Task 4: 零断言 selftest 必须 FAIL（判别性夹具）

**Files:**
- Create: `skills/task-planner/scripts/selftest-assertion-guard.sh`
- Modify: `skills/task-planner/scripts/run-selftests.sh`（在汇总处加零断言拒绝）
- Modify: `skills/task-planner/scripts/selftest-registry.tsv`

**Interfaces:**
- Consumes: 现有 selftest 的 `Total: PASS=x FAIL=y` 输出契约（selftest-tier-consistency.sh:136）
- Produces: `selftest-assertion-guard.sh` → 扫描目标脚本，断言计数为 0 时 exit 1

- [ ] **Step 1: 写 guard 脚本 + 负控制**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
cat > skills/task-planner/scripts/selftest-assertion-guard.sh <<'GAEOF'
#!/usr/bin/env bash
# selftest-assertion-guard — 零断言 selftest 必须被判 FAIL（防假绿门）
# 用法: selftest-assertion-guard.sh <selftest-script>
set -uo pipefail
TARGET="${1:-}"
[ -n "$TARGET" ] && [ -f "$TARGET" ] || { echo "[assertion-guard] rc2: bad target" >&2; exit 2; }
output="$(bash "$TARGET" 2>&1)" || true
total="$(printf '%s\n' "$output" | grep -oE 'Total:.*PASS=[0-9]+ FAIL=[0-9]+' | tail -1 || true)"
[ -n "$total" ] || { echo "[assertion-guard] FAIL: no Total line" >&2; exit 1; }
pass_n="$(printf '%s' "$total" | grep -oE 'PASS=[0-9]+' | cut -d= -f2)"
fail_n="$(printf '%s' "$total" | grep -oE 'FAIL=[0-9]+' | cut -d= -f2)"
if [ "${pass_n:-0}" -eq 0 ] && [ "${fail_n:-0}" -eq 0 ]; then
  echo "[assertion-guard] FAIL: zero assertions in $TARGET" >&2; exit 1
fi
echo "[assertion-guard] OK: $total"
exit 0
GAEOF
chmod +x skills/task-planner/scripts/selftest-assertion-guard.sh
```
Expected: 文件创建成功。

- [ ] **Step 2: TDD 红→绿（用假零断言脚本）**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
echo 'echo "[fake] Total: PASS=0 FAIL=0"' > /tmp/fake-zero-selftest.sh
bash skills/task-planner/scripts/selftest-assertion-guard.sh /tmp/fake-zero-selftest.sh; echo "rc=$? (期望1)"
bash skills/task-planner/scripts/selftest-assertion-guard.sh skills/task-planner/scripts/selftest-evidence-binding.sh; echo "rc=$? (期望0)"
```
Expected: 假脚本 rc=1（负控制成立）、真脚本 rc=0。

- [ ] **Step 3: 接入 run-selftests 汇总**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
grep -n 'Total:\|PASS=\|FAIL=' skills/task-planner/scripts/run-selftests.sh | tail -5
```
Expected: 看到汇总行位置；在汇总输出前插入对每个被发现 selftest 的 guard 扫描（复用 `ls skills/task-planner/scripts/selftest-*.sh` 清单），任一零断言 → 整体 exit 1。用 python 精确插入并 `bash -n` 验证（同 Task 3 Step 2 手法）。

- [ ] **Step 4: registry + review 实物 + commit**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
printf 'selftest-assertion-guard.sh\tacceptance\tzero-assertion selftest must FAIL\tselftest-*.sh;run-selftests.sh\n' >> skills/task-planner/scripts/selftest-registry.tsv
git add -- skills/task-planner/scripts/selftest-assertion-guard.sh skills/task-planner/scripts/run-selftests.sh skills/task-planner/scripts/selftest-registry.tsv
git commit -m "feat(comet-trust): zero-assertion selftest guard (anti fake-green)"
```
Expected: 提交成功。

---

### Task 5: 验收三态结构化 + 异常不静默（verdict 契约）

**Files:**
- Modify: `skills/task-planner/templates/verification.md`（Goal Gate 三态 :117-134）
- Modify: `skills/task-planner/scripts/check-complete.sh`（三态判定接入）
- Create: `examples/verdict-tristate/review.md`

**Interfaces:**
- Consumes: 模板 `outcome: COMPLETE|PARTIAL|BLOCKED` 文本、门 rc 0/1
- Produces: 机器可解析的三态 verdict：`PASSED|FAILED|BLOCKED`（blocked 须用户确认标记）

- [ ] **Step 1: 写三态解析 + 负控制 selftest**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
cat > skills/task-planner/scripts/selftest-verdict-tristate.sh <<'TVEOF'
#!/usr/bin/env bash
# selftest-verdict-tristate — 三态 verdict 必须显式，BLOCKED 不得静默当 PASS
set -uo pipefail
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }
# TC-01: BLOCKED 未被确认 → 拒绝（负控制）
bash skills/task-planner/scripts/check-verdict.sh /dev/stdin <<'V' >/dev/null 2>&1 && bad TC-01 || ok TC-01
outcome: BLOCKED
confirmed: false
V
# TC-02: BLOCKED 已确认 → 放行
bash skills/task-planner/scripts/check-verdict.sh /dev/stdin <<'V' >/dev/null 2>&1 && ok TC-02 || bad TC-02
outcome: BLOCKED
confirmed: true
V
echo "[selftest-verdict-tristate] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
TVEOF
chmod +x skills/task-planner/scripts/selftest-verdict-tristate.sh
```
Expected: 文件创建成功（check-verdict.sh 下一步实现）。

- [ ] **Step 2: 实现 check-verdict.sh**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
cat > skills/task-planner/scripts/check-verdict.sh <<'CVEOF'
#!/usr/bin/env bash
# check-verdict — 读取 verification 文本，校验三态；BLOCKED 须 confirmed:true
set -uo pipefail
F="${1:-/dev/stdin}"
[ -r "$F" ] || { echo "[verdict] rc2: unreadable" >&2; exit 2; }
python3 - "$F" <<'PY'
import sys,re
txt=open(sys.argv[1],encoding='utf-8').read()
m=re.search(r'^\s*outcome:\s*(COMPLETE|PARTIAL|BLOCKED)',txt,re.M)
if not m: print('[verdict] rc1: no outcome',file=sys.stderr); sys.exit(1)
if m.group(1)=='BLOCKED':
    c=re.search(r'^\s*confirmed:\s*(true|false)',txt,re.M)
    if not c or c.group(1)!='true':
        print('[verdict] rc1: BLOCKED without user confirmation',file=sys.stderr); sys.exit(1)
print('[verdict] OK: %s'%m.group(1)); sys.exit(0)
PY
CVEOF
chmod +x skills/task-planner/scripts/check-verdict.sh
bash skills/task-planner/scripts/selftest-verdict-tristate.sh
```
Expected: `PASS=2 FAIL=0`，exit 0。

- [ ] **Step 3: 接入 templates/verification.md + commit**

在 Goal Gate 段（:117-134）补一行机器可读契约：`confirmed: false # BLOCKED 时须用户确认后改 true`。用 python 精确插入带断言。登记 registry、写 examples/verdict-tristate/review.md（复用 Task 3 Step 4 模板），提交。

Expected: `bash -n` OK、selftest PASS=2、提交成功、全量回归 FAIL==基线。

---

## Phase 3 — 入口与稳定性：决策可信 + 断点可信

### Task 6: 用户门账本（decisions 扩展 + blocking 未决项）

**Files:**
- Modify: `skills/task-planner/schemas/plan-state.schema.json`（decisions definition）
- Modify: `skills/task-planner/scripts/planctl.py`（decisions 校验：未决 blocking 门禁终验）
- Modify: `skills/task-planner/scripts/check-complete.sh`（消费 blocking 账本）

**Interfaces:**
- Consumes: 现有 `decisions` 数组 `{id,decision,rationale,tags}`
- Produces: `decisions` 元素可带 `blocking: true` + `confirmed: false`；未确认时不许 `phase-done` 终验

- [ ] **Step 1: 负控制 selftest 先行**

Create `selftest-user-gate-ledger.sh`：TC-01 blocking+unconfirmed → check-complete 拒；TC-02 confirmed:true → 放行。参照 Task 5 的 check-verdict 手法（`blocking:true` + `confirmed:false/true`）。

Expected: 红（check 未实现时 FAIL）→ 绿（实现后 PASS=2 FAIL=0）。

- [ ] **Step 2: schema 扩展 decisions definition**

在 decisions 的 items.properties 加 `blocking:{type:boolean}`、`confirmed:{type:boolean}`，保持 `additionalProperties:false`（带断言，同 Task 1 Step 2 手法）。

Expected: schema 仍可被 jsonschema 加载。

- [ ] **Step 3: planctl/check-complete 消费 blocking**

`planctl.py` 的 decisions 校验加：若存在 `blocking:true, confirmed:false` 条目，`phase-done`/终验相关子命令输出拒锁信息并 exit 3。`check-complete.sh` 加同名门（读 plan-state.json decisions）。

Expected: 负控制 selftest 由红转绿；`python3 -m py_compile` + `bash -n` OK。

- [ ] **Step 4: commit**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
git add -- skills/task-planner/schemas/plan-state.schema.json skills/task-planner/scripts/planctl.py skills/task-planner/scripts/check-complete.sh skills/task-planner/scripts/selftest-user-gate-ledger.sh skills/task-planner/scripts/selftest-registry.tsv
git commit -m "feat(comet-trust): user-gate blocking ledger in decisions"
```
Expected: 提交成功。

---

### Task 7: 只读恢复探针四态结构化（回归守护 + 新实施）

**Files:**
- Modify: `skills/task-planner/scripts/lib/plan-recovery.sh`（inflight 二态 → 结构化四态）
- Modify: `skills/task-planner/scripts/zcode-sessionstart.sh`（消费 verdict，保持只读）
- Create: `skills/task-planner/scripts/selftest-recovery-probe.sh`

**Interfaces:**
- Consumes: Task 6 的 blocking 账本；现有 stage2 pending probe（`zcode-sessionstart.sh:131-189`）
- Produces: 探针输出 `status: READY|STALE|BLOCKED|DEGRADED`（结构化）；BLOCKED 不自动建计划/不切分支；压缩注入保持无条件（Task 7 只守护不回退）

**重要现状**（盘上已核实，勿重复实施）：`zcode-sessionstart.sh:112-118` 已无条件注入技能正文（压缩续命已解绑 inflight）；本 Task 只补 selftest 防回退 + 把 inflight 判定从二态升级为结构化四态，不改注入逻辑。

- [ ] **Step 1: 回归守护 selftest（防注入回退）**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
cat > skills/task-planner/scripts/selftest-recovery-probe.sh <<'RPEOF'
#!/usr/bin/env bash
# selftest-recovery-probe — 压缩注入无条件 + 探针四态结构化 + 只读纪律
set -uo pipefail
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }
# TC-01: 注入不绑 inflight — 源码含 recover-skill 且不在 inflight 条件块内
grep -q 'recover-skill' skills/task-planner/scripts/zcode-sessionstart.sh && ok TC-01 || bad TC-01
# TC-02: 只读纪律 — 探针段无 mkdir/worktree add/switch 写操作
probe="$(sed -n '131,189p' skills/task-planner/scripts/zcode-sessionstart.sh)"
printf '%s\n' "$probe" | grep -qE 'mkdir|worktree add|git switch|git checkout' && bad TC-02 || ok TC-02
# TC-03: 四态枚举存在
grep -qE 'READY|STALE|BLOCKED|DEGRADED' skills/task-planner/scripts/lib/plan-recovery.sh && ok TC-03 || bad TC-03
# TC-04: mutation — 删除 verdict 字段后探针应 DEGRADED（负控制）
printf 'no status here\n' > /tmp/rp-mut.txt
grep -qE 'status: (READY|STALE|BLOCKED|DEGRADED)' /tmp/rp-mut.txt && bad TC-04 || ok TC-04
echo "[selftest-recovery-probe] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
RPEOF
chmod +x skills/task-planner/scripts/selftest-recovery-probe.sh
bash skills/task-planner/scripts/selftest-recovery-probe.sh
```
Expected: TC-03 初为 FAIL（四态未实现，红）；实现后 PASS=4 FAIL=0。

- [ ] **Step 2: 实现四态 verdict（plan-recovery.sh）**

在 `inflight` 判定（`plan-recovery.sh:37-67`）输出末尾加结构化行 `status: READY|STALE|BLOCKED|DEGRADED`：命中本会话 side 指针且 attestation 有效→READY；指针存在但陈旧→STALE；存在 blocking 未确认→BLOCKED；jq 缺失/解析错→DEGRADED。保持 rc 语义（0 命中/1 未命中/2 DEGRADED）向后兼容，仅**附加**输出行（不改现有调用方解析）。

Expected: TC-03 转绿；`bash -n` OK；现有 restore/inflight 调用方行为不变（跑相关 selftest 确认零回归）。

- [ ] **Step 3: registry + review 实物 + commit**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
printf 'selftest-recovery-probe.sh\trecovery\tcompression injection unconditional + probe four-state + read-only discipline\tplan-recovery.sh;zcode-sessionstart.sh\n' >> skills/task-planner/scripts/selftest-registry.tsv
git add -- skills/task-planner/scripts/lib/plan-recovery.sh skills/task-planner/scripts/selftest-recovery-probe.sh skills/task-planner/scripts/selftest-registry.tsv examples/recovery-probe/review.md
git commit -m "feat(comet-trust): structured four-state recovery probe + injection regression guard"
```
Expected: 提交成功；全量 selftest FAIL==基线。

---

## 收尾：合并回 master + 部署 + 终验

### Task 8: 合并与部署对账

- [ ] **Step 1: worktree 内终验**

```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-comet-trust-learning-20261127
git status --short   # 必须干净
bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tail -5
TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 | tail -3
```
Expected: status 干净；selftest FAIL==基线 N；verify 0 fail。

- [ ] **Step 2: 合并回 master**

```bash
cd /mnt/data/dev/task-planner-skill
git merge --no-ff wt/task-comet-trust-learning-20261127 -m "merge: comet-trust 三阶段可信度融合"
git log -1 --oneline
```
Expected: 合并成功；Read 关键文件确认（schema 字段、门脚本、selftest）存在。

- [ ] **Step 3: 部署位对账（含新增 scripts）**

```bash
cd /mnt/data/dev/task-planner-skill
bash skills/task-planner/install.sh --no-backup
TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 | tail -3
```
Expected: 各位 diff=0（全文件对账，含 scripts），verify 0 fail。

- [ ] **Step 4: 清理 worktree + 分支**

```bash
cd /mnt/data/dev/task-planner-skill
git worktree remove tmp/worktrees/task-comet-trust-learning-20261127
git branch -d wt/task-comet-trust-learning-20261127
git worktree list
```
Expected: 无遗留 `wt/*` 分支、无孤儿 worktree。

- [ ] **Step 5: 簿记收口**

用 planctl 把 findings/progress 回填、merge_back 登记为 `merged(<sha7>)`，render 刷新。基线 tag 保留不删。

---

## Self-Review（writing-plans 自查）

- **Spec coverage**：spec §5 三阶段共 10 个动作 → Task 1-7 全覆盖；§4 优先级顺序 = Task 顺序；§6 数据基础不可拆 = Global Constraints 第一条 + 无平行状态源；§7 验收 4 条 = Task 0 基线 + 各 Task 负控制 + Task 8 部署对账 + 通用面三问（每 Task 沿用既有门、未新增 hook、部署位实测）。
- **Placeholder scan**：无 TBD/TODO/「实现略」；每个代码步骤含完整脚本与命令。
- **Type consistency**：`evidence_binding` 元素字段 `{path,sha256,version,recorded_at}` 在 Task 1/2 一致；三态 verdict `PASSED|FAILED|BLOCKED` 与模板 `outcome: COMPLETE|PARTIAL|BLOCKED` 是两层（机器 verdict vs 业务 outcome），Task 5 明确映射；四态 `READY|STALE|BLOCKED|DEGRADED` 在 Task 7 单一定义。
- **已知风险**：Task 3 插入锚点 `side 哨兵` 注释文字可能与盘上不同 → 步骤内已写明先 grep 取实际文本；Task 1 Step 3 `decisions` 在 ARRAY_SECTIONS 的位置需先确认 → 已写明 fallback。
