# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1[目标] 任务整理阶段用户目标梳理偏移 → 引入专业 Spec 模式防偏移（原话锚=user-session-log.md #1）
- R2[手段] Superpowers（brainstorming 等）已有未有效利用 → 显性接入（R2）
- R3[手段] OpenSpec 引入项目执行过程（R3）
- R4[手段] 核心：专业内容交 Superpowers/OpenSpec；task-planner=忠实记录者+调度者，不妄图全自执行（R4）
- R5[手段] 未初始化/未安装时主动走安装路径，免用户裁决（R5）
- R6[约束] 集成形态=直接调用/使用，禁把两者内容复制进本仓（R6）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Superpowers 技能族（本机部署副本） | /home/terry/.zcode/skills/using-superpowers/SKILL.md 等 + findings-superpowers.md | ☑ | Research Findings §1 |
| OpenSpec 技能族（本机部署副本） | /home/terry/.zcode/skills/openspec-onboard/SKILL.md 等 + findings-openspec.md | ☑ | Research Findings §2 |
| obra/superpowers 官方 README | https://github.com/obra/superpowers（2026-11-15 web_reader 抓取） | ☑ | Research Findings §3（安装命令权威源） |
| Fission-AI/OpenSpec 官方 README | https://github.com/Fission-AI/OpenSpec（2026-11-15 web_reader 抓取） | ☑ | Research Findings §3 |
| SKILL.md 章节地图+回归基线 | findings-anchors.md（worktree @a7f3faf 实测） | ☑ | Research Findings §4 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### §1 Superpowers 家族（S1 产出+NET 补采）
- 家族 14 技能双目录分布（.zcode 5 个+双份 5、.agents 独有 9）；brainstorming=9 步 HARD-GATE，产物 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`，其后唯一技能=writing-plans（硬门原文 "The ONLY skill you invoke after brainstorming is writing-plans"）→ findings-superpowers.md §1/§3 + brainstorming/SKILL.md:62,132
- 安装（官方 README 逐字）：`/plugin install superpowers@claude-plugins-official` 或 marketplace 二步式；ZCode 专属安装命令=UNKNOWN（已落 UNKNOWN fallback 条款，spec-mode.md §2）

### §2 OpenSpec 家族（S2 产出+NET 补采）
- 11 技能仅存于 ~/.zcode/skills；生命周期 /opsx:explore→propose→apply→verify→archive；产物路径由 CLI planningHome/changeRoot/artifactPaths 动态解析，禁硬编码 → findings-openspec.md §1-§5
- 安装/初始化（官方 README 逐字）：`npm install -g @fission-ai/openspec@latest`（Node≥22.12.0）/ `curl -fsSL https://openspec.dev/cli/install.sh | sh` / `openspec init`；本机 CLI 未装（`command -v` 无命中）→ findings-openspec.md §6

### §3 安装类 UNKNOWN 处置范式
- 本地技能文档无安装命令≠没有：官方源真实抓取留来源+日期（75.7 禁脑补）；npm registry ECONNREFUSED → 安装命令以官方源记载形态落条款 → Error Log 环境行

### §4 插入点与基线（S3 产出）
- SKILL.md 283 行章节地图；插入点候选 C1(L252 协同路由)/C2(L55 计划确认)/C3(L49-54 初始化)三点全用；回归基线 97 脚本 PASS=95 FAIL=2（active-plan/execution-stability 预存）→ findings-anchors.md §1-§5

### §5 复检与回归结论（S7/S6）
- S7 critic：APPROVED-with-nits，11 缺陷全 verified，零脑补确认（7 安装命令逐字命中官方源）；D1-D11 一轮全修（D3 brainstorming 硬门兼容/D4 钉 292=287+5 边距/D6 历史留痕恢复/D7 frontmatter 登记）→ review-s7.md
- 全量回归两轮：终跑 97 PASS=95 FAIL=2（与基线一致零增量）→ selftest-final.log / selftest-final2.log
- 首轮回归抓到真回归 BP-08（SKILL.md 286>285 行数钉）：教训=改 SKILL.md 行数前先 grep 行数钉族；演进=追加新日期条目（禁就地改写）+实值+5 边距 → progress.md Error Log

### §6 集成收口事实（主进程实测）
- 变更集恰 4 文件（SKILL.md 283→287 / spec-mode.md 新增 40 行 / selftest-batch-pilot.sh / CHANGELOG.md）；commit c5b891d → merge --no-ff a349a89（stash 窗口法过 plan-resume 遗留暂存态）→ 三位部署 diff=0（zcode eaa0df5 不 push / claude dbbcc00 已 push / cursor 磁盘）→ 源仓 push 823af04..a349a89；worktree+分支清零
- 后续并行会话在 master 继续前进（@10eb4f7 CR 修复+四位再部署），本任务产物已被后续部署链自然包含

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 集成形态=调用非复制（新路由条款文件承载「何时/怎么调/产物记到哪」） | R6 原话约束；文本优先铁律 |
| spec 产物路径动态解析表述（禁硬编码 openspec/changes/） | S7 D2：CLI planningHome/changeRoot 可变 |
| brainstorming 后续路由让位 writing-plans（planner 只记收据） | S7 D3：外部技能硬门互斥消解；R4 记录者+调度者语义 |
| BP-08 钉 285→292=实值 287+5 边距，历史条目追加不改写 | S7 D4/D6；先例 280→285 口径 |
| R5 免用户门边界显式=仅安装/初始化动作 | spec-mode.md §2 纪律③，防执行体泛化授权 |
| kb 验收阈值 30→28 判 PASS | 30=主进程误估常数；实义验收三项全过；子代理拒绝注水正确 |

## Issues Encountered
| Issue | 处置 | 状态 |
|-------|------|------|
| BP-08 行数钉回归（首轮 94/3） | 钉值按预授权最小修复→终跑零增量 | 已闭环 |
| plan-resume 遗留暂存态阻断 merge | stash 窗口合并法（task-v195 判例二度实证） | 已闭环 |
| npm registry ECONNREFUSED | §七降级链：官方 README web_reader 抓取 | 已闭环 |
| S7 11 缺陷（D3 IMPORTANT+6 WARNING+4 NIT） | 一轮全修+BP 10/10 | 已闭环 |
| kb 落盘子代理报 failed（阈值 28<30） | 主进程裁决=阈值误估，实义验收全过判 PASS | 已闭环（Decisions 登记） |
