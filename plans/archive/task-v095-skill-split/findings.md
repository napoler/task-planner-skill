# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户指令（2026-09-29）：参考 skill-creator 方法论，将 task-planner 技能拆分——模板生成等非核心功能拆为独立技能，降低主技能（SKILL.md 556 行）复杂度，确保执行效率与稳定性
- 效率的技术本质（测绘确认）：每次触发加载的上下文 = SKILL.md 正文；references/scripts 不读不占上下文 ⇒ 效率收益全部来自「SKILL.md 段落外迁至卫星技能（按需加载）」，仅移动 references 文件不产生上下文收益
- 硬约束（锚点保全清单）：① Rule 1-39 编号冻结（`Rules 1-3[1-9]` 宽容锚）② Rule 17/18/30-39 摘要行 + C19/C25/C26 检查项行留守 SKILL.md（selftest grep 锚）③ 行数锚 ≤558 仅上界（缩减安全）④ 三部署位同步部署 ⑤ hook 接线（~/.zcode/cli/config.json）不动 ⑥ 并行任务 v094 worktree 互不踩踏

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[01-explore 结构测绘（2026-09-29）]** 全量报告落盘 `subagent-state/01-explore-structure.md`（150 行，A 段落地图/B 消费关系/C 耦合风险/D 候选评估四表）。要点：
  1. 总盘 151 文件/23945 行：SKILL.md 556 + reference.md 285 + references/ 14 文件 2432 + scripts/ 68 文件 14388 + templates/ 26 文件 ≈3370 + config.json 440
  2. 三大耦合雷区：① selftest 硬锚（4 处行数钉 ≤558×4、Rule 17/18/30-39 摘要行 grep 锚、C19/C25/C26 项锚、Rules 1-3[1-9] 计数锚）② check-template-type 白名单动态派生焊死 attest 链（variant 目录不可随意移动）③ config.json 单文件 440 行 + T9/T10 类断言要求键名 ≥2 文件同现
  3. 最适合拆（Explore 排序）：②调研路由 SKILL.md L466-506（41 行零机耦）/ ③成本控制（billing 61+cost-control 171+cost_log 72 纯文档闭环）/ ⑤skill-collaboration（113 行内聚，需随迁 selftest-skill-collab+保留 critical-rules 22.3.3 指针）
  4. 模板体系（用户点名）：收益最大（≈5000 行面）难度最高（白名单派生+attest/check-complete 门控链跨缝）——可行切法 = **知识层外迁（template-mapping 230+template-guide 276+§任务模板库 L542-556+Rule 16/34 SOP），机械层留守（templates/ variant 库+init-session+check-template-type+attest 门控）**，卫星技能只读引用 variant 目录零脚本改动
  5. 零机耦内敛候选：Chain 模式详解 L243-284（42 行，无脚本锚，并入 reference.md）/ 高频漂移 L509-538（30 行，Rule 15 指针已在 critical-rules）/ Read-vs-Write L122-130（9 行，Rule 20.5 并入 critical-rules）
  6. 现存已知漂移（顺带修复项）：template-guide.md「13 个」计数锚 vs variant 实际 16 个（v093 加 video-fix 后未同步）；uninstall.sh 默认根路径 $HOME/dev/task-planner 与真实仓 /mnt/data/dev/task-planner-skill 不符
  7. 部署事实：三部署位（~/.zcode、~/.claude、~/.config/opencode）与 canonical 逐字节一致；install.sh = 全量 rsync（scripts+references+templates+config.json）；新卫星技能需扩 install 清单 + check-skill-modify.sh:29 保护 pattern 登记

## Research Findings（P1 增补：基线定格与 v094 影响判定）
- **[基线实测（2026-09-29）]** 34 个 selftest 脚本全 rc=0，合计 **543 PASS / 0 FAIL**（含新增 selftest-tier-b 18 用例；delegation=38 实测补齐）。VC-2 判定基准 = 543/0（非计划草案里的 525/0 旧口径）
- **[v094 合并影响判定]** 规划期间 v094-tier-b-rollout 已完成合并回 master（dcfd8a3+簿记 5c1cdcd），worktree/分支已清理 → **FMEA F3 并行冲突风险解除**。改动面：SKILL.md ±6 行（仍 556 行，段落完整）、critical-rules 14 行（Rule 14④ mini 直做通道——本任务留守区）、check-delegation/check-dispatch/resolve-interaction-mode 三脚本、mini-lite 模板、registry+1。**5 个迁移目标 references 文件行数与测绘报告逐字节一致 = 测绘报告 §B/§C 对本任务范围内仍有效**；行号地图小漂移由 F6（grep 段落标题重定位）覆盖
- **[selftest-tier-b 新锚点]** L40/41 两锚（`diff 分级（[task-v094 T-B6]）`/`轻 diff 合并（[task-v094 T-B6]）`）位于 SKILL.md「代码编辑强制隔离」段 = 留守核心区零冲突；`④ mini 直做通道` 锚在 critical-rules Rule 14 = 本任务只扩 Rule 15/20.5 不触碰。P6 锚点复验清单需追加这 3 锚

