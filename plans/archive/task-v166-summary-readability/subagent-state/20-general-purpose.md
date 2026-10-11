# Checkpoint — S20 对齐面审查（alignment-review，task-v166）

<!-- T1 里程碑 2026-10-11 10:44 CST：审查完成，verdict 已出。方法=review-library/alignment-review/SKILL.md；只读审查，git status 17 项零变化。 -->

## T1 · 审查执行记录（2026-10-11 10:44 CST）

- 方法论：review-library/alignment-review/SKILL.md（十维度清单+证据要求+二值输出合约）
- 审查对象（Rule 70① 总清单，5 个 .md 改动文件）：
  1. skills/task-planner/references/critical-rules.md — 新增 Rule 76 六子条+Rule 70/72 互引指针
  2. skills/task-planner/SKILL.md — 索引 1-76 三处+Rule 76 bullet+终验段联动句+C54 行
  3. skills/task-planner/templates/delivery-summary.md — 新增 §3 审查清单表格，§3/§4/§5→§4/§5/§6 顺延，注释区 ①-⑤→1.-5.
  4. skills/task-planner/templates/variant/image-type.md — Phase 标题圈号清除+Rule 76 引用
  5. skills/task-planner/templates/variant/multiview-ref-type.md — 同上

## 逐维度核查结果（含机器证据）

| 维度 | 结论 | 证据 |
|------|------|------|
| 计数联动（1-76） | PASS | `grep -c '1-76' SKILL.md`=3；`grep -c 'Rule 76' SKILL.md`=6(≥5)；SKILL.md 内 `1-74` 残留=0 |
| 条款锚 | PASS | `grep -cE '^76\.[1-6] ' critical-rules.md`=6；标题锚 :1007；条文与 task_plan §Rule 76 草案逐字一致 |
| 交付模板编号顺延 | PASS（.md 面） | delivery-summary.md :51/:58/:68/:76 现为 §3/§4/§5/§6；头部注释「§6 逐条必填」(:13) 同步；模板内无其他旧段号引用 |
| 模板契约不变量 | PASS | 五要素齐=§1 执行过程摘要/§2 产出清单/§3 审查清单/§5 风险点/§6 下一步建议；§6 定位三要素（对象/看点/动作，Rule 48.3）保留；Rule 48 注释区 ①-⑤→1.-5. 无圈号残留（:34「Rule 54.1③/50.3」=规则子条引用，76.2 但书保护） |
| variant 引用链 | PASS | 两文件「Rule 70 四要素」①-④ 引用受 76.2 但书保护；新增 Rule 76 指针与 critical-rules 互引措辞一致；Rule 76.5 外部引用完整（`grep -c '22.4b' critical-rules.md`=7；plans/task-v161-subagent-return-format/ 存在） |
| 交叉引用（.md→.md） | PASS | skills/*.md 无指向 delivery-summary 旧段号（§4/§5）的锚（仅 C44/48.3/58.5 正文散文提及「下一步建议」字样，非段号锚） |
| 守护锚级联（.sh→.md） | **FAIL** | check-complete.sh:972/975 report-lint 检查②仍锚 `^##[[:space:]]*(5\.\|五、)[[:space:]]*下一步建议`，模板已顺延 `## 6.` → 新模板产物三要素 lint 静默失效 |
| 机器面自跑 | PASS | `bash scripts/selftest-summary-readability.sh` → Total: PASS=13 FAIL=0 WARN=0（SRV-01..13 全 PASS） |

## Verdict

**CHANGES_REQUESTED**

## 问题清单（逐条 file:line + 问题 + 修法）

```
[P0] skills/task-planner/scripts/check-complete.sh:972（同源 :975，注释 :940/:946/:970）— 模板「下一步建议」段已由 ## 5. 顺延为 ## 6.（delivery-summary.md:76），report-lint 检查② 正则仍只匹配 (5.|五、) → 按新模板产出的总结缺看点/动作三要素时 lint 不触发，Rule 48.4/70④ 机器守护静默弱化（方法论 SR-11/12 锚漂移判例=P0）。修法：两处正则改 (5.|6.|五、|六、)；:940/:946/:970 注释「## 5.」改「## 6.」。
[P1] skills/task-planner/references/critical-rules.md:885（67.6 机制守护）— 叙述「SKILL『Critical Rules 1-74』三处…CP-07 锚族扩为 1-(69|71|74)」与实况不符：SKILL.md 已 1-76（grep -c '1-76'=3），脚本实际锚族 1-(69|71|7[4-9])（selftest-context-pressure.sh:101/108）。修法：补 [2026-10-11 task-v166 级联演进] 注 1-74→1-76、锚族 1-7[4-9]（沿用 task-v162/158 在 67.6/71.7 留演进注的先例）。
[P1] skills/task-planner/references/critical-rules.md:954（71.7 机制）— 「SKILL 登记行+计数 1-74（[2026-10-10 task-v162 合并演进] 全集锚 1-71→1-74）」未随 v166 演进（现 1-76）。修法：并集演进注 1-74→1-76。
[P1] skills/task-planner/references/critical-rules.md:1005（74.6 ④）— 「SKILL.md Rules 全集演进至 1-74+合规清单 C51+…」实况=1-76+C54。修法：改「1-76+合规清单 C51/C54」。
[P2] skills/task-planner/templates/variant/image-type.md:21 — VC-1 表行残留新枚举圈号「①合规检②一致性检③质量检」（生成计划的用户可见 VC 表格；76.2② 严格读触犯，但书不覆盖）。pre-existing、S7 声明范围仅 Phase 标题、SRV-13 断言仅覆盖标题形态 → 不阻断。建议：顿号列举或 1. 2. 3.。
[P2] skills/task-planner/templates/variant/image-type.md:4、templates/variant/multiview-ref-type.md:4 — HTML 注释内 ①-⑨ 步骤映射（模板内部注释不渲染，76.1 边界内；pre-existing）。建议登记豁免或后续轮次统一。
[P2] skills/task-planner/SKILL.md:305 — 「含 Rule 40-74 全集」区间描述符未扩至 40-76（Rule 76 已在同括号显式枚举，信息完整无缺失）。建议改「40-76」。
```

## 变更记录输出（alignment-review 三要素）

| 字段 | 说明 |
|------|------|
| 变更范围 | 本次审查对象=5 个 .md 改动文件全量（含交叉触达的 check-complete.sh report-lint 锚与 critical-rules  prose 计数叙述） |
| 冲突处理结果 | 发现 1×P0（report-lint 下一步建议锚漂移）+3×P1（critical-rules  prose 1-74 计数陈旧）+3×P2（variant 残留圈号×2、SKILL 区间描述符×1）；全部只标记未修改（只读审查） |
| 文档当前状态 | .md 五文件本体一致性 PASS（编号顺延/引用链/契约不变量/条文逐字）；残留冲突=4 处实质（P0×1+P1×3）待 S21 修复后复验 |

## T5 · 最终结论（= 返回格式 8 字段块）

```
status: done
acceptance: 3/3 pass — [1:PASS(verdict行在档) 2:PASS(问题清单逐条file:line) 3:PASS(5个.md全覆盖)]
files: none
evidence: grep -c '1-76' SKILL.md=3; grep -cE '^76\.[1-6] ' critical-rules.md=6; delivery-summary.md:51/58/68/76=§3/§4/§5/§6; check-complete.sh:972 锚 '5.|五、' vs 模板 '## 6.' 漂移; bash selftest-summary-readability.sh → PASS=13 FAIL=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/20-general-purpose.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```

**verdict 行：CHANGES_REQUESTED（P0×1 + P1×3 + P2×3，共 7 条）**
