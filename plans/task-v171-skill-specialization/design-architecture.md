# design-architecture.md — task-planner 技能专业化拆分架构设计

> 任务：task-v171-skill-specialization | 分支：wt/task-v171-skill-specialization（from master 618df79）
> 本文档是 Phase 4-7 的唯一执行依据。所有行号以 critical-rules.md@wt/task-v171 实测为准。
> 规则标题混合格式：`### N 标题`（Rule 1-75 主体）与 `## Rule N（标题 — task-vXXX）`（Rule 70/72/76/80）——提取 key off 规则编号，禁 key off 行序（文件顺序非数字序，实证：Rule 59@774 在 Rule 62@756 之后）。

## §1 规则→归属全映射表（76 既有正文规则 + Rule 80 空壳 + Rule 82 新写）

源文件：`skills/task-planner/references/critical-rules.md`（1046+ 行）
行区间=起-止（止=下一条起始-1；末条 Rule 80 空壳至文件尾）

### 核心保留（11 条，原位不动）
| 编号 | 标题 | 源行区间 | 目标文件 |
|------|------|---------|---------|
| 1 | 先规划，再执行 | 5-7 | skills/task-planner/references/critical-rules.md（原位） |
| 2 | PreToolUse 强制阻断 | 8-10 | 同上 |
| 3 | 双操作后立即保存 | 11-13 | 同上 |
| 5 | Phase 完成后更新 | 17-19 | 同上 |
| 19 | 3-File 落盘强制 | 109-120 | 同上 |
| 20 | 计划注入与防篡改 | 121-141 | 同上 |
| 26 | 质量优先于速度门控 | 245-274 | 同上 |
| 51 | 需求覆盖与完成声称门控 | 590-603 | 同上 |
| 62 | 四文件罗盘数据流转与调研知识沉淀纪律 | 756-773 | 同上 |
| 66 | goal 单元固化与 /goal 驱动推进纪律 | 862-875 | 同上 |
| 82 | 技能专业化分层纪律（新写） | 新写段 | 同上（P7 S34 写入） |

### task-dispatch（11 条）→ skills/task-dispatch/references/critical-rules-dispatch.md
| 编号 | 标题 | 源行区间 |
|------|------|---------|
| 12 | 冲突即隔离（工作树默认首选） | 48-50 |
| 13 | 子代理隔离强制（P0） | 51-53 |
| 14 | 代码编辑必须派子代理（P0） | 54-56 |
| 21 | 子任务拆分与模型分工 | 142-171 |
| 22 | 子代理规模限制与交接文件 | 172-203 |
| 23 | 并行任务检测与冲突规避 | 204-221 |
| 25 | 子代理委派门控 | 234-244 |
| 46 | 子代理单任务专注度 | 519-528 |
| 52 | 执行体专业化优先与覆盖矩阵维护 | 604-615 |
| 59 | 子代理拆分粒度硬门与技能伴飞纪律 | 774-795 |
| 68 | 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律 | 892-906 |

### task-discipline（36 条）→ skills/task-discipline/references/critical-rules-discipline.md
| 编号 | 标题 | 源行区间 |
|------|------|---------|
| 4 | 决策前重读计划 | 14-16 |
| 6 | 记全部错误 | 20-22 |
| 7 | 永不重复失败 | 23-25 |
| 8 | 新请求强制重新规划（三分类判定） | 26-30 |
| 9 | 错误提前暴露 | 31-33 |
| 10 | Scope 变更必重规划 | 34-36 |
| 18 | 批量处理质量门控 | 92-108 |
| 27 | 工作产物及时提交 | 275-285 |
| 28 | 交互模式与询问门控 | 286-296 |
| 29 | 上下文与工作文件主动维护 | 297-307 |
| 31 | 错误学习闭环 | 318-329 |
| 32 | 用户否决与禁令追踪 | 330-339 |
| 33 | 解决→反思→验证迭代循环 | 340-350 |
| 35 | 执行结论纪律 | 363-372 |
| 36 | 技能修改保守化与功能删除防护 | 373-385 |
| 41 | 问题自主消解与升级纪律 | 446-457 |
| 42 | 质量审查技能主动检测与补充 | 458-477 |
| 43 | 执行可靠性制度化 | 478-488 |
| 44 | 用户选择点默认项与自动超时裁决 | 489-498 |
| 45 | 注释完整性规范 | 499-518 |
| 48 | 交付总结可定位性与实用性 | 541-550 |
| 53 | 根源解决与决策管辖 | 616-623 |
| 54 | 执行诚实性与即时执行纪律 | 624-641 |
| 55 | 可复用能力落盘纪律 | 642-652 |
| 56 | 用户指令优先与自动执行 | 653-670 |
| 57 | 迭代测试轮次落盘纪律 | 671-684 |
| 60 | 主动解决问题 | 707-742 |
| 65 | 周期性回顾与前后对照 | 831-861 |
| 67 | 上下文压力主动评估与会话交接纪律 | 876-891 |
| 69 | 判断裁决子代理化与驳回打回纪律 | 907-917 |
| 70 | 用户呈报可审批性纪律 | 918-944 |
| 71 | 无源不写·空段占位·写必带锚纪律 | 945-960 |
| 72 | 决策分级与用户打断纪律 | 961-986 |
| 73 | 执行期决策对齐与不变量纪律 | 987-1002 |
| 74 | 变更吸收三判纪律 | 1003-1011 |
| 76 | 总结阶段格式可读性与审查清单实体化纪律 | 1032-1047 |

