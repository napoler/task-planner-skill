# Findings — task-audit-rework-cap-20261121（调研与设计结论）

## F1 根因：机器门只保证"末轮形态达标"，不保证"审计循环收敛"
- check-plan-audit-gate.sh:157-190 只看末段 `[plan-audit-RN]` 的 APPROVED 锚+三 token；JSON shim :123-155 只做 planctl check audit（末轮 APPROVED 且 0C/0I，planctl.py:895-910）。
- Rule 109.2 / SKILL.md:76 已有"连续≥3轮无实质进展→呈报用户裁决"，但纯文本纪律，无机器计数（critical-rules.md:205 / SKILL.md:76）；109.8 机器面未含此判定（:217）。
- 结论：R1→R9 反复打回能一直转，因为没有任何机器判定"同一问题跨轮重复=无进展"。

## F2 真实样本（StoryLab task-ep36-restructure-001/progress.md:21-258）
- R1 REJECTED（1C/6I/6W/3N），R2 REJECTED（0C/1I/7W/3N），R3 APPROVED（0C/0I）。
- **I-5 在 R1 报"已修"，R2 以"I-5 残留"重现**（:27-41/:58）→ 无进展直接证据。
- R2→R3 I-5 清零（:235-241）→ 真实进展，判定必须不误伤这一轮。
- 结论：问题身份跨轮复用是可行信号，但需规范化（去"残留/已修/修复中"状态尾缀）。W/NIT 多为细化，不宜计入硬无进展噪音。

## F3 设计决策
- 优先 JSON 权威源：schema audits[] 新增 issues[]（key/severity/state/title），additionalProperties=false 需同步改 schema；audit-add 增 --issues-json；check audit 加无进展判定。
- 无进展判定：窗口=最近3连续 REJECTED 轮；开放 C/I key 集合末轮 ⊆ 前轮且无新 C/I key（或计数与 key 集不下降）→ no_progress；W/N 不计硬信号。
- rc 兼容：不改 0/1/2，reason 内嵌机器可 grep 的 code `NO_PROGRESS_STREAK_3 / ESCALATE_USER_DECISION_REQUIRED`；enforce 视为 rc1 拒锁，warn 显著 WARN+披露。
- Markdown fallback：仅解析显式 `I-\d+`/`C-\d+` 等 key，去状态尾缀；解析不到时保守 SKIP_NO_ISSUE，不硬升级。
- 阈值对齐原文"连续≥3轮无实质进展"；复位=人工裁决后新一轮带 reset_reason。

## F4 缺口清单（机器化点）
- G1 无跨轮无进展判定；G2 JSON audit 无 issue 载体；G3 MD 路径无 issue 解析；G4 无升级/上报机器出口；G5 规则文本与机器能力不一致；G6 selftest 缺覆盖。
- 需联动：schema/planctl.py/check-plan-audit-gate.sh/attest 缓存键文案/Rule 109.8/SKILL.md:76,79/selftest-planctl.py/selftest-plan-audit-gate.sh/selftest-registry.tsv。

## F5 验证结论（2026-11-21，收口复验）
- **F5.1 审计域自测全绿**：`selftest-planctl.py` 17/17 PASS（含新增 audit-add issues-json/schema 拒绝、3 轮同 key 止损、W/N+APPROVED 不误伤 3 例）；`selftest-plan-audit-gate.sh` 24/24 PASS（含新增 PAG-20..24：JSON shim reason 全文透传 / MD fallback 显式 key 三轮 / WARN legacy / APPROVED 收敛不误伤 / 仅 W/N 不触发）；`selftest-planctl-shim.sh` 15/15 PASS（外契约 stdout 前缀 + rc 0/1/2 零回归）。
- **F5.2 受影响静态锚全绿**：tool-selection 12/12、plan-tier 32/32、verification-gate 13/13、goal-unit 9/9、doc-script-paths 3/3、antiregress 9/9 全 PASS。
- **F5.3 FAIL 不增——3 个 FAIL 经 master 对照确认为基线预存**：`selftest-registry.sh` T05（registry 105 行 vs 磁盘 104，缺 `selftest-md-edit-ops.sh`）；`selftest-summary-readability.sh` SRV-11/SRV-12（级联 8/9，同源 registry 不 PASS）。master 主仓跑同脚本得到**完全相同**的 FAIL 集合；本次 registry 仅 1 行描述替换（numstat 1/1）、未增删行，与这些 FAIL 无因果关系。
- **F5.4 环境 I/O 诊断（非代码缺陷）**：`/mnt/data` 分区 82% 占用，init 单命令 2.7s（/tmp 仅 0.5s），导致 selftest 在 worktree scratch 路径下耗时放大到 ~50s/用例而被外层 timeout 误判为卡死。逐步计时 9 个 planctl 子命令均在 0.5s 内完成，判定函数 `audit_no_progress` 无死循环。临时将 scratch 软链到 /tmp 后全量 selftest 秒级跑完，跑完已还原目录（非软链）。
- **F5.5 不误伤真实收敛**：真实样本 R1/R2 I-5 open（2 轮不触发）、R3 APPROVED 无条件 PASS；4 段 R1-R3 同 key 命中止损后 R4 APPROVED 立即 PASS——两个方向均由 selftest 断言覆盖。
