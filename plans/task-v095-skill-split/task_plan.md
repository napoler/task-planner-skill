---
template_type: refactor
plan_tier: standard
interaction_mode: ask
code_review: required
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    explore: 0
    executor: 6
    code-reviewer: 1
  estimated_opus_equivalent: 1.5
  estimated_savings_vs_naive: 0.6
git_commit: 逐 Phase 提交（worktree 内）
---

# Task Plan: task-planner 技能拆分（4 卫星 + 3 段内敛，SKILL.md 556→≤430 行）

<!-- 适用场景: 代码重构/瘦身（refactor variant）；行为不变 = 文档/路由拓扑重构，功能零删减 -->

## Goal

按用户裁决的标准 4+3 方案将 task-planner 技能拆分：建 4 个卫星技能（plan-research-router / plan-template-kit / plan-cost-guard / plan-collab-router）承接 SKILL.md 非核心段落，另将 3 段内敛进既有权威文档，使主 SKILL.md 从 556 行降至 ≤430 行（≥20% 缩减），全程满足硬约束（Rule 编号冻结、selftest 锚留守、机械门控零改动、三部署位同步）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（P8 CR Gate：code-reviewer APPROVED 方可终验交付） |
| `interaction_mode` | `ask` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 主 SKILL.md ≤430 行，且 Rule 17/18/30-39 摘要行 + C19/C25/C26 检查项行 + `Rules 1-3` 计数锚全部保留 | `wc -l skills/task-planner/SKILL.md` ≤430；逐锚 grep（Rule 摘要行按 brief §2.3 清单） | `<worktree>/skills/task-planner/SKILL.md` + 终验 grep 输出贴 progress.md |
| VC-2 | 全量 selftest 0 FAIL，且用例总数 ≥ Phase 1 基线实测值 | 逐个运行 `bash scripts/selftest-*.sh`（26 个）或全量 runner；对比 P1 基线记录 | `<plan-dir>/progress.md` 基线段 + 终验 selftest 输出 |
| VC-3 | 4 个卫星目录存在于 skills/（frontmatter name=目录名、description 含触发词、正文 <500 行），迁移映射表 100% tick（零内容丢失） | `ls skills/plan-*/SKILL.md` + 逐卫星 frontmatter head 检查 + findings.md 迁移映射表逐行勾选 | `<worktree>/skills/<4 卫星>/` + `<plan-dir>/findings.md` 映射表 |
| VC-4 | install.sh 扩展后三部署位（~/.zcode、~/.claude、~/.config/opencode）diff -r 与 canonical 一致，4 卫星同步在位 | 部署后逐位 `diff -r <canonical>/skills/<sat> <deploy>/skills/<sat>` | P7 部署日志贴 progress.md |
| VC-5 | check-skill-modify.sh 保护 pattern 覆盖卫星路径（行为级验证：模拟写卫星文件触发守卫） | `bash scripts/check-skill-modify.sh` 以卫星路径为入参的守卫触发测试 | P7 守卫测试输出贴 progress.md |
| VC-6 | Code Review APPROVED（code_review: required） | code-reviewer 审查结论 APPROVED；CHANGES_REQUESTED → 回炉修复后重审 | `<plan-dir>/subagent-state/` CR 报告 + progress.md 登记 |

