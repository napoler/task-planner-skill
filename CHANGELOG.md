# 变更日志

所有值得注意的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
本项目遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 新增

- **Rule 33 解决→反思→验证迭代循环（task-v074）** — 问题解决动作后强制「反思四问→独立验证」微循环：progress.md `- [reflect] 反思:/验证:` 两行落盘、≤3 轮迭代边界、notepad 沉淀联动；`config.json#reflect_verify_enforce`（默认 warn）+ `check-complete.sh` REFLECT-GATE（声明 `reflect_verify: required` 的计划终验校验反思行）+ `selftest-reflect-verify.sh`（12 断言）。
- **Rule 34 模板生命周期：选取门控 + 沉淀入库（task-v074）** — `scripts/check-template-type.sh`（新）在 attest 锁定前校验 template_type ∈ 白名单（白名单自 `templates/variant/` 目录动态派生+general，消双权威源），enforce 档拒绝锁定、`--skip-template-check` 逃生；沉淀触发三条件/防滥用（34.3-34.5）；`config.json#template_gate_enforce` + `selftest-template-lifecycle.sh`（16 断言）。首批沉淀 `templates/variant/rule-enhancement-type.md`（技能规则增强类，源自 v071-v074 同类轮次）。
- **init-session.sh 模板路由增强（task-v074）** — 支持 `TASK_TEMPLATE_TYPE` 环境变量（兜第 2 位置参数）；VALID_TYPES 白名单改为 variant/ 目录动态派生（新增变体免改脚本）。
- **check-complete.sh REFLECT-GATE / VC-GATE 紧凑格式兼容（task-v074 P8）** — VC-GATE 计数器并集 `- **V-N:** VC-x` 紧凑映射行（v065 起现行计划格式，原计数恒 0 致门控形同虚设）；映射目标 ∈ 已定义 VC 校验保留。
- **check-scope.sh D10'' attestation 仲裁（task-v074 P8）** — 本会话 side 指针指向的计划存在有效 `.plan-attestation`（SHA-256 匹配）时放行哨兵，修复恢复会话因 SessionStart 重写哨兵 epoch 被误拦（fail-closed：无指针新会话/篡改 attestation 仍拦截）。
- **sid 兜底链统一：哨兵探测 fallback（task-v074 P10）** — 根因：env `CLAUDE_CODE_SESSION_ID` 与 hook stdin `.session_id` 是两套命名空间（SessionStart 哨兵用 hook sid 写、init/plan-created 用 env sid 清 → P1-2 指针/哨兵错位实锤）。
  - `scripts/init-session.sh`：env sid 无对应 side 哨兵时，取 `plans/.plan_required_side/` 下 mtime 最新哨兵文件名 stem 为 sidkey（SessionStart 刚写入=本会话真实 sid 的落地物），据此写 side 指针；env sid 有对应哨兵时行为完全不变（语义红线）。多会话并发局限：最新 mtime 启动会话优先，已知取舍。
  - `scripts/init-session.sh` PLAN_ROOT 解析修正：原 `cd .. && pwd` 假设 CWD=`plans/<task-id>/`（`<root>` 级指针），与 canonical 侧 `<root>/plans/.active_plan{,_side}`（task-plan-init.cjs :76 / resolve-plan-dir.sh :33 / set-active-plan）错位——指针写进 resolve 侧查不到的位置。现 CWD=`plans/` → 指针/哨兵落 `<root>/plans/`；CWD=`plans/<task-id>/`（既有标准运行方式）行为不变；非标准目录维持旧 `cd ..`（零破坏降级）。副作用登记：`plans/<task-id>` 运行时 legacy/side 指针落点从 `<root>/.active_plan{,_side}` 迁移至 `<root>/plans/.active_plan{,_side}`（与 set-active-plan / resolve-plan-dir / attest 口径对齐）。
  - `scripts/plan-created.cjs` 同侧 fallback：sidkey（env 链）无对应 side 哨兵时取 `plans/.plan_required_side/` 下 mtime 最新哨兵 stem，双清除逻辑不变、仅命中口径对齐；无 sid 兜底行为不回归。
  - `scripts/selftest-active-plan.sh` 新增 T12a-d 行为级断言（init 哨兵 stem 指针 / env sid 命中不变 / 无 sid legacy 回归 / plan-created 哨兵被清）。
