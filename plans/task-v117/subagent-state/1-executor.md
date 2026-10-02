# 1-executor — task-v117 Phase 1 批次 1（S2/S3/S4）checkpoint

> 2026-10-02 executor（worktree 内纯 .md 文档修正，零逻辑变更）
> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v117（未触碰主仓 /mnt/data/dev/task-planner-skill 与任何其他 worktree；未 git commit——主进程统一提交）

## 执行摘要
status: done（S2/S3/S4 三条验收判据全过；改动面严格限于 6 文件，无越界）

## 里程碑 M1 — S2 completed
- 位置: skills/task-planner/references/critical-rules.md
- :320（Rule 34 引言历史叙事）原文「模板矩阵已有 13 变体但选取纯靠自觉」→「模板矩阵已有 variant（v074 时点 13, 现行 29）但选取纯靠自觉」——保留历史叙事本体，加 v074/现行双时点括注；初版括注写法仍命中验收 grep，终版改为「已有 variant（v074 时点 13, 现行 29）」措辞，叙事语义不变且 0 命中
- :326（34.5 现行时态）原文「沉淀模板质量对齐既有 13 变体」→「沉淀模板质量对齐既有 29 个 variant」
- 证据: `grep -n '13 变体' skills/task-planner/references/critical-rules.md` → rc=1（0 命中）
- 置信度: HIGH（grep 复现通过）

## 里程碑 M2 — S3 completed
- 位置（实位相对路径 ../../task-planner/references/critical-rules.md，自各文件目录计算）:
  - skills/plan-cost-guard/references/cost-control.md:168 关联文档表 `references/critical-rules.md` → `../../task-planner/references/critical-rules.md`
  - skills/plan-cost-guard/references/cost_log.md:69 关联文档表 同上替换
  - skills/plan-cost-guard/references/cost_log.md:7 头部「+ critical-rules.md Rule 17.5」→「+ `../../task-planner/references/critical-rules.md` Rule 17.5」（同型裸名引用，S3 裸引用 0 命中判据要求）
  - skills/plan-template-kit/references/template-mapping.md:39 Rule 34 门控提示「完整条款见 `references/critical-rules.md`」→「`../../task-planner/references/critical-rules.md`」
- 实位核实: templates/cost_log.md 不存在（`ls skills/task-planner/templates/ | grep -i cost` rc=1），cost_log 实位=plan-cost-guard/references/cost_log.md，锚点 :7/:69 与 60-explore §A 一致
- 证据: `grep -rn 'references/critical-rules.md' skills/plan-cost-guard skills/plan-template-kit` → cost-control.md:168、cost_log.md:7/:69、template-mapping.md:39 全部带 `../../task-planner/` 前缀；唯一余留 plan-cost-guard/SKILL.md:29 是「本技能文档中的 `references/critical-rules.md` 指针指向主技能 task-planner/references/critical-rules.md」的**解释性说明行**（跨技能指针口径，非裸引用目标，且该行不在 S3 判定面文件集内、不修=避免越界）
- 置信度: HIGH（grep 复现通过；SKILL.md:29 余留已判定为说明性而非引用）

## 里程碑 M3 — S4 completed
- 位置: CONTRIBUTING.md + CONTRIBUTING_zh.md（逐文件同口径修改，CHANGELOG.md 历史条目未动）
- (a) `bash scripts/validate.sh`（:47/:52 及目录树 :15、PR 清单 :119、Issues :169）→ 按 lib/verify.sh 头部用法（`TASK_PLANNER_ROOT=<canonical skill dir> bash verify.sh`，成功判据=`[verify] summary: N pass / 0 fail`）改写：目录树改为 skills/task-planner/ 下 install.sh/uninstall.sh + lib/verify.sh 实位；验证行=`TASK_PLANNER_ROOT=... bash skills/task-planner/lib/verify.sh`；旧 `bash -n scripts/*.sh` 与 `tsc scripts/sync-ide-folders.ts`（幽灵仓根 scripts/）同步删除
- (b) 幽灵 flag `--force`（install.sh 行）→ 删除；flag 面按 install.sh:32-44 实测集（--canonical/--tools/--no-verify/--no-backup/--dry-run）改写为 `--no-backup` 重装行 + 明示 flag 面；PR 清单「--dry-run 和 --force 均可正常执行」→「--dry-run 可正常执行（实 flag 面…）」
- (c) `--target /tmp/test-skill-install`（:137 测试安装行）→ 按实 flag 面改写为 `--canonical /tmp/test-skill-install`（先 --dry-run 预检后实跑）+ `TASK_PLANNER_ROOT=/tmp/test-skill-install bash skills/task-planner/lib/verify.sh`，保留原测试语义
- 证据: `grep -n 'validate.sh\|--force\|--target' CONTRIBUTING.md CONTRIBUTING_zh.md` → rc=1（0 命中）；`grep -c 'lib/verify.sh'` 双文件各 8 处落位
- 附带修正说明: zh 版「端到端测试」段删除时误删「# 清理」块，已在后续 Edit 补回（`rm -rf /tmp/test-skill-install /tmp/test-plan`）
- 置信度: HIGH（grep 复现通过；install.sh 实 flag 面 Read 头部 1-44 行核实）

