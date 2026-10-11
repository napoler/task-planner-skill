# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
-->

## Requirements
- 用户诉求（2026-10-03 原话）：「视频 生成 图片生成 剧集创作相关任务处理时候子代理没有进行精细拆分，还有存在总是使用默认代理解决需要有优化」
- 拆解：① 媒体任务需要媒体轴精细拆分（集/场/镜/张 × 工序阶段）② 派发需具名执行体路由，禁 general-purpose 无登记默认兜底

## 📚 必要知识储备对齐记录
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点 |
|--------|---------------|-----------|---------------------|
| Rule 44/45/46 范式 | skills/task-planner/references/critical-rules.md:440-483 | ☑ | §Rule 47 条款草案（范式对齐） |
| §九机制矩阵+§十工具映射 | skills/plan-template-kit/references/template-mapping.md:254-312 | ☑ | §归因 / §mapping联动草案 |
| SKILL.md 路由表/摘要/references 表 | skills/task-planner/SKILL.md:281-347 | ☑ | §SKILL 联动草案 |
| 守卫级联面 | scripts/selftest-*.sh grep（444/483/558/C3x） | ☑ | §2 已验证事实（knowledge-brief） |
| selftest 零新键范式 | scripts/selftest-reliability-institution.sh | ☐ S4 读 | — |
| 部署机制 | scripts/smart-merge-back.sh:1-40 | ☐ P5 读 | — |

## Research Findings

### §1 路由与机制画像现状（explore #1 结论，agent_fab2d362）
1. template-mapping.md §九定义 5 机制组：代码组（9 类）/内容组（15 类）/内容组-视频（video/video-fix）/通用组/轻量档。消费点=critical-rules.md Rule 37.4①（委派检查点先查画像再定执行体）/②（Code Review Gate 触发）/③（内容组走 content_quality）。
2. 媒体类型模板已存在：video(:273)/video-fix(:274)/image(:277)/script-dev(:278)/character-design(:279)/multiview-ref(:280)/storyboard(:281)/prompt-struct(:282)/video-prompt(:283)/motion-camera(:284)/physics-compliance(:285)/qc-defect(:286)/audio-voice(:287)/final-assembly(:288)——共 14 类。
3. general-purpose 兜底定位：skill-agent-router/SKILL.md:17-18「最后的兜底，不是默认选择」；SKILL.md:298 `next_skill: general-purpose`（Chain 交接）。路由表无匹配行时仅多领域/新领域才落 general-purpose。
4. **拆分轴缺口**：Rule 21.1b（critical-rules.md:141）S-unit ≤2文件/≤100行/≤15min 纯代码导向，无媒体等效拆分轴；内容质量门控只管终验不管拆分粒度。
5. 机器校验：check-plan-dispatch.sh attest 校验 S-unit 执行体列+时长 NNmin+输入 ≤2 文件；check-dispatch.sh 校验步骤枚举 >step_max_steps(4)。

### §2 执行体/守卫/部署盘点（explore #2 结论，agent_714470db）
1. variant 模板 29 个（含媒体 14 类）；check-template-type.sh 白名单=variant 基名+general。
2. **~/.zcode/agents/ 无视频/图片/剧集执行体**——内容生产类仅 article-* 系列 12 个+marketing/organic 等写作类。画像引用的 script-writer/script-auditor 不存在。
3. agnes-ai-generation-skill = 调用 Agnes AI 生成 API 的技能（文本/图像/视频生成）。
4. 守卫级联面：SKILL.md 行数上限断言 **≤558**（selftest-knowledge-brief.sh:38、selftest-skill-collab.sh:82、selftest-execution-stability.sh:72），现 444 行余量足；selftest-plan-tier 断言「Critical Rules 全集 1-4[5-9]」（v121/53936ec 预扩，承接 Rule 47-49 零级联）；无 critical-rules.md 行数定数断言。
5. 部署=smart-merge-back.sh --deploy（3 默认位，slot→.bak→tmp→slot 对账）。

