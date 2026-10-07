# sub:4-code-assistant checkpoint (S4: knowledge-brief §6 区块)

status: done

## 已完成动作
1. Read 目标模板 /mnt/data/dev/task-planner-skill-worktrees/task-v144/skills/task-planner/templates/knowledge-brief.md（原 §1-§5，69 行）
2. Read critical-rules.md:702 的 59.3 条文原文（约 1 段，含判别条款）
3. Edit 追加（纯增量，§5 表末行后插入 9 行，§1-§5 零改动）：
   - `<!-- 填写说明：... What=执行前技能扫描先于派发；Why=... 闲置状态（Rule 59.3，对应用户 R5） -->`
   - `<!-- 用户触发型判别（Rule 59.3 判别条款）：... 只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活 -->`
   - `## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）`
   - 四列空表：技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式（含 brainstorming 示例行 + comet「用户手动触发（仅提示）」示例行）

## 验证证据
- 首版 Edit 误删 §5 表末行 `{S-unit ID}` 模板行 → 已修复恢复；终版 git diff = +9/-0 纯追加（§5 表末行零改动）
- 模板文件 77 行；锚点行号：:68 填写指引注释 / :70 用户触发型判别注释 / :71 §6 区块标题 / :73-77 四列空表（:76 comet 示例行）
- grep "可用强化技能" 命中 1 处（:71）；grep "用户手动触发" 命中 2 处（:70、:76）
- git diff 模板文件：+9/-0 纯增量，§1-§5 零改动
- 负结果：git status 显示 references/critical-rules.md 亦为 M，diff 为 +22 行（59.3 条文，属前序 S-unit 落盘产物，非本 S4 改动；本 S4 未触碰该文件，符合 scope）

## 验收对照
- A1 grep "可用强化技能" ≥1 → PASS（1 处）
- A2 填写指引注释（WHAT/WHY，扫 ~/.zcode/skills 与 ~/.agents/skills，供 S-unit 伴飞技能列取值）+ 四列空表 → PASS
- A3 用户触发型判别注释行（comet 族只准写「用户手动触发（仅提示）」，禁自动代激活）→ PASS
- A4 git diff 仅该模板单文件纯增量 → PASS（模板单文件 +9/-0；worktree 内 critical-rules.md 的既有改动属他 S-unit 落盘，非本 S4 产出）
