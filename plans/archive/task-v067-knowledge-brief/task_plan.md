# Task Plan: task-v067 主动知识对齐——「任务知识简略要点」(knowledge-brief) 产物
<!-- template_type: skill-fix -->
<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## Goal
在 task-planner 技能中将计划期「必要知识储备」从清单式升级为要点产物式：新增 knowledge-brief（任务知识简略要点）五段产物并全链路接入（模板/init-session/SKILL.md/critical-rules/plan-writer agent/config+selftest），确保执行期小模型只读 brief 即可稳定执行。

## 用户需求复述（P0-2 对照锚点）
继续补充优化：加强「主动知识对齐」——计划文档阶段就补充知识与资料库（不只是列清单），建立「任务知识简略要点」产物，确保执行期即便是小模型处理也能稳定执行。

## 基线事实（勿凭记忆改写）
- 技能源码仓 canonical：`/mnt/data/dev/task-planner-skill/skills/task-planner/**`；部署位 = skills 3 实体位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）；companion agents/plan-writer.md 还须对齐 2 位（~/.zcode/agents/plan-writer.md 与 ~/.claude/agents/plan-writer.md，后者 model 行为 claude 格式 sonnet）；禁跑 sync-companion 反向拉回，一律定向 cp。
- 基线（task-v066 后 merge 9b3619d）：selftest 11 套件 180 用例 0 fail；config 27 键；SKILL.md 510 行（500 边界遗留，净增 ≤10 行硬约束，细节进 references/）；Rule 21.1b/21.2/22.4/22.6 已存在；templates/ 12 variant + task_plan 模板统一含「📚 必要知识储备」章节（现行=清单+开工前确认可获取，无要点提炼产物）；init-session.sh 建 5 文件；check-dispatch.sh 守卫 22.4a 三文件契约（selftest-dispatch 18 用例）。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `7faf38a5235e4337b64241edd6a4b690` | 启动时生成,注册表追踪 |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v067-knowledge-brief` | §十一 隔离决策已有字段 |
| `scope_files` | `[skills/task-planner/templates/knowledge-brief.md(新增), skills/task-planner/scripts/init-session.sh, skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/companion/agents/plan-writer.md, skills/task-planner/config.json, skills/task-planner/scripts/selftest-knowledge-brief.sh(新增)]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `silent` | Rule 28 交互模式：静默执行+静默决策清单登记（交付报告含清单） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
-->

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | templates/knowledge-brief.md 存在（五段格式）且 init-session.sh 端到端在临时目录建出 6/6 文件（含 brief），5/5→6/6 校验行已同步 | 临时目录 `bash scripts/init-session.sh` 后 `ls` + `grep` 校验行含 6/6 | worktree `skills/task-planner/templates/knowledge-brief.md` + 临时目录 ls 输出 |
| VC-2 | SKILL.md「必要知识储备」段强化落地（清单→计划期采集+提炼要点产物）+ References 指针行，净增 ≤10 行（wc -l ≤520，细节全进 references/） | `wc -l SKILL.md` ≤520 + diff 新增行数统计 | worktree `skills/task-planner/SKILL.md` |
| VC-3 | references/critical-rules.md 联动条款落地：Rule 21.2 自包含补 brief 锚点引用 + 22.4 材料包段补 brief 路径；22.4a 三文件硬契约是否扩展按 Phase 2 KQ2 裁定执行；若扩展则 check-dispatch.sh + selftest-dispatch 同步且无回归 | `grep -n "brief" skills/task-planner/references/critical-rules.md` 命中 21.2+22.4 段 + `bash scripts/selftest-dispatch.sh` 0 fail | worktree critical-rules.md + selftest-dispatch 输出 |
| VC-4 | companion/agents/plan-writer.md 更新「计划期产出 brief」职责（canonical 1 处），且 Phase 5 后与 2 部署位对齐（~/.zcode/agents 原样一致；~/.claude/agents model 行为 sonnet） | `md5sum` canonical vs ~/.zcode/agents/plan-writer.md 一致 + `grep "^model" ~/.claude/agents/plan-writer.md` = sonnet | `skills/task-planner/companion/agents/plan-writer.md` + 2 部署位 |
| VC-5 | config.json 新键 `knowledge_brief_enforce`（enum enforce/warn/off，default warn，流程层执行）落地 + scripts/selftest-knowledge-brief.sh 全绿 + 全量 selftest 0 fail（基线 180 用例无回归） | `python3 -c "import json;print(json.load(open('<worktree>/skills/task-planner/config.json'))['knowledge_brief_enforce'])"` 输出 warn + 全量 `bash scripts/selftest-*.sh` | worktree config.json + selftest 输出 |
| VC-6 | 跨文件一致：brief 概念在 SKILL.md / critical-rules.md / templates（knowledge-brief.md + task_plan.md 章节）/ companion agent / config.json 五处的键名与路径 grep 一致（单一文件名 knowledge-brief.md，无别名漂移） | `grep -rn "knowledge-brief\|knowledge_brief" skills/task-planner/` 人工对账 | grep 输出 + findings.md 对账节 |
| VC-7 | Code Review Gate APPROVED + 合并回 master（merge_back=merged(<commit>)）+ 部署对账（skills 3 位 + agent 2 位 diff/md5 一致） | Code Review 结论 + `git log` merge commit + 部署位 diff 输出 | findings.md Code Review 节 + progress.md Phase 5 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件（路径均相对 canonical 仓根 /mnt/data/dev/task-planner-skill，实现阶段在 worktree 内对应位置操作）
  - 未在列表中的文件一律不碰；如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | skills/task-planner/templates/knowledge-brief.md（新增）, skills/task-planner/companion/agents/plan-writer.md | 其他 agent/模板（例外：templates/subagent_dispatch.md 仅知识上下文包表 +1 行，Phase 2 修订 S3） |
