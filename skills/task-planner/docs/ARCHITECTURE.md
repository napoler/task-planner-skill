# task-planner 多工具架构设计

> **目标**：一份 canonical source，多工具部署位同步，零内容重复，env-var 解析路径。
> **家族分层（2026-10-12 task-v171）**：核心 = 四文件罗盘唯一管理域；79 条非核心规则按域分层至 11 卫星技能（3 新域 + 7 收编 + 1 验证域 verification-gate，Rule 84 task-v173 新增；其余 79 条中纪律域含 85/86/87/88/89/90/92/93/94/95、dispatch 域含 96，协同域含 91）；核心在位 14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83）；分层纪律 = Rule 82（建制/边界/回归防线：禁回潮、禁镜像副本）<!-- [2026-10-23 task-kb-cr-lits-20261023 L-5 实测：卫星侧实体规则编号 dedup=76（+Rule 94 → 77，+Rule 95 → 78，+Rule 96 → 79），全集 14+79=93（77/78/79 已废弃不计）] --><!-- 2026-10-19 task-v191 对齐实态：Rules 1-92 全集、核心 12→14 条、非核心 76→73 条、第 11 颗卫星 verification-gate 入分解 --><!-- 2026-10-21 task-v195：Rule 93（规范再召回纪律）入纪律域，全集 1-92→1-93、非核心 73→74 条 -->。

---

## 1. 设计原则

### 1.1 单一事实源（Single Source of Truth）

