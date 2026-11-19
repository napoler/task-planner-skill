# S1 独立复检（critic）— Rule 110 落盘

- 对象: skills/task-dispatch/references/critical-rules-dispatch.md:310-329（worktree task-model-tier-dispatch-20261119，基线 79debfa）
- 时间: 2026-11-19
- 只读审查，未修改任何文件

## 判据结论

| 判据 | 结果 | 关键证据 |
|------|------|----------|
| a 逐字忠实（对批准稿） | PASS | knowledge-brief.md:91-110 与实现:310-329 逐行 diff 无差异；md5 双侧同为 881bf19ff02c2a145b00c34e72839295 |
| b 纯增量 | PASS | `git diff 79debfa --numstat` = `21 0`；唯一 hunk `@@ -308,0 +309,21 @@`；1-308 行零删除零改写 |
| c 衔接声明自洽 | PASS | 21.3(:24)、96.2(:211) 与 79debfa 版本 `cmp` 完全一致；110 段 grep `修订/替代/废止/作废/取代` = 0 命中；22.6(:69)/59.1(:157)/59.4(:163)/68.3(:182)/104.2(:267) 均解析成功 |
| d 判例锚真实 | PASS | 见下方一手核对清单，无失真 |

## 判例锚一手核对（d）

1. agent_4224ef20 metadata.json：profileId=article-content-editor、createdAt=2026-11-18T23:25:44.116Z、profileSnapshot.modelSelection={providerId:9e221f47-..., modelId:deepseekv4anthropic/deepseek-v4-pro, reasoningLevel:max} —— 与 110 Why 一致（注：顶层 modelSelection 为 null，模型在 profileSnapshot 内；findings §1.1 的 key 路径表述略粗，实质成立）。
2. agent_4f8cfac1 metadata.json：同模型 deepseek-v4-pro、createdAt=2026-11-14T22:12:56.931Z、description="data 块卫生 109+175" —— 与 Why「同模型执行 data 块卫生比对」一致。
3. task.output:30「词数 1173→1166（-7, -0.60%，≤±15%）」—— 与 Why「-7 词（-0.60%，1173→1166）」逐字一致（1173-1166=7；7/1173=0.597%）。
4. user-session-log.md:44-53 的 ①-⑧ 八步（定位备份 .pre-recheck-886d / 写替换脚本 / raw sha256 双写 / 双文件 content 同步替换 / gate --strict / push posts update / API 回读校验 / per-defect 报告+探针复验）与 Why 括号枚举一一对应，8 步机械 + 1 步文字删句 = 8/9 口径成立。
5. task-plan R3 用户原话「有哪一步是真正的内容创作 完全是被滥用 必须纠正 这种方案导致模型被大量浪费」与 Why 引语逐字一致（user-session-log.md:54 同）。
6. agent-model-tiering.md:3「（2026-08-27 用户确认）」、:18/:20「article-writer 走独立 provider 9e221f47 的 deepseek-v4-pro」「article-writer 契约专用」—— Why「agent-model-tiering 2026-08-27 用户裁决 / deepseek-v4-pro=内容创作契约专用」有源。
7. 临场派发绕过：/mnt/data/dev/article-generation/plans/task-coffee-gate-repair-20261113/task_plan.md grep `886|article-content-editor|继承` = 0 命中，与 findings §1.2 一致。

## 发现（MAJOR 0 / MINOR 3 / NIT 3 / QUESTION 1）

- MINOR-1 :319 vs :211 —— 110.2「创作类→重档合法」而 96.2 重档定义仅「复杂推理/多轮试错型」，未含创作类；属延伸补位而非改写，但 110.7 声称「不改写被引条款判定语义」，严格读者会得"简单创作类不达 96.2 重档门槛"歧义。
- MINOR-2 :315 vs :321 —— 110.1 以「机械步骤占比 8/9 → 判机械类」的占比判类，与 110.3「混合≥2 类必须拆分」存在张力：占比判类可把含创作步骤的单元先贴上机械标签（若拆分未执行，创作步骤将落轻档）。
- MINOR-3 :315 vs :327 —— 110.6 单一判据「仅删除/搬运/校验/格式重排=机械类」未覆盖 110.1 明列的「机械报告汇总」（报告本身是新增自然语言文本），按 110.6 字面可能被判创作类→误升档。
- NIT-1 :323 —— 示例 `cli-executor-agent(mini)` 与该 agent 注册绑定 haiku-1（~/.zcode/agents/cli-executor-agent.md:5；agent-model-tiering.md:10 记载其降至 haiku-1，mini 为最低档）不一致；派发声明可 override，故非事实错误，但示例与注册面不符易误读。
- NIT-2 :319 —— 「禁跨类选档」绝对措辞未就近交叉引用 110.6/22.3③ 失败升档例外，靠后文 110.6 才消解。
- NIT-3 plans/findings.md:51 —— 证据锚 key 路径不精确（modelSelection 实际位于 profileSnapshot.modelSelection，顶层为 null）；结论实质正确。
- QUESTION-1 :325 —— `[tier-class:...]` token 由派发方自填，分类与选档同一主体、无独立校验；110.5 已自披露「零机器面/最小可审计形态」，机器面列待授权，属已披露风险而非隐藏缺口。建议（可选）：token 后附 ≤1 句产出物摘要，提升事后可核对性。

## 总结论

**APPROVED** —— 四条判据全部 PASS；纯增量、逐字一致、衔接自洽、判例锚可一手复现。3 条 MINOR 与 3 条 NIT 均为条款设计层改进建议，不构成本次落盘的阻塞项；其中 MINOR-3（机械报告汇总 vs 单一判据）最值得后续补一句判据适用范围说明。

## 验证摘要

总发现 7 / 已验证 7 / 通过率 100%。已核查未发现问题：110 段无「修订/替代」类措辞；`### 110` 计数=1、`### 111`=0；task-planner/SKILL.md `1-110` 计数=3、`1-109`=0；task-dispatch/SKILL.md 索引表口径「15 条=索引 12 条+96/103/104 三条未入表」自洽；变更文件集与 task_plan CA-1/CA-2/CA-3 一致（3 受管文件，无越界）。范围外观察（不计入缺陷）：critical-rules-dispatch.md:211 行首残留「206<TAB>」为 79debfa 既有文本（cmp 一致），与本次无关。
