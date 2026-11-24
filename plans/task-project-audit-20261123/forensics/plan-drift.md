# 计划体系执行层漂移量化巡检报告

- 任务：`task-project-audit-20261123` / 子项【计划体系执行层漂移量化】
- 巡检时间：2026-11-23（只读）
- 仓库：`/mnt/data/dev/task-planner-skill`
- 约束遵守：仅使用只读命令（`find/ls/wc/stat/head/tail/grep/sed/python3` 只读脚本、Read）；未修改任何 `plan-state.json`/MD/hook/模板；仅写入本报告。

## 1. 积压量化（INDEX.md）

**证据命令**：
```bash
cat /mnt/data/dev/task-planner-skill/plans/INDEX.md | wc -l && echo "---" && head -120 ...
tail -40 .../plans/INDEX.md
python3 解析表格行
```

**证据**（`plans/INDEX.md:1-16,58-96`）：
- 头部：`Last refreshed: 2026-11-22_10:02`（`plans/INDEX.md:3`）
- 汇总：`in_progress: 1 | pending: 23 | complete: 16`（`plans/INDEX.md:96`）
- 表格解析结果：`TOTAL_ROWS=40`，`STATUSES={'complete':16,'pending':23,'in_progress':1}`（python3 解析输出）

**pending 中“0/0 且无 goal”空壳**（判定：`status==pending && phase=='0/0' && goal=='(no goal)'`）：

| task_id | phase | goal |
|---|---:|---|
| `task-audit-rework-cap-20261121` | 0/0 | (no goal) |
| `task-crossprojauth-20261104` | 0/0 | (no goal) |
| `task-defect-rrv13-dg12-false-pass` | 0/0 | (no goal) |
| `task-goal-autonomous-20261117` | 0/0 | (no goal) |
| `task-json-state-20261121` | 0/0 | (no goal) |
| `task-positioning-20261115` | 0/0 | (no goal) |
| `task-skillfix-20261105` | 0/0 | (no goal) |
| `task-unknownconcept-research-20261105` | 0/0 | (no goal) |
| `task-v193-skill-goal-drift-fix` | 0/0 | (no goal) |
| `task-workflow-multimodel-delegation-20261109` | 0/0 | (no goal) |

**量化**：
- 空壳数量：**10**
- 空壳率（pending 口径）：**10/23 = 43.48%**
- 空壳率（全部任务口径）：10/40 = 25.00%

**判定**：P1。近半 pending 为无 goal/无 phase 的空壳，占用索引与恢复注意力，反映计划创建/登记流程未闭环。

## 2. plan-state.json vs MD 背离抽样

### 2.1 全局规模

**证据命令**：
```bash
find /mnt/data/dev/task-planner-skill/plans -maxdepth 2 -name 'plan-state.json' | wc -l  # 7
find /mnt/data/dev/task-planner-skill/plans -maxdepth 2 -name 'task_plan.md' | wc -l      # 44
```

**现象**：仓库 44 个任务有 `task_plan.md`，仅 7 个有 `plan-state.json`（15.91%）。说明 JSON 权威源尚未覆盖历史存量，双轨并存。

### 2.2 5 个 in_progress/pending 抽样

**抽样**（按任务要求随机抽 5 个 in_progress/pending；实际取 1 in_progress + 4 pending，含 2 个空壳与 2 个有 goal pending）：

| task | status(INDEX) | plan-state.json | task_plan.md | JSON 业务字段(req/goals/phases) | MD 行数 | GENERATED_HEADER/勿直接编辑/Auto-rendered 标记 | 背离判定 |
|---|---|---:|---:|---|---:|---|---|
| `task-jsonderive-deploy-20261122` | in_progress | 342B, exists | 48253B | 空/空/空（0/0/0） | 642 | **有**（`task_plan.md:38` 有 `GENERATED_HEADER`；`:2` 有 `<!--`；`:22` 含 `plan-state.json`） | **是：JSON 空壳但 MD 庞大** |
| `task-anchor-eread-20261113` | pending | 不存在 | 3034B | N/A | 33 | 无 | 旧 MD-only（无 JSON） |
| `task-goal-ask-fix-20261118` | pending | 不存在 | 799B | N/A | 14 | 无 | 旧 MD-only（无 JSON） |
| `task-audit-rework-cap-20261121` | pending | 不存在 | 2117B | N/A | 26 | 无 | 旧 MD-only 空壳任务（INDEX 0/0 无 goal） |
| `task-crossprojauth-20261104` | pending | 不存在 | 34171B | N/A | 92 | 无 | 旧 MD-only，内容较大但无 JSON 权威源 |

**抽样命令证据**：python3 逐任务读取 `stat().st_size`、JSON keys/空值、MD 行数与标记；输出见巡检终端记录（关键行：`task-jsonderive-deploy-20261122` JSON 342B/req0/goals0/phases0，MD 48253B/642 行/has GENERATED_HEADER）。

### 2.3 全量 plan-state.json 背离扫描（补充量化）

**证据命令**：python3 遍历 7 个 `plan-state.json`，检查 `requirements/goals/phases` 是否全空且 MD > 2000B。

