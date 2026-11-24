status: done

# Quality Auditor Checkpoint — S4 OpenSpec 族清单、CLI 可达性与项目初始化态

## 任务标识
- S-unit: S4 / Phase P2（并行组 g-ro，只读盘点）
- Executor: agent-quality-auditor(sonnet-1)
- 需求锚：R1（真实情况）/ R4（调用不理想，设计层根因）；C2 归因口径=技能缺驱动点/门 + file:line，禁写执行方跳过
- 产物：/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-os.md（54 行）
- 伴飞技能（首动作 Read）：/home/terry/.zcode/skills/openspec-propose/SKILL.md（只读，未代激活）

## 已完成里程碑（append-only）
- T1 2026-11-24 — 读齐三文件（plan-brief v3 §A-§J / knowledge-brief §1-§7 / plan-state.json 权威源）+ 伴飞 openspec-propose SKILL.md；确认 S4 verify 验收口径与 C1/C2/C3 硬约束。
- T2 2026-11-24 — `ls -d /home/terry/.zcode/skills/openspec-*/` 实测 11 个技能目录；逐一 grep frontmatter name/description/allowed-tools/model（全部 `Bash(openspec:*)`，opus 档=propose/new-change，其余 sonnet）。
- T3 2026-11-24 — 三处 skills 目录按技能名 grep（`--include=*.md|*.sh|*.py|*.cjs|*.ts|*.json`，排除自身 SKILL.md 与 backup/archive/tmp），按文本指针/脚本/hook/模板/todo 基线组分类计数；结果=11 技能脚本/hook/模板/todo 基线组全为 0，文本指针 1-39 处；再细分文本指针来源（路由驱动/族内互引/其他）。
- T4 2026-11-24 — 读 spec-mode.md 全（§1 触发 L1+、路由表 :13-16；§1b :18-28；§2 安装引导 :34-35）、SKILL.md:114 唯一指针、skill-collaboration.md:60/68/74 探针断点；一手确认 OpenSpec 只有文本指针、无脚本驱动。
- T5 2026-11-24 — CLI 可达性复跑（probe-path.txt:4-41）：command -v openspec/comet rc=1，绝对路径 1.6.0，PATH 导出在 ~/.bashrc:127；find 实测 14 处 openspec/ 目录，本仓根无、遗留 worktree 有；发现 ZCode 已注册 11 个 /opsx:* 命令文件且正文裸名调用 openspec（opsx/propose.md:37,43,59,74,84）→ 机械断点。
- T6 2026-11-24 — 可选探针（合规）：仅 T/scratch-init/ 空目录用绝对路径 + `--tools none` 跑 `openspec init`，rc=0，产出 openspec/config.yaml + changes/archive/ + specs/；本仓根与真实项目零写入。
- T7 2026-11-24 — Write report-design-os.md（技能清单 11 行 + CLI/初始化/opsx 小节 + 可复跑命令 + 负结果报告）；复跑 VC-2 `grep -c '^[|] OS-'`=11（≥11 达标）；追加 writes.txt 一行；VC-9 复跑 rc=0。

## 验证证据
- VC-2 计数：11（命令 `grep -c '^[|] OS-' .../report-design-os.md` 实跑）。
- 报告行数：54（≤100 粒度门）；表格 11 个 OS- 行，列为安装位/触发原文/5 类引用计数/证据 file:line。
- writes.txt 追加绝对路径；VC-9 判据实跑 rc=0（无越界路径）。
- 未触碰同组他人产物（report-design-sp.md 写入时仍不存在；report-driver-gap-1.md/2.md 未改）、未改仓库受管文件、未改任何真实项目 openspec/。

## 关键发现（供 S13/S14 根因裁定参考，仅陈述证据不下定论）
- 11 个 OpenSpec 技能全部只有文本指针（1-39 处），脚本/hook/模板/todo 基线组驱动点=0（grep 三处 skills 目录分类计数）。
- 机制性断点：代理 Bash PATH 不含 ~/.npm-global/bin（probe-path.txt:10-21），裸名 openspec 不可达（rc=1），而 11 个 /opsx:* 命令文件与技能正文均裸名调用（opsx/propose.md:37 等）；协同矩阵 :60/:68/:74 规定探针失败→该族标记「不可接管」。绝对路径可用（1.6.0）但技能缺自举/绝对路径解析驱动门。
- 落点：本仓根无 openspec/（D-9 据此本轮不调用），14 处其他项目有；属设计层落地门缺失。
- 记录不一致（只读不改）：plan-state.json config.parallel_groups.g-ro=[S3,S4,S5,S8] 与 plan-brief v3 §F:60 的 [S3,S4,S5,S6,S7,S11,S12] 不符，属主进程计划编码面，供 S18 核对。

## 最终结论
S4 验收全项达标（OS 行 11≥11、5 列齐、file:line 证据、CLI/初始化/opsx 小节齐、探针合规隔离），status: done。
