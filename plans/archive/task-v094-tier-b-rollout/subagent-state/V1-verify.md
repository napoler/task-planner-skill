# V1-verify | task-v094 Tier-B 7 项独立验证（干净上下文）

- 验证者: 全新子代理（干净上下文，未依赖 selftest 代码逻辑，独立构造 /tmp 夹具）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v094-tier-b-rollout
- 范围: git log 最近 5 提交 3b4c490..8834b37
- 时间: 2026-09-28
- 只读约束遵守: 未修改 worktree 任何文件; 夹具全部在 /tmp

## 1. 官方 selftest

### selftest-tier-b.sh（18 断言）
Total 行原文:
```
Total: 18 PASS=18 FAIL=0
```
RC=0。18/18 PASS（TB-01~TB-18 逐行 PASS，含 mini 通道正反、silent 缺省、mini-lite 单 Phase 锚、22.8.2/19.2 豁免句、CR 分级句、只读分槽正反、21.4 豁免子条锚）。

### selftest-plan-tier.sh（32 断言）
Total 行原文:
```
Total: 32 PASS=32 FAIL=0
```
RC=0。32/32 PASS。

## 2. 独立夹具复验（自己写最小夹具，非照抄 selftest）

### a) mini 直做通道（check-delegation.sh pretool）
夹具: /tmp/v094-mini-fixture
- plans/v094fix/task_plan.md frontmatter 含 `plan_tier: mini`
- plans/.active_plan 指向 v094fix；plans/v094fix/.session-owner=v094-verify-sid（sid 匹配 → 主进程路径）
- 业务文件 /tmp/v094-mini-fixture/src/app.py

| 用例 | 命令 | 期待 | 实际 | 判定 |
|---|---|---|---|---|
| A1 mini+业务 .py | check-delegation pretool $R/src/app.py v094-verify-sid - | rc=0 | rc=0 | PASS |
| A2 mini+保护区文件 | check-delegation pretool /home/terry/.zcode/skills/task-planner/SKILL.md v094-verify-sid - | rc=2 | rc=2（命令进程退出码 2，无放行输出） | PASS |

证据: 源文件 check-delegation.sh:291-310 ④b 分支（`grep -q 'plan_tier: mini'` 命中 ∧ 文件路径 case 非保护区 → `exit 0`；`*/.zcode/skills/*` 命中保护区 case → 落到 ⑤⑥，enforce 档 exit 2）。worktree config.json delegation_enforce=enforce（jq 实测输出 "enforce"），故 A2 阻断生效。

### b) 只读分槽并行（check-dispatch.sh pretool）
夹具: /tmp/v094-ro-fixture
- plans/ropar/task_plan.md frontmatter 含 `parallel_readonly: true`（+mini 档不干扰）
- 三件套 task_plan.md/findings.md/progress.md 齐备
- 槽占用锁: plans/ropar/subagent-state/.dispatch-inflight 写 30 秒前时间戳（实测 age=30s < 120s 槽占用阈值）

| 用例 | 期待 | 实际（stderr 原文） | 判定 |
|---|---|---|---|
| B1 含 `[readonly-parallel]` 标记+三文件路径+checkpoint | rc=0 | rc=0; `[dispatch-readonly] 只读并行豁免命中(声明+标记双条件), 槽占用(age=30s)放行, 写类锁保留` | PASS |
| B2 去掉标记（同 prompt 其余一致） | rc=2 | rc=2; `[dispatch-block] 🚫 Rule 21.4 串行派发铁律: 串行槽被占用(锁 age=30s<120s), 禁止并行派发` | PASS |

附加核验: B1 放行后锁时间戳 1790612071 未被覆盖（"写类锁保留" 语义实锤，read-back 值不变）。证据: check-dispatch.sh:364-368 T-B1 豁免分支 + cmd_pretool 212 行 ro 双条件计算（`parallel_readonly: true` ∧ prompt `[readonly-parallel]`）。

## 3. 7 项规则文本锚点核对（critical-rules.md + SKILL.md 逐项 grep 命中行）

说明: critical-rules.md 实际路径 = references/critical-rules.md（skill 根无同名文件，find 确认）。

