# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [目标]：跨文件/跨章节理解与知识设定同步缺失——写剧本上一集知识到下一集丢失（严重缺陷），需根治（user-session-log #1 逐字）
- R2 [手段]：写新的一集之前先阅读之前剧集内容（强制前置回读）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules-discipline.md | /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md | ☑ S1+主进程抽查 | Research Findings②/③ |
| critical-rules-dispatch.md | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | ☑ S1+主进程抽查 | Research Findings②/③ |
| critical-rules-media.md | /mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md | ☑ S1+主进程抽查 | Research Findings②/③ |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[S1 枚举扫描 2026-11-15]**（Explore(haiku)，agent_92faccb4）：核心词命中 38 文件/121 处，语义全部为「跨文件检索/写后回读/续写检查点/工序前序产物」，**「上一集→下一集叙事知识连续性」正式条款零命中**。主进程盘上抽查复核：三重点文件 grep '上一集|前情提要|角色状态|世界观' 零命中 ✓（反造谣核验 PASS）。
- **缺口清单（S1 §④，主进程复核采纳）**：五面全缺——①创作前回读前置（无「写第 N 集前必读第 N-1 集产出/前情提要/设定档」强制条款）②完成后设定台账沉淀（无角色状态/世界观/时间线/伏笔回写义务）③跨单元输入契约（任务书/knowledge-brief 不携带前序摘要或 continuity 快照）④设定一致性校验（无冲突检测与验收标准）⑤计划/VC 闭环（创作类计划未纳入「前序输入→本单元产出→设定台账回写」环）。
- **邻近表面（非闭环）**：skills/task-planner/templates/variant/script-dev-type.md:28（continuity/bible 绑定表七类核验）+:66（系列设定=docs/series/<id>/ 必读知识表）——仅计划模板面资产核验，非执行纪律；dispatch 21.4.1（:33）创作单元 Unit/lane 工序产物依赖——工序调度非叙事设定；media Rule 47.1 工序×单元轴同理。教训：**continuity 概念存在于模板面但无任何执行纪律条款承载**。
- **selftest 基线（主仓 2026-11-15，含 3 个未提交 SKILL.md 在途改动）**：run-selftests.sh → Total 97, PASS=94, FAIL=3（selftest-active-plan / selftest-execution-stability / selftest-rule-reserve-pairing）；日志 /tmp/serialsync-st-master.log。**权威基线=Phase 3 建成 worktree 后编辑前实测**（预存 FAIL 与未提交改动/107 预留态相关，worktree 对照为准；VC-3 已改为动态基线文件阈值）。
- **纪元面实测（主进程 grep '1-106'，2026-11-15）**：命中 2 文件=skills/task-planner/scripts/selftest-enumerate-first.sh + skills/task-planner/SKILL.md（与计划 CA-4 一致）。
- **S2 合并登记**：S1 报告已覆盖执行链定位（dispatch/media/discipline/模板变体面）与缺口判定；纪元面+基线=主进程机械实测（25.3 白名单②单事实查询口径）。S2 不再单独派发（防过度委派，宪法 §一），证据齐备于本文件。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 107 落点定案=task-discipline critical-rules-discipline.md 末尾新段（106 之后），级联=dispatch 契约面+media 面指针+全集索引+纪元锚 2 文件 | S1 证据：discipline 是执行纪律域权威载体且 106 在末尾；模板面 continuity 概念（script-dev-type.md:28/:66）可被新条款引用贯通 |
| VC-3 阈值动态化：selftest FAIL 数 ≤ worktree 编辑前基线（存 /tmp/serialsync-st-baseline.count），替代固定初值 2 | 实测主仓基线=3 FAIL 且与未提交在途改动/107 预留态相关；固定阈值会误判（VC-3 原文已预授权按 Phase 1 实测修订） |

#### Rule 107 条款终稿全文（Phase 2 定稿 2026-11-15——插入锚：discipline 106.5 之后；以下为 Phase 3 实施蓝本）

**载体 1：skills/task-discipline/references/critical-rules-discipline.md（106.5 段后新增）**

107. **序列创作知识同步纪律（跨单元叙事连续性三环闭环，P0；2026-11-15 task-serial-sync-20261115 新增）**
> 适用：序列创作任务=同一故事世界内多单元连续创作（多集剧本/多章小说/连载/系列视频脚本/多集分镜等），单元间共享人物/设定/剧情状态。介质中立（文本/视频/漫画/音频脚本通吃）。多单元但无叙事连续性的任务（独立无剧情关联的批量内容）不适用，登记一句豁免理由即可。Why：判例=用户原话「写剧本 上一集知识到下一集丢了 这是严重的缺陷；如果在写新的一集之前阅读之前剧集内容也不会犯这种低级错误」——既有条款只覆盖工序产物依赖（media 47.1/dispatch 21.4.1）与文档写后回读（106.1），跨单元叙事知识既无介质可传也无纪律可依。

