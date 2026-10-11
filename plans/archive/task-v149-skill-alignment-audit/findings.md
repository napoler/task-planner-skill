# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 系统性审核当前技能中的问题（[目标]）
- R2 未对齐/落后内容全部对齐（[目标]）
- R3 问题/错误/不合理之处修复，发现必解决（[目标]）
- 审计范围=task-planner 技能全部载体：SKILL.md/references/scripts/templates/companion/config.json/仓级文档/部署位

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| memory 项目记忆库 | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/（MEMORY.md 索引+各条目） | ☑ | §遗留核对表 |
| v148 delivery-summary（健康参照+遗留尾注） | /mnt/data/dev/task-planner-skill/plans/task-v148-drift-enforce/delivery-summary.md | 待 Phase 2 消费 | §遗留核对表 |
| 部署拓扑 memory | memory task-planner-repo-deploy-flow.md | 待 Phase 2 S4 消费 | §部署拓扑事实 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### selftest 全量基线（Phase 1 — code-runner-agent 后台跑批中）
- 状态：后台执行（检查点 plans/task-v149-skill-alignment-audit/subagent-state/01-code-runner-agent.md）
- 历史参照：v147 时点回归 ΣFAIL=4（master 基线）；active-plan 修复任务记录 master 全量 selftest 曾见 15 FAIL 需分类——本基线实测后归类

### Phase 2 四面审计结论（2026-10-08，四子代理并行，检查点 02-05）
- S1 一致性：10 项（H3/M4/L3）→ subagent-state/02-explore-s1.md（主进程代写，Explore 无 Write 工具面）
- S2 文档滞后：24 项（H8/M10/L6）→ subagent-state/03-explore-s2.md
- S3 三面对齐：17 项（H3/M6/L8）→ subagent-state/04-explore-s3.md
- S4 部署对账：6 项（H2/M2/L2）+ 部署拓扑事实 → subagent-state/05-general-purpose-s4.md
- 主进程抽验 7 项全属实（SKILL:9/registry:50/video-fix-executor/install-companion:63/README_zh:136/C39/config 键——bash 一手输出）
- **拓扑事实更正**：部署位候选 5 个（claude/zcode/opencode/cursor/continue，lib/detect-tools.sh:17-26）；在役三位 zcode/claude/opencode 全量 IDENTICAL（20:28 已同步 21f7e6b）；cursor 位实存但陈旧 10-05；continue 位不存在
- **归因更正**：DCS-20 FAIL 命中串在 skill-fix/SKILL.md:1398 等**无关技能**文件（DCS-20 扫描根=SKILL_ROOT/.. 全 skills 树）→ 环境敏感伪失败，非 task-drift-guard 位不同步（v148 findings 归因有误，追加更正不改写历史）

## 审计发现处置表（Phase 2 收口 — 36 项去重，处置三态）
<!-- fixed=本任务修（承接 S-unit）；SKIP/销账=登记理由；每项终态在 Phase 3/5 回填 -->

