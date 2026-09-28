# task-v095-skill-split 计划撰写简报（供 Plan Writer 消费）

## 1. 任务背景与目标
- 用户指令（2026-09-29）：参考 skill-creator 方法论，将 task-planner 技能拆分——模板生成等非核心功能拆为独立卫星技能，降低主技能（SKILL.md 556 行）复杂度，确保执行效率与稳定性
- 用户已裁决（D1，2026-09-29）：**标准 4+3 方案** = 建 4 个卫星技能 + 3 段内敛；机械门控与 Rule 锚全留守
- 效率原理：每次触发加载的上下文=SKILL.md 正文；收益全部来自「SKILL.md 段落外迁至卫星（按需加载）」；目标主 SKILL.md 556→≤430 行（≥20% 缩减）
- 必读输入（写计划前先 Read）：
  1. `/mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/subagent-state/01-explore-structure.md`（结构测绘：A 段落地图/B 消费关系/C 耦合风险/D 候选评估）
  2. `/mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/findings.md`（需求+硬约束+调研摘要）
  3. `/mnt/data/dev/task-planner-skill/plans/task-v095-skill-split/task_plan.md`（refactor variant 模板已就位，往里填）

## 2. 拆分设计（已裁决，冻结）
### 2.1 四个卫星技能（仓库内新目录 skills/<name>/，随 install.sh 部署三实体位）
| 卫星 | 承接内容（源→目标） | 关键锚点处置 |
|------|--------------------|--------------|
| plan-research-router | SKILL.md §调研类操作 L466-506 → 卫星 references/；主技能原地改 1 行 Skill() 指针 | 零 selftest 锚，最安全，作为 18.9 试点先行 |
| plan-template-kit | ①template-guide.md+template-mapping.md 迁卫星 references/（template-guide「13 个」计数顺手修为 16 与 variant 实际一致）②SKILL.md §任务模板库 L542-556 改指针 ③plan-writer.md(companion) L22/39/50-64 引用同步 ④机械层留守：templates/ variant 库+init-session.sh+check-template-type.sh+attest 门控不动 | selftest-template-lifecycle/selftest-mechanism-profile 路径锚同步改；若门控断裂→回滚 mapping 留守改跨技能指针（FMEA 兜底） |
| plan-cost-guard | billing.md+cost-control.md+templates/cost_log.md（无脚本消费）迁卫星；SKILL.md L294/L345 指针化；互引（batch-quality-gate→cost-control、critical-rules Rule 17 段路径）同步 | Rule 17 摘要行留守 SKILL.md（selftest 锚） |
| plan-collab-router | skill-collaboration.md 迁卫星；SKILL.md L46-54 协同路由段改指针；selftest-skill-collab 随迁并更新路径；selftest-shared-tracker/selftest-fallback 引用同步；subagent-fallback.sh:288 hint 文本同步；critical-rules 22.3.3 指针保留确认 | registry.tsv（selftest-registry.tsv）同步更新 |
### 2.2 三段内敛（不建卫星，主 SKILL.md 段落并入既有权威文档）
- Chain 模式详解 L243-284 → reference.md（Chain Handoff Contract 权威源已在该文件）
- 高频漂移纠正 L509-538 → references/critical-rules.md Rule 15 扩充（只增子条不改编号）
- Read vs Write 矩阵 L122-130 → references/critical-rules.md Rule 20.5
### 2.3 全局硬约束（写进计划 VC/FMEA）
1. Rule 1-39 编号冻结；Rule 17/18/30-39 摘要行+C19/C25/C26 检查项行+`Rules 1-3` 计数锚留守主 SKILL.md
2. 机械门控（check-complete/attest-plan/check-delegation/check-dispatch 等 16 门控脚本）与 hook 接线（~/.zcode/cli/config.json）零改动（check-skill-modify.sh:29 保护 pattern 追加卫星路径除外）
3. 零新 config.json 键（卫星为纯 SOP/文档技能，不读 config）
4. 卫星 SKILL.md 遵循 skill-creator 规范：frontmatter name=目录名、description 含触发词（pushy 风格）、正文薄（<500 行）、细节放 references/
5. 触发模型：主技能保留显式 Skill() 指针行（主路由，类 task-drift-guard 模式）；卫星 description 触发为辅，避免与 task-planner 触发竞争
6. 并行任务约束：v094-tier-b-rollout worktree（wt/task-v094-tier-b-rollout）属并行会话，全程禁碰；合并顺序冲突时 STOP 报告用户
7. 部署面：install.sh rsync 清单追加 4 卫星；三部署位（~/.zcode、~/.claude、~/.config/opencode）部署后 diff -r 复验；新 selftest（selftest-skill-split.sh）登记 selftest-registry.tsv

