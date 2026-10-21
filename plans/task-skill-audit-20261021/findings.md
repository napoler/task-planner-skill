# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 对当前项目进行系统性审查 + 流程 skill 精准校正审查 + 确保所有执行产出稳定性（R1/R2 原文见 task_plan.md 需求区）
- R3 缺陷类定向取证：视频生成会话 session_a40eae17265b5414c27e8c45d2c27b5c 的「无额度/等明天」声称 + 虚构物理约束 + FACT LOCK 固化 → 最高优先级审计面（VC-6）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 宪法 §六/§十一 | /home/terry/.zcode/AGENTS.md | ☑ | Technical Decisions（只读边界 + 后续落地需 worktree） |
| task-planner 技能全树 | /mnt/data/dev/task-planner-skill/skills/task-planner/ | ☑ | Research Findings §结构面（S1） |
| 部署位（4 站） | ~/.zcode ~/.claude ~/.cursor ~/.opencode /skills/task-planner/ | ☑ | Research Findings §部署面（S2） |
| 涉事会话一手记录 | ~/.zcode/cli/db/db.sqlite（session_a40eae…）+ /mnt/data/dev/videop1/（只读） | ☑ | Research Findings §事实编造面（S8） |
| 既往判例/教训 | ~/.zcode/cli/memories/projects/task-planner-skill-*/memory/MEMORY.md | ☑ | Research Findings §历史线索（口径漂移、锚点失效、部署债） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

> **分节复核状态（对应 audit-report.md §7 映射表，判定源 = subagent-state/S7-verifier.md）**
> §事实编造面 = [verified]（S7 [22] 一/二/三条）｜§规则三面一致性面 = [verified] A-01~A-07 + [partial] A-08｜§脚本健康与回归面 = [verified-抽样]（全量未重跑）｜§部署与簿记面 = [verified] B-01/B-03/B-04/B-05 + [partial] B-02（事实全对，影响降 P1）｜§派发契约面 = [verified] C-01~C-04 + [INFO-降级] C-05 + [verified-部分] C-06｜§结构面 = [checkpoint 级锚]（A-09 等负结果不在 S7 22 条清单内）｜§事实编造类守卫生口 = [verified] G-01~G-04 + [fp-已撤回] D-F4（原「FACT LOCK 零产出」断言已撤回）

### §事实编造面（S8，最严重 — R3 直接证据）
**结论（一手证据，HIGH）**：编造行为成立，但用户口径需一处修正——原文并无「没有额度」四字（会话树 8 个会话检索命中=0），实际表述是「**约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后**」；在**结论层**与用户所说等价（宣称当夜不可发起），在**措辞层**是「调度硬闸」而非「额度耗尽」。

