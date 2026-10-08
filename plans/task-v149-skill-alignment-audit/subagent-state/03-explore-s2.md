# S2 仓级文档滞后扫描检查点

**扫描员**: S2-explore  
**仓库**: /mnt/data/dev/task-planner-skill (master 21f7e6b)  
**扫描时间**: 2026-10-08  
**状态**: 完成

---

## 实态基线（一手证据）

| 项目 | 实态 | 证据命令 |
|------|------|----------|
| Rule 数量 | **64 条** (### 1 .. ### 64) | `grep -c '^### [0-9]' skills/task-planner/references/critical-rules.md` → 64 |
| selftest-*.sh | **62 个** | `ls skills/task-planner/scripts/selftest-*.sh \| wc -l` → 62 |
| templates/ 顶层 | **12 个** md | `ls skills/task-planner/templates/*.md \| wc -l` → 12 |
| templates/variant/ | **29 个** | `ls skills/task-planner/templates/variant/ \| wc -l` → 29 |
| companion/agents/ | **7 个** agent | `ls skills/task-planner/companion/agents/` → 7 (含 drift-checker) |
| references/ | **10 个** md | `ls skills/task-planner/references/` → 10 |
| scripts/ 总文件 | **106 个** | `ls skills/task-planner/scripts/ \| wc -l` → 106 |
| scripts/*.sh | **96 个** (62 selftest + 34 非 selftest) | `ls skills/task-planner/scripts/*.sh \| wc -l` → 96 |
| 部署位 | /home/terry/.zcode/skills/task-planner/ 存在 (62 selftest) | `ls` 确认 |

---

## 发现清单

### README_zh.md

#### 1. Rule 数量声明滞后 (H)
- **位置**: README_zh.md:136
- **文档现文**: `critical-rules.md ← Rules 1-45 核心执行约束`
- **实态**: Rules 1-64（critical-rules.md 含 ### 1 到 ### 64）
- **建议**: 改为 `Rules 1-64`

#### 2. 文档索引 Rule 数量滞后 (H)
- **位置**: README_zh.md:229
- **文档现文**: `Rules 1-45 —— 自定义前必读`
- **实态**: Rules 1-64
- **建议**: 改为 `Rules 1-64`

#### 3. companion/agents 数量滞后 (M)
- **位置**: README_zh.md:114
- **文档现文**: `6 个伴生 agent（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor）`
- **实态**: 7 个（新增 drift-checker）
- **建议**: 改为 `7 个伴生 agent` 并补 drift-checker

---

### INSTALL_zh.md

#### 4. selftest 数量严重滞后 (H)
- **位置**: INSTALL_zh.md:293
- **文档现文**: `81 项: .sh 72 个（含 42 selftest）`
- **实态**: 106 项总计，96 个 .sh（含 62 selftest）
- **建议**: 改为 `106 项: .sh 96 个（含 62 selftest）`

#### 5. templates 数量滞后 (M)
- **位置**: INSTALL_zh.md:295-301
- **文档现文**: `39 个模板: 顶层 10 个 md ... + variant/ 29 类`
- **实态**: 顶层 12 个 md + variant 29 个 = 41 个
- **建议**: 改为 `41 个模板: 顶层 12 个 md + variant/ 29 类`

#### 6. companion/agents 数量滞后 (M)
- **位置**: INSTALL_zh.md:305-309
- **文档现文**: `6 个配套 agent: plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor`
- **实态**: 7 个（新增 drift-checker）
- **建议**: 改为 `7 个配套 agent` 并补 drift-checker

#### 7. references 数量滞后 (M)
- **位置**: INSTALL_zh.md:302-304
- **文档现文**: `8 个: critical-rules / completion-gate / goal-gate / dispatch-examples / methodology / todo-sync / worktree-isolation / batch-quality-gate`
- **实态**: 10 个（新增 agent-coverage / capability-registry）
- **建议**: 改为 `10 个` 并补 agent-coverage / capability-registry

---

### CHANGELOG.md

#### 8. [Unreleased] 段条目顺序不一致 (L)
- **位置**: CHANGELOG.md:8-15
- **文档现文**: Rule 63 → Rule 64 → Rule 61（按 63/64/61 顺序排列）
- **实态**: git log 显示合并顺序为 v146 Rule 61 → v147 Rule 63 → v148 Rule 64
- **建议**: 按时间顺序排列为 Rule 61 → Rule 63 → Rule 64

---

### CLAUDE.md

#### 9. Rule 数量声明滞后 (H)
- **位置**: CLAUDE.md:33
- **文档现文**: `critical-rules.md ← Rules 1-39 核心执行约束`
- **实态**: Rules 1-64
- **建议**: 改为 `Rules 1-64`

#### 10. 目录结构缺少 companion/agents/ (M)
- **位置**: CLAUDE.md:13-37
- **文档现文**: 目录树中无 companion/agents/ 条目
- **实态**: companion/agents/ 存在，含 7 个 agent
- **建议**: 补充 `├── companion/agents/ ← 7 个伴生 agent（plan-writer / drift-checker / ...）`

#### 11. scripts/ 列表严重不完整 (M)
- **位置**: CLAUDE.md:19-24
- **文档现文**: 仅列 5 个脚本（init-session/check-scope/sync-todos/check-complete/session-catchup）
- **实态**: 96 个 .sh（含 62 selftest + 34 工具脚本）
- **建议**: 更新为完整列表或概括描述

---

### CONTRIBUTING.md / CONTRIBUTING_zh.md

#### 12. install.sh flag 描述需验证 (L)
- **位置**: CONTRIBUTING.md:63 / CONTRIBUTING_zh.md:63
- **文档现文**: `flag 面 = --canonical / --tools / --no-verify / --no-backup / --dry-run`
- **实态**: 需验证 install.sh 实际支持的 flag（可能新增 --skip-fmea-check 等）
- **建议**: 运行 `bash skills/task-planner/install.sh --help` 验证

---

### examples/full-workflow.md

#### 13. 脚本路径过时 (H)
- **位置**: full-workflow.md:20
- **文档现文**: `bash scripts/install.sh`
- **实态**: install.sh 在 `skills/task-planner/install.sh`
- **建议**: 改为 `bash skills/task-planner/install.sh`

#### 14. 脚本路径过时 (H)
- **位置**: full-workflow.md:26
- **文档现文**: `bash scripts/validate.sh`
- **实态**: 验证脚本在 `skills/task-planner/lib/verify.sh`
- **建议**: 改为 `bash skills/task-planner/lib/verify.sh`

#### 15. session-catchup 文件名错误 (M)
- **位置**: full-workflow.md:41
- **文档现文**: `session-catchup.py`
- **实态**: 实际为 `session-catchup.ts`
- **建议**: 改为 `session-catchup.ts`

---

### skills/task-planner/README.md

#### 16. Rule 数量声明滞后 (H)
- **位置**: skills/task-planner/README.md:72
- **文档现文**: `Rules 1-39（1-12 核心执行约束 + 13-35 P0/P1 扩展门控...）`
- **实态**: Rules 1-64
- **建议**: 改为 `Rules 1-64` 并补 40-64 描述

#### 17. scripts 数量严重滞后 (M)
- **位置**: skills/task-planner/README.md:86
- **文档现文**: `17 个工具脚本`
- **实态**: 96 个 .sh（含 62 selftest + 34 非 selftest）
- **建议**: 改为 `96 个 .sh（含 62 selftest）`

#### 18. references 数量滞后 (M)
- **位置**: skills/task-planner/README.md:71
- **文档现文**: `8 篇规则文档`
- **实态**: 10 篇
- **建议**: 改为 `10 篇规则文档`

#### 19. companion/agents 描述不完整 (M)
- **位置**: skills/task-planner/README.md:120
- **文档现文**: `plan-writer / article-batch-publisher / article-field-fixer`
- **实态**: 7 个（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor / drift-checker）
- **建议**: 更新为完整列表

---

### skills/task-planner/INSTALL.md

#### 20. variant 模板数量滞后 (M)
- **位置**: skills/task-planner/INSTALL.md:250
- **文档现文**: `12 个 variant 模板文件必须齐全`
- **实态**: 29 个 variant 模板
- **建议**: 改为 `29 个 variant 模板文件`

---

### skills/task-planner/MIGRATION.md

#### 21. smoke.sh 测试数量需验证 (L)
- **位置**: MIGRATION.md:45
- **文档现文**: `[smoke] summary: 16 pass / 0 fail`
- **实态**: 需运行 `bash tests/smoke.sh` 确认实际数量
- **建议**: 验证并更新

---

### skills/task-planner/docs/ARCHITECTURE.md

#### 22. references 数量滞后 (L)
- **位置**: docs/ARCHITECTURE.md:13
- **文档现文**: `9 篇规则文档`
- **实态**: 10 篇
- **建议**: 改为 `10 篇规则文档`

#### 23. scripts 数量滞后 (L)
- **位置**: docs/ARCHITECTURE.md:17
- **文档现文**: `90 个文件`
- **实态**: 106 个文件
- **建议**: 改为 `106 个文件`

#### 24. selftest 数量滞后 (H)
- **位置**: docs/ARCHITECTURE.md:81
- **文档现文**: `selftest-*.sh ×51`
- **实态**: 62 个 selftest
- **建议**: 改为 `selftest-*.sh ×62`

---

## 统计

| 严重度 | 数量 |
|--------|------|
| H (高) | 8 |
| M (中) | 10 |
| L (低) | 6 |
| **总计** | **24** |

---

## 未验证项

1. CONTRIBUTING.md / CONTRIBUTING_zh.md 中 install.sh flag 面是否与实际一致（需运行 --help）
2. MIGRATION.md 中 smoke.sh 测试数量（需运行测试）
3. CHANGELOG.md 中已发布版本段的日期/编号单调性（需完整 git log 对照）

---

## 检查点写入时间

2026-10-08 S2 扫描完成
