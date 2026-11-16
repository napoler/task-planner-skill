# fix-R5 — 检查点（Plan Writer 修复轮 5）

- 轮次: R5 修复轮（REJECTED 8 发现 → 增量修订）
- 执行体: plan-writer（独立上下文）
- 开始时间: 2026-11-17T03:44:11+08:00
- 完成时间: 2026-11-17T04:0x+08:00
- 工作目录: /mnt/data/dev/task-planner-skill
- 任务书: plans/task-auditgate-machine-20261116/subagent-state/fix-R5-prompt.md
- 输入: progress.md [plan-audit-R5] 段 + subagent-state/audit-R5.md + 计划三文件
- 范围: 仅 plans/task-auditgate-machine-20261116/ 六文件 + 本检查点；禁碰 skills/**、其他目录、仓库脚本
- 环境事实: uid=1000（非 root，chmod 000 不可读态可测）；config.json 存在（28659 B，`"audit` 命中 0）
- 状态: DONE

## 逐项处置（全部实际 Edit 落盘，grep -n 可定位）

| 编号 | 处置 | 落点 |
|------|------|------|
| C-1[CRITICAL] | VC-2 Verify command 断言捕获时点重排：负例断言组紧跟 `r1`（`n=$?`，位于 awk fixture 与正例执行之前），正例断言组紧跟 `r2`（`p=$?`），末尾仅汇总；其余元素（双处清缓存/awk fixture/enforce env/`rm -rf "$T"`）保留；Evidence 增断言时点说明 | `verification.md:21`（命令）、`verification.md:20`（Evidence） |
| I-1[IMPORTANT] | VC-6 首段删除段锚 awk，改全文件严格 token 正则 `^\[scope-check\] <ISO8601> SCOPE-OK diff=N untracked=N$`（S2 的 `echo ... >> "$PROG"` 形态不变）；判据/Evidence/Notes 口径同步；progress.md Phase 5 段补槽位说明行 | `verification.md:35,36,37`、`task_plan.md:296,306,310,407`、`progress.md:69` |
| W-1[W] | 漂移条款加防滥用双闸（逐名归因 + 漂移后重走 critic 文本审计），`[baseline-shift]` 行格式扩为含逐名归因/重跑依据/critic 复审结论 | `task_plan.md:253`、`task_plan.md:408`、`verification.md:36` |
| W-2[W] | 5-Question Reboot Check 四行 + 交叉验证记录同步当前实态（R1-R4 修复+4b 完成+R5 修复轮 5 / R6 复审为下一步） | `verification.md:207-211`、`verification.md:198` |
| Q-1[Q] | V-1.1 加时点注记（仅 Phase 1 时点；Phase 3 后失效；终验不复跑本 gate），注记落条目标签行以保持 Verify command 可复跑 | `verification.md:53` |
| N-1[NIT] | config 断言改显式 rc 捕获组（found→0 败 / not found→1 过 / error→2 败 fail-closed），`test -f` 保留 | `verification.md:37` |
| N-2[NIT] | 历史段行尾括注（行号后移 → task_plan.md:296/:306） | `progress.md:177` |
| N-3[NIT] | 历史段行尾指针（已由 R4b 处置：同集零增量+基线冻结） | `progress.md:196` |

附带：`findings.md` R5 处置对照表 + Issues 行 + R4 I-1 行 superseded 指针；`knowledge-brief.md` §4-13 改全文件 token 口径 + 新增 §9（五条教训）；`notepad-learnings.md` R5 Verification Results / 五条通用规则 / Files Modified / 段锚形态 superseded 指针；`task_plan.md:205,:209` 簿记同步 R5 态。

## 实测输出（/tmp/r5t，真实执行）

### C-1（mock attest；命令正文逐字提取自 verification.md:21，仅替换 `A=` 路径）
```
VERDICT tag=old mock=attest-mock          rc=1    # 旧形态：正例已建锁 → n=1 → 无 PASS 路径
VERDICT tag=old mock=attest-mock-broken   rc=1
VERDICT tag=new mock=attest-mock          rc=0
VERDICT tag=new mock=attest-mock-broken   rc=1    # 破坏变体（负例也建锁）被 test ! -f 抓到
SUBVALS      r1=1 n=0 r2=0 p=0                     rc=0
SUBVALS-OLD  r1=1 n=1 r2=0 p=0                     rc=1
```

### I-1（严格 token 正则；六态）
```
STATE p0（现状，无留痕）          rc=1
STATE p1（Phase 5 段末插入）      rc=0
STATE p2（EOF 追加 = S2 真实形态） rc=0
STATE p3a（缺 SCOPE-OK）          rc=1
STATE p3b（缺 diff=N）            rc=1
STATE p3c（带 "- " 前缀）         rc=1
```
端到端（verification.md:37 原文，仅替换 `P=` 与 run-selftests 路径为 mock）：TC-A 正向 rc=0 / TC-B 去留痕 rc=1 / TC-C 假 FAIL 名 rc=1；`bash -n` vc6 rc=0、vc2 rc=0。

### N-1（三态 + 新旧形态对照）
```
STATE cfg-key        NEW rc=1 | OLD rc=1 | grep_raw=0
STATE cfg-nokey      NEW rc=0 | OLD rc=0 | grep_raw=1
STATE cfg-unreadable NEW rc=1 | OLD rc=0 | grep_raw=2   # 旧形态 fail-open 确证
端到端（VC-6 命令 + chmod 000 config）rc=1；对照真实 config rc=0
```

## 三约束自证
- ① R1-R3 逐字锚 `task_plan.md:16-18` 逐字未动。
- ② `user-session-log.md` mtime 仍 `2026-11-16 23:39:23.409788871 +0800`（4355 B）。
- ③ `progress.md` 无审计段级 `结论: **APPROVED**` 预写（5 处命中均为占位段规则说明/「仍无预写」自述句）；`[plan-audit-R1..R5]` 结论行均 REJECTED。

## 八机械门真实 rc（2026-11-17 修复轮 5 末复跑）
```
check-plan-dispatch.sh     rc=0  （2 条非阻断 WARN + ✓ 4 个派发型 Phase 均有带执行体 S-unit 表）
check-delegation.sh stats  rc=0  verdict=ok rate=0.800 violations=[]
check-rvc-coverage.sh      rc=0  ✓ R=3 VC=6 映射行=3
check-vc-nonvacuous.sh     rc=0  ✓ 6 条 VC 无真空命令
check-template-type.sh     rc=0  OK template_type=rule-enhancement
check-tier-consistency.sh  rc=0  ✓ standard/L1; lines=477 phases=5 vc=6 sunit=0 scope=4
check-step-placeholders.sh rc=0  ✓ 扫描 checkbox 步骤 22 行
check-goal-cjk.sh          rc=0  ✓ 16 个 CJK 词
```

## 未改
`skills/**`（保护区）、`user-session-log.md`、其他计划目录、仓库脚本；dry-run 脚本与 fixture 全在 `/tmp/r5t`（无新增仓库脚本）；`git status --porcelain` 与动工前逐字一致（计划目录仍 untracked，计划期既有状态）。
