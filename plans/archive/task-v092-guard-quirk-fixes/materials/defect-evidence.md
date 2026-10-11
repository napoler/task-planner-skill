# 缺陷取证材料包（S-unit 材料包 · 计划期主进程考古产出）

> 来源：task-v091 verification.md:24/:83 遗留披露 + progress.md:74/79/84/85 deferred 登记 + subagent-state/S16-plan-parse-lib.md、S32-verify-group3-a3.md checkpoint。仓库基线 = master 0b2208b，全量 selftest 基线 518 PASS / 0 FAIL（32 脚本）。

## 缺陷 1+2：check-conflicts.sh runtime 模式 INDEX 解析（登记 progress.md:85，S18 界定）

- **1a（:118 一带）INDEX 解析管道缺陷**：`active_plans` 恒空 → 运行时 A（同文件）/B（同 worktree）/C（同 task-id）三检测维度实际从不触发。
  - 代码锚点：`skills/task-planner/scripts/check-conflicts.sh:123-145`——`while IFS='|' read -r task_id status phase_total goal mtime _icon`，输入管道 `sed -n '/^| Task ID/,/^|-------/p' plans/INDEX.md | tail -n +2 | grep '^|' | sed ... | awk -F'|' ...`。
  - 机理待实证（Phase 1 取证确认）：候选根因 = sed 区间模式对 INDEX.md 实际表头形态不匹配 / `tail -n +2` 行位错 / status 字段实际含格式（如 `in_progress` 之外的空白或标记）致 `[[ "$status" != "in_progress" ]]` 恒真跳过。修复前必须先跑管道逐段实测真实输出（修 bug 前先 Read 真实数据样本）。
  - **夹具联动**：`selftest-check-conflicts` 的 CC-06 夹具依赖畸形 INDEX（progress.md:84 登记"修 :118 缺陷时须同步改造"）。注意 v091 S16 已将 scope 提取接 `lib/plan-parse.sh`（plan_parse_scope，:134-139 注记），修复不得回退该语义。
- **1b（:145 一带）自计划跳过恒不等**：当前计划目录（current_plan_dir，:147-157 mtime<86400 判定）与 active_plans 内条目的相等/跳过判定恒不成立（登记原文":145 自计划跳过恒不等"）。机理待实证：候选 = 路径形态不一致（`plans/$task_id` 相对 vs `$repo/plans/*` 绝对）或 task_id 前后空白未剥净。

## 缺陷 3：check-drift.sh 两 quirk + 第 5 处复制（登记 S32-g3 checkpoint ①② + progress.md:85）

- **3a（quirk ①）`check_phase_order` 初值误报**：`prev_status` 初值 `pending` 使「全 Phase complete」序列恒误报 `CRITICAL PHASE-SKIP`（ALIGNED 夹具也被误报 rc=1）。锚点：check-drift.sh 内 check_phase_order 函数（grep 定位）。
- **3b（quirk ②）`check_scope_breach` 提取取不到列**：:205 起 awk 区间提取 + `sed 's/.*|//;s/|.*//'` 取尾列——两列范围表取不到「允许的文件」列 → 恒 SCOPE-NONE 跳过（S32 checkpoint ②）。
- **3c（:205 第 5 处复制）区间式 awk 同型 bug**：`awk '/^## ⚠️ 执行范围限制/,/^## /'` 起始行同配终止模式恒为空（gawk 5.2，memory「区间式 awk scope 提取 bug」已登记；task-v053 已将仓内 4 处状态机化，此处为 S16 发现的第 5 处漏网，progress.md:85 登记）。
- **修复方向（计划期裁定输入，非定论）**：S16 建库 `lib/plan-parse.sh`（plan_parse_scope，点分整格语义，头注 3 调用方清单中 check-drift:205 标注"未纳入"）——Phase 1 实证 plan_parse_scope 语义与 check-drift「允许的文件」列语义是否一致；一致则接入统一库（消除第 5 处复制+取列问题），不一致则状态机化+取对列。**禁止**为修复而削弱 check-drift 现有其他检测（phase order/scope 外的 Check 1-3）。
- **定位如实披露**：check-drift.sh 现为"可选佐证"地位（v091 S26：DRIFT CHECK 唯一载体=Skill("task-drift-guard")，脚本仅佐证不双跑）——修复使其佐证输出可信，不改变其佐证地位，**禁止**借机恢复双跑或删脚本。

## 缺陷 4：template-guide.md:69 文档锚过时

- 锚点：`skills/task-planner/references/template-guide.md:69`（§2.5 knowledge-brief 段）——引用"故 :65 的 grep 锚计数 …维持 20 不变"。两处过时：① `:65` 精确行号锚随上方插行漂移（v074 P8 后内容已变动）；② 计数声明与 v074 后实际模板数（§2.3 声明 21 个 = 5 核心 + 3 辅助 + 13 variant）的一致性需 `ls templates/ | wc -l` + `grep -rl "## 📚 必要知识储备" templates/ | wc -l` 实测核对。
- 修复方向：行号锚改章节锚（§2.4 形态，抗插行漂移）；计数按实测修正（20/21 以实测为准，与 §2.3 及 template-mapping.md 交叉一致——若发现 template-mapping.md 同型漂移一并登记不扩 scope，先报告）。

## 范围外清单（维持 deferred，禁止偷渡）

- plan glob 不匹配顶层形态（S13②，progress.md:79 维持 deferred）——与 :147-157 current_plan_dir glob 相邻但不属本任务
- UPS plans/* 37 目录 stat+date ~500ms 慢源（S18 deferred，性能类非行为恢复类）
- Tier B 7 项（32.4 待重议）/ WF-10 部署位上跳非鲁棒（v090 遗留）
- check-delegation/check-plan-dispatch 等其他守卫脚本零触碰

## 验收与约束基线

- 全量 selftest 不得低于基线 518/0；CC-06 改造后 selftest-check-conflicts 全 PASS；check-drift 相关断言（如有）补行为级用例（固定 sid 每次唯一，v078 教训）
- Rule 36：技能文件修改——无功能性删除，全部为缺陷行为恢复（恒误报/恒跳过/恒空 → 设计意图行为）；36.3 删除基线 = git 历史；36.4 清单在计划声明（无删除项）
- worktree 隔离（§十一 P0）：`/home/terry/task-planner-skill-worktrees/task-v092-guard-quirk-fixes`，分支 `wt/task-v092-guard-quirk-fixes`，从 master 0b2208b 拉
- 部署：合并后 `smart-merge-back.sh --deploy` 三实体位（~/.zcode、~/.claude、~/.config/opencode）+ 主进程 diff -r 亲验；对账代码注意 LC_ALL=C pin（v091 C-5 教训，若新增对账逻辑）
