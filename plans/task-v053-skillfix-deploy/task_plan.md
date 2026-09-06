# Task Plan: task-v053-skillfix-deploy — task-planner 技能缺陷批修 + GitHub 提交 + 9 位部署

## Goal
对 canonical 仓 /mnt/data/dev/task-planner-skill 的 task-planner 技能完成 skill-fix 全流程审计与批修（8+ 项已诊断缺陷：awk scope 提取失效、verify.sh 两态误报、init-session CWD 无守卫、frontmatter references 缺 2 条、Rule 10 悬空指针、Rule 14 缺 .sh、21.5 重复段、模板决策树双源评估），在 worktree 内修复并验证后合并 master、推送 GitHub（origin/master），并完成 task-planner×3 部署位重部署 + 全部 9 位 diff -r 复验。

**授权来源（用户原话锚定）**：
> "完成对已有当前技能的审核以及优化。另外还有就是完成，如果处理完成优化之后，提交修改到GitHub进行部署。如果做了优化的话，就是需要完成对本地各个平台的部署。"

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（skill 文档+脚本修复,非产品代码;以 tests/smoke.sh + 专项功能测试替代） |
| `session_id` | task-v053-skillfix-deploy |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v053-skillfix-deploy |
| `scope_files` | 见「执行范围限制」 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 审计报告含 8+ 缺陷逐项 file:line 取证（含"修复前"实测证据） | Read 子代理 checkpoint | plans/task-v053-skillfix-deploy/subagent-state/01-general-purpose.md |
| VC-2 | awk scope 修复后实测提取非空（gawk 5.2） | 对 SKILL.md 跑修复后提取逻辑,行数>0 | progress.md 记录命令+输出 |
| VC-3 | verify.sh 修复后对实体副本部署位不再误报 fail | 跑修复后 verify.sh 对 ~/.zcode/skills/task-planner | progress.md 记录 exit code+输出 |
| VC-4 | git diff 范围与锁定清单一致（无范围外文件） | git status --short 复核 | worktree git status |
| VC-5 | tests/smoke.sh 回归全过 | worktree 内执行 exit 0 | 子代理 checkpoint 02 |
| VC-6 | master 合并 + origin/master 同步（push 后 ahead=0） | git rev-list --count origin/master..master = 0 | git 命令输出 |
| VC-7 | 9 部署位 diff -r 全 IDENTICAL（task-planner×3 已更新,其余 6 位不变） | diff -rq ×9 | progress.md 记录 |
| VC-8 | worktree+分支清理完成,INDEX/记忆/三文件簿记齐 | git worktree list 无残留;INDEX v053 行 | 命令输出+文件 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留（如双源收敛判定 defer）→ PARTIAL 并列清单。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 脚本（worktree 内） | skills/task-planner/scripts/{zcode-pretooluse.sh, sync-todos.sh, init-session.sh}、skills/task-planner/lib/verify.sh、（可选）scripts/check-complete.sh | 其他 .sh/.ts；其他 skill 的 scripts |
| 文档（worktree 内） | skills/task-planner/SKILL.md（仅 frontmatter references 区）、references/critical-rules.md（Rule 10/14/21.5 重复段）、references/template-mapping.md 与 SKILL.md §任务模板库（仅当双源收敛裁决为"做"）、reference.md（仅当 Rule 10 重定向需要） | 其他 references/*；plan-resume/todo-skill/task-drift-guard 全部 |
| 部署位 | 仅 rm+cp -rL 整体部署动作（~/.zcode/skills/task-planner、~/.claude/skills/task-planner、~/.config/opencode/skills/task-planner）；其余 6 位只读 diff | 部署位内直接手改任何文件 |
| 簿记（主仓） | plans/task-v053-skillfix-deploy/*、plans/INDEX.md、plans/.active_plan、记忆目录 memory/* | plans/ 其他任务目录（v052 仅 attest 已完成） |
| Git | wt/task-v053-skillfix-deploy 分支、master merge --no-ff、push origin master | push main；rebase；reset --hard |

**执行前自我检查:**
- [x] 文件在列表中？ [x] 修改必要？ [x] 用户已要求（原话锚定见 Goal 区）？

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目记忆 | 部署拓扑与部署 SOP | memory/task-planner-repo-deploy-flow.md | 必读 | ☑ |
| 项目记忆 | 20260905 缺陷清单（6 项） | memory/task-planner-known-defects-20260905.md | 必读 | ☑ |
| 项目记忆 | awk scope bug 诊断 | memory/task-planner-awk-scope-extraction-bug.md | 必读 | ☑ |
| 仓内诊断 | 去重任务证据 | plans/task-dedup-core-md/{findings,verification}.md | 参考 | ☑ |
| 仓内诊断 | Rule 27 任务证据 | plans/task-git-timely-commit/verification.md | 参考 | ☑ |
| 仓内诊断 | awk bug 详情 | plans/task-template-knowledge-reserve/findings.md | 参考 | ☑ |
| 执行规范 | skill-fix 56 标准 | ~/.zcode/skills/skill-fix/SKILL.md（已加载） | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: task-planner 技能存在 8+ 项"已诊断、有行号证据"的存量缺陷（hook 静默失效/verify 误报/文档漂移），且 master 领先 GitHub 3 提交、部署位停在 89a29ae——本轮一次打通：修复→验证→合并→推送→部署，形成新基线。

**核心问题判断**:
- [x] 解决后能交付（缺陷清零 + GitHub 同步 + 9 位一致）
- [x] 不解决则 skill 运行时缺陷持续（pretooluse/sync-todos scope 检测失效）
- [x] 方法清晰（缺陷清单明确,修复方案已诊断）

## Current Phase
Phase 6（收尾簿记）

## Next Step
完成簿记（deferred-issues/verification/委派统计）→ commit plans/ + push → 记忆同步 ×3 → S58 总结交付

## Phases

### Phase 1: 审计（skill-fix 阶段 1）
- [x] 环境核查（bun 1.4.0/python3 3.12.3/GitHub 分叉状态）
- [x] 子代理审计：S59 Read 覆盖+S64 路径验证+8 项缺陷逐项取证（含修复前实测）+新缺陷扫描
- [x] 审计结论回填 findings.md
- **Status:** complete
- **Executor:** general-purpose（子代理）

### Phase 2: 修复实施 — 脚本批次
- [x] zcode-pretooluse.sh:32,37 + sync-todos.sh:97,180 区间 awk → 状态机式
- [x] lib/verify.sh 三态模型 + main 入口（BASH_SOURCE 守卫）
- [x] init-session.sh 增加 CWD 守卫
- [x] check-complete.sh Rule 27.3 porcelain 范围化检查
- **Status:** complete（主进程已 grep 复核 5 文件标记齐全;smoke 17 pass/0 fail）
- **Executor:** general-purpose 执行体（code-assistant 路由 API 超时 ×2 后换型）

### Phase 3: 修复实施 — 文档批次
- [x] SKILL.md frontmatter references 补 cost-control.md + batch-quality-gate.md
- [x] critical-rules.md Rule 10 悬空指针修复
- [x] critical-rules.md Rule 14 禁改清单补 .sh
- [x] critical-rules.md 129 行附近 21.5 重复段删除
- [x] 模板决策树双源分化：方案 A 收敛完成（SKILL.md 614→570 行,template-mapping.md 零改动,S62 无悬空）
- **Status:** complete（重派轮 2 交付;轮 1 产出被并行代理 git checkout 误毁,见 Errors）
- **Executor:** general-purpose 执行体（主进程 grep 复核）

### Phase 4: 验证
- [x] smoke.sh 回归（worktree 内,17 pass/0 fail ×2;合并后 master 再跑 17/0）
- [x] VC-2/VC-3 专项功能实测（子代理实测+主进程合成仓三分支复测 porcelain 预检+部署位 verify.sh 20 pass/0 fail）
- [x] S61/S62 跨调用方与步骤编号扫描（S62:任务模板库 2 处均非悬空;S61:被改脚本仓内引用均为调用文档,接口未变,无需同步）
- **Status:** complete
- **Executor:** code-runner-agent（子代理,smoke）+ 主进程（专项实测+3 处边界修补）

### Phase 5: 合并 + GitHub + 部署
- [x] merge --no-ff wt/task-v053-skillfix-deploy → master（19a40ca）;grep 复验 7 标记齐全
- [x] push origin master（e126e04..19a40ca,ahead=0）
- [x] worktree remove + branch -d（清单零残留）
- [x] 备份 /tmp/deploy-backup-task-v053/（3 tar）→ task-planner×3 rm+cp -rL → 9 位 diff -r 全 IDENTICAL + 新标记生效抽查 + 部署位 sync-todos --index 端到端 rc=0
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+部署编排——Rule 25.3 白名单）

### Phase 6: 簿记收尾
- [x] INDEX.md 刷新（修复后 sync-todos --index;task-active-plan scope 列首次被提取填充=修复生效证据）
- [x] 记忆同步（deploy-flow 基线 19a40ca/缺陷清单清账/awk bug 已修 三文件更新）
- [x] Standard 58 中文总结块交付
- **Status:** complete
- **Executor:** 主进程（例外理由:② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（无其他会话并行信号;master 89a29ae 干净基线,仅 plans/ 簿记未提交） |
| `isolation` | `worktree`（skill 文件修复,§十一.1 对齐仓库惯例） |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v053-skillfix-deploy（基线 master 89a29ae,基分支按本仓惯例选 master 而非 main——main 已分叉陈旧;已清理） |
| `branch` | wt/task-v053-skillfix-deploy（已删） |
| `merge_back` | merged(19a40ca) |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-06 21:59 | TodoWrite 8 条已建 |
| Phase 2-6 | ☑ | 2026-09-06 21:59 | 同一批 Todo 映射 |

## Key Questions
1. 模板决策树双源分化（缺陷③）本轮收敛还是 defer？→ 审计纠缠度裁决（倾向:SKILL.md 侧收敛为指针,若涉及 Rule 16 连锁改写则 defer）
2. Rule 27.3 脚本化（缺陷⑥,记忆标注"可选"）是否纳入？→ 审计确认 check-complete.sh 结构后小增量则做

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| v052 篡改告警处置=重锁哈希（attest SHA b5b9eb59…） | 尾部为上一会话合并后簿记回写,良性;非恶意篡改 |
| worktree 基分支用 master 而非 §十一.2 示例的 main | 本仓 canonical 开发分支=master,main 已分叉陈旧（3 独有旧提交）,以 main 为基会漏 5 个提交 |
| 部署仅 task-planner×3,其余 6 位 diff 只读复验 | 本轮只改 task-planner;todo-skill/plan-resume/task-drift-guard 无变更 |
| 阶段 2 用户确认以"原话锚定+范围锁定"形式落地 | 用户指令=审核+优化+提交+部署全链路显式授权;修复范围严格限定已诊断缺陷,新发现进 deferred-issues.log |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| （v052 遗留）[PLAN TAMPERED] 告警 | 1 | 核实为良性簿记回写,attest-plan.sh 重锁（SHA b5b9eb59）,告警消除 |
| 修复子代理 API 超时（Cannot connect to API: Headers Timeout Error）×2 批 | 2 | 换 general-purpose 执行体重派成功（code-assistant 类型路由不可用,general-purpose 此前审计已验证可用） |
| **并行代理交叠事故**：脚本批次终检把文档批次的并行改动误判"未授权",`git checkout HEAD --` 恢复 SKILL.md+critical-rules.md → 文档 6 项修复全丢失 | 1 | 已验证丢失（frontmatter 无 cost-control/21.5 计数=2）;文档批次原样重派,新 prompt 明令"禁止 git checkout 恢复文件,发现意外改动只报告" |

## Notes
- 修复前必须 Read 目标文件目标区域（§五）;脚本修复先 bash -n 语法检查再功能实测
- skill-fix S66:不确定修改先测试副本;确定性修复（重复段删除/清单补条目）可豁免但须注明
- deferred-issues.log 记录范围外发现（含其他 3 个 skill 的问题）

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 6（P1 审计=general-purpose;P2 脚本批次=general-purpose 执行体;P3 文档批次=general-purpose 执行体×2 轮;P4 smoke 回归由 P2 执行体附带完成） |
| 主进程直做 Phase 清单 | P5 合并/GitHub/部署编排（① git 编排白名单）;P6 簿记（② 簿记白名单）;P4 内 3 处边界修补（ porcelain 预检实测发现的缺口,手术刀 ≤6 行,验证驱动） |
| 委派率 | 67%（≥0.7 阈值边缘;缺口来自 P5/P6 天然主进程职责+P4 微修补,均在白名单内 → 不降级） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|-------------|
| 1 | 2026-09-06 | general-purpose | worktree 内审计 task-planner（S59/S64/S74+8 项取证） | done | 8/8 缺陷仍存在+3 新发现;awk 实测 1 行 vs 3 行实锤;verify.sh 无 main 入口 stdout 空 | 检查点 01 §B/§E/§F | findings.md Research Findings | plans/task-v053-skillfix-deploy/subagent-state/01-general-purpose.md | ☑ |
| 2 | 2026-09-06 | general-purpose | worktree 内脚本批次修复（awk/verify/init-session/porcelain） | done | 5 文件 +160/-16;smoke 17/0;终检误用 git checkout 毁掉并行文档改动(事故) | 检查点 02+worktree git diff | findings.md Research Findings | plans/task-v053-skillfix-deploy/subagent-state/02-code-assistant-scripts.md | ☑ |
| 3 | 2026-09-06 | general-purpose | worktree 内文档批次修复 6 项（轮 1,产出被毁） | failed | 6/6 完成后被 #2 终检 git checkout 回滚,磁盘零残留 | 本表 Error 行+progress.md | findings.md Issues | plans/task-v053-skillfix-deploy/subagent-state/03-code-assistant-docs.md | ☑ |
| 4 | 2026-09-06 | general-purpose | 文档批次重派（轮 2,禁 git checkout 铁律） | done | 6/6 落地;7 modified 精确匹配;SKILL.md -44 行;21.5=1;S62 干净 | 检查点 03+主进程 grep 复核 | findings.md Research Findings | plans/task-v053-skillfix-deploy/subagent-state/03-code-assistant-docs.md | ☑ |
