# S8 checkpoint — general-analyst(sonnet-1)

status: done

- unit: S8（P3）全量运行与汇总；前置=S7（已验证 sp-os-scan.sh + schema-notes.md）；本轮只读。
- 产物（均 +N/-0，路径已追加 T/writes.txt）:
  - /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/sp-os-assemble.sh（97 行，≤100；bash -n PASS；纯 bash+jq，无 Python）
  - /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json（§H 结构；14 顶层键）
  - /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/parts/2026-11-18.json .. 2026-11-24.json（7 件，11-24 为复跑覆盖）

## 验收对照（逐条）
- 7 文件全扫：PASS。循环调用 S7 sp-os-scan.sh，逐日产出 parts；11-24 由 76797 行版本刷新为 79085 行版本。
- files 结构：PASS。7 项，每项 file(绝对)/lines_scanned/parse_bad/bytes，11-18..11-24 逐一覆盖。
- VC-3 verbatim 实跑 rc=0（true）：files[-7]!=null、全部 lines_scanned>0、parse_bad 数值且 0 ≤ 5% 阈值、七个绝对路径全命中。
- totals 键齐全：16 键（§H 实际列出 16 项，公告写 15；取全集，满足「全部键必须存在」）。盲区 9 项=0；S9 回写 5 项=null（sessions_main_with_sp_used/os_used、sessions_with_calls_main、session_evid_rows、verdict）；sessions_main=169、sessions_sub=2003 为真实跨日去重计数。
- raw 真实：tool_calls_started 80228 / skill_calls_total 99 / read_calls_total 11565 / bash_calls_total 50334 / agent_calls_total 2015；by_day 逐日分布已写入 raw.by_day 与顶层 by_day。独立 grep 抽核 11-18（16=16）、11-24（11=11）与 part 完全一致。
- blind_spot 明确：note 逐字写「结构化日志无工具入参，无法归因 SP/OS 技能名；raw.skill_calls_total 只证明 Skill 工具调用次数，不等于 SP/OS 主动调用。」
- definitions：SP 16 名 + OS 11 名 + CLI token + 11 条信号判定原始模式，来源 T/schema-notes.md (S7) 与 knowledge-brief §6。
- per_session：2172 条（169 main + 2003 sub），按 session_id 跨日去重、first_ts 取 min / last_ts 取 max / 工具计数累加；字段 session_id/kind/first_ts/last_ts/skill/read/bash。
- recheck：占位对象（rechecker=null、commands=[]、max_rel_diff=null、sample_lines=[]、status=pending S10）。
- VC-4 / VC-10 在 S8 阶段预期 rc=1：因 5 个 S9 回写字段按 §H 置 null；S9 回写后应转 rc=0（sessions_with_calls_main 与 session_evid_rows 同时置 0 即满足 VC-10）。

## 一手数字（可复跑：`jq -r ... T/scan-stats.json`）
- 扫描总行数 1,184,652（11-18 258826 / 11-19 143372 / 11-20 201626 / 11-21 193160 / 11-22 154612 / 11-23 153971 / 11-24 79085）；parse_bad 全 0。
- 6 个归档日 lines_scanned == wc -l 精确相等；11-24 为活文件，扫描后继续增长，复核时 wc -l=79178（+93），非计数误差。
- 按日 Skill 调用（仅工具次数，非 SP/OS）：16/19/16/9/6/22/11；按日 Bash：14017/6220/7119/7047/6380/6253/3298；按日主会话：32/38/33/36/33/69/12。

## 口径决策与不确定性（供主进程/S9/S10）
- **§H vs 派发摘要冲突已按 §H 裁决**：派发摘要一处称 sessions_main/sub「置 0 留待 S9（S8 先 null）」，但 §H 定义为「窗口内有记录的主/子会话数」且 S9 verify 只回写 5 字段；若置 null 则终验 VC-4 `.totals.sessions_main != null` 必 FAIL。故本单元置真实去重数（169/2003），并在 scan-stats.json 的 s8_notes 留痕。若主进程坚持改 null，仅需改 jq program 两行后重跑。
- **盲区如实，不归因执行失败**：Skill 工具 99 次是唯一可量化调用强度数据；无任何日志证据表明其中哪些（若有）属于 SP/OS。禁写「SP/OS 被调用 99 次」，也禁写「SP/OS 零调用」——后者同样未被证明。
- S9 需用 report-log.md 的 SESSION-EVID 行标注「有 Skill 调用但技能名不可判定」的会话，并把 sessions_with_calls_main/session_evid_rows 按同一口径回写（盲区下建议同为 0）以满足 VC-10。
- S10 复检 4 个关键数字时：sessions_main=169 来自跨日去重，若按日简单相加会得到 253（main）与 2028（sub），须用同一去重口径复算，否则会误判差异超 1%。
