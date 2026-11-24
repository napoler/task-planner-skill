# S17 Critic — P6 方案独立评审

- 任务：task-sp-os-invocation-audit-20261124 / 执行体 critic(opus-1) / 2026-11-24
- 评审对象：PD/improvement-options.md（38 行）、PD/improvement-proposal.md（43 行）
- 判据：plan-brief.md §F S17 行、§D C1-C8、plan-state.json VC-8、root_causes H1-H5、user-session-log.md:42-56
- 判定：**未通过（NOT APPROVED）** — 1 CRITICAL / 6 IMPORTANT / 5 WARNING / 3 NIT
- 只读评审：仅写本 checkpoint 与 T/writes.txt，未改评审对象与任何受管文件

## 证据抽检结果（全部实际 Read/grep，无脑补）

| 锚点 | 结论 | 证据 |
|---|---|---|
| config.json:29-40（SessionStart 仅一条） | 属实 | `:29 "SessionStart"`、`:34 zcode-sessionstart.sh`，唯一 command |
| config.json:69（UserPromptSubmit） | 属实 | `:69 "UserPromptSubmit"`、`:74 zcode-userpromptsubmit.sh` |
| planctl.py:1271（parallel 占第 8 列） | 精确属实 | `:1271 _cell(s.get("parallel", "")) or "无"`，且 SUNIT_HEADERS `:1166` 第 8 列为「伴飞技能」 |
| check-dispatch.sh:580/586 | 属实但漏跳过条件 | `:580/:585` 提取 .md token；真正 skip 在 `:588 if [ "${#esrcs[@]}" -gt 0 ]` |
| skill-collaboration.md:60,68 | 精确属实 | `:60` OpenSpec 行含 `command -v openspec` + `openspec/`；`:68` 探针失败→不可接管 |
| todo-sync.md:37（部署位） | 属实（部署旧版） | 部署 `:37`=B1-B8 门禁挂钩；repo 源 `:37` 已是含 B9/B10/B11 的门禁挂钩 |
| sync-todos.sh:201-214（部署位） | 属实（部署旧版） | 部署 `:207-214`=B1-B8；repo 源 `:303-324`=B1-B11 |
| spec-mode.md §1 | 属实 | `:6 ## 1. 触发判定与路由表`、`:7` 触发面、`:10-16` 路由表 |
| S4 scratch-init rc=0 | 属实（沿用，未重跑） | report-design-os.md:27 rc=0；report-rootcause-2.md:43 明示本轮未重跑 |
| ~/.bashrc:127 已有 npm-global 导出 | 属实（推翻方案 H4 改法） | probe-path.txt grep 输出 + `sed -n '126,127p'` |

## CRITICAL

### [C-1] B9/B10 编号已被已合并特性占用，且 FILE-CHANGE 锚定 11-23 过期部署副本
- 位置：`improvement-proposal.md:19`、`:21`
- 原文：「必选基线组从 B1-B8 扩 B9「SP/OS 技能到达检查」+ B10「Spec 路由命中核查」」
- 证据：
  - repo 源 `skills/task-planner/scripts/sync-todos.sh:322-324` 已有 `B9=Git基线快照 / B10=Git修改后备份 / B11=Git差异分析与处置`，来自 commit `5915e78a`（`git merge-base --is-ancestor` = yes，已在 master 祖先链）。
  - repo 源 `skills/task-planner/references/todo-sync.md:35,37` 已定义 B1-B11 与 B9/B10/B11 门禁判据。
  - 部署副本 `/home/terry/.zcode/skills/task-planner/scripts/sync-todos.sh`（11-23 05:11）`grep -c B9` = 0，与 repo 源 `diff` 不一致（repo 11-24 05:59）。
- 原因：按现文实施 → 与已合并 B9-B11 语义碰撞/覆盖，或改旧部署副本造成分叉回退；B1-B11 现已带 evidence/command 字段，新增项形态也与现结构不符。
- 置信度：HIGH
- 最小修：目标改 repo 源路径；编号改 B12/B13；声明与 B9-B11 不重叠并沿用 evidence/command 结构。

## IMPORTANT

### [I-1] FILE-CHANGE 直接指向部署位而非 canonical 源（4 处）
- 位置：`:15`（plan-collab-router/skill-collaboration.md）、`:19`（sync-todos.sh）、`:21`（todo-sync.md）、`:35`（check-dispatch.sh）
- 原文：「FILE-CHANGE `/home/terry/.zcode/skills/plan-collab-router/references/skill-collaboration.md:60,68`」
- 原因：部署位是派生物，直改=drift（仓库 AGENTS.md §2）；其中 2 处部署副本已落后 repo 源（实测 DIFF）。同文件其余项却用 repo 路径，口径自相矛盾。
- 置信度：HIGH
- 最小修：全部改 `skills/...` 源路径，部署另列 redeploy 步骤。

### [I-2] H4 PATH 修复无效（目标文件已含该导出，且机制不对）
- 位置：`:27`
- 原文：「加入 `/home/terry/.npm-global/bin`，使非登录 shell 也能 `command -v openspec` 命中」
- 证据：`~/.bashrc:127` 已有 `export PATH="$HOME/.npm-global/bin:$PATH"`；probe-path.txt 在同一环境仍 `openspec_probe_rc=1`，且 `bash -lc` 亦 rc=1；grep 显示 `~/.profile/~/.bash_profile/~/.bash_login/~/.zshrc` 均无该导出。
- 原因：非交互非登录 shell 不 source .bashrc（除 BASH_ENV）；login shell 读 .profile/.bash_profile。故该改动为 no-op，H2 探针驱动点仍恒失败。
- 置信度：HIGH
- 最小修：探针内解析绝对路径（`npm config get prefix` + `/bin/openspec`）或 hook/脚本入口显式 export，并附前后实测证据。

### [I-3] H2 的 check-spec-route.sh 无调用点
- 位置：`:13-14`
- 原文：「由文本路由表落成 `scripts/check-spec-route.sh` 运行时判定脚本」
- 原因：只写"产出收据"，未写哪一处强制调用（init-session/sync-todos/hook），新脚本可长期不执行 → 仍非机器触发（评审面 #5）。
- 置信度：HIGH
- 最小修：点名调用点（建议 sync-todos.sh --json 基线组前置或 init-session.sh），未执行 fail-closed。

### [I-4] H5 门修复描述与现状重合、缺 delta
- 位置：`:35`
- 原文：「门从任务书/计划文件伴飞行提取 `.md` token 做 `-f` 存在性校验；有技能声明但无有效路径=违规（fail-closed）」
- 证据：`check-dispatch.sh:580,585` 已在伴飞行提取 .md token 并 `-f`；skip 条件 `:588`。
- 原因：前半句=现有实现；真正需改的是"如何判定存在技能声明"与 `:588` 跳过条件，现文未写 → 无 delta，可能实施成空操作。
- 置信度：HIGH
- 最小修：明确新判据（escort_skills 为空且无伴飞行=违规；escort 非空则 -f 必过）并点名 `:588`。

