# S9b 收尾补充材料（executor，2026-10-10）

## 任务（1 文件，2 处）
`plan-created.cjs` 残留两处指针旧语义（S9 自报边界事实，S4 清单外同文件同类）：
1. `:153` 注释 `// ②③ 会话指针 → legacy 指针（TTL 24h 与 resolve-plan-dir.sh 对齐）`
2. `:174` label 字符串 `label: 'legacy 指针 .active_plan'`

## 改法
- :153 → `// ②③ 会话指针 → 全局 fallback 指针（TTL 24h 与 resolve-plan-dir.sh 对齐）` + 邻行加 `[2026-10-10 task-v164]` 一句注记（原措辞说明）
- :174 → `label: '全局 fallback 指针 .active_plan'`（display label，仅此一处字符串；主进程已核无 selftest/脚本耦合该字面）

## 验收（主进程将复跑）
- `grep -n 'legacy' plan-created.cjs` 剩余仅：`:11/:16`（legacy 哨兵迁移史，合法）+ `:135-136`（[task-v164] 注记内引文）+ `:221-239/:301`（legacy 哨兵，合法）——指针层 legacy=0
- `node --check` rc=0；`git diff -- plan-created.cjs` 仅 1 注释行+1 字符串行+1 注记行
- `grep -c 'task-v164' plan-created.cjs` ≥2

## 边界
- 只改该文件上述 2 处+1 注记行；禁动其他任何行/文件；禁 git 写操作