### media-planner（3 条）→ skills/media-planner/references/critical-rules-media.md
| 编号 | 标题 | 源行区间 |
|------|------|---------|
| 47 | 媒体制作任务派发纪律 | 529-540 |
| 49 | 单元线多路并行推进 | 551-566 |
| 50 | 内容要求权重分级与评级 | 567-589 |

### 七卫星收编（16 条）
| 卫星 | 收编规则 | 源行区间 | 目标文件 |
|------|---------|---------|---------|
| plan-research-router | 58, 63, 75 | 58@685-706, 63@796-812, 75@1012-1031 | skills/plan-research-router/references/critical-rules-research.md |
| plan-template-kit | 16, 34, 37, 38 | 16@76-79, 34@351-362, 37@386-397, 38@398-410 | skills/plan-template-kit/references/critical-rules-template.md |
| plan-collab-router | 39, 40 | 39@411-434, 40@435-445 | skills/plan-collab-router/references/critical-rules-collab.md |
| plan-cost-guard | 17 | 17@80-91 | skills/plan-cost-guard/references/critical-rules-cost.md |
| plan-resume | 24 | 24@222-233 | skills/plan-resume/references/critical-rules-resume.md |
| progress-tracker | 30 | 30@308-317 | skills/progress-tracker/references/critical-rules-progress.md |
| task-drift-guard | 11, 15, 61, 64 | 11@37-47, 15@57-75, 61@743-755, 64@813-830 | skills/task-drift-guard/references/critical-rules-drift.md |

### 空壳与新增
| 编号 | 标题 | 源行 | 处置 |
|------|------|------|------|
| 80 | 用户会话逐字记录与只写不改纪律（空壳，无正文，v169 历史预留） | 1048-文件尾 | **删除**（§5 删除基线 D-01：空壳无正文，删除无功能损失；Rule 77-79/81 同为预留号无标题无正文） |
| 82 | 技能专业化分层纪律 | 新写 | 新增（P7 S34） |

## §2 三个新卫星规格

### task-dispatch（子代理派发与拆分调度）
- **定位**：管「计划如何被拆分、派发、校验、调度」——子代理全生命周期的机器门控与执行纪律。
- **域边界**：管=拆分粒度/派发契约/返回校验/并行调度/专注度/执行体选型/冲突隔离/代码编辑派子代理/依赖分析；不管=四文件内容本身（核心）、执行诚实/错误闭环等通用纪律（task-discipline）、媒体制作（media-planner）。
- **frontmatter**：`name: task-dispatch`；description 触发词=子代理派发/拆分/并行调度/粒度门/伴飞/返回校验/执行体选型。
- **路由索引格式**（核心 critical-rules 重构后引用）：
  ```
  ## 卫星路由：task-dispatch
  域=子代理派发与拆分调度。规则全文见 skills/task-dispatch/references/critical-rules-dispatch.md（Rule 12,13,14,21,22,23,25,46,52,59,68）。
  调用条件：涉及子代理拆分/派发/并行/粒度校验时 Read 该文件。
  ```
