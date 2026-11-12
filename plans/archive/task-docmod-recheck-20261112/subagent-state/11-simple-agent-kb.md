# 11-simple-agent-kb 机械落盘检查点

## 步骤输出

### 1. 创建条目
- 路径: `/mnt/data/dev/task-planner-skill/knowledge/entries/rule106-docmod-recheck-discipline.md`
- 结果: File created successfully (正文逐字按要求写入，含 frontmatter)

### 2. 删除草稿
- 命令: `rm /mnt/data/dev/task-planner-skill/knowledge/entries/_draft-task-docmod-recheck-20261112.md`
- 结果: `draft_removed=ok`
- 验证: 草稿文件已不存在

### 3. 重建索引
- 命令: `cd /mnt/data/dev/task-planner-skill && bash scripts/kb-rebuild-index.sh 2>&1 | tail -4`
- 结果: (无输出，退出正常)
- 索引文件: `knowledge/INDEX.md` 存在

## 自检
- `ls knowledge/entries/ | grep rule106` => `rule106-docmod-recheck-discipline.md`
- `grep -n "rule106-docmod-recheck" knowledge/INDEX.md | head -2` => 
  `17:| rule106-docmod-recheck-discipline | "Rule 106 文档修改复检与 todo 两组驱动对齐——落地锚点、判例与易错点" | [rule106, verification, todo-sync, 判例, 纪元锚] | [plans/task-docmod-recheck-20261112/knowledge-brief.md, plans/task-docmod-recheck-20261112/findings.md, skills/task-discipline/references/critical-rules-discipline.md] | entries/rule106-docmod-recheck-discipline.md |`
- 命中数 ≥1: 是

## 总结
新条目在位、草稿已删除、索引已重建并包含新条目 id。acceptance 满足。