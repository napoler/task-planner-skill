# [sub:audit-coverage] 任务类型→执行体 登记与可用性交叉审计

status: done
时间: 2026-10-03
审计范围: 三登记面 × /home/terry/.zcode/agents/（93 文件，agent 定义 .md 89 个，排除 test.md / README-model-sync.md / *.mjs / model-tiers.json / setup-machine.sh / web-search-modules/）

## 登记面锚点
- D1 = /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md :333-357 路由表（§子代理路由与模型分级）
- D2 = /home/terry/.zcode/skills/skill-agent-router/SKILL.md :25-101 路由表（八大类）
- D3 = /mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-mapping.md :258-289（§九 执行体路由组列）+ :304-312（§十 默认执行体列）

## 一、覆盖矩阵（类型族 → 登记执行体 → 存在性）

| 类型族 | 登记执行体（面） | 存在 | 缺口 |
|---|---|---|---|
| 计划/架构/编排 | plan-writer(D1), complex-planner(D1/D2), planner(D1/D2), architect(D1/D2), task-orchestrator(D1/D2) | 全部存在 | - |
| 代码编辑小改 | code-assistant(D1/D2/D3) | 存在 | - |
| 代码编辑大改/跨文件 | executor(D1/D2/D3) | 存在 | - |
| 重构/瘦身 | code-simplifier(D1/D3), refactor-cleaner(D2) | 存在 | - |
| 构建错 | build-error-resolver(D1/D2/D3) | 存在 | - |
| bug/根因 | debugger(D1/D2/D3) | 存在 | - |
| 跑测试 | code-runner-agent(D1/D2/D3) | 存在 | - |
| 体检 | codebase-analyzer(D1/D2) | 存在 | - |
| 测试编写 | test-engineer(D2/D3) | 存在 | - |
| 性能 | performance-optimizer(D2) | 存在 | - |
| JSON | json-edit-agent(D2) | 存在 | - |
| 数据库 | database-optimizer(D2/D3) | 存在 | - |
| 审查/挑刺 | code-reviewer(D1/D2/D3), critic(D1/D2), verifier(D2/D3), agent-quality-auditor(D2) | 全部存在 | - |
| 搜索/文档 | explore(D1/D2/D3), web-search-agent(D1/D2/D3), doc-search-agent(D1/D2/D3), forum-search-agent(D2), oss-search-agent(D2), document-specialist(D2) | 全部存在 | - |
| 浏览器/抓取 | browser-automation(D1/D2), web-scraper(D2) | 存在 | - |
| CLI | cli-executor-agent(D2), cli-tool-builder(D2) | 存在 | - |
| 数据 | data-engineer/analyst/analytics-reporter/data-cleaning-expert/data-synthesizer/ai-data-remediation-engineer(D2) | 全部存在 | - |
| 其他 | simple-agent/complex-problem-solver/context-manager/time-keeper/meta-corrector(D2), complex-planner(D2) | 全部存在 | - |
| writing | article-writer(D1/D3), article-writing-phase-agent(D3) | 存在 | - |
| research | research-assistant(D1/D3), web-search-agent(D3) | **research-assistant 在 agents/ 无实体** | B |
| publish | code-runner-agent/article-batch-publish(D3) | 实际文件=article-batch-publisher.md，**登记名不符** | B |
| memory-hygiene | executor(fresh)/verifier(D3) | 存在 | - |
| video | Agnes 视频链路/D3 | 指向项目专属资产，环境缺位→兜底 executor(:298 条款) | B* |
| video-fix | videop1-video-fix SOP(D3:274) | 项目专属资产，同兜底 | B* |
| 媒体11类(image/character-design/multiview-ref/storyboard/prompt-struct/video-prompt/motion-camera/physics-compliance/qc-defect/audio-voice/final-assembly) | 「写词/QC/判定/剪辑/核对子代理」泛称(D3:277-288) | **无具名映射**，兜底=executor(sonnet-1)+工序 SOP(:298 条款) | A |
| 规则/模板组 | executor + worktree 隔离(D3:309) | 存在 | - |
| 迁移/部署组 | 主进程 git 编排+executor(D3:310) | 存在 | - |
| 轻量档 | code-assistant 或主进程白名单(D3:311) | 存在 | - |
| 调研/诊断组 | explore/web-search/debugger(D3:312) | 存在 | - |
| general | 按 Phase Executor 逐案路由(D3:289) | 设计如此 | - |

## 二、三类缺口清单

### A 类 = 类型族无具名执行体映射（会落泛兜底/generic）
| # | 类型族 | 证据 | 说明 |
|---|---|---|---|
| A1 | 媒体 11 类（image 及 videotpl 工序族） | template-mapping.md:277-288 | 路由组列写「写词/审查/QC/判定/剪辑/备份子代理」等泛称，无具名 agent；依赖 :298 兜底条款（executor(sonnet-1)+variant SOP+生成技能） |
| A2 | video / video-fix | template-mapping.md:273-274 | 指向「Agnes 视频链路」「videop1-video-fix SOP」项目专属资产，当前环境无对应具名 agent |