| 测试 | skills/task-planner/scripts/selftest-knowledge-brief.sh（新增） | 其他 selftest/断言 |
| 配置 | skills/task-planner/config.json（仅 +1 键 knowledge_brief_enforce） | 其他 config 键 |
| 文档 | skills/task-planner/SKILL.md（净增 ≤10 行）, skills/task-planner/references/critical-rules.md（21.2/22.4 补句，不动 22.4a）, skills/task-planner/references/template-mapping.md（白名单表 5→6）, skills/task-planner/references/template-guide.md（§2.4 补 brief 说明） | 其他 references |
| 脚本 | skills/task-planner/scripts/init-session.sh（6/6 同步）, skills/task-planner/scripts/check-scope.sh（:66 白名单 +brief，否则执行期写 brief 被拦） | 其他 scripts |

> 注：后三类修订于 Phase 2 设计定稿（findings.md「Phase 2 设计定稿」接入链表 #4/#5/#6/#7，变更联动审计要求 check-scope/template-mapping/template-guide/subagent_dispatch 必须同步）；S-unit 表相应重构为 S1-S6；KQ2 裁定轻量方案（不扩 22.4a，selftest-dispatch 零波及）。

**部署位写入（Phase 5 专属，不占实现期 Scope）**：~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner（3 位，smart-merge-back.sh --deploy）+ ~/.zcode/agents/plan-writer.md、~/.claude/agents/plan-writer.md（定向 cp，claude 位 model 行 sed 为 sonnet；禁跑 sync-companion）。

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。
>
> **本任务即"知识储备升级"任务，本表同时是 knowledge-brief 格式的种子样本**：本任务的 brief 五段产物按 templates/knowledge-brief.md（Phase 3 S1 新建）产出到 `plans/task-v067-knowledge-brief/knowledge-brief.md`（init-session 补建），Phase 1/2 结论持续回填。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | task-planner 技能 canonical 源码（本轮改动全部落点） | `/mnt/data/dev/task-planner-skill/skills/task-planner/**`（master 9b3619d 之后 + worktree 内修改） | 必读 | ☑ |
| 项目内部文档/知识库 | 现行「📚 必要知识储备」全链路（task_plan 模板章节 + 12 variant + SKILL.md 约束行 + plan-writer.md 填写职责 + subagent_dispatch.md §2 材料包） | worktree 内同名文件；Phase 1 explore 产出 `plans/task-v067-knowledge-brief/subagent-state/01-explore-knowledge.md` 含逐处 file:line 锚点 | 必读 | ☑ |
| 项目内部文档/知识库 | 22.4a 三文件硬契约守卫与 selftest 影响面 | `skills/task-planner/scripts/check-dispatch.sh`（"三文件"逻辑）+ `scripts/selftest-dispatch.sh`（18 用例） | 必读 | ☑ |
| 项目内部文档/知识库 | fmea_enforce/skill_collab_enforce 范式（config 新键 enum enforce/warn/off 写法先例） | worktree `skills/task-planner/config.json`（v063/v066 键块） | 必读 | ☑ |
| 项目内部文档/知识库 | 基线 selftest 11 套件 180 用例 0 fail 记录 | `plans/task-v066*/task_plan.md` + master 9b3619d merge 记录 | 参考 | ☑ |
| 规范/标准 | Rule 25.3 主进程直做白名单（Phase 2/4/5 例外理由引用） | `skills/task-planner/references/critical-rules.md` Rule 25.3 段 | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 计划期知识准备停留在"清单"（列了来源但未提炼），执行期小模型拿到材料包仍须自行探索 → 稳定执行无保障；解法 = 计划期产出 knowledge-brief 五段要点产物并接入材料包/契约链路。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（能：brief 模板+全链路接入+selftest 全绿+部署对账 = 可交付）
- [x] 核心问题不解决，其他工作都白费吗？（是：链路不接入则 brief 沦为孤文件，"小模型稳定执行"诉求不成立）
- [x] 核心问题的解决方法是清晰的、可执行的？（清晰：五段格式+KQ1-KQ4 接入点裁定路径+Phase 2 定稿设计）

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
已交付（COMPLETE, merge 9dacc9d, 2026-09-14）

