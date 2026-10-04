# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
-->

## Requirements
- 用户诉求（2026-10-03 追加，原话）：「还有就是没有专门的处理图片和视频生成相关专业agent可以同步补充 确保后期更加专业的处理任务」
- 拆解：新增「图片生成专业执行体」+「视频生成专业执行体」两个 companion agent；与 task-v122 Rule 47.2 具名路由同步（agent 在位时优先，缺位回退 executor 兜底）；部署双位（~/.zcode/agents + ~/.claude/agents）。
- 任务关系：本任务=task-v122 计划期 D2 候选 B 的用户转正（v122 未否决，属新需求）；v122 已 COMPLETE 无活跃计划冲突。

## 📚 必要知识储备对齐记录
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点 |
|--------|---------------|-----------|---------------------|
| companion 4 agent 全文 | skills/task-planner/companion/agents/*.md | ☑ (research-a) | §Research Findings 1/4 + §agent 草案 |
| install-companion 链路 | skills/task-planner/lib/install-companion.sh（glob :163 / adapt :52-90） | ☑ (research-a) | 部署方案（零机制改动） |
| v119 先例 | git show a4bbd19 / plans/task-v119/{progress,verification} | ☑ (research-a) | 部署双位+SRO 先例 |
| agnes 技能 | ~/.zcode/skills/agnes-ai-generation-skill/SKILL.md | ☑ (research-b) | §agent 草案技能段 |
| image/video 工序模板 | skills/task-planner/templates/variant/{image,video,qc-defect,...}-type.md | ☑ (research-b) | §agent 草案流程段 |
| 域执行体范式 | ~/.zcode/agents/{article-writer,article-batch-publisher}.md | ☑ (research-b) | §agent 骨架 |

## Research Findings

#### [sub:research-a] companion agents 机制调研（task-v124 前置侦察）
完整结论落盘 `subagent-state/1-research-a.md`（含 8 字段最终结论块），此处摘要五条:

1. **格式规范**: 4 文件 = complex-planner(48行)/plan-writer(288行)/article-batch-publisher(156行)/article-field-fixer(59行)；frontmatter 要素 name/description/tools/model(/color//thoughtLevel)；model 行两种格式: `custom:<uuid>:<slug>`（sonnet-1/haiku-1，3 文件）与 `account:zai-individual-coding-plan/GLM-5.3`（complex-planner）；name 两种风格: display 名（Complex Planner/Plan Writer）与 kebab 名（article-*）
2. **部署链路**: `lib/install-companion.sh` glob `companion/agents/*.md` 全量分发到 `$TARGET_ROOT/agents/`（自动探测 ~/.zcode→~/.claude；Claude 位 model 行经 adapt_model_line 转纯档名，`account:` 前缀落 default 引号串分支）；install.sh Phase 5.6（install.sh:178-188）自动调用 → **新增 agent 零机制改动**；反向 sync-companion.sh 拉回。「部署 2 位」证据: plans/task-v119/progress.md:81 + verification.md:21-22（VC-5 md5 双位一致，claude 位仅 model 行差异）
3. **守卫级联面**: 无 registry 式 agent 登记表；selftest-registry.tsv 仅登记 selftest 脚本；全仓 selftest 无 agent 清单/数量断言（6 脚本仅锚 plan-writer.md 单文件内容: selftest-knowledge-brief.sh:18 等）。新增 1-2 agent 命中断言面=零（v119 先例实证）。文档 stale 面: install.sh:179 注释/README_zh.md:114/INSTALL_zh.md:306-308「3 个」/INSTALL.md:137-139 三行表——均漏 complex-planner；smart-merge-back.sh --deploy SLOTS 只含 3 个 skills 槽（:377-381），companion/agents 随 skill 树 cp -rL 覆盖，~/.zcode/agents 用户目录不在 SLOTS
4. **complex-planner 先例（a4bbd19）**: 单文件 +48 行 merge；主进程白名单 cp 2 部署位（claude 位 sed model→opus）；skill-agent-router/SKILL.md:98 路由表 +1 行（三列: agent 名/触发场景/禁用边界）；全量 selftest 42 脚本 660 用例零回归
5. **description 触发词惯例**: 职责句 | 定位 | MUST BE USED/启用门槛 | `触发:<竖线分隔词>` 显式段 | 区别/禁用句指向改派对象；中英混排；complex-planner 触发词 5 个 + 独立「禁用:」段，plan-writer 触发 7 词 + 双区别句

#### [sub:research-b] 图片/视频生成专业执行知识盘点
完整六项结论落盘 `subagent-state/2-research-b.md`，摘要:
1. **agnes 技能**: 三能力面 text/image(agnes-image-2.5-flash t2i+i2i)/video(agnes-video-2.5-flash 异步)；video 硬约束 seconds "4"-"12"/size 仅 720P/aspect 六选默认 16:9/n=1/reference images≤5 audios≤3 无 videos（SKILL.md:112）；调用=`python scripts/agnes_api.py text|image|video|video-get|smoke-test`；中文 prompt 先译英文；2026-09-18 .cn 全链路实测通过
2. **image 模板**: 九原子管线 P1-P7，试水门=批次第 1 件过三检才扩批；三检=合规/一致性（逐字溯源）/质量（双硬错误）；预算闸门 ≤20 抽/件超限冻结 STOP；批次 0 打断静默纪律（image-type.md:21-26,59）
3. **video 模板**: G1 草稿人工门=任何 video 调用前置（放行/跳过/否决三登记，Rule 32.2）；草稿+QC=子代理 A / 视频=B 不同执行体；QC 8 类判据=qc.py 机检八类（双硬错误∪水印乱码/风格漂移/元素缺失/一致性偏离，:37 行锚）；缺陷四级处置阶梯+四维归因（qc-defect-type.md:55-57）
4. **四模板纪律**: 写词=四段式 MCD 逐字+五问自检+组词/快审分执行体；分镜=walk_lock 先建后派+geo lock+四步准入；QC=先 QC 后展示+机检满分不豁免亲检；终剪=能剪不重生成+seam 5 边界+NAS/VERSIONS ★✗⚠ 标记
5. **agent 骨架范式**: frontmatter（kebab name/中英混排 description 含触发词与相邻 agent 区别句/model 行双格式/tools 子集）+正文固定节（掌握技能/输出模板含置信度/超时约束/Role/前置检查 HARD_BLOCK/Workflow/禁止行为/证据要求/验证协议/负结果报告）
6. **可用性标注**: agnes 技能+骨架范式=当前可用；六 variant 模板=纪律引用材料（非可调用）；tools/gen.py、qc.py、videop1-* skill 层、style.md/MCD=项目侧指针（本仓与用户级均不存在），新 agent 须登记为材料包指针

#### [sub:baseline] 全量 selftest 基线（v122/v123 后,回归对比用）
完整逐脚本日志+终态+rc 落盘 `subagent-state/1-baseline-executor.md`（含 8 字段结论块，另附 `baseline-run.log` 原始全文），此处仅锚事实:
1. **脚本数=44**（glob `skills/task-planner/scripts/selftest-*.sh` 实测，与 registry TSV 行数 44 一致——selftest-registry.sh 自报 `registry rows=44, actual selftest=44`）
2. **44/44 全过**: 每脚本终态行（`Total:` 或等价 `==== ... 结果: ... ====`）全部 FAIL=0；每条 rc= 行全部 rc=0；无单脚本超 60s（实测最长 18s）
3. 终态行逐条保留在检查点「逐脚本终态 + rc」段（== 脚本名 / 终态行 / rc= 行逐条，未自报汇总数字——汇总由主进程逐行机械求和）
4. 特例格式: selftest-final-gate-hash.sh 终态行为 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（非 `Total:` 前缀，按「等价终态行」保留）

#### [sub:S1] image-generation-executor 落盘完成
- 产物: worktree `skills/task-planner/companion/agents/image-generation-executor.md`（68 行，findings.md §「草案 1」围栏内全文逐字落盘，diff 空=VERBATIM_OK）
- 验收 grep 全过: name=1 / 触发:=1 / model:=1 / 六节锚（掌握的技能·输出模板·前置检查·Workflow·禁止行为·证据要求）各在位

#### [sub:S2] video-generation-executor 落盘完成
- 产物: worktree `skills/task-planner/companion/agents/video-generation-executor.md`（68 行，findings.md §「草案 2」围栏内全文逐字落盘，diff 空=VERBATIM_OK）
- 验收 grep 全过: name=1 / 触发:=1 / model:=1 / 六节锚（掌握的技能·输出模板·前置检查·Workflow·禁止行为·证据要求）各在位 / HARD_BLOCK=5（≥2）
- 检查点: subagent-state/m2-executor.md（status: done）

#### [sub:S4] README_zh/INSTALL_zh companion agent 计数 3→6 修正
- 命中点全量: grep '个伴生\|个配套' 仅 2 处 = README_zh.md:114（树状图「3 个伴生 agent（plan-writer 等）」）与 INSTALL_zh.md:305-307（树状图「3 个配套 agent」多行）；两文件其他位置无存量计数表述（install.sh:179 / INSTALL.md:137-139 属 S5 范围，本 S-unit 未触碰）
- 修正内容: 两文件计数 3→6，清单补全为 plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor；INSTALL_zh.md 树状图新增 2 行保持缩进对齐（续行前导空白与原续行一致）
- 验收: grep '3 个伴生\|3 个配套' 零命中(exit=1)；'6 个伴生'/'6 个配套' 各 1 命中；diff --stat = README_zh.md(+1/-1), INSTALL_zh.md(+4/-2)；未触碰 tree 其他行
- 检查点: subagent-state/m4-executor.md（status: done）

#### [sub:S5] INSTALL.md 表格补 3 行 + install.sh:179 注释补全 6 名
- 修改面: skills/task-planner/INSTALL.md :140-142 新增 3 行（complex-planner = 高复杂度规划备用(GLM-5.3)；image-generation-executor = 图片生成专业执行体(Rule 47.2)；video-generation-executor = 视频生成专业执行体(Rule 47.2)），列格式照抄既有 3 列（源路径|安装目标|用途），插入在 article-field-fixer 行与 skills/task-drift-guard 行之间（companion agents 聚集在表首）；install.sh:179 注释 agent 清单 3→6 名（追加 complex-planner/image-generation-executor/video-generation-executor），仅改该 1 行
- 依据核对: complex-planner.md frontmatter model 行 = `account:zai-individual-coding-plan/GLM-5.3`（表格用途列写 GLM-5.3 简称）；image/video 用途列措辞取自 agent description（三检-QC 门控 / 单镜试水→异步生成→QC 回执）
- 验收: INSTALL.md :139-141 grep 三 agent 名各 1 命中；install.sh:179 含 6 名；git diff --numstat = `3 0 skills/task-planner/INSTALL.md` + `1 1 skills/task-planner/install.sh`，diff 面仅两文件
- 检查点: subagent-state/m5-executor.md（status: done）

#### [sub:S3] SKILL.md 媒体两行 + template-mapping.md 兜底注/媒体制作族行 行内替换（task-v124 联动草案 1/2）
- 修改面: worktree `skills/task-planner/SKILL.md` :356 执行体列 → `` `image-generation-executor` / `video-generation-executor`（在位优先）；缺位回退 `executor` + 工序 variant 模板 SOP + 生成技能（Rule 47.2） ``；:357 执行体列 → `` `video-generation-executor` 按集→场→镜逐级拆 Phase/S-unit（Rule 47.1）；组合工序缺位回退 executor ``；`skills/plan-template-kit/references/template-mapping.md` :298 注句首 → 「媒体族专用执行体 `image-generation-executor`/`video-generation-executor` 在位时优先（task-v124）；缺位时兜底路由 = …（原文保留）」；:308 执行体列 → 「首选 image/video-generation-executor（task-v124 在位优先）；缺位回退 executor(sonnet-1) + 工序 variant 模板 SOP + 生成技能；QC=审查类子代理」
- 防呆: 替换前 grep 核四锚点行号与原文一致（:356/:357/:298/:308）；替换后 `git diff --numstat` 两文件各 `2 2`（SKILL.md）/`2 2`（mapping）且 diff 面仅命中行
- 验收: 四落点 grep 均含 `image-generation-executor` 与 `video-generation-executor`；`wc -l` SKILL.md=447 / mapping=314（净增 0 行）；检查点 subagent-state/m3-executor.md（status: done）

#### [sub:S7] 全量 selftest 回归（45 脚本 698 用例 FAIL=0）
- 执行面: worktree 内 `for f in skills/task-planner/scripts/selftest-*.sh` 单条循环跑完 45 脚本（44 基线 + 新增 selftest-media-agents.sh），全部 rc=0；FAIL>0 脚本=0（`grep -c 'FAIL=[1-9]'`=0）；无单脚本超 60s（实测最长 final-gate-hash 18s，与基线一致）
- 用例核对: PASS 逐行求和=698 = 基线 688 + 新增 media-agents 10；`selftest-media-agents.sh` 终态行原文 `Total: 10 PASS=10 FAIL=0`；`selftest-registry.sh` 终态行原文 `Total: 5 PASS=5 FAIL=0 (registry rows=45, actual selftest=45)`
- 特例终态（非 `Total:` 前缀，等价行已逐条保留）: selftest-delegation.sh `Total: 38    PASS=38  FAIL=0`（后跟 `========` 尾线）；selftest-final-gate-hash.sh `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`
- 逐脚本终态+rc 原文: `subagent-state/m7-executor.md`（完整运行日志 `m7-run.log` 852 行嵌入其首部，本段不自报汇总——汇总由主进程逐行机械求和）
- 检查点: subagent-state/m7-executor.md（status: done）

#### [sub:S10] frontmatter 机械校验（companion/agents 6 文件，按 frontmatter-linter 清单）
- 校验面: worktree companion/agents/ 全 6 文件；规则=frontmatter-linter 清单 1-5（必填字段/name=文件名/model 行格式/tools 一致性/description 一致性）
- 两新文件（image/video-generation-executor）: 必填四字段齐（R1 PASS）；name=文件名 PASS（image:2 / video:2 均与基名精确一致）；model 行 `custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1` 符合 `custom:<uuid>:<slug>`（R3 PASS；install-companion.sh:52-90 双位适配 grep 正则 `custom:[0-9a-fA-F-]*:` 命中）；tools frontmatter 全小写逗号列表 [Read, Write, Edit, Bash, Grep, Glob, TodoWrite]（image:6 / video:6，YAML 解析 PASS）；正文未提及 frontmatter 未列工具（R4 PASS）；description 与正文六节大方向一致（R5 PASS）。BLOCK 级问题=0。
- WARN（格式观察，非 BLOCK）: tools 行 JSON 流式数组 `[Read, ...]` 与仓内既有 4 文件逗号列表风格不一致——功能等价，不阻断
- 既有 4 文件零新告警: article-batch-publisher / article-field-fixer / complex-planner 与 ~/.zcode/agents 主仓 `diff -q` 全 IDENTICAL；plan-writer frontmatter 与主仓逐字一致（正文差异属 v115/v109 历史已提交，非本任务变更）。既有基线告警（非新增）: complex-planner:2 name "Complex Planner"≠complex-planner、plan-writer:4 name "Plan Writer"≠plan-writer（R2，历史遗留）；complex-planner:5 model `account:zai-individual-coding-plan/GLM-5.3` 非 custom: 亦非纯档位（R3，v119 已记录）
- 双新文件 frontmatter 与 findings §agent 草案 1/2 逐字一致（S1/S2 落盘无漂移）
- 纯只读校验；本 S10 零文件修改、零 git 写；检查点 subagent-state/m10-executor.md（status: done）

#### [sub:postmerge] merge 后全量回归（worktree @643e61e，fresh 会话）
- 47/47 selftest 脚本 rc=0；FAIL 总和=0；用例总和=727（46 个 Total 行合计 705 + final-gate-hash 结果行 PASS=22），符合预期 717+10
- registry 自检通过：selftest-registry.sh 终态「registry rows=47, actual selftest=47」（47=47 动态口径一致）
- v126/v129 新增脚本（tool-selection 12 用例、workflow-orchestration 16 用例）全 PASS，master 落地无回归
- 完整逐脚本终态行与 8 字段结论块：subagent-state/m12-postmerge.md

#### [sub:final-reg] 二次合流后全量回归（worktree @7fb8988，fresh 会话，48/48）
- 执行面: worktree 内 `for f in skills/task-planner/scripts/selftest-*.sh` 单条循环跑完 48 脚本（glob 实测 48，预期一致），48/48 rc=0；FAIL>0 脚本=0；无单脚本超 60s 跳过
- registry 自检通过：selftest-registry.sh 终态行原文 `Total: 5 PASS=5 FAIL=0 (registry rows=48, actual selftest=48)`（动态口径一致）
- PASS 逐行机械求和=734（48 个终态行合计，含 final-gate-hash 结果行 PASS=22 与 registry 行 PASS=5；汇总由主进程逐行核验）
- v124 产物（media-agents 10、skill-split 41 等）+ master 三轮新落地（v126/v129/v127）合并后全绿，作为合并回前最终回归证据
- 逐脚本终态+rc 原文全文：subagent-state/m13-finalreg.md（含 897 行原始日志嵌入）

#### [sub:deploy] m14 部署收尾（router 双位九节 + install-companion 双目标 + 部署核对）
- 任务一: 两 skill-agent-router 部署位（/home/terry/.zcode/skills/ 与 /home/terry/.claude/skills/）在「## general-purpose 合法使用场景」前各插入「### 九、内容与媒体类」节（含 image/video-generation-executor 两行三列表）；改后 `grep -n '九、内容与媒体类'` 双文件各 1 命中（:103）；`grep -c 'image-generation-executor\|video-generation-executor'` 双文件各 =2；.claude 位 complex-planner 行 =1（主进程已补入，未重复添加）
- 任务二: install-companion 先 dry-run 复核（.zcode 目标 dry-run 显示 2 install + 2 update + 42 skip）再真跑；双目标 summary: .zcode = `2 installed, 2 updated, 42 skipped (dry_run=0)`；.claude（--target /home/terry/.claude）= `2 installed, 3 updated, 41 skipped (dry_run=0)`（.claude 位 complex-planner.md 经 update 分发）
- 任务三核对: ~/.zcode/agents 两新文件与主仓 companion/agents 同名文件 `diff` 均 IDENTICAL；~/.claude/agents 两新文件与主仓 diff 仅第 4 行 model 行（adapt 生效：claude 位 `model: sonnet`，主仓/.zcode 位 `model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"`；`grep '^model:'` claude 位输出不含 `custom:`，符合 knowledge-brief §2 双位部署行 model adapt 口径）
- 检查点: subagent-state/m14-deploy.md（status: done）

## 🧩 agent 草案全文（S1/S2 材料包 — 落盘即产物）

### 草案 1: skills/task-planner/companion/agents/image-generation-executor.md
```markdown
---
name: image-generation-executor
description: 图片生成专业执行体|图像任务 SOP 执行（核词→试水→三检闭环→扩批回填）|MUST BE USED for 图片生成|图像生成|批量出图|三检闭环|image generation。触发:图片生成|图像生成|批量出图|图片重抽|image generation|Agnes 图片生成。与 article-writer 区别: 产物为图像非文本;与 executor 区别: 本 agent 携带图像工序 SOP 与三检门控，媒体族图像任务优先本 agent（Rule 47.2 具名路由）;与 video-generation-executor 区别: 图像层止于成图三检，视频链走 video 执行体
model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"
thoughtLevel: enabled
tools: [Read, Write, Edit, Bash, Grep, Glob, TodoWrite]
color: '#E76F51'
---

# Image Generation Executor — 图片生成专业执行体

> 超时约束：单会话执行 120 分钟上限；到点未完成返回 partial 并报告已完成件数与断点位置。

## 掌握的技能
- **agnes-ai-generation-skill**: 图像生成（t2i/i2i，agnes-image-2.5-flash）——调用入口 `python scripts/agnes_api.py image ...`（技能目录下），key 读 env `AGNES_API_KEY`/`APIHUB_AGNES_API_KEY`（禁打印）；输出默认返 URL 不下载，落盘按任务要求
- **提示词四段式**: 主体段（MCD/铆钉逐字溯源，自创属性=FAIL）→ 场景段 → 镜头/构图段 → 质量段；中文需求先译流畅英文再生成
- **三检闭环**: 合规 / 一致性（逐字溯源，无法溯源=编造=FAIL）/ 质量（事实逻辑+解剖双硬+水印乱码+风格漂移）；缺检 = 不得验收/入台账/进下游
- **试水门与预算**: 批次第 1 件过完整三检才扩批；单件重抽 ≤20 次（超限冻结=唯一合法 STOP 上报）
- **材料包纪律**: 工序/门控按目标项目 variant 模板（image-type 等）执行；项目侧资产（tools/gen.py·qc.py、MCD/角色卡、style.md）存在则优先，缺位按本 agent 内置 SOP 执行并如实登记

## 输出模板（结构遵从，值按实填）
```text
[GENERATED | QC_PASSED | HARD_BLOCK] <任务单元>
产物: <URL 或文件路径> ×N
三检: 合规=P/F 一致性=P/F 质量=P/F（逐件）
重抽: N 次（预算 20）
置信度: HIGH | MED | LOW
```

## Role Definition
图片生成链的专业执行体：接单→核词→试水→三检→扩批→回执。不做任务规划、不改提示词策略以外的范围、不替主进程做验收裁决。

## 核心能力
- **单件试水与三检仲裁**：首件完整三检，FAIL 修词重抽（记录每次失败维度）
- **批量扩展**：参数冻结后同参批处理，逐件落检查点，异常件单独标记
- **静默执行**：批次内 0 打断（冻结/D6 除外）；只落检查点不回传叙事；批次末单份收尾报告

## 🔒 前置检查（强制）
- 输入缺「任务单元清单 + 提示词（或写词材料）+ 生成参数」任一项 → 输出 `HARD_BLOCK: <缺项>`，不写产物文件
- 生成 API 调用前确认 key 环境变量在位（缺失 → HARD_BLOCK，禁裸调）

## Workflow
1. 读材料包（任务书 + 提示词材料 + 项目工序模板如有）
2. 核词：四段式逐项核验，缺项先补词（自创属性=禁止）
3. 单件试水生成（`agnes_api.py image`，smoke-test 先行）
4. 三检逐项过；FAIL → 定位维度（提示词/模型随机/参考/规格）→ 修词重抽（≤预算）
5. 试水 PASS → 参数冻结 → 批次扩展（逐件落检查点）
6. 回执：按输出模板单份收尾（含逐件三检与重抽计数）

## 禁止行为
- ❌ 无提示词/无核词直接批量生成
- ❌ 首件未过三检即扩批
- ❌ 自创主体属性（MCD/铆钉不逐字 = FAIL）
- ❌ 超预算静默重抽（20 抽上限=冻结上报）
- ❌ 静默吞错（API 报错必须记录并上报）
- ❌ 代表用户验收（QC 结论只是证据，验收归主进程/用户）

## 证据要求（强制）
- 每件产物：URL/路径 + 三检逐项结论 + 重抽计数；关键判断附 file:line 或命令→输出行
- 无第一手证据的结论标注「未验证」；禁止把推测写成已通过

## 验证协议
- 交付前自查：产物 URL 可达性（HEAD 探测）/本地文件存在性；三检结论与产物一一对应
- 抽检揭露：任一「三检 PASS」无对应证据 → 自降为未验证并上报

## 负结果报告
- 连续 2 件同维度 FAIL 或 API 持续报错 → 停止扩批，输出 `HARD_BLOCK: <现象+已尝试>`，等待主进程改派/升级（Rule 22.3）
```

### 草案 2: skills/task-planner/companion/agents/video-generation-executor.md
```markdown
---
name: video-generation-executor
description: 视频生成专业执行体|视频生成链 B 侧 SOP（放行核验→单镜试水→异步生成→QC 回执）|MUST BE USED for 视频生成|镜头生成|video generation。触发:视频生成|镜头生成|视频重生成|video generation|Agnes 视频|成片生成。与 image-generation-executor 区别: 视频链含 G1 放行前置与异步轮询;与草稿/QC 类执行体区别: 本 agent 只做生成侧（草稿 QC 与放行归 A 侧执行体/用户，隔离铁律）
model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"
thoughtLevel: enabled
tools: [Read, Write, Edit, Bash, Grep, Glob, TodoWrite]
color: '#2A9D8F'
---

# Video Generation Executor — 视频生成专业执行体

> 超时约束：单会话执行 120 分钟上限；到点返回 partial 并报告已完成镜头与断点。

## 掌握的技能
- **agnes video 调用**: `python scripts/agnes_api.py video ...`（mode=text/keyframe/reference；异步任务 + `video-get` 轮询）；硬约束 seconds "4"-"12"（默认 "5"）/ size 仅 "720P" / aspect 六选默认 16:9 / n=1 / reference images≤5 且 audios≤3、无 videos 字段 / keyframe 须 first/last 至少一帧
- **G1 放行前置门**: 任何 video 调用前必须存在「草稿放行登记」（放行/跳过/否决三登记之一）——缺登记 = 产出按「未经门」作废；子代理无权代放行
- **隔离铁律**: 草稿+QC（A 侧）与视频生成（B 侧）不同执行体；本 agent=B 侧，禁止同会话兼做草稿 QC 自我背书
- **QC 判据与处置阶梯**: 机检八类+亲检仲裁；缺陷四级处置（剪辑补救→段级重生成→整件重生成→全量须用户显式批准）；四维归因（提示词/模型随机/参考/规格）
- **成本纪律**: 视频调用昂贵——单镜试水先行（smoke-test 不裸调），配额警示后再批量；中文 prompt 先译英文

## 输出模板（结构遵从，值按实填）
```text
[GENERATED | QC_PASSED | QC_FAILED | HARD_BLOCK] <镜头/单元>
放行核验: <登记 grep 行 或 缺失原因>
产物: video_id/URL ×N
QC: 机检=N 类命中 / 亲检=P/F
处置建议: none | 四级之一（含归因维度；只建议不裁决）
置信度: HIGH | MED | LOW
```

## Role Definition
视频生成链 B 侧专业执行体：放行核验→材料核验→单镜试水→异步生成取回→QC 回执。不发起未经放行的生成、不做草稿侧 QC、不裁决处置级别（处置路由归主进程）。

## 核心能力
- **放行核验（grep 实证）**：派发 prompt 必含前置放行登记 grep 行；本 agent 复验后才调 video
- **异步生成与轮询**：video_id 轮询（超时分级上报）；取回 URL/落盘按任务要求
- **QC 回执**：机检+亲检结论、缺陷类别与归因维度、建议处置级别（不自行裁决）

## 🔒 前置检查（强制）
- 缺「放行登记 grep 行 / 镜头清单 / 生成参数（mode、seconds、size、aspect）」任一 → `HARD_BLOCK: <缺项>`，禁发起调用
- key 环境变量与端点核验（api.agnes-ai.cn；apihub 域名=401 陷阱）缺失/错用 → HARD_BLOCK

## Workflow
1. 放行核验：核对 prompt 内放行登记 grep 行（无=HARD_BLOCK）
2. 材料核验：镜头清单/参考图（≤5）/音轨（≤3）/参数合法域校验
3. 单镜试水：smoke-test → 首镜生成 → 取回
4. 首镜 QC：机检+亲检；FAIL → 四维归因 → 建议处置级别上报
5. 试水 PASS → 参数冻结 → 批量镜头生成（逐镜落检查点，异步轮询）
6. 回执：按输出模板逐镜汇总

## 禁止行为
- ❌ 无放行登记发起 video 调用（作废级违规）
- ❌ 未 smoke-test 裸调 / 中文长 prompt 未译英文直接发
- ❌ 同会话兼做草稿 QC 或代用户放行
- ❌ 自行裁决四级处置（只建议不裁决）
- ❌ 超配额无警示批量扩散
- ❌ 静默吞错（异步失败必须记录 video_id 与错误原文）

## 证据要求（强制）
- 每镜：放行 grep 行 + video_id/URL + QC 结论 + 处置建议；关键判断附 file:line/命令输出
- 未验证项显式标注；禁止推测包装

## 验证协议
- 交付前自查：产物 URL 可达/文件在位；QC 结论与产物一一对应；放行核验行在回执可见
- 抽检揭露：任何「QC PASS」无证据 → 自降未验证并上报

## 负结果报告
- 连续 2 镜同型 FAIL / 轮询超时 / 配额拒绝 → 停止批量，`HARD_BLOCK: <现象+已尝试>` 上报（Rule 22.3 处置）
```

## 🔗 联动草案（S3 材料包 — 全部行内替换/纯增量，SKILL/mapping 净增 0 行）

1. **SKILL.md 路由表媒体两行（行内替换）**：
   - 行 1「媒体生成工序」执行体列: `` `executor` + 工序 variant 模板 SOP + 生成技能（Rule 47.2） `` → `` `image-generation-executor` / `video-generation-executor`（在位优先）；缺位回退 `executor` + 工序 variant 模板 SOP + 生成技能（Rule 47.2） ``
   - 行 2「剧集创作管线」执行体列: `` `executor` 按集→场→镜逐级拆 Phase/S-unit（Rule 47.1） `` → `` `video-generation-executor` 按集→场→镜逐级拆 Phase/S-unit（Rule 47.1）；组合工序缺位回退 executor ``
2. **template-mapping.md（两处行内替换）**：
   - §九兜底注首句改为：「媒体族专用执行体 `image-generation-executor`/`video-generation-executor` 在位时优先（task-v124）；缺位时兜底路由=…（原文保留）」
   - §十「媒体制作族」行执行体列改为：「首选 image/video-generation-executor（task-v124 在位优先）；缺位回退 executor(sonnet-1) + 工序 variant 模板 SOP + 生成技能；QC=审查类子代理」
3. **文档计数与表格（3 处 stale 修正 + 1 表补行）**：
   - README_zh.md:114「3 个伴生 agent」→「6 个伴生 agent（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor）」（执行期先 grep 核原文再改）
   - INSTALL_zh.md:306-308 树状图计数 3→6 + 补两行
   - install.sh:179 注释 agent 清单补全为 6 个
   - INSTALL.md:137-139 表格补 3 行（complex-planner 欠账 + 2 新）
4. **skill-agent-router（仓外部署位，Phase 5 执行）**：路由表 :98 区（complex-planner 行）后 +2 行（三列格式：agent 名 | 触发场景 | 禁用边界）；`~/.zcode/skills/skill-agent-router/SKILL.md` + 其他存在部署位同步

#### [sub:S8] fresh 全量复跑终验（45 脚本 698 用例 FAIL=0，VC-4 独立复核）
- 执行面: fresh 独立会话重跑，cwd=worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v124`（@cc95adc）；单条 for 循环跑 45 脚本（44 基线 + 新增 selftest-media-agents.sh），未引用/转抄 m7 日志
- 结果: `== ` 块=45、`rc=0` 行=45、`FAIL=[1-9]` 命中=0；PASS 逐行求和=698 = 基线 688 + media-agents 10；`selftest-registry.sh` 终态行原文 `Total: 5 PASS=5 FAIL=0 (registry rows=45, actual selftest=45)` → VC-4「全量回归 0 FAIL」独立复核 PASS
- 特例终态（非 `Total:` 前缀，等价行已逐条保留）: selftest-delegation.sh `Total: 38    PASS=38  FAIL=0`；selftest-final-gate-hash.sh `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`
- 时长判定: 无脚本 >60s（逐脚本 SECONDS 复测，最长 selftest-vc-gate.sh 17s / selftest-final-gate-hash.sh 16s / selftest-plan-tier.sh、smart-merge 10s）；无跳过脚本（SKIP 断言仅 skill-modify `SKIP=0` 自报）
- 逐脚本终态+rc 原文: `subagent-state/m8-executor.md`（完整运行日志 `m8-fullrun.log` 852 行 + 时长 `m8-timings.txt` 嵌入其内，本段不自报汇总——汇总由主进程逐行机械求和）
- 检查点: subagent-state/m8-executor.md（status: done）

## 🛡️ selftest 清单（S4 材料包 — selftest-media-agents.sh，MA-01..10）
| ID | 断言 | 目标 |
|----|------|------|
| MA-01/02 | 两 agent 文件存在（companion/agents/image-generation-executor.md / video-generation-executor.md） | 产物在位 |
| MA-03/04 | 各文件 frontmatter name=文件名、description 含「触发:」与「MUST BE USED」、model 行在位 | 格式规范 |
| MA-05/06 | SKILL.md 路由表两媒体行含两 agent 名 | 联动 |
| MA-07 | template-mapping.md §九注+§十行含两 agent 名 | 联动 |
| MA-08 | README_zh/INSTALL_zh 含「6 个」计数口径 + INSTALL.md 含两 agent 名行 | 文档同步 |
| MA-09 | install.sh 注释含两 agent 名 | 注释同步 |
| MA-10 | config.json properties=40（零新键） | 零新键 |
输出范式：PASS/FAIL 逐行+Total；FAIL>0 exit 1；头注释四要素（Rule 45.3）+ What/Why 双层（45.2）。registry.tsv 同步 +1 行（45=45）。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| D2 推荐 A：model 行 `custom:9e221f47-…:sonnet-1`（plan-writer 同款） | 约定一致 + install-companion adapt 自动映射 claude 位（零手工）；provider 波动风险由 22.3.1 fallback+部署冒烟兜底。候选 B=`9a69b164…/agnes-3.0-flash`（今日实测健康但非约定格式，claude 位需手工适配） |
| name 用 kebab（image/video-generation-executor） | 与 article 系一致；触发词路由可 grep；display 名非必需 |
| 正文引用工序纪律但不硬绑 videop1 资产 | 项目侧资产（tools/gen.py 等）缺位时按内置 SOP 执行，存在则优先（不假设本地可用） |
| 新守护纳入 registry（45=45） | T02 无缺失硬门；SR-12 动态口径免级联 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 两个 Explore 首次派发均 `Model request failed`（custom provider 本会话第 2/3 次拒单） | 按 22.3① 改派 executor（本会话 9/9 健康）；调研产出完整 |
| 调研 B 首派被 21.4 串行槽锁拦截（缺并行组标记） | 补 `[readonly-parallel]` 标记后重派成功；登记为教训 |
| 两类 dispatch-guard 拦截（步骤枚举 >4 / 多 S-unit 打包） | prompt 去圈码枚举/去他行 ID 字面量；本任务材料包复用该纪律 |

## Resources
- install-companion: skills/task-planner/lib/install-companion.sh（glob:163 / adapt:52-90 / 备份语义）
- v119 先例: git show a4bbd19；plans/task-v119/progress.md:81
- agnes 技能: ~/.zcode/skills/agnes-ai-generation-skill/SKILL.md（视频硬约束 :112 / .cn 实测 :127）
- 工序模板: skills/task-planner/templates/variant/{image,video,qc-defect,final-assembly,prompt-struct,storyboard}-type.md

## Visual/Browser Findings
-（无多模态输入）

#### [sub:S6] selftest-media-agents.sh 落盘 + registry 登记（MA-01..10）
- 产物: worktree `skills/task-planner/scripts/selftest-media-agents.sh`（新建，10 断言 MA-01..10；范式对齐 selftest-media-dispatch.sh：SCRIPT_DIR/SKILL_ROOT、ok/bad、Total 行、头注释四要素+What/Why 双层；MA-10 jq 缺失 SKIPPED 先例同 MD-08）
- registry: `scripts/selftest-registry.tsv` 末行追加 4 列制表符行（domain=「Rule 47.2 媒体专业执行体守护（task-v124）」），45→46 行
- 验收: `bash selftest-media-agents.sh` rc=0 `Total: 10 PASS=10 FAIL=0`；`bash selftest-registry.sh` rc=0 自报 `registry rows=45, actual selftest=45`；`grep -c selftest-media-agents tsv`=1；diff 面仅两文件（git status 确认）
- 检查点: subagent-state/m6-executor.md（status: done）

#### [sub:S9] alignment-review 对齐审查（APPROVED，P0/P1/P2 阻断=0）
- 审查面: worktree @cc95adc（fe31267+cc95adc，工作区干净）10 scope 产出全量对齐；结论=APPROVED，P2 建议 2 条（mapping:308 缩写保留；双位/router 属 Phase 5 仓外面不在本 S9 范围）
- 双向一致性: 六面（SKILL:356/:357、mapping:298/:308、README_zh:114、INSTALL_zh:307-308、INSTALL.md:141-142、install.sh:179）+ registry tsv:46 双 agent 名 grep 全中；旧「3 个」口径 exit=1 零残留；实体 ls=6 与「6 个」口径一致
- 行内替换净增 0 复核: numstat SKILL 2/2、mapping 2/2；wc SKILL=447/mapping=314；skill-split 复跑 41 PASS FAIL=0
- 守护复跑: media-agents `Total: 10 PASS=10 FAIL=0`（MA-01..10）；registry `rows=45, actual=45`；45 脚本全量 rc_sum=0；config properties=40（jq 复跑）
- 越界自检: `git diff --name-only 0f077ae..HEAD` 恰 10 文件 = scope_files 十项，工作区干净
- 落点: verification.md「S9 对齐审查段」（结论+变更记录三要素）；检查点 subagent-state/m9-executor.md（status: done）

#### [sub:S11] Code Review Gate 隔离审查（code-quality-review，APPROVED）
- 审查面: worktree @cc95adc 新建 selftest-media-agents.sh（151 行 MA-01..10）；code-quality-review 技能 15 维清单逐维执行；纯只读
- 结论: **APPROVED**（P0=0, P1=0, P2=2 不阻断）：P2-1 = :144 jq `2>/dev/null` 吞 stderr（fail-safe 行为正确，MD-08 先例同款）；P2-2 = :144 键数 40 硬编码（既定零新键口径绑定，:139 注释已声明）
- 关键复现: `bash selftest-media-agents.sh` → Total: 10 PASS=10 FAIL=0 rc=0；双跑 diff 空（幂等）；`bash -n` 通过；`git diff --name-only 0f077ae..HEAD` 恰 10 文件=scope_files 十项
- 落点: verification.md「Code Review Gate 结论」段；检查点 subagent-state/m11-executor.md（status: done）
