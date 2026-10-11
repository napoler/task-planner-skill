# [sub:research-b] 图片/视频生成专业执行知识盘点（task-v124 输入）

- 执行体: research-b（只读并行预置组，本会话仅领本行）
- 执行时间: 2026-10-03
- 范围: §2 九文件全部读取完成；纯只读 + 本检查点 + findings.md 追加
- 目的: 为 task-v124 新增「图片生成执行体」「视频生成执行体」两个 agent 提供可直接套用材料

## 六项结论（每项含锚点）

### 1. agnes 技能能力与调用方式（锚: /home/terry/.zcode/skills/agnes-ai-generation-skill/SKILL.md）
- 能力面: text（chat/completions+streaming；tool-calling 仅请求形兼容 best-effort，SKILL.md:110）；image（t2i/i2i，agnes-image-2.5-flash，高密度靠 prompt 携带主体层级/光线/构图/质量要求，:111）；video（agnes-video-2.5-flash，mode=text/keyframe/reference，异步任务+轮询 video_id，:112/:114）
- 视频硬约束: seconds 字符串 "4"-"12"（默认 "5"）；size 仅 "720P"；aspect_ratio 默认 16:9（六选）；n=1；reference 模式 images≤5 且 audios≤3，无 videos 字段（400），keyframe 须 first/last 至少一帧（:112）
- 调用方式: `python scripts/agnes_api.py text|image|video|video-get|smoke-test`（:36-105，逐命令示例在文）；key 读 AGNES_API_KEY/AGNES_API_TOKEN/APIHUB_AGNES_API_KEY，禁打印（:15）；端点 https://api.agnes-ai.cn，apihub. 域名=401 陷阱（:9/:20-29）
- 关键纪律: 中文 prompt 先译流畅英文再生成（:113）；视频昂贵须先警示配额（:116）；逐 case 用 smoke-test 不裸调（:117）；输出默认返 URL 不下载（:131）
- 可用性证据: 2026-09-18 国内 .cn 全链路 text/image/video 实测通过（:127）；keyframe/multi-image 未复验（:125）

### 2. image 工序链+门控（锚: skills/task-planner/templates/variant/image-type.md）
- 九原子管线 P1-P7: 剧本规划→合规/物理预检→多状态定义→提示词结构化→生成（试水件）→三检+静默重抽闭环（回 P4/P5）→终验（:4, :29-79）
- 三任务分型 A资产/B镜头图/C修正重抽: 只调 P1-P3 深度，P4-P7 管线恒定（:11-16）
- 门控: 试水门=批次第 1 件过完整三检才扩批，FAIL=修词重抽至 PASS 禁扩批（:6, :59-61）；预算闸门 tools/gen.py budget{piece_id,limit} ≤20 抽/件跨版本累计，超限 exit 3 冻结=唯一合法 STOP 打断（:24, :85）
- 三检=合规/一致性（逐字溯源，无法溯源=编造=FAIL）/质量（事实逻辑+解剖双硬+水印乱码+风格漂移），缺检=不得验收/入台账/进下游（VC-1, :21）
- 静默纪律: 批次 0 打断（冻结与 D6 除外）；子代理只落检查点不回传叙事；批次末单份收尾报告（:5, :81-85）；生成与重抽分属子代理 A/B，主进程 Read 亲检=验收前置（:72, :82）

### 3. video 工序链+QC 8 类（锚: video-type.md + qc-defect-type.md）
- 三任务分型 A整集/B资产/C修正，G1 人工门=任何 video 调用前置门: 草稿 tmp/ 呈示+用户定稿放行，放行/跳过/否决三登记，无登记=产出按「未经门」作废（:5, :35, :59-65）；Rule 32.2 无第一人工确认禁发起 video
- A 型链: P1 基线核验（N1-N7 铆钉，缺锚=STOP 转 B 型补资产）→P2 草稿+机器 QC（子代理 A，任务内禁 video）→P3 G1 门（STOP 等用户，子代理无权代放行）→P4 视频生成（子代理 B，reference 混交 4-5 张）→P5 成片 QC+台账（:22, :45-78）
- 隔离铁律: ③草稿+QC=A 与 ⑥视频=B 不同子代理，同任务自动衔接=违规；B 派发 prompt 必含前置放行登记 grep 行（:81-85）
- QC 8 类判据: tools/qc.py 机检「八类判据」（qc-defect:37，≤4 图/批拆批）；类别面=事实/逻辑/解剖双硬+水印/乱码/风格漂移（image VC-1:21）∪元素缺失/一致性偏离（qc-defect VC-3:23）——8 类为该并集推断（MEDIUM 置信）；成片侧走 video-qc 四趟协议×五层判据（qc-defect:74）
- 缺陷处置四级阶梯: 剪辑补救（0 生成）/片内段级重生成/整件重生成/全量=用户显式批准登记；四维归因=提示词缺陷/模型随机/参考带入/规格缺陷，同型≥2=模板级固化（qc-defect:49, :55-57）

