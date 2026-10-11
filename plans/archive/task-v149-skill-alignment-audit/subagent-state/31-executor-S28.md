# S28 CR 修复批E 检查点（executor，worktree 内写）

- 修改文件：skills/task-planner/README.md（仅此一个）
- 修改项：M-4b — config 键数 40→42
- 位置：README.md:69
- 原文：`├── config.json                              ← 阈值配置（40 键）`
- 新文：`├── config.json                              ← 阈值配置（42 键）`
- 依据：json 实测 .properties=42；守卫（selftest-media-agents MA-10、WF-12、FF-15 等）断言恒为 42

## 自验

```
$ grep -n "40 键\|40 个配置\|=40" skills/task-planner/README.md
退出码: 1（0 命中）

$ grep -n "42 键" skills/task-planner/README.md
69:├── config.json                              ← 阈值配置（42 键）
```

## 同文件其他 40 键声明核对

- grep 全文件无其他 "40 键"/"40 个配置"/"=40" 残留（退出码 1 = 无匹配）
- 同结构块内其他计数行（references 10、templates 10+29、Rules 1-65）均已在先前批次对齐，本次不涉及

## 状态

- M-4b 终态：**fixed**（README.md:69 已改 42，自验通过）
- 未触碰其他文件；未 git commit
