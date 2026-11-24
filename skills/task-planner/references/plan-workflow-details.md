# 计划制作循环细节（惰性加载）

> 本文件由 `skills/task-planner/SKILL.md` 外移而来，内容与原文逐字一致。
> 按需 Read：`→ 详细步骤/表格/示例按需 Read references/plan-workflow-details.md §<锚名>`。
> 主入口见 `SKILL.md`；本文件不替代任何机器门断言锚，断言锚均常驻 `SKILL.md`。

## template-catalog

  - **模板检索与管理（`template-catalog.sh`，task-template-catalog-20261122）**：任务初期第一步调本脚本获取模板清单，让匹配流程化固定进 SOP；**脚本只提供稳定清单+排序，不替模型决策**（选型权威源仍是卫星 `plan-template-kit`）：
    - **列清单**：`bash scripts/template-catalog.sh list --json --scope all` —— JSON 每项含 `file/type/name/summary/scenarios/features/path/scope/default/valid`；`--scope` ∈ all/builtin/project/user/user-global/user-install（user=全局+安装位），`--include-installs` 含四个平台安装位模板；去重优先级 project > user-global > user-install > builtin。
    - **按任务匹配**：`bash scripts/template-catalog.sh list --query "视频 分镜 质检"`（关键词过滤）/ `bash scripts/template-catalog.sh list --recommend "修复生产环境数据库迁移 bug"`（按场景/功能命中数排序）。人不读散文试错，先看清单再定 `template_type` 传 init 第 2 参。
    - **模板克隆/派生（流程化沉淀）**：`bash scripts/template-catalog.sh clone --from video --to video-xxx [--scope project|user-global] [--dry-run] [--force]`（基于现有模板克隆，默认落项目级 `.zcode/plan-templates/`）；`bash scripts/template-catalog.sh derive --from video --to video-yyy --prune "成片质检,台账登记" [--dry-run]`（克隆并按 `## ` 段名裁剪派生）；`bash scripts/template-catalog.sh add <name> --from <type>`（克隆入口别名）。写操作默认同名拒锁（需 `--force` 才覆盖并自动备份 `.bak.<ts>`），`--dry-run` 预演零写入。
    - **元数据契约**：模板头 `<!-- template_meta: {"name":…,"summary":…,"scenarios":[…],"features":[…]} -->`；缺失时脚本回退注释散文启发式抽取（兼容存量与自定义模板）。`bash scripts/template-catalog.sh --help` 查全参数；exit 0=成功/1=业务失败/2=用法错误。
    - **脚本用法四件套（命令选择决策表 + 端到端可照抄示例 + 正反例 + 常见误用；2026-11-22 补示例减少反复试错）**：
      - **按场景选命令**（下表四列：场景 / 该用哪个子命令 / 关键 flag / 易错点；选型权威源仍是卫星 `plan-template-kit`，脚本只给清单与排序，不替模型决策）：

        | 场景 | 该用哪个子命令 | 关键 flag | 易错点 |
        |---|---|---|---|
        | 冷启动拿全量模板清单 | `list` | `--json --scope all` | 漏 `--json` 只能人读、模型难解析；忘 `--scope all` 只扫默认范围 |
        | 按关键词找/排序模板 | `list` | `--query`、`--recommend`、`--json` | `--query` 传整句任务描述易零命中，应给 2-3 个短词；整句改用 `--recommend` |
        | 含各平台安装位模板 | `list` | `--include-installs` | 与 `--scope user` 混用重复；`--scope all` 已含安装位 |
        | 基于现有模板起自己骨架 | `add` | `--from <type> --dry-run` | 漏 `--dry-run` 直接落盘；同名已存在需 `--force` 才覆盖 |
        | 原样复制模板再改名 | `clone` | `--from <type> --to <name>` | `--from`/`--to` 传反；忘 `--dry-run` 即写入 |
        | 复制并按 `## ` 段裁剪 | `derive` | `--from --to --prune "段名"` | `--prune` 段名须与模板 `## ` 标题逐字一致，否则不裁剪 |

      - **端到端可照抄示例**（init 前选模板 → 派生自己的模板 → 回读复核；写操作先 `--dry-run` 预览，去掉才真正写入）：

        ```bash
        # 1) 拿稳定 JSON 清单（模型可解析），据此定 template_type 传 init
        bash scripts/template-catalog.sh list --json --scope all
        # 2) 关键词过滤 + 推荐排序，缩小候选
        bash scripts/template-catalog.sh list --query "代码审查,重构" --recommend "带单测的重构计划" --json
        # 3) 派生自己的模板：先 dry-run 预览，零写入
        bash scripts/template-catalog.sh derive --from code-edit --to my-review --prune "发布,回滚" --dry-run
        # 4) 确认 stdout 为 DRY 无误后，去掉 --dry-run 才真正写入 project 范围（同名冲突再加 --force）
        bash scripts/template-catalog.sh derive --from code-edit --to my-review --prune "发布,回滚"
        # 5) 回读项目级清单，确认派生模板已就位并优先命中
        bash scripts/template-catalog.sh list --scope project --json
        ```

      - **正反例对照**（✅ 正确做法 / ❌ 错误示范）：

        - ✅ 正确：`bash scripts/template-catalog.sh list --json --scope all` 先用 JSON 清单锁定 `type`，再把该 `type` 传给 init。
        - ❌ 错误示范：不查清单、凭记忆把 `template_type` 写成 `video` —— 源模板改名/不存在时选错模板且无提示。
        - ✅ 正确：写操作先 `--dry-run`，如 `bash scripts/template-catalog.sh clone --from code-edit --to my-review --dry-run`，看到 `CATALOG … DRY` 再决定落盘。
        - ❌ 错误示范：直接跑不带 `--dry-run` 的 `clone` 覆盖同名模板 —— 轻则拒锁报错，重则误覆盖已有自定义模板。

      - **常见误用**（症状 → 规避法）：

        - ① 症状：`--query "帮我写一个带登录鉴权的重构计划"` 零命中 → 规避：`--query` 传 2-3 个短关键词（如 `"代码审查,重构"`），整句任务描述改用 `--recommend`。
        - ② 症状：`--prune "发布/回滚"` 派生后段仍在 → 规避：`--prune` 用逗号分隔且与模板 `## ` 段名逐字一致（如 `"发布,回滚"`），斜杠/空格不匹配。
        - ③ 症状：`list --scope user` 结果重复或漏项 → 规避：`user` = 全局+安装位；要含全部安装位应直接用 `--scope all --include-installs`，靠 project > user-global > user-install > builtin 去重。
        - ④ 症状：跑了 `--dry-run` 却以为模板已生效 → 规避：stdout `CATALOG <ACTION> DRY` 表示零写入，真正落盘是 `OK`；去掉 `--dry-run` 再跑一次。