## Next Step
task-v068（执行稳定性增强——哨兵误拦自愈/tamper 自愈重锁/hook 提醒降噪/停车点穷尽自主）待用户启动

## Phases

### Phase 1: 现行知识储备全链路调研
- [x] 盘点 templates/task_plan.md「📚 必要知识储备」章节 + 12 variant 模板的章节一致性
- [x] 盘点 companion/agents/plan-writer.md 的填写职责段 + subagent_dispatch.md §2 材料包输入块 + S-unit 表「输入」列惯例
- [x] 盘点 check-3file-gate.sh / check-complete.sh / check-dispatch.sh 是否校验知识储备/brief；selftest-dispatch 18 用例中"三文件"断言面定位（KQ2/KQ3 决策依据）
- [x] 调研结论 + 逐处 file:line 锚点写 checkpoint 01，主进程回填 findings.md
- **V-N:** VC-1, VC-3
- **Status:** complete（证据: subagent-state/01-explore-knowledge.md 8/8 锚点 + findings.md Research Findings 段; plan-writer 空档实锤=0 命中）
- **Executor:** explore（mini）

#### S-unit 表（Rule 22.6）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 现行知识储备全链路盘点（模板/agent/守卫/selftest 影响面） | 继承 | worktree `/home/terry/task-planner-skill-worktrees/task-v067-knowledge-brief/skills/task-planner/`（材料包摘要:①`templates/task_plan.md`「📚 必要知识储备」章节 + `templates/variant/*.md` 12 文件同章节一致性；②`SKILL.md` 末段"所有模板统一含必要知识储备章节"约束行；③`companion/agents/plan-writer.md` 职责段（「掌握的技能」任务分解/材料包预写）；④`templates/subagent_dispatch.md §2` 材料包输入块；⑤`scripts/check-3file-gate.sh`、`check-complete.sh`、`check-dispatch.sh`（"三文件"守卫）+ `scripts/selftest-dispatch.sh`（18 用例）；⑥`scripts/init-session.sh`（建 5 文件）；⑦`config.json`（27 键，找 fmea_enforce/skill_collab_enforce 块作新键范式参照）。禁止修改任何文件，只读盘点） | checkpoint `plans/task-v067-knowledge-brief/subagent-state/01-explore-knowledge.md` 含：逐处 file:line 锚点表 + 22.4a 三文件契约扩为四文件的 selftest 断言波及面清单（KQ2 依据）+ 建议 | ≤15min | pending |

### Phase 2: 设计定稿（五段格式 + 接入点裁定 + 门控）
- [x] 定稿「任务知识简略要点」(knowledge-brief) 五段格式：①任务一句话与核心概念/术语速查 ②已验证关键事实+证据锚点 file:line ③关键文件路径→行号→≤10 行摘要锚点表 ④易错点/禁止假设清单 ⑤S-unit 材料包索引（哪个 S-unit 读 brief 哪节）
- [x] 接入点裁定 KQ1-KQ4（KQ1 第 6 文件 / KQ2 轻量方案不扩 22.4a / KQ3 不纳入 3file-gate / KQ4 流程约束）+ 门控方案（knowledge_brief_enforce 流程层执行语义）
- [x] 结论 + 五段格式定稿全文写 findings.md（Phase 3 各 S-unit 的材料包来源）
- **V-N:** VC-2, VC-3
- **Status:** complete（证据: findings.md「Phase 2 设计定稿」KQ1-4 裁定+五段骨架+接入链 11 行表; 计划修订 scope/S-unit 表重 attest）
- **Executor:** 主进程（例外理由:②计划系统文件维护+调度规划设计本职——Rule 25.3 白名单）

