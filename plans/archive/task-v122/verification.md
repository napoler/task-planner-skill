# Verification Contract & Phase Gates

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: Rule 47 条款完整（`### 47 ` + 47.1-47.4 四子条，范式对齐 44/46；既有规则零语义改动）
  Evidence: 主仓合并后复验 `grep -c '^47\.'`=4 / `^### 47 `=1（critical-rules.md:484-494）；三提交 diff 仅增量（4bdfa4a +17/−1、16d7df8 +97/−1、d186384 +2/−2）
- [x] VC-2: 零新 config 键（properties 计数=基线 40）
  Evidence: `jq '.properties|length'`=40（Phase 1 基线 / m7 / m9 三处实测一致）
- [x] VC-3: SKILL.md 联动在位（路由表媒体行 ≥2 + 摘要 bullet + references 行含 Rule 47；净增 ≤10 且 ≤558）
  Evidence: SKILL.md:356/:357（媒体生成工序/剧集创作管线）、:282（Rule 47 bullet）、:306（references 行）；wc -l=447（净增 3）
- [x] VC-4: template-mapping.md 联动在位（§九兜底注 + §十媒体族行；既有 30 行矩阵零改动）
  Evidence: template-mapping.md:298/:308；`git diff --numstat`=2 增 0 删
- [x] VC-5: 守护与回归+部署（新 selftest 全绿；全量 0 FAIL；3 位部署 IDENTICAL）
  Evidence: selftest-media-dispatch.sh 9/9；m7 fresh 44/44 rc=0 FAIL=0（逐行求和 685 用例，verification.md:138-142）；smart-merge-back --deploy 输出 3 位 IDENTICAL（merge bf9bb97）；主仓复跑 media-dispatch 9/9

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
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"1 隔离与基线","executor":"主进程（白名单① git/worktree 编排）+ executor（原派 code-runner-agent 被 provider 拒 → Rule 22.3① 改派，Handoff #10 rescue 登记）","reason":"白名单① git/worktree 编排）","needs_git_evidence":0,"self_declared":0},{"phase":"5 合并回 + 部署 + 簿记","executor":"主进程（例外理由:① git 编排 + ② 计划系统簿记——Rule 25.3 白名单）","reason":"例外理由:① git 编排 + ② 计划系统簿记——Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）：Phase 1=①git/worktree 编排（其内自跑基线已实际改派 executor，Handoff #10）+ Phase 5=①②（合并部署+簿记）
- [x] 委派率 0.6 < 0.7 → **WHITELIST-EXEMPT 放行**（直做理由全部命中白名单①②，stats verdict=ok、violations=[]；先例 task-v119 同构）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（两处回归级联=锚级联断裂，按计划 FMEA 预登记「锚过窄→宽容化」分支处置并全程留痕，不属 Q1-Q6 降质行为）
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 3 条——① m7 日志 subagent-state/m7-executor.log（44 脚本 rc/Total 原文，grep 复现）② verification.md:131-142 m6/m7 结论段（与日志逐行对照）③ 主仓 `grep -c '^47\.'`=4 + media-dispatch 9/9 复跑（合并后独立复现）
- [x] 豁免登记:无（无需豁免项）
- [x] 存在未处置违规 → 不适用（零违规）

## 知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| Rule 44/45/46 尾部范式 | Rule 47 块结构对照（标题+源起段+四子条+机制条） | 符合 |
| §九矩阵+§十工具映射 | mapping 两处落点（:298/:308）语义未改既有矩阵 | 符合 |
| SKILL.md 路由表/摘要区 | 三落点（:282/:306/:356-357）行位与格式对齐既有行 | 符合 |
| selftest 零新键范式 | media-dispatch MD-08 与 reliability-institution R-12 同构 | 符合 |
| 部署机制 | smart-merge-back --deploy 3 位 IDENTICAL 对账通过 | 符合 |

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 落地 Rule 47 媒体制作任务派发纪律（47.1 媒体拆分轴+47.2 具名执行体路由禁 general-purpose 默认兜底+47.3 批量试点先行+47.4 零新键机制），联动 SKILL.md 路由表媒体行与 template-mapping.md §九兜底注/§十媒体族行，新建 selftest-media-dispatch.sh 守护，全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位
对照 Verification Contract 逐条复验：
- [x] VC-1 → PASS（critical-rules.md:484-494，grep=4；主仓复验）
- [x] VC-2 → PASS（properties=40 三处实测）
- [x] VC-3 → PASS（:282/:306/:356-357；447≤558）
- [x] VC-4 → PASS（:298/:308；纯增量）
- [x] VC-5 → PASS（m7 fresh 44/44 FAIL=0；3 位 IDENTICAL；主仓复跑 9/9）

outcome: COMPLETE
```

遗留（不阻断 COMPLETE）：
- P2×3（均非阻断）：① SKILL.md:306 前段「Critical Rules 1-39」存量旧文案（本次未改，建议后续轮刷 1-47）② selftest-media-dispatch.sh 权限位与套内混合不统一（运行链一律 `bash <path>`，建议后续轮统一）③ SKILL.md 正文称调用 `Skill("code-review")` 而实际池成员/部署技能实名为 `code-quality-review`（命名漂移，本次已按实名实调并登记）
- Error Log 两级联预防条款（锚扫描全列不截断；锚演进先跨脚本 grep 旧 label）待沉淀 memory（Phase 5 收尾执行）

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

## VC-5 复核证据（[sub:executor-m6] fresh 独立全量复跑，2026-10-03）
- 执行：cwd=/mnt/data/dev/task-planner-skill-worktrees/task-v122，单条 for 循环全量 fresh 运行 44 个 selftest-*.sh（含已修复 skill-split），总耗时 222s，零超时跳过；逐脚本原文行（== 名 / Total: 行 / rc= 行）全量留痕 subagent-state/m6-executor.log（40110B），无引用/转抄 m5 日志。
- 机器计数（源自本会话 fresh 日志）：== 块=44 / rc= 行=44 / 终态行=44（43×`Total:` + final-gate-hash×`结果:`）；FAIL 总和=1；逐 Total 求和 PASS=684 / FAIL=1（44 脚本用例总和 685）；registry `Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)` rc=0。
- **VC-5「全量回归 0 FAIL」当前=未达成**：唯一 FAIL=selftest-self-resolution.sh `Total: 13 PASS=12 FAIL=1`（rc=1），明细行原文 `SR-11 FAIL selftest-skill-split.sh 级联锚缺失（task-v099|task-v1x / -le 4 前缀断言行）`。
- 根因（只读定位，m6 未改仓库/技能文件）：selftest-self-resolution.sh:88 SR-11 宽容正则 `task-v099|task-v1[0-1][0-9]` 于 skill-split 零命中——skill-split 内 task-v 标签现为 v095×2/v097×1/v122×1；m5b 锚演进（444→447，label=task-v122）把 label 推进到 task-v122，超出正则覆盖域（v100-v119）→ 同族「锚过窄→宽容化」级联断裂（v071→v074/v112/v121 先例，task_plan FMEA 预登记分支），与 S5 已修复的 ≤444 行数断言为不同断言，非修复回退。`-le 4` 行在位（skill-split:41 `-le 447`/`-le 558`）。处置待主进程裁决（扩正则至 task-v12x 或等价）后重跑 self-resolution 确认 0 FAIL。
- 其余 43 脚本终态行 FAIL=0 全绿（含 media-dispatch 9/9、skill-split 41/41、final-gate-hash 结果 PASS=22 FAIL=0）。
- 备注：派发契约要求 progress.md 仅 Phase 4 段追加，但 progress.md 现有 Phase 段仅 1/2/3（task_plan Current Phase=4 尚未建段）→ 本 S-unit progress 行未写入（契约禁改范围外），留主进程建 Phase 4 段时补；全部产出见本段 + subagent-state/m6-executor.md + m6-executor.log。
## VC-5 复核证据（[sub:executor-m7] 修复后 fresh 独立全量复跑，2026-10-03）
- 执行：cwd=/mnt/data/dev/task-planner-skill-worktrees/task-v122，单条 for 循环全量 fresh 运行 44 个 selftest-*.sh，零超时跳过；逐脚本原文行（== 名 / Total: 行 / rc= 行）全量留痕 subagent-state/m7-executor.log（836 行）+ m7-executor.md，未引用/转抄 m5/m6 日志。
- 机器计数（源自本会话 fresh 日志）：== 块=44 / rc=0 行=44（无非零 rc）；终态行=44（43×`Total: N PASS=N FAIL=0` + final-gate-hash×`结果: PASS=22 FAIL=0`）；全日志 `FAIL=[非0]` grep 计数=0。
- **VC-5「全量回归 0 FAIL」当前=达成**：m6 唯一 FAIL（self-resolution SR-11 级联锚，正则域 v1[0-1]x 未覆盖 task-v122）经主进程修复（正则域扩至 v1[0-2]x + skill-split 行数锚 444→447）后，本轮独立复跑 selftest-self-resolution.sh `Total: 13 PASS=13 FAIL=0` rc=0，selftest-skill-split.sh `Total: 41 PASS=41 FAIL=0` rc=0，44/44 脚本全绿。
- 备注：纯只读运行，未改任何仓库/技能文件；无 FAIL 明细（FAIL=0）；progress.md 按契约仅在 Phase 4 段追加摘要行。
## 对齐审查结论（[sub:executor-m8] alignment-review，Rule 42.6.2/42.6.3，2026-10-03）

**APPROVED**（alignment-review 清单全过，P0/P1=0；P2×1 不阻断）

审查对象=4 个 scope 产出（worktree 提交 4bdfa4a/16d7df8/d186384）：critical-rules.md Rule 47 块（:484-494）、SKILL.md 三处联动（:282/:306/:356-357）、template-mapping.md 两处（:298/:308）、selftest-media-dispatch.sh（新建 126 行）+ selftest-skill-split.sh:41 锚演进 + selftest-self-resolution.sh:87-88 正则扩域 + registry.tsv 末行。

逐项结论（关键原文行）：
- 文档↔代码同步：PASS — critical-rules 47.1-47.4 子条（:488/490/492/494）↔ SKILL 摘要 bullet 四段对应（:282「47.1…（47.1）；…（47.2）；…（47.3）；…（47.4）」逐子条锚齐）↔ selftest 断言锚逐一对位（MD-01 `^47\.`/MD-02 `^### 47 `/MD-03 媒体生成工序/MD-04 剧集创作管线/MD-05 摘要 bullet/MD-06 mapping「Rule 47.2」/MD-07「媒体制作族」），措辞与语义零漂移。
- 计数与枚举联动：PASS — `grep -c '^47\.'`=4、`^### 47 `=1（critical-rules.md:484-494）；SKILL.md 媒体行=2（:356/:357）≥VC-3 要求；mapping「Rule 47.2」=2（:298/:308）、「媒体制作族」=1（:308）；registry 行「Rule 47 媒体制作派发纪律守护…critical-rules.md ^47 锚」在位（末行）。
- 引用完整性：PASS — Rule 47 引 21.1b（:141 在位）/37.4/18.9-18.11/21.4/36.5/43.4/44.4 全部真实存在；selftest TMAP 定位法 `$SKILL_ROOT/../plan-template-kit/references/template-mapping.md`（selftest-media-dispatch.sh:19）与文件实际路径一致；SKILL:306 references 行「Rule 47 媒体制作任务派发纪律」与 critical-rules:484 标题逐字一致。
- 术语一致性：PASS — 「媒体制作任务派发纪律」四面（critical-rules 标题/SKILL bullet+references/selftest 头注+registry 描述）同一措辞；「媒体制作族」仅 mapping:308 行名；无新旧混用。
- 守卫锚与被守护对象级联：PASS — skill-split:41 T-主锚 `≤447（task-v122 Rule 47 联动 +3;演进 440→442→444→447）且 ≤558 上限` 与 SKILL.md 实际 447 行一致（wc -l=447，≤558 不越）；self-resolution:88 SR-11 正则 `task-v099|task-v1[0-2][0-9]` 覆盖 skill-split label task-v122（grep -cE 命中）；fresh 复跑 media-dispatch `Total: 9 PASS=9 FAIL=0` rc=0，self-resolution 13/13、skill-split 41/41（m7 全量日志佐证 44/44 rc=0 FAIL=0）。
- 变更日志与实际变更同步：PASS — 三提交 numstat 实测：4bdfa4a=3 文件 +17/−1（critical-rules +11/0 纯增量、SKILL +4/−1、mapping +2/0）、16d7df8=3 文件 +97/−1（新脚本 95 行+registry +1+skill-split ±1）、d186384=1 文件 +2/−2，与 progress.md / findings 回执 / 计划 Drift Log 声称逐条对上，无「声称有但没改」「改了没声称」。
- 越界自检：PASS — git 三提交文件集 ⊆ 计划 scope_files + 两级联修复文件（selftest-skill-split/selftest-self-resolution，均属 FMEA 预登记「锚过窄→宽容化」分支，m5b/m6b 已登记）；未触碰 config.json（properties=40 实测不变，VC-2 口径）；主仓零改动。
- 双向一致性（用户诉求↔VC↔改动）：PASS — findings Requirements 原话（拆分粗+默认代理）↔ Rule 47.1 媒体轴/47.2 具名路由 直接闭合；VC-1..VC-5 各判定标准均被实测证据覆盖（VC-1 grep=4 / VC-2 键数 40 / VC-3 行 2+bullet+references、447≤558 / VC-4 2 锚+纯增量 / VC-5 m7 44/44 FAIL=0）。
- P2（不阻断）×1：SKILL.md:306 references 行前段「Critical Rules 1-39」为既有旧文案（本次未改，行尾已追加 Rule 47 名即达意图，语义不互斥）；后续维护轮可顺带刷新为 1-47 口径。

