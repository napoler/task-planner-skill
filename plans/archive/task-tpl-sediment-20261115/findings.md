# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 执行期主动任务路径沉淀→模板文件（variant/Plan 模板），后期按已验证正确路径执行（专档 #1）
- R2 沉淀模板须经严格审查+验证（可靠性门）（专档 #1）
- R3 新增轻量子技能：激活后主动分析当前项目→预测问题→补充适配模板，后续任务直接调用（专档 #1）
- 约束（专档 #2）：与在途任务 task-clause-generalize-20261115 scope 隔离，不接手不重锁

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Rule 34 模板生命周期全文 | skills/plan-template-kit/references/critical-rules-template.md:11-22 | ☑ | F3 |
| check-template-type.sh 白名单派生 | skills/task-planner/scripts/check-template-type.sh:1-43 | ☑ | F1 |
| init-session.sh 项目级模板优先级 | skills/task-planner/scripts/init-session.sh:13-19,65-97,570-730,777-789 | ☑ | F2 |
| 计数/级联锚（TL-17 等） | skills/task-planner/scripts/selftest-template-lifecycle.sh:186-204 | ☑ | F4 |
| 卫星 SKILL 形态先例 | skills/plan-template-kit/SKILL.md:1-40（40 行） | ☑ | F7 |
| 部署面与安装清单 | skills/task-planner/scripts/smart-merge-back.sh:377,389,470；lib/install-stub.sh:41,289 | ☑ | F5 |
| 预留账本 | plans/.rule-reservations.jsonl | ☑ | F6 |

