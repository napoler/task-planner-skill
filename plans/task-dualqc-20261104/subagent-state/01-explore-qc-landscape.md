# 01-explore-qc-landscape（只读调研：Rule 103 双轮质检接线现状）

源仓 = /mnt/data/dev/task-planner-skill（master，HEAD 7d48161；R8-b 预放宽=008e680 已落）。以下路径均相对源仓 skills/。

## 1. 现有完成验证/自审机制

### 1a. task-planner/references/completion-gate.md（7 行，纯指针）
- 全契约已于 task-v173 迁至卫星 verification-gate/references/critical-rules-verification.md Rule 84.4。
- L3 指针注记（Rule 82 分层纪律禁镜像副本）、L5 权威位置、L7 调用时机（子代理返回 done 需 Read 复核时）。
- 无「自审/独立复检」字样；独立复检最近似物=84.7 内容审查门（下）。

### 1b. task-planner/references/critical-rules.md（203 行）
- Rule 26（质量门控）：### 标题 L54，子条 26.1 L58/26.2 L66/26.3 L68/26.4 L78/26.5 L80/26.6 L82。
- Rule 51（需求覆盖与完成声称）：### 标题 L84，子条 51.1 L87 → 51.1a L88/51.2 L90/51.3 L91/51.4 L92/51.5 L93/51.6 L94/51.7 L95/51.8 L96/51.9 L98/51.10 L100/51.11 L102/51.12 L104/51.13 L106。
- 「1-102 全集索引」段：本文件 L191 `## 卫星路由索引（11 卫星…）`（核心尾部段；「Rules 1-102 全集索引」措辞本体在 SKILL.md，见 §6）；L140 有编号说明 HTML 注释（77/78/79 预留未落地史）。
- 新规则插入惯例=**尾部追加**（R81 L159/R82 L173/R83 L181 依次在文件尾追加，Rule 82 边界注 L177 说明核心在位 14 条；非核心域新规则→其归属卫星文件尾部，Rule 20.6 先过 rule-reserve.sh 查重，R82 L177）。
- Rule 103 若落纪律域：插入位=task-discipline/references/critical-rules-discipline.md 尾部（Rule 102 之后，L704 后）；若落验证域：verification-gate Rule 84 子条扩展（84.8）或新 Rule 84.x/新编号。

### 1c. verification-gate 卫星
- references/critical-rules-verification.md（52 行）Rule 84 子条：84.1 L15/84.2 L17/84.3 L19-25/84.4 L27-33（子代理验证协议：done≠完成、Read 实际文件、标记 complete、失败重派、证据要求）/84.5 L35-42（终验复验 SOP，L42 已有 Rule 33.3 指针=「验证由全新独立子代理执行，主进程禁自测替代验收」——**双轮复检的既有最近锚**）/84.6 L44（机制行）/84.7 L46-52（内容审查门：84.7.2 独立子代理=「Verifier/critic 档，全新上下文」L48、84.7.3 审查输入=交付物+VC 表+R 原文 L49、84.7.4 结论落盘 findings.md L50、84.7.5 与机器层互补 L51）。
- scripts/run-verification.sh 入口形态：L10 `用法: bash run-verification.sh <plan-dir>`；输入=plan-dir/verification.md「**Verify command**:」行；输出逐 VC PASS/FAIL/SKIP 明细+汇总；退出码 0=全 PASS/仅 SKIP、1=有 FAIL、2=输入异常（L14）；bash+grep/sed 无 jq。
- 注意：84.7.2「Verifier/critic 档」是档位提法雏形但未定档（无轻/中/重升档量化），103 需补「复检模型比执行体升一档」的量化口径。

