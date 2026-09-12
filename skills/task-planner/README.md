# task-planner — 任务规划与漂移检测技能

> **多工具架构 v2（2026-08-29）**：canonical source + per-tool stub 适配，零内容重复，env-var 路径解析。

## 快速链接

- 📦 **GitHub**：[napoler/task-planner-skill](https://github.com/napoler/task-planner-skill)
- 🚀 **一键安装**：`bash <(curl -sSL https://raw.githubusercontent.com/napoler/task-planner-skill/main/install.sh)`
- 📖 **详细指南**：[INSTALL.md](INSTALL.md) · [MIGRATION.md](MIGRATION.md)
- 🏗️ **架构设计**：[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 概述

结构化任务规划技能，支持多进程/多目录 plan 管理，内置周期性漂移检测。

**核心特性**：
- **5 个生命周期 hook**：SessionStart（哨兵）/ PreToolUse（范围阻断 + 委派门控 + Agent 派发契约守卫，matcher 须含 Agent）/ PostToolUse（计划陈旧检测）/ UserPromptSubmit（新指令影响判定）/ Stop（完成检测）
- **原生 Todo 双向同步**：S1-S5 强制同步时机（计划文档 ↔ TodoWrite/Task 系统）
- **漂移检测**：每 phase 完成后自动调用 `task-drift-guard`
- **工作树隔离**：实现类任务默认首选 worktree（防改坏运行中基础设施）
- **场景化模板**：12 个 variant 模板（research/diagnostic/writing/publish/code-edit/refactor/bugfix/migration/test-writing/deployment/performance-tuning/schema-migration；不匹配时回退通用 task_plan.md）按 `template_type` 字段自动分发；全部 20 个模板统一含「📚 必要知识储备」章节（任务知识库对齐）

---

## 多工具架构

```
┌──────────────────────────────────────────────────────────┐
│ canonical source: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/                    │
│   (独立 git 仓库, 41 文件, 4 commits)                    │
│   - SKILL.md (剥除 hooks)                                │
│   - references/  (8 篇规则)                              │
│   - templates/   (5 核心 + 3 辅助 + 12 variant)          │
│   - scripts/     (16 个工具脚本)                         │
│   - lib/         (5 个 installer 脚本)                   │
│   - tests/       (smoke.sh 16/16 pass)                   │
│   - install.sh / uninstall.sh                            │
└──────────────────┬───────────────────────────────────────┘
                   │  rsync + sed-rewrite
       ┌───────────┼───────────┬───────────┬────────────┐
       ▼           ▼           ▼           ▼            ▼
  ~/.claude   ~/.zcode    ~/.opencode  ~/.cursor   ~/.continue
  /skills/    /skills/    /skills/     /skills/    /skills/
  task-planner/                                           
  (thin shell + content rsync)
```

每个工具的 stub：
- **SKILL.md** 薄壳（< 4KB）— 仅声明该平台 hook 格式
- **scripts/** rsync 副本 + 路径改写为 `${TASK_PLANNER_ROOT:-...}`
- **references/ + templates/** 直接 rsync（与 canonical 一致）

升级流程：`cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner} && git pull` → 所有 stub 自动生效。

---

## 文件结构（canonical 仓）

```
${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/                          ← canonical source (git 仓库)
├── SKILL.md                                 ← 工具无关主文档（hooks 字段已剥除）
├── config.json                              ← 阈值配置（18 键）
├── README.md / examples.md / reference.md
├── references/                              ← 8 篇规则文档
│   ├── critical-rules.md                    # Rules 1-27（1-12 核心执行约束 + 13-27 P0/P1 扩展门控）
│   ├── todo-sync.md                         # S1-S5 同步契约
│   ├── worktree-isolation.md                # 隔离合约
│   ├── template-mapping.md                  # variant 选择决策树
│   ├── template-guide.md                    # 模板定制指南
│   ├── goal-gate.md / completion-gate.md / billing.md
├── templates/                               ← 5 核心 + 3 辅助 + 12 个 variant
│   ├── task_plan.md / progress.md / findings.md / verification.md / notepad-learnings.md
│   └── variant/
│       ├── research-type.md                 # 调研任务
│       ├── writing-type.md                  # 写作任务
│       ├── diagnostic-type.md               # 诊断/修复
│       └── publish-type.md                  # 发布/集成
├── scripts/                                 ← 16 个工具脚本
│   ├── check-complete.sh / .ps1             # Stop hook 完成检测
│   ├── check-conflicts.sh                   # git 冲突分析
│   ├── check-doc-sync.sh                    # 计划陈旧度检测
│   ├── check-drift.sh                       # 漂移检测
│   ├── check-scope.sh                       # PreToolUse 范围阻断
│   ├── init-session.sh / .ps1               # 计划初始化
│   ├── plan-created.cjs                     # 哨兵清除（本会话 side + legacy 双清除，含计划存在性验证）
│   ├── session-catchup.ts                   # 中断恢复
│   ├── sync-ide-folders.ts                  # IDE 折叠区同步
│   ├── sync-todos.sh                        # Phase ↔ Todo 同步
│   ├── task-plan-init.cjs                   # SessionStart 会话私有哨兵（plans/.plan_required_side/<sidkey>.plan_required）
│   ├── zcode-{sessionstart,pretooluse,posttooluse,userpromptsubmit}.sh  # ZCode 适配器
│   ├── plan-doctor.sh                       # 计划机制一键自检（移植自 planning-with-files v3）
│   ├── resolve-plan-dir.sh                  # 解析活跃计划 task_plan.md 路径（可选第 2 参 sid：.active_plan_side/<sid>.active_plan 会话层指针 TTL 24h → 全局 legacy .active_plan → mtime 最新；slug 校验）
│   ├── set-active-plan.sh                   # 会话私有指针 .active_plan_side/<sid>.active_plan + 全局 legacy .active_plan (set/gc/--show)
│   ├── zcode-sessionstart.sh                # ZCode SessionStart 适配器（写会话私有 side 哨兵 + additionalContext 注入；sid 缺失不写哨兵 fail-open）
│
│   # [2026-09-10 task-planrequired-race] 哨兵会话私有化：位置 `plans/.plan_required_side/<sidkey>.plan_required`（sidkey=uuid core，剥 sess 前缀）；清除=plan-created.cjs（存在性验证）/ D10 check-time 自动仲裁 / resume 判定（启动即有有效计划则哨兵不启用）；gc 扩展清扫 side 哨兵（24h TTL）；legacy `<root>/.plan-required` 不再写入、仅作兼容读取
│   # [2026-09-10 task-path-identity] 派发契约路径已身份判定化（stat inode / realpath -m），单拼写即可，混拼写兼容
├── lib/                                     ← Installer 库（v2 新增）
│   ├── detect-tools.sh                      # 探测已部署工具
│   ├── backup.sh                            # 备份现有 stub
│   ├── install-stub.sh                      # 每工具 stub 安装
│   ├── migrate-refs.sh                      # external refs 迁移
│   └── verify.sh                            # 7 项安装验证
├── tests/
│   └── smoke.sh                             # 16 项单元测试（全部通过）
├── docs/
│   └── ARCHITECTURE.md                      # 架构设计详细文档
├── install.sh                               ← 主入口（v2 新增）
├── uninstall.sh                             ← 卸载（v2 新增）
├── INSTALL.md / MIGRATION.md                ← 用户文档
├── .gitignore                               # 排除 .backup/
├── companion/                               — 伴生 agents（plan-writer / article-batch-publisher / article-field-fixer，跨平台部署用）
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
| `template_priority` | `["project-level", "built-in"]` | 模板搜索顺序：项目级覆盖优先，内置兜底 | references/template-mapping.md |
| `subagent` | (见 config) | 子代理超时档位（explore/editor/debugger/executor） | Rule 22.3 |
| `interaction_mode` | `ask` | 交互双模式（Rule 28）：ask=关键决策点询问用户；silent=自主决策+静默决策清单登记；解析优先级 env > 计划配置表 > 本键 > 默认 ask | Rule 28.1 |
| `fmea_enforce` | `warn` | v063 规划期 FMEA 预演档位（enforce/warn/off），RPN>100 Phase 须登记兜底动作（methodology.md R2） | v063 |
| `content_quality_enforce` | `warn` | v063 内容质量门控档位（enforce/warn/off），内容型任务过去 AI 化清单+五维评分卡（methodology.md Q3/Q4） | v063 |

> config.json **无 `version` 字段**——版本信息以 `git log` + `版本历史`段为准。

---

## 安装

### 一键安装（推荐）

```bash
bash <(curl -sSL https://raw.githubusercontent.com/napoler/task-planner-skill/main/install.sh)
```

### 本地开发

```bash
cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}
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
cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}
git pull
```

升级无需重跑 `install.sh`，除非：
- 新增工具类型
- SKILL.md frontmatter 字段变更
- hook 配置变更

---

## 验证

```bash
# 单元测试
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/tests/smoke.sh

# 安装验证
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/lib/verify.sh
```

期望输出：
- smoke: `16 pass / 0 fail`
- verify: 至少 7 pass / 0 fail（zcode stub 未迁移时会有 4 fail）

---

## 关键约束

1. **hooks 必须在 stub 内声明**：canonical SKILL.md 已剥除 hooks 字段。每工具的 stub SKILL.md 才声明平台特定的 hook 格式。
2. **路径契约统一**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 形式，一级 env-var，二级 fallback。
3. **内容零重复**：references/templates 全部从 canonical rsync；scripts rsync + sed 路径改写。
4. **备份默认开启**：现有 stub 自动备份到 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/.backup/<ts>/`。
5. **stub 薄壳**：SKILL.md 必须 < 15KB（canonical 全文 20KB；stub 仅声明 hook + 引用表）。

---

## 故障排查

| 问题 | 原因 | 解决 |
|------|------|------|
| hook 不触发 | settings.local.json 未注册 | `bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts` |
| `TASK_PLANNER_ROOT` 未设 | shell 环境未 export | `.bashrc` 加 `export TASK_PLANNER_ROOT=$HOME/dev/task-planner` |
| 旧 stub 与新 stub 冲突 | `user-invocable: true` 双注册 | 删除旧 stub 后重启 agent |
| 升级后行为异常 | stub 仍指向旧版 | `cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner} && git pull` 后重启 agent |
| check-doc-sync 误判 STALE | fallback 链未含 canonical | 检查 `check-doc-sync.sh` line 30 的 `for _c in` 列表 |

详见 [INSTALL.md §5 故障排查](INSTALL.md)。

---

## 版本历史

- **v2.0（2026-08-29）**：多工具架构重构
  - 单一 canonical 仓（独立 git 项目）+ per-tool stub
  - env-var 路径解析（`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}`）
  - 完整 installer 套件（install.sh + 5 lib + smoke test + 4 docs）
  - 5 hook 链路全部启用
  - GitHub: [napoler/task-planner-skill](https://github.com/napoler/task-planner-skill)
- **v1.2（2026-08-26）**：新增 todo-sync.md、worktree-isolation.md、4 个 variant 模板、check-conflicts.sh
- **v1.1（2026-08-19）**：新增 task-plan-init.cjs SessionStart hook、task-drift-guard 集成
- **v1.0（2026-08-12）**：初始版本，Manus context engineering 原则实现
