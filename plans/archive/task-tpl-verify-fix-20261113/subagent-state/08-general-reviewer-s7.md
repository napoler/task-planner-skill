# 08-general-reviewer-s7 103.3 独立复检

- 复检体：`general-reviewer`（全新只读，未参与前期执行）
- 时间：2026-11-13T03:35:00+08:00
- 对象（只读）：`plans/task-tpl-verify-fix-20261113/{task_plan.md,findings.md,progress.md}`；worktree `/mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113`；`git diff master --stat`(7 files, +59/-35)/`git diff master` 全量；`subagent-state/06-code-runner-smoke.md`、`07-general-coder-sgfix.md`
- 范围声明：仅复核五维与证据链；未改产出、未重做、未扩范围

## 五维结论

### 1) 五漂移 + 第六漂移逐项核（CA-1~CA-5, CA-9~CA-11）
- **CA-1（S-unit 11→10 列，去独立「96 类别」列）PASS**：`skills/task-planner/templates/task_plan.md:338` 口径改为「类别以目标列内（An）前缀标注…S-unit 表为 10 列固定列序…禁增列」；表头/示例行改为 10 列 `:340,:358`（目标列含 `(A6)/(A7)` 前缀示范）；模板内不再有「96 类别」独立列表述（负面语境“禁…”保留于注释口径）。与 findings §3.1 一致。
- **CA-2（Goal 列名空格）PASS**：`skills/task-planner/templates/task_plan.md:143`、`:146` 列名为「对应 S-unit/Phase」；契约注释 `:140` 同步。与 findings §1③/§3.1 一致。
- **CA-3（Phase 4 示例 S-unit 表）PASS**：`skills/task-planner/templates/task_plan.md:354-360` Phase 4 段补最小 10 列 S-unit 示例表并注「Executor≠主进程的 Phase 必附（Rule 22.6…）」；满足 Rule 22.6/dispatch 门预期。与 findings §1④/§3.1 一致。
- **CA-4（Batch Report 非空引导）PASS**：`skills/task-planner/templates/task_plan.md:496-507` 八字段改为 `n/a（…理由/实际填写指引）` 且注释 `:496` 明确「留空会被 18.6 门拦」。与 findings §1⑤/§3.1 一致。
- **CA-5（verification 模板验证区块）PASS**：`skills/task-planner/templates/verification.md:14,18,21,24,27,30` 各 VC 条目预置行首 `**Verify command**:` + 禁占位/禁真空/须引用产出物判据引导；`:14` 头注锚定 `attest-plan.sh:244-285` vc-gate；Phase 示范 `:47,49,66,68` 同步带命令行。与 findings §1②/§2/§3.2 一致。
- **CA-9（dispatch Rule 104 口径）PASS**：`skills/task-dispatch/references/critical-rules-dispatch.md:244` 标题括注改为「计划期类别标注（An 前缀）」；`:256` 速查表列头保留「96 类别」字样但加防歧义半句「（类别落 S-unit 目标列（An）前缀，非独立列）」；`:278` 明确「10 列固定列序，类别以目标列内（An）前缀标注…（task-tpl-verify-fix-20261113 口径迁移）」。与 10 列+前缀契约无矛盾。
- **CA-10（SA-19 断言翻转）PASS**：`skills/task-planner/scripts/selftest-subagent-activation.sh:97-99` 由“模板含 96 类别≥2 处”翻转为 `cnt '(A' >=1 && cnt '96 类别' ==0`，守卫新口径（有前缀示范、无独立列字面）；progress 记录 SA-19 PASS/Total 20 PASS=20 FAIL=0。
- **CA-11（第六漂移 SG-12/13）PASS**：`skills/task-planner/scripts/selftest-subagent-granularity-skill-escort.sh:13-14,148-158` 表头计数由 `-eq 1`→`-ge 1`，What/Why/ok/bad 同步注明「主表+派发 Phase 示例表合法，task-tpl-verify-fix-20261113」。与 CA-3 合法新增 Phase 4 示例表一致；`subagent-state/07-general-coder-sgfix.md` 证实 SG 23/23 PASS、全量 FAIL 回落基线 2。

**判定：CA-1~CA-5, CA-9~CA-11 与 findings §3/计划意图逐项对齐，达成。**（CA-6 见维度3；CA-7 无锚关闭、CA-8 存量 diff 判向由 S5/进度登记，非本 diff 主修面——未见与口径冲突的残留证据。）

