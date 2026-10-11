---
template_type: rule-enhancement
code_review: required
interaction_mode: silent
reflect_verify: required
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    code-runner-agent: 2
    executor: 4
  estimated_opus_equivalent: 2.13
  estimated_savings_vs_naive: 0.65
---

# Task Plan: Rule 36 技能修改保守化与功能删除防护（归因前置 + 删除基线 + 高危确认 + 纯增量纪律 + 消费侧门控）

## Goal
落地 Rule 36 技能修改保守化与功能删除防护（36.1-36.7 七子条 + config 键 skill_modify_enforce 三档默认 warn + check-skill-modify.sh 挂 pretooluse + SKILL-MODIFY GATE + selftest-skill-modify.sh 守护 + SKILL.md 联动与 Rules 1-35→1-36 锚级联），全量 selftest 0 FAIL 后合并回 master 并 smart-merge-back 部署 3 实体位。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含新建 .sh 脚本与 zcode-pretooluse.sh 接线） |
| `interaction_mode` | `silent`（2026-09-17 D1 询问未获答复,harness 自主运行指令→由 ask 转 silent;静默决策清单见 Decisions Made ⑤） |
| `reflect_verify` | `required`（终验 progress.md 需 ≥2 行 [reflect]，REFLECT-GATE 消费） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule 36 条款完整：critical-rules.md 含 `### 36` 块 + 36.1-36.7 七子条锚各 grep 命中，且 36.2 显式引用 31.2/31.3 衔接、36.4 引用 Rule 28 D6 语义（不改 Rule 28/31/32/35 既有文字，git diff 对既有行零改写） | Read 条款块 + `grep -n "36\.[1-7]"` 七锚 + `git diff` 复核既有行 | `references/critical-rules.md`（追加 ~25 行，Rule 35 块 @L292 后） |
| VC-2 | config 键 `skill_modify_enforce` 三档（enum enforce/warn/off，默认 warn，description 注明 Rule 36）挂 properties 内；`jq .properties.skill_modify_enforce.default` = "warn" 且 JSON 校验通过（additionalProperties:false 不破） | `python3 -c json.load` + `jq` 双校验 | `config.json`（三档键区 @L299-310 后追加） |
| VC-3 | 消费侧三件实测：① check-skill-modify.sh 新建且三档行为各一实测证据（enforce 命中未授权技能文件 exit 2 / warn 注入提醒 / off 静默）；② zcode-pretooluse.sh Write/Edit 分支接线 grep 命中（对主进程与子代理一致生效）；③ check-complete.sh 含 SKILL-MODIFY GATE 段（resolve skill_modify_tier 范式 + REFLECT-GATE 后追加，锚注释带 task-v079） | 三档实跑输出 + `grep -n "check-skill-modify" zcode-pretooluse.sh` + `grep -n "SKILL-MODIFY GATE" check-complete.sh` | `scripts/check-skill-modify.sh`（新建）/ `scripts/zcode-pretooluse.sh` / `scripts/check-complete.sh` |
| VC-4 | 全量 selftest 0 FAIL：主进程逐脚本 Total 行机械求和（禁采信子代理自报总数，对照 P1 基线无回归增量外无 FAIL）；新建 selftest-skill-modify.sh 全 PASS（36.x 条款锚 + config 键 json 校验 + SKILL 联动 + C24 + pretooluse 接线锚 + GATE 锚） | `for f in selftest-*.sh` 逐 Total 求和 + 新 selftest 单独跑 | progress.md Selftest Log（证据 subagent-state/p4-regression.md） |
| VC-5 | SKILL.md 联动四件齐（Rule 36 行 / C24 行 / 特判指针段 / frontmatter+L278+L327 锚）+ 全仓（排除 plans/）`grep -rn "Rules 1-35"` 零残留（1-35→1-36 级联修齐含 selftest 宽容/严格锚）+ 3 实体位部署 diff -r =0 | grep 级联残留 + smart-merge-back --deploy 输出 + 主进程 diff -r 亲验 | SKILL.md / README.md:67 / batch-quality-gate.md:130 / 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `skills/task-planner/references/critical-rules.md`（Rule 35 块 @L292 后追加 Rule 36 块 ~25 行） | 改 Rule 28/31/32/35 既有条款语义（仅引用衔接） |
| 配置 | `skills/task-planner/config.json`（properties 追加 1 键 `skill_modify_enforce`；additionalProperties:false → 新键必须进 properties） | 动既有键；顺手修既有脏点 |
| 脚本 | `skills/task-planner/scripts/check-skill-modify.sh`（新建）/ `scripts/zcode-pretooluse.sh`（Write/Edit 分支追加接线）/ `scripts/check-complete.sh`（REFLECT-GATE 后追加 SKILL-MODIFY GATE 段）/ `scripts/selftest-skill-modify.sh`（新建）/ `scripts/selftest-conclusion-discipline.sh`（CD-11/CD-12 断言 1-35→1-36）/ `scripts/selftest-reflect-verify.sh`（RV-10 锚 1-35→1-36） | 其他既有脚本 |
| 脚本（P4/S10 扩围 B 类） | `scripts/selftest-execution-stability.sh`（T8b 行数上限 538→548）/ `scripts/selftest-skill-collab.sh`（T10 同）——SKILL.md 联动净增 3 行后行数断言越限，variant 模板强制约束「行数上限断言同步上调」要求此联动，计划期漏列，执行期按 B 类补登（Decisions ⑧） | 上限纪律本身（548=538+净增上限 10，未来任务仍受限） |
| SKILL | `skills/task-planner/SKILL.md`（**净增 ≤10 行**：Rule 36 行 + C24 行 + 特判指针段 + 3 处 1-35→1-36 锚行位替换） | 大段新增 |
| 文档 | `skills/task-planner/README.md`（:67 锚级联）/ `references/batch-quality-gate.md`（:130 锚级联） | 其他文档 |
| 簿记 | `CHANGELOG.md`（[Unreleased] 新增一条） | 其他 |