### [I-5] 验收口径「用于推进」无驱动点，只覆盖「到达/声明」
- 位置：`:19`（B9=SP/OS 技能到达检查）、`:35`（-f 存在性）
- 原文：「B9 未留痕=禁声称完成」
- 原因：到达（文件存在/Read）≠ 用于推进；R4 验收=被调用并用于推进；S14「调用后未承接」类未被制度覆盖，无「技能步骤产物/结论承接收据」判据。
- 置信度：HIGH
- 最小修：新增项证据定义加承接收据（技能步骤名 + 落盘产物/结论锚），门校验非空。

### [I-6] H5 漏「写入口」断链：plan-brief §F 7 列 / planctl 默认键
- 位置：`:31`
- 原文：「`s_units` 增 `escort_skills` 字段（技能 SKILL.md 路径数组），供 Rule 59.2 伴飞声明使用」
- 证据：`planctl.py:127-128` s_units 默认键 9 个无 escort；本任务 `plan-brief.md:63` S-unit 表 7 列无伴飞列（`templates/task_plan.md` 渲染侧有「伴飞技能」列，SG-13 佐证）。
- 原因：只修"存/渲染/校验"，未修"写入口" → plan-writer 无列可填，字段仍空，门仍无输入；H5 实为四处断链。
- 置信度：MEDIUM
- 最小修：加 plan-brief/plan 模板伴飞列或 plan-writer 映射登记 + planctl 默认键补 escort_skills。

## WARNING

### [W-1] H1 UserPromptSubmit 项是文本注入，非 C5 指定硬门
- 位置：`:9-10`；原文：「增「先扫描相关技能再响应」强制提示」
- 原因：事件投递文本无校验，应显式标注"辅助提示、非门"，并与 I-3 收据门配套。置信度 HIGH

### [W-2] H1 注入脚本无 FILE-CHANGE（来源/落点未定）
- 位置：`:7`；原文：「调用注入 using-superpowers 的脚本（对齐上游 `hooks.json` 的 `run-hook.cmd session-start`）」
- 原因：本地无该脚本；未定"新建脚本 vs 扩 zcode-sessionstart.sh"，实施边界不清。置信度 HIGH

### [W-3] planctl 第 8 列迁移目标二义 + 下游表头面未评估
- 位置：`:33`；原文：「parallel 组标识另迁至独立列或注释」
- 证据：`SUNIT_HEADERS`（planctl.py:1164-1166）10 列，第 9 列已为「前置依赖」；selftest SG-13 锚定表头字面。
- 原因："独立列或注释"二义；迁列需同步表头/自测/解析面。置信度 HIGH

### [W-4] 字段命名与既有词表不一致，且 config.json 有 SG-21 零键负断言
- 位置：`:31`；原文：「`s_units` 增 `escort_skills` 字段」
- 证据：`templates/subagent_dispatch.md:39` 已用 `{escort_skill_path}`；`selftest-subagent-granularity-skill-escort.sh:212` 断言 config.json 内 `escort_skill` 字面=0。
- 原因：命名应统一；若误写入 config.json 将 FAIL。置信度 MEDIUM

### [W-5] H4 落点 FILE-CHANGE 无具体项目路径 → 不可验收
- 位置：`:25`；原文：「目标项目根（实施时确定，本审计仓 C1 只读不执行）」
- 原因：无"选哪个项目根"的判据，实施后无法验收落点。置信度 HIGH

## NIT

### [N-1] check-dispatch 锚 `:580,586` 未包含真正跳过条件（`:588`），定位不精确
### [N-2] options 问题定义句「SP/OS …未被主动调用」宜加「设计层/侧证」限定（日志盲区下不可归因，勿读成已量化 0 调用）
### [N-3] 方案 C 的否决理由「加剧 H3 同构竞争」属推断，未附对照证据（可保留，但标注为判断而非取证）

## 八评审面逐条结论

1. **用户诉求覆盖**：部分通过。H1-H5 各有 ≥1 驱动点，但「用于推进」无判据（I-5）；H2 驱动点无调用点（I-3）；H4 驱动点机制无效（I-2）；H5 写入口缺失（I-6）。
2. **C2 归因**：通过。grep 全文无「执行方跳过/模型未遵守」；3 处「跳过」均指门行为（`:16` 静默跳过、`:36` 无 token 跳过）。差异口径=技能缺驱动点。
3. **C4 已否决项**：通过（独立核实，非仅看 `:41` 声明）。全文无砍委派率硬门、无主进程直做、无 planctl 降级（`:33` 是修渲染非降级）、无直改 4 个 MD 派生视图（仍以 planctl 为写者）。
4. **C5 指定形态**：形态通过、编号失守。H3 确用 sync-todos 必选基线组 + fail-closed 门，但 B9/B10 编号与已合并 B9-B11 冲突（C-1）。
5. **每项改动有驱动点**：部分通过。10 处 DRIVE-POINT 均存在，但 3 处驱动性不足：`:16`（探针无调用点）、`:28`（PATH 改动为 no-op）、`:36`（判据=现状）。无"纯文本指针冒充驱动点"的硬伤，H1 文本注入已如实写成 hook 注入。
6. **盲区与量化边界**：通过。两文档无 99/调用数表述，未把文本提及当调用证据；R-BLIND-1 未被违反（仅 NIT-2 措辞建议）。
7. **不实施边界（D-3）**：通过。options `:4`、proposal `:1,4,43` 明示"交方案待批、本轮不实施"；保护区（hook 配置 / `~/.zcode/skills/**`）标注须单独立项授权。
8. **技术可行性**：部分通过。锚点 9/10 属实（唯一偏差 N-1）；但 1 处路径族错误（I-1）、1 处机制无效（I-2）、1 处编号冲突（C-1）。H4→H2 前置链已正确声明（`:28`，无漏链）。

## 负结果（预期有问题但未发现）

- 未发现「执行方跳过/模型未遵守」类归因（C2 干净）。
- 未发现触犯 C4 四项的实质提案（`:41` 声明与正文一致，非空声明）。
- 未发现把 99 次 Skill 调用写成 SP/OS 调用或零调用（R-BLIND-1 干净）。
- 未发现把方案写成"已实施事实"（D-3 干净）。
- 未发现 SKILL 文本层被改成"复制/内联 SP/OS 内容"（与 spec-mode.md:4 R6 铁律一致）。
- 未发现 H1-H5 有整因遗漏（五因均有点位，问题在点位质量不在覆盖面）。
- 排除：`/home/terry/.zcode/skills/task-planner/scripts/check-dispatch.sh`、`planctl.py`、`plan-collab-router/references/skill-collaboration.md` 三处部署副本与 repo 源一致（diff SAME），故 I-1 的漂移风险仅集中在 sync-todos.sh / todo-sync.md 两项。