### 1d. task-discipline 尾部规则（references/critical-rules-discipline.md，704 行）
- 95 L619（非必要暂停禁令与执行优先）；97 L632（惰性上抛禁令，97.1-97.7）；98 L646（否定/矛盾触发整理）；99 L657（跨项目授权）；100 L670（临时目录统一）；101 L682（git 使用加强）；102 L693（新请求计划同步反思门，102.0-102.5 至 L704）。
- 标题格式惯例：`### <NN> <标题>（P0/P1 — <task-id>，目标：…；判定面=…；衔接 Rule …，既有…原文零改动）`；95/97 有 **建制（为什么有这条）** 块。
- **Rule 103 若落纪律域=插 L704 之后（文件尾，Rule 102 段后）；若落验证域=verification-gate 84.x 扩展（推荐面：84.7 已立独立审查子代理先例，双轮复检属验证全链路域）**。

## 2. 派发模板（task-planner/templates/subagent_dispatch.md，112 行）
段结构（## 段名+行号）：
- L13 `# Subagent Dispatch Prompt`；L15 §1 目标；L22 §2 输入（四文件必传）；L36 伴飞技能（Rule 59.2）；L41 §必要知识储备；L49 §3 验收标准(2-5 条可观察证据)；L55 §4 Scope 禁改清单；L58 §4b 变更类型约束（Rule 74 三判门）；L66 §5 工作路径；L69 §6 时长预算；L72 §7 返回格式（Rule 22.4b 8 固定字段，**8 字段后不得有任何内容**）；L95 §8 checkpoint 落盘（Rule 22.8）；L101 §9 上下文预算（Rule 22.4 第⑨字段）；L104 §10 防幻觉契约（Rule 71.5 禁删）；L111 §定稿可行性判别模式（Rule 74.4，L112 内档位口径「Rule 43.2 min 档即可」）。
- 现状：无「自检/自审」段——§7 返回格式 8 字段固定（新增「执行度自审」字段需改 8 字段契约=Rule 22.4b 联动，注意 L72「不得增删」硬措辞与 task-v161 优先级声明（§7 内 L84 附近：8 字段指令优先于 agent 定义输出模板、段填写禁令））。
- templates/ 全清单（17 项）：batch_report.md、delivery-summary.md、deprecated.md、findings.md、knowledge-brief.md、notepad-learnings.md、progress.md、session-handoff.md、shared-tracker.md、subagent_dispatch.md、task_plan.md、user-session-log.md、verification.md、variant/（子目录，含 image-type.md/multiview-ref-type.md 等）。

## 3. 模型档位梯子（task-dispatch 卫星）
- 权威档位表述=references/critical-rules-dispatch.md：
  - L14（Rule 14 段）：变更规模路由 ≤3 文件/≤300 行 → code-assistant（haiku-1）；>3 文件或 >300 行 → executor（sonnet-1）。
  - L24（21.3）：机械型 haiku-1/判断型 sonnet-1；opus 主会话只做拆分/派发/验收。
  - L30（21.4 失败兜底链）：升级 Complex Problem Solver（高复杂度规划类亦可升级 complex-planner，**GLM5.3/Opus 级备用**）。
  - L53（22.3）：拆细先于升档；③降档(升一档 model，如 haiku→sonnet)。
  - **L206（96.2 模型分档）=计划期正向选档权威行**：轻档=机械型（haiku-1）/中档=判断型（sonnet-1）/重档=复杂推理多轮试错型（GLM5.3/Opus 级备用通道=21.4 失败兜底链既有口径）；约束=59.4 超档拆细不升档、22.3 拆细先于升档、43.2 最小可承载档位优先。
- Rule 96 子条：### 96 标题 L188；96.1 L192（激活默认档矩阵）/96.2 L206（模型分档）/96.3 L208（并行硬标注）/96.4 L210（同消息并发）/96.5 L212（指标留痕）/96.6 L214（管辖边界）。SKILL.md 62 行内无档位细节（全在 references）。
- 升级机制措辞位置：L30（21.4 兜底链升级 Complex Problem Solver/GLM5.3/Opus）、L53（22.3③ 升一档 haiku→sonnet）、L158（59.4 计划期拆细先于升档）、L183（68.3 禁为异构升/降档）。**「复检升一档」无现成量化定义——103 需在 96.2 档位表上定「执行体档位+1=复检档位」映射（haiku→sonnet、sonnet→GLM5.3/Opus）**。