- **目录结构**：`SKILL.md` + `references/critical-rules-dispatch.md` + `scripts/`（6 个：4 迁入 analyze-splits/check-subagent-return/check-rescue-chain/subagent-fallback + 2 随迁 selftest-rescue-chain/selftest-fallback）+ `references/`（3 个迁入 md）。

### task-discipline（执行纪律与工作产物维护）
- **定位**：管「执行过程的纪律与工作产物」——错误闭环/证据/调研/模板/反思/可靠性/能力沉淀/卫生/交互/超时/注释/来源锚/变更吸收等通用执行纪律。
- **域边界**：管=除四文件数据流转（核心 Rule 62）与派发调度（task-dispatch）之外的所有执行期纪律；不管=四文件内容、派发机制、媒体制作。
- **frontmatter**：`name: task-discipline`；description 触发词=执行纪律/错误闭环/证据面/调研/模板/反思/可靠性/能力沉淀/卫生/交互/超时/注释/来源锚/变更吸收/工作产物。
- **路由索引格式**：同 task-dispatch 格式，规则清单=36 编号。
- **目录结构**：`SKILL.md` + `references/critical-rules-discipline.md` + `scripts/`（plan-hygiene.sh+capabilities/）+ `references/`（batch-quality-gate.md+capability-registry.md）。

### media-planner（媒体制作任务派发）
- **定位**：管「媒体制作类任务的拆分轴与执行体路由」——视频/图片/剧集创作类任务的媒体轴精细拆分。
- **域边界**：管=媒体任务派发/单元线并行/内容要求权重分级；不管=通用派发机制（task-dispatch）、通用纪律（task-discipline）。
- **frontmatter**：`name: media-planner`；description 触发词=媒体制作/视频生成/图片生成/剧集创作/单元线并行/内容要求分级。
- **路由索引格式**：同上，规则清单=47,49,50。
- **目录结构**：`SKILL.md` + `references/critical-rules-media.md`。

## §3 七个卫星收编规格

每个卫星统一三动作（原子配对，拆开产生规则悬空）：
1. **落盘**：该卫星 `references/critical-rules-<域>.md` 写入收编规则全文（标题+正文逐字，标题格式统一为 `### N 标题`）
2. **删除**：核心 critical-rules.md 对应文本删除
3. **索引**：该卫星 SKILL.md 追加路由段（域+规则编号清单+调用条件）

| 卫星 | 收编规则 | 目标文件 | SKILL.md 索引行 |
|------|---------|---------|----------------|
| plan-research-router | 58,63,75 | references/critical-rules-research.md | `## 卫星路由：plan-research-router — 域=调研分析与证据纪律（Rule 58,63,75）` |
| plan-template-kit | 16,34,37,38 | references/critical-rules-template.md | `## 卫星路由：plan-template-kit — 域=模板生命周期与难度分级（Rule 16,34,37,38）` |
| plan-collab-router | 39,40 | references/critical-rules-collab.md | `## 卫星路由：plan-collab-router — 域=技能协同与工具面选择（Rule 39,40）` |
| plan-cost-guard | 17 | references/critical-rules-cost.md | `## 卫星路由：plan-cost-guard — 域=成本控制（Rule 17）` |
| plan-resume | 24 | references/critical-rules-resume.md | `## 卫星路由：plan-resume — 域=计划续推（Rule 24）` |
| progress-tracker | 30 | references/critical-rules-progress.md | `## 卫星路由：progress-tracker — 域=共享内容认领（Rule 30）` |
| task-drift-guard | 11,15,61,64 | references/critical-rules-drift.md | `## 卫星路由：task-drift-guard — 域=漂移检测与偏移留痕（Rule 11,15,61,64）` |

## §4 caller 更新清单（7 项，全部实测）

