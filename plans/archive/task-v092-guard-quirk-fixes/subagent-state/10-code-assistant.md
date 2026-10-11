# Checkpoint 10-code-assistant (task-v092/S10)

status: completed（本 S10 范围内）
commit: 35cd075（worktree 分支 wt/task-v092-guard-quirk-fixes）

## 已完成里程碑
1. Read 目标文件全文 + 实测 S9 后两脚本现状（check-conflicts.sh:147/:174 单参默认形态、check-drift.sh:219 列限形态 `plan_parse_scope "$PLAN_FILE" 3`）
2. Edit template-guide.md 两行（:69 契约安全 bullet、:74 差异 bullet），+2/-2
3. worktree 提交 35cd075，`git diff HEAD~1 --stat` = 仅 template-guide.md
4. 主仓 findings.md 追加 `### S10 修复记录`；progress.md 追加 Phase 4 段（新建该段，含 S10 行）

## 改动对照（改前 → 改后）
- :74 `故 :65 的 grep 锚计数 …` → `故 §2.4「统一标题」条的 grep 锚计数 …`（行号锚→章节锚，抗插行漂移；「维持 20 不变」计数未动，留 S11）
- :69 `该区块被 check-conflicts.sh / check-drift.sh 以状态机方式提取（/ ^## ⚠️ 执行范围限制/{f=1;next} /^## /{f=0}），` → `该区块被 check-conflicts.sh / check-drift.sh 经统一库 lib/plan-parse.sh 的 plan_parse_scope 提取（check-conflicts 默认形态、check-drift 列限形态，语义权威源见库头注），`

## 验收证据
- `grep -n ':65' <worktree>/…/template-guide.md` → 0 命中（grep exit=1，commit 后复验）
- `grep -n '§2.4「统一标题」'` → :74 命中
- `git -C <worktree> diff HEAD~1 --stat` → `template-guide.md | 4 ++--`，单文件 +2/-2（≤6 行约束内）
- 主仓 skills/ 零触碰（diff 全在 worktree）；其他 worktree 零触碰

## 供 S11 的接力信息
- :74 「维持 20 不变」与 §2.3「21 个」/§2.4「应为 21」仍三方矛盾（S4 实测 grep 锚=22），S11 按 S4 归因计数修正
- S4 open_questions① 已处置：:69 状态机描述按 S9 接库后形态修正，且区分了两脚本调用形态差异（conflicts=默认单参、drift=列限）

## 未决/风险
- 无阻塞。主仓 findings.md/progress.md 为簿记写入（Rule 27），未 git 提交（plan 目录簿记按主仓惯例）。
