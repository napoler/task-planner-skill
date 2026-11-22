# Knowledge Brief — task-cli-help-examples-20261122（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-cli-help-examples-20261122/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-cli-help-examples-20261122/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

<!-- 填写说明：一句话说明本任务做什么 + 为什么做（≤2 行）；下方术语表每条 ≤1 行，只收录「不解释会读不懂后续 S-unit 材料包」的术语 -->
## §1 任务速览与核心概念
- 任务一句话：给两个 CLI（template-catalog.sh / planctl.py）的 help 与 Skill 文档补齐可照抄示例，让用户不再因用法不清反复试错。
- 背景/动机：用户投诉"脚本使用来回错误、反复修正"；两脚本 help 无示例、两文档无端到端示例是直接原因。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| epilog | argparse 帮助末尾原文块，配 RawDescriptionHelpFormatter 可放多行可照抄示例 |
| 四件套 | 命令选择决策表 + 端到端示例 + 正反例 + 常见误用（对症"选错命令/记错参数"） |
| 四部署位 | ~/.zcode / ~/.agents / ~/.claude / ~/.cursor 的 task-planner，与源仓 md5 全一致的四个一致副本 |
| worktree | git 隔离开发区，Skill 保护区改动必须在其中开发（§十一） |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| template-catalog.sh 主 parser 无 epilog/formatter，子命令无示例；头注释已有可复用 Usage/契约/exit code | Explore 5e87503c；源 :307-349 | P2 在 argparse 构造处加 epilog+formatter，复用头注释文案 |
| planctl.py 主 parser 已有 RawDescriptionHelpFormatter，但 epilog 仅一行；add_cmd 不传 formatter；19 子命令无示例 | Explore 5e87503c；源 :1861-1954 | P2 扩 add_cmd 透传 formatter+epilog，补关键子命令示例 |
| SKILL.md 用法散落无端到端示例/正反例/决策表；examples.md 仅两条 phase-done+render | Explore d934b87f | P3 落点 SKILL.md L47-51/L310-328 + examples.md |
| 13 处 SKILL.md 副本仅源仓+4 部署位三文件 md5 全一致，其余为 stub/归档快照 | Explore d934b87f | P5 只同步四位，opencode stub 不动 |
| selftest 基线 104 脚本 FAIL=8（FAIL 集见 VC-6） | critic 审计实跑 | VC-6 用 FAIL 集差集，非数字 |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/template-catalog.sh | :307-349 | build_parser + 分发；epilog/formatter 插入点 |
| skills/task-planner/scripts/planctl.py | :1861-1971 | 根 parser + add_cmd + 19 子命令注册；epilog/formatter 插入点 |
| skills/task-planner/SKILL.md | :47-51 | 模板检索与管理段（template-catalog 四件套落点 A） |
| skills/task-planner/SKILL.md | :310-328 | 结构化状态操作 SOP（planctl 四件套落点 B） |
| skills/task-planner/examples.md | :1-46 | 现有示例偏叙事，仅两条 phase-done+render |

> 以上行号=勘察日快照（2026-11-22），实施日以盘上实际 grep 重验为准，禁盲用旧行号。

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁止改两个脚本的 handler/业务逻辑——只动 argparse epilog/formatter/help 文案（VC-7 核 diff 无控制流改动）。
2. 禁止凭记忆写示例 flag——逐条对照 --help 真实参数（VC-4 做合法 flag 差集）。
3. 示例命令必须可在 worktree 实跑，禁止虚构子命令/参数；template-catalog 是 bash 内嵌 python argparse，不是纯 bash。
4. 部署只同步四个一致位，禁碰 opencode stub / 归档 / 其他 worktree 副本（D1）。
- FMEA RPN>100 兜底指针：本任务三条 FMEA RPN 均 ≤72，无 >100 项；最高风险 FMEA-2（示例含虚构 flag，RPN 72）兜底=逐条对照 argparse + VC-4 差集。

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §2 | （已完成，勘察报告见 plan-state research 段） |
| S2 | §2 + §3 + §4 | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner/scripts/template-catalog.sh |
| S3 | §2 + §3 + §4 | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner/scripts/planctl.py |
| S4 | §1 + §3 + §4 | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner/SKILL.md |
| S5 | §1 + §3 + §4 | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-cli-help-examples-20261122/skills/task-planner/examples.md |
| S6 | §2 + §4 | （VC 命令见 verification.md） |
| S7 | §2 | （D1 决策 + VC-5） |
<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| writing-skills | ~/.agents/skills/writing-skills/SKILL.md | 改 skill 文档示例、评测触发精度 | 子代理 prompt 提示（辅助，非强制） |
| verification-before-completion | ~/.zcode/skills/verification-before-completion/SKILL.md | 终验交付前证据驱动完成检查 | 主进程 Skill 调用（终验） |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-cli-help-examples-20261122>` → 生成 knowledge/entries/_draft-task-cli-help-examples-20261122.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

