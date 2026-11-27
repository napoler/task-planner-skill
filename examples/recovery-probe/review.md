# recovery-probe 审查实物（Task 7 / 只读恢复探针四态）

## 目标

把压缩恢复探针从二态（命中/未命中/无 jq）升级为结构化四态 `READY|STALE|BLOCKED|DEGRADED`，同时守护 2026-11-24 已落地的「技能正文无条件注入」与 Rule 119「stage2-pending 只读探针」不被回退。本实物给出可复现的正例、负控制与审查命令。

## 实物

### 1. 四态 verdict 输出（lib/plan-recovery.sh 新增独立子命令）

下列为 `bash skills/task-planner/scripts/lib/plan-recovery.sh verdict <root> sess-rp01` 的真实输出形态（`sidkey=rp01`）：

```text
# READY：本会话 side 指针命中 + Status 行在途 + attestation 有效
status: READY            rc=0

# STALE：attestation 破锁（或指针不存在/终态/Status 行失效）
status: STALE            rc=1

# BLOCKED：decisions 有 blocking:true,confirmed:false（用户门未决）
status: BLOCKED          rc=0

# DEGRADED：plan-state.json 解析失败（或 jq 缺失）
status: DEGRADED         rc=2
```

判别顺序 `DEGRADED > BLOCKED > STALE > READY`；`inflight` 的 stdout（计划目录绝对路径）与 rc 0/1/2 **逐字节不变**，四态以独立子命令的附加输出行提供，避免破坏 `selftest-compact-recovery` T12/T13 的金样契约与 hook 单行 JSON 契约。BLOCKED 仅表示用户门未决，不改变「指针有效」的 rc 0；探针全程只读，不建计划、不切分支、不写状态。

### 2. selftest RED → GREEN

```text
# 实现前（verdict 子命令尚不存在）
FAIL TC-03 READY    verdict 期望 status:READY rc=0，实测 out=[] rc=2
FAIL TC-03 STALE    verdict 期望 status:STALE rc=1，实测 out=[] rc=2
FAIL TC-03 BLOCKED  verdict 期望 status:BLOCKED rc=0，实测 out=[] rc=2
FAIL TC-03 DEGRADED verdict 期望 status:DEGRADED rc=2，实测 out=[] rc=2
PASS TC-01 / PASS TC-02 / PASS TC-04（负控制）  → Total: PASS=3 FAIL=4，rc=1

# 实现后
PASS TC-01 无在途指针仍无条件注入技能正文（防注入回退）
PASS TC-02 stage2 探针只读（无执行写命令/文件系统零变化，提示文本不算写操作）
  TC-03-READY OK status=READY rc=0
  TC-03-STALE OK status=STALE rc=1
  TC-03-BLOCKED OK status=BLOCKED rc=0
  TC-03-DEGR OK status=DEGRADED rc=2
PASS TC-03 四态结构化 ... 兼容
PASS TC-04 mutation 判别性成立（删 verdict 行后不再报 READY）
[selftest-recovery-probe] Total: PASS=4 FAIL=0，rc=0
```

四态四例合并为 brief 口径的单个 TC-03 断言，明细行逐例打印；TC-04 用 `sed` 抹掉 `lib` 副本中的 `printf 'status: %s\n'` 后要求不再报 READY，证明 TC-03 非恒真。

### 3. 注入段零改动（TC-01 静态 + 哈希对照）

```text
git diff HEAD -- skills/task-planner/scripts/zcode-sessionstart.sh   → 空
git show HEAD:.../zcode-sessionstart.sh | sed -n '112,118p' | sha256sum
   = de4fac4f50aac4f368b99bb85269b07687209bd141ade3372f823b2cefe1cb0f
       sed -n '112,118p' .../zcode-sessionstart.sh | sha256sum
   = de4fac4f50aac4f368b99bb85269b07687209bd141ade3372f823b2cefe1cb0f
```

TC-01 另做行为级守护：无 side 指针的夹具跑 hook，注入内容须含 `【技能正文·开始】` 且末行为 `【技能正文·结束】`（pipefail 下用 `grep -F >/dev/null` 而非 `grep -q` 读全量，避免 SIGPIPE 假 FAIL）。

### 4. 只读纪律（TC-02）

```text
夹具: <root>/plans/.tags-index.json = {"followup-of:task-x":["task-x"]}，无 task-x-rc/
hook 注入: [stage2-pending] 出现且含 task-x（证明探针确实触发）
静态: 探针段（marker → PYPROBE）无行首 mkdir / git worktree add / git switch / git checkout，
      无 subprocess / os.system / os.mkdir / makedirs / shutil / .write(
行为: hook 前后 find 快照（排除 init 自身哨兵 .plan_required_side / .active_plan_side）逐字节相同，
      未产生 plans/task-x-rc/，git worktree / branch 零变化
```

**与 brief 逐字断言的差异（已登记）**：brief 的 TC-02 用裸 `grep -E 'mkdir|worktree add|...'` 扫 `sed -n 131,189p`，会命中 `zcode-sessionstart.sh:180` 中**打印给用户的 Rule 119 action 提示串**（该提示是 examples/stage-advance/review.md 的既有契约），属假阳性。本实现改判「实际执行的写命令 + 文件系统快照」，语义更严且不改 Rule 119 输出。

## 审查命令（C-R1..C-R6）

| ID | 命令（仓库/worktree 根执行） | 预期 |
|---|---|---|
| C-R1 | `bash skills/task-planner/scripts/selftest-recovery-probe.sh` | `PASS=4 FAIL=0`，rc=0 |
| C-R2 | 按上表四态夹具运行 `bash skills/task-planner/scripts/lib/plan-recovery.sh verdict <root> sess-rp01` | 四行分别为 `status: READY/STALE/BLOCKED/DEGRADED`，rc=0/1/0/2 |
| C-R3 | `sed "s/printf 'status: %s\\\\n'/printf 'MUTATED: %s\\\\n'/" skills/task-planner/scripts/lib/plan-recovery.sh > /tmp/lib-mut.sh && bash /tmp/lib-mut.sh verdict <READY-root> sess-rp01` | 输出不含 `status: READY`（负控制可证伪） |
| C-R4 | `git diff HEAD -- skills/task-planner/scripts/zcode-sessionstart.sh` | 空（含 :112-118 注入段） |
| C-R5 | `bash skills/task-planner/scripts/selftest-compact-recovery.sh` 与 `selftest-stage-advance.sh` | 分别 `40 PASS/0 FAIL`、`8 PASS/0 FAIL`（既有调用方零回归） |
| C-R6 | `bash skills/task-planner/scripts/selftest-registry.sh` 与 `selftest-assertion-guard.sh skills/task-planner/scripts/selftest-recovery-probe.sh` | registry 行数=实际 selftest 数；guard `OK`（非零断言假绿） |

## 已知边界

- 无 side 指针 / 指针指向终态计划时统一报 STALE（四态内没有独立的「无计划」态）；存量计划无 `.plan-attestation` 视为兼容 READY，破锁才降 STALE。
- `verdict` 需要 jq；jq 缺失 → `status: DEGRADED` + rc 2（与既有 lib 的 DEGRADED=no-jq 口径一致，调用方 fail-open）。
- hook 本轮按显式约束零改动：verdict 是 opt-in 子命令，未接入 stdout（避免破坏单行 JSON 与「技能正文结束标记必须末行」契约）；注入回归由 TC-01 守护。
- 基线 FAIL 集 `{dispatch, enumerate-first, execution-stability}` 直接实跑仍为 1/1/2 个 FAIL，未新增。
