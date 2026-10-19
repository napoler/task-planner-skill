# 交付总结 — task-v191-project-audit-sync

## 说明
对 task-planner-skill 仓库做**系统性审查**（发现 50+ 项文档/引用漂移，其中 2026-10-19 审计报告的多项 P0/P1 已由 task-v188/v189/v190 修复，本批核实并清理残留 + 同步陈旧文档），把**所有文档同步到最新**口径（Rules 1-92 / 核心 14 条 / 73 条非核心 / 11 卫星 / 92 selftest / 146 脚本 / 8 伴生），修正跨技能引用形式与脚本文本残留，零回归后合并回 master。

## 产出（25 文件修正 + 1 selftest 锁步 + 审计检查点）
- 仓根/核心文档：`README_zh.md`、`CLAUDE.md`、`INSTALL_zh.md`、`progress.md`（孤儿改写为占位）、`skills/task-planner/{README.md, docs/ARCHITECTURE.md, SKILL.md}`
- 规则口径 1-91/1-80 → 1-92；行/脚本/伴生/refs/config/templates 计数刷新；ARCHITECTURE 纪元史补至 81-92 + 11 卫星
- 跨技能引用（references 层 `../`→`../../`、双拼清除、裸 config/templates 补 `../../task-planner/` 前缀）：task-dispatch / task-discipline / plan-template-kit / progress-tracker / task-drift-guard + 2 selftest 脚本
- frontmatter：`media-planner/SKILL.md`（`tools:`→`allowed-tools:` 统一）；`task-discipline/SKILL.md` 索引表补 Rule 85-90 六行
- 脚本文本：`register-hooks-cj.ts` / `sync-ide-folders.ts`（bun / ts-node → `node --experimental-strip-types`）；docs 残留 `bun run` 引用清零
- 模板：`video-fix-type.md` 加 S75 D1 videop1 专属豁免注
- 轻量技能：`todo-skill/{SKILL.md, WORKFLOW.md, tools/cli_todo-manager.ts, tools/store.json}`（model mini→haiku、路径 .claude→.zcode、死引用、store 重置为空）
- 锚点漂移：`SKILL.md` `:191`→`:195`、`lane-detect.sh:85`→`:86`；`init-session.sh:463` 同锚同步
- selftest 锁步：`selftest-media-agents.sh` MA-08 伴生计数 7→8
- 审计检查点：`plans/task-v191-project-audit-sync/subagent-state/{A,B,C,D}-*.md`

## 审查（回归证据）
- 基线 `run-selftests.sh`（缓存态）：Total: 92 PASS=92 FAIL=0
- 修后 `run-selftests.sh --fresh`：Total: 92 PASS=92 FAIL=0（**零回归**；曾 1 FAIL=selftest-media-agents MA-08，补 7→8 锁步后复跑绿）

## 风险（本批未动，登记待裁决）
1. `task-planner/scripts/` 70 个 .sh 头注释仓根形式 `skills/task-...`（N6，纯注释低价值）
2. `task-discipline/references/batch-quality-gate.md:19,36,48,114,139,140` 裸 `templates/` 引用（同 N4 型缺前缀，仅 :141 已修）
3. `iterative-optimizer` / `error-fix-prompt-forge` frontmatter 缺 model/tools（仓级约定本不统一，需单独裁决）
4. `video-fix-type.md` videop1 专属路径（加豁免注未改，移植需替换占位符）
5. 主仓 `plans/` 下 task-v180/v181/v183/v184/v187/v188/v189/v190 已完成未归档（Rule 81）+ `plans/INDEX.md` 未刷新
6. 部署位 `~/.zcode/skills/**` 未同步（需用户单独授权重新部署，本仓改动未自动生效）

## 下一步建议
1. 用户授权后重新部署 `~/.zcode/skills/**`（本仓改动不自动生效）
2. 按 Rule 81.1 归档已完成计划 + 重跑 `sync-todos.sh --index` 刷新 INDEX
3. 上述待裁决项 1-4 按需清理
