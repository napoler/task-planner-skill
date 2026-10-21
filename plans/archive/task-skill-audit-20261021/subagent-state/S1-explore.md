# S1-explore — task-planner-skill 仓「技能全树 + 守卫脚本 + 规则载体」结构盘点清单

- **角色**：S1 explore（只读盘点，未做任何质量评判）
- **产出时间**：2026-10-22
- **仓根**：`/mnt/data/dev/task-planner-skill`
- **约束遵守**：全程只读（find/ls/grep/wc/sed -n/awk 打印），唯一写入 = 本文件；无 git 写操作；未触碰任何其他仓/worktree
- **复现命令基线**：`cd /mnt/data/dev/task-planner-skill && find skills -type f -not -path '*/.backup/*' | wc -l` → 299

---

## 0. 全局量级（先读这个，所有结论的基数）

| 指标 | 值 | 复现命令 |
|------|----|---------|
| skills/ 下活文件总数（排除 `.backup`） | 299 | `find skills -type f -not -path '*/.backup/*' \| wc -l` |
| skills/ 下活代码+文档总行数 | ≈ 52 596 | `find skills -type f -not -path '*/.backup/*' -exec cat {} + \| wc -l` |
| 技能目录数 | 15（1 核心 + 14 卫星/顶层） | `ls -1 skills/` |
| `skills/task-planner/.backup/` 文件数 | 1 556 | `find skills/task-planner/.backup -type f \| wc -l` |
| `.backup/` 体积 | 23 MB / 284 054 行 | `du -sh skills/task-planner/.backup` |
| `.backup/` 是否入 git | 0（被 `skills/task-planner/.gitignore` 的 `.backup/` 排除） | `git ls-files skills/task-planner/.backup \| wc -l` |

**关键比例**：`.backup/`（活树 1 556 文件 / 284 054 行）体积是活技能树（299 文件 / 52 596 行）的 **5.2 倍行数、6.4 倍文件数**，物理落在技能目录内部。

---

## 1. 目录/文件清单（行数 + 字节数）

### 1.1 技能级汇总

| 技能目录 | 活文件数 | 总行数 | 总字节 | 构成 |
|----------|---------|-------|-------|------|
| `skills/task-planner/`（核心） | 236 | 44 282 | 2 284 383 | SKILL.md + references/ + scripts/(146) + templates/(42) + companion/ + review-library/(11) + lib/ + docs/ + tests/ |
| `skills/task-dispatch/` | 11 | 1 796 | 116 379 | SKILL.md + 4 references + 6 scripts |
| `skills/task-discipline/` | 7 | 1 299 | 196 900 | SKILL.md + 4 references + 2 scripts |
| `skills/plan-resume/` | 9 | 1 751 | 77 871 | SKILL.md + README + config.json + 1 reference + 4 scripts + tests/smoke.sh |
| `skills/plan-template-kit/` | 4 | 731 | 67 772 | SKILL.md + 3 references |
| `skills/progress-tracker/` | 3 | 369 | 19 743 | SKILL.md + 2 references |
| `skills/verification-gate/` | 4 | 424 | 20 455 | SKILL.md + 1 reference + 1 script + 1 template |
| `skills/plan-cost-guard/` | 5 | 364 | 19 544 | SKILL.md + 4 references |
| `skills/plan-collab-router/` | 3 | 236 | 41 404 | SKILL.md + 2 references |
| `skills/plan-research-router/` | 3 | 155 | 27 307 | SKILL.md + 2 references |
| `skills/error-fix-prompt-forge/` | 2 | 136 | 8 054 | SKILL.md + 1 template |
| `skills/iterative-optimizer/` | 1 | 107 | 7 236 | SKILL.md only |
| `skills/todo-skill/` | 5 | 851 | 47 031 | SKILL.md + WORKFLOW.md + _meta.json + tools/cli_todo-manager.ts + tools/store.json |
| `skills/media-planner/` | 2 | 105 | 15 165 | SKILL.md + 1 reference |
| `skills/task-drift-guard/` | 4 | 308 | 22 820 | SKILL.md + README.md + EXAMPLES.md + 1 reference |

> 复现：`for d in skills/*/; do printf '%s %s %s\n' "$d" "$(find "$d" -type f -not -path '*/.backup/*' \| wc -l)" "$(find "$d" -type f -not -path '*/.backup/*' -exec cat {} + \| wc -l)"; done`

### 1.2 核心技能 `skills/task-planner/` 子目录汇总

| 子目录 | 文件数 | 行数 | 字节 |
|--------|-------|------|------|
| `scripts/` | 146 | 31 883 | 2 066 353 |
| `templates/` | 42 | 4 832 | 319 664（其中 `templates/variant/` 29 个变体模板） |
| `lib/` | 6 | 965 | 41 778 |
| `review-library/` | 11 | 928 | 94 319 |
| `companion/` | 8 | 795 | 52 727（8 个 companion agent 定义） |
| `references/` | 6 | 662 | 90 906 |
| `docs/` | 1 | 306 | 24 636 |
| `tests/` | 1 | 77 | 2 361 |
| 根级文件 | 10 | 3 575 | 202 221 |

> 复现：`for d in skills/task-planner/*/; do find "$d" -type f -printf '%s\n' \| paste -sd+ \| bc; done`

### 1.3 核心技能根级文件明细

| 文件 | 行 | 字节 |
|------|----|------|
| `skills/task-planner/SKILL.md` | 266 | 39 875 |
| `skills/task-planner/config.json` | 546 | 28 659 |
| `skills/task-planner/examples.md` | 414 | 11 184 |
| `skills/task-planner/reference.md` | 331 | 12 954 |
| `skills/task-planner/README.md` | 299 | 23 015 |
| `skills/task-planner/INSTALL.md` | 282 | 11 758 |
| `skills/task-planner/install.sh` | 227 | 9 903 |
| `skills/task-planner/MIGRATION.md` | 195 | 6 139 |
| `skills/task-planner/install.log` | 937 | 52 418 |
| `skills/task-planner/uninstall.sh` | 78 | 2 481 |

### 1.4 核心技能 `references/` 明细

| 文件 | 行 | 字节 |
|------|----|------|
| `references/critical-rules.md` | 203 | 50 541（均行 ≈ 249 B） |
| `references/methodology.md` | 251 | 25 156 |
| `references/worktree-isolation.md` | 124 | 8 791 |
| `references/todo-sync.md` | 70 | 5 275 |
| `references/completion-gate.md` | 7 | 564 |
| `references/goal-gate.md` | 7 | 579 |

### 1.5 核心技能 `companion/agents/` 明细

| 文件 | 行 | 字节 |
|------|----|------|
| `companion/agents/plan-writer.md` | 291 | 20 051 |
| `companion/agents/article-batch-publisher.md` | 160 | 6 672 |
| `companion/agents/video-generation-executor.md` | 70 | 5 562 |
| `companion/agents/image-generation-executor.md` | 69 | 5 534 |
| `companion/agents/article-field-fixer.md` | 61 | 3 283 |
| `companion/agents/decision-arbiter.md` | 60 | 5 105 |
| `companion/agents/complex-planner.md` | 48 | 2 877 |
| `companion/agents/drift-checker.md` | 36 | 3 643 |

### 1.6 卫星技能全部活文件明细（含行/字节）

