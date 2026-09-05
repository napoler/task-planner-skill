# Task Plan: Rule 27 工作产物及时提交（git 管理强制）— skill 行为增强

## Goal

为 task-planner skill 增加 Phase 级 git 提交强制门控（Rule 27）：实现类 Phase 的产物在翻转 complete 前必须 commit 到当前工作分支，终验与恢复场景联动核验，从机制上杜绝"任务做完了、修改没提交、会话中断即丢失"。

> 授权来源：用户指令"优化当前 skill 确保执行代码开发等任务完成后及时提交到 git 管理 避免修改被丢弃"（2026-09-05，本轮显式授权）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 .md 规则文档增强，无业务代码变更） |
| `session_id` | git-timely-commit-20260905 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-git-timely-commit` |
| `scope_files` | `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/references/worktree-isolation.md` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | SKILL.md Phase 执行循环含步骤 4.5「提交工作产物（Rule 27）」，位于步骤 4（回写计划）与步骤 5（同步 Todo）之间；含禁盲扫/非 git 跳过/豁免三要素 | grep 验证 | `grep -n "4.5 \*\*提交工作产物" skills/task-planner/SKILL.md` |
| VC-2 | critical-rules.md 存在 Rule 27 全文（27.1 时机 / 27.2 范围 / 27.3 校验 / 27.4 豁免 / 27.5 终验联动 / 27.6 恢复补提交）；SKILL.md Critical Rules 注册表含 Rule 27 行；References 表 critical-rules 行更新为 1-27；frontmatter 描述行同步 | grep 验证 | `grep -n "### 27 工作产物及时提交" references/critical-rules.md`；`grep -c "Rule 27" SKILL.md` ≥3 |
| VC-3 | SKILL.md 合规检查清单含 C17（git 提交核验）；终验交付含「git 提交核验」项 | grep 验证 | `grep -n "C17\|git 提交核验" skills/task-planner/SKILL.md` |
| VC-4 | worktree-isolation.md 生命周期 ③ 细化为"每 Phase 完成即提交（Rule 27）+ 禁用 add -A 盲扫" | grep 验证 | `grep -n "Rule 27" references/worktree-isolation.md` |
| VC-5 | 回归通过（tests/smoke.sh 全过）；master 收到 --no-ff 合并；worktree 与 wt/ 分支已清理；主仓任务范围无未提交变更 | 命令验证 | smoke 输出；`git log --merges -1`；`git worktree list`；`git status --short skills/` |

**终验规则**：全部 VC 通过 → COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| skill 规则文档 | `skills/task-planner/SKILL.md`、`references/critical-rules.md`、`references/worktree-isolation.md` | 其他任何文件（templates/、scripts/、config.json 等） |
| 脚本层 | 无（本轮不改任何 .sh/.ts/.cjs——git 校验以规则钩子落地，脚本化硬门控列为遗留建议） | 修改 check-3file-gate.sh / check-complete.sh |

**执行前自我检查**:3 个文件均在列表内；修改直接服务 Rule 27 落地；用户已显式授权。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | SKILL.md 全文（执行循环/注册表/检查单/终验插入点） | skills/task-planner/SKILL.md @ master 5228d06 | 必读 | ☑ 本会话已通读（去重任务中） |
| 项目内部文档/知识库 | references/critical-rules.md 全文（Rule 编号体系与措辞风格） | references/critical-rules.md @ 5228d06 | 必读 | ☑ 本会话已通读 |
| 项目内部文档/知识库 | references/worktree-isolation.md 全文（§4 生命周期提交点） | references/worktree-isolation.md | 必读 | ☑ 本会话已通读 |
| 项目内部文档/知识库 | scripts/check-3file-gate.sh / check-complete.sh（确认现有门控无 git 检查,定脚本零改动策略） | scripts/ 两文件 @ 5228d06 | 必读 | ☑ 本会话已通读 |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**：skill 全流程（Phase 执行循环→终验→worktree 合并回）没有任何 git 提交强制点——3-File Gate 管回填、check-complete 管终验、合并回合约只在合并前查一次干净；产物未提交状态下翻转 complete 被完全放行，会话中断/误操作/worktree 清理即可抹掉工作。解决后能交付吗？——能：Rule 27 把提交前移到每 Phase 翻转点，丢弃上限收敛为一个 Phase 增量。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？（防丢失是执行安全的地基）
- [x] 解决方法清晰可执行？（规则钩子三层：执行循环 4.5 / C17 / 终验联动）

## Current Phase

已交付（无活跃 Phase — outcome: **COMPLETE**,2026-09-05）

## Next Step

无后续动作。遗留决策项：① 9 实体部署副本仍为 ad7900d（落后 master 两个 merge）,是否重部署由用户决定;② 27.3 脚本化硬门控（check-complete.sh 增范围化 porcelain 检查）列为可选后续。

## Phases

### Phase 1: 计划初始化与隔离区建立
- [x] init-session 5 文件 + 冲突预判（基线 5228d06,worktree list 干净）
- [x] 填充 task_plan.md + attest 锁定 + plan-created.cjs 清哨兵
- [x] worktree 建立（集中目录规范路径）+ S1 Todo 映射
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排与计划文档操作属主进程白名单）

### Phase 2: Rule 27 规则层编辑（worktree 内）
- [x] E1 SKILL.md ×5：执行循环插步骤 4.5；Critical Rules 注册表加 Rule 27 行；合规清单加 C17；终验交付加 git 提交核验项；References 表 critical-rules 行 1-26→1-27 + frontmatter 描述行修正
- [x] E2 critical-rules.md：文件尾新增 Rule 27 全文（27.1-27.6）
- [x] E3 worktree-isolation.md：§4 ③ 细化为"每 Phase 完成即提交（Rule 27）+ 禁用 add -A 盲扫"
- **Status:** complete
- **Executor:** 主进程（例外理由:全部为 .md 规则文档编辑（白名单明示"*.md(计划/文档)"）;3 文件变更 <80 行）

### Phase 3: 验证、合并回与终验
- [x] worktree 内 grep 复验 VC-1~VC-4 + tests/smoke.sh 回归
- [x] 3-File Gate + commit + 主仓 merge --no-ff + Read 复验（VC-5）
- [x] worktree remove + branch -d + INDEX 刷新 + 终验交付
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排与终验属主进程白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（master 5228d06 即本会话去重任务刚合并的基线;skills/ 无未提交变更;worktree list 仅主仓;未跟踪文件仅计划类,零重叠） |
| `isolation` | `worktree`（实现类任务默认首选,用户未否决） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-git-timely-commit` |
| `branch` | `wt/task-git-timely-commit` |
| `merge_back` | `merged(9b167fe)` |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-05 | S1 映射于 worktree 创建时建立 |
| Phase 2 | ☑ | 2026-09-05 | 同上 |
| Phase 3 | ☑ | 2026-09-05 | 同上 |

