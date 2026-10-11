# S15 alignment-review 对齐审查检查点（只读）

- 审查对象：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit`，HEAD=`88e6248f40371083ef04093461c47f7c55950cff`
- diff 范围：`git diff 21f7e6b..HEAD`（实测 **4 commit**：a234369 / fca4f40 / aa06dde / 88e6248，33 文件 +243/-167）+ 本任务计划产出 `plans/task-v149-skill-alignment-audit/`
- 需求锚：R2「没有对齐的以及落后的内容全部帮我对齐」（Rule 51.1a）
- 技能加载：`Skill("alignment-review")` **加载成功**（用户级 `~/.zcode/skills/alignment-review`），按标准流程执行，无降级
- 结论：**CHANGES_REQUESTED**（P1×3，无 P0；P2×3）

---

## 维度一 · 版本一致性（≥6 处交叉抽查，声明 vs 命令实测）

| # | 声明处（file:line） | 声明值 | 实测命令 | 实测 | 判定 |
|---|--------------------|--------|----------|------|------|
| 1 | SKILL.md:9 / :278 / :357 | Critical Rules 全集 1-65 | `grep -c '^### [0-9]' critical-rules.md` | 65（### 1..### 65） | PASS |
| 2 | docs/ARCHITECTURE.md:17,64 | scripts 106 条目=104 文件+2 子目录 | `ls scripts\|wc -l`=106；`find -maxdepth 1 -type f`=104；子目录 lib/ capabilities/ | 106/104/2 | PASS |
| 3 | INSTALL_zh.md:293 | .sh 96（含 62 selftest） | `find scripts -maxdepth 1 -name '*.sh'`=96；`ls selftest-*.sh`=62 | 96/62 | PASS |
| 4 | README.md:79 / ARCHITECTURE.md:15 / INSTALL_zh.md:313 | templates 10 主 + 29 variant=39 | `find templates -maxdepth 1 -type f`=10；`find templates/variant`=29 | 10/29/39 | PASS |
| 5 | INSTALL_zh.md:302-304 / ARCHITECTURE.md:13,46 | references 10 | `find references -maxdepth 1 -type f`=10 | 10 | PASS |
| 6 | INSTALL_zh.md:306 / README.md:120 | companion 7 | `ls companion/agents/`=7 | 7 | PASS |
| 7 | README.md:69 / INSTALL_zh.md:290 | config 42 键 | `node -e` Object.keys(properties)=42 | 42 | PASS |
| 8 | README_zh.md:136,229 / CLAUDE.md:33 / README.md:72 | Rules 1-65 | critical-rules 实块 65；SKILL.md 无 1-39/1-45/1-64 残留 | 一致 | PASS |
| 9 | INSTALL_zh.md:3 / ARCHITECTURE.md:100 | 在役三位=zcode/claude/opencode | `ls`：zcode/claude/opencode/cursor 存在，continue 缺失 | 与口径一致 | PASS |
| 10 | INDEX.md:205 汇总 | in_progress 0 / pending 0 / complete 94 | 表内行 tally=94 complete、0/0；已完成段=94 | 94=94=94 | PASS |

> 维度一：**10/10 PASS**。核心计数面（Rule 65 / selftest 62 / scripts 106=104+2 / config 42 / companion 7 / templates 10+29 / references 10 / 在役位口径 / INDEX 汇总）全部与实测一致。

---

## 维度二 · 变更记录三要素（42.6.3 处置表↔commit↔Decisions）

| 抽样 | 处置表项 | commit 记录 | Decisions 表 | 判定 |
|------|----------|-------------|--------------|------|
| A | D6/D7 Rule 65 恢复+config 孤儿键合法化 | a234369「Rule 65 恢复(57→65 仲裁重编号)」 | 「Rule 65=恢复 v142…重编号非新造」 | 改了 A 记了 A ✓ |
| B | D14/D15 README_zh/CLAUDE/skill README Rule 集合 | fca4f40「仓级文档批(D14-D19…)」 | —（处置表承接） | 改了 A 记了 A ✓ |
| C | D20 video-fix-executor 实态 / D24 DCS-20 收窄 / D25 COMPAANION | fca4f40 逐项点名 | — | 改了 A 记了 A ✓ |
| D | CR M-1..M-5 / L-1..L-3 闭环 | 88e6248 全清单点名 | 「CR 修复批 S24-S28」行 | 改了 A 记了 A ✓ |

> 维度二：**抽 4 组，正向（改了记了）全部通过**。反向（记了没改/改了没记）见维度三异常。

---

## 维度三 · 语义漂移（修正是否引入/遗留新不一致）

### 明确通过项
- **INDEX 汇总 vs 表内实数**：94=94=94（PASS，幽灵条目已消）。
- **SKILL 全集行 vs critical-rules 实块数**：65=65（PASS）。
- **Rule 65 块 vs v142 原文**：CR S14 已证「57↔65 归一化后逐字节 IDENTICAL」，本次复核 `### 65` 块在位、C39 行 SKILL.md:210 在位、registry:61 已改 65（PASS）。

