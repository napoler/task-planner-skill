# 交付总结 — task-v192-deploy-zcode（部署到 zcode 位并推送）

## 说明
承接 task-v191 遗留第 6 项「部署位 `~/.zcode/skills/**` 未同步」。把 task-planner-skill 仓 canonical 的 15 个技能**全量副本**同步到 zcode 部署位（`~/.zcode` = `napoler/zcode-config` 仓 main 分支），并推送部署结果。

## 产出
- **15 技能全量同步**：canonical `/mnt/data/dev/task-planner-skill/skills/` → `~/.zcode/skills/`（`rsync -a`，不 `--delete` 保留运行时态）：
  task-planner + 14 卫星（task-dispatch/task-discipline/media-planner/plan-collab-router/plan-research-router/plan-resume/plan-template-kit/plan-cost-guard/progress-tracker/task-drift-guard/todo-skill/verification-gate/iterative-optimizer/error-fix-prompt-forge）
- 携带 task-v188/189/190/191 全部修正（bun→node、Rules 1-92 口径、跨技能引用、v189 F11 新脚本 schemas/verify_io/selftest-verify-io、frontmatter、索引）
- **zcode-config 提交 + 推送**：`2c51f48`（`1b5d4b0..2c51f48 main->main`），67 文件，仅 `skills/` 变更（他域未提交变更 cli/memories、v2、plans/.drift-rhythm 未纳入）

## 审查（证据）
- `diff -rq` canonical vs 部署位（15 技能）：**0 内容差异**（运行时态目录除外）
- 部署位 spot 核验：`session-catchup.ts` shebang=`node --experimental-strip-types`、`SKILL.md` `Rules 1-92`×2
- 源仓回归（task-v191）：`run-selftests.sh --fresh` = 92/92 PASS
- **部署位 selftest 说明**：`selftest-media-agents` 在部署位仅 MA-08 失败（9 PASS），根因=MA-08 引用 `$SKILL_ROOT/../../README_zh.md`（**仓库根文件**，部署位不含仓库根）；其余 MA-01/02/03/04/05/06/07/09/10 全 PASS。此为 selftest 的既有路径特性（设计为在 canonical 仓运行），**非部署缺陷**；canonical 仓内 92/92 全绿。

## 风险
- 部署位 `~/.zcode/skills/**` 属 §六 保护区，本次经用户 R1「完成部署并推送」显式授权
- zcode-config 为跨机同步配置仓（main=claw 主机），本次 push 到 main；其他主机接入时按其分支模型 pull
- 部署位运行完整 selftest 套件会因「引用仓库根文件」产生既有误报（同 MA-08 型），完整回归应在 canonical 仓跑

## 下一步
- 新会话验证 zcode 位技能加载（部署内容即时生效，无需重启即可被 Read）
- task-v191 delivery-summary 第 5 项（主仓已完成计划归档 Rule 81 + INDEX 刷新）仍未做，按需处理

## 10-26 多平台部署补账（用户指令「完成本地平台部署」）
10-19 首轮只覆盖 zcode 位且簿记未落（INDEX 曾挂 pending 0/0）。2026-10-26 全量盘点本地各平台并同步（canonical = 本地 HEAD `6324ce2`，15 技能全集）：

| 平台 | 载体 | 同步范围 | 验证 | 提交 |
|------|------|---------|------|------|
| zcode | `~/.zcode`（zcode-config main，git） | 15 技能全量 `rsync -a`（不带 `--delete`） | 逐技能 `diff -rq` 内容差异=0 | `df22f48`（16 文件，仅 8 个有变更的技能目录，他域 27 脏文件未纳入） |
| claude | `~/.claude`（claude-config master，git） | 15 技能全量 | 逐技能 diff=0 | `8ed938c`（297 文件，15 技能 pathspec 锁定；他域 231+ 脏文件未纳入） |
| cursor | `~/.cursor`（非 git） | 15 技能全量 | diff=0；运行态 `.drift-rhythm/` 保留 | 无需提交 |
| agents | `~/.agents`（非 git） | 仅 `plan-resume`（15 技能中唯一已布该位的共享位；余 14 个未布该位=范围外不扩） | diff=0；旧 `.bak` 备份保留 | 无需提交 |

一手事实：claude 位差异全是「canonical 前进、位落后」（bun→node 迁移、Rules 1-96 口径、Rule 95/96 新增），无宿主适配内容会被覆盖；videop1 仓 `skills/` 为自有视频技能族（comet/craft/review-*），不在 15 技能集内，不同步。遗留：两个 config 仓与源仓的 push 均未执行（本次「本地平台」范围），按需另指令。