# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1: 强化四文件体系（task_plan/findings/progress/knowledge-brief）作为主代理↔子代理数据流转交互协议的重要性；更好交互+知识积累，尤其调研类；调研产出罗盘沉淀到知识库文件
- R2: 根治前轮实证缺陷——调研子代理被派发 prompt 明确禁写 findings.md（「主进程回填，你只写检查点」），知识只停检查点

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 部署位 critical-rules.md（22.4a/22.5/22.8/19.1 原文） | /home/terry/.zcode/skills/task-planner/references/critical-rules.md:169,172,176-181,110 | ✅ | ## 缺陷根因链 |
| 派发模板 §2 契约块 | /home/terry/.zcode/skills/task-planner/templates/subagent_dispatch.md:21-24 | ✅ | ## 现状事实 |
| check-dispatch.sh 结构 | 同名 scripts/:1-37 + get_mode/KQ3 段 | ✅ | ## 现状事实 |
| check-3file-gate.sh 信号面 | 同名 scripts/:12-108（ledger 主信号+mtime 兜底） | ✅ | ## 现状事实 |
| knowledge-brief 模板五段 | templates/knowledge-brief.md:1-62（§1-§5） | ✅ | ## 现状事实 |
| rule 预留账本 | plans/.rule-reservations.jsonl（58=v142 已落/59=v144/60=本任务） | ✅ | ## 编号与并行现状 |

## 缺陷根因链（Rule 31.2 — 前轮用户指出缺陷的归因）
- **现象**：videop1 调研子代理被 prompt 明确告知「findings.md（主进程回填，你只写检查点）」→ 守约不写 findings；两检查点 17.7KB/12.6KB 实质产出，findings.md 43 行 0 个 `[sub:]` 小节
- **直接原因**：派发 prompt 手写了过时契约措辞（2026-09-27 task-v091 B-2 之前的「主进程统一回填」旧制）
- **根因（5 Whys）**：① 为何子代理不写？prompt 禁止 → ② 为何 prompt 禁止？主进程派发时自由措辞收窄契约 → ③ 为何收窄能生效？check-dispatch.sh 只校验三文件路径存在+返回字段+checkpoint 路径（:2-4），不校验读写契约措辞语义 → ④ 为何守卫不查措辞？22.4a 只要求 prompt 含三文件路径，未强制契约原文/同语义引用 → ⑤ 为何无此要求？B-2 修订只改了规则正文，未同步派发侧机器守卫（机制面缺口）
- **类别**：规则缺位+机制面缺口（守卫盲区）
- **修正路由**：Rule 60.2 契约不可收窄禁令 + check-dispatch 措辞 lint（本任务 Phase 1/2）

## 现状事实（一手验证，Phase 0 侦察）
- 22.4a（deployed critical-rules.md:169）：findings.md 对子代理=可读可写（仅追加 `#### [sub:{seq}-{type}]` 小节），B-2 澄清「追加由子代理**必做**；主进程仅在子代理未自写时兜底回填；禁止双侧同写同一锚点」
- 22.5（:172）：子代理返回 30s 内主进程 Read 产出 + 复核/回填双通道（自写→复核替代回填）
- 22.8.2 T2（:178）：每次调研得出结论即落检查点——检查点=防上下文易失的持久化层，与 findings 自写是**叠加义务**非二选一
- 派发模板 §2（subagent_dispatch.md:21-24）：三文件契约行齐备（task_plan 只读/findings 可写=仅追加/progress 仅追加），**缺 knowledge-brief 行**（kb 仅在 22.4 材料包摘要条款中「存在时应引用」）
- check-dispatch.sh：cmd_pretool/cmd_check 双入口 + scan_missing 三文件身份判定（v0910 改造）+ KQ3 三项增量检测（v075：字符数/打包/步骤枚举）全挂 get_mode() 档位（enforce/warn/off），「只增不改既有分支」范式在位
- check-3file-gate.sh：主信号=ledger-*.jsonl 锚点后行数（:89-98），mtime 兜底（:108+）；v067 起认 6 文件但不校验 kb 增量
- ledger-append.sh 事件枚举：phase_complete/progress/error/gate_block/attest/note（无 kb_distill）
- knowledge-brief 模板五段：§1 速览/§2 已验证事实/§3 文件锚点/§4 易错点/§5 S-unit 材料包索引——§2/§3 设计为「执行期各 S-unit 完成后持续回填」但无强制条款与门控
- SKILL.md 产出落盘映射表（:105-120）：六类产出全进 findings，无 knowledge-brief 行

