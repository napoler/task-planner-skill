# S3 检查点 — 视频生成执行体 47.6 块 graft（task-imgqc-basiccheck-20261105）

状态: COMPLETE（未 commit，按任务约定）

## 里程碑
- [x] M1 Read 目标全文（70 行）+ 部署位基底 L60-77（47.6 块）+ 规则层 47.6/47.6a-c 源（critical-rules-media.md L21/23-25）
- [x] M2 Edit 纯增量插入
- [x] M3 grep 验收 + git diff 核验

## 改动
文件: skills/task-planner/companion/agents/video-generation-executor.md（worktree 内唯一修改对象）
位置: L68-78（「## 验证协议」段之后、「## 负结果报告」段之前，与部署位基底同构位置；插入后 47.6 块标题落在 L69）
块结构:
- `## QC 强制抽检门（Rule 47.6，task-crossprojauth R7 2026-11-04）`（deploy 版标题原样）
  - 抽帧抽检 SOP（每镜 ≥3 帧 首/中/尾 + image-understand 判读 + 缺陷清单 + 证据落盘）— deploy 基底原文
  - **47.6a 硬约束逐条核验门**（视频措辞: 抽帧判读证据上逐条标 PASS/FAIL；判例 sess_83f64e428b 保留）
  - **47.6b 常识认知缺陷类目（H 级）**（既有清单并入视频项 运动方向矛盾/串戏/物理合理性；三类扩容: 空间布局/场景构成/物件功能；「逐视角不一致」→ 视频链「逐镜头不一致」）
  - **47.6c 先取证后判定**（成图/抽帧取证原文 + 判定结论落检查点；无留痕=QC 未做，51.2 禁称 COMPLETE）
  - 47.5 重做环三件套 + 抽检未完成禁称 COMPLETE 尾条（deploy 基底原文）

## grep 验收（实测输出）
- 硬约束逐条核验门: 1 ✓（≥1）
- 47.6a/47.6b/47.6c: 各 1，合计 3 ✓（≥3）
- QC 强制抽检门: 1 ✓（≥1，标题 L69）
- git diff --stat: `1 file changed, 10 insertions(+)` — 只动本文件、纯插入 ✓
- frontmatter diff: hunk 起点 @@ -66,5（在 L1-8 frontmatter 之外），0 deletions → frontmatter 零改动 ✓

## 风险/负结果
- 无。未 commit 未 push（遵守任务约定）。SRC 既有正文 95.x 条款零改动（纯增量插入验证: diff 无 - 行）。
