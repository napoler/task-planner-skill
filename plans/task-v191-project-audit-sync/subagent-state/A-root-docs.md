# A-root-docs 文档一致性审计检查点（task-v191）

审计范围：仓根 + 核心文档（10 个目标文件）
真值基准（本轮 wc/find/grep 实测）：
- SKILL.md = **237 行**；全集口径 = **Rules 1-92**，核心在位 14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83），其余 73 条 → 11 卫星（SKILL.md:9/179/221 为口径源）
- critical-rules.md = **193 行**
- scripts/ = **146 文件 / 137 .sh / 92 selftest-*.sh**
- 卫星 critical-rules-*.md = **11 个，全部存在**（含 verification-gate=Rule 84，task-v173 新增）
- config.json properties = **53**（顶层 6 键）
- templates 顶层 md = **13**，variant = **29**
- task-planner/references/ = **6 个 md**（dispatch-examples/batch-quality-gate/agent-coverage/capability-registry 已迁至卫星）
- companion/agents = **8 个**（含 decision-arbiter，task-v152/Rule 69 新增）

> 说明：严重度 P0=会误导执行/硬错；P1=口径性漂移（全集/行数/数量）；P2=陈旧快照或次级不一致。CHANGELOG.md 为历史变更日志，其内 1-65/1-72→1-75/62→65/110→146 等旧值属**历史记录**，不作为漂移计（例外：CHANGELOG.md:18 明确把 CLAUDE.md:33/README_zh.md:136,229 列为「1-NN 计数级联」锚点，佐证 RD-01/02/03 三处应为 1-92 而非 1-91）。

---

## 一、规则编号漂移（真值 1-92）

### RD-01 | P1 | README_zh.md:136
- 原文：`├── critical-rules.md      ← Rules 1-91 核心执行约束 <!-- ... --> <!-- 2026-10-14 对齐 1-75→1-83（Rule 81/82/83 落地，核心 14 条） -->`
- 问题：可见文本 "Rules 1-91"，真值 = 1-92（SKILL.md:9 "Rules 1-92 全集索引"）。Rule 92 存在于 task-discipline（见 RD-04 佐证）。
- 建议：改 "Rules 1-91" → "Rules 1-92"。

### RD-02 | P1 | README_zh.md:229
- 原文：`| skills/task-planner/references/critical-rules.md | Rules 1-91 —— 自定义前必读 <!-- ... -->`
- 问题：同 RD-01，"1-91" → 应 "1-92"。
- 建议：改 "1-91" → "1-92"。

### RD-03 | P1 | CLAUDE.md:33
- 原文：`├── critical-rules.md ← Rules 1-91 核心执行约束 <!-- ... --> <!-- 2026-10-14 对齐 1-75→1-83（Rule 81/82/83 落地，核心 14 条） -->`
- 问题：同 RD-01。
- 建议：改 "1-91" → "1-92"。

### RD-04 | P1 | README_zh.md:136/229 + CLAUDE.md:33（纪元注释末步）
- 原文（三处同）：`<!-- 2026-10-14 对齐 1-75→1-83（Rule 81/82/83 落地，核心 14 条） -->`
- 问题：纪元注释末步停在 "1-83"，但其行内可见文本写 "1-91"，两者互斥；且真值已至 1-92。纪元链落后两个纪元（84/85-92 未记）。
- 佐证 Rule 91/92 实存：plan-collab-router/references/critical-rules-collab.md:38 `### 91 workflow 脚本内 per-subagent 模型分档纪律`；SKILL.md:170 "Rule 39,40,91"。
- 建议：补齐纪元注释至 "1-92"，并核对核心 14 条口径（当前 "核心 14 条" 正确，仅全集上限 83/91 均落后）。

