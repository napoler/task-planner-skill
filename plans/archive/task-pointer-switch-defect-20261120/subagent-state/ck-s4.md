# Checkpoint S4 — selftest-pointer-lifecycle.sh 扩展 PL-11..PL-14 行为断言（G1/G3/G4，VC-5）

## 1. task_id
task-pointer-switch-defect-20261120 / Phase 3 / S4

## 2. status
done

## 3. summary
在 worktree `wt/task-pointer-switch-defect-20261120` 内**仅修改** `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（git diff：1 file changed, 80 insertions(+), 5 deletions(-)），在既有 PL-01..PL-10 之后新增四条回归断言 PL-11..PL-14，把 P1/P2 已修的四类场景固化为守护：PL-11 init 一次切换（G1）、PL-12 非加粗不漏判（G3/G4）、PL-13 注释/散文不误拦 fail-open（G3）、PL-14 fallback 身份门控保留（G1，静态断言）。同步把头部注释 `PL-01..10` 措辞改为 `PL-01..14`、静态/行为断言计数改为 8/6、Total 改为 14；新增 `INIT` 变量指向同目录 `init-session.sh`。夹具沿用既有 `$TMP`（mktemp -d + EXIT trap），每条独立子目录 p11/p12/p13 + 不同随机 sid 前缀（pl11/pl12/pl13），目标计划均含 task_plan.md。全部失败消息含场景名与断言号，注释 What+Why 标注 2026-11-20 / task-pointer-switch-defect-20261120 / G1-G3-G4 映射。未新建任何脚本文件。

## 4. findings（断言清单 + 行号，worktree 内 selftest-pointer-lifecycle.sh）
- `:2-7` 头部注释：`PL-01..10` → `PL-01..14`；静态断言 7→8（+PL-14 静态锚）、行为断言 3→6（+PL-11/12/13）；保留 F1-F5 守护说明。
- `:15` 新增 `INIT="$SCRIPT_DIR/init-session.sh"`（PL-11 与 PL-14 需要的同目录脚本路径）。
- `:100-107` 新增区块 What+Why 注释：记录四类场景对应 G1/G3/G4、回退风险（skip 静默失切 / 全文裸匹配误伤 / fallback 覆写他会话 side 键）、夹具隔离范式（mktemp -d + trap + 独立子目录 + 不同 sid 前缀 + 目标计划含 task_plan.md）。
- `:109-125` **PL-11 [G1] init 一次切换**：夹具 old-claimant（加粗 `- **Status:** in_progress` + `owner=sess$SID11`）+ new-switch-task 目录；`export CLAUDE_CODE_SESSION_ID` 后 cd new-task 跑 init（`:116`）。判据（`:118-121`）= side 键内容 `new-switch-task`（`:117`）且输出含「明确切换意图」「old-claimant」且无「skip 写入」；ok/bad 在 `:122/:124`。
- `:127-141` **PL-12 [G3/G4] 非加粗不漏判**：claimant=`- Status: in_progress`（非加粗）+ owner，目标 target-12 含 task_plan.md。判据（`:136-139`）= 输出含「指针未切换」且 side≠target（文件不存在或内容非 target-12）；ok/bad 在 `:138/:140`。
- `:143-159` **PL-13 [G3] 注释/散文不误拦**：claimant 仅注释行 `<!-- 历史注释 Status: in_progress 仅说明 -->` + 散文行 `- Update phase status as you progress: pending → in_progress → complete` + `- **Status:** complete`。判据（`:154-155`）= side=`target-13`（fail-open 写入成功）且输出无「指针未切换」；ok/bad 在 `:156/:158`。
- `:161-170` **PL-14 [G1] fallback 门控保留（静态断言）**：`cnt '_sid_fallback=1' "$INIT"` 与 `cnt '会话 id 未确定' "$INIT"` 各 ≥1（`:165-166`）；注释说明伪造 freshness fallback（无 sidmap + 抢用 ≤120s 他会话哨兵）成本高且脆弱故降级静态锚，守住 D3 覆写防护语义；ok/bad 在 `:167/:169`。
- `:172` Total 语义随计数：`echo "Total: 14 PASS=$PASS FAIL=$FAIL"`；`:173` exit 规则不变。

## 5. evidence（selftest 输出尾部 + 语法 + diff + 非空洞性 + VC-5）
### 5.1 bash -n
```
bash -n <selftest> => SYNTAX_OK
```

### 5.2 完整 selftest 输出（worktree 原路径，3 次重跑一致）
```
PASS PL-01 gc 源码含全局生命周期分支（stale/dead-ref/completed-ttl 锚在位）
PASS PL-02 gc 源码含哨兵-side 缺口巡检
PASS PL-03 set 源码含所有权守卫（.session-owner 扫描在位）
PASS PL-04 set 分支 ROOT 默认 $PWD（positional[1]:-$PWD 锚在位）
PASS PL-05 deploy 段含 staging 与 post-verify（stage=2, diff-r=3）
PASS PL-06 check-complete 移交提醒在位（stderr 通道锚已校验）
PASS PL-07 SKILL.md 含指针清理纪律行（会话隔离指针 bullet 的 gc 清扫措辞承载）
PASS PL-08 set ROOT 回归（计划目录内 set exit 0, side 指针写入）
PASS PL-09 stale 夹具 gc（dead-ref + completed-ttl 双场景, 输出含 stale 且指针置空）
PASS PL-10 所有权守卫（假 claimant in_progress → skip 写入 + WARN 含 claimant 键名; --force 覆盖写入）
PASS PL-11 init 一次切换（G1: 同 sid 在途 claimant → 通告+直写 side=new-switch-task, 无 skip）
PASS PL-12 非加粗不漏判（G3/G4: - Status: in_progress 命中守卫, 输出指针未切换且 side≠target）
PASS PL-13 注释/散文不误拦（G3: 注释+散文含字样但状态 complete → fail-open 写入 side=target）
PASS PL-14 fallback 门控保留（G1: 静态锚 _sid_fallback=1 + 「会话 id 未确定」WARN 在位）
Total: 14 PASS=14 FAIL=0
```
计数：`PASS PL-01..10 = 10`、`PASS PL-11..14 = 4`、`FAIL 行 = 0`、selftest rc=0。

### 5.3 非空洞性（变异测试，临时副本在 /tmp，未触碰 worktree）
全目录 `cp -a` 副本基线 = 14 PASS/FAIL=0；逐项回退修复后对应断言均转 FAIL（各 PASS=13 FAIL=1）：
- 回退 init「明确切换意图」文案 → `FAIL PL-11 ... side=new-switch-task`（通告判据生效）。
- 回退 set「指针未切换」文案 → `FAIL PL-12 ... OUT=[... OLD_SKIP_WORD ...]`。
- set 守卫改回松散全文匹配（line278 → `grep -q in_progress ...`）→ `FAIL PL-13 ... 被...声明 skip 写入`（散文误拦被抓住）。
- 移除 `_sid_fallback=1` 标记 → `FAIL PL-14 ... 缺 _sid_fallback=1 或未确定 WARN 锚`。
> 附注：首次变异测试仅复制 `*.sh` 导致 init 找不到 `templates/`（输出 "no template found, skipping"）而 PL-11 假失败；改为全目录 `cp -a` 后基线 14 PASS 全绿，确认该假失败为测试副本构造缺陷，非断言缺陷。

### 5.4 git diff 范围
```
worktree status ->  M SKILL.md / M init-session.sh / M selftest-pointer-lifecycle.sh / M set-active-plan.sh（无 untracked / 无新增脚本）
git diff --stat -- selftest-pointer-lifecycle.sh -> 1 file changed, 80 insertions(+), 5 deletions(-)
```
S4 本单元改动仅 selftest-pointer-lifecycle.sh；另三项为 S1/S2/S3 既有变更，本单元未触碰。

### 5.5 VC-5 官方门禁（verification.md:33）
PASS：`grep -Eq "PL-1[1-9]"` 命中；`FAIL=0`；`PASS PL-0x|10 >= 10`；`PASS PL-1x >= 4`；scope `BAD=[]`。

## 6. next_steps
- 主进程复核本 diff 与行号锚，回填 progress.md Phase 3 / task_plan.md S4 状态与 findings.md VC-5 结论。
- S4b（Phase 3）执行 VC-1~VC-5 全量证据采集（verification.md 官方命令），本单元仅覆盖 selftest 扩展与 VC-5 selftest 面。
- Phase 4 合并回时须把 selftest 改动与 S1/S2/S3 同批带上，并复核部署位同步。

## 7. risks
- PL-14 为静态断言（按 prompt 允许降级），只验 `_sid_fallback=1` 与「会话 id 未确定」锚存在，不执行真实 freshness fallback 行为；真实抢用他会话哨兵场景仍依赖 VC-1 手工夹具与非空洞性变异测试旁证。
- PL-11 依赖 init-session.sh 能在夹具目录完成模板渲染（需同目录 templates/）；worktree 完整目录下已实测 3 次全绿，若后续剥离模板资源会导致假失败（已在 5.3 附注记录判别方法）。
- 不同 sid 前缀（pl11/pl12/pl13）+ 独立 $TMP 子目录已消除 claimant glob 首命中互扰；若未来新增 PL-1x 断言需沿用该隔离范式。

## 8. handoff
checkpoint: yes — /mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/subagent-state/ck-s4.md