## 迁移映射表（P1 冻结版 — 执行期逐项 tick，终验 V3 证据）
| # | 源（主仓 skills/task-planner/） | 目标 | 锚点/引用处置 | tick |
|---|-------------------------------|------|--------------|------|
| M1 | SKILL.md §调研类操作（grep `调研类操作` 定位，测绘 L466-506） | plan-research-router/references/research-routing.md | 主技能原地 1 行 Skill() 指针；零 selftest 锚 | ☐ |
| M2 | SKILL.md 路由表 github 行 + 调研段内 §反模式互引 | 随 M1 同步指针 | 段内自洽 | ☐ |
| M3 | references/template-guide.md（276 行） | plan-template-kit/references/ | selftest-template-lifecycle 路径锚同步；「13 个」计数修 16 | ☐ |
| M4 | references/template-mapping.md（230 行） | plan-template-kit/references/ | selftest-mechanism-profile/selftest-template-lifecycle 路径锚同步；SKILL.md frontmatter references 清单更新 | ☐ |
| M5 | SKILL.md §任务模板库（grep `任务模板库` 定位） | 收敛为指针行（指向 plan-template-kit） | knowledge-brief≥2 次锚保留确认 | ☐ |
| M6 | companion/agents/plan-writer.md 模板引用三处（L22/39/50-64） | 路径改指卫星 | 注意其为 agents/ 安装位非 skills/ | ☐ |
| M7 | references/billing.md（61）+ references/cost-control.md（171） | plan-cost-guard/references/ | SKILL.md References 表行 + critical-rules Rule 17 段路径 + batch-quality-gate 互引同步；Rule 17 摘要行留守 | ☐ |
| M8 | templates/cost_log.md（72，无脚本消费） | plan-cost-guard/references/（或 templates/） | install-stub rsync templates/ 目录不受影响 | ☐ |
| M9 | references/skill-collaboration.md（113） | plan-collab-router/references/ | selftest-skill-collab 随迁改路径 + selftest-shared-tracker/selftest-fallback 引用 + subagent-fallback.sh:288 hint + registry.tsv dep_anchors + critical-rules 22.3.3 指针保留 | ☐ |
| M10 | SKILL.md §Chain 模式详解（grep `Chain 模式详解` 定位） | reference.md（Chain Handoff Contract 权威源所在，消重） | 无脚本锚 | ☐ |
| M11 | SKILL.md §高频漂移纠正（grep `高频漂移` 定位） | critical-rules.md Rule 15 扩充（只增子条） | Rule 15 摘要行留守 SKILL.md | ☐ |
| M12 | SKILL.md §Read vs Write 矩阵（L122） | critical-rules.md Rule 20.5 | 无锚 | ☐ |
| M13 | install.sh rsync 清单 + check-skill-modify.sh 保护 pattern + 新建 selftest-skill-split.sh + registry.tsv 登记 | P7 安装面四件套 | registry T02/T03 计数断言同步 | ☐ |

## Research Findings（P2 执行期回填 — 已按 29.2 折叠为索引，明细见检查点）
- **[P2 试点卫星 plan-research-router（2026-09-29，COMPLETE）]** 三步式范式（骨架→外迁+指针化→锚点同步）闭环成功零回归：卫星 2 文件（SKILL.md 41 行定稿+references/research-routing.md 42 行含双路 SOP 全文）；主 SKILL.md 556→519；期间抓出并修复 T11×3 内容锚断链（S3b，双处核验阈值未放宽）；全量复验 543/0 持平。github-cli 触发词重叠→P8 CR 复查项。明细检查点：subagent-state/21-p2-s1、22-p2-s2、23-p2-s3、24-p2-s3b.md

- **[P3-S1（2026-09-29，已 Read 复核）]** plan-template-kit 卫星建成：SKILL.md 34 行（纯知识层定位/两 references 分工/机械层留守声明/`../task-planner/templates/variant/` 相对引用/34.2 四点同步指针/双入口/边界铁律）；template-guide.md+template-mapping.md git mv 入卫星（保留历史）；「13 个」→16 修正且补全枚举（mini-lite/video/video-fix，VC 字段描述取自各 variant 文件头注释非臆造）；template-mapping 零内容改动（其「v093 起 16 类」已正确）。**S3 注意**：template-guide §2.4/§2.5 的 22/23/26 锚计数未动（描述全仓口径，templates/ 未变则口径不变）；TL-17 断言「13 个」待 S3 同步改「16 个」

