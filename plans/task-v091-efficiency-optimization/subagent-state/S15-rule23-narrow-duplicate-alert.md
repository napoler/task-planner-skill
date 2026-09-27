# S15 警报 — 并发重复派发检测，第二执行体零写入停止（错误报告）

- task: task-v091-efficiency-optimization / S15 C-1a②③ / subagent: executor（第二次派发的执行体，本文件作者）
- date: 2026-09-27 05:58 +0800
- status: **stopped — 与另一 S15 执行体并发同场（本执行体进场时 clean ✅，执行中被对方写入）**
- 本文件独立于对方将写的 `S15-rule23-narrow.md`，不覆写。协议先例=S14-duplicate-dispatch-alert.md（05:45，同一重复派发模式）。

## 1. 事实时间线（+0800，除本文件外零写入；对 worktree/主仓源码零改动）

| 时刻 | 事件 | 证据 |
|---|---|---|
| 05:46:30 | 派发台账标记 in-flight（epoch 1790459190） | subagent-state/.dispatch-inflight 内容 |
| ≈05:47 | 本执行体进场核对：HEAD=fb67f3a ✅ status clean ✅（此时通过硬约束） | git log/status 原文（本执行体工具记录） |
| 05:48-05:53 | 本执行体只读输入材料（提案 L123-138/目标脚本/三夹具/S14 checkpoint/posttooluse 先例），自备改造方案待写 | 工具调用记录 |
| 05:52:59-05:53:12 | 对方 /tmp 验证活动：Edit 夹具 stdin + 3 轮计时（run1 real=1.30s / run2 1.21s / run3 1.25s，37 计划仓 /tmp/r23-perf + 参照镜像 /tmp/r23-ref） | stat + 文件内容 |
| **05:54:33** | **对方将 S15 实现写入 zcode-pretooluse.sh（+32/-11，M 状态，未 commit）** | stat mtime + git status/diff --stat |
| ≈05:55 | 本执行体 Edit 被拒（"File has been modified since read"）→ 触发并发检测，转入只读取证 | Edit 报错原文 |
| 05:56-05:58 | 本执行体复核 ×3：HEAD 恒 fb67f3a、` M zcode-pretooluse.sh` 恒存、无 S15 checkpoint、无新 commit；对方进程快照不可见（瞬时 bash 无常驻进程） | status/ls/ps |

## 2. 对方落盘实现的只读快照评估（本执行体 05:57 实跑，仅供裁决，非采纳声明）

- `bash -n` OK；selftest-rule23-conflict-scan.sh 实跑结果（rc=0）：
  `R23-01 PASS 在途第二计划命中 scope → 报 [conflict]`
  `R23-02 PASS 完结计划被豁免`
  `R23-03 PASS 无指针过期在途计划仍被扫到`
  `Total: 3 PASS=3 FAIL=0` → **S15 验收主门（三夹具 3/3）在快照时刻已达成**
- 本执行体已备好等价改造方案（Edit 内容已在工具记录中），未写入任何字节。

## 3. 快照实现与 S15 brief 的可见偏差（不裁量，列交协调者）

1. **完结判定未覆盖 verification.md**：brief/提案 a② 引「复用 posttooluse:100-105 判定先例」，:105 含同目录 verification.md 的 outcome 豁免；对方仅扫 task_plan.md（其注释自述"同源 :100-105"但实现只及 :100）。生产中已交付计划 outcome 多落 verification.md → 收窄面可能不及预期（COMPLETE 计划仍会被提醒）。
2. **②形态为「每计划单 awk」而非「单 awk 多文件输入」**：fork 5N→N（非 →常数 1）；brief 主形态未实现，括号「等价单遍方案」是否涵盖由协调者裁定。
3. 注释标签日期「[2026-09-26 task-v091 C-1a②③]」≠ brief 指定「[2026-09-27 task-v091 C-1a②③]」（S14 重复派发同款漂移）。
4. 新增 `tgt == "" ||` 空 basename 即命中分支（原语义 grep -qF "" 空匹配近似等价，行为面差异微小）。

## 4. 恢复选项（推荐 ②）

1. 等对方自然收尾（写 checkpoint + commit）后，按其报告验收。
2. **（推荐）verify-then-adopt**：等对方退出后，由协调者指定唯一执行体按 §3 偏差清单逐项裁定——②/③/④ 可接受即补验收（byte-compare+R1 计时复核）+commit；① 若裁定为必须（提案原文倾向必须），在其基础上补 verification.md 同组喂入或重派。
3. 清空重派：`git -C <worktree> restore skills/task-planner/scripts/zcode-pretooluse.sh` 后重派 S15（brief 增补：进场残留即停条款+唯一执行体确认+verification.md 判定口径）。
4. 重派前核查派发台账/进程，确认无第三执行体。

## 5. 本执行体声明

- 对 worktree 与主仓源码：**零写入、零 commit、零 restore**；唯一写入=本警报文件。
- /tmp：本执行体仅实跑 selftest 一轮（mktemp 私有目录，trap 自动清理完毕）；对方产物（/tmp/r23-perf*、/tmp/r23-ref）非本执行体所建，未触碰、未清理。
- 曾向协调者 RespondToCoordinator 通报并发冲突（详见会话记录）。
