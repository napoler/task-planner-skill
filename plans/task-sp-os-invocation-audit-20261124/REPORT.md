# 审计报告：Superpowers / OpenSpec 未被主动调用的真相与改进方案

- 任务：task-sp-os-invocation-audit-20261124｜日期：2026-11-24｜执行体：主进程 + 多子代理隔离审计
- 状态：**方案待批，本轮不实施（D-3）**。VC-1..10 待末轮报告面审计后全 PASS。

## 一、结论先行
1. **真实情况**：窗口内（11-16 路由改动之后）没有证据显示 SP/OS 两族技能被**制度性主动调用**并用于推进。日志层因结构化日志只有 `context.toolName`、无工具入参，无法把任何 Skill 调用归因到具体技能名——因此**既不能说「SP/OS 被调用了 99 次」，也不能说「SP/OS 零调用」**。
2. **能确证的部分在设计层**：12 个应发生时点（入口 7 + 执行收口 5）全数缺 SP/OS 真实驱动门——4 个「无」（gap-1 的 GAP-1/3/6 + gap-2 的 DG-2）、8 个「仅文本提及」（gap-1 的 GAP-2/4/5/7 + gap-2 的 DG-1/3/4 + DG-5 收口仅自家部分驱动、不覆盖 SP/OS）、0 个有 SP/OS 真实驱动点；SP 16 名、OS 11 名技能的引用面均停留在 SKILL.md 文本指针。侧证 SP 计划收据 0 条、OS 产物收据 1 处（遗留 worktree、未固化为驱动点）。
3. **根因不在技能文本，在编排层驱动点缺失**：H1-H5 五条全部 CONFIRMED，每条落到具体 file:line（见第四节），无一条可归因为「执行方跳过/模型未遵守」。
4. **改进方向**：推荐方案 A（五因五驱动点），已产出 `FILE-CHANGE` + `DRIVE-POINT` 落地清单并经 critic 独立评审；待用户批准、分区授权后实施。

## 二、窗口、口径与盲区声明
- **日志窗口**：`/home/terry/.zcode/cli/log/zcode-2026-11-18.jsonl` … `zcode-2026-11-24.jsonl` 共 7 文件、1,184,652 行、`parse_bad=0`（全量扫描，非抽样）。主会话 169、子会话 2003、Skill 工具调用 99。
- **R-BLIND-1 取证盲区**：原始 `tool.call.started` 行仅含 `toolName=Skill` + queryId/turnId 等，**无 `skill`/`input`/`command`/`file_path` 字段**（三条原始行实读为证，见 T/scan-stats.json 的 `recheck.sample_lines`）。db.sqlite 与 rollout 双源亦无法补齐技能名。
- **双面口径**：日志不可判定 ≠ 设计层不可判定。设计层与侧证独立于日志盲区，结论来自驱动缺口 + 侧证，不来自日志调用数。`SESSION-EVID=0`、`sessions_with_calls_main=session_evid_rows=0` 是盲区下的正当空集（VC-10）。
- **验收定义**：「主动调用」= 被调用**且用于推进**（有可指认承接产物/流程），仅文本提及不计；ritual（调用无承接）同样因技能名不可归因无法在日志层判定。

## 三、关键数字（全部盘上复现）
| 项 | 值 | 证据 |
|---|---|---|
| SP 技能名 / OS 技能名 | 16 / 11 | T/report-design-sp.md、report-design-os.md |
| 驱动时点缺口 | 12 个（无 4 / 仅提及 8〔含收口 1 处仅自家部分驱动〕/ SP/OS 真驱动 0） | T/report-driver-gap-1.md:26（无3+仅提及4）、report-driver-gap-2.md:12/19/30/37/44 |
| Skill 工具调用 | 99（技能名不可归因） | T/scan-stats.json totals + report-log.md:4 |
| SP 计划收据 / OS 产物收据 | 0 / 1（legacy 未固化） | T/report-plans.txt:45-51、report-openspec-artifacts.txt:9-17 |
| 独立复检最大相对差 | 0（rechecker=Verifier） | T/scan-stats.json recheck |
| 全量写入越界 | 0（writes.txt 全在 PD/T 内，行数见实时台账） | VC-9 rc=0 |
| VC-2..10 | 全 rc=0 | plan-state.json vcs[] 命令逐条复跑 |

## 四、五条根因（H1-H5 全 CONFIRMED，file:line）
- **H1 入口无驱动点**：`~/.zcode/cli/config.json:29-40` SessionStart 仅挂 zcode-sessionstart.sh，全文 0 处 SP/OS；上游 hooks.json 的 `run-hook.cmd session-start` 本机未接线。
- **H2 路由触发面窄**：`skills/task-planner/SKILL.md:114` 是唯一 SP/OS 文本接线（`spec-mode.md:12/16` 同为文本路由表），无运行时脚本判定；`command -v openspec` 仅见于 selftest（非运行时）。
- **H3 功能同构竞争**：task-planner 自带机制有 `sync-todos.sh` 基线组 + check-* 脚本门驱动，SP/OS 无任何对应脚本/hook/基线组成员——自家机制有驱动而 SP/OS 无。
- **H4 OpenSpec 落点缺失**：本仓根无 `openspec/`（test -d rc=1、git log 计 0）；`openspec` 二进制绝对路径可用（1.6.0）但 `command -v` 在 Bash 下 rc=1，PATH 导出仅在 `~/.bashrc:127`（no-op 修法已排除）。
- **H5 伴飞字段载体三处断链**：编码层 s_units 无 escort 字段（`planctl.py:127-128`）；渲染层 `:1271` 把 parallel 填进第 8 列「伴飞技能」使其从不承载路径；派发门 `check-dispatch.sh:588` 无 .md token 即跳过校验。唯一泛化注入路径（路径 + 首动作 Read）三处同时断链，本轮靠 prompt 手填补偿，不可泛化。

## 五、推荐方案（方案 A；完整对比见 improvement-options.md，落地清单见 improvement-proposal.md）
- **A（推荐）**：对 H1-H5 各补一个可机器触发的驱动点——H1 SessionStart 注入 hook；H2 路由判定脚本化 + 绝对路径 CLI 探针；H3 `sync-todos.sh` 必选基线组扩 B12/B13（避开已合并 B9-B11）+ fail-closed 门；H4 目标项目根 `openspec/` 初始化前置；H5 补 escort_skills 字段（同步 schema/known 键）+ 修渲染列 + 修 `:588` 跳过逻辑。复用已验证驱动模式，不新增独立架构。
- B（最小止血）：只修 H5 + H3 —— 缓解非根治（H1/H2/H4 未解，无法让会话「主动决定用」）。
- C（统一新建 router）：过度设计——与现有门链功能重叠，可能加剧 H3 同构竞争。
- **实施边界**：D-3 本轮不实施；hook 配置、`~/.zcode/skills/**` 等保护区改动须单独立项授权；一律改 canonical 源 `<repo>/skills/`，部署位由 install.sh 派生。

## 六、交付物索引
- 计划权威源：PD/plan-state.json（派生视图 task_plan/verification/findings/progress.md 禁手工编辑）
- 原始取证：T/report-log.md、report-rootcause-1.md、-2.md、report-driver-gap-1.md、-2.md、report-plans.txt、report-openspec-artifacts.txt、scan-stats.json
- 方案：PD/improvement-options.md、improvement-proposal.md；评审：PD/subagent-state/17-critic.md