### Phase 3: 实现（worktree 内串行 S1→S5）
- [x] S1 新增 templates/knowledge-brief.md + init-session.sh 建第 6 文件 + check-scope.sh 白名单同步
- [x] S2 template-mapping.md 白名单表 5→6 + template-guide.md §2.4 brief 说明
- [x] S3 critical-rules.md 21.2/22.4 补 brief 句（不动 22.4a）+ subagent_dispatch.md 知识上下文包表 +1 行
- [x] S4 SKILL.md :509 段强化 + References 指针行（净增 ≤10 行）
- [x] S5 companion agents/plan-writer.md 计划期产出 brief 职责（canonical 1 处；部署位对齐放 Phase 5）
- [x] S6 config.json 新键 knowledge_brief_enforce（默认 warn）+ scripts/selftest-knowledge-brief.sh
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete（证据: 6 S-unit 全 done 各自主进程一手复验 PASS; Handoff 02-07 全 ☑; 12 文件 10 改 2 新; commit 见 git log wt 分支; selftest-dispatch 18/18 零波及证 KQ2 裁定正确）
- **Executor:** executor（sonnet-1，worktree 内串行）

#### S-unit 表（Rule 22.6；Phase 2 修订版 S1-S6，材料包=findings.md「Phase 2 设计定稿」对应行 + checkpoint 01 锚点）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 新增 knowledge-brief.md 五段模板 + init-session.sh 建第 6 文件 + check-scope.sh 白名单同步 | 继承 | worktree `skills/task-planner/`（材料包: findings「Phase 2 设计定稿」五段格式骨架 + 接入链 #1/#2/#3；锚点 checkpoint 01 §7 init-session :90/:120/:131 + §4 check-scope:66） | 临时目录 init-session 建 6/6 文件; check-scope 对 brief 放行（scope 白名单含 knowledge-brief.md）; bash -n 两脚本过 | ≤15min | done（联动加改 check-3file-gate.sh:43 文案 5→6; init-session.ps1 旧链路未动登记） |
| S2 | template-mapping.md 白名单表 5→6 + template-guide.md §2.4 brief 说明 | 继承 | worktree `references/`（材料包: 接入链 #4/#5 + checkpoint 01 §1 template-guide:65 grep 锚与 :68 插入位置约束） | grep "knowledge-brief" 两文件 ≥1 命中; 白名单表 6 文件齐; :65 锚计数语义核对记录 | ≤15min | done（实际落点 guide §2.5 :70-73） |
| S3 | critical-rules.md 21.2/22.4 补 brief 句（不动 22.4a）+ subagent_dispatch.md 知识上下文包表 +1 行 | 继承 | worktree `references/critical-rules.md` :115/:127 + `templates/subagent_dispatch.md` :25-29（材料包: 接入链 #6/#7 + checkpoint 01 §6 锚点；约束: 禁改 22.4a 三文件契约原文） | grep brief 命中 21.2+22.4 段; dispatch 表 brief 行存在; 22.4a 原文 diff 零改动 | ≤15min | done |
| S4 | SKILL.md :509 段强化 + References 指针行（净增 ≤10） | 继承 | worktree `skills/task-planner/SKILL.md`（材料包: 接入链 #8 + 现行 :509 约束行原文 + :316 指针插入位） | wc ≤520; grep "knowledge-brief.md" ≥2; 旧 :509 语义（缺失→STOP）保留 | ≤15min | done |
| S5 | plan-writer.md 计划期产出 brief 职责（三处落点） | 继承 | worktree `companion/agents/plan-writer.md`（材料包: 接入链 #9 + :37-43 掌握的技能/:98-116 产出契约/:188 禁止行为锚点 + 五段格式骨架） | grep "knowledge-brief\|知识简略要点" ≥2 命中（职责+契约/禁止行为）; canonical 1 处修改 | ≤15min | done |
| S6 | config.json knowledge_brief_enforce 键 + scripts/selftest-knowledge-brief.sh 新建 | 继承 | worktree `config.json` :81-100 范式 + :327 properties 登记 + `scripts/selftest-skill-collab.sh` 风格参照（材料包: 接入链 #10/#11 + findings T1-T10 用例清单） | python3 读到 default=warn; 新 selftest 全绿; 全量 selftest 0 fail（基线 180 无回归） | ≤15min | pending |

