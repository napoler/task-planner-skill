# S7 checkpoint — general-analyst(sonnet-1)

status: done

- unit: S7（P3）日志 schema 确认 + 扫描脚本 + 单日试跑；并行组 g-ro（只读）。
- 产物（新建，均 +N/-0）:
  - /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/schema-notes.md（27 行，≤50）
  - /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/sp-os-scan.sh（45 行，≤50，bash -n PASS）
  - /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/parts/2026-11-24.json（单日试跑产物）
- writes: 追加 4 行到 T/writes.txt（三产物 + 本 checkpoint）。

## 验收对照（逐条）
- schema-notes ≤50 行：27 行 PASS。
- scan.sh ≤50 行：45 行 PASS；纯 awk 无 Python 依赖；输入一个日志绝对路径，输出 T/parts/<日期>.json（日期从文件名提取）。
- 11-24 单日跑通：PASS，jq -e . 校验有效 JSON；落盘文件取自规范绝对路径。
- lines_scanned == wc -l：冻结同 basename 快照实跑 wc-l=76493、lines_scanned=76493，相等 PASS（活文件持续增长，逐次 wc 不同，故用快照证明计数无损）。
- 信号键名与 §H 对齐：files 级含 file/lines_scanned/parse_bad/bytes；totals 级键（sessions_main/sub、skill_calls_sp/os、escort_reads_sp/os、mentions_text_sp/os、openspec_cli_calls、with_sp/os、*_used、sessions_with_calls_main、session_evid_rows、verdict）全部照出；不可归因项置 0 + blind_spot 元数据；raw.* 保留真实原始计数（skill_calls_total=11 等）；per_session 含 session_id/kind/first_ts/last_ts。
- 盲区如实记：schema-notes 首节即「结构化日志无工具入参，无法判定调用哪个 SP/OS 技能」，附字段清单/Skill 11 次/grep '"skill":'=0/技能名 0 命中证据。

## 关键发现（供 S8/S9/S13/S14）
- **首要盲区**：zcode-*.jsonl 顶层无 input/args/skill/command/file_path；工具调用仅 event + context.toolName，无参数。grep '"skill":'=0；14 个 SP/OS 技能名全文 0 命中。Skill 工具 started=11 次仅能证明 Skill 被调用，不能证明是 SP/OS。按 C3 禁止推测补名；S8/S9 不得把「Skill 11 次」写成「SP/OS 被调用」。
- 判定路径：工具调用=`$.event=="tool.call.started"` && `$.context.toolName`；会话 id `$.sessionId`（sess_<uuid> 主 / sess_subagent_agent_<uuid> 子 / 裸 uuid=ttft 诊断同主 / session_<hex>=MCP 排除）；时间戳 `$.timestamp`（ISO8601 UTC，按 UTC+8 日切片）；父会话 `$.context.parentSessionId`。
- 单日 raw（末次落盘，活文件值随增长微变）：tool_calls_started 5135 / Skill 11 / Read 783 / Bash 3215 / Agent 109；主会话 12、子会话 109；parse_bad 0。
- 补口径可行性：rollout/model-io-sess_*.jsonl 的 response.toolCalls[].input 确有 skill/file_path/command，但文件快速轮转（实测数分钟内被替换，当前仅 3 个），无法覆盖 7 天全量；db/db.sqlite=13.1GB（主进程另探 schema）。本单元仅评估未全量。
- 11-16/11-17 日志已不在磁盘，窗口限 11-18..11-24 七日。