**不改动清单（保守化自身示范）**:
- Rule 28/31/32/35 既有语义文字（36.4 引用 D6、36.2 引用 31.2/31.3，均不改写原文）
- `templates/variant/rule-enhancement-type.md`（工作区已有 v077 遗留未提交 diff——保持原样，本任务不提交不覆盖；worktree 基线从 master 取，遗留 diff 不入本次 merge）

**强制约束**:
- 新规则编号 = 36（当前最大 35，Rule 35 @L292）；合规清单接续最大 C 编号 → **C24**（当前最大 C23 @L197）
- ⚠️ **锚级联**：动手前 `grep -rn "Rules 1-" skills/task-planner/scripts/` 全修齐——严格锚（CD-11/CD-12/CD-18/CD-19/RV-10 的 `1-35` 字面量）改 `1-36`；宽容正则 `Rules 1-3[1-5]`（selftest-veto VT-10 / selftest-error-loop EL-11）改 `Rules 1-3[1-6]`；避免两阶段间回归 FAIL
- 派发契约：executor prompt 必含计划三文件绝对路径 + acceptance:/checkpoint: 等 8 字段标签；材料过 35.3 落盘引用（任务书路径 subagent-state/N-dispatch.md 模式）

## Phases

### Phase 1: 隔离与基线
- [x] 建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism`，分支 `wt/task-v079-skill-modify-conservatism` 自 master 新建（宪法 §十一 11.2 集中目录）
- [x] 全量 selftest 基线：code-runner-agent 逐脚本 Total 行落盘，主进程 awk 机械求和定数（对照基线记 PASS/FAIL 总数）
- [x] 插入点锚确认：critical-rules.md Rule 35 块尾 / config.json 三档键区 / SKILL.md L9/L197/L219/L278/L327 / check-complete.sh REFLECT-GATE 尾（~L818）——前置 Read 核一遍
- **V-N:** VC-4, VC-1
- **Status:** complete
- **Executor:** 主进程（例外理由:白名单① git 编排）+ code-runner-agent（基线跑测，白名单③ 机械求和）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 建 worktree 并确认基线 commit | 主进程 | 本计划隔离决策行（worktree_path/branch） | `git -C <worktree> log -1` 显示 master HEAD 且主仓 `git status` 无任务范围重叠变更 | 5min | pending |
| S2 | 全量 selftest 基线逐 Total 落盘 | code-runner-agent(mini) | knowledge-brief.md（§5 S2 材料包：fixture 注意 + 逐 Total 求和指令） | 逐脚本 Total 行原样落盘 `subagent-state/p1-baseline.md`，主进程 awk 求和定数回填本行 | 15min | pending |

### Phase 2: 条款 + config 键 + 消费侧门控（VC-1..VC-3）
- [x] S3 Rule 36 七子条追加（VC-1）
- [x] S4 config 键 skill_modify_enforce（VC-2）
- [x] S5 check-skill-modify.sh 新建 + zcode-pretooluse.sh 接线（VC-3①②）
- [x] S6 check-complete.sh 追加 SKILL-MODIFY GATE（VC-3③）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1），严格串行派发（S3→S4→S5→S6 有锚依赖，一次一个、验收通过再派下一个）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S3 | Rule 36 七子条（36.1-36.7）追加至 critical-rules.md（~25 行，36.2 引 31.2/31.3、36.4 引 Rule 28 D6） | 继承 | subagent-state/02-rule36-design-brief.md §「Rule 36 条款设计」（L9-17 全文逐字采用，禁改写） | `grep -c "^36\." critical-rules.md`=7；既有 Rule 28/31/32/35 行 git diff 零改写 | 15min | pending |
| S4 | config.json properties 追加 skill_modify_enforce（三档默认 warn，description 单行注明 Rule 36，短描述风格照 reflect_verify/template_gate 先例 @L299-310） | 继承 | 01-explore-conventions.md §2（additionalProperties:false + 命名模式，L12-16 ≤5 行摘要） | `python3 -c json.load` 通过；`jq .properties.skill_modify_enforce.default`="warn" | 8min | pending |
| S5 | 新建 check-skill-modify.sh（realpath 归一化命中技能文件模式 + 活跃计划「执行范围限制」表未列该文件 → warn 提醒/enforce exit 2；主进程与子代理一致生效）+ zcode-pretooluse.sh Write/Edit 分支接线 | 继承 | 01-explore-conventions.md §8（pretooluse 链 L29-48 接线点 + check-delegation 子代理 exit 0 空档说明 ≤8 行摘要） | 三档实跑各一证据落 p2-s5.md；`grep -n check-skill-modify zcode-pretooluse.sh` ≥1；未授权命中 enforce 档 exit 2 | 15min | pending |
| S6 | check-complete.sh REFLECT-GATE 段后追加 SKILL-MODIFY GATE（resolve skill_modify_tier：env TASK_PLANNER_SKILL_MODIFY_ENFORCE > config > warn；校验删除性行为清单已登记且逐项有确认记录；锚注释带 task-v079） | 继承 | 01-explore-conventions.md §4（GATE 顺序 L25 + 统一范式 resolve_X_tier L26 ≤4 行摘要；插入锚=REFLECT-GATE case 结束 ~L818 后） | `grep -n "SKILL-MODIFY GATE" check-complete.sh` ≥1；warn 档实测不阻断 exit 0 | 12min | pending |

### Phase 3: selftest 守护 + 锚点级联修复（VC-4/VC-5 前半）
- [x] 新建 selftest-skill-modify.sh（selftest-veto.sh 范式：头注释逐条用例 + ok/bad 双函数 + 36.x 条款锚 + config 键 python3 json 校验 + SKILL Rule 36 行/C24 行锚 + pretooluse 接线锚 + GATE 锚 + 尾 `exit $((FAIL > 0))`）
- [x] 锚级联全修齐：selftest-conclusion-discipline.sh CD-11/CD-12/CD-18/CD-19（1-35→1-36）+ selftest-reflect-verify.sh RV-10（1-35→1-36）+ 宽容正则 `Rules 1-3[1-5]`→`Rules 1-3[1-6]`（selftest-veto VT-10 / selftest-error-loop EL-11）+ 前置全扫 `grep -rn "Rules 1-" scripts/` 无漏
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** executor（sonnet-1），严格串行（先锚级联后新 selftest，防新 selftest 断言撞旧锚）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S7 | 新建 selftest-skill-modify.sh（≥6 断言覆盖 VC-1/2/3/5 锚点） | 继承 | 01-explore-conventions.md §3（selftest-veto.sh 范式 L21 ≤5 行摘要）+ 02-brief §「36.7 机制」（③守护内容清单） | 单跑 `bash selftest-skill-modify.sh` 全 PASS（此时 SKILL 联动未做→依赖锚置后放行策略：断言锚仅限 P2 已落地的 critical-rules/config/scripts 三件，SKILL 联动锚留给 P4 后全量跑） | 15min | pending |
| S8 | 锚级联修齐（CD-11/12/18/19 + RV-10 + 宽容正则 2 处） | 继承 | knowledge-brief.md §3（锚点表逐行行号+摘要）+ 前置 grep 全扫输出 | `grep -rn "Rules 1-35\|1-3[1-5]" scripts/` 残留=0（CD 宽容断言改后自洽）；CD/RV/VT/EL 四个 selftest 单跑全 PASS | 15min | pending |

### Phase 4: SKILL 联动 + 文档同步 + 全量回归（VC-5/VC-4）
- [ ] SKILL.md 四件：Rule 36 行（Critical Rules 列表 L278 段内，格式对齐 Rule 31/32 行）/ C24 行（L197 C23 后，格式对齐 C20/C23）/ 特判指针段「技能文件修改保守化（Rule 36 — task-v079）」（L219 Rule 34 特判段后）/ frontmatter L9 + L278 + L327 锚 1-35→1-36；README.md:67 与 batch-quality-gate.md:130 同步级联；SKILL.md 净增 ≤10 行 wc -l 复核（当前 538 行；行数上限断言如涉同步上调）
- [ ] 全量 selftest 回归：code-runner-agent 逐 Total 落盘 p4-regression.md，主进程 awk 求和定数（预期=基线 + 新 selftest 断言数，0 FAIL）
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** executor（sonnet-1）SKILL 联动与级联；全量回归跑测派 code-runner-agent（白名单③ 机械求和，主进程定数）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S9 | SKILL.md 四件联动 + README/batch-gate 锚级联（净增 ≤10 行） | 继承 | knowledge-brief.md §3（SKILL L9/L197/L219/L278/L327 + README:67 + batch-gate:130 逐行锚）+ 02-brief §「SKILL.md 联动」（4 条清单 L19-23） | `grep -c "Rule 36" SKILL.md` ≥2；`grep -n "C24" SKILL.md` ≥1；全仓（排除 plans/）`grep -rn "Rules 1-35"` 计数=0；SKILL.md 净增 wc -l ≤10 | 15min | pending |
| S10 | 全量 selftest 回归逐 Total 落盘 | code-runner-agent(mini) | knowledge-brief.md §5 S10 材料包（同 S2 求和方法 + 预期数=基线+新断言数，以实跑为准） | 逐脚本 Total 行落盘 `subagent-state/p4-regression.md`；主进程 awk 求和 0 FAIL 后回填 | 15min | pending |

### Phase 5: 合并回 + 部署 + 簿记（VC-5）
- [x] 11.3 合并回合约 6 条全过（Phase 全 complete + worktree status 干净 + 主仓无重叠未提交变更——v077 遗留 variant diff 保持原样不入 merge）→ `git merge --no-ff wt/task-v079-skill-modify-conservatism`
- [x] 主仓副本执行 smart-merge-back --deploy 3 实体位 + 主进程 diff -r 亲验 =0
- [x] 簿记：merge_back 回写 / CHANGELOG [Unreleased] 条目 / INDEX+ledger / worktree remove + branch -d 清零
- **V-N:** VC-5, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:白名单① git 编排 + ③ 部署/push）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S11 | merge + 部署 3 实体位 + diff -r 亲验 + worktree 清理 + 簿记回写 | 主进程 | 本计划隔离决策行 + 宪法 §11.3 六条（≤6 行摘要） | merge commit 入 master；3 位 diff=0；`git worktree list` 无本任务条目；plan `merge_back=merged(<commit>)` 回写；CHANGELOG +1 条 | 15min | pending |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（主仓 skills/ 无与任务范围重叠的未提交变更；注意 `templates/variant/rule-enhancement-type.md` 有 v077 遗留 diff——保持原样，不入本次 merge，登记为已知项） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism` |
| `branch` | `wt/task-v079-skill-modify-conservatism`（自 master 新建） |
| `merge_back` | merged(8aba15d)（merge --no-ff；部署=smart-merge-back --deploy rc=0 三位 IDENTICAL；合并后 master 全量回归 349/0） |

