# S77 机械/智能流程分治审查报告

- **审查时间**: 2026-10-19
- **审查对象**: `/mnt/data/dev/task-planner-skill/skills/` 下全部 26 个技能（15 核心 + 11 review-library）
- **审查标准**: skill-fix Standard 77（机械/智能流程分治强制，P1 — 2026-10-19 新增）
- **审查方法**: 主上下文机械扫描 + 2 个隔离子代理深度 Read 审计（核心 8 技能 / review-library 11 技能）
- **范围**: 只读诊断，未修改任何技能文件

---

## 0. 发现总览

| 等级 | 数量 | 说明 |
|------|------|------|
| P0 | 0 | 无（未发现分治误用导致的事实性/安全性缺陷） |
| P1 | 4 类系统性 | 77.1 全局缺失 / 77.4 智能思路缺失 / 77.6 混合未拆分 / 77.2 部分缺失（3 review 技能） |
| P2 | 2 类 | 77.2 机械锚点仅覆盖输出合约层 / 77.3 中间产出无 schema 校验 |

**整体健康度**：机械侧（77.2/77.3）核心技能普遍达标（scripts/+templates/ 锚点密集），智能侧（77.4/77.6）普遍薄弱。**77.1 步骤属性标注是全局性缺失**（19/19 needs-review 技能均无 M/A/M+A 标注），属文本面低风险修复。

---

## 1. 审查范围与分类

### 1.1 需审查（19 个，≥2 步骤）

| 类型 | 数量 | 技能 |
|------|------|------|
| 核心 | 8 | task-planner, iterative-optimizer, task-drift-guard, progress-tracker, todo-skill, error-fix-prompt-forge, verification-gate, plan-resume |
| review-library | 11 | alignment-review, test-quality-review, image-review, general-review, code-quality-review, ui-quality-review, security-review, release-review, documentation-review, data-quality-review, content-quality-review |

### 1.2 豁免（7 个，纯知识/路由卫星）

| 技能 | 豁免理由 |
|------|---------|
| plan-template-kit | 纯知识层，"不执行任何机械动作" |
| plan-cost-guard | 纯知识层，"不执行节流判定" |
| media-planner | 纯路由索引卫星 |
| task-discipline | 纯规则索引文档，无 Phase/Step |
| task-dispatch | 规则索引+脚本清单文档 |
| plan-research-router | "只读路由决策，不代替调研工具执行" |
| plan-collab-router | 纯路由索引卫星 |

---

## 2. 六项审计结果汇总

### 2.1 核心 8 技能

| 技能 | 77.1 | 77.2 | 77.3 | 77.4 | 77.5 | 77.6 | 判定 |
|------|------|------|------|------|------|------|------|
| task-planner | ❌ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ |
| iterative-optimizer | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | N/A | ⚠️ |
| task-drift-guard | ❌ | ✅ | ⚠️ | ⚠️ | ✅ | N/A | ⚠️ |
| progress-tracker | ❌ | ✅ | ✅ | N/A | ✅ | ⚠️ | ⚠️ |
| todo-skill | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ⚠️ | ⚠️ |
| error-fix-prompt-forge | ❌ | ✅ | ✅ | ❌ | ✅ | N/A | ⚠️ |
| verification-gate | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠️ | ⚠️ |
| plan-resume | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |

### 2.2 review-library 11 技能

| 技能 | 77.1 | 77.2 | 77.3 | 77.4 | 77.5 | 77.6 | 判定 |
|------|------|------|------|------|------|------|------|
| alignment-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| test-quality-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| image-review | ❌ | ❌ | ⚠️ | ❌ | ✅ | ❌ | ❌ |
| general-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| code-quality-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| ui-quality-review | ❌ | ❌ | ⚠️ | ❌ | ✅ | ❌ | ❌ |
| security-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| release-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| documentation-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| data-quality-review | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| content-quality-review | ❌ | ❌ | ⚠️ | ❌ | ✅ | ❌ | ❌ |

---

## 3. P1 发现（系统性）

### P1-1: 77.1 步骤属性标注全局缺失（19/19）

**问题**：全部 19 个 needs-review 技能均未对任何 Phase/Step 标注「机械 M / 智能 A / 混合 M+A」属性。Standard 77 §4 将 77.1 列为【必选·不可跳过】，缺失 = P1。

**证据**：对 19 个 SKILL.md `grep -nE "机械|智能|M\+A|\[M\]|\[A\]"` 无步骤级属性命中。

**修复建议**：在各 SKILL.md 执行流程段为每步加 `[M]/[A]/[M+A]` 标记。

### P1-2: 77.4 智能步骤无 ≥2 思路+选择条件（15/19）

**问题**：15/19 技能的智能步骤仅描述单一路径，未给 ≥2 可选思路+选择条件。仅 plan-resume 达标（§7.10 四项测试 T1-T4 + 裁决优先级三选）。