## init-delegation

- [ ] [A] **初始化首动作委派（L1+）— 需求分析与计划文档创建子代理隔离**：
  - **两段式判定指针**：修复类请求先过「计划制作循环」开头的 **[P0] 两段式修复拆分判定**（含 L0/mini/trivial/L0-E 升档铁律）；本块仅管委派形态，不承载判定本体。
  - **触发**：L1+（standard/full，非 L0/mini/trivial/L0-E）任务 `init-session.sh` 完成 7 文件后的首个智能子动作（机械子动作/清哨兵按既有契约先行）
  - **动作**：派发计划子代理承接用户指令复述+需求分析+计划文档填写（`task_plan/findings/knowledge-brief/progress/verification`，以执行体产出契约为准）；**首选 Plan Writer**（`companion/agents/plan-writer.md`（仓库同级部署位同名 agent）），provider/档位失败按判例降级 `general-purpose` 并留痕
  - **计划期例外（22.4a/62.2）**：计划产出子代理=计划文档**计划期单写者**（隔离决策区块含 check-conflicts.sh 判读由其起草）；执行期子代理仍按 22.4a 只读；主进程对产物**盘上复核**（Rule 84.4）后展示/确认
  - **主代理职责收窄**：仅保留 skill 激活+init 机械子动作+派发+收据回收+user-session-log 逐字落盘（Rule 80.1）+计划展示+D1 确认+attest 锁定；需求分析与文档撰写细节不进主上下文
  - **收据契约**：派发与返回仍走 22.4a/b/c 派发全契约（22.4b 八字段返回，机械守卫不变）；主进程回收的最小收据=从八字段返回+盘上复核提炼 `{task_id, files_created[], open_questions[], 摘要}`（≤20 行）
  - **边界**：会话绑定脚本（`init-session.sh`/`attest-plan.sh`/`set-active-plan.sh`/`plan-created.cjs`/哨兵清理）禁由子代理执行（会话态竞争）；D1/attest/收据回收归主进程
  - **豁免**：L0/mini/trivial/L0-E 轻量档不适用本条款（Rule 38.6/38.7 比例原则不变）
  - **动机**：隔离更好、提高子代理激活率、降低主代理上下文占用；禁止误读为“所有场景一律加仪式”

## conflict-isolation-options

  **可选思路**：
  1. 思路 A：按 §十一 硬条款判定——命中保护区/基础设施/并行开发任一条 → 选 worktree 隔离（适用场景：实现类任务、改运行行为、用户并行开发时）
  2. 思路 B：命中 §11.5 例外（纯文档/纯调研/单文件 ≤3 行 trivial）→ 直接在主工作树进行（适用场景：不产生运行行为变更、无并行冲突风险时）
  - （独立检查项）Spec 模式触发判定（2026-11-15）：L1+ 且需求模糊/多方向/规格类 → 整理阶段路由专业执行体：`Skill("brainstorming")` 发散澄清 / `Skill("openspec-propose")` 规格化；技能或 CLI 未安装 → 按 `references/spec-mode.md` §2 安装引导直接安装（免用户门）；planner 只记录产物路径收据并调度，禁自拟规格（详见 `references/spec-mode.md`）；按复杂度在两族间择一路由见 `references/spec-mode.md` §1b（复杂度主轴+信号修正，2026-11-16 /goal 增补）；验证前置定位见 `references/spec-mode.md` §5（验证三载体映射：计划面 VC 契约/执行面 TDD+verification-before-completion/收口面 openspec-verify-change，2026-11-16 /goal 增补）