#### [sub:1-code-runner] 全量 selftest 基线（Rule 47 落地前取证）
- 执行窗口：2026-10-03T00:57:10Z ~ 00:58:46Z（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v122，纯只读运行）。
- 43/43 脚本全部执行完毕，0 超时 0 跳过；全部 rc=0；42 个脚本末行 `Total: N PASS=N FAIL=0`，无一条 FAIL。
- 唯一非常规输出格式：selftest-final-gate-hash.sh 末行为 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（自带横幅，无 `Total:` 前缀）；另 selftest-delegation/execution-stability/fallback/knowledge-brief/skill-collab/skill-split 的 `Total:` 行存在双空格变体（不影响求和）。
- 逐脚本明细与完整日志：检查点 plans/task-v122/subagent-state/1-code-runner.md 与 1-code-runner.log。

#### [sub:executor-m3] mapping 联动两处纯增量落盘（S3 执行回执）
- 落点 A：§九末注后（现 :298）插入「媒体族执行体兜底路由（task-v122 Rule 47.2）」注 1 行，文案=草案原文机械插入零改字句；grep -c 'Rule 47.2' = 2（A+B 各 1 次命中）。
- 落点 B：§十内容组行后（现 :308）插入「媒体制作族」特化行 1 行，文案=草案原文；grep -c '媒体制作族' = 1。
- 零改动守护：git diff --numstat = `2 0 template-mapping.md`（0 deletions）；§九既有 30 行矩阵与 §十既有 6 行零改；文件 wc -l = 314（312+净增 2，≤316 达标）。
- 检查点：plans/task-v122/subagent-state/m3-executor.md（status: done）。


#### [sub:executor-m1] Rule 47 条款草案全文追加 critical-rules.md 文末（S1 执行回执）
- 取稿：findings.md 围栏草案（### 47 标题行 + 47.1-47.4 四子条，11 行）原文机械追加至 critical-rules.md 文末（原 46.5 收尾 :482 之后），零改字句零重排。
- 落点验证：wc -l 483→494（+11）；grep -c '^47.' = 4；grep -c '^### 47 ' = 1。
- 零删改守护：git diff --numstat = 11+0（0 deletions）；46.x 及更早内容 diff 无改动行。

#### [sub:executor-m2] SKILL.md 三处联动纯增量落盘（S2 执行回执）
- 落点 A（路由表）：「业务文档/配置/技能文件」行后插入媒体生成工序/剧集创作管线 2 行（草案原文机械插入零改字句）；grep -c '媒体生成工序'=1、grep -c '剧集创作管线'=1。
- 落点 B（摘要）：Critical Rules 摘要 Rule 44 bullet 后插入 Rule 47 bullet 1 行；grep -c 'Rule 47（媒体制作任务派发纪律'=1。
- 落点 C（references）：critical-rules 行行尾「Rule 46 子代理单任务专注度」后行内追加「/ Rule 47 媒体制作任务派发纪律」（1 增 1 删，零净增行）；grep -c 'Rule 47 媒体制作任务派发纪律'=1。
- 行数/守护：wc -l 444→447（净增 3 ≤6，≤558 达标）；diff --stat = `5 ++++-`（4 insertions, 1 deletion）；防呆 grep '1-4[5-9]' 三脚本先例（ask-default-timeout/conclusion-discipline/plan-tier）确认追加 Rule 47 名不触发级联。
- 检查点：plans/task-v122/subagent-state/m2-executor.md（status: done）。

#### [sub:executor-m4] selftest-media-dispatch.sh 静态守护 + registry 登记（S4 执行回执）
- 新建 skills/task-planner/scripts/selftest-media-dispatch.sh（MD-01..MD-09 九断言，断言清单=findings §selftest 断言清单原文机械落盘；头注释四要素 + 每断言 What/Why 双层注释；ok()/bad()/Total 行/exit 语义范式同 selftest-reliability-institution.sh；MD-08 零新键 jq properties=40 沿用 R-12 fail-open SKIPPED 先例）。
- TMAP 定位法修正记录：template-mapping.md 已随 task-v095 拆分移入 plan-template-kit/references/（task-planner/references/ 无此文件），采用先例 `$SKILL_ROOT/../plan-template-kit/references/template-mapping.md`（同 selftest-mechanism-profile.sh:30、selftest-template-lifecycle.sh:37）。
- registry.tsv 末行追加 1 登记行（4 列制表符分隔，cat -A 确认 ^I 分隔）；git diff 仅限 2 文件（新脚本 untracked + registry 1 insertion 0 deletion）。
- 自检：selftest-media-dispatch.sh rc=0 `Total: 9 PASS=9 FAIL=0`；selftest-registry.sh rc=0 `Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)`；grep -c 'selftest-media-dispatch' registry = 1。
- 检查点：plans/task-v122/subagent-state/m4-executor.md（status: done）。

