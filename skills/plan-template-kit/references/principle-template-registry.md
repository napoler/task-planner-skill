# 原则→模板区块注册表（spec_version=1）

> 权威映射：模板治理原则与模板载体区块的对应关系。守卫 `skills/task-planner/scripts/check-template-principles.sh` 按本表校验覆盖面。
> spec_version=1（2026-11-20 task-antiregress-tplgov-20261120 建立；模板规范升级时递增并同步本表与守卫口径）。

## 映射表

| 原则 | 权威规则锚 | 模板载体区块 | base 必选? | derived 载体口径 | 豁免档 | 守卫断言 |
|------|------------|--------------|------------|------------------|--------|----------|
| 防倒退 | Rule 111（进度产出基线防倒退） | `## 📦 进度产出基线` + `## 🛡 防倒退终检` | 是（enforce） | 轻量指针行：grep `进度产出基线` ≥1 即合规（S3 已落 3 个 variant）；其余 derived 指针行按 **warn** 口径逐步补齐，不计 FAIL | mini-lite, l0-lite（自动跳过） | base: enforce 两区块标题；derived: 指针行 warn |
| 规范基线 | Rule 51.15（Spec-Baseline） | `## 🔒 规范基线`（none-justified 合法豁免形态） | 是（enforce） | 标题或 `<!-- principle-exempt: 规范基线 理由 -->`/lineage `pruned` 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `🔒 规范基线`；derived: warn |
| 用户需求原文 | Rule 51.1 | `## 🎯 用户需求原文` | 是（enforce） | 标题或豁免/pruned 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `🎯 用户需求原文`；derived: warn |
| 根源覆盖 | Rule 53.1 | `## 🧮 根源覆盖表` | 是（enforce） | 标题或豁免/pruned 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `🧮 根源覆盖表`；derived: warn |
| Goal 单元 | Rule 66.1 | `## 🎯 Goal 单元表` | 是（enforce） | 标题或豁免/pruned 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `🎯 Goal 单元表`；derived: warn |
| 验证契约 | Rule 84 | `## ✅ Verification Contract`（含 `**Verify command**:`） | 是（enforce） | 标题或豁免/pruned 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `✅ Verification Contract`；derived: warn |
| FMEA 预演 | Rule 22.3 / 方法论 R2 | `## 📊 FMEA 预演` | 是（enforce） | 标题或豁免/pruned 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `📊 FMEA 预演`；derived: warn |
| 证据锚 | Rule 71 | `## 🔍 证据面清单`（证据面/无源不写条款） | 是（enforce） | 标题或豁免/pruned 显式登记；derived 当前按 **warn** 逐步补齐 | mini-lite, l0-lite | base: enforce `🔍 证据面清单`；derived: warn |
| 指令理解迭代 | Rule 28.2.2 | `## 🧭 指令理解迭代草稿` | 是（在途豁免） | base 在途未落盘按登记豁免；derived 标题或豁免/pruned，当前按 **warn** | mini-lite, l0-lite | base: in-flight 豁免（合并后对齐 enforce）；derived: warn |
| 输出示例契约 | Rule 113 / 113.10（输出示例契约 + 展示义务） | `## 🧩 输出示例与格式契约` | 是（enforce） | derived 全 31 档必填（含 mini-lite/l0-lite 极简版）；**标题 token + 示例段含可审查内容**（fenced 示例块或极简档行内 code 真实实例，禁「略/TBD/...」）方为合规，仅 token 即 FAIL；本原则**不随豁免档跳过**；权威实物 `examples/json-template-upgrade/review.md` | 无（用户 2026-11-25 明确要求「所有计划任务必须包含完整示例」+ 晚间「先展示产出实物」裁决） | base: enforce `🧩 输出示例与格式契约` + 内容；derived: enforce（含豁免档，极简档行内 code） |
| lineage（派生治理） | 本任务 S4/S5（模板分级） | `<!-- template-lineage:` 头（derived 必选；base=`level=base` 行） | 是（enforce） | derived 必含 `template-lineage`；base 必含 `level=base` | 无（lineage 为派生治理核心，不豁免） | base: enforce `level=base`；derived: enforce `template-lineage` 头 |