| 项 | 锚 | 命中位置 | 判定 |
|---|---|---|---|
| 1. mini 直做通道 | T-B4 | critical-rules.md:55（Rule 14 ④：「mini 直做通道（[task-v094 T-B4]：plan_tier=mini 含 auto-tier ∧ 非保护区 → 主进程直做合法…check-delegation pretool ④b 放行，保护区永不放行）」）+ critical-rules.md:177（25.3 白名单⑥：「trivial/mini 直做通道…mini 档 ≤30 行/≤2 文件/单模块/≤15min——[task-v094 T-B4]」，T-B4 共 2 处）+ 机器面 check-delegation.sh:291 ④b | PASS |
| 2. mini 缺省 silent | T-B3 | critical-rules.md:227（28.2 末尾：「mini 档缺省 silent（[task-v094 T-B3]）：plan_tier=mini 且未显式声明 interaction_mode 时 resolve 层 ②b 直接 silent（env/计划行显式仍优先）」）+ 机器面 resolve-interaction-mode.sh:75 「②b [2026-09-28 task-v094 T-B3] mini 档缺省层」 | PASS |
| 3. mini-lite 单 Phase 化 | T-B2 | critical-rules.md:339（38.3 末尾：「单 Phase 化（[task-v094 T-B2]）：mini-lite 模板 2 Phase→固定 1 Phase（实施+验收合一）」）+ 模板 templates/variant/mini-lite-type.md:31「## Phases（固定 1：实施+验收合一，[task-v094 T-B2]）」 | PASS |
| 4. T5 短任务免写 | T-B5 | critical-rules.md:142（22.8.2：「短任务豁免（[task-v094 T-B5]）：预估 ≤step_max_minutes(15min) 的 S-unit 免 T5 落盘…T1-T4 与 checkpoint 路径仍必做」） | PASS |
| 5. 纯实施 findings 一行声明 | T-B7 | critical-rules.md:96（19.2：「纯实施 Phase 一行声明豁免（[task-v094 T-B7]）：…写一行 [implementation-only] …即计实质增量」） | PASS |
| 6. CR diff 分级+轻 diff 合并 | T-B6 | SKILL.md:145（「diff 分级（[task-v094 T-B6]）：轻 diff（代码文件 ≤3 个且合计 ≤50 行）→ 单轮轻量审查…重 diff → 全量多轮 CR 原流程不变」）+ SKILL.md:457（「轻 diff 合并（[task-v094 T-B6]）：改动 ≤3 文件且 ≤50 行时编译/lint/测试合并单代理一次跑完」） | PASS |
| 7. 只读分槽并行 | T-B1 | critical-rules.md:122（21.4 末尾：「只读分槽豁免（[task-v094 T-B1]…）：计划 frontmatter 声明 parallel_readonly: true ∧ 派发 prompt 含 [readonly-parallel] 标记…机器面=check-dispatch serial_slot_check 第④参放行且不覆盖写类锁；写类 S-unit 仍严格独占槽」）+ 机器面 check-dispatch.sh:364-368 | PASS |

marker 计数: critical-rules.md 内 T-B1=1, T-B2=1, T-B3=1, T-B4=2, T-B5=1, T-B6=0, T-B7=1；SKILL.md 内 T-B6=2（其余无）。7 项规则文本锚全部在位。

## 4. 汇总

- 7/7 项 PASS；selftest 18/18 + 32/32；独立夹具 4/4 正反断言 PASS。
- 负结果检查: 未发现异常。排除风险: ① A2 证明 mini 通道未破保护区红线；② B2 证明写类串行约束未被 T-B1 豁免削弱（无标记仍 rc=2）；③ B1 后锁未被覆盖，"不覆盖写类锁"语义实锤；④ config.json 双 enforce 档位实测，非 warn 档下结论有效。
- 备注: 任务书写 `critical-rules.md/SKILL.md`，实际规则锚文件为 `references/critical-rules.md`（全仓 find 无根级 critical-rules.md），非缺陷，路径澄清。

status: PASS (7/7)
files_written: 仅本检查点 /mnt/data/dev/task-planner-skill/plans/task-v094-tier-b-rollout/subagent-state/V1-verify.md（worktree 零写入；/tmp 夹具可清理）
