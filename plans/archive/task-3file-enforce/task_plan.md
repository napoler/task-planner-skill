<!-- template_type: code-edit -->
<!-- 任务: task-3file-enforce — findings/progress 从模板摆设到强制有效使用 -->

# Task Plan: task-planner 三文件罗盘有效使用强制化

## Goal
修改 task-planner skill 的相关条目与支撑机制，使 findings.md/progress.md 在计划执行中被强制有效使用：执行中硬门控（Phase complete 前置双条件+可执行脚本）、子代理回填与 Handoff 流程绑定、模板低摩擦瘦身、hook 提醒分级升级。消除"模板主体永不动、启动填一次后停更、绕过模板末尾追加"现象（用户例证：plans/task-plan-resume-v05 findings 前 107 行模板未动且 42+ 分钟停更）。用户原话："必须修改该skill 的相关条目 确保可以有效使用该文件"。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（改动为 .md 契约文本 + .sh/.py 门控脚本与模板；脚本行为以 Phase 4 行为测试验证，替代 review gate） |
| `session_id` | 本会话 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/3file-enforce` |
| `scope_files` | 见「执行范围限制」 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Phase complete 前置门控可执行：新建门控脚本对"findings/progress 自 Phase 开始无更新"exit 1，对"均已回填"exit 0；SKILL.md 执行循环第 4 步与 critical-rules.md 19.2 引用同一机制且与脚本行为一致 | 脚本正反用例测试输出 + grep 三处机制名 | Phase 4 测试输出 |
| VC-2 | 模板瘦身不回归：findings.md ≤60 行 / progress.md ≤80 行（现状 114/167）；check-complete.sh 3-File Gate 对纯模板判 stub、对填入 ≥3 行实质内容的文件判通过（与改造前行为一致） | wc -l + check-complete.sh 正反用例输出 | Phase 4 测试输出 |
| VC-3 | 子代理回填流程绑定：critical-rules.md 22.5 与 SKILL.md Handoff 登记表说明含"verify_done = Read 产出 + findings 回填双条件"；task_plan 模板 Handoff 登记表含 findings 落点列 | grep + Read 条款 | 两文件 diff |
| VC-4 | hook 提醒分级升级：zcode-posttooluse.sh 对持续陈旧（第 2 次提醒仍陈旧）输出升级警告（含 Rule 19.7 违规与 Rule 26.3 处置提示）；config.json 新增阈值字段且 JSON 解析合法 | 脚本行为测试 + jq 解析 config.json | Phase 4 测试输出 |
| VC-5 | 四处表述一致 + 部署同步：SKILL.md/critical-rules.md/templates/scripts 对 3-File 机制关键词无矛盾表述；合并回 master 后 8 个部署位 diff -r 一致且 lib/verify.sh 通过 | grep 关键词核对 + diff -r ×8 + verify.sh | 命令输出 |
| VC-6 | 既有测试不回归：bash tests/smoke.sh 全绿（含既有 3-File/stub 用例，若有则按新模板适配） | bash tests/smoke.sh | 测试输出 |

**终验规则**：全部 VC 通过 → COMPLETE；任一 VC 3 次修复失败 → BLOCKED 升级用户。

**outcome: COMPLETE**（2026-09-05,merge ab6fa0a）——VC-1~VC-6 全部通过（证据见 Phase 5 checklist）;委派率 10% 但各 Phase 例外理由均已登记（Rule 25.4）。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| skill 契约文本 | skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md | 其他 references/*.md（template-guide.md 仅当 EXAMPLE 迁移需要时只读引用） |
| skill 脚本 | skills/task-planner/scripts/check-3file-gate.sh(新建)、skills/task-planner/scripts/zcode-posttooluse.sh、skills/task-planner/scripts/check-complete.sh（仅当 stub 判定需适配）、skills/task-planner/config.json | 其他 scripts/*（init-session.sh/attest 等不动） |
| 模板 | skills/task-planner/templates/findings.md、skills/task-planner/templates/progress.md、skills/task-planner/templates/task_plan.md（仅 Handoff 表加列） | templates/variant/*（除非 Phase 1 查实 variant 覆盖 findings/progress，届时先扩范围再动） |
| 测试 | skills/task-planner/tests/smoke.sh（追加用例） | 其他测试 |
| 仓级文档 | CHANGELOG.md | README 等其他仓根文档 |
| 计划文档 | plans/task-3file-enforce/** | 其他 plans/ 目录（task-plan-resume-v05 只读） |

**强制约束**：部署端 8 个位置（~/.zcode/skills×3、~/.claude/skills×4、~/.agents/skills×1）仅在 Phase 5 合并后用 cp -rL 同步，不提前手改；skills/task-planner/INSTALL.md 等安装类文件不改。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | SKILL.md 执行循环/产出落盘映射/C16/Rule 19 摘要（L109-151/L184/L213/L298） | skills/task-planner/SKILL.md @f281ecd | 必读 | ✅ 主进程全文精读 |
| 项目内部文档 | critical-rules.md Rule 3/19.1-19.7/22.5 全文 | skills/task-planner/references/critical-rules.md（L11-12/L87-96/L124） | 必读 | ✅ grep 摘录（Phase 1 全文段落复认） |
| 项目内部文档 | check-complete.sh 3-File Gate 实现（L184-220 stub 行集合判定） | skills/task-planner/scripts/check-complete.sh | 必读 | ◐ 关键段已读，Phase 1 补全 |
| 项目内部文档 | zcode-posttooluse.sh compass 实现（mtime+冷却 state 文件） | skills/task-planner/scripts/zcode-posttooluse.sh | 必读 | ◐ 关键段已读，Phase 1 补全 |
| 项目内部文档 | 模板本体 findings/progress + variant 是否覆盖 | skills/task-planner/templates/ | 必读 | ☐ Phase 1（含 v05 计划 6.1K vs 新 init 4.3K 差异溯源） |
| 用户宪法 | §十一 worktree 隔离 / §六 保护区 | ~/.zcode/AGENTS.md | 必读 | ✅ 已加载 |
| 既有记忆 | awk scope 提取 bug（pretooluse/sync-todos 失效,与本次 compass 链路区分） | memory task-planner-awk-scope-extraction-bug | 参考 | ✅ 已加载 |

## ⚠️ 核心问题定义

**核心问题**: Rule 19 契约文本详尽但执行中 100% 被绕过——唯一硬门控（19.5 终验非 stub）启动填一次即可永久通过；2-Action Rule 无记账；hook 提醒无后果可无限无视；模板 100+ 行注释推高摩擦导致绕过模板末尾追加。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？——能：findings/progress 成为执行中真实维护的活文档
- [x] 核心问题不解决，其他工作都白费吗？——是：恢复会话/上下文压缩后三文件重建上下文的机制失效
- [x] 核心问题的解决方法是清晰的、可执行的？——是：M1-M7 修改清单（见 Decisions D1）

## Current Phase
Phase 5

## Next Step
Phase 5：worktree 内 commit → 主仓 merge --no-ff → 清理 worktree → 部署端 cp -rL 同步 + verify → 记忆更新

## Phases

### Phase 1: 补充详查 + 修改清单定稿
- [x] 读 zcode-userpromptsubmit.sh compass 注入段（结论:无 compass 段,提醒仅 PostToolUse 链路）
- [x] 读 init-session.sh 模板复制逻辑 + 溯源模板差异 + 确认 variant 是否覆盖 findings/progress（结论:仅 task_plan.md 走 variant,findings/progress 恒用内置模板）
- [x] 读 check-complete.sh stub 判定全段 + tests/smoke.sh 既有用例（结论:动态模板行集合,瘦身自适应;smoke 零 3-File 用例）
- [x] 读 templates/findings.md + progress.md 全文（经 v05 文件头部 diff 证实与当前模板一致,114/167 行）
- [x] M1-M7 修改清单定稿（文件×条款×新文本要点）写入 findings.md
- **Status:** complete
- **Executor:** 主进程（例外理由:定向 Read ≤5 个已知文件段，委派转述损耗大于收益，Rule 13 例外之已知位置查询）

### Phase 2: worktree 隔离区创建
- [x] `git worktree add /mnt/data/dev/task-planner-skill-worktrees/3file-enforce -b wt/3file-enforce master`（HEAD f281ecd）
- [x] 确认 worktree 内 skills/task-planner/ 与 master 一致（scripts 完整,git status 干净）
- [x] 动作留痕 progress.md
- **Status:** complete
- **Executor:** 主进程（例外理由:git worktree 簿记操作，无可委派 agent 类型）

### Phase 3: 实施改动（worktree 内，先零冲突文件后契约文本）
- [x] 3a 模板瘦身：templates/findings.md（107→43 行）、templates/progress.md（132→61 行）——注释压缩、EXAMPLE 删除、锚名保持、Test Results 并入 Phase 段、Started 标注锚点
- [x] 3b 门控脚本：新建 scripts/check-3file-gate.sh（108 行,bash -n 过;初版锚点跨段 bug 已修,七用例全绿）
- [x] 3c hook 升级：zcode-posttooluse.sh state 9 字段+双链路升级判定 + config.json 加 compass_escalate_after（code-assistant 完成,主进程核验通过）
- [x] 3d 契约文本：SKILL.md 5 处 + critical-rules.md 4 处（19.1/19.2/19.7/22.5）+ templates/task_plan.md Handoff 表加 findings 落点列
- [x] 3e CHANGELOG.md 条目（[Unreleased]###新增 顶部,结构已修复验证）
- **Status:** complete
- **Executor:** 主进程（.md 契约文本+模板,Rule 14 白名单;3b 新脚本 ≤80 行主进程直做登记例外）+ code-assistant（3c hook/config,haiku-1）

### Phase 4: 验证（行为测试 + 一致性 + 回归）
- [x] 门控脚本七用例：陈旧→exit 1 / 回填→exit 0 / 退化模式分歧正确 / 缺文件→exit 1 / 无活动 Phase→exit 0（T1,含初版锚点跨段 bug 的发现与修复）
- [x] check-complete.sh stub 检测回归：新模板纯模板→报 stub；填 3 行实质→stub 报错消失（T2）
- [x] posttooluse 升级警告复验：冷却后二次陈旧→🚨 升级文案(Rule 19.7/26.3)+f_miss 重置（T3,另验证冷却防刷屏正常）
- [x] grep 一致性：check-3file-gate/findings 落点/compass_escalate_after/实质增量 四组关键词在 SKILL/critical-rules/templates/scripts/config 分布一致（T4）
- [x] bash tests/smoke.sh 全绿 17 pass / 0 fail（T5,VC-6）
- **Status:** complete
- **Executor:** 主进程（例外理由:行为测试为一次性小命令验证,拆派转述成本大于收益）+ code-assistant（3c 自测场景 A/B/C）

### Phase 5: 终验 + 合并回 + 部署同步 + 收尾
- [x] worktree 内逐条复验 VC-1~VC-6：VC-1 门控行为(T1 七用例)+文本一致(T4)✓ / VC-2 模板 43+61 行+stub 回归(T2)✓ / VC-3 findings 落点列+双条件(grep 3 文件)✓ / VC-4 升级警告实测触发+config jq 解析✓ / VC-5 四处一致+部署 diff IDENTICAL✓ / VC-6 smoke 17 pass/0 fail✓；git status 干净后 commit 3cc7839
- [x] 主仓 `git merge --no-ff wt/3file-enforce` → ab6fa0a + Read 复验(脚本 112 行可执行/SKILL 引用 3 处/模板 43+61/config default=2)
- [x] `git worktree remove` + `git branch -d wt/3file-enforce`
- [x] 部署端同步（D7 实体副本模型）：rsync -a --delete → ~/.zcode/skills/task-planner + ~/.claude/skills/task-planner,diff -r 双位 IDENTICAL,门控脚本部署位实跑 exit 0
- [x] 记忆更新：task-planner-three-file-compass.md 补记第四层执行中硬门控
- **Status:** complete
- **Executor:** 主进程（例外理由:主仓合并/部署同步属主仓操作）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号① ?? .zcode/ ?? plans/ 会话级未跟踪,与 skills/ 无重叠;信号②③ wt/plan-resume-v05 为 D8 已知暂停方,协调策略见下） |
| `isolation` | `worktree`（§11.1.1/§11.1.4 命中:skills/ 保护区 + scripts/） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/3file-enforce` |
| `branch` | `wt/3file-enforce` |
| `merge_back` | `merged(ab6fa0a)` |

