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
| 1 | 全量同步 15 技能 canonical → `~/.zcode/skills/`（`rsync -a`，不 `--delete` 以保留运行时态） | 主进程(Bash) | pending | rsync 输出 + `diff -rq`=0 |
| 2 | 验证部署位（diff=0 + 部署位跑 run-selftests.sh 子集） | 主进程(Bash) | pending | 命令输出 |
| 3 | zcode-config 提交（**仅** 15 技能目录，不碰他域未提交变更）+ push origin main | 主进程(Bash) | pending | git log + push 输出 |
| 4 | 确认 task-planner-skill 仓已推送（origin/master=5ccf308） | 主进程(Bash) | pending | git log origin/master |

## Verification Contract
| VC | 命令 | 判据 |
|----|------|------|
| VC-1 | `diff -rq <canonical>/<sat> ~/.zcode/skills/<sat>` × 15 | 0 差异（运行时态目录除外） |
| VC-2 | `cd ~/.zcode/skills/task-planner && bash scripts/run-selftests.sh --only media-agents` | PASS=10 FAIL=0 |
| VC-3 | `cd ~/.zcode && git log --oneline -1 && git status --short skills/` | 新提交含 15 技能目录；status 干净（他域未提交变更不纳入） |
| VC-4 | `cd /mnt/data/dev/task-planner-skill && git log --oneline -1 origin/master` | =5ccf308 |

## 🔀 隔离决策
- 部署目标 `~/.zcode/skills/**` 属 §六 保护区；用户 R1「完成部署并推送」= 显式授权（§十一 11.5.1 例外）。同步为全量副本（非编辑保护区逻辑），zcode-config 仓库 git 可回滚。
- task-planner-skill 仓侧无新改动（task-v191 已提交推送），本任务仅动部署位 + zcode-config。

## 范围外（不碰）
- `~/.zcode/agents/**`、`~/.zcode/cli/**`（模型绑定/记忆等他域，本任务未改其源）
- zcode 位非 task-planner-skill 来源的技能（graphify/prompt-master/…）
- zcode-config 已存在的他域未提交变更（cli/memories、v2/setting.json 等，属自动备份域）