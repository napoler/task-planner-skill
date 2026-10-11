# design-draft — Rule 66 goal 单元固化与 /goal 驱动推进纪律（task-v151）

<!--
  WHAT: Phase 3 派发 S-unit 的物料蓝本——六子条草案全文 + Goal 单元表列契约 + 守卫改动伪码 + 钉值级联清单。
  WHY: 用户 2026-10-09 三次澄清定稿方向：任务分解固化为 goal 单元（任务名+目标+完整验证方式），用 ZCode 内置
       /goal 目标模式逐个驱动推进；R5 纠正废弃「自建程序化机制」方向，/goal=输入框直接激活的内置命令，
       技能层只做映射供料（40.3 既有口径）+执行期 goal 逐个门控。
  WHEN: 计划批准（D1）后 Phase 3 逐项派发；S-unit 任务书引用本文件对应段落，子代理不凭会话记忆实现。
-->

## 1. 需求→条款映射（Rule 58.4 手段/目标二分消费）

| R 行 | 条款承载 |
|------|---------|
| R1 规划后任务以「任务名+目标+验证方式」固化 | 66.1 Goal 单元表六列契约（goal-id/任务名/目标/完整验证方式/对应单元/状态） |
| R2 目标含完整验证，goal 推进确保可靠性 | 66.3 逐 goal 验证通过才翻 complete（机器面=check-complete 对照） |
| R3 用 ZCode 内置 /goal（输入框直接激活），不绕远 | 66.2 内置命令口径固化（不可代调/不可读态/映射供料+单行呈示） |
| R4 自动分解→调度→逐个解决 | 66.4 分解（S-unit 表 22.6）→调度（21.4 铁律）→逐 G 推进序 |
| R5 方向纠正 | 本草案全文（superseded 初版方向不留进实现） |

## 2. Rule 66 六子条草案（critical-rules.md 文末追加，行 846 后；既有 1-65 正文零改写）

```markdown
### 66 goal 单元固化与 /goal 驱动推进纪律（P0, 2026-10-09 task-v151，目标：规划获批后任务自动分解固化为 goal 单元（任务名+目标+完整验证方式），执行按 goal 逐个调度推进并与 ZCode 内置 /goal 目标模式对齐供料，确保后期执行可靠性；判定面=计划期区块+执行期门控，机器面=check-plan-dispatch/check-complete/selftest-goal-unit-goal-mode.sh，零新 config 键；Rule 40.3 /goal 既有口径不动）

66.1 **goal 单元固化（goal-unit freezing）**：计划获批（attest）后，任务必须自动分解固化为「🎯 Goal 单元表」逐行 goal 单元——六列契约：goal-id（G1/G2… 纯数字递增）| 任务名（≤8 字）| 目标（≤1 句）| 完整验证方式（可复现：命令+判据 或 路径+关键行 或 diff/输出形态，三选一必具其一，禁「检查没问题」类无据表述）| 对应 S-unit/Phase | 状态（pending/complete）。standard/full 档必填（缺一列或验证方式列空白=计划无效回炉）；mini 档豁免（66.5）。

66.2 **/goal 内置命令口径（built-in /goal semantics）**：/goal = ZCode 用户侧 harness 内置命令（输入框直接输入即激活目标模式，会话朝目标迭代），技能层**不可代调、不可读取其运行态**（40.3 如实披露口径延伸，防虚构 54.0）；技能层职责=「映射供料」——Goal 单元表是 /goal 完成审计的证据源；执行期每 goal 翻 complete 时单行呈示对应 VC/证据锚（44.5 展示限制，不循环重展）；禁止「技能已设置 /goal」「/goal 状态为…」类无第一手证据表述。

66.3 **逐 goal 验证通过门（verify-gate）**：执行按 goal 逐个推进（单 goal 焦点，禁跨 goal 连做——46.1 单任务专注度 goal 级延伸）；goal 行翻 complete 前必须：①「完整验证方式」实跑通过 ②progress.md 追加 `[goal:Gn] 证据锚` 行（验证命令+PASS 结果+产物路径，三要素）；缺任一=禁止翻格。check-complete.sh 终验逐行对照：status=complete 的 goal 行无对应 [goal:Gn] 证据行=exit 1（与 64.2 门控同档）；有 goal 未 complete=终态最高 PARTIAL（58.5 三态语义对齐，禁 COMPLETE 冒充）。

66.4 **分解→调度→逐个解决推进序（advance order）**：自动分解=S-unit 表（22.6，拆分前查 21.6.1 模式库）；调度=Rule 21.4 铁律（声明并行组内并行、未声明串行）+Goal 单元表 G 序；逐个解决=每 goal 走「派发起→验收（22.5 三证据）→实跑验证方式→翻格+[goal:Gn] 落盘+单行呈示→下一 goal」；跨 goal 前移/跳序仅按 49.2 推进三条件双登记（Lane 表或 progress [advance] 行），未登记=越序违规。

66.5 **模板区块承载与 mini 豁免（template carriage）**：「🎯 Goal 单元表」=general 模板区块（插入位=「🎯 核心目标达成裁决」后、「⚠️ 执行范围限制」前）；mini-lite 模板按 38.3 区块白名单声明豁免（未加区块不构成违约）；check-plan-dispatch.sh attest 期对 standard/full 档做区块存在性+六列+验证方式列非空机械校验，缺失=拒锁（59.1 硬门同档；--skip-goal-check 逃生口对齐 --skip-dispatch-check 惯例，登记 Decisions）。

66.6 **机制（mechanism）**：零新 config 键（沿用 25.4/43.4 零新键纪律）；机器面=check-plan-dispatch.sh 计划期硬门 + check-complete.sh 终验对照 + scripts/selftest-goal-unit-goal-mode.sh 静态守护（66.1-66.6 子条锚/模板区块锚/SKILL 摘要行/C45 合规行/registry 登记行/零新键负断言）+selftest-registry.tsv 登记；合规清单 C45（SKILL.md 消费侧）。
```