### 2) 渲染安全
- **PASS**：`git diff` 显示模板仅语义内容/注释/表结构修改；`skills/task-planner/templates/task_plan.md:2`、`skills/task-planner/templates/verification.md:2` 仍保留渲染契约注释 `{{VAR}}` 语义说明（机械 token 未被误删/改写为占位值）；未见新增/改动 `{{...}}` 机械渲染变量。`subagent-state/06-code-runner-smoke.md` Step 1 记录渲染 7 文件、功能体无机械 `{{UPPER}}` 泄漏（仅契约注释命中），与 diff 一致。tplrender 6+8 变量映射/契约注释面未受破坏证据充分。

### 3) 契约互恰（kit ↔ 模板实际形态 ↔ 门判据；dispatch 与模板零矛盾）
- **PASS**：`skills/plan-template-kit/references/template-mapping.md:232-237` §7.1 落“验证区块契约”（锚 `attest-plan.sh:244-285`）与“S-unit 10 列序契约”（锚 `check-plan-dispatch.sh:246-278`，列序/禁增列/禁管道转义/`(An)` 前缀），并互证 `verification.md:14,18,21,24,27,30`、`task_plan.md:338,340,358`；`template-guide.md:167` 补指针。与模板实际形态一致。
- **PASS**：`check-plan-dispatch.sh:246-278` 仍按 `$4=执行体/$5=输入/$7=时长/$8=粒度` 及 `Nf/Nl/Nmin` 校验，匹配模板 10 列固定列序；`attest-plan.sh:244-285` vc-gate 要求行首 `**Verify command**:` 与非空内容，匹配 verification 模板预置行。
- **PASS**：dispatch `:256` 表列头保留旧标签“96 类别”但立即限定为“类别落 S-unit 目标列（An）前缀，非独立列”，`:278` 明确 10 列+前缀+口径迁移判例——与模板“无独立列、目标列前缀”及门定位无语义矛盾（属防歧义兼容表述，非回退旧契约）。

### 4) 断言维护正当性（SA-19 / SG-12,13）
- **PASS（随契约走，非弱化）**：SA-19 从强制旧字面“96 类别≥2”改为强制新契约“存在 `(An)` 前缀示范且模板无 `96 类别` 字面”，实质仍守住“类别标注在模板中可见”且阻止独立列回退。SG-12/13 从“表头唯一=1”改为“≥1”，因 CA-3 使 Phase 4 示例表成为 Rule 22.6 合法必需形态；判据仍要求表头含 `粒度(三值)`/紧随的 `伴飞技能` 列（机器输入源不丢），仅放宽重复次数以容纳合法多表——实质守卫保留。S6 捕获 SG 回归→07 修复闭环，符合“断言随契约演进”而非为绿让路。

### 5) 冒烟证据链（S6/SG 修复闭环）
- **PASS（闭环）**：`subagent-state/06-code-runner-smoke.md` 证实渲染 7 文件、功能体零机械 token 泄漏、最小填充后 `check-plan-dispatch` `EXIT:0`（“✓ 3 个派发型 Phase 均有带执行体的 S-unit 表”）、VC `**Verify command**: test -f` 命中=1、`tmp-smoke-tplfix` 清理（REMOVED/ABSENT）。S6 当时全量自测尾部为 FAIL=3（含 `selftest-subagent-granularity-skill-escort`，与 CA-3 引入 Phase 4 示例表导致旧 `=1` 断言冲突一致）；`subagent-state/07-general-coder-sgfix.md` 证实 SG 脚本单跑 23/23 PASS、`run-selftests` 尾部 FAIL=2（基线）；progress Phase 3 另记 SA-19 单跑 20/20 PASS。综合：冒烟抓到第六漂移→修复→基线恢复，证据链闭合支撑 VC-5。

## 总裁决
- **APPROVED**

## 备注/残余风险（非阻断）
1. S6 checkpoint 对 SA-19 的显式文本定位不足，但 progress 记录 SA-19 自测与 SA-19 负向字面守卫逻辑与模板现状一致；建议后续在 smoke 记录中显式附 SA 片段以增强可追溯性（信息性）。
2. CA-7（SKILL.md 注释块）因无锚关闭属执行体据实处置：模板本体已承载教学口径，当前无反证表明遗漏同源教学面；CA-8 项目级覆盖 diff 判向在 S5 路径上，未见本次 diff 需同步项。