### RD-05 | P1 | ARCHITECTURE.md:42
- 原文：`│ Rules 1-80 全集索引：核心在位 12 条  │` + `│（1,2,3,5,19,20,26,51,62,66,80,82）│`
- 问题：ARCHITECTURE.md 仍写 "Rules 1-80 / 核心 12 条"，真值 = 1-92 / 核心 14 条（漏 81/83 两条核心规则，漏 84-92 全集）。ARCHITECTURE 为架构权威文档，偏差 12 条规则，最严重的口径漂移。
- 建议：改为 "Rules 1-92 全集索引：核心在位 14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83）"。

### RD-06 | P1 | ARCHITECTURE.md:114
- 原文：`- **核心在位 12 条**（1,2,3,5,19,20,26,51,62,66,80,82）全文见 references/critical-rules.md（165 行，含分层架构说明 + 卫星路由索引）` + `- **其余 70 条**按域迁至上表 11 卫星（3 新域 50 条 + 7 收编 16 条）`
- 问题：核心 12（真值 14）、其余 70（真值 73）。§4「纪元演进史」末行停在 "Rules 1-80"（:120），落后 83/84/92。
- 建议：核心 12→14、其余 70→73、全集 1-80→1-92，与 SKILL.md/README.md 对齐。

### RD-07 | P2 | critical-rules.md:188
- 原文：`**plan-collab-router**（域=技能协同与工具面选择）：规则全文见 ../../plan-collab-router/references/critical-rules-collab.md（Rule 39,40）；...`
- 问题：本仓 satellite 路由索引把 plan-collab-router 记为 "Rule 39,40"，但 Rule 91 亦落此文件（collab.md:38 `### 91`），SKILL.md:170 记 "Rule 39,40,91"。核心侧路由索引漏 91。
- 建议：core 路由索引 plan-collab-router 行补 "Rule 39,40,91"。

---

## 二、行数声明漂移（真值 SKILL.md=237 / critical-rules=193）

### LC-01 | P1 | skills/task-planner/README.md:4
- 原文：`家族分层 v2.1（2026-10-12 task-v171）：核心只负责四文件罗盘管理（SKILL.md 214 行）；...`
- 问题：SKILL.md 实测 237 行，非 214。
- 建议：214 → 237（或去掉具体行数只写"瘦身至 ≤250+边距"）。

### LC-02 | P1 | skills/task-planner/README.md:89
- 原文：`│   - SKILL.md (214 行, hooks 字段已剥除)   │`
- 建议：214 → 237。

### LC-03 | P1 | skills/task-planner/README.md:119
- 原文：`├── SKILL.md ← 工具无关主文档（214 行; hooks 字段为空, 文末含 11 卫星路由表）`
- 建议：214 → 237。

### LC-04 | P1 | ARCHITECTURE.md:13
- 原文：`- SKILL.md（214 行，hooks 字段为空；文末含 11 卫星路由表 + Rules 1-84 全集索引）`
- 问题：214 行（真值 237）；且 "Rules 1-84 全集索引" 又与 1-92 不一致（比 :42 的 1-80 还多一处、仍偏旧）。
- 建议：214 → 237；1-84 → 1-92。

### LC-05 | P1 | ARCHITECTURE.md:128
- 原文：`├── SKILL.md ← 工具无关主文档（214 行, hooks 字段为空）`
- 建议：214 → 237。

### LC-06 | P2 | skills/task-planner/README.md:81
- 原文：`全文见 references/critical-rules.md（190 行，2026-10-14 实测；含分层架构说明+卫星路由索引）`
- 问题：critical-rules.md 实测 193 行。"190 行" 是 2026-10-14 快照，已落后 3 行。
- 建议：190 → 193。

### LC-07 | P2 | ARCHITECTURE.md:114
- 原文：`...全文见 references/critical-rules.md（165 行，含分层架构说明 + 卫星路由索引）`
- 问题：实测 193 行，"165 行" 严重落后。
- 建议：165 → 193。

### LC-08 | P2 | ARCHITECTURE.md:302
- 原文：`...分层后核心 214 行 + 按需 Read 卫星全文，token 效率与域内聚双赢（Rule 82）`
- 建议：214 → 237（或改"≤250+边距"表述）。

---

## 三、脚本 / 数量声明漂移（真值 146/137/92；templates 13；refs 6；companion 8；config props 53）

