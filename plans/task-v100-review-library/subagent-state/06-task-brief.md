# P3-S6 任务书: selftest-review-library.sh（RL-01..10）+ registry +1（task-v100）

任务: worktree 内新建 `scripts/selftest-review-library.sh`（RL-01..10 静态断言）+ `selftest-registry.tsv` +1 行。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/（只读）
- progress.md: 同目录（子代理禁写）

## 范式源（第一步必读）
/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/scripts/selftest-self-resolution.sh（SR-01..12 全文——SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad()、编号断言、`Total: N PASS=x FAIL=y` 结尾、exit 语义,全部照同构）

## RL 断言 10 条（断言锚动手前先对 worktree 实际文件 grep 实测,防锚漂移假断言——v099 教训）
- RL-01: `ls review-library/ | wc -l` = 10（恰 10 目录）
- RL-02: 10 个目录名与清单精确一致（general-review/code-quality-review/test-quality-review/security-review/image-review/content-quality-review/documentation-review/data-quality-review/ui-quality-review/release-review;实现方式自定,如逐一 -d 判定）
- RL-03: 每目录含 SKILL.md（10 个 -f 全过）
- RL-04: 每个 SKILL.md frontmatter 含 `name:` 与 `description:`（10×2 grep）
- RL-05: 每个 SKILL.md 含「APPROVED」与「CHANGES_REQUESTED」与「Rule 43.1」（10×3）
- RL-06: 每个 SKILL.md 清单条目 `grep -c '^- \[ \]'` ≥10（10 个全查）
- RL-07: 每个 SKILL.md 四要素标题（## 触发条件/## 审查清单/## 证据要求/## 输出合约）各 ≥1（10×4）
- RL-08: SKILL.md（主文件）`grep -c '| C30 |'`=1 且含「四级顺序」≥1（C30 四级化同步锚）
- RL-09: CRIT 42.2 行含「④ task-planner 内置 review-library 兜底池」与「均未命中=缺口」（四级化主体锚）且 CRIT `grep -c '三级检测顺序'`=0
- RL-10: 全池 10 文件 `grep -nE '1-4[0-9]'` 零命中（越界字面负断言）
- 脚本纯静态只读,bash -n 过,零仓库写入

## registry +1 行（四列对齐既有行,先 head -3 看格式）
script=selftest-review-library.sh / domain=Rule 42 质量审查兜底池（review-library） / trigger_scenarios=「Rule 42.2 四级检测第④层兜底池;10 通用质量审核技能;C30 四级化」 / dep_anchors=「review-library 10 目录;SKILL C30 四级;CRIT 42.2 四层锚」

## acceptance: 验收标准
1) `bash scripts/selftest-review-library.sh` → `Total: 10 PASS=10 FAIL=0` rc=0
2) `bash -n` rc=0
3) `bash scripts/selftest-registry.sh` Total 0 FAIL 且 rows=actual=40
4) tsv `wc -l`=41
5) `git -C <wt> status --short` 本步面=新 .sh untracked + tsv M（review-library 为 P2 存量）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/06-exec-p3s6.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3-S6
completed_steps: 逐条
files_written: 绝对路径清单
evidence: Total 行与 registry 验证输出
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
