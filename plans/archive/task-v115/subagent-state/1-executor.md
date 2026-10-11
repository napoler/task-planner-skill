# Checkpoint — sub:1-executor（task-v115 Phase 1 回流级联面普查）
status: in_progress
agent: executor
started: 2026-10-02
scope: 只读普查 videop1 面（/home/terry/.zcode/skills）vs 主仓基底（/mnt/data/dev/task-planner-skill/skills），产出收编/合并/级联三清单

## 第一部分 收编清单（12 个 videop1 独有 variant 预检）

头部合规：12/12 全部合规——每个文件 `<!-- template_type: <X> -->` 在 :2、`<!-- plan_tier: standard -->` 在 :7，无缺失，收编时零头部修正。
知识锚合规：12/12 全含 `## 📚 必要知识储备` 章节（grep -L 空输出），收编后 knowledge-brief 锚 23→35。
plan_tier 缺省面：12/12 均显式声明 plan_tier: standard（grep -L "plan_tier" 空输出）。

逐文件行数+主题（videop1 面=/home/terry/.zcode/skills/task-planner/templates/variant/）：
- audio-voice-type.md 77 行 — 音频配音对齐（声线表/语言锁三层，零生成）
- character-design-type.md 85 行 — 角色设计+一致性锁定（定妆根图/multiview/角色卡含音色，G1 放行）
- final-assembly-type.md 83 行 — 终剪组装验证（段片组整集成片，seam 全过+NAS 备份+终审登记）
- image-type.md 100 行 — 图像生成任务（N 件×用途×分型，三检闭环+预算账本+静默自动完成）
- motion-camera-type.md 77 行 — 运动与运镜方案落词（运动卡/可行性核对/POV 纪律）
- multiview-ref-type.md 77 行 — 既有锚件补制 multiview/sheet/装备变体合版（全静默）
- physics-compliance-type.md 77 行 — 物理事实与交通合规判定（逐镜判定报告+修正路由）
- prompt-struct-type.md 78 行 — 结构化提示词卡产出（镜头词/资产词，四段齐+判定层快审）
- qc-defect-type.md 83 行 — 成图/成片质检与缺陷处置（逐件质检卡+FAIL 全路由+判例固化）
- script-dev-type.md 83 行 — 剧本工序 M0 大纲/M1 定稿本（原子六相+八红线自检）
- storyboard-type.md 77 行 — 分镜拆解（线稿定稿页+关键帧九宫格，逐格双硬 QC）
- video-prompt-type.md 77 行 — 镜头行转视频提示词与 spec（机械门全过+逐镜转换卡）

收编操作面：12 文件直接拷入 /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/，17→29。

## 第二部分 合并方案（3 分叉文件三方对照，主仓基底）

plan-writer.md：主仓与 videop1 **逐字节相同**（cmp 确认 IDENTICAL，各 276 行）——分叉不存在于当前文件态；唯一增量需求 = 映射表补 12 行（§任务模板库表 :53-67 现为 16 行=15 variant+general；补 12 行 → 29 行；表后 :70 行「门控契约（Rule 34.1）」段保持不动）。合并方案=零冲突直加 12 行。

template-guide.md（主仓 291 行 vs videop1 302 行），逐段判定：
- 收编段（videop1 增量）：§2.2 标题（:32 「17 个」→「29 个」+追加 planimage +image/videotpl +视频工序 11 类 注释）；§2.2 表 12 行新行（主仓 :52 memory-hygiene 行之后插入 videop1 的 image+11 类行，主仓 memory-hygiene 行保留）；§2.2 尾注（:64 「17 variant=25 模板/实际 25 个 .md」→「29 variant=37 模板/实际 37 个 .md」+ videop1 漂移注）；§2.4 标题（:66 「22/25」→「35/37」+「planimage +image，videotpl +11」注）；§2.4 统一标题锚计数（:70 「应为 22」→「应为 35」；例外清单 +delivery-summary 一项？见负结果）；§2.4 task_plan 系行（:71 「主模板+17 variant，含锚 16」→「主模板+29 variant，含锚 28」）；§三场景5 互斥表补 4 行（video vs image / video-image vs 工序11类 / script-dev vs video / qc-defect vs video-fix，主仓互斥表 :157-169 位置）；§九机制矩阵补 12 行+「不适用」15 行+括注（image+videotpl 11 类两条）。
- 保留段（主仓演进，videop1 版缺失或旧口径）：:45-46 deployment/performance-tuning 行「健康检查」「资源」补充（主仓 v108-v114 演进）；:71 含锚结构=16 vs videop1 写 15（取主仓 16 结构+改数）；:228 Rule 40.4 行「按 Rule 21.4 独立性守门调度（并行默认+声明组，未声明=串行，10-02）」（videop1 :239 为旧句「维持 Rule 21.4 串行」——取主仓）；§2.4「契约安全」行（主仓 :74 有，videop1 无——保留主仓）。
- 冲突点（同段两版都改）：① :32 §2.2 标题（主仓 17 vs videop1 28 旧计数 → 取结构并合成 29）；② :45-46 两行（主仓加字 vs videop1 删字 → 取主仓）；③ :64 尾注（两版漂移史分叉 → 主仓句+追加 videop1 两条增量注）；④ :228/:239 21.4 句（→取主仓）。