| # | 文件:行 | 旧内容 | 新内容 | 验证 |
|---|---------|--------|--------|------|
| C1 | skills/task-planner/scripts/check-complete.sh:632 | `crc="$SKILL_ROOT/scripts/check-rescue-chain.sh"` | `crc="$SKILL_ROOT/../task-dispatch/scripts/check-rescue-chain.sh"` | `grep -c 'task-dispatch/scripts/check-rescue-chain' check-complete.sh` =1 且旧路径 grep=0 |
| C2 | skills/task-planner/install.sh:195,198,199 | `"$TASK_PLANNER_ROOT/scripts/subagent-fallback.sh"`（3 处） | `"$TASK_PLANNER_ROOT/../task-dispatch/scripts/subagent-fallback.sh"` | 同上模式 grep 旧路径=0 |
| C3 | skills/task-planner/lib/verify.sh:240-243 | `scripts/subagent-fallback.sh` 路径引用 | `../task-dispatch/scripts/subagent-fallback.sh` | grep 旧路径=0 |
| C4 | skills/task-planner/scripts/selftest-context-hygiene.sh:27 | `HYG="$SCRIPT_DIR/plan-hygiene.sh"` | `HYG="$SCRIPT_DIR/../task-discipline/scripts/plan-hygiene.sh"`（T07-T09 断言文本同步） | 该 selftest 跑通 T07-T09 |
| C5 | skills/task-planner/scripts/selftest-subagent-granularity-skill-escort.sh:55 | `ASPL="$SCRIPT_DIR/analyze-splits.sh"` | `ASPL="$SCRIPT_DIR/../task-dispatch/scripts/analyze-splits.sh"`（SG-20 断言文本同步） | SG-20 断言改指后跑通 |
| C6 | skills/task-planner/scripts/selftest-subagent-return.sh:9 | `RS="$SCRIPT_DIR/check-subagent-return.sh"` | `RS="$SCRIPT_DIR/../task-dispatch/scripts/check-subagent-return.sh"` | 该 selftest 跑通 |
| C7 | skills/task-planner/scripts/selftest-skill-collab.sh:14 | `FALLBACK="$SCRIPT_DIR/subagent-fallback.sh"` | `FALLBACK="$SCRIPT_DIR/../task-dispatch/scripts/subagent-fallback.sh"`（T6 断言文本同步） | T6 跑通 |

**SKILL.md 提及更新**（随 P7 S33 整体重写自然消解，登记备查）：:94 plan-hygiene、:324 check-subagent-return、:362 analyze-splits、:523 subagent-fallback。

**config.json 描述串**（:139/:148/:251/:257/:267 含脚本名描述）：纯描述性字符串非路径引用，不动（selftest 不断言描述串内容，实证 grep 无断言）。

## §5 删除基线（Rule 36.3）

### 核心 critical-rules.md 将删除的 65 条规则编号（76-11=65）
```
4,6,7,8,9,10,11,12,13,14,15,16,17,18,21,22,23,24,25,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,52,53,54,55,56,57,58,59,60,61,63,64,65,67,68,69,70,71,72,73,74,75,76
```
（65 个编号；Rule 59@774 在 Rule 62@756 之后——删除按编号定位禁按行序）

### 空壳删除
- D-01：Rule 80 空壳标题（1048-文件尾，无正文）——删除无功能损失。

### 删除后验证（grep 零残留）
```bash
cd skills/task-planner/references
for n in 4 6 7 8 9 10 11 12 13 14 15 16 17 18 21 22 23 24 25 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 52 53 54 55 56 57 58 59 60 61 63 64 65 67 68 69 70 71 72 73 74 75 76 80; do
  grep -nE "^(### $n |## Rule $n（)" critical-rules.md && echo "RESIDUE: $n"
done
# 期望输出：无 RESIDUE 行
```

### 核心保留 11 条+新增
保留：1,2,3,5,19,20,26,51,62,66（原位）；新增：82（P7 S34 写入）。

## §6 边界案例与机器契约

### 混合标题格式
`### N 标题`（Rule 1-75 主体，75 条中 72 条）与 `## Rule N（标题 — task-vXXX）`（Rule 70/72/76/80，4 条）。提取/迁移工具一律 `grep -nE '^(### N |## Rule N（)'` key off 编号；**禁 awk 区间正则**（mawk 不支持 {2,4} 表达式，实证事故见 task_plan Errors Encountered）。

### check-plan-dispatch.sh 机器契约（计划期硬门）
- 时长列：`^[0-9]+min$` 纯 NNmin（模板示例「≤15min」不合规，会 SKIPPED）
- 粒度三值：`^([0-9]+)f/([0-9]+)l/([0-9]+)min$`，任一超 step_max（2f/100l/15min）→ add_violation **拒锁**
- 例外登记：整行含「例外登记」子串 → 超限降级 SKIPPED 放行（task-v144 先例）
- 输入列：路径 token>2 仅 SKIPPED 提示不阻断
- ID 列：纯数字（S2a 式拒锁）；前置依赖列必填（无则 -）