**证据**：
- iterative-optimizer Step 2 "列全部 FAIL 项,按影响排序→选定本轮最弱项" 为单路径
- todo-skill Step 2 Agent 拆解仅约束 JSON 结构无拆解策略
- error-fix-prompt-forge Step 2 缺口分析单路径
- verification-gate Step 1 VC 设计无设计思路选项
- review-library 11 技能所有含判断的条目均单一路径

**修复建议**：各补 ≥2 思路 + 可判定选择条件。

### P1-3: 77.6 混合步骤未拆分（18/19）

**问题**：18/19 技能的混合步骤未显式拆分为机械子动作 + 智能子动作。仅 plan-resume 达标（§7.5 推进纪律/§7.10 合法停点把机械与智能分离）。

**证据**：review-library 每条 checklist = 「机械检查动作（grep/Read/diff/跑）」+「智能判定（是否达标/归因/严重度）」捆在一行。

**修复建议**：混合步骤拆为两条：机械子动作入固定流程，智能子动作入决策描述。

### P1-4: 77.2 机械 SOP 锚点缺失（3/19，review-library）

**问题**：image-review / ui-quality-review / content-quality-review 三个技能的审查法以目视/通读为主，无 SOP/脚本/模板锚点。

**证据**：三个技能无 references/、scripts/、templates/ 子目录；主要审查法为"目视检查构图""目视检查错位/溢出""通读判断"。

**修复建议**：为目视/通读类审查法补固定 SOP 段（如截图命名规范/采集流程/通读检查清单）。

---

## 4. P2 发现

### P2-1: 77.2 机械锚点仅覆盖输出合约层（11/19，review-library）

**问题**：review-library 11 技能的机械锚点仅覆盖输出合约（二值首行 + 逐行问题清单格式），checklist 机械动作未固化为可复用 SOP 段/脚本。

**修复建议**：将 checklist 中的机械检查动作（grep/diff/跑测试）抽取为独立 SOP 段或脚本。

### P2-2: 77.3 中间产出无 schema 校验（11/19，review-library）

**问题**：review-library 11 技能的机械可校验仅覆盖最终二值结论，各步骤中间产出为散落 prose findings，无 schema/字段校验。

**修复建议**：为中间产出提供结构化校验锚点（如 JSON schema / jq 校验命令）。

### P2-3: task-planner 智能步骤指针外置

**问题**：task-planner 的智能步骤（T1-T5 解构/方案终裁）指针外置至 references/methodology.md，SKILL.md 内无就地选择条件。

**修复建议**：在 SKILL.md 内就地补触发条件摘要。

### P2-4: todo-skill WORKFLOW.md 与 SKILL.md 不一致

**问题**：todo-skill/WORKFLOW.md:35 标注 "Single-step tool/script skill / No multi-phase structure" 与 SKILL.md 6 步工作流不符，疑 workflow-gen 生成器陈旧。

**修复建议**：更新 WORKFLOW.md 或重新生成。

---

## 5. 负结果报告

- **预期"机械步骤无锚点/无校验"问题**：核心 8 技能**未发现**——锚点普遍完备（77.2 6✅2⚠️，77.3 5✅3⚠️）
- **预期"智能步骤过度脚本化"（77.5 反模式）**：19/19 技能**未发现**——智能步骤均以自然语言描述保留弹性
- **排除了"锚点文件缺失"可能性**：13 个关键锚点路径经 `[ -e ]` 实测全部存在
- **排除了 task-drift-guard 纯查询豁免误判**：属只读检测（§7 可豁免 §3），但 77.1 标注仍适用

---

## 6. 修复建议优先级

| 优先级 | 修复项 | 影响范围 | 预估工作量 |
|--------|--------|---------|-----------|
| P1 | 77.1 步骤属性标注 | 19 技能 | 中（每技能加 [M]/[A]/[M+A] 标记） |
| P1 | 77.4 智能≥2思路 | 15 技能 | 中高（每技能智能步骤补 ≥2 思路+选择条件） |
| P1 | 77.6 混合拆分 | 18 技能 | 中（混合步骤拆为两条） |
| P1 | 77.2 机械锚点（3 review 技能） | 3 技能 | 低（补 SOP 段） |
| P2 | 77.2/77.3 review-library 机械固化 | 11 技能 | 中高（抽取 SOP + schema） |
| P2 | task-planner 智能步骤就地化 | 1 技能 | 低 |
| P2 | todo-skill WORKFLOW.md 更新 | 1 技能 | 低 |

---

## 7. 下一步建议

1. **修复任务规划**：如需修复，建议另开任务（需 worktree §十一），按 P1→P2 优先级逐批修复
2. **77.1 标注可批量化**：19 技能的步骤属性标注可用同一模板批量应用
3. **77.4 智能思路需逐技能设计**：每个技能的智能步骤需单独设计 ≥2 思路+选择条件，不可批量套用
4. **review-library 可套同一模板**：11 个 review 技能结构同构，修复可套同一 S77 分治模板

---

**报告生成时间**: 2026-10-19
**审查执行体**: 主上下文 + 2 个 agent-quality-auditor 子代理（sonnet-1）
**报告路径**: plans/skill-audit-s77-20261019/s77-audit-report.md