#### [sub:executor-m5] 全量 selftest 回归（44 脚本，Phase 3）
- 44 脚本（43 基线 + 新增 selftest-media-dispatch.sh）全部执行完毕，无 >60s 跳过；逐脚本 Total/rc 原文见检查点 subagent-state/m5-executor.md 及 m5-executor-run.log。
- 结果: 43 脚本全绿，唯一 FAIL = selftest-skill-split.sh `Total: 41 PASS=40 FAIL=1`（rc=1），FAIL 行原文 `[FAIL] T-主 行数 ≤444（task-v112 交付总结模板指针+2 行;演进 440→442→444）且 ≤558 上限`。
- 现场取证（只读）: `wc -l skills/task-planner/SKILL.md` = 447（超 444 上限，未破 558 硬上限）。
- 归因方向（未验证，供主进程裁决）: commit 4bdfa4a（task-v122/Phase 2，Rule 47 条款 +SKILL 联动，+17/−1）使 SKILL.md 越过 444；selftest-skill-split.sh 444 上限断言在 Rule 47 增量落地时未同步演进。基线 Phase 1 时 444 满足，FAIL 非 S4 新增 media-dispatch 脚本引入。
- 新增脚本贡献与预期一致: selftest-media-dispatch.sh `Total: 9 PASS=9 FAIL=0`；selftest-registry.sh `Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)`。
- 回归非全绿 → 主进程需裁决：演进 444 上限断言（如 444→447）或压缩 SKILL.md 行数后重跑该脚本。

#### [sub:executor-m5b] T-主 行数上限断言 444→447 单行锚演进（修复单 m5b 执行回执）
- 落点：worktree skills/task-planner/scripts/selftest-skill-split.sh:41 单行替换（444 断言→447 断言，label 同步注明 task-v122 与演进链 440→442→444→447，≤558 上限不变），按 rule-enhancement 模板明文先例（v071→v074/v112 同款），其余行零改动。
- 验收证据：selftest-skill-split.sh rc=0 `Total: 41  PASS=41  FAIL=0`（修复前 FAIL=1→FAIL=0）；git diff --numstat = `1 1`；残留守护 `grep -c 'le 444'` = 0（label 演进链文案 440→442→444→447 中的 "444" 为指定新文案固有部分，非旧断言残留）。
- 背景：本任务 Phase 2（commit 4bdfa4a）使 SKILL.md 444→447，该断言级联属计划 FMEA 预登记「锚过窄→宽容化」兜底（Handoff #11 已登记）。
- 检查点：plans/task-v122/subagent-state/m5b-executor.md（status: done）。

#### [sub:executor-m6] VC-5 全量回归独立复核（fresh，44 脚本逐条 rc/Total）
- 执行方式：cwd=/mnt/data/dev/task-planner-skill-worktrees/task-v122 单条 for 循环全量 fresh 运行 44 脚本（含已修复的 skill-split），总耗时 222s，零超时跳过；逐脚本 `== 名 / Total: 行 / rc= 行` 原文全量留痕 subagent-state/m6-executor.log（40110B），本会话未引用/转抄 m5 日志。
- 机器计数（源自本会话 fresh 日志）：== 块=44 / rc= 行=44 / 终态行=44（43×`Total:` + final-gate-hash×`结果:`）；FAIL 总和=1；逐 Total 求和 PASS=684 / FAIL=1（44 脚本用例总和 685）；registry rows=44 actual=44。
- 唯一 FAIL：selftest-self-resolution.sh `Total: 13 PASS=12 FAIL=1` rc=1，明细行原文 `SR-11 FAIL selftest-skill-split.sh 级联锚缺失（task-v099|task-v1x / -le 4 前缀断言行）`。
- 根因定位（只读）：selftest-self-resolution.sh:88 SR-11 宽容正则 `task-v099|task-v1[0-1][0-9]` 于 skill-split 零命中（skill-split 内 task-v 标签实为 v095×2/v097×1/v122×1）；`-le 4` 行在位（skill-split:41，-le 447/-le 558，m5b 锚演进 444→447 后 label=task-v122）。即 m5b 锚演进把 label 推进到 task-v122，超出 SR-11 正则 task-v1[0-1][0-9]（覆盖 v100-v119）覆盖域 → 同族「锚过窄→宽容化」级联断裂（v071→v074/v112/v121 先例，task_plan FMEA 预登记分支），与 S5 已修复的 ≤444 行数断言是不同断言，非回归。处置待主进程裁决（扩正则至 task-v12x 或等价），m6 未越权修改。
- 负结果声明：其余 43 脚本终态行 FAIL=0 全绿（含 media-dispatch 9/9、skill-split 41/41、registry 5/5(44=44)、final-gate-hash 结果 PASS=22 FAIL=0）；registry rows=44/actual=44 与预期一致。