- **fail-open 显式化（task-v074 P10，CR P2a 收口）** — `scripts/attest-plan.sh` 两处「脚本不存在/不可执行 → 静默跳过」分支各加一行 stderr（行为零变化，仍放行）：`[template-gate] SKIPPED (check-template-type.sh 不可执行)` 与 `[plan-dispatch] SKIPPED (check-plan-dispatch.sh 不可执行)`，消除静默放行不可见。
- **文档悬空清理（task-v074 P10）** — `README_zh.md` :88 安装指引改指 `INSTALL_zh.md`；目录树补 `companion/agents/`（3 agent）/`templates/knowledge-brief.md`/`templates/variant/`（13 变体一行概括）；「英文文档」段如实改为无独立英文文档、指向 `CONTRIBUTING.md` 及 INSTALL_zh/README_zh 内英文术语；本文件历史条目 `docs/ARCHITECTURE.md §4.5.2` 章节号修正为 §2.6（文件实际存在）。

### 变更

- SKILL.md 联动扩至 Rules 1-34：合规清单新增 C21（Rule 33 反思验证）/C22（Rule 34 模板门控与沉淀）；config.json 37 键（新增 2 三档键，并根除 3 键历史重复定义）；SKILL.md 535 行。
- 文档对齐：template-guide/template-mapping/critical-rules 变体计数 12→13（rule-enhancement 登记）；README_zh/CLAUDE 的 "Rules 1-10" → 1-34；本清单补 v071-v073 缺漏条目同批补记（见下）。

- **多计划 `.active_plan` 指针机制（移植上游 resolve-plan-dir/set-active-plan,task-active-plan）** — 消除 hook 按 mtime 猜活跃计划的歧义(多计划并行时可能注入非预期计划):
  - `scripts/resolve-plan-dir.sh`(新,移植裁剪) — 解析链:指针→mtime 最新→legacy 根;slug 校验防路径穿越;恒 exit 0。
  - `scripts/set-active-plan.sh`(新) — `<task-id>` 设置 / `--show` 查看 / `--clear` 清除回退。
  - `init-session.sh` — 创建计划后自动写指针(最新创建=默认活跃;失败仅警告)。
  - `zcode-userpromptsubmit.sh`/`zcode-posttooluse.sh` — 计划探测改指针优先,resolver 缺失兜底旧逻辑。
  - `plan-doctor.sh` — 第 2 段显示解析来源(指针/mtime)与切换指引。
- **复用上游 planning-with-files v3 实现（ledger 工作账本/plan-doctor/gate 信号升级,Rule 19.2/19.8）** — 按用户指令复用 [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) 已验证实现,替换自研弱信号:
  - `scripts/ledger-append.sh`(新,移植) — 追加式 JSONL 工作账本:`{"tick","ts","agent","phase","event","summary","files"}`,事件枚举 progress/phase_complete/error/gate_block/attest/note;保留上游已验证的 tick 全局单调/flock 并发/UTF-8 截断修复;plan-dir 改显式传参适配本仓惯例。ledger = 机器层工作信号,md 三文件 = 人读层(上游架构 C3)。
  - `scripts/check-3file-gate.sh` **信号升级** — 主信号从 mtime 改为 ledger 语义证据(锚点后 ledger-*.jsonl 有新增行 = 真实工作流);mtime 降为无 ledger 存量计划的 fallback。依据上游 G5 设计注记:"mtime moves on any file touch and is thus unreliable"。
  - `scripts/plan-doctor.sh`(新,移植适配) — 六段一键自检:canonicalizer/计划解析/hook 面 4 事件位+注入实跑/attestation/安装面漂移核对/延迟;恒 exit 0,诊断"静默失效"。
  - 契约同步:SKILL.md 执行循环 3c/3-File 门控加 ledger 调用点与信号优先级;critical-rules.md 19.2 重写信号优先级+新增 19.8 工作账本条款。
  - **宿主能力边界落盘**:ZCode hooks 仅 4 事件无 Stop,上游五守卫完成门(gate-stop.sh)Tier1 硬阻断在本宿主不可用,不移植;执行中强制 = posttooluse 提醒/升级链 + 契约自跑门控(plan-doctor 第 6 段注明)。