结果：
- `DIVERGENCE_COUNT=2`
- `task-jsonderive-deploy-20261122`: JSON 342B，MD 48253B，`has_gen=True`
- `task-git-rework-guard-20261122`: JSON 47927B，MD 46871B，`has_gen=False`，但 `requirements/goals/phases/vcs/findings` 全为 0

**解释**：
- 样本 1 为典型“JSON 空壳但 MD 庞大”（141x 体积比）。MD 含 `GENERATED_HEADER` 标记，说明至少经历过 render/模板形态，但 JSON 语义字段未填充。
- 样本 2 为“JSON 非小但业务字段空 + MD 大且无 GENERATED_HEADER”，表现为权威源未承载业务语义，MD 仍像手工/旧形态承载。

## 3. hook/模板引导检查（是否仍指导“直接 Edit MD”）

**检查范围**：`/home/terry/.zcode/skills/task-planner/{hooks,templates,scripts,SKILL.md,references}`；全局 `~/.zcode` hook 文件发现。

### 3.1 全局 hook 位置事实

```bash
find /home/terry/.zcode -maxdepth 4 -type f \( -name '*hook*' -o -name '*posttool*' -o -name '*pretool*' \)
```
输出仅见：
- `/home/terry/.zcode/skills/task-planner/scripts/register-hooks-cj.ts`
- `/home/terry/.zcode/skills/task-planner/scripts/zcode-posttooluse.sh`
- `/home/terry/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh`
（另有非 task-planner 的 comet/prompt-corrector hook 与 hookify commands）

**结论**：未发现 task-planner 专用 `hooks/` 目录；运行时 hook 引导主要在 `scripts/zcode-*.sh`。

### 3.2 引导证据（planctl 写 JSON 后 render）

| 文件 | 行 | 证据摘录 | 语义 |
|---|---:|---|---|
| `/home/terry/.zcode/skills/task-planner/scripts/zcode-posttooluse.sh` | 267-269 | “状态走 planctl... 4 个 MD=render 派生视图禁手工 Edit”“调研与结论 → planctl add...”“变更后 ... planctl render 刷新派生视图” | 明确禁止手工 Edit MD，要求 planctl+render |
| `/home/terry/.zcode/skills/task-planner/scripts/zcode-posttooluse.sh` | 296-297,302,324-325,330 | “经 planctl add --section ... 写入 plan-state.json（...派生视图，随 render 刷新）” | 细分 actions/errors/research/test_results 的 planctl 路径 |
| `/home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh` | 285 | “先 planctl update/set 更新 Phase/VC/范围+render（task_plan.md 为派生视图）” | 用户新指令进入计划时走 planctl+render |
| `/home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh` | 308 | “[plan-data] 权威源=plan-state.json：状态/语义变更走 planctl 后 render；本回放读取派生视图（4 个 MD 勿手工 Edit）” | 明确权威源与只读视图 |
| `/home/terry/.zcode/skills/task-planner/templates/task_plan.md` | 2 | “正式数据经 planctl add/set 写入 plan-state.json 后 render 派生本视图——直接填写会在首次 render 被覆盖” | 模板禁止直接填写 |
| `/home/terry/.zcode/skills/task-planner/templates/findings.md` | 2 | 同类 planctl+render 派生口径 | 模板禁止直接填写 |
| `/home/terry/.zcode/skills/task-planner/templates/progress.md` | 2 | 同类 planctl+render 派生口径 | 模板禁止直接填写 |
| `/home/terry/.zcode/skills/task-planner/templates/verification.md` | 2 | 同类 planctl+render 派生口径 | 模板禁止直接填写 |
| `/home/terry/.zcode/skills/task-planner/SKILL.md` | 355-356,369,406-407,414 | “JSON 是唯一权威源...4 个 MD 视图一律不得手工 Edit/Write...手工编辑会在下一次 render 被全量覆盖”；“❌ 错误示范：写完直接手工改 progress.md —— 下次 render 全量覆盖” | 技能规范强约束 planctl+render |
| `/home/terry/.zcode/skills/task-planner/scripts/init-session.sh` | 1072-1075,1099-1103 | “init 只建权威源...首次 planctl 数据写入后必须 render...4 MD=派生视图，手工编辑会被 render 覆盖” | init 引导正确 |
| `/home/terry/.zcode/skills/task-planner/scripts/attest-plan.sh` | 82-102 | 空壳检测 WARN：`plan-state.json 业务数据为空而 task_plan.md 已被手工填写（SOFT_ONLY 信号；正确流程=planctl 写入+render）` | 运行时能识别 MD 手填/JSON 空壳信号，但仅 WARN |

### 3.3 是否存在“指导直接 Edit MD”

在检查的 hooks/templates/scripts/SKILL/references 中，**未发现指导“直接 Edit task_plan.md/progress.md/findings.md/verification.md 作为正式流程”的文本**；相反，多处明确“禁手工 Edit/Write”“直接填写会被 render 覆盖”“走 planctl add/set + render”。