## audit-gate-details

  - **审计输入材料包**：task_plan.md + user-session-log.md 需求锚（逐字原文）+ knowledge-brief.md + 上轮问题清单（如有）
  - **审计维度**：①需求覆盖完整性（含 51.9 自缩水检查）②机制设计合理性 ③既有机制冲突面 ④比例原则与豁免面 ⑤可执行性（VC 命令判别性）⑥篡改面（逐字锚/加戏检查）——逐维结论+file:line 证据
  - **裁决映射（由审计体出具，主进程只登记不得自判达标）**：`0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED`（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）；达标=0C/0I 且连续一轮零新发现
  - **迭代闭环**：REJECTED→打回修正→再次审计，轮次不设上限；连续 ≥3 轮无实质进展→呈报用户裁决（防死循环）；每轮固定留痕 progress.md `[plan-audit-R<N>]` 段（轮次/审计体/结论/问题清单/修复对照）
    - [2026-11-24 task-perf-default-mini] 脚本刹车补充：累计 2 轮 REJECTED 且无 APPROVED → planctl 写入回显 [audit-cap] + PreToolUse 拦 Agent 派发（decision-arbiter 例外），登记 [audit-converge] 收口；「轮次不设上限」仅指有实质进展（issues 收敛）的迭代，无进展轮数由本刹车约束。
    - **无进展机器判定口径（2026-11-21 task-audit-rework-cap-20261121）**：取最近最多 3 个连续 REJECTED 轮，以显式 issue key 为信号——`issues[]` 中 `severity∈{C,I}` 且 `state∈{open,new}` 的 key 集跨轮完全相同（无清零、无新增）即判无进展；无 issues 字段的轮视为无信号跳过；末轮 APPROVED（清零收敛）一律不命中，防真实进展被误伤。命中后**禁止继续自动派发同类修复**，改走 decision-arbiter→AskUser 上报用户裁决（机器面 reason=`NO_PROGRESS_STREAK_3`，见下方机器门行）；goal 语境不 AskUser：独立仲裁一次后按 28.9②④ 登记待授权清单/判据上限，续推按 28.9⑤ 固定点应答。简版再审输入包收敛为「仅变更增量 + 上轮问题清单」：重派只带本轮 delta 与未闭环 key，禁整包重审放大重复发现。
  - **阻断语义**：未经审计 APPROVED（或豁免登记）禁展示给用户、禁进入 D1 yes/目标绑定确认/attest/清哨兵链路；本门**不适用 Rule 44.3 超时自动通过**（未达标禁自动放行）
  - **与既有机制边界**：计划面逃逸 Rule 103.3 由本门承载，执行期产物仍由 Rule 103 承载，二者不叠加；全流程原则与覆盖面映射全文=references/critical-rules.md Rule 109
  - **机器门（attest 锁定前自动，Rule 109.8）**：attest 内置 `check-plan-audit-gate.sh` 判定 `[plan-audit-RN]` 审计留痕（`[audit-gate]` 行）；`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce` 时未达标计划拒锁——**含审计证据缺失（progress.md 缺失/不可读，enforce 档不得借 IO 异常旁路；CR W-1）**（默认 warn 留痕不阻断——存量不重锁，首版起步）；`--skip-audit-check` 仅 L1+ 逃生（WARN+交付披露）；mini/L0/trivial 跳过、无声明 `SKIP legacy-no-decl`、`ENFORCE=off` 显式 SKIP；selftest=`scripts/selftest-plan-audit-gate.sh`
  - **无进展止损 reason（2026-11-21）**：`planctl check audit` / `check-plan-audit-gate.sh` 命中 3 轮连续 REJECTED 且开放 C/I key 集不变时 stdout 输出 `NO_PROGRESS_STREAK_3 ESCALATE_USER_DECISION_REQUIRED <details: 各轮 key 集合>`（rc 1，gate 行前缀 `[audit-gate] FAIL:`）；JSON 权威源由 `check audit` 判定，MD fallback 从问题清单行解析显式 `I-\d+`/`C-\d+`（剥「残留/已修」尾缀），解析不到任何 key 仅 `WARN NO_ISSUE_KEYS legacy` 不硬升级；`status.no_progress_streak` 供外部观测。末轮 APPROVED 无条件 PASS（收敛不误伤）。

## plan-confirm-alignment

  - **门控**：**goal/目标迭代（28.8）** 下 D1（计划批准）属可裁决点——**禁止**等待/询问用户 yes，按推荐项（已展示计划执行）静默自治批准并登记自动裁决记录五要素后直接执行后续链路（含 attest/清哨兵，受 Rule 109 审计门未达标禁自动放行约束；预算外硬门按 28.9② 登记待授权清单、不停表）。**非 goal**：等待用户显式 `"yes"`——无授权禁止执行；**D1 超时自动通过（Rule 44.3，2026-10-22 用户授权 P3）**：（注意：前置的计划独立审计门不适用本款——审计未达标禁自动放行，Rule 109）完成性指令/单步机械指令场景下按 44.1 默认 5 分钟超时自动通过（默认项=按已展示计划执行），自动通过须登记「自动裁决记录」五要素（超时值/推荐项/触发时间/裁决理由/被覆盖的未决选项）——D1 不再是「只能无限等 yes」的死等门；真分叉（D2/D5）与破坏性动作（D6 硬停点）仍必须等待用户答复，不适用本款。确认后 `bash scripts/attest-plan.sh` 锁定（内置 check-plan-dispatch.sh 校验派发型 Phase 的 S-unit 执行体列，缺失拒锁，`--skip-dispatch-check` 逃生）
  - **目标绑定确认（D1 升级，P0）**：D1 批准前，必须完成目标绑定——复述/落盘「本计划 Goal = <Goal 行原文>，服务用户指令 = <user-session-log.md 最近一条用户原话>」并形成确认锚；attest-plan.sh 锁定记录须含 Goal 原文 + 用户原话摘录 + 确认时间（落 .active_plan 绑定或 attest 记录）。**goal/目标迭代（28.8）**：按推荐项静默自治完成绑定与确认锚登记，**禁止**等待用户确认/回复；**非 goal**：须等用户确认（该等待同样适用 44.3 超时自动通过口径：超时按已展示计划执行并登记自动裁决记录）。**禁止**在确认锚（显式/自治登记）形成前清哨兵（plan-created.cjs）。Why: RCA 缺失环节 2——D1 显式 yes 是 LLM 行为门（SKILL.md:49-51），可被跳过或默认「用户已同意」；本条把 D1 从行为门升级为需落盘的确认锚，缺确认锚不认。
  - Spec 模式前置：命中 `references/spec-mode.md` §1 触发判定时，确认 spec 产物路径已登记（记录者收据）方可进入 yes/attest

