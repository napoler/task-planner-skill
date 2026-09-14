# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 优化技能执行稳定性：不被中途打断,减少打断概率
- 遇到问题主动解决而非停下——环境级中断（哨兵误拦/tamper 摩擦/observe 噪音/慢注入）自愈或降噪
- 护栏前提：sid 匹配才自愈,外部篡改仍被拒

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **Phase 1 hook 链路六项勘察（seq 01 explore,全文锚点见 subagent-state/01-explore-hooks.md）**：
  - E1 根因：memories 目录**不在**哨兵白名单（check-scope.sh:65-73,grep memories=0;memories 豁免仅在 check-delegation.sh:171 两套独立机制）+ plan-created.cjs:169-177 无 sid 时静默跳过但仍打成功文案（v060 缺陷行）
  - E2 检测点：attest-plan.sh:79-84 唯一比对,仅 zcode-userpromptsubmit.sh:49-56 每轮调用;PostToolUse 挂点可行（.session_id/.tool_name 可取）;**attestation 无 sid 字段**→护栏借 .session-owner 或新增 attested_by_sid
  - E3 根因：zcode-userpromptsubmit.sh **无 CLAUDE_CODE_SESSION_ID env 兜底**（L24 拿空→default→恒不写 owner;对比 resolve-plan-dir.sh:31/attest-plan.sh:34 均有兜底）——sid 源最弱;observe 注入在 check-delegation.sh:112+258-262,不跑 stats
  - E4（KQ3=不同根）：真慢源=Rule 23 全 plans/ 循环（zcode-pretooluse.sh:91-102,32 计划×awk×2）+ resolve_plan_dir_any 7 级盲找——**本任务不动**（FMEA 216 削链风险）,登记 deferred
  - 休眠地雷：owner 读 tr -cd 'a-zA-Z0-9' 丢 _- 与 check-delegation L96 'a-zA-Z0-9_-' 规范不一致（S3 顺带对齐）
  - config 28 键确认,hook_self_heal_enforce 未撞名,新键必须入 .properties（L337 additionalProperties）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| （Phase 2 裁定见下节） | |

## Phase 2 设计定稿（2026-09-14 主进程裁定 = S1-S4 材料包源）

### 自愈矩阵（每类中断:自愈动作+sid 护栏）
| 中断 | 自愈动作 | 护栏 | S-unit |
|------|---------|------|--------|
| E1 哨兵误拦 memory 写入 | check-scope.sh:65-73 豁免表加 `$HOME/.zcode/cli/memories/`* → exit 0 | 仅 memory 目录,不影响其他拦截 | S1 |
| E1' plan-created 清不掉哨兵 | :169-177 无 sid 兜底：清「.active_plan_side/<sidkey>.active_plan **不存在或 mtime>24h**」的 side 哨兵 + 哨兵不存在路径补日志 | 指针存在性+24h 双条件,防误删他会话活跃哨兵（KQ1） | S1 |
| E2 TAMPERED 摩擦 | **方案 A'（PostToolUse 自动重锁）**：zcode-posttooluse.sh 计划探测段后挂——编辑路径==task_plan.md 且 `.session-owner`==本会话 sid → 自动 `attest-plan.sh <path> --skip-dispatch-check` 重锁；attest 写入 attested_by_sid 字段（:68 补） | sid 不匹配（他会话编辑）→ 不重锁,TAMPERED 维持（KQ2;负例必测） | S2 |
| E3 observe 每次注入 | S3a zcode-userpromptsubmit.sh:24-25 UPS_SID 补 env 兜底 `${CLAUDE_CODE_SESSION_ID:-${ZCODE_SESSION_ID:-}}`;S3b check-delegation.sh observe 注入会话级节流（/tmp/task-planner-observe-<sid>.flag,首注后停注）+ owner 读取 tr 规范对齐 'a-zA-Z0-9_-'（休眠地雷顺修） | 节流仅降噪,owner 修复后自然停注 | S3 |
| E4 慢注入 | **本任务不修**（Rule 23 O(N)+盲找优化=FMEA 216 削链风险）→ deferred-issues 登记 | - | - |
| E5 密集提醒 | 不删不降频（提醒机制合理,Rule 26.3）| - | - |