| 技能 | 文件 | 行 | 字节 |
|------|------|----|------|
| task-dispatch | `SKILL.md` | 62 | 3 073 |
| task-dispatch | `references/agent-coverage.md` | 130 | 14 905 |
| task-dispatch | `references/critical-rules-dispatch.md` | 185 | 70 135（均行 ≈ 379 B） |
| task-dispatch | `references/dispatch-examples.md` | 107 | 7 495 |
| task-dispatch | `references/split-pattern-library.md` | 136 | 12 068 |
| task-dispatch | `scripts/analyze-splits.sh` | 198 | 10 733 |
| task-dispatch | `scripts/check-rescue-chain.sh` | 286 | 12 158 |
| task-dispatch | `scripts/check-subagent-return.sh` | 98 | 6 998 |
| task-dispatch | `scripts/subagent-fallback.sh` | 316 | 17 165 |
| task-dispatch | `scripts/selftest-fallback.sh` | 146 | 8 403 |
| task-dispatch | `scripts/selftest-rescue-chain.sh` | 132 | 6 786 |
| task-discipline | `SKILL.md` | 89 | 5 937 |
| task-discipline | `references/critical-rules-discipline.md` | 602 | 173 164（均行 ≈ 288 B，全仓最大文件） |
| task-discipline | `references/batch-quality-gate.md` | 171 | 13 142 |
| task-discipline | `references/capability-registry.md` | 10 | 1 357 |
| task-discipline | `references/execution-recall-card.md` | 51 | 4 458 |
| task-discipline | `scripts/plan-hygiene.sh` | 165 | 7 030 |
| task-discipline | `scripts/capabilities/agnes-quota.sh` | 211 | 12 651 |
| plan-resume | `SKILL.md` | 437 | 29 128 |
| plan-resume | `README.md` | 37 | 2 738 |
| plan-resume | `config.json` | 9 | 445 |
| plan-resume | `references/critical-rules-resume.md` | 17 | 3 607 |
| plan-resume | `scripts/extract-meta.sh` | 198 | 7 512 |
| plan-resume | `scripts/scan-plans.sh` | 114 | 3 097 |
| plan-resume | `scripts/score-plans.py` | 270 | 10 172 |
| plan-resume | `scripts/select-and-resume.sh` | 354 | 15 129 |
| plan-resume | `tests/smoke.sh` | 315 | 17 513 |
| plan-template-kit | `SKILL.md` | 40 | 4 116 |
| plan-template-kit | `references/critical-rules-template.md` | 53 | 19 734 |
| plan-template-kit | `references/template-guide.md` | 317 | 17 783 |
| plan-template-kit | `references/template-mapping.md` | 321 | 26 139 |
| progress-tracker | `SKILL.md` | 199 | 9 031 |
| progress-tracker | `references/critical-rules-progress.md` | 16 | 3 289 |
| progress-tracker | `references/ledger-format.md` | 154 | 7 423 |
| verification-gate | `SKILL.md` | 94 | 6 839 |
| verification-gate | `references/critical-rules-verification.md` | 52 | 10 098 |
| verification-gate | `scripts/run-verification.sh` | 127 | 6 304 |
| verification-gate | `templates/verification.md` | 151 | 5 683 |
| plan-cost-guard | `SKILL.md` | 43 | 3 523 |
| plan-cost-guard | `references/billing.md` | 60 | 2 998 |
| plan-cost-guard | `references/cost-control.md` | 171 | 8 208 |
| plan-cost-guard | `references/cost_log.md` | 72 | 2 967 |
| plan-cost-guard | `references/critical-rules-cost.md` | 18 | 1 868 |
| plan-collab-router | `SKILL.md` | 44 | 4 360 |
| plan-collab-router | `references/critical-rules-collab.md` | 79 | 24 719 |
| plan-collab-router | `references/skill-collaboration.md` | 113 | 12 349 |
| plan-research-router | `SKILL.md` | 45 | 3 326 |
| plan-research-router | `references/critical-rules-research.md` | 68 | 21 706 |
| plan-research-router | `references/research-routing.md` | 42 | 2 275 |
| media-planner | `SKILL.md` | 47 | 2 238 |
| media-planner | `references/critical-rules-media.md` | 58 | 12 927 |
| task-drift-guard | `SKILL.md` | 91 | 4 335 |
| task-drift-guard | `README.md` | 35 | 990 |
| task-drift-guard | `EXAMPLES.md` | 114 | 3 803 |
| task-drift-guard | `references/critical-rules-drift.md` | 68 | 13 492 |
| error-fix-prompt-forge | `SKILL.md` | 87 | 5 874 |
| error-fix-prompt-forge | `templates/fix-prompt-template.md` | 49 | 2 180 |
| iterative-optimizer | `SKILL.md` | 107 | 7 236 |
| todo-skill | `SKILL.md` | 128 | 4 176 |
| todo-skill | `WORKFLOW.md` | 62 | 2 979 |
| todo-skill | `_meta.json` | 11 | 273 |
| todo-skill | `tools/cli_todo-manager.ts` | 645 | 21 778 |
| todo-skill | `tools/store.json` | 5 | 62 |

---

## 2. 规则载体清单（`references/critical-rules*.md` 全仓）

### 2.1 载体文件路径 × Rule 覆盖区间

| # | 载体路径 | 行 | 字节 | Rule 正文编号（`^#{2,4} N` 抽取） | 条数 |
|---|---------|----|----|--------------------------------|-----|
| 1 | `skills/task-planner/references/critical-rules.md`（**核心**） | 203 | 50 541 | 1, 2, 3, 5, 19, 20, 26, 51, 62, 66, 80(`## Rule 80（`), 81, 82, 83 | 14 |
| 2 | `skills/task-discipline/references/critical-rules-discipline.md` | 602 | 173 164 | 4, 6, 7, 8, 9, 10, 18, 27, 28, 29, 31, 32, 33, 35, 36, 41, 42, 43, 44, 45, 48, 53, 54, 55, 56, 57, 60, 65, 67, 69, 70, 71, 72, 73, 74, 76, 85, 86, 87, 88, 89, 90, 92, 93 | 44 |
| 3 | `skills/task-dispatch/references/critical-rules-dispatch.md` | 185 | 70 135 | 12, 13, 14, 21, 22, 23, 25, 46, 52, 59, 68 | 11 |
| 4 | `skills/plan-collab-router/references/critical-rules-collab.md` | 79 | 24 719 | 39, 40, **91** | 3 |
| 5 | `skills/plan-research-router/references/critical-rules-research.md` | 68 | 21 706 | 58, 63, 75 | 3 |
| 6 | `skills/plan-template-kit/references/critical-rules-template.md` | 53 | 19 734 | 16, 34, 37, 38 | 4 |
| 7 | `skills/media-planner/references/critical-rules-media.md` | 58 | 12 927 | 47, 49, 50 | 3 |
| 8 | `skills/task-drift-guard/references/critical-rules-drift.md` | 68 | 13 492 | 11, 15, 61, 64 | 4 |
| 9 | `skills/progress-tracker/references/critical-rules-progress.md` | 16 | 3 289 | 30 | 1 |
| 10 | `skills/plan-cost-guard/references/critical-rules-cost.md` | 18 | 1 868 | 17 | 1 |
| 11 | `skills/plan-resume/references/critical-rules-resume.md` | 17 | 3 607 | 24 | 1 |
| 12 | `skills/verification-gate/references/critical-rules-verification.md` | 52 | 10 098 | 84 | 1 |
| — | **合计（活载体 12 个）** | **1 571** | **396 085** | 核心 14 + 卫星 76 = **90 条** | **90** |

> 复现（逐文件）：`for f in $(find skills -name 'critical-rules*.md' -not -path '*/.backup/*'); do grep -nE '^#{2,4} [0-9]+' "$f"; done`

### 2.2 非活载体（归档/备份副本，不参与现行路由）

| 路径 | 性质 |
|------|------|
| `skills/task-planner/.backup/claude-stub-20261012-235503/claude-code/references/critical-rules.md` | 安装 stub 备份（314 902 B） |
| `skills/task-planner/.backup/claude-stub-20261012-235503/{cursor,opencode,zcode}/references/critical-rules.md` | 各 IDE stub 备份 |
| `skills/task-planner/.backup/claude-stub-20261012-235503/cursor/.backup/claude-stub-20261009-222907/**/references/critical-rules.md` | 二级嵌套备份（4 份） |
| `plans/archive/task-v081-fine-grain-step-gate/subagent-state/baseline/critical-rules.md` | 计划基线快照 |
| `plans/archive/task-v082-minimal-probe/subagent-state/baseline/skills/task-planner/references/critical-rules.md` | 计划基线快照 |

> 全仓 `find . -name 'critical-rules*.md'` 共 23 命中 = 活载体 12 + 备份 9 + 计划快照 2。

### 2.3 两张并行「卫星路由索引」（同一份规则映射的两个副本）