### QT-01 | P1 | skills/task-planner/README.md:94
- 原文：`│   - scripts/     (119 条目 = 110 .sh 含 76 selftest)     │`
- 问题：实测 scripts/ = 146 文件 / 137 .sh / 92 selftest。三项全偏（119/110/76）。
- 建议：119→146、110→137、76→92。

### QT-02 | P1 | skills/task-planner/README.md:132
- 原文：`├── scripts/ ← 119 条目（110 .sh 含 76 个 selftest-*.sh + .ps1/.cjs/.ts/.tsv + lib//capabilities/ 子目录）` + `:146 └── selftest-*.sh ×76 + selftest-registry.tsv`
- 建议：119→146、110→137、76→92（两处含 ×76）。

### QT-03 | P1 | ARCHITECTURE.md:16
- 原文：`- scripts/（119 条目 = 110 个 .sh（含 76 个 selftest-*.sh）+ .ps1/.cjs/.ts/.tsv + lib//capabilities/ 两个子目录）`
- 建议：119→146、110→137、76→92。

### QT-04 | P1 | ARCHITECTURE.md:139
- 原文：`├── scripts/ ← 119 条目（110 .sh 含 76 selftest，2026-10-12 实测）`
- 建议：同 QT-03。

### QT-05 | P1 | INSTALL_zh.md:293
- 原文：`├── scripts/ (106 项: .sh 96 个（含 62 selftest）; <!-- 2026-10-08 task-v149 对齐实态 -->`
- 问题：实测 146/137/92；"106/96/62" 是 2026-10-08 task-v149 快照，虽标"对齐实态"但已落后 30+/40+/30+。
- 建议：106→146、96→137、62→92，并刷新"对齐实态"注释日期。

### QT-06 | P2 | INSTALL_zh.md:313
- 原文：`> 实际清单以 ls -R ... 为准（2026-10-08 实测：39 个模板（顶层 10 个 md + variant 29 类）、106 项 scripts（含 62 selftest）、10 个 references、7 个 companion agent）`
- 建议：106/62→146/92；39 模板（顶层 10）→42（顶层 13）；10 refs→6；7 companion→8；刷新日期。

### QT-07 | P1 | INSTALL_zh.md:302
- 原文：`├── references/ (10 个: critical-rules / completion-gate / goal-gate / dispatch-examples / methodology / todo-sync / worktree-isolation / batch-quality-gate / agent-coverage / capability-registry)`
- 问题：task-planner/references/ 实测仅 **6 个** md（critical-rules/completion-gate/goal-gate/methodology/todo-sync/worktree-isolation）。所列 dispatch-examples/agent-coverage 已迁 task-dispatch，batch-quality-gate/capability-registry 已迁 task-discipline（test -f 均 MISSING，find 证实现居卫星）。功能已迁移而文档未更新。
- 建议：改为 6 篇 + 注"其余 4 篇已按域迁至 task-dispatch/task-discipline 卫星"。

### QT-08 | P2 | README_zh.md:114
- 原文：`companion/agents/ ← 7 个伴生 agent（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor / drift-checker） <!-- 2026-10-08 task-v149 对齐实态 -->`
- 问题：companion/agents 实测 **8 个**（新增 decision-arbiter.md，task-v152/Rule 69，见 CHANGELOG.md:20）。
- 建议：7→8，补 decision-arbiter。

### QT-09 | P2 | INSTALL_zh.md:306
- 原文：`companion/agents/ (7 个配套 agent: plan-writer / ... / drift-checker, 部署到 ~/.zcode/agents/ 等)`
- 建议：7→8（补 decision-arbiter）。

### QT-10 | P2 | README.md:81 / README.md:4,288 / ARCHITECTURE.md:4,115
- 原文：README.md:81 "其余 **71** 条"；README.md:4/288 "**76** 条"；ARCHITECTURE.md:4 "76 条"、:115 "其余 **70** 条"；口径源 SKILL.md:9 "其余 **73** 条"。
- 问题：同族 4 份文档对"非核心条数"给出 71/76/70/73 四个不同值，互相矛盾，且与口径源 73 不一致。
- 建议：统一为 73（以 SKILL.md 为准）。

