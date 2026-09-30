# 03-exec-p2s3 checkpoint — P2-S3 RT selftest + registry + T-主 级联（task-v103）

状态: 完成（全部 acceptance 通过，未 commit，按任务书禁 git commit/add）

## 落盘文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v103-ask-default-timeout）
1. `skills/task-planner/scripts/selftest-ask-default-timeout.sh`（新建，RT-01..09，范式同 selftest-reliability-institution.sh）
2. `skills/task-planner/scripts/selftest-registry.tsv`（EOF +1 行 `selftest-ask-default-timeout.sh`，4 列 TSV 形态照既有行）
3. `skills/task-planner/scripts/selftest-skill-split.sh`（T-主 行钉级联 `-le 440` → `-le 442`，label 改「task-v103 C33/Rule44 摘要 440→442」，`-le 558` 上限未动）

## 三脚本 Total 行原文
- `bash scripts/selftest-ask-default-timeout.sh` →
  `Total: 9 PASS=9 FAIL=0`（RT-01..09 全 PASS；RT-09 jq 在位,键数 40 非 SKIPPED；exit=0）
- `bash scripts/selftest-skill-split.sh` →
  `Total: 41  PASS=41  FAIL=0`（T-主 442 级联过；exit=0）
- `bash scripts/selftest-self-resolution.sh` →
  `Total: 12 PASS=12 FAIL=0`（SR-12 原文：`registry selftest-self-resolution 登记行 ≥1 且总行数 42=脚本数+表头（动态）`；exit=0）

## 其他验收
- `bash -n selftest-ask-default-timeout.sh` → 无输出（语法过）；`grep -c 'RT-09'` 该脚本 = 4（含头注释/正文）
- registry 42 行 = 41 脚本 + 表头（SR-12 动态口径咬合，RT+registry 同批落盘）
- 断言锚均先对实文实测再写：`grep -c '^44\.'` CRIT=4（441-444 行）；44 节内「默认选项」4/「自动超时」2/「5 分钟」2；44.2 行内 41.3=1；SKILL `| C33 |`=1；模板「自动超时默认项」=1；mini-lite「Rule 44 豁免」=1；越界 `1-4[0-9]`：CRIT 44 节=0、SKILL.md=0（全库命中在 42.6.4 行,44 节内零）；config properties=40
- 硬约束：S1/S2 产物（CRIT 44/SKILL C33/模板行）零改动；本步只动 3 个目标文件
- `git -C <wt> status --short` → `?? scripts/selftest-ask-default-timeout.sh` + M registry/skill-split + 存量 M SKILL.md、CRIT、task_plan.md、mini-lite-type.md（=新增1 + M2 + 前序4,与 acceptance 5 一致）

## issues
无

## next_step
交主代理跑全量 selftest 收口（registry 42 行口径下其余脚本回归）并按 §11.3 合并回约处理 wt/task-v103-ask-default-timeout 分支。