107.0 **序列台账登记（计划期，P1）**：计划期识别为序列创作时，task_plan 必须声明序列知识台账路径（如 `<plan-dir>/continuity-ledger.md` 或项目既有设定档/系列 bible 路径）；台账不存在时由首单元执行体创建。台账最小字段五项：人物/角色状态、世界观与设定规则、剧情时间线、伏笔登记（埋设/回收状态）、前序单元产出路径清单。台账=Rule 62 四文件之外的序列介质，不替代四文件（62.5 增量门控照旧）。

107.1 **单元完成台账沉淀（产出期，P0）**：每个创作单元（第 N 集/章/分镜批）完成、声明 done 前，执行体必须把本单元新增/变更的设定事实写入序列知识台账：新人物、人物状态变化、世界观规则增改、时间线推进、新埋伏笔/伏笔回收。未更新台账禁声明完成（51.2 完成声称门联动）。台账允许摘要级逐条事实（一行一条），禁复制正文段落。Why：无沉淀介质则长序列回读成本失控（全量回读 N-1 个单元不可持续），台账=可回读的浓缩介质。

107.2 **动笔前强制回读（消费期，P0——用户点名手段）**：派发单元 N+1 时，任务书必须携带：①紧邻前序单元（N）产出文件绝对路径——执行体首动作=完整 Read；②序列知识台账绝对路径；③更早单元仅在台账条目指向相关时按需 Read。执行体首动作=Read 台账+前序单元产出，回读未完成禁动笔。禁止以「任务书摘要已含设定」为由跳过回读——摘要不替代原文（防摘要失真）。派发契约面=dispatch 22.4d，模板面=subagent_dispatch.md §2 序列行。Why：判例同上——回读原文是最廉价且唯一可靠的上下文恢复手段。

107.3 **验收一致性核对（验收期，P0）**：创作单元 QC/审查必须对照台账+前序产出做一致性核对，五项逐项过：人物名/称呼与关系、已确立事实、时间线顺序、伏笔状态（禁无交代回收/重复埋设）、世界观规则。发现冲突=FAIL 返工+台账勘误回写；冲突漏出至用户侧=执行链缺陷（复盘按 Rule 31 归因）。与 47.6 抽检门叠加执行（工序面+叙事面两道门）。

107.4 **主进程验收与接续（编排期，P1）**：子代理返回后主进程验收须核台账已更新（Read 台账确认本单元条目在位）；跨会话/跨计划接续序列任务时，恢复协议=先读台账→再读最近前序单元产出→然后按需读更早单元（80.4 恢复读序的序列扩展）。

107.5 **豁免与边界**：①非序列任务豁免（登记理由一行）；②用户明确提供完整设定档/系列 bible 时，107.2 的回读对象可为该设定档替代前序单元全文（任务书显式登记替代关系）；③台账丢失/中断恢复时，先从已有单元产出反向抽取重建台账，再续写（禁凭记忆重建）。机制范式对齐 47.4：判定面=LLM 行为（计划期序列登记/派发携带/执行体首动作/验收核对），机器面=既有 selftest 静态文本锚（107.x 子条锚，仅锁步更新既有断言，零新脚本零新键）。

**载体 2：skills/task-dispatch/references/critical-rules-dispatch.md（22.4c 段后新增 22.4d）**

22.4d **序列创作单元回读输入必附（Rule 107.2 派发面承载，2026-11-15 task-serial-sync-20261115）**:序列创作任务（同一故事世界多单元连续创作，判定与豁免=Rule 107 适用面）派发单元 N+1 时，prompt 输入段必须附**前序产出与台账双路径**：①前序产出=紧邻前序单元（N）产出文件绝对路径（执行体首动作=完整 Read，禁摘要替代）②序列知识台账绝对路径（Rule 107.0 五字段）。缺任一路径 → 禁止派发（LLM 行为门；模板面=subagent_dispatch.md §2「前序产出与序列台账」行，非序列任务填 none）。Why：判例=用户原话「写剧本 上一集知识到下一集丢了」——工序产物依赖（22.4a 三文件）不含叙事知识，跨单元知识必须有显式输入契约。

**载体 3：skills/media-planner/references/critical-rules-media.md（47.6 段后新增 47.7）**

47.7 **序列剧集叙事知识同步（Rule 107 媒体面指针，2026-11-15 task-serial-sync-20261115）**:多集剧本/多章小说/系列分镜等序列媒体创作，除 47.1 工序产物依赖（母图/分镜/剧本定稿强串行）外，跨单元**叙事知识**同步按 Rule 107 三环闭环执行：107.0 台账登记（计划期声明 continuity 台账路径）→107.1 单元完成沉淀设定事实→107.2 下一单元派发必附前序产出+台账路径且执行体首动作回读→107.3 验收五项一致性核对（与 47.6 抽检门叠加：工序/物理面+叙事面两道门）。工序串行不自动保证叙事连续——产物依赖≠知识传递（判例=上一集设定在下一集丢失）。

