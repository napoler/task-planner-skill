# task-planner 技能结构测绘（task-v095-skill-split / 01-explore）

- 生成时间: 2026-09-29 · 只读侦察 · canonical: /mnt/data/dev/task-planner-skill/skills/task-planner
- 总盘: 全仓 151 文件 / 23945 行（SKILL.md 556 / reference.md 285 / references/ 14 文件 2432 / scripts/ 68 文件 14388 / templates/ 10 顶层+16 variant / companion/ 3 agent / lib/ 6 脚本 / docs/ / config.json 440）

## 0. 部署位与 hook 接线（前置事实）
- 三个部署位全部存在且与 canonical 逐字节一致（diff -rq 无差异）:
  - /home/terry/.zcode/skills/task-planner/ （hook 实际指向此位）
  - /home/terry/.claude/skills/task-planner/
  - /home/terry/.config/opencode/skills/task-planner/
  ⇒ 任何内容移动必须三部署位同步（install.sh 全量 rsync，见 §C6）。
- ZCode hook 接线（/home/terry/.zcode/cli/config.json → hooks.events）:
  - SessionStart → bash /home/terry/.zcode/skills/task-planner/scripts/zcode-sessionstart.sh
  - PreToolUse (matcher: Write|Edit|Agent|CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet) → zcode-pretooluse.sh
  - PostToolUse → zcode-posttooluse.sh
  - UserPromptSubmit → zcode-userpromptsubmit.sh
  全部指向 ~/.zcode/skills/task-planner/scripts/（注意 PreToolUse matcher 已含 workflow 系工具 = Rule 39 接线点）。
- Claude 侧 ~/.claude/settings.local.json 用 ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner} 宏（register-hooks-cj.ts 生成），Stop → check-complete.ps1/check-complete.sh。
- zcode-posttooluse.sh:108 硬编码 `SKILL_ROOT="${OPENCODE_SKILL_ROOT:-$HOME/.zcode/skills/task-planner}"`（opencode 位经此变量可覆盖，唯一定点）；其余脚本 SKILL_ROOT = BASH_SOURCE 相对解析（随部署位走，无硬编码）。

## A. SKILL.md 段落地图（556 行）

| 行号 | 段落 | 定性 | 归属 |
|---|---|---|---|
| 1-23 | frontmatter | references 清单 + 平台 hook 注释 | 核心（元数据，拆件后需同步改） |
| 25-28 | P0 铁律 + Goal | 技能定位一句话 | 核心 |
| 29-45 | ## 主进程=调度管理器（三铁律/六白名单） | 委派机制总纲 | 核心规划流程（Rule 25/22 骨架） |
| 46-56 | ### 专业技能协同路由（L46） | comet/OpenSpec/superpowers/dynamic-workflows 触发矩阵，权威源 skill-collaboration.md | 非核心候选⑤⑥ |
| 58-170 | ## 执行流程图（L58） | 哨兵/init-session/计划确认/attest/Phase 循环 6 步/Code Review Gate/终验交付 | 核心规划流程（计划创建 L58-86、Phase 循环 L88-107、终验 L157-170） |
| 82-86 | 方法论检查点（Poka-Yoke L82 / 思维解构 L84 / 共享追踪 L86） | 设计期指针行 | 非核心候选⑦（82/84）；④共享追踪（86） |
| 109-121 | ### 产出落盘映射（3-File） | findings.md 分流表 | 核心规划流程 |
| 122-130 | ### Read vs Write 矩阵（Rule 20.5） | token 判定 | 非核心候选⑧（可并入 critical-rules） |
| 130-142 | Chain 区块交接 | linked/fan-out handoff | 核心（与 Rule 21 绑定） |
| 144-155 | Code Review Gate | 终验前置 | 核心规划流程（终验） |
| 157-170 | 终验交付 | VC 复验/check-complete | 核心规划流程（终验） |
| 172-202 | ### 合规检查清单 C1-C27（L172-202） | 每 Phase 确认表 | 核心（但 C22/C25/C26/C27 是模板/画像/tier/workflow 行 = 非核心锚） |
| 204-206 | 原生 Todo 同步 | 指针行 | 核心 |
| 208-230 | 用户新指令处理（A/B/C/D） | 影响判定表 + Rule 31/32/33/34/36/8.1 特判指针（L222-227） | 核心（表）+ 非核心候选⑦⑧指针 |
| 232-241 | 冲突分析与 worktree 隔离 | 隔离默认策略 | 核心 |
| 243-284 | ## Chain 模式详解（L243-284） | linked/fan-out/执行规则 | 非核心候选⑧（chain 模式，仅多 block 任务用） |
| 286-317 | ## Critical Rules（L286-317） | Rule 1-39 摘要表 | 混合：1-12/19-20/21-25/27 = 核心；17/18/30-33/34/37/38/39 = 非核心候选②③④⑤⑦⑧ |
| 319-326 | Completion Gate / Scope+Goal Gate | 指针行 | 核心 |
| 328-334 | I/O 契约 + Chain Handoff Contract | 指针行 | 核心（332 指针） |
| 336-353 | ## References（L336-353） | 文档索引表 | 核心（拆件后必改） |
| 357-410 | ## 子代理路由与模型分级（L357-410） | 路由表（Rule 21）+ 模型档位 + 反模式 | 派发机制（Rule 21/22 路由表） |
| 414-449 | ## 超时与失败兜底（L414-449） | 五档兜底/Handoff 登记/subagent-fallback（L446） | 派发机制（Rule 22 落地） |
| 448-449 | 环境级中断自愈 | hook 自愈条款 | 核心（机制面，非可拆） |
| 451-464 | 代码编辑强制隔离 | 路由表指针 + 验证流程 | 派发机制 |
| 466-506 | ## 调研类操作（L466-506） | WebSearch+github 双路/引用格式 | 非核心候选②调研路由 |
| 509-538 | ## 高频漂移纠正（L509-538） | task-drift-guard 密度 | 非核心候选⑧（Rule 15，可移 references） |
| 542-556 | ## 任务模板库（L542-556） | 模板强制约束 + knowledge-brief + plan-writer 契约 | 非核心候选①模板体系 |