- **三文件执行中硬门控（Rule 19.2 强化）** — 治理「启动填一次后 findings/progress 停更、绕过模板末尾追加」的执行缺口(上条 Rule 19.5-19.7 只在终验查非 stub,启动填一次即永久通过):
  - `scripts/check-3file-gate.sh`(新) — Phase complete 翻转前硬校验:① progress.md 对应 Phase 段已回填 ② findings.md 本 Phase 期间有增量。mtime 判定,锚点 = progress.md Phase 段 Started 时间戳,缺失退化用 stale 阈值;exit 1 禁止翻转。设计取向「宁可误报逼一次回填,不可漏报」。
  - `zcode-posttooluse.sh` `[plan-compass]` **升级机制(Rule 19.7)** — 同一文件连续 `config.json#compass_escalate_after`(默认 2)次提醒仍无回填(mtime 早于上次提醒)→ 升级警告(违反 Rule 19.7,按 Rule 26.3 处置:登记 Error Log,终验 outcome 最高 PARTIAL);state 扩展 9 字段向后兼容。
  - **子代理回填流程绑定(Rule 19.1/22.5)** — Handoff 登记表新增「findings 落点」列;verify_done = Read 实际产出 ✓ + findings.md 回填 ✓ 双条件,SKILL.md 执行循环 3a/Rule 19 摘要/C16(收紧为可验证条款)/critical-rules.md 19.1/19.2/19.7/22.5 同步;`templates/task_plan.md` Handoff 表加列。
  - **模板低摩擦瘦身** — `templates/findings.md` 107→43 行、`templates/progress.md` 132→61 行:注释压缩、EXAMPLE 删除、Test Results 并入 Phase 段(与 19.2 三件套对齐)、Started 字段标注为门控锚点;段落锚名不变(产出落盘映射表按锚名路由)。已知局限:历史计划(旧模板生成)若重跑终验,旧注释续行会被误算实质行(方向=变松,历史计划已终结影响≈0)。
- **三文件罗盘强制（Rule 19.5/19.6/19.7）** — 补齐 findings.md/progress.md「存在但无人管」的执行缺口:
  - `scripts/check-complete.sh` 新增 **3-File Gate（Rule 19.5）**:plan 目录缺 findings.md/progress.md → exit 1;存在但为模板 stub(扣除模板行集合后实质行 <3) → exit 1;task_plan.md >500 行 → Rule 19.6 瘦身 WARNING(不阻断)。头注释同步修正(原 "Always exits 0" 与实际不符)。
  - `scripts/zcode-posttooluse.sh` 新增 **`[plan-compass]` 及时性提醒(Rule 19.7)**:findings.md/progress.md 陈旧(阈值 `config.json#findings_stale_minutes` 默认 20 / `#progress_stale_minutes` 默认 25)→ 提醒回填,独立冷却;state 扩展 5 字段向后兼容;原 plan 陈旧提醒文案改为三文件分流(状态→task_plan / 结论→findings / 动作→progress),治理"一切塞 task_plan"。
  - `scripts/init-session.sh` 新增 5 文件存在性复核:缺失/空 → `[init] ERROR` + exit 1;全通过 → `5/5 planning files verified`。
  - `SKILL.md` 新增合规项 C16 + 终验 3-File Gate 步骤 + 3d hook 响应分流;`references/critical-rules.md` 新增 19.5/19.6/19.7 条款。