### KQ1-KQ4 裁定
- **KQ1** 哨兵兜底护栏 = 「active side 指针不存在 OR mtime>24h」双条件;活跃指针存在且 <24h 的哨兵兜底不清（负例实测）
- **KQ2** tamper 自愈选 **PostToolUse 自动重锁（方案 A'）**:护栏=编辑会话 sid==.session-owner（计划认领者）;--if-mine 手动模式作为负例失败时的降级备选（FMEA 168 兜底）
- **KQ3** E4 与 E3 不同根（慢源=Rule 23 O(N)+7 级盲找,勘察⑤）→ S3 只修 E3;E4 登记 deferred（本任务不动 Rule 23/pretooluse 循环）
- **KQ4** hook 改动新会话生效:本会话只做临时目录模拟实测,交付口径=新会话;Phase 4 证据标注「模拟」
- **改动面确认**:scope_files 9 项无需扩展（S2 需改 attest-plan.sh 已在列;S3 需改 check-delegation.sh **不在列→scope 修订补入**）

### scope 修订（Phase 2）
- 源码行加 skills/task-planner/scripts/check-delegation.sh（S3b observe 节流+tr 规范对齐）;禁止行相应移除该项

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

#### [sub:02-executor] S1 产出
- check-scope.sh §③ 豁免表上方新增 `case "$abs_path" in "$HOME/.zcode/cli/memories/"*) exit 0 ;; esac`（E1 memory 前缀豁免,仅该前缀,其他拦截不变）
- plan-created.cjs 无 sid else 分支改为兜底清除:枚举 .plan_required_side/*,仅当 .active_plan_side/<sidkey>.active_plan 不存在或 mtime>24h 时删（KQ1 双条件）;保留/清除/无残留三条路径均补日志;成功文案加诚实化注释
- 验收 6/6:语法双过 + 负例A 保留(护栏) + 正例B/C 清除 + check-scope memory exit 0 / 非白名单 exit 1 / 无哨兵 exit 0 不变 + git diff 恰 2 文件(+44/-1)

#### [sub:03-executor] S2 产出
- attest-plan.sh:68 锁定写入追加 `attested_by_sid=${ZCODE_SESSION_ID:-${CLAUDE_SESSION_ID:-}}` 字段（sid 获取链,无 sid 空串;verify 仅读 plan_sha256,向后兼容）
- zcode-posttooluse.sh 计划探测段后（L46-70）挂 TAMPERED 自愈分支: tool∈{Write,Edit,MultiEdit} + .tool_input.file_path 归一==活跃计划 task_plan.md + .session-owner==SID(非 default) → 后台 `env ZCODE_SESSION_ID=$SID attest-plan.sh <plan> --skip-dispatch-check`（静默,失败仅一行 stderr,`&` 不阻塞）
- 实测注意: 正例验证中 resolve-plan-dir.sh 需 .active_plan_side/<sid>.active_plan 指针（测试环境经 attest 流程隐式建立）;`plan_dir` 变量提前定义于 case 前,消除旧 L119 首用错位
- 验收 5/5: bash -n 双过 + 正例(attested_by_sid=SIDA,mtime 刷新,SHA 自洽) + owner 不匹配/无关文件/owner 缺失三负例 attestation 均不变 + git diff 本 S-unit 恰 2 文件

#### [sub:04-executor] S3 产出
- zcode-userpromptsubmit.sh: UPS_SID env 兜底链 (stdin→CLAUDE_CODE_SESSION_ID→ZCODE_SESSION_ID→default, 对齐 resolve-plan-dir.sh:31 风格, L24-32); owner/UPS_SID 的 tr 统一 'a-zA-Z0-9_-' (L32/L106)
- check-delegation.sh: NO_OWNER/EMPTY_OWNER 分支 observe 注入会话级节流 (/tmp/task-planner-observe-${sid_norm}.flag, 首注后静默, L258-268)
- 实测: E3 正例 env-only sid 写 owner 成功 (sessTEST123/zcodeSID456); observe 连跑两次 run1 注入/run2 静默; tr -cd 全部 sid 点已含 _-; 改动仅上述 2 文件, 未 commit
- checkpoint: subagent-state/04-executor-s3.md

#### [sub:05-executor] S4 产出
- SKILL.md: 409-411 行插入「### 🛡️ 环境级中断自愈(task-v068)」条款（5 项机制+键名+sid 护栏+E4 deferred 口径, 净增 +3 行, 513→516≤523）
- config.json: properties 内 knowledge_brief_enforce 块后插同构键 hook_self_heal_enforce（+10 行, enum enforce/warn/off default warn, description 注明「off 档后续轮接读取,enforce 预留」+sid 护栏恒在）；python3 json.load 无异常
- scripts/selftest-execution-stability.sh: 新建（115 行, T1-T10 共 14 断言, 风格照 selftest-knowledge-brief.sh: BASH_SOURCE 相对路径/t() 计数器/PASS/FAIL/Total/exit; T7 python3 缺失降级 grep 双路径）— 自跑 14/14 PASS exit 0
- 回归抽测: selftest-knowledge-brief 16/16 + selftest-dispatch 18/18 全 PASS; T10 哨兵 knowledge-brief.md 五段=5 且 init-session.sh "6/6"≥1
- 本次 git diff 恰 3 文件（SKILL.md +3 / config.json +10 / 新脚本）; hook 脚本 6 个 M 文件为 S1-S3 遗留未 commit, 本 S-unit 未触碰; 未 commit
- checkpoint: subagent-state/05-executor-s4.md

#### [sub:06-executor] S5a 产出
- P0-1 `zcode-posttooluse.sh:57-69`：`*/*` case 分支新增纯文件名 CWD 直拼 + `plans/*/` glob 兜底；owner==SID 护栏与零子进程短路保留；验收 ②③（相对路径重锁正/负例）PASS。
- P0-2 `zcode-userpromptsubmit.sh:34/110`：UPS_SID 与 owner 读侧 `tr -cd 'a-zA-Z0-9_-'` → `'a-zA-Z0-9'`，补 P2-3 `[ -z "$UPS_SID" ] && UPS_SID="default"`；验收 ④（pretooluse:30 vs userpromptsubmit:34 canon 逐字节一致，`sess-abc123 → sessabc123`）与 ⑤（env-only sid E3 回归）PASS。
- **残余风险（待 orchestrator 判定）**：`check-delegation.sh:96/255` 仍保留 `a-zA-Z0-9_-` canon，与本修复后 hook 侧 `a-zA-Z0-9` 形成**反向失配**（含 `-` 真实 sid 下 check-delegation 侧保留 `-`，本侧剥离）——CR scope 未授权修改，建议 Fix-B 扩 scope 修该文件 L96/L255/L84 注释。
- `git diff --stat`：2 files changed, +21/-4，恰为授权 2 文件；无越权改动。

#### [sub:07-executor] S5b 产出
- P1-2 `zcode-posttooluse.sh:81-84`：attest 后台 `&` → 同步执行；`env ZCODE_SESSION_ID="$SID"` → `env ZCODE_SESSION_ID="${ZCODE_SESSION_ID:-$SID}"`（外层已有值时尊重外层,防静默覆盖污染 attested_by_sid 审计）
- P2-1 `plan-created.cjs:192-207`：兜底清除循环内 `fs.existsSync(ptr)` 三处调用 → 循环开头缓存 `const ptrExists = fs.existsSync(ptr)` 两处共用；unlink 后日志按缓存值输出真实原因（防并发误打「无活跃指针认领」）
- canon `check-delegation.sh:96/255`：`tr -cd 'a-zA-Z0-9_-'` → `tr -cd 'a-zA-Z0-9'`（与全仓剥除 canon 一致；owner 内容现由 UPS 剥除写入,读取侧统一剥除消反向失配）；:186 timestamp `tr -cd '0-9'` 未动
- 验收 6/6 逐项：
  ① `bash -n zcode-posttooluse.sh` PASS / `bash -n check-delegation.sh` PASS / `node --check plan-created.cjs` PASS
  ② P1-2 行为复验（临时目录 /tmp/e2fixb.*/plans/task-x）：相对路径 stdin 正例重锁成功,attestation `attested_by_sid=sesssessabc123`（Outer 未设→回落 SID）；Outer=`ZCODE_SESSION_ID=OUTERSID` 时 `attested_by_sid=OUTERSID`；无孤儿 attest 进程（同步执行确认）
  ③ P2-1 逻辑核对：缓存前 L192/L198/L204 三处 `fs.existsSync(ptr)` → 缓存后 L194 `const ptrExists` 唯一调用点,L197/L202 两处共用；行为复验（env 全 unset,3 个 side 哨兵+对应 active_plan 指针）：sess1（指针 mtime>24h）→「指针 mtime>24h 过期」,sess3（无指针）→「无活跃指针认领」,sess2（指针存在且<24h）→「⚠ 保留侧哨兵（活跃指针存在且 <24h,保留）」,文件保留
  ④ `grep -n "tr -cd" check-delegation.sh` 全 3 点:L96 `a-zA-Z0-9`（owner 读）,L186 `0-9`（timestamp,未动）,L255 `a-zA-Z0-9`（sid_norm）
  ⑤ 跨脚本 canon 复测：`sid=sess-abc123` 经 `pretooluse:17/30/63`（`tr -cd 'a-zA-Z0-9' | head -c 40`）/`UPS:34`（同）/`check-delegation:255`（同）→ 三侧输出均 `sessabc123`,逐字节一致
  ⑥ `git diff --stat` 恰 3 文件：`zcode-posttooluse.sh` / `plan-created.cjs` / `check-delegation.sh`（`zcode-userpromptsubmit.sh` 为 S5a 遗留 M 状态,非本 S-unit 改动）