## methodology-t1-t5

  **就地触发条件摘要**（全文→`references/methodology.md` §思维方法论 T1-T5）：
  - **T1 问题先行**：新任务 T0 规划时 / 任何方案提出前 / 任何修复动手前 → 三问自检（①问题是什么 ②解决到什么程度算好 ③不解决/解决错的代价）
  - **T2 解构四问**：计划创建（task_plan「核心问题定义」段）/ 复杂问题动手前 → 四问逐级作答（问题→本质[连问≥5 为什么]→解决方案[≥1 候选+取舍]→执行方案[S-unit 化+可验证]）
  - **T3 金字塔**：方案陈述 / 选项呈现 / 报告组织 → 结论先行 / 以上统下 / MECE / 逻辑递进
  - **T4 逐步推导**：T2②③作答 / FMEA 推演 / Rule 31.2 根因 / 复杂调试 → 推导链显式化落 findings，断点标「未验证」
  - **T5 消费点**：①规划先行的 T1 ②计划创建的 T2 ③方案候选的 T3 ④Phase 执行前的 Poka-Yoke ⑤失败纠偏的 T4

## shared-tracker-options

  **可选思路**：
  1. 思路 A：从 scope_files 反查共享资源——多 Phase 触碰同一文件/目录/资源 → 判命中（适用场景：改动集中在少数文件、资源易枚举时）
  2. 思路 B：从任务类型判定——同类任务重复 ≥3 次（批量站点/批量文档等）→ 判命中（适用场景：批量同类操作、资源分散难枚举时）

## execution-agent-quickref

     搜索定位→Explore｜网络调研→Web Search Agent/general-researcher｜官方文档→Doc Search Agent｜
     大文件/日志→log-distiller｜检查验证审查→Verifier/Code Reviewer/critic｜批量既定步骤→executor｜
     媒体批量质检循环→image/video-generation-executor｜长耗时管道→code-runner 或后台执行｜
     批量簿记→plan-bookkeeper｜单文件小改→Code Assistant｜中等编码→general-coder｜
     独立创作→general-writer｜分析归因→general-analyst｜偏移检查→drift-checker｜方案终裁→decision-arbiter
     （全文与触发判据见 `../task-dispatch/references/critical-rules-dispatch.md` Rule 104；主进程保留=编排/路由/派发/回收/决策/三文件回填/白名单①-⑥）

## change-type-compliance-gate

     - **判据**：先问是补充还是替代——补充是常态，替代是例外，删除是特许；未做三判即写入 = P0 违规
     - **通用修改合规门（Rule 74.7，P0）**：执行期任一对已确立规范/阈值/区间的改动（含产物内口径就地放宽），落地前必须先补 `task_plan.md`「📋 变更标注表」合规四元组（变更对象+当前值原文→拟变更值+依据+影响评估+处置），无用户逐字授权+证据的放宽禁落地；若命中 `🔒 规范基线` 同步走 51.15 STOP→授权→Decisions→更新→重 attest。禁「先改后补」；详见 task-discipline/references/critical-rules-discipline.md Rule 74.7

## agent-failure-ledger-details

     - **为何会话级而非 memory**：失败只记客观事实（时间/类型/原因），**不写"该 agent 有缺陷"的判断**——agent 修好后 ledger 随任务结束即弃，不会像 memory 那样陈旧误报（用户 2026-11-23 裁决）。
     - **失败当下不注入、不阻断**：零机器门、零 hook、fail-open；失败当下照常按既有降级链处理（重试/换档/爬升），本条只负责留痕，不改变派发行为。
     - **交付时消费**：终验交付总结（Rule 48）前执行 `bash <skill>/scripts/agent-failure-ledger.sh count <plan-dir> <sid>`；非 0 则在 delivery-summary「风险点」段增一节「本次 Agent 执行异常」列出 N 次失败与台账绝对路径，提示用户审查修正（模板见 `templates/delivery-summary.md`）；为 0 则写"无"。归档时 `clear` 清本会话台账。
     - **子代理亦须遵守**：派发 prompt 的八字段契约追加一条——返回若为失败态，子代理自身亦以 `append` 留痕（其 sid=自身会话 id），确保嵌套派发失败也被记录。

## phase-context-recall

     - **3f' 周期性会话记忆回顾（Rule 93/80.8⑤，用户"定时回顾会话知识"诉求）**：每完成 3 个 Todo/S-unit（config `periodic_review_interval_calls`，默认 8 次工具调用互补），主进程重读会话记忆四载体——`findings.md`（结论/证据）+ `knowledge-brief.md` §2-§4（知识锚/易错点）+ `user-session-log.md` 尾部 ≤30 行（用户原话锚）+ `progress.md` 本 Phase 尾部→①梳理（当前执行与记忆是否一致）②纠偏（偏移标 `[corrected]`）③反思（遗漏/未利用知识回填 findings/kb）④留痕 progress `[memory-review]` 行。承载模板 `templates/task_plan.md` / `templates/progress.md` 同名条目；与 3f/3g 同拍执行；mini/L0 档豁免
     - **3g 规范召回（Rule 93）**：每完成 3 个 S-unit 或 Phase 翻转 complete（先到者），主进程亲自 Read `../task-discipline/references/execution-recall-card.md` 并 progress 留 `[recall]` 行（可与 3f/3f' 同拍执行）；compaction 恢复/会话恢复/[assess]≥PRESSURE 后第一动作先读召回卡（93.3）；mini/L0 档豁免