## B. 文件消费关系表（行数 + 被引用方）

### references/（14 文件）
| 文件 | 行数 | 主要引用方 |
|---|---|---|
| critical-rules.md | 368 | SKILL.md L9/341/全文 30+ 指针、21 个 selftest、lib/install-stub.sh、docs/ARCHITECTURE、README、7 个 references 互引、templates/cost_log、variant/rule-enhancement → 全仓最热文件，不可拆 |
| methodology.md | 236 | SKILL.md L82/84/305、selftest-methodology（cp 进 fixture 目录断言 §思维方法论/14 条/9 条）、plan-writer.md、templates/writing-type、task_plan.md |
| template-mapping.md | 230 | SKILL.md L19/293/341/365、selftest-template-lifecycle（TL-16/17/18 断言 Rule 34 提示+§九矩阵）、selftest-mechanism-profile（Rule 37 权威源 §九）、critical-rules、variant/rule-enhancement |
| template-guide.md | 276 | SKILL.md L18/556、selftest-template-lifecycle（L82 TL-17 断言含 rule-enhancement 且「13 个」锚）、selftest-mechanism-profile（TGUIDE L31）、knowledge-brief.md |
| batch-quality-gate.md | 168 | SKILL.md L16/295、selftest-batch-pilot、selftest-conclusion-discipline、plan-writer.md L83、templates/batch_report、task_plan.md |
| cost-control.md | 171 | SKILL.md L15/294/345、billing.md、batch-quality-gate.md、critical-rules.md、templates/cost_log |
| skill-collaboration.md | 113 | SKILL.md L46/348、selftest-skill-collab（T1b 断言 ≤300 行）、selftest-shared-tracker、selftest-fallback、subagent-fallback.sh L288 hint 文本 |
| todo-sync.md | 70 | SKILL.md L42/206、sync-todos.sh、selftest-task-boundary、install-stub、critical-rules |
| worktree-isolation.md | 92 | SKILL.md L14/241、check-conflicts.sh L14 注释、install-stub、critical-rules |
| completion-gate.md | 33 | SKILL.md L11/342、README、docs、template-guide |
| goal-gate.md | 17 | SKILL.md L12/326、selftest-vc-gate、check-complete.sh |
| dispatch-examples.md | 41 | selftest-dispatch DX-01..05b（L292-303 断言 critical-rules 22.4b ↔ 本文件绑定）、subagent_dispatch.md、critical-rules |
| billing.md | 61 | SKILL.md L17/344、cost-control、templates/cost_log、README |
（合计 2432 行，实际 grep 核对 14 文件）

