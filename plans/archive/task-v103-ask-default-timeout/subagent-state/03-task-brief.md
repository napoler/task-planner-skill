# P2-S3 任务书: RT selftest（RT-01..09）+ registry 行 + T-主 行钉级联（task-v103）

任务: worktree 内新建 scripts/selftest-ask-default-timeout.sh（RT-01..09）+ registry 登记 +1 行 + T-主 行钉级联 440→442。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件（worktree skills/task-planner/ 下）
1. scripts/selftest-ask-default-timeout.sh（新建,参照 selftest-reliability-institution.sh 范式: SCRIPT_DIR/SKILL_ROOT 解析/ok()/bad()/Total 行/exit 语义）
2. scripts/selftest-registry.tsv（EOF +1 行）
3. scripts/selftest-skill-split.sh（T-主 行钉级联,B 类扩围）

## 断言清单（RT-01..09,先 Read S1/S2 实文实测锚再写断言）
- RT-01: CRIT `grep -c '^44\.'`=4（44.1-44.4 四子条锚）
- RT-02: 用户原话锚——CRIT 44 节内「默认选项」≥1 且「自动超时」≥1 且「5 分钟」≥1
- RT-03: 44.2 行内「41.3」引用≥1（低区分度直接裁决衔接锚）
- RT-04: SKILL `grep -c '| C33 |'`=1（合规清单消费行）
- RT-05: 模板 task_plan.md `grep -c '自动超时默认项'`≥1（配置行锚）
- RT-06: mini-lite `grep -c 'Rule 44 豁免'`≥1（豁免声明锚）
- RT-07: registry `grep -c 'selftest-ask-default-timeout'`=1（登记锚）
- RT-08: 越界负断言——CRIT 与 SKILL `grep -nE '1-4[0-9]'` 零命中
- RT-09: 零新 config 键——config.json properties 键数=40（同 R-12/WF-12 口径;jq 缺失打 SKIPPED 不 FAIL）
头注释: 脚本定位/RT-01..09 描述/「静态只读零写入」声明。Total 行=`Total: 9 PASS=9 FAIL=0` 形态。

## T-主 级联（B 类扩围,以实测 442 为准禁手估）
- selftest-skill-split.sh T-主断言: `-le 440` → `-le 442`（SKILL.md S2 后实测 442 行）;label 措辞同步（「task-v103 C33/Rule44 摘要 440→442」）;`-le 558` 等上限断言不动
- 同时复跑 selftest-skill-split 确认 T-主 PASS

## registry 行
`selftest-ask-default-timeout.sh` 行,列形态照 registry 既有行（对照 1-2 行取列结构）。SR-12 动态口径（registry 行数=脚本数+表头）自动咬合,RT+registry 必须同批落盘（否则 SR-12 单侧断）。

## 硬约束
- S1/S2 产物（CRIT 44/SKILL C33/模板行）零改动;只动 3 个目标文件
- 禁「1-4x」越界字面;禁 git commit/add

## acceptance: 验收标准
1) `bash scripts/selftest-ask-default-timeout.sh` → `Total: 9 PASS=9 FAIL=0`
2) `bash scripts/selftest-skill-split.sh` → 全 PASS（T-主 442 级联过）
3) `bash scripts/selftest-self-resolution.sh` → 12/0（SR-12 动态口径 42 咬合: 41 脚本+表头=42 行=registry 42 行）
4) `bash -n` 新脚本语法过;`grep -c 'RT-09' scripts/selftest-ask-default-timeout.sh`≥1
5) `git -C <wt> status --short`: 新增 1 + M 2（registry/skill-split）+ 前序 S1/S2 存量 4 文件

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/subagent-state/03-exec-p2s3.md（含三脚本 Total 行原文）。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 三个 Total 行+bash -n 输出
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