## 给主进程的下一步（最小修正）

1. C-1：改 repo 源路径 + 编号 B12/B13 + 与 B9-B11 不重叠声明。
2. I-1：全部 FILE-CHANGE 换 `skills/...` 源路径，部署单列一步。
3. I-2：H4 改"探针内绝对路径解析/hook 入口 export"，删 `~/.bashrc` 改法。
4. I-3：给 check-spec-route.sh 指认调用点（fail-closed）。
5. I-4：点名 `check-dispatch.sh:588` 跳过条件与 escort 声明判据。
6. I-5：B12 证据加"承接收据"判据（对齐 R4「用于推进」）。
7. I-6：补 plan-brief/plan 模板伴飞列 + planctl 默认键。
8. W-1~W-5 可与上并修；N-1~N-3 可顺手修。

修好后重跑 S17（或按主进程裁决以增量复审），VC-8 末轮审计 APPROVED 才可达。

---

# S17 增量复审（第 2 轮）— 修订版判定

- 复审对象：improvement-options.md（38 行）、improvement-proposal.md（51 行，标注「S17 评审后修订版」）
- 判定：**NOT APPROVED（0C / 3I / 4W / 1N）** — 原 1C 与 6I 中 4I 关闭、C-1 与 I-6 未完全关闭，另新增 2I（字段锚不全、写入口目标不成立）+ 1I（options 未同步）
- 主进程自检「旧 B9/B10 扩写残留=0」与盘上事实不符（options:14 仍有），已复现

## 关闭情况（逐条）

| 原项 | 状态 | 证据 |
|---|---|---|
| C-1 B9/B10 冲突 | **部分关闭** | proposal:22 已改 B12/B13 + canonical 源；但 options:14 仍写「从 B1-B8 扩 B9（SP/OS 技能到达检查）+ B10」，与 options:31「B1-B11 门链 / 新增项编号 B12/B13」自相矛盾 |
| I-1 部署位路径 | 关闭 | proposal:5 路径纪律 + :16/:18/:22/:24/:36/:40/:42 均 `<repo>/skills/...`（:12 相对路径见 N-1） |
| I-2 H4 PATH no-op | 关闭（proposal） | :32 明写不改 `~/.bashrc`，改探针内绝对路径；但 options:15、:37 仍写「PATH 接线」 |
| I-3 无调用点 | 关闭 | :16 指认 planctl init；`planctl.py:1950 add_cmd("init", ...)` 实测存在（措辞问题见 W-1） |
| I-4/N-1 门跳过条件 | 关闭（proposal） | :42 点名 `check-dispatch.sh:588` 并承认 :580/585 已提取；options:16 仍写 580/586 |
| I-5 用于推进 | 关闭 | :26 增「技能步骤产物承接收据」判据（覆盖 S14 调用后未承接） |
| I-6 写入口 | **未关闭** | :38 目标为 `PD/plan-brief.md`（本任务一次性产物，`grep -rl plan-brief` 在 skills/ 命中 0）且称 `templates/subagent_dispatch.md` 有「7 列表无伴飞列」——实测该模板 `:37-39` 已有「### 伴飞技能」节，其表格是 3 列知识源表；真实 canonical 模板 `templates/task_plan.md:369,387` 与 19 个 `templates/variant/*.md` 均**已有**「伴飞技能」列 |

## 新增 IMPORTANT

### [N-I-1] options.md 方案 A 要点段未同步修订，与 proposal/自身推荐结论矛盾
- 位置：`improvement-options.md:14`、`:15`、`:16`、`:37`
- 原文：「必选基线组从 B1-B8 扩 B9（SP/OS 技能到达检查）+ B10（Spec 路由命中核查）」
- 原因：同文件 `:31` 已写「B1-B11 门链 / 新增项编号 B12/B13」；`:15`/`:37` 仍是已判 no-op 的「PATH 接线」；`:16` 仍是 `580/586`。方案 A 是报告与用户要读的推荐面，保留旧编号会把已合并 B9-B11 冲突重新写回。
- 置信度：HIGH（grep 复现：options 内 `B1-B8`/`B9` 仅 :14/31 两处，:14 为残留；`PATH 接线` :15,:37；`580` :16）

### [N-I-2] H5 写入口 FILE-CHANGE 目标不成立
- 位置：`improvement-proposal.md:38`
- 原文：「FILE-CHANGE `PD/plan-brief.md` §F S-unit 表 + `templates/subagent_dispatch.md` 伴飞列：表头增「伴飞技能」列（现 7 列无此列）」
- 原因：`PD/` 是本审计任务目录（proposal:46 自证），改它对未来计划零作用，且属被审计记录；`templates/subagent_dispatch.md:37-39` 已有伴飞技能节、无 7 列表；真正承载 S-unit 列的 `templates/task_plan.md:369,387` + 19 个 `templates/variant/*.md` 已有该列 —— 该行三项事实均不成立。
- 置信度：HIGH

### [N-I-3] 新增 `escort_skills` 字段的改动锚不全，实施后 validate 必 FAIL
- 位置：`improvement-proposal.md:36`（只列 `planctl.py:127-128`）
- 原文：「`planctl.py:127-128` s_units 默认键增 `escort_skills`」
- 证据：`schemas/plan-state.schema.json:542-558` 的 `s_unit_item` 为 `additionalProperties: false` 且 properties 仅 10 键；`planctl.py:555-558` 另有一份独立硬编码 known 键清单，未知键在 `:587-591` 直接报错。
- 原因：只改默认面 → 无论是 `planctl set/add --section s_units` 还是 schema 校验都会拒绝 escort_skills；须同改 schema + known 清单（+ 渲染/SUNIT_HEADERS）。
- 置信度：HIGH

## WARNING
- [N-W-1] `:16` 「由 S15 同批新增的 planctl 检查门…或挂 UserPromptSubmit hook 调用——二选一在写作时定为「planctl init 内置调用」」：S15 只产出方案对比未新增任何门（事实错误）；"二选一"与"已定"并存，措辞自相矛盾（结论本身可行）。
- [N-W-2] `:42`「当任务书/计划声明了技能意图但 esrcs 为空时判违规」未点名"意图声明"的信号源；建议明确为读 `plan-state` 的 `s_units[].escort_skills` 非空，否则门仍无从判定。
- [N-W-3] `:40` 若为 parallel 新增第 11 列，除 SUNIT_HEADERS/selftest 外还需同步 `templates/task_plan.md:369,387` 与 19 个 `templates/variant/*.md` 的列序；更省的替代=parallel 落到既有「前置依赖」列，零列变更（建议采用）。
- [N-W-4] `:32` 以 FILE-CHANGE 形式写「不改 `~/.bashrc`」，无自身文件目标（实质是 H2 脚本重复项 + Decisions 登记）；建议降为前置依赖说明，避免 FILE-CHANGE 计数虚高（现 14 条含 1 条非文件改动）。

