# 4-general-reviewer.md — A5 复检（103.3 双轮质检第二轮，sonnet-1）

## 对象
- worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115`
- branch: `wt/task-serial-sync-20261115` / commit: `c5300a0`
- 6 被改文件: `skills/media-planner/references/critical-rules-media.md`, `skills/task-discipline/references/critical-rules-discipline.md`, `skills/task-dispatch/references/critical-rules-dispatch.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/scripts/selftest-enumerate-first.sh`, `skills/task-planner/templates/subagent_dispatch.md`
- 基线: `/tmp/serialsync-st-baseline.count` = `2`

## 1. 全量回归（worktree）

### 命令
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115 && bash skills/task-planner/scripts/run-selftests.sh > /tmp/serialsync-st-wt.log 2>&1
echo "---EXIT:$?---"
```

### 关键输出
- 包装退出: `---EXIT:1---`（run-selftests.sh 返回 1）
- 摘要: `Total: 97 PASS=94 FAIL=3 (run=97 reused=0)`
- 失败脚本: `Failed: selftest-active-plan selftest-dual-qc selftest-execution-stability`
- FAIL 行:
  - `[FAIL]   selftest-active-plan (rc=1)`
  - `[FAIL]   selftest-dual-qc (rc=1)`
  - `[FAIL]   selftest-execution-stability (rc=1)`

### 回归定位（selftest-dual-qc，新增失败）
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115 && bash skills/task-planner/scripts/selftest-dual-qc.sh 2>&1 | tail -40; echo "dualqc_exit=$?"
```
关键输出:
```
DQ-01 PASS ^103.[1-8] 计数=8
...
DQ-07 PASS 衔接（Rule 103）=1/84.7.2 为其先例面=1
DQ-08 FAIL 锚缺失（纪元窗=4/其余 8[0-9] 条=0/Rule 103 双轮质检与同步完整性域=1）
DQ-09 PASS 3h 双轮质检（Rule 103）=1/103.6 同步核对清单=3
...
DQ-14 PASS registry 已登记 selftest-dual-qc
Total: 14 PASS=13 FAIL=1
dualqc_exit=0
```
（脚本汇总打印后以 FAIL 计数退出态在 run-selftests 汇总中记为 rc=1；直跑 tail 显示 `dualqc_exit=0` 为该复合命令末行 echo 的壳返回，脚本本体 DQ-08 FAIL/Total FAIL=1 为实）

### 判据对照
- 基线 FAIL 数: 2（`selftest-active-plan`, `selftest-execution-stability`）
- 实测 FAIL 数: 3，新增 `selftest-dual-qc` → **回归（超出基线）**

## 2. V-3.1 / V-3.2 / V-4.1 复跑（verification.md 原文，worktree 前缀）

### V-3.1 (Phase 3, Rule 107 锚命中)
命令:
```bash
bash -c 'w=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills; c1=$(grep -c "序列创作知识同步" "$w/task-discipline/references/critical-rules-discipline.md"); c2=$(grep -cE "107\.[1-4]" "$w/task-discipline/references/critical-rules-discipline.md"); test "$c1" -ge 1 -a "$c2" -ge 4'
```
退出码: `0` → **PASS**

### V-3.2 (Phase 3, 级联条款命中)
命令:
```bash
bash -c 'w=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills; a=$(grep -c "前序产出" "$w/task-dispatch/references/critical-rules-dispatch.md"); b=$(grep -c "前序产出" "$w/media-planner/references/critical-rules-media.md"); test "$a" -ge 1 -a "$b" -ge 1'
```
退出码: `0` → **PASS**

### V-4.1 (Phase 4, worktree 全量 selftest ≤ 基线)
命令:
```bash
bash -c 'bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills/task-planner/scripts/run-selftests.sh > /tmp/serialsync-st-wt.log 2>&1; test "$(sed -n "s/^Total: .* FAIL=\([0-9]*\).*/\1/p" /tmp/serialsync-st-wt.log | tail -1)" -le "$(cat /tmp/serialsync-st-baseline.count)"'
```
退出码: `1` → **FAIL**（实测 FAIL=3, 基线=2）

## 3. 103.3a 全文回读比对（6 文件 vs findings §Technical Decisions 载体 1-5）

### 载体 1 — `skills/task-discipline/references/critical-rules-discipline.md` (Rule 107/107.0-107.5, 106.5 后)
- 插入锚: `106.5` 段末（行 ~738 “B1 设计为持续项避免逐次修改的 todo 刷屏。”）后空行接 `107.`（行 740）。
- 文本核对: `107` 标题+适用面+Why、`107.0`（计划期台账声明/五字段/Rule 62 不替代）、`107.1`（单元完成沉淀/禁声明完成联动 51.2）、`107.2`（动笔前强制回读①②③/禁摘要替代/派发契约面 dispatch 22.4d、模板面 subagent_dispatch.md §2 序列行）、`107.3`（五项一致性核对/FAIL 返工+勘误回写/与 47.6 叠加）、`107.4`（主进程验收与接续/80.4 扩展）、`107.5`（豁免与边界三项/机制范式 47.4）与 findings 载体 1 终稿逐段一致。
- 格式: 与既有规则（粗体编号子条+冒号+正文+Why/联动）形态一致；无吞锚/无重复/无截断。
- 结论: **一致**（无偷改/漏句/私增）。

### 载体 2 — `skills/task-dispatch/references/critical-rules-dispatch.md` (22.4d, 22.4c 后)
- 位置: `22.4c` 后空行插入 `22.4d`（行 64），`22.5`（行 66）在后，22.4c 原文保留。
- 文本核对: findings 载体 2 终稿全文一致（Rule 107.2 派发面承载、前序产出+台账双路径①②、LLM 行为门、模板面指针、Why 判例）。
- 格式: 与 22.4a/b/c 同类条款形态一致。
- 结论: **一致**。

### 载体 3 — `skills/media-planner/references/critical-rules-media.md` (47.7, 47.6c 后/49 前)
- 位置: 47.6c 段后空行插入 `47.7`（行 27），`### 49`（行 29）紧随，47.6/47.6a-c 原文保留。
- 文本核对: findings 载体 3 终稿全文一致（Rule 107 媒体面指针、107.0-107.3 三环闭环、47.6 叠加、产物依赖≠知识传递判例）。
- 格式: 与 47.x 条款形态一致。
- 结论: **一致**。

