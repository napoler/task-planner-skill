# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
- R1「现在开始帮我部署。」= 把 repo 侧成果同步到三个部署位（~/.zcode ~/.claude ~/.cursor），使所有项目生效。
- R2「并提交所有修改到GitHub。」= 本仓工作树全部改动提交并推送 origin/master。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| knowledge/entries/planflow-plan-lifecycle-gates.md | knowledge/entries/planflow-plan-lifecycle-gates.md | 是 | 技术决策（门控序列编排） |
| knowledge/entries/discipline-execution-honesty.md | knowledge/entries/discipline-execution-honesty.md | 是 | 研究发现（三证据判据）+ 技术决策（独立复核） |
| skills/task-planner/references/worktree-isolation.md | skills/task-planner/references/worktree-isolation.md | 是 | 技术决策（部署位单源边界） |

## Research Findings
- **部署位与仓库是双向差异，不是单向落后**（证据：~/.zcode/skills/task-planner/SKILL.md mtime 2026-10-22 03:21、42532B；仓库同文件 mtime 2026-10-21 11:30、39875B；`diff` 显示部署位含 Rule 44.3 D1 超时自动通过 + L0-E 纯执行档，仓库含 Rule 93 规范召回 + Rule 51.9-51.12）。单向覆盖会删掉当天 03:21 才上线的活内容 → 必须并集。
- **同一技能存在三条独立工作流在写同一批文件**：① 仓库 master（Rule 93 / 51.9-51.13 / 知识库两步）；② 部署位 10-22 03:21 同步流（videop1 的 44.3 / L0-E，来自 task-videop1-protectfix-001）；③ 仓库 10-21 11:30 遗留（Rule 51.9-51.13 文本+守卫，尚未提交）。三者内容互不覆盖，必须并集落库。
- **平台运行时是部署位的真实差异维度**：claude/cursor 位是 bun 平台（install.sh 用 `bun run`、shebang `#!/usr/bin/env bun`），仓库源/zcode 位是 node 平台（`node --experimental-strip-types`）。9 个 flavor 文件的差异仅限此维度，其余内容必须逐字一致。
- **卫星层存在部署悬空引用**：仓库 task-planner 的 SKILL.md:95 / task_plan.md:312 / :140 引用 `../task-discipline/references/execution-recall-card.md` 与 Rule 93，但三位部署位的 task-discipline 卫星缺该卡且无 Rule 93 段 → 部署 task-planner 必须连卫星一起同步，否则部署后新规则指向空文件（证据：grep -c '^### 93 ' 部署位=0 / 仓库=1；execution-recall-card.md 三位 MISSING）。
- **项目级覆盖 init 解析序**：`.zcode/plan-templates/` → `~/.zcode/skills/task-planner/templates/`（init-session.sh:65-97）。本仓 .zcode/plan-templates/task_plan.md 与部署位模板逐字一致后即冗余，删除后回落部署位仍生效（冒烟：收尾两步 grep=2）。
- **init 冒烟的硬约束**：init-session.sh 要求当前目录为 `<项目>/plans/<task-id>/`，在 /tmp 下会直接报错退出（证据：实测 "必须在 plans/<task-id>/ 目录下运行"）。
- **独立复核结论**：general-purpose 子代理对三位部署位做 6 项独立核验 → VERDICT: PASS（模板两步各=2；critical-rules 51.9-51.13 在位；zcode 位差异 0；claude/cursor 差异恰为 9 个 flavor 文件且无非 flavor 差异；无冲突标记；三位 selftest-requirement-coverage 27/27）。检查点：plans/task-kb-deploy-20261022/subagent-state/1-general-purpose.md

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 部署采用「三方并集 + 冲突人工裁决」，不采用单向 rsync 覆盖 | 部署位含仓库没有的活内容（44.3/L0-E），单向覆盖 = 静默删除当天上线的规则 |
| 并集结果回写仓库作单一源，再由仓库同步到三位 | 避免「部署位为准」导致 GitHub 落后于实际生效版本；保证 repo == zcode 位、repo ≈ claude/cursor（仅 flavor 差） |
| 3 方合并的 base 取各部署位同步代对应的仓库提交（74a9188 / ecb5e54） | base 必须是双方共同祖先，否则「ours」方向反转（实测 cursor 键数断言被取成旧值 47） |
| claude/cursor 采用「仓库最新内容 + 运行时 flavor 单独还原」 | 部署位比 base 更旧时 3 方合并方向不可靠；flavor 是唯一合法平台差异，单独还原可控可验 |
| 删除项目级 task_plan.md 覆盖，保留 knowledge-brief.md 覆盖 | task_plan 覆盖与部署位逐字一致 = 双源漂移；knowledge-brief 的 §7 是项目专属段，共享模板无此需求（避免对无知识库机制的项目产生悬空引用） |
| 运行时差异不写进共享模板 | bun/node 是平台属性不是内容属性，共享模板保持单一写法，由部署环节按平台还原 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 部署位比 base 提交更旧时并集解取错侧（cursor 27 文件仍不一致） | 改两段式：rsync 全量覆盖 + flavor 还原；复验 cursor 差异=9 |
| SKILL.md 两处并集冲突（Rule 93 行 / P4 权重 0 行） | 按「内容互斥度低、双侧都要留」裁决：冲突1 留仓库 Rule 93 行，冲突2 留部署位 P4 长行 |
| cursor 3 处冲突 | 取仓库侧（Rules 1-93 计数；卫星路径 `../../` 在 cursor 位下才正确；selftest registry 2 行缺失） |
| attest 报「12 条 VC 中仅 6 条含可执行验证命令」 | Goal Gate 复选行与 VC 条目同形被重复计数 → 改前缀为「复验 VC-N：」 |
| CR 首轮 Blocker：会话级轻量标记对任意路径放行 | 口径① 复用口径② 的机械产物区 + gitignore 判定；受管文件实测 exit 0→1；修复提交 14d6673，合并 eaa58af |
| CR 首轮 Suggestion：模板 §7 悬空指针 | 改为条件式引用「项目级 knowledge-brief.md §7 入库回链段，若有」 |

