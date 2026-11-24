# S9 checkpoint — general-analyst(sonnet-1)

status: done
time: 2026-11-24

- unit: S9（P3）逐会话推进证据 + 回写 scan-stats.json 5 字段；前置=S8（全量扫描，主进程复核通过）；本轮只读调研，仅写 4 个指定产物。
- 做法：全部取证直接消费 S8 已复核产物（scan-stats.json / parts / schema-notes / R-BLIND-1 / driver-gap-1,2 / plans / openspec-artifacts），未重算全量、未改任何 skills/agents/hooks/配置。

## 产物（均 +N/-0，路径已追加 T/writes.txt）
- /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-log.md（86 行，≤100 硬限）：①SP/OS 族 used/ritual 理想判据表 + 盲区不可应用声明；②SESSION-EVID 0 行 + 消歧；③「有 Skill 调用但技能名不可判定」主会话前 35 个；④最近 12 个主会话时间线；⑤verdict 双面口径。
- /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json：仅回写 totals 的 5 个字段（python3 -I 精确文本替换，每键断言唯一命中 1 次）——sessions_main_with_sp_used=0 / sessions_main_with_os_used=0 / sessions_with_calls_main=0 / session_evid_rows=0 / verdict=双面一句话。其余字段字节未动。
- /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt：追加本轮 3 条产物路径。
- /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/9-general-analyst.md（本文件）。

## 验收自检（逐条实跑，均 rc=0）
- VC-4（plan-state vcs 原文 jq -e，含 verdict!=null and verdict!="" 与 definitions!=null）：rc=0。
- VC-10（sessions_with_calls_main == session_evid_rows，两者皆 0）：rc=0。
- VC-9 写入范围：writes.txt 全部路径均位于 PD/ 或 T/ 前缀内 → 预期 rc=0（见末次实跑）。
- report-log.md 行数：wc -l = 86（≤100）。
- scan-stats.json 合法 JSON：jq -e . → rc=0。
- 未动字段抽查：sessions_main=169 / sessions_sub=2003 / per_session=2172 / raw.skill_calls_total=99 / files=7 / recheck 仍 status=pending S10（rechecker=null、commands=[]、max_rel_diff=null、sample_lines=[]）——全部与 S8 一致。

## 关键判定与口径（供主进程/S10）
- 5 字段填 0 的依据：盲区下 SP/OS 技能名不可归因 → 经 SESSION-EVID 判 used 的会话数=0；skill_calls_sp/os 已被 S8 置 0 → sessions_with_calls_main（SP+OS）必为 0；session_evid_rows 必须与之一致满足 VC-10。与 S8 全部 0 字段自洽；填非零会矛盾。
- §H② 消歧：SESSION-EVID 行的「Skill 调用」按 SP/OS 专属理解，故 0 行；「有通用 Skill 工具调用但技能名不可判定」的 62 个主会话单列为独立章节，不计入 SESSION-EVID 与两个 SP/OS 专属计数。若按通用 Skill 理解会得到 62 行并与 S8 冲突——按 §H 专属口径裁决。
- verdict 两面：日志层不可判定（不可写成 SP/OS 零调用，也不可写成 99 次 SP/OS 调用）；设计层 12 驱动时点缺失/仅文本提及 + 侧证（SP 收据 0、OS 收据 1 且未固化）可判定「未被制度性主动调用」。两面都写，未二选一隐瞒。
- blockers：main 且 skill>0 会话实际 62 个 > 35 软阈值，report-log.md 第③节按硬限只列前 35 个，余 27 个未逐条列出（完整清单可 jq 复跑：`.per_session[]|select(.kind=="main" and .skill>0)`）。详单不影响 5 字段结论（这些会话技能名均不可判定）。

## 留给 S10（Verifier）的注意事项
- recheck 段完全留白未动，等你按 §H 写 rechecker=Verifier / commands[] / max_rel_diff / sample_lines[]，勿被本轮写入误导。
- 复检 4 关键数字务必用跨日去重口径：sessions_main=169、skill_calls_sp=0、skill_calls_os=0、openspec_cli_calls=0；按日相加会得 253(main) 致误判 >1%。盲区 3 项在 S8/S9 一致为 0，max_rel_diff 应为 0。
- 11-24 为活文件（UTC+8 切片起 11-23T16:00Z），其主会话 last_ts 落在 11-23T16:00Z~21:59Z，按 last_ts 排序复检时间线时勿误判「11-24 无会话」。
- 复检 VC-4/VC-10 用 plan-state.json vcs[] 原文命令，本轮已 rc=0；report-log.md 86 行、verdict 双面口径已落盘。