### Phase 4: 验证
- [x] 全量 selftest 0 fail（11 套件基线 180 用例 + 新增 selftest-knowledge-brief）
- [x] init-session 端到端：临时目录建 6 文件核验（VC-1 实测）
- [x] 一致性 grep（VC-6 五处键名/路径对账，结果落 findings.md）
- [x] Code Review Gate（required；结论 + 静默决策清单登记）
- **V-N:** VC-5, VC-6
- **Status:** complete（证据: 全量 12 套件 196 例 0 fail + smoke 17/0 + 一致性 9 文件 + Code Review APPROVED（2 P3 登记遗留 D-2）; verification.md 7/7 VC）
- **Executor:** code-runner-agent（mini）+ 主进程机械验证白名单③（跑测本体派 code-runner-agent；机械 grep/wc/selftest 结果收取与 Code Review 编排由主进程做）

#### S-unit 表（Rule 22.6）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 全量 selftest + init-session 端到端 + 一致性 grep | 继承 | worktree `skills/task-planner/scripts/selftest-*.sh`（材料包: 基线 180 用例 0 fail + 新增套件；命令清单: 逐个 bash 跑）+ `scripts/init-session.sh` 临时目录执行 + `grep -rn "knowledge-brief\|knowledge_brief" skills/task-planner/` 对账 | selftest 全部 0 fail 输出；临时目录 6/6 文件；grep 对账结果落 checkpoint | ≤15min | pending |