## 4. 纪元锚级联面（R8-b 预放宽已落 008e680）
结论：**零级联（顶锚面）**。R8-b 提交 008e680 已把顶锚全部预放宽到 11x 窗口：
- 现行锚形态=各 selftest 内 `1-(8[0-9]|9[0-9]|10[0-9]|11[0-9])([^0-9]|$)`（30 个 .sh 文件含 1-10[0-9]/11[0-9] 字面），例：
  - selftest-anti-deferral.sh:86（AD-09 纪元窗 ≥3）、:91（AD-10 `其余 [89][0-9] 条` 计数面）
  - selftest-subagent-activation.sh:65-66（SA-11 同窗 ≥3）、:67（SA-12 `其余 [89][0-9] 条` ≥2）
  - selftest-session-log.sh:74（负样本探针 1-120 不得命中 11x 窗）
  - selftest-error-loop.sh:76、selftest-reflect-verify.sh:67、selftest-plan-tier.sh:97、selftest-tool-selection.sh:86、selftest-lane-advancement.sh:130、selftest-requirement-coverage.sh:145、selftest-reliability-institution.sh:97、selftest-iteration-persistence.sh:165、selftest-research-first.sh:78/87、selftest-verification-gate.sh:82、selftest-context-pressure.sh:109/118、selftest-conclusion-discipline.sh:91、selftest-parallel-scheduling.sh:121、selftest-capability-persistence.sh:94、selftest-execution-honesty.sh:105、selftest-absorption-discipline.sh:43-102 等。
- **103 在 11x 窗（100-119）内 → 上述所有断言仍 PASS，无需改任何纪元顶锚。**
- 需人工随动的仅是**字面计数口径**（非正则 FAIL）：SKILL.md L9/L210/L253 的 `Rules 1-102 全集索引` 字面、`其余 85 条`、纪律域枚举（L210 尾部 `…/100/101/102 纪律域`）须随 103 并入改 `1-103`/`其余 86 条`/枚举追加 103；AD-08（selftest-anti-deferral.sh:82 `94,95,97` 路由枚举 ≥1 不变）、AD-10/SA-12 的 `其余 [89][0-9] 条` 计数面（85→86 后仍 ≥2 PASS，**注释史随动一行**）。
- 判据基线：R8-b 提交信息=「fresh 94/94 + live 1-102/85 条全绿」（47caded/008e680 message）。

## 5. selftest 登记
- 登记文件=**scripts/selftest-registry.tsv**（95 行=表头 1+登记 94；列格式 4 列 tab 分隔：`script\tdomain\ttrigger_scenarios\tdep_anchors`，表头 L1）。
- 登记惯例：新增 selftest-*.sh 必须补 TSV 一行（selftest-registry.sh T02 无缺失/T03 无孤儿/T04 无重复/T05 四字段完整 双向守护）；最近例=末 4 行（selftest-subagent-activation.sh 行、selftest-anti-deferral.sh 行——domain 列写 `Rule NN …(AD-01..12…)`，dep_anchors 列分号分隔被守文件含 `scripts/selftest-registry.tsv` 自登记 + 各卫星 references 路径；selftest-verification-gate.sh 行=VG-01..12 十二维度例）。
- 计数锚：SKILL.md/README/progress.md 中无 `94/94` 形态钉值；仅 run-selftests.sh:79 注释「其余 73 脚本串行」（top-5 并行注记，非总数断言）；AD-12 类负断言只管 registry 自登记闭环。新增 selftest 后总数 95 无机器钉值，仅需 TSV 一行 + run-selftests glob 自动枚举。