## Key Questions

1. 为什么不改 check-3file-gate.sh 把 git 检查做成脚本硬门控？→ 3-File Gate 职责单一（回填存在性）,塞入 git 检查违反"检测点不重复"原则（Rule 26.5 风格）,且改运行中脚本回归风险大;本轮以规则钩子三层落地（4.5 步骤/C17/终验项）,脚本化硬门控列为遗留建议等用户决策。
2. plans/ 要不要一起提交？→ 不要。仓现状 plans/ 长期 untracked（会话级状态）,Rule 27.2 明确禁盲扫防卷入。

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 新规则编号 = Rule 27 | critical-rules.md 现有 1-26 顺延;P0 级（丢失工作=不可逆损失） |
| 提交点 = 执行循环步骤 4.5（回写计划后、翻转 complete 前） | 沿用 2.5 插入先例,最小扰动编号;"翻转 complete 前提"与 3-File Gate 同位,门控语义一致 |
| 丢弃上限收敛目标 = 单 Phase 增量 | 逐 Phase 提交使用户中断/误操作的最坏损失从"整个任务"降为"一个 Phase",这正是"及时"的含义 |
| 禁 `git add -A` 盲扫 | 仓内 plans/ untracked、存在并行 worktree,盲扫会把会话状态与他人产物卷入提交 |
| 非 git 目录跳过而非阻塞 | 提交能力缺失时如实登记,不制造假阻塞;豁免双通道（计划声明 deferred / 用户显式） |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| （暂无） | — | — |

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-05 | 每 Phase 翻转前 3-File Gate 硬校验 ×2（exit 0）+ smoke 17/17 + 全程范围自检（仅触碰 scope 3 文件）+ Rule 27 dogfood（e99c34b 逐 Phase 提交+porcelain 自检） | 全部 | ALIGNED（未单独跑 Skill("task-drift-guard"),以 3-File Gate+VC 复验+范围自检替代,如实记录） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 3 |
| 主进程直做 Phase 清单 | P1 git 编排+计划白名单;P2 .md 规则文档白名单;P3 git 编排+终验白名单（理由见各 Executor 字段） |
| 委派率 | 0%（全部带登记例外理由;纯 .md 规则增强无可委派代码单元） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

本任务无子代理派发（全部 Phase 主进程直做,例外理由已登记）。

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|-------------|
| — | — | — | 无派发 | — | — | — | — | — |
