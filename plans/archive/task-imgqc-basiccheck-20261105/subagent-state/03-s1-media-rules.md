# 03-s1-media-rules S1 检查点

任务：task-imgqc-basiccheck-20261105 S1 — 在 worktree 内 media-planner 规则文件 Rule 47.6 段末插入 47.6a/b/c 三子条款。

## 状态：DONE（修改完成 + grep 验收通过 + diff 范围确认）

## 目标文件（唯一改动文件）
`/mnt/data/dev/task-planner-skill-worktrees/task-imgqc-basiccheck-20261105/skills/media-planner/references/critical-rules-media.md`

## 插入位置与 diff 摘要
- 插入位置：L23-L25（原 L21 = 47.6 条款段末，其后、`### 49` 段之前；插入 3 个 `-` 列表项 + 前置空行，共 4 行纯增量）
- diff --stat：`skills/media-planner/references/critical-rules-media.md | 4 ++++`（1 file changed, 4 insertions(+)，0 deletions — 既有条款逐字未动）
- 47.6a L23 = 硬约束逐条核验门（P0）：QC 前提取需求原文/设定卡/负例裁决中全部「可视觉判定硬约束」→ 逐条登记检查项 → 取证证据上逐条 PASS/FAIL+留痕；任一 FAIL=硬拒收（禁入候选/禁挂待审核/禁作推荐）直接进 47.5 重做环；禁「整体不错/大体符合」印象替代逐条核验（判例 sess_83f64e428b「场景无人物」未逐条核验致含人物图挂待审核放行）
- 47.6b L24 = 常识认知缺陷类目扩容（H 级=禁交付）：既有解剖/透视、文字乱码、主体错位 3 项之上加 空间布局类/场景构成类/物件功能类，各含判据（载具入户门应单侧、镜像翻转、光影跨物体不连贯、漂浮/部件融合等）
- 47.6c L25 = 先取证后判定（P0）：QC 判读必须基于成图实际取证输出（image-understand 或等效工具逐项描述原文），禁凭提示词/生成意图/记忆印象判 PASS；取证原文+逐条判定落检查点留痕，无取证留痕=QC 未做（按 Rule 51.2 禁称 COMPLETE）
- 措辞微调说明：三子条标题括注对齐该文件既有「（task-xxx 纯文本增量）」体例；47.6c 末尾 51.2 引用格式对齐既有「按 Rule 51.2 完成声称门，禁称 COMPLETE」体例；语义判据一字未丢。
- 文件尾注/纪元注释区：无级联需要，未动；未新增引用行、未新增 Rule 编号。

## grep 验收输出原文（2026-11-06 执行）
```
$ grep -c "硬约束逐条核验门" <f>          → 1      （期望 ≥1 ✅）
$ grep -cE "空间布局|场景构成|物件功能" <f> → 1      （行计数=1：三词同处 L24 47.6b 一行；逐词复核 grep -oE | uniq -c：空间布局 1、场景构成 1、物件功能 1，各 ≥1 ✅）
$ grep -c "47.6a\|47.6b\|47.6c" <f>        → 3      （期望 ≥3 ✅）
$ git diff --stat → skills/media-planner/references/critical-rules-media.md | 4 ++++
                      1 file changed, 4 insertions(+)   （只动本文件 ✅）
$ git status --short → M skills/media-planner/references/critical-rules-media.md（唯一改动文件 ✅）
```

## 约束自检
- 只 Edit 了这一个文件；既有条款正文（含 L21 47.6 段原文）逐字保留（diff 0 deletions 佐证）
- 未 git commit/push（worktree 内保持未提交状态，由主进程统一回合约处理）
- 负结果说明：检查了 L1-L37 段结构（47/49/50 三个 Rule 块），确认 47.6 段体例为「条款号 粗体标题：正文」+ 子条 `-` 列表；未发现与其他子条/尾注冲突；未修改任何既有条款字。
