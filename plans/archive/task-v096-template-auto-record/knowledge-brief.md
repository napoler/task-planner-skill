# Knowledge Brief — task-v096-template-auto-record（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 20（template-guide.md:65 验收）
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出（2026-09-29），执行期持续回填。
> 全部事实来自本会话实际 Read/grep 实测，证据 file:line 可复核；派发 prompt 按 §5 索引引用 § 锚点做材料包，禁止凭记忆转述。

## §1 任务速览与核心概念
- 任务一句话：为 task-planner 引入「模板自动记录与主动激活」——三时点感知网（T1 计划创建期机器提示 / T2 计划期 LLM 条款 / T3 终验 warn 兜底）+ 全自动模板生成合约（34.7），全量 selftest 0 FAIL 后合并部署。
- 背景/动机：现行 34.3 沉淀触发仅在终验且纯人工判定（C22「沉淀判定人工」无机器激活点），init-session 类型空缺时静默落 general 无提示，模板复用完全依赖人记忆。
- 权威源：`plans/task-v096-template-auto-record/subagent-state/01-plan-writer-brief.md`（需求与设计唯一权威，本 brief 是其知识底座）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 三时点感知网 | T1 init-session.sh 机器激活点 + T2 critical-rules 34.7 LLM 行为 + T3 check-complete.sh warn 兜底，三层主动提示模板沉淀 |
| [template-sense] | T1 emit 的提示行 token，也是 T3 warn 检索与 P6 selftest 断言的统一标识 |
| 🔁 模板感知区块 | init-session 运行时追加到 task_plan.md 末尾的区块（触发信号+34.3② 预登记+终验必查+四点同步指针），非模板本体内容 |
| 全自动生成合约 | 终验命中 34.3 且 COMPLETE → 主进程直接派执行体生成新 variant，不 AskUserQuestion；34.5 闸门内置生成侧 |
| 34.5 闸门内置 | 生成执行体先 ls variant 查重 + 泛化性评估；一次性/不可泛化 → 登记不沉淀理由收场而非硬生成 |
| 计数级联 | 新沉淀 variant 时 template-guide.md「N 个」计数 +1 且 selftest-template-lifecycle TL-17 断言同步改（v093 教训：同源锚必须同改） |
| 四点同步（34.2） | template-mapping.md / plan-writer.md / SKILL.md 模板节 / template-guide.md 四落点；拓扑注意：mapping/guide 在卫星 plan-template-kit/references/ |
| hook 税 | v091 实证：UserPromptSubmit hook 每轮注入拖慢全部会话，是最大慢源——D1 裁决禁碰 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 34 现行=34.1-34.6 共 6 子条（L313-318），critical-rules.md 全文 390 行（L390 末行） | skills/task-planner/references/critical-rules.md:313-318（grep ^34. 实测） | 34.7 插入点=L318 之后纯追加，零编号冲突 |
| Rule 34 摘要行含 selftest 锚子串「Rule 34（P0）模板生命周期门控与沉淀」及子条列表「选取门控(34.1)/…/机制(34.6)」 | skills/task-planner/SKILL.md:262 | 行内改「感知」语义时该子串必须保全 |
| C22 行现行：「…命中 34.3 沉淀触发时已按 34.4 沉淀或登记不沉淀理由（沉淀判定人工）」 | skills/task-planner/SKILL.md:186（sed 184-188 实测） | 行内改「沉淀判定人工」→「终验全自动生成（34.7）+登记」，其余子串保全 |
| SKILL.md 其他联动面：L9 索引行、L214「模板选取门控与沉淀（Rule 34 — task-v074）」段、L429 卫星指针段 | skills/task-planner/SKILL.md:9,214,429 | P3 S2 联动范围；selftest-template-lifecycle TL-15 守护 L214 段标题 |
| general fallback 链：TEMPLATE_TYPE 空时 project default 文件 > env TASK_TEMPLATE_DEFAULT > 缺省 general（逐字节不变行为） | skills/task-planner/scripts/init-session.sh:149-165 | T1 分支①改点：fallback 决议为 general 时 emit+追加区块 |
| unknown 类型分支：「WARNING: unknown template_type …」 | skills/task-planner/scripts/init-session.sh:183-186 | T1 分支②改点；mini tier 分流在其后 L189-194，追加写盘点须与它正交 |
| check-complete.sh 1039 行，fmea-gate 段档位解析 env>config>warn、`[fmea-gate] ⚠` 输出不阻断 | skills/task-planner/scripts/check-complete.sh:486-517 | P4 新 warn 段照此风格，≤15 行，零新 config 键 |
| TL-17 断言：template-guide.md 含 rule-enhancement 且计数「16 个」 | skills/task-planner/scripts/selftest-template-lifecycle.sh:81 + skills/plan-template-kit/references/template-guide.md:32 | 计数级联守护点：新沉淀后「16 个」→「17 个」两处同改 |
| variant 模板现存 16 个；check-template-type.sh 白名单=general+ls variant 动态派生 | templates/variant/ ls 实测（16 文件）+ 简报 §3 | 新 variant 自动入白名单，零白名单同步成本 |
| selftest 脚本现存 35 个；registry=scripts/selftest-registry.tsv + selftest-registry.sh | skills/task-planner/scripts/ ls 实测 | P6 新建 selftest-template-sense 后必须登记 registry |
| 卫星技能实体位于 skills/plan-template-kit/（与 task-planner 平级），SKILL.md 已含沉淀指针节 | ls /mnt/data/dev/task-planner-skill/skills/ 实测 + 简报 §3 | P5 改点=卫星 SKILL.md 沉淀节，非主技能 |
| v095 终态基线预期 35 脚本 584 PASS / 0 FAIL（aa092cc..de8e8fe 已 push），无并行冲突面 | 简报 §7 | P1 以实测为准禁沿用纸面数；worktree 无冲突 |
| C22 行在主模板由 TL-14 守护（grep '^| C22 '） | scripts/selftest-template-lifecycle.sh:75-76 | C22 行内改时行首格式 `\| C22 \|` 不可破坏 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :313-318 | Rule 34 现行六子条：34.1 选取门控（白名单动态派生+逃生披露）/ 34.2 四点同步 / 34.3 沉淀触发三条件 / 34.4 沉淀流程（≤100 行 variant+四点登记+selftest）/ 34.5 防滥用（查重+泛化性）/ 34.6 机制 template_gate_enforce 三档默认 warn——34.7 纯追加在其后 |
| skills/task-planner/SKILL.md | :262 | Rule 34 摘要行（P0 锚）：选取门控/四点同步/沉淀触发/沉淀流程/防滥用/机制子条列表+开关键名——T2 行内补「感知」处 |
| skills/task-planner/SKILL.md | :186 | C22 合规清单行：template_type 门控（机器门）+34.3 命中时沉淀或登记理由（沉淀判定人工）——T2 行内改全自动语义处 |
| skills/task-planner/SKILL.md | :214 | 「模板选取门控与沉淀（Rule 34 — task-v074）」段：门控+触发→提炼+四点同步流程——可加指针行处（TL-15 守护段标题） |
| skills/task-planner/SKILL.md | :429 | 卫星指针段：模板选型/沉淀主路由 Skill("plan-template-kit")，机械层留守——拓扑认知锚 |
| skills/task-planner/scripts/init-session.sh | :149-165 | fallback 链：PDIR default > env TASK_TEMPLATE_DEFAULT > general——T1 分支①（general 落地时 emit+追加区块） |
| skills/task-planner/scripts/init-session.sh | :183-186 | unknown template_type WARNING+Falling back 分支——T1 分支②（emit+追加区块） |
| skills/task-planner/scripts/init-session.sh | :189-194 | mini tier 分流（tier=mini 且已命中 variant 则忽略提示）——追加区块不得破坏其语义 |
| skills/task-planner/scripts/check-complete.sh | :486-517 | fmea-gate warn 范式：resolve 档位 env>config>warn、`[fmea-gate] ⚠` 不阻断——P4 新段风格范本 |
| skills/task-planner/scripts/selftest-template-lifecycle.sh | :75-81 | TL-14（C22 行锚）与 TL-17（guide 计数「16 个」）断言——锚保全与计数级联守护 |
| skills/plan-template-kit/references/template-guide.md | :32 | 「Variant 模板（16 个 …）」计数行+沉淀收编历史注记——计数级联落点 1 |
| skills/plan-template-kit/SKILL.md | 沉淀指针节 | 已含 Rule 34.3→34.2 四点同步指针——P5 补全自动合约+计数级联清单处（精确行号执行期 grep 定位） |