### QT-11 | P2 | INSTALL_zh.md:295
- 原文：`├── templates/ (39 个模板: 顶层 10 个 md ... + variant/ 29 类 ...)`
- 问题：templates 顶层 md 实测 **13**（batch_report/delivery-summary/deprecated/findings/knowledge-brief/notepad-learnings/progress/session-handoff/shared-tracker/subagent_dispatch/task_plan/user-session-log/verification），总 13+29=42。"顶层 10" 落后 3（缺 user-session-log/session-handoff/deprecated）。
- 建议：顶层 10→13、总 39→42。

### QT-12 | P2 | INSTALL_zh.md:290
- 原文：`├── config.json (JSON-Schema 阈值配置, 42 键)`
- 问题：config.json 实测 `properties` = **53** 键（顶层 6 键）。"42 键" 为旧快照（Rule 80.6 曾记 properties 44→46，现 53）。
- 建议：42→53（或写"以 properties 实测为准"，避免硬钉）。

### QT-13 | P2 | README.md:31 / ARCHITECTURE.md:37
- 原文：`10 技能分层图 = 核心 task-planner + 3 新域卫星(...) + 7 收编卫星(...)，共 11 个技能节点（核心 1 + 卫星 10）`
- 问题：标题写"核心 + 11 卫星"，正文分解却 "3 新域 + 7 收编 = 10 卫星"，与 11 矛盾；第 11 颗 verification-gate（Rule 84，task-v173）未进"3+7"分解与路由表（README 路由表实测仅 10 行，缺 verification-gate；critical-rules.md 路由索引却有 11 颗含 verification-gate:193）。
- 建议：把 verification-gate 补入分解/路由表（11 颗），或统一"10/11"口径。

---

## 四、跨技能引用路径形式

### PF-01 | P2 | ARCHITECTURE.md:74/84/100 等
- 原文：`规则全文 | ../task-dispatch/references/critical-rules-dispatch.md`（及 task-discipline/media-planner/... 同式）
- 问题：ARCHITECTURE.md 位于 skills/task-planner/docs/，其 `../` 解析到 skills/task-planner/（test -f `docs/../task-dispatch/...` = **DOES NOT RESOLVE**）；正确应为 `../../`。而同形式在 skills/task-planner/README.md（:68+）里是对的（`../` 解析到 skills/）。两文档对同一约定"从 skill 根写 ../"混用，docs/ 层未多退一级。
- 建议：docs/ 内 `../<sat>/...` → `../../<sat>/...`；或在文档标注"路径相对 skill 根 skills/task-planner/"。

### PF-02 | P2 | README_zh.md:139 + CLAUDE.md:36
- 原文：`[billing.md → ../plan-cost-guard/references/billing.md] ← 计费模式说明（已迁出至卫星 skill plan-cost-guard）`
- 问题：README_zh.md 与 CLAUDE.md 均在**仓根**，`../plan-cost-guard/...` 解析到仓根的上一级 /mnt/data/dev/plan-cost-guard（test -f = **DOES NOT RESOLVE**）；实际文件在 skills/plan-cost-guard/references/billing.md。
- 建议：仓根写 `skills/plan-cost-guard/references/billing.md`（或标注相对仓根）。

---

## 五、硬编码绝对路径（/mnt/data/dev、/home/terry）

### AP-01 | —（负结果） | 全部 10 个目标文件
- grep `/mnt/data/dev` 与 `/home/terry` 于 10 个目标文档：**0 命中**。文档路径契约统一用 `${TASK_PLANNER_ROOT:-...}` / `<repo>` / `~/.zcode/...` 占位符，未见硬编码绝对路径。
- 结论：无问题（ARCHITECTURE.md:22-25 明确声明"无 ~/.claude/~/.zcode 硬编码"，与实测一致）。

---

## 六、陈旧内容 / 纪元链