## 3. Goal 单元表列契约与模板区块草案（templates/task_plan.md 插入「核心目标达成裁决」后、「执行范围限制」前）

```markdown
## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
<!--
  WHEN: attest 获批后立即填写（自动分解：S-unit/Phase → goal 单元映射）
  WHY: 用户 2026-10-09 裁决——任务分解后逐格固定为「任务名+目标+完整验证方式」，
       执行按 goal 逐个推进（66.3），/goal 目标模式完成审计的证据源（66.2 映射供料）
  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应S-unit/Phase | 状态(pending/complete)
  状态机: pending → complete(仅 66.3 三证据齐备后翻格,同步 progress.md [goal:Gn] 证据行)
-->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | <示例> | | <命令+判据 或 路径+关键行> | S1/Phase 1 | pending |
```

## 4. 守卫脚本改动草案（伪码级，供 executor S-unit 落地）

### 4.1 check-plan-dispatch.sh（attest 期，追加一段，置于 S-unit 校验段之后）
```bash
# Rule 66.5 goal 单元表硬门（standard/full 档）：
# 档位判定: plan 文件含 '<!-- plan_tier: mini -->' 或 auto_tier: mini 标记 → 跳过（mini 豁免）
# 校验（awk 状态机抽 '## 🎯 Goal 单元表' 区块，与既有 S-unit 区块状态机同范式，禁区间提取 next 陷阱—35/awk 状态机惯例）：
#  ① 区块存在（缺 → SKIP 提示+enforce 档拒锁，WARN 档提示）
#  ② 表头六列锚（goal-id/任务名/目标/完整验证方式/对应 S-unit/状态 关键词 grep）
#  ③ 逐数据行: goal-id 匹配 ^G[0-9]+$ 且序号连续; '完整验证方式'列非空且非占位符（<...>/空/「检查没问题」黑名单词）
#  ④ --skip-goal-check 逃生口（对齐 --skip-dispatch-check，echo 登记行）
```

### 4.2 check-complete.sh（终验，追加一段）
```bash
# Rule 66.3 goal 逐行对照（终验段，awk 状态机抽 Goal 单元表）：
#  ① status=complete 的 goal 行 → progress.md grep '[goal:Gn]' 证据行，缺 → exit 1（与 64.2 门控同档，提示行含 G 号）
#  ② 存在 status=pending 的 goal 行 → 终态禁 COMPLETE（降级 PARTIAL 提示；plan_tier: mini → 整段跳过）
#  ③ 本段输出行前缀 [goal-gate] 便于 selftest 锚定
```

### 4.3 SKILL.md 级联（4 处）
- 行 9 / 行 280 / 行 360：`1-65` → `1-66`（计数级联，v149 判例：级联须覆盖计数与宽锚形态——同时 grep `Critical Rules 1-65` 与 `Rules 1-65` 两形态确认仅 3 处命中，无第四处）
- 行 335（Rule 65 摘要行）之后插 Rule 66 摘要行（一句话版：goal 单元固化六列契约+/goal 内置命令映射供料口径+逐 goal 验证通过门+分解→调度→逐个解决推进序；机器面=check-plan-dispatch/check-complete+selftest-goal-unit-goal-mode.sh，零新 config 键）
- 合规检查清单 C44 行后追加 C45 行（goal 单元自查：66.1 六列填写/66.3 [goal:Gn] 证据行逐落/66.4 G 序推进/66.2 禁 /goal 代调声称；机器面=check-plan-dispatch 硬门+check-complete 对照+静态守护）