### templates/（26 文件 ≈ 3370 行）
- task_plan.md 420：消费方最多（check-scope/check-template-type/check-plan-dispatch/check-3file-gate/check-drift/sync-*/selftest ×8/reference.md/zcode-posttooluse）——核心，不可拆
- verification.md 127：check-complete L630（V-N 模板行数比对）、zcode-pre/posttooluse、selftest-vc-gate —— 核心
- subagent_dispatch.md 60：check-dispatch L222、selftest-conclusion-discipline（CD-21/22）、selftest-knowledge-brief、selftest-fine-grain-steps、plan-writer —— 派发机制
- knowledge-brief.md 52：init-session 第 6 文件、check-scope/check-3file-gate 白名单、selftest-knowledge-brief（10 断言） —— 模板候选但消费面广
- progress.md 63 / findings.md 43：check-3file-gate/stub 检测（check-complete L99-100）、sync-ide-folders.ts L44 三元组 —— 核心 3-File
- notepad-learnings.md 36：selftest-error-loop/veto/conclusion-discipline 断言内文 —— 核心
- batch_report.md 65：check-complete L338、plan-writer L84 —— 候选③④附属
- cost_log.md 72：无脚本消费（纯指针） —— 候选③附属
- shared-tracker.md 24：selftest-shared-tracker L57、SKILL.md L351 —— 候选④附属
- variant/ 16 文件（bugfix 149/code-edit 139/deployment 150/diagnostic 85/migration 149/mini-lite 44/performance-tuning 150/publish 111/refactor 144/research 85/rule-enhancement 146/test-writing 146/video-fix 133/video 84/writing 78，合计 1934 行）：check-template-type 白名单动态派生源 + init-session 复制源 + selftest-plan-tier（mini-lite 特殊：L46/82/34 断言 ≤80 行、frontmatter plan_tier: mini、「固定 1」锚）

### scripts/（68 文件 14388 行）核心面摘要
- hook 入口 4（zcode-*）: pretooluse 155/posttooluse 242/userpromptsubmit 212/sessionstart 38；内部调 check-scope/check-delegation/check-skill-modify/check-dispatch/attest-plan/check-conflicts/sync-todos/resolve-plan-dir/set-active-plan
- 门控脚本: check-complete 1039（终验总门，消费 6+ config 键+3 模板 stub 检测）、check-delegation 594、check-dispatch 387、check-plan-dispatch 281、attest-plan 225、check-3file-gate 137、check-template-type 42、check-rescue-chain 286、check-conflicts 222、check-context-hygiene 145、check-scope 187、check-skill-modify 92、subagent-fallback 316、smart-merge-back 623、init-session 355、sync-todos 336
- selftest 26 脚本 5674 行 + registry.tsv 35 行 + registry.sh 53 行

## C. 耦合风险清单（拆什么会断什么）

### C1. selftest 对 SKILL.md 的硬锚（拆分直接击碎点）
1. 行数钉 ≤558 ×4：selftest-batch-pilot.sh:55、selftest-execution-stability.sh:72、selftest-knowledge-brief.sh:38、selftest-skill-collab.sh:81 —— 拆分只减不增，安全方向；但注释里每轮 task-vNNN 增量史会随删除失效
2. Rule 摘要行锚：selftest-error-loop.sh:53 `grep 'Rule 31' | grep '错误学习闭环'`；selftest-batch-pilot.sh:43 `Rule 18` 行含「试点先行」；selftest-veto.sh:45 `Rule 32` 行含「用户否决与禁令追踪」；selftest-shared-tracker.sh:43 `Rule 30` 行含「共享内容认领追踪」；selftest-workflow-orchestration.sh:47 `Rule 39（动态工作流编排`；selftest-conclusion-discipline.sh:59/69 `Rule 35`+`Rule 35.3 大输入落盘引用`；selftest-mechanism-profile.sh:61/63/65 `类型适配（Rule 37）`+`| C25 ` 行 + Critical Rules 段内 grep —— **Rule 摘要行若从 SKILL.md 删除，对应 selftest 必 FAIL**。结论：Rule 17/18/30-34/37/38/39 的摘要行是 selftest 守护锚，拆 references 可，但 SKILL.md 内摘要行要么保留要么同步改 selftest
3. 合规项锚：selftest-error-loop.sh:55 `| C19 |`、selftest-plan-tier.sh:77 `^| C26 ` 含 Rule 38、selftest-mechanism-profile.sh:63 C25 —— 检查项表行被逐条钉死
4. `Rules 1-3[1-9]` 宽容锚：selftest-error-loop.sh:59、selftest-conclusion-discipline.sh:64-67（`1-3[5-8]` 计数≥3、`1-34` 计数=0）、selftest-reflect-verify.sh RV-10 `Rules 1-3[5-7]` —— **拆件导致 Rule 编号重新编号 = 全线崩；编号冻结是硬约束**
5. 特定章节锚：selftest-execution-stability.sh:71 `环境级中断自愈`≥1、selftest-knowledge-brief.sh:37 `knowledge-brief` 在 SKILL.md ≥2 次、selftest-shared-tracker.sh:45 `共享内容追踪检查点`

