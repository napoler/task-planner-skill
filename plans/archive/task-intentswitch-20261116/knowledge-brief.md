# Knowledge Brief — task-intentswitch-20261116（任务知识简略要点）
<!--
  计划期产出，执行期持续回填。执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识。
  与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）。
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：增强 task-planner 在会话内识别 A→B 无关需求并主动「挂起 A、切换到 B 计划」的显性度与可审计性（增强既有机制，非新建）。
- 背景/动机：既有 Rule 8.1/94/102/E 类与 plan-resume/drift 防线已在位，但用户实感「不明显」；需让切换及时触发、会话面可感知、事后可追溯（R1，user-session-log.md#1）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 意图切换（A→B） | 会话执行计划 A 时用户提出与 A 无关的新需求 B，应挂起 A、激活新计划执行 B 实现隔离（user-session-log.md#1） |
| D 类 新任务边界 | 与当前计划 Goal/范围/交付物均无关联→开新计划 init、旧计划原样保留、禁混入（skills/task-planner/SKILL.md:194；discipline:21） |
| E 类 目标切换 | 命中可判定换目标三判→禁止自行归类执行，须复述+用户显式 yes 后按 Rule 94 处置（skills/task-planner/SKILL.md:201；discipline:23） |
| Rule 94 计划隔离 | 跨计划级重大偏差时主动询问拆分并隔离：旧封存待 resume/新独立 init/禁交叉写入（discipline:607-618） |
| Rule 102 反思门 | 新指令先五问判定+ B/C/D/E 先落盘后执行，含对照 user-session-log 既有原话 80.8②（discipline:695-706） |
| drift-checker 安全网 | 执行偏移/目标漂移拦截子代理（ALIGNED/DRIFT/BLOCKED），64.2.1/64.7 防 Goal∩专档原话零交集自证；非意图切换发起器（drift-guard:8-68） |
| 显性通告/切换登记（增强目标） | 切换时会话面输出挂起计划/触发#N/新计划/下一步，且落最小字段留痕（findings R-3/R-5,S-A） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| SKILL.md 已有单入口收口序列 ①落盘专档→②D/A/B/C/E 判定→③文档同步→④Todo S5→⑤103.6，D 类表与 E 类确认门已定义 | skills/task-planner/SKILL.md:190,194,201 | 增强应在该入口增补快速判定卡/显性通告/切换登记指引，不另起平行流程（R-2） |
| Rule 8.1/8.1.1 规定 D 先于 A/B/C、三要素均无关联开新计划且旧计划保留，目标切换三判命中须先确认 | skills/task-discipline/references/critical-rules-discipline.md:21,23 | S-A 入口卡片必须复用“三要素对照+三判”语义，避免弱化既有判定权威 |
| Rule 94 规定重大偏差主动询问拆分、隔离处置（封存待 resume/独立 init/禁交叉写入）与 silent 默认隔离登记 | skills/task-discipline/references/critical-rules-discipline.md:607-618（:614-615） | 需补会话面显性通告模板并与 94.3/94.4 对齐；交叉锚收敛不改权威语义（R-2/R-3） |
| Rule 102 规定反思门五问含对照 user-session-log 既有原话(80.8②)、B/C/D/E 先落盘后执行及落盘自检行 | skills/task-discipline/references/critical-rules-discipline.md:695-706（:700,703） | 快速锚句与登记需保留 102.0/102.2 约束，不得把“先落盘后执行”弱化为口头提示 |
| UPS hook 默认 [plan-note] 已含反思门/D 类/断点检查点/专档对照，但无快速“Goal/范围/交付物↔最新专档原话”锚句与显性通告/登记字段 | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:283,285,287 | S2 重写 :287 note：前置可扫描锚句，保留 Rule 102.0/80.8②/8.1 关键约束（VC-4） |
| drift-checker 为执行偏移检测；64.2.1/64.4/64.7 提供目标漂移零交集拦截与四锚（含用户原话对照锚），属安全网非切换发起器 | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:8-68；skills/task-planner/SKILL.md:122 | VC-5：仅补边界说明，严禁改 64.2.1/64.7 判定语义与关键锚 |
| 机制全景/诊断结论：H1/H2/H4/H6 verified，H3/H5 partially verified；根因 R-1~R-5；推荐 S-A 最小增强、S-B 备选 | plans/task-intentswitch-20261116/findings.md（机制全景表 M1-M15、H1-H6、Technical Decisions） | 执行期按 S-A 落地；交付需如实披露仍为 LLM 行为门强化（非100%机器强制） |
| 冲突扫描 risk（①未提交22/⑤基础设施5/③遗留wt分支1/④未完成12）→ 必须 worktree 隔离 | `bash /home/terry/.zcode/skills/task-planner/scripts/check-conflicts.sh`（2026-11-16，exit 0） | 实现期在 tmp/worktrees/task-intentswitch-20261116（wt/task-intentswitch-20261116）进行 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/SKILL.md | :122 | [DRIFT CHECK]：用户新指令先过「用户新指令处理」判定再派 drift-checker；S4 边界说明邻近点 |
| skills/task-planner/SKILL.md | :188-201 | 新指令处理单入口（收口序列、D/A/B/C 表、判定顺序、E 类+按94）；S1 主修改面 |
| skills/task-discipline/references/critical-rules-discipline.md | :18-23 | Rule 8/8.1/8.1.1：D 类判定与 E 类三判确认门（权威语义） |
| skills/task-discipline/references/critical-rules-discipline.md | :607-618 | Rule 94：单计划单域、偏差判据、询问拆分、隔离处置；S3 交叉锚候选 |
| skills/task-discipline/references/critical-rules-discipline.md | :695-706 | Rule 102：反思门五问、五类判定、先落盘后执行/自检行、hook 机制；S3 交叉锚候选 |
| /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md | :8-47 | Rule 11/15/61：drift-checker 执行偏移检测载体与三态契约 |
| /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md | :51-68 | Rule 64：三件套/门控/64.2.1 目标漂移不可豁免/64.4 四锚/64.7 零交集禁 ALIGNED（勿改） |
| /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh | :283-287 | [plan-note] 逐 prompt 提示三分支（E/邻近B/默认反思门）；S2 修改 :287 |
| plans/task-intentswitch-20261116/user-session-log.md | #1 | R1 原话逐字锚与理解镜像（意图切换对照基准） |
| plans/task-intentswitch-20261116/findings.md | 全文 | 机制全景 M1-M15、H1-H6、R-1~R-5、S-A/S-B 方案与证据 |
| plans/task-intentswitch-20261116/task_plan.md | 全文 | Goal/R→VC/Phases+S-unit/CA-1~CA-4/FMEA/隔离决策（执行契约） |

