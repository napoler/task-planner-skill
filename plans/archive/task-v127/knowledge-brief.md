# Knowledge Brief — task-v127（Rule 50 内容要求权重分级与评级）
<!--
  定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。
  与三文件罗盘关系：本文件=知识维，不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）。
  材料源：task_plan.md（§Rule 50 设计契约）+ findings.md §Requirements/§Research Findings（只读）+ 两份 explore 检查点。
-->

## §1 任务速览与核心概念
- 任务一句话：在 task-planner 落地 **Rule 50「内容要求权重分级与评级」**（原子验收条目表 + 权重分级 + 逐条分级评级 + 双向判程度项），联动 SKILL.md 与 3 个媒体 variant 模板，新建静态 selftest 守护，全量回归 0 FAIL 后合并回 master 并部署 3 实体位。
- 背景/动机：用户原话「要求人物脸上有泪痣；不注意看不到。当前只关注有泪痣，完全忽略了后者……要求的限制大小被忽略导致人物设计缺陷」——复合需求的存在性约束与程度/强度约束在计划期（VC）与执行期（QC）双断链（findings §Requirements）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 原子验收条目表 | 把复合需求拆成逐条机读结构：`\|条目\|类型\|层级\|权重\|判定刻度\|` |
| 类型 P / E | **P**=存在性（Presence，有/无）；**E**=程度（Extent，显隐度/强度刻度） |
| 层级 H / S | **H**=硬约束（必过，任一 FAIL 即整体 FAIL）；**S**=评分项（加权计入总分）；未标注默认 H |
| 程度双向判 | E 类条目：过显眼=FAIL，过小到不可见**亦** FAIL（连带违反存在性条目） |
| 泪痣样例（P/H + E/H 双条目） | 「有泪痣」=P/H；「不注意看不到」=E/H；两条并列，不得把后者并入前者 |
| worktree | git 隔离开发区，实现类任务必须在其中开发（宪法 §十一 P0） |
| S-unit | 单次 Agent() 派发单元，单会话单 S-unit（Rule 46.1）；ID 纯数字 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| critical-rules.md 现 520 行；最后 Rule=49（`### 49` 位于 :506，49.x 至文尾 :520）；新块追加点=:520 后 | `skills/task-planner/references/critical-rules.md:506,520` | Rule 50 文末追加；S1 插入前须 `grep -n '^### 49'` 复锚 |
| Rule 47 媒体派发纪律 :484-494，零 QC 权重/强度/评级语义；`grep -c '权重' critical-rules.md`=0 | `critical-rules.md:484-494` | 规则面无既有评级语义，Rule 50 为纯新增 |
| goal-gate.md 全 17 行：VC 判定二元三态 COMPLETE/PARTIAL/BLOCKED，无分级/加权评分 | `skills/task-planner/references/goal-gate.md:7-17` | VC 分级语义 1 行为纯增量补点（S4） |
| 仓内既有加权评分先例=Q4 五维内容评分卡：五维各 1-5 分、权重表 25/20/20/20/15 合计 100、加权 ≥4.0 放行 | `skills/task-planner/references/methodology.md:193-212`（阈值 :209） | Rule 50.4 加权判定直接对齐此形态（D5） |
| SKILL.md frontmatter :9 现声明「Critical Rules 全集 1-49」；SKILL.md 现 449 行 | `skills/task-planner/SKILL.md:9` | S2 前 frontmatter 字面 1-49→1-50；净增 ≤10 行 |
| 级联锚 PT-08=`grep -qE 'Critical Rules 全集 1-4[5-9]'`：`1-4[5-9]` **不匹配** "1-50"，落体后 0 命中→bad | `skills/task-planner/scripts/selftest-plan-tier.sh:77-78` | S6 必须扩锚覆盖 1-50（v121 宽容化先例） |
| 级联锚 CD-11=`grep -cE '1-4[5-9]'` + 合计 ≥3（`1-3[5-9]` 在 :66） | `skills/task-planner/scripts/selftest-conclusion-discipline.sh:66,69-70` | S7 扩口径使 "1-50" 计入 |
| 级联锚 RT-08：`grep -oE '1-4[0-9]'` 逐匹配 + `grep -vE '^1-4[5-9]$'` 越界零命中；"1-50" 不含 "1-4" 故**天然不命中** | `skills/task-planner/scripts/selftest-ask-default-timeout.sh:60-69` | S6 复核确认零越界；避免误改断言语义 |
| selftest-registry.tsv 现 46 行（表头 + 45 脚本）；scripts/ 下 selftest-*.sh 实存 45 个 | `skills/task-planner/scripts/selftest-registry.tsv`（wc -l=46） | S5 registry 追加 +1 行 → 47；全量回归基线=45 脚本，落地新脚本后 46 |
| config.json properties 键自守护=40（多个 selftest 断言） | `skills/task-planner/scripts/selftest-ask-default-timeout.sh:71-74`（RT-09 等） | 零新键则无此级联（D2） |
| templates/variant/ 含媒体族 image/character-design/qc-defect 等 30 个类型文件 | `skills/task-planner/templates/variant/`（ls） | 评级契约区块消费点落点（S3/S4） |
| 外部图像链 7 技能无一具备「需求清单输入→逐项判定」；image-review 二值 + P0/P1/P2 缺陷级、image-understand 纯描述无判定 | findings §[sub:02-explore]；`subagent-state/02-explore-skills.md`；`~/.zcode/skills/image-review/SKILL.md:9,43-46` | 落点=task-planner 编排层；下游技能被消费不改造（D4） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `skills/task-planner/references/critical-rules.md` | :484-494 | Rule 47 媒体派发四子条（拆分轴/具名路由/试点先行/机制），Rule 50 条文体例参照 |
| `skills/task-planner/references/critical-rules.md` | :506-520 | Rule 49 单元线多路并行（最新落块），50 追加点=:520 后 |
| `skills/task-planner/SKILL.md` | :9 | frontmatter references 行，规则全集字面「1-49」待扩「1-50」 |
| `skills/task-planner/SKILL.md` | 摘要区 / 路由表媒体行 | Rule 50 bullet 与媒体路由消费点挂载位（S2） |
| `skills/task-planner/references/goal-gate.md` | :7-17 | VC 五规则 + 二元三态退出标准；分级语义 1 行追加点（:13 后） |
| `skills/task-planner/references/methodology.md` | :193-212 | Q4 五维评分卡：权重表 + 加权总分 + 三档阈值（Rule 50.4 形态先例） |
| `skills/task-planner/scripts/selftest-plan-tier.sh` | :77-78 | PT-08 `1-4[5-9]` 宽容锚（需覆盖 1-50） |
| `skills/task-planner/scripts/selftest-conclusion-discipline.sh` | :66-70 | CD-11 `1-3[5-9]`+`1-4[5-9]` 计数合计 ≥3 |
| `skills/task-planner/scripts/selftest-ask-default-timeout.sh` | :60-69 | RT-08 越界负断言（`1-4[0-9]` 逐匹配），"1-50" 天然不命中 |
| `skills/task-planner/scripts/selftest-registry.tsv` | :1（表头）/ 表尾 | 4 列：script/domain/trigger_scenarios/dep_anchors；新守护登记 +1 行 |
| `skills/task-planner/scripts/selftest-media-dispatch.sh` | 全文 | 同族静态守护范式（MD-01..09，S5 新脚本参照） |
| `skills/task-planner/templates/variant/image-type.md` | :18 VC 段后 | 图像生成模板，评级契约区块挂载位（S3） |
| `skills/task-planner/templates/variant/character-design-type.md` | :18 VC 段后 | 角色设计模板，评级契约区块挂载位（S3） |
| `skills/task-planner/templates/variant/qc-defect-type.md` | :18 VC 段后 | 质量审查模板，评级契约区块挂载位（S4） |