| 载体 | 位置 | plan-collab-router 行写的 Rule | task-discipline 行写的 Rule |
|------|------|---------------------------|---------------------------|
| 核心 `critical-rules.md` §卫星路由索引 | `skills/task-planner/references/critical-rules.md:191-203`（plan-collab-router 行 = `:198`） | **39,40**（缺 91） | 显式列举 44 条，无 75 |
| 核心 `SKILL.md` 卫星路由表 | `skills/task-planner/SKILL.md:190-202`（plan-collab-router 行 = `:199`，task-discipline 行 = `:195`） | **39,40,91** | 区间式 `41-45,53-57,69-76`（**69-76 含 75**） |
| `SKILL.md` frontmatter 卫星行 | `skills/task-planner/SKILL.md:16-19`（task-discipline 行 = `:17`） | — | 同上区间式 `41-45,53-57,69-76` |
| 核心域条数口径（两处一致 = 14） | `skills/task-planner/SKILL.md:9` / `:208`；`skills/task-planner/references/critical-rules.md:177` | — | 核心 14 条清单完全一致 |

> 复现：`grep -n 'plan-collab-router\|task-discipline:' skills/task-planner/SKILL.md`；`grep -n '卫星路由索引' skills/task-planner/references/critical-rules.md`

---

## 3. 守卫脚本清单（`skills/task-planner/scripts/` 全部 `.sh/.ts/.cjs/.ps1`）

> 目录内共 146 文件 = 92 个 `selftest-*.sh`（见 §4）+ 53 个守卫/钩子/工具脚本 + 1 个数据文件 `selftest-registry.tsv`。
> 分类依据 = 读各脚本前 5-10 行头注。复现：`sed -n '1,10p' <script>`。

### 3.1 守卫门（gate / check-*）—— 判定型，产出 PASS/FAIL/exit code

| 脚本 | 行 | 字节 | 职责（头注归纳） |
|------|----|------|----------------|
| `check-complete.sh` | 2 066 | 149 631 | **终验完成度主门**：解析 task_plan.md 全部 Phase 的 `- [x]` 进度，串联各子门（Rule 18.6/19.5/23.6/31.5/25.4），Stop hook 消费 |
| `check-3file-gate.sh` | 385 | 19 906 | Rule 19.2 执行中 3-File 回填门控（Phase 翻 complete 前必须调用） |
| `check-delegation.sh` | 616 | 29 553 | Rule 55 执行期委派门控（session-owner 对比 + 白名单 + exit2 阻断 + warn 计数） |
| `check-dispatch.sh` | 685 | 53 521 | Rule 22.4c/22.8.1 Agent() 派发契约守卫（3 文件绝对路径 + 8 字段返回 key + 检查点路径） |
| `check-plan-dispatch.sh` | 676 | 42 940 | Rule 22.6/25.1 计划期派发门控（派发型 Phase 必附执行体 S-unit 表） |
| `check-conflicts.sh` | 222 | 11 176 | 计划创建前冲突分析 + Rule 23 运行时并发冲突检测（scope 交集） |
| `check-context-hygiene.sh` | 145 | 4 858 | Rule 29.2/29.3 上下文退场机械检查器（只读扫描 findings/progress） |
| `check-drift.sh` | 335 | 12 994 | 防漂移检测：Phase 完成后对照原始计划校验执行偏航 |
| `check-evidence-anchor.sh` | 530 | 32 039 | 证据锚真实性三层检查（存在性 + 行界 + 否定 trim + provenance + CLAIM_MATCH 内容核对） |
| `check-gate-degraded.sh` | 175 | 12 120 | P-07 门降级可见化判定器（fail-open 降级放行落 `[gate-degraded]` 痕迹） |
| `check-goal-cjk.sh` | 169 | 9 852 | P-06 纯中文 Goal 的 CJK 分词漂移补检（locale 鲁棒） |
| `check-rvc-coverage.sh` | 211 | 11 352 | P-08 R→VC 双向覆盖核对（R 孤儿 / VC 孤儿） |
| `check-scope.sh` | 187 | 9 541 | PreToolUse 守卫：Write/Edit 对 session-scoped `.plan_required_side` 哨兵校验 |
| `check-skill-modify.sh` | 96 | 5 222 | Rule 36 技能修改保守化门（技能文件写入须登记于活跃计划范围表） |
| `check-state-consistency.sh` | 141 | 7 484 | P-04 计划状态三源一致性（checkbox ↔ Status ↔ progress 交叉） |
| `check-step-placeholders.sh` | 93 | 5 923 | P-03 计划步骤模糊动词占位符扫描器 |
| `check-stop-guard.sh` | 92 | 5 746 | Stop hook 停止护栏（五重 guard + stall 检测，block 计数 cap=20） |
| `check-template-type.sh` | 42 | 2 387 | Rule 34.1 模板选取门控（template_type 白名单动态派生） |
| `check-tier-consistency.sh` | 152 | 10 328 | P-09 档位声明外部体量复核（mini 四条件 + L0 禁滥用） |
| `check-vc-nonvacuous.sh` | 189 | 9 720 | P-02 VC 非真空命令检查（拦截 `true`/`:`/`echo ok` 等恒 exit 0 命令） |
| `check-window-consistency.sh` | 353 | 18 605 | Rule 51.1a/51.7 通用窗口口径一致性 lint（跨族口径警报） |
| `check-doc-sync.sh` | 68 | 2 971 | task_plan.md 陈旧度检测 + 强制同步（max_age_minutes） |

### 3.2 钩子 / 平台适配层（hook 入口，喂给 ZCode/Claude 工具面）

| 脚本 | 行 | 字节 | 职责 |
|------|----|------|------|
| `zcode-pretooluse.sh` | 158 | 11 338 | ZCode PreToolUse 适配器：哨兵期 Write/Edit 阻断 + Rule 23 运行时并发检测 |
| `zcode-posttooluse.sh` | 385 | 26 685 | PostToolUse 周期强制同步 hook（工具调用计数 + 活跃计划探测 + 已完结静默） |
| `zcode-userpromptsubmit.sh` | 312 | 20 644 | UserPromptSubmit hook：Rule 20.4 smart 注入（结构感知计划复诵块，mtime 变更限频） |
| `zcode-sessionstart.sh` | 77 | 4 633 | SessionStart 适配器：调 task-plan-init.cjs 写哨兵，恒 exit 0（fail-open） |
| `task-plan-init.cjs` | 170 | 9 825 | 哨兵机制写入端（SessionStart hook，`.plan-required`） |
| `plan-created.cjs` | 305 | 16 541 | 计划创建事件处理（清哨兵 + 活跃计划指针 + archive 跳过） |
| `register-hooks-cj.ts` | 217 | 9 145 | 把 4 个 zcode hook 注册进平台配置 |
| `init-session.sh` | 1 023 | 69 556 | 会话初始化主脚本（6 文件建立/复核 + trivial 代码修复 auto-tier 判定 + 模板路由） |
| `init-session.ps1` | 79 | 2 383 | 同上 PowerShell 版 |
| `check-complete.ps1` | 46 | 1 708 | 终验 PowerShell 版 |

### 3.3 状态 / 指针 / 账本 / 生命周期工具

