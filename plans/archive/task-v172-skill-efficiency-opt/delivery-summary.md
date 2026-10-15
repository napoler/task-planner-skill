# task-v172 交付总结：task-planner 技能执行效率与质量优化（首轮落地）

> 用户诉求（R1/R2/R3）见 task_plan.md「🎯 用户需求原文」。首轮落地 CA-1/2/3（R3 核心），回归 77/77 零破坏。

## 1. 为什么低复杂度任务会跑几小时（根因，有实证）

用户样本 `sess_af21a26a`（videop1 项目 task-videop1-voicerivet-001「视频音色铆钉+提示词模板改造"）：

- **时间线**：2026-10-12 21:58 初始化 → 23:41 前已完成 3 勘察子代理取消重派、CreateWorkflow 3 次被拒（本会话 fast 模型无 Skill 工具）、hook 拦截回炉多轮 → 10-13 09:38 仍在跑，**近 4 小时未收口**（原始证据=videop1 progress.md Error Log、8 个检查点约 147KB）。
- **根因 RC1-RC6**（详见 findings.md「Technical Decisions」表）：
  1. 通道/复杂度错配：低复杂度任务走 standard/L2 重通道 + 五阶段 + 8 次子代理；
  2. 通道不可达无快速失败：CreateWorkflow 无 Skill 工具仍重试 3 次；
  3. hook 每轮/每调用开销复利：UPS 0.22-0.26s/轮 + 1-1.5KB 注入，PostToolUse 0.34-0.36s/调用，50 轮注入累积 ≈55KB；
  4. **提醒周期不分档（R3 命中）**：15/20/25min+10calls 对全 tier 统一，低复杂度任务被 [plan-sync]/[plan-compass] 反复打回写计划文件——这就是用户看到的「来回折腾多次读取 Task 文件」的体感来源；
  5. 只读子代理（Explore）无写工具，却被契约强制 checkpoint 落盘 → 主进程代写往返（本会话 S1/S2 两次实证，videop1「executor 返回空」同源）；
  6. 跨任务噪音与全量重算：SessionStart 无条件注入 INDEX top-3 陈旧任务（7 个 stale in_progress）。

## 2. 本轮落地了什么（worktree commit b135265，20 文件，77/77 回归）

| CA | 改动 | 效果（对应 R3） | 机器守护 |
|----|------|----------------|---------|
| CA-1 | UPS smart 注入改为「计划文件变更即注入 + 未变更每 20 轮兜底刷新」，并启用 prompt 类型门控（config smart_inject_interval=20、smart_inject_type_gate=on） | 计划没被编辑的那些轮不再重扫/复诵 task_plan.md——**回答用户「每隔多少步才限制更新一次」：变更即更，否则 20 轮一次**；50 轮注入 55KB 复利被砍到只变化轮+刷新轮 | 配置键+注释锚；回归 77/77 |
| CA-2 | 陈旧提醒周期按档位分档：plan_tier=mini ∨ execution_lane=L0 时 plan/progress/findings 的 15/20/25min ×2（light_tier_interval_multiplier=2） | 低复杂度任务不再被 15min 打回写计划文件，30/40/50min 一次 | 同上 |
| CA-3 | PostToolUse 每调用 2×sed→1×awk、8×cut→1×awk | 纯进程孵化合并（N1 投递节奏不变） | 回归 77/77 |

**顺带修复/证实**：config 键数守护「零新键」锚级联 44→46（17 个 selftest 同步，先例 task-perf-opt 42→44）；纯净基线 worktree 对照证明本次 18 个 FAIL 全为键数锚级联引入且已全修（0 残留）。

## 3. 二轮补完（此前登记下一轮的 CA-4/5/6 全部完成）

- **CA-4**（2026-10-13，merge 87bb3b6）：check-dispatch 只读 Executor checkpoint 代写豁免（22.8.6），回归 77/77 + task-dispatch 42/42；
- **CA-5**（2026-10-14，merge 0817eef + fix 13a23ab）：SessionStart [task-resume] 陈旧任务折叠——INDEX.md 表格区 in_progress 全部 >7 天未更新时折叠为单行，实测 3 场景（全 stale=折叠/混合=注入/空=跳过）全 PASS；
- **CA-6**（2026-10-14，merge 0817eef）：Rule 83 通道不可用快速失败（83.1 前置探测/83.2 三选项/83.3 禁≥2次同法重试/83.4 机制）+ selftest-channel-fast-fail.sh CF-01..06。

**本轮实弹发现并修复的 bug**：CA-5 初版 awk 用 `$8` 读日期列，INDEX.md scope_files 列含逗号致 `-F'|'` 字段位移，混合场景实测 FAIL → 13a23ab 改为整行正则取最后一个日期。

## 4. 生效与合并状态

