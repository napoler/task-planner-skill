# Findings & Decisions

## Requirements

- 用户原话（2026-09-06）：「该技能的核心定位就是主进程的，主进程的一个核心任务调度管理器。……我希望可以有效的降低……主进程的核心目标就是调度管理，而不是要将所有任务都由主进程去执行，/skill-fix 可以调用该技能做技能审查以及优化。」
- 拆解：① 定位声明=主进程纯调度管理器 ② 有效降低主进程亲自执行 ③ 通过 skill-fix 审查+优化 task-planner 技能落地

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）

| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| SKILL.md 全文 | skills/task-planner/SKILL.md（607 行） | ☑ | Research Findings#诊断报告 |
| critical-rules.md 全文 | skills/task-planner/references/critical-rules.md（209 行） | ☑ | Research Findings#诊断报告 |
| templates/task_plan.md+verification.md+config.json | skills/task-planner/ | ☑ | Technical Decisions |
| skill-fix 标准（S47-62/S64/S74）+ 宪法 | 会话加载 | ☑ | Technical Decisions |
| memory deploy-flow / known-defects | 记忆目录 | ☑ | deferred-issues.log |

## Research Findings

### skill-fix 诊断报告（Phase 2 收口,2026-09-06）

**审计工具结果**：
- `subagent_skill_auditor.ts`：40 文件扫描,0 问题（S39/39a 干净）
- `path_existence_validator.ts`：verdict FAIL_P0(3)——**误报**。MISSING 三项 `references/{todo-sync,worktree-isolation,critical-rules}.md` 实际存在（ls 证据:31843B/4813B/5056B）,根因=验证器将相对引用按 cwd/项目根而非 skill 根解析。不修工具（范围外→deferred D4）
- S61 cross_caller_aligner（critical-rules.md）：引用方=cost_log/completion-gate/cost-control/batch-quality-gate/README,均为文件级引用,本次改条款措辞不改编号 → 不受影响
- S62：`<50%` 共 5 处（SKILL.md:184、critical-rules.md:166/179、templates/task_plan.md:315+322、templates/verification.md:78）;Rule 25 无跨技能引用

**委派定位漏洞清单（修复依据）**：

| # | 级别 | 位置 | 问题 |
|---|------|------|------|
| F1 | P1 | SKILL.md L33 | 「专业代码编辑最佳实践（**鼓励使用，非强制**）」与 L350/L434 P0 强制条款自相矛盾,头部定位被弱化 |
| F2 | P0 | SKILL.md L25 Goal 区 | Goal 只讲产出物,无「主进程=调度管理器」身份定位;定位埋在 L350 节内 |
| F3 | P0 | SKILL.md L55/L377-378/L451-453 + critical-rules.md L53(Rule 14) | 主进程 Edit 例外面=「.md/.json/.yaml」全类+AGENTS.md——文档型仓库(如本仓)等于全部放行,委派定位被架空 |
| F4 | P1 | SKILL.md L184 + critical-rules.md L166(25.4)/L179(Q5) | 委派率阈值 50% 过低+硬编码;「无登记理由」逃生舱无白名单约束,v051 实测 0% 委派仍 COMPLETE |
| F5 | P1 | templates/task_plan.md L169/L202/L315/L322 + verification.md L78 | 模板 canned 例外理由与 50% 旧阈值;未对齐白名单枚举 |
| F6 | P1 | SKILL.md L415 兜底表#3 | 主进程接管(22.3③)后未绑定 Rule 25.3 例外登记 |
| F7 | （误报） | path validator 3 P0 | 解析基准误报,已取证 |

**规则现状（已强部分,收口不重建）**：Rule 25.1 Executor 字段强制+2.5 委派检查点+Rule 22 八字段 prompt+Handoff 表+26 Q5 惩罚映射均已存在;config.json 是阈值真源（`additionalProperties:false`,加键需同步 schema）。

## Technical Decisions

### Phase 4 回归记录（2026-09-06）

code-runner-agent（Handoff#1）worktree 内 smoke:exit 0,17 pass/0 fail;检查点 status: done 已 Read 复核。VC-5a ✅。

### 终验与交付记录（2026-09-06）

merge **89a29ae** 落 master;check-complete 5/5 exit 0;attest 终态 **21c94a34**（会话重启重锁）;记忆基线已更新（部署位漂移待授权）。交付结论 COMPLETE,部署建议与遗留见 verification.md。

### Phase 3 实施记录（2026-09-06）

worktree 5 文件 +34/−20（diff --stat 证据）;attest=cfd49f0a;VC-1~4 grep 断言全过（证据 progress.md Phase 3 Test Results 表）。编辑终稿与设计一致,无范围外文件。

- 阈值外置 `config.json#delegation_rate_floor`（number,0.7,0~1）——S9/S10;SKILL/critical-rules/templates 全部引用该键
- Rule 25.3 例外理由白名单六项：① 纯 git/worktree 编排 ② 计划系统文件维护（三件套/INDEX/ledger/attest/plan 模板）③ 机械验证命令（只读,输出可控）④ 用户显式要求主进程亲为 ⑤ Rule 22.3 兜底接管 ⑥ 单文件 ≤3 行 trivial（非保护区）——白名单外理由视为未登记,按 25.4/Q5 处置
- 主进程 Edit 白名单（F3 收窄）：① 计划系统文件（plans/** 三件套+notepad+verification+INDEX+ledger、`.claude/plan-templates/`）② 原生 Todo 同步 ③ ≤3 行 trivial;AGENTS.md/业务文档/配置/技能文件 → 默认派子代理

## Issues Encountered

（无错误;path validator 误报见 Research Findings,工具缺陷不在本任务范围→deferred D4）

## Resources

- 修复目标文件（worktree）: `/mnt/data/dev/task-planner-skill-worktrees/task-v052-scheduler-positioning/skills/task-planner/{SKILL.md,references/critical-rules.md,config.json,templates/task_plan.md,templates/verification.md}`
- skill-fix 工具: `~/.zcode/skills/skill-fix/tools/{path_existence_validator,subagent_skill_auditor,cross_caller_aligner}.ts`（bun 1.4.0 已验证）
