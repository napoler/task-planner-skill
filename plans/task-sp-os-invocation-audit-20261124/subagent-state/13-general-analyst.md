# Checkpoint — S13 general-analyst（P5 根因裁定 H1-H3：入口 / 触发面 / 同构竞争）

status: done
task_id: task-sp-os-invocation-audit-20261124
s_unit: S13
executor: general-analyst(sonnet-1)
parallel_group: 无（P5 串行，前置 S3/S4/S5/S6 已主进程复核）

## 八字段返回
- status: done
- 做了什么: 对 config.hypotheses 的 H1/H2/H3 逐条给出二值判定（无部分确认），每条 ≥2 个本次亲自 grep/sed 盘上复核的证据锚 + 一句可复跑验证命令 + 一段 C2 口径缺陷表述；产出编码建议供主进程写 root_causes。
- 产物绝对路径: /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-rootcause-1.md（49 行 ≤100）；本 checkpoint；/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt（追加 3 行）。
- 验收: H1/H2/H3 各 3 个证据锚（均 ≥2 要求），每条字段 file:line + 命令输出；三条验证命令实测 rc=0（H1 compound / H2 compound / H3 compound，均在主进程 shell 实跑）；报告 49 行符合 ≤100；C2 口径逐句自查无「执行方跳过/模型未遵守/行为门被忽略」类归因。
- 关键结论: H1 CONFIRMED（SessionStart config.json:29-40 仅 zcode-sessionstart.sh，4 个 zcode-*.sh SP/OS 提及=0，上游 run-hook.cmd session-start 未接线）；H2 CONFIRMED（SKILL.md:114 唯一文本指针，grep -c=1，spec-mode.md:7/12/16 文本路由表，check-*.sh SP/OS 命中=0）；H3 CONFIRMED（sync-todos.sh:201-214 B1-B8 脚本带出且 SP/OS=0，todo-sync.md:28-40 六环驱动链，B6 引擎检测仅一次性；SP/OS 仅文本指针）。
- 留给下游: 主进程按报告末尾建议编码 root_causes H1-H3（defect 以 CONFIRMED 开头、process ≥61 字符）并置 config.hypotheses H1-H3 verified=true；H4/H5 由 S14 裁定（PATH 落点与伴飞字段载体坏已明确划归、未越界）；P6 方案 S15/S16 承接。
- blockers: none（所有引用锚均在只读盘上亲测复现，无失败通道）。
- confidence: HIGH（证据为 file:line 原文 + grep 计数一手只读命令；盲区 R-BLIND-1 已遵守，未用 raw.skill_calls_total=99 冒充 SP/OS 调用）。

## 判定汇总（供主进程直接读取）
| 假设 | 判定 | 锚1 | 锚2 | 锚3 | 验证命令 rc |
|---|---|---|---|---|---|
| H1 | CONFIRMED | config.json:29-40 | zcode-sessionstart.sh:3,13 SP/OS=0 | upstream-hooks.json:9-17 | 0 |
| H2 | CONFIRMED | SKILL.md:114 (grep=1) | spec-mode.md:7/12/16 | check-*.sh 命中=0 | 0 |
| H3 | CONFIRMED | sync-todos.sh:201-214 B1-B8 | todo-sync.md:28-40 六环 | planctl.py:1271 / check-dispatch.sh:580 | 0 |

## 负结果与边界
- 排除「SP/OS 技能文本没写触发要求」（using-superpowers SKILL.md:3,20、spec-mode.md:7/12/16 齐备）——缺口在驱动层不在文本层。
- C2 合规：全部缺陷表述为技能缺 hook/脚本/必选组驱动点 + file:line，无执行方行为归因。
- 未越界：H4（command -v openspec rc=1 / 绝对路径 1.6.0）与 H5（planctl.py:1271 伴飞列被 parallel 占用）仅作为交叉点提及，结论归 S14。
- 未触 C4 已否决项；未碰 T/scan-stats.json 与 T/report-log.md。

## 复跑命令（三条，实测 rc=0；REPO/ZD 替换为绝对路径后执行）
```
test "$(grep -ciE 'superpowers|openspec|using-superpowers' ZD/task-planner/scripts/zcode-sessionstart.sh)" -eq 0 && test "$(sed -n '29,40p' /home/terry/.zcode/cli/config.json | grep -c zcode-sessionstart.sh)" -eq 1 && test "$(grep -c 'using-superpowers' /home/terry/.zcode/cli/config.json)" -eq 0
test "$(grep -c 'Spec 模式触发判定' REPO/skills/task-planner/SKILL.md)" -eq 1 && test "$(grep -rliE 'superpowers|openspec' ZD/task-planner/scripts/check-*.sh 2>/dev/null | wc -l)" -eq 0 && grep -q 'L1+ 且需求模糊/多方向/规格类' REPO/skills/task-planner/SKILL.md
test "$(grep -ciE 'superpowers|openspec' ZD/task-planner/scripts/sync-todos.sh)" -eq 0 && grep -q '"task_id":"B1"' ZD/task-planner/scripts/sync-todos.sh && grep -q '结论落盘 Decisions' ZD/task-planner/references/todo-sync.md
```
