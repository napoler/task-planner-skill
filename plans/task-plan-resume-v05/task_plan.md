<!-- template_type: code-edit -->
<!-- 任务: plan-resume v0.5 — 任务恢复自主化（模型自主选任务续推，不等用户抉择） -->

# Task Plan: plan-resume v0.5 任务恢复自主化

## Goal
将 plan-resume 从"扫描后只报告、等用户说续推哪个"升级为 v0.5"自主分析→选最值得推进的 1 个任务→立即续推至完成或需用户决策点"，并同步修改 task-planner 侧契约（Rule 24 / SKILL.md / C13），消除"仅报告不续推"旧契约。用户原话："我希望就是模型可以自主根据分析，选择需要推进的任务进行完成，而不是等待用户抉择。"

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（预期审查范围仅 score-plans.py 等 .py 文件；.md/.sh 按 Gate 过滤规则不在范围） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | plan-resume SKILL.md 标识 v0.5，含自主推进两触发点（①会话启动无活跃计划/恢复类指令 ②当前计划交付终态后）与五守卫（单次1计划/跨项目只报告/BLOCKED跳过/熔断标记尊重/选后必须报告选了什么+为什么） | grep v0.5 + Read 条款 | plan-resume/SKILL.md |
| VC-2 | 旧契约清除：task-planner SKILL.md 与 critical-rules.md 中"仅报告，不替用户续推"不再是执行中扫描以外的无例外规则（新契约：执行中扫描保持只报告；触发点①②自主续推） | grep 残留检查 + Read | 两文件 diff |
| VC-3 | Rule 24 重写后与 plan-resume SKILL.md 行为一致；24.3 编辑事故句（"phase_status_map 已在 [Unreleased] 段跟踪"）清除；扫描顺序三处漂移统一为"DRIFT CHECK 之前" | grep 三处 + Read | critical-rules.md |
| VC-4 | plan-resume/config.json 存在且被 select-and-resume.sh 读取（autonomous_resume 开关）；改动 .sh 全部 `bash -n` 通过；score-plans.py 语法检查通过 | bash -n + python3 -m py_compile | 命令输出 |
| VC-5 | tests/smoke.sh 新增 v0.5 用例（config 读取 / skip_states 排除 / 自主选择输出标记）且全绿 | bash tests/smoke.sh | 测试输出 |
| VC-6 | CHANGELOG.md 含 v0.4 补记 + v0.5 条目；plan-resume README 模式描述同步 v0.5 | grep + Read | CHANGELOG.md |
| VC-7 | worktree 合并回 master：`merge_back=merged(<sha>)`；部署端 ~/.agents/skills/plan-resume 软链状态核实（实体副本则同步）；合并后主仓 Read 复验 | git log + readlink + Read | git 输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；任一 VC 3 次修复失败 → BLOCKED 升级用户。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| plan-resume 技能 | skills/plan-resume/{SKILL.md, README.md, config.json(新建), scripts/*.sh, scripts/*.py, tests/smoke.sh} | 其他技能目录 |
| task-planner 契约 | skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md | task-planner 其他文件（config.json/scripts 不动） |
| 仓级文档 | CHANGELOG.md | README_zh.md 等其他仓根文档 |
| 计划文档 | plans/task-plan-resume-v05/** | 其他 plans/ 目录 |

**强制约束**: 不在允许列表中的文件一律不碰；部署端 ~/.agents/skills/plan-resume 仅在 Phase 5 核实后按需同步，不提前手改。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | plan-resume SKILL.md v0.4 全文（§6 等用户决策 / §7 smart-resume） | skills/plan-resume/SKILL.md（345 行, dcfa55b） | 必读 | ✅ (Explore agent 全文比对) |
| 项目内部文档 | Rule 24 全文（L142-151, 含 24.5 旧契约原话） | skills/task-planner/references/critical-rules.md | 必读 | ✅ (Explore agent 摘录) |
| 项目内部文档 | task-planner SKILL.md 恢复相关三处（L17/L126/C13） | skills/task-planner/SKILL.md | 必读 | ✅ (Explore agent 定位) |
| 上游源码 | select-and-resume.sh / score-plans.py / scan-plans.sh / extract-meta.sh | skills/plan-resume/scripts/（Phase 2 开工前 Read） | 必读 | ☐ Phase 2 确认 |
| 用户宪法 | §四 用户意图优先 / §十一 worktree 隔离 | ~/.zcode/AGENTS.md（本会话已加载） | 必读 | ✅ |

## Current Phase
(全部 Phase complete,终验交付完成)

## Phases

### Phase 1: worktree 隔离区创建
- [x] `git worktree add /mnt/data/dev/task-planner-skill-worktrees/plan-resume-v05 -b wt/plan-resume-v05 master`
- [x] 确认 worktree 内 skills/plan-resume/ 与 master 一致
- [x] 动作留痕 progress.md
- **Status:** complete
- **Executor:** 主进程（例外理由: git worktree 簿记操作，无可委派 agent 类型，Rule 25 白名单）

### Phase 2: plan-resume v0.5 改造
- [ ] Read scripts/{select-and-resume.sh, score-plans.py, scan-plans.sh, extract-meta.sh} 现状（知识储备确认）
- [ ] SKILL.md：版本→v0.5；§6"等用户决策"重写为双模式契约（执行中扫描=只报告；触发点①②=自主选 1 个续推）；§7 smart-resume 升级为"自主推进模式"（config 驱动，cron 场景复用）；守卫五条成文；"选中后调用方立即读该计划三文件按下一 pending Phase 续推至交付/用户决策点"
- [ ] 新建 config.json：autonomous_resume(默认 true) / max_auto_plans_per_trigger=1 / cross_project_auto_resume=false / skip_states=[blocked, awaiting-user]
- [ ] select-and-resume.sh：读 config；--auto-push 语义改为 config 授权+flag 显式覆盖；增加 skip_states 硬排除与仓库范围过滤（auto 模式仅当前仓计划）
- [ ] score-plans.py：如需配合排除逻辑做最小改动（≤30 行）
- [ ] README.md 模式描述同步
- [ ] .md 条款由主进程 Edit（纯文档例外）；脚本改动派 code-assistant
- **Status:** complete（2026-09-05 曾让位 task-3file-enforce 暂停,同日由本会话恢复并完成;恢复时已按该注记执行 bash -n ×4 + smoke 39/39 盘点续做,全过）
- **Executor:** 主进程（.md 条款,例外:纯文档）+ code-assistant（脚本,haiku-1）

### Phase 3: task-planner 侧契约同步
- [x] critical-rules.md Rule 24 重写（标题/导语/24.1-24.7 全对齐,24.3 事故句清除,24.5 新行为契约）
- [x] task-planner SKILL.md 三处同步（L17/L126/C13+L303 规则索引共 4 处）
- [x] grep 验证通过（VC-2 唯一残留=新 24.5 取代注记本身;VC-3a 空;VC-3b 语义统一"之前"）
- **Status:** complete
- **Executor:** 主进程（例外:纯 .md 契约文本，Rule 14 白名单）

### Phase 4: 测试补强 + 一致性验证 + CHANGELOG
- [x] 派 code-assistant 补 tests/smoke.sh v0.5 用例（含守卫真实触发断言,共 39 用例）
- [x] bash tests/smoke.sh 39/39 全绿 + 4 个 .sh bash -n + py_compile 全过（VC-4/VC-5）
- [x] 主进程写 CHANGELOG.md（新增 v0.4 补记+v0.5 条目/变更 2 条/修复 1 条）（VC-6）
- [x] code_review Gate：改动文件全部为 .md/.sh/.json,按 Gate 过滤规则代码文件(.py/.ts 等)为 0 个 → 零范围 APPROVED（score-plans.py 未改动）
- **Status:** complete
- **Executor:** code-assistant（测试脚本,haiku-1）+ 主进程（CHANGELOG,纯文档）

### Phase 5: 终验 + 合并回 + 清理 + 记忆修正
- [x] worktree 内逐条复验 VC-1~VC-6 + git status 干净(commit 42c31b7)
- [x] 主仓 `git merge --no-ff wt/plan-resume-v05` → 01061db + Read 复验(config.json 在位/v0.5×14/Rule 24 新标题) + merge_back 回写
- [x] `git worktree remove` + `git branch -d wt/plan-resume-v05` 完成,git worktree list 仅主仓
- [x] 部署端核实（D7: 全部已转实体副本模型）：readlink 确认已非软链 → 5 变更文件 cp 到 ~/.agents 与 ~/.claude 两根,diff -rq 全目录 IDENTICAL×2（不同步=部署端停留 v0.4 的风险已消除）
- [x] 记忆修正：task-planner-repo-deploy-flow.md v0.5 落地条目 + MEMORY.md 索引同步
- **Status:** complete
- **Executor:** 主进程（例外:主仓合并/清理属主仓操作,子代理无主仓上下文）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅 3 个会话级未跟踪文件,与 skills/ 无重叠） |
| `isolation` | `worktree`（§11.1.1 命中:修改 skills/ 保护区） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/plan-resume-v05` |
| `branch` | `wt/plan-resume-v05` |
| `merge_back` | `merged(01061db)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | worktree 创建 |
| Phase 2 | ☐ |  | plan-resume v0.5 |
| Phase 3 | ☐ |  | task-planner 契约 |
| Phase 4 | ☐ |  | 测试+CHANGELOG |
| Phase 5 | ☐ |  | 合并回+收尾 |

## Key Questions

1. 上下游调用方？→ task-planner Rule 24 被动调用 + 用户直接调用（"继续上次任务"类）+ cron（v0.4 已有）——三处契约文本全部在范围内
2. 现成测试？→ tests/smoke.sh v0.3 版，未覆盖 v0.4 脚本 → Phase 4 补
3. 文档更新？→ plan-resume README + CHANGELOG（v0.4 补记 + v0.5）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 自主触发点=①会话启动无活跃计划/用户恢复类指令 ②当前计划交付终态后；执行中被动扫描保持只报告 | 满足用户"自主续推"诉求同时防打断进行中工作（漂移防护）；用户原话语境即"恢复时不要等抉择" |
| D2 授权模型=config.json `autonomous_resume: true` 默认开启 + 会话级口头逃生（"不要自动续推"→本次只报告） | 用户明确要求自主行为→默认开；逃生阀保留宪法 §四 用户意图优先 |
| D3 守卫五条：单次1计划/跨项目只报告/BLOCKED与awaiting-user跳过/熔断标记尊重/选后必须报告 | 跨项目隔离是宪法 §五 P0；BLOCKED 计划续推=违反原计划用户决策；透明性对冲自主风险 |
| D4 v0.4 §7 smart-resume 升级并入 v0.5 自主模式而非另起模式 | cron 与会话恢复复用同一选择路径，减少契约分叉 |
| D5 顺带修复：Rule 24.3 事故句、三处扫描顺序漂移统一、CHANGELOG 补 v0.4 | 均在本次重写触及范围内，不修则新契约与旧文本自相矛盾 |
| D6 计划自行授权：用户指令即显式授权（自主会话模式,计划展示于最终交付报告） | 用户请求明确具体；worktree 开发+合并是既有已验证模式（f281ecd 前例） |
| D7 (2026-09-05 新指令影响判定=B 级) 部署模型转换：用户指令将 8 条部署软链（~/.zcode/skills×3、~/.claude/skills×4、~/.agents/skills×1）改为真实文件拷贝；不影响本计划 Phase 2-4 工作，但 Phase 5 部署端核实语义从"软链自动生效"变为"合并后用 cp -rL 重新拷贝同步"（VC-7 括号内"实体副本则同步"分支已天然覆盖） | 用户明确指令；转换后 repo 变更不再自动传播到部署端，v0.5 合并回时必须显式重新同步，否则部署端停留在 v0.4 快照 |
| D8 (2026-09-05 新指令影响判定=独立任务) findings/progress 有效使用强化：用户指出三文件罗盘执行中沦为模板摆设（例证即本计划：findings.md 前 107 行模板未动、启动后 42+ 分钟停更、绕过模板末尾自由追加），要求修改 task-planner 条目确保有效使用。判为独立新任务 task-3file-enforce（改 Rule 19 体系/脚本/模板，与本计划 Phase 3 的 Rule 24 段不同 hunk）；本计划 Phase 2 让位暂停 | 同文件跨任务并行需 hunk 隔离；本计划半成品已落盘可恢复；用户新指令优先级最高（P0-1） |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 每次 Phase 完成 → 调用 `Skill("task-drift-guard")`
- 计划文档留在主仓 plans/，实现全部在 worktree 绝对路径下进行
- 记忆「plan-resume v0.5 合并待立项」经调研证伪（v0.4 已收编,零漂移）——v0.5 即本次要建的版本，Phase 5 修正记忆
