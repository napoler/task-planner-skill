# Code Review 复审记录（第 2 轮）— task-kb-deploy-20261022 / task-kb-cr-fix-20261022

- 复审对象: 合并提交 `eaa58af`（修复分支 `wt/task-kb-cr-fix-20261022`，修复提交 `14d6673`），基线 `9ec6fea`
- 代码面实际变更范围: `git diff --name-only 9ec6fea eaa58af` → 仅 2 个代码文件
  （`skills/task-planner/scripts/check-scope.sh`、`skills/task-planner/templates/task_plan.md`）；
  其余 5 个差异为 `plans/task-kb-deploy-20261022/` 簿记文件（a955005/bb3a80b/3dd4ef1/aaa01c6 四个 bookkeeping 提交，非代码面）
- 复审方式: 只读（未修改任何被审文件，未做 git 写操作；checkpoint 文件除外）
- **结论: VERDICT: CR APPROVED WITH NITS**（上轮 1 Blocker + 1 自有缺陷均已修复并经实测复验；余项全部非 Blocker）

---

## Blockers

**无。** 上轮唯一 Blocker 已修复并独立复验。

### [已修复并复验] `skills/task-planner/scripts/check-scope.sh:115-132` — 口径① 会话级轻量标记不再对任意路径放行
- 修后实现（:121-131）: 标记存在时先走 `case "$_fp" in "$ROOT/tmp/"*|"$ROOT/output/"*|"$ROOT/.cache/"*`，再走 `git -C "$ROOT" check-ignore -q -- "$_fp"`；都不命中 → 打 `⚠ 轻量档标记存在但目标非机械产物区（$_fp）→ 按仓库受管文件拦截` 并落到 :133-143 的 ② 分支（同样不命中）→ `return 1`。
- 复验矩阵（/tmp 夹具，`TASK_PLANNER_SID=sess-abc123`，实际执行）:

  | 场景 | 目标 | 修后期望 | 修后实测 |
  |---|---|---|---|
  | 哨兵 + 标记 | `src/main.py`（受管） | 1 | **exit 1**（`⚠ 轻量档标记存在但目标非机械产物区`）|
  | 哨兵 + 标记 | `tmp/a.json` | 0 | exit 0（轻量档放行 + 机械产物区）|
  | 哨兵 + 标记 | `tmp/b.txt`（gitignore） | 0 | exit 0（轻量档放行 + gitignore 区）|
  | 哨兵，无标记 | `src/main.py` | 1 | exit 1（`🚫 本会话计划哨兵未满足`）|
  | 哨兵，无标记 | `tmp/a.json` | 0 | exit 0（机械产物区放行，无回归）|
  | legacy `.plan-required` + 标记 | `src/main.py` | 1 | **exit 1** |
  | legacy `.plan-required` + 标记 | `tmp/a.json` | 0 | exit 0 |
  | legacy `.plan-required`，无标记 | `src/main.py` | 1 | exit 1 |

  旁路封堵成立；两个放行口径（side 哨兵 / legacy 哨兵）同边界；机械产物区与无标记路径零行为回归；`bash -n` 通过。
- 注释与实现现一致: :99「两个口径均不放开仓库受管文件的写入拦截」已与 :116-120 的实现和 Why 注记（含 CR 归属）自洽。
- 置信度: HIGH

### [已修复并复验] `skills/task-planner/templates/task_plan.md:355` — §7 悬空指针已消除
- 修后原文: `条目规范见 knowledge/README.md（项目级 knowledge-brief.md §7 入库回链段，若有）`
- 复验: `knowledge/README.md` 在位；`skills/task-planner/templates/knowledge-brief.md` 仍为 §1-§6（基模板无 §7，符合事实）；`.zcode/plan-templates/knowledge-brief.md:79` 的 §7 以「若有」条件式引用 → 非本仓项目不再悬空。
- 置信度: HIGH

---

## Suggestions（均为非 Blocker，不阻断本轮）