#### [sub:executor-m6b] SR-11 跨锚宽容正则扩域自洽化（修复单 m6b 执行回执）
- 落点：worktree skills/task-planner/scripts/selftest-self-resolution.sh 仅 2 行——:88 条件行正则 `task-v099|task-v1[0-1][0-9]`→`task-v099|task-v1[0-2][0-9]`（[0-2] 覆盖 v100-v129）；:87 注释行尾追加 `;2026-10-03 task-v122 锚演进: skill-split label 迁至 task-v122 越出 v11x，正则扩 v12x（[10-2] 覆盖 v100-v129），断言语义不变`（同款先例：v100 B 类扩围、v102、v113 三次宽容化，断言语义不变）。
- 验收证据：selftest-self-resolution.sh rc=0 末行 `Total: 13 PASS=13 FAIL=0`（修复前 m6 实测 PASS=12 FAIL=1）；selftest-skill-split.sh rc=0 末行 `Total: 41  PASS=41  FAIL=0`；git diff --numstat = `2 2`（仅注释行+条件行）；新域唯一 grep -c 'task-v1\[0-2\]\[0-9\]' = 1、旧域残留 grep -c 'task-v1\[0-1\]\[0-9\]' = 0。
- 归因确认：m5b 锚演进把 skill-split label 推至 task-v122（v122 > v119），越出 SR-11 正则覆盖域 → 本 fix 属计划 FMEA 预登记「锚过窄→宽容化」分支（Handoff #12 已登记），非回归、非越权修改。
- 检查点：plans/task-v122/subagent-state/m6b-executor.md（status: done）。

#### [sub:executor-m8] alignment-review 对齐审查（S7，Rule 42.6.2 标准收尾）
- 审查对象：4 个 scope 产出（worktree 提交 4bdfa4a/16d7df8/d186384）——critical-rules Rule 47 块 :484-494 / SKILL :282,306,356-357 / mapping :298,308 / selftest-media-dispatch.sh（新建 126 行）+ skill-split:41 + self-resolution:87-88 + registry 末行。
- 四面引用 grep 对照全一致：「媒体制作任务派发纪律」在 critical-rules:484 标题 / SKILL:282 bullet / SKILL:306 references 行尾 / selftest-media-dispatch 头注+registry 描述 五处同一措辞；`grep -c '^47\.'`=4；SKILL 媒体行=2（:356 媒体生成工序/:357 剧集创作管线）；mapping「Rule 47.2」=2（:298 兜底注/:308 特化行）、「媒体制作族」=1（:308）；21.1b 既有锚 :141 在位零改动。
- 守卫锚级联核验：skill-split:41 锚 `≤447` 与 SKILL 实际 447 行一致（≤558 不越）；self-resolution:88 正则 `task-v1[0-2][0-9]` 覆盖 skill-split label task-v122；fresh 复跑 media-dispatch `Total: 9 PASS=9 FAIL=0` rc=0。
- 越界自检：三提交文件集 ⊆ 计划 scope（+FMEA 预登记两级联修复文件）；config.json properties=40 未动（VC-2）；本审查纯只读零仓库修改。
- 结论：APPROVED（P0/P1=0；P2×1=SKILL:306 前段「Critical Rules 1-39」旧文案不阻断，建议后续轮刷新 1-47 口径）；变更记录三要素已落 verification.md「对齐审查结论」段。
- 检查点：plans/task-v122/subagent-state/m8-executor.md（status: done）。

