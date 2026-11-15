# review-s7 — Spec 模式集成 独立复检（critic，只读）

对象：`tmp/worktrees/task-specmode-integration-20261115`（wt/task-specmode-integration-20261115，基点 master@a7f3faf）。复检时间 2026-11-15。
方法：`git diff master` 全量 + spec-mode.md 全文 + 官方 README 逐字核 + 机器判据实跑；不采信实现者自评。

## 0. 变更集事实（实测）
- `git status --short` = 恰好 4 项：M CHANGELOG.md / M skills/task-planner/SKILL.md / M skills/task-planner/scripts/selftest-batch-pilot.sh / ?? skills/task-planner/references/spec-mode.md —— 无计划外文件。
- SKILL.md 283(master) → 286(wt)；`bash selftest-batch-pilot.sh` 实跑 **10 PASS / 0 FAIL（BP-08 PASS 286≤286）**。
- grep 判据：spec-mode.md 四短语命中 5；SKILL.md 三关键词各 1（合计 3）。

## 1. R1-R6 判定
| 需求 | 判定 | 条款落点（file:line） | 一句理由 |
|---|---|---|---|
| R1 目标偏移→Spec 模式 | covered | spec-mode.md:3,7；SKILL.md:54 | 明确「整理阶段=偏移高发区」并给出触发条件与路由 |
| R2 Superpowers 显性接入 | covered（窄） | spec-mode.md:12,21；SKILL.md:54 | 仅路由 brainstorming 一个成员（writing-plans 仅交叉引用），与族内其余 9 成员分工未声明边界 |
| R3 OpenSpec 引入执行过程 | covered | spec-mode.md:13,14,15,23 | propose/explore/apply/verify + init 四段齐全，覆盖「执行过程」而非仅提案 |
| R4 记录者+调度者 | **partial** | spec-mode.md:10(表列),16,29,31,36；SKILL.md:60 | 记录者义务有可执行列与前置门，但 ① 无机器判据（attest-plan.sh 对 spec/收据 grep 零命中，无新增 selftest）② :16 把「实施计划」留在 planner 自有流，与用户原话「将**任务计划**…交给他们」相左（D3） |
| R5 安装引导（命令+来源+免门边界） | covered | spec-mode.md:18-25 | 三条命令与官方 README 逐字一致（已复核）；:25③ 明写「免用户门仅及安装/初始化，其他不可逆动作仍走既有门」——边界清晰；缺陷=Superpowers 行只有 Claude 生态路径（D5） |
| R6 禁止复制 | partial | spec-mode.md:4（铁律）,28（反模式） | 仅负面清单，无机器可判据（无 grep/selftest 断言本仓不含两族技能正文，也无体量/结构上限） |

