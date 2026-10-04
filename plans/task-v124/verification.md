# Verification Contract & Phase Gates

## Goal (1 sentence)

新增 image/video-generation-executor 两个 companion 专业执行体（agnes 调用/工序门控/三检-QC/证据纪律完整 SOP）+ SKILL/mapping 行内联动（净增 0）+ 四文档同步 + selftest-media-agents 守护，部署双位（~/.zcode/agents + ~/.claude/agents + router 双位）并合并回 master（用户诉求：媒体任务专业化处理）。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: 两 agent 文件在位且格式规范（name/触发词/MUST BE USED/model 行 + 六节齐全）
  Evidence: companion/agents/{image,video}-generation-executor.md（67/68 行）；逐字 diff D1/D2 IDENTICAL（主进程 awk 复核）；frontmatter 清单校验 PASS 无 BLOCK（subagent-state/m10-executor.md）
- [x] VC-2: 联动在位（SKILL 两行+mapping 两处含两 agent 名；净增 0）
  Evidence: SKILL.md:356/:357、mapping:298/:308（grep 各=2）；fe31267 numstat 各 2/2（行内替换，当时 wc 447→447）；S9 六面一致对照
- [x] VC-3: 文档同步（README_zh/INSTALL_zh 计数=6；INSTALL.md 表格 3 行；install.sh 注释 6 名）
  Evidence: README_zh.md:114「6 个伴生」/ INSTALL_zh.md:305「6 个配套」/ skills/task-planner/INSTALL.md:140-142 / install.sh:179
- [x] VC-4: 守护与回归（新 selftest 全绿；registry 动态一致；全量 0 FAIL）
  Evidence: selftest-media-agents.sh 10/10（MA-01..10）；registry rows=actual（终态 49=49）；回归链 47/727 → 48/734（fresh）→ 主仓终态 49/PASS_SUM=744 全 0 FAIL