| ID | 发现 | 严重度 | 处置 | 承接 |
|----|------|--------|------|------|
| D1 | INDEX.md 八行幽灵状态行（v133/135/138/142/143/144/146/147，git merge-base 全实证） | H | fixed | S5 |
| D2 | SKILL.md:9 frontmatter「61 预留未落地」断言错误+全集上界需随 Rule 65 演进 1-64→1-65 | H | fixed | S16 |
| D3 | SKILL.md Rule 61 括注缺失（v147 遗留） | M | fixed | S16 |
| D4 | SKILL.md Critical Rules 摘要列表缺 Rule 45/46/48/56/60 bullet（References/frontmatter 有、bullet 无——本会话 SKILL 加载面二次实证） | H | fixed | S16 |
| D5 | C39 缺口=v142 合规项被撞号丢失（1a92ef3 commit msg「SKILL.md 新增 C39 合规检查项」实证） | M | fixed（随 Rule 65 恢复 C39 行） | S16 |
| D6 | v142 Rule 57 周期性回顾条款文本在 v141 撞号合并中静默丢失；selftest-periodic-review.sh 断言幽灵文本=永久 FAIL 根因；条款源于用户 2026-10-06 反馈 | H | fixed（恢复为 Rule 65：按 critical-rules.md:676 仲裁先例「内容零改动重编号」；new_rule:65 预留） | S7 |
| D7 | config 孤儿键 periodic_review_enforce/interval_calls（:329,:335） | M | fixed（Rule 65 恢复后键合法化，零删除） | S7 |
| D8 | 守卫锚级联：Rule 65 落地→1-64→1-65+尾部负断言 ^65→^66（v147 先例：六守卫 LA-12/RC-11/SR-07/TS-05/WF-10/DCS-11+RF 脚本） | H | fixed | S16-S20 |
| D9 | selftest-registry.tsv:50 行号锚失效（指 Rule 51 实态全错位） | H | fixed | S8 |
| D10 | init-session.sh:380 锚 SKILL.md:524 超文件范围（实 498 行） | H | fixed | S8 |
| D11 | selftest-plan-dispatch.sh:37 注释锚漂移（task_plan.md:144 实为「核心问题定义」） | M | fixed | S8 |
| D12 | selftest-self-resolution.sh:15,76 + selftest-reliability-institution.sh:14,80 注释锚演进滞后 | L | fixed | S8 |
| D13 | check-doc-sync.sh 引用 config.json#sync_interval_calls 键不存在（实有 todo_sync_interval_calls:196） | M | fixed（考证后改引用或登记映射） | S11 |
| D14 | README_zh.md:136,229「Rules 1-45」滞后 | H | fixed（→1-65，S7 先落） | S9 |
| D15 | CLAUDE.md:33 + skills/task-planner/README.md:72「Rules 1-39」滞后 | H | fixed（→1-65） | S9 |
| D16 | INSTALL_zh.md:293 selftest 42→实 62、scripts 81→实 106 | H | fixed | S10 |
| D17 | docs/ARCHITECTURE.md:81 selftest ×51→实 ×62 | M | fixed | S10 |
| D18 | examples/full-workflow.md:20,26 脚本路径失效（scripts/install.sh、scripts/validate.sh；drift 整改勘误：实位 examples/ 非 docs/） | H | fixed（先核实 validate.sh 实态路径） | S10 |
| D19 | 仓级文档 M/L 计数项全集（companion 7/templates 12+29/references 10 等）+CONTRIBUTING flag 面未验证项 | M/L | fixed+抽验 | S10 |
| D20 | agent-coverage.md:36/50/120 video-fix-executor 登记失实（实体不存在；v124 实造 image/video-generation-executor 两件） | H | fixed（登记改实态+未落地注记，52.2 B 类零容忍） | S12 |
| D21 | 模板面：创作单元并行表区块 templates grep=0+variant 区块缺失裁定 | H/M | 核实后 fixed 或登记设计豁免（Rule 38.3 mini 白名单语义） | S12 |
| D22 | check-drift.sh 头注未反映「61.5 降级佐证，不双跑」定位 | L | fixed | S6 |
| D23 | complex-planner model 档位三面不一致（agent-coverage vs companion frontmatter） | M | fixed（frontmatter=truth source 统一） | S12 |
| D24 | DCS-20 扫描根环境敏感伪失败（命中串在 skill-fix/plan-cost-guard 无关技能；扫描根=SKILL_ROOT/.. 过宽） | M | fixed（扫描根收窄/豁免+归因更正） | S11 |
| D25 | lib/install-companion.sh:63 BACKUP_DIR 落扫描路径+COMPAANION_DIR 变量拼写疑点（本会话抽验新增）+:118/119 mkdir/cp 不一致 | H | fixed | S12 |
| D26 | cursor 位陈旧（10-05，77 行差异，缺 v146/147/148 全部产物） | H | fixed（Phase 5 重同步部署） | Phase 5 |
| D27 | cursor 位 companion/.backup-20260930 六备份污染扫描路径（v146 判例复发） | H | fixed（移出扫描路径非删除） | Phase 5 |
| D28 | 「三部署位」口径 vs detect-tools 五候选不一致；在役位集合未固定 | L | fixed（文档批统一口径+在役位集合定义） | S10 |
| D29 | SKILL.md 卫星技能裸引用路径（billing/cost-control 等） | L | SKIP（卫星技能设计模式；References 表已用 ../ 前缀正常） | — |
| D30 | v146「cursor 位缺失」系用错名核查（planning-with-files；实际位名 task-planner 存在） | M | 销账（D26/D28 已修正口径；v146 findings 历史不改写，此处登记更正） | — |
| D31 | C32 措辞分叉（v102 遗留 L11） | M | 销账（S3 清单5实证 SKILL C32 与 alignment-review 无分叉） | — |
| D32 | v124 行为级冒烟待新会话（L14） | L | 销账（实体在位+部署 IDENTICAL；行为冒烟属运行时验证非本次静态对齐范围，时效过期） | — |
| D33 | videop1 存量 findings/kb 回填（L13） | M | SKIP（跨仓债，非本仓范围；登记至部署位债清单随 D28 口径） | — |
| D34 | 哨兵删除竞态+指针兜底两级化遗留（L10 后半） | M | SKIP（机制级增强，非静态对齐；登记 deferred 建议） | — |
| D35 | v129 deferred 5 项（L15：check-complete 机器深化/PT-08 口径/并行声明格式/RC 注释漂移/SKIPPED 求和口径） | M | 部分承接+部分销账（S11 核对：check-complete 深化/并行声明格式/RC 注释漂移 3 项已被后续任务消化；PT-08 实态自洽 plan-tier 32/32 PASS 销账；SKIPPED 求和口径仍存在→**遗留登记**：核心门控脚本行为变更风险，建议独立任务） | S11 |
| D36 | S2 未验证项：install.sh --help flag 面/MIGRATION smoke 16 pass | — | fixed（S10 实测：flag 面与 CONTRIBUTING 一致；smoke 实跑 17 pass，MIGRATION 16→17 已修） | S10 |
| D37 | CHANGELOG.md 全程未更新（对齐审查 P2：本任务变更无 CHANGELOG 记录；S2#8/#10/#11 三项漏登随本行补登归档） | M | fixed（主进程补 [Unreleased] 条目，纯增量 trivial 白名单⑥） | 主进程 |
| D38 | 回归新引入守卫锚漏网 ×2（MA-08 断言「6 个伴生」vs S9 改 7；CD-19 宽锚 1-3[5-8] vs 1-65——级联清单按 1-64/^65 形态筛选漏掉计数与宽锚形态） | H | fixed（F1 批：MA-08→7/CD-19→1-6[0-9]\|1-3[5-9]；教训=锚级联筛选须覆盖计数/宽锚形态，非仅上界字面） | F1 |
| D39 | alignment P1×3（full-workflow:192 .py 残留/README:32-38 计数块自相矛盾/properties=40 六处残留含「口径同步」失实声明） | M | fixed（F2/F3 批，自验 FAIL=0） | F2/F3 |
| D40 | 会话指针并行抢占（他会话 v150 写全局指针，本会话恢复后解析落到 v150 计划；set 用法需显式 project-root） | M | fixed（本会话 side 指针显式 set 回 task-v149，--show 复验解析正确） | 主进程 |

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 65=恢复 v142 周期性回顾（重编号非新造） | 考古实证条款源于用户反馈+脚本/键/C39 全在仅文本丢失；v143 :676 仲裁先例=内容零改动重编号；退役=功能删除风险更高且违背用户意图 |
| cursor 位处置=重同步非弃用 | cursor 是 detect-tools 五候选之一且位已存在（陈旧）；弃用=功能删除需用户确认，重同步=对齐修复 |
| D27 备份处置=移出非删除 | v146 判例语义=备份须在扫描路径外；删除备份丢失回滚能力（§五 安全底线） |