| 脚本 | 行 | 字节 | 职责 |
|------|----|------|------|
| `attest-plan.sh` | 606 | 43 104 | Rule 20.1 计划 attestation（SHA-256 锁定 → 注入前校验，篡改则 `[PLAN TAMPERED]`） |
| `archive-plan.sh` | 241 | 11 955 | Rule 81 完成→归档器（mv plans/<id> → plans/archive/<id>，支持 --batch/--dry-run） |
| `auto-finalize.sh` | 90 | 6 372 | Rule 42.7/38.7 收尾引擎（INDEX 刷新 + CHANGELOG 收口 + 四项证据校验） |
| `set-active-plan.sh` | 288 | 16 556 | 活跃计划指针设置/查看（全局 fallback + 会话私有 side 双层） |
| `resolve-plan-dir.sh` | 147 | 8 186 | 解析当前活跃计划 task_plan.md 路径（移植 planning-with-files v3 解析链） |
| `resolve-interaction-mode.sh` | 103 | 4 026 | Rule 28.1 交互模式解析（env > 计划配置表 > 默认 ask） |
| `lane-detect.sh` | 126 | 9 398 | Rule 38.7 执行通道机器判定（L0/L1/L2，按 git diff 体量） |
| `ledger-append.sh` | 155 | 6 454 | 追加式工作账本（移植自 planning-with-files v3，flock 并发 + tick 单调） |
| `periodic-review.sh` | 195 | 5 410 | Rule 65 周期性回顾与前后对照检测 |
| `rule-reserve.sh` | 408 | 14 427 | Rule 20.6 Rule 编号预留登记账本（reserve/check/next/list/land/release，append-only） |
| `plan-doctor.sh` | 128 | 5 706 | 计划机制一键自检（计划解析 + hook 面 + 安装面一致性） |
| `allow-direct.sh` | 188 | 8 201 | Rule 55 用户明文豁免主进程委派门控的入口（同 sid 仅一次 + `--force`） |
| `verify_io.sh` | 85 | 4 486 | I/O 契约机器校验（7 文件在位 + check-delegation stats JSON schema） |
| `lib/plan-parse.sh` | 51 | 3 227 | 公共库：计划文件 scope 提取语义唯一权威源（消除多处内联复制漂移） |

### 3.4 同步 / 部署 / 工具脚本

| 脚本 | 行 | 字节 | 职责 |
|------|----|------|------|
| `run-selftests.sh` | 169 | 9 073 | **全量 selftest 回归统一入口**（枚举 `selftest-*.sh` 逐个跑 + 输入指纹缓存 + Total 汇总） |
| `sync-todos.sh` | 434 | 22 504 | Phase→Todo 同步报告生成器（`--index` 生成 plans/INDEX.md 全量重算） |
| `sync-companion.sh` | 143 | 6 343 | 反向同步：把安装位 companion/agents/ 与顶层 skills/ 的修改拉回 canonical |
| `sync-ide-folders.ts` | 198 | 8 502 | 多 IDE 目录（cursor/gemini/codex/opencode/…14 个）规范源同步 |
| `session-catchup.ts` | 274 | 10 482 | 会话扫描/恢复（扫描 Claude Code 会话目录，探测 OPENCODE_DATA_DIR） |
| `smart-merge-back.sh` | 780 | 48 115 | 合并回智能门（V1-V6 结构化预检 + `--no-ff` 合并 + `--deploy` 重部署对账） |
| `schemas/check-delegation-stats.schema.json` | 25 | 1 053 | check-delegation stats JSON 契约 schema（消费方=check-complete.sh:453-524） |
| `selftest-registry.tsv` | 93 | 34 719 | selftest 分域登记表（script/domain/trigger_scenarios/dep_anchors，92 行数据） |

### 3.5 卫星技能自带的守卫脚本（非集中于核心）

| 脚本 | 行 | 字节 | 职责 |
|------|----|------|------|
| `skills/task-dispatch/scripts/check-rescue-chain.sh` | 286 | 12 158 | Rule 65 子代理失败挽救链路机械门控 |
| `skills/task-dispatch/scripts/check-subagent-return.sh` | 98 | 6 998 | Rule 22.4b 子代理 8 字段返回主进程侧机械校验器 |
| `skills/task-dispatch/scripts/analyze-splits.sh` | 198 | 10 733 | Rule 59.6 S-unit 拆分体检（粒度三值 Nf/Nl/Nmin） |
| `skills/task-dispatch/scripts/subagent-fallback.sh` | 316 | 17 165 | provider 类失败后主动 Scaling 改派 |
| `skills/task-discipline/scripts/plan-hygiene.sh` | 165 | 7 030 | Rule 29.4/29.5 工作文件整理器（诊断型） |
| `skills/task-discipline/scripts/capabilities/agnes-quota.sh` | 211 | 12 651 | Rule 55 首个落盘实例：Agnes 账户额度/计费层直查 |
| `skills/plan-resume/scripts/select-and-resume.sh` | 354 | 15 129 | plan-resume v0.6 自主推进编排（config 驱动 + skip_states 硬排除） |
| `skills/plan-resume/scripts/scan-plans.sh` | 114 | 3 097 | 扫描工作区所有 task-planner 计划位置 |
| `skills/plan-resume/scripts/extract-meta.sh` | 198 | 7 512 | 从单个 task_plan.md 提取元数据 |
| `skills/plan-resume/scripts/score-plans.py` | 270 | 10 172 | plan-resume v0.4 综合加权打分（importance_score 等） |
| `skills/verification-gate/scripts/run-verification.sh` | 127 | 6 304 | Rule 84.6 统一验证执行入口（解析 verification.md 的 Verify command 逐条执行） |
| `skills/plan-resume/tests/smoke.sh` | 315 | 17 513 | plan-resume 冒烟测试（非 selftest- 前缀） |
| `skills/task-planner/tests/smoke.sh` | 77 | 2 361 | 核心冒烟测试（非 selftest- 前缀） |

---

## 4. selftest 清单（全仓 `selftest-*.sh`）

### 4.1 分布统计

| 范围 | 数量 | 复现命令 |
|------|------|---------|
| `skills/task-planner/scripts/`（活、集中） | **92** | `ls skills/task-planner/scripts/selftest-*.sh \| wc -l` |
| `skills/task-dispatch/scripts/`（活、卫星自带） | **2** | `find skills/task-dispatch -name 'selftest-*.sh'` |
| **skills/ 活树合计** | **94** | `find skills -name 'selftest-*.sh' -not -path '*/.backup/*' \| wc -l` |
| `plans/` 下 | 3 | `find plans -name 'selftest-*.sh' \| wc -l` |
| `skills/task-planner/.backup/` 下 | 557 | `find skills/task-planner/.backup -name 'selftest-*.sh' \| wc -l` |
| **全仓合计** | **654** | `find . -name 'selftest-*.sh' -not -path './.git/*' \| wc -l` |

> 全仓 654 = 活 94 + `.backup` 557 + plans 快照 3。
> **所有卫星技能的 selftest 都集中在核心 `skills/task-planner/scripts/`**，卫星自身 `scripts/` 只有 2 个（task-dispatch）。

### 4.2 活 selftest 全清单（94 条）— 路径 + 头注职责 + 覆盖 Rule

