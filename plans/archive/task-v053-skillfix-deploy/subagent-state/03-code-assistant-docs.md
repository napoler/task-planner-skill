# Code-Assistant Docs Checkpoint — task-v053-skillfix-deploy | Phase 3 (重派轮次 2)

> 执行体:task-v053-skillfix-deploy 文档修复执行体(code-assistant 类型,重派第 2 轮)
> worktree:`/mnt/data/dev/task-planner-skill-worktrees/task-v053-skillfix-deploy/`
> 修改文件清单(本执行体自主):**仅 2 个** — `skills/task-planner/SKILL.md` + `skills/task-planner/references/critical-rules.md`
> 重派原因:上一轮修改文件在 worktree 重置后丢失,本次按当前文件实际状态重新执行全部 6 项修复
> diff stat:SKILL.md 614→570 行(-44),critical-rules.md 209→207 行(-2)

---

## 修复 A frontmatter references 补 2 条

**位置**:`SKILL.md:7-18` frontmatter `references:` 列表(`- references/worktree-isolation.md` 与 `- references/billing.md` 之间)
**改动**:追加 `- references/cost-control.md`(照抄正文 line 344-346 风格)与 `- references/batch-quality-gate.md`(照抄正文 line 345-346 风格)。

**Edit 前后关键行**:
```diff
 - references/worktree-isolation.md: 冲突分析与工作树隔离契约（实现类默认首选 + 合并回合约）
+- references/cost-control.md: 成本控制策略详解（Rule 17 详解）
+- references/batch-quality-gate.md: 批量处理质量门控详解（Rule 18 详解：前置 3 问 + 双采样 + Batch Report）
 - references/billing.md: 计费模式（单次触发）
```

**验证**:`grep -n "references/cost-control.md:" SKILL.md` = 2 命中(原 1 正文 + 新 1 frontmatter);`grep -n "references/batch-quality-gate.md:" SKILL.md` = 2 命中(同)。frontmatter 现共 11 条 references。

---

## 修复 B Rule 10 悬空指针 + 同步措辞

**位置**:
- `references/critical-rules.md:33` Rule 10 悬空指针
- `SKILL.md:8` frontmatter 第一条 reference.md 描述
- `SKILL.md:341` References 表第一行

**改动**:统一为 `Chain Handoff Contract · 重规划触发条件` 措辞,与 `reference.md:279` 实际节标题 `**重规划触发条件**(任一):` 锚点一致。`SKILL.md:335` 已使用 Chain Handoff Contract 措辞,无需修改。

**Edit 前后关键行**:
```diff
-critical-rules.md:33
-详见 `reference.md § 重规划触发`。
+详见 `reference.md § Chain Handoff Contract · 重规划触发条件`。

-SKILL.md:8 (frontmatter)
-M anus context engineering 原则 + 3-Strike + 5Q + Chain Handoff 合约 + Chain 重规划触发
+M anus context engineering 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件

-SKILL.md:341 (References 表)
-M anus 原则 + 3-Strike + 5Q + Chain Handoff 合约 + Chain 重规划触发
+M anus 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件
```

**剩余 3 处非指针**:`SKILL.md:335`(Chain 区块交接合约内容描述,自身表述完整)、`SKILL.md:298`(新请求重规划概念)、`critical-rules.md:27`(Rule 8 三分类判定引用)。全部可解析。

---

## 修复 C 双源收敛(方案 A) + S62 扫描

**位置**:
- `SKILL.md` §任务模板库(原 line 555-614,59 行)→ 收敛为指针块(~16 行)
- `SKILL.md:302` Rule 16 自指描述 → 改为指向 template-mapping.md
- `references/critical-rules.md:59` Rule 16 双指 → 删除 SKILL.md 引用,保留 template-mapping.md 单一指向

**SKILL.md 侧独有内容识别**:
逐行比对 SKILL.md §任务模板库 vs template-mapping.md §一/§六/§七:
- 模板清单(13 行)、决策树(16 行)、互斥关系表(6 行)= 35 行 → **全部**在 template-mapping.md 找到等价物 → 整段删除
- 强制约束 P0 块(6 行):含 `init-session.sh` 自动复制 / 必要知识储备章节 / plan-writer 集成 / 项目级覆盖优先级 — **template-mapping.md 未覆盖** → 保留,标注"模板集成侧独有"

