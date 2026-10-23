# 8a-cr-alignment — 对齐审查员检查点（只读审查，零源文件改动）

- status: done
- date: 2026-10-24
- 审查对象：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023`（HEAD=886f060，未提交增量 7 M + 1 ??）
- 审查基线：plans/task-subagent-boost-20261023/draft-rule96.md（§2 全文+§3 六编辑+§4 selftest 设计）+ 检查点 1-rule-mapper.md / 2-anchor-mapper.md（另参考 5/6 检查点核对其声明）

## VERDICT: APPROVED

（nit 级观察 4 条见文末；无 BLOCKER）

## 一、判定依据（全部本会话实跑/实读，标注命令）

### 1. 增量立法——禁改写 21.4/22/46/52 语义 ✅
- `git diff -U0`（dispatch.md + 核心critical-rules.md）hunk 全集恰 3 处：dispatch.md:4（头注编号随动）、dispatch.md `@@ -185,0 +186,29 @@`（文件尾纯追加 29 行）、核心 critical-rules.md:193（枚举尾 `,96`）。21.4(:25-32)/22(:48-79)/46(:112-130)/52(:133-143) 权威全文区间**零 hunk**。
- `diff <(sed -n '46,74p' draft-rule96.md) <(sed -n '186,214p' critical-rules-dispatch.md)` = 空 → 草稿 §2 与落盘 Rule 96 逐字节一致（29 行：溯源注释+96 标题+建制+96.1-96.6）。
- `grep -c '^96\.[1-6] '`=6、`^96\.7`=0（六子条封顶，无越界）；`wc -l`=214（185+29）。
- 96.6 管辖边界+「冲突时以被引条款为准」自限在位；21.4「未声明者默认串行」原文在位（SA-14 实测 ≥1）；68.2 论证义务未废除（96.3 明文衔接）；零新机器门/零新 config 键（diff 无任何脚本逻辑变更）。
- SKILL.md/模板改动全部为枚举扩员、纪元字面、纯追加行（见 3）。

### 2. 管辖与编号 ✅
- 编号合法：plans/.rule-reservations.jsonl 尾两行 `rule:95→task-nopause-execfirst-20261023`、`rule:96→task-subagent-boost-20261023`——本任务用 96 未碰 95。
- 落点校正（draft §0）：Rule 96 全文落卫星 dispatch.md 尾、核心仅动 :193 枚举——符合核心 Rule 82 分层纪律（check-point 1 §一 依据一致）。
- 交叉引用锚实存（亲 grep）：25.5=dispatch.md:108、43.2=task-discipline/critical-rules-discipline.md:165、22.3=dispatch.md:53、59.4=dispatch.md:158、68.3=dispatch.md:177、agent-model-tiering=仓内既有引用（dispatch.md 多处+plan-cost-guard/cost-control.md+task-planner/companion/agents/plan-writer.md）。

### 3. 锚点与级联完备 ✅（对照检查点 2 冻结清单）
- SKILL.md：`grep -cE '1-96([^0-9]|$)'`=3（:9/:209/:252）、`52,59,68,96`=2（:16/:195）、`其余 78 条`=2（:9/:209）、`Rules 1-94`=0、`77 条`=0、`wc -l`=268≤275（BP-08）。
- 核心 critical-rules.md:193 枚举含 `,96`（亲读行内容）。
- dispatch.md 头注 :4 = draft 编辑 1 随动原文（亲读）。
- 模板逐字节比对（去草稿 markdown 引号壳/前导空格后 diff=空）：task_plan.md:327（draft:110）、:495-497（draft:112-114）、subagent_dispatch.md:34 并发句、SKILL.md:245 指针句（draft:103）全一致；指针句落「派发与执行纪律指针」段末（sed -n '239,246p' 亲读）。
- run-selftests.sh :11 `76→77`、:79 `72→73`（diff 亲读）。

### 4. 机器门实跑（本会话亲自执行）✅
- `bash skills/task-planner/scripts/selftest-subagent-activation.sh` → **SA-01..15 全 PASS，Total 15/15，rc=0**（SA-03 七类锚 7/7）。
- `bash skills/task-planner/scripts/selftest-registry.sh` → T01-T05 全 PASS（rows=93/actual=93 双向配平，rc=0）。
- 抽样 10 个级联相关既有 selftest 全 rc=0：batch-pilot/parallel-scheduling/session-log/plan-tier/absorption-discipline/veto/error-loop/conclusion-discipline/capability-persistence/lane-advancement。
- 新脚本 `-rwxr-xr-x`（+x 在位，ls 亲证）。

### 5. 用户诉求覆盖（对照 task_plan.md:7「🎯 用户需求原文」R1-R3 实存区块）✅
- ①激活率：96.1 七类触发类别矩阵（A1 制定计划/A2 调研分析/A3 多文件搜索/A4 大文件/A5 验证审查/A6 批量/A7 创作）默认派发 + 主进程窄白名单例外（须登记一句话理由）→ 直治「制定计划/调研分析被主进程吞掉」。
- ①模型分档：96.2 计划期正向三档判定（轻 haiku-1/中 sonnet-1/重 GLM5.3·Opus 级既有通道）→ 直治「子代理切大/小模型提质省成本」。
- ②并行率：96.3 计划期并行硬标注（≥2 无依赖必须声明组，未声明未论证=计划缺陷）+ 96.4 同消息并发派发（禁止逐个等返回）+ 96.5 指标留痕（激活子代理数/最大并行宽度）→ 直治「经常只开 1 个并行子代理」。

### 6. 铁律遵守 ✅
- 禁 commit：`git log -1`=886f060（=master 基线）、`git log master..HEAD | wc -l`=0。stash@{0} 为 task-v141 时代旧 WIP（d806d05），非本任务产物。
- 禁触碰 plans/ 其他任务目录：worktree diff/status 无任何 plans/ 文件。
- 审查员自身零源文件改动：仅写入本检查点。

## 二、nit 级观察（不阻断，留簿记/S7 消化）

1. **SA-14 断言面偏离设计稿（已留痕、守卫增强）**：draft §4.1 SA-14 为 3 合取项（「超档拆细不升档」被记为 59.4 在位锚）；实现为 4 合取项并重定位——亲证校正属实：59.4 原文（dispatch.md:158）=「先拆细再派，禁止派出去等失败再兜底」，无「超档拆细不升档」字串；该四字串仅存在于新 96.2（:206）复述句。实现同时守住 59.4 真实原文+96.2 复述，断言总数仍 15。脚本头注+selftest 1:18-19+6-machine-gate.md 三处留痕。可接受。
2. **run-selftests.sh 注释钉 77/73 延续基线历史失真**：实测 selftest-*.sh=93 个（registry rows=93），注释钉按 draft 编辑 6 的 +1 口径（76→77/72→73）执行——基线注释本就失真（无门）。是否校真留 S7/簿记裁决（检查点 6 blockers 栏已如实注记）。
3. **全量回归未跑（计划内归属，非本审查射程）**：`run-selftests.sh --fresh`（93 脚本 ≈8-18min）归 S7 lane，draft §4.4-6 与检查点 6 均如实声明未跑；本审查抽样 12 个全绿不替代全量回归。
4. **Rule 96 溯源注释引文口径**：注释自称「原话（抄录于…区块）」，但 ①② 引文实为共享背景的两点诉求概括措辞（与任务书逐字一致），非 task_plan.md:7 R1-R3 逐字原文；指针指向正确、语义忠实、R1-R3 全文实存可溯。建议簿记时把 ①② 视为「诉求摘录」而非「原话」即可，无需改文。

## 三、未跑/未见项（如实报告）

- 未跑全量 selftest 套件（见 nit-3，S7 lane 归属）。
- 未验证运行时部署位（~/.zcode/）——非本任务射程（检查点 1 §三：install/sync 范畴）。