## §4 易错点与禁止假设清单
1. **禁止改 drift-checker 判定语义**：64.2.1/64.7/四锚与 ALIGNED/DRIFT/BLOCKED 逻辑不动；只补“安全网非发起器”边界说明（H4, VC-5）。
2. **禁止复制 94/102 全流程造成第二事实源**：SKILL.md 做单入口显性化，Rule 94/102 仅增交叉锚/一致性提示，权威细则保留（R-2, VC-3）。
3. **禁止弱化既有关键约束**：hook 压缩后必须保留 Rule 102.0、80.8② 专档对照、Rule 8.1 不混入计划等关键语义/引用（H5, VC-4）。
4. **禁止假设 E 类三判覆盖所有 A→B 场景**：纯语义无关未命中三判形式仍可为 D 类，快速判定卡需兜底并显性通告（H3）。
5. **禁止主仓裸改 skills/** 与 hook 部署位无约束扩写：实现走 worktree；hook 改动最小化且限 :287 分支语义增强。
6. **禁止虚构“已机器强制”**：S-A 为 LLM 行为门+提示强化，未获授权不新增脚本/config 键，交付如实披露残余风险（R-1）。
- FMEA RPN>100 兜底指针：→ task_plan.md「📊 FMEA 预演」Phase 2「多处文案修改引入语义漂移」(RPN 200) 与「hook 措辞压缩丢失关键约束」(RPN 128)。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P0（Phase 1,已完成） | §1 + §2 + §3 | plans/task-intentswitch-20261116/findings.md；plans/task-intentswitch-20261116/user-session-log.md#1 |
| S1（Phase 2） | §1 + §2(M1-M4,M7,M8,M15) + §3(SKILL.md:188-201) + §4(2,4) | skills/task-planner/SKILL.md:188-201；plans/task-intentswitch-20261116/findings.md（R-1~R-3,R-5,S-A） |
| S2（Phase 2） | §2(M13,VC-4事实) + §3(zcode-userpromptsubmit.sh:283-287) + §4(3) | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:287；plans/task-intentswitch-20261116/findings.md（H5,R-1） |
| S3（Phase 2） | §2(M7,M8) + §3(critical-rules-discipline.md:607-618,695-706) + §4(2) | skills/task-discipline/references/critical-rules-discipline.md:614-615,700-703；plans/task-intentswitch-20261116/findings.md（R-2） |
| S4（Phase 2） | §2(M9,M10,M11,VC-5事实) + §3(SKILL.md:122; drift-guard:51-68) + §4(1) | skills/task-planner/SKILL.md:122；/home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:59,68；plans/task-intentswitch-20261116/findings.md（R-4,H4） |
| S1（Phase 3） | §2(VC-2~VC-6对应事实) + §4(1-6) | plans/task-intentswitch-20261116/verification.md；plans/task-intentswitch-20261116/task_plan.md（CA-1~CA-4,FMEA） |
| S2（Phase 3） | §2(冲突/范围事实) + §4(2,5) | plans/task-intentswitch-20261116/task_plan.md（隔离决策、scope_files）；git diff --name-only 证据（执行期产出） |
| S1（Phase 4） | §1 + §2 + §4(6) | plans/task-intentswitch-20261116/verification.md；plans/task-intentswitch-20261116/progress.md（VC/CR 证据汇总） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | /home/terry/.zcode/skills/task-planner/SKILL.md | 本任务直接增强 task-planner 意图切换入口与流程显性度 | 主进程按规划流程执行；子代理按派发模板挂载约束 |
| plan-resume | /home/terry/.zcode/skills/plan-resume/SKILL.md | 切换后旧计划封存/恢复语义对齐（M12, Rule 94.4） | 子代理/主进程按需 Read 参考（非代执行） |
| task-drift-guard | /home/terry/.zcode/skills/task-drift-guard/SKILL.md | drift-checker 边界与 64.x 安全网语义核对（R-4/H4） | 参考与验收对照；执行期按 Rule 61 派发检测 |
| code-quality-review | /home/terry/.zcode/skills/code-quality-review/SKILL.md | hook/规则文档改动质量与回归审查 | Phase 3/4 子代理按需激活 |
| documentation-review | /home/terry/.zcode/skills/documentation-review/SKILL.md | SKILL.md 与规则文案显性、一致性、交叉锚审查 | Phase 3/4 子代理按需激活 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/task-intentswitch-20261116>` → 生成 knowledge/entries/_draft-task-intentswitch-20261116.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md