### BP-08 行数钉演进
selftest-batch-pilot.sh:11,53 当前钉 `SKILL.md 行数 ≤558`。P7 S33 重写后 SKILL.md≤250 行 → S38 演进钉值至 **275**（≤250+25 边距，先例=v168 实值+25 口径）。

### rule-range 纪元锚扩
selftest 中规则编号宽容正则（如 `1-7[0-4]` 形态）需扩至覆盖 1-77（76 既有+82）。S38 同步。

### install-stub.sh 注册
:36 `SATELLITE_SKILLS=(plan-research-router plan-template-kit plan-cost-guard plan-collab-router)` → 追加 `task-dispatch task-discipline media-planner`（P7 S39）。install_satellite_skills()@:244 自动 rsync 到 4 部署位。

### attest 门（计划锁定）
- 四锚：`^## 🎯 用户需求原文`、R 行 `**R1**`、`^#{2,3}.*R→VC 映射`、`^##[^#].*根源覆盖表`
- FMEA 门：段标题「FMEA 预演」+数据行≥1+RPN>100 行兜底列非空
- template-gate：`<!-- template_type: migration -->` 注释形态（已锁定）
- rule-reserve：new_rule 单元格纯数字 `82`（已登记持有）

### 跨技能相对路径模式
caller 更新统一 `$SKILL_ROOT/../<归属>/scripts/` 模式（先例：selftest-drift-check-subagent.sh:17 `SATELLITE_SKILL="$SKILL_ROOT/../task-drift-guard/SKILL.md"`）。

### 文件顺序非数字序实证
Rule 59@774 在 Rule 62@756 之后；Rule 68@892 在 Rule 69@907 之前。任何批量处理 key off 编号，禁按行号顺序假设编号顺序。

## §7 selftest 锚修复批清单（S35-S37 执行依据）

56 个 selftest 引用 critical-rules.md（`CRIT="$SKILL_ROOT/references/critical-rules.md"`），核心重构后这些断言将 FAIL。修复分 3 批，按「该 selftest 引用的移动 rule 号落集」归类（python 交叉统计实测）：

### 批1（P7 S35）：task-discipline 关联断言集（46 个）
```
selftest-absorption-discipline.sh [69,74]    selftest-active-plan.sh [45,53]
selftest-ask-default-timeout.sh [44,47]       selftest-batch-pilot.sh [8,18,31,38,39]
selftest-capability-persistence.sh [36,45,55] selftest-conclusion-discipline.sh [35,72,75]
selftest-context-hygiene.sh [29]              selftest-context-pressure.sh [67,70,71,74,75]
selftest-decision-drift.sh [73]               selftest-decision-grading.sh [31,53,72]
selftest-drift-check-subagent.sh [15,40,61,63,64,65,67,74,76]
selftest-error-loop.sh [8,31,33,35,36,72]     selftest-evidence-goal-gate.sh [36,45,58,59,63,64,65]
selftest-execution-honesty.sh [40,54,55]      selftest-execution-stability.sh [8,36,39,45,53,59]
selftest-final-gate-hash.sh [45,53]           selftest-four-file-dataflow.sh [31,45,58,64,65]
selftest-goal-unit-goal-mode.sh [36,69,70]    selftest-interaction.sh [28]
selftest-iteration-persistence.sh [36,40,45,57,58,59,60,63,64,65]
selftest-lane-advancement.sh [40,49,63,64,65,67,68,69,70,72,74,75,76]
selftest-methodology.sh [45,53]               selftest-parallel-scheduling.sh [36,68,70,72,75]
selftest-periodic-review.sh [45,65]           selftest-plan-dispatch.sh [45,53]
selftest-proactive-research.sh [31,75]        selftest-reflect-verify.sh [22,33,37,72]
selftest-reliability-institution.sh [40,42,43,55]
selftest-report-reviewability.sh [31,68,70,71]
selftest-requirement-coverage.sh [40,52,53,54,55,63,64,65,67,68,69,70,72,74,75,76]
selftest-requirement-grading.sh [36,50]       selftest-research-first.sh [7,31,40,63,65,67,69,72,74,75,76]
selftest-review-library.sh [42,43]            selftest-root-resolution.sh [40,50,53,54,55,70,75]
selftest-self-resolution.sh [40,41,55,63,64,65,67,68,69,70,72,74,75,76]
selftest-skill-collab.sh [8,32,36,39]          selftest-skill-modify.sh [36]
selftest-skill-split.sh [17,21,40,52,53,54,55,59,65,67,69,70,72]
selftest-source-anchor-discipline.sh [71,74,75,76]
selftest-subagent-granularity-skill-escort.sh [36,45,58,59]
selftest-summary-readability.sh [31,75,76]    selftest-task-boundary.sh [8]
selftest-tool-selection.sh [38,39,40,63,64,65,67,68,69,72,74,75,76]
selftest-user-instruction-priority.sh [56]    selftest-veto.sh [32,37,72]
selftest-workflow-orchestration.sh [36,39,63,64,65,67,68,75]
```
**修复动作**：CRIT 变量保留指向核心 critical-rules.md（核心仍含 11 条核心规则的文本）；断言中被移走的 rule 文本改指 `../task-discipline/references/critical-rules-discipline.md` 多锚点（`CRIT_D`）或改断言形态。跨多 home 的 selftest（如 requirement-coverage）按断言 target 拆多锚。