#### [sub:executor-m9] Code Review Gate 回执（code-quality-review 隔离审查，3 个 .sh 重 diff 全量）
- 加载：Read /home/terry/.zcode/skills/code-quality-review/SKILL.md（池成员实名；契约中 "code-review" 为命名漂移）。
- 对象：selftest-media-dispatch.sh（新建，commit 16d7df8 +95/0，HEAD 实文件 wc -l=95；派发契约"126 行"为口径偏差）、skill-split:41（444→447 单行锚 ±1，16d7df8）、self-resolution:87-88（SR-11 正则扩 v1[0-2]x +2/−2，d186384）；基准 b07c0cb，累计 diff numstat=95+/2 2/1 1。
- 14 维清单全 PASS，P0/P1=0，P2×2（不阻断）：① media-dispatch 权限 -rwxrwxr-x 与套内混合权限不统一（运行链一律 bash 调用，不影响执行）② skill-split:41 label 锚引用 task 代号而非 commit hash（rule-enhancement 模板明文先例，维持）。
- fresh 实跑（本会话，全 rc=0）：media-dispatch `Total: 9 PASS=9 FAIL=0`（MD-08 jq 在位实跑 properties=40 非 SKIPPED）；skill-split `[PASS] T-主 行数 ≤447` + `Total: 41 PASS=41 FAIL=0`；self-resolution `SR-11 PASS` + `Total: 13 PASS=13 FAIL=0`；bash -n ×3 OK。
- 越界自检：3 文件 ⊆ 契约 scope（+FMEA 预登记两级联修复文件）；worktree `git status --short`=空；config 未动；纯只读零 git 写。
- 终局结论：**APPROVED**（二值）；结论+证据段已落 verification.md「Code Review Gate 结论」段。
- progress.md Phase 5 行未写（契约"仅 Phase 5 段"但该段尚不存在，沿用 m6 先例留主进程补）。
- 检查点：plans/task-v122/subagent-state/m9-executor.md（status: done）。
## 归因（Rule 31.2 四维，用户指出缺陷触发）
| 维度 | 内容 |
|------|------|
| 现象 | 媒体任务（视频生成/图片生成/剧集创作）执行时子代理拆分粗、总用 general-purpose |
| 直接原因 | SKILL 路由表无媒体行 → 无具名执行体映射；Rule 21.1b 无媒体拆分轴 |
| 根因（5 Whys） | 为何 general-purpose？→路由表无匹配行。为何无行？→媒体类型只建到模板/画像层，派发层未联动。为何拆分粗？→21.1b 拆分轴=文件/行，媒体天然轴（单元×工序）无等效定义。为何脱节？→画像执行体列引用项目专属资产（tools/gen.py、script-writer——videop1 项目资产）通用环境缺位，缺「资产缺位时的通用兜底路由」条款。**根因=类型体系与派发路由两层脱节：画像有类型、路由无行、拆分无轴、资产缺位无兜底** |
| 类别 | 机制缺口（设计盲区，非执行失误） |

## Rule 47 条款草案全文（S1 材料包——插入点：critical-rules.md 文末 46.5 之后）