### 4. 写词/分镜/QC/终剪四模板关键纪律
- prompt-struct（写词，prompt-struct-type.md:28-63）: 五相=铆钉取材→四段式组装（主体段 MCD 逐字，自创属性=FAIL）→子句族选配→五问自检+review-prompt 快审（D10 逐字一致/可见性二选一）→存档登记；组词与快审不同执行体防自我背书；全程 0 生成 0 额度；同型 FAIL≥2=子句固化进模板件
- storyboard（分镜，storyboard-type.md:30-63）: 走位清单 walk_lock 先建后派（缺=STOP）；geo lock 俯视底图无现役=STOP；批次第 1 格=试水件过 P4 才扩批；关键帧九宫格四步准入（机判→亲检→择优→送审）；页级人工门 [gate-skip] 须用户原话逐字双登记
- qc-defect（QC，qc-defect-type.md:30-69）: 六相=拆批（≤4 图/批，sheet 锚不离批）→机检→主进程亲检（机判=参考项；「机检满分不豁免亲检」判例）→四维归因→最小范围处置路由（子代理无权裁决处置级）→复检闭环+判例入 docs/experience/；先 QC 后展示
- final-assembly（终剪，final-assembly-type.md:30-64）: 六相=段片清点对账（缺段=STOP 回生产域）→剪辑组装（tools/edit cut/concat/xfade；「能剪不重生成」0 生成路径优先）→seam QC（5 边界+否定式措辞，FAIL 回剪环静默）→成片判定（video-qc 四趟达级）→NAS 三目录备份+VERSIONS.md ★✗⚠ 全标记→终审人工门

### 5. 域执行体 agent 骨架模板（锚: /home/terry/.zcode/agents/article-writer.md, article-batch-publisher.md）
```markdown
---
name: <kebab-domain-executor>
description: "<职责句: 输入→输出>|MUST BE USED for <Phase 场景>|<英文触发词>|<中文触发词>。与<相邻 agent>区别: <职责边界+改派指向>"
color: <色>; model: "custom:<uuid>:<slug>"（或 account: 前缀格式）; thoughtLevel: high
tools: [Read, Write, Edit, Bash, Grep, Glob, TodoWrite]（按任务面取子集）
---
```
正文固定节（顺序=article-writer 范式，≤15 行框架）:
1. `## 掌握的技能`（3-5 条「名: 一句话」）
2. `## 输出模板`（**[状态枚举如 GENERATED/QC_PASSED/INFO]** + 关键字段 + 置信度 HIGH/MED/LOW）
3. 超时约束引用块（120 分钟，到点返 partial）
4. `## Role Definition` + `## 核心能力`（加粗能力名 bullets）
5. `## 🔒 前置检查（强制）`（输入缺=「HARD_BLOCK: [原因]」不写文件）
6. `## Workflow`（编号步）+ `## 禁止行为`（❌ 清单）
7. `## 证据要求（强制）`（file:line+原文≥10 字符+置信度）/ `## 验证协议` / `## 负结果报告`
部署面: task-planner 仓 companion/agents/*.md → lib/install-companion.sh 自动分发双位（findings research-a 第 2 条，零机制改动）

### 6. 能力可用性标注
- ✅ 当前环境可用: agnes-ai-generation-skill（~/.zcode/skills，frontmatter model: sonnet；scripts/agnes_api.py 直接可跑，key 走 env AGNES_API_KEY；2026-09-18 全链路 .cn 实测 :127）
- ✅ 可套用骨架: article-writer/article-batch-publisher 两 agent（写法范式+部署链路 install-companion.sh）
- ⚠️ 项目侧引用（非可调用）: 六 variant 模板=计划工序/门控/纪律材料，新 agent 正文引用其纪律条文而非调用
- ⚠️ 项目侧引用（本仓/用户级均不存在）: tools/gen.py 预算账本、tools/qc.py 机检、videop1-* skill 层（review-image/video-qc/video-edit…）、style.md、MCD/角色卡——指针指向 videop1 项目仓，新 agent 应写入「必要知识储备」表为材料包指针，禁假设本地可用

## T5 最终结论（8 字段块）
status: done
acceptance: 6/6 pass — [agnes 能力与调用 ✅; image 工序链+门控 ✅; video 工序链+QC 8 类 ✅; 四模板关键纪律 ✅; 域执行体骨架 ✅; 可用性标注 ✅]
files: /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/2-research-b.md(+1); /mnt/data/dev/task-planner-skill/plans/task-v124/findings.md(+1 段)
evidence: SKILL.md:112(video 硬约束) / image-type.md:21(三检) / video-type.md:35(G1 门) / qc-defect-type.md:37(八类判据) / article-writer.md:1-15(frontmatter 范式)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/2-research-b.md (status: done)
findings_written: findings.md `#### [sub:research-b] 图片/视频生成执行知识盘点` 锚
blockers: none
confidence: HIGH（QC 8 类具体枚举为中置信并集推断，已标注）