### Phase 5: 合并部署交付
- [x] smart-merge-back.sh --deploy（skills 3 实体位）
- [x] companion agent 2 位定向 cp 对齐（~/.zcode/agents/plan-writer.md 原样 cp；~/.claude/agents/plan-writer.md cp 后 model 行 sed 为 sonnet；禁跑 sync-companion 反向拉回）
- [x] diff/md5 复验（skills 3 位 + agent 2 位）+ worktree 清理（git worktree remove + git branch -d wt/task-v067-knowledge-brief）
- [x] 交付报告（含静默决策清单 + merge_back=merged(<commit>) 回写本计划）
- **V-N:** VC-4, VC-7
- **Status:** complete（证据: merge 9dacc9d + skills 3 位 IDENTICAL + agent 2 位 md5=267e1f0b×2/claude model=sonnet + worktree list 干净 + 主仓复验 16/16 + check-complete exit 0）
- **Executor:** 主进程（例外理由:① git 编排+②簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①-⑤ 摘要:仅会话私有文件 + plans/INDEX.md 簿记；无与任务范围重叠的未提交变更） |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v067-knowledge-brief` |
| `branch` | `wt/task-v067-knowledge-brief`（基于 master 9b3619d） |
| `merge_back` | `merged(9dacc9d)`（smart-merge-back V1-V6 全 OK + --deploy skills 3 位 IDENTICAL + agent 2 位定向 cp 核验 + worktree/分支已清理） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。本会话 sid=7faf38a5235e4337b64241edd6a4b690。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 S1 | init-session.sh 改坏既有 5 文件流程（6 文件校验行漏改/模板缺段） | 7 | 4 | 5 | 140 | 兜底: 临时目录端到端实测 6/6 + 既有 5 文件逐一 diff 对照（22.3 ①改派 executor 补修 + ②smoke 验证后重跑 Phase 4） |
| Phase 3 S3 | KQ2 裁定为"扩展 22.4a 契约"时波及 check-dispatch 守卫 + selftest-dispatch 18 用例未同步 | 6 | 5 | 6 | 180 | 兜底: KQ2 裁定优先轻量方案（材料包段引用 brief 路径，零波及）；若裁定重量方案 → 先 grep selftest-dispatch 断言面清单（findings KQ2 依据）再动手，断言失败走 22.3 ①改派 Debugger |
| Phase 5 | plan-writer agent 部署位漂移（claude 位 model 行未 sed / 定向 cp 漏位 / 误跑 sync-companion） | 7 | 4 | 5 | 140 | 兜底: Phase 5 定向 cp + md5 核验（claude 位 model 行 grep 须为 sonnet）；漂移 → 重新定向 cp（22.3 ②拆细重做该步骤，禁 sync-companion 反向拉回） |
| Phase 2 | KQ1-KQ4 裁定与设计草案冲突导致 Phase 3 返工 | 5 | 3 | 6 | 90 | （RPN≤100，留白）裁定结论必落 findings.md 供 S-unit 材料包引用，冲突即 STOP 报告 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions（Phase 2 已裁定）
1. **KQ1** → init-session 第 6 文件 `plans/<task-id>/knowledge-brief.md`（模板 templates/knowledge-brief.md）；避免 task_plan 膨胀（Rule 19.6）
2. **KQ2** → **轻量方案：不扩 22.4a 硬契约**（波及 check-dispatch 7 处+selftest 5 组+存量兼容）；brief 经 22.4 材料包段+dispatch 知识上下文包表引用注入；扩契约登记为后续独立任务
3. **KQ3** → 不纳入 check-3file-gate（存量 5 文件计划全量补建否则 exit 1=破坏兼容）；brief 靠 init 建档+plan-writer 职责+SKILL 条款保障；enforce 档预留
4. **KQ4** → 补流程约束（22.4 材料包段一句「brief 存在时材料包摘要应引用 brief 节锚点」+ plan-writer S-unit 输入列注明 brief 节锚点），非硬契约

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| template_type=skill-fix；Batch Report 与 Chain 区块删除（single 模式非批量） | 用户调用指令 + 单 skill 任务 |
| brief 落点 = init-session 第 6 文件 `plans/<task-id>/knowledge-brief.md`（KQ1 定稿） | 避免 task_plan.md 膨胀违反瘦身 Rule 19.6；6/6 校验行同步成本可控 |
| KQ2 轻量方案：不扩 22.4a，brief 经材料包+知识上下文包表注入 | checkpoint 01 §2 波及面（check-dispatch 7 处+selftest 5 组）风险 >> 收益；扩契约登记后续独立任务 |
| KQ3 不纳入 check-3file-gate | 存量 5 文件计划全量补建否则 exit 1 = 破坏存量兼容（checkpoint 01 §3） |
| KQ4 流程约束而非硬契约 | 22.4 补一句+plan-writer 职责即可达意图，硬契约属 KQ2 范畴 |
| S-unit 表 S1-S5 重构为 S1-S6 + scope 表补 4 个联动文件 | 变更联动审计 P0：check-scope 白名单不同步则执行期写 brief 被 scope guard 拦截；template-mapping/template-guide/subagent_dispatch 同理 |
| config 新键 knowledge_brief_enforce 默认 warn、流程层执行 | 对齐 fmea_enforce/skill_collab_enforce 范式；注意 config.json:327 additionalProperties 需登记 |
| 部署纪律: skills 3 位 smart-merge-back.sh --deploy + agent 2 位定向 cp（claude 位 model 行 sed sonnet），禁 sync-companion 反向拉回 | 用户指令背景事实（P0 不改写） |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- brief 五段格式速记：①任务一句话与核心概念/术语速查 ②已验证关键事实+证据锚点 file:line ③关键文件路径→行号→≤10 行摘要锚点表 ④易错点/禁止假设清单 ⑤S-unit 材料包索引
- **task-v068 候选登记（用户 09-13 指令「优化执行稳定性,减少中途打断,主动解决而非被打断」）**：v067 交付后立项——机制化候选：①会话哨兵误拦自愈（v065 D-12+v060 非交互清不掉，本会话两次复现）②hook 慢导致 Edit 超时（delegation-observe 30s 超时但写入已生效）③PLAN TAMPERED 自修订自愈重锁④hook 密集提醒降噪/合并⑤22.3.3 精神扩展至全部停车点（穷尽自主手段才停）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-13 | ✅ ALIGNED | VC-1..7 | Phase 1/2 全程仅 plans/ 簿记+只读调研，无 scope 外写入；drift-guard 检查单在会话内执行（skill 已加载，省重入） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 5（执行期回填：Phase 1 explore / Phase 3 executor / Phase 4 code-runner-agent） |
| 主进程直做 Phase 清单 | Phase 2（②计划系统文件维护+调度规划设计本职）、Phase 4 机械验证白名单③、Phase 5（① git 编排+②簿记） |
| 委派率 | （执行期回填；< delegation_rate_floor 默认 0.7 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 00 | 2026-09-13 | plan-writer | 撰写 task-v067 知识简略要点增强计划（覆盖本 stub） | done | 5 Phase/7 VC/FMEA 3 行 RPN>100 有兜底; 附加「本任务自产 brief 种子样本」设计; 主进程 Read 复核通过 | task_plan.md:1-263 | 基线事实段 | plans/task-v067-knowledge-brief/subagent-state/00-plan-writer.md | | 0 | ☑ |
| 01 | 2026-09-13 | explore | Phase 1 S1 调研：现行知识储备+材料包链路盘点 | done | 8/8 锚点表+KQ2 波及面（check-dispatch 7 处+selftest 5 组）+KQ3 存量兼容依据+plan-writer 0 命中空档实锤; 主进程落盘 checkpoint+findings 回填 | subagent-state/01-explore-knowledge.md 全文 | Research Findings 段 | plans/task-v067-knowledge-brief/subagent-state/01-explore-knowledge.md | | 0 | ☑ |
| 02 | 2026-09-13 | executor | S1 brief 模板+init-session 6/6+check-scope 白名单 | done | 端到端 6/6+白名单功能验证(brief 放行/他文件拦)+check-3file-gate 文案联动; 主进程一手复验 PASS; 纠正:注释 L9 实含「必要知识储备」词句 1 次(执行器称 0),锚计数 20 未变,微修并入 S2 | init-session.sh:91,122,133 | [sub:02-executor] S1 产出 | plans/task-v067-knowledge-brief/subagent-state/02-executor-s1.md | | 0 | ☑ |
| 03 | 2026-09-13 | executor | S2 template-mapping 白名单 5→6+template-guide 说明+brief 模板注释微修 | done | mapping :163 六文件表(行号漂移顺修)+guide §2.5 新条目+brief L9 词句清零; 主进程一手复验(两 refs 各 1 命中/词 0/锚 20) PASS | template-mapping.md:163, template-guide.md:70-73 | [sub:03-executor] S2 产出 | plans/task-v067-knowledge-brief/subagent-state/03-executor-s2.md | | 0 | ☑ |
| 04 | 2026-09-13 | executor | S3 critical-rules 21.2/22.4 补 brief 句+dispatch 知识包表 +1 行 | done | :115/:127 补句落地; 22.4a/c diff=0; dispatch :29 brief 行; 主进程一手复验 PASS | critical-rules.md:115,127 | [sub:04-executor] S3 产出 | plans/task-v067-knowledge-brief/subagent-state/04-executor-s3.md | | 0 | ☑ |
| 05 | 2026-09-13 | executor | S4 SKILL.md :509 段强化+References 指针行 | done | 513 行净+3; 采集/STOP 保留+:511 提炼+:512 引用+:316 指针; 返回消息+checkpoint 缺失,按 22.8.5 以主进程一手复验为准(产出实体验讫) | SKILL.md:510-512,316 | [sub:05-executor] S4 产出(未落盘,主进程代验) | plans/task-v067-knowledge-brief/subagent-state/05-executor-s4.md(缺失) | timeout(消息截断,产出完好) | 0 | ☑ |
| 06 | 2026-09-13 | executor | S5 plan-writer.md 计划期产出 brief 职责 | done | 三落点 :45/:113/:192+description :4 顺带; grep 4 命中; 契约表行禁凭记忆编造约束; 主进程一手复验 PASS | plan-writer.md:45,113,192 | [sub:06-executor] S5 产出 | plans/task-v067-knowledge-brief/subagent-state/06-executor-s5.md | | 0 | ☑ |
| 07 | 2026-09-13 | executor | S6 config knowledge_brief_enforce 键+selftest-knowledge-brief.sh | done | config :101-110 键块(default warn,properties 合规)+新 selftest 16 断言全绿(T5b 智能修正:KQ3 锚定存在性循环而非全文件)+dispatch 18/18 零波及+SKILL :512 行内补键指针(0 新增行); 主进程一手复验 PASS | config.json:101-110 | [sub:07-executor] S6 产出 | plans/task-v067-knowledge-brief/subagent-state/07-executor-s6.md | | 0 | ☑ |
| 2 |  |  |  |  |  |  |  |  |  | 0 | ☐ |
