# S6-executor 检查点（task-v194-subagent-unit-cap）

status: done

## 任务
在 worktree 内按复审意见做 7 处精确文本修订（全部为既有行内追加或新增 1 行子弹，禁改其他内容），复跑全量 selftest。

## 环境事实
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v194-subagent-unit-cap
- branch: wt/task-v194-subagent-unit-cap
- 基线 commit: 14be073（前序单元 46.6/75.8/47.1 已落盘，开工时 git status 干净）
- 可改 3 文件：critical-rules-dispatch.md / critical-rules-research.md / critical-rules-media.md

## 7 项修订清单（old→new 逐字）
- [x] A1 判定口径补「合并单文件」反绕过（dispatch.md L128）
- [x] A2 内容类括注「约 1 篇」裁决口径（dispatch.md L124）
- [x] A3 批量小操作行后新增兜底子弹（整行新增，dispatch.md L126 后）
- [x] A4 豁免①补普查边界（dispatch.md L127）
- [x] B1 方向计数反绕过（research.md L64）
- [x] B2 方向粒度判据补 58.1 换算边界（research.md L67）
- [x] C1 集/场口径括注（media.md L12）

## 自验项
- [x] git diff 7 处落位（3 文件 / 7 insertions / 6 deletions，删除行=6 处被改行原版，无孤儿删除）
- [x] grep -c "^46\." dispatch.md = 6
- [x] grep -c "75\.8" research.md = 2 (>=2)
- [x] 全量回归 run-selftests.sh --fresh exit=0 FAIL=0

## 轮次记录

### 修订落位（Edit 逐字执行）
- 3 文件共 7 处 Edit，全部精确匹配 old 字符串，逐处成功。

### git diff 自验（原文）
```
=== DIFF STAT ===
 skills/media-planner/references/critical-rules-media.md           | 2 +-
 skills/plan-research-router/references/critical-rules-research.md | 4 ++--
 skills/task-dispatch/references/critical-rules-dispatch.md        | 7 ++++---
 3 files changed, 7 insertions(+), 6 deletions(-)
```
- 删除行(不含---): 6 ；新增行(不含+++): 7
- 6 条 `-` 行 = 6 处被修改行的「改前原文」（A1/A2/A4/B1/B2/C1）；7 条 `+` 行 = 6 处改后行 + 1 条 A3 纯新增子弹。
- 无孤儿删除（每条 `-` 均有对应 `+` 替换）；净内容=纯追加。
- 注：A1 依派发 spec 将行尾 `）。` 改为 `」）；` 后续接追加（spec 原文即 `」）；`），属 spec 指定的定界符替换，非内容删除。

### grep 计数（原文）
```
=== grep -c '^46\.' dispatch.md (期望 6) === 6
=== grep -c '75\.8' research.md (期望 >=2) === 2
```

### 全量回归（原文）
```
Total: 92 PASS=92 FAIL=0 (run=92 reused=0)
=== EXIT CODE: 0 ===
```

## 最终汇总
- 7 处修订全部落位，3 文件，git diff = 7 insertions / 6 deletions（6 删除行均为被改行改前原文，无内容丢失）。
- 锚计数：`^46\.`=6（不变）；`75.8`=2（>=2）。
- 全量回归：`Total: 92 PASS=92 FAIL=0`，exit=0（对照 S4 R3 基线 `Total: 92 PASS=92 FAIL=0`，零回归）。
- 未触碰：check-*.sh 守卫脚本、config.json、selftest 脚本、主仓、其他 worktree；无 git commit。
- 负结果：未发现其他异常；本批 7 处纯追加修订未触发任何 selftest 断言漂移（锚计数不变）。

## 最终结论
status: done
- acceptance: 7/7 修订落位 + 3 项自验全 PASS + 全量回归 92/92
- confidence: HIGH