### 载体 4 — `skills/task-planner/templates/subagent_dispatch.md` (§2 序列行)
- 位置: §2 输入段“材料包绝对路径/来源”行后新增“前序产出与序列台账…”行（行 30），用户输入一致性约束行（行 31）仍在后。
- 文本核对: findings 载体 4 终稿一致（Rule 107.2/22.4d、占位符 `{紧邻前序单元产出绝对路径} {continuity 台账绝对路径}`、首动作回读、非序列填 none）。
- 格式: 与 §2 其他 bullet 一致。
- 结论: **一致**。

### 载体 5 — `skills/task-planner/SKILL.md` + `skills/task-planner/scripts/selftest-enumerate-first.sh` (索引/纪元)
- SKILL.md: `1-107` 出现 3 处（行 9/223/266），路由行含 `,107`（行 210: task-discipline 路由追加 ,107）。`1-106` 字面命中 1 处（行 105，`106.1-106.4` 子条引用上下文，属 Rule 106 本体引用/禁改区，非纪元窗残留）。纪元与路由级联符合 findings 载体 5 意图。
- selftest-enumerate-first.sh: `1-106` 残留 0，EN-06 锁步 `1-107`≥3 且 `,107`，EN-07 负断言通过；脚本头注释与断言文本已锁步 1-107。
- 格式: 与既有纪元锁步写法一致。
- 结论: **基本一致**（SKILL 存在 1 处 `1-106` 字面但位于禁改的 Rule 106 本体引用行，非纪元残留；其余纪元/路由一致）。

### 互引完整性（107.2↔22.4d↔47.7↔模板行）
- 107.2 明确指向 “dispatch 22.4d，模板面=subagent_dispatch.md §2 序列行” ✓
- 22.4d 指向 “Rule 107.2/107.0…模板面=subagent_dispatch.md §2「前序产出与序列台账」行” ✓
- 47.7 指向 “Rule 107…107.0-107.3…107.2 下一单元派发必附前序产出+台账路径” ✓
- 模板行指向 “Rule 107.2/22.4d” ✓
- 结论: **互引完整**。

## 4. 纪元面专项检查

### 命令与结果
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115
grep -c '1-107' skills/task-planner/SKILL.md        # => 3
grep -n ',107' skills/task-planner/SKILL.md         # => 210: ... ,107）|
grep -c '1-106' skills/task-planner/SKILL.md        # => 1 (line 105, Rule 106 本体引用)
grep -c '1-106' skills/task-planner/scripts/selftest-enumerate-first.sh  # => 0
bash -n skills/task-planner/scripts/selftest-enumerate-first.sh; echo "bash_n_exit=$?"  # => bash_n_exit=0
bash skills/task-planner/scripts/selftest-enumerate-first.sh; echo "exit=$?"
```
selftest-enumerate-first 结果:
```
[PASS] EN-01 task-discipline critical-rules 含行首 '### 105 ' 段标题(SEC105)
[PASS] EN-02 SEC105 '^105\.[1-5] ' 五子条行首锚计数=5 (got=5)
[PASS] EN-03 SEC105 关键判据词计数 全量枚举≥4(4) 零命中≥1(1) 回退≥1(2) ls≥2(4)
[PASS] EN-04 105.5 反例锚段含「装备车」与「命名族」(SEC105)
[PASS] EN-05 交叉引 'Rule 35' 与 '100.6' 在位于SEC105
[PASS] EN-06 SKILL.md 含 '1-107' ≥3 处(3) 且含 ',107' 路由
[PASS] EN-07 负断言: SKILL.md '1-105' 字面残留=0
Total: 7  PASS=7  FAIL=0
exit=0
```

## 缺陷清单（分级）
- **P1 回归（阻塞 VC-3/V-4.1 判据）**: 全量 selftest 新增 `selftest-dual-qc` 失败（DQ-08 FAIL：`锚缺失（纪元窗=4/其余 8[0-9] 条=0/Rule 103 双轮质检与同步完整性域=1）`），Total FAIL=3 > baseline 2。失败名单从预存 {selftest-active-plan, selftest-execution-stability} 扩展为含 selftest-dual-qc；V-4.1 exit 1。疑似 1-107/规则索引级联未同步更新 selftest-dual-qc 的纪元/锚断言，需修复或同步基线/断言后方可通过回归门。证据: `/tmp/serialsync-st-wt.log`, selftest-dual-qc 直跑输出。

## 结论
- 载体 1-5 终稿文本与互引在 worktree 内落地一致（SKILL line 105 `1-106` 为 Rule 106 本体引用非纪元残留）；V-3.1/V-3.2/纪元面检查/selftest-enumerate-first PASS。
- 但全量回归出现新增失败 selftest-dual-qc，V-4.1 FAIL → **有条件不通过（存在 P1 回归阻塞回归门）**。 
