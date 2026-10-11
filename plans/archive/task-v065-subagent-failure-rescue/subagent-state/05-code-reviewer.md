# 05 Code Reviewer 检查点（task-v065 审查体）

status: done
acceptance: APPROVED（0 blocker / 0 必须修改项；2 项 non-blocking 建议 + 3 项观察项）

## 审查范围
- worktree /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue（wt/task-v065-subagent-failure-rescue）
- 9 commits: 1b84ca3 38d6ced 6f2611a aa19691 7ad8ec0 7f1a0a9 f175210 39dc8b9 b15d42a（git diff master...HEAD，35 文件 +1079/-101）

## 证据（逐条验证过的关键审查点）
1. check-complete.sh:454-460 — RESCUE-CHAIN GATE 只在 crc_rc==1 时 exit 1，warn/off/exit2 均不阻断，与注释契约一致
2. check-plan-dispatch.sh:37 — legacy 判定键 grep -qE '^- \*\*Executor:\*\*'（F-2 修复），selftest T07/T08 实测 exit 1/0 正确
3. allow-direct.sh:122 / check-delegation.sh:201 / ledger-append.sh:133 — 三处 flock -w 5 9 统一 .ledger_lock，fail-open else 分支为原语句，持锁等待语义一致；T5 注释与实现匹配
4. 全量 selftest 实测：10 个 selftest-*.sh 共 160 PASS / 0 FAIL（比计划宣称 159 多 1 条 T 计数，全绿）；shellcheck 本机不可用（未装），bash -n 全过，node --check plan-created.cjs 通过
5. VC-GATE 行序敏感性实测（隔离 skill 副本 + 4 种 Phase 段行序夹具，绕过前置 DELEGATION GATE 后单独跑 check-complete）：
   - V-N 在 Status/Executor/SU 表之后（模板 canonical 行序，自测 T01 同序）→ PASSED
   - V-N 在段内 Status 行之前（模板注释声称的「Status 行前」行序）→ PASSED
   - 真实 30 行计划格式（V-N 段首 + `**Status:** complete(2026-09-13)` 全角括号 + SU 表）→ PASSED
   - 段内残留模板占位 V-N 行 → 正确计 0 条实质映射 → WARNING（非误放行）
   结论：行序不敏感，段边界处理正确

## Findings（全部 non-blocking，仅记录）
- R-1（💬 Nit）subagent-fallback.sh:282 timeout hint 引「Rule 21.4」——对照 21.1b 评估拆细的条文实际在 21.4 内（实测确认），引用成立；但 hint 文案「先按 Rule 21.4 对照 21.1b 评估 ② 拆细重派」对 21.4 串行派发铁律的主题略漂移，纯文案
- R-2（💬 Nit）check-complete.sh:455 RESCUE-CHAIN GATE 与 VC-GATE 之间的 rescue 门控输出 human 行到 stdout（非 stderr），与同段其他门控 stderr 风格不一致，不影响契约
- R-3（🟡 观察）check-complete.sh VC-GATE 段约 130 行内联于脚本（>300 行文件红线逼近），可维护性风险；功能实测正确
- R-4（🟡 观察）22.3.1 行内追加「22.3.2 provider 全灭挽救档」使该行 ~900 字符且与 22.3.1 未分行（critical-rules.md:125），文本密度超限；语义与 28.4.1 无矛盾（拆细是 ② 档内动作，未构成新档位或矛盾 STOP 语义）
- R-5（🟡 观察）sync-todos subject 新增 ": title" 段（V-4），todo-sync.md 契约已同步（line 18），下游消费者（todo-sync.md 表 + selftest T10 断言）同仓一致；外部仓消费者若按旧格式 "{task-id}/Phase N" 精确匹配会失配——仓内无此消费者，回归面封闭

## 条款一致性核查结论
- 22.7 新语义（≥2 失败强制换档而非 STOP，穷尽 ①-④ 后才 STOP）vs 22.7.1（STOP 六字段）vs 28.2 D6（ask 硬停/silent 按 28.4.1 降级）vs 28.4.1（禁静默空等）：无矛盾。28.4.1 ①「登记 STOP-DEGRADED 决策行」与 22.7.1 六字段引用衔接一致
- 模板 task_plan.md Handoff 表新增 rescue/retry_count 列，与 22.5 列枚举、check-rescue-chain.sh 列匹配（表头 rescue/挽救 关键词定位 col_rescue，checkpoint/检查点 定位 col_cp）口径一致；selftest-rescue-chain T07 验证列缺失计违规
- SKILL.md 五档表 ⑤ AskUserQuestion 行补 28.4.1 降级交付指引，与 critical-rules 28.4.1 正文一致
- config.json 新增 vc_gate_enforce/rescue_chain_enforce 两键，均 default=warn，与脚本档位解析（env > config > fail-open warn）一致
- 三个 .ts @configurable 头为纯注释，无行为变更；register-hooks-cj 头声明 canonicalPath $HOME/dev/task-planner，与代码 186 行 TASK_PLANNER_ROOT 默认一致

## 回归面/负结果报告
- 检查文件：全部 35 个 diff 文件 + resolve-plan-dir.sh/goal-gate.md/verification.md 等被引用件；未发现问题路径：SQL 注入/XSS/路径穿越（plan-created.cjs 指针读取加 isValidSlug + 内容 strip，拒路径穿越；check-rescue-chain 的 cp_val 用 case /* 相对/绝对分支 + PLAN_DIR 前缀拼接，无注入面）；flock 三处锁名一致 .ledger_lock（T-6 已统一）；exit code 契约 0/1/2 与既有门控兼容（check-rescue-chain exit 2 不阻断，check-complete 只认 rc==1）
- awk/grep 边界：grep -E '^- \*\*Executor:\*\*' 转义正确（selftest T08 验证完全无 Executor 行 legacy 放行）；check-complete:484 附近 awk 区间模式 `^###|^##  ` 双空格口径与 python 段切一致（实测行序不敏感）
