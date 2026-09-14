# Findings & Decisions
<!-- 
  WHAT: Your knowledge base for the task. Stores everything you discover and decide.
  WHY: Context windows are limited. This file is your "external memory" - persistent and unlimited.
  WHEN: Update after ANY discovery, especially after 2 view/browser/search operations (2-Action Rule).
-->

## Requirements
<!-- Captured from user request (2026-09-04) -->
- 用户原始指令：「优化 task-planner 的模板，要求每个模板都添加一个必要的知识储备章节，比如任务相关规范、文档、文献、图书等，便于对齐任务知识库」
- 范围 = templates/ 全部模板（8 主 + 12 variant = 20 个，`ls` 实测；template-guide 旧计数 13/18 为漂移，一并修正）
- 章节内容 = 任务相关规范/官方文档/内部知识库/文献/图书等知识源清单
- 目的 = 任务开启即对齐任务知识库（开工前逐项确认可获取）

## Research Findings

### 结构图谱（Phase 1 grep 实测）

**task_plan 系（13 个，结构对齐）**：
- 主 `task_plan.md`：执行范围限制 → **核心问题定义** → Current Phase → Phases…
- 完整变体 8 个（bugfix/code-edit/deployment/migration/performance-tuning/refactor/schema-migration/test-writing）：执行范围限制 → Current Phase → Phases
- 精简变体 4 个（diagnostic/research/writing/publish）：执行范围限制 → Phases（publish 另有回滚策略/Batch Report/Drift Log）

**辅助模板（7 个，结构独立）**：
- `findings.md`：Requirements → Research Findings → Technical Decisions → Issues → Resources → Visual
- `progress.md`：Session → Test Results → Error Log → 5-Question
- `verification.md`：Goal → VC → Phase Gates → 委派统计 → 质量门控统计 → Goal Gate → 5Q
- `batch_report.md`：单节 Batch Report 表（Rule 18.6 八字段）
- `cost_log.md`：调用记录 → 累计统计 → 节流建议 → 历史对比 → 关联文档
- `notepad-learnings.md`：New Requests → What Worked/Didn't → Files Modified → Verification → Notes for Next Time
- `subagent_dispatch.md`：1目标/2输入/3验收/4禁改/5路径/6时长/7返回格式

### 脚本契约红线（check-complete.sh 实读确认）

- 按**行首 `---`** 分段 → 新章节内禁止出现以 `---` 开头的行（表格分隔行 `|---|` 不受影响）
- 硬解析 `### Phase N:` 与 `- **Status:**` → 新章节禁止使用这两种格式
- Batch Report 八字段 / fan-out Aggregator 校验基于 `##` 标题正则 → 新章节名避开 "Batch Report" 关键词
- check-doc-sync.sh 仅查 mtime；check-complete.sh 不校验模板章节 → 两脚本均无需改动

### 部署形态

`~/.zcode/skills/task-planner/` 为独立目录（非 symlink），SKILL.md 与 verification.md 已落后于仓库 → 仓库为 dev 源，本次以仓库为准；部署（install.sh）交用户后续决策。

## 章节规范（canonical spec — Phase 4 executor 派发依据）

**统一标题**：`## 📚 必要知识储备`（后接括号副标题按模板适配）→ 全库唯一 grep 锚（VC-1）。

**A. task_plan 系 canonical 块**（插入锚点：`## ⚠️ 执行范围限制` 段结束之后、下一 `##` 标题之前；主模板则在「核心问题定义」之前）：

```markdown
## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。
```

**B. variant 类型示例行**（在 A 的表格中追加 1 行示例，空行模板保留）：
- bugfix：`| 官方 Issue/changelog | 上游已知 issue 与版本差异 | URL + issue 号 | 必读 | ☐ |`
- code-edit：`| 上游源码/release | 依赖库源码与 release notes | URL + commit SHA/tag | 必读 | ☐ |`
- deployment：`| 运维 runbook/配置规范 | 部署环境基线与回滚规范 | 内部路径/URL | 必读 | ☐ |`
- diagnostic：`| 审计基线/历史 issue | 既有结论与已知问题清单 | 内部路径/URL | 参考 | ☐ |`
- migration：`| 官方迁移指南 | 框架/语言官方升级文档 | URL + 版本号 | 必读 | ☐ |`
- performance-tuning：`| benchmark 方法论 | 性能测试规范与历史基线报告 | 内部路径/URL | 参考 | ☐ |`
- publish：`| API schema 规范 | OpenAPI/接口契约文档 | URL + 版本号 | 必读 | ☐ |`
- refactor：`| 重构方法论 | 如《重构》Martin Fowler / 团队代码规范 | 书目/路径 | 参考 | ☐ |`
- research：`| 领域权威文献 | 综述/白皮书/竞品公开资料 | URL/书目 | 参考 | ☐ |`
- schema-migration：`| DB 官方 DDL 文档 | 在线 DDL/锁表规范与版本特性 | URL + 版本号 | 必读 | ☐ |`
- test-writing：`| 测试规范 | 测试金字塔/团队用例规范 + 被测设计文档 | 路径/书目 | 参考 | ☐ |`
- writing：`| 风格/SEO 规范 | 写作风格指南与 SEO 基线 + 主题权威文献 | 路径/URL | 必读 | ☐ |`