## 6. SKILL.md 核心接线点（task-planner/SKILL.md）
- L11 completion-gate 指针行（→Rule 84.4）；L19 卫星技能行（verification-gate 全链路描述）；L56 计划期 VC 可执行命令引用（Rule 84.1 + Skill("verification-gate")）；L97 Phase 执行循环 V-N 校验行（Rule 84.3/84.4，SOP→卫星 Step 2）；L105 Code Review Gate；L107 终验交付机械子动作；L115-116 终验智能子动作（Rule 84.5 Step 3 + run-verification.sh 统一入口）；L118 委派率统计（Rule 25.4/L0-E P4）。
- L206 卫星路由表 verification-gate 行（11 卫星表内，域=任务验证全链路，Rule 84）；路由表段头 L192 `## 卫星路由表（11 卫星…）`。
- L208 `## Critical Rules 指针（核心域）` 段；L210 `Rules 1-102 全集索引：**核心在位 14 条**（1,2,3,5,19,20,26,51,62,66,80,81,82,83）…其余 85 条…（含 Rule 84 验证域、Rule 85/…/102 纪律域）`；L253 References 表行 `Critical Rules 核心域 1-102 全集索引（14 条核心全文+…）`。
- L9 frontmatter 指针行（同「Rules 1-102 全集索引」字面，AD-09 三处=frontmatter/全文索引/References 表）。
- new_rule 声明惯例：L60「规则编号预留（Rule 20.6）：新增 Rule 编号在计划声明 `new_rule: <NN>`；attest 自动查重」；机器消费=attest-plan.sh:479-482（HTML 注释 `<!-- new_rule: <N> -->` 或配置表行 `| new_rule | <N> |` 两形态）+rule-reserve.sh。
- Phase 执行循环段头 L78（`- [ ] **Phase 执行循环（每 Phase 独立闭环）**`）。

## 7. 部署位拓扑
| 部署位 | git? | toplevel | 最近提交 | SKILL.md diff vs 源仓 |
|---|---|---|---|---|
| ~/.zcode/skills/task-planner | 是 | /home/terry/.zcode（monorepo，工作区有 memories 改动=正常在途） | 32bb716「chore(task-crossprojauth R8-b): 纪元顶锚 11x 预放宽（同源仓 008e680）」 | **0 行** |
| ~/.agents/skills/task-planner | 不存在 | — | — | — |
| ~/.cursor/skills/task-planner | **非 git 仓**（NOT-git，仅落盘，memory 提示口径确认） | — | — | **0 行** |
| ~/.claude/skills/task-planner | 是 | /home/terry/.claude | 456fed0（同源仓 R8-b） | **0 行** |

收口态=四端 SKILL.md 全一致（diff=0）；新增 Rule 103 需级联落 zcode/claude 两个 git 位 + cursor 落盘位。

## 综合结论（103 接线面）
1. **规则载体首选**=verification-gate 卫星（验证全链路域，84.7 已有「独立子代理复检+升档提法雏形 Verifier/critic 档」先例）→ 双轮=84.4②（Read 复核）升级「执行体自审上报」+ 新增「独立复检轮（升一档）」；或纪律域 Rule 103 尾部追加（critical-rules-discipline.md L704 后，格式照 97/102 范式）。
2. **派发模板**=subagent_dispatch.md 加「执行度自审」段/字段：注意 §7 八字段「不得增删」硬措辞（L72）+task-v161 优先级声明——自审面更宜落 §8 checkpoint 或验收面（§3 附自审回执）而非破坏 8 字段契约。
3. **档位升一档**=96.2 L206 三档表（轻 haiku-1/中 sonnet-1/重 GLM5.3-Opus）上定映射；升级链措辞先例=L30（21.4 GLM5.3/Opus 备用）、L53（22.3 升一档）。
4. **纪元面=零级联**（11x 预放宽已容纳 103）；仅 SKILL.md L9/L210/L253 字面 `1-102→1-103`、`85→86 条`、纪律域枚举追加 103 + 各 selftest 注释史随动一行。
5. **selftest**=新写 selftest-dual-qc.sh + selftest-registry.tsv 补一行（惯例例=末行 selftest-anti-deferral.sh 行）；无总数钉值需改。
