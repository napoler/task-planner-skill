# Verification Contract & Phase Gates

## Goal (1 sentence)

把「总是用通用 Agent」的三类缺口收口为机制：覆盖矩阵落仓（agent-coverage.md）+ Rule 52 执行体专业化优先（52.1-52.4）+ 三登记面修复（SKILL 六族行+mapping B 修正+router 族行）+ selftest-agent-coverage 守护，全量 0 FAIL 后合并回 + 部署（用户诉求：拆分子代理时使用更对应的专业代理）。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: 矩阵落仓完整（类型族表+三类缺口表+C 类 41 行纳入/豁免+零专用体领域段）
  Evidence: references/agent-coverage.md（128 行；四段 :9/:42/:63/:113；C=41 全含纳入\|豁免；B 5 条去向）；S9 对账通过
- [x] VC-2: 登记面修复（B 类零残留；SKILL 六族行在位）
  Evidence: ComplexProblemSolver/article-batch-publish(无 er) 字面零残留（S9 grep）；六族行 SKILL:364-369 + mapping :266/:268/:278 三处在位
- [x] VC-3: Rule 52 四子条 + bullet + references；零新键
  Evidence: `^52\.`=4（critical-rules 文末 +12）；SKILL:290 bullet/:314 refs；properties=40
- [x] VC-4: 守护与回归（agent-coverage 全绿；registry 动态一致；全量 0 FAIL）
  Evidence: agent-coverage 8/8 SKIPPED=0；registry 50=50；回归链 50/752（S7/主进程）→ fresh 50/752（S8）
- [x] VC-5: 部署与审查（merge+3 位 IDENTICAL+router 双位；CR+align 双 APPROVED）
  Evidence: merge c38a5fc；3 技能位 IDENTICAL；router 双位 151（六族行各 6）；CR APPROVED（CR 段）/alignment APPROVED（:133-160）

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom]
- [ ] V-1.2: [mapped to VC-? or custom]

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ...
- [ ] V-2.2: ...

Status: `pending` Last verified: —

---

### Phase 3: {Name}