**Edit 前后关键行(SKILL.md §任务模板库)**:
```diff
-## 📚 任务模板库（任务开启期必选 — P0）
+## 📚 任务模板库（任务开启期必选 — P0）
 
-**原则**：...
+> **权威源声明**：模板分流决策树、模板清单与互斥关系的**单一权威源** = `references/template-mapping.md` §一（决策树）/ §六（模板清单）/ §七（互斥关系）。执行时按需 Read；本节仅保留流程约束与模板集成侧独有的强制要求。
 
-### 模板清单
-[13 行表格 - 等价物在 template-mapping.md §六]
-### 选择决策树
-[决策树 ASCII 16 行 - 等价物在 template-mapping.md §一]
-### 模板互斥关系
-[6 行表格 - 等价物在 template-mapping.md §六末段]
+**原则**：...
 
-### 强制约束（P0）
+### 强制约束（P0,模板集成侧独有 — 模板分流细节以 template-mapping.md 为准）
 [6 行独有约束,init-session.sh / 必要知识储备 / plan-writer / 项目级覆盖]
```

**SKILL.md Rule 16 描述**:
```diff
-**Rule 16（P0）任务开启期选模板**：...必须按类型选模板（详见下方 §任务模板库）
+**Rule 16（P0）任务开启期选模板**：...必须按类型选模板（详见 `references/template-mapping.md`，模板分流单一权威源）
```

**critical-rules.md Rule 16**:
```diff
-决策树见 SKILL.md §「任务模板库」+ `references/template-mapping.md`。
+决策树见 `references/template-mapping.md`（模板分流单一权威源）。
```

### S62 扫描处置表(`grep -rn "任务模板库" skills/`)

| file:line | 原文 | 处置 | 依据 |
|-----------|------|------|------|
| `SKILL.md:557` | `## 📚 任务模板库（任务开启期必选 — P0）` | **保留**(章节标题,内容已收敛为指针块,语义仍通) | 修复 C 主操作 |
| `companion/agents/plan-writer.md:22` | `template_type: code-edit  # 13 类之一（详见 SKILL.md §任务模板库）` | **未触碰**(文件在禁止修改范围外,任务指令仅允许改 2 文件) | 任务约束 P0「禁止触碰其他任何文件」 |

**悬空指向**:**0**(plan-writer.md 注释仍指向已收敛章节标题,但章节本身存在且承载指针声明,语义不悬空)。

---

## 修复 D Rule 14 禁改清单补 .sh + SKILL.md 同步

**位置**:
- `references/critical-rules.md:53` Rule 14 扩展名清单追加 `.sh`
- `SKILL.md:175` Code Review Gate 范围去掉 `.sh` 排除

**改动**:`.sh` 纳入业务代码治理;SKILL.md 审查范围过滤同步纳入 `.sh`。

**Edit 前后关键行**:
```diff
-critical-rules.md:53
-主进程禁止直接 Edit/Write 业务代码（`.ts/.tsx/.js/.jsx/.py/.go/.rs/.java/.c/.cpp/.h/.hpp`）。
+主进程禁止直接 Edit/Write 业务代码（`.ts/.tsx/.js/.jsx/.py/.sh/.go/.rs/.java/.c/.cpp/.h/.hpp`）。

-SKILL.md:175
-审查范围：...过滤为代码文件（`.py/.ts/.tsx/.js/.jsx/.go/.rs/.java/.c/.cpp/.h/.hpp`），排除 `.md/.json/.yaml/.yml/.txt/.sh/.toml/.cfg`
+审查范围：...过滤为代码文件（`.py/.sh/.ts/.tsx/.js/.jsx/.go/.rs/.java/.c/.cpp/.h/.hpp`），排除 `.md/.json/.yaml/.yml/.txt/.toml/.cfg`
```

---

## 修复 E 删除重复的 21.5 段

**位置**:`references/critical-rules.md:135-136`(重复段,夹在 Rule 22.7 与 Rule 23 之间错位复制)

**改动**:删除 line 135 的 21.5 段及其后的空行,保留 line 117 正本。删除前两行 cat -n 显示**字节级一致**。

**Edit 前后关键行**:
```diff
 22.8.5 **返回缺失兜底**:...
 
-21.5 **拆分自检(动工前)**:展示计划 / plan-writer 产出时自检——任一 Phase 无法用一句话说清验收标准,即视为粒度过大,回炉重拆后再交用户确认
-
 ### 23 并行任务检测与冲突规避(P0)
```