## NIT
- [N-N-1] `:12` 新脚本写作 `skills/task-planner/scripts/zcode-sp-inject.sh`，与同文档其余 `<repo>/skills/...` 前缀不一致，易与部署位 `/home/terry/.zcode/skills/...` 混淆。

## 复核通过项（无回归）
- C2：修订版无「执行方跳过/模型未遵守」归因。
- C4：独立再核，无砍委派率硬门/主进程直做/planctl 降级/直改 4 视图；`:48` 声明与正文一致。
- C5：B12/B13 形态正确且编号避开 B9-B11（proposal 侧）。
- R-BLIND-1：`:50` 明示未把 99 次调用写为 SP/OS 调用；options:7 已补「设计层/侧证」限定（N-2 关闭）。
- D-3：`:1/:51` 不实施 + 保护区授权要求保留。
- 计数：`(Recommended)`=1、`^FILE-CHANGE`=14、`DRIVE-POINT`=15（grep 实测与自检一致）；38/51 行 ≤100（C8 文档粒度）。

## 复审结论与最小修正

修 3 项 I 即可达 0C/0I：①同步 options:14/:15/:16/:37 到修订版结论；②:38 写入口目标改为「planctl known 键 + schema + plan-writer 填列义务」，删 `PD/plan-brief.md` 与 `subagent_dispatch` 7 列表表述；③:36 补 schema:542-558 与 planctl:555-558 两个锚。W/N 同批顺手改更佳。修后跑 VC-8 与一次增量复审即可推进 P7。

---

# S17 增量复审（第 3 轮）— 主进程声称修复的后验证

- 复审对象：improvement-options.md（38 行）、improvement-proposal.md（51 行，「S17 评审后修订版」）
- 判据：plan-brief.md §D C1-C8 / §F S17 行（APPROVED=0C/0I）、verification.md:23 VC-8、plan-state.json root_causes H1-H5 与 audits
- 判定：**NOT APPROVED（0C / 1I / 6W / 5N）** — 第 2 轮 3 项 I 中 N-I-1、N-I-3 关闭，N-I-2 仅「删旧目标」未「立新目标」（新指向文件不存在），W/N 同批 5 项全部关闭
- 只读评审：仅追加本 checkpoint 与 T/writes.txt；未改评审对象、未 git 操作

## 3 项 I 关闭状态（逐条盘上实证）

| 原项 | 状态 | 盘上证据 |
|---|---|---|
| N-I-1 options 未同步 | **关闭** | :14 已为「从 B1-B11 扩 **B12**…+ **B13**…避开已合并的 B9-B11（commit 5915e78a）」；:15 已改「探针内用绝对路径解析（**不改 `~/.bashrc`**…属 no-op）」，不再写 PATH 接线；:16 已改 `check-dispatch.sh:588` 并声明「28 个 variant 本已有『伴飞技能』列…不在模板缺列」；:37 已改「PATH 改动已按 S17 判为 no-op 剔除」 |
| N-I-2 写入口目标不成立 | **未关闭（部分）** | 已删 `PD/plan-brief.md` 与「7 列无伴飞列」表述（:38 原文「`PD/plan-brief.md` 是本审计一次性目录、改它对未来计划零作用，剔除」）——但新目标 `skills/task-planner/references/plan-writer.md` **不存在**（`ls` ENOENT），见 [I-1] |
| N-I-3 字段锚不全 | **关闭** | :36 三锚全部实测属实：`schemas/plan-state.schema.json:542-558`（s_unit_item，`additionalProperties:false`，properties 恰 10 键 id…parallel）、`planctl.py:555-558`（known.update s_units 9 键）、`planctl.py:591`（`errs.append(f"{where}: 未知字段…）`，:589-590 为其注释，:587-591 覆盖成立）；另查 `validate_state` 无第二份 s_units 白名单、selftest 无 s_unit_item 键数断言，故锚已足 |

W/N 同批 5 项：:40 parallel 改落「前置依赖」列（机制可行：check-plan-dispatch.sh:499-500 从整行 `match($0,/\[parallel-group:[^]]+\]/)` 提取行内标记，rule68_expand_deps:449-465 对非 ID token 不做 H4 误判）、:42 已点名 `s_units[].escort_skills` 非空为意图信号、:12 已 `<repo>/` 前缀、:32 已降为 DECISION-REGISTER（全文 `^FILE-CHANGE` 计数 14→13 印证）、options:37 歧义行已改写——**5/5 关闭**。

## CRITICAL：无

## IMPORTANT

### [I-1] H5 写入口 FILE-CHANGE 指向不存在的文件，写入口断链仍未修（N-I-2 实质未关闭）
- 位置：`improvement-proposal.md:38`
- 原文：「FILE-CHANGE `<repo>/skills/task-planner/references/plan-writer.md`（N-I-2 修正：写入口目标改为「plan-writer 填列义务」…」
- 证据：
  - `ls /mnt/data/dev/task-planner-skill/skills/task-planner/references/plan-writer.md` → No such file or directory；references/ 实有 8 个文件（completion-gate/goal-gate/critical-rules/methodology/spec-mode/todo-sync/worktree-isolation/longform-continuity-methodology），无 plan-writer.md。
  - 真正承载 plan-writer 撰写义务的是 `skills/task-planner/companion/agents/plan-writer.md`（存在，31 行 frontmatter + 「## 掌握的技能」节）；对其 `grep -n "伴飞\|escort"` = **0 命中**，S-unit 列义务确实缺失。
  - 全仓 `grep -rn "references/plan-writer" skills/` = 0 命中（仅本 proposal 自身），即新指向的文件即使新建也无人加载（非 `new` 标记，与 :12 显式写 `FILE-CHANGE new` 的体例不一致）。
- 原因：实施者按行读会遭遇 ENOENT；若自行新建该 references 文件，则义务落在一个没有任何 agent/脚本读取的孤儿文档里，plan-writer 填列义务仍不生效 → N-I-2 的实质（写入口无载体）未闭环。
- 置信度：HIGH
- 最小修：`:38` 目标改为 `<repo>/skills/task-planner/companion/agents/plan-writer.md`，「## 掌握的技能」节增一条「S-unit 表『伴飞技能』列填 `escort_skills` 绝对路径（非空即门有输入）」（可选同步 `<repo>/skills/task-planner/SKILL.md` 模板节指针）；若坚持新建 references 文件，须行首标 `new` 并在上述 agent 定义的技能清单加读取指针，否则视为孤儿文件。

