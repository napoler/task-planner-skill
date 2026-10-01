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
-

#### [sub:1-executor] 模板普查
（全量只读普查 2026-10-02；六维结论 + 修复清单 v1；完整清单与证据存 subagent-state/1-executor.md）

- **维度1 v107 结论核实（全坐实）**：① task_plan.md:249 与 critical-rules.md:49 仍旧 worktree 约定 `../<repo>-wt-<task-id>`（worktree-isolation.md:32/37/50 已立新约定 `<repo-parent>/<repo>-worktrees/<task-id>` 并明文废止）；② knowledge-brief.md:9 注释「锚计数维持 20」≠ 实测 `grep -rl "## 📚 必要知识储备" templates/` = 22（guide:77 已 22，此注释未回写）；③ mapping §一清单 13 variant(L32-44)/§六速查 13 行(L133-145)/§九矩阵 14 行 均 ≠ ls variant/ 实测 16（缺 mini-lite/video/video-fix）；④ guide:63「实际 26 个 .md」≠ ls 实测 25、:65 标题「23/26」≠ 实测 22/25（同文件内与 :77 的 22 自相矛盾）；⑤ 4 variant（diagnostic/publish/research/writing）缺 `template_type:` 注释（grep -ln 仅 12 命中），16/16 有 plan_tier；⑥ T-1 坐实：writing:11-12/63、research:14、publish:12/15/34/90 所引 4 脚本全仓 find 0 命中 → 目标项目侧示例值。
- **维度2 区块完整性**：委派统计全 16 variant 缺（Rule 25.4 机器落点在 verification.md「委派统计复验」段 :74，variant 计划共用 verification.md 已覆盖 → task_plan 侧是否镜像节=待裁决 M-11）；Handoff 节仅 mini-lite:44（合法，38.3 白名单⑤），其余 15 缺 → **check-complete.sh:1014-1017 的 Handoff 抽查节锚对 variant 计划静默失效**（M-08 高风险联动）；Drift Log 7 variant 在位 / 9 标准 variant 缺（M-07）；mini-lite 缺委派统计与 Drift = 38.3 白名单合法豁免。
- **维度3 声明形态**：主模板 task_plan.md:8 仅 `plan_tier: standard`，无 `template_type:` 行（L22 正文提及）；12/16 variant 双注释在位。
- **维度4 新规范行**：「自动超时默认项/质量审查工具/对齐审查」3 行仅主模板 task_plan.md:31-33；15 标准 variant 配置表仅 code_review 单行；「🧰 工具选择与编排」仅主模板 L136（40.2 明言 general 承载 + mini 豁免 → variant 缺口需裁决 M-12）。
- **维度5 验证独立性**：templates/ 全库「验证由独立子代理执行」类表述 grep 0 命中；最近锚=Rule 33.3「独立验证（不信自报）」（critical-rules:304）。候选落点 A=verification.md:108 Goal Gate 段后加原则行（终验判定面）/ B=task_plan.md:35 VC 段头部（计划期声明面，Executor 可据此填 V-执行体）；备选 C=task_plan.md:214 Phase 4 / D=verification.md:74 复验段注。推荐 A+B。
- **维度6 四点同步面**：SKILL.md:274「standard 13 variant」、critical-rules:348「14 行：13 variant+general」、:361「现有 13 个 variant」均 ≠16；plan-writer.md:53-66 映射表 14 行缺 mini-lite/video；mapping §一/§六/§九 同缺；guide §2.2 已 16 行 ✓（四落点中 guide 无需改）；selftest-template-lifecycle.sh 实跑 18/18 PASS，TL-17 仅锚 guide「16 个」→ 修 13→16 零自测断裂。
- **修复清单 v1**：M-01~M-13 全文（ID/锚点/修法/性质/联动面）见 subagent-state/1-executor.md「修复清单 v1」表；其中 M-11（task_plan 侧委派统计节是否镜像 15 variant）与 M-12（40.2 口径：variant 补区块 or 改表述）两项待主进程裁决。

#### [sub:2-executor] 批次一
（2026-10-02 批次一六项修复全部完成，git diff --stat 恰 8 文件 +15/-5；旧串零残留复核通过；selftest-template-lifecycle 18/18 PASS；逐项证据见 subagent-state/2-executor.md）

