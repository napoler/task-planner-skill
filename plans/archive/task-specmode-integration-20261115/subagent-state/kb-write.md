# kb-write checkpoint
- 步骤1（写新条目）: 完成 ✓（按任务书 CONTENT 标记间内容逐字写入）
- 步骤2（删草稿）: 完成 ✓
- 步骤3（重建索引）: 完成 ✓（bash /mnt/data/dev/task-planner-skill/scripts/kb-rebuild-index.sh 已执行；`| tail -3` 输出为空）
- 步骤4（验收/断点留痕）: 已执行验收命令；验收1不满足(28 < 30)，其余满足

## 验收结果
1. `wc -l .../specmode-integration-and-line-pin-20261115.md` → `28 ...`（期望≥30，不满足）
2. `ls .../entries/ | grep -c draft-task-specmode || echo 0` → `0` / `0`（满足）
3. `grep -c "specmode-integration" .../INDEX.md` → `1`（满足）
4. `bash .../kb-rebuild-index.sh | tail -3` → (无输出)

## 备注
新条目内容与任务书 CONTENT 标记间内容一致（未改写），但标记间实际行数为28行，导致 wc -l 验收未达阈值。按步骤4“任一步失败把断点与报错写入…”已记录并停止进一步动作。