- **模板标准章节「📚 必要知识储备」（20/20 模板全覆盖）** — 任务知识库对齐:计划创建时列出本任务依赖的规范/官方文档/内部知识库/文献/图书,Phase 1 开工前逐项确认「必读」项可获取,缺失 → STOP 禁止凭记忆硬写。task_plan 系(主模板+12 variant)为五类知识源表+类型示例行+Phase 1 确认 checkbox;7 个非 task_plan 模板(4 核心+3 辅助)按用途轻量适配(对齐记录/使用记录/符合性核验/知识依据/计费知识依据/储备备注/知识上下文包)。章节统一标题 `## 📚 必要知识储备` 可 grep 验收。配套:SKILL.md Rule 16 强制约束、critical-rules.md Rule 16、template-guide.md §2.4、template-mapping.md §七 同步更新;修正 template-guide 模板计数漂移(实测 5 核心+3 辅助+12 variant=20)。
- **`companion/skills/plan-resume/`** — 中断/过期计划扫描技能。与 task-planner 协同:扫描 `plans/*/task_plan.md` 等 3 处存储位置,通过「时间衰减 / 代码环境失效 / 目标已被取代」三维判定过期项,产出报告让用户决策(不替用户 resume/archive/drop)。参考 `companion/skills/plan-resume/SKILL.md`。
- **`plan-resume` v0.4 智能推进(补记,2026-09-04 随 `dcfa55b` 收编但当时未记本档)** — `scripts/score-plans.py` 综合加权打分(out_degree 50% + git_keyword_hits 30% + 失败反比 20%)与 `scripts/select-and-resume.sh` 智能推进编排(SKILL.md §7 smart-resume);当时为 cron 显式 `--auto-push` opt-in,默认 dry-run。
- **`plan-resume` v0.5 任务恢复自主化(2026-09-05)** — 用户指令"模型自主根据分析选择需要推进的任务进行完成,而不是等待用户抉择"落地:
  - **双模式契约**:恢复触发点(会话启动无活跃计划 / 用户恢复类指令 / 当前计划交付终态后)默认**自主打分选 Top 1 并续推至交付或用户决策点**;当前计划执行中的被动扫描保持只报告(防打断)。
  - **`config.json`(新增)**:`autonomous_resume`(默认 true)总开关 + 守卫阈值(`max_auto_plans_per_trigger=1` / `skip_states=[blocked,awaiting-user,hold]` / `cross_project_auto_resume=false` 恒禁 / `fresh_threshold_days=7` / `max_failure_count=3`)。
  - **`select-and-resume.sh`**:config 纯 grep/sed 加载(缺文件/缺键默认值兜底)、模式解析(flag > config)、`skip_states` 硬排除、auto 模式仓内范围守卫(outside-repo 排除)、标记 payload `mode=auto-resume`(token `[auto-pushed-by-cron]` 沿用防旧过滤失效);`--dry-run`/`--auto-push` 显式覆盖保留。
  - **SKILL.md §7 重写**(7.1 触发与授权 / 7.2 配置 / 7.3 打分 / 7.4 过滤 / 7.5 推进纪律 / 7.6 报告 / 7.7 兼容性 / 7.8 风险 / 7.9 决策记录):守卫底线(跨仓只报告、BLOCKED/[awaiting-user]/[hold] 跳过、单次 1 个、用户"不要自动续推"会话级逃生)成文;续推=按该计划自身契约接着干,不得改 Goal/VC/范围。
- **`scripts/sync-companion.sh` + `lib/install-companion.sh` 同步器改用 `find -maxdepth 2`** — 修复 companion skills 只扫顶层文件的限制,支持子目录(`scripts/`)。向后兼容 `companion/skills/task-drift-guard/`(只含顶层 3 文件)。详见 `skills/task-planner/docs/ARCHITECTURE.md` §2.6（Companion 同步器设计决策；2026-09-16 task-v074 P10 修正原悬空章节号 §4.5.2）。

### 变更

