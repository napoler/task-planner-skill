# Knowledge Brief — task-v076-conclusion-discipline（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 行号基于 master@a182aed（2026-09-16 实核）
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：落地 Rule 35 执行结论纪律（能力否定三关 + 大输入落盘引用补救）+ check-dispatch/selftest 守护 + SKILL.md 四点同步，全量 selftest 0 FAIL 后合并 master 并部署 3 实体位 push GitHub。
- 背景/动机：用户实测两类蠢结论——①接口有 CRUD 却断言「无法查看」（没读完整 API 就下否定结论并结束任务）②prompt 过大直接失败收场（应落盘引用）→ 必须机器化为规则 + 门控 + 守护。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 能力否定三关 | 35.2 三关=①通读完整接口面（API 全 endpoint/CLI --help 全文/schema 全字段）②CRUD 一致性推断（有写接口则读接口必存在，get/detail/view/fetch 变体逐一尝试）③替代路径 ≥1 条（如 list+过滤） |
| 落盘引用（35.3） | prompt 超 prompt_max_chars 或材料过大 → 内容写 <plan-dir>/subagent-state/{seq}-prompt.md 或材料包，prompt 只留绝对路径 + 第一步 Read 指令；禁失败收场/禁静默截断 |
| 四点同步（rule-enhancement 范式） | critical-rules 新条款 / SKILL.md 列表行+合规清单 C 行+索引行+兜底注 / 消费侧脚本提示 / selftest 锚点同步，缺一即回归 FAIL |
| 全量 selftest 口径 | `for f in scripts/selftest-*.sh` 逐个跑、逐 `Total:` 行求和；总数禁采信子代理自报（主进程复核定数） |
| 3 实体位 | ~/.zcode、~/.claude、~/.config/opencode 下 skills/task-planner（smart-merge-back --deploy 自动分发，diff -r 复验） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| critical-rules.md 全文 290 行，Rule 34 段止 L290，Rule 35 插入点=L290 后 | plans/task-v076-conclusion-discipline/subagent-state/01-explore.md:6（本仓 wc -l 实核 290） | S2a 插 L290 后；插后文件 ≈310 行 |
| 22.4 单行条款 L127 末句含「机器校验已生效：check-dispatch.sh…」 | critical-rules.md:127（实核） | S2a 在 L127 行末追加超限补救句（指向 35.3），不新开子条 |
| 无既有「能力否定/先读完整接口文档」类条款，不重复立法 | 01-explore.md:7（grep 无法|不可能|接口文档 仅 4 处无关命中） | Rule 35 是新增而非改写既有规则 |
| SKILL.md 共 535 行，净增预算 ≤5 行 | 01-explore.md:8（本仓 wc -l 实核 535）；selftest-knowledge-brief.sh:38 断言 ≤540 | 四点同步含 3 处行内替换（L9/L277/L325）+ 3 处插入（L196/L301/L409）= 净增 3 行→538；上限断言须 540→545 注 task-v076 |
| SKILL.md 三处版本字样实为三种写法：L9 frontmatter `Critical Rules 全集 1-34`、L277 `（Rules 1-34）`、L325 索引表 `Critical Rules 1-34` | SKILL.md:9/277/325（grep 实核） | S2b/S3b 锚必须按实际写法定位，不能只 grep `Rules 1-34` |
| check-dispatch.sh L258 原文 `echo "[dispatch-guard] ⚠ prompt 长度 $pchar > $pmax"`；FG 断言用 `grep -qF 'prompt 长度'` | check-dispatch.sh:258（实核）；01-explore.md:26 | S2c 追加指引行必须保留 'prompt 长度' 字面在位，否则 selftest-dispatch FG-01..04 破 |
| subagent_dispatch.md 位于 templates/ 而非 references/（L91-94 §9 上下文预算，L92 现行解法只有「拆细」无落盘表述） | templates/subagent_dispatch.md:91-94（find 实核路径 + sed 实核内容） | S2c 补救行插 L92 后；派发 prompt 引该文件用绝对路径 |
| selftest 锚 4 处：reflect-verify.sh:60 严格锚 `grep -q 'Rules 1-34'`（+头注释 L13）、error-loop.sh:14 与 veto.sh:13 宽容锚 `Rules 1-3[1-4]`、knowledge-brief.sh:38 上限 ≤540 | scripts/selftest-reflect-verify.sh:13,60；selftest-error-loop.sh:14；selftest-veto.sh:13；selftest-knowledge-brief.sh:38（grep/sed 实核） | S3b 一次修齐：严格锚→1-35、宽容锚→`3[1-5]`、上限→545 注 task-v076 |
| 全量 selftest 基线=19 脚本 313/0（task-v075 progress.md:152 口径）；本任务新建 selftest-conclusion-discipline.sh 后=20 脚本 | 01-explore.md:9 | P1 跑基线确认 313/0；P4 预期 = 313 + CD 断言数（预期 8-10 条） |
| CHANGELOG 在仓根（skills/task-planner/CHANGELOG.md 不存在，实际=/mnt/data/dev/task-planner-skill/CHANGELOG.md），样式 L8 [Unreleased]→L10 ### 新增→L12-15 `- **特性（task-vNNN 子项）** — 描述` | find + sed 实核（L12 为 task-v075 A1 条目） | S4b 改仓根 CHANGELOG.md，条目样式照 L12 |
| selftest-veto.sh 风格范式：宽容锚 + ok/bad 计数 + 末行 `printf 'Total: %d PASS=%d FAIL=%d'` | scripts/selftest-veto.sh（头注释 L13 + 末行范式，01-explore 指认） | S3a 新建脚本照此风格，末行必须 printf Total 行（全量求和依赖该行） |
| notepad 被否决方案段名固定 = `## 🚫 被否决方案（User Rejected — Rule 32）` | templates/notepad-learnings.md:14（01-explore.md:33 指认） | S2b 在 plans/task-v076-conclusion-discipline/notepad-learnings.md 同段名下登记两条 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :281-290 | Rule 34 段（34.1-34.6 模板生命周期门控），段止 L290=Rule 35 插入点 |
| skills/task-planner/references/critical-rules.md | :127 | Rule 22.4 单行条款（九字段+上下文预算+机器校验声明），行末追加超限补救句 |
| skills/task-planner/SKILL.md | :9 | frontmatter references 行 `Critical Rules 全集 1-34（…Rule 34 模板生命周期门控）` → 1-35 + 追加 Rule 35 名 |
| skills/task-planner/SKILL.md | :196 | C22 合规清单行（attest 前 template_type 门控）→ C23 插入点（L196 后） |
| skills/task-planner/SKILL.md | :277 | `详见 references/critical-rules.md（Rules 1-34）：` → 1-35 |
| skills/task-planner/SKILL.md | :300-301 | Rule 33/34 列表行区（P0 规则速览段），Rule 35 列表行插 L301 后，范式照 Rule 34 行 |
| skills/task-planner/SKILL.md | :325 | References 索引表行 `Critical Rules 1-34（含 … Rule 34 模板生命周期门控）` → 1-35 |
| skills/task-planner/SKILL.md | :401-409 | 五档兜底表（表头 L401，表体 L403-409 含 5 档 AskUserQuestion 行），兜底注行插 L409 后：拆细仍超限时映射 35.3 落盘而非升档 |
| skills/task-planner/scripts/check-dispatch.sh | :258 | `echo "[dispatch-guard] ⚠ prompt 长度 $pchar > $pmax"` 告警行 → 追加 1 行补救指引（含 35.3 + 落盘路径范式，保留 'prompt 长度' 字面） |
| skills/task-planner/templates/subagent_dispatch.md | :91-94 | §9 上下文预算（prompt ≤ prompt_max_chars；L92 现行解法=拆细回 S-unit 表）→ L92 后补落盘补救行 |
| skills/task-planner/scripts/selftest-knowledge-brief.sh | :38 | `T2b SKILL.md 行数 ≤540（task-v074 扩充）` 断言 → 改 ≤545（task-v076 扩充） |
| skills/task-planner/scripts/selftest-reflect-verify.sh | :13,60 | 头注释 L13（RV-10 描述）+ :60 `grep -q 'Rules 1-34'` 严格锚 → 均改 1-35 |
| skills/task-planner/scripts/selftest-error-loop.sh / selftest-veto.sh | :14 / :13 | 宽容锚 `Rules 1-3[1-4]`（断言在 :59/:51）→ `Rules 1-3[1-5]` |
| CHANGELOG.md（仓根） | :8-15 | [Unreleased]→### 新增→条目样式（L12 task-v075 条目为格式样板） |
| skills/task-planner/scripts/selftest-veto.sh | 全文（≤70 行） | S3a 风格参照：宽容锚 + ok/bad 计数 + 末行 printf Total |