- [x] VC-5: 部署与审查（merge+双位部署+router；双审查 APPROVED；零新键）
  Evidence: merge 0a82262；3 技能位 IDENTICAL；~/.zcode 位两 agent IDENTICAL、~/.claude 位仅 model=sonnet adapt；router 双位「九」节 :103；alignment APPROVED（:120-147）+ CR APPROVED（:156-187）；properties=40

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
| companion agent 范式 4 文件 | 两新 agent frontmatter/正文结构对照（S10 校验 PASS） | 符合 |
| install-companion 链路 | 双目标分发实跑（2i/2u/42s、2i/3u/41s）+ claude 位 adapt 核对 | 符合 |
| agnes 调用面/工序门控 | agent 正文技能段与 Workflow 按 research-b 材料落盘（逐字 diff） | 符合 |
| v119 部署先例 | 双位 cp/适配同款；router 行登记同款（并补 claude 位欠账） | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"1 隔离与基线","executor":"主进程（白名单①）+ executor（基线运行）"},{"phase":"5 CR Gate + 合并回 + 部署双位 + 簿记","executor":"executor（CR Gate）+ 主进程（白名单①② + 仓外部署面=用户授权）"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Phase 1=①；Phase 5=①②+用户授权仓外面）
- [x] 委派率 0.6 < 0.7 → **WHITELIST-EXEMPT 放行**（stats violations=[] verdict=ok；先例 v119/v122 同构）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（三轮合流冲突=正常 git 并集解决，非降质）
- [x] Evidence 抽查 ≥3 条:① m8-fullrun.log（45 脚本原文，grep 复现）② S9 六面一致对照段（:124-136）③ 主仓终态全量 49/744 复跑（合并后独立复现）
- [x] 豁免登记:无
- [x] 存在未处置违规 → 不适用（零违规）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 媒体双专业执行体 + 联动 + 守护 + 双位部署合并回
对照 Verification Contract 逐条复验：
- [x] VC-1 → PASS（两 agent 67/68 行；D1/D2 IDENTICAL；S10 PASS）
- [x] VC-2 → PASS（SKILL:356/357、mapping:298/308；numstat 2/2 净增 0）
- [x] VC-3 → PASS（README:114/INSTALL_zh:305/INSTALL.md:140-142/install.sh:179）
- [x] VC-4 → PASS（10/10；registry 49=49；47/727→48/734→49/744 全 0 FAIL）
- [x] VC-5 → PASS（merge 0a82262；3 位+双位+router 双位；CR/align 双 APPROVED；零新键）

outcome: COMPLETE
```

遗留（不阻断 COMPLETE）：
- P2×2（CR 报告）：① 两新 agent tools 行为 JSON 数组风格与既有逗号风格不统一（功能等价）② selftest-media-agents 权限位/口径建议
- 行为级冒烟待新会话：真实媒体任务观察「executor 兜底 → 专业体命中」（agent 列表会话启动固化，本会话不可见新 agent；同 v119 遗留模式）

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## S9 对齐审查段（alignment-review, Rule 42.6.2）

结论: **APPROVED**（P0=0, P1=0, P2=0）— 审查范围: worktree @cc95adc 双提交 fe31267/cc95adc + 工作区（干净）全部 task-v124 产出。

### 各检查项结论（附关键原文行）

| 检查维度 | 结论 | 关键证据 |
|---|---|---|
| 双 agent 文件在位+格式（VC-1 面） | PASS | companion/agents/ 6 文件在位；两新文件 67/68 行；`name: image-generation-executor` / `name: video-generation-executor`（:2，=文件名）；description 各含 `MUST BE USED` + `触发:` 段（:3）；model 行各 1（:4，D2-A `custom:9e221f47…:sonnet-1`）；六节锚齐全（掌握的技能/输出模板/前置检查/Workflow/禁止行为/证据要求 各=1，video HARD_BLOCK=5） |
| 六面引用一致（VC-2 双向） | PASS | SKILL.md:356 媒体生成工序行含 `image-generation-executor`/`video-generation-executor`（在位优先）；:357 剧集创作管线行含 `video-generation-executor`；mapping:298 §九注 + :308 媒体制作族行双名在位；README_zh.md:114 / INSTALL_zh.md:307-308 / INSTALL.md:141-142 / install.sh:179 六面全部含双名（grep 全中）；registry tsv:46 登记行含双名 |
| 计数与枚举联动（VC-3 面） | PASS | `grep '3 个伴生\|3 个配套'` exit=1 零残留；`6 个伴生`=1（README_zh:114）/ `6 个配套`=1（INSTALL_zh:305）；companion/agents 实体 `ls`=6 文件（plan-writer/article-batch-publisher/article-field-fixer/complex-planner/image/video），与「6 个」口径一致；INSTALL.md 6 行 companion 表（含 3 新行 :140-142） |
| 行内替换净增 0 | PASS | `git diff --numstat 0f077ae..HEAD`: SKILL.md 2/2、mapping 2/2、install.sh 1/1、README_zh 1/1；`wc -l` SKILL.md=447 / mapping=314（与基线一致，skill-split 锚 447 不受影响，复跑 skill-split 41 PASS FAIL=0） |
| 守护与 registry（VC-4 面） | PASS | selftest-media-agents.sh 151 行，复跑 `Total: 10 PASS=10 FAIL=0`（MA-01..10 原文）；registry tsv 46 行，`selftest-registry.sh` 自报 `Total: 5 PASS=5 FAIL=0 (registry rows=45, actual selftest=45)` |
| 全量回归（对齐面复核） | PASS | 45 脚本全量复跑 rc_sum=0，FAIL=[1-9] 命中=0（media-dispatch 9/9、skill-split 41/41 抽样原文） |
| 零新 config 键 | PASS | MA-10 复跑 PASS + `jq '.properties\|length'`=40 |
| 术语一致性 | PASS | 「在位优先 / 缺位回退」措辞在 SKILL:356-357 与 mapping:298/:308 四处同构；旧「3 个」口径零残留；`image/video-generation-executor` 缩写仅 mapping:308 一处（同句全名已在前半句展开，非混用） |
| 互引完整性 | PASS | image agent description 互引 video-generation-executor（:3，=1）；video agent 互引 image-generation-executor（:3，=1）；两 agent 互指规则（Rule 47.2 具名路由）与 SKILL 媒体两行指向一致，无语义互斥 |
| 多副本同步 | N/A（仓内单源） | install-companion glob `companion/agents/*.md` 自动分发，零机制改动；双位部署属 Phase 5 仓外面（本 S9 范围外，VC-5 由部署对账收口） |
| 越界自检（scope_files） | PASS | `git diff --name-only 0f077ae..HEAD` 输出恰 10 文件，与 scope_files 十项逐一相等（INSTALL_zh/README_zh/mapping/INSTALL.md/SKILL.md/两 agent/install.sh/media-agents.sh/registry.tsv），工作区 `git status` 空 |

### 变更记录三要素（42.6.3）

| 字段 | 内容 |
|---|---|
| 变更范围 | 10 文件（见越界自检行）：2 新 agent + SKILL:356-357 + mapping:298/:308 + README_zh:114 + INSTALL_zh:305-308 + INSTALL.md:140-142 + install.sh:179 + selftest-media-agents.sh（新 151 行）+ registry.tsv:46 |
| 冲突处理结果 | 文档 stale 4 处（research-a 第 3 条）全部按最新口径（6 个 agent）更新，无删除/归档；行内替换保留「缺位回退」原语义（裁决依据=计划 Decisions「行内替换净增 0 + 在位优先缺位回退」）；未决残留冲突=无 |
| 文档当前状态 | 六面（SKILL/mapping/README_zh/INSTALL_zh/INSTALL.md/install.sh）+ registry 双 agent 名引用一致；计数 6 口径全仓零残留；残留冲突=0 |

### 建议（P2，不阻断）
- P2 mapping:308 缩写 `image/video-generation-executor`：同句前半已含全名，语义无歧义，保留即可；若后续模板实例回溯出现歧义再全名化。
- P2 双位部署（~/.zcode/agents + ~/.claude/agents）与 skill-agent-router +2 行属 Phase 5 仓外面，本 S9 不覆盖；VC-5 由部署对账 + 冒烟收口。

审查证据全部机器可复现（grep/wc/numstat/selftest 命令原样重跑）；逐命令输出索引见 `subagent-state/m9-executor.md`。

---

## Code Review Gate 结论（S11, code-quality-review，.sh 面隔离审查）

结论: **APPROVED**（P0=0, P1=0, P2=2 不阻断）— 审查对象: worktree @cc95adc 新建 `skills/task-planner/scripts/selftest-media-agents.sh`（151 行，MA-01..10 静态断言）；工具面=code-quality-review 技能清单逐维执行；纯只读审查零 git 写。

### 各检查维度结论（附关键原文行）

| 检查维度 | 结论 | 关键证据（命令/file:line） |
|---|---|---|
| 正确性与边界 | PASS | 实跑 `bash selftest-media-agents.sh` → `Total: 10 PASS=10 FAIL=0` rc=0；失败路径=每断言 else 分支 `bad NN` 均输出定位信息（:38/:48/:62/:71/:83/:95/:109/:124/:136/:145）；空值边界：grep 全部 `|| true` 兜底（:56-58），文件缺失走 MA-01 bad（:35-39 `-s` 判空） |
| 错误处理 | PASS（1 P2） | 无裸吞错：jq 唯一 `2>/dev/null`（:144）但结果 `keys` 入断言——config 畸形→keys=""→bad 10（fail-safe 非静默）；jq 缺失走 SKIPPED 打印行（:147，非静默降级，与 MD-08/R-12 先例一致） |
| 命名与可读性 | PASS | ok/bad/PASS/FAIL/SCRIPT_DIR/SKILL_ROOT 与 selftest-media-dispatch.sh:22-23/:94-95 全同构；每断言 What/Why 双层注释（:31-34 等）；单函数 ok/bad 各 2 行，无 >50 行函数 |
| 重复与死代码 | PASS | grep 仓内守护范式=media-dispatch（头注释:3 显式声明「范式对齐」）；10 断言语义各不重叠（双 agent 分断言 :45/:68 防部分守护，:67 注释明写理由）；无不可达分支 |
| 注释与 docstring | PASS | 头注释四要素（用途/输入/输出/依赖 :2-11）；无 TODO 占位；每断言含防什么漂移的 Why（:33-34/:88-89 等） |
| 输入校验 | PASS | 无外部入口（守护脚本）；路径定位 `SCRIPT_DIR/SKILL_ROOT`（:15-16）+ MA-01 前置在位校验；无 dict.get/x or default 模式 |
| 并发与资源 | PASS | 无文件/socket/子进程长开；循环体=单脚本一次性执行；grep/wc/jq 短进程无泄漏面 |
| 依赖与版本 | PASS | 依赖=bash+grep+test+jq（可选，:11）；jq 缺失降级 SKIPPED 明示（:9/:147），无 lock 漂移 |
| 风格一致性 | PASS | 与 selftest-media-dispatch.sh 逐结构对照：`grep -c '…' \|\| true` 计数模式（:90-91 vs :45/:51）、ok/bad 单行函数（:28-29 vs :22-23）、Total+`exit $((FAIL > 0))`（:150-151 vs :94-95）完全同构 |
| 测试配套 | PASS | 本脚本自身即测试（selftest）+ registry 登记行 `selftest-registry.tsv:46`；实跑 10/10；`bash selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=45, actual selftest=45)` |
| 越界自检 | PASS | `git diff --name-only 0f077ae..HEAD` 恰 10 文件 = 计划 scope_files 十项逐一相等；工作区 `git status` 干净；本审查会话零仓内写入（仅 plans/ 契约追加） |
| 幂等与副作用 | PASS | 连跑两次 `diff` 输出为空（IDEMPOTENT rc=0×2）；脚本零写操作（grep/test/jq/printf 只读面，头注释:8「零写入」） |
| 复杂度与分层 | PASS | 最大嵌套=MA-10 if-in-if 2 层（:143-145），全脚本无 >2 层嵌套；断言线性平铺 |
| 常量与配置 | PASS | `properties=40` 单一断言点（:144-145）同 43.4/44.4/47 口径（:139 注释）；「6 个」计数锚=文档面实际措辞 grep 锚（:117-118），无 3 处以上散落魔数 |
| 语法/可执行性 | PASS | `bash -n` 通过；`git diff 0f077ae..HEAD -- <file>` 确认 new file +151 行全量 |

### P2 建议（不阻断）

- [P2] `selftest-media-agents.sh:144` — `jq -r … 2>/dev/null || true` 吞掉 jq 运行时 stderr：config.json 畸形时行为正确（keys=""→bad 10），但诊断信息被抑制。建议修法（可选）：去 `2>/dev/null` 或 bad 10 文案补「config 解析失败？」提示。MD-08 先例同款写法，故仅 P2。
- [P2] `:144` 键数常量 `40` 硬编码于断言行——与 43.4/44.4 既定零新键口径绑定（:139 注释已声明同口径），config 键数演进时需同步本行；守护脚本惯技，接受。

### 结论（机械解析行）

`APPROVED` — P0=0, P1=0, P2=2（上文逐条）；15 维清单全过，证据可原样重跑复现。

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