## 编号与并行现状（Phase 0 侦察）
- Rule 58=v142 已落 master（a7c01a8，主动解决问题泛化）但**未同步部署位**（repo 653-690 行 deployed 无）；v143 预留的 58 被抢占，其落地必改号
- Rule 59=v144 预留（拆分粒度硬门+技能伴飞）；**v144 worktree 已出现**（a7c01a8 基点），会话在飞
- 本任务已 `rule-reserve.sh reserve 60`（note 提醒 v143 避让）；v144 scope 与本任务重叠 check-dispatch/模板/kb 模板面
- 双 worktree 在飞：/mnt/data/dev/task-planner-skill-worktrees/task-v143、task-v144

## 设计决策（Phase 1 输入）
- Rule 60 六子条草案（标题：四文件罗盘数据流转与调研知识沉淀纪律）：
  - 60.1 定位：四文件=主子代理数据流转唯一协议介质；RAM/Disk 隐喻；恢复读序 4 文件化
  - 60.2 契约不可收窄：四文件读写契约与 22.4a 同语义强制；收窄词黑名单 ∧ 缺 append 锚点双条件判定；检查点与 findings 自写=叠加义务
  - 60.3 调研双落盘：findings 自写小节（22.4a 既有）+ 主进程 22.5 蒸馏 kb §2/§3/§4；Handoff 落点列双锚 `findings锚|kb:§N`
  - 60.4 消费闭环：调研型派发强制引用 kb §锚（升格 22.4「应引用」）；联动 55.1 复用前置禁从零重调研
  - 60.5 知识增量门控：调研型 Phase complete 前 kb 增量（ledger kb_distill/mtime）；gate --require-kb；豁免须登记
  - 60.6 机制：零新 config 键 + selftest-four-file-dataflow.sh + C41
- kb 主进程单写者理由：结构化底座供派发消费，并行直写破坏 §1-§5 结构（B-2 同构）；findings 子代理自写语义不动

## Resources
- 部署位技能根：/home/terry/.zcode/skills/task-planner/
- 仓内技能根：/mnt/data/dev/task-planner-skill/skills/task-planner/
- rule-reserve.sh：reserve/check/next/land/release 五命令，账本 plans/.rule-reservations.jsonl
- videop1 实证物：/mnt/data/dev/videop1/plans/task-videop1-flow-overhaul-001/（findings.md 43 行/检查点 2 件/.dispatch-inflight 在飞）

## Phase 1 产出锚（worktree critical-rules.md，Rule 60 已落地 2026-10-08）
- `### 60` 标题行 ：694；60.1 定位 ：698；60.2 契约不可收窄+lint 规格 ：700；60.3 调研双落盘 ：702；60.4 消费闭环 ：704；60.5 kb 增量门控 ：706；60.6 机制 ：708
- 纯增量验证：git diff = +18/-0（既有 Rules 原文零改动，36.5 ✓）
- worktree 绝对路径：/mnt/data/dev/task-planner-skill-worktrees/task-v145/skills/task-planner/references/critical-rules.md

## Issues Encountered
- **双 sid 错位写拦**（2026-10-08，已解）：SessionStart 哨兵 sidkey=45fc6cc1 ≠ init-session env sid=afd0b28e，写守卫按 45fc6cc1 解析时命中全局旧指针 task-v142 → 计划 mtime 早于哨兵 → 拦 worktree 写入。修法=set-active-plan.sh set task-v145-four-file-dataflow --sid 45fc6cc1（D10'' attestation 仲裁放行）。**登记 deferred**：哨兵/指针/env sid 三方 sidkey 统一属 fix-pointer-race 同族遗留（RC 系），另立项
- **check-plan-dispatch S-unit 表解析口径**（2026-10-08，已适应）：表头须字面 `| ID |` 开头+含「执行体」列、数据行 `| S<n> |`、执行体=awk 第 4 字段、时长格式 `NNmin`——初版计划表用 `| S-unit |` 表头+S-1 编号+≤15min 格式三连不识别（attest 两轮拦下后对照脚本源码修正）