canonical 仓 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/` 是 task-planner 全部内容实现的唯一来源（2026-10-12 task-v171 拆分后实测）：
- `SKILL.md`（237 行，hooks 字段为空；文末含 11 卫星路由表 + Rules 1-96 全集索引）<!-- 2026-10-19 task-v191 对齐实态：214→237 行、1-84→1-92 -->
- `references/`（6 篇规则文档：critical-rules/todo-sync/worktree-isolation/goal-gate/completion-gate/methodology；纪律/派发/媒体域规则已迁至各卫星 `references/critical-rules-*.md`）
- `templates/`（13 个主模板 + 29 个 variant，`find templates -maxdepth 1 -type f -name '*.md' | wc -l` → 13，`templates/variant/*.md` → 29；variant 28/29 含「📚 必要知识储备」章节）
- `scripts/`（146 条目 = 137 个 .sh（含 92 个 selftest-*.sh）+ .ps1/.cjs/.ts/.tsv + lib//capabilities/ 两个子目录）<!-- 2026-10-19 task-v191 对齐实态：119/110/76 → 146/137/92 -->
- `lib/`（6 个 installer 库脚本：detect-tools/backup/install-stub/install-companion/migrate-refs/verify）
- `config.json`（阈值配置）

### 1.2 工具无关性

canonical 仓的**内容不绑定**任何特定 agent 工具：
- 无 `~/.claude` / `~/.zcode` 硬编码
- hook 命令通过 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 解析
- 配置文件 / 模板 / references 文本均不假设运行环境

### 1.3 家族分层原则（task-v171 新增，Rule 82）

- **核心只管四文件罗盘域**：`task_plan.md`/`findings.md`/`progress.md`/`knowledge-brief.md` 四文件 = 主代理↔子代理数据流转唯一协议介质（Rule 62.1）；核心 SKILL.md 只展开核心在位 14 条规则（1,2,3,5,19,20,26,51,62,66,80,81,82,83）。
- **规则全文唯一副本**：每条规则全文只栖息一个载体（核心或唯一卫星），迁移按「落盘（卫星 references/critical-rules-*.md）+ 删除（核心文本）+ 索引（SKILL.md 卫星路由表行）」原子配对，拆开产生规则悬空。
- **回归防线**：卫星路由表行 = 核心对卫星的唯一指针；卫星 selftest 随卫星落盘；禁在核心展开非核心域规则（防镜像副本回潮）。

---

## 2. 技能家族分层：核心 + 11 卫星技能

> 11 技能分层图 = 核心 task-planner + 3 新域卫星（task-dispatch / task-discipline / media-planner）+ 7 收编卫星（plan-research-router / plan-template-kit / plan-collab-router / plan-cost-guard / plan-resume / progress-tracker / task-drift-guard）+ 1 验证域卫星（verification-gate，Rule 84，task-v173 新增；规则全文收编入 11 卫星，安装链路经 `lib/install-companion.sh` 顶层发现分发），共 12 个技能节点（核心 1 + 卫星 11）。<!-- 2026-10-19 task-v191 对齐实态：补第 11 颗 verification-gate，原「10 技能分层图/核心 1 + 卫星 10」分解与标题「11 卫星」矛盾 -->

```
                    ┌───────────────────────────────────────────────┐
                    │ 核心 task-planner = 四文件罗盘唯一管理域         │
                    │ Rules 1-96 全集索引：核心在位 14 条             │
                    │（1,2,3,5,19,20,26,51,62,66,80,81,82,83）       │
                    └──────────────┬────────────────────────────────┘
                                   │ SKILL.md 文末「卫星路由表」按需 Read 规则全文
        ┌──────────────────────────┼───────────────────────────┐
        ▼ 新域卫星 ×3（task-v171 新建）                            ▼ 收编卫星 ×7（既有 skill 收编规则全文）
┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐
│ task-dispatch      │ │ task-discipline    │ │ media-planner      │
│ 子代理派发与拆分调度 │ │ 执行纪律与工作      │ │ 媒体制作任务派发    │
│ Rule 12,13,14,21,  │ │ Rule 4,6,7,8,9,10, │ │ Rule 47,49,50      │
│ 22,23,25,46,52,    │ │ 18,27-36,41-45,48, │ │                    │
│ 59,68（11 条）      │ │ 53-57,60,65,67,    │ │                    │
│                    │ │ 69-76（36 条）       │ │                    │
└────────────────────┘ └────────────────────┘ └────────────────────┘
┌──────────────┐┌──────────────┐┌──────────────┐┌──────────────┐┌──────────────┐
│plan-research ││plan-template ││plan-collab   ││plan-cost     ││plan-resume   │
│-router       ││-kit          ││-router       ││-guard        ││              │
│Rule 58,63,75 ││Rule 16,34,   ││Rule 39,40    ││Rule 17       ││Rule 24       │
│              ││37,38         ││              ││              ││              │
└──────────────┘└──────────────┘└──────────────┘└──────────────┘└──────────────┘
┌──────────────┐┌──────────────┐
│progress-     ││task-drift-   │
│tracker       ││guard         │
│Rule 30       ││Rule 11,15,   │
│              ││61,64         │
└──────────────┘└──────────────┘
```

### 2.1 新域卫星规格（task-v171 新建）

| 卫星 | 定位 | 域边界 | 规则数 | 规则全文 |
|------|------|--------|--------|---------|
| task-dispatch | 管「计划如何被拆分、派发、校验、调度」——子代理全生命周期的机器门控与执行纪律 | 不管四文件内容本身（核心）、通用执行纪律（task-discipline）、媒体制作（media-planner） | 11 | `../../task-dispatch/references/critical-rules-dispatch.md` |
| task-discipline | 管「执行过程的纪律与工作产物」——错误闭环/证据/调研/模板/反思/可靠性/能力沉淀/卫生/交互/超时/注释/来源锚/变更吸收 | 不管四文件数据流转（核心 Rule 62）、派发机制（task-dispatch）、媒体制作 | 36 | `../../task-discipline/references/critical-rules-discipline.md` |
| media-planner | 管「媒体制作类任务的拆分轴与执行体路由」——视频/图片/剧集创作媒体轴精细拆分 | 不管通用派发机制（task-dispatch）、通用纪律（task-discipline） | 3 | `../../media-planner/references/critical-rules-media.md` |

新域卫星随迁资产：`task-dispatch` 收 6 个 scripts（analyze-splits/check-subagent-return/check-rescue-chain/subagent-fallback + selftest-rescue-chain/selftest-fallback）+ 3 篇 references；`task-discipline` 收 plan-hygiene.sh + capabilities/ + batch-quality-gate.md + capability-registry.md；`media-planner` 仅 SKILL.md + references。

### 2.2 收编卫星规格（既有 skill，规则全文收编）

| 卫星 | 域 | 收编规则 | 规则全文 |
|------|----|---------|---------|
| plan-research-router | 调研分析与证据纪律 | 58,63,75 | `../../plan-research-router/references/critical-rules-research.md` |
| plan-template-kit | 模板生命周期与难度分级 | 16,34,37,38 | `../../plan-template-kit/references/critical-rules-template.md` |
| plan-collab-router | 技能协同与工具面选择 | 39,40 | `../../plan-collab-router/references/critical-rules-collab.md` |
| plan-cost-guard | 成本控制 | 17 | `../../plan-cost-guard/references/critical-rules-cost.md` |
| plan-resume | 计划续推 | 24 | `../../plan-resume/references/critical-rules-resume.md` |
| progress-tracker | 共享内容认领 | 30 | `../../progress-tracker/references/critical-rules-progress.md` |
| task-drift-guard | 漂移检测与偏移留痕 | 11,15,61,64 | `../../task-drift-guard/references/critical-rules-drift.md` |

收编统一三动作（原子配对，2026-10-12 task-v171 执行）：**落盘**（卫星 references 写收编规则全文，标题格式统一 `### N 标题`）+ **删除**（核心 critical-rules.md 对应文本删除）+ **索引**（卫星 SKILL.md 追加路由段）。

---

## 3. 卫星路由表（核心 SKILL.md 文末同表）

| 卫星 | 域 | 规则全文路径 | 调用条件 |
|------|----|------------|---------|
| task-dispatch | 子代理派发与拆分调度 | `../../task-dispatch/references/critical-rules-dispatch.md` | 拆分/派发/并行/粒度校验/执行体选型/超时兜底/代码编辑隔离（Rule 12,13,14,21,22,23,25,46,52,59,68） |
| task-discipline | 执行纪律与工作产物维护 | `../../task-discipline/references/critical-rules-discipline.md` | 执行纪律/错误闭环/证据/调研/批量/反思/注释/可靠性/能力沉淀/变更吸收（Rule 4,6,7,8,9,10,18,27,28,29,31-36,41-45,48,53-57,60,65,67,69-76） |
| media-planner | 媒体制作任务派发 | `../../media-planner/references/critical-rules-media.md` | 视频/图片/剧集创作媒体轴拆分与执行体路由（Rule 47,49,50） |
| plan-research-router | 调研分析与证据纪律 | `../../plan-research-router/references/critical-rules-research.md` | 调研/分析/评估/归因证据面覆盖与反推诿（Rule 58,63,75） |
| plan-template-kit | 模板生命周期与难度分级 | `../../plan-template-kit/references/critical-rules-template.md` | 模板选取/沉淀入库/难度分级/轻量档判定（Rule 16,34,37,38） |
| plan-collab-router | 技能协同与工具面选择 | `../../plan-collab-router/references/critical-rules-collab.md` | comet/OpenSpec/superpowers/dynamic-workflows 路由（Rule 39,40） |
| plan-cost-guard | 成本控制 | `../../plan-cost-guard/references/critical-rules-cost.md` | opus 频次/嵌套成本/成本门控（Rule 17） |
| plan-resume | 计划续推 | `../../plan-resume/references/critical-rules-resume.md` | 交付终态/会话恢复触发点扫描与自主续推（Rule 24） |
| progress-tracker | 共享内容认领 | `../../progress-tracker/references/critical-rules-progress.md` | 跨任务共享内容认领追踪/进度复用（Rule 30） |
| task-drift-guard | 漂移检测与偏移留痕 | `../../task-drift-guard/references/critical-rules-drift.md` | 漂移检测/偏移检查子代理化/周期回顾节奏（Rule 11,15,61,64） |

## 4. 规则全集索引与纪元演进

**Rules 1-96 全集索引**（2026-10-24 task-nopause-execfirst-20261023 并集解更新：1-94→1-95→1-96；2026-10-23 task-focus-plan-split-20261023 更新；2026-10-21 task-v195 更新；2026-10-19 task-v191 对齐）：
- **核心在位 14 条**（1,2,3,5,19,20,26,51,62,66,80,81,82,83）全文见 `references/critical-rules.md`（203 行，2026-10-23 task-kb-cr-lits L-5 实测；task-v191 快照 193 行；含分层架构说明 + 卫星路由索引）
- **其余 79 条**按域迁至上表 11 卫星（3 新域 61 条 + 7 收编 17 条 + 验证域 1 条 Rule 84，合计 79；纪律域含 85/86/87/88/89/90/92/93/94/95（85-90/92-94 为 v171 后追加 9 条，95 为 2026-10-23 追加 1 条）、dispatch 域含 96（2026-10-24 task-subagent-boost-20261023 追加 1 条）、协同域含 91 为追加 1 条）<!-- [2026-10-23 task-kb-cr-lits-20261023 L-5 扩面：原拆分 50+16+1=67 与外层 74/76 均不自洽（50/16 为 v171 快照、未含后续追加），改为现值 58=dispatch 11+discipline 44+media 3、17=research 3+template 4+collab 3+cost 1+resume 1+progress 1+drift 4，58+17+1=76 与实测 dedup 一致（+Rule 94: 58→59、44→45 → 77；+Rule 95 → 78、discipline 45→46；+Rule 96 → 79、dispatch 11→12）] -->
- Rule 82（技能专业化分层纪律）为 task-v171 新增：建制/边界/回归防线三款，禁回潮、禁镜像副本

**纪元演进史**（selftest 宽容正则锚守护随动，防回退误报）：
- 2026-10-09 task-v149 对齐 Rules 1-65 → 2026-10-10 task-v154 合并并集演进至 Rules 1-69 → task-v160/v163/v166 陆续落地 Rule 70/72/74/75/76，全集至 1-76
- 2026-10-12 task-v171：76 条既有规则按域分层至 10 卫星 + Rule 82 新增，全集索引演进为「Rules 1-80」（核心 12 条 + 卫星 66 条）；selftest 中规则区间宽容锚同步扩至覆盖 1-77 全集（例：`selftest-batch-pilot.sh` BP-09 `隶属 Rules 1-(3[6-9]|[4-6][0-9]|7[0-7])`，含 77 纪元）
- 2026-10-14~18 task-v183/v187/v190：Rule 81/83 入核心（核心 12→14 条）+ 第 11 颗卫星 verification-gate（Rule 84，task-v173 新增）+ Rule 85-90/92（纪律域）+ Rule 91（协同域）落地，全集演进为「Rules 1-92」（核心 14 条 + 卫星 73 条，2026-10-19 task-v191 对齐）
- 2026-10-21 task-v195：Rule 93（规范再召回纪律）入纪律域，全集演进为「Rules 1-93」（核心 14 条不变，卫星 73→74 条）；执行规范召回卡 execution-recall-card.md 同批落地
- 2026-10-23 task-focus-plan-split-20261023：Rule 94（任务专注性与计划隔离纪律）入纪律域，全集演进为「Rules 1-94」（核心 14 条不变，卫星 76→77 条）；Rule 94 全文（94.1–94.6）与执行规范召回卡 execution-recall-card.md 之 Rule 94 蒸馏行（L39）同批落地
- 2026-10-23 task-nopause-execfirst-20261023：Rules 1-94→1-95（Rule 95 非必要暂停禁令与执行优先纪律）
- 2026-10-24 task-subagent-boost-20261023：Rules 1-95→1-96（Rule 96 子代理激活默认与并行推进强化，dispatch 域；本文档计数由 task-nopause-execfirst-20261023 合并时并集解补齐 79 条口径）

---

## 5. 目录结构

```
${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/                          ← canonical source (git 仓库)
├── SKILL.md                                 ← 工具无关主文档（237 行, hooks 字段为空，2026-10-19 task-v191 对齐）
├── config.json                              ← 阈值配置
├── README.md / examples.md / reference.md
├── references/                              ← 6 篇规则文档（2026-10-12 实测）
│   ├── critical-rules.md                    # 核心域 14 条全文 + Rules 1-96 全集索引 + 分层架构说明
│   ├── todo-sync.md / worktree-isolation.md / goal-gate.md / completion-gate.md / methodology.md
│   └── [79 条非核心规则 → 各卫星 references/critical-rules-*.md（见 §3 路由表）]
├── templates/                               ← 13 主模板 + 29 variant（2026-10-12 实测）
│   ├── task_plan.md / progress.md / findings.md / verification.md / notepad-learnings.md
│   ├── knowledge-brief.md / subagent_dispatch.md / delivery-summary.md / shared-tracker.md / user-session-log.md / batch_report.md / session-handoff.md / deprecated.md
│   └── variant/                             ← 场景化变体 29 个（28/29 含「📚 必要知识储备」）
├── scripts/                                 ← 146 条目（137 .sh 含 92 selftest，2026-10-19 task-v191 对齐）
│   ├── run-selftests.sh                     # 全量 selftest 回归统一入口（--fresh/--only/--status）
│   ├── check-complete.sh / .ps1             # Stop hook 完成检测
│   ├── check-conflicts.sh / check-drift.sh / check-doc-sync.sh / check-scope.sh
│   ├── init-session.sh / .ps1               # 计划初始化
│   ├── plan-created.cjs                     # 哨兵清除（side + legacy 双清除）
│   ├── session-catchup.ts / sync-todos.sh / sync-ide-folders.ts
│   ├── task-plan-init.cjs                   # SessionStart 会话私有哨兵
│   ├── resolve-plan-dir.sh / set-active-plan.sh   # 活跃计划指针（side 优先 → 全局 fallback → mtime）
│   ├── attest-plan.sh / check-dispatch.sh / check-plan-dispatch.sh / rule-reserve.sh / ledger-append.sh / smart-merge-back.sh 等
│   └── selftest-*.sh ×92 + selftest-registry.tsv
├── lib/                                     ← installer 库（6 脚本）
│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星显式 rsync）
│   ├── install-companion.sh                 # 顶层 skills/*/ 自动发现分发（含另 3 个收编卫星）
│   └── detect-tools.sh / backup.sh / migrate-refs.sh / verify.sh
├── tests/  └── smoke.sh
├── docs/    └── ARCHITECTURE.md             ← 本文档
├── install.sh / uninstall.sh
├── INSTALL.md / MIGRATION.md
├── companion/                               ← 伴生 agents（drift-checker 等）
├── review-library/                          ← 审查模式库
└── .gitignore
```

## 6. 部署形态（2026-10-05 task-v131 M-1 口径修正：实盘=各宿主位均为全量副本，非「薄壳+rsync 指针」）

宿主位清单（均 = 本仓 `skills/task-planner/` 全量副本：SKILL.md / scripts/ / references/ / templates/ / config.json 全同步，无独立 lib/、tests/、docs/、install.sh）：
- `~/.zcode/skills/task-planner/`          ← ZCode 位
- `~/.claude/skills/task-planner/`        ← Claude Code 位
- `~/.config/opencode/skills/task-planner` ← OpenCode 位（物理路径；`~/.opencode` 为其 symlink 兼容入口）
- `~/.cursor/skills/task-planner/`        ← Cursor 位
- hooks 注册于各宿主配置：zcode 位 = `~/.zcode/cli/config.json`，claude 位 = `~/.claude/settings.local.json`（经 `scripts/register-hooks-cj.ts`），非 SKILL.md frontmatter

**卫星技能随装**（两条链路并存）：
1. `lib/install-stub.sh:41` `SATELLITE_SKILLS` 显式登记 7 个（4 既有 + task-v171 S39 追加 task-dispatch/task-discipline/media-planner）→ `install_satellite_skills()` 整目录 rsync 到宿主位同级 `skills/<sat>/`（源缺失则跳过，向后兼容不阻塞）
2. `lib/install-companion.sh`（install.sh Phase 5.6）自动发现仓库顶层 `skills/*/`（排除 task-planner 本体）→ 覆盖另 3 个收编卫星（plan-resume/progress-tracker/task-drift-guard）

---

## 7. 路径解析契约

### 7.1 单一表达式

所有 hooks / scripts / 文档使用同一表达式：
```bash
${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}
```

### 7.2 三级 fallback

```
一级：环境变量 TASK_PLANNER_ROOT
二级：fallback 至 canonical 仓默认位置
三级：（无）若一二都未设，命令失败 — 提示用户
```

### 7.3 跨技能相对路径模式

caller/文档引用卫星资产统一 `../<归属>/...` 相对路径（先例：`selftest-drift-check-subagent.sh` `$SKILL_ROOT/../task-drift-guard/SKILL.md`，`../` 相对 skill 根 skills/task-planner/ 解析）；task-v171 起核心 caller 批量改用 `../task-dispatch/scripts/`、`../task-discipline/references/` 模式指向迁出资产。注意：本文档位于 docs/ 子目录（比 skill 根多一层），故文档正文内引用卫星资产一律 `../../<sat>/...`，§3/§2 表格中的 `../../` 前缀即由此而来（2026-10-19 task-v191 对齐）。

---

## 8. Per-Tool 部署位适配

### 8.1 通用结构

每个部署位持有（2026-10-05 task-v131 M-1 注记：部署形态=全量副本，「stub/薄壳」为历史术语）：
- **SKILL.md**（由 `generate_stub_skill_md` 生成）：`description`/`model`/`allowed-tools` + 平台特定 hook 声明 + 内容引用表（指向 `${TASK_PLANNER_ROOT}/...`）
- **scripts/**：rsync from canonical + sed-rewritten 路径（仅动作于未改写文件，幂等）
- **references/ + templates/ + config.json**：直接 rsync from canonical

### 8.2 工具差异

| 工具 | Hook 注册位置 | Hook 配置格式 | 适配分支 |
|------|--------------|--------------|---------|
| Claude Code | `~/.claude/settings.json` 或 `settings.local.json` | `hooks: { SessionStart: [...], PreToolUse: [...] }` | `claude-settings` |
| ZCode | 部署位 SKILL.md frontmatter | `hooks:\n- type: command\n  name: ...` | `zcode-frontmatter` |
| OpenCode / Cursor / Continue | 部署位 SKILL.md frontmatter | 类似 ZCode | `opencode/cursor/continue-frontmatter`（通用模板） |

### 8.3 适配原则

- **路径硬编码最小化**：所有 hook command 用 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/...` 形式
- **平台特性保留**：每工具的 hook 命名空间与配置语法遵循该平台规范
- **脚本无修改**：部署位 scripts/ 是 canonical 的精确副本（仅路径重写），逻辑与 canonical 完全一致

---

## 9. 升级与同步

### 9.1 更新 canonical

```bash
cd ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}
git pull
```

所有部署位自动生效（无需重跑 install.sh）：references/、templates/ 已在 install 时 rsync 锁定；scripts/ 通过 env-var 解析。

### 9.2 添加新工具

修改 `lib/install-stub.sh` 的 `TOOL_PROBES` 数组并在 `generate_stub_skill_md` 添加对应 `*-frontmatter` 分支。`install.sh` 自动检测并安装新工具。

### 9.3 新增卫星技能（task-v171 起三处注册，缺一即部署残缺）

1. `lib/install-stub.sh` `SATELLITE_SKILLS` 数组追加卫星名（显式 rsync 族）
2. 核心 `SKILL.md` 文末「卫星路由表」追加路由行（域/规则全文路径/调用条件）
3. 收编既有 skill 时确认 `lib/install-companion.sh` 顶层 `skills/*/` 自动发现覆盖

---

## 10. 回归命令（全量 selftest）

```bash
# 全量 selftest 回归——忽略输入指纹缓存，92 个 selftest-*.sh 全量重跑（新基线/发布前用；2026-10-19 task-v191 对齐）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/run-selftests.sh --fresh

