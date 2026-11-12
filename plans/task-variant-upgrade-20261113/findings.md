# Findings — task-variant-upgrade-20261113

## §1 统一增量块（文件尾追加，逐字）
```

## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 |  |  |  |  | pending |

## Phases 派发表骨架（S-unit 10 列固定列序——check-plan-dispatch.sh $4/$5/$7/$8 定位，禁增列/禁单元格管道转义；类别=目标列内（An）前缀）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6） | 继承 |  |  | 10min | 1f/10l/10min | 无 | - | pending |

## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（<一句理由>） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | <worktree 分支，合并前可弃> |
```

## §2 处置规则（执行体机械套用）
1. 逐文件先 grep 三件套：`grep -n 'goal-id\|| ID |\|Batch Report' <文件>`——已有者按本条处置，缺者按 §1 块尾部追加。
2. Goal 单元表：已有 goal-id 表但列名「对应 S-unit」缺空格 → 修列名；无 → 追加。
3. S-unit 表：已有但非 10 列（如 rule-enhancement:58 七列）→ **替换**表头/分隔/占位数据行为 10 列新口径（findings §1 第二块）；无 → 追加骨架。
4. Batch：无 → 追加。
5. **追加位置=文件末尾**（最安全锚——本仓 106.1a 教训：禁在既有段落中间插入）；追加前 Read 文件尾 5 行确认结尾形态。
6. mini-lite-type.md / l0-lite-type.md **禁改**（Rule 38.2 白名单：增仪式区块=模板违约）。
7. 每文件改后跑结构回读（106.1a）：`grep -cE '^## |^## 🎯|^## Phases|^## 📦'` 对比改前——只增不减、无重复标题。

## §3 特例
- rule-enhancement-type.md:58 既有 7 列表：替换为 10 列（保留段标题语境，其下若有占位数据行同步替换）。
- 各 variant 既有「验收判据/VC」段语义零改动（verification.md 是共享源已含验证区块，无需 variant 侧补）。

## §4 分组
- 组 A（9）：audio-voice / bugfix / character-design / code-edit / deployment / diagnostic / final-assembly / image / memory-hygiene
- 组 B（9）：migration / motion-camera / multiview-ref / performance-tuning / physics-compliance / prompt-struct / publish / qc-defect / refactor
- 组 C（10）：research / rule-enhancement / schema-migration / script-dev / storyboard / test-writing / video-fix / video-prompt / video / writing
