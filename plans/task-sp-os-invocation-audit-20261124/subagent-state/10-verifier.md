# S10 Verifier checkpoint — P3 日志取证独立复检（2026-11-24）

- 任务：task-sp-os-invocation-audit-20261124
- 执行体：S10（Verifier）
- 状态：complete（recheck 段已回写，status 由 pending S10 改为 done，并在 status_note 注明）
- 唯一产物写入：`T/scan-stats.json` 的 `recheck` 段（其余字段经 sha256 对比字节未动）

## 一、复检任务一：4 个关键数字重算

| 字段 | 权威值 | 独立重算值 | 方法 | rel_diff |
|---|---|---|---|---|
| sessions_main | 169 | 169 | `jq -r '.per_session[]|select(.kind=="main")|.session_id' parts/2026-11-18.json .. 2026-11-24.json \| sort -u \| wc -l` → 169；抽样确认 dedup 集无 `sess_subagent_*` 泄漏（grep -c=0） | 0 |
| skill_calls_sp | 0 | 0 | `sp-os-scan.sh:37` 将 SP/OS 归因字段硬编码 0；`schema-notes.md:5-7`、`report-log.md:4` 记明原始日志仅有 context.toolName、无工具入参；实测 `grep -c -E '"(input\|args\|command\|skill\|file_path)"[[:space:]]*:' zcode-2026-11-24.jsonl`=0 | 0（权威 0 且重算 0，按约定 rel_diff=0） |
| skill_calls_os | 0 | 0 | 同上（os_skills 11 名无入参可匹配） | 0 |
| openspec_cli_calls | 0 | 0 | 同上（Bash 命令字段不存在，UNATTRIBUTABLE→0） | 0 |

- **max_rel_diff = 0**（四项全一致）。
- 口径警示：by_day 各日 sessions_main=32/38/33/36/33/69/12，相加 253 是错误口径；跨日按 session_id 去重才是 169。未采用 253。
- 补充一手观察：SP/OS 技能名字符串在 11-18..11-23 日志的 `error` 字段（错误 payload 中列出的技能清单）出现，例如 `zcode-2026-11-18.jsonl` 一条 `turn.failed` 的 `error.message` 含 `- brainstorming (file: .../brainstorming/SKILL.md)`。这是错误文本、非 tool.call.started 的 skill 入参，不构成 SP/OS 调用证据；不改变上述 0 值。11-24 文件该类命中为 0，与 schema-notes 一致。

## 二、复检任务二：原始日志行抽查（≥3 条，等效判据）

任务书原文要求抽查 ≥3 条 SESSION-EVID 行对应原始日志行；盲区下 S9 产出 SESSION-EVID=0 行（`report-log.md:15-19`），空集无可抽。按等效判据从 `report-log.md` 第三节清单取 3 个主会话，实读原始行（均实读成功，无 UNAVAILABLE）：

| # | session_id | 原始文件 | 时间戳 | toolCallId | 关键字段 | 结论 |
|---|---|---|---|---|---|---|
| 1 | sess_62b55613-f4e7-43c7-a1ae-5387114eecd6 | zcode-2026-11-18.jsonl | 2026-11-17T18:57:07.432Z | 3937bfc2-0e12-4816-ace1-2d2abad7eea1 | event=tool.call.started, context.toolName=Skill, context_keys 无 skill/input/command | 技能名不可判定，不可判 SP/OS |
| 2 | sess_96b8479a-9590-43fc-a240-6ae500e14ade | zcode-2026-11-19.jsonl | 2026-11-18T23:21:07.658Z | call_3d2350c763ba4dacb2fcf7c1 | 同上 | 技能名不可判定，不可判 SP/OS |
| 3 | sess_71522e36-6ee6-4af5-91da-8e029988e700 | zcode-2026-11-20.jsonl | 2026-11-20T01:01:51.547Z | chatcmpl-tool-8818737345942d54 | 同上 | 技能名不可判定，不可判 SP/OS |

三条与 `report-log.md` 第三节登记的次数分别为 2/1/1，实测原始 `tool.call.started`+`toolName=Skill` 计数同为 2/1/1。故 62 个有 Skill 调用的主会话无一对可判 SP/OS → SESSION-EVID=0 正当；这是盲区的数据结构事实，非执行方跳过、非模型未遵守（C2）。

## 三、复检任务三：VC 与结构校验

| 检查 | 命令来源 | rc |
|---|---|---|
| VC-4 | plan-state.json vcs[] 原文 | 0 |
| VC-9 | plan-state.json vcs[] 原文 | 0 |
| VC-10 | plan-state.json vcs[] 原文 | 0 |
| `jq -e . scan-stats.json` | 合法性 | 0 |

- 5 字段实读：`sessions_main_with_sp_used=0`、`sessions_main_with_os_used=0`、`sessions_with_calls_main=0`、`session_evid_rows=0`、`verdict` 非空且双面口径（日志盲区不可判定 + 设计层驱动缺口/侧证可判定），与 `report-log.md` 第五节一致。
- recheck 回写后重跑 VC-4/9/10 仍全 rc=0（见下），totals 未被触碰。
- 字节保真：`jq -S 'del(.recheck)' scan-stats.json | sha256sum` 回写前后均为 `846f9e991107a8b9e02646fff8c1df1b7fab4c0ccc601e1fdee28c581877ec2c` → PASS。

## 四、回写后 VC 复跑（最终）

- VC-4 rc=0；VC-9 rc=0；VC-10 rc=0；`jq -e .` rc=0。
- 回读 recheck 段：`rechecker=Verifier, status=done, max_rel_diff=0, commands_n=8, sample_lines_n=3`。

## 五、留给下游 P5-P7

- `scan-stats.json` 的 recheck 段已定稿，VC-4/9/10 消费无障碍；P5-P7 可按现状继续。
- 需在最终结论中保留双面口径：日志层 Skill 99 次不可归因（既非「SP/OS 零调用」也非「SP/OS 被调用 99 次」）+ 设计层/侧证层可判定未被制度性主动调用。

## 六、blockers

- 无阻断。未验证边界：第三节余下 32 个会话原始行未逐条实读（按 ≥3 条抽查要求取证）；无日志轮转导致的 UNAVAILABLE 样本。