- 全部 CA-1/2/3/4/5/6/7/8 已 merge 入 master（最新 13a23ab）并 **push origin**；
- 四部署位（~/.zcode, ~/.claude, ~/.cursor, ~/.config/opencode）已同步 diff=0（5 个 CA-5/6 文件逐位核验 OK）；
- 回归：全仓 78 selftest，唯 1 FAIL=selftest-requirement-grading RG-04，归因并行会话模板扫荡（character-design-type.md 删五要素行），与本任务零相关；
- worktree wt/task-v172-ca5-ca6 已清理。

## 5. 本轮新增（CA-7/8，用户 R4/R5 新需求）

| 项 | 改动 | 效果 |
|----|------|------|
| **CA-7 复合审查** | drift-checker（独立纠偏子代理）的判定锚从「task_plan R 条目（可能被转译）」升级为「user-session-log.md 全部用户原话（多轮，含纠正/追加/否决）+ task_plan R 双源，原话优先（Rule 80.4）」；[drift-rhythm] 提醒加「读 user-session-log 全原话对照执行查偏移，偏移→打回」指引；DCS-21 守护 | 直接回答 R4：复合审查确实用用户多轮原始对话对照执行，最能体现是否偏离用户核心需求 |
| **CA-8 纠偏执行率 DRIFT-GATE** | check-complete 终验新增 DRIFT-GATE：已完成多 Phase 但 subagent-state 无任何 *drift* 检查点 → 出 `[DRIFT-GATE]` 告警（env `TASK_PLANNER_DRIFT_GATE_ENFORCE`，默认 warn 不拦，保持 77/77）；CD-07 守护 | 直接回答 R5：把「纠偏子代理是否真执行过」变成机器可观测信号，杜绝 v160 后 0% 执行率静默重演 |

## 6. 回答用户 4 个问题

**Q1 降频降到多少？会丢数据吗？**
降到：**计划文件被编辑 → 立即注入；没编辑 → 每 20 轮才兜底注入一次**（`smart_inject_interval=20`，0=恢复每轮，可按需调小）。**不会丢数据**：数据落盘（findings/progress/检查点）是子代理/主代理主动写的，与"注入频率"无关；注入只是"复诵提醒"，提醒少了不影响盘上数据。你的判断对——几轮内模型记忆足以保留；唯一理论边界是极长对话（>20 轮无计划变更且模型遗忘），届时 20 轮兜底会刷新，attest 防篡改每轮仍在。

**Q2 每轮 1–1.5K token 是什么？每轮叠加吗？**
是 hook 每轮通过 additionalContext 注入的"计划复诵块"（Goal/Next Step/Current Phase/进行中 Phase/Decisions/progress 尾 5 行）≈1–1.5KB。**你的直觉对：它确实"每轮叠加"——但叠加发生在多轮上下文重放层面，不是数据层**：数据盘上只有一份，但每轮对话把"前面所有轮 + 本轮"一起送进上下文窗口计费，这个块每轮都被重新注入一次 → 50 轮 ≈ 50 次 = 累积约 55KB 上下文占用。砍注入频率（CA-1）就是直接砍这个复利。

**Q3 其他优化方向（遇问题优化、不降性能）/ 为什么还慢？**
已落 5 项（CA-1/2/3/7/8）覆盖"每轮 hook 开销复利 + 提醒不分档 + 纠偏没执行"三类。"为什么还慢"的另一大头是**通道错配**（低复杂度走重通道 + 多子代理 + 重试回路，videop1 实证）——这正是登记下一轮的 CA-4/5/6（只读子代理代写豁免 / 会话启动 INDEX 噪音 / 通道不可用快速失败）。

**Q4 验证/纠偏机制缺陷 + 子代理纠偏 + 复合审查**
已取证证实：drift-checker 检查点仅 v146/v160/v169 有，**v160 后约 10 个任务零执行**（机制在位但靠 LLM 自觉，无机器强制）。CA-7 把复合审查的输入换成"用户多轮原话"（最能体现真实目的），CA-8 把"是否执行过纠偏"变成终验机器可观测门。要真正硬拦截，把 `TASK_PLANNER_DRIFT_GATE_ENFORCE=enforce` 打开即可（当前默认 warn 不改行为，避免破坏 77/77 基线，是否收紧由你定）。

## 7. 预期收益（基于 report.md:87-107 实测口径外推）

- 低复杂度标准任务：50 轮注入 ≈55KB → 仅变化轮 + 每 20 轮刷新，注入量降约 80–95%；
- mini/L0 轻任务：计划写回提醒间隔 ×2（15→30min 等），直接砍"反复读写 task_plan"体感；
- 每次工具调用 PostToolUse 少 9 个子进程孵化；
- 复合审查/纠偏执行率变为机器可观测（消除静默 0% 执行）。

## 8. 风险与不变式

- attest 防篡改校验每轮不变（未降载）；drift-rhythm N1 投递节奏不变（CA-3 只并进程）；DRIFT-GATE 默认 warn 不改 exit（零基线破坏）；
- 全仓 77 selftest FAIL=0（b135265 与 cc50ead 两次独立复跑均 77/77）；质量门（VC/反造谣/回填）零弱化。