### 变更记录（Rule 42.6.3 三要素）
| 变更范围 | 冲突处理结果 | 文档当前状态 |
|---|---|---|
| task-v122 全部产出：critical-rules.md（+11，Rule 47 块 :484-494）、SKILL.md（净+3，:282/:306/:356-357）、template-mapping.md（+2，:298/:308）、selftest-media-dispatch.sh（新建，registry 登记）、selftest-skill-split.sh:41（444→447 锚演进）、selftest-self-resolution.sh:87-88（SR-11 正则扩域）；对齐审查仅追加 verification.md 本段，零仓库文件修改 | 无前后版本冲突/重复段落/编号漂移/失效引用（写入前五维扫描 0 命中）；两处既有锚级联断裂（skill-split ≤444、SR-11 正则域）按 FMEA 预登记「宽容化」先例处置，裁决依据=m5/m6 fresh 回归定位+m5b/m6b 单行/单正则最小修复（断言语义不变）；未决残留冲突=无 | 四面（critical-rules/SKILL/mapping/selftest）Rule 47 编号与名称引用全一致，P0/P1=0；对齐审查结论=APPROVED；唯一未决项=P2×1（SKILL:306「1-39」旧文案，不阻断，建议后续轮刷新） |

## Code Review Gate 结论（[sub:executor-m9] code-quality-review 隔离审查，3 个 .sh 重 diff 全量，2026-10-03）