**载体 4：skills/task-planner/templates/subagent_dispatch.md（§2 输入段材料包行后新增一行）**

- **前序产出与序列台账（序列创作任务必附，Rule 107.2/22.4d）**：{紧邻前序单元产出绝对路径} {continuity 台账绝对路径}——执行体首动作=完整 Read 前序产出+台账，未回读禁动笔；非序列任务填 none

**载体 5（索引/纪元）：skills/task-planner/SKILL.md（路由表 task-discipline 行加 107+纪元 1-106→1-107）+ references/critical-rules.md（全集索引 1-106→1-107+索引行）+ scripts/selftest-enumerate-first.sh（纪元锁步 1-106→1-107）**

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:1-general-coder] Rule 107 权威载体落地
- 结论：在 worktree `critical-rules-discipline.md` 的 106.5 段末尾追加 Rule 107「序列创作知识同步纪律」全文（107+107.0-107.5），格式对齐既有条款；未带「载体 1」标题行。
- 证据：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills/task-discipline/references/critical-rules-discipline.md:740`（107 标题）, `:743/:745/:747/:749/:751/:753`（107.0-107.5）, `:738`（106.5 末行锚在位）。
- 验收：grep '序列创作知识同步'=1；grep -cE '107\.[0-5]'=6；106.5 末原文行逐字在位（无吞锚/无重复/无截断）PASS。

#### [sub:2-general-coder] 派发面+媒体面级联
- 结论：worktree `critical-rules-dispatch.md` 于 22.4c 末后插入 22.4d（Rule 107.2 派发面：前序产出与台账双路径）；`critical-rules-media.md` 于 47.6c 末、49 标题前插入 47.7（Rule 107 媒体面指针）。
- 证据：dispatch 22.4c 原文在位（:62）+22.4d@`:64`+22.5@`:66`；media 47.6c 原文在位（:25）+47.7@`:27`+49@`:29`；`grep -c '前序产出'` dispatch=1 media=1，`22.4d`/`47.7` 标题各唯一。
- 验收：锚段 22.4c/47.6(c) 逐字保留、无重复段、无截断 PASS（VC-2 worktree 面就位）。

#### [sub:3-general-coder] 索引纪元面更新
- 结论：worktree SKILL.md 四处纪元锚 1-106→1-107 完成（:9/:223/:266 含 89→90 与 Rule 107 索引项追加；:210 task-discipline 路由行追加 ,107）；:105「3i 修改后复检（Rule 106）」未改（禁改）。
- 证据：`skills/task-planner/SKILL.md:9,210,223,266` 均含 `1-107`/`,107`；selftest `selftest-enumerate-first.sh:9,92-99` EN-06 注释/grep/echo 锁步 1-107/,107。
- 验收：A `grep -c '1-107'`=3；A `grep -n ',107'`=1；B `bash -n` exit 0；B `grep -c '1-106'`=0。
- 说明：A `grep -c '1-106'`=1（:105 `106.1-106.4` 子条区间字面含 `1-106`，属 Rule 106 本体引用，按指令禁改/视为排除项）。

#### [sub:4-general-coder] DQ-08 断言锁步
- 根因：Rule 107 落地后 SKILL.md 纪元从 1-106 演进为 1-107（「其余 89 条」→「其余 90 条」，:9/:223），`selftest-dual-qc.sh` DQ-08 仍断言 `其余 8[0-9] 条`，dq08b=0<2 导致 FAIL（dq08a=4/dq08c=1 正常）。
- 修法：锁步替换目标文件 4 处 `其余 8[0-9] 条`→`其余 9[0-9] 条`（:11 注释/:97 模式/:100 ok/:102 bad），`≥3/≥2/≥1` 三条件与 dq08a/dq08c 不变。
- 自验：`bash -n` exit 0；`bash skills/task-planner/scripts/selftest-dual-qc.sh` → `Total: 14 PASS=14 FAIL=0`；目标文件残留 `其余 8[0-9] 条`=0。
- 证据：`skills/task-planner/scripts/selftest-dual-qc.sh:11,97,100,102`；DQ-08 输出 `纪元窗=4/其余 9[0-9] 条=2/Rule 103 双轮质检与同步完整性域=1`。

#### [sub:5-general-coder] 知识入库
- 条目：`knowledge/entries/serial-creation-knowledgesync-rule107.md`（Rule 107 序列创作知识同步三环闭环，含落点锚与级联易错点）。
- INDEX：`bash scripts/kb-rebuild-index.sh` 已执行；`grep -c 'serial-creation-knowledgesync-rule107' knowledge/INDEX.md`=1（命中）。