#### [sub:2-S1-executor] check-dispatch 契约收窄 lint（Rule 60.2）实测

- 实现（worktree `skills/task-planner/scripts/check-dispatch.sh`，git diff **+63/-0 单文件**，既有分支零改动）：
  - 新增 `scan_contract_narrowing()`（:152-175）：双条件 ∧ 缺一不判——A(收窄词)= 某行含「只写检查点」或同行「主进程回填」+紧随否定续文（你只|不用写|无需写|不必写|禁止写|不要写）；B(缺 append 锚点)= 全文不含 `#### [sub:` 或 `可写=仅追加`。A ∧ B → 输出一行前缀 `[dispatch-contract]`（含 Rule 60.2 指引）。
  - 接入点：`cmd_check` 缺项通过后追加（stdout 一行 + exit 1，:309-317）；`fine_grain_checks` ⑥（stderr 告警 + 计入 hits，:471-482）→ 复用既有档位管线（enforce=exit 2 / warn=计数文件 `task-planner-dispatch-warn-<sid>` / off=跳过）。
  - 头部注释按仓内惯例补 [2026-10-08 task-v145 S-1] 修改说明段（What+Why+Rule 60.2 锚）。
- 实测证据（fixture 全在 /tmp，未入仓）：
  - 负样例 `/tmp/v145-neg-prompt.md`（三文件路径 + 「findings.md（主进程回填，你只写检查点）」无锚点）→ `check` 输出 `[dispatch-contract] 🚫 ...` exit=1；enforce `pretool` exit=2。
  - 正样例 `/tmp/v145-pos-prompt.md`（含 `可写=仅追加` + 「主进程兜底回填」）→ `check` exit=0 放行，无 `[dispatch-contract]` 行。
  - 回归：合规 prompt `/tmp/v145-ok-prompt.md` 改动前后 `check` 输出一致（空 + exit 0）；`bash -n` SYNTAX_OK。
  - 误报守卫（全放行 exit 0）：edge1「主进程回填」无否定续文；edge2「只写检查点」但含 `可写=仅追加`；edge3 否定续文在「主进程回填」之前（按规格「紧随其后」不判）。
  - 回归 selftest：selftest-dispatch / dispatch-grain / fine-grain-steps / conclusion-discipline / tier-b 全 FAIL=0 rc=0。
- 边界（如实）：收窄词黑名单按 60.2 窄化定义（「主进程回填」须同行+紧随否定续文），跨行共现或否定在前不判（降误报方向，可能漏报非典型收窄措辞——由 Rule 60.2 文本条款覆盖）。

#### [sub:2-S2-general-purpose] 3file-gate --require-kb + ledger kb_distill（Rule 60.5）实测

- 实现（worktree `skills/task-planner/scripts/`，两文件纯增量）：
  - `check-3file-gate.sh`（git diff +68/-5）：新增可选旗标 `--require-kb`——参数解析先剥离旗标再取首个位置参数（不传时 `PLAN_ARG=$1` 与改动前逐字节一致，既有 findings/progress 判定分支零改动）；新增 `kb_distill_activity()`（与 `ledger_activity` 同锚点/同 awk 提取，多一个 `"event":"kb_distill"` 字段过滤）；第 5 条件 = kb 存在 ∧（ledger 锚点后 kb_distill 行 ∨ kb mtime 晚于锚点；无锚点退化 findings_stale 阈值），不满足 exit 1 输出 `[3file-gate] kb 增量缺失（Rule 60.5：调研型 Phase 需 knowledge-brief 蒸馏或豁免登记）`。头部注释按惯例补 [2026-10-08 task-v145 S-2 Rule 60.5] What+Why+兼容说明。
  - `ledger-append.sh`（git diff +11/-1）：`VALID_EVENTS` 追加 `kb_distill` 为第 7 项（既有 6 项零改动）；usage 经 `${VALID_EVENTS}` 自动同步；头部枚举注释与修改说明同步。