template-mapping.md（主仓 258 行 vs videop1 299 行），逐段判定：
- 收编段（videop1 增量）：§一 决策树补 12 行（image+视频工序 11 类，主仓 :23 memory-hygiene 行位置之后）；§一 清单补 12 行（主仓 :49 memory-hygiene 行之后）；§一 Rule 34 门控提示（:27 「v093 起 16 类，task-v109 起 17 类」→追加「task-v115 起 29 类」）；§六 速查表补 12 行（主仓 :151-154 四行保留+追加 12 行）；§六 互斥表补 4 行；§九 矩阵补 12 行（33 数据行→45 数据行）+「不适用」括注（主仓 :240 「3 行」→「15 行」+videop1 两条括注行）；§十 内容组行（主仓 :252 「（writing/research/publish/video）」→「（writing/research/publish/video/image+videotpl 工序 11 类）」）、映射使用规则② 21.4 句（主仓 :258 新句保留）。
- 保留段（主仓演进）：:23 决策树 memory-hygiene 行、:46-47/:49 清单 mini-lite/video/memory-hygiene 行、:151-154 速查表四行（轻量档/视频生产/视频修正/记忆卫生）——videop1 版这三处已丢失（videop1 基于 v109 前分叉）；:255「轻量档（mini-lite）」行 21.4 新句；:258 映射使用规则 21.4 新句；§九 矩阵既有 18 行结构（video/video-fix/mini-lite/memory-hygiene 数据行）。
- 冲突点：① :27 Rule 34 计数句（主仓「v109 起 17 类」vs videop1「planimage 起 17 类+videotpl 起 28 类」→合成 29 口径）；② §六 速查表与 §九 矩阵同区（主仓加 4 行 vs videop1 加 12 行删 4 行 → 主仓 4 行全保留+追加 12 行）；③ §十 内容组行 21.4 句新旧（→取主仓句+组别扩列）。

## 第三部分 级联清单（29 全链 grep 集合，主仓 skills/ 逐处）

A. `grep -rn "17 个\|17 variant\|18 行\|25 个 .md\|16 个 variant" skills/` 命中（排除 .backup 备份目录）：
1. plan-template-kit/references/template-guide.md:32 「Variant 模板（17 个」→「29 个」+尾注追加 videop1 两条
2. plan-template-kit/references/template-guide.md:64 「17 variant = 25 个模板…实际 25 个 .md」→「29 variant = 37 个模板」（模板口径=5 核心+3 辅助+29，主仓既有句式）；「实际 N 个 .md」按 raw ls：主仓收编前 27（10 顶层+17 variant，实测），收编后 39（10 顶层+29 variant）——videop1 版 :75 写 38 系其位 ls 数，主仓口径按主仓目录实况 **39**（Phase 2 执行时先 `ls | wc -l` 实测定稿，本清单给实测值 39，禁止臆数）
3. plan-template-kit/references/template-guide.md:66 「22/25 个模板文件统一含」→「35/38」+漂移注「planimage +image，videotpl +11」
4. plan-template-kit/references/template-guide.md:70 「验收（应为 22」→「应为 35」（知识锚 grep 实测，见 B）
5. plan-template-kit/references/template-guide.md:71 「主模板 + 17 variant，含锚 16」→「主模板 + 29 variant，含锚 28」
6. task-planner/README.md:23 「17 个 variant 模板（…memory-hygiene；」列表追加 12 类名+「17 个」→「29 个」；同句「全部 26 个模板统一含」→「全部 38 个模板统一含」
7. task-planner/README.md:35 「5 核心 + 3 辅助 + 17 variant」→「29 variant」
8. task-planner/README.md:74 「5 核心 + 3 辅助 + 17 个 variant」→「29 个 variant」
9. task-planner/SKILL.md:275 「standard 17 variant」→「standard 29 variant」
10. task-planner/references/critical-rules.md:357 「（18 行：17 variant + general」→「（30 行：29 variant + general」
11. task-planner/references/critical-rules.md:370 「② standard…=现有 17 个 variant」→「现有 29 个 variant」
12. task-planner/scripts/selftest-template-lifecycle.sh:20 注释「TL-17…计数含「17 个」（…task-v109 memory-hygiene 收录 16→17）」→「…29 个（task-v115 videop1 回流 12 类 17→29）」；:87 断言 `grep -q '17 个'` → `grep -q '29 个'`（TL-17 语义更新，编号 TL-17 保留）
13. task-planner/scripts/selftest-skill-split.sh:50 `t "T-迁 template-guide.md 含 17 个" grep -q '17 个'` → `含 29 个 / grep -q '29 个'`
14. task-planner/companion/agents/plan-writer.md：表 :53-67 补 12 行（17→29 行=28 variant+general）——无计数文案需改（表后无数字句，负结果确认）