### 4.4 新 selftest-goal-unit-goal-mode.sh（断言清单，G-01..）
| 断言 | 锚 | 判据 |
|------|-----|------|
| G-01 | critical-rules.md | `^### 66 ` 标题 =1 |
| G-02 | critical-rules.md | `^66\.[1-6] ` 子条各 =1（6 条，EG-16 演进面：本自测承接 `^66\.[0-9] =6` 正向断言） |
| G-03 | templates/task_plan.md | `^## 🎯 Goal 单元表` =1 + 六列表头行 =1 + 插入位语义（位于「核心目标达成裁决」与「执行范围限制」之间，awk 行序断言） |
| G-04 | SKILL.md | `Rule 66` 计数 ≥2（摘要行+References 描述行 1-66）；`^\| C45 ` =1 |
| G-05 | check-plan-dispatch.sh | `Goal 单元表` 锚 + `--skip-goal-check` 锚各 =1 |
| G-06 | check-complete.sh | `goal-gate` 输出前缀锚 + `[goal:G` grep 逻辑锚各 =1 |
| G-07 | selftest-registry.tsv | 末行含 `selftest-goal-unit-goal-mode.sh` |
| G-08 | config.json | 零新键负断言：`goal[_-](unit|gate|advance)` =0 |
| G-09 | 钉值联动 | SKILL.md 行数 ≤ 上调后上限（见 §5） |

## 5. 钉值级联清单（recon Q6/Q8 结论，逐项对照执行）

| # | 文件:行 | 现值 | 改后 | 说明 |
|---|---------|------|------|------|
| D1 | selftest-skill-split.sh:46 | SKILL.md 行数 ≤510（现 509） | ≤515 | Rule 66 摘要行 +1、C45 行 +1 → 511 触顶；上调 515 留 4 行余量（v150 判例：钉值上调留缓冲） |
| D2 | selftest-evidence-goal-gate.sh EG-16 | `^66\.[0-9] =0` 前向防线（58 块尾无 66 入侵） | 语义演进：58 块范围内（awk 区块限定）`^66\.[0-9] =0` 保留；全文件面断言移交新自测 G-02（=6） | 直接删断言=防线真空；区块化限定后 58 守护语义不变 |
| D3 | selftest-registry.tsv | 63 脚本+表头 | 追加 1 行（64+表头） | selftest-self-resolution.sh:109 动态断言（registry 行数=脚本数+1）自动跟随，无需改 |
| D4 | selftest-batch-pilot.sh:55 / drift-check-subagent.sh:84 / knowledge-brief.sh:39 / execution-stability.sh:72 / skill-collab.sh:82 | SKILL ≤558 | 不动（511<558） | 仅登记确认，不改 |
| D5 | 模板区块插入 | 模板 +约 12 行 | 检查无脚本钉模板行数（recon Q6 未列模板行数钉值）→ 落地前 grep `task_plan.md.*行数\|wc.*task_plan` 复核一次 | 兜底防漏网 |

## 6. 部署与回归 SOP（Phase 5）

1. worktree 内 `git add <scope 7 文件> && git commit -m "feat(task-planner): task-v151 Rule 66 goal 单元固化与 /goal 驱动推进纪律"`（逐 Phase 提交口径：Phase 3 S-unit 全部完成后 Phase 3 末提交一次，scope 限定禁 -A）
2. 全 selftest 回归（入口命令 Phase 2 实测定：`ls scripts/selftest-*.sh` 全跑 或既有 runner）→ FAIL 计数 vs baseline-selftest.log 对比=0 新增
3. `bash install.sh` 三部署位（~/.zcode 主 + cursor/claude 位按仓 install 实际支持面）→ 逐位 `diff -rq 仓内 部署位 --exclude=subagent-state` 全空（IDENTICAL）
4. `smart-merge-back.sh <worktree>`（--no-ff）→ `git worktree remove` + `git branch -d wt/v151-goal-mode` → 主仓 Read 关键文件复验
5. `rule-reserve.sh land 66 task-v151`
6. 部署位同步后重跑 attest 锁定本计划（新守卫已生效自验）+ 重锁前置：Decisions Made 登记本行（Rule 51.7）

## 7. 风险与兜底（FMEA 消费面）

| 风险 | 判例来源 | 兜底 |
|------|---------|------|
| 并行会话 live race 改 critical-rules/SKILL 致冲突 | v149 D 系列/v150 三方合流 | 每 S-unit 派发前 `git fetch && git diff master..origin/master -- <scope>`；冲突=并集解+affected selftest 重跑 |
| worktree 自 master 创建但技能文件与部署位不同步 | v150 实证（44 行 vs 587 行） | Phase 2 创建后立即 `diff` critical-rules.md/SKILL.md vs 部署位 ~/.zcode，不一致=从部署位 cp 修复再动（progress 记行） |
| 钉值漏项转红 | v150 教训 | 派发前对照 §5 清单逐项 grep；转红=拆细派 code-assistant 单文件修 |
| 用户并行开发期间写主仓 | 宪法 §十一 | 实现全部在 worktree；plans/ 簿记在主仓（会话级状态不进 worktree 契约） |
