# P3-S4+S5 任务书: 新建 selftest-self-resolution.sh + registry 登记（task-v098）

任务: worktree 内新建 scripts/selftest-self-resolution.sh（Rule 41 静态断言守护,SR-01..SR-12）并登记 registry。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/task_plan.md（只读: VC-3 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/findings.md（只读: SR 断言清单设计段）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v098-auto-resolution/skills/task-planner/scripts/ 下）
1. 新建 selftest-self-resolution.sh
2. selftest-registry.tsv（当前 38 行=表头+37 数据行;追加 1 数据行）

## 硬约束
- 先 Read selftest-tool-selection.sh 全文——SCRIPT_DIR/SKILL_ROOT 路径解析、ok()/bad() 结构、`Total: N PASS=x FAIL=y` 行、exit 语义必须同构。
- 静态只读断言（grep/wc/jq）,零仓库写入。
- `bash -n` 语法过;断言锚必须先 grep worktree 实际文件确认存在再写进脚本（防锚漂移假断言）。
- 注意: 并行 Wave 的其他 agent 正在写 critical-rules.md 与 SKILL.md——若个别锚暂时缺失（如 C29 尚未写入）,等 30 秒重试 grep 最多 3 轮再判;仍缺则在 issues 报明缺失锚,勿造假 PASS。

## SR 断言清单（SR-01..SR-12）
- SR-01: critical-rules.md `grep -c '^41\.'` = 6
- SR-02: critical-rules.md 41.2 区域含「G1」与「G4」（grep 全文件各 ≥1 即可）
- SR-03: critical-rules.md 含「已尝试清单」≥1 且含「D6 硬停点语义保留不弱化」≥1
- SR-04: critical-rules.md 含「直接做」≥1 且含「留用户裁决」≥1
- SR-05: critical-rules.md 41.6 含「零新 config 键」≥1 且含「selftest-self-resolution.sh」≥1
- SR-06: SKILL.md `grep -c 'Rule 41'` ≥3 且 `grep -c '| C29 |'` =1
- SR-07: SKILL.md `grep -c 'Rules 1-39'` =2 且 `grep -c '1-40'` =0
- SR-08: SKILL.md 含「含 Rule 40/41」≥1;critical-rules.md `grep -c '^40\.'` =6（Rule 40 与 41 共存零损伤）
- SR-09: config.json properties 键数 = 40（同 WF-12 口径,参考 selftest-workflow-orchestration.sh 实现）
- SR-10: SKILL.md 含「升级四门槛」或「四门槛」≥1（摘要行锚）
- SR-11: selftest-skill-split.sh 含「task-v098」≥1 且含 `-le 4` 前缀断言行存在（级联落地证据;不锁具体数值,数值以该脚本自身 selftest 验证）
- SR-12: selftest-registry.tsv 含「selftest-self-resolution」≥1 且总行数=39（S5 完成后断言;S4 阶段可先跳过本条输出 SKIPPED 注记,S5 后复跑全绿）

## 操作顺序
S4: 先 Read selftest-tool-selection.sh 范式 → grep 实测各锚 → 写 selftest-self-resolution.sh → `bash -n` + 实跑全 PASS。
S5: registry.tsv 追加 1 行（四列对齐既有行格式,先 head -3 看格式）: script=selftest-self-resolution.sh / domain 按既有行风格 / trigger_scenarios=「Rule 41 问题自主消解与升级纪律;升级四门槛;消解清单;trivial 自主裁定」/ dep_anchors=「critical-rules.md ^41 锚;SKILL.md C29+Rule 41 摘要;Rules 1-39 字面锚;skill-split 级联 label」→ 复跑 selftest-registry.sh 双向一致 + selftest-self-resolution.sh 全绿（SR-12 转绿）。

## acceptance: 验收标准
1) `bash scripts/selftest-self-resolution.sh` Total 行 PASS=12 FAIL=0（SR-12 在 S5 后转绿）
2) `bash -n` rc=0;静态只读零仓库写入
3) `bash scripts/selftest-registry.sh` Total 0 FAIL 且 rows=actual=38
4) tsv `wc -l` =39
5) `git -C <wt> status --short` 本任务书范围=新文件 untracked + tsv M（critical-rules.md/SKILL.md 为并行 Wave 存量,不算）

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/subagent-state/04-executor-p3s4s5.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3-S4S5
completed_steps: 逐条
files_written: 绝对路径清单
evidence: Total 行输出
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
