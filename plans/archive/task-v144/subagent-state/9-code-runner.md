# sub:9-code-runner checkpoint (Rule 22.8)
status: done
task: task-v144 S9 — worktree 全量 selftest 回归跑批（所有 selftest-*.sh）+ master 对照

## 执行口径（可复现）
- worktree 批：`for f in <wt>/skills/task-planner/scripts/selftest-*.sh; do TMPDIR=<scratch> timeout -k 5 120 bash "$f"; done`
  - cwd 剥离到 /tmp/tp144/wt-tmp（脚本均 SCRIPT_DIR 自定位，cwd 无关）；TMPDIR 隔离；每脚本 timeout 120s
  - 批脚本: /tmp/tp144/run-batch.sh；汇总: /tmp/tp144/wt-out/summary.tsv；逐脚本日志: /tmp/tp144/wt-out/logs/
- master 对照批（da1f308）：同口径跑 /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ → /tmp/tp144/master-out/
- 新守护单跑复核：`bash scripts/selftest-subagent-granularity-skill-escort.sh` → `Total: 23 PASS=23 FAIL=0` rc=0

## 批跑规模与结果
- worktree 57 脚本（含新脚本, 不含 master 独有 selftest-evidence-goal-gate.sh）：rc=0 × 40，rc=1 × 17
- master 57 脚本（含 selftest-evidence-goal-gate.sh 21/21 PASS, 不含新脚本）：rc=0 × 42，rc=1 × 15
- worktree 17 个 rc=1 中：9 个与 master 逐行败绩相同（存量）；8 个含 worktree-only 断言失败（master 同断言 PASS）
- 无任何「worktree PASS 而 master FAIL」脚本（master rc=1 集 ⊂ worktree rc=1 集）
- 验收③达成：selftest-subagent-granularity-skill-escort.sh 在列且 `Total: 23 PASS=23 FAIL=0`

## 逐脚本原文行（57 行，主进程可机械求和）
见 /tmp/tp144/wt-acceptance-lines.txt（同文已入 findings.md §[sub:9]）。关键：
- selftest-subagent-granularity-skill-escort.sh rc=0 :: Total: 23 PASS=23 FAIL=0

## 归属分析（双跑定位：存量 vs 回归）
### A. 存量（worktree 与 master FAIL 行逐行相同）— 15 脚本涉存 | 其中 9 脚本纯存量
根因簇1 = config.properties 断言「应 40」而实键 42（worktree/master config.json `diff` IDENTICAL，两侧同败）：
  AC-07 / RT-09 / CP-16 / MA-10 / MD-08 / R-12 / RG-07 / IP-15 / LA-14 / RC-13 / SR-09 / TS-12 / WF-12（13 组断言，横跨 13 脚本）
根因簇2 = selftest-periodic-review.sh 未登记 registry（两侧 registry rows=56 actual=57 同）：
  selftest-registry.sh T02；selftest-self-resolution.sh SR-12；selftest-periodic-review.sh PR-09
根因簇3 = selftest-periodic-review.sh 自身 PR-03/04/05/10（Rule 57 检查维度/纠正机制/开关键/C39 缺失）+ requirement-coverage RC-15（critical-rules '56.'=5 应 0）——两侧同败

### B. worktree-only 失败（8 脚本，master 同断言 PASS）— 需主进程裁决
① knowledge-brief 六段化未级联（v144 S4 新增 §6 直接后果）— 2 脚本：
   - selftest-knowledge-brief.sh T1b `[FAIL] T1b 五段标题 grep -c '^## §' = 5`（断言 `-eq 5`；实 6）
   - selftest-execution-stability.sh T10a `[FAIL] T10a knowledge-brief.md 五段 grep -c '^## §' = 5`
   - 取证：`grep -c '^## §'`：base a7c01a8=5 / master=5 / worktree=6（§6 行 L71）；base/master 均 PASS
② SKILL.md 'Rules 1-39' 锚漂移（v144 S2 把 References 行 `Critical Rules 1-39`→`Critical Rules 1-59`）— 5 脚本：
   - selftest-tool-selection.sh TS-05 / selftest-self-resolution.sh SR-07 / selftest-lane-advancement.sh LA-12 / selftest-requirement-coverage.sh RC-11 / selftest-workflow-orchestration.sh WF-10（'1-39'+'1-45' 和=5<6）
   - 取证：`grep -c 'Rules 1-39' SKILL.md`：base=2 / master=2 / worktree=1（worktree L271 保留、L338 被 S2 改为 1-59）
③ selftest-iteration-persistence.sh IP-14（`57 块尾「58.x」=8（应 =0）`）— 基线自带缺口，非 v144 引入：
   - base（v142 提交）+ worktree 脚本同为负断言 58.x=0；base/worktree critical-rules 57.4 之后 58.x=8（v142 Rule 58 块）→ base 即败
   - master 侧脚本已由 v143 级联为 59.x=0（master 59 号空缺）→ PASS
   - 前向风险：worktree 57.4 之后 `^59\.[0-9] `=8（v144 Rule 59 块）；master 版断言（59.x=0）若原样用于合并后树将必 FAIL → 需同 v143 范式再级联

## 其它观察
- master 独有 selftest-evidence-goal-gate.sh（task-v143 产物）不在 worktree 分支 → 不在本次 57 对照面；合并时 registry 行（master 行 57）与本分支新行并需并存
- worktree registry 相对 master 仅行 57 不同（各自登记本任务新脚本）
- 脚本写面核查：全部 fixture 落 mktemp/$TMPDIR（grep 验证无仓库相对路径写入）；worktree git status 跑批前后一致（M×7 + ??×2 均为 S1-S8 既有产物）

## 负结果
- 未修复任何 FAIL（Scope 禁改）；未 git add/commit 任何仓库；未 stash/checkout
- 未发现 worktree PASS / master FAIL 的反向回归
- 未发现脚本级挂起/超时（最长 selftest-final-gate-hash 17.0s，远低于 120s 上限）
- 未验证（超范围）：merge 后 master 版 IP-14 对新树的必败性仅手工同口径 grep 复算（59.x=8），未实际合并验证
