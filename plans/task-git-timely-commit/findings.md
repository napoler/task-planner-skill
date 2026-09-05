# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
-->

## Requirements
- 用户指令（2026-09-05 原话）："优化当前skill 确保执行代码开发等任务完成后及时提交到git管理 避免修改被丢弃"。
- 影响判定：B 类新需求 → 新计划 task-git-timely-commit（旧去重计划已终态 COMPLETE 且已 attest 锁定,不复用、不回改,保持历史完整）。
- 授权：本轮显式授权,代替 yes 门控。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| SKILL.md 全文（执行循环/注册表/C 检查单/终验/References） | skills/task-planner/SKILL.md @ master 5228d06 | ☑ | §1/§2 |
| references/critical-rules.md 全文 | references/critical-rules.md @ 5228d06 | ☑ | §2 |
| references/worktree-isolation.md 全文 | references/worktree-isolation.md @ 5228d06 | ☑ | §2 |
| scripts/check-3file-gate.sh + check-complete.sh 全文 | scripts/ @ 5228d06 | ☑ | §1 |
| references/completion-gate.md 全文 | references/completion-gate.md @ 5228d06 | ☑ | §1 |

## Research Findings

### §1 现状诊断：修改为什么会丢（逐文件证据）
- **全流程没有任何 git 提交强制点**：
  - SKILL.md Phase 执行循环（109-127 行）：6 步（开启→Todo→委派检查→执行落盘→回写→Todo→DRIFT）无任何 commit 动作；
  - `check-3file-gate.sh`（全文 137 行）：只校验 findings/progress 回填存在性（ledger/mtime 信号），无 git 检查；
  - `check-complete.sh`（全文 265 行）：校验 Phase 状态/Batch Report/Aggregator/3-File stub，无 git 检查；
  - `references/worktree-isolation.md` §4：仅合并回合约 #2 在合并前查一次"worktree 内 status 干净"——**事后一次性检查**；direct（非隔离）场景完全无提交约束；
  - `references/completion-gate.md`：管"子代理 done ≠ 完成"，同样无提交语义。
- **三条丢失路径**：① 会话中断 → 未提交修改留在工作区，恢复会话靠记忆辨认（易错漏）；② 误操作（`git clean -fd` / `git checkout -- .` / `git reset --hard`）直接抹除未提交工作；③ worktree 场景若在提交前执行 `git worktree remove`，整个隔离区工作归零。
- **结论**：缺的不是"能提交"（worktree 合约隐含要求），而是"及时提交"的强制时点——现状允许整个任务做完仍零提交。

### §2 设计决策（Rule 27 形态）
- **Rule 27（P0）工作产物及时提交**，六条细则：27.1 时机（实现类 Phase 翻转 complete 前必提交；worktree 场景逐 Phase 提交到 worktree 分支，direct 场景提交主仓当前分支；禁攒批）；27.2 范围（只 add scope 产物，**禁 `git add -A`/`git add .` 盲扫**，plans/ 按仓约定不入库；message 格式 `<type>(<scope>): task-<id>/Phase N — <摘要>`）；27.3 校验（提交后 `git status --porcelain -- <scope>` 必须为空；非 git 目录记行跳过不阻塞）；27.4 豁免（计划声明 `git_commit: deferred` 或用户显式"先不提交"，登记 verification.md；无登记未提交翻转 = 违规按 Rule 26.3 回炉）；27.5 终验联动（交付前 scope 无未提交变更，遗留→补提交注明"终验补提交"）；27.6 恢复补提交（session-catchup/plan-resume/5Q 恢复时发现 scope 未提交变更→先补提交注明"跨会话补提交"再继续）。
- **三层规则钩子（零脚本改动）**：执行循环插步骤 4.5（提交动作本体）+ 合规清单 C17（每 Phase 自查）+ 终验「git 提交核验」项（兜底）。
- **丢弃上限收敛目标 = 单 Phase 增量**：逐 Phase 提交使用户中断/误操作的最坏损失从"整个任务"降为"一个 Phase"。
- **worktree-isolation.md §4 ③ 细化**：每 Phase 完成即提交（Rule 27 联动），禁 `add -A`——合并回合约 #2 的"干净"由逐 Phase 提交自然满足。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 不改 check-3file-gate.sh / check-complete.sh | 3-File Gate 职责单一（回填存在性），塞入 git 检查违反"检测点不重复"原则（Rule 26.5 风格）；改运行中脚本回归风险大；脚本化硬门控列为遗留建议待用户决策 |
| 提交点 = 执行循环步骤 4.5 | 沿用步骤 2.5 插入先例，编号零扰动；与 3-File Gate 同位（翻转 complete 前提），门控语义一致 |
| git 校验命令 = `git status --porcelain -- <scope>` | 范围化判定，不受 plans/ untracked 等无关文件干扰 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| Bash cwd 跨调用持久漂移，attest/ledger 相对路径失败（**本会话第 2 次同类失败**，Rule 7 信号） | 本会话剩余脚本调用全部用绝对路径；根因=dedup 任务时 `cd plans/...` 后 cwd 残留，已如实记 Error Log |

## Resources
- skills/task-planner/SKILL.md:109-127（执行循环）、288-305（注册表）、193-213（C 检查单）、180-191（终验）
- skills/task-planner/references/critical-rules.md:193（文件尾,Rule 27 插入点）、129（既有缺陷:重复的 21.5 段,报告不修）
- skills/task-planner/references/worktree-isolation.md:47-64（§4 生命周期）
- skills/task-planner/scripts/check-3file-gate.sh / check-complete.sh（门控现状依据）

## Visual/Browser Findings
- （本任务无多模态输入）

## §3 Phase 2 执行结果（2026-09-05）
- 8 处编辑全部落地：SKILL.md 6 处（:9 frontmatter 描述、:120 执行循环 4.5、:189 终验 git 提交核验、:216 C17、:306 注册表 Rule 27 行、:335 References 表 1-27）+ critical-rules.md:194 Rule 27 全文 + worktree-isolation.md:54 §4③ 逐 Phase 提交。
- **Rule 27 dogfood 验证**：本任务 Phase 2 产物按 27.1/27.2 立即提交（e99c34b，范围化 add 三文件，message 用新格式），27.3 porcelain 自检为空——新门控在作者自己的任务里闭环可用。
- smoke 回归 17 pass / 0 fail（含 check-complete.sh、verify_installation 项）。
- 现有门控关系厘清（写入 Rule 27 正文）：19.2 管回填存在性、worktree 合约 #2 管合并前一次性干净、27 管逐 Phase 及时入库——检测点互不重复（Rule 26.5 风格）。

## §4 合并回证据（Phase 3,2026-09-05）
- master merge commit **9b167fe**（--no-ff,3 files +21/−4）,前序 commit e99c34b（Rule 27 合规 message）。
- 主仓复验：Read SKILL.md:120 确认 4.5 步骤落位；Rule 27 提及 ×5；critical-rules.md 27 全文在位。
- 清理：worktree 已 remove、`wt/task-git-timely-commit` 分支已删（was e99c34b）,worktree list 仅主仓。
- **Rule 27.5 自证**：主仓 skills/ porcelain 为空——本任务全部产物已入库,零未提交遗留。
- **部署提醒**：9 实体部署副本仍为 ad7900d 基线（现落后 master 两个 merge:去重 5228d06 + 本任务 9b167fe）,需用户决策后显式重部署（cp -rL + diff -r 复验）。
- 遗留建议：若需把 27.3 校验做成脚本硬门控,可后续任务在 check-complete.sh 增加范围化 porcelain 检查（本轮按职责单一原则未动脚本）。
