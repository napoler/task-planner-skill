# Knowledge Brief — task-v078-guard-fp-fixes（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 20（template-guide.md:65 验收）
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：修复两类守卫误报（提醒链对已交付计划误报 + check-dispatch 打包检测误计示例 ID），各自 selftest 守护，全量 20 脚本 0 FAIL 后合并 master 并部署 3 位 push。
- 背景/动机：v077 交付报告 deferred 区遗留的两个误报点——①本仓约定 outcome 写 verification.md 而提醒链豁免只查 task_plan.md → 豁免永不触发（v076/v077 连续误报）；②check-dispatch 打包检测全位置计数 `S[0-9]+` 把契约条文示例 ID 计为多 S-unit 打包阻断（v078 考古派发即被实证拦截一次）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 提醒链 | zcode-posttooluse.sh（PostToolUse hook）对陈旧 plans 的 plan-compass/plan-sync/升级警告生成源 |
| 打包检测 | check-dispatch.sh L264 `grep -oE 'S[0-9]+'` 全位置计数，≥2 个不同 S-unit ID 即判定打包（Rule 22.6） |
| 双条件豁免 | prompt 同时含「任务书」+ `subagent-state/` → 打包检测出 SKIPPED 提示不阻断（Rule 35.3 落盘任务书范式） |
| 3 位部署 | 主仓副本 smart-merge-back --deploy 到 3 个部署实体位（diff -r 复验=0） |
| Total 求和 | 主进程对 20 个 selftest-*.sh 逐脚本 Total 行 awk 机械求和 PASS/FAIL（禁采信子代理自报总数） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 既有豁免只查 task_plan.md outcome，L100 `grep -qiE 'outcome: *(COMPLETE\|BLOCKED)'` 未命中即继续 | 01-explore.md §①（zcode-posttooluse.sh L100） | 修复=S3 在 L100 后补 verification.md 兜底分支（同目录、同正则、-qi 容前导空格） |
| 本仓约定 outcome 写在 verification.md（v076/v077 均如此） | 01-explore.md §① | 兜底分支命中后 `exit 0` 不再触发 compass/sync 陈旧提醒 |
| L264 打包计数为全位置匹配（注释 L45-47 定死口径） | 01-explore.md §②（check-dispatch.sh L264/L45-47） | S4 豁免须在 L264 计数前短路，非豁免 prompt 行为不变 |
| 单条件 subagent-state/ 豁免=废掉打包门（所有合规派发检查点路径都在其下） | 01-explore.md §②（L68/290/300） | 被否决方案登记——禁用单条件，必须双条件 |
| FG-03（L254-264）为唯一多 S-unit 检测用例，断言含 'S-unit ID' 文案 | 01-explore.md §②（selftest-dispatch.sh） | S4 新增 FG-05（正向豁免）时 FG-03 原样保留（反向回归） |
| execution-stability T11a/b（:106-135）fixture 无 outcome/verification.md | 01-explore.md §①（selftest-execution-stability.sh） | 加兜底不改 T11a/b 既有行为；S5 前置先跑 T11a/b 基线 |
| .gitignore 已补 `plans/**/.session-owner`（check-ignore 验证生效）；旧哨兵 038d...plan_required staged 待删 | 01-explore.md §③ | S8 簿记提交随带 .gitignore/.session-owner 与旧哨兵删除 |
| 并行存根 plans/task-v079-skill-modify-conservatism/ 非本会话所建 | 01-explore.md §③ | 不碰不提交，登记隔离决策表 conflict_scan=risk |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/scripts/zcode-posttooluse.sh | :100 | 既有 outcome 豁免（L101 exit 0）；:97 24h 静默；:106-119 配置读取（SKILL_ROOT :105）——S3 只动 L100 一带，≤4 行 |
| skills/task-planner/scripts/check-dispatch.sh | :264 | 打包计数 `grep -oE 'S[0-9]+'`；L265 计数/L266 ≥2 判定/L267 文案/L269 hits；warn 分支 L278-285、enforce exit 2 L286-287；get_mode L113-127（config:61 默认 enforce） |
| skills/task-planner/scripts/selftest-dispatch.sh | :219-276 | FG-01 L219-240 基线 / FG-02 L242-252 超长 / FG-03 L254-264 多 S-unit（:256 prompt、:261 断言 'S-unit ID'）/ FG-04 L266-276 brief |
| skills/task-planner/scripts/selftest-execution-stability.sh | :16/:42/:106-135 | :16 POSTTOOL 定义；:42 T3 静态；:106-107/:133-135 T11a/b 行为执行（mk_fixture 既有手法） |
| plans/task-v078-guard-fp-fixes/subagent-state/01-explore.md | 全文 | 本轮全部锚点与设计裁决的唯一权威来源（锚点禁凭记忆改写） |

## §4 易错点与禁止假设清单
1. 禁止假设单条件 subagent-state/ 豁免可用（考古 ①L68/290/300 证伪——所有合规派发路径都在其下，单条件=打包门全废）；必须「任务书」+ `subagent-state/` 双条件同时命中。
2. 禁止把兜底正则放宽为非终态词：只认 `COMPLETE|BLOCKED`，否则未交付计划也被豁免（FMEA 第 2 行）。
3. 禁止改动 zcode-posttooluse.sh :97（24h 静默）与 :106-119（配置读取）逻辑；改动 ≤4 行最小化（运行中基础设施，部署位实时加载）。
4. 禁止删改既有 selftest 用例（selftest 只增不减）；S5 前置先跑 T11a/b 基线再动 fixture 相关写法。
5. 禁止凭记忆改写 01-explore.md 锚点值（行号/正则/文案以该文件实核值为准）。
6. 禁止采信子代理自报 Total 总数：全量 0 FAIL 由主进程逐 Total 行 awk 求和定数。
7. 禁止触碰 plans/task-v079-skill-modify-conservatism/（并行存根，非本会话所建，不碰不提交）。
8. 禁改 SKILL.md / config.json（零新键）/ references / templates / critical-rules.md。

## §5 S-unit 材料包索引（与 task_plan.md S-unit 表「输入」列互链）

| S-unit | 材料包（路径 + 对应节锚点） | 说明 |
|--------|---------------------------|------|
| S1 | 01-explore.md §③ → 本 brief §4.7/§2（并行存根不碰） | worktree 建立 + 基线 commit |
| S2 | 01-explore.md §① → 本 brief §2（compass/stale 零覆盖、T11a/b fixture 无 verification.md） | 全量基线 337/0 |
| S3 | 01-explore.md §① → 本 brief §3（zcode-posttooluse.sh :100/:97/:106-119） | verification.md 兜底 |
| S4 | 01-explore.md §② → 本 brief §3（check-dispatch.sh :264、selftest-dispatch.sh :254-264） | 双条件豁免 + FG-05 |
| S5 | 01-explore.md §① → 本 brief §3（execution-stability :106-135） | 行为用例 + T11a/b 回归 |
| S6 | task_plan.md VC-5 → 本 brief §1（Total 求和） | 全量回归定数 |
| S7 | task_plan.md Decisions Made | CHANGELOG 条目 |
| S8 | 01-explore.md §③ → 本 brief §2（.gitignore/旧哨兵/并行存根） | 合并回+部署+簿记 |
