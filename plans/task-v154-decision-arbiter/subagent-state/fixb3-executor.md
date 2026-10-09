# fixb3-executor 检查点 — Fix-B3 registry 末行恢复

- **时间**: 2026-10-10 03:43:32 CST
- **任务**: task-v154 S8 回归修复第四批（串行槽，最后一批）— Fix-B3
- **worktree**: /mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter
- **写入目标（唯一）**: skills/task-planner/scripts/selftest-registry.tsv
- **操作**: 将末行 `selftest-decision-arbiter.sh` 整行剪切到 `selftest-goal-unit-goal-mode.sh` 行之前（swap 末两行，字节级保真）

## 末两行 head/tail 摘录（col1 + sha256）

| 行号 | col1 | sha256 |
|------|------|--------|
| 65 | selftest-decision-arbiter.sh | a2a482de4bb160896ee2ea24c9385278b5e2819b190d27f35a1a28e9ae9eebb3 |
| 66 | selftest-goal-unit-goal-mode.sh | 2794b6b91af024ddb2ff568e01f63dc43bdb142581616f1df209f5c3495954f0 |

- 移动前: line65(goal-unit)=2794b6b9…, line66(decision-arbiter)=a2a482de…
- 移动后: line65=a2a482de…(=旧 line66), line66=2794b6b9…(=旧 line65) → 字节级 swap 成立
- 末行 = `selftest-goal-unit-goal-mode.sh`（G-07 恢复）

## 结构校验

- wc -l = 66（表头 1 + 数据 65），移动前后行数不变
- awk NF 分布: 66 行全部 NF=4；空单元格检查无输出
- registry.tsv 之外零触碰（git status: 仅 registry.tsv 为本次新增 M；其余 4 个 selftest-*.sh 为任务前既有改动）

## 三脚本运行尾部

### selftest-goal-unit-goal-mode.sh (exit 0)
```
G-06 PASS check-complete.sh 'goal-gate' 锚=9（≥1）+ '[goal:G' grep 锚=4（≥1）
G-07 PASS selftest-registry.tsv 末行含 selftest-goal-unit-goal-mode.sh
G-08 PASS config.json properties 键名 goal[_-](unit|gate|advance) =0（零新键）
G-09 PASS SKILL.md 行数=521 ≤526（D2 上调后上限）
Total: 9 PASS=9 FAIL=0
```

### selftest-registry.sh (exit 0)
```
T01 PASS
T02 PASS
T03 PASS
T04 PASS
T05 PASS
Total: 5 PASS=5 FAIL=0 (registry rows=65, actual selftest=65)
```

### selftest-decision-arbiter.sh (exit 0)
```
DA-14 PASS 覆盖矩阵 28 行判断裁决行在位
DA-15 PASS registry 自登记行在位
DA-16 PASS 零新 config 键：arbiter=0 且新增面无 _enforce 键
Total: 16 PASS=16 FAIL=0
```

## 结论
Fix-B3 完成：G-07 FAIL→PASS，G-01..09 无回退；registry T01..T05 全 PASS（rows 计数不变=65）；decision-arbiter DA-01..16 全 PASS。next_step=主进程复跑全量回归收尾 Phase 3。
