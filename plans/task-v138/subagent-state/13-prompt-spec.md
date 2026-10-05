# task-v138 / selftest-capability-persistence.sh + registry.tsv 实施规格（P3-S3 任务书材料）

> 消费者：executor（P3-S3）｜生成：主进程 2026-10-05｜范式：scripts/selftest-veto.sh

## A. selftest-capability-persistence.sh 断言清单（只断言 Rule 55 新增锚；禁触碰既有脚本任何行）

1. critical-rules.md：`^### 55 ` 计数=1；`^55\.[1-6] ` 计数=6；块首说明行含 `task-v138`
2. SKILL.md：`Rule 55` 计数≥3；`40-55` 计数=1；`40-53` 计数=0（演进完成断言，样式参照 RR-16 演进后口径）
3. capability-registry.md：文件存在；表头 8 列；`agnes-quota` 行存在且 8 字段非空
4. scripts/capabilities/agnes-quota.sh：存在；`bash -n` 通过；`grep -icE 'sk-[a-z0-9]|cpk-'`=0；头注释含 `Rule 55`
5. companion/agents/video-generation-executor.md 与 image-generation-executor.md：各自 `capability-registry` 计数≥1
6. config.json：properties 键数=40（零新键声明锚；沿用 tsv 末列既有口径，jq 或 grep 计数）
7. 脚本自身：`SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"` 自定位（仓库/worktree/部署位三处可跑）；被检文件路径相对 SCRIPT_DIR 解析（`$SCRIPT_DIR/../references/...`、`$SCRIPT_DIR/../companion/agents/...`、`$SCRIPT_DIR/../capabilities/...`、`$SCRIPT_DIR/../../config.json` 以实际布局为准，先 Read selftest-veto.sh 学既有相对定位法）；输出 `Total: N PASS=x FAIL=y` 行；FAIL>0 → exit 1，全过 → exit 0
8. 头注释 What+Why（Rule 45）：What=守护对象清单与运行方式；Why=Rule 55.6 机制锚（task-v138 2026-10-05），只断言新增锚防锚级联

## B. selftest-registry.tsv 追加行（4 列 Tab 分隔；先 Read 末行确认分隔形态与行尾换行再追加）

列1: `selftest-capability-persistence.sh`
列2: `Rule 55 可复用能力落盘纪律守护（task-v138）`
列3: `critical-rules 55.x 六子条/SKILL 40-55 全集/capability-registry 8 列/agnes-quota.sh 存在+无硬编码 key/两 executor 接线行/config properties=40 零新键`
列4: `references/critical-rules.md ^55;SKILL.md Rule 55;references/capability-registry.md;scripts/capabilities/agnes-quota.sh;companion/agents/image+video-generation-executor.md;config properties=40`

## C. 验收口径（自测后写入返回 8 字段 acceptance）

1. `bash scripts/selftest-capability-persistence.sh` → Total 行 FAIL=0 且 exit 0
2. tsv 行数 52→53 且新行列数=表头列数（awk -F'\t'）
3. `git -C <worktree> diff --numstat` 仅两文件（新脚本 +N/-0、tsv +1/-0）
4. 抽跑既有脚本确认未波及：selftest-veto.sh、selftest-media-dispatch.sh 各自 Total FAIL=0