## 🔖 CR 复审遗留项登记（CR APPROVED WITH NITS，0 Blocker）
> 来源：Code Reviewer 复审（第二轮）。以下均为**非阻断**，且经复审核实其中 4 项系本次部署（9ec6fea）引入/激活，
> 非历史遗留。按 §四.6 文本优先 + L0-T 纯文本档登记为待修清单，本轮不实施（超出「部署 + 提交」射程）。

| # | 位置 | 缺陷 | 级别 | 引入方 | 待修方向 |
|---|------|------|------|--------|---------|
| L-1 | `skills/task-planner/scripts/check-delegation.sh:251` vs `:351` | k8s 保护清单 `*/.k8s/*` 与 `*/k8s/*` 口径不一致（fail-closed，需同时命中 gitignore 区才可能放行） | 非 Blocker | 本次部署引入 | 统一为一套 glob 口径 |
| L-2 | `skills/task-planner/scripts/check-tier-consistency.sh:61` | `execution_lane: L0-E` 被前缀解析为 L0（2-Phase 夹具实测 exit 1） | 非 Blocker | 本次部署引入 | 解析改精确匹配，避免 `L0-E` 与 `L0` 前缀碰撞 |
| L-3 | `skills/task-planner/scripts/selftest-requirement-coverage.sh` | 51.13 无 selftest 守护（RC-24..27 仅覆盖 51.9-51.12） | 非 Blocker | 本次部署引入 | 补 RC 断言覆盖 51.13 |
| L-4 | `skills/task-planner/scripts/selftest-requirement-coverage.sh:8` | 头注 `RC-01..RC-23` 与实际 RC-27 不符（实测 27 PASS=27） | 非 Blocker | 本次部署引入 | 同步头注计数 |
| L-5 | `skills/task-planner/README.md:81` / `docs/ARCHITECTURE.md:4` | 规则计数写 74 条，实测 76 条（base 即如此） | 非 Blocker | 既有 | 口径同步 |
| L-6 | `skills/task-planner/scripts/task-plan-init.cjs:103-115` | 口径① 限权后豁免归因文案失准（实测真实放行来源是「不写哨兵」而非 marker） | Suggestion | 本次部署引入 | 二择一：轻量会话仍写哨兵 / 或改文案为真语义并注明 `fix`/`简单` 子串匹配连带面 |
| L-7 | `skills/task-planner/scripts/check-scope.sh:121-130` vs `:133-142` | 修复后 12 行同构判定重复，「机械产物区」定义分居两处易漂移 | Suggestion | 本次部署引入 | 抽 `_is_mechanical_artifact_path()` 复用 |
| L-8 | `check-scope.sh:22-23` / `:123,128,131` / `check-delegation.sh:437` / `templates/task_plan.md:353,355` | 头注未列放行来源；留痕走 stdout 建议 `>&2`；日期 10-07/09-07 不一致；相邻两行路径基准混用 | Nit | 混合 | 择机一并清理 |

## Resources
- 部署位：~/.zcode/skills/、~/.claude/skills/、~/.cursor/skills/（各含 15 个本仓卫星）
- 仓库技能族：/mnt/data/dev/task-planner-skill/skills/（15 卫星）
- 提交：9ec6fea（master == origin/master）
- 知识库检索：`bash scripts/kb-search.sh <关键词>` / `bash scripts/kb-rebuild-index.sh`

## Visual/Browser Findings
（本任务暂无多模态发现——未产生截图/PDF/网页证据）