## Research Findings
<!-- 子代理结论回填（Rule 19.1）：两个 Explore 子代理 2026-11-15，Handoff #1/#2 -->
- **F1 模板体系现状**：templates/ 顶层 13 个 .md + variant/ 共 **30 个** *-type.md（清单见 Explore 回执）；白名单由 check-template-type.sh:17 动态派生（`general` + `ls variant/*-type.md`，无硬编码）；variant 最小骨架=l0-lite-type.md:1-12（12 行：`<!-- template_type: x -->` 机读头 + `**template_type**`/`**plan_tier**` + Goal + VC(≥2) + Phase 骨架）；Rule 34.4 上限 ≤100 行。
- **F2 项目级模板覆盖原生机制（特性 B 沉淀位可零脚本复用）**：init-session.sh:65-80 `find_project_templates()` 自 CWD 向上找 `.claude/plan-templates` 或 `.zcode/plan-templates`；:82-97 `copy_template` 按文件名 per-file 覆盖（项目级优先于内置）；:667-679 VALID_TYPES **并入项目目录 `*-type.md`**（项目级 variant 自动进白名单）；:707-715/777-789 项目级 `*-type.md` 绝对路径直用作 task_plan 源。本仓 `.zcode/plan-templates/` 现仅 knowledge-brief.md 一文件（实测 ls）。⚠ 项目级放 `task_plan.md` 会覆盖主模板——advisor 默认只写 `*-type.md`，禁覆盖核心 7 计划文件模板。
- **F3 Rule 34 缺口分析（特性 A 立项依据）**：34.3 沉淀触发**仅终验时判定**（三条件）；34.4 流程=提炼→直接新建 variant→四点登记，**无候选暂存、无独立审查、无 render 验证**；34.5 双闸门=查重+泛化性；34.7 全自动生成合约（终验 COMPLETE+命中触发→直接派执行体生成）。用户要求「执行时主动沉淀+严格审查验证」→ 增量补 34.8（执行期沉淀触点+候选暂存+严格审查门）与 34.9（项目模板适配沉淀位）。
- **F4 计数与级联锚**：TL-17（selftest-template-lifecycle.sh:198-204）硬断言 template-guide.md 含 `rule-enhancement` 且含 `30 个`——**本任务不加官方 variant 则计数不动**；卫星级联面=task-planner/SKILL.md:213 路由表行+「11 卫星」计数串、references/critical-rules.md:178,200 分层枚举/路由索引、lib/install-stub.sh:41 `SATELLITE_SKILLS`、README.md:31,72,187、docs/ARCHITECTURE.md:37,85,104、check-skill-modify.sh（守卫白名单，执行期 grep 确认）；selftest-skill-split.sh:18,33,52 固定 4 卫星清单，**新增目录不破坏**。
- **F5 部署面**：smart-merge-back.sh:389,470 `--deploy` 仅覆盖 task-planner 技能目录→3 槽位（~/.zcode、~/.claude、~/.config/opencode）；variant/ 在 task-planner 目录内→被 --deploy 覆盖；**新增顶层卫星目录不被自动部署**→须 install-stub.sh SATELLITE_SKILLS（:41，注释提四宿主含 ~/.cursor）+手工 cp+逐位对账。
- **F6 Rule 编号**：预留账本已至 **107**（task-serial-sync-20261115 landed）；核心 14 条全文纪律（critical-rules.md:180）；本任务增量挂 Rule 34 族子条（34.8/34.9），**无新编号**，new_rule 留空。
- **F7 卫星 SKILL 最小合法形态**：frontmatter `name`+`description` 必备，`model`/`allowed-tools` 可选；plan-template-kit/SKILL.md 40 行=最轻先例（章节：何时读哪份 reference/与机械层关系/沉淀指针/使用入口/边界铁律/卫星路由）。
- **F8 知识库机制**：kb-sync-from-plan.sh → knowledge/entries/_draft-<task>.md → kb-rebuild-index.sh；与模板沉淀（Rule 34）不同机制，仅收尾知识入库用。
- **F9 render 契约**：render_template() init-session.sh:183-279，6 变量+残留 `{{TOKEN}}` fail-closed exit 2（:270-279）；调用接线 :1027-1042（失败 exit 1）；审查门 G2 冒烟直接复用。
- **F10 并发面**：在途 worktree tmp/worktrees/task-clause-generalize-20261115（branch wt/...，HEAD 2042fdc）；其 scope 含 task-planner/SKILL.md:229 与 critical-rules.md:107 行（findings 判例依据=其计划 scope_files），与本任务改的同文件**不同区域**（我改 :213 路由表/路由索引，其改 :229 bullet/:107 条款行）。
- **F11（P1-S1 定稿）**：clause-drafts.md 36 行五节齐（§0 scope/§1 34.8 四要素/§2 34.9 沉淀位/§3 冒烟 spec/§4 五落点级联 spec/§5 dogfood spec）；定稿复核修正 1 处——§3 步骤 3 init 调用形态改为 `TASK_TEMPLATE_TYPE=<type> init-session.sh "<冒烟任务名>"`（原稿 `<sid> <type>` 与真实签名不符）；V-1.1 PASS（34.8 锚=2+G1-G4 锚=7）。
- **F12（P1-S2 定稿）**：advisor-draft.md 60 行（frontmatter name/description 含触发词与排除面+SOP 六步+边界铁律 5 条+卫星路由段）；定稿复核修正 1 类缺陷——4 处「见 findings F2/F9」任务本地指针在落位 SKILL.md 后会悬空，已全部换机制名锚（init-session.sh 原生发现机制/render_template fail-closed 契约）；V-1.2 PASS（name=1+步骤锚=21）。
- **F13（P2 落位回执）**：六单元全过，commit 8bc8e86（10 文件 +96/-26，worktree 清洁）。三处执行期发现：① S5 实测计划写的根路径 README.md/docs/ARCHITECTURE.md **不存在**→实际落点 skills/task-planner/ 下（CA-7 路径已修正登记）；② S5 误将 advisor 归「收编卫星」桶+worktree sweep 发现 selftest-verification-gate.sh VG-06 硬断言 '11 卫星'（真值 12 必破）→ S5b 补漏单元修正：4 新域/7 收编分类+VG-06 计数窗 12 化+registry 同步（实跑 selftest-verification-gate **PASS=13 FAIL=0 exit 0**）；③ S5 报告 README:4 残留经主进程复测=**误报**（全文件 grep 零命中）。103.6 同步核对全绿：五落点 advisor 名 grep 1/2/1/1/4/6、旧计数串 0、TL-17「30 个」未动、34.1-34.7 删除行=0。
- **F14（P2-S6 dogfood 选型）**：候选 `rule-clause-cascade-type`（39 行，机读头+Goal/VC×3/Phase×3/执行范围限制/必要知识储备，G1 自检 PASS，README 已登记 G2/G3 待审）；选型依据=INDEX/archive/git log 指纹显示本仓最高频类型为「规则/条款级联修订」（级联+计数窗+插段防吞锚一体化），30 类查重无同名（rule-enhancement 已占用故新建项目适配型）。
- **F15（103.3 复检 R1 轮+修复回执，commit ff2d992）**：critic 全文回读 9 对象判 **CHANGES_REQUESTED**（9 项）：C-1 advisor/SKILL.md:60 第 5 处 findings 指针漏改（**F12 更正**：「4 处已全清」不实，实为 5 处漏 1）；C-2 README/ARCH 4 处幽灵 `plan-template-advisor/references/` 路径；C-3 critical-rules.md:178 建制规则归属枚举误列 advisor（其规则数=0，已回退 7 卫星、保留路由索引行）；C-4 34.7 全自动合约与 34.8 官方门双通道未衔接（已补衔接句：34.7 生成候选同样须过 G1-G4，34.5 双闸门=G3 输入）；C-5 候选模板仓根路径+本地指针；C-6 install-stub 注释 7→8；C-7 verification-gate 3 处「第 11 卫星」→「第 12 卫星」（CA-12）；C-8 行位次统一（SKILL.md advisor 行移新域组）；C-9 ARCH §2.1 列语义充实。5 修复单元并行全 PASS（fix-f1a/f1b/f2a/f2b/f3 检查点），verification-gate selftest 复跑 PASS=13 FAIL=0。**批评注**：CA-8（.zcode/plan-templates 落位）与 CA-9 属 OPEN 状态（待 G2/G3 过门后落位），非缺失。
- **F16（复检 R2 轮+回归基线锚，review-critic-r2.md）**：C-1..C-9 全 PASS（9/9）；新捕获同类残留 2 项→CA-14：C-10 critical-rules.md:201 路径深度断链（`../plan-template-advisor/` 解析为不存在路径，ls ENOENT 硬证据；应 `../../`，系派发 spec 笔误传播）；C-11 六处「7 卫星/7 个卫星」（README:113,150/install-stub:246,304/ARCH:160,182，全 pre-existing）须**逐点语义判定**——指 SATELLITE_SKILLS rsync 清单者→8，指收编卫星数者**保持 7**（CA-11 后正确值），禁盲改。**回归基线锚（另案登记）**：全量 `run-selftests.sh --fresh`（worktree）=97 项 PASS=95 FAIL=2——`selftest-active-plan`(T11) 与 `selftest-execution-stability`(T11b) 两脚本在 8bc8e86..ff2d992 间零改动且对本任务 9 改动文件引用命中=0 → 预存环境/历史漂移，非本任务回归；记入 VC-6 基线 FAIL 集合（另案修复，不阻本任务）。
- **F17（G2 首跑 FAIL→CA-15 修复→复跑 PASS+CA-8 落位）**：S2 首跑实证 **类型标识派生口径缺陷**——init 从文件名去 `-type.md` 得 `rule-clause-cascade`，候选机读头误写双后缀 `rule-clause-cascade-type`→unknown→generic 回退；对照探针（rule-clause-cascade）全链通过。修复=统一标识（候选+README+advisor SOP 补命名纪律句，CA-15）+候选 VC-3 改等价聚合口径（原引用不存在 scripts/run-selftests.sh）。复跑 PASS（smoke-g2-r2.md：project-level 选中+零残留+五块+指针无污染，commit 71c97ad）。**该教训回写 advisor SOP=沉淀机制 dogfood 的第一手改进**。critic R3 终审 **APPROVED**（NIT-1 非阻断：README 路由表缺 verification-gate 行，pre-existing，登记 follow-up）。S3 回归：新增 FAIL=0（基线与 worktree 各 2 项预存 FAIL 一致：T11/T11b B1；口径=97 selftest 聚合，run-selftests.sh 不存在）。CA-8 落位：.zcode/plan-templates/rule-clause-cascade-type.md+manifest README.md（首个项目适配模板上线）。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 特性 A 落点=Rule 34 族增量子条 34.8/34.9，不新增 Rule 编号 | 增量默认（Rule 74.2a）；编号账本已至 107，避免编号竞态；域归属=模板域（critical-rules.md:178 判定） |
| 候选暂存=计划目录 `template-candidate/` → 审查门 → 官方 variant/ 或项目级 | 零新目录约定零新脚本；plans/ 写入白名单内；未过门禁入官方库 |
| 审查门两级：官方 G1-G4 / 项目级 G1+G2+G3 | G1 结构 lint（34.4 最小结构+≤100 行+机读头）/ G2 render 冒烟（复用 render_template fail-closed）/ G3 独立审查派发（critic 类，对齐用户「严格审查」）/ G4 官方级联四点+计数+selftest（仅官方库） |
| 特性 B 沉淀位=`<项目>/.zcode/plan-templates/`（或 .claude 位） | 复用 F2 原生发现机制（init 自动并入白名单），零接线零脚本；advisor 只写 `*-type.md`+manifest，禁覆盖核心计划文件模板 |
| 不新增 selftest 脚本/机器门 | 文本优先铁律（宪法 §二/§四 P0）；验收用既有 selftest+grep 判据承载 |
| advisor 最小形态=单 SKILL.md（name/description） | 用户要求「简单」；plan-template-kit 40 行先例；SOP 内联不过度分层 |
| template_type=general | 混合型任务（规则增款+新技能+项目模板 dogfood），无单一既有类型覆盖；rule-enhancement 聚焦纯条款修订不含技能目录新增（先例：clause-generalize 同判 general） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 旧计划 task-clause-generalize 哈希失配告警（他会话获批后改动未重锁） | 用户裁决不碰仅报告（专档 #2）；本任务 scope 与其文件级重叠面（SKILL.md/critical-rules.md）不同区域，FMEA 登记并集解兜底 |
| Explore 报 rule-reserve.sh 读取失败（sed 路径异常） | 编号留空不需 reserve；land 时再实测（账本事实已由 jsonl 取证，F6） |

## Resources
- skills/task-planner/templates/variant/（30 个 *-type.md，l0-lite-type.md=最简骨架先例）
- skills/plan-template-kit/references/critical-rules-template.md（Rule 34 全文 :11-22）
- skills/task-planner/scripts/init-session.sh（模板优先级 :65-97 / 类型解析 :570-730 / render :183-279）
- skills/task-planner/scripts/check-template-type.sh（白名单派生 :17）
- skills/task-planner/lib/install-stub.sh:41（SATELLITE_SKILLS）
- skills/task-planner/scripts/smart-merge-back.sh（--deploy 3 槽位 :389,470）
- plans/.rule-reservations.jsonl（编号账本）

## Visual/Browser Findings
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位；禁推测填充 -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