## drift-check-options

  **可选思路**：
  1. 思路 A：按 Executor 字段机械派发——Phase 有 Executor 字段即派子代理，主进程只回填三文件+验收 Read（适用场景：派发型 Phase、S-unit 边界清晰时）
  2. 思路 B：主进程直做——命中直做白名单（trivial/单文件小改）或 Executor=主进程时自执行（适用场景：改动小、派发开销大于收益时）


## final-verification-mechanical

  - **git 提交核验+编号账本**：scope 文件无未提交变更（或已按 Rule 27 逐 Phase 提交）；新增编号 `bash scripts/rule-reserve.sh land <NN> <task-id>`
  - subagent 返回 "done" → **必须 Read 实际产出文件**，禁止信任自报
  - **退出前**：`bash scripts/check-complete.sh`——exit 0 正常结束；exit 1→STOP 报告未完成任务

## final-verification-options

  **可选思路**：
  1. 思路 A：严格按门脚本 exit code 判定——全门 exit 0 → COMPLETE，任一门非 0 → 回炉修复（适用场景：门覆盖充分、产出可机器校验时）
  2. 思路 B：门通过后加人工复核——对关键 Evidence 抽样复现，发现门未覆盖的缺陷即降级 outcome（适用场景：交付面广、门可能漏检内容型缺陷时）

## output-mapping-table

| 产出类型 | 写入 findings.md 段落 | 写入时机 |
|---------|---------------------|---------|
| 调研结论/搜索结果摘要 | `## Research Findings` | 子代理返回后**紧邻** |
| 根因分析/排查结论 | `## Issues Encountered`（Issue+Resolution） | 根因定位后 |
| 技术选型/方案决策 | `## Technical Decisions`（+task_plan Decisions Made 双写） | 决策时 |
| URL/文件路径/API 引用 | `## Resources` | 发现时 |
| 截图/网页等多模态信息 | `## Visual/Browser Findings`（转文字） | **立即**（多模态不持久） |
| 用户需求拆解 | `## Requirements` | Phase 1 期间 |

## read-write-matrix

### 📖 Read vs Write 决策矩阵（Rule 20.5 — 省 token）

> 权威源=`references/critical-rules.md` Rule 20.5。场景速查：刚写完的文件→**不要再 Read**（内容还在上下文）（20.5 豁免写入确认型重读；跨字段一致性复检不豁免，见 Rule 106.1）；看过的图/PDF/网页/搜索返回→立即写 findings；开新 Phase→读 plan+findings；出错→读相关文件；中断/压缩恢复→读全部三文件（Rule 19.3）＋执行规范召回卡（Rule 93.3）。


## compliance-table-a

| G1 | 用户任务已复述目标无歧义；task_plan.md 存在且含 Phase+VC 表；计划已展示并获用户显式授权；计划独立审计门已 APPROVED 或豁免登记（Rule 109，D1 前置） | ☐ |
| G1b | 计划 Goal 的站点/域名词/目标实体与 user-session-log.md 最近用户原话有交集（目标绑定）；新建计划已过目标切换三判（E 类）；入站指令已过 8.1.2 预检（明显错位/疑似误发=已询问澄清） | ☐ |
| G2 | 本 Phase R 锚定复诵已写；动作相关性三问已过（v168 两锚点） | ☐ |
| G3 | Phase 委派检查点已过：Executor 字段在位非主进程已派发；白名单直做已登记例外理由 | ☐ |

## inbound-instruction-screen

**入站指令字面/语义筛查（L0-T 文本锚，2026-11-24）**：每条入站用户指令（重点：语音转写）在 80.1 逐字落盘之后、8.1.2/D-A-B-C-E 判定与 28.2.2 复述之前执行，记作 ①a。
- **三类识别**：① 同音/近音字、专有名词与项目术语被同音替换、错别字、断句/标点缺失；② 语义合理性（动作-对象搭配、任务类型与三源[项目定位锚/活跃计划 Goal/user-session-log 最近原话]是否自洽）；③ 意图保持校验。**不得改变用户真实意图**。
- **处置分级**：明显错字且唯一合理修正→自主修正后继续，不问用户；≥2 个合理修正且影响目标/范围/交付→才列 2-4 选项、首选标 `(Recommended)` 请用户确认；goal/silent/44.3 下歧义不阻塞，按推荐项静默自决并登记假设。
- **逐字对照登记**：修正须在 user-session-log.md **追加** `#N 入站校正` 条目（引用原条目号，列"原话字面→修正字面→依据"，原话零改写，守 80.2），progress.md 追加 `[inbound-scan]` 行 + Decisions Made 一行；复用既有三载体，零新文件。
- **禁令**：禁以修正后文字冒充用户原话（80.4）；禁回改历史条目（80.2）；禁因本检查新增无价值询问（28.2.2）；**禁跳过分析直接执行**。与 8.1.2 分工：本条管字面/语义合理性，8.1.2 管项目定位错位，独立留痕（[inbound-scan] vs [align-scan]）。