### C2. 脚本/hook 对 SKILL.md/references/templates 的路径硬编码
- 非 selftest 脚本引用 references 仅 3 处且全为注释/hint 文本（check-conflicts.sh:14、subagent-fallback.sh:288、check-skill-modify.sh:29 白名单 pattern `references/*|templates/*`）—— 路径级耦合低
- check-skill-modify.sh:29 技能文件保护 pattern 含 `SKILL.md|references/*|templates/*|companion/*` —— 新拆分技能的文件需加进该 pattern 才受 Rule 36 保护
- check-complete.sh L630 硬编码读 `templates/verification.md` 做 V-N 基准行数（`sed+grep -E 'V-数字.数字'`）—— verification.md 结构变动直接断
- init-session.sh:23/57 BUILTIN_TEMPLATES="${SCRIPT_DIR}/../templates" + variant 目录 = SKILL_ROOT/templates/variant（复制语义：按 template_type 找 `variant/<type>-type.md`）
- check-template-type.sh L14-16 白名单动态派生（见 C3）
- sync-ide-folders.ts L44 `["templates/findings.md","templates/progress.md","templates/task_plan.md"]` 硬编码三元组
- zcode-hook 内部只调 `$SKILL_ROOT/*.sh` 相对路径（C0 已述）—— hook 脚本可整体保留

### C3. check-template-type.sh 白名单动态派生 × variant/ 耦合
- 白名单 = `general` + `ls "$SKILL_ROOT/templates/variant/"*-type.md` 去后缀（Rule 34.1 明令「禁硬编码副本」）
- 耦合点：①移动/删除 variant 目录 → 白名单骤缩 → attest-plan 内置模板门控拒绝新 type；②init-session 依赖同一目录复制模板；③selftest-plan-tier L96 对 13 个 standard variant + task_plan.md 统计 `plan_tier: standard` 标记数（std_marks）；④selftest-template-lifecycle TL-17 断言 template-guide 含「13 个」（**目录实际 16 个 variant，「13 个」是文档计数锚，新加 variant 必须同步改 template-guide 文案**——现存已知脱节：mini-lite/publish 等加入后计数已漂移，文档未更新）
- ⇒ 模板体系（templates+init-session+check-template-type+template-guide/mapping+plan-writer 模板选择表）是一个内聚孤岛，可整体迁出为独立技能，唯一跨技能缝 = attest-plan.sh/check-complete.sh 调 check-template-type（改为跨技能调用或保留 stub）