```markdown

### 47 媒体制作任务派发纪律（P0, 2026-10-03 task-v122，目标：视频生成/图片生成/剧集创作类任务获得媒体轴精细拆分与具名执行体路由——消除「拆分粗+general-purpose 默认兜底」双层脱节；判定面=LLM 行为+selftest 静态守护、零新 config 键；衔接 Rule 21.1b/37.4/18.9，既有 Rules 原文零改动）

本条源于用户 2026-10-03 反馈：媒体制作任务在 task-planner 治理下子代理拆分粗、总是落 general-purpose 默认代理。归因（5 Whys 收敛）：模板/画像层已有媒体 14 类（template-mapping.md §九 video/image/script-dev+工序 11 类），但其「执行体路由组」列引用项目专属资产（tools/gen.py·qc.py、script-writer 等）在通用环境缺位；SKILL.md 路由表无媒体制作行；Rule 21.1b 拆分轴纯代码导向（文件/行）——三层脱节使执行会话落回 general-purpose 兜底（skill-agent-router 定位其=最后兜底非默认）。

47.1 **媒体拆分轴（阶段 × 生产单元）**：template_type ∈ 媒体族（video/video-fix/image/script-dev/character-design/multiview-ref/storyboard/prompt-struct/video-prompt/motion-camera/physics-compliance/qc-defect/audio-voice/final-assembly）的派发型 Phase，S-unit 拆分轴 = 制作阶段（写词→生成→质检→处置→组装）× 生产单元（集/场/分镜/镜头/张/音频条）；单 S-unit = 单生产单元 × 单阶段（例：「E3S2 镜头视频生成」），禁止「整集生成」式粗粒度派发。21.1b 的文件/行上限对媒体任务按生产单元等效换算——预估时长仍是拆分主判据（生成 API 等待时长计入预估），预估 >15min 或单元数 >1 批 → 拆分为多 S-unit 而非整体派出。

47.2 **具名执行体路由（general-purpose 默认兜底禁止）**：画像 §九执行体路由组引用的项目专属资产在当前环境缺位时，媒体族通用兜底路由 = `executor(sonnet-1)` + 对应工序 variant 模板 SOP + 生成技能（如 Skill("agnes-ai-generation-skill") 或项目侧生成工具，派发 prompt 必须点名技能与生成参数契约）；质检工序 = QC/审查类子代理；写词/剧本/判定类零生成工序 = executor(sonnet-1) 判断档。general-purpose 仅限跨领域复合/无法归类场景且须在 Handoff 登记表登记理由（对齐用户宪法 §一 与 skill-agent-router「最后兜底非默认」定位）；禁止因「路由表无匹配行」而默认落 general-purpose。

47.3 **批量生成试点先行（联动 Rule 18.9-18.11）**：同参批量生成 ≥3 生产单元前，首单元必须试点验证（提示词/参数/产物质检三通过）→ 参数冻结 → 方可批量；首单元失败禁止批量（18.9 硬门）；失败率熔断沿用 18.10。并行面按 Rule 21.4：同参无依赖批量单元可声明并行组，依赖前序产物（母图/分镜/剧本定稿）的工序强串行。

47.4 **机制（零新 config 键 — 与 43.4/44.4 同范式）**：判定面=LLM 行为（计划期媒体轴拆分、具名执行体路由、试点先行，非机器触发，无需开关键）；机器面=`scripts/selftest-media-dispatch.sh` 静态断言（47.1-47.4 四子条文本锚 + SKILL.md 路由表媒体行锚 + template-mapping.md §九兜底注锚 + 零新键）；消费侧=委派检查点（Phase 执行循环步骤 2.5）查画像时对媒体族 template_type 套用本条；既有 21.1b/22.6/37 原文零改动（Rule 36.5 纯增量）。
```

## SKILL 联动草案（S2 材料包——三处，净增 4-6 行）

1. **路由表**（§子代理路由与模型分级，插在「业务文档/配置/技能文件」行之后）+2 行：
```markdown
| **媒体生成工序（视频/图片单体：写词/生成/QC/修正）** | `executor` + 工序 variant 模板 SOP + 生成技能（Rule 47.2） | **sonnet-1** | ❌ | ≤1 生产单元 × 1 工序 | 拆 S-unit（Rule 47.1 媒体轴） |
| **剧集创作管线（多集/多镜整链）** | `executor` 按集→场→镜逐级拆 Phase/S-unit（Rule 47.1） | **sonnet-1** | ❌ | ≤1 集 × 1 工序 per S-unit | 拆 Phase |
```
2. **Critical Rules 摘要**（Rule 46 bullet 之后）+1 bullet（约 2 行）：
```markdown
- **Rule 47（媒体制作任务派发纪律 — task-v122）**：媒体拆分轴=制作阶段×生产单元，单 S-unit=单单元×单阶段（47.1）；具名执行体路由=executor+工序模板 SOP+生成技能，general-purpose 默认兜底禁止、例外登记理由（47.2）；批量生成试点先行联动 Rule 18.9 硬门（47.3）；零新 config 键+selftest-media-dispatch.sh 守护（47.4）
```
3. **references 表 critical-rules 行**（:305）行尾行内追加（零增行）：
`…Rule 46 子代理单任务专注度 / Rule 47 媒体制作任务派发纪律）`