...

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 覆盖审计/资产盘点（2-coverage/1-inventory） | 矩阵四段与 C 类 41 行逐项对照底稿（S1 转写+S9 对账） | 符合 |
| 三登记面锚 | SKILL 六族行/映射三修正/router 双位族行逐处 grep | 符合 |
| Rule 尾部范式（46/47/51） | Rule 52 块结构对照（标题+源起+四子条+机制） | 符合 |
| v128 编号账本 | rule-reserve 预留 52 + new_rule 声明 + attest 查重通过 | 符合 |
| selftest 范式 | agent-coverage 与 media-dispatch 同构（AC 编号/ok-bad/Total） | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"1 隔离与基线","executor":"主进程（白名单①）+ executor（基线）"},{"phase":"5 CR Gate + 合并回 + 部署 + 簿记","executor":"executor（CR Gate）+ 主进程（白名单①② + 仓外部署面=用户授权）"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Phase 1=①；Phase 5=①②+用户授权仓外面）
- [x] 委派率 0.6 < 0.7 → **WHITELIST-EXEMPT 放行**（verdict=ok violations=[]；曾因 Executor 串缺白名单括注现 violation，补括注后复跑恢复 ok——自修复留痕）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:① m8-executor.md 50 脚本原文（grep 复现）② S9 对账段（:133-160）③ 主仓终态 50/752 复跑
- [x] 豁免登记:无
- [x] 存在未处置违规 → 不适用（零违规）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — Rule 52 执行体专业化优先与覆盖矩阵
对照 Verification Contract 逐条复验：
- [x] VC-1 → PASS（agent-coverage 128 行；C=41；B 5 条）
- [x] VC-2 → PASS（B 零残留；六族行 :364-369；mapping 三处）
- [x] VC-3 → PASS（^52.=4；bullet/refs；properties=40）
- [x] VC-4 → PASS（8/8；50=50；50/752 双层复跑）
- [x] VC-5 → PASS（merge c38a5fc；3 位+router 双位；双 APPROVED）

outcome: COMPLETE
```

遗留（不阻断 COMPLETE）：
- P2×2（CR 报告）：agent-coverage 脚本 chmod +x 建议 / AC-04 豁免名单随动注记
- 行为级冒烟待新会话：真实任务规划期观察「选型查矩阵→专用体优先」实际生效（Rule 52 行为面）

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |

---

## Alignment Review（Phase 4 S9 — Rule 42.6.2，subagent executor/fresh，2026-10-04）

**结论：APPROVED**（P0=0 / P1=0 / P2=0；对齐基准=审计底稿 subagent-state/2-coverage.md A/B/C 三类 + findings §设计 1-4 + Rule 52 条款；审查面=矩阵 agent-coverage.md / Rule 52 / SKILL 六族行+三修正+双联动 / mapping 三处 B 修正 / selftest-agent-coverage.sh+registry / 两锚演进，worktree 提交 0494007+cd3c116）

### 逐检查项结论（关键原文证据）

1. **矩阵↔底稿转写一致性** — PASS：agent-coverage.md 四段锚 `grep -n '^## '` = `9:## 一… / 42:## 二… / 63:## 三… / 113:## 四…`；§一 26 行对应底稿 2-coverage §一（行 23/24 video 行标注「v124 承接」、行 25 image 由 v124 承接，与 1-inventory/审计 B* 口径一致）。
2. **B 类 5 条处置对账（零残留）** — PASS：`grep -rlP 'article-batch-publish(?!er)' SKILL+mapping+companion+templates` 零命中（exit 1）；`grep -rl 'ComplexProblemSolver'` 同面零命中；mapping :278 script-dev 行 grep `script-writer|script-auditor`=0（实测 `:278 | script-dev | … 兜底路由=executor(sonnet-1)+script-dev variant 模板 SOP`）。正面锚在位：`grep -c 'complex-problem-solver' SKILL.md`=2（:348/:358），mapping :266 `article-batch-publisher`、:268 `research-assistant（Skill 调用）/web-search-agent（agent）` 在位。旧字面仅存于矩阵 §二 B 表（agent-coverage.md:55-61，52.3 口径合法记录面，AC-03 扫描面已显式排除并注释自证理由）。
3. **C 类 41 行覆盖计数** — PASS：`awk '/^## 三、/,/^## 四、/' | grep -cE '^\| [0-9]+ \|'`=41；逐行缺「纳入|豁免」=0。六族行↔C 表实体对账：逐族 grep 六族行所含实体，六族 missing=[]（39 纳入行全在对应族行；#34 explore-fb / #35 web-search-opencode 两豁免行各附一行理由，与 router SKILL.md:7 豁免声明互证）。
4. **Rule 52 条款↔矩阵文件头↔SKILL bullet 互引一致性** — PASS：critical-rules.md `grep -c '^52\.'`=4（561/563/565/567）+ `### 52 ` 标题 :557；矩阵文件头维护责任声明（:3）与 52.3 口径逐字同源；SKILL :290 bullet 五要点（52.1-52.4+守护）与 :314 references 行尾「/ Rule 52 执行体专业化优先与覆盖矩阵维护」双联动在位。
5. **守护断言↔被守护对象级联** — PASS（实跑）：`bash selftest-agent-coverage.sh` → `Total: 8 PASS=8 FAIL=0 SKIPPED=0` rc=0（AC-04 候选 46 全在位、AC-05 C 表=41/缺处置列=0、AC-07 properties=40、AC-08 `^21.1b`=1/`^47.`=4）；`bash selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=50, actual selftest=50)` rc=0（registry 末行 domain=「Rule 52 执行体覆盖矩阵守护（task-v125）」，脚本实存 197 行）。
6. **两锚演进级联** — PASS：selftest-skill-split.sh:41 `T-主 行数 ≤461（…454→461…演进 440→…→461，先例 v112/v122/v126/v127）` 且 SKILL 实测 `wc -l`=461；selftest-requirement-coverage.sh:157 RC-15 `grep -c '^53\.'` 负断言=0（critical-rules `grep -c '^53\.'`=0，`^52.`=4 合法态，S5 演进语义未反转）。
7. **术语一致性/旧措辞零残留** — PASS：登记面（SKILL+mapping+companion+templates）内 B 类旧字面四类（无 er 形 publish / ComplexProblemSolver / script 裸名 / 无标注 research-assistant agent 用法）grep 全 0；唯一残留=矩阵文档记录面（第 2 项说明）。
8. **版本对齐/多副本** — PASS：`git log -1 cd3c116 --format=%cs`=2026-10-04 与条款/脚本头部 2026-10-04 声明一致；worktree `git status --short`=0 行（干净）；仓内无同实体多副本（router 仓外位归 Phase 5 主进程对账，S9 面外）。
9. **越界自检** — PASS：`git diff --name-only 2d65b5d..cd3c116`=8 文件，out-of-scope=0（7 scope_files + S5 预登记面 selftest-requirement-coverage.sh，该脚本在 task_plan FMEA/执行范围「脚本」类 S5 承接面内）；v124 媒体两行 SKILL :370/:371 未动、mapping :298 兜底条款原文未动（S4 留痕 numstat 3/3 复核）。

**负结果报告**：检查了上述 9 项（对齐技能清单 14 维中适用 9 维；i18n/schema/变更日志维度本任务不适用——无翻译副本/无 payload schema/CHANGELOG 面由 Phase 5 簿记承接）；未发现 P0/P1/P2 异常；排除风险：矩阵文档记录面旧字面被误扫（AC-03 扫描面设计已排除并注释）、C 类行数回退、六族行裁切、锚 461/`^53` 漂移。未验证项：skill-agent-router 仓外族行（VC-5，Phase 5 主进程对账面，非 S9 范围，显式登记）。

### 变更记录三要素（Rule 42.6.3）
- **变更范围**：plans/task-v125/verification.md（追加本段 alignment 审查）+ findings.md（追加 `[sub:S9]` 锚段）+ progress.md（Phase 4 Actions taken 追加 `[sub:S9]` 行）；审查对象 worktree 8 文件只读未改。
- **冲突处理结果**：发现的唯一「表观冲突」= 矩阵 §二 B 表记载 B4/B5 旧字面 vs AC-03「旧字面零残留」——裁决=非冲突（矩阵为 52.3 维护责任文档记录面，AC-03 脚本 :69-70 注释已声明排除该面；判定依据=断言脚本注释原文+实跑 AC-03 PASS），处置=保留原样+证据入本段第 2 项；无其他冲突点，无未决残留。
- **文档当前状态**：verification.md 本段=新增（无与既有占位模板冲突，VC 表/Goal Gate 段原样保留待主进程终验回填）；一致残留冲突=0。

## Code Review Gate 结论（Phase 5 S10 — Rule 42.2 ④ code-quality-review，subagent executor/fresh，2026-10-04）

**结论：APPROVED**（P0=0 / P1=0；P2=2 建议不阻断；审查面=3 个 .sh：selftest-agent-coverage.sh 新建 197 行 cd3c116 + selftest-skill-split.sh 锚演进 ±1 + selftest-requirement-coverage.sh RC-15 ±6；worktree /mnt/data/dev/task-planner-skill-worktrees/task-v125；git diff 2d65b5d..HEAD）

### 逐维度结论（code-quality-review 清单 14 维，关键原文证据）

1. **正确性与边界** — PASS：`bash selftest-agent-coverage.sh` 实跑 `AC-01..AC-08 全 PASS，Total: 8 PASS=8 FAIL=0 SKIPPED=0 rc=0`（AC-04 候选 46=token 提取-豁免 25，home 全在位；AC-05 C 表=41/缺处置列 0；AC-06 `^52.`=4/`^### 52 `=1；AC-07 properties=40；AC-08 `^21.1b`=1/`^47.`=4）；`bash selftest-skill-split.sh` `Total: 41 PASS=41 FAIL=0`（T-主 行数 ≤461，SKILL 实测 `wc -l`=461）；`bash selftest-requirement-coverage.sh` `Total: 15 PASS=15 FAIL=0`（RC-15 `grep -c '^53\.'`=0 负断言语义未反转：critical-rules `^52.`=4 合法态）。边界分支逐条核对：AC-01 矩阵空/缺失→bad 01；AC-04 目录缺位→skip（fail-open，52.2 口径，selftest-agent-coverage.sh:133-134）；AC-07 jq 缺失→skip 07（:177-182，MA-10 先例一致）。
2. **错误处理** — PASS：grep 失败均 `|| true` 兜底后显式计数比对（:37-39/:55/:71-74），非静默吞错——FAIL 路径全部经 bad() 显式打印（:29/:43/:46/:61/:78/:145/:158/:170/:193）；两处 `2>/dev/null`（:89 awk、:178 jq）仅屏蔽 stderr 噪音，结果均经显式 FAIL/SKIP 分支暴露，无 except:pass 类静默降级。
3. **命名与可读性** — PASS：抽 3 符号 ok/bad/skip（:28-30，语义与调用一致）、EXEMPT_TOKENS（:104-128，25 项逐条带依据注释 :91-103）、HOMEOC/HOMEMISS（:136-140）；魔数 41（AC-05 :155）/40（AC-07 :179）/46-25 均入注释 What/Why 说明；最长逻辑块 AC-04 17 行（:133-147），无超 50 行函数体。
4. **重复与死代码** — PASS：AC 断言均为仓内唯一（registry.tsv:51 已登记 domain「Rule 52 执行体覆盖矩阵守护（task-v125）」；51 个 selftest-* 脚本名不冲突）；`grep -n 'skip()' selftest-agent-coverage.sh` 命中调用 :134/:181，无 unused 函数/变量；无不可达分支（AC-04 目录缺位 else 分支与 jq 分支互斥完整）。
5. **注释与 docstring** — PASS：新脚本头部 12 行 What/Why/输入/输出/依赖（:2-12）；每 AC 块双层注释（What+Why）；两锚演进 diff 均含「原因+先例+日期 2026-10-04」变更注（skill-split :41 label、RC-15 `[task-v125 S5 演进重锚]` 行）；无 TODO 占位。
6. **输入校验** — PASS：AC-01 前置 `[ -s "$MATRIX" ]` 空/缺失校验（:36）；AC-04 前置 `[ ! -d "$AGENTS_DIR" ]`（:133）；变量全 `set -u`（:14）；无 dict.get/x or default 类缺掩。
7. **并发与资源** — PASS：temp 文件 `/tmp/.ac04.toks.$$` 以 PID 后缀隔离（:90/:129）且 :132 `rm -f` 成对释放；无循环内建连接、无未设上限后台任务。
8. **依赖与版本** — PASS：仅 bash+grep+awk+jq（缺失走 SKIPPED），无新 import/依赖漂移，与仓内 selftest 系先例（media-agents :9/:11）同口径。
9. **风格一致性** — PASS：SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、`exit $((FAIL > 0))` 与 selftest-media-agents.sh（:28-29/:150）全同构（脚本头 :3 自声明）；skill-split ±1 / RC-15 ±6 diff 均保持原文件既有 `t "…" bash -c "…"` / `ok N "…"` 行内风格。
10. **测试配套** — PASS：守护脚本自身即配套断言，实跑 8/8+41/41+15/15 全绿 0 回归；registry `Total: 5 PASS=5 (registry rows=50, actual selftest=50)`。
11. **越界自检** — PASS：`git diff --name-only 2d65b5d..HEAD`=8 文件（agent-coverage.md/critical-rules.md/SKILL.md/template-mapping.md/selftest-agent-coverage.sh/selftest-registry.tsv/selftest-requirement-coverage.sh/selftest-skill-split.sh），对照 task_plan scope_files 7 项+S5 预登记面 selftest-requirement-coverage.sh（plan 「脚本」类执行范围），out-of-scope=0；v124 媒体两行未动。
12. **幂等与副作用** — PASS：连跑两次 agent-coverage 输出逐行一致（IDEMPOTENT-OK）；纯只读+`/tmp` 一次性 temp（PID 隔离、自清理），无 rm -rf/git reset --hard 类不可逆操作。
13. **复杂度与分层** — PASS：最深嵌套 AC-04 while 内 if=3 层（:137-139），未超限；无跨层直连。
14. **常量与配置** — PASS：EXEMPT_TOKENS 集中常量区（:104-128）+逐条依据注释；断言口径 41/40/4/46 各仅 1 处散落，无同义魔数 3 处以上。

**P2 建议（不阻断）**
- `[P2] selftest-agent-coverage.sh:1(mode 100644) — 新脚本未置可执行位（仓内 51 个 selftest-* 中 49 个 755；S7/S8 回归循环均以 `bash script` 调用不受影响）— 建议 merge 前 `chmod +x`，与仓内脚本面一致`
- `[P2] selftest-agent-coverage.sh:89-90(AC-04) — `grep -oE '[a-z][a-z0-9]+(-[a-z0-9]+)*'` 对中文表内 ASCII 子串（fresh/web-search/it/xecutor 等）碎切产物依赖 25 项豁免名单压制 — 已注释留痕（:100-103），名单随矩阵演化需人工随动；可后续加 awk 按空格边界取词收窄候选面`

**负结果报告**：检查了上述 14 维（10 维主审 + 4 维辅审）；未发现 P0/P1 异常；排除风险：AC-04 候选面漂移（双缺位 0）、C 表行数回退（=41 锁定）、`^53.` 负断言语义反转（=0 且 `^52.`=4 合法态互证）、越界写入（8 文件全在 scope 面）、幂等破坏（两次连跑一致）。未验证项：仓外 skill-agent-router 族行（VC-5，Phase 5 主进程对账面，非 S10 面）；shellcheck 未安装，语法面以 `bash -n` ×3 全过替代（SYNTAX-OK）。

### 变更记录三要素（Rule 42.6.3，S10）
- **变更范围**：plans/task-v125/verification.md（追加本段 CR Gate 结论）+ findings.md（追加 `[sub:S10]` 锚段）+ progress.md（Phase 5 段 Actions taken 追加 `[sub:S10]` 行）；审查对象 worktree 3 .sh 只读未改（`git status --short`=0 行）。
- **冲突处理结果**：0 冲突（P2 两条为改进建议非缺陷，无未决残留）。
- **文档当前状态**：verification.md 本段=新增；既有占位模板（VC 表/Goal Gate）原样保留待主进程终验回填。

**终局二值结论：APPROVED（P0=0 / P1=0 / P2=2，P2 不阻断，建议 merge 后执行）**
