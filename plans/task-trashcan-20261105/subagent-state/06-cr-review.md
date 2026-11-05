# 06 CR Review — Rule 100.6 垃圾桶机制（trash/）
- Reviewer: General Reviewer（只读）
- Date: 2026-11-05
- Object: worktree `/mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105` commit `e3f03d2`（feat(rule-100.6): 垃圾桶机制——废弃数据判废即移 trash/与检索排除）

## Verdict
**APPROVED**（无 BLOCKER/MAJOR；2 条 MINOR/INFO 级观察项，不阻断合并）

## Checklist
| # | 项 | 结论 | 证据 |
|---|---|---|---|
| 1 | 增量纪律：100.0-100.5 零改动？除 variant 两处替代与 media 指针外纯追加？ | PASS | `git diff HEAD~1 -- skills/task-discipline/references/critical-rules-discipline.md` 仅 `+` 100.6 一行（行681上下文100.5/101标题未动）。media 47.5 原文保留，仅在其后追加淘汰件处置段（`skills/media-planner/references/critical-rules-media.md:20`）。variant 两模板各 1/2 行替换（image `:26` VC-6，video `:61,:72` Phase 3/5），其余零改动；registry/.gitignore/deprecated 均追加。 |
| 2 | 替代合规：variant 两模板替代是否只改处置动作、VC 编号与验收语义保留？ | PASS | image-type VC-6 仍为 VC-6，验收方式仍含 `台账行 grep URL+归档登记`、产出仍含 `output/*.md+docs/archive/README.md`，仅处置动作改为 `判废移入 trash/`（`templates/variant/image-type.md:26`）。video-type Phase 3 门控语义句保留（`未获放行=停留 in_progress 呈用户，禁止进入 Phase 4`），Phase 5 FAIL/全PASS 流程与执行体保留，仅否决/废弃件处置动作替换（`templates/variant/video-type.md:61,72`）。 |
| 3 | 一致性：100.6↔media 指针↔variant↔deprecated 分工声明的 Rule 编号/锚词/trash 路径口径一致？ | PASS | Rule 编号统一 `100.6`/`Rule 100.6`（discipline `:681`，media `:20`，image `:26`，video `:61,72`，deprecated `:8`，selftest/registry）。锚词一致：`判废即移`/`trash/`/`<project-root>/trash/`/禁 `-failed` 式原地重命名。分工互链：discipline 100.6 声明 `Rule 73.5 deprecated.md=内容/文档条目级…本条=文件级/物理稿件…经指针互链`（`:681`）；deprecated 声明反向分工（`:8`）；Rule 73.5 存在（discipline `:475`），交叉引用有效。 |
| 4 | 语义正确性：trash/ vs tmp/ 区别与 Rule 100.1 清理链事实一致？检索排除可执行？ | PASS | 100.6 明确 `tmp=临时可再生随任务清（100.1 清理链），trash=废弃但可找回跨任务保留`（discipline `:681`），与 100.1 `worktree remove…+孤儿扫描`/100.2 tmp=gitignore+100.3 机械写豁免事实一致（discipline `:676-678`）；trash 不随任务终态清理与“不物理删除(mv)”匹配。检索排除条款具象到 `Explore/grep/glob/ls 扫描/素材选型/数据回找`，可执行（行为约束+路径排除语境），machine 面由 .gitignore+流程纪律承载，符合 100.6 “判定面=LLM 行为+文本锚；机器面=静态锚断言”声明。 |
| 5 | selftest 质量：FD-01 锚按真实文本仍有效？FD-06 负断言判定可靠？ | PASS（附 MINOR 观察） | FD-01 用 `grep -qF '100.6 垃圾桶机制'`，真实标题为 `**100.6 垃圾桶机制（trash/…）**`（discipline `:681`），子串匹配有效且守护目标成立（`scripts/selftest-file-disposal.sh:45-49`，实跑 PASS）。FD-06 扫描 `当日归档（-failed` 在 image/video/media 三文件计数求和=0，实跑 `PASS FD-06…image=0 video=0 media=0`（脚本 `:81-94`）。**MINOR**：FD-06 依赖该精确字面覆盖“处置动作正向表述”，若未来换写法（如 `落选件当日归档（-failed`）可能漏检；但当前变更已消除该字面，且脚本 diag 打印命中行，风险可控。 |
| 6 | 范围越界：8 文件全部服务垃圾桶机制？ | PASS | 8 文件均与 Rule 100.6/trash 落地直接相关：discipline 100.6 条款、media 47.5 淘汰处置指针、variant image/video 处置动作、deprecated 分工声明、.gitignore `trash/`、selftest FD、registry 登记（`git show --stat`）。无无关功能/重构/格式化扩散。 |
| 7 | gitignore 安全：trash/ 行不影响既有 tmp/ 等规则？ | PASS | `.gitignore` 仅追加注释+`trash/`（`git show -- .gitignore`：`+` 3 行，在 `tmp/` 块后追加）；既有 `tmp/`、`plans/.active_plan`、`.drift-rhythm/` 等规则未改动；`trash/` 为独立顶层模式，不与 `tmp/` 冲突。 |

## Findings
- **MINOR (FD-06 负断言覆盖面)**：`scripts/selftest-file-disposal.sh:81-94` 以字面 `当日归档（-failed` 判定“处置动作正向表述”清零，能守住本次替代形态，但对未来同义改写（不含 `当日归档（` 前缀）非穷尽。建议后续若扩展守护，可补充 `-failed/-superseded` 在“归档/处置”语境的更宽正则（需避免误伤否定句“禁…-failed”）；当前非阻断。
- **INFO (FD-04a 锚粒度)**：FD-04a 仅断言 image-type 含 `trash`（`:53-56`），未像 FD-04b 要求计数≥2；image VC-6 当前仅 1 处 `trash/`，语义足够，但锚较宽。可选增强为计数≥1 且同语境词（如 `Rule 100.6`）双锚；非必须。

## Evidence commands
- `git log --oneline -1` / `git show HEAD --stat` / `git show HEAD --unified=5`（worktree `/mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105`）
- `bash skills/task-planner/scripts/selftest-file-disposal.sh` → `Total: 8 PASS=8 FAIL=0`
- 关键锚 grep：discipline `100.6`/`73.5`（`:681/:475`），media `:20`，variant `image:26 video:61,72`，deprecated `:8`，.gitignore `trash/`

## Conclusion
变更满足纯增量+定点替代+跨文件分工一致+trash/tmp 语义区分，FD 自测 8/8 绿；建议合并。