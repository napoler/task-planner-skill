# S12 部署准备批检查点 — task-v149（D20/D21/D23/D25）

- 执行体：executor（sonnet-1）
- 时间：2026-10-08
- 工作区：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 权限约束：仅改 install-companion.sh + agent-coverage.md；templates/ 只读裁定
- 状态：DONE

## D25: install-companion.sh 三处修复

### 1. COMPAANION_DIR 拼写修正
- **位置**: skills/task-planner/lib/install-companion.sh:20
- **原文**: `COMPAANION_DIR="${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion"`
- **修正**: `COMPANION_DIR=...`（7 处引用全部同步改：20/39/40/63/149/152/154 行）
- **注释**: `[2026-10-08 task-v149 D25] 修正变量名拼写 COMPAANION_DIR→COMPANION_DIR`

### 2. BACKUP_DIR 扫描路径外移
- **位置**: skills/task-planner/lib/install-companion.sh:63
- **原文**: `BACKUP_DIR="$COMPANION_DIR/.backup-$(date +%Y%m%d-%H%M%S)"`
- **修正**: `BACKUP_DIR="$HOME/.task-planner-backups/companion/$(date +%Y%m%d-%H%M%S)"`
- **依据**: 仓库内 grep "skill-deploy-backups"=0 命中；部署位有 ~/skill-deploy-backups-* 12 目录（install.sh 惯例）；按任务要求无仓库惯例则用 ~/.task-planner-backups/companion/<ts>/
- **注释**: `[2026-10-08 task-v149 D25] 备份根移出技能扫描路径`

### 3. mkdir/cp 路径不一致修正
- **位置**: skills/task-planner/lib/install-companion.sh:118-119
- **原文**: `mkdir -p "$BACKUP_DIR/$(dirname "${dst#$TARGET_ROOT/}")"` + `cp "$dst" "$BACKUP_DIR/$(basename "$dst")"`
- **修正**: `cp "$dst" "$BACKUP_DIR/${dst#$TARGET_ROOT/}"`（与 mkdir 对齐）
- **注释**: `[2026-10-08 task-v149 D25] cp 目标路径与 mkdir 对齐`

### 自验
- `bash -n skills/task-planner/lib/install-companion.sh` → SYNTAX OK
- BACKUP_DIR 逻辑走查：dst=/home/terry/.zcode/agents/explorer.md → ${dst#$TARGET_ROOT/}=agents/explorer.md → mkdir -p "$BACKUP_DIR/agents" + cp "$dst" "$BACKUP_DIR/agents/explorer.md" → 结构对齐，不再扁平化

## D20: agent-coverage.md video-fix-executor 登记失实修正

### 实态核实
- companion/agents/ 实际文件（7 个）：article-batch-publisher.md, article-field-fixer.md, complex-planner.md, drift-checker.md, image-generation-executor.md, plan-writer.md, video-generation-executor.md
- **video-fix-executor.md 不存在**

### 三处修正
1. **行 24（第 36 行）**: 原 `B*：同上，v124 承接` → `**未落地**：video-fix-executor 实体不存在...落地条件=videop1-video-fix SOP 项目资产可用 [2026-10-08 task-v149 D20]`
2. **A 类表（第 50 行）**: 原 `v124 补 video-generation-executor / video-fix-executor 两专用体...v124 承接` → `v124 补 video-generation-executor（在位）；video-fix-executor 未落地...部分承接`
3. **§四 增补候选（第 120 行）**: 原 `v124 已补 image-generation-executor + video-generation-executor + video-fix-executor 两族三件` → `v124 已补 image-generation-executor + video-generation-executor 两件（在位）；video-fix-executor 未落地...`

## D23: complex-planner 档位统一登记面

### truth source
- companion/agents/complex-planner.md frontmatter: `model: "account:zai-individual-coding-plan/GLM-5.3"`

### 统一登记
- **行 1（第 13 行）**: `complex-planner(D1/D2)` → `complex-planner(D1/D2, GLM-5.3)`
- **行 18（第 30 行）**: `complex-planner(D2)` → `complex-planner(D2, GLM-5.3)`

### SKILL.md 路由表
- SKILL.md:401 描述 "GLM5.3/Opus 级" 与 frontmatter 基本一致，无同歧义 → 只报告不改

## D21: 模板面裁定

### 裁定表

| 检查项 | grep 结果 | 裁定 | 理由 |
|--------|----------|------|------|
| 创作单元并行表/Lane 状态表 | 0 命中 | **SKIP** | SKILL.md:265 声明"主进程单写者"=设计预期，非模板预置（手写声明=设计预期登记 SKIP） |
| mini-lite 缺「工具选择与编排」 | 有豁免声明（Rule 40.2/task-v097） | **SKIP** | 38.3 区块白名单延伸，显式豁免声明 |
| mini-lite 缺「隔离决策」 | 无此区块 | **SKIP** | 38.3 区块白名单仅含 5 区块（Goal/VC/执行范围限制表/单 Phase/Handoff 表），「隔离决策」不在白名单内 |
| standard 档 variant 缺「隔离决策」 | 部分缺失（video-fix/research/publish/video/rule-enhancement/diagnostic/writing-type 7 个 variant 无此区块） | **待复核** | 无明确规则声明 standard 档必需区块清单（38.3 只定义 mini-lite 白名单），拿不准登记待复核不改动 |

### 未改动文件
- templates/ 下所有文件均未改动（裁定结果=SKIP/待复核，无缺陷需补骨架）

## 改动文件清单

| 文件 | 改动 |
|------|------|
| skills/task-planner/lib/install-companion.sh | 3 处（COMPAANION_DIR 拼写+BACKUP_DIR 外移+mkdir/cp 对齐） |
| skills/task-planner/references/agent-coverage.md | 5 处（D20 三处 video-fix-executor 实态+D23 两处 complex-planner 档位） |

## 未验证项
- standard 档 variant 缺「隔离决策」是否为缺陷（待复核）
- video-fix-executor 落地条件（videop1-video-fix SOP 项目资产可用性）
