# checkpoint — m6-executor（S6 selftest-media-agents）

status: done

## 摘要
新建 worktree `skills/task-planner/scripts/selftest-media-agents.sh`（MA-01..10，151 行，范式对齐 selftest-media-dispatch.sh：SCRIPT_DIR/SKILL_ROOT、ok/bad、Total 行、FAIL>0 exit 1、头注释四要素+What/Why 双层注释）；`scripts/selftest-registry.tsv` 末行追加 4 列制表符行（domain=「Rule 47.2 媒体专业执行体守护（task-v124）」），45→46 行。

## 断言实现（findings §selftest 清单九行 → MA-01..10）
- MA-01 双 agent 文件在位非空（image 4563B / video 4521B）
- MA-02/04 各 frontmatter `name:`=文件名（grep 精确整行）
- MA-03/05 各 frontmatter 三要素：「触发:」≥1 + 「MUST BE USED」≥1 + `^model:`≥1
- MA-06 SKILL.md「媒体生成工序」行含 image 名 ≥1 且「剧集创作管线」行含 video 名 ≥1（行内 grep 组合）
- MA-07 template-mapping.md「媒体族专用执行体」注 ≥1 且双 agent 名各 ≥1
- MA-08 README_zh「6 个伴生」+ INSTALL_zh「6 个配套」+ INSTALL.md 双 agent 表路径行（companion/agents/xxx.md）各 ≥1
- MA-09 install.sh 注释双 agent 名各 ≥1
- MA-10 config.json properties=40（jq 缺失打 SKIPPED 不 FAIL，同 MD-08/R-12 先例）

## 验收证据（自跑，worktree 内）
1. `bash scripts/selftest-media-agents.sh` → rc=0，末行原文：`Total: 10 PASS=10 FAIL=0`
2. `bash scripts/selftest-registry.sh` → rc=0，末行原文：`Total: 5 PASS=5 FAIL=0 (registry rows=45, actual selftest=45)`
3. `grep -c 'selftest-media-agents' scripts/selftest-registry.tsv` → `1`
4. `git status --short`（worktree）→ ` M skills/task-planner/scripts/selftest-registry.tsv` + `?? skills/task-planner/scripts/selftest-media-agents.sh`（diff 面仅两文件）；`git diff --numstat` tsv = `1 0`
5. Scope 禁改清单遵守：只新建 1 脚本 + 改 registry.tsv + §2 契约追加（findings 锚段 [sub:S6] + progress Phase 3 Actions taken），未改其他文件、无 git 写操作

## 最终结论（8 字段块，同返回格式）
status: done
acceptance: 3/3 pass — [selftest-media-agents.sh 末行: `Total: 10 PASS=10 FAIL=0` rc=0; selftest-registry.sh 末行: `Total: 5 PASS=5 FAIL=0 (registry rows=45, actual selftest=45)` rc=0; `grep -c 'selftest-media-agents' selftest-registry.tsv`=1, numstat=`1 0` tsv + 新脚本 ??]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v124/skills/task-planner/scripts/selftest-media-agents.sh (+151/-0); /mnt/data/dev/task-planner-skill-worktrees/task-v124/skills/task-planner/scripts/selftest-registry.tsv (+1/-0)
evidence: `bash selftest-media-agents.sh`→`Total: 10 PASS=10 FAIL=0`(rc=0); `bash selftest-registry.sh`→`registry rows=45, actual selftest=45`(rc=0); `grep -c`→1; `git status --short`→仅两文件
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/m6-executor.md (status: done)
findings_written: /mnt/data/dev/task-planner-skill/plans/task-v124/findings.md §Research Findings 段末 `#### [sub:S6] selftest-media-agents.sh 落盘 + registry 登记（MA-01..10）`
blockers: none
confidence: HIGH
