# S7-fix 执行检查点 — task-v148 防偏移加强（worktree wt/task-v148-drift-enforce）

verdict: APPROVED（F1-F7 全部修复，F8 规格固有不动）
执行时间: 2026-10-08
基点: master e54973d

## 修复清单（F1-F7）

### F1 [MAJOR] gate 条件 6 补 plan_tier: mini 豁免出口
- 文件: skills/task-planner/scripts/check-3file-gate.sh
- 改动: 条件 6 的 drift_exempt_check 之后、env 降档之前，插入 `elif grep -qm1 'plan_tier: mini' "$PLAN_FILE"` 分支
- 判定序: ledger → 检查点 → exempt → mini → env
- docblock 同步更新
- 既有函数体零改动

### F2 [MINOR] selftest 补 DCE-17（off 档）+ DCE-18（mini 豁免）
- 文件: skills/task-planner/scripts/selftest-drift-enforcement.sh
- 改动: DCE-14 之后追加 DCE-17（env off exit 0）和 DCE-18（plan_tier: mini 豁免 exit 0）
- Total: 16 → 18

### F3 [MINOR] fixture Started 改运行时 date 生成
- 文件: skills/task-planner/scripts/selftest-drift-enforcement.sh
- 改动: :35 的 `printf '## Phase 2: test\n- **Started:** 2026-10-08 12:00\n'` 改为 `printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')"`
- 消除墙钟依赖

### F4 [MINOR] DCE-16 SID 改随机（dce16$$）
- 文件: skills/task-planner/scripts/selftest-drift-enforcement.sh
- 改动: DCE-16 段 SID 从固定 `testsid` 改为 `dce16$$`（运行时 PID）
- 避免跨运行累积主计数器导致优先级 4 提前返回

### F5 [MINOR] hook 调用点前移至 plan 解析成功后
- 文件: skills/task-planner/scripts/zcode-posttooluse.sh
- 改动: 将 emit 函数 + drift_rhythm_check 函数定义整体前移到 :44（`[ -z "$plan" ] && exit 0` 行后），删除原函数定义和末尾调用
- 函数体零改动，仅移动位置
- 确保优先级 1-4 命中 exit 0 时 drift 计数仍自增

### F6 [MINOR] ledger-append.sh docblock 枚举补 drift_check
- 文件: skills/task-planner/scripts/ledger-append.sh
- 改动: :9 行尾追加 `| drift_check`

### F7 [MINOR] drift-checker.md 追加行改列表项
- 文件: skills/task-planner/companion/agents/drift-checker.md
- 改动: :35 追加行前置空行 + `- ` 前缀

## 自验证据

### selftest-drift-enforcement.sh
```
Total: 18 PASS=18 FAIL=0
```

### selftest-drift-check-subagent.sh
```
Total: 20 PASS=20 FAIL=0
```

### selftest-four-file-dataflow.sh
```
Total: 18 PASS=18 FAIL=0
```

### hook 两态
- 态 1（注入触发）: stdout 含 `[drift-rhythm]` 提醒
- 态 2（静默 0 字节）: stdout 空

### 分支命中场景
- 优先级 4 命中时，drift 计数仍自增（count 10 → 11，last_inject 0 → 11）

### bash -n
- check-3file-gate.sh OK
- zcode-posttooluse.sh OK
- selftest-drift-enforcement.sh OK

### git diff master --numstat
```
2	0	CHANGELOG.md
2	1	skills/task-planner/SKILL.md
2	0	skills/task-planner/companion/agents/drift-checker.md
18	0	skills/task-planner/references/critical-rules.md
86	0	skills/task-planner/scripts/check-3file-gate.sh
4	2	skills/task-planner/scripts/ledger-append.sh
1	0	skills/task-planner/scripts/selftest-registry.tsv
50	4	skills/task-planner/scripts/zcode-posttooluse.sh
```
删除行来自 S1-S6 阶段既有改动和 F5 函数定义移动（非删除既有逻辑）。

## 硬约束验证
- F1 新增判断不动既有函数体: PASS
- F5 仅移动+删一行（函数定义移动，非删除既有逻辑）: PASS
- critical-rules.md 零改动: PASS（本次 F1-F7 未触碰）
- 主仓只读: PASS
- 禁 git 写: PASS