- 实测证据（fixture 全在 /tmp，未入仓；真计划目录基线 = exit 0 空输出存 /tmp/v145-gate-baseline.out）：
  - T1 沙箱无旗标 → PASS exit 0；T2 `--require-kb` 且 kb 旧+无 kb_distill → `[3file-gate] kb 增量缺失（Rule 60.5…）` exit 1；T3 旗标前置（`--require-kb <dir>`）→ 同 exit 1；T4 `touch` kb → exit 0；T5 重置 kb 旧 + `ledger-append kb_distill` → exit 0。
  - T6 非法事件 `bogus_event` → `invalid event 'bogus_event' (allowed: … kb_distill)` exit 2；T8 `--help` 枚举含 kb_distill；T7 kb 文件缺失 + `--require-kb` → exit 1 Rule 60.5；T9 锚点前 kb_distill 行 + kb 旧 → exit 1（锚点语义正确，非任意 kb_distill 即放行）。
  - 回归：真计划目录无旗标改动前后输出逐字节一致（diff IDENTICAL, exit 0）；`bash -n` 两脚本 SYNTAX_OK；`selftest-knowledge-brief.sh` 16/16 PASS（T5a '6 planning files' 串保留、T5b `^for f in .*knowledge-brief`=0 未破坏）。
- 边界（如实）：无 Started 锚点时 kb mtime 退化用 `findings_stale_minutes`（无 kb 专属阈值，复用既有 config 键，Rule 60.6 零新 config 键）；kb_distill 仅作语义信号之一，mtime 分支仍可单独放行（与 findings/progress 同「主信号+兜底」范式）。

#### [sub:4-S1-code-runner] 全量 selftest 回归：master 基线 vs wt/task-v145（57+57 脚本）

- 运行：两处各 57 个 `selftest-*.sh` 逐一 `timeout 120 bash`（cd 各自 scripts 目录，只读），摘要 → `/tmp/v145-regression-master.out`、`/tmp/v145-regression-wt.out`（行例：`selftest-active-plan.sh exit=0 dur=11771ms | Total: 29 PASS=29 FAIL=0`）；全量日志 → `/tmp/v145-regression-{master,wt}-logs/`。
- 汇总：master 15 nonzero / FAIL 总 21；worktree 15 nonzero / FAIL 总 22；15 个 nonzero 脚本清单两侧完全一致；14 个脚本 FAIL 行逐字一致（计数相同）。
- 唯一计数差异：`selftest-iteration-persistence.sh`（master 17/1 → worktree 16/2，增量 IP-14「critical-rules.md 57 块尾「58.x」=8（应 =0，58 号被顺手创建）」）。
- IP-14 归因（证据）：worktree 版该脚本与 merge-base a7c01a8 版 md5 相同（`bdae7356…`，本任务净改动 merge-base 三点 diff 不含它）；`git archive a7c01a8` 全树展开到 `/tmp/v145-baseline-check` 复跑 = `Total: 18 PASS=16 FAIL=2`（IP-14/IP-15 FAIL 逐字一致）→ 该 FAIL 任务开始前已存在（worktree 基线脚本旧口径 `^58\.`；master 主线已做「58→59 级联演进」，见 master 版注释「2026-10-07 task-v143 合并级联演进」）→ 非本任务引入。
- 本任务引入 FAIL 数 = 0：worktree 侧 22 条中 21 条与 master 逐字一致（13 条 `config properties=42 应 40` 系 v141/v142 演进后旧脚本期望值落后，两树 config.json md5 相同 `bf2b5e7c…`；periodic-review 5 条 Rule 57 落点缺失；registry T02；RC-15；SR-12——均 master 既有），1 条 IP-14 复现证明预存在。
- 新增脚本 `selftest-four-file-dataflow.sh`：18/18 PASS exit 0（FF-01..FF-18 全 PASS，日志 `/tmp/v145-regression-wt-logs/selftest-four-file-dataflow.sh.log`）。
- 零修改：两处 git status 跑前/跑后一致；`plans/.active_plan` 等 M 文件 mtime ≤ 02:09（早于 03:0x 套件运行时刻）；未触其他 worktree（task-v143/v144）。
- 负结果（如实）：worktree 缺 master 侧 `selftest-evidence-goal-gate.sh`、registry.tsv 第 57 行两树指向不同脚本（evidence-goal-gate vs four-file-dataflow）——系分叉基线差异，非本任务所为；最长脚本 final-gate-hash 27.5s、vc-gate 18.8s 均远低于 120s 上限，无 timeout 发生。

#### [sub:5-align] task-v145 文档改动对齐审查（alignment-review，Rule 42.6.2）— 裁决 APPROVED