**APPROVED**（code-quality-review 14 维清单全过，P0/P1=0；P2×2 不阻断）

审查对象（worktree 基准 b07c0cb，`git diff b07c0cb..HEAD -- <3 文件>` 全量）：
- skills/task-planner/scripts/selftest-media-dispatch.sh（新建，+95/0，commit 16d7df8；HEAD 实文件 wc -l=95，派发契约"126 行"为口径偏差，以实文件为准）
- skills/task-planner/scripts/selftest-skill-split.sh:41（单行锚演进 444→447 ±1，commit 16d7df8）
- skills/task-planner/scripts/selftest-self-resolution.sh:87-88（SR-11 正则扩域 `task-v1[0-1][0-9]`→`task-v1[0-2][0-9]` +2/−2，commit d186384）

逐维结论（14 维，关键原文行）：
- 正确性与边界：PASS — `bash -n` ×3 syntax OK；本会话 fresh 实跑全绿（media-dispatch `Total: 9 PASS=9 FAIL=0` rc=0、skill-split `Total: 41  PASS=41  FAIL=0` rc=0、self-resolution `SR-11 PASS` + `Total: 13 PASS=13 FAIL=0` rc=0）；grep 失败路径均 `|| true` 接住（media-dispatch.sh:29/45/51/58/65/72/90-91）；TMAP 目标路径 `skills/plan-template-kit/references/template-mapping.md` 实测在位（test -f EXISTS）
- 错误处理：PASS — 无静默吞错；media-dispatch:80 `2>/dev/null || true` 仅护 jq，外层 `command -v jq` 判在位，缺失打 SKIPPED 提示行（:83，与 self-resolution:75-80 SR-09 先例同构）；每断言 FAIL 分支有 bad() 输出
- 命名与可读性：PASS — ok()/bad()/MD-NN 编号与 reliability-institution/self-resolution 先例同构；魔数均有注释（40 键=零新键口径 :75-77；4=47.1-47.4 四子条 :25-28）；全脚本 95 行平铺，函数体 ≤50 行
- 重复与死代码：PASS — 结构对齐 reliability-institution 先例，TMAP 定位法有先例（mechanism-profile/template-lifecycle 同款）；无不可达分支
- 注释与 docstring：PASS — media-dispatch 头注四要素 :2-10（用途/输入/输出/依赖）+每断言 What/Why 双层注释；self-resolution:87 留痕 4 段（v100/v102/v113/v122）；skill-split:41 label 含演进链 440→442→444→447
- 输入校验：PASS — 静态断言脚本无 CLI 参数入口；路径经 BASH_SOURCE 解析（:14-15）；缺文件走 FAIL 分支非静默
- 并发与资源：PASS — 无常驻文件/socket/线程/子进程；无后台任务；无循环内重复建连接
- 依赖与版本：PASS — 依赖 bash+grep（硬）+jq（可选 fail-open），jq 本会话实跑成功（config properties=40）；零新增外部依赖
- 风格一致性：PASS — 两处改动为单行/单正则最小修改，与邻近代码同构；新脚本 SCRIPT_DIR/SKILL_ROOT 定位、Total 行、`exit $((FAIL > 0))`（:95）与先例逐句对齐
- 测试配套：PASS — 新脚本本身即 Rule 47 守护资产（9 断言）；registry.tsv:45 登记行在位（4 列制表符，cat -A 确认）；m7 全量 44/44 FAIL=0 零回归
- 越界自检：PASS — 3 文件 ⊆ 契约 scope（media-dispatch=scope_files 明文；skill-split/self-resolution=FMEA 预登记两级联修复文件，m5b/m6b 已登记）；worktree `git status --short`=空；config.json 未动（properties=40，VC-2 口径）；主仓零改动
- 幂等与副作用：PASS — 三脚本纯只读（grep/wc/jq）；media-dispatch 本会话重跑结果一致（9/9 rc=0）；无不可逆命令
- 复杂度与分层：PASS — 断言体嵌套 ≤2 层；无跨层直连
- 常量与配置：PASS — "40 键"在 self-resolution:76 与 media-dispatch:81 同口径交叉核对无冲突；零新 config 键承诺被 MD-08/SR-09 双守护

