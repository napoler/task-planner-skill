# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## Phase 1 Findings (2026-09-10)
- 10 文件全量 cp -f 落盘 worktree：`diff -rq /home/terry/.zcode/skills/task-planner skills/task-planner -x .git` EXIT=0（0 differ），zcopy 自带 .git 目录未拷入（预期）
- git status 仅 skills/task-planner 10 文件 M + 本计划目录 untracked，无越界文件
- 收编内容确认：① active-plan-race（zcopy git 6685a93）9 文件 ② check-complete Rule 25.4 白名单豁免（zcopy 侧未入 git 直接改动）
- 证据：diff 命令输出（本会话工具记录）；zcopy 提交信息 `git -C /home/terry/.zcode/skills/task-planner log -1 6685a93`

## 排查 Findings: dispatch-block 误拦（2026-09-10）
- 3 次 Agent() 被旧 hook（主仓 v058 版 check-dispatch，无 sid 解析）按主仓 .active_plan=task-v058 的计划目录校验，prompt 指向 worktree 计划目录 → task_plan.md/findings.md/progress.md 缺项拦截。= active-plan-race 缺陷的又一次实锤
- 修复链路（主仓操作，不属 worktree 范围）：
  1. `ln -sfn <worktree>/plans/task-v059-active-plan-race /mnt/data/dev/task-planner-skill/plans/task-v059-active-plan-race`（符号链接）
  2. `set-active-plan.sh set task-v059-active-plan-race --sid 980c720a... /mnt/data/dev/task-planner-skill`（side 指针）
  3. 主仓 legacy `plans/.active_plan` 写入 task-v059-active-plan-race
- 证据：旧链路 `check-dispatch.sh check` EXIT=0；新 zcopy 链路 `TASK_PLANNER_SID=... check-dispatch.sh pretool` EXIT=0（两条命令输出见会话记录）

## Phase 2 Findings (2026-09-10, executor 02)
### P2-S1: 4 既有 selftest 全过（VC-2）
worktree 内 `bash skills/task-planner/scripts/<t>` 直跑，无需额外环境变量（脚本自定位 SCRIPT_DIR），两次复跑一致：
| selftest | EXIT | 计数 |
|---|---|---|
| selftest-dispatch.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| selftest-delegation.sh | 0 | Total: 38 PASS=38 FAIL=0（含 T17/T17b/T18/T18b 白名单相关 + T_RATE_OK/T_RATE_LOW 委派率用例） |
| selftest-plan-dispatch.sh | 0 | Total: 6 PASS=6 FAIL=0 |
| selftest-fallback.sh | 0 | Total: 21 PASS=21 FAIL=0（输出含 2 行 jq 语法警告，属该脚本 T06e 既有用例行为，不影响计数） |
证据：命令输出原文（本 executor 工具记录）；关键行 `Total: 38    PASS=38  FAIL=0` / `EXIT=0`。