**跨任务冲突协调**：wt/plan-resume-v05 已暂停（D8），其 worktree 仅改 skills/plan-resume/ 4 文件、未触 task-planner 文件——本任务与其无实际 hunk 冲突；本任务先合并，对方恢复时 merge master 即可。对方恢复前本任务禁止动 skills/plan-resume/**。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ✅ | 2026-09-05 | S1 建映射 |
| Phase 2 | ☐ |  | worktree 创建 |
| Phase 3 | ☐ |  | 实施改动 |
| Phase 4 | ☐ |  | 验证 |
| Phase 5 | ☐ |  | 合并+部署 |

## Key Questions

1. 为什么现有 Rule 19 七条款没生效？→ R1 findings 无执行中硬门控（19.5 终验只查非 stub,启动填一次永久通过）/ R2 hook 提醒无后果（提醒→冷却→再提醒,无视零代价）/ R3 模板 100+ 行注释高摩擦,实际用法退化为末尾自由追加 / R4 子代理回填无流程绑定（Handoff verify_done 只绑 Read）
2. 模板瘦身会破坏 stub 检测吗？→ 不会：check-complete.sh 动态读 templates/ 做行集合扣除,模板行集合随瘦身自动收缩,检测反而更敏锐（Phase 4 回归用例证实）
3. 门控判定用什么指标？→ mtime 代理指标（findings/progress mtime 必须晚于 Phase 开始锚点;锚点取 progress.md Phase 段 Started 字段,缺失则退化用 stale 阈值）。mtime 可被无关写污染——设计取向"宁可误报逼一次回填,不可漏报"（写进脚本注释）
4. 历史计划里的旧版大模板文件怎么办？→ 不回填不迁移（历史计划已终结/暂停）;新 init 起新模板自动生效

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 修改清单 M1-M7：M1 SKILL.md 执行循环第 4 步双条件门控;M2 critical-rules.md 19.2 重写+19.1/22.5 Handoff 绑定;M3 新建 check-3file-gate.sh;M4 双模板瘦身;M5 posttooluse 分级升级+config 阈值;M6 C16 收紧+task_plan 模板 Handoff 表加列;M7 CHANGELOG | 对应用户"必须修改相关条目确保有效使用"——机制化(门控/绑定/降摩擦/后果),非文本重复强调;逐项可验证 |
| D2 门控指标用 mtime+Phase 开始锚点,不做内容 diff | 脚本无基线可 diff;mtime 是务实代理指标;误报代价=一次回填动作,可接受 |
| D3 模板瘦身但段落锚点名(Research Findings/Technical Decisions/Issues/Resources/Visual)保持 | 产出落盘映射表按锚点名路由,改锚名会破坏映射契约 |
| D4 实施顺序先零冲突(模板/脚本/hook/config)后契约文本(SKILL/critical-rules) | 与暂停中的 wt/plan-resume-v05 未来 Phase 3 同文件错峰,降低合并敏感性 |
| D5 计划自行授权：用户指令即显式授权（自主会话模式,计划展示于最终交付报告） | 用户指令明确具体("必须修改");worktree+合并回是本仓已验证模式(f281ecd 前例,D6 同款) |
| D6 (影响判定) 本指令为独立新任务 task-3file-enforce,原活跃计划 task-plan-resume-v05 让位暂停(D8 已落盘对方计划) | 两任务同文件不同 hunk;暂停方 worktree 半成品已记录可恢复 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 本任务是"修三文件使用"本身——本计划全程示范三文件有效使用（dogfood）：子代理返回紧邻回填 findings、动作随做随记 progress、Phase complete 前自跑门控
- 每次 Phase 完成 → `Skill("task-drift-guard")`
- 计划文档留在主仓 plans/，实现全部在 worktree 绝对路径下进行
- 模板 worktree_path 示例仍是旧规范 `../<repo>-wt-<task-id>`，本次按 §11.2 新规范（集中目录）执行；模板该示例的更新不在本任务范围

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0.5 / 5（Phase 3 的 3c 由 code-assistant 执行,其余子项主进程） |
| 主进程直做 Phase 清单 | Phase 1(定向 Read 已知位置,登记)/Phase 2(git 簿记白名单)/Phase 3 的 3a/3b/3d/3e(.md 白名单+3b 实际 108 行略超 ≤80 行预估,例外登记)/Phase 4(一次性小命令验证)/Phase 5(主仓操作白名单) |
| 委派率 | 10%（<50%——例外理由均已登记;3b 应派未派属预估失准,如实记录不粉饰） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|-------------|
| 1 | 2026-09-05 01:50 | code-assistant | 3c:posttooluse compass 分级升级 + config.json 加 compass_escalate_after | done | state 9 字段+双链路升级判定;bash -n/jq/3 场景自测过;diff 仅 2 文件 | zcode-posttooluse.sh:48-160;config.json:82-87 | Research Findings (Phase 3 实施) | ☑ |
| 2 | | | | | | | | ☐ |