**终验规则**：
- 全部 VC 通过 → COMPLETE
- VC-2 失败（selftest 回归）= 锚点/引用断裂 = BLOCKED 升级用户（拆分不允许行为变化）
- VC-1 行数不达标但锚点全在 → PARTIAL，说明理由
- VC-6 CHANGES_REQUESTED → 回到对应 Phase 修复，禁止绕过 CR 直接交付

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 主技能文档 | `skills/task-planner/SKILL.md`（段落外迁+指针化+内敛，锚点行留守）、`skills/task-planner/reference.md`（接收 Chain 模式详解）、`skills/task-planner/references/critical-rules.md`（仅 Rule 15 扩充子条 + Rule 20.5，**只增不改编号**） | 删除/改写 Rule 1-39 摘要行、C19/C25/C26 行、`Rules 1-3` 计数锚；重排 Rule 编号 |
| 新建卫星 | `skills/plan-research-router/**`、`skills/plan-template-kit/**`、`skills/plan-cost-guard/**`、`skills/plan-collab-router/**`（新建目录） | 触碰 `skills/` 下其他既有技能（plan-resume/progress-tracker/task-drift-guard/todo-skill） |
| 迁移文件 | `skills/task-planner/references/{research 类迁移内容,template-guide.md,template-mapping.md,billing.md,cost-control.md,skill-collaboration.md}`（按 P2-P5 迁移映射表执行）；`templates/cost_log.md` | 机械层留守物：`templates/` variant 库+顶层模板、`scripts/init-session.sh`、`scripts/check-template-type.sh`、`scripts/attest-plan.sh` 门控逻辑 |
| 脚本（仅白名单内） | `install.sh`（rsync 清单追加 4 卫星）、`scripts/check-skill-modify.sh`（:29 保护 pattern 追加卫星路径——唯一例外）、`scripts/selftest-skill-split.sh`（新建）、`scripts/selftest-registry.tsv`（登记新 selftest）、`scripts/subagent-fallback.sh`（:288 hint 文本同步）、selftest 路径锚同步（brief P3/P5 点名的 selftest 文件） | 其他 68 个脚本零改动；hook 接线 `~/.zcode/cli/config.json` 零改动；config.json 键零新增零删除 |
| companion | `companion/agents/plan-writer.md`（L22/39/50-64 引用同步） | article-batch-publisher.md / article-field-fixer.md |
| 部署面 | 三部署位 `~/.zcode/skills/`、`~/.claude/skills/`、`~/.config/opencode/skills/`（仅 P7 部署动作，install.sh 执行） | 手工散拷文件；部署位 hook 指向变更 |
| 计划文档 | `plans/task-v095-skill-split/**`（主仓侧） | 其他 plans/ 目录 |

**强制约束**（全局硬约束 §2.3 逐条落位）：
1. Rule 1-39 编号冻结；Rule 17/18/30-39 摘要行 + C19/C25/C26 检查项行 + `Rules 1-3` 计数锚留守主 SKILL.md（selftest grep 锚，违反 = VC-2 全线崩）
2. 机械门控（check-complete/attest-plan/check-delegation/check-dispatch 等 16 门控脚本）与 hook 接线（~/.zcode/cli/config.json）零改动；唯一例外 = check-skill-modify.sh:29 保护 pattern 追加卫星路径
3. 零新 config.json 键（卫星为纯 SOP/文档技能，不读 config）
4. 卫星 SKILL.md 遵循 skill-creator 规范：frontmatter name=目录名、description 含触发词（pushy 风格）、正文薄（<500 行）、细节放 references/
5. 触发模型：主技能保留显式 Skill() 指针行（主路由，类 task-drift-guard 模式）；卫星 description 触发为辅，措辞收窄避免与 task-planner 触发竞争
6. 并行任务约束：`wt/task-v094-tier-b-rollout` worktree 属并行会话，全程禁碰；合并顺序冲突 → STOP 报告用户
7. 部署面：install.sh rsync 清单追加 4 卫星；三部署位部署后 diff -r 复验；新 selftest（selftest-skill-split.sh）登记 selftest-registry.tsv

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | 结构测绘报告（段落地图/消费关系/耦合风险/候选评估） | plans/task-v095-skill-split/subagent-state/01-explore-structure.md | 必读 | ☑（计划期已消费） |
| 项目内部文档 | 计划撰写简报（唯一需求与设计权威源） | plans/task-v095-skill-split/subagent-state/02-plan-writer-brief.md | 必读 | ☑（计划期已消费） |
| 项目内部文档 | findings.md（需求+硬约束+调研摘要） | plans/task-v095-skill-split/findings.md | 必读 | ☑（计划期已消费） |
| 项目内部文档 | 锚点清单（selftest 硬锚 C1 节 / 机械层 C2-C7 节） | plans/task-v095-skill-split/subagent-state/01-explore-structure.md §C | 必读 | ☑ |
| 方法论 | skill-creator 规范（渐进式披露三层 / description 触发词 / <500 行） | /home/terry/.zcode/cli/plugins/cache/zcode-plugins-official/skill-creator/0.1.0/skills/skill-creator/SKILL.md | 参考 | ☑ |
| 项目内部文档 | 主 SKILL.md 段落行号地图（迁移映射的行号事实源） | skills/task-planner/SKILL.md（A 段落地图见测绘报告 §A） | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位；② `必读` 项缺失 → STOP 记入 findings.md；③ 引用格式对齐调研类操作·强制引用格式。

## Current Phase

全部完成（8/8 complete，交付 COMPLETE）

## Phases