- **`lib/verify.sh` 适配软链部署模型（项目体检产出）** — 部署位为指向 canonical 的软链时,"薄壳体积 <15KB / 脚本无硬编码路径"检查不再适用(全量内容与回退默认值均为预期状态),改为校验软链指向 canonical 且经链可读;ZCode hooks 校验从 SKILL.md frontmatter 改为实际注册机制 `~/.zcode/cli/config.json`;opencode/cursor 薄壳保持 frontmatter 检查。修复后实跑 18 pass / 0 fail(此前 5 fail)。
- **清理被 git 运踪的运行时备份产物** — 移除仓根 `.backup/`(2026-08-29 旧薄壳备份,内容保留于 git 历史),新增 `.gitignore`(`.backup/`、`__pycache__/`)防止运行时产物再次入库;`.backup/` 仍是 `lib/backup.sh` 的设计备份位,仅不再追踪。
- **布局统一:外围 skill 全部迁移至仓库顶层 `skills/`** — `companion/skills/{task-drift-guard,plan-resume}` → 顶层(与 task-planner 同级),companion/ 仅留 agents/;`install-companion.sh`/`sync-companion.sh` 安装与回同步源改为顶层 skills/(自动发现含 SKILL.md 的目录,排除 task-planner 本体;新增仓根 CHANGELOG.md 校验,防止从已部署副本运行时误将部署目录当源);`todo-skill` 纳入分发范围;task-drift-guard 顶层陈旧副本以 companion 版归一(含批量漂移判定 + model 行,与线上部署逐字节一致)。`~/.agents/skills/plan-resume` 软链重指顶层新路径。
- **`plan-resume` v0.3 多格式扫描**: `scan-plans.sh` 新增 openspec(`openspec/changes/*/tasks.md`)与 spec-kit(`specs/*/tasks.md` + `specs/*/spec.md`)两个扫描位置(共 3 种存储格式:task-planner / openspec / spec-kit)。openspec 默认跳过 `archive/`(加 `--include-archived` 可开启)。
- **`extract-meta.sh` 三后端**:新增 `format=openspec` / `format=spec-kit` 分派,openspec 后端读 `.openspec.yaml` goal + tasks.md 完成度,spec-kit 后端读 spec.md 的 `**Status**` 字段与 tasks.md 完成度;原 `format=task-planner` 后端完全保留。
- **SKILL.md 报告模板**:在推荐清单表格里新增 `Format` 列 + 混合格式展示示例;报告元信息加 `格式覆盖` 行;§1 计划位置补 openspec / spec-kit 两条;§1.1 用户参数映射加 `--include-archived`;§2.1 提取字段表扩展为 7 字段 + 格式判定表。
- **`tests/smoke.sh` 5 项新测试**: openspec format / task_id;spec-kit format / 完成度 / spec.md Status 字段;加上 `--help` 检查。
- **task-planner 与 plan-resume 集成**: `references/critical-rules.md` 新增 Rule 24 — Phase complete 后**被动**调 `Skill("plan-resume")` 扫描工作区其他中断任务(不替用户续推,只产报告)。`SKILL.md` frontmatter 加 plan-resume 引用,Phase 执行循环 step 5(DRIFT CHECK 后)加 plan-resume 调用节点,Chain handoff 加 step 5。合规检查清单加 C13。`templates/progress.md` 加 plan-resume 报告检查点表。
- **task-planner 侧契约同步 plan-resume v0.5**: `references/critical-rules.md` Rule 24 全节重写为"被动扫描与自主续推"(执行中只报告 / 恢复触发点自主 Top 1 / 守卫五条 / 24.7 增"不要自动续推"降级例外);清除 24.3 编辑事故句(CHANGELOG 术语"phase_status_map 已在 [Unreleased] 段跟踪"混入规则正文);SKILL.md frontmatter references 行、Phase 执行循环被动扫描段、C13 合规项、Rule 索引四处同步,扫描时机表述统一为"DRIFT CHECK 之前"(原 SKILL.md/Rule 24/CHANGELOG 三处不一)。
- **`tests/smoke.sh` 翻修并补 v0.5 覆盖**: 新增 v0.5 用例(config 加载与缺省兜底 / skip_states 硬排除 / 默认自主选 Top1 写 `mode=auto-resume` 标记 / outside-repo 守卫 / `--dry-run` 显式覆盖);另修正 8 条自 v0.4 起即失败的陈旧断言(`extract-meta.sh` 已移除 `format=`/`task_completion_pct` 输出、`scan-plans.sh` 不再扫 openspec/spec-kit 的 tasks.md、`--help` 无 `--include-archived`,均以 git archive 对照 HEAD 证实改前即红),逐条替换为等数量当前真实行为断言,用例数不减。