## §4 易错点与禁止假设清单
1. 禁止裸行号改文件：改 SKILL.md 前逐处 grep 锚内容定位（行内替换会让后续行号漂移，S2b/S2c 串行顺序 = critical-rules 先行、SKILL 后行的既定顺序不可颠倒——颠倒后行号已变）
2. 禁止动 config.json（本任务零新键，用户裁决）；35.6 机制只写 check-dispatch 提示 + selftest 守护
3. 禁止改既有 22.4/22.7 条款语义：只在 L127 行末追加一句（指向 35.3），22.7 换档逻辑原文不动，消费侧映射语义写进 35.5
4. 禁止假设 'prompt 长度' 字面可删：FG-01..04 断言 `grep -qF 'prompt 长度'` 命中它，check-dispatch.sh 追加行后必须复跑 selftest-dispatch.sh 全 22 断言
5. 禁止只改严格锚漏宽容锚（或反之）：4 处锚一次修齐（reflect-verify 严格 + error-loop/veto 宽容 + knowledge-brief 上限）；改前 `grep -rn "Rules 1-" skills/task-planner/scripts/` 全扫确认无第 5 处
6. 禁止采信子代理自报的 selftest 总数：P1/P4 Total 求和一律主进程逐脚本 `Total:` 行复核（模板范式 VC-4 注明）
7. 禁止把 CHANGELOG.md 找成 skills/task-planner/CHANGELOG.md（该路径不存在，实际在仓根 /mnt/data/dev/task-planner-skill/CHANGELOG.md）
8. 禁止把 SKILL.md L9 当 `Rules 1-34` 写法：实为 `Critical Rules 全集 1-34`（frontmatter），S2b 按实际文本替换
- FMEA RPN>100 兜底指针：本任务 FMEA 三项 RPN 均 ≤100（96/84/54），无 RPN>100 项；最高项 P2 行锚漂移（RPN=96）兜底=按锚内容定位 + 22.3 ②拆细（→ task_plan.md FMEA 表「Phase 2 行锚漂移」行）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1a | §2 + §3 | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/subagent-state/01-explore.md |
| S1b | §2（全量口径）+ §3 | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §2 |
| S2a | §1（Rule 35 全文要点）+ §3（critical-rules :281-290/:127） | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §1 |
| S2b | §3（SKILL.md 六锚 + notepad 段名）+ §4（易错点 1/5/8） | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §3 |
| S2c | §3（check-dispatch :258 + subagent_dispatch :91-94）+ §4（易错点 4） | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §3 |
| S3a | §3（selftest-veto 全文范式）+ §2（末行 Total 行要求） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-veto.sh |
| S3b | §2（锚 4 处证据行）+ §4（易错点 5） | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §4 |
| S4a | §2（全量口径 19→20 脚本 + 基线 313/0） | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §2 |
| S4b | §3（CHANGELOG :8-15 样式） | /mnt/data/dev/task-planner-skill/CHANGELOG.md |
| S5a | §3（部署三位 + 合并回合约） | /mnt/data/dev/task-planner-skill/plans/task-v076-conclusion-discipline/knowledge-brief.md §3 |