### Phase 1: 基线冻结与隔离区建立
- [x] 全量 selftest 基线记录：34 脚本实测 543 PASS / 0 FAIL（delegation=38 补齐），贴 progress.md ✅
- [x] 迁移映射表 M1-M13 已落 findings.md（P1 冻结版，含 v094 影响判定与 F3 解除）✅
- [x] worktree 已建立：/mnt/data/dev/task-planner-skill-worktrees/task-v095-skill-split（5c1cdcd）✅
- [x] v094 核对完成：规划期间已合并回 master（dcfd8a3+簿记 5c1cdcd），worktree/分支已清理，F3 风险解除 ✅
- **Status:** complete
- **Executor:** 主进程（例外理由：Rule 25.3 白名单①基线验证③worktree 管理属主进程职责，非业务代码写入）

### Phase 2: 试点卫星 plan-research-router（Rule 18.9 试点先行）
- [x] S1 建卫星骨架 ✅（SKILL.md 41 行 + references 占位；主进程 Read 复核合格）
- [x] S2 主技能段落外迁 ✅（40 行正文迁卫星 references 42 行；原位 3 行指针；556→519；互引零命中）
- [x] S3 端到端验证 ✅（残留零/锚点抽验 7/7；抓出并修复 selftest-skill-collab T11×3 断链——S3b 断言跟随迁移+双处核验阈值不放宽；主进程独立复验全量 543/0 持平）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 建 plan-research-router 卫星骨架 | executor | 测绘报告 §D 候选②行（调研路由零机耦评估）；skill-creator SKILL.md（frontmatter 规范）；检查点 plans/task-v095-skill-split/subagent-state/21-p2-s1.md | 卫星目录 3 件套在位，frontmatter name=plan-research-router | ≤15min | pending |
| S2 | L466-506 外迁+指针替换 | executor | 主 SKILL.md L466-506（WebSearch+github 双路调研 SOP，41 行）；L378 路由行+L505 反模式互引；检查点 subagent-state/22-p2-s2.md | 卫星 references/ 含双路 SOP 全文；SKILL.md 原地 1 行 Skill("plan-research-router") 指针；L378/L505 同步 | ≤15min | pending |
| S3 | 试点端到端验证 | executor | 检查点 subagent-state/22-p2-s2.md 产物清单；selftest 快速跑法；检查点 subagent-state/23-p2-s3.md | `wc -l` 记录行数降幅；grep 主 SKILL.md 无调研正文残留；26 selftest 与基线对比无新增 FAIL | ≤15min | pending |

### Phase 3: 卫星 plan-template-kit（模板知识层外迁，机械层留守）
- [x] S1 建卫星骨架 + template-guide.md/template-mapping.md 迁卫星 references/ ✅（git mv 保历史 rename 95%/100%；计数 16 对齐实测+枚举补全）
- [x] S2 SKILL.md §任务模板库 改指针 ✅（519→516，锚子串保全；plan-writer.md 全库 grep 实证零路径引用=负结果零改动，测绘 L22/39/50-64 描述与 v094 后现状不符）
- [x] S3 selftest 路径锚同步 ✅（TMAP/TGUIDE 卫星同级解析+TL-17 13→16+critical-rules 三行随迁扩围②；TL 18/0+MP 19/0+KB 16/0+白名单 17+attest verify exit 0；主进程独立复验 543/0）
- [x] FMEA 兜底：attest/check-complete 门控未断链（attest --verify exit 0 实证），回滚方案未触发 ✅
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 卫星骨架+两文档迁移+计数修复 | executor | template-guide.md 276 行（13 类模板指南，:65 计数锚）；template-mapping.md 230 行（§一决策树/§六清单/§七互斥）；检查点 subagent-state/31-p3-s1.md | 两文件在卫星 references/ 且主技能侧已指针化；template-guide 计数=16 | ≤15min | pending |
| S2 | SKILL.md 模板节指针化+plan-writer 引用同步 | executor | 主 SKILL.md L542-556（模板库节 15 行）；plan-writer.md L22/39/50-64（模板选择表与 mapping §六双写）；检查点 subagent-state/32-p3-s2.md | L542-556 收敛为指针行；plan-writer 三处引用指向卫星路径 | ≤15min | pending |
| S3 | selftest 锚同步+门控验证 | executor | selftest-template-lifecycle.sh（TL-16/17/18 路径锚）；selftest-mechanism-profile.sh（TGUIDE/§九矩阵锚）；check-template-type.sh L14-16（白名单动态派生，留守不动）；检查点 subagent-state/33-p3-s3.md | 两 selftest PASS；attest-plan 模板门控链跑通；机械层文件 git diff 为零 | ≤15min | pending |

