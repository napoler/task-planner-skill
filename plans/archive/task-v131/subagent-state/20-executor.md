# subagent-state 20 — executor / task-v131 Phase 6 S1（ARCHITECTURE 数字+薄壳口径 / INSTALL Detect 行）

## 任务
- worktree: /home/terry/task-planner-skill-worktrees/task-v131（branch wt/task-v131，HEAD=187e69b）
- 材料包: knowledge-brief.md §2；审计 L-4 + L-5（M-1 残留行内）
- 允许改动面: skills/task-planner/docs/ARCHITECTURE.md + skills/task-planner/INSTALL.md（仅 2 文件，未 commit）

## 实测结构数字（find -maxdepth 1 -type f | wc -l，2026-10-05 worktree 内实测）
| 目录 | 实测 | 原文数字 | 差异 |
|------|------|---------|------|
| references/ | 9 | 8 | +methodology.md（agent-coverage/batch-quality-gate/dispatch-examples/methodology 共 4 篇为审计后新增/漏列面） |
| scripts/ | 90 | 16 | 含 51 个 selftest-*.sh + selftest-registry.tsv + check-*/resolve-*/sync-* 守卫族 |
| templates/ | 10 | 5+3 | 主模板 10（task_plan/progress/findings/verification/knowledge-brief/subagent_dispatch/batch_report/delivery-summary/notepad-learnings/shared-tracker） |
| templates/variant/ | 29 | 12 | 29 个 *-type.md |
| lib/ | 6 | 5 | 补 install-companion.sh（2026-09-04 新增） |
| tests/ | 1（smoke.sh） | — | 树内保留 |

## 修改清单
### docs/ARCHITECTURE.md
1. §1.1 单一事实源清单（原 :13-16）：references 8→9、templates 5+3+12→10+29、scripts 16→90，新增 lib 行（6 脚本）；每行附 find 实测命令 + `<!-- 修改说明（task-v131, 2026-10-05）：原行为=... -->` 注释（原因/时间/原行为三要素）
2. §2 目录树：references 补「新增 4 篇」笔述行；templates 补 knowledge-brief/subagent_dispatch/batch_report/delivery-summary/shared-tracker 行 + variant 注实测 29；scripts 补「守卫与簿记脚本」笔述行 + selftest 族 ×51（含 task-v131 新建 selftest-root-resolution.sh，不逐列）；lib 补 install-companion.sh 行；各目录头标注「实测 N，2026-10-05」
3. §2 宿主位块（原 :94-102 薄壳口径）：「Claude/ZCode stub + 薄壳 SKILL.md + rsync」→「四宿主位（zcode/claude/opencode/cursor）全量副本 + hooks 注册于宿主配置（zcode=~/.zcode/cli/config.json，claude=~/.claude/settings.local.json）+ opencode 物理路径 ~/.config/opencode（~/.opencode= symlink 兼容入口）」；附修改说明注释，与 INSTALL.md §1 口径注记对齐
4. §4.1 「SKILL.md（薄壳）」→「全量副本位 = canonical 原样同步」+ 历史术语注记

### INSTALL.md
1. :31 Detect tools 行：`~/.opencode/` → `~/.config/opencode/`（物理路径）+「~/.opencode 为其 symlink 兼容入口，探测以物理路径为准」注记 + 修改说明注释（对齐 lib/detect-tools.sh:23 TOOL_PROBES 物理路径口径，审计 L-5 行内残留补齐）

## 验证
- `git diff --stat` = 仅 2 文件：`skills/task-planner/INSTALL.md | 3 +-`、`skills/task-planner/docs/ARCHITECTURE.md | 54 +++++++-----`（31 insertions / 26 deletions），未 commit
- `grep -c "\.config/opencode" INSTALL.md` = **3**（≥2 达标；行 :31 Detect 注记 / :33 Install 全量副本行 / :37 M-1 口径注记）
- 旧数字残留检查：「8 篇规则」「16 个工具脚本」仅存于修改说明注释内（记录原行为，预期）；「薄壳」3 处全部在注记/历史术语说明内
- 无 selftest/check 脚本对 ARCHITECTURE.md 数字锚断言（grep 0 命中，无级联）
- 代码围栏平衡：```` ``` ```` 12 个（偶数）
- 其他文件 0 触碰（git status 仅 2 modified）

## 遗留/风险
- 无阻断。ARCHITECTURE.md §1.3/§4/§5.1/§5.2/§5.3/§6.4 仍存「stub/rsync」设计概念措辞——本 S-unit 范围仅 §1.1/§2/§4.1 数字与部署形态口径；§4/§5 的 rsync 设计概念属文档设计面（非部署形态断言），留后续文档梳理（未扩大范围）

## 8 字段返回
status: complete
acceptance: git diff --stat 仅 2 文件 + grep ".config/opencode" INSTALL.md = 3（≥2）双达标
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v131/subagent-state/20-executor.md
evidence: 实测 references=9/scripts=90/templates=10+variant 29/lib=6（find 命令）；diff stat 31+/26-；grep -c=3；见上方各段
files: skills/task-planner/docs/ARCHITECTURE.md, skills/task-planner/INSTALL.md
issues: 无阻断；§4/§5 stub/rsync 设计概念措辞未动（范围外，登记遗留）；scripts 实为 90 非派发口径预给的 89（以 find 实测为准，派发口径数字作废）
next: Phase 6 S2（check-dispatch.sh :71-72 注释）/ S3（agent-coverage 行数锚）；本 S-unit 不 commit，由主控统一 git 编排
confidence: HIGH