**C. variant Phase 1 追加 checkbox**（插入该模板 `### Phase 1` 清单末尾、`**Status:**` 行之前）：
`- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)`

**D. 辅助模板轻量适配版**：
- `findings.md`（锚点：`## Requirements` 段后）：`## 📚 必要知识储备对齐记录` + 表（知识源/定位/是否已消费/结论落点段落）
- `progress.md`（锚点：Session 段后、`## Test Results` 前）：`## 📚 必要知识储备使用记录` + 表（Phase/引用知识源/用途）
- `verification.md`（锚点：`## Goal Gate` 标题前）：`## 📚 必要知识储备符合性核验` + 表（必读项/核验方式/结论）
- `batch_report.md`（锚点：文件末尾追加）：`## 📚 必要知识依据（规范对齐）` + 表（规范/文档/遵循要点）
- `cost_log.md`（锚点：`## 关联文档` 标题前）：`## 📚 计费知识依据` + 表（计费规范/成本标准/定位）
- `notepad-learnings.md`（锚点：`## Notes for Next Time` 标题前）：`## 📚 知识储备备注` + 3 行引导（本次新发现的知识源/值得入库的书目文献/待补齐的知识缺口）
- `subagent_dispatch.md`（锚点：`## 2. 输入` 段后）：`## 📚 必要知识上下文包（随 prompt 注入）` + 表（知识源/定位/注入方式：全文摘录 vs 路径引用）

**E. 全局约束（executor 红线）**：只插入不修改既有行；新章节内禁止行首 `---`、禁止 `### Phase`、禁止 `**Status:**`；每处插入 ≤25 行；中文标题+英文括注风格与现库一致。

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| 统一章节名 `## 📚 必要知识储备`（副标题按模板适配） | 用户指令「每个模板」+ grep 可验证(VC-1) |
| 辅助模板用轻量适配版而非同一张表 | cost_log 等数值日志放通用表是噪音;适配版保留"对齐知识库"意图 |
| 仓库为修改基准 | live 副本(~/.zcode)已漂移且落后,仓库是 dev 源 |

## Issues Encountered

| Issue | Resolution |
|-------|------------|
| session-catchup.ts 挂起(>30s) | 终止跳过;新会话无恢复点,哨兵机制正常 |
| plan-created.cjs 报「哨兵不存在」 | 疑被 hook 并行清除;`ls` 确认已清除,门控正常,无影响 |

## Resources

- 模板契约文档：`references/template-guide.md` §四、`references/template-mapping.md` §七
- 校验脚本：`scripts/check-complete.sh`（分段/解析规则）
- 宪法条款：`/home/terry/.zcode/AGENTS.md` §六 保护区、§十一 worktree 路径规范
- critical-rules：Rule 16（模板强制）/ 19（三文件）/ 22（交接）/ 25（委派门控）
- memory：`quality-over-speed-in-skill-enhancement.md`（质量门控+跨文件一致性要求）

## Visual/Browser Findings

（无多模态输入）

## critic 审查结论与裁定（Phase 6,2026-09-04）

### critic 报告（agent_250628e8,verdict=CHANGES_REQUESTED,9 项）
| # | 级别 | 主进程裁定 |
|---|------|-----------|
| 1 | P0 awk 区间解析被截断 | **驳回** — 证据:`git show HEAD:...task_plan.md` + awk 实测,HEAD 基线区间式提取=0(既有 bug);状态机式(check-conflicts/check-drift)HEAD=5/工作区=5 无影响。critic 的"修改前应输出 6"未实测 |
| 2 | P1 guide 契约安全声明不完整 | 采纳 — 改为准确表述(状态机提取机制+安全插入位置) |
| 3 | P1 Rule 16 缺验收命令 | 采纳 — critical-rules Rule 16 补验收锚,mapping §八 补 scope 提取检查命令 |
| 4 | P2 guide §2.2 仍写 13 个 | 采纳 — 改 12 |
| 5 | P2 README 3 处旧计数 | 采纳(B 类扩展,已登记 Decisions) |
| 6 | P2 ARCHITECTURE 旧计数(4 变体) | 采纳(同上) |
| 7 | P2 CHANGELOG "辅助模板"口径 | 采纳 — 改"7 个非 task_plan 模板(4 核心+3 辅助)" |
| 8 | P2 critical-rules "共 13 类" | 采纳 — 改"共 12 类,general 为通用回退"(对齐 init-session.sh VALID_TYPES) |
| 9 | NIT 双空行+batch_report 语义顺序 | 采纳 — 6 文件空行规整;知识依据块上移至 Batch Report 字段区之前 |

### 遗留发现(非本次引入,移交用户决策)
- `zcode-pretooluse.sh:32,37` / `sync-todos.sh:97,180` 的区间式 awk 提取(`/,/^## /`)在 GNU Awk 5.2 下因起始行同时匹配终止模式而恒为空 → PreToolUse 冲突检测的 scope 提取实际失效。属既有 bug,修复需改脚本(超出本任务范围)。