审查对象：wt/task-v145 相对 a7c01a8 的三文档改动（`critical-rules.md +18/-0`、`SKILL.md +3/-0`、`templates/subagent_dispatch.md +1/-0`；git diff --stat a7c01a8..HEAD 三文件 22 insertions, 0 deletions；工作树 clean）。

维度逐条结论（维度覆盖 14/14，含可补强 2 项）：
- 引用完整性（P0 级维度）PASS：Rule 60 全部跨条引用语义与被引条款实际一致——
  - 60.1→19.3（critical-rules.md:698 引 19.3「恢复会话先读三文件」=task_plan→progress→findings，:112 实证；扩展第 4 步 knowledge-brief 语义相符）
  - 60.2→22.4a（:700 引契约 task_plan 只读/findings 可写仅追加/progress 仅追加，与 :169 22.4a 逐项一致）+22.8（检查点，:176-181「检查点落盘与断点重试协议」相符）
  - 60.3→22.5（:702 引「22.5 复核时蒸馏」，:172 22.5「子代理返回 30s 内主进程必须 Read 实际产出并复核/回填 findings」相符）+22.4a B-2（:169「[2026-09-27 task-v091 B-2] 单写者澄清」存在）
  - 60.4→22.4（:704 引「brief 存在时应引用」，:166 22.4「brief 存在时材料包摘要应引用 … §1-§5」相符）+55.1（:617「复用前置检查（reuse-first check）」相符）
  - 60.5→19.2（:706 引「19.2 双条件（progress 回填 + findings 增量）」，:111 19.2「① progress 段回填 ② findings 本 Phase 实质增量」相符）
- 术语一致性 PASS：「四文件」7 处、「知识底座」3 处（critical-rules:696/698 + 模板:26）、「双落盘」4 处（SKILL:117/210/316 + critical-rules:702）、「蒸馏」4 处（同上）——三面（条款/SKILL/模板）口径统一，无旧措辞残留（如「三文件」未与四文件混用为同义）。
- 守卫锚与被守护对象级联（P0 级）PASS：C41 描述机器面与脚本实现名逐一命中——`check-dispatch.sh` 契约措辞 lint=scan_contract_narrowing（:160 定义/:309-317 cmd_check 接入/:471-482 fine_grain）、`check-3file-gate.sh --require-kb`（:35 旗标解析/:126 kb_distill_activity/:173-197 第 5 条件）、`ledger-append.sh kb_distill`（:28 VALID_EVENTS 第 7 项）、`selftest-four-file-dataflow.sh` 在位（scripts/，8477B，selftest-registry.tsv:57 已登记）。
- 结构对齐 PASS：Rule 60 标题行（:694）格式=Rule 57（:642）/58（:656）同构「（P0 — task-vNNN，目标：…；判定面=…、零新 config 键；衔接 Rule …，既有 Rules 原文零改动）」；C41（SKILL:210）紧接 C40（:209），无本任务引入的跳号。
- 既有内容零删改 PASS：三文件 diff 仅 `+` 行，0 删除行（`git diff … | grep -E '^-[^-]'` = NO_DELETIONS）。
- 索引/登记联动 PASS：selftest-registry.tsv:57 登记新守护，编号与实际实体一致。
- 多副本/多部署位同步：本阶段不判（部署位同步属 Phase 5 / VC-9，合并前预期未同步，已登记 task_plan:61/145）。
- 越界自检 PASS：三文档改动全部落在 task_plan scope_files 声明面内，未触范围外文件。
- 静态守护实测：`bash scripts/selftest-four-file-dataflow.sh` → Total 18 PASS=18 FAIL=0 exit=0（FF-01..FF-18，含 FF-15 config 零新键 properties=42、FF-16 60 块尾无 61.x 前向防线）。

非阻断观察（P2，均非本任务引入或经计划授权）：
- [P2] SKILL.md:208→210 C39 编号缺失（C38 后直接 C40）——经 `git show a7c01a8:…SKILL.md` 核对为**基线既有**（base 同样无 C39），非本次改动引入；C41 接 C40 正确。
- [P2] SKILL.md:110 映射表列头「写入 findings.md 段落」现容纳 knowledge-brief 行（:117）——列头语义略窄，属计划 Phase 3 显式授权的新增（task_plan:117），仅措辞可优化。
- [P2] Rule 58 摘要行缺失（SKILL.md 摘要区 54/55/57/60，无 58）——基线既有（base 亦无），v142 落地时未补；Phase 5 部署同步已含「v142 Rule 58 漂移一并补齐」（task_plan:145）。
- [P2] 模板 knowledge-brief 行（subagent_dispatch.md:26）在计划 Phase 3 规定文本外附加「[2026-10-08 task-v145] 四文件契约第 4 文件,Rule 60.2 不可收窄」标注——超集信息，无害。