- **M-01/M-02 旧 worktree 约定清零**：task_plan.md:249 `worktree_path` 示例值 与 critical-rules.md:49 Rule 12 目录约定 均改为新范式 `<repo-parent>/<repo>-worktrees/<task-id>`（对齐 worktree-isolation.md 已废止旧约定的结论）；`grep -c "repo>-wt-"` 两文件=0，仅 smart-merge-back.sh:99 注释「旧式」兼容说明残留（脚本自述兼容层，非任务书范围，未动）。
- **M-03 计数锚回写**：knowledge-brief.md:9 头注释「grep 锚计数维持 20」→「维持 22（template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）」，与 guide §2.4 及 `grep -rl "## 📚 必要知识储备" templates/|wc -l`=22 实测对齐。
- **M-05 双数矛盾消解**：template-guide.md:63「实际 26 个 .md」→「25 个」（ls 实测 9 核心+16 variant=25）；:65 标题「23/26」→「22/25」（实测 22/25，与 :77 的 22 一致）。
- **M-06 声明注释补齐**：diagnostic/publish/research/writing 四 variant 首行标题后各插 `<!-- template_type: <X> -->`（位置对齐 bugfix-type.md 既有范式；16/16 variant 现全含 template_type，grep -c 复核 16 文件各 1 命中）。
- **M-10 示例注脚统一**：writing-type/publish-type/research-type 各在该 VC 表末行下加 1 行注脚「> 注：VC 表中脚本路径为示例值（目标项目相对路径），非本技能仓文件」——不删行不改脚本名（article_json_editor.py/verify_content_originality.py/keyword_coverage.py/rollback.sh 保留原位，注脚一次覆盖全表避免逐行重复）。
- **负结果**：worktree 外零写入；无 git add/commit；批次二/三（M-04/M-07/M-08/M-09/M-11/M-12/M-13）未触碰，留待后续批次。

#### [sub:3-executor] 批次二
（2026-10-02 批次二 M-04/M-09 四点同步面 13→16 全部完成；selftest-template-lifecycle 18/18 PASS；逐项证据见 subagent-state/3-executor.md）

- **M-04 mapping 三段补齐**：§一 文件清单 13→16（补 mini-lite/video 两行，另回填 rule-enhancement 既有 §六 落点使 §一 与 variant/ 实测 16 对齐）；§六 速查表 13→16（补 mini-lite「轻量档豁免」、video「内容组-视频 人工门 32.2/QC 8 类」、video-fix「内容组-视频 disposition_ref/full-regen d 级」三行，画像措辞对齐 guide §2.2）；§九 矩阵 14→17（16 variant+general；补 video/video-fix 两行「内容组-视频」+ mini-lite 一行「轻量档豁免」）。
- **M-09 四点同步 13→16**：plan-writer.md:53-68 映射表 14→17 行（补 video/mini-lite，video-fix 既有保留）；SKILL.md:274「standard 13 variant」→「standard 16 variant」；critical-rules.md:348「14 行：13 variant+general」→「17 行：16 variant+general」、:361「现有 13 个 variant」→「现有 16 个 variant」。
- **验收**：批次二 diff 恰 4 文件（mapping +9、plan-writer +2、SKILL 2±1、critical-rules 6±3，基线含批次一 8 文件）；§一 清单=16、§六=16、§九 数据行=17；grep「13 variant」「14 行」「现有 13」四文件零残留（exit=1）；selftest TL-17（guide「16 个」串未动）/TL-18（§九节存在）均 PASS。
- **负结果**：guide §2.2 未动；无 git add/commit；批次三（M-07/M-08/M-11/M-12/M-13）未触碰。

#### [sub:4-executor] 批次三
（2026-10-02 批次三 M-07/M-08/M-12/M-13 增量补齐全部完成；逐项证据见 subagent-state/4-executor.md）

- **M-07 Drift Log 9 文件新补**：bugfix/code-edit/deployment/migration/performance-tuning/refactor/rule-enhancement/schema-migration/test-writing 各追加「## 🚨 Drift Log（漂移检测记录）」节于文件末（精简两行版：标题+四列表头+空行，对齐 task_plan.md:334 范式）。既有 7 文件（diagnostic/publish/research/video-fix/video/writing 等）未动。
- **M-08 Handoff 15 文件补齐**：14 文件追加「## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）」节（说明一行+九列表头+示例行，备注列合并省略，Drift Log 之后/文件末）；diagnostic 既有节标题缺「必填」字样已规范化为全字面（check-complete.sh:1014 节锚「Subagent Handoff 登记表」逐字命中，机器门对 variant 计划生效）。
- **M-12 配置3行+🧰 区块**：15 文件「🔍 Code Review 配置」表补「对齐审查/自动超时默认项/质量审查工具」3 行（主模板 :31-33 精简版）；无该节的 7 文件（diagnostic/publish/research/video-fix/video/writing 等）先补「## 🔍 Code Review 配置」节再挂 3 行；各文件「## Phases」节前插「## 🧰 工具选择与编排（Rule 40）」精简区块（说明一行+三列表头+示例 1 行）。mini-lite 未动。
- **M-13 验证独立性双落点**：verification.md Goal Gate 段末（:117）追加 A 行（独立子代理终验;Rule 33.3 延伸;2026-09-26 用户裁决）；task_plan.md VC 段引导注释后（:48）插入 B 行（独立子代理执行验证;Executor 可填 V-类执行体）。
- **验收**：diff --stat 本批 15 variant(+20..23)+verification.md(+2)+task_plan.md(本批+1)=17 文件（knowledge-brief.md 改动属 Phase 2 既有未提交变更，不计本批；task_plan.md 隔离决策 worktree_path 行改动同为既有）；机械计数 Drift Log grep -L 仅 mini-lite 1 缺（16/16 有）、Handoff grep -l=16/16、配置3行 15/15、验证独立性 verification/task_plan 各 1 命中；selftest-template-lifecycle 18/18 PASS、selftest-plan-tier 32/32 PASS（mini-lite 白名单未破坏）。无 git add/commit。

