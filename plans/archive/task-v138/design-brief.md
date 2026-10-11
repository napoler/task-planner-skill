# task-v138 设计简报（plan-writer 唯一需求与设计权威源）

> 供料时间: 2026-10-05 ｜ 基线仓: /mnt/data/dev/task-planner-skill @ master 078c683 ｜ 消费者: plan-writer（写 task_plan.md + knowledge-brief.md）

## 1. 任务一句话

在 task-planner 技能新增 **Rule 55「可复用能力落盘纪律」** + 固定能力脚本目录与注册表 + 首个实例（Agnes 视频额度查询脚本）+ 生成链执行体 SOP 接线 + selftest 守护，根除「高频可复用操作每次现场发明方法（耗时累计推算额度）产出错误结果」的复发性缺陷。

### 用户原始诉求摘要（完整原话见 §2 R 行）

用户在视频创作链（Agnes）中反复观察到：查询视频生成剩余额度这类高频操作从未被落盘成固定脚本；执行体每次现场发明「第一次消耗几秒、第二次消耗几秒」式耗时累计推算法，产出完全错误的额度结果。要求：常用/可复用功能第一次成功执行即落盘到固定脚本/固定文档，之后一律复用。

## 2. 用户需求原文（R 行 — Rule 51.1 逐条抄录，plan-writer 原样入计划 🎯 区块，禁转译/缩写/合并）

- **R1**: 「我希望可以在我的该技能中，确保就是常用的功能、可复用的功能及时落盘到一个固定的脚本或者固定文档中」
- **R2**: 「确保后期不会重新再执行一遍弱智的功（能）」——落盘之后必须复用，禁止每次重复现场发明临时方法
- **R3**: 「像获取视频额度、视频剩余视频生成剩余额度，这种非常常用的功能……正常应该是直接通过API继续获取……他做的时候是每次将莫名其妙，第一次消耗了几秒，第二次消耗了几秒，然后统计出来，最终产出的结果就是一个莫名其妙的完全不对的结果」——权威 API 直查优先，禁止耗时累计类代理推算
- **R4**: （复述确认范围）机制落在 task-planner 技能体系=通用执行纪律（覆盖一切任务链），视频额度查询为其首个落盘实例；非仅视频个案补丁

## 3. 设计方向（已定稿，plan-writer 据此成文，不得另起炉灶）

### 3.1 Rule 55 条款骨架（五子条 + 机制，纯增量追加）

- **55.1 复用前置检查**：执行任何「可复用操作」前必查能力注册表 + 固定脚本目录。可复用操作判别特征（满足其一）：① 查询类外部事实（额度/余额/配额/剩余量/状态）；② 已重复 ≥2 次或可预见重复的固定多步流程；③ 存在权威数据源的操作。命中既有脚本 → 直接复用，禁止现场重新实现。
- **55.2 权威来源优先禁令**：目标事实存在权威直查来源（API 返回字段/官方端点）时，禁止以间接推算产出该事实——耗时累计反推、抽样估算、上下文记忆拼接等代理方法一律禁止；仅当权威来源经查证确认不可得后才允许推算，且结论必须标注「推算值+方法+未验证」。与 Rule 43.1（未验证登记）、54.1（资源状态第一手验证）同面衔接。
- **55.3 首次成功即落盘**：可复用操作第一次以正确方法成功执行后，执行体必须**当次**落盘：① 可脚本化 → 脚本入 `scripts/capabilities/`（What+Why 注释完整，Rule 45）；② 注册表登记（见 55.4）；③ 纯知识形态（无脚本价值）→ 入 references/ 固定文档。落盘是任务 DoD 的一部分：已成功执行可复用操作而未落盘 = 任务不完整。
- **55.4 固定位置与格式**：脚本=`skills/task-planner/scripts/capabilities/`；注册表=`skills/task-planner/references/capability-registry.md`（唯一索引，表格行：名称|脚本路径|用途|调用方式|数据来源端点|输出形态|verified 日期|任务来源）；随技能部署位同步到三宿主。
- **55.5 执行体接线**：image-generation-executor / video-generation-executor 的 SOP 必须包含额度查询复用指向行；Rule 23.10 的「当日剩余额度」约束以脚本直查值为唯一取值来源，禁止执行体内自行估算。
- **55.6 机制**：零新 config 键；`selftest-capability-persistence.sh` 静态守护；与 Rule 34.3（模板沉淀）并行不冲突（模板=方法论文档，能力=可执行脚本）；不改 22.3.0/41/54 既有语义。

### 3.2 实施落点（scope 文件清单，全部在 worktree 内操作，相对 skills/task-planner/）

1. `references/critical-rules.md` — 文件尾（现尾锚 53.5 之后）纯增量追加 Rule 55 全文
2. `SKILL.md` — Critical Rules 索引追加 Rule 55 一行（纯增量；References 表 critical-rules 行的「含 Rule 53」措辞若需提及 55 则行内改写，禁净删）
3. `scripts/capabilities/agnes-quota.sh` — 新建（首个能力脚本，bash+curl，密钥复用 agnes_api.py 同源，禁硬编码）
4. `references/capability-registry.md` — 新建（注册表，首条=agnes-quota）
5. `companion/agents/video-generation-executor.md` — SOP 追加额度查询复用指向行（纯增量）
6. `companion/agents/image-generation-executor.md` — 同上（若 Phase 1 确认端点为账户级则对称接线；仅视频级则只改 video 并登记理由）
7. `scripts/selftest-capability-persistence.sh` — 新建守护脚本（只断言新增锚，禁碰既有脚本断言，防锚级联）
8. `scripts/selftest-registry.tsv` — 追加一行登记（格式对照现有行）