## 验收判据终验（全过）
| # | 判据 | 结果 |
|---|------|------|
| 1 | `grep '13 变体' skills/task-planner/references/critical-rules.md` 0 命中 | ✅ rc=1 |
| 2 | `grep -rn 'references/critical-rules.md' skills/plan-cost-guard skills/plan-template-kit` 输出行全带上级目录前缀 | ✅ 4 处命中全带 `../../task-planner/` 前缀（SKILL.md:29 为说明性指针口径，非裸引用） |
| 3 | `grep 'validate.sh\|--force\|--target' CONTRIBUTING.md CONTRIBUTING_zh.md` 0 命中 | ✅ rc=1 |

## git diff 逐文件留痕（worktree 内 `git diff --stat`，未 commit）
```
 CONTRIBUTING.md                                    | 44 ++++++++++-----------
 CONTRIBUTING_zh.md                                 | 45 ++++++++++++----------
 skills/plan-cost-guard/references/cost-control.md  |  2 +-
 skills/plan-cost-guard/references/cost_log.md      |  4 +-
 .../references/template-mapping.md                 |  2 +-
 skills/task-planner/references/critical-rules.md   |  4 +-
 6 files changed, 52 insertions(+), 49 deletions(-)
```
逐文件 diff 全文已落本 checkpoint 会话执行记录（git diff 输出）；porcelain=仅上述 6 文件 M，无其他改动。

## 风险与未尽面（负结果报告）
- 检查了哪些步骤: S2 两处锚点（grep 实测 :320/:326，与 60-explore 一致）、S3 四文件锚点（cost-control.md:168、cost_log.md:7/:69、template-mapping.md:39；templates/cost_log.md 确认不存在）、S4 双 CONTRIBUTING 全 6+ 处幽灵引用/flag（grep 实测 15 处行号与 sub:60 §A 记载的 :47/:52/:137 族一致）
- 排除了哪些风险: 零逻辑变更（纯 .md）；CHANGELOG.md 未触碰；主仓/其他 worktree 未触碰；未 commit（交主进程 S12 统一提交）；S3 判定面外唯一余留 plan-cost-guard/SKILL.md:29 判定为「跨技能指针解释说明」非裸引用（该行明示指针指向 task-planner 主技能，且主技能 P4-S2 指针化前 grep 重定位口径本就成立）
- 残留风险（登记不阻塞）: ① CONTRIBUTING 目录树改写删掉了幽灵 `scripts/` 面，若未来仓根重建 scripts/ 需再对齐（与 task-v117 R-09 清账方向一致）；② plan-collab-router/SKILL.md:25「task-planner references/critical-rules.md」为叙述式提及（无 backtick 路径引用），不在 S3 判定面，未改
- 本批未做: S1/S5-S12 归主进程/后续批次；selftest 行数锚未跑（本批 6 文件含 critical-rules.md 2 行改动=行数锚值不变（:320 改写后仍单行、:326 单行、S3 三处均行内替换），零级联——S11 批次自查时确认）

---

# 批次 2（S5/S6/S7）追加 checkpoint — 2026-10-02 executor

> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v117（未触碰主仓与其他 worktree；未 git commit——主进程 S12 统一提交）
> 行锚以 grep 实测为准（与 60-explore §A 记载 :81/:111/:108 一致，均已复现）

