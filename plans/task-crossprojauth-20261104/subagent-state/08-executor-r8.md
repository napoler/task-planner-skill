
## S1 R8-a 条款插入证据（2026-11-04）
- 6 文件 `grep -c '^## QC 强制抽检门'` = 1 各：
  - /home/terry/.zcode/agents/image-generation-executor.md =1
  - /home/terry/.zcode/agents/video-generation-executor.md =1
  - /home/terry/.claude/agents/image-generation-executor.md =1
  - /home/terry/.claude/agents/video-generation-executor.md =1
  - /home/terry/.cursor/agents/image-generation-executor.md =1
  - /home/terry/.cursor/agents/video-generation-executor.md =1
- 既有章节标题（Role Definition/核心能力/前置检查/Workflow/禁止行为/证据要求/验证协议/负结果报告）每位=1，6 文件全 OK
- frontmatter L1-8 三位逐位比对：zcode=引号+custom UUID model；claude=无引号+model: sonnet；cursor=无引号（description 无引号）+custom UUID model——零改动
- zcode/claude `git diff --stat`：各 +7 行（仅新增条款块），14 insertions(+) 合计
- 插入位置=各文件「## 负结果报告」段之前（image 位 L68 / video 位 L69 附近确认）

## S2 R8-a 部署位提交证据
- zcode 仓（main）提交 hash=f12c044，2 files +14 insertions（image +7 / video +7，仅条款块）
- claude 仓（master）提交 hash=bc5f2a6——**登记**：该仓此前未跟踪这两个 agent 文件（untracked），commit 呈 new file mode（+76/+77=整文件），非 +7/+8 增量；pathspec 仍严格限定两文件，内容=frontmatter 逐位适配+正文含新条款块，无越权改动
- cursor 位：仅落盘不提交（~/.cursor 非 git）✓
- 提交前 zcode/claude `git status`：claude 仓 agents/ 大量他文件既有 M 状态（其他会话遗留），本次 pathspec 未触碰 ✓

## S3 R8-b 顶锚 11x 预放宽证据（源仓 28 脚本逐文件 Edit，禁 sed 全仓）
- 全量面（S3 前 grep -ln '10[0-9]' *.sh）=28 文件全命中已处理清单：anti-deferral/subagent-activation/absorption-discipline/conclusion-discipline/context-pressure/decision-drift/drift-check-subagent/error-loop/execution-honesty/iteration-persistence/lane-advancement/parallel-scheduling/plan-tier/reflect-verify/reliability-institution/requirement-coverage/requirement-grading/research-first/root-resolution/self-resolution/session-log/skill-split/source-anchor-discipline/summary-readability/tool-selection/verification-gate/veto/capability-persistence
- 清单外命中登记：无（28 命中文件全部属 spec 已知面族+同族随动面；纯数字注释/config 键 53 类非窗口命中 0 处——grep 面即判据 1-9 全族覆盖）
- 判据落点：ERE 裸族 1-(8[0-9]|9[0-9]|10[0-9])→补 |11[0-9]（含 尾缀/AD-09/SA-11 形态、session-log 负样本探针 1-110→1-120）；AD-04 面 1-(7[0-9]|[89][0-9]|10[0-9])→补 11[0-9]；BRE 并联族 1-[89][0-9]|10[0-9]→|11[0-9]（DCS-11/RG-06/VG-06/RF-06/decision-drift）；skill-split 面 Rules 1-(3[0-9]|[4-9][0-9]|10[0-9])→补 11[0-9]（+AD-12 pin 行 L100 同步）；conclusion-discipline n35 面 1-(3[5-9]|9[0-9]|10[0-9])→补 11[0-9]；「其余 8[0-9] 条」→「其余 [89][0-9] 条」（AD-10/SA-12b 两处 live 锚）
- AD-12 pin 面 L91-100 11 处 pin 与兄弟脚本 live 主锚逐字一致同改（pin 断言的 grep -qF 目标字面 5 _pin_lit + _pin_tol 2 处随兄弟 live 面改，skill-split pin L100 随 skill-split live 面改）
- 负断言族 0 改动：1-39/1-40/1-51|53|55/40-[5-8][0-9]=0 等 grep 计数逐文件复核未变
- 注释行：改动行紧邻 R2/R3 注释追加「[2026-11-04 task-crossprojauth-20261104-R8: 11x 预放宽]」短注；历史注释行不改写
- S3 后残留扫描：grep '10[0-9]' 非注释 live 行且同行无 11[0-9] =0（RESIDUAL LIVE=0）
- 11[0-9] 全量面 grep -rn *.sh | wc -l =74（≥30 判据 PASS）
- 28 文件 bash -n 语法全过