#### [sub:5-executor] 独立回归验证
（全新独立会话，2026-10-02；42/42 selftest 于 worktree 内全量回归，逐脚本 rc 逐项回报，证据见 subagent-state/5-executor-results.txt）

- **全量结果**：42/42 脚本 rc=0；机械求和（grep 各脚本 Total 行）PASS=638+22(final-gate-hash)=660，FAIL=0 —— 与基线 660/0 完全一致，无回归。
- **逐脚本原文**：42 行（`N 脚本名 rc=0 dur=Ns <Total 行原文>`）全录于 `subagent-state/5-executor-results.txt:1-42`；其中 selftest-registry 行末附注「(registry rows=42, actual selftest=42)」，selftest-final-gate-hash 无 `Total:` 行、其原始结果行为 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（已如实记录，未伪造 Total 行）。
- **超时情况**：单脚本最大耗时 22s（final-gate-hash / vc-gate），远低于 90s 阈值，无 timeout 标记；全批 121s 完成，远低于 25min 总预算。
- **负结果**：rc≠0 或 FAIL>0 的脚本 = 0（不存在）；worktree 与主仓零文件写入，无 git 写操作；批次三 23 文件 commit 后自测面零断裂。
- **结论**：独立门通过，可进入合并回（VC-1 满足：独立子代理全新会话全量 42 selftest 0 FAIL，逐脚本 rc 已回报）。

#### [sub:6-executor] 形态与干净上下文验证
（全新独立会话，2026-10-02；对象=worktree 三批次修复后终态：/mnt/data/dev/task-planner-skill-worktrees/task-v108/skills/task-planner/templates/variant/ + scripts/）