> 契约详见 `references/worktree-isolation.md` §3（集中目录命名 `<repo-parent>/<repo>-worktrees/<task-id>`；仓库=运行中基础设施，§11.1 命中信号⑤，实现期必须 worktree）。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| P2/S5 | check-skill-modify.sh 误报命中合法文件（plans/ 白名单/realpath 归一化漏 case） | 6 | 4 | 5 | 120 | 主进程接管（22.3 ⑤ 档）：单用例复现 ≤2 轮定位误报模式 → 补白名单 case → 三档重测；仍误报 → warn 档放行执行 + enforce 档暂缓升级记 blockers，禁止为赶进度放宽匹配 |
| P3/S8 | 锚级联漏修致 CD/RV 自测 FAIL 连锁（两阶段间回归） | 5 | 5 | 4 | 100 | （RPN=100 临界；前置 grep 全扫输出存 p3-s8.md，FAIL 则按新行内容重锚 ≤2 轮；>2 轮 → meta-corrector 隔离排查） |
| P4/S9 | SKILL.md 净增 >10 行破纪律 | 4 | 3 | 4 | 48 | （RPN≤100；行位替换优先，超限时把特判指针段压缩至 2 行） |
| P5/S11 | .zcode 部署位自保护 REJECTED 致 3 位 diff≠0 | 5 | 6 | 4 | 120 | 主进程接管（22.3 ⑤ 档）：手动 `rm`+`cp -rL` 主仓 `skills/task-planner` 补齐该位再 diff 复验（v077 先例：仅动该位内容，不碰 cli/config.json）；仍 FAIL → AskUserQuestion |
| P2/S6 | GATE 追加位置错（撞 warn 计数段/末行 exit） | 4 | 3 | 4 | 48 | （RPN≤100；锚=REFLECT-GATE case 结束后 L818 后插入，插入后单跑 check-complete 三档冒烟） |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/commit） | 必读级别 | 已确认 |
|------|-----------|---------------------|---------|--------|
| 项目内部 | 结构侦察（Rule 31/32 范式/config 键模式/GATE 顺序/variant 骨架/hook 接线，8 节） | `plans/task-v079-skill-modify-conservatism/subagent-state/01-explore-conventions.md` | 必读 | ☑ |
| 项目内部 | Rule 36 设计裁定全文（七子条/SKILL 联动四处/不改动清单/Phases/VC/frontmatter） | `plans/task-v079-skill-modify-conservatism/subagent-state/02-rule36-design-brief.md` | 必读 | ☑ |
| 项目内部 | critical-rules.md Rule 31/32/35 块（衔接锚：31.3@L255 / 35@L292 后插入点） | `skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 项目内部 | 知识底座 | `plans/task-v079-skill-modify-conservatism/knowledge-brief.md`（本任务 §1-§5） | 必读 | ☑ |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | 2026-09-17 05:40 | Explore | 仓库结构侦察（Rule 31/32 范式/config/GATE/联动锚/variant/hook） | done | 8 节结论落盘（01 检查点）；代理无 Write 工具，主进程代落盘 | subagent-state/01-explore-conventions.md | findings.md Research Findings | subagent-state/01-explore-conventions.md | - | 0 | ☑ |
| 2 | 2026-09-17 | plan-writer | 本计划 + knowledge-brief 撰写 | done | 计划 203 行+brief 76 行；主进程 Read 复核通过（区块/VC/S-unit/Decisions 齐）；发现并补入 RV-10 锚级联（已入 S8）；误建 stray 目录已自清，主进程复验不存在 | task_plan.md + knowledge-brief.md | findings.md plan-writer 条 | subagent-state/02-plan-writer.md | - | 0 | ☑ |
| 3 | 2026-09-17 06:08 | code-runner-agent | P1/S2 全量 selftest 基线采集（worktree@187194b） | done | 20 脚本 rc 全 0 逐 Total 落盘；主进程求和 337/0（自报 352 弃用）；0 超时 | subagent-state/p1-baseline.md | findings.md P1 基线条 | subagent-state/04-code-runner-p1.md | - | 0 | ☑ |
| 4 | 2026-09-17 06:2x | executor | P2/S3 Rule 36 七子条追加 | done | 12 行纯新增@L300-311，0 删除；主进程 Read 复核条款忠实 brief+衔接句在位；grep 七锚=7 | worktree critical-rules.md diff | findings.md P2/S3 条 | subagent-state/05-executor-s3.md | - | 0 | ☑ |
| 5 | 2026-09-17 06:3x | executor | P2/S4 config 键 skill_modify_enforce | done | +6 行 0 删除@L311-316；主进程 python3 复验 default=warn/enum 三档/JSON 合法 | worktree config.json diff | findings.md P2/S4 条 | subagent-state/06-executor-s4.md | - | 0 | ☑ |
| 6 | 2026-09-17 06:5x | executor | P2/S5 check-skill-modify.sh+pretooluse 接线 | done | 92 行新脚本+接线；六条自验过；主进程亲测 enforce 未授权 rc=2/已授权 rc=0；3 处设计偏差合理已记录 | subagent-state/08-executor-s5.md | findings.md P2/S5 条 | subagent-state/08-executor-s5.md | - | 0 | ☑ |
| 7 | 2026-09-17 07:0x | executor | P2/S6 SKILL-MODIFY GATE | done | +35 行 0 删除；fixture 六场景 rc 正确；主进程复验语义+bash -n OK | worktree check-complete.sh diff | findings.md P2/S6 条 | subagent-state/09-executor-s6.md | - | 0 | ☑ |
| 8 | 2026-09-17 07:1x | executor | P3/S7 新建 selftest-skill-modify.sh | done | 61 行 SM-01..08；主进程亲跑 7 PASS+2 SKIP rc=0；SM-08 两段策略待 P4 转实断言 | subagent-state/10-executor-s7.md | findings.md P3/S7 条 | subagent-state/10-executor-s7.md | - | 0 | ☑ |
| 9 | 2026-09-17 07:2x | executor | P3/S8a CD+RV 锚宽容化 | done | CD 23/23+RV 12/12 主进程亲跑 rc=0；11 行改动仅 2 文件 | subagent-state/11-executor-s8a.md | findings.md P3/S7 条(策略修正) | subagent-state/11-executor-s8a.md | - | 0 | ☑ |
| 10 | 2026-09-17 07:3x | executor | P3/S8b VT+EL 宽容正则 | done | VT 13/13+EL 16/16 主进程亲跑 rc=0；4 处改动仅 2 文件；功能性严格锚残留=0 | subagent-state/12-executor-s8b.md | findings.md P3/S7 条(策略修正) | subagent-state/12-executor-s8b.md | - | 0 | ☑ |
| 11 | 2026-09-17 07:4x | executor | P4/S9 SKILL 联动+级联 | done | 净增 3 行；联动四件齐；级联零残留；主进程抽查通过 | subagent-state/13-executor-s9.md | progress.md P4 段 | subagent-state/13-executor-s9.md | - | 0 | ☑ |
| 12 | 2026-09-17 07:5x | code-runner-agent | P4/S10 全量回归首跑 | partial | 344/2：行数断言越限 2 FAIL（真实回归）→ 触发 B 类扩围 Decisions ⑧ | subagent-state/p4-regression.md | progress.md P4 段 | subagent-state/14-code-runner-p4.md | - | 0 | ☑ |
| 13 | 2026-09-17 07:5x | executor | P4/S10-fix 行数断言 538→548 | done | 17/17+19/19；4 行改动仅 2 文件 | subagent-state/15-executor-s10fix.md | progress.md P4 段 | subagent-state/15-executor-s10fix.md | - | 0 | ☑ |
| 14 | 2026-09-17 07:6x | code-runner-agent | P4/S10 全量回归终跑 | done | 主进程修正 awk 亲验 21 脚本 346/0（基线 337+新增 9，零回归） | subagent-state/p4-regression-final.md | progress.md P4 段 | subagent-state/16-code-runner-p4final.md | - | 0 | ☑ |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 隔离+基线（S1/S2） |
| Phase 2 | ☐ |  | S3-S6 严格串行 |
| Phase 3 | ☐ |  | S7/S8 守护+锚级联 |
| Phase 4 | ☐ |  | S9/S10 联动+回归 |
| Phase 5 | ☐ |  | S11 合并部署簿记 |

## Key Questions
1. check-skill-modify.sh 的「当前活跃计划」定位：读 `plans/*/task_plan.md` 最近 mtime 者 or 哨兵 sid 关联计划？——P2/S5 前置定案（倾向 sid 关联，与 check-delegation 同源；定案结果回填 findings.md）。
2. 新 selftest 断言在 P4 前依赖 SKILL 锚（Rule 36 行/C24）：S7 采取「断言只锁 P2 已落地三件，SKILL 锚留给 P4 后全量跑」的两段策略，是否接受？（默认接受，P3 全量 selftest 时新 selftest 跳过 SKILL 锚用例需在头注释注明）
3. v077 遗留 variant diff 处理：保持原样不入本次 merge（conflict_scan 已登记）——若主仓在 P5 前该 diff 被用户提交，merge 前重扫 conflict_scan。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| ① Rule 36 设计裁定 = 用户 2026-09-17 原始诉求（技能出错禁止盲改 + 防功能静默移除 + 默认保守）+ 文章优化技能「流量分级优化」功能被静默移除事故样本 | 设计全文=02-rule36-design-brief.md（主进程裁定，plan-writer 直接采用，不再重开方案讨论） |
| ② 保守化示范：36.4 引用 Rule 28 D6 语义不扩列、36.2 引用 31.3 不改既有条款文字、v077 遗留 variant diff 保持原样不动 | 新规则自身遵守「纯增量、不动既有语义」，示范即执行 |
| ③ `skill_modify_enforce` 默认 warn | 对齐 14 个三档键全默认 warn 的观察期先例；enforce 经 config 升级，warn 提醒先跑一个迭代 |
| ④ 隔离=worktree（§11.1 信号⑤：本仓=运行中基础设施，scripts/zcode-pretooluse.sh 改动被所有会话实时 hook 加载） | 宪法 §十一 P0；直接开发=P0 投毒 |
| ⑤ silent: D1 计划批准询问（AskUserQuestion）未获用户答复（2026-09-17 06:0x），harness 自主运行指令=按最佳判断继续、不视为拒绝 | 按呈报推荐项执行（skill_modify_enforce 默认 warn/新 selftest 两段断言/v077 遗留 diff 不入合并/interaction_mode 由 ask 转 silent）；交付报告附本静默决策清单供用户复核，任何时刻可叫停改判 |
| ⑥ silent: S8 锚级联改宽容 `1-3[56]` 而非计划原文「严格锚改 1-36」 | 计划 S8 验收要求 CD/RV/VT/EL 单跑全 PASS，但 SKILL.md 需 P4/S9 才改——严格 1-36 在 S8 必 FAIL，时序自相矛盾；宽容锚两阶段自洽，最终态严格性由 S9 残留 grep=0 + SM-08 自动实断言 + S10 全量回归保证 |
| ⑦ silent: S8 按 config max_files_per_dispatch=3 拆 S8a(CD+RV)/S8b(VT+EL) 两次串行派发 | config subagent.max_files_per_dispatch=3，计划 S8 一次 4 文件越上限；拆分不改变验收口径 |
| ⑧ B 类扩围（2026-09-17 P4/S10）：scope 表新增 selftest-execution-stability.sh/selftest-skill-collab.sh 两文件（行数上限断言 538→548） | S10 回归暴露 SKILL.md 541 行越 538 断言（真实回归增量，非假阳性）；variant 模板强制约束本要求行数断言同步上调，计划期漏列；548 保持净增 ≤10 纪律余量；来源=S10 实证（p4-regression.md L198/L392） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（P2/P3/P4-S9 为 executor 派发型；P1 code-runner、P4-S10 跑测） |
| 主进程直做 Phase 清单 | P1-S1（白名单① git 编排）、P4/S10 定数（白名单③ 机械求和）、P5-S11（白名单①③ 部署/push） |
| 委派率 | 执行期回填（delegation_rate_floor 0.7；全直做部分须白名单登记） |

## Notes
- 更新 phase 状态: pending → in_progress → complete；重大决策前重读本计划
- 统计类结论一律逐 Total 原文行落盘，主进程机械求和定数（Rule 35 纪律）
- 本任务即 Rule 36 的 dogfood：本计划自身对 critical-rules/config/scripts/SKILL 的修改=「执行范围内授权修改」（执行范围限制表逐行登记），非 36.3 所指「未归因偷渡修改」；P2 各 S-unit 前置 Read 目标文件后再动手