### 批2（P7 S36）：media/collab/template 关联断言集（5 个）
```
selftest-mechanism-profile.sh [37]        selftest-media-agents.sh [47]
selftest-plan-tier.sh [38,47,50]         selftest-template-lifecycle.sh [34,37,48]
selftest-template-sense.sh [34]
```
**修复动作**：CRIT 加 `CRIT_M`（media-planner references）+`CRIT_T`（plan-template-kit）+`CRIT_C`（plan-collab-router）多锚。

### 批3（P7 S37）：dispatch/其他 关联断言集（13 个）
```
selftest-agent-coverage.sh [21,36,47,52,69]  selftest-check-conflicts.sh [23]
selftest-decision-arbiter.sh [52,69]          selftest-delegation.sh [25]
selftest-dispatch-grain.sh [46]               selftest-drift-enforcement.sh [64]
selftest-knowledge-brief.sh [8,21,38,39,59]   selftest-media-dispatch.sh [21,36,47]
selftest-rule23-conflict-scan.sh [23]         selftest-shared-tracker.sh [30]
selftest-split-pattern-library.sh [21]        selftest-subagent-return.sh [22]
selftest-tier-b.sh [14]
```
**修复动作**：CRIT 加 `CRIT_DP`（task-dispatch references）+对应卫星锚；check-conflicts/delegation/tier-b 断言改指 task-dispatch。

### 批修复验收
每批完成：`bash -n` 通过+该批 selftest 全绿；三批完成后核心 75 selftest 全量 FAIL=0（run-selftests.sh）。

## §8 执行序列与依赖

```
P4(task-dispatch) ──┬── P5(task-discipline) ──┬── P6(卫星体系) ── P7(核心瘦身) ── P8(终验)
                   │                          │
                   └── caller 更新(S8-S11) ────┘
```
- P4/P5 无相互依赖（不同目标文件），可并行；P6 收编依赖核心删除基线就绪（P7 S31 前可先落盘卫星侧，删除动作在 P7 统一执行——卫星收编 S24-S30 含核心删除，故 P6 实际依赖 P5 完成后执行）
- P7 核心瘦身必须在 P4-P6 全部落盘后（删除与落盘原子配对）
- P8 回归必须在 P7 全部完成后
- 关键路径：P4→P5→P6→P7→P8

## §9 风险登记

| 风险 | 触发面 | 兜底 |
|------|--------|------|
| 规则文本迁移截断 | P5 六批迁移 | 逐批编号对照表核验+源 diff 对照 |
| caller 漏改 | P4 S8-S11 | §4 清单逐项 grep 验证+回归 FAIL=0 拦截 |
| selftest 锚修复遗漏 | P7 三批 | §7 清单 64 个全覆盖+全量回归拦截 |
| BP-08 钉未演进致误报 | P7 S38 | 钉值=275 与 S33 联动同一 Phase |
| worktree 合并冲突 | P8 merge-back | §十一 合并回合约 STOP 报告 |