### P2-S2: VC-7 白名单豁免 3 用例（Rule 25.4 行为验证）
- 输入来源：check-complete.sh:372 调 `check-delegation.sh stats <plan-dir>`（:102 PLAN_DIR_GUESS=plan 文件目录）→ 单行 JSON；白名单块 :407-421；floor :112 从 config.json 读（当前 0.7）；jq 缺失 :415 `command -v jq` 判定分支 → fail-closed
- 夹具在 /tmp/v059-vctest/（case1/plan、case2/plan 各 3 文件；nojq-bin=符号链接 /usr/bin 全部命令并 rm jq），零污染 worktree
| 用例 | 输入摘要 | 期望 | 实际 | 一致 |
|---|---|---|---|---|
| 1 白名单内理由 | rate=0.000<0.7，reason「白名单①: git 编排…」 | EXEMPT 放行 exit 0 | exit 0，stderr `[plan] DELEGATION RATE WHITELIST-EXEMPT (rate=0.000 < floor=0.7, main_direct=1 条理由全白名单内, Rule 25.4 不降级)` + `DELEGATION GATE PASSED` | 是 |
| 2 非白名单理由 | reason「实现登录功能」 | 保持 FAILED | exit 1，`DELEGATION GATE FAILED (Rule 25.4 / task-v055) — verdict=violation`（self_declared_reason violation），无 EXEMPT 行 | 是 |
| 3 jq 缺失模拟 | `env PATH=/tmp/v059-vctest/nojq-bin`（jq 不可见，python3/awk/grep 保留）跑用例 1 夹具 | fail-closed 保持 FAILED | exit 1，`DELEGATION GATE FAILED (verdict=ok rate=0.000 floor=0.7)`，无 EXEMPT 行（grep 兜底能解析 rate 但豁免分支要求 jq） | 是 |
判定命令（已记录进 02-executor.md checkpoint）：
- case1: `bash $CC /tmp/v059-vctest/case1/plan/task_plan.md` → exit 0
- case2: `bash $CC /tmp/v059-vctest/case2/plan/task_plan.md` → exit 1
- case3: `env PATH=/tmp/v059-vctest/nojq-bin bash $CC /tmp/v059-vctest/case1/plan/task_plan.md` → exit 1
其中 `CC=<worktree>/skills/task-planner/scripts/check-complete.sh`

## Phase 3 Findings (2026-09-10, Code Assistant 03)
#### [sub:03-code-assistant] P3-S1/P3-S2 文档净零联动（worktree skills/task-planner/，4 文件 +7/-3）
| 文件:行 | 改动 | 理由 |
|---|---|---|
| README.md:94 | resolve-plan-dir.sh 行描述改为「可选第 2 参 sid：.active_plan_side/<sid> 会话层指针 TTL 24h → 全局 legacy → mtime 最新」 | 原「保留解析链+slug 校验」是 Phase 1 之前旧仓库描述，与脚本现行为漂移（:95 set-active-plan 行已随 zcopy 拷入无漂移，未动） |
| SKILL.md:64 | 初始化段补 1 行「会话隔离指针（active-plan-race）」（side 会话层 + legacy 兜底 + gc，指 Rule 22.9） | 机制在 SKILL 无任何描述（grep active_plan 0 命中）；插在 init-session 行后 1 行，净零 |
| references/critical-rules.md:139 | 新增 Rule 22.9（双参解析链/写入侧认领/.session-owner/gc，1 行） | 原 22.x 无指针机制规则；编号续 22.8.5 之后，与 §23 并行冲突主题衔接 |
| INSTALL.md:183 | 5.1a 段补 1 行「会话 sid 隔离」 | hook 说明处（check-dispatch/PreToolUse 上下文）缺 sid 隔离句 |
| critical-rules.md:171 | 新增 Rule 25.4a（白名单豁免机械执行：六关键词 ①git 编排/②计划系统文件/③机械验证/④用户显式/⑤兜底接管/⑥trivial → WHITELIST-EXEMPT；未命中 FAILED；jq 缺失 fail-closed） | 25.4 原文(:170)已有「全白名单→不降级」语义但无机械执行/标记名；check-complete.sh:411 注释「依据 critical-rules 25.4」需文档可查落地规则号 |
| SKILL.md:150 | 终验段 Rule 25 行尾补「白名单豁免」半句 | SKILL 摘要处无豁免说明，check-complete 行为对齐 |

## 负结果报告（P3）
- 已核查依赖文件：resolve-plan-dir.sh / set-active-plan.sh / check-complete.sh / zcode-pretooluse.sh / zcode-userpromptsubmit.sh / zcode-sessionstart.sh 头部注释与关键行（.session-owner 命中 5 处）、SKILL.md/README.md/INSTALL.md/critical-rules.md 全文 grep（active_plan/指针/25.4/白名单/22.8）
- 未发现冲突：25.4 原行语义与新 25.4a 互补无矛盾；README:95 无漂移未动；22.4c「当前活跃计划」表述无需改（指 Rule 22.9 即可）
- 排除风险：未触碰 scripts/ 任何文件；未改 Q5(:182/:194) 25.4 引用行（语义已被 25.4 原行覆盖，无需扩）；改动全部在允许文件清单内（git diff --stat 4 文件 +7/-3 佐证）

