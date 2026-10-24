# Knowledge Brief — {task-id}（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/<task-id>/knowledge-brief.md 后即按 §1-§5 填写；
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
- 任务一句话：init-session.sh 内建变量渲染层（render_template），init 产物机械占位符由脚本直接替换真实值，模型只填语义内容。
- 背景/动机：用户投诉模板 ID/日期/路径靠模型自主识别修正——慢、不稳定、需路径检索；脚本传参最稳定准确高效。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| {{VAR}} token | 渲染层主形态：{{TASK_ID}}/{{TASK_NAME}}/{{DATE}}/{{DATETIME}}/{{TASK_PLANNER_ROOT}}/{{PLAN_DIR}} 六变量，init 时 sed 替换 |
| 兼容映射 | 8 种旧形态（{task-id}/<task-id>/<task>/{task-name}/[Brief Description]/[DATE]/[YYYY-MM-DD HH:MM]/${TASK_PLANNER_ROOT:-…}）由渲染层直接替换，variant 29 文件零文本迁移 |
| 语义占位 | 模型填写面：尖括号中文（<用户原话>）/#N 序号/[Title]/<按需增行> 等——脚本禁碰，边界=ASCII token/日期形态/尖括号纯 ASCII=脚本渲染 |
| fail-closed | 非注释行残留 {{大写}} token → init exit 1 列 token 名；HTML 注释区间豁免（契约注释 {{VAR}} 示例合法） |
| _created_this_round | 本轮新建文件列表（BLOCKER-1 修复产物）：渲染只遍历新建文件，重复 init 对既有文件零触碰保 append-only |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| init 复制模板为纯 cp 零替换、$1 只进 echo、DATE 定义未用 | subagent-state/01-explore-init-mechanism.md（调查②，init-session.sh:83-97,395,479） | 渲染层动机与接线点选择的事实底座 |
| 实际任务名变量=PROJECT_NAME 非 TASK_NAME | init-session.sh:395（S3 实测） | 渲染层取值来源；后续改脚本勿用错变量名 |
| sed 转义顺序 \→&→\| | init-session.sh:99-112（_sed_escape_repl） | 值含特殊字符安全替换的关键 |
| 渲染收窄=_created_this_round 列表 | init-session.sh:761-843 四入列点+渲染循环（CR-fix） | 重复 init 零触碰既有文件；新增创建点必须显式入列 |
| selftest 全量基线 93 脚本 | run-selftests.sh 输出（2026-10-24 多轮） | 回归对照基线；suite 数=93 不因新增断言行变化 |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/init-session.sh | :99-260 | 渲染层：_sed_escape_repl/_strip_html_comments/render_template（6 变量+8 映射+残留校验） |
| skills/task-planner/scripts/init-session.sh | :961-1032 | 接线段：_created_this_round 遍历渲染+fail-closed exit 1 |
| skills/task-planner/templates/task_plan.md | 全文 | token 化范本（{{VAR}} ×12+契约注释+语义占位保留形态） |
| skills/task-planner/SKILL.md | :40-41 | 初始化段渲染契约指示面 |
| skills/task-planner/scripts/selftest-session-log.sh | SL-12 段 | 二次 init append-only 回归护栏断言 |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁止模型手工修正产物中的机械占位符（渲染层已脚本化；手改=绕过 fail-closed 防线）——SKILL.md:41 契约
2. 派发契约中的文档示例文本须与机器校验正则互斥设计（判例：契约注释 {{VAR}} 触发残留校验致 7 模板全 fail，三子代理独立上报；修复=注释区间豁免）
3. 禁止硬编码行号进注释（判例：NIT-2 L694 漂移）——用函数名/段描述引用
4. 渲染循环禁 `for *.md` 全目录遍历（BLOCKER-1 判例：重复 init 改写 append-only 记录）——只遍历 _created_this_round
5. FMEA RPN>100 兜底指针：Phase 3「盘点遗漏」→ 残留校验 fail-closed 机器兜底+S1 边界清单（task_plan.md FMEA 表）；已按此走通（实测 S14 残留计数=0）
- FMEA RPN>100 兜底指针：{→ task_plan.md FMEA 表「{Phase} {失败模式}」行}

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| {示例：S1} | §1 + §2 + §3 | /abs/path/to/material.md |
| {示例：S2 设计任务} | §2(基线) + §3(锚点) | plans/.rule-reservations.jsonl + <审计台账 align-audit 路径>（台账产物路径，替代 prompt 内联基线） |
| {S-unit ID} | {§x} | {路径} |
<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| {示例：brainstorming} | ~/.agents/skills/brainstorming/SKILL.md | {本任务画像中哪一点命中该技能} | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| {示例：comet} | ~/.zcode/skills/comet/SKILL.md | {匹配点} | 用户手动触发（仅提示） |
| {技能名} | {SKILL.md 绝对路径} | {匹配点} | {激活方式} |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/<task-id>>` → 生成 knowledge/entries/_draft-<task-id>.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