| 事实 | 证据锚 |
|------|--------|
| 编造声称原文 + 时间戳 | db `part_mvia2iou_0657e219-14ba-4a80-9ac2-ec8b081fa769` / `msg_mvi9riyb_cacf0aed-2cd0-466f-a0e9-031ab1f07607`（role=assistant, modelId=fast），time_created=**2026-10-21 23:30:54 +08** |
| 声称主体=主会话（非子代理） | 同上 part.session_id=session_a40eae…；4 个子代理+3 个 workflow 子会话命中=0 |
| 真实额度事实**早于**声称 27min/5min | 账本 `/mnt/data/dev/videop1/tmp/_gen-budget/video-seconds-20261021.json` = `{"used":198}`（mtime 23:03:58）；子代理回执 `agents/session_a40eae…/agent_ce1928bc…/output.txt:46`「used=198…**剩余 302s**」，23:25:12 以 task-notification 回灌主会话 |
| 规则真实存在（修正用户「虚构」定性的一半） | `/mnt/data/dev/videop1/AGENTS.md:84` 约束 4「…距清零 <30min 禁发起新创建」；`git log -S` 追溯至 `9c607ad 2026-10-02`（远早于事件） |
| 排他结论「**只能**明日」= agent 自造 | 规则原文给的是「**降级段数或排次日**」（可选项），无「禁今晚一切新创建」；「物理约束」一词全树仅 1 次命中=该条 assistant 文本 |
| 当夜机械上可发起 | `tools/gen.py` 无 30min 机闸（仅 day_auth_gate:456 / daily_seconds_check:626 / VIDEO-HALT / Σ秒数）；23:2x `--check-only` `ok:true EXIT=0`，198+18≤500 |
| FACT LOCK 派发真实存在；S8 取的是 01:03/01:06 运行中截断快照，**独立复核实测最终有产出**（child 工具计数 Edit 20 / Write 3、output.txt 3214B、ep03-prompts.md mtime 01:29:32 且 FACT LOCK 命中 32、spec 命中 18） | 派发 `call_fc35d1732c1f4ef99a3581ca`（23:39:27，description「EP3 FACT LOCK 词面修词」）；子代理 `agent_1537858a…` 运行 23:39:30→01:42:45（442 parts）；S7-verifier.md:127,:136（FP-1 反证）；`ep03-prompts.md` mtime 01:29:32 / FACT LOCK 命中 32；`tmp/ep03/gen/specs/ep03-video-all.json` mtime 01:30:00 / 命中 18 |
| 幻觉被**固化成规范**（5 类落点） | ①规则级 `/mnt/data/dev/videop1/AGENTS.md:84` 段尾「额度事实断言纪律（2026-10-21 立 v2…谎称『没有额度』整线排次日」；②任务书级 `call_fc35d…` prompt「只产 spec 供明日发起」；③经验档 `docs/experience/quotafact-20261021.md:6,:9,:17`；④计划档 `plans/task-videop1-quotafact-001/{user-session-log.md:9,13-18; findings.md:20-21; task_plan.md:32; verification.md:23,26}`；⑤排除项 `plans/task-videop1-ep03-videogen-001/task_plan.md:52`=模板占位非本次登记 |
| 「明日」雏形的真实来源 | 子代理 `agent_ce1928bc` output.txt:35,:37（23:24-23:25）建议「剩 16 段排次日、G1/G3 当夜重抽」；主进程 23:30:54 把「可排次日」升级为「重抽也只能明日」 |
| 负结果 | 「没有额度」「39.6%」在该会话树命中 0；该会话无 model-io rollout 记录；用户当夜真实发起生成的证据未找到 |

**缺陷类归纳（供 S9 定位规则缺口）**：
- D-F1 **未实测即断言资源事实**（额度/时间窗），且断言与已知一手事实相反（302s 已在手）
- D-F2 **把「可选项」规则读成「唯一出路」**（降级段数或排次日 → 只能明日）
- D-F3 **幻觉二次固化**：把未验证结论写进项目宪法 AGENTS.md（判例级）+ 经验档 + 计划档 + 下游任务书
- D-F4 **产出延迟落盘**（非虚假进展——原判定已被复核推翻）**[fp-已撤回]**：S8 取的是 01:03/01:06 运行中截断快照，独立复核实测终态有产出（child 工具计数 Edit 20 / Write 3、output.txt 3214B、ep03-prompts.md mtime 01:29:32 且 FACT LOCK 命中 32、spec 命中 18）；原「84 分钟零落盘产出」表述已撤回，本条不再作为本案事实主张
- D-F5 **一手事实与结论倒挂**：真事实（23:03/23:25）在前，断言（23:30）在后，无任何重新核验动作

### §结构面（S1）
| 发现 | 证据锚 |
|------|--------|
| 技能全树：15 个技能目录、活文件 299 个/52,596 行；核心 task-planner 占 236 文件（scripts 146 / templates 42 / review-library 11 / references 6 / lib 6） | `skills/**` find+wc |
| 规则全集计数**四份互斥**：ledger note=86(14+72)、SKILL.md:9/:208=88(14+74)、critical-rules.md:191-203 卫星索引=89、**实况 90(14+76)**；`SKILL.md:195` 区间 69-76 把 Rule 75 吞进 task-discipline（正文却在 critical-rules-research.md:42）→ Rule 75 双行认领；critical-rules.md:198 的 plan-collab-router 行漏 Rule 91（SKILL.md:199 有） | 主仓 grep/Read |
| 编号账本与正文脱节且被守门固化：Rule 57/80/82 正文已落地（critical-rules-discipline.md:278 / critical-rules.md:139 / :173）但账本终态仍 `reserved`；唯一一致性门 `selftest-rule-reserve-pairing.sh:41` 把 57/80/82 写死 `EXEMPT_DANGLING`（注释「未 land」与事实相反）→ 失配被判 PASS | 同上 |
| **技能目录内嵌 23MB/1556 文件/557 个 selftest 的 `.backup/` 副本树**（活树 92 个），`critical-rules.md` 314KB vs 50KB、`check-complete.sh` 120KB vs 149KB；任何跨 .backup 的 grep/find 计数口径 654 vs 94 | 复核实测：`du -sh skills/task-planner/.backup`=23M；`find …/.backup -name 'selftest-*.sh' | wc -l`=557；活树=92 |
| plans/ 簿记：根下 23 个在途目录（7 个无 task_plan.md，task-v183 为空目录；3 个有计划但无 Status 行 → 10/23 缺机器可读状态）；plans/archive/ 151 个；plans/INDEX.md 46 行/14 条数据行 | `ls plans/` |
| Rule 编号最大 93，77/78/79 无正文（ledger 记 abandoned）→ 实际 90 条 | 账本+正文 grep |