### 修复

- **`plan-resume/select-and-resume.sh` python 内联段转义 SyntaxError**:打分调用内联 python 的 f-string 中 `d[\"k\"]` 反斜杠转义在 python3.12 下直接 SyntaxError,且被 `2>/dev/null` 掩盖、pipefail 放大为 EXIT=1 报告截断;改为先赋局部变量再进 f-string(v0.5 改造中发现,顺带修复)。

### 删除

(无)


## [2.0.0] — 2026-08-08

### 新增
- **`scripts/install.sh`** —— 一键安装器，支持 `--target`、`--dry-run`、`--force`、`--source`、`--no-validate`、`--uninstall`。默认安装到 `~/.claude/skills/task-planner/`
- **`scripts/validate.sh`** —— 安装后完整性检查：`.sh`/`.py`/`.ts` 语法检查、JSON 验证、frontmatter 检查、模板存在性、可执行权限
- **`scripts/uninstall.sh`** —— 安全卸载，支持 `--dry-run`、`--force`、`--target`。操作父目录前会询问确认
- **`README.md`** —— 项目概览、功能特性表、快速上手、项目结构、验证契约说明、多任务并行模式、文档索引、配置参考、许可、贡献链接
- **`README_zh.md`** —— 中文版本 README
- **`INSTALL.md`** —— LLM 自动安装代码块 + Linux/macOS/WSL/Windows 手动安装说明
- **`INSTALL_zh.md`** —— 中文版本安装说明
- **`CHANGELOG.md`** —— 本文档
- **`CONTRIBUTING.md`** —— 开发流程、脚本规范、PR 检查清单
- **`CONTRIBUTING_zh.md`** —— 中文版本贡献指南
- **`examples/full-workflow.md`** —— 端到端演示：从请求到规划到执行到验证到交付
- **`CLAUDE.md`** —— 仓库级 Claude Code 指南（目录结构、开发工作流、常用命令）
- **`scripts/check-complete.ps1`** —— `check-complete.sh` 的 PowerShell 镜像（原生 Windows 支持）
- **`scripts/init-session.ps1`** —— `init-session.sh` 的 PowerShell 镜像（原生 Windows 支持）

### 变更
- `README.md` 由 1 句话扩展为完整项目文档
- 任务计划模板注释更新为中英双语标题
- `validate.sh` 中 TypeScript 严格类型检查降级为警告（`sync-ide-folders.ts` 依赖的 `@types/node` 非 Skill 硬依赖）

### 修复
- `init-session.ps1`：硬编码路径 `skills\plan\templates\` 修正为 `skills\task-planner\templates\`
- `init-session.ps1`：补全缺失的 `verification.md` 模板复制（之前只复制 4 个文件，Shell 版复制 5 个）
- `sync-todos.sh`：`stat -c %y` 是 GNU 专属，现增加 macOS BSD stat（`stat -f '%Sm'`）兼容
- `CONTRIBUTING.md`：Python 脚本路径 `scripts/session-catchup.py` 修正为 `skills/task-planner/scripts/session-catchup.py`
- 全部 `<owner>` / `<you>` 占位符替换为实际 GitHub 用户名 `napoler`
- `INSTALL.md`：修复残留中文文本（第 26 行）

### 删除
- 无。所有现有 Skill 文件均保留（详见提交记录中 `skills/task-planner/` 的无操作 diff）。

---

## [1.0.0] — 2026-08-01（初始提交）

- 裸 Skill 包 —— 从内部开发环境复制的 `task-planner` Skill 文件
- 无分发表面（无 README、无安装脚本、无文档）
- 内容：`SKILL.md`、`config.json`、`reference.md`、`examples.md`、`scripts/`、`templates/`、`references/`