- **① 形态核查（16/16）**：`cd variant && for f in *-type.md; do echo "$f $(grep -c 'template_type:' $f)"; done` → 16 行逐文件计数全部 =1（bugfix/code-edit/deployment/diagnostic/migration/mini-lite/performance-tuning/publish/refactor/research/rule-enhancement/schema-migration/test-writing/video-fix/video/writing，各 1）。值与文件名匹配核对（`grep -o 'template_type:.*' | head -1`）：16/16 值 = 文件名去 `-type.md` 后缀（如 diagnostic-type.md → `template_type: diagnostic -->`，无 -type 后缀残留），无一例外。
- **① 内置模板现状**：templates/ 下 task_plan.md、knowledge-brief.md、shared-tracker.md、batch_report.md、verification.md、subagent_dispatch.md 六文件 `grep -c 'template_type:'` 全部 =0（现状：仅 variant 带声明，内置通用模板无 template_type 行——与三批次修复范围一致，非异常）。
- **② 干净上下文实测**：`TESTDIR=$(mktemp -d /tmp/v108-fresh-XXXX)` → /tmp/v108-fresh-IaHM；`mkdir plans/fresh-test-$$` 后 `cd` 入内运行 worktree 的 `init-session.sh`（无位置参 → general 缺省路由；`SCRIPT_DIR` 自解析使 BUILTIN_TEMPLATES 指向 worktree 模板，输出「No project-level templates found, using built-in defaults」→ 6 文件全部 built-in 复制）。结果：6/6 文件建成（findings/progress/notepad-learnings/verification/knowledge-brief/task_plan），脚本自报 `[init] 6/6 planning files verified`、exit 0。task_plan.md:48 命中「**验证独立性**：本计划验证动作默认由独立子代理执行…」=1 处（M-13-B 生效实证）。`check-template-type.sh <生成 task_plan.md>` 输出 `[template-gate] OK: template_type=general`、exit 0。
- **② 模板来源行为记录**：init-session.sh 经 `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` 自解析脚本位置，BUILTIN_TEMPLATES=`$SCRIPT_DIR/../templates`——直接调用 worktree 内脚本即取 worktree 模板，无需 SKILL_ROOT/home 环境变量（未发现此类变量支持，行为如上）。
- **③ 残留与清理**：脚本在 `$TESTDIR/plans/` 下另留 `**active_plan_side** 指针（`.active_plan_side/afd0b28e….active_plan` 内容=`fresh-test-415545`）——随 TESTDIR 一并删除，主仓 plans/ 零写入、零残留。`rm -rf /tmp/v108-fresh-IaHM` 后 `ls /tmp/v108-fresh-*` → `No such file or directory`，清理确认。
- **负结果**：无异常——16/16 形态全过；init-session 全链路 exit 0；worktree 与主仓零文件写入（仅本允许 findings/progress 追加与 checkpoint 落盘），无 git 写操作。

#### [sub:7-executor] 对齐审查
（全新独立会话，2026-10-02；按 alignment-review 四要素审查 worktree 三批次修复后模板变更面 23 文件 +333/-8；逐项证据见 subagent-state/7-executor.md）

- **结论**：APPROVED（P0/P1=0，仅 P2×1）
- **要素1 文档↔产出同步**：M-01~M-13 逐项对应 23 文件 diff 全吻合——抽 5 项 diff 原文：M-01 task_plan.md worktree_path `../<repo>-wt-<task-id>`→`<repo-parent>/<repo>-worktrees/<task-id>`、M-02 critical-rules Rule 12 同改、M-03 knowledge-brief:9 锚计数 20→22、M-05 guide 26→25/23·26→22·25、M-09 SKILL.md:274「standard 13 variant」→「standard 16 variant」+critical-rules:348/361 17 行·16 variant、M-13 双落点（verification.md Goal Gate 后 + task_plan.md VC 段后「验证独立性」行各 1 命中）；M-11 裁决落地核实：16 variant `## 📊 委派统计` 节 grep -l=0（不镜像=Phase 2 裁决一致）；无清单外改动、无清单内遗漏（15 variant diff 增量=Drift Log/Handoff/配置 3 行/🧰 区块四项，与 M-07/08/12 一一对应）。
- **要素2 计数枚举联动**：16/17/22/25 全口径互查一致——mapping §一清单=16、§六速查=16、§九矩阵数据行=17（16 variant+general）；plan-writer 映射表 L53-68=17 行（16 variant+general）；SKILL.md:274「16 variant」；critical-rules:348「17 行：16 variant+general」+:361「现有 16 个 variant」；guide:63「25 个 .md」（ls 实测 9 核心+16 variant=25）+:65「22/25」（grep 实测 22）；knowledge-brief:9「维持 22」（grep -rl 知识储备锚实测=22）；旧串「standard 13 variant/14 行：13/现有 13 个 variant/`../<repo>-wt-<task-id>`」全仓 grep 零残留。
- **要素3 引用完整性**：新增内容引用抽验 10 条全过——variant 配置 3 行引 Rule 42.6（critical-rules:424 在位，含 42.6.1/42.6.2 及 mini 豁免口径）/Rule 44 44.2（:442 在位）/Rule 42.2 四级检测（:420 在位）；🧰 区块引 Rule 40（SKILL:48 索引行+40.2:398「standard/full 档计划须含」原文，variant 补区块与 40.2 语义一致）；Handoff 节标题引 Rule 22.5（:158 交接登记在位）；验证独立性行引 Rule 33.3（:304「独立验证（不信自报）」原文）+「2026-09-26 用户裁决」（findings 三批次记录在位）；mini-lite 38.3 白名单（:362 在位）；worktree 新约定串与 worktree-isolation.md:32 逐字一致；「人工门 32.2」画像性引用合法（32.2 为计划期禁令消费条款）。
- **要素4 守卫锚级联**：selftest-template-lifecycle 实跑 18/18 PASS（TL-17 guide「16 个」+rule-enhancement 锚健康，TL-18 §九节在位）；selftest-plan-tier 实跑 32/32 PASS（mini-lite 白名单断言未破坏）；check-complete.sh:1015 awk 节锚 substring「Subagent Handoff 登记表」对 16/16 variant 标题命中（15 个全字面「（Rule 22.5 必填）」+ mini-lite:44「（Rule 22.5）」，awk 为 substring 匹配→机器门对 variant 计划生效，M-08 高风险联动闭环）。
- **发现分级**：[P2] mapping:232 §九 mini-lite 行「跳 FMEA/知识储备/委派统计/Batch 区块」较 critical-rules:361（38.2 档位矩阵）原文「知识储备表」缺「表」字——建议补字对齐，不阻断（selftest 无该串断言）。§六 :149 mini-lite 行写 38.1 三条件（≤2 文件∧≤15min∧单模块）属合法异文，不计漂移。
- **负结果**：P0/P1=0；worktree 零写入、零 git 操作；内置 6 模板无 Handoff/Drift Log 节=主模板范式例外（task_plan.md 主模板承载），非缺陷。

