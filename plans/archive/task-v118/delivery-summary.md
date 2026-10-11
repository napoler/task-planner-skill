# task-v118 交付总结（五要素）

> 机器档案：plans/task-v118/{task_plan.md, findings.md, progress.md, verification.md, subagent-state/}；本总结只做用户面索引，数据不重写。

## 一、任务说明
用户指令：优化子代理任务规划——单个子代理执行任务过于复杂导致效率低下，要求单代理任务简单高效、禁一次性给过多任务、确保专注。
落地形态：**Rule 46「子代理单任务专注度」**三层钳制——条款（46.1 单会话单 S-unit/46.2 守卫豁免收窄/46.3 拆分单一性/46.4 模板引导/46.5 机制零新键）+ 机器守卫（check-dispatch.sh 双豁免收窄）+ 模板引导（派发模板双引导行）。根因实证：v117 单会话连领 9 S-unit 分 4 批次（主因）、v116 任务书豁免+markdown 编号双漏检（放大器）、v113/v115 复合型 S-unit（次因）。

## 二、产出清单
| 产出 | 位置 |
|------|------|
| Rule 46 条款块（五子条） | skills/task-planner/references/critical-rules.md L474-483 |
| SKILL.md 四处联动（frontmatter 1-46/2.5 措辞/摘要行/References） | skills/task-planner/SKILL.md L9/L85/L247/L305 |
| 派发模板双引导行 | skills/task-planner/templates/subagent_dispatch.md L17/L67 |
| 守卫收窄（任务书 S-id 计数 + markdown 步骤口径 + 共用提取函数） | skills/task-planner/scripts/check-dispatch.sh |
| selftest-dispatch-grain.sh（10 断言 GR-01..10） | skills/task-planner/scripts/ |
| 三锚口径扩展（RT-08/PT-08/CD-12 → 1-4[56]）+ registry 43 行 | 同目录 4 个 selftest + tsv |
| 合并 master df7e427；三部署位（~/.zcode|~/.claude|~/.config/opencode）0 差异 | 部署对账见 progress.md Phase 5 |

## 三、审查信息
- **Code Review Gate**：初审 CHANGES_REQUESTED（1 BLOCKER：提取器全角标点盲区——恰是 46.2 要收口的中文引用形态）→ fix-phase F1/F2 → **复审 APPROVED**（5 项销项、8 形态提取探测、自由 prompt 与 master 字节对比一致、7 套件×3 轮复跑全绿）
- **alignment-review（42.6.2）**：APPROVED（变更记录三要素落 progress.md）
- **全量 selftest**：43/43 脚本 rc=0，ΣPASS=676 ΣFAIL=0（基线 666→676 自洽）
- 本任务执行自身消费新规则（dogfood）：16 次 Agent 派发全部单 S-unit 单目标，S6a∥S6b 并行组示范 21.4

## 四、风险点
1. **守卫裸相对引用边缘形态**（CR 复审 LOW 观察）：任务书引用无目录前缀且 cwd 不在计划目录时 fail-open 放行——Rule 22.4a 绝对路径契约下属边缘，已登记未修
2. **{1,2} 位限 trade-off**：行首 ≥100 号枚举不入步骤计数（99 步远超 smax=4 早被拦截，lead-in 已保证拦截，实际无绕过面）
3. **CD-12 类锚漂移风险**：SKILL.md frontmatter 后续每加 Rule 仍需三锚宽容化级联（RT-08/PT-08/CD-12 现口径 1-4[56]，下次到 1-47 需再扩）
4. **无**未提交变更、无遗留 FAIL、无范围外文件

## 五、下一步建议
1. 行为面观察期：dispatch_contract_enforce=warn 档环境积累批次连做实拦数据，再评估升 enforce（当前默认 enforce，已有机器面）
2. 46.3 拆分单一性的计划期机器面（预估时长 SKIPPED→定性拦截）当前仅条款约束，后续轮可评估 check-plan-dispatch 扩展
3. 三锚宽容化可预扩至 1-4[5-9] 减少下次级联（成本极低，未做——保持本次最小 diff）