| # | 路径 | 职责（头注） | 覆盖 Rule |
|---|------|------------|----------|
| 1 | `skills/task-planner/scripts/selftest-absorption-discipline.sh` | Rule 74 变更吸收三判纪律载体存在性静态守护（AD-01..14） | 74 |
| 2 | `skills/task-planner/scripts/selftest-active-plan.sh` | active-plan-race 会话私有指针自测（T01..T12f） | 指针 |
| 3 | `skills/task-planner/scripts/selftest-agent-coverage.sh` | Rule 52 执行体专业化优先 + 覆盖矩阵静态守护（AC-01..09） | 52 |
| 4 | `skills/task-planner/scripts/selftest-archive-plan.sh` | Rule 81 完成→归档机制行为守护（AP-01..AP-20） | 81 |
| 5 | `skills/task-planner/scripts/selftest-ask-default-timeout.sh` | Rule 44 默认项与自动超时静态守护（RT-01..11） | 44 |
| 6 | `skills/task-planner/scripts/selftest-batch-pilot.sh` | Rule 18 批量试点先行硬门静态守护（BP-01..03） | 18 |
| 7 | `skills/task-planner/scripts/selftest-capability-persistence.sh` | Rule 55 可复用能力落盘静态守护（CP-01..20） | 55 |
| 8 | `skills/task-planner/scripts/selftest-channel-fast-fail.sh` | Rule 83 通道不可用快速失败全链断言（CF-01..06） | 83 |
| 9 | `skills/task-planner/scripts/selftest-check-conflicts.sh` | check-conflicts.sh 五类信号行为级自测 | 23 |
| 10 | `skills/task-planner/scripts/selftest-check-drift.sh` | check-drift.sh 三 quirk 修复行为级回归 | 漂移 |
| 11 | `skills/task-planner/scripts/selftest-conclusion-discipline.sh` | Rule 35 执行结论纪律静态守护（CD-01..08） | 35 |
| 12 | `skills/task-planner/scripts/selftest-context-hygiene.sh` | Rule 29 上下文维护面 hermetic 守护（T01..） | 29 |
| 13 | `skills/task-planner/scripts/selftest-context-pressure.sh` | Rule 67 上下文压力评估与会话交接静态守护（CP-01..09） | 67 |
| 14 | `skills/task-planner/scripts/selftest-decision-arbiter.sh` | Rule 69 判断裁决子代理化载体锚静态守护 | 69 |
| 15 | `skills/task-planner/scripts/selftest-decision-drift.sh` | Rule 73 执行期决策对齐与不变量机制守护（DD-01..22） | 73 |
| 16 | `skills/task-planner/scripts/selftest-decision-grading.sh` | Rule 72 决策分级与用户打断纪律静态守护（DG-01..12） | 72 |
| 17 | `skills/task-planner/scripts/selftest-delegation.sh` | Rule 55 委派门控自测（T01..T09） | 55 |
| 18 | `skills/task-planner/scripts/selftest-dispatch-grain.sh` | Rule 46 子代理单任务专注度守护（GR-01..） | 46 |
| 19 | `skills/task-planner/scripts/selftest-dispatch.sh` | check-dispatch.sh + pretooluse Agent 分支自测（T01..12） | 22 |
| 20 | `skills/task-planner/scripts/selftest-doc-script-paths.sh` | 文档脚本/文档引用路径存在性断言（「引用即契约」） | 全域 |
| 21 | `skills/task-planner/scripts/selftest-drift-check-subagent.sh` | Rule 61 偏移检查子代理化载体锚静态守护 | 61 |
| 22 | `skills/task-planner/scripts/selftest-drift-enforcement.sh` | Rule 64.5 机制守护（静态 DCE-01..10 + 行为 DCE-11..16） | 64 |
| 23 | `skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh` | 顶层 error-fix-prompt-forge skill 静态守护 | — |
| 24 | `skills/task-planner/scripts/selftest-error-loop.sh` | Rule 31 错误学习闭环静态守护（EL-01..） | 31 |
| 25 | `skills/task-planner/scripts/selftest-evidence-anchor.sh` | P-01 证据锚真实性行为级 + 静态守护（EA-01..20） | 证据 |
| 26 | `skills/task-planner/scripts/selftest-evidence-goal-gate.sh` | Rule 58 调研分析证据纪律静态守护（EG-01..23） | 58 |
| 27 | `skills/task-planner/scripts/selftest-execution-honesty.sh` | Rule 54 执行诚实性与即时执行纪律静态守护（EH-） | 54 |
| 28 | `skills/task-planner/scripts/selftest-execution-stability.sh` | 环境级中断自愈面守护套件（自愈矩阵 6 行） | 68/自愈 |
| 29 | `skills/task-planner/scripts/selftest-final-gate-hash.sh` | 终验重复门四元内容键 SKIP-BY-HASH 六夹具 | 终验 |
| 30 | `skills/task-planner/scripts/selftest-fine-grain-steps.sh` | 步骤枚举门控（step_max_steps）行为级守护（SG-） | 步骤 |
| 31 | `skills/task-planner/scripts/selftest-four-file-dataflow.sh` | Rule 62 四文件罗盘数据流转静态守护（FF-01..18） | 62 |
| 32 | `skills/task-planner/scripts/selftest-gate-degraded.sh` | P-07 门降级可见化行为级 + 静态守护（GD-01..16） | 降级 |
| 33 | `skills/task-planner/scripts/selftest-gate-injection.sh` | 5 门注入式行为回归（GI-01..11） | 门链 |
| 34 | `skills/task-planner/scripts/selftest-goal-cjk.sh` | P-06 纯中文 Goal 漂移补检（GCK-01..11） | CJK |
| 35 | `skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh` | Rule 66 goal 单元固化静态守护（G-01..09） | 66 |
| 36 | `skills/task-planner/scripts/selftest-input-consistency.sh` | Rule 85 用户输入一致性静态守护（IC-01..05） | 85 |
| 37 | `skills/task-planner/scripts/selftest-interaction.sh` | Rule 28.1 resolve-interaction-mode.sh 解析优先级自测（TI-） | 28 |
| 38 | `skills/task-planner/scripts/selftest-iteration-persistence.sh` | Rule 57 迭代测试轮次落盘静态守护（IP-01..18） | 57 |
| 39 | `skills/task-planner/scripts/selftest-iterative-optimizer.sh` | 顶层 iterative-optimizer skill 静态守护（IL-01..08） | — |
| 40 | `skills/task-planner/scripts/selftest-knowledge-brief.sh` | knowledge-brief 六段骨架 + 全链路接入面守护 | 59.3 |
| 41 | `skills/task-planner/scripts/selftest-lane-advancement.sh` | Rule 49 单元线多路并行推进静态守护 | 49 |
| 42 | `skills/task-planner/scripts/selftest-mechanism-profile.sh` | Rule 37 任务类型机制画像静态守护（MP-，target=CRIT_T） | 37 |
| 43 | `skills/task-planner/scripts/selftest-media-agents.sh` | Rule 47.2 媒体双专业执行体静态守护 | 47 |
| 44 | `skills/task-planner/scripts/selftest-media-dispatch.sh` | Rule 47 媒体制作任务派发纪律静态守护 | 47 |
| 45 | `skills/task-planner/scripts/selftest-methodology.sh` | methodology/FMEA/内容质量门控嵌入点守护（M-01..11） | 方法论 |
| 46 | `skills/task-planner/scripts/selftest-parallel-scheduling.sh` | Rule 68 依赖分析/并行分组/异构分摊静态守护（P-01..09） | 68 |
| 47 | `skills/task-planner/scripts/selftest-periodic-review.sh` | Rule 65 周期性回顾静态守护（PR-01..10） | 65 |
| 48 | `skills/task-planner/scripts/selftest-plan-dispatch.sh` | check-plan-dispatch.sh + attest-plan.sh 集成自测（T01..12） | 22/25 |
| 49 | `skills/task-planner/scripts/selftest-plan-tier.sh` | Rule 38 难度分级与轻量档守护（PT-，target=CRIT_T） | 38 |
| 50 | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh` | 指针与部署生命周期守护（PL-01..10） | 指针 |
| 51 | `skills/task-planner/scripts/selftest-proactive-research.sh` | Rule 75 网络调研主动激活静态守护（PR-01..15） | 75 |
| 52 | `skills/task-planner/scripts/selftest-reflect-verify.sh` | Rule 33 解决→反思→验证迭代循环静态守护（RV-） | 33 |
| 53 | `skills/task-planner/scripts/selftest-registry.sh` | selftest 分域 registry(TSV) 一致性自守护（T01..） | registry |
| 54 | `skills/task-planner/scripts/selftest-reliability-institution.sh` | Rule 42/43 质量审查+执行可靠性制度化静态守护（R-01..16） | 42/43 |
| 55 | `skills/task-planner/scripts/selftest-report-reviewability.sh` | Rule 70 用户呈报可审批性静态守护 | 70 |
| 56 | `skills/task-planner/scripts/selftest-requirement-coverage.sh` | Rule 51 需求覆盖与完成声称门控静态守护（十三子条） | 51 |
| 57 | `skills/task-planner/scripts/selftest-requirement-grading.sh` | Rule 50 内容要求权重分级与评级静态守护 | 50 |
| 58 | `skills/task-planner/scripts/selftest-research-first.sh` | Rule 63 检索优先与反推诿静态守护 | 63 |
| 59 | `skills/task-planner/scripts/selftest-review-library.sh` | Rule 42 质量审查兜底池静态守护（RL-01..15） | 42 |
| 60 | `skills/task-planner/scripts/selftest-root-resolution.sh` | Rule 53 根源解决与决策管辖静态守护 | 53 |
| 61 | `skills/task-planner/scripts/selftest-rule23-conflict-scan.sh` | Rule 23 运行时并发冲突扫描行为级自测 | 23 |
| 62 | `skills/task-planner/scripts/selftest-rule-reserve-pairing.sh` | Rule 20.6 账本 reserve↔land 配对不变量守护（PR-01..03） | 20.6 |
| 63 | `skills/task-planner/scripts/selftest-rule-reserve.sh` | Rule 20.6 编号预留登记机制静态守护（RR-01..10） | 20.6 |
| 64 | `skills/task-planner/scripts/selftest-rvc-coverage.sh` | P-08 R→VC 双向覆盖行为级 + 静态守护（RVC-01..09） | 覆盖 |
| 65 | `skills/task-planner/scripts/selftest-self-resolution.sh` | Rule 41 问题自主消解与升级静态守护（SR-01..13） | 41 |
| 66 | `skills/task-planner/scripts/selftest-session-log.sh` | Rule 80 用户会话逐字记录全链断言（SL-01..11） | 80 |
| 67 | `skills/task-planner/scripts/selftest-shared-tracker.sh` | Rule 30 共享内容认领追踪静态守护（ST-） | 30 |
| 68 | `skills/task-planner/scripts/selftest-skill-collab.sh` | 协同路由面守护套件（T1..T10 / 19 断言） | 22.3.3 |
| 69 | `skills/task-planner/scripts/selftest-skill-modify.sh` | Rule 36 技能修改保守化静态守护（SM-01..） | 36 |
| 70 | `skills/task-planner/scripts/selftest-skill-split.sh` | 技能拆分终态守护套件（4+3 拆分方案） | 拆分 |
| 71 | `skills/task-planner/scripts/selftest-smart-merge.sh` | smart-merge-back.sh 智能门 hermetic 自测（SM-01..15b） | 合并 |
| 72 | `skills/task-planner/scripts/selftest-source-anchor-discipline.sh` | Rule 71 无源不写/空段占位/写必带锚静态守护（SA-01..12） | 71 |
| 73 | `skills/task-planner/scripts/selftest-split-pattern-library.sh` | Rule 21.6 拆分模式库机器面静态守护（SP-01..13） | 21.6 |
| 74 | `skills/task-planner/scripts/selftest-state-consistency.sh` | P-04 计划状态三源一致性门行为级自测 | 一致性 |
| 75 | `skills/task-planner/scripts/selftest-step-placeholders.sh` | P-03 步骤占位符扫描行为级 + 静态守护（SP-01..10） | 占位 |
| 76 | `skills/task-planner/scripts/selftest-subagent-granularity-skill-escort.sh` | Rule 59 拆分粒度硬门与技能伴飞静态守护 | 59 |
| 77 | `skills/task-planner/scripts/selftest-subagent-return.sh` | Rule 22.4b 返回格式污染三面守护（A3..A10） | 22.4b |
| 78 | `skills/task-planner/scripts/selftest-summary-readability.sh` | Rule 76 总结可读性与审查清单实体化静态守护 | 76 |
| 79 | `skills/task-planner/scripts/selftest-sync-index.sh` | sync-todos.sh --index 行为级自测（T01..） | INDEX |
| 80 | `skills/task-planner/scripts/selftest-task-boundary.sh` | Rule 8.1 新任务边界判定静态守护（TB-） | 8.1 |
| 81 | `skills/task-planner/scripts/selftest-template-lifecycle.sh` | Rule 34 模板生命周期静态守护（TL-，target=CRIT_T/CRIT_D） | 34 |
| 82 | `skills/task-planner/scripts/selftest-template-sense.sh` | Rule 34.7 三时点模板感知网行为级守护 | 34.7 |
| 83 | `skills/task-planner/scripts/selftest-tier-b.sh` | Tier B 全 7 项守护（T-B1..T-B7 正反夹具） | 档位 |
| 84 | `skills/task-planner/scripts/selftest-tier-consistency.sh` | P-09 档位声明外部复核行为级 + 静态守护（TC-01..08） | 档位 |
| 85 | `skills/task-planner/scripts/selftest-tool-selection.sh` | Rule 40 harness 工具面主动选择静态守护（TS-01..12） | 40 |
| 86 | `skills/task-planner/scripts/selftest-user-instruction-priority.sh` | Rule 56 静态守护（56.1-56.5 + SKILL 联动 + 零新键） | 56 |
| 87 | `skills/task-planner/scripts/selftest-vc-gate.sh` | check-complete.sh 终验 VC/V-N 门控自测（V-9） | 84 |
| 88 | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh` | P-02 VC 非真空命令行为级 + 静态守护（VNC-01..13） | 84 |
| 89 | `skills/task-planner/scripts/selftest-verification-gate.sh` | Rule 84 验证技能独立化静态守护（84.6 机器面） | 84 |
| 90 | `skills/task-planner/scripts/selftest-verify-io.sh` | verify_io.sh 行为守护（7 文件 + stats schema + 坏 JSON） | IO |
| 91 | `skills/task-planner/scripts/selftest-veto.sh` | Rule 32 用户否决与禁令追踪静态守护（VT-） | 32 |
| 92 | `skills/task-planner/scripts/selftest-workflow-orchestration.sh` | Rule 39 动态工作流编排静态守护（WF-01..16 + WF-17..22） | 39/91 |
| 93 | `skills/task-dispatch/scripts/selftest-fallback.sh` | subagent-fallback.sh 自测（T01..T08） | 兜底 |
| 94 | `skills/task-dispatch/scripts/selftest-rescue-chain.sh` | check-rescue-chain.sh 自测（hermetic，T01..T05） | 挽救 |