#### [sub:9-executor] 部署对账
（全新独立会话，2026-10-02 04:21；对账对象=主仓 5a30382（Merge branch 'wt/task-v108'，23 文件全在 skills/ 下）vs ~/.zcode、~/.claude、~/.opencode 三宿主，三宿主只读，零写入零 git 写操作；方法=23 文件×3 宿主 diff -q + 宿主 blob 是否=merge-base ac82371 归类，全程 ~10min）

- **23 文件×3 宿主逐宿主结论**（diff -q 全部 DRIFT=23/23/23，进一步以「宿主文件是否=base ac82371 版本」定落后/独立迭代）：
  - **~/.claude：落后 23 文件，无独立迭代**（at-base=23/23）→ 纯落后；部署建议：主仓 23 文件一次性全量同步，无冲突风险
  - **~/.opencode：落后 23 文件，无独立迭代**（at-base=23/23）→ 纯落后；部署建议：同上全量同步
  - **~/.zcode：落后 20 文件 + 独立迭代 3 文件**（at-base=20/23）；独立迭代 3 文件 = plan-template-kit/references/template-guide.md（「Variant 模板 28 个」计数 + videop1 +image 与 +12 视频工序映射）/ template-mapping.md（12 行 videop1 分支映射）/ task-planner/companion/agents/plan-writer.md（videop1 variant 类型表 + 删质量审查工具行 v099 异文）；部署建议：仅 3 文件与 videop1 双向漂移（v107 28-variant 面）正面冲突，须先裁决 videop1 是否上主仓再同步，其余 20 文件可单独同步
- **variant/ 目录级差异**（diff -rq，只列文件名；主仓 16 *-type.md）：
  - zcode=28 个：主仓 16 个全部内容 differ；宿主独有 12 个 = audio-voice / character-design / final-assembly / image / motion-camera / multiview-ref / physics-compliance / prompt-struct / qc-defect / script-dev / storyboard / video-prompt-type.md（videop1 12 类视频工序，v107 已知面，本次复核确认仍在）
  - claude=16 / opencode=16：与主仓同名集合一致，16 个全部内容 differ（均=base 旧版）
  - **template_type 注释状态**（grep -L "template_type:"）：主仓 16/16 全有；三宿主**各缺 4 个**=diagnostic / research / publish / writing-type.md（该注释为 5a30382 新增，base 中 4 文件 0 处→宿主为旧版所致）；zcode video-prompt-type.md template_type=1（独有文件已带注释）
- **负结果**：无阻塞；三宿主部署位零文件写入；23 文件无 MISSING（三宿主目录结构与主仓完全对应）；唯一风险面 = zcode videop1 3 文件双向漂移（覆盖即丢），已记入部署建议供用户裁决

## Technical Decisions

#### [sub:8-executor] 合并后主仓终验
（全新独立会话，2026-10-02；master@5a30382（Merge branch 'wt/task-v108'）全量 42 selftest 机械回归终验，v079 教训「合并回后必跑 master 全量防基线漂移」；逐项证据见 subagent-state/8-executor.md + 8-executor-results.txt）

- **结论**：42/42 selftest 全部 rc=0，FAIL=0；机械求和 PASS=660（与 sub:5 worktree 基线 660/0 一致，无基线漂移）；单脚本最大耗时 22s<90s 超时阈值，无超时、无 partial。
- **42 行逐项原文**：格式 `N 脚本名 rc=N dur=Ns :: Total 行原文`，存 8-executor-results.txt:1-42（含 final-gate-hash 特殊格式说明：无 Total 行，结果行 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` rc=0 计入 22/0）。
- **registry 自证**：selftest-registry.sh rc=0 `Total: 5 PASS=5 FAIL=0 (registry rows=42, actual selftest=42)`——登记数=实跑数=42。
- **负结果**：rc≠0 或 FAIL>0 的脚本 = 0（不存在）；主仓零文件写入（仅本允许的 findings/progress 追加与 checkpoint/results 落盘），零 git 写操作；基线 660/0 无漂移。

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
