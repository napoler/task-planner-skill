# Checkpoint — sub:1-executor 根目录文档刷新（task-v116）

status: done（最终 8 字段块见下方）

## 修改文件（仅 worktree 内 2 个，禁改清单内）
- /mnt/data/dev/task-planner-skill-worktrees/task-v116/README_zh.md（9 处编辑）
- /mnt/data/dev/task-planner-skill-worktrees/task-v116/INSTALL_zh.md（14 处编辑）

## 六类刷新落点
1. 安装命令口径：全部 `bash scripts/install.sh`→`bash skills/task-planner/install.sh`；幽灵 flag 行重写（--target 段→「多工具软壳模型」小节 + --tools/--no-backup/--no-verify/--canonical 实 flag；--uninstall→`bash skills/task-planner/uninstall.sh`（--dry-run/--keep-canonical/--keep-backups 实 flag）；--force 行删除，升级节改为重装覆盖口径）；`bash scripts/validate.sh`→`bash skills/task-planner/lib/verify.sh`（预期输出改 `[verify] summary: N pass / 0 fail`，证据=lib/verify.sh:253）；`bash scripts/uninstall.sh`→实位
2. session-catchup.py 幽灵：README×4（:30/:46/:80/:125/:150 区段）全部→`session-catchup.ts`（bun/node）；INSTALL:61 python3 依赖行→`bun 或 node ≥18`+`jq` 两行
3. 数字簇：「13/16 变体」→「29 类（含 video/image 家族 12 类）」；「37 键」→40；「55 个脚本」→「81 项（.sh 72 个，含 42 selftest）」；「Rules 1-39」→1-45（README×2）；「5 个模板文件」→「6 个计划文件」；目录树补 knowledge-brief.md 行+模板段重写（39 模板=顶层 10+variant 29）；「1.3MB」→「2.0 MB（2026-10-02 du 实测）」
4. INSTALL 英文死链→`skills/task-planner/INSTALL.md`·`skills/task-planner/README.md`；README「英文文档」节同步改实位描述
5. 「26 个模板」类→39（以 ls 实测为准，2026-10-02 注记）；references 段同步实测 8 个（billing/cost-control 已迁出/不存在于 references/ 实测列表，据实改写）
6. 语义通顺、未重排结构；install 头段/LLM 自动安装段按多工具软壳模型（detect-tools 五工具 claude-code/zcode/opencode/cursor/continue）重写

## 实测对照（全部当日 ls/du/grep 复核）
| 口径 | 实测值 | 证据 |
|------|--------|------|
| variant | 29（12 家族） | ls templates/variant=29；grep audio/character/image/motion/multiview/physics/prompt-struct/qc/storyboard/video=12 |
| config 键 | 40 | python3 json load properties len |
| scripts | 81 项/.sh 72/selftest 42（selftest-*.sh；registry.tsv 43 行=42 selftest+表头区 1 行） | ls scripts=81；grep '\.sh$'=72；ls scripts/selftest-*.sh=42 |
| 计划文件 | 6 | init-session.sh:340 六文件循环 |
| Rules | 1-45 | critical-rules.md Rule 号最大 45 |
| 总大小 | 2.0M | du -sh skills/task-planner |
| 模板 | 39 | find templates -name '*.md'=39（顶层 10+variant 29） |
| 安装 flag | --canonical/--tools/--no-verify/--no-backup/--dry-run | install.sh case 段 |
| 卸载 flag | --canonical/--keep-canonical/--keep-backups/--dry-run | uninstall.sh:25-28 |
| verify 输出 | [verify] summary: N pass / N fail | lib/verify.sh:253 |

## 验收 grep（零残留）
`grep -n "bash scripts/\|session-catchup.py\|13 变体\|37 键\|Rules 1-39\|5 个模板文件" README_zh.md INSTALL_zh.md` → RC=1（0 匹配）
扩展幽灵 grep（--target/--uninstall/--force/VALIDATION PASSED/1.3 MB/55 个）→ 0 残留

## Scope 合规
未触碰 skills/、未 git add/commit（git status 仅 2 文件 M：README_zh.md、INSTALL_zh.md），未动 worktree 外文件（findings/progress 追加在主仓 plans/ 内按契约授权）。

## 最终 8 字段块
```
status: done
acceptance: 3/3 pass — ① grep 零残留 RC=1（bash scripts/|session-catchup.py|13 变体|37 键|Rules 1-39|5 个模板文件=0 匹配，扩展幽灵 flag/VALIDATION PASSED/1.3MB 亦 0）② 实测数字逐项对照（29 变体含 12 家族/40 键/81 项含 42 selftest/6 计划文件/Rules 1-45/39 模板/2.0MB——全部当日 ls+du+grep 复核，对照表见上）③ checkpoint 落盘（本文件，含 8 字段块）
files: /mnt/data/dev/task-planner-skill-worktrees/task-v116/README_zh.md（9 处）；/mnt/data/dev/task-planner-skill-worktrees/task-v116/INSTALL_zh.md（14 处）；追加 /mnt/data/dev/task-planner-skill/plans/task-v116/{findings.md,progress.md}
evidence: 验收 grep 命令原文 RC=1 零输出；git status --short = " M INSTALL_zh.md / M README_zh.md"；实测数字源命令输出（ls=29/81/72/42、python props=40、du=2.0M、find templates=39、Rules max=45、init-session.sh:340 六文件循环）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v116/subagent-state/1-executor.md (status: done)
findings_written: #### [sub:1-executor]
blockers: none
confidence: HIGH
```