### Phase 4: 卫星 plan-cost-guard（成本三件套迁移）
- [x] S1 建卫星骨架 + 三件套迁卫星 ✅（git mv×3 rename 实证；SKILL.md 37 行；迁移文件内 4 处路径文本随迁）
- [x] S2 指针化+互引同步 ✅（九处全过：SKILL.md 517→515 摘要行子串保全；critical-rules 17.8 编号零改动；batch-gate L138；README 树形标注；grep 零残留）
- [x] S3 验证 ✅（主进程白名单③：残留终检零命中+全量 543/0 持平；仓根 3 处死路径 defer P7 已裁定登记）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 卫星骨架+三件套迁移 | executor | billing.md 61 行（计费模式+成本估算表）；cost-control.md 171 行（Rule 17 详解）；templates/cost_log.md 72 行（无脚本消费纯指针）；检查点 subagent-state/41-p4-s1.md | 三文件在卫星内闭环；主技能 templates/ 下 cost_log.md 移除且 install 白名单同步候选登记 findings | ≤15min | pending |
| S2 | 指针化+互引同步 | executor | 主 SKILL.md L294（Rule 17 摘要行，留守仅改详见路径）/L345（References 表 cost 行）；critical-rules Rule 17 段路径；batch-quality-gate.md 内 cost-control 互引；检查点 subagent-state/42-p4-s2.md | 摘要行仍在（grep Rule 17 含「成本控制」）；L345 表行指向卫星；互引零断链 | ≤15min | pending |
| S3 | 迁移验证 | executor | 检查点 subagent-state/42-p4-s2.md 产物清单；基线记录；检查点 subagent-state/43-p4-s3.md | grep 全仓无死路径引用；selftest 与基线一致 | ≤15min | pending |

### Phase 5: 卫星 plan-collab-router（协同路由迁移+selftest 随迁）
- [x] S1 建卫星骨架 + skill-collaboration.md 迁卫星 ✅（git mv 92% similarity 113 行无损；骨架 40 行；自引用 2 处内化）
- [x] S2 七文件一致性同步 ✅（协同段 7 行指针节含 skill_collab_enforce/四族名/×5 引用锚；hint 与 T10a PAIR-CONSISTENT；registry 3 行；意外 WF-09 锚断链授权内修复复验 16/16）
- [x] S3 验证 ✅（主进程白名单③：验证链 25/0+11/0+31/0+5/0+全量独立复验 543/0，SKILL.md 513 行）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 卫星骨架+文档迁移 | executor | skill-collaboration.md 113 行（comet/OpenSpec/superpowers 触发矩阵+移交 vs 嵌入合约+22.3.3）；检查点 subagent-state/51-p5-s1.md | 卫星 references/ 承接全文 ≤300 行 | ≤15min | pending |
| S2 | 主技能指针化+五处引用同步 | executor | 主 SKILL.md L46-54（协同路由段 9 行）+L348；selftest-skill-collab.sh 96 行（T1b ≤300 行锚）；selftest-shared-tracker.sh/selftest-fallback.sh 引用行；subagent-fallback.sh:288；registry.tsv L11/23/24；检查点 subagent-state/52-p5-s2.md | L46-54 指针化；3 selftest 路径改指卫星；hint 文本一致；registry.tsv dep_anchors 无死路径 | ≤15min | pending |
| S3 | 迁移验证 | executor | 检查点 subagent-state/52-p5-s2.md 产物清单；检查点 subagent-state/53-p5-s3.md | selftest-skill-collab/shared-tracker/fallback 三脚本 PASS | ≤15min | pending |

