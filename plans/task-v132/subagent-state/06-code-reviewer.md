# 06-code-reviewer checkpoint — task-v132 Phase 4（CR 全量 + alignment 双镜头）

- status: done
- 时间: 2026-10-05
- 审查对象: worktree wt/task-v132 相对 master 的 diff（3 commits 4d81b28/757ea24/53699c1，7 文件）
- 只读: 未修改任何被审文件（所有实验在 /tmp 副本上进行）
- 判定: CR 终判=CHANGES_REQUESTED | ALIGN 终判=CHANGES_REQUESTED

## 环境事实（影响复现）
- worktree 工作树当前与 HEAD 不一致：check-complete.sh 的 R-COVERAGE 门被**未暂存删除**
  （`git diff HEAD` = 136 deletions；HEAD grep rcov-gate=5，工作树=0）。
  故所有行为实测均以 `git archive HEAD` 导出的 committed 内容为准（/tmp/committed、/tmp/cskill）。

## CR 镜头发现
### P1-CR-1 R-COVERAGE 门 R 集合提取用未锚定 `grep -oE 'R[0-9]+'`（误报阻断交付）
- 位置: check-complete.sh（rcov_plan_rs 行；committed 版 :800 附近）
- 原文: `rcov_plan_rs="$(printf '%s\n' "$rcov_req_rows" | grep -oE 'R[0-9]+' | sort -u || true)"`
- 复现: 取真实 v131 计划（全 covered，gate PASS 静默 rc=0），仅把 R1 行正文追加「，另见 R9 报告」→ gate FAIL：
  `[rcov-gate] ✗ R-COVERAGE FAILED ... 缺口 — R9(核对表缺行) — 拒 COMPLETE 只可 PARTIAL`（rc=1）。
- 原因: 未锚定，R 行正文内任何 R<数字> 提及（交叉引用，如 v131 R7「（R3 重申）」先例）被当作需求编号；
  真实需求未变却报「缺行」→ enforce 档误拦截合法交付。
- 修法: 锚定 R 行首编号，如 `grep -oE '^[[:space:]]*[-*][[:space:]]*\**R[0-9]+'` 后再取 R<数字>；
  或直接在 awk 状态机中输出行首 R 号。
- 置信度: HIGH（机制已复现）／真实触发频率 MEDIUM

### P2-CR-2 lint 子串边界误报（exit 1 超出「样张级」口径）
- 位置: check-window-consistency.sh:70-87（WEEK_FAMILY/HOUR_FAMILY 词）+ contains() :108
- 复现（锚=一个月 月族）:
  `第7天` → ⚠『7天』rc=1；`124小时` → ⚠『24小时』rc=1；`下一周` → ⚠『一周』rc=1。
- 原因: 纯子串 contains，无边界；且 FMEA F2 声明「exit 1 仅样张级明确不一致」，实测把里程碑「第7天」等误升为阻断级。
- 修法: 命中后加左边界排除（前一字符为数字=否）或提供豁免/降档；至少「第N天」规则化。
- 置信度: HIGH

### P2-CR-3 lint 无生产调用点（孤立机制）
- 位置: check-window-consistency.sh（全脚本）
- 证据: `grep -rn "window-consistency\|window-lint" .` 仅命中 selftest-requirement-coverage.sh（RC-17）；init/attest/check-plan-dispatch/check-complete 均无调用。
- 影响: 该 lint 在生产链路永不自动运行，G2 运行期保护缺失（仅单测跑）。
- 置信度: HIGH（无调用点）／意图 MEDIUM

## ALIGN 镜头发现
### P1-ALIGN-1 51.7 条款声称 lint 属 attest/dispatch 门，代码无接入（文档↔代码不一致）
- 位置: references/critical-rules.md:567
- 原文: `执行体已在途的，重建派发前重过 attest/dispatch 门（含窗口口径 lint）。`
- 证据: `grep -rn "window-consistency" .` 无 attest-plan.sh / check-plan-dispatch.sh 命中（仅 selftest）。
- 影响: 条款承诺的运行期门控无实现，属「声称有机制、代码无」。
- 修法: 在 attest-plan.sh 或 check-plan-dispatch.sh 增调用（warn 起步），或改 51.7 措辞为「建议手动运行 scripts/check-window-consistency.sh」。
- 置信度: HIGH（无调用点）／「应否接线」MEDIUM

### P1-ALIGN-2 init silent 判定 env-only，偏离唯一权威解析器口径
- 位置: init-session.sh:546
- 原文: `if [ "${TASK_PLANNER_INTERACTION_MODE:-}" = "silent" ] && [ -f "task_plan.md" ]; then`
- 证据: scripts/resolve-interaction-mode.sh:4-8 权威四级口径 = ①env →②计划配置表行 →②b mini 缺省 →③config.json；
  init 仅实现 ①。经②/③判定为 silent 的计划不会即时落锁。
