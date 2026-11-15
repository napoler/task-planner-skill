# 任务书：kb 条目落盘与索引重建（task-initdelegation-20261115 终验收尾）

仓库=/mnt/data/dev/task-planner-skill。需求锚：不适用（纯机械单元，落盘主进程已定稿内容）。

## 步骤
1. Read 本任务书同目录 `kb-entry-content.md`（条目终稿全文），用 Write 工具**逐字**创建 `/mnt/data/dev/task-planner-skill/knowledge/entries/dispatch-init-delegation.md`
2. `rm /mnt/data/dev/task-planner-skill/knowledge/entries/_draft-task-initdelegation-20261115.md`
3. 在仓库根执行 `bash scripts/kb-rebuild-index.sh`
4. 验证：新条目在位（wc -l ≥40）、draft 已删、INDEX 含 dispatch-init-delegation 行
5. 检查点：本目录 `kb-entry.md` 写动作+验证摘要（≤10 行）
禁改其他文件，禁 git 操作。

## 返回格式（8 固定字段严格模板，22.4b；字段名与顺序不得改；8 字段后不得有任何内容）
status: done|partial|blocked
acceptance: <逐条对照上述验收项>
files: <创建/修改/删除文件绝对路径清单>
evidence: <关键证据 file:line 或命令输出摘要>
checkpoint: <检查点路径>
findings_written: none（纯机械单元）
blockers: <无则 none>
confidence: high|medium|low
