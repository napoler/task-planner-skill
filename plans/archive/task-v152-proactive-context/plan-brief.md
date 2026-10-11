# Plan Brief — task-v152-proactive-context（plan-writer 任务书）

> 消费方式：先 Read 本文件全文 + knowledge-brief.md + findings.md，再 Read 拆分模式库，然后产出 task_plan.md。
> 本文件是任务书权威源；与 kb/findings 冲突时以本文件为准。

## 一、用户需求原文（Rule 51.1 逐字抄录，禁转译/缩写/合并）

- **R1**: 「优化当前的技能，加入一个，就是说主动，在遇到上下文过长，或者说出现就是出现混乱的时候，我希望可以进行主动地进行压缩，或者说是整理优化。就是类似的方式。」<sub>（[目标]）</sub>
- **R2**: 「如果实在是解决不了，也可以撰写交接文档，要求在新的会话中开启。」<sub>（[目标]）</sub>
- **R3**: 「核心就是主动评估、主动优化。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-4 | 新 Rule 条款含主动评估触发+PRESSURE 压缩动作原文（grep 锚）；评估三态 verdict 定义在位；hook 节奏提醒实弹可见 |
| R2 | VC-3, VC-4 | templates/session-handoff.md 五段模板在位+条款规定穷尽后必写+新会话恢复链指引；CONFUSED→交接路径条款原文 |
| R3 | VC-1, VC-5 | 「主动评估」「主动优化」关键词入条款；全 selftest 回归 FAIL=0 基线零新增 |

## 二、已定设计方向（写入计划，不重新设计；细节措辞留给执行期条款撰写）

新增 **Rule 67「上下文压力主动评估与会话交接纪律」**（编号 67 已避让并行 task-v151 占用的 66；账本实测 65 landed、66/67 空闲）：

- **67.1 主动评估触发（三档）**：① 节奏档=借 posttooluse 既有 drift-rhythm 计数（N，env 可调）注入评估提醒 ② 事件档=连续失败 ≥2 / drift 判 DRIFT / harness 压缩（compaction）发生后恢复点 ③ 高危信号档=periodic-review 判 CONTRADICTION、同一文件反复改、Todo 与计划失同步
- **67.2 三态 verdict**：HEALTHY（继续）/ PRESSURE（触发主动压缩整理）/ CONFUSED（触发交接兜底）；评估动作=按信号清单自评（工具调用轮数、计划三文件行数与陈旧度、重复失败次数、结论矛盾数）
- **67.3 PRESSURE→主动压缩整理**：复用 Rule 29.2/29.3 SOP（superseded 标记/折叠/指针制/蒸馏 kb），语义升级=**不等 Phase complete，命中即执行**
- **67.4 CONFUSED→会话交接文档**：22.3 五档穷尽仍失败或无法确定当前状态 → 按新模板 `templates/session-handoff.md`（五段：目标锚/已完成与证据/当前断点/未决问题/新会话恢复指令）落盘，登记 Decisions Made+progress，恢复链=session-catchup → 四文件读序（Rule 62.1）→ plan-resume（Rule 24.5）
- **67.5 hook 承载**：`scripts/zcode-posttooluse.sh` 既有 drift-rhythm 节奏块内追加单行评估提醒（env 降档默认可关）；**不改 /home/terry/.zcode/cli/config.json**
- **67.6 机制**：零新 config 键（env 降档，先例 Rule 64.5/64.6）+ 新 selftest `scripts/selftest-context-pressure.sh` + `selftest-registry.tsv` 加行 + SKILL 合规清单新条目 C45 + SKILL.md 「Critical Rules 1-65」三处级联 1-67

## 三、硬约束（计划必须体现，违者验收 FAIL）

1. `template_type: rule-enhancement`（白名单实值无 -type 后缀——v150 判例）
2. `new_rule: 67` / `interaction_mode: ask` / `plan_tier: standard` / `code_review: required` / `session_id: 4ec328fb-b4fa-4c4d-b8aa-49ed84a9d2aa`
3. **零新 config 键**（config properties=42 被多 selftest 钉死）——任何开关走 env 降档
4. SKILL.md :9, :280, :360 三处「Critical Rules 1-65」→ 1-67 级联（+references 表 Rule 行）
5. selftest-registry.tsv 4 列 63 行基线；新 selftest 必加行（selftest-registry T02-T05 + SR-12 行数断言自动跟随）
6. 并行 v151 会话在 `wt/v151-goal-mode` 改同批文件 → 本任务 worktree 从 master 建，合并冲突预期=文尾 Rule 追加点/SKILL 计数行并集解

