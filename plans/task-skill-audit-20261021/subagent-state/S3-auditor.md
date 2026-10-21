# S3 审计检查点 — task-planner 规则三面一致性（规则正文 / 索引指针 / 机器契约）

任务：/mnt/data/dev/task-planner-skill 仓内 task-planner 技能「规则三面一致性」只读审计，定位导致执行产出不稳定的规则层缺陷。
审计范围：`skills/*/references/critical-rules*.md`（正文）+ `skills/task-planner/SKILL.md` / `README.md` / `docs/ARCHITECTURE.md`（索引）+ `skills/task-planner/scripts/selftest-*.sh` + `plans/.rule-reservations.jsonl`（机器契约）。
排除：`skills/task-planner/.backup/`（557 个旧副本），所有 grep/find 均已 `--exclude-dir=.backup`。
所有结论带 file:line 证据锚；下述命令均实跑复现（只读）。

---

## 0. 复现命令（证据来源）

```bash
# 规则正文全集（含 Rule 80 异常标题格式）
for f in skills/task-planner/references/critical-rules.md skills/*/references/critical-rules-*.md; do
  grep -nE "^#{2,4} *(Rule )?[0-9]+" "$f"; done
# → 89 个 `^### N ` 标题；Rule 80 用 `## Rule 80（…` 形式（唯一），补齐后 = 90 条
# 实况：distinct=89，missing 1-93 = 77 78 79 80（80 仅因格式未命中）→ 活规则 = 90（14 核心 + 76 卫星）
```
```bash
cd skills/task-planner && bash scripts/selftest-rule-reserve-pairing.sh   # Total: 3 PASS=3 FAIL=0
for s in selftest-plan-tier selftest-context-pressure selftest-absorption-discipline \
         selftest-verification-gate selftest-channel-fast-fail selftest-evidence-goal-gate \
         selftest-self-resolution selftest-proactive-research; do bash scripts/$s.sh; done
# → 全部 exit 0（8/8 全绿）
```

---

## A. 规则全集事实表（Rule 编号 → 唯一正文位置）

### A-01 活规则 = 90 条，非 86/88/89（P0）
- 现象：`^#{2,4} *(Rule )?[0-9]+ ` 枚举得 89 个标题；其中核心 13（Rule 80 因标题格式 `## Rule 80（…` 未命中）+ 卫星 76 = 89；补 Rule 80 = **90**。
- 证据：`skills/task-planner/references/critical-rules.md:139`（`## Rule 80（用户会话逐字记录与只写不改纪律 — task-v169）`，全仓唯一非 `### N` 形式标题）；命令见 §0。
- 分区：核心 14 = 1,2,3,5,19,20,26,51,62,66,80,81,82,83（`critical-rules.md`）；卫星 76 见下表。
- 影响：任何按 `^### N` 枚举的工具/守卫得 89（少 Rule 80）→ 计数口径天然分歧；下游把 89 当权威即漏 Rule 80。
- 分级：P1（格式面）/ P0（计数面，见 B-01）。

### A-02 卫星归属事实表（唯一正文位置，file:line 为标题行）
| 卫星 | 规则号 | 正文文件 |
|---|---|---|
| task-dispatch | 12,13,14,21,22,23,25,46,52,59,68（11） | `skills/task-dispatch/references/critical-rules-dispatch.md` |
| task-discipline | 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41,42,43,44,45,48,53,54,55,56,57,60,65,67,69,70,71,72,73,74,76,85,86,87,88,89,90,92,93（**44**） | `skills/task-discipline/references/critical-rules-discipline.md` |
| media-planner | 47,49,50（3） | `skills/media-planner/references/critical-rules-media.md` |
| plan-research-router | 58,63,**75**（3） | `skills/plan-research-router/references/critical-rules-research.md`（Rule 75 正文 = `:42`） |
| plan-template-kit | 16,34,37,38（4） | `skills/plan-template-kit/references/critical-rules-template.md` |
| plan-collab-router | 39,40,**91**（3） | `skills/plan-collab-router/references/critical-rules-collab.md`（Rule 91 = `:38`） |
| plan-cost-guard | 17（1） | `skills/plan-cost-guard/references/critical-rules-cost.md` |
| plan-resume | 24（1） | `skills/plan-resume/references/critical-rules-resume.md` |
| progress-tracker | 30（1） | `skills/progress-tracker/references/critical-rules-progress.md` |
| task-drift-guard | 11,15,61,64（4） | `skills/task-drift-guard/references/critical-rules-drift.md` |
| verification-gate | 84（1） | `skills/verification-gate/references/critical-rules-verification.md` |
| 核心 | 1,2,3,5,19,20,26,51,62,66,80,81,82,83（14） | `skills/task-planner/references/critical-rules.md` |
- 合计 11+44+3+3+4+3+1+1+1+4+1 = 76 卫星 + 14 核心 = **90**。
- 无「2 处正文」的独立规则（`^#{2,4} *(Rule )?[0-9]+ ` 跨 12 文件 uniq -c，重复项仅 70/72 的 70.1-70.6/72.1-72.6 子条，同文件内）——**但 Rule 38.7 是例外：逐字双载**（见 D-01）。