### ST-01 | P2 | progress.md（仓根，32 行）
- 原文：`### Error Log (Phase 5 补记) - 竞写冲突:并行会话(task-3file-enforce,即今晨实体副本转换会话)...` + `### task-v086 难度分级...（2026-09-21）` + `### task-v087 新任务边界判定（2026-09-22）`
- 问题：仓根 progress.md 内容为某批任务（task-v086/v087/v139）的进度片段/竞写事故记录，非"仓库级当前进度"；含 "P2 标 ⏸ 暂停"、"回卷 pending" 等任务态措辞，属遗留/孤儿内容。
- 建议：确认是否应保留；若为一次性任务簿记，归档或清空为仓库级进度模板。

### ST-02 | P1 | ARCHITECTURE.md:118-120
- 原文：`纪元演进史 ... 2026-10-12 task-v171：76 条既有规则按域分层至 10 卫星 + Rule 82 新增，全集索引演进为「Rules 1-80」...`
- 问题：ARCHITECTURE 纪元史末行停在 task-v171 / Rules 1-80 / 10 卫星，未反映 2026-10-14 起 81/82/83 入核心、verification-gate(Rule 84)、91/92 落地及 11 卫星；与 §2/§4 的 "11 卫星/1-80" 自相矛盾（§2 标题 11、正文 10；:113 写 1-80、:13 写 1-84）。
- 建议：补一条 "2026-10-14/18 演进程"（1-83 核心 14 + verification-gate 第 11 颗 + 91/92），统一 1-92/11 卫星。

### EC-01 | P1 | README_zh.md:136,229 + CLAUDE.md:33（HTML 纪元注释链）
- 原文（5 条注释）：`<!-- 2026-10-09 task-v152 ... --> <!-- 2026-10-09 task-v153 ... --> <!-- 2026-10-10 task-v158 演进 1-69→1-71 --> <!-- 2026-10-10 task-v163 级联 1-72→1-75 --> <!-- 2026-10-14 对齐 1-75→1-83（Rule 81/82/83 落地，核心 14 条） -->`
- 问题：纪元链末步 1-83，行内可见文本 1-91，真值 1-92 —— 三层不一致；链落后 84/85-92 两个纪元。critical-rules.md 本身文件头**无**纪元链（头 3 行干净），故"1-91/1-83"漂移的落点集中在这 3 份索引文档。
- 建议：纪元链末步补至 1-92，与可见文本一并校正。

### EC-02 | —（负结果） | critical-rules.md:98/130/148
- 逐规则溯源注释（Rule 62 @L98、Rule 80 @L130、Rule 81 @L148）与真实落点一致（"纯增量新增/预留号顺位取得/追加新增"），未发现漂移。

---

## 验证证据（本轮实测命令摘要）
- `wc -l skills/task-planner/SKILL.md` → 237；`wc -l .../critical-rules.md` → 193
- `find skills/task-planner/scripts -type f` → 146；`-name *.sh` → 137；`selftest-*.sh` → 92
- `ls skills/*/references/critical-rules-*.md` → 11 个（全存在，含 verification-gate）
- `python3 ... properties` → 53；`find templates -maxdepth 1 -name *.md` → 13；`ls references/*.md` → 6；`ls companion/agents` → 8（含 decision-arbiter）
- `grep -rn "Rules 1-91\|1-92\|→1-83"` → 命中 README_zh:136,229 + CLAUDE:33（1-91/→1-83）、README.md:36,81,123（1-92）
- `test -f docs/../task-dispatch/...` → DOES NOT RESOLVE；`test -f skills/task-dispatch/...` → RESOLVES
- `test -f ../plan-cost-guard/references/billing.md`（仓根）→ DOES NOT RESOLVE；实际 skills/plan-cost-guard/...
- `test -f references/dispatch-examples|agent-coverage|batch-quality-gate|capability-registry` → 全 MISSING（迁至卫星）
- 硬编码路径 grep（/mnt/data/dev、/home/terry，10 文件）→ 0 命中