# 缓存版（日常）：命中缓存脚本输出 [reused] 跳过重跑
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/run-selftests.sh

# 只跑子集 / 只读查指纹与缓存
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/run-selftests.sh --only dispatch
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/run-selftests.sh --status
```

- 期望末行 `Total: N PASS=x FAIL=y` 且 **FAIL=0**（指纹 = 全部 selftest 内容 + 技能源目录 git 状态；缓存仅省 CPU 不省正确性）
- 卫星 selftest 随卫星落盘（如 `../task-dispatch/scripts/selftest-*.sh`，相对 skill 根），按需同口径跑批
- `selftest-registry.tsv` 登记全部 selftest（入口 `run-selftests.sh` 除外，改名规避递归）

---

## 11. 故障模式

### 11.1 `TASK_PLANNER_ROOT` 未设置

症状：`check-doc-sync.sh` 报 `SKILL_ROOT undefined`。
解决：export 或 fallback 链必须包含 canonical 默认路径。

### 11.2 hook 注册未生效

症状：SessionStart 时无 task-planner 提示。
解决：检查 `settings.local.json` 的 `hooks` 块；或重跑 `node --experimental-strip-types scripts/register-hooks-cj.ts`。

### 11.3 sed 路径改写遗漏

症状：脚本中仍含 `~/.zcode/skills/task-planner`。
解决：手动 `sed -i 's|...|...|g' <script>`，并检查 `lib/install-stub.sh` 的 `rewrite_paths_in_scripts`。

### 11.4 卫星资产 404（task-v171 新增）

症状：`CRIT_D`/`BGATE` 等 `../task-discipline/...` 路径断言 FAIL（脚本内相对 skill 根）。
原因：卫星未随装（SATELLITE_SKILLS 未登记或 companion 发现失败）。
解决：确认 `lib/install-stub.sh:41` 数组含目标卫星；非 canonical 运行时明确跳过语义（源缺失 skip 不阻塞）。

---

## 12. 设计权衡（Trade-offs）

| 决策 | 备选 | 选择理由 |
|------|------|---------|
| `scripts/` 在部署位内副本 | 完全 env-var 解析 | 部分平台 hook 配置限制路径必须在部署位内；env-var 兼容性差 |
| canonical 仓独立 git | monorepo skill 子目录 | 跨项目共享；版本独立；多人协作 |
| 5 hooks 全部启用 | 仅 SessionStart | 与 zcode 端功能对齐；提供完整漂移检测 |
| `install.sh` 用 bash | Python / TypeScript | bash 4.0+ 跨平台一致；无运行时依赖 |
| 规则按域分层至卫星（核心瘦身） | 全部规则留核心单文件 | SKILL.md 558 行超载上下文；分层后核心 237 行（task-v171 时点 214 行快照，2026-10-14~18 规则演进后实测 237，2026-10-19 task-v191 对齐）+ 按需 Read 卫星全文，token 效率与域内聚双赢（Rule 82） |
| 卫星双安装链路（显式 rsync + companion 发现） | 单一链路 | 显式链路保 4 既有卫星历史行为不变；companion 发现覆盖既有外围 skill；两者幂等互补 |
| backup 保留在 `.backup/` | 删前询问 | 默认安全；用户加 `--no-backup` 才删 |