P2（不阻断）×2：
- [P2] selftest-media-dispatch.sh 权限 -rwxrwxr-x 与套内混合权限（部分先例 -rw-rw-r--）不统一 — 运行链一律 `bash <path>` 调用，不影响执行；建议后续轮统一脚本位权限
- [P2] selftest-skill-split.sh:41 label 锚引用 task 代号（task-v122）而非 commit hash — 属 rule-enhancement 模板明文先例（v071→v074/v112 同款），维持即可

### 变更记录（Rule 42.6.3 三要素 — Code Review Gate）
| 变更范围 | 冲突处理结果 | 文档当前状态 |
|---|---|---|
| 本 Gate 仅追加 verification.md 本段 + findings.md m9 回执 + subagent-state/m9-executor.md 检查点，零仓库/技能文件修改、零 git 写操作 | 写入前扫描：verification.md 现有 3 个结论段（m6/m7/m8）与本段无编号/命名冲突；m9 段落锚 `#### [sub:executor-m9]` 在 findings.md Research Findings 段末唯一无重复；派发契约"126 行"与实文件 95 行口径偏差如实登记（m4 回执同款数字，非本 Gate 引入）；progress.md Phase 5 段尚不存在 → 契约"仅 Phase 5 段追加"无法执行，沿用 m6 先例留主进程补 | 代码审查结论=APPROVED（P0/P1=0，P2×2 不阻断）；三脚本 fresh 实跑 9/9+41/41+13/13 全 rc=0；Code Review Gate 放行 Phase 5 后续 smart-merge-back --deploy |