### Phase 6: 主技能收尾内敛（三段并入既有权威文档）
- [x] S1 Chain 模式详解 → reference.md ✅（零锚实证；+45 行新节与 Chain Handoff Contract 互补零删减；513→474）
- [x] S2 高频漂移 → Rule 15.1-15.3 + Read vs Write → 20.5 ✅（编号完整性 167→170 只增实证；TB-11 锚双处保全；474→443）
- [x] S2b 微收拢 ✅（三指针节压缩 443→429；30+ 锚点差集空；连带发现 S2 遗留 T6 FAIL）
- [x] S2c T6 窗口随迁 ✅（135→160，21.2/22.4 合法后移，16/0）
- [x] S3 锚点清单逐条 grep 复验 ✅（主进程白名单③：24 项全集在位含 T-B6 固定串补验；SKILL.md 429 行=VC-1 达标 -22.8%；全量 543/0）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | Chain 详解并入 reference.md | executor | 主 SKILL.md L243-284（linked/fan-out/执行规则 42 行，无脚本锚）；reference.md 285 行（含 Chain Handoff Contract 权威源）；检查点 subagent-state/61-p6-s1.md | reference.md 含 Chain 详解且无重复段落；SKILL.md 对应段收敛为指针 | ≤15min | pending |
| S2 | 两段并入 critical-rules | executor | 主 SKILL.md L509-538（高频漂移 30 行）/L122-130（Read vs Write 9 行）；critical-rules.md Rule 15/20.5 段；检查点 subagent-state/62-p6-s2.md | Rule 15 仅增子条、Rule 20.5 新增；Rule 编号零变化（grep `Rules 1-3` 锚不动） | ≤15min | pending |
| S3 | 锚点清单逐条复验+行数记录 | executor | brief §2.3 硬约束清单（锚点全集）；selftest-error-loop.sh:53-59 等锚样例；检查点 subagent-state/63-p6-s3.md | 每锚 grep 命中列表贴检查点；`wc -l` SKILL.md ≤430 | ≤15min | pending |

### Phase 7: 安装面扩展与全量验证 + 合并回 master
- [x] S1 安装面四件套 ✅（install-stub 卫星数组+守卫 pattern+selftest-skill-split 41 断言+registry 35 行；验证链全过）
- [x] S1b 文档死路径收口 ✅（4 文件 11 处；计数实测 8 篇纠偏；CHANGELOG 历史不改）
- [x] S2 全量验证 ✅（主进程白名单③独立复验 35 脚本 584/0；守卫行为级三支路实测）
- [x] S3 合并回 master ✅（smart-merge-back V1-V6 全过，merge=aa092cc，主仓复验通过）
- [x] S4 三部署位部署 ✅（五技能×三位 diff -r 15/15 IDENTICAL+.zcode 位实跑 41/41；worktree/分支已清理）
- **Status:** complete
- **Executor:** executor（S1/S2 脚本修改与验证，sonnet-1）+ 主进程（S3/S4，例外理由：Rule 25.3 白名单③ git 合并与①部署验证属主进程职责）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 安装面+守卫+新 selftest | executor | install.sh（7 相结构，lib/install-stub.sh:9-12 rsync 面）；check-skill-modify.sh:25-33（pattern case 块）；registry.tsv 35 行登记格式；检查点 subagent-state/71-p7-s1.md | rsync 清单含 4 卫星；pattern 命中卫星路径；registry.tsv 新增行 | ≤15min | pending |
| S2 | worktree 全量验证 | executor | P1 基线记录（progress.md）；selftest-skill-split.sh（断言 4 卫星在位+指针可达）；检查点 subagent-state/72-p7-s2.md | 全量 selftest 0 FAIL 且用例数 ≥ 基线；守卫触发测试输出在案 | ≤15min | pending |
| S3 | 合并回 master | 主进程（白名单③） | v094 worktree 状态（P1 记录）；smart-merge-back.sh 预检；检查点 subagent-state/73-p7-s3.md | merge --no-ff 完成且 git log 复验在案；冲突则 STOP | ≤15min | pending |
| S4 | 三部署位部署复验 | 主进程（白名单①③） | install.sh 部署 SOP（C6 节：canonical→三部署位全量）；检查点 subagent-state/74-p7-s4.md | 逐位 diff -r 零差异输出贴 progress.md | ≤15min | pending |