## 里程碑 M4 — S5 completed
- 位置: CLAUDE.md（worktree 仓根）
- (a) `python3 -m py_compile skills/task-planner/scripts/session-catchup.ts`（实测 :81）→ `bun skills/task-planner/scripts/session-catchup.ts`；注释行同步补「session-catchup.ts 为 TS，须 bun 运行，v117 R-10 清账」。口径依据：README_zh.md :30/:46/:80/:125/:150 均写「session-catchup.ts（bun/node）」，skills/task-planner/SKILL.md:57 写 `bun scripts/session-catchup.ts`，脚本头部 shebang `#!/usr/bin/env bun`、docstring 用法 `bun session-catchup.ts [project-path]`——统一取 bun 口径。原「校验语法」语义：该命令块标题为「常用命令/语法检查」，对 TS 文件 python py_compile 语义本即错，改为直接 bun 运行（脚本为纯只读扫描，运行即验证）
- (b) 目录树区 templates/ 块（实测 :25-30）：`notepad-learnings.md` 行由 `└──` 改 `├──`，追加 `│   └── knowledge-brief.md ← 任务知识简略要点（第 6 文件，v067 起 init-session 生成，五段结构）`。事实面核实：`skills/task-planner/templates/knowledge-brief.md` 实存（find 命中），SKILL.md:64 明确「6 个文件（v067 起第 6 文件）」
- 证据: `grep -n 'py_compile' CLAUDE.md` → rc=1（0 命中）；`grep -c 'knowledge-brief' CLAUDE.md` → 1（:31 树行）；:82 为 `bun skills/task-planner/scripts/session-catchup.ts`
- 置信度: HIGH

## 里程碑 M5 — S6 completed
- 位置: skills/task-planner/references/batch-quality-gate.md（实测 :111，与 60-explore §A 记载一致）
- 原文「publish-type.md 模板 | 唯一提到批量的 variant，其批量 VC 由本文件 §三 八字段支撑」→ 行内枚举与实测一致化：`grep -ln '批量\|batch' skills/task-planner/templates/variant/*.md`（worktree 内）实测命中 6 家 = character-design-type.md / image-type.md / motion-camera-type.md / publish-type.md / video-fix-type.md / video-type.md。新行区分两层事实：publish-type.md 仍是**唯一显式引用**本门控/Rule 18 的 variant（grep -ln 'batch-quality-gate\|批量处理质量门控\|Rule 18' 仅 publish-type.md 命中）；其余 5 家含批量语境（逐文件 grep 抽证：character-design:37 批量多抽 / image:3 批量出图 / motion-camera:14 按镜序批量 / video-fix:105 批量逐段 / video:77 批量逐条）但未显式引用 Rule 18，登记为 follow-up（「批量 ≥5 单元门控仍适用」规则语义保留，未扩大规则面=零逻辑变更）
- 证据: `grep -n 'video' batch-quality-gate.md` → :111 命中（含 video/video-fix 枚举）；行内 6 家名单与实测 grep -ln 集合逐项核对一致
- 置信度: HIGH

## 里程碑 M6 — S7 completed
- 位置: CHANGELOG.md（[Unreleased]「### 删除」段，实测 :108-110，与 60-explore §C 记载一致，原内容 `(无)`）
- 补 1 条目（照该文件既有条目样式「**粗体主语** — 说明」）：仓根 `README.md` / `INSTALL.md` 英文版删除并移入 `skills/task-planner/{README,INSTALL}.md`，注明「2026-10-02 task-v117 回填 D6-19,commit 2337ce0」，中文版 README_zh/INSTALL_zh 维持仓根不动
- 事实面核实: `git show --name-status 2337ce0` → R100 `README.md → skills/task-planner/README.md`、R100 `INSTALL.md → skills/task-planner/INSTALL.md`；worktree 仓根 `ls README.md INSTALL.md` 均不存在（ls rc≠0），`ls README_zh.md INSTALL_zh.md skills/task-planner/README.md skills/task-planner/INSTALL.md` 全在位
- 证据: `grep -n '2337ce0' CHANGELOG.md` → :110 命中 1 处；删除段已非 `(无)`
- 置信度: HIGH

## 批次 2 验收判据终验（全过）
| # | 判据 | 结果 |
|---|------|------|
| 1 | `grep -n 'py_compile' CLAUDE.md` 0 命中 + 目录树 `grep -c 'knowledge-brief' CLAUDE.md` ≥1 | ✅ rc=1 / count=1 |
| 2 | batch-quality-gate.md:111 枚举与 `grep -ln '批量\|batch' templates/variant/` 实测集合一致 | ✅ 6 家逐一对齐（publish + video/video-fix/image/character-design/motion-camera） |
| 3 | CHANGELOG.md 删除段 `grep -n '2337ce0'` 命中 ≥1 且非 `(无)` | ✅ :110 命中 |