**执行前防呆**：先 `grep -rn "1-4\\[5-9\\]" scripts/selftest-*.sh` 复扫锚（v121 预扩位），确认追加 Rule 47 名不触发级联；wc -l 复核 ≤558。

## mapping 联动草案（S3 材料包——两处纯增量）

1. **§九矩阵后**（:291「新增任务类型时…」行与 ：292-297 内容组不适用注之后）追加兜底注 1 行：
```markdown
> 媒体族执行体兜底路由（task-v122 Rule 47.2）：路由组列引用的项目专属资产（tools/gen.py·qc.py / script-writer / videop1 SOP 等）在当前环境缺位时，通用兜底路由 = executor(sonnet-1) + 对应工序 variant 模板 SOP + 生成技能（如 agnes-ai-generation-skill，派发 prompt 点名）；质检工序 = QC/审查类子代理；禁止 general-purpose 无登记默认兜底。
```
2. **§十表**（:306 内容组行之后）追加特化行 1 行：
```markdown
| 媒体制作族（video/video-fix/image+工序 11 类，自内容组行特化拆出 — task-v122 Rule 47.2） | executor(sonnet-1) + 工序 variant 模板 SOP + 生成技能；QC=审查类子代理 | 子代理+生成技能；机械 QC/机检脚本为验证面 | 同参批量单元可声明组并行；跨工序阶段链（母图/分镜/剧本依赖）强串行 |
```
（既有内容组行与 §九 30 行矩阵零改动——Rule 36.4 纯增量免确认）

## selftest 断言清单（S4 材料包——selftest-media-dispatch.sh，范式对齐 selftest-reliability-institution.sh）

| ID | 断言 | 目标 |
|----|------|------|
| MD-01 | `grep -c '^47\.'` ≥ 4 | critical-rules.md 四子条在位 |
| MD-02 | `grep -q '^### 47 '` | 标题锚 |
| MD-03 | grep '媒体生成工序' ≥1 | SKILL 路由表行 1 |
| MD-04 | grep '剧集创作管线' ≥1 | SKILL 路由表行 2 |
| MD-05 | grep 'Rule 47（媒体制作任务派发纪律' ≥1 | SKILL 摘要 bullet |
| MD-06 | grep 'Rule 47.2' ≥1（template-mapping.md） | §九兜底注 |
| MD-07 | grep '媒体制作族' ≥1（template-mapping.md） | §十特化行 |
| MD-08 | 零新键：config.json properties 计数 == 40（写法对齐 selftest-reliability-institution.sh 零新键断言；jq 缺失 fail-open 按 该脚本先例） | 零新 config 键 |
| MD-09 | 既有锚守护：critical-rules.md '^21.1b' 在位 + SKILL.md grep '代码编辑（单文件' ≥1（路由表既有行未删） | 纯增量不破坏 |

输出范式：`PASS/FAIL` 逐行 + 末行 Total；FAIL>0 → exit 1。脚本头注释四要素（Rule 45.3：用途/输入/输出/依赖）。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 候选 A：executor+工序模板 SOP+生成技能兜底路由（推荐，默认项） | 零 agent 生态成本闭合两抱怨；生成资产本属项目侧；候选 B 新建媒体 agent 族=范围扩张数倍，且 media 执行体价值在 SOP/模板而非 agent 壳 |
| 纯增量策略（§十特化行不改既有行） | Rule 36.4 语义改写需逐项确认；纯增量可回滚免确认 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| session-catchup.ts 在仓根不存在（memory 陷阱再证实：实为技能目录内脚本） | 用部署位 ~/.zcode/skills/task-planner/scripts/ 入口，登记 memory 既有 stale 标记维持 |

## Resources
- 画像矩阵权威源：skills/plan-template-kit/references/template-mapping.md:254-312
- 规则尾部范式：skills/task-planner/references/critical-rules.md:440-483
- v121 预扩锚先例：git show 53936ec（RT-08/PT-08/CD-12 → 1-4[5-9]）
- 部署脚本：skills/task-planner/scripts/smart-merge-back.sh

## Visual/Browser Findings
-（无多模态输入）
