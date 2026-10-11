# P5 任务书: CR Gate 隔离审查（task-v105,084a92a..fbe2109）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 084a92a..fbe2109（task-v105 池成员宿主可枚举实现面）。只读,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 084a92a..fbe2109`
- 主审: scripts/smart-merge-back.sh（install_pool_links 函数+调用点+头注释——35 行纯增）
- 轻审: lib/install-companion.sh（池分发 if 块,+21/-1）;scripts/selftest-review-library.sh（RL-14/15+头注释 13→15）

## 专项核对点（逐项给结论与证据）
1. **挂载安全性（最高优先）**: install_pool_links 是否存在任何「覆盖/删除顶层既有条目」路径——已存在条目必须一律跳过（LINK-WARN）,挂载后校验失败仅 rm 本次新建的链;`[ -e ] || [ -L ]` 双条件（断链软链场景）;相对软链目标（slot 原子替换后有效性）
2. **exit 语义隔离**: LINK-* 输出是否可能改变函数返回值/脚本 exit 码/DRIFT 判定——函数 return 0、调用处无 DRIFT 逻辑;deploy_reconcile/validate_slot/原子替换/exit 0 既有行零改动（diff 核对）
3. **install-companion 分发语义**: cmp 不同→skip+WARN+skipped 计数（独立 skill 不覆盖）;等同→sync_one 幂等;仅 SKILL.md 单文件;agents 段/非 task-planner 分支零改动
4. **级联完整性**: RL-14/15 断言锚对照两脚本实文;RL-01..13 零改动;头注释 13→15;registry 无需新行（无新脚本）
5. **三宿主挂载现状亲验**: ~/.zcode/skills 11 链+~/.claude/skills 11 链+opencode 10 链+security-review 独立副本保留（readlink/grep name 实测）
6. **越界字面与字面锚**: 新增文本 1-4x 零命中;「Rules 1-39」2 处保全;config 零改动
7. **一般缺陷**: 其他正确性/一致性问题（含:`ls -d .../*/ | xargs basename` 对空格成员名的鲁棒性说明——池成员 kebab-case 无空格,是否可接受）

## 输出合约
- `APPROVED` 或 `CHANGES_REQUESTED`(逐条 [P0/P1/P2] 文件:行 — 问题 — 修法)
- 先落盘: /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/subagent-state/04-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 7 专项逐项结论
