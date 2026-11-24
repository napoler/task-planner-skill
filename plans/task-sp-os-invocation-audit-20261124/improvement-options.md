# 改进方案对比（S15 / P6）— Superpowers × OpenSpec 主动调用根治

> 任务：task-sp-os-invocation-audit-20261124；执行体：主进程 + Superpowers `brainstorming`（S15 权威定义要求）；日期：2026-11-24。
> 定位：交方案待批（D-3），本轮不实施。五条根因 H1-H5 均 CONFIRMED（P5，VC-7 rc=0）。
> 评审：S17 critic 逐轮 NOT APPROVED（R1 1C/6I/5W/3N、R2 0C/3I/4W/1N、R3 0C/1I/6W/5N），主进程盘上复核后逐条修订；本版含 R2/R3 计数（NIT 修正）。

## 问题定义（一句话）
设计层与侧证一致表明：SP/OS 两族技能在解决问题时未被制度性主动调用（日志盲区下无法归因技能名，故此判断来自设计层驱动缺口+侧证，非日志调用数）；根因不在技能文本（iron law 齐备），而在**编排层缺驱动点/门**：H1 入口无 hook 注入、H2 路由只有文本指针、H3 自家机制有脚本驱动而 SP/OS 无、H4 OpenSpec 无落点目录且 CLI PATH 不可达、H5 伴飞字段载体三处断链致技能到不了执行层。

## 方案 A (Recommended)— 五因五驱动点：补 hook + 基线组 + 字段载体 + PATH/落点
**核心**：对每条 CONFIRMED 根因各补一个可机器触发的驱动点，全部复用 task-planner 已验证有效的驱动模式（hook 注入 / sync-todos.sh 必选基线组 / check-* 门 / planctl 字段），不新增独立架构。

- H1：`config.json` 的 SessionStart 增一条注入 using-superpowers 的 hook（对齐上游 `run-hook.cmd session-start`），UserPromptSubmit 增「先扫描技能再响应」提示。
- H2：`spec-mode` 路由判定由文本路由表落成运行时脚本门；OpenSpec CLI 探针失败显式记「不可接管」而非静默。
- H3：`sync-todos.sh` 必选基线组从 B1-B11 扩 **B12**（SP/OS 技能到达检查）+ **B13**（Spec 路由命中核查），避开已合并的 B9-B11（commit 5915e78a）；配 fail-closed 门（未勾禁声称完成/禁 Phase complete），符合 C5「必须每次发生→基线组成员+门」指定形态。
- H4：项目根 `openspec/` 初始化前置 + H2 探针内按可移植顺序解析 openspec（`$(npm config get prefix)/bin/openspec` → `command -v openspec` → 本机已观测绝对路径兜底，**不硬编码单一路径**，W-4 修正；**不改 `~/.bashrc`**：其已有 export 但 probe 仍 rc=1，属 no-op）。
- H5：`s_units` 增 `escort_skills` 字符串数组字段（同步 planctl known 键 `:555-558` 与 schema `:542-558`，否则 validate 拒绝），修 `planctl.py:1271` 让第 8 列真正承载技能路径（parallel 落既有「前置依赖」列注解、零列变更），修 `check-dispatch.sh:588` 跳过条件使门 fail-closed；plan-writer 填列义务落 `companion/agents/plan-writer.md`（I-1 修正）。canonical 模板 `templates/task_plan.md:369,387` 与 31 个 variant 中 28 个本已有「伴飞技能」列（3 个轻量类型无 S-unit 表）、`subagent_dispatch.md:37-39` 已有伴飞节——断链在渲染赋值与 schema/known 键，不在模板缺列。`spec-mode.md` §1 文本表为路由脚本的单一事实源（NIT 修正）。

**取舍**：覆盖 H1-H5 全部根因、根治性强、每处复用现有模式可被 VC 门量化验证；代价是改动面跨 5 个文件族 + hook 配置，需分批实施、每批独立评审，且触保护区（hook/配置/`~/.zcode/skills`）须单独立项授权。**推荐理由**：只有全因覆盖才能满足用户「被调用并用于推进」的验收——缺任一因仍有断点。

## 方案 B — 最小止血：只修 H5 伴飞载体 + H3 基线组
**核心**：只补最高杠杆的两处——伴飞字段载体（技能到执行层的唯一可泛化路径）与 sync-todos 基线组门（每次执行强制检查），不动入口 hook、路由脚本与 OpenSpec 落点/PATH。

**取舍**：改动面小（2 文件族 + 1 基线组）、风险低、可快速见效于「技能到达子代理」环节；但 H1（入口）、H2（路由触发面）、H4（OpenSpec 落点/PATH）未解——会话启动时仍不注入、路由仍靠文本、OpenSpec 仍无处落地。属**缓解非根治**：能让已决定用技能的会话到达执行层，但无法让会话「主动决定用」。不推荐作最终方案。

## 方案 C — 统一技能路由层（新建独立 router）
**核心**：新建一个统一的 SP/OS 技能路由脚本/配置，把所有触发判定、注入、到达逻辑集中到一处新组件，与 task-planner 门链解耦。

**取舍**：长期架构清晰、可扩展；但①引入新组件=新概念+新维护面，与现有 task-planner 门链功能重叠，可能**加剧 H3 同构竞争**（此为基于同构竞争机理的判断，非取证结论——本次审计未实测新 router 与门链的竞争行为）；②改动最大、评审成本最高；③与「复用已验证驱动模式」的稳健取向相悖。当前根因是「现有链路缺驱动点」而非「缺一个路由层」，属过度设计。不推荐。

## 推荐结论
推荐 **方案 A**。三个方案均以「不改技能文本层、只补驱动点/门/载体/PATH」为前提，均不触 C4 已否决项（不砍委派率硬门、不改主进程直做、不降级 planctl、不直改 4 个 MD 派生视图）。方案 A 是唯一对 H1-H5 五因全覆盖、且每处驱动点都有现成对照机制（B1-B11 门链 / check-dispatch 门 / SessionStart hook）可复用的选项，最可能达成用户「主动调用且用于推进」的验收（注：新增项编号 B12/B13，避开已合并的 B9-B11）。方案 B 作快速止血备选，方案 C 不推荐。

## 方案设计自查（brainstorming spec self-review）
- 占位符：无 TBD/TODO；五因驱动点均对应具体 file:line。
- 内部一致性：三方案均不改文本层、不触 C4，与五条 root_causes 的 fix 字段指向一致。
- 范围：聚焦「补驱动点」单一目标，未引入无关重构（方案 C 已因过度设计被否）。
- 歧义：H4 的 `openspec/` 初始化与探针内绝对路径解析均为前置驱动点、非业务功能改动，语义唯一（PATH 改动已按 S17 判为 no-op 剔除）。
- 落地门：每方案改动项将在 S16 逐条写成 `FILE-CHANGE` + `DRIVE-POINT`，交 S17 critic 独立评审。