### C4. config.json 键 ↔ 脚本绑定（全量键清单，440 行 JSON Schema）
- 数值键（子代理规模）: max_vc(5)/min_verification_per_phase(2)/retry_count(3)/max_tool_calls_before_refresh(5)/max_view_browser_before_save(2)/escalation_threshold(3)/todo_sync_interval_calls(10 → zcode-posttooluse)/plan_update_interval_minutes(15)/stale_remind_cooldown_calls(10)/findings_stale_minutes(20)/compass_escalate_after(2)/progress_stale_minutes(25)/prompt_note_interval(10)/plan_archive_age_days(7)/delegation_rate_floor(0.7 → check-complete)/autonomous_resume(true → plan-resume skill 消费)/plan_dir_pattern/template_priority
- subagent.* 10 子键: max_per_phase/retry_limit/max_files_per_dispatch(3)/max_lines_per_dispatch(300)/step_max_files(2)/step_max_lines(100)/step_max_minutes(15)/step_max_steps(4)/timeout_by_type（explore30/editor60/debugger60/executor120）/prompt_max_chars —— 消费方 check-dispatch/check-plan-dispatch/selftest-final-gate-hash（四元内容键）
- 档位键（14 个 enforce 键 → 消费脚本）: delegation_enforce→check-delegation+check-complete；dispatch_contract_enforce→check-dispatch；fmea_enforce→attest-plan+check-complete；vc_gate_enforce/rescue_chain_enforce/error_loop_enforce/reflect_verify_enforce/mechanism_profile_enforce/skill_modify_enforce/plan_tier_enforce→check-complete；template_gate_enforce→attest-plan；skill_modify_enforce→check-skill-modify；plan_tier_enforce→check-plan-dispatch；rescue_chain_enforce→check-rescue-chain；provider_fallback→subagent-fallback；context_hygiene/plan_hygiene/shared_tracker/veto/hook_self_heal/content_quality/knowledge_brief/skill_collab → 仅 SKILL.md 流程层（无脚本消费=纯文档档位）
- **拆分风险：一个 config.json 服务全技能；拆成多技能后每个新技能要么各自带 config 要么跨技能读 task-planner/config.json —— 路径约定需重设计；selftest-knowledge-brief T10/selftest-execution-stability T9 断言「键名同时出现在 config.json+SKILL.md ≥2 文件」，拆走键+改 SKILL.md 需同步双改**

