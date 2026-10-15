# 7-code-assistant 检查点

status: done

## 改动清单（3 文件）

1. `/mnt/data/dev/task-planner-skill-worktrees/task-v177/skills/media-planner/references/critical-rules-media.md`
   - :17 47.4 措辞顺延：「47.1-47.4 四子条」→「47.1-47.5 五子条」（唯一计数表述，无其他 Rule 47 共 N 子条类计数需刷）
   - :19 新增 47.5「生成不满意自主迭代环（Rule 86.5 媒体链默认循环，2026-10-15 task-v177）」：不满意→模型自主迭代 N 轮（N 默认 3，预算账本内）；每轮只换一维（提示词/随机种子/参考锚）；逐轮记命中判据+淘汰理由；「换提示词 vs 随机重抽」二选一呈用户=违规（86.1-86.2，用户无抽卡分布数据）；停线=达验收交付最优+淘汰记录 / N 轮耗尽→允许带逐轮数据上抛预算追加（86.3③ 类，三件套齐备）；头注 What+Why + 正先例 character-design-type.md:42
   - :7 Rule 47 标题行尾追加 [2026-10-15 task-v177] 47.5 头注（What+Why + 投诉锚 R1 + 正先例）
2. `/mnt/data/dev/task-planner-skill-worktrees/task-v177/skills/media-planner/SKILL.md`
   - :32 规则索引表 47 行加「含 47.5 生成不满意自主迭代环」（照相邻句式）
   - :43 联动规则表追加 Rule 86 行（task-discipline，可测问题禁问→媒体自主迭代环 47.5）
   - :47 参考文档行本无段号（只写「Rule 47,49,50」3 条计数）——未同刷（47.5 属 Rule 47 子条，非新规则编号，3 条计数仍正确；判定=无需改）
3. `/mnt/data/dev/task-planner-skill-worktrees/task-v177/skills/task-planner/scripts/selftest-media-dispatch.sh`（selftest 级联，任务纪律允许）
   - :4 头注「四子条」→「五子条（47.5 加入级联）」
   - :32-34 MD-01 注释「四子条锚/47.1-47.4 四条」→「五子条锚/47.1-47.5 五条」；断言阈值保持 ≥4（向下兼容，实测命中 5）

## 级联 grep 结果

- selftest 钉点全列：:4/:32-34 三处「四子条」类措辞已全部同步；:37 断言 `grep -c '^47\.'` ≥4 未钉死 4（47.5 加入后命中 5，PASS 语义不变，零断言逻辑改动）
- 全文 grep「四子条|47.1-47.」确认无其他钉点残留

## 验证

- `bash skills/task-planner/scripts/selftest-media-dispatch.sh` → Total: 9 PASS=9 FAIL=0, exit=0
- `grep -c "47\.5\|自主迭代" critical-rules-media.md` → 3（≥2 达标）
