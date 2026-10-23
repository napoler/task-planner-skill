# 3b — image-generation-executor.md 精确编辑检查点

- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023/skills/task-planner/companion/agents/image-generation-executor.md
- 编辑 1 [DONE] L42 段尾追加「额度不可查询（无通道/计费层未填充）时执行即探测（Rule 95.1）……」：前置唯一性核对 old1 count=1 → Edit 成功（单行追加，未重排/未动 frontmatter/未引入「询问」，改写为「向用户求证」）
- 编辑 2 [PENDING] Workflow 第 4 步扩写质检处置自主化（Rule 95.3）
- 编辑 2 [DONE] Workflow 第 4 步扩写质检处置自主化（Rule 95.3）：old2 唯一性核对 count=1 → Edit 成功（单行追加，未重排/未动 frontmatter/未引入「询问」，用「以提问形式推给用户」）

## 自验结果（全 PASS）
- 自验1 双锚: grep -q "处置自主" → PASS; grep -q "推给用户" → PASS
- 自验2 负锚: grep -cE "是否有额度|询问.{0,12}额度|额度.{0,12}询问" → 0 (期望 0) PASS
- 自验3 正向: grep -c "执行即探测" → 1 (期望 >=1) PASS
- 附加 字面「询问」计数 → 0 PASS
- git diff --stat → 2 files：image-generation-executor.md(我的 2 hunk) + video-generation-executor.md(并行执行体 01:45:10 改，非我所为，未触碰)
- 我的文件 diff：仅 2 处增量（L42 段尾 + Workflow 第 4 步），frontmatter 未动，无重排

## 结论
status=COMPLETED；仅改 image-generation-executor.md，2 hunk，零范围外改动；未 git add/commit