## intent-switch-templates

**意图切换执行清单（D 类定案后按序执行）**：① 旧计划挂起登记（其 progress.md 追加 [intent-switch] 行+在途单元断点检查点）+释放旧计划会话占用（删除其 `.session-owner`——挂起=会话不再认领；回切时 userpromptsubmit hook 自动重建）+回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 planctl 变更+render 后重跑 attest-plan.sh，防 PLAN TAMPERED 误报→ ② 新计划 init（plans/{new-task-id}/ 全流程，指针自动切换）→ ③ 显性通告（会话面输出下方模板，用户可见）→ ④ 切换登记（新计划 progress.md [intent-switch] 行 + Decisions Made 一行）。
**显性通告模板**：【计划切换通告】旧计划 <old-task-id> 已挂起（断点=其 progress.md [intent-switch] 行）→ 新计划 <new-task-id> 已激活（指针已切换）→ 触发原话=user-session-log #N → 后续在新计划推进，旧计划可用 plan-resume 恢复。
**切换登记最小字段**：[intent-switch] 旧=<id> 新=<id> 触发=原话#N 判定=D/E 确认=yes|44.3自动 时间=<ISO8601>（复用既有载体，不新建文件）；回切分支追加 回切状态=<yes已回切|no|保持挂起>。
**回切通告模板（B 收口时触发）**：【计划回切通告】B 已收口（<new-task-id>，outcome=<COMPLETE/PARTIAL>）→ 检测到挂起链 A（<old-task-id>，挂起于 user-session-log #N）→ 是否切回继续执行 A？yes=路由 plan-resume 定向恢复；no=保持挂起并登记 回切状态。

## complaint-protocol-a

> **元根因守护（Rule 38.7 比例原则的行为面）**：用户投诉「慢」时，不仅修补当前症状，还检查既有通道边界（L0/mini/trivial）是否覆盖该场景，未覆盖则扩展边界而非叠加新门控。

- **投诉响应协议**：每次用户投诉「慢 / 好几个小时解决一个最简单的问题」时——① 复述用户原话 → ② 检查既有通道（L0 微变更 / mini 轻量档 / trivial 代码修复档）是否覆盖该场景 → ③ 未覆盖则扩展既有通道边界（如 Change #1 的 trivial 代码修复第四条件），而非叠加新的门控/仪式。

## complaint-protocol-b

- **L0 通道定期边界审查触发**：每 10 个任务或每月，检查「最常见的简单场景」是否被既有通道排除（如代码文件改动被 lane-detect.sh:86 禁滥用条款排除 → 已补 trivial 第四条件）。审查留痕于 findings.md。
- **L0-E 纯执行档（2026-10-22 用户授权 task-videop1-protectfix-001 新增；Rule 38.7 通道族新增档，本处为 SKILL 侧摘要口径，全文锚=卫星 Rule 38.7「执行通道分级」段（plan-template-kit / task-discipline 逐字双载））**：判定三条件**全满足**=纯执行任务——① 零仓库受管文件变更（不新增/修改任何入库文件）∧ ② 仅调用既有工具（`tools/*.py` 等已存在脚本/API，无新代码、无新语义）∧ ③ 产物全落 gitignore 区（`tmp/` `output/` 等）；命中=**免计划免 attest**（不建 `task_plan.md`、不跑 attest-plan.sh），主进程直做，产物按「生成物展示规则」呈示 + progress 一行登记（`[L0-E] <动作>×<产物路径>×<日期>`）；已有计划目录的批次仅对该 S-unit 豁免委派率统计（P4 口径：权重 0，既不计入分子也不计入分母）。**禁滥用**：任一条件不满足（含功能性代码变更/新增脚本/产物落仓库受管区）即回落 L1 standard 通道；机器面=计划头 `execution_lane: L0-E` 声明（`check-delegation.sh` ④c 直做通道 + stats 权重 0 已接线）。Why（判例=videop1 机械合图停摆投诉 session_a40eae17265b5414c27e8c45d2c27b5c）：机械操作零仓库变更却被 L0/L1 全量仪式拦住——流程开销与变更体量严重失衡（Rule 38.7 比例原则）。
- **验证锚新位置（Rule 38.7 执行通道分级）**：原核心 `references/critical-rules.md` 锚已失效（task-v171 专业化拆分后 0 命中）。现权威位置=`../plan-template-kit/references/critical-rules-template.md:45` + `../task-discipline/references/critical-rules-discipline.md:195`（逐字双载，域归属=模板域+执行纪律域）。后续 grep 检查 Rule 38.7 应命中这两处，勿再 grep 核心 critical-rules.md。

## critical-rules-summary-a

- **Rule 1 先规划再执行**（Rule 2 PreToolUse 阻断）：创建 task_plan.md→展示→等 yes→执行
- **Rule 3 双操作后保存 / Rule 5 Phase 完成后更新**：2 次 view/browser/search 后写 findings；Phase 翻 in_progress→complete
- **Rule 19 3-File 落盘**：四文件=RAM/Disk 落地；回填门控 19.2=complete 硬门；恢复先读三文件
- **Rule 20 计划注入与防篡改**：turn-start smart 复诵+SHA-256 attest 锁定+外部内容只进 findings