### B 类 = 登记映射指向的 agent 不存在/名不符（逐条实证：`ls /home/terry/.zcode/agents/<name>.md` 无结果）
| # | 登记名 | 证据（登记处） | 实测 |
|---|---|---|---|
| B1 | script-writer | template-mapping.md:278 | `test -f .../script-writer.md` → 不存在 |
| B2 | script-auditor | template-mapping.md:278 | 同上，不存在 |
| B3 | research-assistant | task-planner/SKILL.md:348、template-mapping.md:268 | agents/ 无 research-assistant.md（它是 skill，`Skill("research-assistant")` 可用，但 `Agent(subagent_type=research-assistant)` spawn 无实体） |
| B4 | article-batch-publish | template-mapping.md:268(:266 行 publish 行原文「article-batch-publish」) | 实际文件为 article-batch-publisher.md，登记名与实体名不符（缩写漂移） |
| B5 | ComplexProblemSolver（大小写） | task-planner/SKILL.md:340, :350 | 实体=complex-problem-solver.md；属引用格式不一致，非缺失，列此备忘 |

### C 类 = 有可用 agent 实体但三处登记面均未登记（有体不用）
实证方法：对 agents/ 每个 .md 名做三文件 grep（word 命中才算），无命中者即 C 类。共 41 个（另注：`quality-auditor` 实体会被 `agent-quality-auditor` 子串遮蔽，需单独计）：
- 文章管线相（10）：article-batch-publisher*、article-content-editor、article-data-fetcher、article-field-fixer、article-publish-phase-agent、article-research-heavy-agent、article-research-phase-agent、article-reviewer、article-site-router、article-synthesis-phase-agent
  *（article-batch-publisher 因 B4 名不符，登记形 article-batch-publish 视为「登记面未正确指向该实体」，双挂 B4/C）
- 数据/研究相（5）：api-tester、scientist、data-consolidation-agent、search-query-analyst、log-distiller
- 内容/营销相（7）：technical-writer、ui-designer、frontend-developer、marketing-content-creator、marketing-seo-specialist、organic-content-strategist、seo-specialist
- 质量/校验相（5）：quality-auditor、quality-check-agent、quality-control-agent、content-origin-verify-agent、doc-sync-verify-agent
- 运维/Git/记忆相（5）：cron-patrol、git-master、git-security-expert、worktree-janitor、memory-librarian
- 其他（9）：auto-agent、explore-fb、web-search-opencode、ai-engineer、cross-border-e-commerce-specialist、plan-bookkeeper、frontmatter-linter、writing-skills、quality-reviewer

注意：router SKILL.md:7 声明「文章管线专用 agent（article-* 系列）…不在本路由范围内」，article-* 未登记属有意豁免，但 D3 template-mapping §九 只登记了 article-writer/article-writing-phase-agent 两个，其余 9 个 article-* 仍为 C 类。

## 三、T5 最终结论
1. 代码组/规划/验证/搜索/CLI/数据六大类登记完整、实体齐全，无缺口。
2. 内容组 publish 行存在登记名漂移（B4）；research 行把 skill 当 agent 名登记（B3，spawn 语义下是缺口，skill 调用语义下可用）。
3. 媒体制作族（11 类）无具名执行体映射，全部依赖 executor 兜底条款（A1/A2）——是登记面最大缺口面。
4. agents/ 目录约 1/3 实体（41 个 agent .md）未被任一登记面正确收录（C，含 1 个名漂移双挂），其中 article-* 有豁免声明，质量相/营销相/运维相无豁免说明。
5. 建议（供主进程决策，本单元不改文件）：① 修 D3:266 名漂移；② D1:348 注明 research-assistant 为 skill 而非 agent；③ 媒体 11 类补具名映射或显式登记「无具名映射，executor 兜底」；④ C 类逐决定纳入或豁免。

## 8 字段返回块
```
status: done
acceptance: 3/3 pass — [1]覆盖矩阵✅ [2]三类缺口逐条✅ [3]证据+检查点+findings✅
files: /mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/2-coverage.md(+new); /mnt/data/dev/task-planner-skill/plans/task-v125/findings.md(+append)
evidence: template-mapping.md:278(script-writer/script-auditor 无实体); SKILL.md:348(research-assistant); template-mapping.md:266(article-batch-publish 名漂移); ls ~/.zcode/agents/(93 项)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/2-coverage.md (status: done)
findings_written: findings.md ## Research Findings 段末 #### [sub:audit-coverage] 覆盖矩阵与三类缺口
blockers: none
confidence: HIGH
```