B. knowledge-brief 计数锚：
- 主仓 `grep -rl "## 📚 必要知识储备" skills/task-planner/templates/ | wc -l` = **23**（顶层 10 个 .md 中 7 个含锚=batch_report/findings/subagent_dispatch/verification/progress/task_plan/notepad-learnings；无锚 3=delivery-summary/knowledge-brief/shared-tracker；variant/ 16/17 含锚，mini-lite 无）
- videop1 面同命令 = **34**（顶层 7+variant 27/28 含锚，仅 mini-lite 无）
- 12 新 variant 全含锚 → 收编后主仓 = 23+12 = **35**；改法：guide :70 「应为 22」→「应为 35」+ §2.4 标题括注「22/25」→「35/38」
- 负结果：knowledge-brief.md:9 自述「grep 锚计数维持 22」与主仓实测 23 不符（主仓 17 计数轮漏更，本轮一并改 35）；README:23 「全部 26 个模板统一含」实测 26 个文件中仅 23 含锚——两处主仓既有漂移，本轮修正（README 26→38，措辞「除 delivery-summary/knowledge-brief/shared-tracker/mini-lite 外统一含」）

C. TL-17/skill-split/README/template-guide 逐处改法 = A.12/A.13/A.6-8/A.2-5（已列）

D. 负结果与实测纠偏：
- knowledge-brief 锚主仓实测 23 而非 guide 声称 22（既有漂移，本轮级联修正为 35）
- 主仓 templates/ 顶层 .md=10（5 核心=task_plan/batch_report/verification/findings/progress；3 辅助=knowledge-brief/shared-tracker/subagent_dispatch；delivery-summary/notepad-learnings=2 个另计）；「5 核心+3 辅助」括注与目录实况有 2 文件差额（delivery-summary/notepad 归入「不入此口径」句已有先例，主仓 :64 括注即如此处理——收编后 .md 口径=38（26 顶层+12）
- variant 白名单「16 类」残留面（旧计数 16 的脚本/文档注释，grep "16 类" 命中）：plan-template-kit/SKILL.md:19、task-planner/scripts/init-session.sh:275,294,327、task-planner/scripts/selftest-template-sense.sh:100（触发信号样板行）——5 处需同步 16→29（或改动态表述「variant/ 目录动态派生」）；属 29 全链扩展新增锚（17 轮无此面，因 16 计数早于 v109 17 口径）
- critical-rules:348（v109 清单编号）对应现文件 :357（行号漂移，内容=37.1 矩阵 18 行句）——级联按内容定位，勿按旧行号
- template-guide:64 在 videop1 面为 :75（行号偏移，主仓 :64 为基准）
- .backup-20261001-071943/template-guide.md 内「17 个」命中属备份文件，不入级联面

## 最终结论（8 字段）
status: done
acceptance: 3/3 pass — ①三部分逐项结论完成（收编预检/逐文件合并判定/逐处级联改法）②三清单完整（收编 12 项逐文件/合并 3 文件逐段 file:line/级联 14 处+扩展锚 5 处）③检查点含 8 字段块
files: /mnt/data/dev/task-planner-skill/plans/task-v115/subagent-state/1-executor.md（新建）; findings.md/progress.md 追加待主进程回填
evidence: cmp plan-writer.md 两版=IDENTICAL; grep -L 12 variant 头部/plan_tier/知识锚全合规; 主仓知识锚实测 23 vs guide 声称 22（漂移实证）; videop1 面实测 34; diff 三文件全量段级比对
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v115/subagent-state/1-executor.md (status: done)
findings_written: #### [sub:1-executor] 回流普查
blockers: none
confidence: HIGH
