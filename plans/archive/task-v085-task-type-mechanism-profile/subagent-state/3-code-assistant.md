# task-v085 S2 — code-assistant 检查点（SKILL.md 三处纯增量）

## S2 完成记录（2026-09-20）

**目标文件**：/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/SKILL.md
**行数变化**：545 → 549 行（净增 4 行，git diff numstat = 4 insertions / 0 deletions，纯插入零改写）

### 三处插入（全部逐字按材料包）
1. **路由表头部注记**（原 line 354 附近）：「### 路由表（按任务类型）」标题行与「**目的**」段之后、表头之前，插入 1 行：
   `> **类型适配（Rule 37）**：下表为代码组画像的默认路由；…仅裁剪代码组机制，通用守卫不变。`（+ 1 个空行，现 SKILL.md:356-357）
2. **合规清单 C25 行**：C24 行之后插入 1 行 `| C25 | 本任务已按 Rule 37 套用机制画像：… | ☐ |`（现 SKILL.md:201）
3. **Critical Rules 列表 Rule 37 行**：Rule 36 条目行之后插入 1 行 `- **Rule 37（P0）任务类型机制画像**：…（详见 references/critical-rules.md Rule 37）`（现 SKILL.md:310）

### 验收 grep 实际输出
```
$ grep -c "Rule 37" skills/task-planner/SKILL.md
3
$ grep -q 'C22' skills/task-planner/SKILL.md && echo C22-OK
C22-OK
$ grep -q '模板选取门控与沉淀' skills/task-planner/SKILL.md && echo TL15-OK
TL15-OK
$ grep -q 'C24' skills/task-planner/SKILL.md && echo C24-OK
C24-OK
$ git diff --stat -- skills/task-planner/SKILL.md
 skills/task-planner/SKILL.md | 4 ++++
 1 file changed, 4 insertions(+)
$ git diff --numstat -- skills/task-planner/SKILL.md
4	0	skills/task-planner/SKILL.md
```

- `grep -c "Rule 37"` = 3（≥3 达标：路由表注记 1 + C25 行 1 + Rule 37 列表行 1）
- `git diff --stat` 净增 4 行 ≤ 10（材料包上限），且删除 0 = 纯增量
- TL-14 锚（C22/C24 行）与 TL-15 锚（Rule 34「模板选取门控与沉淀」）均保留，grep 仍命中
- 仅写该文件 + 本检查点，未触碰 critical-rules.md（S1 产物）或其他文件

### 负面检查
- 未改写既有任何行（diff 中无 `-` 行）
- 未改动 frontmatter、模型档位、合规清单 C1-C24 既有行
- 无冲突依赖：Rule 37 行指向 references/critical-rules.md Rule 37（S1 已追加，2-code-assistant.md 确认）