## WARNING

### [W-1] 同一文档内 variant 计数自相矛盾（28 与 19），且总数与盘上不符
- 位置：`improvement-proposal.md:38`、`:40`
- 原文：「28 个 `templates/variant/*.md` **本已含「伴飞技能」列**」／「无需动 SUNIT_HEADERS/19 个 variant」
- 证据：`ls skills/task-planner/templates/variant/*.md | wc -l` = **31**；`grep -l "伴飞技能"` = **28**；缺列 3 个=mini-lite-type.md / l0-lite-type.md / longform-continuity-type.md（且这 3 个 `grep "S-unit\|前置依赖"` = 0，属无 S-unit 表的轻量类型，无需列）。
- 原因：:38 的「28 个」实为「含列数」却写成 variant 全集口径，:40 又写「19 个」，两处数与实态均不一致；实施时按 19 个核对会漏检 12 个模板。
- 置信度：HIGH
- 最小修：统一写「31 个 `templates/variant/*.md`，其中 28 个已有『伴飞技能』列，3 个轻量类型（mini-lite/l0-lite/longform-continuity）无 S-unit 表」，:40 的 19 改为 31。

### [W-2] H2 调用点与声明的输入不匹配：`planctl init` 时点拿不到「需求特征」，收据将空判
- 位置：`improvement-proposal.md:16`
- 原文：「运行时判定（输入=计划 tier/需求特征，输出=应路由技能族）…定为在 planctl `init` 子命令内置调用该脚本」
- 证据：`planctl.py:780-808 cmd_init` 仅消费 `args.task_id / args.tier / args.lane / args.template_body_from / args.force`；`init-session.sh:1112` 在 `planctl init` 时传入的是「已渲染的 task_plan.md **模板正文原文**」（占位符态），需求内容此时尚未产出。
- 原因：init 时点无需求特征可判 → 路由收据只能是空/恒过，驱动点形式存在但无实质判定；且该项与 H3 的 B13「Spec 路由命中核查」职能重叠，易出现两处各判一半。
- 置信度：HIGH
- 最小修：调用点后移（如首个 `planctl render` 或 `check-plan-dispatch.sh` 计划门），或明确写「init 仅按 tier 粗筛，需求特征判定由 B13 基线组承担」，避免空判收据。

### [W-3] H1 新增 hook 脚本缺「部署位同步」步骤，hook 命令指向部署位路径
- 位置：`improvement-proposal.md:8`、`:12`
- 原文：「新增一条 hook 调用独立脚本 `zcode-sp-inject.sh`」／「FILE-CHANGE new `<repo>/skills/task-planner/scripts/zcode-sp-inject.sh`」
- 证据：`/home/terry/.zcode/cli/config.json:34` 现 command = `bash /home/terry/.zcode/skills/task-planner/scripts/zcode-sessionstart.sh`（部署位绝对路径）；repo 源同脚本与部署位是两份。
- 原因：新脚本只落 canonical 源，若不同步部署位，SessionStart 调用的路径不存在 → 入口注入在首次会话即失败；proposal 未列 redeploy（install.sh + verify.sh）步骤。
- 置信度：HIGH
- 最小修：H1 增一行「部署位同步：`bash skills/task-planner/install.sh --no-backup` + `TASK_PLANNER_ROOT=… lib/verify.sh`，逐位 diff 判向」，并注明 hook 仍指部署位路径。

### [W-4] canonical 产物内硬编码个人 home 绝对路径（可移植性残留）
- 位置：`improvement-options.md:15`、`improvement-proposal.md:18`、`:32`
- 原文：「直接用绝对路径解析 openspec（`/home/terry/.npm-global/bin/openspec --version`）」
- 代价：canonical 脚本会被安装到多工具部署位（§2 派生物体系），硬编码 `/home/terry` 在换机/换用户后必失效，且与「canonical 为唯一权威源」定位冲突。
- 说明：非回溯第 1 轮 I-2（no-op 判定已关闭），仅为实施前的可移植性提示，非阻断。
- 置信度：MEDIUM
- 最小修：探针改为「`$(npm config get prefix)/bin/openspec` 优先 → `command -v openspec` → 观测到的绝对路径兜底」三档，绝对路径仅作已知状态记录。

### [W-5] 权威源 root_causes[H4].fix 仍写已被判 no-op 的「PATH 接线」，与修订版方案互斥
- 位置：`plan-state.json` → `root_causes[H4].fix`（经 planctl 渲染会进 task_plan.md / 交付面）
- 原文：「补项目根 openspec/ 初始化前置与代理执行环境 PATH 接线；须经独立评审与用户批准，本轮不实施。」
- 证据：options:15 与 proposal:32 均已明写「不改 `~/.bashrc`…属 no-op」「PATH 改动已按 S17 判为 no-op 剔除」。
- 原因：两文档已纠正、权威状态未纠正 → 渲染出的交付文档会把已否决的 no-op 修复重新写回用户视野（A 类事实回写），评审面与交付面口径分裂。
- 置信度：HIGH
- 最小修：主进程用 `planctl` 更新 `root_causes[H4].fix` 为「探针内绝对路径解析 + 不改 .bashrc（no-op 已排除）」并 `render`；属 planctl 写入口，非本 critic 可写。

### [W-6] VC-8 当前 rc=0 由上一阶段（P5 根因审计）的 APPROVED 审计项支撑，不构成本轮认证
- 位置：`plan-state.json` → `audits[3]`
- 原文：`{'round': 4, 'verdict': 'APPROVED', 'by': 'critic(opus-1)', 'counts': {...}, 'issues': [{'key':'W-R4W1','title':'重复 A2 已删除'}, …]}`
- 证据：audits 共 4 条（round1 REJECTED、round2 REJECTED、round3/4 APPROVED），条目内容为根因/VC 系列的 W-R4W1/W-R4W2，非 S17 方案评审；VC-8 判据直接取 `.audits[-1].verdict`（verification.md:23）。
- 原因：在未追加本轮记录前，`.audits[-1]` 恒为旧 APPROVED → VC-8 对该门是空过；主进程以「rc=0」汇报存在把旧结论当本轮结论的风险。
- 置信度：HIGH
- 最小修：本轮结论须由主进程 append 新 audit（round=5，verdict=实测 NOT APPROVED，issues=本清单键），再跑 VC-8；届时 rc≠0 属正确行为，不得为过门而预填 APPROVED。

## NIT