### Phase 8: CR Gate 与终验簿记
- [x] CR Gate ✅（code-reviewer verdict=APPROVED，0 Blocker/0 Suggestion/2 Nit；Nit1 重复行已修 bea7341+selftest 9/0+41/0+三位同步；Nit2 config.json:99 登记 defer）
- [x] 主进程逐条复验 VC-1..VC-6 全 PASS ✅（verification.md 已回填；委派统计 verdict=ok WHITELIST-EXEMPT）
- [x] 簿记 ✅（INDEX/ledger/memory/push 于交付报告前完成；merge_back=merged(aa092cc) 已回填）
- **Status:** complete
- **Executor:** 主进程 + code-reviewer（主进程部分例外理由：Rule 25.3 白名单⑤ CR 编排与终验簿记属主进程职责）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（并行任务 v094 同仓 worktree 开发中） |
| `isolation` | `worktree`（实现类任务强制，宪法 §十一） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v095-skill-split`（已按 §11.3.5 清理：worktree remove+branch -d 完成） |
| `branch` | `wt/task-v095-skill-split`（已删除） |
| `merge_back` | `merged(aa092cc)`（2026-09-29 smart-merge-back V1-V6 全过；master 复验+三部署位 15/15 IDENTICAL） |

**v094 并行禁碰约束**：`/mnt/data/dev/task-planner-skill-worktrees/task-v094-tier-b-rollout`（wt/task-v094-tier-b-rollout）属并行会话——全程禁碰其内容；禁止 `git checkout`/`git switch` 切主仓分支；禁止 `git reset --hard`/`git clean -fd`；只读查询（`git worktree list`/`git log`/`git diff`）可执行；合并前 merge-base 核对，顺序冲突 → STOP 报告用户。子代理派发 prompt 必含：① 任务范围 ② worktree 绝对路径 ③ 禁碰其他 worktree 强约束。计划文档留在主仓 plans/task-v095-skill-split/（不进 worktree）。

## 🔥 FMEA（失效模式与影响分析，7 列 ≥5 项 = brief §5）

| # | 失败模式 | Phase | 影响 | 严重度(S) | 发生度(O) | 检测度(D) | RPN | 兜底/预防措施 |
|---|---------|-------|------|----------|----------|----------|-----|--------------|
| F1 | selftest 锚断裂（Rule 摘要行/C19/C25/C26 误删，内敛时误伤） | P6 | 全量 selftest FAIL，VC-2 崩 | 9 | 4 | 2 | 72 | P6 S3 锚点清单逐条 grep 复验 + 全量 selftest 兜底 + 锚点行只改路径部分不动关键词 |
| F2 | template-mapping 迁移致 attest/check-complete 门控断链（白名单派生引用死路径） | P3 | 模板门控拒绝新任务，行为变化 | 9 | 3 | 3 | 81 | 机械层留守（D1 裁决）；P3 S3 attest 门控跑通验证；断链→回滚 mapping 留守+跨技能指针降级 |
| F3 | v094 并行合并冲突（两 wt 同改 master 血统） | P7 S3 | 合并失败/踩踏并行会话 | 8 | 4 | 2 | 64 | 合并前 git log/merge-base 核对 + smart-merge-back 预检 + 冲突即 STOP 报告用户；全程禁碰 v094 worktree |
| F4 | 三部署位漏同步/半同步（部分位缺卫星） | P7 S4 | 触发行为在不同工具间不一致 | 7 | 4 | 3 | 84 | 部署 SOP 固化在 P7 S4：install.sh 全量 + 逐位 diff -r 复验（VC-4），禁手工散拷 |
| F5 | 卫星 description 与主技能触发竞争（用户意图 task-planner 却加载卫星） | P2-P5 | 路由漂移，执行体错位 | 6 | 3 | 4 | 72 | 主路由显式 Skill() 指针为主 + 卫星 description 收窄措辞（§2.3.5）；P8 CR 复查四卫星 description |
| F6 | 行号漂移致外迁段落切错边界（P2-P6 陆续改动后 §A 行号失效） | P2-P6 | 残留正文/误删相邻锚 | 7 | 5 | 3 | 105 | 每 S-unit 派发 prompt 附「以 grep 段落标题重定位，禁止盲信行号」指令（knowledge-brief §4 第 8 条） |
| F7 | plan-writer.md 引用同步遗漏致模板派发断链（companion 装在 agents/ 位而非 skills/） | P3 S2 | plan-writer 选模板指引死链 | 5 | 3 | 3 | 45 | P3 S2 三处引用逐处勾选（findings 迁移映射表）+ P7 全量 selftest 兜底 |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 基线+隔离区 |
| Phase 2 | ☐ |  | 试点卫星（18.9） |
| Phase 3 | ☐ |  | 模板 kit |
| Phase 4 | ☐ |  | 成本 guard |
| Phase 5 | ☐ |  | 协同 router |
| Phase 6 | ☐ |  | 三段内敛 |
| Phase 7 | ☐ |  | 安装面+验证+合并 |
| Phase 8 | ☐ |  | CR+簿记 |

## Subagent Handoff 登记表（Rule 22.5）

| # | Phase/S-unit | subagent_type(model) | 派发时间 | 检查点路径 | verify_done | 备注 |
|---|--------------|---------------------|---------|-----------|-------------|------|
| 1 | P2-S1 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/21-p2-s1.md | ☑ | 卫星骨架（试点首件）；Read 复核 SKILL.md 41 行+占位 2 行合格 |
| 2 | P2-S2 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/22-p2-s2.md | ☑ | 主 SKILL.md 556→519；卫星 references 42 行；锚点原位复核 |
| 3 | P2-S3 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/23-p2-s3.md | ☑ | 抓出 T11×3 FAIL（v080 调研链内容锚随正文迁移断链）；卫星收尾 2 项完成；540/543 |
| 4 | P2-S3b（T11 锚同步，M9 职责提前） | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/24-p2-s3b.md | ☑ | 25/0 修复；主进程独立复验 543/0；commit 475f2a5 |
| 5 | P3-S1 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/31-p3-s1.md | ☑ | git mv×2+计数 16 对齐实测+骨架 34 行 Read 复核合格 |
| 6 | P3-S2 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/32-p3-s2.md | ☑ | 主 SKILL.md 519→516；锚子串三处保全；plan-writer 零路径引用（负结果实证） |
| 7 | P3-S3 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/33-p3-s3.md | ☑ | 验证链全绿+独立复验 543/0；commit bdbd3ba |
| 8 | P4-S1 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/41-p4-s1.md | ☑ | git mv×3+骨架 37 行+迁移文件内 4 处路径文本修正 |
| 9 | P4-S2 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/42-p4-s2.md | ☑ | 九处全过+517→515+锚子串保全 |
| 10 | P4-S3（主进程接管，白名单③机械验证） | 主进程 | 2026-09-29 | （本表备注代替检查点：验证输出已贴 progress.md P4 段） | ☑ | 残留终检零命中+全量 543/0 |
| 11 | P5-S1 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/51-p5-s1.md | ☑ | git mv 92% similarity+自引用 2 处内化+骨架 40 行 |
| 12 | P5-S2 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/52-p5-s2.md | ☑ | 七文件同步+WF-09 意外修复；验证链全绿；任务书落盘式派发（Rule 35.3） |
| 13 | P5-S3（主进程接管，白名单③机械验证） | 主进程 | 2026-09-29 | （验证输出贴 progress.md P5 段） | ☑ | 独立复验 543/0+SKILL.md 513 行；P5 提交 stash 残留已 amend 修补 |
| 14 | P6-S1 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/61-p6-s1.md | ☑ | 零锚实证+513→474+reference.md +45 零语义丢失 |
| 15 | P6-S2 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/62-p6-s2.md | ☑ | 474→443；15.1-15.3/20.5 只增不改编号；TB-11 锚双处保全 |
| 16 | P6-S2b（微收拢） | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/63-p6-s2b.md | ☑ | 443→429 达标；锚点差集空；发现 S2 遗留 T6 FAIL（行号窗口） |
| 17 | P6-S2c（T6 窗口随迁） | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/64-p6-s2c.md | ☐ | selftest-knowledge-brief T6 行号窗口跟随迁移（15.1-15.3 合法增量为因） |
| 18 | P6-S3（主进程接管，白名单③） | 主进程 | 2026-09-29 | （验证输出贴 progress.md P6 段） | ☑ | 锚点 24 项全集在位+429 行+543/0；commit 738e635 |
| 21 | P8 CR Gate | code-reviewer | 2026-09-29 | plans/task-v095-skill-split/subagent-state/81-p8-cr.md | ☑ | APPROVED（0 Blocker/0 Suggestion/2 Nit）；Nit1 已修 bea7341 |
| 22 | P8 Nit1 修复 | code-assistant | 2026-09-29 | plans/task-v095-skill-split/subagent-state/82-p8-nit1.md | ☑ | 1 行去重；selftest 9/0+41/0；三部署位单文件已同步 |
| 19 | P7-S1 | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/71-p7-s1.md | ☑ | install-stub 卫星数组+守卫 pattern+41 断言 selftest+registry 35 行；全量绿 |
| 20 | P7-S1b | executor | 2026-09-29 | plans/task-v095-skill-split/subagent-state/72-p7-s1b.md | ☐ | 文档死路径收口（defer 清单：CLAUDE/README_zh/ARCHITECTURE/README 计数） |

## Key Questions

1. P1 全量 selftest 实测基线是否达到 525/0 口径？（若基线即有 FAIL，先记录并区分既有失败 vs 拆分引入）
2. v094 worktree 是否在 P7 合并前已合并回 master？（决定 P7 S3 的 merge-base 预检结果与合并顺序）
3. plan-template-kit 的卫星 references/ 引用 variant 目录时用相对路径（`../task-planner/templates/variant/`）还是绝对部署路径？（S1 派发前裁决，倾向仓内相对+部署后 install 保形）
4. check-template-type 白名单动态派生在 satellite 场景下是否需要 SKILL_ROOT 环境变量兜底？（机械层留守假设下预期不需要，S3 验证确认）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 拆分方案 = 标准 4+3（4 卫星 + 3 段内敛），机械门控与 Rule 锚全留守 | 用户裁决 2026-09-29（brief §1/§2 冻结，不得重开） |
| D 类新任务判定 | v094 原样保留（brief §6：新任务不改 v094 plan/账本，仅记录 merge-base 供 P7 预检） |
| 思路复述 | 已呈示（2026-09-29，计划确认消息内 4 行复述：Phase 序列/执行体档位/门控兜底/隔离合并交付节奏），用户显式 yes 批准；P2 试点后仍按原约定向用户呈示范式验证结论再批量复制 |
| 模板体系切法 = 知识层外迁、机械层留守 | 测绘 C3：check-template-type 白名单动态派生焊死 attest 链，机械层（templates/variant+init-session+check-template-type+attest）零改动是唯一安全切法（brief §2.1） |
| 试点先行顺序 = research-router → template-kit → cost-guard → collab-router | Rule 18.9 单件未验证禁批量；research-router 零 selftest 锚最安全（测绘 §D 候选②），范式验证后再做高耦联的 P3/P5 |
| 卫星触发模型 = 主技能显式 Skill() 指针为主，description 触发为辅 | brief §2.3.5：避免卫星 description 与 task-planner 触发竞争（类 task-drift-guard 模式） |
| 部署策略 = install.sh rsync 清单追加 4 卫星，不复制安装设施 | 测绘 C6：新技能重复整套 install 设施代价高，最小代价 = 纯内容外移 + 清单扩展 |
| 每 Phase 逐 commit（worktree 内） | brief §6 格式要求；单 Phase 可回滚，CR 审查粒度清晰 |
| P3 扩围①：critical-rules.md Rule 16 行（L61）「共 13 类」计数枚举一并修正为 16（同源漂移，含 video/video-fix/mini-lite 补全） | B 类扩围登记（2026-09-29 P3 侦察发现）：与 template-guide「13 个」同一漂移源，留着即在权威规则文件保留已知错误计数；TL-17 断言「13 个」需同步改「16 个」（S3）；范围表 critical-rules 例外+1 处 |
| P3 决策：卫星引用 variant 目录用仓内相对路径 `../task-planner/templates/variant/` | Key Question 3 裁决（2026-09-29）：skills/ 同级布局在 canonical 与三个部署位保持一致，相对路径随部署位走零硬编码 |
| P3 扩围②：critical-rules.md 路径文本更新（Rule 16 计数行外，34.2/37.1 行的 template-mapping/template-guide 路径前缀改卫星，关键词子串保全） | B 类扩围登记（2026-09-29 P3-S3 前）：迁移文件的权威源路径文本必须随迁，否则规则文件指向悬空路径；TL-03/MP-02 断言按子串 grep 不受前缀影响 |
| P4 扩围③：README.md L72 安装树清单中 billing.md 路径随迁更新（1 行） | B 类扩围登记（2026-09-29 P4 清点发现）：变更联动审计（memory P0 要求）——迁移后 README 结构描述不得留死路径；消费方清点确认 scripts/selftest 零断言，纯文档行 |
| P4 defer 裁定：仓根文档死路径 3 处（CLAUDE.md:35/README_zh.md:139/docs/ARCHITECTURE.md:50 的 billing.md）与 README L66「8 篇」计数 → P7 一次性收口 | 2026-09-29：P5/P6 迁移后 references/ 计数与结构还会变化，立即修会二次返工；P7 安装面扩展时以终态一次收口（S1 清单+1） |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 知识储备锚点：测绘报告 01-explore-structure.md（A 段落地图/B 消费关系/C 耦合风险/D 候选评估）+ skill-creator 方法论 + brief §2.3 锚点清单 = 执行期必读三件套
- 重构 = 行为不变：本任务中「行为」= selftest 全绿 + 锚点全在 + 门控链路通；任何 selftest 新增 FAIL = 立即 STOP 定位，禁止带病推进
- knowledge-brief.md（同目录）为执行期知识底座，S-unit 材料包索引与上表「输入」列互链
- 每 2-3 个 Phase 完成 → `Skill("task-drift-guard")` 漂移检查；P2 试点后向用户呈示范式结论再复制（Decisions Made 第 3 行）
- 执行体模型档位：executor(sonnet-1)；禁止为省成本将锚点 grep 复验类步骤降档 haiku（锚点误判风险高，违反 agent-model-tiering 约定）