## S4 源仓提交证据
- 源仓 commit=008e680（pathspec 28 脚本逐个 add，28 files +79/-79，零新脚本零新键）

## S5 部署位提交与 cmp 对账证据
- 28 脚本仅 cp 本次放宽面（禁整目录 cp）至 zcode/claude/cursor 三部署位 scripts/
- 三位 vs 源仓 cmp：drift_zcode=0 drift_claude=0 drift_cursor=0；zcode↔claude、zcode↔cursor 互 cmp 全一致（MISMATCH 0）
- 提交 hash：zcode=32bb716（28 files +79/-79）；claude=456fed0（同）；cursor 位仅落盘不提交

## S6 fresh 全量回归证据
- bash skills/task-planner/scripts/run-selftests.sh --fresh 输出尾部：
Total: 94 PASS=94 FAIL=0 (run=94 reused=0)
- 判据全绿：live 1-(8x|9x|10x|11x) 全集 grep SKILL.md=3 ≥1/≥2/≥3 各面；「其余 [89][0-9] 条」=2 ≥2；live 1-102 在位（,96=2、85 条 L9/L210 双载体）

## S7 全量自检表
| 项 | 判据 | 实测 | 结论 |
|----|------|------|------|
| S1 6 文件 QC 门 grep -c | 各=1 | 6/6 各=1 | PASS |
| S1 章节标题 | 8 章各=1 | 6 文件全 OK | PASS |
| S1 frontmatter | 三位零改动 | zcode/claude git diff 仅 +7 行条款块；cursor L1-8 人工比对不变 | PASS |
| S2 部署位提交 | zcode/claude pathspec 提交+cursor 落盘 | zcode=f12c044 claude=bc5f2a6 | PASS |
| S3 全量面 10[0-9] | 清单外命中登记 | grep -ln 28 文件=已处理 28 清单，清单外=0 | PASS |
| S3 11[0-9] 面 | ≥30 | =74 | PASS |
| S3 残留 live 10-only | =0 | RESIDUAL LIVE=0（仅 R2/R3 历史注释行含 10[0-9] 字样，非 live 面） | PASS |
| S3 负断言族 | 原值不动 | 1-39=7 处/40-[5-8][0-9] 负断言 in位/1-(51|53|55)=1 处 均未改 | PASS |
| AD-12 pin 族 | 11 处逐字一致 | 5 _pin_lit 各 1 + _pin_tol 全在位；AD-12 PASS | PASS |
| S4 源仓提交 | pathspec 逐个 | 008e680 28 files +79/-79 | PASS |
| S5 三方 cmp | drift=0 | zcode/claude/cursor vs 源仓 三向 cmp 全 0 | PASS |
| S5 提交 | zcode/claude 同 message | 32bb716 / 456fed0 | PASS |
| S6 fresh 回归 | 94/94 | Total: 94 PASS=94 FAIL=0 (run=94 reused=0) | PASS |

## 最终结论
- **R8-a**（47.6 QC 强制抽检门）：2 agent × 3 位 6 文件逐位 in-place 条款块插入全过，frontmatter/model/tools 零改动，zcode/claude 仓已 pathspec 提交，cursor 位仅落盘。
- **R8-b**（纪元顶锚 11x 窗口预放宽）：源仓 28 脚本逐文件 Edit（禁全仓 sed），AD-12 pin 族 11 处与兄弟 live 主锚逐字一致同改，负断言族零改动，fresh 全量回归 94/94 全绿，源仓 008e680 已提交，三部署位 cmp drift=0 且 zcode/claude 已提交。
- **全部 7 项自检 PASS，无 FAIL。**