裁决：**APPROVED**（清单全过，P0/P1 = 0）。

#### [sub:5-cr-code] task-v145 .sh 改动代码质量审查（code-quality-review，Rule 42.2 第④层）— 裁决 APPROVED

审查对象：wt/task-v145 相对 a7c01a8 的 4 个 .sh 改动（check-dispatch.sh +63/-0、check-3file-gate.sh +68/-5、ledger-append.sh +11/-1、selftest-four-file-dataflow.sh 新增 113 行）。维度覆盖 14/14，P0/P1=0。

正确性与边界（实跑证据）：
- gate --require-kb 五态：kb_distill 锚点后→exit0 / 锚点前(2019<2020)→exit1（T9 边界符规格）/ kb mtime 晚于锚点→exit0 / 无 kb 文件→exit1 / 无 Started 锚点退化 stale 阈值→exit1。全符合 60.5。
- lint 双条件：neg1(只写检查点+无锚点)→exit1；neg2(主进程回填+你不用写 同行)→exit1；pos(含 `可写=仅追加` 锚点)→exit0；bare(主进程回填 无否定)→exit0；跨行 只写检查点→仍拦(exit1)。
- 参数兼容：不传旗标 old(a7c01a8) vs new 输出逐字节 IDENTICAL；--require-kb 前置/后置位置参数均生效；多余位置参数与旧行为一致（均忽略，与 `<plan-dir> [--phase N]` 类既有用法兼容）。
- pretool 接线三档：enforce=exit2 / warn=exit0+计数落盘(task-planner-dispatch-warn-<sid>) / off=skip，实测通过。

回归面：全量 57 selftest，worktree 与 a7c01a8 基线（56 脚本）同为 15 脚本 nonzero；逐脚本输出 diff 仅 selftest-registry(:6 计数 55→56/56→57) 与 selftest-self-resolution(SR-12 计数行) 随 +1 脚本同步（预存在 registry 漂移口径不变）→ 本改动引入 FAIL=0。

非阻断观察（P2，4 条）：
- [P2] selftest-four-file-dataflow.sh:77 FF-08 断言 `kb_distill_activity()`≥2 与头注释 :14 声称「=1」不一致；且 ≥2 由 gate 头注释(check-3file-gate.sh:21)+定义(:126)满足，真正调用点 :181 `kb_distill_activity;`（无括号）未计入——删掉调用 FF-08 仍 PASS，未锁其声称的「定义调用」集成。建议：改 `kb_distill_activity`（去括号）≥2 或断言调用行，并同步头注释；progress main:4-R2 记「实际定义+调用=2」为误判（实为注释+定义）。
- [P2] selftest-four-file-dataflow.sh:82 FF-09 `kb_distill`≥2 由 ledger 注释(5 处中 4 处为注释)满足，删 VALID_EVENTS 实改仍 PASS；建议锚 `VALID_EVENTS=.*kb_distill`。
- [P2] check-dispatch.sh:159-175 lint 漏报边界：A2 分支「主进程回填+否定续文」限同行（跨行「主进程回填\n你不用写」不判）；B 锚点任一在全文出现即短路放行（收窄 prompt 若以禁止语引用 `#### [sub:` 亦逃逸）——均为文件内显式注释的降误报取舍。
- [P2] selftest cnt() 助手(:65) 对缺失文件返回空串 → `[ "" -eq N ]` 触发 bash "integer expression expected" 到 stderr（失败方向正确=fail-closed，仅噪声）。

其余维度：命名/注释（What+Why+日期/任务/原行为，Rule 45）齐备；零新 config 键（properties=42 未变，FF-15 PASS）；scope 8 文件全部落在 task_plan scope_files 内；无 TODO 占位/死代码/未释放资源；风格与邻近既有代码一致。

裁决：**APPROVED**（P0/P1 = 0；4 条 P2 非阻断）。