## 3. Phase 骨架（8 Phase，S-unit 由你按 22.6 细化：每 S-unit ≤2 文件/≤100 行/≤15min）
- P1 基线冻结与隔离区建立（Executor: 主进程，白名单①②③）：全量 selftest 基线记录（期望 525/0 口径以实测为准）→ 迁移映射表逐文件落 findings.md → git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-v095-skill-split -b wt/task-v095-skill-split master
- P2 试点卫星 plan-research-router（Executor: executor，sonnet-1）：18.9 试点先行——建卫星+主技能段落外迁+指针替换+frontmatter references 清单同步，端到端验证拆分范式
- P3 卫星 plan-template-kit（Executor: executor）：按 2.1 表执行；含 template-guide 计数修复与 selftest 路径锚同步
- P4 卫星 plan-cost-guard（Executor: executor）
- P5 卫星 plan-collab-router（Executor: executor）：含 selftest 迁移与 registry.tsv 更新
- P6 主技能收尾内敛（Executor: executor）：2.2 三段内敛+锚点清单逐条 grep 复验（Rule 摘要行/C 检查项/行数上界）
- P7 安装面扩展与全量验证（Executor: executor 脚本修改 + 主进程白名单①③部署）：install.sh/check-skill-modify.sh/selftest-skill-split.sh/registry.tsv + 全量 selftest 0 FAIL + worktree 内验证后合并回 master（smart-merge-back）+ 三部署位部署与 diff -r 复验
- P8 CR Gate 与终验簿记（Executor: 主进程+code-reviewer）：code_review: required → APPROVED 后终验交付+merge 确认+INDEX/ledger 簿记

## 4. VC 草案（Verification Contract，可润色不可减）
- V1 主技能 SKILL.md ≤430 行且 Rule 17/18/30-39 摘要行+C19/C25/C26+Rules 1-3 计数锚全在（grep 证据）
- V2 全量 selftest 0 FAIL 且用例总数 ≥ Phase 1 基线实测值
- V3 四卫星目录存在于 skills/ 且 frontmatter 合规（name=目录名+description 含触发词）+ 迁移映射表 100% tick（零内容丢失）
- V4 install.sh 扩展后三部署位 diff -r 与 canonical 一致（4 卫星同步在位）
- V5 check-skill-modify.sh 保护 pattern 覆盖卫星路径（行为级：写卫星文件触发守卫）
- V6 CR APPROVED（code_review: required）

## 5. FMEA 候选（≥3 项，按 7 列表落计划）
- selftest 锚断裂（Rule 摘要行/C 项误删）→ P6 锚点清单逐条 grep+全量 selftest 兜底
- template-mapping 迁移致 attest/check-complete 门控断链 → 回滚留守+跨技能指针降级
- v094 并行合并冲突 → 合并前 git log/merge-base 核对+smart-merge-back 预检+冲突即 STOP
- 三部署位漏同步/半同步 → diff -r 三位逐位复验（部署 SOP 固化在 P7）
- 卫星 description 与主技能触发竞争 → 主路由显式 Skill() 指针为主+description 收窄措辞

## 6. 格式与契约要求
- template_type: refactor（frontmatter 已由 init 写入）；plan_tier: standard；interaction_mode: ask；code_review: required；git_commit: 逐 Phase 提交（worktree 内）
- 隔离决策：worktree（路径见 P1），计划文档留主仓 plans/；「🔀 隔离决策」区块写明 v094 并行约束
- Decisions Made 表须含：D1 拆分方案=标准 4+3（用户裁决 2026-09-29）、D 类新任务判定（v094 原样保留）、思路复述待呈示行
- 派发型 Phase（P2-P7）每行配 S-unit 表（22.6 列：S-unit ID 纯数字如 S1/S2、目标文件、≤2 文件/≤100 行/≤15min、执行体、检查点路径 <plan-dir>/subagent-state/）
- 知识储备章节：登记测绘报告+skill-creator 方法论+锚点清单为必读源
- 完成后同步产出 knowledge-brief.md（五段：速览/已验证事实/文件锚点/易错点/S-unit 材料包索引），材料包索引指向 01-explore 报告锚点

## 7. 返回契约（8 字段严格格式）
status / 产出文件（task_plan.md+knowledge-brief.md 绝对路径+行数）/ 关键结论（Phase/S-unit/VC 计数）/ 证据 / 未完成项 / 失败与原因 / 下一步建议 / 风险提示