### 备注与口径
- **base**：`skills/task-planner/templates/task_plan.md`，以 `<!-- template-lineage: level=base` 标识。
- **derived**：`skills/task-planner/templates/variant/*.md` 中含 `template-lineage: level=derived` 的模板（当前 29）；`mini-lite-type.md`、`l0-lite-type.md` 为豁免档模板（轻量档，自动跳过）。
- **行内豁免通道**：`<!-- principle-exempt: <原则> 理由 -->`（显式豁免登记）；lineage 头 `pruned` 清单为派生裁剪的显式登记面，防止静默丢失。
- **warn/enforce 分层（S5 落地口径）**：**base 与 lineage 列 = enforce FAIL**（base: 防倒退两区块/规范基线/用户需求原文/根源覆盖/Goal 单元/验证契约/FMEA/证据锚 + `level=base`；derived: `template-lineage` 头）。**warn 列输出计数不计 FAIL**：derived 防倒退指针行 `进度产出基线`（当前 3/29，S3 抽样）及 derived 各原则区块覆盖面（按 `pruned` 裁剪逐步补齐）。**指令理解迭代**：base 在途豁免（主仓未提交改动簇，合并后对齐 enforce），derived warn。逐步补齐后可按 registry 更新将 warn 列翻 enforce。
- **指令理解迭代在途声明**：`## 🧭 指令理解迭代草稿` 为主仓工作树在途区块，当前 worktree HEAD 未含；本轮诚实登记「在途：主仓未提交改动簇，合并后对齐」，禁假称已在位。

## 派生铁律（R5，二级派生与核心传导）

- **派生登记**：derived 模板必须带 `template-lineage` 头，声明 `parent`、`base`、`spec_version` 与 `pruned` 裁剪清单（逐级可追溯）。
- **双参照铁律（二级派生）**：二级派生（从 variant 派生新模板）必须同时参照 base 与 parent（**base+parent 双参照**）再派生；裁剪清单 = 父级裁剪 ∪ 新增裁剪，并逐级对齐 base 重新评估合法性，禁止仅参考直接 parent 导致核心原则传导丢失。
- **核心不可静默丢失**：base 必选原则区块（本表 enforce 列）未经本注册表豁免登记不得从派生链消失；裁剪必须在 lineage `pruned` 与必要时 `<!-- principle-exempt: ... -->` 中显式登记。守卫按本表校验。
- **新原则落地同步**：新原则落地时本表同步登记（原则级联面含模板族），并同步更新守卫断言与 selftest，确保原则的可靠性不因模板演进而漂移。

## 机器可读断言清单（供守卫解析）

```registry-assertions
SPEC_VERSION=1
BASE_TEMPLATE=skills/task-planner/templates/task_plan.md
VARIANT_DIR=skills/task-planner/templates/variant
EXEMPT_VARIANTS=mini-lite-type.md,l0-lite-type.md
OUTPUT_EXAMPLE_TOKEN=🧩 输出示例与格式契约
ENFORCE_BASE=📦 进度产出基线|🛡 防倒退终检|🔒 规范基线|🎯 用户需求原文|🧮 根源覆盖表|🎯 Goal 单元表|✅ Verification Contract|📊 FMEA 预演|🔍 证据面清单|level=base
ENFORCE_DERIVED_LINEAGE=template-lineage
WARN_DERIVED=进度产出基线|🔒 规范基线|🎯 用户需求原文|🧮 根源覆盖表|🎯 Goal 单元表|✅ Verification Contract|📊 FMEA 预演|🔍 证据面清单
IN_FLIGHT_BASE_EXEMPT=指令理解迭代
EXEMPT_MARKER_PREFIX=<!-- principle-exempt:
```