### 4.3 registry 与磁盘一致性（已核对 = 完全一致）

| 项 | 值 |
|----|----|
| `selftest-registry.tsv` 行数 | 93（1 表头 + **92 数据行**） |
| `skills/task-planner/scripts/selftest-*.sh` 实际数 | 92 |
| 磁盘有但 registry 无 | 0 |
| registry 有但磁盘无 | 0 |

> 复现：`tail -n +2 selftest-registry.tsv \| cut -f1 \| sort > /tmp/r; ls selftest-*.sh \| xargs -n1 basename \| sort > /tmp/d; comm -13 /tmp/r /tmp/d; comm -23 /tmp/r /tmp/d`

---

## 5. 规则编号索引（Rule 编号全景）

### 5.1 编号最大值与分布

| 指标 | 值 | 证据 |
|------|----|------|
| 全仓出现过的最大 Rule 编号 | **93** | `grep -rhoE '\bRule ?[0-9]+'` → 93 计数最高（`Rule 93: 39 refs`）；ledger 最大号 = 93（`{"rule":93,...,"landed"}`） |
| 出现过的编号下界 | 1 | `Rule 1: 86 refs` |
| 编号连续性 | 1–93 全部出现过（无整号段缺失） | 逐号计数表（Rule 1..93 每号 ≥11 refs） |
| 唯一越界编号 | **99**（2 refs） | 仅出现在 `plans/archive/task-v148-drift-enforce/{findings.md:104,subagent-state/08-executor.md:16}` 的**负例测试夹具**（`Rule 99.9` 故意不命中），非真实条款 |
| 实际有正文的规则总数 | **90** | 1–93 中扣除 77/78/79（ledger 标 `abandoned`，无正文）= 90 |
| 核心正文 | 14（1,2,3,5,19,20,26,51,62,66,80,81,82,83） | `skills/task-planner/references/critical-rules.md` |
| 卫星正文 | 76 | 11 个卫星载体合计（见 §2.1） |

### 5.2 号段位分布（按 10 号段）