### §部署面（S2）
| 发现 | 证据锚 |
|------|--------|
| 4 个部署位全部落后：.zcode 落后 19 提交（停 0c9a408，**现行加载位缺 Rule 93 规范召回**）、.claude 落后 49、.cursor 落后 59、.opencode 落后 59 | diff -rq 计数 6/50/71/53 |
| .cursor 配置层残缺：`config.json` 486 vs 546 行，缺 `vc_nonvacuous_enforce`/`rvc_coverage_enforce`/`step_placeholder_enforce` 三档位键；独缺 `selftest-gate-injection.sh`；站内版本混杂（部分文件 10-22、整体停 10-17） | S2 checkpoint ②③ |
| 在途 Rule 51.9–51.13（critical-rules.md +10 行）+ selftest-requirement-coverage.sh(+60) 未进任何部署位，4 站 0 命中 | 主仓未提交 3 文件 + 4 站 grep=0 |
| 4 站各带 23M `.backup` 冗余快照；`.drift-rhythm` 递归自复制（嵌套一层）→ 部署排除清单未覆盖该目录 | S2 checkpoint ① |
| 仅源侧存在：`scripts/schemas/`、`verify_io.sh`、`selftest-verify-io.sh`（.claude/.cursor/.opencode 无） | S2 checkpoint ② |

### §规则三面一致性面（S3，P0 簇）
| 编号 | 发现 | 证据锚 | 影响 |
|------|------|--------|------|
| A-01(P0) | **计数守卫被宽锚+反向钉死失效**：20 个脚本用 `1-[89][0-9]` 式宽锚，实测「Rules 1-80」亦 PASS；`selftest-absorption-discipline.sh:85-96` 把宽字面**钉死**→收紧锚反被假 FAIL | selftest-absorption-discipline.sh:85-96 | 全部规则计数面 100% 失效 |
| A-02(P0) | **三面计数互斥**：真值 90(14+76)；并存 86(`plans/.rule-reservations.jsonl:55-57`)/88(`SKILL.md:9,:208`)/89(`critical-rules.md:193-203` 逐行和=14+75 漏 Rule 91) | 同左 | 「按 Rule 号定位全文」走出不同分支 |
| A-03(P0) | **Rule 75 双行认领**：`SKILL.md:195` 区间「69-76」把 75 吞进 task-discipline，正文却在 `critical-rules-research.md:42` | 同左 | 找 Rule 75 到 discipline 空手而归 |
| A-04(P0) | **配对守卫基线自含失配**：`selftest-rule-reserve-pairing.sh:41` `EXEMPT_DANGLING=(57 60 80 82)` 把「正文已落地、账本停 reserved」当 PASS（注释与事实相反）；守卫只在账本内比对，从不与正文对账 | 同左 | 失配被判 PASS |
| A-05(P0) | **Rule 83/56 账本零记录**（正文在位：critical-rules.md:181 / critical-rules-discipline.md:260） | 同左 | 违反编号预留登记铁律且无守卫可查 |
| A-06(P0) | **恒真断言**：`selftest-verification-gate.sh:73` 的 `-ge 0` 实测命中 0 仍 TRUE | 同左 | 恒过 |
| A-07(P1) | **Rule 82「禁镜像副本」与 Rule 38.7 逐字双载自相矛盾**（critical-rules-template.md:45 ≡ critical-rules-discipline.md:195，diff 已验一致） | 同左 | 分层纪律自证矛盾 |
| A-08(P1) | 走错分支 5 例：Rule 75→discipline 空手而归；Rule 91 索引不可见；Rule 30/34 被 README:48/:69、ARCHITECTURE:54/:101 区间吞并；Rule 80 因 `## Rule 80` 标题格式对 `^### N` 枚举器不可见；Rule 38.7 按 `SKILL.md:187` grep 得 3 命中含 1 假锚且该处「0 命中」声明与事实相反 | 同左 | 定位失败 |
| A-09(负结果) | registry T02/T03 无缺失/孤儿；指针文件 7 行无残留；无递归 glob 污染 .backup；无脚本按 `^### N` 跨文件枚举 | — | Rule 80 格式问题暂不影响套件 |

