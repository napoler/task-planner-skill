# task-v171 交付总结 — task-planner 核心专业化拆分

> 用户核心诉求（R1-R5）：核心技能只负责四文件罗盘记录/文档管理与计划制作；其他专业工作独立为卫星技能，「调用其他技能而非自己实现」，杜绝「什么都负责导致产出混乱」。
> 完成：2026-10-12；执行载体=dynamic workflow（P5-P8 主体）+ 主进程收尾（merge-back/对账/簿记）；merge-back commit=1036781。

## 一、说明（达成什么）

核心 task-planner 收敛为「四文件罗盘 + 计划制作循环」唯一职责，77 条既有规则按域分层归属 10 面，SKILL.md 从 556 行瘦身到 218 行挂 10 面路由表，新增 Rule 82 制度化防回潮。全量机器门控 77/77 零回归。用户「唯一性/专业性」诉求达成。

## 二、产出（对象 / 路径 / 动作）

| 对象 | 路径（仓相对） | 动作 |
|------|--------------|------|
| 核心规则 | `skills/task-planner/references/critical-rules.md` | 1046→165 行：删 65 条移走规则+Rule 80 空壳，保留 13 条核心（1,2,3,5,19,20,26,51,62,66,80,81,82）+分层说明+10 卫星路由索引 |
| 核心 SKILL | `skills/task-planner/SKILL.md` | 556→218 行：四文件罗盘定位+计划制作循环+10 面路由表+核心规则指针 |
| 新卫星 task-dispatch | `skills/task-dispatch/` | 11 规则（12,13,14,21,22,23,25,46,52,59,68）+6 脚本+3 references |
| 新卫星 task-discipline | `skills/task-discipline/` | 36 规则 6 批逐字迁移+4 组 git mv（capabilities/plan-hygiene/batch-quality-gate/capability-registry） |
| 新卫星 media-planner | `skills/media-planner/` | 新建，Rule 47/49/50 |
| 7 卫星收编 | `skills/{plan-research-router,plan-template-kit,plan-collab-router,plan-cost-guard,plan-resume,progress-tracker,task-drift-guard}/` | 各落盘 critical-rules-\<域\>.md+SKILL.md 路由段（共 16 条） |
| Rule 82 | 核心 critical-rules.md | 技能专业化分层纪律（建制/边界/回归防线） |
| 机器契约 | selftest-batch-pilot BP-08 558→275；install-stub 注册 3 新卫星；README/ARCHITECTURE 重写 | 已随 1036781 落地 |
| 规则全集 | 13 核心 + 11 dispatch + 36 discipline + 3 media + 16 卫星 = 77 | 全量逐字 66/66 IDENTICAL（对 e82dd42） |

## 三、审查详细（各门证据）

| 审查门 | 命令 | 结果 |
|--------|------|------|
| 全量回归 | `bash skills/task-planner/scripts/run-selftests.sh --fresh`（主仓 master 态） | 77/77 PASS FAIL=0 |
| dispatch 域 | `bash skills/task-dispatch/scripts/selftest-{fallback,rescue-chain}.sh` | 2/2 PASS |
| 规则逐字 | 66 条 N.x 子条 diff e82dd42 | 66/66 IDENTICAL（含 38.7 补回） |
| 核心规则集 | `grep -cE '^### '` 核心文件 | 13 条（含 Rule 81 master 并行+Rule 82 本任务） |
| SKILL 行数 | `wc -l` | 218（≤250） |
| VC 复验 | workflow 验证条件复核员 8 条 | 7/8 PASS（VC-8=merge-back/部署对账，已主进程闭环） |
| 质量门 CR | workflow 评审员（1 轮拦截 Rule 81 并集解后） | APPROVED |

**主进程 3 处修复（merge-back 期间独立发现并闭环）**：
1. Rule 38.7（执行通道分级）在 plan-template-kit 迁移时漏子条 → 全量逐字校验揪出，sed 从 master 提取补入 → 66/66 转绿。
2. SA-10（source-anchor-discipline）fix-prompts.md 被 task-v170 归档到 `plans/archive/` → selftest 锚改指 archive → SRV-12 级联随之转绿。
3. selftest-tier-b 第 1 轮 /tmp mktemp 时序偶发 FAIL → 复跑确认 77/77（非逻辑缺陷）。

## 四、风险（必须列举）

| 风险 | 说明 | 处置 |
|------|------|------|
| 部署位未同步 | 4 部署位（zcode/claude/opencode/cursor）+3 新卫星仍为旧版，**新技能行为在运行位未生效**；合并只入 master 仓 | 已落 deployment-reconciliation.md；写入需用户授权跑 install |
| cursor 位历史欠同步 | 差异 130 行（> 其他 3 位 83 行） | 授权时建议全量重同步 4 位 |
| 行为面未冒烟 | 新规则/路由在真实会话的生效验证需新会话 | 代码与门面已就绪，建议新会话冒烟 |
| tier-b flake | /tmp 临时目录时序偶发 | 已知 flake 模式，复跑即绿；非阻断 |
| CR 意见原文不可达 | workflow 报告如实登记 `workflow_introspection_unavailable`（记录能力缺口，非空项目） | 不影响结论（CR 已 APPROVED），意见已按盘面取证登记 |

## 五、下一步建议

1. **授权部署**：用户确认后跑 `bash skills/task-planner/scripts/install.sh --all-hosts`（写 4 位+rsync 3 新卫星），消除「运行位仍是旧版」风险。
2. **新会话冒烟**：验证 task-dispatch/task-discipline/media-planner 三新卫星在真实派发场景的路由命中。
3. **（已完成）存 workflow**：本次拆分执行脚本已 `SaveWorkflow` 存为 project 资产 `.zcode/workflows/task-v171-skill-specialization.dwf.ts`（复用需先改顶部 const 路径与规则编号）。