- 影响: G3「silent 路径锚哈希即时落盘」对非 env 通道的 silent 计划失效（窗口期保护缺口）；
  init:530 注释自称「Rule 28 解析口径」与实现不符。
- 修法: 调 `bash "$SCRIPT_DIR/resolve-interaction-mode.sh" <plan>` 取口径，仅在结果=silent 时落锁。
- 置信度: HIGH（代码事实）／实际触发面 MEDIUM

### P2-ALIGN-3 「Rule 51 六子条」枚举随 51.7/51.1a 增量未同步
- 位置: SKILL.md:304 ／ scripts/selftest-registry.tsv:50 ／ selftest-requirement-coverage.sh:4,26
- 原文: `需求原文锚定+验证机制先行+完成声称对照门+自缩水禁令+生成前置盘点六子条`
- 证据: 条款实际含 51.1,51.1a,51.2-51.7（`grep -cE '^51\.'` = 8）；RC-01 断言 ≥6 故未 FAIL。
- 影响: 用户可见摘要/登记枚举落后于条款增量（计数联动漂移）。
- 修法: 统一改「七子条（51.1-51.7）」或注明「51.7 增补」。
- 置信度: HIGH（文本过期）／是否算缺陷 MEDIUM

### P2-ALIGN-4 rcov_concession_registered 关键词共现启发式（放宽面）
- 位置: check-complete.sh（rcov_concession_registered 函数）
- 原文: `grep -E "\b$1\b" ... | grep -qE '让步|uncovered|partial'`
- 影响: Decisions 中某行若同时出现「R<k>」与 partial/让步 词（非真让步语境）会被判为已登记→放行 uncovered。
- 修法: 收紧为「R<k> + 让步」明确同现（去掉宽词 uncovered/partial）或要求行首结构。
- 置信度: MEDIUM

## P0 状态异常（阻断合并回约 §11.3，非 diff 缺陷）
- worktree 工作树 check-complete.sh R-COVERAGE 门被未暂存删除 → `git status` 不干净；
  工作树跑 selftest-requirement-coverage.sh = `Total: 22 PASS=19 FAIL=3`（RC-18/19/20 FAIL）。
- committed 内容无此问题（导出后 `Total: 22 PASS=22`）。
- 处置建议: `git restore skills/task-planner/scripts/check-complete.sh` 或 `git checkout HEAD -- <file>` 恢复后复跑；确认无并行会话误删。

## 正面验证（负结果）
- 零回归: 真实 v131 计划目录 master vs v132(committed) check-complete 输出 stdout 逐字节 IDENTICAL、
  stderr（剔除 rcov 行）IDENTICAL（warn/enforce 双档）。R-COVERAGE 门与 VC-GATE/DELEGATION 门互不干扰。
- committed 内容全量 selftest：51 个 selftest-*.sh 全部 rc=0（SUM FAILED=0）。
- 51.1 四锚硬门不可被 --skip 绕过：`attest-plan.sh --skip-dispatch-check --skip-fmea-check <缺🎯计划>` rc=1（fail-closed 在位）。
- 51.7/判例纯增量：51.1 末句原文保留+尾追加；`grep -c` 三锚（51.7/判例/报告路径）各=1。
- 引用完整性：51.1 判例引用报告 plans/incident-reports/2026-10-05-72h-instruction-mutation.md 存在。
- 登记联动：registry 行 NF=4；selftest-registry.sh 5/5（rows=51=actual）；selftest header RC-01..RC-22 已同步。
- 越界: numstat 7 文件全部落在 scope（critical-rules/check-complete/check-window-consistency/init-session/zcode-userpromptsubmit/selftest-requirement-coverage/registry）。
- CHANGELOG：最近一次维护在 task-v117，本仓惯例非逐任务更新 → 未改不构成不一致（deferred）。
- 多部署位同步：本机仅见 2 处（.zcode/skills、repo），按任务书 deferred Phase 5。

## 证据索引（可重跑）
- /tmp/px131 系列 & /tmp/cmp/{master,wt}/scripts/check-complete.sh（对称对比目录）
- /tmp/cskill = `git archive HEAD skills/task-planner`；/tmp/committed = scripts+references
- 复现命令见各发现

---

## 复审轮（Round 2，2026-10-05）— 对 fix 提交 b2780a0 + 80dedc4

- 审查对象: wt/task-v132 最新 HEAD=80dedc4 相对 master（10 文件，+941/-14）
- 工作树: git status 干净（P0 状态异常已消除；rcov-gate 工作树=5=HEAD）
- 判定: CR 终判=APPROVED | ALIGN 终判=CHANGES_REQUESTED
- 证据环境: `git archive HEAD skills/task-planner` → /tmp/cskill2（语法全 OK）

