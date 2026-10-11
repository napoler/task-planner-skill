# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[Phase 1 S1] bash -n 全量语法扫描（2026-10-02，主进程 ④ 接管=mini provider rejected，白名单③）**：skills/ 下 10 个 skill 全部 `*/scripts/*.sh` 共 **75 个脚本，0 语法 FAIL**。证据：`for f in skills/*/scripts/*.sh; do bash -n; done` → `scanned=75 syntax_fail=0`。v106 基线稳定性在语法面成立。


#### [sub:2-executor] 全量回归
- **[Phase 1 S2] 42 selftest 全量回归（2026-10-02，sub:2-executor 执行，22.3① 改派自 code-runner mini）**：42/42 脚本 rc=0，0 FAIL，0 timeout。逐脚本 PASS 求和 **660**、FAIL 求和 **0**，与 v106 基线 660/0 完全一致。特例：`selftest-final-gate-hash.sh` 无 `Total:` 行（rc=0），结果行原文为 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（计入求和）。逐脚本 rc+Total 行原文（42 行）见 checkpoint `subagent-state/2-code-runner.md`。

#### [sub:3-executor] S1 主文档面审查
- **[Phase 2 S1] task-planner SKILL.md + critical-rules.md 一致性五维审查（2026-10-02，sub:3-executor）**：6 项问题（P1×2 / P2×4，其中 2 项待复核）。摘要：
  - P-1 (P1) SKILL.md:64「5 个文件」验证锚过期，init-session.sh:3/:210 实测建 6 文件（task-v067 第 6 文件 knowledge-brief.md）
  - P-2 (P1) critical-rules.md:75（Rule 16）验收锚 `grep -rl "## 📚 必要知识储备" templates/ | wc -l = 21`，实测 = 22
  - P-3 (P2) critical-rules.md:361「现有 13 个 variant」/ :317「既有 13 变体」vs 实测 variant/ 目录 16 个（standard 档是否含 video 语义待复核）
  - P-4 (P2) SKILL.md:246/:304 括注「Rules 1-39（含 Rule 40/41/42/43/44）」逻辑矛盾（40-44 不在 1-39 内）；"Rules 1-39" 是 selftest WF-10 机器锚（selftest-workflow-orchestration.sh:52-57），修复须同源同改
  - P-5 (P2 待复核) SKILL.md:9 frontmatter references 摘要行仅枚举至 Rule 36，37-44 未列入（是否属索引面口径存疑）
  - P-6 (P2 待复核, out-of-scope) task_plan 知识储备行引用的 skills/task-planner/scripts/install-companion.sh 实测 MISSING（两审查文件未引用，移交主进程）
  - 五维负结果：维度1 Rule 1-44 主编号 44 个无跳号无重复；维度3 C1-C33 连续无重复；维度5 两文件内 19 条引用路径全部实存；维度4 实测 42 selftest/11 池/16 variant/75 脚本中池 11 与 16 类锚点（:420/:75）✓ 一致
  - 全文问题清单与证据见 checkpoint: plans/task-v107/subagent-state/3-executor.md

