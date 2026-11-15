---
id: specmode-integration-and-line-pin-20261115
title: "Spec 模式外部技能集成（Superpowers×OpenSpec）与 SKILL.md 行数钉演进判例（task-specmode-integration-20261115）"
tags: [spec-mode, superpowers, openspec, 外部技能集成, BP-08行数钉, stash窗口合并, 调用非复制]
sources: [plans/task-specmode-integration-20261115/findings-superpowers.md, plans/task-specmode-integration-20261115/findings-openspec.md, plans/task-specmode-integration-20261115/findings-anchors.md, plans/task-specmode-integration-20261115/review-s7.md, skills/task-planner/references/spec-mode.md, plans/task-specmode-integration-20261115/user-session-log.md]
updated: 2026-11-15
---

# Spec 模式外部技能集成与行数钉演进（2026-11-15）

> 需求锚：用户 /goal 原话（user-session-log #1，R1-R6）——整理阶段偏移→Spec 模式；Superpowers/OpenSpec 显性接入；planner=忠实记录者+调度者；未安装→主动安装免用户门；**调用非复制**。

## 1. 集成事实（复用面）
- **Superpowers**（官方 README 2026-11-15 抓取）：Claude 位 `/plugin install superpowers@claude-plugins-official` 或 `/plugin marketplace add obra/superpowers-marketplace` + `/plugin install superpowers@superpowers-marketplace`；brainstorming=9 步 HARD-GATE，产物 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`，**其后唯一技能=writing-plans（硬门，原文 "The ONLY skill you invoke after brainstorming is writing-plans"）**
- **OpenSpec**（Fission-AI）：`npm install -g @fission-ai/openspec@latest`（Node≥22.12.0）或 `curl -fsSL https://openspec.dev/cli/install.sh | sh`；项目初始化 `openspec init`；生命周期 `/opsx:explore→propose→apply→verify→archive`；**产物路径由 CLI planningHome/changeRoot/artifactPaths 动态解析，禁硬编码**
- **本机部署位**：superpowers 族=`~/.zcode/skills`+`~/.agents/skills` 双目录（同名优先级未明示=UNKNOWN）；openspec 族=仅 `~/.zcode/skills`（11 技能）；openspec CLI 本机未装（`command -v` 无命中）
- **task-planner 集成锚**：SKILL.md 三点纯增量（初始化 Spec 模式触发判定 L54/计划确认前置 L60/协同路由行 L255，283→287 行）+ frontmatter references 登记 + `references/spec-mode.md`（路由表/安装引导/反模式/记录者调度者职责，40 行）

## 2. 判例与易错点
1. **BP-08 行数钉演进口径**（selftest-batch-pilot.sh）：改 SKILL.md 行数前先 grep 行数钉族；演进=**追加新日期条目（禁就地改写历史行）+ 实值+5 边距**（先例 280→285；本次 287→292）；零边距钉值会被复检判退化（S7 D4）
2. **交接点互斥判例**（S7 D3）：给外部技能后续路由写条款前必查其 SKILL.md 硬门——brainstorming 硬门禁止其后调用其他技能，本仓"planner 自有计划流"行与之互斥；修=路由让位 writing-plans/tasks.md，planner 只做收据记录
3. **双权威防二义**（S7 D1）：同族路由已有权威源（plan-collab-router/skill-collaboration.md「comet→OpenSpec→superpowers 先命中先用」）时，新路由文件须显式让位声明，禁并立两个权威
4. **安装类 UNKNOWN 处置**：本地技能文档无安装命令≠没有——官方 README 真实抓取留来源+日期（75.7）；registry 拒连（ECONNREFUSED）时安装命令以官方源记载形态落条款，禁脑补
5. **stash 窗口合并法二度实证**：遗留暂存态（`A` 新文件）阻断 merge → `git stash push -- <pathspec>` 限定 → `--no-ff` merge → `stash pop --index` 原态回填（M+A 状态逐一核对）
6. **反复制负断言机器判据**：外部技能集成验收=变更集文件清单核对（git status 恰=N 个预期文件）+仓库内无对方内容文件（find openspec/superpowers=空）
7. **check-complete P-04 三源一致**：Phase 翻 complete 前 checkbox↔Status↔progress 三处同步，progress 同名段须 `[goal:Gn]` 证据行；规范召回类 checklist 勾选前提=真读了召回卡+progress 留 `[recall]` 行
8. **承诺边界写进条款**：R5 免用户门仅及安装/初始化动作，其他不可逆仍走既有门（spec-mode.md §2 纪律③）——用户授权的边界要显式，防执行体泛化

- FMEA RPN>100 兜底指针：本任务无 RPN>100 项（最高 72，见 plans/task-specmode-integration-20261115/task_plan.md FMEA 表）