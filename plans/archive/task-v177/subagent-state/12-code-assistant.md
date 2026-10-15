# 12-code-assistant 检查点

status: done

## 改动清单
1. skills/task-planner/scripts/selftest-error-loop.sh:78 — EL-11 宽容锚 `Rules 1-(3[1-9]|[4-7][0-9]|8[0134])` → `Rules 1-(3[1-9]|[4-7][0-9]|8[01346])`（L75-77 加注 RG-06 范式注释；ok/bad 消息随动更新 8[01]→8[01346]，断言逻辑不变）
2. skills/task-planner/scripts/selftest-veto.sh:66 — VT-10 宽容锚 `8[0134]([^0-9]|$)` → `8[01346]([^0-9]|$)`（保留尾边界断言，不放越界 82-89；L63-65 加注；ok/bad 消息 1-3x..83 → 1-3x..86）

## 验证
- `bash skills/task-planner/scripts/selftest-error-loop.sh` → Total: 16 PASS=16 FAIL=0（EL-11 PASS）
- `bash skills/task-planner/scripts/selftest-veto.sh` → Total: 13 PASS=13 FAIL=0（VT-10 PASS）

## 纪律确认
- 仅改 2 个授权文件；git status 中其余 M 文件为 task-v177 前序阶段（76-86 级联）遗留，非本次改动
- 未做 git 写操作；未跑全量 selftest