- Scope 合规：仅改 3 文件,未触碰 selftest/SKILL/config/check-scope/UPS/attest-plan.sh；无 commit
- checkpoint: subagent-state/07-executor-fix-b.md

#### [sub:08-executor] Fix-C 产出
- P2-2 落地: selftest-execution-stability.sh 追加 T11a/T11b(B1 行为级, 真实 bash 子进程跑 attest-plan.sh + zcode-posttooluse.sh) + T12(B2 三侧 canon 一致, 复刻 pretooluse L17/UPS L34/jq 全链路管道), Total 14→17 全 PASS exit 0。
- B1 负例双条件口径: owner=othersid999 → 哈希不更新(旧值)**且** attested_by_sid 保持基线空串(非 sessabc123, 防洗白); 破坏性自检 harness 独立复现 NEG-OK。
- B2 采用行为式(管道输出对比)而非 grep 源码, 因 tr 字符集若被分侧改动, grep 断言仍全绿正是 P2-2 要防的盲点; FAIL 时自带 [B2-diag] 三侧实际值。
- evidence: T11a 实测 attested_by_sid=sessabc123 + plan_sha256==sha256sum(task_plan.md) 新值; T11b stored==旧 h1 且 bysid 空。
- checkpoint: plans/task-v068-execution-stability/subagent-state/08-executor-fix-c.md