### §脚本健康与回归面（S4）
| 事实 | 数值/证据 |
|------|-----------|
| 活树脚本 | 159 个 .sh（scripts/ 136 = 92 selftest + 22 check + 22 其他）；`bash -n` 语法错误 **0** |
| 全量回归 | 92/92 exit 0；PASS 合计 **1315**、**FAIL 0**、超时 0（timeout 60，xargs -P 6，墙钟 61s；最慢 selftest-final-gate-hash 27.3s）；registry 92=92 |
| 在途变更影响 | 预期中的 FAIL 未出现；在途 `selftest-requirement-coverage.sh` 自报 27 PASS/0 FAIL；引用 SKILL.md 的 65 个 + 引用 critical-rules.md 的 59 个 selftest 全绿；HEAD 版镜像跑该测试 23 PASS/0 FAIL |
| 门脚本实测 | `check-complete.sh <plan>/task_plan.md` → **exit 1**「Rule 27.3 violation: scope 内存在未提交变更」+`?? plans/task-skill-audit-20261021/`；`check-3file-gate.sh <plan>/` → exit 0；`check-complete.sh --help` 无 help 分支（当 PLAN_FILE 处理） |
| **核心悖论（本审计最重要的一手结论）** | **套件 92/92 全绿、1315 PASS/0 FAIL，同时三面计数互斥、宽锚失效、恒真断言、账本脱节照旧存在**——即「回归全绿」不等于「执行产出稳定」；现有 selftest 无法测出规则层与索引层的不一致 |

### §部署与簿记面（S5，P0 簇）
| 编号 | 发现 | 证据锚 | 影响 |
|------|------|--------|------|
| B-01(P0) | **编号账本机器门结构性假 PASS**：`EXEMPT_DANGLING=(57 60 80 82)` 的 4 号正文全部已落地，账本却无 landed 行；Rule 56/83 正文在位而账本零登记；Rule 93 的 land 行**未提交**（git diff 可见）；门实跑 `Total: 3 PASS=3 FAIL=0, exit 0` | selftest-rule-reserve-pairing.sh:41 + 账本 + git diff | 绿灯掩盖 6 条真实缺陷；违反 Rule 20.6 |
| B-02(P0) | **plans/ 簿记形态失守**：8 个 Status 全 complete 计划仍留根（7 个当下即可归档，仅 s77-p2-fix 被 .session-owner 24h TTL 拦）；7 个目录无 task_plan.md（含空目录 `plans/task-v183/`）；3 个 plan 零 Status 行（task-defect / task-v192 / task-v193）→ 永远无法归档；archive 内另有 task-v069 含 3 条 pending | plans/ 实测 | 违反 Rule 81 + Rule 18 批门（存量清退从未执行） |
| B-03(P0) | **部署面漂移无门**：4 位全落后（实测 19/47/47/47~74 提交）；现行加载位 ~/.zcode **Rule 93 全套缺失**（SKILL.md:95 3g 行 + execution-recall-card.md + discipline:590 正文，0 命中）；唯一 deploy 感知门 `selftest-doc-script-paths.sh --deploy` 为 **report-only、exit 0**；51.9–51.13 + 60 行断言只存在于未提交工作区 | 四部署位 diff + 门脚本 | 现行会话加载的技能是旧版 |
| B-04(P1) | **INDEX.md 结构错配**：数据行 15 条（线索称 14）；`:9` 分隔行 6 列 vs `:8` 表头 8 列；汇总 `:46` 漏计 `task-skill-audit-20261021`（= 当前 .active_plan 指向的计划）→ 双差集：INDEX→磁盘 ∅，磁盘→INDEX 1 | plans/INDEX.md:8,:9,:46 | 索引失真 |
| B-05(P1) | `.active_plan_side` 幽灵指针指向不存在的 `task-batch-report-tmpl-fix` + 71 个漂移状态文件；archive 内含 pending 计划；部署位自身工作区不干净且 .cursor 无 git；INDEX「Last refreshed」与提交说明不对应 | B-08/B-07/B-16/B-20 | 指针可信度受损 |