| 号段 | 有正文号 | 段内条数 | 缺号 | 归属 |
|------|---------|---------|------|------|
| 1–9 | 1,2,3,4,5,6,7,8,9 | 9 | 无 | 核心(1,2,3,5) + 纪律(4,6,7,8,9) |
| 10–19 | 10,11,12,13,14,15,16,17,18,19 | 10 | 无 | 纪律(10,18) + 漂移(11,15) + 派发(12,13,14) + 模板(16) + 成本(17) + 核心(19) |
| 20–29 | 20,21,22,23,24,25,26,27,28,29 | 10 | 无 | 核心(20,26) + 派发(21,22,23,25) + 续推(24) + 纪律(27,28,29) |
| 30–39 | 30,31,32,33,34,35,36,37,38,39 | 10 | 无 | 共享(30) + 纪律(31,32,33,35,36) + 模板(34,37,38) + 协同(39) |
| 40–49 | 40,41,42,43,44,45,46,47,48,49 | 10 | 无 | 协同(40) + 纪律(41–45,48) + 派发(46) + 媒体(47,49) |
| 50–59 | 50,51,52,53,54,55,56,57,58,59 | 10 | 无 | 媒体(50) + 核心(51) + 派发(52) + 纪律(53–57) + 调研(58) + 派发(59) |
| 60–69 | 60,61,62,63,64,65,66,67,68,69 | 10 | 无 | 纪律(60,65,67,69) + 漂移(61,64) + 核心(62,66) + 调研(63) + 派发(68) |
| 70–79 | 70,71,72,73,74,75,76,79 | 8 | **77,78** | 纪律(70,71,72,73,74,76) + 调研(75) + 79 = abandoned |
| 80–89 | 80,81,82,83,84,85,86,87,88,89 | 10 | 无 | 核心(80,81,82,83) + 验证(84) + 纪律(85–89) |
| 90–93 | 90,91,92,93 | 4 | 无 | 纪律(90,92,93) + 协同(91) |

> 注：上表「79」无正文，ledger 记 `abandoned`；故 70–79 段实为 7 条正文（70–76）。精确地：正文号 = 1–93 去 {77,78,79} = 90 条。

### 5.3 编号预留账本（`plans/.rule-reservations.jsonl`）

| 指标 | 值 | 证据 |
|------|----|------|
| 账本总行数 | 81 | `wc -l plans/.rule-reservations.jsonl` |
| 账本覆盖的编号范围 | **46–93**（1–45 全部不在账本内） | `grep -oE '"rule": *[0-9]+'` 去重 |
| 状态分布 | landed 39 / reserved 37 / abandoned 4 / contested 1 | `grep -oE '"status": *"[a-z]+"' \| sort \| uniq -c` |
| 唯一 `contested` 条目 | Rule 50（task-v125 vs task-v127 抢号，后由 v127 land 落定） | `{"rule": 50, "status": "contested", "claimants": ["task-v125","task-v127"]}` |
| `abandoned` 条目 | 60（让位 v143 仲裁）、77、78、79（task-v168 封存未合并） | 同上 |
| **终态 `reserved` 但正文已存在** | **57, 80, 82**（3 条） | 账本 `57=reserved`/`80=reserved`/`82=reserved`；正文 `critical-rules-discipline.md:278` / `critical-rules.md:139` / `critical-rules.md:173` 均已落地 |
| **正文已存在但账本完全无记录** | **83**（1 条） | `grep -c '"rule": *83' plans/.rule-reservations.jsonl` → 0；正文 `critical-rules.md:181`（`### 83 通道不可用快速失败`） |
| 配对守护脚本的豁免表 | `EXEMPT_LANDED=(46 47 48 49 50 75)` / `EXEMPT_DANGLING=(57 60 80 82)` | `skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:38` / `:41` |

---

## 6. `plans/` 簿记形态概览

### 6.1 根级在途计划目录清单（23 个非 archive 目录）

| 目录 | `task_plan.md` | Status 行 | 备注 |
|------|---------------|----------|------|
| `cost-analysis-2026-10-05` | ✗ 无 | — | 仅 4 个 .md 报告，无计划 |
| `incident-reports` | ✗ 无 | — | 仅 2 份事故报告 |
| `perf-diagnosis-2026-10-12` | ✗ 无 | — | 仅 report.md |
| `s77-p2-fix` | ✓ | `complete` | worktree wt/s77-p2-fix |
| `skill-audit-20261019` | ✗ 无 | — | 仅 diagnostic-report.md + subagent-state/ |
| `skill-audit-s77-20261019` | ✓ | `complete` | |
| `skill-audit-s77-fix-20261019` | ✓ | `complete` | |
| `task-defect-rrv13-dg12-false-pass` | ✓ | **无 Status 行** | 全文仅 1 处 "status" 字样（非 `**Status:**` 形态） |
| `task-P01-evidence-anchor` | ✓ | `in_progress` | INDEX 标 in_progress |
| `task-skill-audit-20261021` | ✓ | `pending` | **本审计任务本身** |
| `task-v180-scope-contract` | ✓ | `complete` | |
| `task-v181` | ✓ | `complete` | |
| `task-v183` | ✗ 无 | — | **目录完全为空**（`ls -A` = 0 项） |
| `task-v183-verif-closeout` | ✓ | `complete` | 与空的 `task-v183` 并存（同名拆分） |
| `task-v184-proactive-error-review` | ✓ | `complete` | |
| `task-v187-workflow-activation-parallel` | ✓ | `complete` | |
| `task-v188-skill-audit-fix` | ✓ | `in_progress` | |
| `task-v189-skill-audit-deferred-fix` | ✓ | `in_progress` | |
| `task-v190-skill-audit-legacy-fix` | ✓ | `in_progress` | |
| `task-v191-project-audit-sync` | ✗ 无 | — | 仅 delivery-summary.md + subagent-state/ |
| `task-v192-deploy-zcode` | ✓ | **无 Status 行** | |
| `task-v193-skill-goal-drift-fix` | ✓ | **无 Status 行** | 全文 0 处 "status" |
| `verification-upgrade-2026-10-16` | ✗ 无 | — | 仅 report.md |

> 复现：`for d in plans/*/; do [ -f "$d/task_plan.md" ] && grep -m1 -oE '\*\*Status:\*\*[[:space:]]*[a-zA-Z_]+' "$d/task_plan.md"; done`

**汇总**：23 个在途目录 = 16 个有 `task_plan.md` + **7 个没有**；16 个有计划的目录中 **3 个缺 Status 行**（`task-defect-rrv13-dg12-false-pass` / `task-v192-deploy-zcode` / `task-v193-skill-goal-drift-fix`）。合计 **10/23 在途目录缺机器可读状态**。

### 6.2 归档区与索引

| 项 | 值 | 复现命令 |
|----|----|---------|
| `plans/archive/` 归档目录数 | **151** | `ls -1 plans/archive \| wc -l` |
| 其中含 `task_plan.md` 的 | 150 | `find plans/archive -maxdepth 2 -name task_plan.md \| wc -l` |
| `plans/INDEX.md` 是否存在 | ✓ 存在 | `ls -la plans/INDEX.md` → 7 846 B |
| `plans/INDEX.md` 行数 | **46** | `wc -l plans/INDEX.md` |
| `plans/INDEX.md` 表行数（`^\| `） | 16（1 表头 + 1 分隔 + 14 数据行） | `grep -c '^| ' plans/INDEX.md` |
| INDEX 状态分布 | complete 8 / in_progress 4 / pending 3 | `grep '^| ' plans/INDEX.md \| awk -F'|' '{print $3}' \| sort \| uniq -c` |
| INDEX 是否含 archive 条目 | ✗ 不含（设计如此，仅索引在途） | 表头注释「in_progress=中断待续 / pending=未开始 / complete=已完成」 |
| INDEX 生成者 | `sync-todos.sh --index`（自动生成，勿手改） | `plans/INDEX.md:2` 注释 |
| INDEX 最后刷新 | 2026-10-21_14:11 | `plans/INDEX.md:3` |

### 6.3 plans/ 根级其他条目

| 条目 | 性质 |
|------|------|
| `plans/INDEX.md` | 自动生成索引（46 行） |
| `plans/round-retrospective-2026-10-04.md` | 回顾文档 |
| `plans/.active_plan_side/` | 全局活跃计划指针目录 |
| `plans/.plan_required_side/` | 会话私有哨兵目录 |
| `plans/.drift-rhythm/` | 漂移节奏状态 |
| `plans/.zcode/` | 工作区级 zcode 元数据 |
| `plans/.rule-reservations.jsonl` | Rule 编号预留账本（81 行，见 §5.3） |