#### [sub:09-executor] Fix-D 产出
- 修复点: `selftest-delegation.sh:440-441`(T20 断言前,`cd "$TMP_T20"` 之后)新增 2 行:注释 `# [2026-09-13 task-v068 Fix-D] observe 节流 flag 自洁,防脏环境偶发 FAIL` + `rm -f "/tmp/task-planner-observe-anysid.flag"`(sid `any-sid` 经 canon 剥除 = `anysid`,与 check-delegation.sh:263 observe flag 路径逐字节一致)。
- 根因: task-v068 observe 节流(check-delegation.sh:261-267)首次触发后 touch `/tmp/task-planner-observe-${sid_norm}.flag`,后续同 sid 静默;selftest T20 用固定 sid `any-sid` 断言 observe 输出(delegation-observe|additionalContext),残留 flag 导致 T20b grep FAIL(脏环境 37/38 实测复现)。
- 验收: ① `bash -n` PASS ② 干净环境 38/38 ③ 脏环境(`touch` flag 后)38/38(flag 被 T20 前置清理+check 重新 touch,测试跑完 rm 残留) ④ `git diff --stat` 恰 1 文件 +2 ⑤ 无 commit。
- checkpoint: plans/task-v068-execution-stability/subagent-state/09-executor-fix-d.md