## 遗留核对表（Phase 1 归集 — memory 已知遗留 × 现状核对）
<!-- 每项处置三态：本任务修(F#/S# 承接) / 已被后续任务修(核对后销账) / 仍遗留+理由(登记 SKIP) -->

| # | 遗留项 | 来源（memory 锚） | 初步现状 | 处置承接 |
|---|--------|------------------|---------|---------|
| L1 | INDEX.md 幽灵状态行：v133/v135/v138/v142/v143/v144/v146/v147 八行全部落后于实际终态 | task-v147 遗留「INDEX 陈旧条目」+ 本会话一手核实（git merge-base 实证）：v133=已合并 4e734b2（43.5/43.6/51.8 落地）/v135=已合并 b03fd36/v138=complete（merge 1992566+5ed69e7，delivery-summary 在位）/v142=两提交 1a92ef3+a7c01a8 均在 master（其 Rule 58 已被 v143 仲裁重编号 60，critical-rules.md:676 注）/v143/v144/v146/v147 均已合并 | **确认存在（8 行全幽灵）** | S5 |
| L2 | SKILL.md frontmatter 上界措辞（Rules 1-58 旧上界 vs 实际 1-64） | v145/v146 遗留双源登记 | 待 Phase 2 核实 | S6 |
| L3 | SKILL.md Rule 61 括注缺失 | task-v147 遗留 | 待核实 | S6 |
| L4 | v148 DCE 描述（selftest-registry.tsv 中 DCE 行描述与 Rule 64 实态措辞） | task-v147 遗留 | 待核实 | S6 |
| L5 | periodic-review selftest 断言失效：selftest-periodic-review.sh 头注断言「Rule 57 周期性回顾与前后对照」（PR-01..PR-10），但 critical-rules.md 中「周期性回顾/periodic-review」**grep=0 命中**（一手实证 2026-10-08）——v142 的 Rule 57（周期性回顾，1a92ef3 在 master）被 v141 的 Rule 57（迭代测试轮次落盘，critical-rules.md:642 注）占号后条款文本消失，selftest 仍在断言已不存在的文本=永久 FAIL 根因面 | task-v144/v146 遗留「periodic 4 FAIL」+ 本会话一手 grep | **根因面确认（编号撞车后条款文本丢失/迁移未考证）**——修复前先 git show 1a92ef3 考古原文，再裁决：恢复条款（改号）或重接/退役 selftest | S7 |
| L6 | install-companion.sh 备份落扫描路径判例复发（13 处已移出，复发面待扫） | task-v146 遗留 | 待 Phase 2 S4 核实 | S11/S12 |
| L7 | registry 存量行号锚迁移（v136/v138 deferred；AC/行号锚会随行演进失效） | task-v136/v138 deferred | 待 Phase 2 S1 核实 | S8 |
| L8 | DCS-20 部署债（v148 DCE 断言第 20 项登记的部署位债） | task-v148 遗留 | 待 Phase 2 S4 核实 | S12 |
| L9 | cursor 部署位缺失（三部署位口径 vs cursor 位未同步） | task-v146 遗留 | 待 Phase 2 S4 核实 | S12 |
| L10 | master 全量 selftest 基线漂移（曾见 15 FAIL 需 master 对照分类）+ 哨兵删除竞态 | active-plan-pointer-race memory deferred | 基线实测中（上半）｜哨兵竞态=机制缺陷,Phase 2 评估是否本任务修 | S9+基线 |
| L11 | SKILL C32 措辞分叉（v102 遗留：SKILL 与 review-library 的 C32 措辞不一致） | align-audit-2026-10-05 遗留① | 待 Phase 2 S3 核实 | S9 |
| L12 | set-active-plan set 路径缺陷 | task-v147 遗留 | 本会话开场实证：另一会话(bb1908c6)哨兵+side 指针指向已完结 v145——指针陈旧现场复发 | S10 |
| L13 | videop1 存量 findings/kb 回填（部署位侧消费债，跨仓） | task-v145 遗留 | 跨部署位债——核实后登记处置（可能 SKIP=他仓范围） | S12 |
| L14 | v124 行为级冒烟待新会话（media agents，凭证刷新+automation 复测） | task-v124 遗留 | 时效存疑（10-04 登记，后续多任务已动同域）——核对后销账或登记 | 待核对 |
| L15 | v129 deferred 5 项（check-complete 机器深化/PT-08 口径债/并行声明格式/RC 注释漂移/SKIPPED 求和口径） | task-v129 遗留 | 待 Phase 2 S1/S3 逐项核实现状 | S9/S10 |
| L16 | 审计未知面（四面扫描新发现） | 本任务 Phase 2 | — | S9-S12 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| attest 首跑失败：时长格式 ≤15min 不可解析/F1-F6 编号不合 S+纯数字/Phase 4 缺 S-unit 表 | 读 check-plan-dispatch.sh 解析器后精确修正（S+数字 ID/NNmin/补表），二跑通过（SHA 3c054bac） |
| 会话指针现场：plan-created.cjs 枚举到他会话(bb1908c6) side 指针→已完结 v145 | 本会话 mtime 回退解析正确（set-active-plan --show 实证→v149）；他会话陈旧哨兵不动（sid 护栏），登记 L12 审计承接 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 仓根：/mnt/data/dev/task-planner-skill（master 21f7e6b）
- 技能本体：/mnt/data/dev/task-planner-skill/skills/task-planner/
- 部署位（在役确认）：/home/terry/.zcode/skills/task-planner（~/.agents/skills/task-planner 不存在——一手 ls 实证 2026-10-08）
- selftest 守护面：skills/task-planner/scripts/selftest-*.sh（62 个）
- 规则预留账本：plans/.rule-reservations.jsonl（63/64 已 land，下一可用编号 65）

## Visual/Browser Findings
-（无多模态输入）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
