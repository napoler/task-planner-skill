# [sub:10-executor] Phase 4 S3: selftest-dispatch.sh 检查点

## 任务
新建 scripts/selftest-dispatch.sh（hermetic，11 用例，Total/PASS/FAIL 汇总，FAIL>0 exit 1）

## 参照读取（done）
- selftest-delegation.sh L1-60: mktemp -d + trap + PASS/FAIL 计数 + RESULTS 汇总风格
- check-dispatch.sh 全文: pretool/check 双入口, scan_missing 7 key, 档位链 env→config.json, fail-open 语义
- zcode-pretooluse.sh L54-66: Agent 分支 prompt→mktemp→check-dispatch pretool, rc=2 透传 exit 2

## 里程碑
- [x] 参照读取完成（selftest-delegation 风格 / check-dispatch 接口 / hook Agent 分支）
- [x] Write selftest-dispatch.sh v1（11 用例）→ 首轮运行 FAIL=3（T05/T06/T09）
- [x] 根因 1:run_case 里 `export A=1 B=2` 复合行在 `set -u` 下 B 引用未展开 → 改 `;` 分行
- [x] 根因 2:管道前缀 `VAR=x printf|cmd` 只对 printf 生效,env 传不到 hook 子进程 → T09/T10 改 sh -c + export
- [x] 根因 3:T08 期望「缺 2 项」但 T08 prompt 同时去 progress.md+checkpoint: 还残留其他项缺 → 补回 subagent-state/ 行使缺项恰 2
- [x] 档位语义定稿:enforce 硬覆盖;warn/off/unset 沿用外层(外层 off 反验时 T05 恰 FAIL=1,满足验收 3 非恒真)
- [x] 全量验收 11/11 PASS;off 反验 FAIL=1;wc -l=121 ≤150;grep 硬路径=0;plans/ 零 dirty;chmod +x;临时 scratch 文件 /tmp/offout.txt 已删
- [x] findings.md `#### [sub:10-executor]` 小节 + progress.md `[sub:10]` 行已写

## 最终结论
- status: done
- 交付: /mnt/data/dev/task-planner-skill-worktrees/task-v057-subagent-io-contract/skills/task-planner/scripts/selftest-dispatch.sh (+121 行, -0;chmod +x)
- 验收: 5/5 PASS(A1 bash-n+wc121 / A2 11-11 exit0 / A3 off 反验 FAIL=1 / A4 plans dirty=0 + trap 清理 / A5 硬路径 grep=0)
- 证据: bash selftest-dispatch.sh → "Total: 11 PASS=11 FAIL=0" EXIT=0; TASK_PLANNER_DISPATCH_ENFORCE=off 同命令 → "Total: 11 PASS=10 FAIL=1"
- 副作用: 仅 findings.md 插入 3 行小节 + progress.md 追加 1 行;未触碰既有脚本;scratch /tmp/offout.txt 已 rm
- blockers: none
- 备注: T09 规格写 `unset TASK_PLANNER_PLAN_DIR` + `cd $TMP/nowhere` 防哨兵,但 hook 内 check-dispatch 需要 PLAN_DIR 指向 $PLAN 才走到缺项判定,故 T09 用 PLAN_DIR=$PLAN(仍 cd nowhere 防哨兵),语义等价且与 T07(fail-open)不重复
