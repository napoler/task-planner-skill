# 07-executor checkpoint — task-v132 Phase 4 修复批 A（2 文件，2026-10-05）

- status: done
- worktree: /home/terry/task-planner-skill-worktrees/task-v132（wt/task-v132）
- 只动 2 文件（git status 确认，`M` ×2，越界文件=0）：
  - skills/task-planner/scripts/check-complete.sh（+30/−9 行级 diff）
  - skills/task-planner/scripts/check-window-consistency.sh（+32/−9）
- 未 commit（任务书要求；工作树保留改动待 CR 复审后随 Phase 4 提交）

## Fix 1 — CR-P1 R-COVERAGE R 集合提取行首锚定（check-complete.sh :795-818）
- 原行为：awk 状态机抽 🎯 区块全量 `- ` 列表行 → 未锚定 `grep -oE 'R[0-9]+'` 提 R 号；
  R 行正文交叉引用（「另见 R9」「（R3 重申）」）被误当需求编号 → enforce 档报「核对表缺行」误拦。
- 修法：awk 锚定 `^[[:space:]]*[-*][[:space:]]*\**R[0-9]+`（任务书给式），状态机内
  `match($0,/R[0-9]+)/` 直接输出行首 R 号 → `sort -u` 即 R 集合；核对表侧（rcov_cov_awk
  表格行首 R cell 提取）本就只认行首 R 号，两侧口径对齐。修改注释含原因/时间/原行为。
- 证据：R1 行注入「另见 R9 报告」、R2 行注入「(R3 重申)」后旧逻辑输出 R 集合含 R9（误报复现）；
  新逻辑输出 R1..R7（R9 不再计入），enforce 档 check-complete rc=0 PASS 静默。

## Fix 2 — ALIGN-P2 :858 让步判定收紧（check-complete.sh rcov_concession_registered）
- 原行为：`grep -E "\b$1\b" | grep -qE '让步|uncovered|partial'` 宽词共现 → Decisions 行仅以
  状态词描述（「R1 目前为 partial」）即被误判已登记让步 → 裸 partial/uncovered 误放行。
- 修法：去掉宽词 uncovered/partial，收紧为「R<k> 与 让步 明确同现」（保留注释说明口径=
  需求锚 R1 逐字「无 Decisions 让步登记→拒 COMPLETE 只可 PARTIAL」，登记判据=让步非状态词）。
- 证据：专项负例（R1 partial + Decisions 仅「R1 目前为 partial，后续版本再覆盖」）enforce rc=1
  拦截；专项正例（Decisions「R1 显式让步（用户确认降范围）」）rc=0 PARTIAL 语义提示放行。
- 零回归：RC-19（缺行）/RC-20（裸 uncovered 双断）PASS——RC-20 正例「R1 显式让步
  （uncovered 登记）」含「让步」字面，收紧后仍双命中，判定结果不漂移。

## Fix 3 — CR-P2 check-window-consistency.sh 边界排除（window_word_hit 新函数）
- 原行为：纯子串 `contains()`；「第7天」（周族「7天」子串）/「124小时」（小时族「24小时」子串）
  误升为阻断级 exit 1，超出 FMEA F2「exit 1 仅样张级」口径。
- 修法：新增 `window_word_hit()`：grep -E 行级匹配，前字符排除数字/「第」（「第N天」里程碑
  形态整体豁免 + 数字前缀=更长数字串子串不拆词），后字符排除同族计量单位延续（天/小时/日
  尾巴不拆词，sed 转义免硬编码词表变更踩坑）；判定①（计划/载荷跨族 ⚠ 警报）与全局出现表
  （term_plan/term_payload）全部改用该函数，豁免语境词（判例/事故/incident-reports）逻辑不动。
- 证据 6 用例（锚=一个月 月族）：第7天 rc=0 / 124小时 rc=0 / 「7 天」独立 rc=1（样张钉住）/
  7天无空格 rc=1 / 一周跨族 rc=1 / 30天同族异值 rc=0 仅 advisory。

## 验证汇总（全部实测，留档 /tmp/v132-fixa/）
| 项 | 结果 | 证据文件 |
|----|------|---------|
| a) v131 计划 + R 行「另见 R9」/「(R3 重申)」注入, enforce | rc=0 PASS 静默（误报消除） | verify-rcov.txt §a + v131-a/ |
| b) 缺行负例（删 R7 核对行）, enforce | rc=1 `[rcov-gate] ✗ … R7(核对表缺行)` | verify-rcov.txt §b + v131-b/ |
| b2) 裸 uncovered 负例（R7=uncovered+证据「无」）, enforce | rc=1 `R7(uncovered 且 Decisions 无让步登记)` | verify-rcov.txt §b2 + v131-c/ |
| ALIGN-P2 负例（partial 仅状态词）/ 正例（含「让步」） | rc=1 / rc=0 | verify-rcov.txt §P2 |
| c) lint 第7天 / 124小时 → rc=0；「7 天」独立 → rc=1 | 全符（含 7天/一周/30天 对照） | verify-lint.txt |
| d) selftest-requirement-coverage.sh | Total: 22 PASS=22 FAIL=0（rc=0） | selftest-rc.out / verify-selftest.txt |
| d) check-window 相关用例（=RC-17，自包含在 requirement-coverage） | PASS（正例 exit=0 无⚠ / 负例 exit=1 有⚠） | selftest-rc.out RC-17 行 |
| 回归：10 个调用 check-complete 的 selftest（vc-gate/final-gate-hash/plan-tier/error-loop/reflect-verify/delegation/mechanism-profile/template-sense/root-resolution/skill-modify） | 全 rc=0 | （未单独留档，本表为准） |
| 语法 | bash -n 两脚本 OK | — |
| 越界 | git status 仅 2 目标文件 M | git diff --stat |

## 负结果说明
- 排除风险：Fix 1 锚定式不误吞 R→VC 映射表（映射表首字符 `|` 不匹配 `^[-*]` 行首式，
  且状态机本就限 🎯 区块至下一 `##` 标题）；RC-12 断言「需求覆盖核对」区块在位仍 PASS
  （模板未动）；lint fail-open 路径（缺参/无计划）行为不变（rc=0 留痕行实测）。
- 未验证项（非本批范围，遗留 CR 发现）：P2-CR-3（lint 无生产调用点）/ P1-ALIGN-1
  （51.7 条款 vs 代码接入）/ P1-ALIGN-2（init silent 判定 env-only）/ P2-ALIGN-3（六子条枚举）
  ——均属修复批 B+ 或 deferred 范围，本批未触碰。
