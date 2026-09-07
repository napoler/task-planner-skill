---
agent_type: executor-fb (general-purpose executing on task)
task_id: task-v055-fallback
seq: 11
status: in_progress
created_ts: 2026-09-08
---

## 任务
task-v055-fallback 实施批次 — 在 worktree 内完成 5 文件改动 + 自测脚本 + 1 个 git commit。

## 里程碑
- [ ] M1: subagent-fallback.sh 落盘 + chmod +x
- [ ] M2: config.json 新增 provider_fallback 键
- [ ] M3: critical-rules.md Rule 22.3 行内升级 + 22.3.1 新增
- [ ] M4: SKILL.md §「超时与失败兜底」段后追加 3-4 行
- [ ] M5: lib/verify.sh 新增第 10 号检查 + Checks 注释列表追加
- [ ] M6: install.sh 插入 Phase 5.7（best-effort）
- [ ] M7: selftest-fallback.sh 编写 + 跑绿
- [ ] M8: git add + commit

## 错误与受阻
（实施过程中记录）

## 最终结论
（任务结束时回填）