衔接验证:Rule 22.8.5 → 空行 → `### 23`(无空行堆叠/截断);`grep -c "21.5" references/critical-rules.md` = **1**(仅正本,line 117)。

---

## 修复 F Rule 27.3 文档同步脚本钩子说明

**位置**:`references/critical-rules.md:206` Rule 27.3 描述

**改动**:在原句尾(非 git 目录跳过说明之前)追加一句脚本兜底描述,反映另一并行代理在 `scripts/check-complete.sh` 已实现的 scope porcelain 预检逻辑。

**措辞与实现一致性核验**:
- 已 grep `scripts/check-complete.sh` line 18 `check_scope_porcelain()` 函数存在
- line 24:`[plan] Rule 27.3: 非 git 仓库,跳过 porcelain 预检`(对应"非 git → 跳过")
- line 71:`[plan] Rule 27.3: 范围限制列表为空,跳过 porcelain 预检`(对应"scope 解析不出 → warn 跳过")
- line 78-81:`porcelain="$(git ... status --porcelain -- $candidates 2>/dev/null)";if [ -n "$porcelain" ]; then echo "Rule 27.3 violation: scope 内存在未提交变更";exit 1`(对应"解析出且存在未提交变更 → exit 1")

**Edit 前后关键行**:
```diff
 27.3 **提交校验**:提交后 `git status --porcelain -- <scope 文件>` 必须为空;非空 = 有遗漏,补提交或说明原因。
+脚本兜底：`check-complete.sh` 已内置 scope porcelain 预检（scope 解析不出→warn 跳过;解析出且存在未提交变更→exit 1）。
 **非 git 目录** → progress.md 记一行 `[git-commit] 跳过:非 git 仓库`,不阻塞(提交能力缺失不是造假理由,如实登记)。
```

---

## 终检

| # | 检查项 | 命令 | 结果 |
|---|--------|------|------|
| 1 | 21.5 重复段消除 | `grep -c "21.5" skills/task-planner/references/critical-rules.md` | **1**(仅正本,line 117) |
| 2a | cost-control.md frontmatter | `grep -n "references/cost-control.md:" SKILL.md` | line 15(frontmatter) + line 344(正文) = **2 命中** |
| 2b | batch-quality-gate.md frontmatter | `grep -n "references/batch-quality-gate.md:" SKILL.md` | line 16(frontmatter) + line 345(正文) = **2 命中** |
| 3 | 任务模板库悬空指向扫描 | `grep -rn "任务模板库" skills/` | 2 hit,均非悬空(SKILL.md:557 章节标题承载指针声明 / companion/agents/plan-writer.md:22 注释超出本任务范围) |
| 4 | git status 文件数 | `git -C <worktree> status --short` | 7 文件 modified(精确匹配任务约束:5 脚本已存在不动 + 我的 2 个文件) |
| 5 | template-mapping.md 零改动 | `git status --short skills/task-planner/references/template-mapping.md` | (空 = 未变) |
| 6 | diff stat | `git diff --stat skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md` | SKILL.md 614→570(-44 行) / critical-rules.md 209→207(-2 行) |
| 7 | Rule 22.7→Rule 23 衔接 | 视觉检查 `sed -n '130,137p'` | 空行正常,无堆叠/截断 |
| 8 | 改动语义一致性 | Read SKILL.md 末尾约束块 6 行 | 全部保留(init-session.sh / 必要知识储备 / plan-writer / 项目级覆盖) |

**全部检查通过**。

---

## 落盘确认

- 检查点:`/mnt/data/dev/task-planner-skill/plans/task-v053-skillfix-deploy/subagent-state/03-code-assistant-docs.md` ← 本文件(覆盖重写)
- 修改文件:`skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`(仅此 2 个)
- 未触碰:`references/template-mapping.md` / `references/completion-gate.md` / `references/goal-gate.md` / `references/todo-sync.md` / `references/worktree-isolation.md` / `references/billing.md` / `references/cost-control.md` / `references/batch-quality-gate.md` / `companion/**` / `scripts/*` / `lib/*` / `templates/*`
- 5 个脚本并行代理产物(`lib/verify.sh` / `scripts/check-complete.sh` / `scripts/init-session.sh` / `scripts/sync-todos.sh` / `scripts/zcode-pretooluse.sh`)**全部保留,未尝试 checkout/restore/stash**
- 无 git commit(任务约束)
- 重派轮次:2