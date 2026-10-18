# task-planner — 任务规划与漂移检测技能

> **多工具架构 v2（2026-08-29）**：canonical source + per-tool 部署位同步，env-var 路径解析。
> **家族分层 v2.1（2026-10-12 task-v171）**：核心只负责四文件罗盘管理（SKILL.md 214 行）；76 条既有规则按域分层至 11 卫星技能（3 新域 + 7 收编），卫星路由表按需 Read 规则全文，禁回潮禁镜像副本（Rule 82）。

## 快速链接

- 📦 **GitHub**：[napoler/task-planner-skill](https://github.com/napoler/task-planner-skill)
- 🚀 **一键安装**：`bash <(curl -sSL https://raw.githubusercontent.com/napoler/task-planner-skill/main/install.sh)`
- 📖 **详细指南**：[INSTALL.md](INSTALL.md) · [MIGRATION.md](MIGRATION.md)
- 🏗️ **架构设计**：[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 概述

结构化任务规划技能，支持多进程/多目录 plan 管理，内置周期性漂移检测；2026-10-12 起为「核心 + 11 卫星」技能家族形态。

**核心特性**：
- **5 个生命周期 hook**：SessionStart（哨兵）/ PreToolUse（范围阻断 + 委派门控 + Agent 派发契约守卫，matcher 须含 Agent）/ PostToolUse（计划陈旧检测）/ UserPromptSubmit（新指令影响判定）/ Stop（完成检测）
- **原生 Todo 双向同步**：S1-S5 强制同步时机（计划文档 ↔ TodoWrite/Task 系统）
- **漂移检测**：每 phase 完成后自动派发 `drift-checker` 子代理（Rule 61 载体，规则全文在卫星 `task-drift-guard`）
- **工作树隔离**：实现类任务默认首选 worktree（防改坏运行中基础设施）
- **场景化模板**：13 个主模板 + 29 个 variant（2026-10-12 实测；variant 28/29 含「📚 必要知识储备」章节）按 `template_type` 字段自动分发
- **技能家族分层**：核心 = 四文件罗盘唯一管理域；派发/纪律/媒体/模板/调研/协同等域规则按卫星分流，见下方分层图与路由表

---

## 技能分层图：核心 + 11 卫星技能

> 10 技能分层图 = 核心 task-planner + 3 新域卫星（task-dispatch / task-discipline / media-planner）+ 7 收编卫星（plan-research-router / plan-template-kit / plan-collab-router / plan-cost-guard / plan-resume / progress-tracker / task-drift-guard），共 11 个技能节点（核心 1 + 卫星 10）。

```
                    ┌───────────────────────────────────────────────┐
                    │ 核心 task-planner = 四文件罗盘唯一管理域         │
                    │ Rules 1-92 全集索引：核心在位 14 条             │
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

## 卫星路由表（11 卫星 — 非核心域规则全文按需 Read）

| 卫星 | 域 | 规则全文路径 | 调用条件 |
|------|----|------------|---------|
| task-dispatch | 子代理派发与拆分调度 | `../task-dispatch/references/critical-rules-dispatch.md` | 拆分/派发/并行/粒度校验/执行体选型/超时兜底/代码编辑隔离（Rule 12,13,14,21,22,23,25,46,52,59,68） |
| task-discipline | 执行纪律与工作产物维护 | `../task-discipline/references/critical-rules-discipline.md` | 执行纪律/错误闭环/证据/调研/批量/反思/注释/可靠性/能力沉淀/变更吸收（Rule 4,6,7,8,9,10,18,27,28,29,31-36,41-45,48,53-57,60,65,67,69-76） |
| media-planner | 媒体制作任务派发 | `../media-planner/references/critical-rules-media.md` | 视频/图片/剧集创作媒体轴拆分与执行体路由（Rule 47,49,50） |
| plan-research-router | 调研分析与证据纪律 | `../plan-research-router/references/critical-rules-research.md` | 调研/分析/评估/归因证据面覆盖与反推诿（Rule 58,63,75） |
| plan-template-kit | 模板生命周期与难度分级 | `../plan-template-kit/references/critical-rules-template.md` | 模板选取/沉淀入库/难度分级/轻量档判定（Rule 16,34,37,38） |
| plan-collab-router | 技能协同与工具面选择 | `../plan-collab-router/references/critical-rules-collab.md` | comet/OpenSpec/superpowers/dynamic-workflows 路由（Rule 39,40） |
| plan-cost-guard | 成本控制 | `../plan-cost-guard/references/critical-rules-cost.md` | opus 频次/嵌套成本/成本门控（Rule 17） |
| plan-resume | 计划续推 | `../plan-resume/references/critical-rules-resume.md` | 交付终态/会话恢复触发点扫描与自主续推（Rule 24） |
| progress-tracker | 共享内容认领 | `../progress-tracker/references/critical-rules-progress.md` | 跨任务共享内容认领追踪/进度复用（Rule 30） |
| task-drift-guard | 漂移检测与偏移留痕 | `../task-drift-guard/references/critical-rules-drift.md` | 漂移检测/偏移检查子代理化/周期回顾节奏（Rule 11,15,61,64） |

## Critical Rules 指针

Rules 1-92 全集索引：**核心在位 14 条**（1,2,3,5,19,20,26,51,62,66,80,81,82,83）全文见 `references/critical-rules.md`（190 行，2026-10-14 实测；含分层架构说明+卫星路由索引）；其余 71 条已按域迁至上表 11 卫星——**非核心域规则勿在本技能展开**（Rule 82 回归防线）。

---

## 多工具架构

```
┌──────────────────────────────────────────────────────────┐
│ canonical source: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/                    │
│   (独立 git 仓库, 17 顶层条目)                           │
│   - SKILL.md (214 行, hooks 字段已剥除)                   │
│   - references/  (6 篇规则)                              │
│   - templates/   (13 主模板 + 29 variant)                │
│   - scripts/     (119 条目 = 110 .sh 含 76 selftest)     │
│   - lib/         (6 个 installer 脚本)                   │
│   - tests/       (smoke.sh)                             │
│   - install.sh / uninstall.sh                            │
└──────────────────┬───────────────────────────────────────┘
                   │  rsync + sed-rewrite
       ┌───────────┼───────────┬───────────┬────────────┐
       ▼           ▼           ▼           ▼            ▼
  ~/.claude   ~/.zcode  ~/.config/    ~/.cursor   ~/.continue
  /skills/    /skills/   opencode/    /skills/    /skills/
  task-planner/          skills/
                          task-planner/
  (部署位 SKILL.md = 生成的 hook 薄壳 + 内容引用表; 其余为全量副本)
```

> [2026-10-05 task-v131 审计 L-5 修正] opencode 物理部署位 = `~/.config/opencode/skills/task-planner`；`~/.opencode` 为其 symlink 兼容入口（实测 `~/.opencode -> ~/.config/opencode`）。

**卫星技能随装**（2026-10-12 task-v171 S39 起）：`lib/install-stub.sh:41` `SATELLITE_SKILLS` 数组登记 7 个卫星（4 既有 + 3 新域），安装时整目录 rsync 到各宿主位同级 `skills/<sat>/`；另 3 个收编卫星经 `lib/install-companion.sh` 顶层 `skills/*/` 自动发现机制分发。

---

## 文件结构（canonical 仓）

```
${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/                          ← canonical source (git 仓库)
├── SKILL.md                                 ← 工具无关主文档（214 行; hooks 字段为空, 文末含 11 卫星路由表）
├── config.json                              ← 阈值配置
├── README.md / examples.md / reference.md
├── references/                              ← 6 篇规则文档（2026-10-12 task-v171 拆分后实测; 纪律/派发/媒体域规则已迁至卫星）
│   ├── critical-rules.md                    # 核心域 14 条规则全文+Rules 1-92 全集索引+分层架构说明
│   ├── todo-sync.md                         # S1-S5 同步契约
│   ├── worktree-isolation.md                # 隔离合约
│   ├── goal-gate.md / completion-gate.md / methodology.md
│   └── [critical-rules-discipline 等 70 条规则 → 各卫星 references/critical-rules-*.md]
├── templates/                               ← 13 主模板 + 29 个 variant（2026-10-12 实测）
│   ├── task_plan.md / progress.md / findings.md / verification.md / notepad-learnings.md
│   ├── knowledge-brief.md / subagent_dispatch.md / delivery-summary.md / shared-tracker.md / user-session-log.md / batch_report.md / session-handoff.md / deprecated.md
│   └── variant/                             ← 场景化变体（28/29 含「📚 必要知识储备」章节）
├── scripts/                                 ← 119 条目（110 .sh 含 76 个 selftest-*.sh + .ps1/.cjs/.ts/.tsv + lib//capabilities/ 子目录）
│   ├── run-selftests.sh                     # 全量 selftest 回归统一入口（--fresh 忽略缓存全量重跑）
│   ├── check-complete.sh / .ps1             # Stop hook 完成检测
│   ├── check-conflicts.sh                   # git 冲突分析
│   ├── check-doc-sync.sh                    # 计划陈旧度检测
│   ├── check-drift.sh                       # 漂移检测
│   ├── check-scope.sh                       # PreToolUse 范围阻断
│   ├── init-session.sh / .ps1               # 计划初始化
│   ├── plan-created.cjs                     # 哨兵清除（side + legacy 双清除, 含存在性验证）
│   ├── session-catchup.ts                   # 中断恢复
│   ├── sync-todos.sh                        # Phase ↔ Todo 同步
│   ├── task-plan-init.cjs                   # SessionStart 会话私有哨兵（plans/.plan_required_side/<sidkey>.plan_required）
│   ├── resolve-plan-dir.sh / set-active-plan.sh  # 活跃计划指针（side 会话私有优先 → 全局 fallback → mtime）
│   ├── attest-plan.sh / check-plan-dispatch.sh / rule-reserve.sh / ledger-append.sh / smart-merge-back.sh  # 守卫与簿记
│   └── selftest-*.sh ×76 + selftest-registry.tsv  # 自测守护族（不逐列）
├── lib/                                     ← Installer 库（6 个）
│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星）
│   ├── install-companion.sh                 # 顶层 skills/*/ 自动发现分发（含另 3 个收编卫星）
│   ├── detect-tools.sh / backup.sh / migrate-refs.sh / verify.sh
├── tests/
│   └── smoke.sh                             # 单元测试
├── docs/
│   └── ARCHITECTURE.md                      # 架构设计详细文档（含 10 技能分层图+路由表+回归命令）
├── install.sh                               ← 主入口（Phase 5.6 companion 分发 + Phase 5.7 provider fallback bind）
├── uninstall.sh                             ← 卸载
├── INSTALL.md / MIGRATION.md                ← 用户文档
├── companion/                               — 伴生 agents（drift-checker 等，跨平台部署用）
├── review-library/                          ← 审查模式库（池成员宿主可枚举分发）
└── .gitignore                               # 排除 .backup/
```

---

## config.json 键说明（常用键 21 项）

`config.json` 为 JSON Schema，**全部阈值集中管理**。常用键语义：

| 键 | 默认值 | 用途 | 关联 |
|----|--------|------|------|
| `max_vc` | 5 | 每个 plan 最低 VC 条目数 | Std 44 |
| `min_verification_per_phase` | 2 | 每个 Phase 最低 V-N 校验数 | Std 45 |
| `retry_count` | 3 | 同 V-N 连续 FAIL 最大重试次数 | Std 42 |
| `max_tool_calls_before_refresh` | 5 | 重读 task_plan.md 的工具调用阈值 | Std 10 |
| `max_view_browser_before_save` | 2 | view/browser/search 次数后写 findings.md | Rule 3 |
| `delegation_rate_floor` | 0.7 | 子代理执行 Phase 占比下限；低于此或主进程直做理由不在白名单 → outcome 最高 PARTIAL | Rule 25.4 |
| `escalation_threshold` | 3 | 连续失败触发 AskUserQuestion 的次数 | Rule 9 |
| `todo_sync_interval_calls` | 10 | PostToolUse 提醒原生 Todo 同步的工具调用间隔 | references/todo-sync.md |
| `plan_update_interval_minutes` | 15 | task_plan.md 最长存活时间；超时强制回写提醒 | check-doc-sync.sh 默认 |
| `stale_remind_cooldown_calls` | 10 | `[plan-compass]` 陈旧提醒触发后的冷却调用数（防未修复时重复轰炸） | zcode-posttooluse.sh |
| `prompt_note_interval` | 10 | `[plan-note]` 新指令判定提示的注入间隔（第 1 条 + 每 N 条一次） | zcode-userpromptsubmit.sh |
| `plan_dir_pattern` | `plans/{task-id}/` | 计划目录命名模式（任务隔离目录模板） | references/critical-rules.md |
| `autonomous_resume` | true | plan-resume 恢复触发点自主续推开关；true 时自动推下一个 pending Phase，省去显式确认 | Rule 24.5 |
| `findings_stale_minutes` | 20 | findings.md 最长存活时间；超时触发 `[plan-compass]` 陈旧提醒 | `[plan-compass]` 链路 |
| `compass_escalate_after` | 2 | 连续陈旧提醒未响应次数；达到后升级 `[plan-compass]` 警告 | Rule 19.7 |
| `progress_stale_minutes` | 25 | progress.md 最长存活时间；超时触发 `[plan-compass]` 陈旧提醒 | `[plan-compass]` 链路 |
| `template_priority` | `["project-level", "built-in"]` | 模板搜索顺序：项目级覆盖优先，内置兜底 | ../plan-template-kit/references/template-mapping.md |
| `subagent` | (见 config) | 子代理超时档位（explore/editor/debugger/executor） | Rule 22.3 |
| `interaction_mode` | `ask` | 交互双模式（Rule 28）：ask=关键决策点询问用户；silent=自主决策+静默决策清单登记；解析优先级 env > 计划配置表 > 本键 > 默认 ask | Rule 28.1 |
| `fmea_enforce` | `warn` | 规划期 FMEA 预演档位（enforce/warn/off），RPN>100 Phase 须登记兜底动作（methodology.md R2） | methodology.md |
| `content_quality_enforce` | `warn` | 内容质量门控档位（enforce/warn/off），内容型任务过去 AI 化清单+五维评分卡（methodology.md Q3/Q4） | methodology.md |

> config.json **无 `version` 字段**——版本信息以 `git log` + 版本历史段为准。

---

## 安装

### 一键安装（推荐）

```bash
bash <(curl -sSL https://raw.githubusercontent.com/napoler/task-planner-skill/main/install.sh)
```

### 本地开发

```bash
cd ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}
bash install.sh
```

### 高级选项

```bash
bash install.sh --canonical /opt/task-planner    # 自定义位置
bash install.sh --tools claude-code,zcode        # 仅装指定工具
bash install.sh --no-backup                      # 跳过备份
bash install.sh --dry-run                        # 演练
bash install.sh --no-verify                      # 跳过自检
```

详见 [INSTALL.md](INSTALL.md)。

---

## 升级

```bash
cd ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}
git pull
```

升级无需重跑 `install.sh`，除非：
- 新增工具类型
- SKILL.md frontmatter 字段变更
- hook 配置变更
- **新增卫星技能**（须先在 `lib/install-stub.sh:41` `SATELLITE_SKILLS` 登记 + SKILL.md 卫星路由表追加路由行，见 docs/ARCHITECTURE.md §升级与同步）

---

## 验证与回归

```bash
# 单元测试
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/tests/smoke.sh

# 安装验证
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/lib/verify.sh

# 全量 selftest 回归（忽略缓存全量重跑; 新基线/发布前用）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/run-selftests.sh --fresh
```

回归期望输出：末行 `Total: N PASS=x FAIL=y` 且 **FAIL=0**（缓存版省 CPU 不省正确性：`--fresh` 无视输入指纹缓存全量重跑；卫星 selftest 随各卫星落盘，如 `../task-dispatch/scripts/selftest-*.sh`，按需同口径跑批）。

---

## 关键约束

1. **hooks 不在 canonical SKILL.md 声明**：canonical SKILL.md 的 hooks 字段为空（`# hooks: <TOOL-ADAPTED>` 注释）；每工具部署位 SKILL.md 由 `lib/install-stub.sh` 的 `generate_stub_skill_md` 生成，才声明平台特定的 hook 格式。
2. **路径契约统一**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 形式，一级 env-var，二级 fallback。
3. **内容零重复**：references/templates 全部从 canonical rsync；scripts rsync + sed 路径改写。
4. **备份默认开启**：现有部署位自动备份到 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/.backup/<ts>/`。
5. **规则分层唯一副本（Rule 82）**：每条规则全文只在一个载体（核心或唯一卫星）；非核心域规则勿在核心技能展开，卫星侧改动经「落盘+删除+索引」原子配对。
6. **卫星注册三处联动**：新增卫星 = `lib/install-stub.sh` SATELLITE_SKILLS（显式 rsync 族）+ SKILL.md 卫星路由表行 + `lib/install-companion.sh` 顶层发现（收编既有 skill 时）；只改一处 = 部署残缺。

---

## 故障排查

| 问题 | 原因 | 解决 |
|------|------|------|
| hook 不触发 | 宿主配置未注册 | `bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts`（claude 位） |
| `TASK_PLANNER_ROOT` 未设 | shell 环境未 export | `.bashrc` 加 `export TASK_PLANNER_ROOT=$HOME/dev/task-planner-skill/skills/task-planner` |
| 旧部署位与新部署位冲突 | `user-invocable: true` 双注册 | 删除旧 stub 后重启 agent |
| 升级后行为异常 | 部署位仍指向旧版 | `cd ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner} && git pull` 后重启 agent |
| check-doc-sync 误判 STALE | fallback 链未含 canonical | 检查 `check-doc-sync.sh` 的 `for _c in` 列表 |
| 卫星技能未随 task-planner 装上 | SATELLITE_SKILLS 未登记 | 检查 `lib/install-stub.sh:41` 数组含全部 7 个显式 rsync 卫星 |

详见 [INSTALL.md §5 故障排查](INSTALL.md)。

---

## 版本历史

- **v2.1（2026-10-12）**：技能专业化拆分（task-v171）
  - 核心只负责四文件罗盘管理：SKILL.md 558→214 行瘦身，行数钉演进 558→275（≤250+25 边距）
  - 76 条既有规则按域分层至 10 卫星（3 新域 task-dispatch/task-discipline/media-planner + 7 收编），Rule 82 分层纪律新增（禁回潮禁镜像副本）
  - `lib/install-stub.sh` SATELLITE_SKILLS 4→7；本文档与 docs/ARCHITECTURE.md 重写反映分层架构+路由表+回归命令
- **v2.0（2026-08-29）**：多工具架构重构
  - 单一 canonical 仓（独立 git 项目）+ per-tool 部署
  - env-var 路径解析（`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}`）
  - 完整 installer 套件（install.sh + 6 lib + smoke test + 4 docs）
  - 5 hook 链路全部启用
  - GitHub: [napoler/task-planner-skill](https://github.com/napoler/task-planner-skill)
- **v2.0.3（2026-10-09 ~ 10）**：Critical Rules 计数多轮对齐（task-v149 对齐 Rules 1-65；task-v154 合并并集演进至 Rules 1-69；后续纪元由 selftest 宽容正则锚守护随动）
- **v1.2（2026-08-26）**：新增 todo-sync.md、worktree-isolation.md、4 个 variant 模板、check-conflicts.sh
- **v1.1（2026-08-19）**：新增 task-plan-init.cjs SessionStart hook、task-drift-guard 集成
- **v1.0（2026-08-12）**：初始版本，Manus context engineering 原则实现
