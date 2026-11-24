# 调研发现（主进程一手证据，待与代理报告合并）

## F1. 无运行时 token/上下文预算机器门（2026-11-24 主进程 grep 实测）
- 命令：`grep -rln 'token.*budget\|context.*budget\|上下文预算\|token_budget\|max_tokens\|上下文窗口\|压缩阈值' skills/task-planner/scripts/ SKILL.md` → **零命中**。
- 含义：当前体系没有"当前会话用了多少 token / 逼近窗口多少 / 主动截断或摘要"的运行时机制。长上下文管理完全依赖：平台被动压缩（hook 检测 compact）+ 人肉规则（Rule 67 四信号自评、Rule 29 文件退场）。
- 注入体量实测：`planctl.py recover-skill` 输出 **62943 字节**（≈15k tok），每次压缩恢复无条件注入。

## F2. 现有"上下文管理"实为文件卫生 + 规则蒸馏，不是窗口预算
- `check-context-hygiene.sh`：只读扫描 findings.md/progress.md 行数（findings>500 行报警、完成 Phase Action>10 行建议折叠），输出 `[context-hygiene]` 建议，**退出码 1/2 但无自动压缩动作**。
- `execution-recall-card.md`（≤120 行）：Rule 93——每 3 S-unit 或 Phase 翻转或压缩恢复后读一次，是规则蒸馏卡，不是会话内容摘要。
- `context-corrector` / `task-drift-guard` / `drift-checker`：处理"语义偏移"（否定/矛盾触发、目标对齐三态判定），不处理"token 体量"。

## F3. 此前取证已知机制（引用，不重复展开）
- 压缩恢复链路已修（无条件注入 SKILL.md 全文，commit 113e5035）。
- 消费断裂历史结论：[[resource-utilization-consumption-anchor-20261123]]——写入门齐备消费门空。
- 9h/54 子代理判例：[[sess-ba603cf5-skill-loop-guard-20261118]]，Rule 96.7 全局预算门。

## F4. 用户早已锚定"短上下文工程"方向——本次诊断的真正命题是"知道但没做到"（主进程 grep 记忆库实证）
- 用户 2026-09-09 原话（`split-before-upgrade-small-steps.md:10`）："**小模型在短上下文和长上下文区别巨大**""一次性分配的任务过大执行过久""子代理完全不需要大模型执行，只要有完整计划小模型也可以做得很好"。已落 Rule 21.1b/22.3②/22.4⑨（步级 ≤2 文件/100 行/15min、prompt ≤3000 字符）。
- 用户 11-15 /goal 锚定（`project-positioning-lowtier-methodology.md:15,17`）：项目三支柱之一="**核心=长上下文数据工程**"，评估任何新机制先问是否服务"低档模型质量稳定/子代理专业分工/长上下文数据工程"。
- 用户 11-15 问题（`task-v195-spec-recall-rule93.md:13`）：长上下文>100-200k 或压缩后规范遗忘；用户否决"每 N 轮全量重载技能文件"（复现膨胀），采纳"计划条目内每 3-5 任务重读规范 + 独立执行规范摘要卡"（execution-recall-card ≤120 行）。
- **诊断命题重构**：不是"没有长上下文方案"，而是三层断裂——① 机制存在但执行层架空（如 auto-tier 修4 前从未触发）；② 只做文件卫生/规则重读，无运行时 token 预算；③ 记录写入齐备但读回消费弱。与 LangChain 类方案的对比应聚焦"它如何把上下文管理变成运行时可观测、可自动执行的流水线"。