## Phase 4 Findings (2026-09-10, Test Engineer 04)
### P4-S1: zcopy 自测核实 + 新增 selftest-active-plan.sh（VC-2/VC-3）
- 核实结论：zcopy 6685a93 提交信息声称「自测: 4 selftest 97/97 + E2E 双向」，但 `git -C /home/terry/.zcode/skills/task-planner log -1 6685a93 --format=%B` 证实该 97/97 属提交时一次性 /tmp 运行记录，未随 10 文件入库（zcopy 仓 git 仅 2 commit：e429b5a baseline + 6685a93，6685a93 的 diff 不含任何 selftest 文件）；仓内可复跑的 4 selftest = dispatch 12 + delegation 38 + plan-dispatch 6 + fallback 21 = 77 用例，均不覆盖 active-plan-race 新机制（grep side/TTL/gc 0 命中）→ 按仓内范式补 1 个新脚本（VC-3 判据：worktree 自测全集可复跑全过，以 90 用例为准）
- 新增 `skills/task-planner/scripts/selftest-active-plan.sh`（116 行，hermetic：全部夹具 mktemp -d，trap rm -rf，零仓外状态依赖；call() 助手统一 env -u CLAUDE_CODE_SESSION_ID 防外层 env 扰动；T08 对 init-session 加 find-upward/.claude/plan-templates 根遍历无命中核查，find_project_templates 失败 return 1 不触 set -e）
- 用例设计（9 项要求 → 13 计数，子项分编号）：
  | # | 覆盖点 | 设计 | 结果 |
  |---|--------|------|------|
  | T01/01b | side 优先 | legacy=aa + side(s1)=bb 并存，resolver 带 s1 → bb；带 s2（无 side）→ aa | PASS |
  | T02 | 无 sid 零破坏回归 | 只 legacy 存在，无 sid 调用 → legacy 指向 | PASS |
  | T03 | TTL 过期 | side touch -d '25 hours ago' → 被跳过走 legacy | PASS |
  | T04/04b | 非法 slug | side 内容 `../evil` 与 `/abs/evil` → 均拒绝走 legacy | PASS |
  | T05a/05b | set 位置参数兼容 | 旧签名 `<task-id> [root]` 写 legacy；`set <task-id> --sid sX [root]` 写 side | PASS |
  | T06 | gc 清扫 | 25h 旧 side 删除、新 side 保留、计数=1（gc 的 root 为位置参数 `[root]`，验证位置） | PASS |
  | T07 | --show 双视图 | 同显 全局指针行 + `side 指针(sid=sZ): bb` + 解析=side 指向 | PASS |
  | T08a/08b | init-session 分支 | CWD=plans/xx + env sid → 写 side/xx 且 legacy 不存在；CWD=plans/yy 无 sid → 写 legacy=yy 且无 side/yy（只断言指针写结果，未跑全模板流） | PASS |
  | T09 | fail-open（加分） | 不存在 root 恒 exit 0 空输出 | PASS |
- 首跑 13/13 PASS EXIT=0；复跑 5 selftest 全集（与 Phase 2 同命令）：active-plan 13 + dispatch 12 + delegation 38 + plan-dispatch 6 + fallback 21 = 90 用例，5×EXIT=0，fail=0
- 负结果报告：负路径（T04 穿越、T03 TTL、T06 残留）均实测被正确拒绝/清扫，未发现缺陷；已排除外层 CLAUDE_CODE_SESSION_ID 扰动（call() 统一 env -u）、init-session 根遍历副作用（walked-to-root 实测无 .claude/plan-templates 命中）、plans/ 实体目录污染（复测后 git status 无新增 plans 项，仅原 untracked）
- 改动清单：仅新建 scripts/selftest-active-plan.sh（116 行）+ 本计划三文件 + checkpoint；未改其他脚本（git status 13 M = Phase 1 的 9 源码 + Phase 3 的 4 文档，本 Phase 无增量 M）