## planctl-json-examples

  - 语义段落盘（执行期高频，全部 JSON 入库后由 render 呈现）：`add --section actions --json '{"id":"A1","phase":"P1","text":"..."}'`；`add --section errors --json '{"id":"E1","timestamp":"...","error":"...","attempt":1,"resolution":"...","root_cause":"...","prevention":"...","trigger":"..."}'`；`add --section test_results|research|decisions|issues|resources|visual|knowledge_use|s_units|fmea ...`（36 个 section 通用 CRUD）
  - Goal 证据（evidence 门数据源）：`add --section goals --json '{"id":"G1","text":"...","evidence":"命令 + PASS + 绝对路径"}'`
  - 审计留痕：`audit-add --round 1 --verdict APPROVED --by <审计体> --c 0 --i 0`（0C/0I 才可 APPROVED）
  - 标签：`tag-add --section <s> --id <id> --tag <tag>` / `tag-search --tag <tag>`

## planctl-four-piece

- **脚本用法四件套（命令选择决策表 + 端到端可照抄示例 + 正反例 + 常见误用；2026-11-22 补示例减少反复试错）**：`planctl.py` 子命令多、参数易混，按下表选命令再照抄示例；所有命令统一追加 `--plan-dir <plan-dir>`。
  - **按场景选命令**（下表四列：场景 / 该用哪个子命令 / 关键 flag / 易错点）：

    | 场景 | 该用哪个子命令 | 关键 flag | 易错点 |
    |---|---|---|---|
    | 新建计划权威源 | `init` | `--task-id --tier --lane` | state 已存在需 `--force`；init 只建 JSON、不 render |
    | 读回状态 / 做校验 | `get` / `status` / `validate` | `--section`、`--id` | `get --section` 传错段名返回空；`validate` 只读不改 |
    | 改单字段 / 加条目 | `set` / `add` | `set: --section --id --field --value`；`add: --section --json` | 写顶层字段时 `set` 不得带 `--section`/`--id`；`add` 必须带 `--json` |
    | 推进 Phase / 判 VC | `phase-start` / `phase-done` / `vc-pass` / `vc-fail` | `--id` | 漏 `--id` 直接用法错误；先 start 再 done |
    | 机器门判定 | `check` | 位置参数 `vc-nonvacuous`/`rvc`/`audit`/`evidence` | 检查项是位置参数、不是 flag；rc 0=PASS |
    | 生成 MD 派生视图 | `render` | 仅 `--plan-dir` | 每次写后必须 render，否则手工编辑残留不被覆盖 |
    | 追加审计轮次 | `audit-add` | `--round --verdict --by --c --i --w [--issues-json]` | APPROVED 须 0C/0I；无进展信号源走 `--issues-json` |

  - **端到端可照抄示例**（init → 加入需求/VC → 推进 → 审计 → 门检 → render；写操作直接落 JSON，改坏用 `.history` 回退）：

    ```bash
    PD=plans/task-001   # 换成真实含 plan-state.json 的目录
    # 1) 初始化权威源（state 已存在才加 --force）
    python3 skills/task-planner/scripts/planctl.py init --plan-dir "$PD" --task-id TASK-001 --tier standard --lane L1
    # 2) 加入需求与 VC（写操作，直接入 JSON）
    python3 skills/task-planner/scripts/planctl.py add --plan-dir "$PD" --section requirements --json '{"id":"R1","text":"需求原文","type":"手段"}'
    python3 skills/task-planner/scripts/planctl.py add --plan-dir "$PD" --section vcs --json '{"id":"VC1","criterion":"判据","command":"验证命令"}'
    # 3) 写顶层字段、建 Phase（init 不预置 phases，须先 add 再 phase-start）、推进、判 VC
    python3 skills/task-planner/scripts/planctl.py set --plan-dir "$PD" --field next_step --value '下一步动作'
    python3 skills/task-planner/scripts/planctl.py add --plan-dir "$PD" --section phases --json '{"id":"P1","status":"pending","s_units":[],"v_checks":[]}'
    python3 skills/task-planner/scripts/planctl.py phase-start --plan-dir "$PD" --id P1
    python3 skills/task-planner/scripts/planctl.py vc-pass --plan-dir "$PD" --id VC1
    # 4) 审计留痕（0C/0I 才可 APPROVED）
    python3 skills/task-planner/scripts/planctl.py audit-add --plan-dir "$PD" --round 1 --verdict APPROVED --by reviewer --c 0 --i 0 --w 0
    # 5) 机器门 + 生成 4 个 MD 派生视图（写完必 render）
    python3 skills/task-planner/scripts/planctl.py check --plan-dir "$PD" vc-nonvacuous
    python3 skills/task-planner/scripts/planctl.py render --plan-dir "$PD"
    ```

  - **正反例对照**（✅ 正确做法 / ❌ 错误示范）：

    - ✅ 正确：每次写（add/set/phase-*/audit-add）之后跑 `render`，MD 视图与 JSON 权威源保持一致。
    - ❌ 错误示范：写完直接手工改 `progress.md` —— 下次 `render` 全量覆盖，改动丢失且流程无效。
    - ✅ 正确：`check` 用位置参数传检查项（如 `vc-nonvacuous`），读 rc 与单行 `PLANCTL CHECK` 判 PASS/FAIL。
    - ❌ 错误示范：给 `check` 传一个不存在的选项名而不是位置参数 → 报 unrecognized arguments、rc 2。

  - **常见误用**（症状 → 规避法）：

    - ① 症状：写顶层字段却带 `--section requirements`，报 id 缺失 → 规避：写顶层字段时 `set` 省略 `--section` 与 `--id`；只有改条目时才带。
    - ② 症状：`render` 后手改 MD 又丢失 → 规避：MD 是派生只读视图，语义一律 `add`/`set` 入 JSON 再 `render`，禁直接 Edit/Write。
    - ③ 症状：`check` 传不存在的选项名报 unrecognized arguments → 规避：检查项 `vc-nonvacuous`/`rvc`/`audit`/`evidence` 是位置参数，直接跟在 `--plan-dir` 之后。
    - ④ 症状：`init` 遇到已存在 state 报拒绝覆盖 → 规避：确认要重建才加 `--force`（会覆盖旧权威源），否则改用 `set`/`add` 做增量更新。
    - ⑤ 症状：`phase-start --id P1` 报 `phases 中未找到 id='P1'`（实测 init 不预置 phases）→ 规避：先 `add --section phases --json '{"id":"P1","status":"pending","s_units":[],"v_checks":[]}'` 建条目，再推进 Phase。

