# S6 任务书：spec_version retrofit 扫描/改造 SOP 机制化（2026-11-20）

执行体：在 worktree 内落地 R4 存量模板升级机制。全程中文。前序：spec_version=1 已全量声明（base+29 variant+kit，d0c217f/5818356）；注册表与守卫已就位。

## 0. 绝对路径（worktree 内）
- W=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120
- kit：$W/skills/plan-template-kit/（SKILL.md 含 `spec_version=1` 声明行=当前规范版本权威源；scripts/inject-template-lineage.sh 在位可参考其风格；references/principle-template-registry.md 在位）
- 模板面：$W/skills/task-planner/templates/task_plan.md + templates/variant/*.md（31 个，mini-lite/l0-lite 豁免无 lineage 头）
- 新扫描脚本：$W/skills/plan-template-kit/scripts/scan-template-spec.sh（**名字已预定，VC-12 判据引用，禁改名的结构**）
- 新 SOP：$W/skills/plan-template-kit/references/retrofit-sop.md
- 新 selftest：$W/skills/task-planner/scripts/selftest-template-retrofit.sh（样本=先 Read selftest-template-principles.sh）+ registry.tsv +1 行

## 1. 交付物（4 项）

### ① scan-template-spec.sh（新建）
- 解析 kit SKILL.md 的当前规范版本 N（`spec_version=<N>` 行）作为权威源
- 扫描 base+31 variant 的 lineage 头 `spec_version=` 字段（豁免 2 个 variant 记 SKIPPED-EXEMPT）
- 输出三段：`CURRENT-SPEC: <N>` / 每模板一行 `<file> spec_version=<v> OK|OUTDATED|MISSING` / 汇总 `OUTDATED: <count>`（vc-gate 判据引用 "spec_version" 字样在输出中）
- 参数：`--target-spec <N>`（对照目标版本，>当前 N 时全部列为 OUTDATED=模拟升级场景）；无参数=对照当前 N
- 退出码：OUTDATED=0 → rc 0；存在 OUTDATED → rc 1（供收口门用）；缺 lineage 头且非豁免=MISSING 计入 OUTDATED

### ② retrofit-sop.md（新建，≤60 行）
六步流程：①kit SKILL spec_version 递增 ②注册表（principle-template-registry.md）新增/修订原则行 ③`scan-template-spec.sh --target-spec <新N>` 产过时清单 ④逐模板改造（优先 inject-template-lineage.sh/守卫可脚本化面）⑤守卫复验（check-template-principles+check-template-type+selftest 族全绿）⑥登记（findings+本 SOP 尾部版本历史表追加一行）
- 开头写明机制化来源：task-variant-upgrade-20261113 判例（模板升级≠一处修，教学面四族=主模板+kit+variant+守卫）
- 尾部版本历史表：`| spec_version | 日期 | 变更 | 任务 |`，首行=1|2026-11-20|初版（lineage+原则注册表+守卫）|task-antiregress-tplgov-20261120

### ③ kit SKILL.md 接线（+2 行内）
retrofit SOP 指针行（含 `retrofit` 与 `spec_version` 关键词；禁动既有 spec_version=1 行与派生铁律行）

### ④ selftest-template-retrofit.sh（新建）+ registry.tsv
断言集：SOP 存在+关键锚（六步/版本历史/variant-upgrade 判例）；scan 脚本行为级 3 条——`--target-spec 1` 输出 OUTDATED: 0 且 rc=0（存量清零证据）、`--target-spec 2` 列出全量 44 行 OUTDATED 且 rc=1（清单功能真实工作非恒过）、无参数 rc=0；kit 指针行在位。输出风格随样本。

## 2. 验收（自查 5 条，入 checkpoint 自审段）
1. VC-12：`bash skills/plan-template-kit/scripts/scan-template-spec.sh --target-spec 1` rc=0 且输出含 spec_version；`--target-spec 2` rc=1 且 OUTDATED=44
2. SOP 存在且六步/判例锚/版本历史齐
3. kit SKILL 指针行在位且既有行零改动（git diff 仅 +行）
4. 新 selftest PASS rc=0 + registry 登记；全量 run-selftests FAIL 集==基线 8 集零新增
5. 103.2 自审逐条对照，证据锚 file:line 入 checkpoint

## 3. 禁改面
上列文件外一切禁改（三份 rules/主模板/variant/既有脚本/注册表/守卫禁动）；主仓与部署位禁碰。
