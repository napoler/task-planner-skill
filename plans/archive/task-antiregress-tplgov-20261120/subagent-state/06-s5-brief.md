# S5 任务书：原则→模板区块注册表 + 覆盖守卫 + 派生铁律条款（2026-11-20）

执行体：在 worktree 内落地 R2 原则注入机制（注册表+守卫）与 R5 派生铁律文本。全程中文。前序已就绪：Rule 111/106.8/22.4f（15fc6c5）；29 variant lineage 头 + base level=base + kit spec_version=1 + inject-template-lineage.sh（d0c217f）。

## 0. 绝对路径（worktree 内）
- W=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120
- base 主模板（区块归纳源，只读）：$W/skills/task-planner/templates/task_plan.md（先 grep '^## ' 取全区块清单）
- kit：$W/skills/plan-template-kit/SKILL.md（已含 spec_version=1 行@:8 附近）；references/ 目录（新建注册表文件放这里）
- 新守卫：$W/skills/task-planner/scripts/check-template-principles.sh
- 新 selftest：$W/skills/task-planner/scripts/selftest-template-principles.sh（结构样本=先 Read selftest-antiregress.sh）
- registry：$W/skills/task-planner/scripts/selftest-registry.tsv（+1 行）

## 1. 交付物（4 项）

### ① 注册表 skills/plan-template-kit/references/principle-template-registry.md（新建）
「原则→模板区块」权威映射（spec_version=1 口径），表结构：`原则 | 权威规则锚 | 模板载体区块 | base 必选? | derived 载体口径 | 豁免档 | 守卫断言`。必含原则行（从 base 现状归纳，先 grep 核实区块名再写，禁臆造）：
- 防倒退（Rule 111）→「📦 进度产出基线」+「🛡 防倒退终检」；base 必选；derived=轻量指针行（grep「进度产出基线」≥1 即合规，S3 已落 3 个 variant，其余 variant 由守卫放行口径=lineage 头存在即可+指针行逐步补齐登记）；mini-lite/l0-lite 豁免
- 规范基线（Rule 51.15）→「🔒 规范基线」区块（none-justified 合法豁免形态）
- 用户需求原文（Rule 51.1）→「🎯 用户需求原文」；根源覆盖（Rule 53.1）→「🧮 根源覆盖表」；Goal 单元（Rule 66.1）→「🎯 Goal 单元表」；验证契约（Rule 84）→「✅ Verification Contract」含 **Verify command**；FMEA→「📊 FMEA 预演」；证据锚（Rule 71）→ 证据面/无源不写条款
- 指令理解迭代（Rule 28.2.2）→ 载体=主仓工作树在途区块（worktree HEAD 未含，如实标注「在途：主仓未提交改动簇，合并后对齐」——诚实登记，禁假称已在位）
- lineage（本任务新增机制）→ template-lineage 头（derived 必选，base=level=base 行）
- 表尾：spec_version=1 声明 + 「新原则落地时本表同步登记（原则级联面含模板族）」条款 + 二级派生铁律文本（见 ④）

### ② 覆盖守卫 skills/task-planner/scripts/check-template-principles.sh（新建）
- 功能：读注册表 → 对 base+29 derived 逐模板校验必选原则载体存在性（grep 区块标题/lineage 头/指针行口径按注册表列）
- 豁免：mini-lite/l0-lite 自动跳过；`<!-- principle-exempt: <原则> 理由 -->` 行内豁免通道
- 缺失→FAIL 输出清单（模板名+缺失原则），exit 1；全绿→`PRINCIPLES-COVERAGE PASS`，exit 0
- `--selftest-smoke` 模式：内置正反夹具（临时目录造缺块/全齐两夹具自验判定器，用完即清理）——**VC-07 判据就是本模式**
- 阈值口径：derived 的防倒退指针行当前仅 3/29（S3 抽样），守卫对「指针行」列按**警告不计 FAIL**（warn 口径登记，逐步补齐后再翻 enforce——防一次性 26 个 FAIL 阻塞），base 与 lineage 列=enforce FAIL

### ③ 派生铁律条款（R5 核心，VC-14 载体）
写入注册表 §派生铁律 一节（kit 侧权威文本）：
- **派生登记**：derived 模板必须带 template-lineage 头（parent/base/spec_version/pruned 裁剪清单）
- **双参照铁律**：二级派生（从 variant 派生新模板）必须同时参照 base 与 parent（base+parent 双参照）再派生；裁剪清单=父级裁剪 ∪ 新增裁剪，逐级对齐 base 重新评估合法性
- **核心不可静默丢失**：base 必选原则区块（注册表 enforce 列）未经注册表豁免登记不得从派生链消失；守卫按本表校验
- kit SKILL.md 加 2 行指针：注册表路径 + 派生铁律一句（含「双参照」关键词，满足 VC-14 grep）

### ④ selftest-template-principles.sh（新建）+ registry.tsv 登记
断言集：注册表存在+必含关键词（防倒退/验证/证据/理解迭代/双参照/spec_version）+ 守卫脚本存在 + 守卫 --selftest-smoke rc=0 + 正反夹具行为级（缺块 FAIL/全齐 PASS）+ kit 指针行。输出风格随 selftest-antiregress.sh。

## 2. 验收（自查 5 条，入 checkpoint 自审段）
1. VC-06：注册表存在且 grep 防倒退/验证/证据/理解迭代 各≥1
2. VC-07：`bash check-template-principles.sh --selftest-smoke` rc=0 含 PASS
3. VC-14：`grep -rn "双参照\|二级派生" skills/plan-template-kit/ skills/task-planner/references/ skills/task-discipline/references/` ≥1 命中
4. 守卫实跑 base+29 derived：enforce 列全绿（exit 0）；warn 列输出计数
5. 新 selftest PASS rc=0 + registry 登记；全量 run-selftests FAIL 集==基线 8 集零新增

## 3. 禁改面
上列文件外一切禁改（三份 rules/主模板/variant/既有脚本禁动）；主仓与部署位禁碰。