**例外/注意**：历史任务产物自身存在手工/旧形态 MD（如抽样中 `task-git-rework-guard-20261122` 无 GENERATED_HEADER 且 JSON 业务字段空）；这属于执行层漂移结果，不是当前 hook/模板指导文本。

## 4. 逐项判定

| 项 | 现象 | 证据 | 根因 | 严重度 | 建议（仅文字） |
|---|---|---|---|---|---|
| 积压与空壳 | pending 23 个，其中 10 个为 `0/0 + (no goal)` 空壳 | `plans/INDEX.md:58-96` 汇总；python3 解析 TOTAL_ROWS=40, EMPTY_SHELLS_PENDING=10 | 计划登记/立项流程缺少硬门：创建索引行或目录后未补 goal/phase/plan-state；历史遗留未清理 | P1 | 对空壳 pending 做一次性 triage：补全 goal/phase 或归档/删除；在 plan 创建入口增加“goal+phase 非空”校验；INDEX 刷新时标注空壳告警 |
| JSON/MD 覆盖不足 | 44 个 task_plan.md 仅 7 个 plan-state.json | `find ... plan-state.json | wc -l = 7`，`task_plan.md = 44` | 迁移期兼容保留了 MD-only 存量；未强制回填 JSON | P1 | 设定迁移策略：活跃/in_progress 优先迁移到 plan-state.json；存量 pending 明确“冻结/归档/迁移”状态，避免双轨无限期并存 |
| JSON 空壳但 MD 庞大 | 抽样命中 `task-jsonderive-deploy-20261122`：JSON 342B 空业务字段，MD 48253B/642 行，有 GENERATED_HEADER | `plans/task-jsonderive-deploy-20261122/plan-state.json`（req/goals/phases/vcs/findings 空）；`task_plan.md:2,22,38`；全量扫描 DIVERGENCE_COUNT=2 | 执行者未按 planctl 写入语义数据，仅产出/保留了大 MD；render/模板形态存在但权威源未被填充；attest 仅 WARN 不阻断 | P0 | 将 attest 的 SOFT_ONLY 空壳信号升级为 active/in_progress 的阻断或强显眼门（需用户授权后改）；在 planctl/render 前增加“业务字段非空或显式豁免”检查；对该任务做 JSON 回填或判定作废 |
| 业务语义未入 JSON | `task-git-rework-guard-20261122`：JSON 47927B 但 req/goals/phases/vcs/findings 空，MD 46871B 无 GENERATED_HEADER | python3 输出 top_keys=15, 业务字段 0；MD head 无生成标记 | 可能是旧计划被部分 JSON 化但未迁移业务段，或写入路径绕过 planctl 业务 section | P1 | 对有 plan-state.json 的任务加“业务段完整性”审计；迁移工具应覆盖 requirements/goals/phases/vcs/findings/decisions/actions/errors |
| Hook/模板引导 | 当前 hook/模板/SKILL 主体引导 planctl+render，明确禁手工 Edit | `zcode-posttooluse.sh:267-269,296-330`；`zcode-userpromptsubmit.sh:285,308`；`templates/*:2`；`SKILL.md:355-356,369,406-407,414`；`init-session.sh:1099-1103`；`attest-plan.sh:82-102` | 文案层已纠偏；漂移主要在执行遵从与历史存量，不在当前引导文本 | P2 | 保持现有引导；补充“检测到手工编辑 MD 后自动提示/阻断”的执行层机制（需用户授权） |

## 5. 核心命题结论

**命题**：历史记忆声称的“planctl 替换 markdown 未起效、执行层 SOFT_ONLY”在当前仓库是否仍成立？

**结论：部分成立（Yes for 执行层残留 / No for 引导层）。**

- **“planctl 替换 markdown 未起效”——执行层仍部分成立**：证据显示 44 个 task_plan.md 中仅 7 个有 plan-state.json；抽样 5 个里 4 个无 plan-state.json；全量 7 个 JSON 中 2 个出现业务语义空壳/未承载（`task-jsonderive-deploy-20261122` JSON 342B vs MD 48253B；`task-git-rework-guard-20261122` 业务字段全空但 MD 46871B）。这表明替换尚未在执行层彻底落地。
- **“执行层 SOFT_ONLY”——仍部分成立**：`attest-plan.sh:82-102` 对“plan-state.json 业务数据为空而 task_plan.md 已被手工填写”仅输出 WARN，不阻断；hooks/SKILL 虽已强文案约束，但缺少对手工编辑 MD 的硬拦截证据（pretooluse 未见对应 MD 编辑阻断；posttooluse/userpromptsubmit 为提醒）。
- **引导层“仍指导直接 Edit MD”——不成立**：当前 hook/模板/SKILL 明确要求 `planctl add/set/... + render`，并多处标注“派生视图禁手工 Edit/Write”。

**量化支撑**：JSON 覆盖率 7/44=15.91%；pending 空壳率 10/23=43.48%；抽样背离 1/5 为典型 JSON 空壳+大 MD；全量 JSON 业务空壳背离 2/7=28.57%。