### 3.3 Agnes 端点事实（Phase 1 调研的已知输入）

已验证（源：`~/.zcode/skills/agnes-ai-generation-skill/references/api.md`，2026-10-05 读）：
- Base URL: `https://api.agnes-ai.cn`（`apihub.agnes-ai.cn`=已知错误域恒 401）
- 视频：`POST /v1/videos`（创建）、`GET /agnesapi?video_id=<ID>&model_name=agnes-video-2.5-flash`（查询）
- 图像：`POST /v1/images/generations`；`402` = subscription not enabled or quota exhausted
- **技能内未记录直查剩余额度的端点** → Phase 1 必须调研：① wiki.agnes-ai.cn 官方文档（网络调研）；② OpenAI 兼容 billing 端点家族（如 `/v1/dashboard/billing/subscription`、`/v1/dashboard/billing/usage`）一次只读探测（GET ≤3 个，最小探针原则 35.6）
- 密钥来源：读 `~/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py` 的 `get_api_key()` 确认同源（env/配置文件），探针与最终脚本必须复用同一来源，禁硬编码密钥
- **探测失败兜底**：穷尽官方文档+兼容端点后仍不可得 → 脚本落盘为「错误处理已验证+端点待确认」形态，V2 判 PARTIAL 显式登记，禁止伪造直查成功

### 3.4 台账供料（21.2.1 — 以下定数 plan-writer 必须从台账/重测取得并入 knowledge-brief §2/§3/§5，禁止凭记忆内联重建）

- 编号账本: `plans/.rule-reservations.jsonl`（46-54 已占用，54=task-v136 reserved 未落地 → **本任务 new_rule: 55**）
- selftest 基线: `scripts/selftest-*.sh` = **51 个**；`scripts/selftest-registry.tsv` = 52 行（51 条目+表头）（2026-10-05 @078c683 实测，plan-writer 可重测带时效戳）
- 行数定数: `references/critical-rules.md` = 593 行（尾锚 53.5 机制行）；`SKILL.md` = 478 行（2026-10-05 实测）
- companion/agents 实体清单: article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / plan-writer / video-generation-executor（共 6）
- 模板先例: `templates/variant/rule-enhancement-type.md`；同款计划先例 `plans/task-v137/task_plan.md`

## 4. Phase 骨架（建议 5 Phase，plan-writer 细化为 S-unit 表，每行 ≤2 文件/≤100 行/≤15min）

- **Phase 1 调研与端点确认**：S1 网络调研 wiki.agnes-ai.cn（web-search-agent, mini，≤3 query）；S2 只读端点探针（executor, sonnet-1，GET ≤3 个+原始响应落盘 findings）→ 结论：端点可用/不可得
- **Phase 2 条款与索引落地**（executor, sonnet-1）：S1 critical-rules.md 追加 Rule 55 全文；S2 SKILL.md 索引行追加
- **Phase 3 能力脚本与接线**（executor, sonnet-1）：S1 agnes-quota.sh + capability-registry.md 首条；S2 两 executor SOP 接线行；S3 selftest-capability-persistence.sh + registry.tsv 登记
- **Phase 4 回归与双审查**：S1 code-runner-agent 跑全量 selftest（目标 52 个 FAIL=0）；S2 code-quality-review；S3 alignment-review（42.6.2 标准收尾）
- **Phase 5 终验合并部署簿记**（主进程白名单①②）：smart-merge-back --deploy、rule-reserve land 55、INDEX/ledger、memory 更新、delivery-summary

## 5. 验收骨架（VC 方向，plan-writer 成表并附可复验命令）

- V1: Rule 55 五子条在 critical-rules.md（grep 锚 ^55.1..^55.6）且 R1-R4 映射完整
- V2: agnes-quota.sh 存在+`bash -n` 通过+（端点确认时）实测返回结构化额度
- V3: capability-registry.md 首条字段完整（8 列）
- V4: video-generation-executor.md（及 image 若对称）含复用指向行（grep 锚）
- V5: 全量 selftest FAIL=0（51+1=52）
- V6: 三宿主部署同步 diff=0；合并回 master 后 Read 复验关键文件

## 6. 风险与硬约束（plan-writer 写入计划约束区）

- **v136 worktree 在途**（wt/task-v136 @4bca3dd，Rule 54 预留未实施）→ 本任务纯增量+追加锚=文件尾；合并回前复查 v136 是否已动 master；冲突预期=同区域追加，行内协调
- **纯增量纪律（36.5）**：禁改既有条款语义；新 selftest 只断言新增锚
- **锚级联防御**：新增断言禁触碰既有脚本既有断言行
- **密钥安全**：脚本禁硬编码 key
- **Rule 45 注释完整性**：脚本与条款 What+Why 双层注释
- **交互模式**：`interaction_mode: silent`（无人值守会话+用户指令明确；Decisions Made 预登记 `silent:` 行，交付附静默决策清单）；D6 硬停点语义不变
- **frontmatter**：`template_type: rule-enhancement` / `new_rule: 55` / `isolation: worktree` / `code_review: required` / `parallel_groups: []`（未声明组=串行默认）
- task_plan.md 末尾 init-session 已追加的「🔁 模板感知」区块须保留：本任务命中既有 variant（rule-enhancement），登记无需新沉淀