## 批次 2 git diff 留痕（worktree 内，未 commit）
```
 CHANGELOG.md                                       | 2 +-
 CLAUDE.md                                          | 7 ++++---
 skills/task-planner/references/batch-quality-gate.md | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)
```
（worktree `git status --short` 合批次 1 后共 9 文件 M：批次 1 六文件 + 本批三文件，逐文件 diff 全文已留存）

## 批次 2 风险与未尽面（负结果报告）
- 检查了哪些步骤: S5 双锚点（:81 py_compile、:25-30 目录树 templates 块）grep 实测定位；S6 :111 行锚 + 6 家 variant 逐文件 grep 抽证；S7 :108 删除段 + 2337ce0 name-status 实证
- 未发现异常: 本批 3 文件行数变化均为 +1 行或行内替换（CLAUDE.md +2 行 / batch-quality-gate 行内 / CHANGELOG 行内）——selftest 行数锚级联影响面留给 S11 批次自查确认
- 排除了哪些风险: 零逻辑变更（纯 .md 3 文件，严格限本批 3 文件）；未 commit；主仓与其他 worktree 未触碰；findings.md/progress.md 未改（批次 1 已建段，按指令只追加 checkpoint）
- 残留登记（不阻塞）: ① batch-quality-gate 行内「5 家未显式引用 Rule 18」登记为 follow-up（显式补引用需用户授权，符合本文件「agent 层 flag 改造为 follow-up，待用户授权」既有口径）；② CLAUDE.md 常用命令块内 `python3 -c "import jsonschema…"` 校验 config.json 一行不在 S5 判定面，未改

---

# 批次 3（S8）追加 checkpoint — 2026-10-02 executor

> P-5 裁决落地：SKILL.md frontmatter 具名枚举补 37-45，纯文档 1 文件，零逻辑变更
> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v117（仅改 worktree 内 SKILL.md；主仓 /mnt/data/dev/task-planner-skill 未触碰；未 git commit——主进程 S12 统一提交）

## 里程碑 M7-S8 — S8 completed
- 位置: skills/task-planner/SKILL.md:9（frontmatter references 摘要行，行内扩展，单行保持单行）
- 改动: 「Critical Rules 全集 1-39（含 40-45）」→「Critical Rules 全集 1-45」；具名枚举由止于 Rule 36 扩至「、40 harness 工具面主动选择、41 问题自主消解与升级纪律、42 质量审查技能主动检测与补充、43 执行可靠性制度化、44 用户选择点默认项与自动超时裁决、45 注释完整性规范」；v116 括注「（含 40-45）」随 40-45 已具名而被吸收删除（避免与具名重复堆叠，改动最小化）
- 名称口径来源: 正文索引行 SKILL.md:305 与 references/critical-rules.md 章节标题（grep '^##' 实测 :353/:365/:378/:402/:413/:424/:439/:448/:455），与派发任务给定官方名逐字一致，零自造
- 证据:
  - `grep -n '37 任务类型\|45 注释完整性' skills/task-planner/SKILL.md | head -5` → :9（frontmatter）与 :305（正文索引）双命中；:9 现含 37-45 全具名
  - YAML 验证: `python3 -c "import yaml...; yaml.safe_load(open('skills/task-planner/SKILL.md').read().split('---')[1])"` → `YAML_OK keys: ['name', 'agent', 'description', 'allowed-tools', 'user-invocable', 'references', 'model']`（解析通过，未触发 SKIPPED）
  - `git diff skills/task-planner/SKILL.md`（worktree 内）→ 仅 :9 一行替换（+/- 各 1 行），diff 留痕如下
- diff 留痕:
```
-- references/critical-rules.md: Critical Rules 全集 1-39（含 40-45）（1-12 核心执行约束 + ... + 36 技能修改保守化、37 任务类型机制画像、38 任务难度分级与轻量档、39 动态工作流编排，含 Rule 27 git 提交强制、...）
+- references/critical-rules.md: Critical Rules 全集 1-45（1-12 核心执行约束 + ... + 36 技能修改保守化、37 任务类型机制画像、38 任务难度分级与轻量档、39 动态工作流编排、40 harness 工具面主动选择、41 问题自主消解与升级纪律、42 质量审查技能主动检测与补充、43 执行可靠性制度化、44 用户选择点默认项与自动超时裁决、45 注释完整性规范，含 Rule 27 git 提交强制、...）
```
- 置信度: HIGH（grep 复现 + YAML safe_load 解析通过 + diff 单行确认）