## 2. 缺陷清单
- **D1** [WARNING] 双权威路由表未分主次：`skill-collaboration.md:53`「判定顺序敏感、先命中先用（重→轻）：comet → OpenSpec → superpowers」，而 `spec-mode.md:7-8`「L1+ 命中即走」无 comet 优先级；同时 `SKILL.md:254` 仍宣称该文件是「专业技能协同（comet/OpenSpec/superpowers）权威源」，`SKILL.md:255` 又把同三族路由指向 spec-mode.md。→ 建议 spec-mode.md:34 与 SKILL.md:255 各加一句「总表/细分层」主次说明，并声明 comet 优先不变。置信度 HIGH。
- **D2** [WARNING] 同文件自相矛盾：`spec-mode.md:13` 硬编码产物路径 `openspec/changes/<name>/`，而 `:37` 自述「禁硬编码猜测，用 planningHome/changeRoot/artifactPaths 动态解析」；`comet-open/SKILL.md:123` 更指出 classic runtime 不支持仓库外 change root。→ :13 改为「路径以 `openspec status --change <name> --json` 的 changeRoot 为准」。置信度 HIGH。
- **D3** [IMPORTANT] 交接点指令互斥（直接决定 R4）：`spec-mode.md:16`「规格获批→实施计划：task-planner 自有计划流（可交叉引用 writing-plans）」vs `brainstorming/SKILL.md:62,132`「The ONLY skill you invoke after brainstorming is **writing-plans**. Do NOT invoke any other skill」。→ 需二分声明：writing-plans 产出实现计划 vs task_plan.md 仅承载门控/VC，planner 不重写其内容。置信度 HIGH。
- **D4** [WARNING] BP-08 钉值零边距：`selftest-batch-pilot.sh` `if [ "$lines" -le 286 ]` 恰等于实值 286，与本文件演进口径（275=250+25；2026-11-05 实值 280→285=+5）背离 → 行数回归钉退化为等值断言，下次 +1 行即 FAIL。置信度 HIGH。
- **D5** [WARNING] 安装引导生态覆盖不全：`:21` 仅给 Claude Code `/plugin marketplace add` + `/plugin install` 两条 slash 命令（另两行是可直接 bash 执行的 npm/curl）；当前运行生态为 ZCode（技能位于 `~/.zcode/skills`、`~/.agents/skills`），无对应安装路径，R5「免门安装」在该行可能不可执行并落入 Rule 97 判词门。→ 补 ZCode 路径或注明适用生态。置信度 MEDIUM（未实测 `/plugin` 是否可用）。
- **D6** [WARNING] 历史留痕被就地改写：该脚本把 2026-11-05 条目「上限 275→285」改写成「275→286」（header 与内联注释两处），使历史行谎称当时即到 286；文件自身惯例是追加新日期条目。→ 追加 `[2026-11-15 task-specmode-integration-20261115] +3 行, 285→286`，保留原行。置信度 HIGH。
- **D7** [WARNING] 引用清单漏登记：`SKILL.md:7-15` 的 frontmatter `references:` 逐条登记 6 个本地 reference（含 reference.md/examples.md），新增 `references/spec-mode.md` 未入册；且 scripts 内无清单守护（grep 零命中），机器不会发现。置信度 HIGH。
- **D8** [NIT] BP-08 header 摘要仍写「BP-08 SKILL.md 行数 ≤275」，与代码 286 不符（既有陈旧，但本次恰好改该行未顺手修正）。
- **D9** [NIT] `SKILL.md:54` 结构错位：插在「**可选思路**：1./2.」枚举之后以 `-` bullet 出现，会被读作「思路 C」，实际是触发判定条款。
- **D10** [NIT] `L1+` 为未定义记号（既有档位=mini/L0/L0-T/L0-E/L1 standard）；且 `spec-mode.md:7` 只排除「mini/L0-T」，漏 L0-E 纯执行档。
- **D11** [NIT] `CHANGELOG.md:16` 未提 BP-08 钉值改动与「零新 selftest 守护」，且未带 task-id（同类条目惯例带 task-vNNN）。

## 3. 负结果与验证摘要
- 已核**未发现问题**：9 步 HARD-GATE / 终态 writing-plans / `docs/superpowers/specs/...-design.md` 三处描述与 `brainstorming/SKILL.md:25-33,62` 逐条一致（非脑补）；`/opsx:propose`、`/opsx:explore` 在 openspec 技能集内实际存在（各 4 处）；`planningHome/changeRoot/artifactPaths` 实存于 openspec-archive-change:36 等；Rule 39/40/91、Rule 52、Rule 51.1、Rule 97、Rule 22.3 全部实存且语义与引用相符（无捏造规则号）；R6 未发现「复制内容」实体（新文件 37 行，仅承载何时/怎么调用）。
- 排除的可能性：未发现 SKILL 三行与 Rule 39/40/91 的**直接**措辞冲突（仅 D1 的权威层二义）；未发现 CHANGELOG 位置/格式破坏（`## [Unreleased] / ### 新增` 下 `- **名** — 日期：描述` 合规）。
- 验证摘要：总发现 11 / 已验证 11 / 通过率 100%。总裁决 1 IMPORTANT + 6 WARNING + 4 NIT + 0 CRITICAL。

## 4. 结论
**APPROVED-with-nits（附合并前必修）**：变更纯增量、回归全绿（10/10）、无新增 config 键、命令来源全部可考；但 **D3（R4 架构边界）+ D1 + D2 + D6 建议合并前修**（均为一句话级文案修正，非结构返工）；D4/D5/D7 可下一轮。若 D3 不在本轮澄清，R4 只能计 partial，交付声明须按 R4 partial 写，不得声称「记录者+调度者已完整落地」。
