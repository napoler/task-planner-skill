# 8-code-assistant 检查点

status: done
date: 2026-10-15
scope: task-v177 S5 — 新建 selftest-rule86-autonomous-decision.sh + selftest-registry.tsv 登记（CA-7）

## 改动清单（2 文件，worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v177）

### 文件1（新建）skills/task-planner/scripts/selftest-rule86-autonomous-decision.sh
- 10 条断言 AA-01..AA-10（four-file-dataflow 范式：ok/bad/eq/ge/zero/pair/cnt+grep 文本锚计数+末行 Total+相对 SCRIPT_DIR）：
  - AA-01 `^### 86\.` 七子条标题计数=7
  - AA-02 86.1 语义内核 pair（分类闸+可测性三问）
  - AA-03 86.2 负面清单 pair（负面清单+重抽 vs 换词）
  - AA-04 86.3 四分类穷尽 if 四短语（偏好/不可逆/预算/合规 各≥1，pair 助手仅两参故用 if 合成）
  - AA-05 86.4 三件套 pair（我的推荐+缺一=无效上抛）
  - AA-06 86.5 媒体链默认循环 pair（媒体链默认循环+自主迭代）
  - AA-07 86.7 机器面自指锚（脚本名在条款内 ≥1，防守卫自盲）
  - AA-08 media 47.5 消费锚（critical-rules-media.md「自主迭代」≥1，实测=2）
  - AA-10 反例负断言：image-type.md「选定/重抽」=0（前向锚）
  - AA-09 头注 What+Why 双层（Rule 45）
- 头注 What+Why 双层齐备（Rule 45）

### 文件2 skills/task-planner/scripts/selftest-registry.tsv
- 追加 1 行（第 84 行，4 列真实 tab）：
  `selftest-rule86-autonomous-decision.sh`<TAB>`Rule 86 可测问题禁问静态守护 AA-01..10（task-v177；R1 投诉锚「可测选优却推责用户」+R3 落地；86.7 机器面）`<TAB>`Rule 86 条款锚/86.1-86.7 七子条(分类闸/负面清单/四分类穷尽/三件套/媒体链默认循环/零缺陷不免责/机器面)/media 47.5 消费锚(自主迭代)/image-type.md「选定/重抽」二选一反例负断言(S6/CA-8 前向锚)/registry 自登记 改动`<TAB>`critical-rules-discipline.md;critical-rules-media.md;templates/variant/image-type.md;selftest-registry.tsv`

## 验证

- `bash skills/task-planner/scripts/selftest-rule86-autonomous-decision.sh`（worktree 内）→ **PASS=9 FAIL=1**
  - 唯一 FAIL = AA-10（预期红）：S6/CA-8 的 image-type.md:88「选定/重抽」三处止血尚未 land 到 worktree（git status 确认 image-type.md 无改动）；AA-10 按四文件范式设计为前向锚（FF-11 判例同构），S6 合入后自动转绿，脚本本身零缺陷
  - **10/10 转绿能力已实证**：/tmp 镜像用「选定/重抽→默认项」止血版 image-type.md 跑同一脚本 → `Total: 10 PASS=10 FAIL=0` rc=0
- `bash skills/task-planner/scripts/selftest-registry.sh` → **T01..T05 全 PASS，Total: 5 PASS=5 FAIL=0**（registry rows=82, actual selftest=82；T02 无缺失、T03 无孤儿不报）
- `bash -n` 新脚本语法 OK

## 负结果/边界报告

- 未触碰 image-type.md（S6 属另一并行单元，本单元禁碰）；AA-10 预期红已记录归因
- 依赖面 grep 复核：7 子条标题=7 / 自主迭代(media)=2 / 选定/重抽(image-type)=1，全部与断言期望一致
- 排除风险：无全量 selftest 运行（铁律）、无 git 写操作、无 3 文件以上改动
