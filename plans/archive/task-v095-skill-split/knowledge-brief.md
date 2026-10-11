# Knowledge Brief — task-v095-skill-split（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填 §2/§3。

## §1 任务速览与核心概念

- 任务一句话：按用户裁决的标准 4+3 方案拆分 task-planner 技能——4 个卫星技能承接 SKILL.md 非核心段落 + 3 段内敛进既有权威文档，SKILL.md 556→≤430 行，selftest 全绿与锚点全在为行为不变判据。
- 背景/动机：每次触发加载的上下文 = SKILL.md 正文（references/scripts 不读不占上下文），段落外迁 = 按需加载 = 触发成本下降。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 卫星技能 | 仓库内 skills/<name>/ 新建技能，承接主技能非核心段落，主技能留显式 Skill() 指针行做主路由 |
| 机械层留守 | templates/ variant 库+init-session.sh+check-template-type.sh+attest 门控零改动（白名单动态派生焊死 attest 链，测绘 C3） |
| selftest 锚 | selftest 脚本对 SKILL.md 的 grep 硬锚（Rule 摘要行/C 项行/行数钉/计数锚），删锚即 FAIL |
| 行数钉 | selftest 断言 SKILL.md ≤558 行 ×4 处（C1-1）；缩减安全方向，≤430 目标在其内 |
| 三部署位 | ~/.zcode、~/.claude、~/.config/opencode 三处 skills/ 全量目录，install.sh rsync 同步，部署后 diff -r 复验 |
| 段落内敛 | 不建卫星，把 SKILL.md 段落并入既有权威文档（reference.md / critical-rules.md） |
| v094 并行禁碰 | wt/task-v094-tier-b-rollout 属并行会话 worktree，全程禁碰，合并前 merge-base 核对 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| SKILL.md 现为 556 行；目标 ≤430（≥20% 缩减） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（wc -l 实测 556，2026-09-29）；brief §1 | VC-1 判定基准；行数钉 ≤558 缩减安全 |
| Rule 摘要行是 selftest 硬锚：selftest-error-loop.sh:53 grep 'Rule 31'、selftest-batch-pilot.sh:43 'Rule 18' 含「试点先行」、selftest-veto.sh:45 'Rule 32'、selftest-shared-tracker.sh:43 'Rule 30'、selftest-workflow-orchestration.sh:47 'Rule 39'、selftest-conclusion-discipline.sh:59/69 'Rule 35'、selftest-mechanism-profile.sh:61/63/65 'Rule 37'+C25 | 01-explore-structure.md §C1-2；各 selftest 脚本对应行 | Rule 17/18/30-39 摘要行留守 SKILL.md；删除即对应 selftest FAIL |
| C19/C25/C26 检查项行被逐条钉死 | selftest-error-loop.sh:55（C19）、selftest-plan-tier.sh:77（C26）、selftest-mechanism-profile.sh:63（C25） | 合规检查清单 C1-C27 行不可动 |
| `Rules 1-3[1-9]` 宽容计数锚存在 ×4 脚本 | selftest-error-loop.sh:59、selftest-conclusion-discipline.sh:64-67、selftest-reflect-verify.sh RV-10（测绘 C1-4） | Rule 编号重新编号 = 全线崩；编号冻结是硬约束 |
| 行数钉 ≤558 ×4 | selftest-batch-pilot.sh:55、selftest-execution-stability.sh:72、selftest-knowledge-brief.sh:38、selftest-skill-collab.sh:81 | 缩减方向安全；注释内 vNNN 增量史失效可接受 |
| check-template-type.sh 白名单动态派生（general + ls variant/*-type.md），Rule 34.1 禁硬编码副本 | skills/task-planner/scripts/check-template-type.sh:14-16（测绘 C3）；init-session.sh:23/57 同源复制 | 模板机械层留守；variant 目录不可移动 |
| check-complete.sh L630 硬编码读 templates/verification.md 做 V-N 基准行数 | check-complete.sh:630（测绘 C2） | verification.md 结构零改动 |
| check-skill-modify.sh:25-33 保护 pattern 含 SKILL.md/references/*|templates/*|companion/* 等 case 块 | scripts/check-skill-modify.sh:29（本次实测 Read 确认） | :29 追加卫星路径 = 唯一机械例外 |
| 三部署位与 canonical 逐字节一致（diff -rq 无差异）；hook 指向 ~/.zcode 位 | 01-explore-structure.md §0；install.sh 7 相（L129-147 源 lib/install-stub.sh） | 部署 = install.sh 全量重跑 + diff -r 复验，脚本名不变则 hook 接线不动 |
| zcode-posttooluse.sh:108 唯一 SKILL_ROOT 硬编码（环境变量可覆盖） | 01-explore-structure.md §0 | 不改 hook 脚本则零影响 |
| 卫星候选自评：调研路由零 selftest 锚最安全；成本三件套纯文档闭环；collab 需迁 selftest-skill-collab+3 处引用；模板知识层外迁机械层留守 | 01-explore-structure.md §D ②③⑤① + findings.md Research §4 | P2 试点先行顺序的依据 |
| template-guide「13 个」计数 vs variant 实际 16 个（已知漂移） | 01-explore-structure.md §C3；selftest-template-lifecycle TL-17 断言 | P3 S1 顺手修为 16 |
| registry.tsv 35 行登记 26 selftest+dep_anchors；selftest-skill-collab/shared-tracker/fallback 的 dep_anchors 都含 skill-collaboration.md | scripts/selftest-registry.tsv:11/23/24（本次实测 Read 确认） | P5 S2 须同步 registry.tsv dep_anchors |
| subagent-fallback.sh:288 hint 文本引用 skill-collaboration.md | 01-explore-structure.md §B skill-collaboration 行 | P5 S2 hint 文本同步 |
| config.json 440 行单文件服务全技能；T9/T10 类断言要求键名 ≥2 文件同现 | 01-explore-structure.md §C4 | 零新键约束；卫星不读 config |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/SKILL.md | L46-56 | 协同路由段（comet/OpenSpec/superpowers 触发矩阵）；L55 指向 skill-collaboration.md 的指针行——P5 外迁+指针化对象 |
| skills/task-planner/SKILL.md | L122-130 | Read vs Write 决策矩阵（Rule 20.5）——P6 S2 并入 critical-rules |
| skills/task-planner/SKILL.md | L243-284 | Chain 模式详解（linked/fan-out）——P6 S1 并入 reference.md |
| skills/task-planner/SKILL.md | L294/L345 | Rule 17 摘要行 / References 表 cost 行——P4 指针化（摘要行留守仅改详见路径） |
| skills/task-planner/SKILL.md | L466-506 | 调研类操作（WebSearch+github 双路+引用格式+禁止清单）——P2 外迁对象，本次实测确认边界行 |
| skills/task-planner/SKILL.md | L509-538 | 高频漂移纠正——P6 S2 并入 critical-rules Rule 15 |
| skills/task-planner/SKILL.md | L542-556 | 任务模板库节（权威源声明=template-mapping.md）——P3 S2 指针化 |
| skills/task-planner/scripts/check-skill-modify.sh | :25-33 | 保护 pattern case 块（SKILL.md/config.json/references/*|templates/*|companion/*）——P7 S1 :29 追加卫星路径 |
| skills/task-planner/scripts/selftest-registry.tsv | 35 行 | 26 个 selftest + dep_anchors 登记；L11/23/24 与 collab 相关——P5/P7 同步 |
| skills/task-planner/scripts/check-template-type.sh | :14-16 | 白名单动态派生（general + variant 目录）——留守不动 |
| skills/task-planner/scripts/subagent-fallback.sh | :288 | hint 文本引用 skill-collaboration.md——P5 同步 |
| skills/task-planner/scripts/check-complete.sh | :630 | 读 templates/verification.md 做 V-N 基准——不动 |
| skills/task-planner/lib/install-stub.sh | :9-12 | rsync 面：scripts/ 带 sed 路径重写 + references/+templates/+config.json——P7 S1 扩清单参考 |
| skills/task-planner/install.sh | :129-147 | Phase 4 stub 安装/Phase 5 migrate-refs 入口——P7 部署 SOP 锚 |
| skills/task-planner/companion/agents/plan-writer.md | L22/39/50-64 | 模板引用三处（SKILL.md §任务模板库/variant 选择/mapping 双写表）——P3 S2 同步 |
| plans/task-v095-skill-split/subagent-state/01-explore-structure.md | 全文 150 行 | 结构测绘权威源（A 段落地图/B 消费关系/C 耦合风险/D 候选评估）——所有行号迁移的最终事实源 |
| plans/task-v095-skill-split/subagent-state/02-plan-writer-brief.md | 全文 | 设计裁决冻结版（4+3 方案/硬约束 §2.3/VC §4/FMEA §5） |

## §4 易错点与禁止假设清单

1. 禁止删除/改写 SKILL.md 内 Rule 17/18/30-39 摘要行、C19/C25/C26 行、`Rules 1-3` 计数锚——它们是 selftest grep 硬锚；「指针化」只改行的「详见」路径部分
2. 禁止重排 Rule 编号；critical-rules.md 只增子条不改编号（Rule 15 扩充 / Rule 20.5 新增）
3. 禁止动 templates/ variant 库、init-session.sh、check-template-type.sh、attest-plan.sh 门控逻辑、check-complete.sh、verification.md——机械层留守是 D1 裁决的组成部分
4. 禁止动 hook 接线（~/.zcode/cli/config.json）与 zcode-*.sh；check-skill-modify.sh:29 追加卫星路径是唯一脚本例外
5. 禁止新增 config.json 键；卫星为纯 SOP/文档技能不读 config
6. 禁止碰 wt/task-v094-tier-b-rollout worktree 内容；禁止主仓 git checkout/switch/reset --hard/clean -fd
7. 禁止假设 selftest 基线 = 525/0——以 P1 实测为准记录后再开工
8. 迁移行号以测绘报告 §A 为起点，动手前必须 Read 现文件核对（SKILL.md 在 P2-P6 持续变化，行号会漂移——每 S-unit 派发 prompt 附「以 grep 段落标题重定位」指令）
9. 卫星 description 措辞必须收窄（含「计划调研路由/模板知识库/成本控制/技能协同」类限定词），禁止写成宽泛触发词与 task-planner 竞争
10. plan-writer.md 是 companion agent 非 references，迁移引用时注意它安装在 ~/.zcode/agents/ 位（install-companion.sh），路径同步勿写成 skills/ 下
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「F1 selftest 锚断裂」「F2 template-mapping 迁移致门控断链」行（回滚留守+跨技能指针降级；P6 锚点清单逐条 grep+全量 selftest 兜底）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P2-S1 | §1 + §2（候选②零机耦行） | /mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/subagent-state/01-explore-structure.md（§D ②） |
| P2-S2 | §1 + §3（SKILL.md L466-506 行） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md |
| P2-S3 | §2（基线事实） | task_plan.md VC 表 + plans/task-v095-skill-split/progress.md（P1 基线段） |
| P3-S1 | §2（C3 白名单派生/计数漂移行） | skills/task-planner/references/template-guide.md + references/template-mapping.md |
| P3-S2 | §3（plan-writer.md L22/39/50-64 行） | skills/task-planner/companion/agents/plan-writer.md |
| P3-S3 | §2（TL-16/17/18 锚行） | skills/task-planner/scripts/selftest-template-lifecycle.sh + scripts/selftest-mechanism-profile.sh |
| P4-S1 | §1 + §2（三件套闭环行） | skills/task-planner/references/billing.md + references/cost-control.md + templates/cost_log.md |
| P4-S2 | §3（SKILL.md L294/L345 行） | skills/task-planner/SKILL.md + references/critical-rules.md（Rule 17 段）+ references/batch-quality-gate.md（互引） |
| P4-S3 | §2 | task_plan.md VC 表 |
| P5-S1 | §1 | skills/task-planner/references/skill-collaboration.md（113 行全文） |
| P5-S2 | §2（registry.tsv/hint 行）+ §3（subagent-fallback:288 行） | scripts/selftest-skill-collab.sh + scripts/selftest-shared-tracker.sh + scripts/selftest-fallback.sh + scripts/subagent-fallback.sh + scripts/selftest-registry.tsv |
| P5-S3 | §2 | 同 P5-S2 材料 + progress.md 基线段 |
| P6-S1 | §3（SKILL.md L243-284 行） | skills/task-planner/reference.md（Chain Handoff Contract 权威源） |
| P6-S2 | §2（`Rules 1-3` 计数锚行）+ §4（第 2 条） | skills/task-planner/references/critical-rules.md（Rule 15/20.5 段） |
| P6-S3 | §2（锚点全集行）+ §4（第 1 条） | plans/task-v095-skill-split/subagent-state/02-plan-writer-brief.md（§2.3） |
| P7-S1 | §3（check-skill-modify/install-stub 行） | skills/task-planner/install.sh + lib/install-stub.sh + scripts/check-skill-modify.sh + scripts/selftest-registry.tsv |
| P7-S2 | §2（基线行） | plans/task-v095-skill-split/progress.md + 新建 scripts/selftest-skill-split.sh |
| P7-S3 | §1（v094 并行禁碰行）+ §4（第 6 条） | scripts/smart-merge-back.sh + progress.md（P1 merge-base 记录） |
| P7-S4 | §2（三部署位行） | skills/task-planner/install.sh |
| P8 | §2 + §4 全部 | task_plan.md VC 表 + verification.md（终验模板） |