## §4 易错点与禁止假设清单
1. **派发守卫契约（Rule 22.4a/b / check-dispatch.sh）**：executor prompt 必自带计划三文件绝对路径 + `status:/acceptance:/files:/evidence:/checkpoint:/findings_written:/blockers:/confidence:` 8 字段标签；任务书内 distinct S-unit ID ≥2 或行首 markdown 编号会被判打包拦截——派发 prompt 不得复述任务书编号列表。
2. **Rule 编号**：接续最大 Rule 取 **50**，禁碰 48/49。任务书标「避让 pending v126 的 49」——实际 Rule 49 已落 `critical-rules.md:506`，仍取 50。
3. **级联锚禁止用改断言语义掩盖问题**：三锚（PT-08/CD-11/RT-08）只按 v121 宽容化先例扩口径使 `1-50` 合法；「锚过窄→宽容化 / 内容越界→回炉」二分处置（FMEA Phase 3 行 RPN=96 兜底）。RT-08 对 "1-50" 天然不命中，勿误加白反转语义。
4. **零新 config 键**：不得改 `config.json`（properties 必须保持 40）；机制面=新建静态 selftest（50.6，v122/v123 先例）。
5. **S-unit 机器契约**：ID 纯数字（S1-S9，禁字母后缀）；**输入列文件路径 token ≤2**；**预估时长一律 NNmin 格式且 ≤15min**，超限先拆不升档；「执行体」列必填（继承 / 具体 subagent_type(model)）。S1-S7 每行 ≤2 文件。
6. **程度条目禁止并入存在性条目**（Rule 50.2）；未标注层级默认 **H**。泪痣案例必须拆出 P/H 与 E/H 双条目（VC-3 判定对象）。
7. **禁区**：禁改 findings.md/progress.md；git 只读；禁触碰其他 worktree（`/mnt/data/dev/task-planner-skill-worktrees/task-v124`）与既有簿记残留（v116 dispatch-inflight、v118/v121/v124/v125/v128/v129）。技能文件=保护区，改动一律在 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v127`（分支 `wt/task-v127`）内进行。
8. **脚本语言纪律**：禁 `python3 -c` / `node -e` 内联；≤3 行用 bash。
- FMEA RPN>100 兜底指针：无 RPN>100 行（最高 96）；96 两行兜底见 `task_plan.md` FMEA 表「Phase 3 级联锚扩口径后回归 FAIL」/「Phase 4 全量回归未知 FAIL」。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §4.2 + §4.6 | /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md（§Rule 50 设计契约） |
| S2 | §1 + §2 + §4.4 | /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md（Rule 50 设计契约 + 执行范围限制） |
| S3 | §2 + §3 + §4.6 | /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md（泪痣样例表） |
| S4 | §2 + §3 | /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md（Rule 50 设计契约） |
| S5 | §3 + §4.5 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-media-dispatch.sh（范式） |
| S6 | §2 + §4.3 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-plan-tier.sh |
| S7 | §2 + §4.3 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-conclusion-discipline.sh |
| S8 | §2 + §3 | /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md（Phase 1 基线） |
| S9 | §2 + §4.8 | /mnt/data/dev/task-planner-skill/plans/task-v127/verification.md |
