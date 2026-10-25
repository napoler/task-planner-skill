# Task Plan: task-v192-deploy-zcode（部署到 zcode 位并推送）

## 🎯 用户需求原文（Rule 51.1 逐条抄录）
- **R1**: 「完成部署并推送。」（承接 task-v191 遗留第 6 项=部署位 `~/.zcode/skills/**` 未同步；「推送」= 部署结果持久化）<sub>（[目标]）</sub>

## Goal
把 task-planner-skill 仓 canonical 的 **15 个技能全量副本**同步到 zcode 部署位 `~/.zcode/skills/`（`~/.zcode` = `napoler/zcode-config` 仓库 main 分支），并推送部署结果（zcode-config 仓库）；task-planner-skill 仓本身已于 task-v191 推送至 origin/master。

## 背景（已核实的一手事实）
- `~/.zcode` 是 git 仓库（remote=`git@github.com:napoler/zcode-config.git`，branch=main），部署位 = 其中的**全量副本**（ARCHITECTURE §6「实盘=各宿主位均为全量副本，非薄壳+rsync 指针」）。
- 部署位当前**陈旧**：task-planner 有 36 文件落后 + 缺 3 新文件（v189 F11：scripts/schemas/、verify_io.sh、selftest-verify-io.sh）；session-catchup.ts 仍 `#!/usr/bin/env bun`。
- 15 个技能目录 = 仓 `skills/` 全集，zcode 位全部齐备。
- zcode 位仅应同步这 15 个 task-planner-skill 自有技能，**不得**触碰 zcode 位其他来源技能（graphify/prompt-master/verification-before-completion 等）。

## Phases
| Phase | 动作 | Executor | 状态 | 证据 |
|-------|------|----------|------|------|
| 1 | 全量同步 15 技能 canonical → `~/.zcode/skills/`（`rsync -a`，不 `--delete` 以保留运行时态） | 主进程(Bash) | complete | 10-19 首轮 diff -rq=0；10-26 用户指令「完成本地平台部署」复同步 15/15，diff=0，zcode-config 提交 `df22f48`（16 文件） |
| 2 | 验证部署位（diff=0 + 部署位跑 run-selftests.sh 子集） | 主进程(Bash) | complete | 10-26 四位（zcode/claude/cursor/agents-plan-resume）逐技能 `diff -rq` 内容差异=0；canonical 回归 93/93（task-audit-tail-20261026 check-complete 全门 exit 0） |
| 3 | zcode-config 提交（**仅** 15 技能目录，不碰他域未提交变更）+ push origin main | 主进程(Bash) | complete | 10-19 `2c51f48` 已 push；10-26 复同步本地提交 `df22f48`（16 文件，他域 27 脏文件未纳入）；claude 位 10-26 本地提交 `8ed938c`（297 文件，仅 15 技能 pathspec）；cursor/agents 位非 git 无需提交。push 待用户指令（本地部署范围内） |
| 4 | 确认 task-planner-skill 仓已推送（origin/master=5ccf308） | 主进程(Bash) | complete | 10-19 时点成立；10-26 复核：本地 HEAD `6324ce2` 领先 origin/master `2e7976a`，领先提交推送待用户指令 |
| 5 | 三仓推送远程（用户 10-26 指令「推送修改到远程」）：源仓 master + zcode-config main（`df22f48`）+ claude-config master（`8ed938c`） | 主进程(Bash) | complete | 10-26 推送成功：源仓 `2e7976a..6246f25`、zcode-config `7a2c789..df22f48`、claude-config `c12273d..8ed938c`，push 前三仓 behind=0 无分叉 |

## Phase 状态锚（sync-todos.sh 可解析形态：表格是人类可读面，下方列表锚=机器计数面，两者必须同步翻转）
<!-- 形态约束：脚本只认 `### Phase N:` + 行首 `- **Status:**`（v176/D1 锚定口径）；本计划 Phase 表为表格形态，机器面在此镜像，防 INDEX 0/0 失真（task-v192 簿记缺口判例） -->

### Phase 1: 全量同步 15 技能至 zcode 位
- **Status:** complete

### Phase 2: 验证部署位
- **Status:** complete

### Phase 3: 提交部署仓
- **Status:** complete

### Phase 4: 确认源仓已推送
- **Status:** complete

### Phase 5: 三仓推送远程
- **Status:** complete

## Verification Contract
| VC | 命令 | 判据 |
|----|------|------|
| VC-1 | `diff -rq <canonical>/<sat> ~/.zcode/skills/<sat>` × 15 | 0 差异（运行时态目录除外） |
| VC-2 | `cd ~/.zcode/skills/task-planner && bash scripts/run-selftests.sh --only media-agents` | PASS=10 FAIL=0 |
| VC-3 | `cd ~/.zcode && git log --oneline -1 && git status --short skills/` | 新提交含 15 技能目录；status 干净（他域未提交变更不纳入） |
| VC-4 | `cd /mnt/data/dev/task-planner-skill && git log --oneline -1 origin/master` | =5ccf308 |
| VC-5 | 三仓各 `git fetch && git rev-list --count origin/<br>..HEAD` | 均=0（无未推送提交）；push 失败/分叉=停报 |

## 🔀 隔离决策
- 部署目标 `~/.zcode/skills/**` 属 §六 保护区；用户 R1「完成部署并推送」= 显式授权（§十一 11.5.1 例外）。同步为全量副本（非编辑保护区逻辑），zcode-config 仓库 git 可回滚。
- task-planner-skill 仓侧无新改动（task-v191 已提交推送），本任务仅动部署位 + zcode-config。

## 范围外（不碰）
- `~/.zcode/agents/**`、`~/.zcode/cli/**`（模型绑定/记忆等他域，本任务未改其源）
- zcode 位非 task-planner-skill 来源的技能（graphify/prompt-master/…）
- zcode-config 已存在的他域未提交变更（cli/memories、v2/setting.json 等，属自动备份域）