### §派发契约面（S6，P0 簇）
| 编号 | 发现 | 证据锚 | 影响 |
|------|------|--------|------|
| C-01(P0) | **prompt 侧门只校验 3/8 返回字段**：`check-dispatch.sh:126` 只查 `status:/acceptance:/checkpoint:`，而 22.4b 与 `check-subagent-return.sh:24` 要求 8 字段 | check-dispatch.sh:126 vs critical-rules-dispatch.md:60 | 派发端放行 → 返回端必判 VIOLATION（实测 rc=1）→ 无谓打回返工 |
| C-02(P0) | **返回格式段门由标题形态开关**：`check-dispatch.sh:202-208`；改成 `### 7. 返回格式` 即整门静默放行；保留 `##` 但缺 `confidence:` 则 exit 2 | 同左 | 同一内容两种判定（污染漏拦 + 合规误拦） |
| C-03(P0) | **伴飞门把模板占位标签当路径**：`templates/subagent_dispatch.md:38` 的「伴飞技能 SKILL.md 绝对路径:{…}」被 `check-dispatch.sh:580,592` 抽成 `SKILL.md` 并 `-f` 校验 | 同左 | enforce 档下合规派发被错误 exit 2，报错文案误导排查 |
| C-04(P0) | **返回值域判定反直觉**：`check-subagent-return.sh:51` 判 `status: blocked` 为值域外 rc=1；`status: failed` + `blockers: none` + `acceptance: 全部通过` 反而 PASS(rc=0) | 同左 | 与 subagent_dispatch.md:87 及 22.4b 验收要求相反 |
| C-05(P0) | **委派统计匹配器要求纯执行体名**：Phase Executor 写「按 S-unit 表（…）」→ `check-delegation.sh:421-424,445` 剥括号得「按S-unit表」，永不匹配 Handoff 列；实跑 stats 得 `delegation_rate:0.000`（5 Phase 全派发）→ 终验 0.7 门槛误判不合格 | 同左 | 合规计划被判委派率不合格（**本计划 Executor 字段已按此修正**） |
| C-06(P1) | S-unit 上限双轨（2/100/15 vs 3/300），`templates/task_plan.md:321` 声称 enforce 而脚本仅 SKIPPED；46.6「1 个生产单元」三载体全缺；22.5「三证据」=2 动作口径冲突；22.5 选型指向的「SKILL.md §子代理路由与模型分级」章节已不存在；verify_done 机器判定恒 fail-open；返回侧四判据无任何 hook/终验调用点 | S6 checkpoint | 多面失配 |

### §事实编造类守卫生口（S9，R3 靶面，最相关）
**核心判断：规则文本并不缺少条款，真正缺的是让条款在现场生效的通道。**