#### [sub:S3] 三宿主部署位盘点（2026-10-02，主进程 ④ 接管，白名单③）
- **主仓**：10 个 skill（task-planner + 4 卫星 plan-{collab-router,cost-guard,research-router,template-kit} + plan-resume/todo-skill/task-drift-guard/progress-tracker + iterative-optimizer）+ review-library 池 11 技能（skills/task-planner/review-library/）
- **~/.zcode/skills**：10 skill + 11 池技能相对软链（→ task-planner/review-library/*）✓ 全在位
- **~/.claude/skills**：10+11 全在位（池=同款相对软链）✓
- **~/.opencode/skills**：10+11 全在位 ✓
- **⚠️ 发现**：`~/.config/opencode/skills` 存在**第二套旧部署**——含 task-planner/task-drift-guard/部分池技能，但**缺** iterative-optimizer、plan-collab-router、plan-cost-guard、plan-research-router、plan-resume、plan-template-kit、progress-tracker、todo-skill；与 ~/.opencode/skills 的关系（opencode 实际加载位/废弃残留）待 Phase 3 核实

#### [sub:4-executor] references+templates 审查
- **[Phase 2 S2] references/(除 critical-rules) + templates/ 四维审查（2026-10-02，sub:4-executor）**：8 项问题（P1×2 / P2×6）+ 2 项待复核。摘要：
  - P1-1 templates/task_plan.md:249 worktree_path 示例值仍为旧约定 `../<repo>-wt-<task-id>`，worktree-isolation.md:37/宪法 §11.2 已立新规范 `<repo-parent>/<repo>-worktrees/<task-id>`
  - P1-2 templates/knowledge-brief.md:9 「grep 锚计数维持 20（template-guide.md:65 验收）」过期，实测 `grep -rn "^## 📚 必要知识储备" templates/ | wc -l` = 22（卫星 template-guide:77 已写 22，本文件未同步；与 sub:3 P-2 同根）
  - P2-1 references/worktree-isolation.md:46+71 双「## 4.」章节号（生命周期/合并回合约）
  - P2-2 references/methodology.md:4/:232 指针行 SKILL.md:82/:159/:81/:156 行号锚偏移（实测 Poka-Yoke=:76、内容质量门控=:153）
  - P2-3 references/batch-quality-gate.md:135 「隶属 Rules 1-36」与现行 Rule 1-44 脱节（sub:3 P-4 同家族）
  - P2-4 references/batch-quality-gate.md:111 「publish-type 唯一提到批量的 variant」过期：video-type:63 / video-fix-type:91/96 亦含「批量」
  - P2-5 references/dispatch-examples.md:5 「DX-01..DX-03 守护」vs selftest-dispatch.sh 实测含 DX-01..DX-05b
  - P2-6 4 variant（diagnostic/publish/research/writing）缺 `<!-- template_type: X -->` 注释行（12/16 有；gate 不受影响但形态不统一）
  - 待复核 T-1：writing/research/publish variant VC 表引用 4 个不存在脚本（article_json_editor.py/verify_content_originality.py/keyword_coverage.py/rollback.sh，全仓 find 0 命中）——疑为任务侧示例值口径，建议加注脚
  - 待复核 T-2：8 个 13 节标准 variant 缺「委派统计/Handoff 登记表/Drift Log」区块（主模板有；需主进程确认 plan-writer 是否补全，否则升 P1）
  - 四维负结果：config.json 11 键对拍全 PASS（含 properties=40）；methodology 14 条 / Rule 18 十一条款 / batch_report 八字段实测一致；20 条路径抽验 16 EXISTS/4 MISSING（4 条=T-1 脚本）
  - 全文问题清单与证据见 checkpoint: plans/task-v107/subagent-state/4-executor.md

#### [sub:5-executor] 卫星配套技能审查
- **[Phase 2 S3] 9 个卫星/配套技能文档面四维审查（2026-10-02，sub:5-executor）**：4 项问题（P1×1 / P2×3）+1 项待复核。摘要：
  - S3-P1 (P1) plan-cost-guard/SKILL.md:21「Rule 17.5 … >15 次强制 STOP」阈值断言主侧无源：critical-rules.md:84 17.5 仅「≥10 次 → AskUserQuestion」，全文无 >15 STOP 条款（grep 无命中）——卫星侧过期/虚构阈值
  - S3-P2 (P2) plan-template-kit/references/template-guide.md:63/:65 数字簇过期：「实际 26 个 .md」实测 templates/ 现 25 个；「23/26 统一含知识储备」与 :69/:77 grep 锚=22、:102「task_plan 系含锚 15」三口径互斥（实测 grep -rl=22、例外 3 文件实测确认）
  - S3-P3 (P2) plan-template-kit/references/template-mapping.md:26/:145「白名单 16 类」vs §一 清单 14 文件 + §六 速查表 14 行：video-type/mini-lite-type 未枚举；§九 矩阵 14 行（13 variant+general）与主侧 critical-rules.md:348 Rule 37.1「14 行」一致
  - S3-P4 (P2) progress-tracker/SKILL.md:192 边界表引用 `plan-bookkeeper` 幽灵技能（仓 skills/ 与 ~/.zcode/.claude/.agents 三部署位均无此技能，ls 零命中）；待复核：plan-resume/SKILL.md:246 session-catchup 与 plan-cost-guard/billing.md:40/58 session-catchup.ts 的计费/恢复口径
  - 四维负结果：维度1 引用路径抽验 20+ 条 0 MISSING（卫星 6 个 references/、plan-resume 4 脚本+config.json+README+smoke、todo-skill 4 文件、主侧 8 个被引脚本全实存）；维度2 主→卫星 6 条 + 卫星→主 6 锚（Rule 17.1/:80、17.5/:84、17.8/:87、22.3.3/:153、34.1/:313、37.1/:348）全部实存，三部署位 comet 13/openspec 11/superpowers 10 成员数与 collab-router 声称一致；维度3 selftest-registry.tsv 42 行=42 脚本 4 列无重无孤儿（selftest-registry.sh 实跑 5/5 PASS）、iterative-optimizer selftest 实存（IL 实跑 8/8 PASS，SKILL.md 97 行∈[90,120]）、review-library 11 目录✓、template-mapping 16 类 vs variant/ 实测 16✓（§一 缺 2 条计入 S3-P3）；维度4 数字面 42 selftest/75 脚本锚点与 Phase 1 基线一致，config 5 键（skill_collab/shared_tracker/template_gate/knowledge_brief/autonomous_resume）全实存，plan-resume config.json skip_states 与 §7.2 表一致
  - 全文问题清单与证据见 checkpoint: plans/task-v107/subagent-state/5-executor.md

#### [sub:6-executor] 根目录文档审查
- **[Phase 2 S4] 仓根目录 6 文档（README_zh/INSTALL_zh/CHANGELOG/CONTRIBUTING/CONTRIBUTING_zh/CLAUDE）三维审查（2026-10-02，sub:6-executor）**：19 项问题（P1×2 / P2×17，其中 1 项待复核 D6-19）。核心结论：
  - D6-01 (P1) 根级 `scripts/{install,validate,uninstall}.sh` 口径全面失效：仓根无 scripts/ 目录，install.sh/uninstall.sh 实位 skills/task-planner/，validate.sh 全仓 0 命中；README_zh:59/67/266、CONTRIBUTING 双份 dev-loop/PR 清单全部命令入口失效
  - D6-02 (P1) session-catchup.py 幽灵：实为 session-catchup.ts；README_zh:46/80/150、INSTALL_zh:61/239-245 引用 .py；仓内 .py 仅 1 个（plan-resume score-plans.py）
  - D6-03~D6-05 (P2) INSTALL_zh 安装内容清单（2026-09-16 核对）过期：13 变体 vs 实测 16（缺 mini-lite/video/video-fix）；references 12 口径混入 4 个卫星 skill 文件（主侧实 8）；scripts 55 个/selftest×19 vs 实测 81 项/42 selftest
  - D6-06 (P2) INSTALL_zh:282「config.json 37 键」vs properties=40（与 WF-13 锚 40 同源）
  - D6-07/D6-17 (P2) 安装口径错位：install.sh 实 flag={--canonical/--tools/--no-verify/--no-backup/--dry-run}，无 --target/--force/--uninstall；默认模型=5 工具 per-tool 软壳（detect-tools.sh:18-22 含 .zcode/.opencode/.cursor/.continue），非「~/.claude 单目录」
  - D6-08/D6-18 (P2) 卸载/验证命令幽灵（uninstall.sh 实 flag={--canonical/--keep-canonical/--keep-backups/--dry-run}；validate.sh 不存在，验证面=lib/verify.sh）；「.py 镜像」口径错（实为 .ts）
  - D6-09 (P2) INSTALL_zh:315 英文链接死链 INSTALL.md/README.md（根 0 命中；与 README_zh:217「暂无独立英文文档」矛盾）
  - D6-10 (P2) CLAUDE.md:25-30 + CONTRIBUTING 双份模板树漏 knowledge-brief.md（第 6 计划文件，init-session.sh:340 六文件循环）
  - D6-11 (P2) README_zh:136/229 + CLAUDE.md:32「Rules 1-39」过期，实测主编号至 Rule 44（critical-rules.md:393-439 五个 ### 头）
  - D6-12 (P2) README_zh:153「5 个模板文件」vs init-session.sh:351 `6/6 planning files verified`
  - D6-13 (P2) 根目录树不全（CONTRIBUTING 漏 LICENSE/README_zh/INSTALL_zh/CHANGELOG；README_zh 漏 LICENSE）；CONTRIBUTING:24「plans/ (gitignored)」断言与 git 实态矛盾（plans/INDEX.md 等 tracked，.gitignore 无 plans/ 条目）
  - D6-14 (P2) INSTALL_zh:309「总大小约 1.3 MB」vs du 实测 2.0M
  - D6-15 (P2) INSTALL_zh:61 前置依赖 python3≥3.8「session-catchup.py + JSON 验证」基于 .py 假设（并入 D6-02）
  - D6-19 (P2 待复核) CHANGELOG 2.0.0 段(119/121)称新增 README.md/INSTALL.md，现存仓根无英文文档（疑已移除但 CHANGELOG 无「删除」回填），需 git log 查证
  - 负结果：README_zh 16 variant✓/config 9 键示例✓/3 伴生 agent✓/billing 软链注记✓/lib/install-companion.sh 实位✓；CHANGELOG:89 ARCHITECTURE.md §2.6 指针实存✓（D6-16 核验项）
  - 全文问题清单（19 条含逐条证据）见 checkpoint: plans/task-v107/subagent-state/6-executor.md

#### [sub:7-executor] 部署位 diff 对账
- **[Phase 3] 主仓 skills/ × 三宿主部署位逐 skill diff 对账 + 第二套部署角色核实（2026-10-02，sub:7-executor）**：
  - **逐 skill 结论（10 × 3，diff -rq）**：
    - `~/.zcode/skills`：plan-collab-router / plan-cost-guard / plan-research-router / todo-skill / task-drift-guard / progress-tracker / iterative-optimizer = IDENTICAL；**task-planner = DIFF**（companion/agents/plan-writer.md + scripts/selftest-template-lifecycle.sh 内容 differ；部署位多出 12 个 templates/variant/*-type.md——主仓 skills/ 下无此目录，主仓独有 companion/.backup-20261001-*）；**plan-template-kit = DIFF**（references/template-guide.md + template-mapping.md differ）；**plan-resume = DIFF**（主仓独有 tests/，部署位无）
    - `~/.claude/skills`：9/10 IDENTICAL；task-planner 仅主仓多 companion/.backup-20261001-*（部署位无，其余全同）
    - `~/.opencode/skills`：9/10 IDENTICAL；task-planner 同上仅 backup 目录差异；plan-resume 仅主仓有 tests/
  - **第二套部署角色核实（~/.config/opencode/skills）**：`~/.opencode` 是**软链** → `/home/terry/.config/opencode`（同 inode 3436922，`~/.opencode/skills` 与 `~/.config/opencode/skills` 为同一目录）→ **不存在第二套部署，findings [sub:S3] 的「缺 8 个新技能」疑虑撤销**：10 个 skill 的 SKILL.md 逐个 diff -q 全 IDENTICAL；task-planner/9 个 satellite 的 diff -rq 亦全同（除主仓独有 backup/tests 目录）；critical-rules.md 含 Rule 44（grep -c=1，与主仓一致）；mtime 2026-10-01 07:19 与 ~/.opencode 一致。`~/.opencode/config.json` 仅 52 字节（$schema），无 skills 目录配置项，加载走默认 `~/.opencode/skills`
  - **池软链健康（33 条）**：11 池技能 × 3 宿主 readlink 全为 `task-planner/review-library/<name>`（相对软链），33/33 目标实存，三宿主目标字符串一致（无 MISMATCH）。注：hosts 侧 `brainstorming` 为实体目录（非池技能、不在 11 池内），不计入 33；config/opencode/skills 另有多出条目 `superpowers`（软链指向 superpowers/skills，异常项已记录，非本任务范围）
  - 差异清单全文 + 命令证据：checkpoint `plans/task-v107/subagent-state/7-executor.md`；原始 diff 日志 /tmp/sub7-diff.log /tmp/sub7-opencode.log /tmp/sub7-links.log

#### [sub:10-executor] 对齐审查
- **[Phase 6] alignment-review 对齐审查收尾（2026-10-02，sub:10-executor，Rule 42.6.2 标准流程）**：四要素逐项核对，结论 = **CHANGES_REQUESTED（0 P0 / 1 P1 / 2 P2）**。摘要：
  - 要素1 文档↔产出同步（PASS，附 1 项 P2）：抽 5 条 report↔checkpoint 对照全一致——①「75 脚本 0 语法 FAIL」=checkpoint 1 原文「scanned=75 syntax_fail=0」（1-code-runner.md:7）②「42/42 PASS 660/FAIL 0」=checkpoint 2 final 汇总「PASS=660 FAIL=0（final-gate-hash PASS=22 已计入）」（2-code-runner.md:67；results.txt 638+22=660 复测吻合）③「.zcode 28 vs 主仓 16、差集 12 video 家族」=checkpoint 7 diff -rq 原文「(12 个)」（7-executor.md:22），ls/comm 复测一致（主仓 16/.zcode 28/差集 12）④「init-session 6/6」实测 init-session.sh:351「6/6 planning files verified」⑤「EX-1 videop1 双向漂移」diff -rq 复现 plan-template-kit references differ。progress [sub:N] 行与 9 份 checkpoint 一一对应✓；但六件套状态面 task_plan Phase 1-4=complete vs progress Phase 1-4 Status=in_progress（:13/30/45/51）未翻转→P2-Q1。
  - 要素2 计数联动 **命中 P1**：report 问题总表 §3.1-3.5 实际数据行 = 1(EX-1)+6(§3.2 P-1~P-6)+10(§3.3 P1-1~P2-6,T-1,T-2)+6(§3.4 C-P1~C-P6)+19(§3.5 D6-01~D6-19) = **42 行**，但 report:3 头声明「44 条」且 progress:54/task_plan:142 同写「44 条[EX-1+P1×7/P2×31/待复核×4/负结果1]」——**声明 44 vs 表格实 42，缺口 2 行**；P2×31 声明 vs 表格 P2-labeled 实 33、待复核×4 声明 vs 表格 待复核-labeled 实 5（P-5/P-6/T-1/T-2/C-P6）口径漂移。P1×7 经核一致（P-1,P-2,P1-1,P1-2,C-P1,D6-01,D6-02）；R-01~R-15 表实 15 行✓。三件套文件间「44」表述彼此一致，不一致发生在「report 头声明 vs report 自身表格内容」（声明/事实不符=P1）。
  - 要素3 引用完整性 PASS（抽验 11/11 实存）：3-executor §P-1~P-6（表格行 :31-36）✓ / 4-executor §P1-1~P2-6,T-1,T-2（:21-34）✓ / 5-executor §C-P1~C-P6（:73-100）✓ / 6-executor §D6-01/02/19（:34/35/52）✓ / 7-executor §diff 清单（:22）✓ / report「checkpoint N §ID」8 处引用✓ / `readlink ~/.zcode/skills/alignment-review → task-planner/review-library/alignment-review`✓ / lib/install-companion.sh 实位（ls✓）✓ / 根 6 md（ls✓）✓ / ~/.opencode 与 ~/.config/opencode 同 inode 3436922（stat✓）✓ / score-plans.py 实位 plan-resume/scripts/（find✓）。
  - 要素4 守卫锚级联 PASS（report 零过期锚）：report.md grep「Rules 1-39 / Rules 1-36」共 5 处（:18/:48/:59/:89/:124），全为「引述被守护锚（P-4 的 1-39 机器锚 / P2-3 的 1-36）」非自身漂移措辞；WF-10「Rules 1-39」机器锚（selftest-workflow-orchestration.sh:52-57）未被 report 误引。task_plan 三登记行核对：自动超时默认项=D1 批准（Decisions Made:222 silent D1，与执行一致✓）、对齐审查=本 sub:10（进行中✓）、质量审查工具行（:22）登记 4 工具但 documentation-review/code-quality-review 未作为独立工具面执行（仅 alignment-review 经 sub:10 实际执行）→P2-Q1。
  - **发现项**（分级+锚点；P1 阻断，建议主进程收尾修复）：
    - [P1] report.md:3 头声明「44 条」vs report §3.1-3.5 表格实 42 数据行（awk 计数）（+progress:54 / task_plan:142 同写 44）— 声明 44 ≠ 表格实 42 缺 2 行，且 P2×31/待复核×4 声明 vs 表格 P2×33/待复核×5 口径漂移；计数未随表格联动 — 修法：以表格实行为准重算声明（42 行 / P2×33 / 待复核×5）或补齐缺口行使 44 成立，report+progress+task_plan 三处同步
    - [P2] progress.md:13/30/45/51「Status: in_progress」×4 vs task_plan.md:102/117/134/145「Status: complete」— progress Phase 1-4 状态行未随主进程翻转为 complete（六件套状态同步缺失）；契约 sub:10 禁改既有 Status，登记待主进程收尾补翻
    - [P2] task_plan.md:22 质量审查工具登记含 documentation-review/code-quality-review，实际仅 alignment-review 经 sub:10 独立执行（documentation-review/code-quality-review 由 executor 审查波次承担，未独立执行）— 登记 vs 执行口径偏差，主进程终验注明（Rule 25.4 口径）
    - 负结果：三副本同步面（池 11 技能×3 宿主）与模板/实例面已由 checkpoint 7 33/33 软链健康覆盖，本次未新增检查项；report.md 无机器断言锚（非 selftest 断言对象），守卫锚级联面=WF-10「Rules 1-39」4 索引文档，report 未引述其过期措辞，零漂移。
  - 全文证据与逐条命令输出：checkpoint `plans/task-v107/subagent-state/10-executor.md`

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