### 已修复并实测确认（负结果，逐条复现）
- P0 状态异常: `git status --short` 空；`grep -c rcov-gate` 工作树=HEAD=5 ✅
- CR-P1 R 集合误报: 真实 v131 计划 R1 行注入「另见 R9」+R2 行注入「（R3 重申）」→ enforce rc=0 PASS 静默；删 R7 核对行 → rc=1 `R7(核对表缺行)` ✅（b2780a0 awk 行首锚定）
- CR-P2 lint 边界: 第7天 rc=0 / 124小时 rc=0 / 「7 天」rc=1 / 「7天」rc=1 / 「一周」rc=1 / 「30天」advisory rc=0（window_word_hit 前数字/「第」排除）✅
- CR-P2b+ALIGN-P1a lint 接线: attest-plan.sh:326 调 lint；实测跨族计划 → stderr 出 `[window-lint] ⚠` + `[attest] [window-lint] 警告` 且 `.plan-attestation` 生成、rc=0（warn 级不拒锁）✅
- ALIGN-P1b init silent 权威链: env 路径 → 判定来源=env 落锁；resolver 路径（前置干净 silent 行计划）→ 判定来源=resolver 落锁；ask → 零落锁 ✅
- ALIGN-P2 让步判定收紧: partial+Decisions 仅状态词「目前为 partial」→ rc=1；partial+「显式让步」→ rc=0 PARTIAL 提示 ✅
- ALIGN-P2 六子条枚举: SKILL.md:304/registry:50/RC-01 `-ge 7` 已同步（子条实测 8）✅ 但见下方新 P1
- RR-09 负断言语境锚定: `grep -cE '(全集|Rules) 1-51'`；root-resolution 17/17 PASS ✅
- 全量回归: 真实 worktree 内 51 个 selftest 全 rc=0（FAILED=0）；PASS_SUM=777（对账一致）✅
- 零回归: v131 真实计划 master vs v132 输出 stdout 逐字节 IDENTICAL、stderr(剔 rcov) IDENTICAL（warn/enforce 双档）✅

### 复审新发现（本轮）
#### [P1-ALIGN-R2] references/critical-rules.md:566 — 51.6 枚举+机制状态未随 v132 同步（最后一处落点漏改）
- 原文: `selftest-requirement-coverage.sh 静态守护（六子条锚+SKILL/模板联动锚+负断言）；…；check-complete 深化解析（自动核对覆盖表）登记 deferred 候选，不弱化既有终验门控`
- 证据: (a) SKILL.md:304/registry:50/RC-01 已升级「七子条/-ge 7」，51.6 仍写「六子条锚」→ 同规则计数自相矛盾；
  (b) check-complete.sh 的 R-COVERAGE 门已实现「自动核对覆盖表」（`grep -c rcov-gate`=5）→ 51.6 称其「登记 deferred 候选」= 声明与事实不符。
- 根因: 任务书「critical-rules.md 纯增量、禁改既有条款语义」+「六→七子条同步」仅列 SKILL/registry/RC-01，51.6 落点遗漏。
- 建议修法: 最小事实同步——51.6「六子条锚」→「七子条锚」、「登记 deferred 候选」→「已落地（task-v132 G1 R-COVERAGE 门）」；
  或由主进程在 Decisions Made 显式登记「51.6 措辞暂缓同步」并接受该文档漂移。
- 置信度: HIGH（文本/实现双向取证）／应否本轮修 MEDIUM（受纯增量纪律约束）

#### [P2] init resolver 路径被模板占位行遮蔽（ALIGN-P1b 残留面）
- 位置: init-session.sh（resolver 分支）/ resolve-interaction-mode.sh:64（`head -n1`）
- 实测: init 生成计划第 50 行含模板指导行 `| \`interaction_mode\` | \`ask\` / \`silent\`（可省略…） |`，
  resolver 取首行值列得 `ask`（合法）→ 直接 emit ask，后置真实 `silent` 行（:461）永不生效 → 返回 ask。
- 影响: 对 init 自生成计划，ALIGN-P1b 的计划表路径不生效（仅手写/首行即 silent 的计划生效）；
  env 通道仍生效（主通道，影响面窄）。属 resolver 既有 head -n1 语义，非 v132 引入。
- 置信度: HIGH（实测 resolver 输出 ask）

#### [P2] 修复批越界（相对 task_plan.md「执行范围限制」）
- 证据: 修复新增触碰 attest-plan.sh / SKILL.md / selftest-root-resolution.sh，原允许清单未含（脚本栏仅列 check-complete/新 lint/zcode-userpromptsubmit/init-session）。
- 说明: 均为响应 CR/ALIGN P1 的必要最小改动且经本次复审请求显式点名 → 建议由主进程 Decisions 补登记范围扩权，不阻断。
- 置信度: HIGH

### 复审结论
- CR 终判: APPROVED（CR-P1/CR-P2/CR-P2b 三项已修复并实测；P0 状态异常已消除；51 selftest 全绿；零回归）
- ALIGN 终判: CHANGES_REQUESTED（P1-ALIGN-R2 单条：critical-rules.md:566 枚举/机制状态漂移未清）