### S-1 `skills/task-planner/scripts/task-plan-init.cjs:103-115`（尤其 :114 文案）— 标记被限权后，整会话放行的真实来源变成「不写哨兵」，:114 的归因文案已不准确
- 原文（:114）: `console.log('[task-plan] ✅ 轻量档命中（机械操作词面「' + lmKw + '」）→ 不写哨兵文件，跳过计划门控（check-scope.sh 轻量放行分支消费 .plan_lightweight 标记）');`
- 原因: 轻量会话**根本不写哨兵**，而 check-scope 的标记判定只嵌在两个「哨兵存在」分支内 → 在轻量流真实形态下（无 sentinel、无 legacy `.plan-required`）标记分支永不可达，实测 `Write <project>/src/main.py` = exit 0（与无标记对照完全相同）。即：修复后「仅放行机械产物区」的收敛只覆盖「哨兵与标记并存」（旧哨兵残留/会话恢复）这一路径，而完整轻量会话仍是整会话无计划门控；:114 把豁免归因于 marker，与实际机制（缺哨兵）不符。
- 影响面: 与上轮相同的前置条件（平台是否透传 prompt；作者注记自述当前 hook 链 `promptText` 恒空 → 不可达），故**非回归、非 Blocker**；但这是本次部署引入的语义，建议显式化。
- 修复（二选一）:
  1. 轻量会话仍写哨兵（只写不清），让 marker 只放宽机械产物区——此时本轮修复的收敛才端到端生效；
  2. 若确认「轻量会话=整会话免计划门控」是用户授权的 P1 本意，则把 :99/:114 两处注释改成该真语义（并注明 `fix`/`简单` 等子串匹配会让普通开发指令也落入该档），避免后续审查者按「仅机械产物」误读。
- 置信度: HIGH（行为已实测）｜触发可达性 MEDIUM（依赖 prompt 透传）

### S-2 `skills/task-planner/scripts/check-scope.sh:121-130` 与 :133-142 — 修后出现 12 行完全同构的重复判定
- 原文: 两段均为 `case "$_fp" in "$ROOT/tmp/"*|"$ROOT/output/"*|"$ROOT/.cache/"*)` + `git -C "$ROOT" check-ignore -q -- "$_fp"`
- 原因: 口径① 复用口径② 的等价实现被复制而非抽取；同一「机械产物区」定义日后若只改一处即产生口径漂移（与上轮 `*/.k8s/*` vs `*/k8s/*` 同类风险）。
- 修复: 抽 `_is_mechanical_artifact_path() { case "$1" in ...;; esac; git -C "$ROOT" check-ignore -q -- "$1"; }`，两处调用 + 仅在调用侧区分提示文案。
- 置信度: HIGH

---

## Nits（沿用上轮未修项，均非阻断）

- **N-1 `skills/task-planner/scripts/check-scope.sh:22-23`** — Exit codes 头注仍只写 `0 = ALLOWED (无项目根 / 哨兵不存在 / D10 仲裁放行 / 写 plans/ / 豁免文件名)`，未列「轻量档 + 机械产物区 / gitignore 区」。建议补两项，便于排障时区分 exit 0 来源。置信度 HIGH。
- **N-2 `skills/task-planner/scripts/check-scope.sh:123/128/131`** — 放行成功与 ⚠ 留痕仍写 stdout（`zcode-pretooluse.sh:18` 未重定向）。建议改 `>&2` 保持 hook stdout 协议干净。置信度 MEDIUM。
- **N-3 `skills/task-planner/scripts/check-delegation.sh:437`** — `# [2026-10-07 task-v055-fix-review] B-1/M-1:...` 与同事件另 11 处 `2026-09-07` 不一致且无修改说明（Rule 45.4）。建议回改或补并集订正注记。置信度 HIGH。
- **N-4 `skills/task-planner/templates/task_plan.md:353` vs `:355`** — 相邻两行路径基准混用（`<skill>/scripts/` 与仓根 `scripts/`）。建议统一基准。置信度 HIGH。

---

## 上轮其余遗留项归类确认（本轮不要求修）

请求前提是「非 Blocker 的既有缺陷、且不在本次部署引入范围内」。逐项核实结果：**「非 Blocker」全部成立；「不在本次部署引入范围」仅第 5 项成立，第 1-4 项实为本次部署（9ec6fea）引入/激活的非阻断缺陷**，建议归类时按此更正（避免后续被误记为"历史遗留"而永久不修）。