- **[P3-S2（2026-09-29，已 Read 检查点复核）]** 主 SKILL.md 519→516：frontmatter 两行 references → 1 行卫星指针；Rule 16/Rule 37 摘要行与路由表「类型适配（Rule 37）」三处仅改路径前缀、锚子串保全（grep 复核在位）；§任务模板库 收敛为 9 行指针节（①Rule 16 ②Rule 34.3→34.4 ③knowledge-brief 第 6 文件 + Skill 主路由行），knowledge-brief 计数=2 达标。**plan-writer.md 零改动（负结果实证）**：4 组 grep 全库核实无 template-mapping/template-guide 路径引用、映射表无 §六 源注明——测绘报告 C5 的 L22/39/50-64 引用描述与 v094 后现状不符，以实测为准。**移交 P8 CR 复查项**：§任务模板库 压缩时「必要知识储备采集条款细则」自主技能删除，需确认卫星 template-guide §2.4 知识储备契约已等价承接（防内容丢失）
- **[P3-S3（2026-09-29，已 Read 检查点+主进程独立复验）]** 两 selftest 的 TMAP/TGUIDE 改 `$SKILL_ROOT/../plan-template-kit/references/` 同级解析；TL-17 计数断言 13 个→16 个（阈值未放宽、未删断言）；critical-rules 三行随迁（Rule 16 计数 13→16+枚举补全、34.2/37.1 路径前缀，TL-03/MP-02 依赖子串全保留）。验证链：TL 18/0 + MP 19/0 + KB 16/0 + check-template-type 白名单 17（general+16 类型实测）+ attest --verify exit 0 + 全量无 FAIL。**主进程独立复验：34 脚本 543 PASS/0 FAIL 持平**（executor 汇报「35 脚本」系 glob 误计 selftest-registry.tsv，已纠正口径）。遗留观察：critical-rules L61「grep -rl 必要知识储备 templates/ = 21」验收锚未在授权范围未动，templates/ 零改动故口径成立

- **[P4-S1（2026-09-29，已 Read 检查点复核）]** plan-cost-guard 卫星建成：SKILL.md 37 行（description 含 performance 排除项）；billing/cost-control/templates→cost_log 三件 git mv 入卫星（rename 实证）；迁移文件内 4 处路径文本随迁（cost-control ×3、billing ×1，`grep templates/` 零残留）；cost_log 零改动（其内部相对引用同目录后仍有效）。消费方清点（P4 开工前）：scripts/selftest **零断言**；待 S2 同步面=SKILL.md 5 处+critical-rules 2 处+batch-quality-gate 1 处+README 1 处（扩围③已登记）

- **[P4-S2/S3（2026-09-29，已 Read 检查点+主进程验证）]** S2 九处指针化全过：SKILL.md 517→515（frontmatter 两行合一卫星指针+Rule 17 摘要行路径随迁且「成本控制 — 降低 Opus 使用频率」「cost_log 记录」子串保全+References 表 2 行）；critical-rules L64/L73（17.8 编号零改动）；batch-quality-gate L138；README 安装树 2 行树形标注。自验 `grep -v plan-cost-guard` 零残留。S3 主进程白名单③接管验证：残留终检零命中+全量 34 脚本 543/0。**移交 P7 清单（defer 裁定）**：仓根文档死路径 3 处（CLAUDE.md:35/README_zh.md:139/docs/ARCHITECTURE.md:50 仍写 billing.md）+README L66「8 篇」计数——P5/P6 迁移后 references/ 计数还会变，P7 一次性收口避免二次返工

- **[P5-S1（2026-09-29，已 Read 检查点复核）]** plan-collab-router 卫星建成：SKILL.md 40 行（三族顺序敏感/22.3.3 档位/纯知识层声明/排除 Rule 39 dynamic-workflows）；skill-collaboration.md git mv 113 行无损（similarity 92%，唯一 diff=L72 两处自引用内化为「见本文 §二/§四」）。**中间态披露**：3 个 selftest+fallback hint+registry 仍指旧路径，P5-S2 完成前全量 selftest 预期 FAIL（计划内中间态，勿误判回归）

- **[P5-S2/S3（2026-09-29，已 Read 检查点+主进程独立复验）]** 七文件同步全过：协同段收敛 7 行指针（标题锚/skill_collab_enforce 键名/四族名/`skill-collaboration.md`×5 全保留）+Rule 30 行/表行/外部行路径随迁+critical-rules 两处仅路径 token+3 selftest COLLAB 随迁+hint 与 T10a 逐字符一致（PAIR-CONSISTENT 实证）+registry 3 行。**意外事件**：Step1 收敛致 selftest-workflow-orchestration WF-09 锚（`dynamic-workflows（用户显式点名`）断链——executor 按授权行内修复（行首关键词写回，断言未放宽），复验 WF 16/16。**主进程独立复验：34 脚本 543/0，SKILL.md 513 行**。新增观察登记：① jq 1.7 下 selftest-fallback 2 条 stderr 噪音（P1 基线即存在，非本任务引入，断言仍 PASS）→ 后续任务修；② config.json:99 description 死路径文本（config 零改动约束内，P7/CR 裁定）；③ 仓根死路径 defer 清单维持 P7 收口