## 四、🔀 隔离决策区块内容（check-conflicts.sh 实测 2026-10-09 19:36）

- 信号① 未提交变更 3 文件：`M plans/.active_plan`、`?? plans/task-v151-goal-mode/`、`?? plans/task-v152-proactive-context/`
- 信号② 额外 worktree：`/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode [wt/v151-goal-mode]`
- 信号③ 遗留 wt 分支：`wt/v151-goal-mode`
- 信号④/⑤：无
- **决策：worktree 隔离（默认首选，宪法 §十一 保护区命中）**；worktree_path=`/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context`（Phase 2 从 master 创建）；计划文档留主仓 plans/

## 五、scope_files

```
skills/task-planner/references/critical-rules.md
skills/task-planner/SKILL.md
skills/task-planner/templates/session-handoff.md（新）
skills/task-planner/scripts/zcode-posttooluse.sh
skills/task-planner/scripts/selftest-context-pressure.sh（新）
skills/task-planner/scripts/selftest-registry.tsv
```

## 六、询问点（Rule 44 自动超时默认项，登记「自动超时默认项」行）

- **D1**: 默认=批准计划+worktree 隔离 / 超时 5min
- **D2**: 默认=新 Rule 67 形态（vs 扩展 Rule 29 子条）/ 超时 5min —— 理由：能力三段（评估/压缩/交接）超出 Rule 29「多→退场」语义；67 空闲
- **D3**: 默认=hook 接线纳入本期（vs 纯规则层、hook 推后）/ 超时 5min —— 理由：无 hook 承载=纯 LLM 自律（Rule 65 同款空白），主动性不可靠

## 七、Phase 结构建议（可优化，每 Phase 必有 `**Executor:**` 字段，主进程直做须引 Rule 25.3 白名单例外理由）

1. **Phase 1 设计定稿**：条款文本草案+session-handoff 模板草案+hook 接线方案 → `design-draft.md`（计划目录）；过 C24/C36（Rule 36 删除基线=纯增量无删除）
2. **Phase 2 worktree 创建**：`git worktree add` + 关键文件与 master 一致性核对（memory 判例：worktree 分支不同步）
3. **Phase 3 实施**（worktree 内，拆 S-unit）：3a 条款+SKILL 级联（critical-rules.md + SKILL.md）；3b 新模板 session-handoff.md；3c hook 接线+selftest+registry 加行——文件集互不相交可评估并行（Rule 21.4 四问，声明 parallel_groups 才并行，未声明=串行）
4. **Phase 4 验证**：新 selftest PASS + 全量 selftest 回归 FAIL=0（基线 63 脚本）+ hook cadence 实弹冒烟（触发一次提醒观测）
5. **Phase 5 终验**：逐 VC 复验 → Code Review Gate（重 diff 多轮）→ alignment-review 收尾（42.6.2）→ `smart-merge-back.sh --deploy` 合并对账（部署位 diff=0）→ rule-reserve land 67 → 交付总结五要素

## 八、必备区块清单（缺一=计划无效）

🎯用户需求原文（R1-R3 逐字+R→VC 映射）、🧮根源覆盖表（53.1）、Verification Contract VC 表、FMEA 预演、🔀 隔离决策、🧰 工具选择与编排（Rule 40.2 逐 Phase 工具面+判定行）、Decisions Made 种子行（67 避让 66 / 零新键 env 降档 / worktree / 双 sid 指针对齐 / 侦察走 Explore agent_9c951ea4）、Code Review 配置表、S-unit 表（22.6：执行体/伴飞技能/Nf/Nl/Nmin 三值列/单元组标记）、Subagent Handoff 登记表（补登侦察行 agent_9c951ea4，status=complete）、自动超时默认项行、plan_tier: standard、frontmatter `parallel_groups`（若 P3 宣并行）。

## 九、返回契约（8 字段）

`status` / `plan_path` / `phase_count` / `s_unit_count` / `plan_lines` / `key_decisions` / `open_risks` / `checkpoint`

> 三文件单写者约束：你只写 task_plan.md；findings.md/progress.md 由主进程回填。