### 漂移/遗留项（详见下方问题清单）
- **[P1-1] examples/full-workflow.md:192 残留 `session-catchup.py`**（本任务 D18 只修了 :41，漏 :192；仓内实为 session-catchup.ts，无 .py）→ 同文件内 :41(.ts) 与 :192(.py) 自相矛盾，用户可见示例失效引用。
- **[P1-2] skills/task-planner/README.md:86 残留「17 个工具脚本」**（S2 发现#17，未修、未登记）；同文件 :32「41 文件,4 commits」/ :34「8 篇规则」/ :35「5 核心+3 辅助」/ :36「17 个工具脚本」/ :38「smoke 16/16」均陈旧，与已改 :79「10 核心」自相矛盾。D19 自称「计数项全集」实为不全。
- **[P1-3] config properties 计数残留 40**：critical-rules.md:425/436/446/460/469 仍写「config.json properties=40 维持」，selftest-iteration-persistence.sh:185 亦写 `properties=40`；而实际 config=42（base 即 42），本任务已将 registry 10 行及多脚本注释改为 42 并宣称「与 43.4/44.4/47.4 口径同步」——该同步声明与 43.4(:460)/44.4(:469) 实写 40 **不符**。属 R2「落后未对齐」残留。
- **[P2] 计划产出自身**：task_plan.md「Subagent Handoff 登记表」(L305-312) 空置（已有 28 检查点在位）；task_plan「Current Phase」仍写 Phase 1+Phase 2、「Next Step」陈旧、Phase 4 表 Status=pending 而 progress 为 in_progress、Phase 4 Executor 字段未随 Decisions「S13 改主进程/S15 改派 general-purpose」同步。
- **[P2] knowledge-brief §2 过时事实**：「『三部署位』口径需 S4 重新确认拓扑（cursor 位?）」（S4 已定论：五候选/三在役/cursor 陈旧/continue 未部署）；「下一可用编号 65」（本任务已 land 65，下一应为 66）。
- **[P2] S2 检查点(03) 基线误差**：templates 顶层记 12（实测 10），S10 已实测纠正并采用 10，未向下游传播（无实害，登记）。

---

## 维度四 · 计划产出自身对齐（VC/Executor/Handoff ↔ progress/checkpoints）

- **检查点在位性**：`subagent-state/` 实有 01-25 + 27-31 共 30 份（26=本检查点），覆盖 Phase 1 基线/S1-S4 审计/S5-S28 修复/两轮 drift-check/S13 回归/S14 CR，与 progress.md 各 Phase 段印证一致（PASS）。
- **VC 印证**：VC-1（S13 回归检查点 24 在位）/ VC-2/VC-3（findings 处置表 D1-D36 + 遗留表 L1-L16 在位）/ VC-5（S14 检查点 25 在位）均有落点；VC-4/VC-6 属 Phase 5，未执行（登记未验证）。
- **偏差**：见维度三 [P2]（Handoff 空置、task_plan 状态字段陈旧）——属计划簿记滞后，非技能产物缺陷。

---

## 问题清单（CHANGES_REQUESTED）

```
[P1] examples/full-workflow.md:192 — 残留失效引用 `session-catchup.py`（实为 session-catchup.ts；同文件 :41 已改 .ts）— 改 .py→.ts
[P1] skills/task-planner/README.md:86 — 残留「17 个工具脚本」陈旧计数（S2#17 未修未登记）— 改「96 个 .sh（含 62 selftest）」并登记；同块 :32/:34/:35/:36/:38 同步（41 文件/8 篇规则/5 核心+3 辅助/17 工具/16-16）与 :79 口径统一
[P1] skills/task-planner/references/critical-rules.md:425,436,446,460,469 + scripts/selftest-iteration-persistence.sh:185 — config 计数残留 properties=40（实 42）；且 registry/脚本注释「与 43.4/44.4/47.4 口径同步」声明与 43.4/44.4 实写 40 不符 — 统一改 42（或统一登记为历史维持口径并消除「同步」误导）
[P2] plans/task-v149-skill-alignment-audit/findings.md 处置表 — S2#8(CHANGELOG 段序)/#10,#11(CLAUDE.md 缺 companion/agents 条目、scripts 列表不全) 未入 D 表、未修、CHANGELOG.md 全程未改 — 补登记（fixed/deferred/SKIP 三态）
[P2] plans/task-v149-skill-alignment-audit/knowledge-brief.md §2 — 「三部署位口径待 S4 确认」「下一可用编号 65」两条已被后续事实取代 — 回填现状
[P2] plans/task-v149-skill-alignment-audit/task_plan.md — Handoff 登记表空置 / Current Phase+Next Step 陈旧 / Phase 4 Status 与 Executor 未同步 — 终验前补录
```

---

## 变更记录输出（三要素）

| 字段 | 内容 |
|------|------|
| 变更范围 | 只读审查：worktree HEAD 88e6248（33 文件 diff）+ 计划四文件 + subagent-state 30 检查点。**未修改任何被审对象** |
| 冲突处理结果 | 无（只读审查，不执行写入前闸门整理）；发现 3 项 P1 残留冲突 + 3 项 P2，均给出可执行修法；未决残留=P1×3 |
| 文档当前状态 | 核心计数面 10/10 一致；残留冲突：full-workflow:192 / README:86 及同块 / properties=40 三处未对齐 |

---

## 未验证项
- 全量 62 selftest 回归与 P1 基线逐条 diff（由 S13/检查点 24 承担，本次未复跑）。
- 部署位 IDENTICAL 对账（Phase 5 VC-4 未执行）；cursor 位重同步 / companion .backup-* 移出（Phase 5）。
- 行为级冒烟（属运行时验证，非静态对齐范围）。

## 检查点写入时间
2026-10-09 alignment-review S15 完成