## script-index

## 脚本索引（发现性入口）

<!-- [2026-11-23 task-fix-all-20261123] 补充脚本发现性索引：163 个脚本文件按类别索引，避免仅靠正文零散提及导致发现性差；不穷举全部 selftest，给分类+权威发现命令。 -->

`scripts/` 共 **163** 个文件（含 `lib/`、`schemas/`）。权威清单以文件系统为准：`ls skills/task-planner/scripts`（或 `find skills/task-planner/scripts -type f | sort`）。

| 类别 | 数量(约) | 代表脚本/入口 | 用途 |
|------|---------:|---------------|------|
| 生命周期/init | 11 | `init-session.sh`, `attest-plan.sh`, `archive-plan.sh`, `set-active-plan.sh`, `resolve-plan-dir.sh`, `resolve-interaction-mode.sh`, `auto-finalize.sh`, `plan-created.cjs`, `session-catchup.ts`, `task-plan-init.cjs` | 计划创建/锁定/归档/指针/恢复 |
| 状态与计划操作 | 5 | `planctl.py`, `plan-doctor.sh`, `sync-todos.sh`, `ledger-append.sh`, `template-catalog.sh` | JSON 权威源 CRUD/render、诊断、Todo/账本/模板 |
| 机械门/检查 | 25 | `check-complete.sh`, `check-3file-gate.sh`, `check-plan-audit-gate.sh`, `check-plan-dispatch.sh`, `check-dispatch.sh`, `check-delegation.sh`, `check-drift.sh`, `check-scope.sh`, `check-rvc-coverage.sh`, `check-vc-nonvacuous.sh` | attest/完成/派发/漂移/范围/VC 等门禁（`check-*.sh`） |
| 合并/隔离/辅助 | 6 | `smart-merge-back.sh`, `check-conflicts.sh`, `allow-direct.sh`, `lane-detect.sh`, `periodic-review.sh`, `rule-reserve.sh` | worktree 合并回、冲突、直改豁免、车道/周期/编号 |
| hook/平台接线 | 4 | `zcode-sessionstart.sh`, `zcode-userpromptsubmit.sh`, `zcode-pretooluse.sh`, `zcode-posttooluse.sh` | ZCode hook 入口 |
| 同步/校验/注册 | 7 | `sync-companion.sh`, `sync-ide-folders.ts`, `register-hooks-cj.ts`, `verify_io.sh`, `run-selftests.sh`, `selftest-registry.tsv`, `selftest-registry.sh` | 部署同步、I/O 校验、自测注册表/运行器 |
| selftest | 106 | `selftest-*.sh` / `selftest-planctl.py` | 规则/脚本回归守护；全量入口 `bash scripts/run-selftests.sh`，登记见 `selftest-registry.tsv` |
| lib/schemas | 2 | `lib/plan-parse.sh`, `schemas/check-delegation-stats.schema.json` | 共享解析与 JSON schema |

> 发现脚本时优先：① 本节类别 → ② `grep -rn "<关键词>" skills/task-planner/scripts` → ③ 直接读脚本头部注释/`--help`。新增脚本应归入对应类别并保持命名可检索（`check-*`/`selftest-*`/`sync-*`/`zcode-*`）。


## references-table

| `reference.md` | Manus 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 |
| `references/methodology.md` | 思维方法论 T1-T5 + 内容质量 Q3/Q4 + FMEA/Poka-Yoke |
| `references/completion-gate.md` | 子代理验证 + 串行同步 |
| `references/goal-gate.md` | Goal Gate + VC 规则 + 退出标准 |
| `references/todo-sync.md` | 原生 Todo 同步契约（S1-S5/映射/hook 响应） |
| `references/worktree-isolation.md` | 工作树隔离契约（实现类默认首选+合并回合约） |
| `templates/knowledge-brief.md` | 知识底座模板（init 第 6 文件；五段） |
| `templates/user-session-log.md` | 用户会话逐字记录专档模板（第 7 文件；append-only，Rule 80） |
| `templates/shared-tracker.md` | 共享内容认领追踪区块模板（Rule 30） |
| `templates/deprecated.md` | 废弃内容隔离区（Rule 73.5 只入不出；非白名单，不计入 grep 锚计数） |
| `templates/session-handoff.md` | 会话交接文档（Rule 67.4 CONFUSED 触发；写回 Decisions Made + progress [handoff]） |
| `examples.md` | 实际示例 |
| `../task-dispatch/references/agent-coverage.md` | 执行体覆盖矩阵（Rule 52.1） |
| `../task-discipline/references/batch-quality-gate.md` | 批量处理质量门控详解（Rule 18） |