---

## 7. 三条最值得主进程深挖的结构异常观察

### 异常 1 —— 规则全集计数三处互相矛盾（同一事实有 4 个不同版本）

| 口径来源 | 声明的总数 | 与实况 90 的差 |
|---------|-----------|---------------|
| `plans/.rule-reservations.jsonl` 77/78/79 三条 note（2026-10-16 修正语） | **86 = 14 核心 + 72 卫星** | −4 |
| `skills/task-planner/SKILL.md:9` + `:208`（两处同写"其余 **74** 条已按域迁至上表 11 卫星"） | **88 = 14 + 74** | −2 |
| `skills/task-planner/references/critical-rules.md:191-203` §卫星路由索引（plan-collab-router 行写 "Rule 39,40"） | **89 = 14 + 75** | −1 |
| **实况**（12 个活载体 `^#{2,4} N` 标题去重求和） | **90 = 14 + 76** | 基准 |

- 证据锚 A：`skills/task-planner/references/critical-rules.md:191-203` vs `skills/task-planner/SKILL.md:190-202` — **两张并行路由索引对同一卫星给出不同 Rule 集**（前者缺 91）。
- 证据锚 B：`skills/task-planner/SKILL.md:195` 的 task-discipline 行用区间式 `41-45,53-57,69-76`，其中 **69–76 吞掉了 Rule 75**，而 Rule 75 正文在 `skills/plan-research-router/references/critical-rules-research.md:42`（同时被 `SKILL.md:197` 归给 research）→ **Rule 75 被两行同时认领**。
- 证据锚 C：`skills/task-planner/SKILL.md:9` 与 `:208` 都写"其余 74 条"，但其上方 `:190-202` 表格实际列举 77 个编号（区间展开后），自相矛盾。
- 为什么值得深挖：执行期任何"按 Rule 编号定位规则全文"的派发/校验动作（`selftest-doc-script-paths.sh`、`check-dispatch.sh` 返回契约、`critical-rules.md` 卫星索引）都会因**同一 Rule 号在 3 个载体间归属不一致**而走出不同分支——直接命中"执行产出不稳定"。

### 异常 2 —— Rule 编号账本与规则正文严重脱节，且守护脚本把失配固化成"豁免"

- 3 条规则正文已落地但账本终态仍是 `reserved`：**Rule 57**（`skills/task-discipline/references/critical-rules-discipline.md:278`）、**Rule 80**（`skills/task-planner/references/critical-rules.md:139`）、**Rule 82**（`skills/task-planner/references/critical-rules.md:173`）；账本行：`{"rule": 57, "status": "reserved", ...}` / `{"rule":80,"status":"reserved",...}` / `{"rule":82,"status":"reserved",...}`。
- 1 条规则正文已落地但账本**完全无记录**：**Rule 83**（`skills/task-planner/references/critical-rules.md:181`），`grep -c '"rule": *83' plans/.rule-reservations.jsonl` → **0**。
- 守护脚本把这 3 条明确写成"历史悬空预留（非在途）"豁免：`skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:41` → `EXEMPT_DANGLING=(57 60 80 82)`（同行上方注释"均为历史悬空预留，非在途"）。**注释所述事实（"未 land"）与正文事实（已落地）相反**。
- 为什么值得深挖：`selftest-rule-reserve-pairing.sh` 是**唯一**的编号一致性机器门，它对上述失配返回 PASS —— 意味着"规则已生效但编号体系认为它没生效"的状态被守门脚本制度化保留；后续任何依赖编号账本做冲突检测/新增编号仲裁的动作（`rule-reserve.sh next`）都会给出错误结论。

### 异常 3 —— 技能目录内嵌 23 MB / 1 556 文件 / 557 个 selftest 的 `.backup/` 副本树，且与活树文件名高度重名

- 证据锚 A：`skills/task-planner/.backup/` = 23 MB / 1 556 文件 / 284 054 行（活技能树 299 文件 / 52 596 行的 **5.2 倍行数**），且含 557 份 `selftest-*.sh`（活树仅 92 份）。
- 证据锚 B：该树与活树**同名重名**（例：`.backup/.../claude-code/references/critical-rules.md` 314 902 B vs 活 `skills/task-planner/references/critical-rules.md` 50 541 B；`.backup/.../claude-code/scripts/check-complete.sh` 120 175 B vs 活 149 631 B；`.backup/.../claude-code/scripts/selftest-registry.tsv` 28 361 B vs 活 34 719 B），且含**嵌套二级备份** `.backup/claude-stub-20261012-235503/cursor/.backup/claude-stub-20261009-222907/`（4 份再副本）。
- 证据锚 C：`.backup/` 虽被 `skills/task-planner/.gitignore` 排除（`git ls-files skills/task-planner/.backup | wc -l` → 0），但**部署脚本用全量 rsync 复制技能目录**：`skills/task-planner/lib/install-stub.sh:266-268` → `rsync -a --delete "$src/" "$dst/"`（`src` = 仓内技能目录），`install-stub.sh:232` 的 `find "$stub_dir/scripts"` 亦为全量遍历，无 `--exclude` 命中 `.backup`。
- 为什么值得深挖：**同名不同内容的双份脚本/规则**是"守卫脚本读错版本"与"grep 锚点命中错误副本"的直接成因（仓库自身在 `skills/task-planner/SKILL.md:187` 已记录过一次同类事故："原核心 `references/critical-rules.md` 锚已失效，v171 拆分后 0 命中"）；而 `.backup` 中存在**旧版 check-complete.sh / selftest-registry.tsv / 92 个 selftest**，任何"全仓 grep/find 取脚本全集"的自动化（`run-selftests.sh` 的枚举面、`selftest-doc-script-paths.sh` 的路径断言面）若跨越 `.backup` 边界，会拿到 654 而非 94 个 selftest。

---

## 附：本次盘点使用的复现命令清单（全部只读）

```bash
cd /mnt/data/dev/task-planner-skill
# §0-1 结构与体量
find skills -type f -not -path '*/.backup/*' -printf '%s\t%p\n' | sort -k2
find skills -type f -not -path '*/.backup/*' | while read f; do printf '%s\t%s\t%s\n' "$(wc -l < "$f")" "$(stat -c%s "$f")" "$f"; done
du -sh skills/task-planner/.backup; find skills/task-planner/.backup -type f | wc -l
git ls-files skills/task-planner/.backup | wc -l
# §2 规则载体
find . -name 'critical-rules*.md' -not -path './.git/*' | sort
for f in $(find skills -name 'critical-rules*.md' -not -path '*/.backup/*'); do grep -nE '^#{2,4} [0-9]+' "$f"; done
sed -n '190,203p' skills/task-planner/references/critical-rules.md
sed -n '190,202p' skills/task-planner/SKILL.md
# §3-4 守卫脚本与 selftest
for f in skills/task-planner/scripts/*.sh skills/task-planner/scripts/*.ts skills/task-planner/scripts/*.cjs; do sed -n '1,10p' "$f"; done
find . -name 'selftest-*.sh' -not -path './.git/*' | sort
ls skills/task-planner/scripts/selftest-*.sh | wc -l
tail -n +2 skills/task-planner/scripts/selftest-registry.tsv | cut -f1 | sort -u | comm -13 - <(ls skills/task-planner/scripts/selftest-*.sh | xargs -n1 basename | sort)
# §5 编号索引
grep -rhoE '\bRule ?[0-9]+' --include='*.md' --include='*.sh' --include='*.ts' --include='*.cjs' --include='*.json' . | grep -oE '[0-9]+' | sort -n | uniq -c
cat plans/.rule-reservations.jsonl
sed -n '30,45p' skills/task-planner/scripts/selftest-rule-reserve-pairing.sh
# §6 plans 簿记
for d in plans/*/; do [ -f "$d/task_plan.md" ] && grep -m1 -oE '\*\*Status:\*\*[[:space:]]*[a-zA-Z_]+' "$d/task_plan.md"; done
ls -1 plans/archive | wc -l; wc -l plans/INDEX.md; grep -c '^| ' plans/INDEX.md
```
