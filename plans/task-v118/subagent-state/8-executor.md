# Checkpoint: 8-executor — task-v118 两个 selftest 锚口径扩展（v117 范式）

- 状态: COMPLETE
- 时间: 2026-10-03
- worktree: /home/terry/task-planner-skill-worktrees/task-v118

## 编辑清单（仅 2 文件，锚断言+注释+消息）

### 1. skills/task-planner/scripts/selftest-ask-default-timeout.sh（RT-08）
- 头注释 L12: `[task-v117 口径扩展] 全集 1-45` → `[task-v118 口径扩展] 全集 1-46，1-4[56] 为合法形态加白`
- 行内注释 L59-61: 同步 v118 口径扩展说明 + 注明 2026-10-03 修改原因/原行为（Rule 45.4）
- 断言 L63-64: `grep -vcE '1-45'` → `grep -vcE '1-4[56]'`（变量 a 与 b 两处）
- ok/bad 消息: `1-45 已加白 task-v117` → `1-4[56] 已加白 task-v117+task-v118`

### 2. skills/task-planner/scripts/selftest-plan-tier.sh（PT-08）
- 头注释 L11: 追加 `[task-v118 口径扩展] 字面锚 1-45→宽容 1-4[56]（frontmatter 全集具名演进 1-46，语义等价，同 v117 WF-10/PT-08 先例）`
- 行内注释 L75-76: 同步 + 注明 2026-10-03 修改原因/原行为（原=固定字面 `grep -q 'Critical Rules 全集 1-45'`）
- 断言 L77: `grep -q 'Critical Rules 全集 1-45'` → `grep -qE 'Critical Rules 全集 1-4[56]'`
- ok/bad 消息同步（1-4[56] + task-v117+task-v118）

## 验证证据

### selftest-ask-default-timeout.sh → 全 PASS
```
RT-08 PASS 越界 1-4x 字面零命中（CRIT 44 节=0 / SKILL.md=0，1-4[56] 已加白 task-v117+task-v118）
Total: 9 PASS=9 FAIL=0 (rc=0)
```

### selftest-plan-tier.sh → 全 PASS
```
PT-08 PASS SKILL.md frontmatter 索引 1-4[56]（task-v117+task-v118 口径扩展，v088 级联 1-39 后继）
Total: 32 PASS=32 FAIL=0 (rc=0)
```

### 负向自检（锚仍有牙齿）
- 操作: `sed -i 's/Critical Rules 全集 1-46/Critical Rules 全集 1-99/' SKILL.md`
- 结果: `PT-08 FAIL SKILL.md frontmatter 缺「Critical Rules 全集 1-4[56]」` / `Total: 32 PASS=31 FAIL=1` / rc=1（符合预期 FAIL）
- 还原: `git checkout -- SKILL.md`（worktree 内 SKILL.md 恢复干净态，frontmatter 回到 `1-46`）

### 还原后复跑（确认还原无误）
- selftest-plan-tier.sh: Total: 32 PASS=32 FAIL=0
- selftest-ask-default-timeout.sh: RT-08 PASS + Total: 9 PASS=9 FAIL=0

## git diff 复核
`git status --short` 仅两文件 M；`git diff --stat`:
```
 skills/task-planner/scripts/selftest-ask-default-timeout.sh | 13 +++++++------
 skills/task-planner/scripts/selftest-plan-tier.sh           |  7 ++++---
 2 files changed, 11 insertions(+), 9 deletions(-)
```
diff 内容逐行审查：仅 RT-08 与 PT-08 的锚断言/注释/消息，RT-01..07/09 与 PT-01..07/09..32 零改动，断言语义未反转（越界仍须零命中 / 索引面存在性守护不变）。

## 结论
口径扩展完成，两 selftest 全 PASS + 负向自检 FAIL 符合预期 + SKILL.md 已还原。无遗留风险。