| # | 项 | 是否 Blocker | 引入方（实测依据） |
|---|---|---|---|
| 1 | `check-delegation.sh:251` `*/.k8s/*` vs `:351` `*/k8s/*` | **非 Blocker**（fail-closed：需同时命中 gitignore 区才可能放行 k8s 清单；影响面=极窄边界；注释「同源」失准） | **本次部署引入**：`is_protected_path()` 由 9ec6fea 首次新增（9ec6fea 前不存在该函数），14d6673 未触及 |
| 2 | `check-tier-consistency.sh:61` 把 `execution_lane: L0-E` 解析成 L0（实测 2-Phase L0-E 夹具 exit 1） | **非 Blocker**（L0-E 条款本身「免计划」，带 L0-E 头的计划属罕见形态；影响=终验误拦/连带跳门，非数据面） | **本次部署引入**：L0-E 档由 9ec6fea 引入（新档名与旧解析器前缀碰撞），14d6673 未修 |
| 3 | 51.13 无 selftest 守护（仅 RC-24..27 = 51.9-51.12） | **非 Blocker**（守护覆盖缺口，非条款失效；条款文本在位） | **本次部署引入**：51.9-51.13 与 RC-24..27 均于 9ec6fea 落地 |
| 4 | `selftest-requirement-coverage.sh:8` 头注 `RC-01..RC-23` 与实际 RC-27 不符 | **非 Blocker**（纯注释失真，不影响断言正确性；实测 Total 27 PASS=27） | **本次部署引入**：base 2448e01 头注 RC-01..RC-23 与实际条数一致，9ec6fea 增 RC-24..27 未同步头注 |
| 5 | `README.md:81` / `docs/ARCHITECTURE.md:4` 「非核心 74 条」vs 实测 76 | **非 Blocker**（口径失真，不驱动任何门控） | **确为既有**：base 2448e01 已写 74（`git show 2448e01:...README.md` 命中 74），本次两提交均未触及 |

补充: 第 1/2 项属「新机制与旧消费端未对齐」型技术债，建议在下一轮 L0-T 纯文本登记进 findings/待修清单（本轮不修不阻断）。

---

## 回归与部署复验（本轮实跑）

- 全量 selftest（master 工作树）: `bash skills/task-planner/scripts/run-selftests.sh --fresh`
  → `Total: 92 PASS=92 FAIL=0 (run=92 reused=0)`，exit 0（**独立复现作者的 92/0 结论**，全程 fresh 无缓存粉饰）
- 语法: `bash -n skills/task-planner/scripts/check-scope.sh` → OK
- 部署位: `diff -rq skills/task-planner ~/.zcode/skills/task-planner` → **IDENTICAL**；
  `~/.claude`、`~/.cursor` 各 9 个差异文件，逐文件 diff 行数 2/10/2/6/4/6/2/2/2，全部为 `node --experimental-strip-types` ↔ `bun run` 运行时 flavor；`check-scope.sh` 与 `templates/task_plan.md` **未出现在差异列表** → 本轮修复已同步到三位。
- 工作树清洁: 执行上述命令后 `git status --short` 仅本 checkpoint 文件（未污染仓库）。

## 负结果（本轮检查但未发现问题）

- 修复未越界改动: 代码面 diff 仅 2 文件（`check-scope.sh` +17/-3、`task_plan.md` +1/-1），无夹带、无格式重排、无无关文件。
- 修复未放宽其他拦截语义: 无标记 / legacy 哨兵 / 机械产物区 三组对照全部与修前一致（见上方矩阵 5-8 行）；`plans/` 豁免、D10'/D10'' 仲裁、白名单表均未触碰。
- 未引入命令注入/未加引号展开: 新增分支沿用 `"$_fp"` 引号化与 `git -C "$ROOT" check-ignore -q -- "$_fp"` 写法。
- 重复粘贴/截断: `_lightweight_release` 单次定义、函数尾 `return 1` 完整、文件尾 `exit 0` 在位。
- 文档侧: §7 指针修复后全文仅剩历史记录中的旧表述（plans/ 内），技能与模板面零悬空引用。
