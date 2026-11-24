<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-sp-os-invocation-audit-20261124

- task_id: `task-sp-os-invocation-audit-20261124`
- 时间: created_at=2026-11-23T20:11:24Z / updated_at=2026-11-24T00:45:50Z

## Goal (1 sentence)
- 用一手证据查清 11-16 路由修改后 SP/OS 两族技能是否被主动调用（调用并用于推进解决，仅文字提及不计）。
- 定位「未被调用」的技能设计层根因（缺哪个驱动点/门 + file:line），逐条验证或推翻 H1-H5。
- 产出可被驱动的改进方案（2-3 方案 + 推荐 + FILE-CHANGE + DRIVE-POINT）并经独立评审，待用户批准、本轮不实施。

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pending | 计划与报告均经独立审计达标。判据：末轮审计 verdict=APPROVED，且存在与末轮轮次一致、以「[audit-before-delivery] verdict=APPROVED round=」开头的行动留痕（即报告面审计已登记）。改前：没有报告面审计留痕 → FAIL。 | jq -e --argjson r "$(jq -r '.audits[-1].round' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json)" '.audits[-1].verdict=="APPROVED" and (any(.actions[]; .text[0:48] == "[audit-before-delivery] verdict=APPROVED round=\($r)") or any(.actions[]; .text[0:49] == "[audit-before-delivery] verdict=APPROVED round=\($r)"))' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json |  | plan-brief v2 §I 终稿 |
| VC-2 | pending | 设计层现状表落盘（R1）。判据：report-design-sp.md 的 SP 行 ≥14；report-design-os.md 的 OS 行 ≥11；report-driver-gap-1.md 与 report-driver-gap-2.md 的 DRIVER-GAP 行各 ≥1（改前文件不存在 → FAIL）。 | test "$(grep -c '^[\|] SP-' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-sp.md)" -ge 14 -a "$(grep -c '^[\|] OS-' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-os.md)" -ge 11 -a "$(grep -c 'DRIVER-GAP' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-1.md)" -ge 1 -a "$(grep -c 'DRIVER-GAP' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-2.md)" -ge 1 |  | plan-brief v2 §I 终稿 |
| VC-3 | pending | 日志全量覆盖（R2）。判据：files ≥7 且逐一覆盖 11-18..11-24 七个日志文件的绝对路径；每文件 lines_scanned>0；parse_bad 为数值且 ≤ lines_scanned×5%。 | jq -e '.files[-7] != null and all(.files[]; .lines_scanned>0 and (.parse_bad - 0)==.parse_bad and (.parse_bad - 0) <= (.lines_scanned * 0.05)) and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-18.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-19.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-20.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-21.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-22.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-23.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-24.jsonl")' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  | plan-brief v2 §I 终稿 |
| VC-4 | pending | 调用量化结论（R2/R4）。判据：totals 的会话数、调用数、used 数、提及数、openspec 调用数均存在，verdict 非空，definitions 非空。 | jq -e '.totals.sessions_main != null and .totals.sessions_main_with_sp != null and .totals.sessions_main_with_os != null and .totals.sessions_main_with_sp_used != null and .totals.sessions_main_with_os_used != null and .totals.skill_calls_sp != null and .totals.skill_calls_os != null and .totals.escort_reads_sp != null and .totals.escort_reads_os != null and .totals.openspec_cli_calls != null and .totals.mentions_text_sp != null and .totals.mentions_text_os != null and .totals.verdict != null and .totals.verdict != "" and .definitions != null' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  | plan-brief v2 §I 终稿 |
| VC-5 | pending | 独立复检一致（R2）。判据：recheck.max_rel_diff ≤0.01 且 rechecker=Verifier。 | jq -e '.recheck.max_rel_diff<=0.01 and .recheck.rechecker=="Verifier"' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  | plan-brief v2 §I 终稿 |
| VC-6 | pending | 侧证清点（R2）。判据：report-plans.txt 的 PLANS-EVID 行 ≥1；report-openspec-artifacts.txt 的 OS-ARTIFACT 行 ≥1。 | test -s /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-plans.txt -a "$(grep -c '^[P]LANS-EVID' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-plans.txt)" -ge 1 -a "$(grep -c '^[O]S-ARTIFACT' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-openspec-artifacts.txt)" -ge 1 |  | plan-brief v2 §I 终稿 |
| VC-7 | pending | 根因全覆盖（R4）。判据：root_causes 覆盖 H1-H5，每条 defect 以 CONFIRMED 或 REFUTED 开头，process 非空且 ≥61 字符（改前占位条目 defect 以 verified=false 开头 → FAIL）。 | jq -e 'all(.root_causes[]; (.defect[0:9]=="CONFIRMED" or .defect[0:7]=="REFUTED") and .process != "" and .process[60:61] != null) and .root_causes[-5] != null and any(.root_causes[]; .id=="H1") and any(.root_causes[]; .id=="H2") and any(.root_causes[]; .id=="H3") and any(.root_causes[]; .id=="H4") and any(.root_causes[]; .id=="H5")' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json |  | plan-brief v2 §I 终稿 |
| VC-8 | pending | 改进方案 + 评审（R3）。判据：improvement-options.md 含 (Recommended) ≥1；improvement-proposal.md 的 FILE-CHANGE 行 ≥1、DRIVE-POINT ≥1；末轮审计 APPROVED。 | test "$(grep -c '[(]Recommended[)]' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-options.md)" -ge 1 -a "$(grep -c '^[F]ILE-CHANGE' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-proposal.md)" -ge 1 -a "$(grep -c 'DRIVE-POINT' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-proposal.md)" -ge 1 -a "$(jq -r '.audits[-1].verdict' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json)" = APPROVED |  | plan-brief v2 §I 终稿 |
| VC-9 | pending | 写入范围零越界（C1）。判据：writes.txt 非空且不存在位于 `PD/`、`T/` 之外的路径。 | test -s /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt -a -z "$(grep -v -e '^/mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/' -e '^/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt)" |  | plan-brief v2 §I 终稿 |
| VC-10 | pending | 逐会话推进证据齐备（R4）。判据：sessions_with_calls_main 与 session_evid_rows 均存在且相等（零调用时二者均为 0）。 | jq -e '.totals.sessions_with_calls_main != null and .totals.session_evid_rows != null and .totals.sessions_with_calls_main == .totals.session_evid_rows' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  | plan-brief v2 §I 终稿 |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