- [N-1] `improvement-options.md:16` 只引 `templates/task_plan.md:369`，proposal:38 为 `:369,387`；两行均实存，建议 options 补 `,387` 保持同源锚一致。
- [N-2] `improvement-proposal.md:36`「`s_units` 默认键增 `escort_skills`」未定字段类型：schema `s_unit_item.properties` 全为 string，planctl known 侧有 `STR_FIELD`/`STR_LIST_FIELD` 两型（phase_gates.depends 用列表）；建议明写「单路径=string，多技能=array[string]」以免实施侧选错谓词。
- [N-3] `improvement-proposal.md:4`「本版修正依据：S17 critic NOT APPROVED（1C/6I/5W/3N）」只记第 1 轮计数，未记第 2 轮（0C/3I/4W/1N）；正文内联 `N-I-2/N-I-3 修正` 已覆盖，属版本头信息不全。
- [N-4] `improvement-proposal.md:16`「文本路由表落成 `scripts/check-spec-route.sh`」未声明单一事实源；建议加一句「`spec-mode.md` §1 表=契约面，脚本=派生实现，冲突以表为准」，防双源漂移（对齐 Rule 34.2 同步纪律）。
- [N-5] `improvement-proposal.md:40` 未注明 `s_units` 无 depends 字段、渲染侧「前置依赖」列当前恒输出 `-`（`planctl.py:1271` 同一行的 `"-"` 字面量）；实施时须由 `parallel` 合成 `[parallel-group:<组名>]` 注入该单元格，否则渲染会丢掉组标记并触发 check-plan-dispatch H3（声明组无成员标记）。

## C1-C8 / 硬约束再核（正文实证，非仅看文末声明）

- **C1 只读**：两文档均为待批清单，无实施动作；本轮我只写 checkpoint + writes.txt。
- **C2 归因**：`grep 执行方|模型未遵守|未遵守` 仅命中 proposal:47 的合规否定句；全文 5 处「跳过」全指门行为（:19 静默跳过、:42/:43 无 token 跳过、options:16 跳过条件）——**无回归**。
- **C3 一手全量**：本轮未新引日志统计；options:7 保留「日志盲区/非日志调用数」限定。
- **C4 已否决项**：独立核实无砍委派率硬门、无主进程直做、无 planctl 降级（:40 是修渲染，:46 仍以 planctl 为派生视图唯一写者）、无直改 4 个 MD 视图——**无回归**。
- **C5 形态**：B12/B13 = sync-todos.sh 必选基线组成员（:22）+ todo-sync.md 门禁（:24/:26 fail-closed）+ 承接收据判据，符合「必须每次发生→基线组+脚本驱动」——无回归。
- **R-BLIND-1**：无 99 次调用被写成 SP/OS 调用或零调用（仅 :50 否定句）；无文本提及当调用证据；options:7 保留「设计层/侧证」限定——无回归。
- **D-3 不实施**：options:4、proposal:1/:51 明示待批不实施，保护区改动要求单独立项授权——无回归。
- **C8 粒度**：options 38 行、proposal 51 行，均远小于文档阈值。
- **VC-8 计数**：`(Recommended)`=1、`^FILE-CHANGE`=13、`DRIVE-POINT`=15（grep 实测与主进程声称一致）；但见 [W-6] audits 口径问题。

## 负结果（预期有问题但未发现 / 排除的可能性）

- 未发现新引入的 C4 触犯项或 C2 归因违规（含新增的 :26 承接收据表述，仍属「缺判据」而非「执行方过失」）。
- 未发现「把 no-op 或已否决项写回文档正文」：options:15/:37、proposal:18/:32 一致剔除 .bashrc 改法（回写仅存于 plan-state，见 W-5）。
- 未发现 :40 的「parallel 落前置依赖列」会破坏机器门：check-plan-dispatch.sh:499-500 用整行正则取行内标记，:449-465 依赖展开对 `[parallel-group:…]` token 不做同组冲突误判（排除「零列变更不可行」假设）。
- 未发现 N-I-3 之后仍有第三份 s_units 键白名单：`validate_state` 无独立 s_units 清单，selftest 无 `s_unit_item`/键数断言（排除「实施后仍会三处被拒」的扩大化判断）。
- 未发现 B12/B13 与已合并 B9-B11 的语义碰撞：`sync-todos.sh:322-324` 仅 B9/B10/B11 三条 Git 基线，B12/B13 编号空位成立（`git merge-base --is-ancestor 5915e78a HEAD` = YES 复核通过）。
- 未发现引用锚失效：config.json:29-40（SessionStart 单条）/ :69（UserPromptSubmit）、spec-mode.md:6、skill-collaboration.md:60,68、sync-todos.sh:303、todo-sync.md:35,37、planctl.py:1271/:1950/:555-558/:591、check-dispatch.sh:588、task_plan.md:369,387、subagent_dispatch.md:37-39 全部逐一命中。
- 排除：`skills/task-planner/scripts/` 下无 `check-spec-route.sh` 同名冲突（新脚本命名可落）。

## 验证摘要

- 总发现：12（0C / 1I / 6W / 5N）
- 已验证：12（每条均附 Read/grep/ls 现场输出复现）
- 通过率：100%
- 8 处「已并入」锚点复核：config.json×2、planctl×4、check-dispatch×1、schema×1、sync-todos/todo-sync×3、template×3、skill-collaboration/spec-mode×3 — 全部属实

## 结论与最小修正（1 处 I 即可推进）

修 `improvement-proposal.md:38` 一处（目标改为 `skills/task-planner/companion/agents/plan-writer.md`，或在新建时标 `new` + agent 技能清单加指针）即可达 0C/0I；W-1~W-4 建议同批顺手（纯文档 4 行内改动），W-5 需主进程经 planctl 更新 root_causes[H4].fix，W-6 需本轮 verdict 落 audits 后重跑 VC-8。修后跑一次增量复审（第 4 轮）即可推进 P7。

---

# S17 第4轮 + S20 报告面终审

- 评审体：critic(opus-1) / 2026-11-24 / 只读（仅追加本 checkpoint + T/writes.txt 一行；未改被审对象与任何受管文件，无 git 操作）
- 范围：(A) S17 第4轮增量复审（验第3轮 1I/6W/5N 是否真闭环）；(B) S20 报告面简版独立审计（round=5，5 份交付文件逐份 verdict）
- 判据：plan-brief §D C1-C8 / §F S17·S20 行、verification.md:16 VC-1 / :23 VC-8、plan-state root_causes H1-H5 / audits[] / D-18
- **总判定：NOT APPROVED（0C / 1I / 1W / 1N）** — (A) S17 修复全部闭环（6W+5N 关闭、I-1 关闭、W-6 待本轮 verdict）；(B) REPORT.md 关键数字「无 8 / 仅提及 4」与盘上两份 gap 源报告不符（貌似 无/仅提及 互换），构成 1 IMPORTANT。

## (A) S17 第4轮 — 逐条闭环状态（盘上实证）