### C5. companion/ 与 SKILL.md 互引
- plan-writer.md（271 行）: L22 引用「SKILL.md §任务模板库」、L39 `templates/variant/` 选择、L44 knowledge-brief 五段契约（对应 selftest-knowledge-brief 全链路断言）、L50-64 模板映射表（与 template-mapping §六 双写，需同步）、L83-84 批量触发词→batch_report+batch-quality-gate
- article-batch-publisher.md（156）/article-field-fixer.md（59）: 外围内容管线 agent，与规划核心无强耦合
- install-companion.sh 安装：companion/agents/*.md → ~/.zcode/agents/ 或 ~/.claude/agents/（已验证两部署位 agents/ 下三文件在位）；顶层 skills/{task-drift-guard,plan-resume,todo-skill} 由仓根安装（外围依赖面）
- **拆分风险：plan-writer 是模板体系的执行体，随模板拆出走；SKILL.md 路由表 L369「计划撰写 → plan-writer」行须改指新技能**

### C6. install/uninstall/register-hooks 安装面
- install.sh 7 相：canonical(git) → detect-tools → backup → **install-stub（rsync scripts/ + references/ + templates/ + config.json → 各工具 stub 目录，sed 重写硬编码路径）** → migrate-refs → register-hooks（claude 显式 patch settings.local.json；zcode/opencode/cursor/continue = 平台读 SKILL.md frontmatter 自动注册）→ install-companion → subagent-fallback bind
- 实测三部署位非 stub 而全量目录（diff 全同）⇒ 当前实际安装路径是全量复制而非薄壳
- uninstall.sh: 删 stub 目录 +（可选）canonical/backup；`TASK_PLANNER_ROOT 默认 $HOME/dev/task-planner`（与 canonical 仓路径 /mnt/data/dev 不符 = 历史遗留默认值）
- **拆分风险：新技能要重复整套 install/uninstall/companion/selftest-registry 设施；最小代价 = 新技能先只做「纯 references 外移」（install-stub 多 rsync 一个目录 + selftest 路径改 4 处行数/引用锚）**

### C7. 其它暗雷
- selftest-registry.tsv（35 行）登记全部 26 个 selftest + dep_anchors；增删 selftest 必同步 TSV 否则 selftest-registry.sh T02/T03 FAIL —— 拆件后每个新技能的 selftest 独立成 registry
- .zcode/workflow-drafts/（审查草稿 .dwf.ts，非运行件）
- 三部署位逐字节一致 = 每次拆分后 `install.sh` 全量重跑 + `~/.zcode/cli/config.json` hooks 指认不变（脚本名不变即可）
- SKILL.md frontmatter `references:` 清单 8 行（L8-19）= 平台读取面，拆件后逐个迁出

## D. 非核心候选评估表（按内聚度排序）

| # | 候选 | 包含资产（行数） | 消费点 | 难度 | 拆分风险一句话 |
|---|---|---|---|---|---|
| ① | 模板生成体系 | templates/ 全 26 文件≈3370（variant 1934+顶层 1436）+ init-session.sh 355 + check-template-type.sh 42 + template-guide 276 + template-mapping 230 + knowledge-brief 52 + batch_report/cost_log/shared-tracker 161 + plan-writer.md 271 + SKILL.md §任务模板库 L542-556(15) | 高: check-complete(verification 基准)、attest-plan(模板门控)、check-plan-dispatch、selftest ×7、install-stub rsync、plan-writer 路由行 | **高** | 白名单动态派生把 template_type 语义焊在 attest 门控链上，迁移需保留 check-template-type stub 跨技能调用 |
| ② | 调研路由 | SKILL.md §调研类操作 L466-506(41) + 路由表 github 行 L378 + research/web-search agent 行 | 中: 无脚本消费，纯流程文档；selftest 零锚 | **低** | 几乎零机耦，最安全；唯一缝=路由表行与 §反模式互引（L505） |
| ③ | 成本控制 Rule 17 | cost-control.md 171 + billing.md 61 + cost_log.md 72 + SKILL.md L294/L345 | 中: 指针 4 处，无脚本 | 低 | 三文件自成闭环，纯文档迁出+摘要行 1 行即可 |
| ④ | 批量门控 Rule 18 | batch-quality-gate.md 168 + batch_report.md 65 + SKILL.md L295/摘要行 + plan-writer L83-84 | 中: selftest-batch-pilot 5 锚（含 SKILL.md「Rule 18 摘要行含试点先行」L43） | 中 | 摘锚全在 selftest-batch-pilot（可随迁），但 Rule 18 与 Rule 31（18.10 投毒红线交叉引用）互锁 |
| ⑤ | skill-collaboration | skill-collaboration.md 113 + SKILL.md L46-54(9)+L348 + selftest-skill-collab 96 | 中: selftest T1b 断言文件 ≤300 行 + T9 键名跨文件 + subagent-fallback hint 文本 L288 | 中 | 与 Rule 22.3.3 兜底链互引（五档兜底表 ④→技能族接管），迁出需保留 critical-rules 内指针 |
| ⑥ | workflow 编排 Rule 39 | critical-rules Rule 39 段（在 368 行大文件内）+ SKILL.md L53/L202/L317 + zcode-pretooluse workflow matcher + selftest-workflow-orchestration 110 | 中: hook matcher 已含 CreateWorkflow/AmendWorkflow/SaveWorkflow/EvalWorkflowSnippet（删 Rule 39 要动 cli config.json hooks） | 中 | 触发面在平台 hook matcher 里，纯删 SKILL 段不够，需同步改 ~/.zcode/cli/config.json |
| ⑦ | methodology/FMEA | methodology.md 236 + SKILL.md L82-84(3)+L305 + selftest-methodology 221 + config fmea/content_quality 键 | 高: selftest-methodology cp 文件进 fixture 做 14 条/9 条/§思维方法论计数断言；attest/check-complete 双点机器门 | 中 | 文件可整体迁出但 fixture 断言路径 + FMEA 门控脚本段（attest L门控段/check-complete 终验段）是跨技能缝 |
| ⑧ | 其它可削 | Chain 模式详解 L243-284(42) / 高频漂移 L509-538(30) / Read-vs-Write L122-130(9) / 中断自愈 L448-449 | 低: 中断自愈有 selftest 锚（C1-5）；Chain 详解无脚本锚 | 低 | 直接压进 reference.md（已含 Chain Handoff Contract 权威源）或 critical-rules，零机耦 |

**总评**：三大耦合雷区 = ①selftest 行数钉+Rule 摘要行锚（拆 SKILL.md 段落必改 4-7 个 selftest）②check-template-type/init-session 白名单动态派生（模板体系焊死在 attest 链）③config.json 单文件 440 行 + 键名跨文件一致性断言（T9 类断言要求键名在 ≥2 文件同现）。最适合拆的 3 个：②调研路由（零机耦，立即可做）、③成本控制（纯文档闭环）、⑤skill-collaboration（内聚但需迁 selftest-skill-collab）。模板体系①收益最大（~5000 行 + SKILL.md 15 行）但难度最高，建议第二批。