## §4 易错点与禁止假设清单

1. 禁止改 templates/task_plan.md 模板本体——「🔁 模板感知」区块是 init-session.sh **运行时追加**（它锚多，动本体伤全部下游生成）。
2. 禁止碰 UserPromptSubmit hook（zcode-userpromptsubmit.sh L182 [plan-note] 注入点）与一切 hook 接线——D1 裁决冻结（hook 税）。
3. 零新 config 键——T3 是纯 warn 语义无门控键；34.7 也不挂三档键（硬约束）。
4. grep 锚断裂风险：C22 行、Rule 34 摘要行（L262）、L214 段标题、L9 索引行都是 selftest/机器门锚——只做行内关键词改写，既有子串（「template_type 已过 check-template-type.sh 门控」「Rule 34（P0）模板生命周期门控与沉淀」「\| C22 \|」行首格式）必须保全；改前快照差集对账。
5. Rule 编号冻结 1-39：34.7 纯追加，禁止重排/重编号既有子条。
6. 内容型锚必漏（v095 Error Log 教训）：每个改点 S-unit 动手前先 grep 消费方 selftest 断言（`grep -n '<关键词>' scripts/selftest-*.sh`），锚点清单只作导航不作豁免。
7. 计数级联双锚：新沉淀 variant 时 template-guide.md L32「16 个」与 selftest-template-lifecycle.sh L81 TL-17 必须同改（v093 教训）；本任务自身预计不沉淀新类型（rule-enhancement 已存在），级联是 34.7 条款内容而非本任务执行项。
8. selftest 总数禁采信子代理自报：主进程逐脚本 Total 行求和；基线以 P1 实测为准，非纸面 584。
9. init-session.sh 是 v095 留守机械层：改动唯一合法来源=Rule 36.2 归因（用户点名功能增量，简报 §2.3）；改后 bash -n + selftest-plan-tier 及 init-session 相关 selftest 全绿是硬门槛。
10. T1 追加点与 mini tier 分流正交：L189-194 分流发生在 variant 路由后，追加区块不得破坏「tier=mini 忽略提示」语义；追加区块破坏下游解析（check-scope/check-3file-gate/check-template-type 读 task_plan.md）是最高 RPN 失败模式 → 追加前 grep 下游解析锚+两分支实测+selftest 兜底。
11. subagent_type 纯 token：派发 prompt 与 Handoff 登记表只写 executor / code-reviewer / code-assistant，禁括号模型后缀（v095 教训）。
12. 逐 Phase git 提交（worktree 内）；合并回后 install.sh 全量部署三实体位 + diff -r 复验，禁跳过部署位复验。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「P2 init-session 追加区块破坏下游解析」行（RPN 最高项，兜底=追加前 grep 下游解析锚+两分支正/负例实测+selftest 兜底）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P2-S1 | §2（fallback 链行）+ §3（A6/A8 行）+ §4 条 1/10 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh |
| P2-S2 | §2（unknown 行）+ §3（A7 行）+ §4 条 1/10 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh |
| P3-S1 | §1（三时点/全自动合约）+ §3（A1 行）+ §4 条 3/5 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md |
| P3-S2 | §3（A2/A3/A4 行）+ §4 条 4 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md |
| P4-S1 | §3（A9 行）+ §1（T3 定义）+ §4 条 3 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh |
| P5-S1 | §3（A12 行）+ §1（全自动生成合约） | /mnt/data/dev/task-planner-skill/skills/plan-template-kit/SKILL.md |
| P6-S1 | §1（T1/T3 触发样例）+ §2（registry 行） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv |
| P6-S2 | §2（registry 行 + 基线行） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.sh |
| P7-S1 | §4 条 8（求和纪律）+ §2（基线行） | /mnt/data/dev/task-planner-skill/plans/task-v096-template-auto-record/progress.md |
| P7-S2 | §4 条 12（部署位 diff -r） | /mnt/data/dev/task-planner-skill/skills/task-planner/install.sh |
| P8-S1 | §1（全自动合约）+ §4 条 6/7 | /mnt/data/dev/task-planner-skill/plans/task-v096-template-auto-record/verification.md |