- **[P6-S1（2026-09-29，已 Read 检查点复核）]** Chain 模式详解内敛 reference.md：预防性断言清点实证零锚（grep Chain/chain_mode/linked/fan-out 于 selftest 全零命中）；整段逐字迁入（diff 仅差标题行）+来源注记；与既有 Chain Handoff Contract 判定为互补关系零删减（一处近似重叠标注待 CR 裁量）；主 SKILL.md 513→474（-39），指针节 3 行。移交观察：SKILL.md 执行循环内 L126/L138 仍有 linked/fan-out 操作简述（属流程步骤非详解，未动）

- **[P6-S2/S2b（2026-09-29，已 Read 检查点复核）]** S2：高频漂移→critical-rules 15.1-15.3（只增子条，编号完整性 167→170 实证）+Read-vs-Write→20.5 追加判定矩阵；TB-11 锚「A/B/C 判定后做漂移检查」主动识别双处保全（critical-rules 15.1 表+主 SKILL 指针行）；474→443。S2b：三指针节压缩+空行收拢 443→**429（≤430 达标）**，30+ 锚点差集空。**遗留缺陷**：S2 增补使 critical-rules 21.2/22.4 行号（142/154）漂出 selftest-knowledge-brief T6 硬窗口（<135）→ 15/16 FAIL，S2b 以 HEAD 还原对照实证根因后逐字节还原；S2c 修复窗口随迁。**执行偏差再犯登记**：S2b 为验证根因再次使用 HEAD 还原式操作（虽备份还原零损失），禁 git 约束的执行面已在 Error Log Prevention 覆盖，P7/P8 派发继续显式声明

- **[P6-S3（2026-09-29，主进程白名单③终验）]** 锚点全集 24 项逐条 grep 全在位（含 T-B6 双锚固定串补验——selftest-tier-b 硬编码部署位路径，worktree 侧必须独立验）；SKILL.md **429 行（≤430 达标，556→429 = -22.8%）**；全量 34 脚本 **543 PASS/0 FAIL**。P6 期间锚点发现累计：TB-11（task-boundary）、T6 窗口（knowledge-brief）、WF-09（workflow）三处测绘外内容锚全部「跟随迁移」式修复，零放宽零删除

- **[P7-S1/S1b（2026-09-29，已 Read 检查点复核）]** S1 安装面四件套：卫星安装扩展最小 diff 落在 lib/install-stub.sh（SATELLITE_SKILLS 数组+install_satellite_skills()，全量/stub 位统一处理+幂等防踩）；check-skill-modify 精确 4 名白名单（拒泛化前缀防误伤）；selftest-skill-split.sh 新建 41 断言全绿；registry 34→35 行（rows=断言同步过）。守卫行为级验证：卫星路径 warn 注入/enforce BLOCKED exit 2/非保护路径静默三分支实测。S1b 文档收口：4 文件 11 处树行/计数标注；**计数纠偏=references 基线实测 13 篇（测绘表 14 系误计）迁 5 剩 8**，按实测写入；CHANGELOG 历史记录不改（防篡改史）；skill-collaboration 在 4 文件零死路径（已指针化）。全量 35 脚本无 FAIL

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 基线口径定格 543/0（34 脚本），取代草案 525/0 旧口径 | v094 并行合并新增 selftest-tier-b 等；VC-2 以 P1 实测为判定基准（Rule 36.3 基线先行） |
| F3 并行合并冲突风险解除（不删除 FMEA 行，保留兜底动作） | v094 已于规划期完成合并（5c1cdcd）；P7 S3 合并前仍执行 merge-base 预检作为例行兜底 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 测绘报告（全量）：`plans/task-v095-skill-split/subagent-state/01-explore-structure.md`
- hook 接线：`/home/terry/.zcode/cli/config.json` hooks.events（4 事件 → ~/.zcode/skills/task-planner/scripts/zcode-*.sh）
- 锚点样例：selftest-batch-pilot.sh:55、selftest-execution-stability.sh:72、selftest-knowledge-brief.sh:38、selftest-skill-collab.sh:81（行数钉 ≤558）；check-skill-modify.sh:29（保护 pattern）；zcode-posttooluse.sh:108（唯一 SKILL_ROOT 硬编码）
- skill-creator 方法论：渐进式披露三层（metadata 常驻 / SKILL.md 触发加载 <500 行 / references 按需）；description=触发信号要写触发词

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