### A-03 Rule 80 标题格式异常（唯一破坏枚举一致性者）（P1）
- 现象：全仓 90 条规则中，89 条用 `### <N> <标题>`，仅 Rule 80 用 `## Rule 80（…）`。
- 证据：`skills/task-planner/references/critical-rules.md:139` vs `:159`(### 81)/`:173`(### 82)/`:181`(### 83)。
- 影响：任何 `^### N ` 枚举/区间提取脚本会漏 Rule 80（如 `awk '/^### 69 /,/^### 7[0-9] /'` 族）；跨文件计数得 89 而非 90，与「89」这一错误索引数字巧合混淆，掩盖真实缺口。
- 分级：P1。

### A-04 0 正文编号（登记，非缺陷）
- 77/78/79 无正文：`plans/.rule-reservations.jsonl:55-57` 记 `abandoned`（task-v168 封存未合并）。属合法废止，非缺陷；但**计入/不计入口径在四份计数里各不相同**（见 B-01）。

### A-05 Rule 83 / Rule 56 正文在位但编号账本零记录（P0）
- 现象：Rule 83 正文完整（含 83.1-83.4 子条 + `selftest-channel-fast-fail.sh` 守护），Rule 56 正文在位，但 `plans/.rule-reservations.jsonl` 中 **无任何 `"rule":83` / `"rule":56` 行**。
- 证据：`skills/task-planner/references/critical-rules.md:181`（Rule 83 正文）；`skills/task-discipline/references/critical-rules-discipline.md:260`（Rule 56 正文）；`grep -n '"rule":83\|"rule":56' plans/.rule-reservations.jsonl` → 0 行（账本 rule 全集 = 59..93 中缺 56/83）。
- 影响：违反 SKILL.md:59 / `check-complete.sh:109` 的「新增编号必须 `rule-reserve.sh land` 登记」；配对守卫对该类**完全盲**（只比账本内两集合，从不与正文对账）→ 假 PASS。
- 分级：P0。

---

## B. 计数与区间断言核对（哪个是错的）

### B-01 全集计数四份互斥（P0）——真值 90(14+76)
| 出处 | 声明 | 判定 |
|---|---|---|
| `plans/.rule-reservations.jsonl:55-57`（77/78/79 的 note） | 「全集实测 **86=14 核心+72 卫星**」 | ❌ 错（少 4；且 77/78/79 已 abandoned 不计入的算法本身对，但数值陈旧） |
| `skills/task-planner/SKILL.md:9` | 「Rules 1-93 全集索引…**其余 74 条**按域归 11 卫星」 | ❌ 错（实为 76） |
| `skills/task-planner/SKILL.md:208` | 「核心在位 14 条…**其余 74 条**」 | ❌ 错（实为 76） |
| `skills/task-planner/references/critical-rules.md:193-203` 卫星索引逐行枚举求和 | 14 + 75 = **89** | ❌ 错（漏 Rule 91，见 B-02） |
| 实况（A-01） | **90 = 14 核心 + 76 卫星** | ✅ 唯一正确值 |
- 影响：三个不同的错误数字并存，任一处被下游当权威即产生不同的规则覆盖面认知；「88」与「86」之差恰为 2 条真实落地的规则（87-93 批次）。
- 分级：P0。

### B-02 核心卫星索引漏 Rule 91（P0）
- 现象：`critical-rules.md:198` 的 plan-collab-router 行只列 `Rule 39,40`；同仓 `SKILL.md:199` 列为 `Rule 39,40,91`。
- 证据：`sed -n '193,203p' skills/task-planner/references/critical-rules.md` 展开 11 行 → 卫星合计 75（缺 91）；`skills/plan-collab-router/references/critical-rules-collab.md:38` 确证 Rule 91 正文在位。
- 影响：按「核心索引」导航的 agent 永远看不到 Rule 91（workflow per-subagent 模型分档），而 Rule 91 正是防「全流统一档位」的条款 → 漏读即行为漂移。
- 分级：P0。

### B-03 SKILL 路由表区间 `69-76` 吞并 Rule 75（双行认领）（P0）
- 现象：`SKILL.md:195`（及 frontmatter `:17`）task-discipline 行写 `Rule …,69-76,85,…`；区间展开含 **75**，而 Rule 75 正文在 plan-research-router（`:197` 同表另一行已列 75）。
- 证据：`SKILL.md:195` 与 `:197`；`skills/plan-research-router/references/critical-rules-research.md:42`（`### 75 网络调研主动激活…`）。
- 影响：同一 Rule 号被两行认领 → 「按表读 discipline 文件」时 0 命中（Rule 75 不在 discipline），agent 或误判规则不存在、或转述失真；这是 E-01 的直接机制。
- 分级：P0。

### B-04 README/ARCHITECTURE 路由表区间吞并 Rule 30 与 Rule 34（P0）
- 现象：`README.md:69`（表行）与 `docs/ARCHITECTURE.md:101` 的 task-discipline 行写 `Rule 4,6,7,8,9,10,18,27,28,29,31-36,41-45,48,53-57,60,65,67,69-76`。
  - `31-36` 展开含 **34**（真身 = plan-template-kit，`critical-rules-template.md:11`）；
  - `69-76` 展开含 **75**（真身 = plan-research-router）。
- 另有 ASCII 图：`README.md:48` / `ARCHITECTURE.md:54` 同一域框写「69-76（36 条）」，而该框内枚举 `27-36` 又吞 **30**（真身 = progress-tracker，`critical-rules-progress.md:8`）。
- 影响：四份索引（SKILL / README 表 / README 图 / ARCHITECTURE）对同一卫星的规则集合给出三种不同答案；修复 SKILL 而不同步 → 索引面继续漂移。
- 分级：P0。

### B-05 文档数字自相矛盾（P1）
- `README.md:4`：「SKILL.md **237 行**」；实测 `wc -l skills/task-planner/SKILL.md` = **266**。同段又写「非核心 76→73 条」后接「73→74 条」，与 `:81` 的「74 条」及实况 76 互斥。
- `README.md:81`：「`references/critical-rules.md`（**193 行**，2026-10-19 task-v191 实测）」；实测 = **203 行**。
- `docs/ARCHITECTURE.md:115`：「其余 74 条…3 新域 **50 条** + 7 收编 **16 条** + 验证域 **1 条**」→ 50+16+1=**67 ≠ 74**（同句内算术自破）。
- 证据：`wc -l` 两条 + `sed -n '115p'`。
- 分级：P1（不直接致错分支，但破坏「文档=权威计数源」的可信度）。

---

## C. 机器契约失效的守卫

### C-01 `selftest-rule-reserve-pairing.sh` 豁免表基线自含失配 + 与正文零对账（P0）
- 位置：`skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:9,11,38,41`。
- 原文：`:38` `EXEMPT_LANDED=(46 47 48 49 50 75)`；`:41` `EXEMPT_DANGLING=(57 60 80 82)`；`:40` 注释「57=v141 预留后 land 未配对；60=v143 仲裁改号；80=v169；82=v171（均为历史悬空预留，非在途）」。
- 失效机理：
  1. 实跑（§0）输出 `PR-02 PASS reserved 悬空项=57 60 80 82 全在豁免表…` —— 而这 4 条**正文均已落地**（57→`critical-rules-discipline.md:278`；80→`critical-rules.md:139`；82→`critical-rules.md:173`），注释「非在途」与事实相反 → 真实失配被当 PASS 放行。
  2. 守卫只在账本内部比两集合（`comm -23/-13`，`:63,:80`），**从不与规则正文对账** → Rule 83/56 账本零记录（A-05）不触发任何 FAIL。
  3. `EXEMPT_LANDED` 含 46-50/75：这些确为「landed 无 reserved」，但同一表把「landed」写进注释，掩盖了它们**同样零 reserved 记录**的账本残缺（历史旁路）。
- 假 PASS 条件：任何「正文已 land、账本停在 reserved 或空」的漂移 → PASS。
- 分级：P0。

### C-02 `selftest-verification-gate.sh:73` 恒真子断言（P0）
- 位置：`skills/task-planner/scripts/selftest-verification-gate.sh:73`。
- 原文：`… && [ "$(grep -cF 'Rule 80,88,84' "$TP_SKILL" || true)" -ge 0 ] && [ "$(grep -cE 'Rule ?84' "$TP_SKILL" || true)" -ge 2 ]`。
- 失效机理：`-ge 0` 对任何计数恒真（实测 `grep -cF 'Rule 80,88,84' skills/task-planner/SKILL.md` = **0**，判定仍 TRUE）。该子句声称守护「Rule 80/88/84 三域并列」接线，实际零约束。
- 假 PASS：SKILL.md 删掉 Rule 80/88 的路由引用 → 该断言仍 PASS（只要 `Rule 84` ≥2）。
- 分级：P0（恒真断言 = 纸面守卫）。

### C-03 宽锚 `1-[89][0-9]`：接受 1-80…1-99 任何上界（P0，面最广）
- 位置：20 个脚本使用（`grep -rlc "1-\[89\]\[0-9\]" skills/task-planner/scripts/*.sh` = 20），代表：
  - `selftest-plan-tier.sh:96`：`grep -qE 'Critical Rules 核心域.*Rules 1-[89][0-9]' "$SKILLMD"`
  - `selftest-reliability-institution.sh:96-98`：断言 `1-[89][0-9]` ≥1 且字面 `1-40` =0
  - `selftest-context-pressure.sh:109-110`、`selftest-absorption-discipline.sh:42`
- 失效机理：实测 `printf 'Rules 1-80 全集' | grep -cE '1-[89][0-9]'` = **1**（同样接受 1-99）。即 SKILL 声明「Rules 1-80」这一**已知错误值**也会 PASS。
- 假 PASS：规则计数从 90 掉到 80（或任何 8x/9x）都无法被检出；且守卫的**报告文案本身写「Rules 1-80 全集」**（`selftest-plan-tier.sh:96`、`selftest-reliability-institution.sh:98`、`selftest-context-pressure.sh:102` 注释）→ 文案与实际断言分离，人读 PASS 行会以为锚在 1-80。
- 分级：P0。

### C-04 宽容正则被「反向钉死」，禁止收紧（P0）
- 位置：`skills/task-planner/scripts/selftest-absorption-discipline.sh:85-93`（AD-12）。
- 原文：`:85-89` `_pin_lit "$SCRIPTS/selftest-tool-selection.sh" "grep -cE '1-[89][0-9]'" …`（5 处 lit + 6 处 tol，共 11 处）；`:96` 判定「live 锚字面（精确 5：'1-[89][0-9]' 纪元 grep ×5）或宽容正则族（6）二者居一」。
- 失效机理：AD-12 把 11 个脚本里的**宽容正则字面**作为被断言对象。任何人把 `1-[89][0-9]` 收紧为准确的 `1-93` → AD-12 FAIL（假 FAIL）。
- 后果：C-03 的盲点被机制**锁定**——修正计数锚会先撞红这套守卫，形成「守卫阻止修守卫」的自我固化。
- 分级：P0。

### C-05 `selftest-session-log.sh` SL-05：注释/文案/代码三套正则，负样本控制失效（P1）
- 位置：`skills/task-planner/scripts/selftest-session-log.sh:66-72`。
- 原文：`:66` 注释「扩围正则 `1-8[0134]([^0-9]|$)`…负样本 '1-82'/'1-89' 不得命中——禁越界放开」；`:68` 文案「纪元锚 '1-8[0-9]'」；`:69` 实际 `grep -cE '1-[89][0-9]([^0-9]|$)'`；`:70-71` 负样本用 `1-8[0134]`。
- 失效机理：实测 `echo '1-90' | grep -cE '1-[89][0-9]([^0-9]|$)'` = **1**（live 锚接受 1-90）；而负样本断言 `echo '1-90' | grep -cE '1-8[0134]([^0-9]|$)'` = 0（真），即**负样本测的是另一个正则**，对 live 锚零约束。
- 假 PASS：声明「禁越界放开 1-82/1-89」实际不成立；三套正则并存使维护者按注释改锚必失败或改错处。
- 分级：P1。

### C-06 迁移后注释/标签指向旧位置（P1，未致 FAIL 但误导排查方向）
- `selftest-proactive-research.sh:6`：注释「· references/critical-rules.md（Rule 75 条款本体，PR-01..PR-09）」；实际变量 `:36` `CR="$SCRIPT_DIR/../../plan-research-router/references/critical-rules-research.md"  # Rule 75 条款本体（v171 迁移后归属）`。注释未随迁移更新（脚本行为正确 → 负结果，但 FAIL 时排查者会去错文件）。
- `selftest-evidence-goal-gate.sh:85,87,242`：文案/注释均写「critical-rules.md」；实际 `:74` `CRIT="…/plan-research-router/references/critical-rules-research.md"`。同类标签漂移。
- 分级：P1。

### C-07 SKILL.md:187「0 命中」声明与事实相反（P1）
- 位置：`skills/task-planner/SKILL.md:187`。
- 原文：「原核心 `references/critical-rules.md` 锚已失效（task-v171 专业化拆分后 **0 命中**）…后续 grep 检查 Rule 38.7 应命中这两处，勿再 grep 核心 critical-rules.md」。
- 失效机理：实测 `grep -c '38\.7' skills/task-planner/references/critical-rules.md` = **1**（命中在 `:181` Rule 83 标题内的「衔接 …38.7（执行通道分级）」交叉引用）。
- 影响：声明「0 命中」使「按命令复核锚点」的人得到 1 命中，误判核心文件仍是权威锚；真实权威锚 = `plan-template-kit/references/critical-rules-template.md:45` + `task-discipline/references/critical-rules-discipline.md:195`（两处均已实测确认）。
- 分级：P1。

### C-08 负结果（已检查、未发现违规——防止重复劳动）
- `selftest-registry.sh` T02/T03：**无缺失/无孤儿**（`for f in scripts/selftest-*.sh; grep -q "^$b" selftest-registry.tsv` → 0 条 MISSING；tsv 93 行 vs 实脚本数一致）。
- 指针文件 `references/completion-gate.md` / `goal-gate.md`：均为 7 行纯指针，无残留规则正文 → **不构成 Rule 82 镜像副本**。
- `run-selftests.sh:113` 只 glob `$SCRIPT_DIR/selftest-*.sh`；未发现任何递归 `find -name 'selftest-*'` 未排除 `.backup` 的脚本（`grep` 0 命中）→ `.backup` 不污染套件计数。
- 独立规则无「2 处正文」（除 D-01 的 38.7 逐字双载）；无脚本按 `^### N` 跨文件枚举（故 A-03 影响限于人读/新工具，现有套件不受影响）。
- 已检查但**未发现**守卫断言「Rule 91 存在」「Rule 75 归属 research」「全集=90」——即 B-02/B-03/B-01 无任何机器守护，纯靠人维护。

---

## D. 规则互相矛盾 / 管辖重叠

### D-01 Rule 82「禁镜像副本」vs Rule 38.7 逐字双载（P0）
- 现象：`critical-rules.md:173`（Rule 82）立「禁回潮、禁镜像副本」；而 Rule 38.7 全文**逐字**出现在两个卫星：`plan-template-kit/references/critical-rules-template.md:45` 与 `task-discipline/references/critical-rules-discipline.md:195`（两处文本一致，实测 diff 无差异）。
- 且 `SKILL.md:187` 把该双载称为「逐字双载，域归属=模板域+执行纪律域」，即**由 SKILL 授予豁免**。
- 矛盾点：Rule 82 是 P0 铁律，其豁免却写在 SKILL.md 正文（非 Rule 82 条文内），构成「规则文本 vs 规则解释」的管辖冲突；任何审计 Rule 82 的守卫若按「同文本出现 2 次 = 违规」判定，将把 38.7 判违规（反之则漏检真镜像）。
- 分级：P0（规则自洽性）。

### D-02 同事项两处规定：Rule 75 vs Rule 63/60（重叠，已声明）
- `critical-rules-research.md:42`（Rule 75「网络调研主动激活…反死磕主动检索」）与 `:26`（Rule 63「检索优先与反推诿…主动检索」）、`task-discipline/…:295`（Rule 60「主动解决问题…枚举替代方案」）三者均以「遇阻先检索/主动解决」为规范对象。
- Rule 75 标题自述「衔接 Rule 60/63/…」，属显式重叠而非隐藏冲突；但**索引面把 75 又错分给 discipline**（B-03），使「去哪读」比「读哪条」更不确定。
- 分级：P1（重叠已声明）/ P0（归属错分见 B-03）。

### D-03 编号格式双轨：`## Rule 80` vs `### 81`（管辖=机器契约）（P1）
- 见 A-03。Rule 80 是唯一用「Rule + 号」前缀 + `##` 级标题的规则，与 Rule 82「分层纪律/一致性」精神相悖（同族条目形态不一）。
- 分级：P1。

### D-04 编号账本 schema 双轨（空格 vs 无空格）（P1）
- `plans/.rule-reservations.jsonl` 前段（`:1-57`）形如 `{"rule": 46, "status": "landed", …}`（冒号后有空格），后段（`:58-81`）形如 `{"rule":80,"status":"reserved",…}`（无空格）。
- 影响：解析方必须写容错正则（`selftest-rule-reserve-pairing.sh:52` 已用 `[[:space:]]*` 容错），但任何朴素 `grep -o '"rule":[0-9]*'` 会漏掉带空格的 46-57 段（本审计首轮即因此误判，见 §0 命令的 `[[:space:]]*` 版本）→ 同一账本产出两套计数。
- 分级：P1。

---

## E. 「按 Rule 号定位全文会走错分支」的具体场景

### E-01 Rule 75 → 被 SKILL 路由表导向 task-discipline（空手而归）
- 走错路径：`SKILL.md:195`（`69-76` 含 75）→ Read `skills/task-discipline/references/critical-rules-discipline.md` → **0 命中 `### 75`**。
- 真路径：`skills/plan-research-router/references/critical-rules-research.md:42`。
- 证据：`SKILL.md:195`、`:197`、`critical-rules-research.md:42`；`grep -cE '^### 75 ' critical-rules-discipline.md` = 0。
- 执行后果：agent 读到「规则不存在」→ 或跳过 Rule 75（网络调研主动激活 → 执行期不再主动检索，正是「无对标就下结论」类漂移），或凭印象复述成幻觉条款。**执行产出不稳定最直接机制**。
- 分级：P0。

### E-02 Rule 91 → 按「核心卫星索引」导航则完全看不到
- 走错路径：`critical-rules.md:198`（collab 行 `Rule 39,40`）→ agent 认为 collab 域只有 39/40 → 不读 `critical-rules-collab.md:38` 的 Rule 91。
- 真路径：`skills/plan-collab-router/references/critical-rules-collab.md:38`。
- 证据：`critical-rules.md:198` vs `SKILL.md:199`（后者含 91）——两份索引互斥。
- 执行后果：workflow 编排任务丢失 per-subagent 模型分档纪律 → 全流统一档位（资源浪费）或悄悄降档；且该条自带「官方文档与用户级技能机制矛盾」的验证前置门，漏读即失去矛盾披露。
- 分级：P0。

### E-03 Rule 34 / Rule 30 → 被 README/ARCHITECTURE 路由表导向 task-discipline
- 走错路径：`README.md:69` / `docs/ARCHITECTURE.md:101` 的 discipline 行区间 `31-36` 含 **34** → Read discipline 文件 → 0 命中 `### 34`。
- 真路径：`skills/plan-template-kit/references/critical-rules-template.md:11`（Rule 34）。
- 同理 `README.md:48` / `ARCHITECTURE.md:54` 图内 `27-36` 含 **30** → 真身 `skills/progress-tracker/references/critical-rules-progress.md:8`。
- 证据：上述 file:line；`grep -cE '^### (30|34) ' critical-rules-discipline.md` = 0。
- 执行后果：模板生命周期门控（Rule 34）与共享内容认领（Rule 30）在按图索骥的执行流中被跳过。
- 分级：P0。

### E-04 Rule 80 → 任何按 `^### N` 的定位器漏检
- 走错路径：`grep -nE '^### 80 ' critical-rules.md` → 0 命中（标题为 `## Rule 80（…`）。
- 真路径：`skills/task-planner/references/critical-rules.md:139`。
- 证据：A-03；同文件 `:159/:173/:181` 均为 `### N` 形式。
- 执行后果：以标题枚举构建「规则清单」的工具/脚本会认为 80 缺失（与 A-01 的 89 vs 90 同源）；Rule 80 是 user-session-log 只写不改纪律，漏读即「用户原话被改写」。
- 分级：P1。

### E-05 Rule 38.7 → 按 SKILL 指令 grep 得 3 命中，1 个是假锚
- 走错路径：照 `SKILL.md:187`「勿再 grep 核心 critical-rules.md」但实际 grep 全仓 → 命中 3 处：`critical-rules.md:181`（Rule 83 内的交叉引用，**非正文**）+ `critical-rules-template.md:45` + `critical-rules-discipline.md:195`。
- 真路径：后两者（逐字双载）。
- 证据：`grep -rn '38\.7'`（§0 命令）；`critical-rules.md:181` 命中行含「衔接 Rule 22.3…/38.7（执行通道分级）」。
- 执行后果：审计者以 `critical-rules.md:181` 为「Rule 38.7 正文」→ 拿到的是 Rule 83 的衔接句而非比例原则全文（L0/L1/L2 通道分级缺失）→ 执行通道定级失据。
- 分级：P1。

---

## 5 条最严重发现（按影响排序）

1. **C-03 + C-04（宽锚 + 反向钉死）**：20 个脚本用 `1-[89][0-9]`，实测接受「Rules 1-80」为 PASS；且 `selftest-absorption-discipline.sh:85-96` 把该宽容字面钉死为断言对象，使「收紧锚」本身触发假 FAIL。全集计数从 90 漂到 80 不会被任何守卫发现——**计数面 100% 失效**。（P0）
2. **B-01 + B-02 + B-03（三面计数互斥 + Rule 75/91 归属错）**：真值 90(14+76)，同仓并存 86/88/89 三个错值；核心索引漏 91，SKILL 路由表把 75 双行认领。直接导致 E-01/E-02 走错分支 → 执行行为漂移。（P0）
3. **C-01（配对守卫基线自含失配 + 与正文零对账）**：`EXEMPT_DANGLING=(57 60 80 82)` 把「正文已落地但账本停 reserved」的 4 条当 PASS，注释「非在途」与事实相反；Rule 83/56 账本零记录且守卫盲。**失配被判 PASS**。（P0）
4. **A-05（Rule 83/56 正文在位、编号账本零记录）**：违反 SKILL.md:59 / check-complete.sh:109 的编号预留登记铁律，且无守卫可与正文对账，编号体系失去单一事实源。（P0）
5. **C-02 + D-01（恒真断言 + Rule 82 禁镜像 vs 38.7 逐字双载）**：`selftest-verification-gate.sh:73` 的 `-ge 0` 恒真（实测命中 0 仍 PASS），三域并列契约零约束；同时 P0 铁律 Rule 82「禁镜像副本」与其唯一豁免（38.7 双载，写在 SKILL.md 而非条文内）互相矛盾。（P0）

---

## 附：与 S1 线索的差异（独立复核修正）

- S1 称「selftest-rule-reserve-pairing.sh:41 把 57/80/82 写死 EXEMPT_DANGLING（注释与事实相反）」——**修正为 4 个：57 60 80 82**（`:41` 全表），且实跑 PASS 行为已复现（§0）。
- S1 称「critical-rules.md:191-203 卫星索引写 89」——**机理修正**：索引逐行枚举求和 = 14+75 = 89（漏 Rule 91）；另有一个巧合的「89」来自 `^### N` 枚举（漏格式异常的 Rule 80）。两者数值相同但成因不同，修复动作不同。
- S1 称「Rule 57/80/82 正文已落地但账本终态仍 reserved」——**扩展**：Rule 57 在账本 `:17` 为 reserved（无 landed），80 `:58`、82 `:60` 同；另新增发现 **Rule 56 / Rule 83 账本零记录**（S1 未列）。
- 新增（S1 未列）：C-02 恒真断言、C-03/C-04 宽锚与反向钉死、C-05 SL-05 三套正则、C-07「0 命中」声明与事实相反、B-04 README/ARCHITECTURE 区间吞 30/34、B-05 文档行数/算术自破、D-04 账本 schema 双轨。