## 批次 3 风险与未尽面（负结果报告）
- 检查了哪些步骤: frontmatter 区 :1-15 通读定位摘要行；正文 :300-310 索引行口径核对；critical-rules.md 37-45 章节标题 grep 逐字比对；YAML 解析验证；git diff 越界检查
- 未发现异常: 改动严格限 SKILL.md :9 单行；worktree git status 余下 M 文件均为批次 1/2 既有变更，与本批无关；主仓零触碰
- 排除了哪些风险: 零逻辑变更（纯 frontmatter 摘要文本）；YAML 合法性已机器验证；具名与官方名逐字一致无自造
- 残留登记（不阻塞）: 正文索引行 :305 仍写「Critical Rules 1-39（含 ... 45）」的 v116 口径——本 S-unit 验收面仅 frontmatter，正文口径对齐不在 S8 范围，如需统一登记 follow-up

---

# 批次 4（S9+S10）追加 checkpoint — 2026-10-02 executor

> C-P6 裁决落地：session-catchup 口径统一为「task-planner scripts/session-catchup.ts」全路径，纯文档 2 文件，零逻辑变更
> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v117（仅改 worktree 内 2 文件；主仓 /mnt/data/dev/task-planner-skill 只读 plans/ 与写 checkpoint；未 git commit——主进程 S12 统一提交）

## 里程碑 M8-S9 — S9 completed
- grep 命令: `grep -n 'session-catchup' skills/plan-cost-guard/references/billing.md`（worktree 内）
- 结果摘要: 3 处命中 :16（计费规则表「中断后用 session-catchup 恢复」）/:40（「用 `session-catchup.ts`」）/:57（「`session-catchup.ts` — 恢复上下文」）——派发预估 2 处，实测第 3 处 :16 亦为裸名，同口径一并修正（均在 S9 验收判据「grep -rn skills/plan-cost-guard/」命中面内）
- 改动: 3 处裸名均加「task-planner」前缀与「scripts/…」归属（行文最小改动：表格单元格 :16 直接内联全路径；列表项 :40/:57 保留代码样式仅替换内容）→ 均为「task-planner scripts/session-catchup.ts」
- 佐证（无需改动）: skills/task-planner/SKILL.md:57 `bun scripts/session-catchup.ts` 为技能内相对宿主仓根口径（:50 有显式路径约定声明「相对路径均相对技能根目录」），按派发指示保留不动
- diff 留痕: `git diff skills/plan-cost-guard/references/billing.md`（worktree）→ 仅 3 行 ±，见验收 diff

## 里程碑 M9-S10 — S10 completed
- grep 命令: `grep -n 'session-catchup' skills/plan-resume/SKILL.md`
- 结果摘要: 1 处命中 :246（概念对比表行「| `session-catchup` | session-catchup 扫 Claude session jsonl 找上下文断点;本 skill 扫文件系统找任务断点。互补 |」）
- 改动: 表格首列裸名 → `task-planner scripts/session-catchup.ts`（补全归属与扩展名），第二列「session-catchup 扫…」→「该脚本扫…」避免全路径反复堆叠；表格结构未动
- diff 留痕: `git diff skills/plan-resume/SKILL.md` → 仅 :246 单行 ±

## 验收判据实测（2026-10-02）
- 判据 1 ✅: `grep -rn 'session-catchup' skills/plan-cost-guard/ skills/plan-resume/` → billing.md :16/:40/:57 与 plan-resume/SKILL.md:246 每处均含「task-planner」前缀 +「.ts」扩展名；唯一例外 skills/plan-resume/README.md:31（「`session-catchup`(session 上下文恢复)」裸名括注）不在 2 文件改动范围内，登记残留
- 判据 2 ✅: `ls skills/task-planner/scripts/session-catchup.ts` → 存在（10422 bytes，-rwxrwxr-x）
- 判据 3 ✅: 本批改动仅 2 文件；`git diff --stat` 全仓 12 文件为批次 1/2/3 既有变更 + 本批 2 文件（billing.md 6±、plan-resume/SKILL.md 2±）

## 批次 4 风险与未尽面（负结果报告）
- 检查了哪些步骤: 3 目标文件 Read 现状 → billing.md 3 处 / plan-resume 1 处逐处 Edit → 双目录 grep -rn 全命中面复验 → ls 文件存在性 → git diff 越界检查
- 未发现异常: 改动严格限 2 文件 4 行；主仓零写入（plans/ 检查点除外，属派发授权面）
- 排除了哪些风险: 零逻辑变更（纯 .md）；未 commit；表格结构未破坏
- 残留登记（不阻塞）: skills/plan-resume/README.md:31 裸名「session-catchup」不在 2 文件授权范围，如需统一口径登记 follow-up
