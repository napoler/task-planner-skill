# 02-explore-skill-activation — 技能主动激活面盘点与缺口分析

> task-v168 只读调研产出（子代理返回原样落盘，主进程仅追加本节头）。所有锚点均为子代理第一手 grep/ls 复核；引用一律带 file:line。

## 1. 技能库全景

### 1.1 目录统计

| 目录 | 技能目录数（排除非目录文件） |
|------|------|
| `/home/terry/.zcode/skills/` | 130 |
| `/home/terry/.agents/skills/` | 49 |
| **合计** | **179** |

> 注：`.zcode/skills/` 根级有 `SKILL.md`、`CHANGELOG.md`、`references` 三个非技能目录/文件，已排除。

### 1.2 user-trigger-only 技能名单（disable-model-invocation: true）

| 技能名 | 路径 | 行号 |
|--------|------|------|
| comet-any | `/home/terry/.zcode/skills/comet-any/SKILL.md` | `:4` |
| comet-memory | `/home/terry/.zcode/skills/comet-memory/SKILL.md` | `:4` |
| comet-review | `/home/terry/.zcode/skills/comet-review/SKILL.md` | `:4` |

### 1.3 user-invocable: false 技能名单

| 技能名 | 路径 | 行号 |
|--------|------|------|
| sub-agents | `/home/terry/.zcode/skills/sub-agents/SKILL.md` | `:5` |

### 1.5 model-invocable 技能数

- 总计 179 个技能目录；3 个 disable-model-invocation: true；1 个 user-invocable: false
- **model-invocable 技能数: 175**（179 - 3 - 1）

### 1.6 spike 技能

**不存在**。两个目录中均无 spike 技能目录（`ls | grep -i spike` 空输出）。

## 2. 重点技能 frontmatter 实证

- superpowers 族全 13 副本（using-superpowers/brainstorming/systematic-debugging/subagent-driven-development/test-driven-development/executing-plans/writing-plans/verification-before-completion/requesting-code-review/receiving-code-review 等）**均无 disable-model-invocation 声明** → 理论可自动激活，但用户 R5 确认「从未激活过」→ 病灶在无扫描机制而非 frontmatter。
- comet 族 13 个中仅 comet-any/comet-memory/comet-review 声明 disable（各自 :4）；**comet 主入口/comet-classic/comet-native 等 10 个无声明** → Rule 59.3（critical-rules.md:782）把「comet 族」整体归为用户触发型，措辞过宽，与 frontmatter 事实不符（3/13）。
- dogfood（sonnet）/plan-collab-router/agent-optimizer（sonnet）无 disable 声明。

## 3. Rule 59 现行措辞摘录（critical-rules.md）

- :772 注释头（来源 task-v144，判例 R1-R6）；:774 章节标题
- :778 59.1 粒度三值硬门（Nf/Nl/Nmin，check-plan-dispatch.sh/check-dispatch.sh 双 enforce）
- :780 59.2 技能伴飞（S-unit 表「伴飞技能」列；任务书 2 注入 SKILL.md 绝对路径+首动作 Read；>300 行重型技能主进程提炼 ≤20 行内联）
- :782 59.3 执行前技能扫描（计划期扫描技能面 → knowledge-brief「可用强化技能」区四列；**user-trigger 型（comet 族等 frontmatter 声明 disable-model-invocation 设计者）仅提示用户手动激活，禁止主进程/子代理自动代激活**——红线）
- :784 59.4 能力预防判据；:786 59.5 分段执行锚；:788 59.6 机制守护（selftest-subagent-granularity-skill-escort.sh）；:790 59.7 零新 config 键；:792 59.8 与既有 Rules 关系

## 4. check-dispatch.sh 伴飞技能校验逻辑（:566-599）

- 检测序号 7（:74 注释头）：prompt 内「伴飞」关键行提取 .md 路径 token（:580 `grep '伴飞' | grep -oE '[A-Za-z0-9._/-]+\.md'`），逐路径 -f 校验（:588-598）
- fail-closed：路径不存在即短路违规，输出 `[dispatch-guard] Rule 59.2 伴飞路径不存在`（:595）；无「伴飞」声明行 → 跳过（:570）
- 未实例化占位符 `<path>/SKILL.md` 最长匹配得 `/SKILL.md` → -f 必失败 → fail-closed（:574-578）
- **无任何 disable-model-invocation 校验**（gap）

## 5. 现有激活相关机制清单

- 规则：Rule 59.3（:782）、Rule 59.2（:780）、Rule 75 网络调研主动激活（:1008,:1016）
- 模板：knowledge-brief §6 可用强化技能清单（templates/knowledge-brief.md:71-77）；S-unit 表伴飞技能列（templates/task_plan.md:313）；subagent_dispatch.md 伴飞子节（:35-38）
- 脚本：check-dispatch.sh 伴飞路径校验（:566-599）；selftest-subagent-granularity-skill-escort.sh（SG-01..21 静态守护）；SG-15 仅锁 brief §6 段锚存在、**不校验内容非空**（selftest-subagent-granularity-skill-escort.sh:164）
- agent：plan-writer.md:135 brief 五段契约（无 §6 内容非空契约）
- ledger：VALID_EVENTS 无 skill_activation（ledger-append.sh:30）
- zcode cli config.json:160-165 skills 键仅 atomcode/agentcore（enable:false），无白名单/激活配置

## 6. 缺口清单

### P0（机器面完全缺失——R5「从未激活过」直接原因）
1. 无技能扫描脚本（scripts/ 无 skill-scan；59.3 纯 LLM 行为面，critical-rules.md:782）
2. 无技能匹配引擎（任务画像→技能匹配无算法载体）
3. 无技能激活 ledger 事件（ledger-append.sh:30）
4. 无激活 hook（zcode-*.sh 无技能激活钩子）
5. 无技能激活 config 键（config.json 无 skill_activation 键）
6. 59.3 无任何机器守护（selftest 仅锁文本锚）

### P1（设计面缺陷）
7. comet 族 disable 声明不一致：59.3「comet 族」整体归 user-trigger 与实际 3/13 不符
8. knowledge-brief §6 无机器校验（SG-15 仅段锚存在）
9. 伴飞技能列无候选提示（templates/task_plan.md:313）
10. 无技能使用反馈闭环

### P2
11. plan-collab-router / skill-agent-router / dogfood 未被 task-planner 显式消费

## 7. 设计输入结论

1. 新规则要点：Rule 59.9 技能激活留痕（ledger `skill_activation` 事件：技能名/路径/激活方式/触发者）+ 计划期技能扫描 enforce（brief §6 内容非空机器校验）
2. 脚本落点：新增 `scripts/scan-skills.sh`（扫两目录 SKILL.md description + frontmatter → 候选列表四列含 disable 判定）；check-dispatch.sh 伴飞路径校验后追加 disable-model-invocation 校验（enforce 拒锁 auto-activate 型伴飞声明，user-trigger 型只提示）
3. hook 触点：zcode-sessionstart.sh 会话启动检测到计划 → 提示技能扫描 + 输出 brief §6 摘要
4. ledger 事件：`skill_activation`（activation_method = companion_inject / main_call / user_manual；triggered_by = plan-writer / main / subagent）→ 终验可统计激活率验证 R5 消解
5. **红线**：① 禁自动代激活 disable-model-invocation: true 的技能（59.3）；② 禁新增 config.json 键（59.7，档位复用既有三档 off/warn/enforce）；③ 禁修改 superpowers/comet 等技能 frontmatter；④ 59.3 措辞按 frontmatter 事实精确化（comet 族 3/13 → 逐个 frontmatter 判定而非族级一刀切）