| 项 | 状态 | 盘上证据 |
|---|---|---|
| I-1 H5 写入口 | 关闭 | proposal:39 目标=companion/agents/plan-writer.md；`ls` 实存(21076B)、`sed :37`「## 掌握的技能」、`grep 伴飞\|escort`=0（真实缺口）、全仓 `grep references/plan-writer`=0 |
| W-1 variant 计数 | 关闭 | 盘上 variant=31、含「伴飞技能」列=28、缺列 3=l0-lite/mini-lite/longform-continuity；proposal:40/:42 与 options:17 三处均 31/28/3，一致 |
| W-2 H2 调用点两级 | 关闭 | proposal:17 cmd_init(planctl.py:780-808) 仅消费 task_id/tier/lane/template_body_from/force（sed 实证无需求特征）、需求特征级后移 B13、与 B13 分级互补不重叠 |
| W-3 部署同步 | 关闭 | proposal:13 install.sh+lib/verify.sh 部署与对账；config.json:34 实证 command=`bash /home/terry/.zcode/skills/task-planner/scripts/zcode-sessionstart.sh`（部署位）→ 仅落 canonical 会 ENOENT |
| W-4 可移植链 | 关闭 | proposal:19/:33、options:16 均「npm config get prefix)/bin/openspec → command -v → 观测兜底」；唯一 /home/terry/.npm-global/bin/openspec 命中为否定句「不硬编码」 |
| W-5 root_causes H4.fix | 关闭 | plan-state root_causes[H4].fix=「探针内按可移植链解析…不硬编码绝对路径、不改 ~/.bashrc（:127 已有 export 但 probe rc=1=no-op）」；全文无「PATH 接线」 |
| W-6 verdict/audits | 待本轮→未闭合 | audits[-1] 仍=round4 APPROVED（旧 P5 审计，W-6 空过）；本轮 verdict=NOT APPROVED → 主进程须先修 8/4 再复跑重审，禁预填 |
| NIT-1 :387 锚 | 关闭 | options:17 含「templates/task_plan.md:369,387」 |
| NIT-2 STR_LIST_FIELD | 关闭 | proposal:37「类型定为字符串数组（planctl.py:162 STR_LIST_FIELD）」 |
| NIT-3 R2/R3 计数 | 关闭 | options:5「R1 1C/6I/5W/3N、R2 0C/3I/4W/1N、R3 0C/1I/6W/5N」 |
| NIT-4 spec-mode§1 单一事实源 | 关闭 | proposal:17「spec-mode.md §1 文本路由表为该脚本判定的唯一事实源」 |
| NIT-5 depends/前置依赖恒渲 - | 关闭 | proposal:42「s_units 当前无 depends 字段、『前置依赖』列由 :1271 同行恒渲 -」 |

结论：(A) 第3轮 1I/6W/5N 全部真闭环（12/12 盘上复现），无回归；唯 W-6 因本轮发现新 I 而由主进程后续闭环。

## (B) S20 五份文件逐份结论

1. **improvement-proposal.md**（53 行）— PASS。(A) 项全闭；C2/C4/C5/R-BLIND-1/D-3 合规（独立 grep：C2 仅否定句、C4 仅否定声明、R-BLIND-1:52 否定句、无「已实施」）。
2. **improvement-options.md**（39 行）— PASS。推荐 A；(Recommended)=1；variant 31 一致；H4 不改 .bashrc+可移植链；C4:32 否定声明。
3. **REPORT.md**（45 行）— **FAIL（1 IMPORTANT）**：关键数字「无 8 / 仅提及 4」与盘上不符（见 I-1）；另 NIT（writes 45→49）。
4. **report-rootcause-1.md**（49 行）— PASS。H1-H3 CONFIRMED、≥2 锚、C2 净、R-BLIND-1:39 净。
5. **report-rootcause-2.md**（45 行）— PASS（1 WARNING）。H4/H5 CONFIRMED 扎实；仅 H4「PATH 接线」措辞较修订后口径略粗（见 W-1）。

## IMPORTANT

### [I-1] REPORT 关键数字「无 8 / 仅提及 4」与两份 gap 源报告不符（貌似 无/仅提及 互换）
- 位置：REPORT.md:8（§一.2）、REPORT.md:22（§三 关键数字表）
- 原文：「12 个应发生时点（入口 7 + 执行收口 5）全数缺驱动门——8 个「无」、4 个「仅提及」、0 个有真实驱动点」／「驱动时点缺口 | 12 个（无 8 / 仅提及 4 / 有驱动 0）」
- 盘上源（S5/S6 产物，应被忠实汇总）：
  - report-driver-gap-1.md:26「驱动 0 条 / 仅提及 4 条（GAP-2/4/5/7）/ 无 3 条（GAP-1/3/6）」（7 时点）
  - report-driver-gap-2.md：DG-1 Phase 开启=仅提及、DG-2 派发前伴飞=无、DG-3 执行中=仅提及、DG-4 完成声称前=仅提及、DG-5 收口归档=部分驱动不覆盖 SP/OS（5 时点）
- 12 时点真实合计：无=3+1=4；仅提及=4+3=7（+收口 1 处「部分驱动不覆盖 SP/OS」，3 桶口径下并入仅提及=8）；有真实 SP/OS 驱动=0。
- 原因：REPORT 的「无 8 / 仅提及 4」在任一自洽定义下都无法由两源复现（gap-1 GAP-2 与 gap-2 DG-1 同引 using-superpowers SKILL.md 自述文本，却一处计仅提及、一处计无，互斥）；数值恰为「无 4 / 仅提及 8」的互换。同错亦见 T/drift-check.md:94（非 5 文件范围，修时一并对齐）。
- 影响：交付报告「结论先行+关键数字」对用户呈现错误拆分（8 vs 4 倒置），违 S20「数字须与盘上一致」；顶层结论（12 缺、0 真驱动）不变。
- 置信度：HIGH
- 最小修：REPORT.md:8/:22 改为「无 4 / 仅提及 8（含收口 1 处仅自家部分驱动）/ 有真实 SP/OS 驱动 0」（或 4 桶：无 4/仅提及 7/部分驱动 1/有 0）；对齐 drift-check.md:94；改后复述句与 VC-2/VC-6 不受影响。

## WARNING

### [W-1] report-rootcause-2.md 的 H4 fix 方向仍写「PATH 接线」，与修订后「不改 .bashrc、可移植链解析」口径略粗
- 位置：report-rootcause-2.md:45（另 :17/:43 为 gap 描述，准确，无需改）
- 原文：「H4=落点初始化 + 代理 PATH 接线驱动点」
- 证据：plan-state root_causes[H4].fix、options:16、proposal:19/:33、REPORT:33 均已改「不改 ~/.bashrc / 探针内可移植链解析 / no-op 已排除」。
- 原因：文件 5 是交付件，单读 :45 的「PATH 接线」易被读回已否决的 .bashrc 改法；非硬矛盾（同目标=代理环境 CLI 可达），但措辞落后修订节奏。
- 置信度：MEDIUM
- 最小修：:45「代理 PATH 接线驱动点」→「代理环境 CLI 可达（探针内可移植链解析，不改 .bashrc）」；:17/:43 作为 gap 描述保留（准确，勿动 process 字数）。