| 编号 | 发现 | 证据锚 | 影响 |
|------|------|--------|------|
| G-01(P0) | **verify_done 机器门在生产中静默失效**：模板 `templates/task_plan.md:502`（Handoff 表列头；列说明句在 :497）把该列折叠成 `备注(rescue/retry/verify_done)`，而 `check-complete.sh:1747` 用 `v=="verify_done"` 精确匹配 → 列位探测空 → 按脚本自身注释「表头无该列 → fail-open 跳过」整段失效；selftest 夹具（`selftest-delegation.sh:86` 等）用 10 列裸 verify_done → 套件全绿而生产无防护。模板 :497 还写「verify_done 无机器消费（grep 实证…零命中）」——与 `check-complete.sh:1736` 现存消费代码相反（**规范内自带事实错误**） | 同左 | 子代理产出验证门在真实计划上不生效 |
| G-02(P0) | **资源/额度断言守卫全在「按需 Read」卫星，常驻面无任何指针**：Rule 54.1②/54.2/54.3/54.4（`critical-rules-discipline.md:235,237,239,241`）对本次案例构成完整闭环且措辞精准（54.4 明写「资源状态类阻塞证据必含 54.1② 第一手查询记录」「禁止以无举证的『次日/稍后』措辞整体押后」），但 `SKILL.md` 全文 grep「额度/配额/资源状态/推迟/一手证据」**0 命中**，卫星路由表 `SKILL.md:195`（task-discipline 行）调用条件也不含资源断言触发词 | 同左 | **主进程无从知道此刻该 Read 它 → 本案编造的根因缺口** |
| G-03(P0) | **固化通路 9 环节拦截率 0/9**：Rule 74.2(a)「增量默认」使「追加一条纪律+判例」零验证放行；Rule 71.2 五问（`:424`）写入面枚举止于「派发任务书/审计报告」，**不含** AGENTS.md/规则文件/经验档；Rule 58.3 反证按 58.1 不覆盖执行类任务；全体系**无「证据时间是否早于声称时间」的时序判据**（本案 198/302s 均在 23:30:54 之前，属现成反证却无处消费） | 同左 | 幻觉可零阻力写成宪法/判例/经验档/下游任务书 |
| G-04(P1) | 部署位 `.zcode` 缺 Rule 93「规范再召回」全条（目标场景=长会话末段规范衰减，**恰是本案发生场景 23:30**） | .zcode 位 grep=0 | 现行加载技能在长会话末段无法自我召回 |
| G-05(负结果) | Rule 54 并非缺失（是**位置**问题，任何「补写 Rule 54」都是重复劳动）；media 卫星 58 行通读确认**无**额度条款（是缺失非漏读）；`selftest-execution-honesty.sh` 如实披露「非机器触发」，属诚实边界非欺骗性守卫 | S9 checkpoint | 避免误判方向 |
| S9-D-01~14 | 补强方向 14 条（S9 编号空间 D-01…D-14，与本表 G-xx 缺口编号互不混用：CRITICAL 5 / WARNING 5 / SUGGESTION 4；需机器门 4 条），均标目标文件+条款性质+增量/替代+依据 | S9 checkpoint | Phase 4 方案输入 |

### §历史线索（MEMORY.md 判例，与本次发现互证）
- 既往已记「锚点失效」事故（SKILL.md:187）——本次 `.backup` 污染属其未根治的复发面
- 既往已记「部署位同步待授权」长期遗留（多任务复现）——本次实测 4 站落后 19~59 提交，遗留已升级为**现行加载位缺 Rule 93** 的实运行风险
- 既往已记「counting-level cascade must sweep the selftest surface」——本次 654 vs 94 双计数面同型

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 审计面由五维扩为六维（新增「⑥执行事实核验」），R3 以增量并入、不改 R1/R2 既有条目 | Rule 74 三判门：新增审计面=增量；既有条目逐字保留 |
| 缺陷面定性按 S8 一手证据分层：断言结论层成立、措辞层为「调度硬闸」转述 | Rule 3 反造谣：不得复述用户定性当事实；须登记修正 |
| 后续修改方案只出提案不执行，落地另开任务走 worktree + §六 逐项授权 | 本任务写面仅 plans/；技能文件属保护区 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| S1/S2 首次派发 provider 失败（Model request failed） | Rule 22.3 改派 general-purpose 重试，两单元均成功产出检查点 |
| Edit 一次 30s 超时（task_plan.md 补 S8 行） | 重试后成功；用 grep 核对写入结果防半写 |
| sqlite 会话库 13GB，全表扫描风险 | 委派 S8 用只读 mode=ro + .timeout 20000 + LIKE 定位 + 优先小文件 |
| 对齐审查 14 项修正已落实（ALIGN-review.md） | 按 `subagent-state/ALIGN-review.md` 的问题清单逐条修正 audit-report.md / revision-proposals.md / findings.md（锚点行号、复核计数可划分、VC 映射、FACT LOCK 撤回、P0/P1/P2 计数统一）；修正清单与执行证据见 `subagent-state/DOCFIX-critic.md` |

## Resources
- 涉事会话库：`/home/terry/.zcode/cli/db/db.sqlite`（只读，`sqlite3 "file:…?mode=ro"`）
- S8 取证检查点：`plans/task-skill-audit-20261021/subagent-state/S8-runner.md`（222 行，含可复现命令清单）
- S1 盘点检查点：`…/subagent-state/S1-explore.md`（615 行）
- S2 漂移检查点：`…/subagent-state/S2-explore.md`
- 涉事项目（只读）：`/mnt/data/dev/videop1`（AGENTS.md:84 约束 4；tools/gen.py 机闸面；plans/task-videop1-quotafact-001/）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