## NIT

### [N-1] REPORT.md:26「writes.txt 45 行」为写报告时快照，盘上现 49 行
- 位置：REPORT.md:26；原文「0（writes.txt 45 行全在 PD/T 内）」
- 说明：writes.txt 随审阅轮次增长（现 49，VC-9 质量属性「全在 PD/T」仍成立、越界=0）；建议改为不含硬编码计数或注明「截至报告撰写」。

## C2/C4/C5/R-BLIND-1/D-3 再核（五文件正文实证）

- C2：grep 执行方跳过/模型未遵守/偷懒 → 全部为否定/约束句（REPORT:9「无一条可归因…」、rootcause:4 口径声明、proposal:49）；无正归因。✓
- C4（已否决 4 项）：仅命中否定声明（options:32、proposal:50、rootcause-2:45 边界）；无砍委派率硬门/主进程直做/planctl 降级/直改 4 MD 视图之实提案；proposal planctl:1271=修渲染非降级。✓
- C5：B12/B13=sync-todos 必选基线组（proposal:23）+ todo-sync 门禁（:25/:26 fail-closed）+ 承接收据（:27），符合「必须每次发生→基线组+门」。✓
- R-BLIND-1：99 全部为「既不能证 99 次调用/也不能证零调用」否定句（REPORT:7/:13/:23、rootcause-1:39、rootcause-2:34、proposal:52）；无文本提及当调用证据。✓
- D-3：五文件均「待批/不实施」；grep 无「已实施/已修复」。✓
- 窗口/盲区：REPORT:13 窗口 11-18..24、:14 R-BLIND-1 盲区声明在位。✓

## 验证摘要
- 总发现：3（0C / 1I / 1W / 1N）
- 已验证：3（均 Read/grep/jq 盘上复现）
- 通过率：100%
- 抽验锚点：config.json:34、planctl.py:127-128/162/780-808、plan-writer.md:37、variant 31/28/3、scan-stats raw.skill_calls_total=99/parse_bad=0/rel_diff=0、files 行合计 1184652、report-plans.txt:49-50、OpenSpec legacy 9 产物、root_causes[H4].fix、audits[-1]=round4 —— 全部属实；唯一不符=REPORT 8/4（I-1）。

## 负结果（检查过但未发现）
- (A) S17 六项 W 修复无一项为「声称已改但盘上未改」。
- 五文件无 C2 正归因、无 C4 实提案、无「99 次=SP/OS 调用/零调用」、无「已实施」。
- 排除：REPORT/options/proposal 三处 H4 口径已一致（均不改 .bashrc+可移植链），H4 矛盾仅存于报告 5 的措辞（W-1）。
- 排除 8/4 有其它来源：design-sp/os 无时点分类汇总；8/4 仅见 REPORT.md + drift-check.md:94，均为主进程汇总而非 S5/S6 证据。

## 结论
NOT APPROVED（0C/1I/1W/1N）。**A 面（S17 第4轮）实质全闭环**；阻断项唯一=REPORT.md:8/:22 关键数字 8/4 倒置（I-1）。修 I-1（+顺手 W-1/N-1）后复跑增量复审，0C/0I 时再由主进程 append audits round=5 APPROVED + `[audit-before-delivery]` 留痕并复跑 VC-1/VC-8（W-6 届时闭合）。

---

# S20 I-1 修订复审

- 评审体：critic(opus-1) / 2026-11-24 / 只读（仅追加本段 + T/writes.txt 一行；未改被审文件、无 git）
- 范围：聚焦复核上轮 S20 的 1I（I-1）+ 1W（W-1）+ 1N（N-1）+ drift-check:94，四项修正
- **判定：APPROVED（0C / 0I）** — 四项全部正确关闭，无回归

| 项 | 状态 | 盘上证据 |
|---|---|---|
| I-1 | ✅关闭 | REPORT.md:8 现「4 个『无』（gap-1 GAP-1/3/6 + gap-2 DG-2）、8 个『仅文本提及』（gap-1 GAP-2/4/5/7 + gap-2 DG-1/3/4 + DG-5 收口仅自家部分驱动、不覆盖 SP/OS）、0 个 SP/OS 真驱动」；:22 表「无 4 / 仅提及 8〔含收口 1 处仅自家部分驱动〕/ 真驱动 0」+ 锚 gap-1:26、gap-2:12/19/30/37/44。对照源：gap-1:26「无3/仅提及4」+ gap-2 五时点（仅提及3/无1/部分1）→ 合计 无4 / 仅提及7+部分1=8 / 真0，完全一致；顶层「12 全缺 SP/OS 真驱动门」不变 |
| N-1 | ✅关闭 | REPORT.md:26 现「writes.txt 全在 PD/T 内，行数见实时台账」；全文无 writes 硬编码计数（唯一「1,184,652 行」为日志行数，合法保留） |
| W-1 | ✅关闭 | report-rootcause-2.md:45 现「H4=落点初始化 + 代理环境 CLI 可达〔可移植链解析，不改 ~/.bashrc〕」，与 root_causes[H4].fix / options:16 / proposal:33 / REPORT:33 口径一致（均 不改 .bashrc + 可移植链） |
| drift:94 | ✅关闭 | drift-check.md:94 改「无4+仅提及8〔含收口1处…〕+SP/OS真驱动0」+「原无8/仅提及4为倒置」纠正注；新增 :101「## S20 终审 I-1 修订留痕（2026-11-24）」段，列四处修正 |

- 残留核查（全 PD+T）：无「无8/仅提及4」活值残留。命中项均合法——①`5-quality-auditor.md:16`、`recheck-notes.md:9` 的「仅提及4/无3」是 S5 **七时点单表**自有口径（非 12 合计）；②本条 checkpoint 上轮历史记录；③`drift-check.md:94/102` 的「原…倒置」纠正注。
- REPORT.md 45 行 ≤100；顶层结论、SP16/OS11、收据 0/1、99 不可归因、rel_diff=0、1184652 均保持。
- 验证摘要：4/4 已验证，通过率 100%。

## 结论
**APPROVED（0C / 0I）**。四项修正盘上实证全部正确关闭，无新增问题。主进程可 append `audits round=5 verdict=APPROVED` + `[audit-before-delivery]` 行动留痕，并复跑 VC-1/VC-8（W-6 届时闭合）。
