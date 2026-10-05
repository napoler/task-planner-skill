# Knowledge Brief — task-v138（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/<task-id>/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

<!-- 填写说明：任务一句话 + 为什么做；下方术语表每条 ≤1 行 -->
## §1 任务速览与核心概念
- 任务一句话：在 task-planner 技能落地 **Rule 55「可复用能力落盘纪律」**（55.1-55.6）+ 固定能力脚本目录与注册表 + 首个实例 `agnes-quota.sh` + 两个生成执行体 SOP 接线 + selftest 守护，全量 selftest 0 FAIL 后合并回 master 并部署 3 宿主实体位。
- 背景/动机：视频创作链中「查剩余生成额度」这类高频操作从未落盘成脚本，执行体每次现场发明「第一次消耗几秒、第二次消耗几秒」的耗时累计推算法，产出完全错误的额度；用户要求常用/可复用功能第一次成功执行即落盘到固定脚本或固定文档，之后一律复用。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| worktree | git 隔离开发区，实现类任务必须在其中开发（宪法 §十一），本任务路径 `/home/terry/task-planner-skill-worktrees/task-v138` |
| capability registry | `references/capability-registry.md`——能力脚本唯一索引（8 列表），下个执行体靠它发现已落盘方法 |
| capabilities 目录 | `scripts/capabilities/`——可复用能力脚本固定落点（`agnes-quota.sh` 为首条），随技能部署位同步三宿主 |
| 权威来源优先 | Rule 55.2：目标事实有 API/官方端点可直查时，禁止耗时累计/抽样估算/记忆拼接等代理推算 |
| 落盘=DoD | Rule 55.3：可复用操作首次正确执行后未落盘 = 任务不完整（写入前先问「它可脚本化吗」） |
| S-unit | Rule 22.6 派发单元，一行 = 一次 `Agent()` 派发，硬限 ≤2 文件 / ≤100 行 / ≤15min |
| parallel_groups | Rule 21.4 声明式并行组；本任务 `[]` 空 = 全部串行（2026-10-02 演进默认） |
| selftest | `scripts/selftest-*.sh` 静态守护脚本；基线 51 个，Rule 55 落地后 52 个 |
| 三宿主部署位 | `~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`（`smart-merge-back.sh` 的 `DEFAULT_DEPLOY_ROOTS`） |

<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实证据列优先填台账路径锚，并保留原文重验锚并列 -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 基线快照：仓 `master@078c683`，selftest-*.sh = **51** 个，`selftest-registry.tsv` = **52** 行（51 条目+表头） | `ls skills/task-planner/scripts/selftest-*.sh \| wc -l` → 51；`wc -l < skills/task-planner/scripts/selftest-registry.tsv` → 52（重测时间 2026-10-05） | Phase 4 S1 全量回归目标总数 = **52**，FAIL 必须 =0；总数以主进程逐脚本 Total 行求和为准 |
| `references/critical-rules.md` = **593 行**，末行为 Rule 53「53.5 机制」行 | `wc -l < skills/task-planner/references/critical-rules.md` → 593；`tail -3` 见 53.5 机制行（重测 2026-10-05） | Phase 2 S1 插入点 = **文件尾**（593 行之后），禁在 53.5 之前插入 |
| `SKILL.md` = **478 行**；Rule 索引 bullet 位于 Rule 49-53 连排段尾部（Rule 53 bullet 之后）；Critical Rules 全集行写「全集 1-53」；References 表 `critical-rules.md` 行写「Rule 53 根源解决与决策管辖」 | `wc -l < skills/task-planner/SKILL.md` → 478；`grep -n 'Rule 5[0-3]' SKILL.md` → Rule 50 bullet / 51 / 52 / 53 各 1 行（重测 2026-10-05） | Phase 2 S2 三处联动：全集行「1-53」→「1-55」、Rules 索引追加 Rule 55 bullet、References 表行内改写（禁净删） |
| Rule 编号账本：46-53 全部 `landed`；**54 = task-v136 `reserved` 未落地** | `plans/.rule-reservations.jsonl`（13 行，末行 `{"rule":54,"status":"reserved","task_id":"task-v136","ts":"2026-10-05"}`） | 本任务 `new_rule: 55`，**禁占 54**（Rule 20.6） |
| `skills/task-planner/scripts/capabilities/` **目录不存在**（首建） | `ls -la skills/task-planner/scripts/capabilities` → No such file or directory（2026-10-05） | Phase 3 S1 需 `mkdir -p` 新建目录后写 `agnes-quota.sh` |
| Agnes Base URL = `https://api.agnes-ai.cn`；`apihub.agnes-ai.cn` 为已知错误域（恒 401） | `~/.zcode/skills/agnes-ai-generation-skill/references/api.md`（design-brief §3.3 引用，2026-10-05 读） | 脚本与探针的 base URL 唯一取该值，禁用 apihub |
| Agnes 已知端点：`POST /v1/videos`（创建）、`GET /agnesapi?video_id=<ID>&model_name=agnes-video-2.5-flash`（查询）、`POST /v1/images/generations`（图像）、图像 `402` = subscription not enabled or quota exhausted | 同上 `references/api.md`（2026-10-05 读） | 这些是**创建/查询单任务**端点，**不等于额度端点**；技能内未记载直查剩余额度的端点 → Phase 1 必须调研确认 |
| 密钥来源：`agnes_api.py` 的 `get_api_key()`（env/配置文件），须同源复用 | `~/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py`（Phase 1 S2 前须确认函数所在行号） | `agnes-quota.sh` 禁硬编码 key（FMEA RPN=120 高风险项） |
| `companion/agents/` 实体清单 = 6：`article-batch-publisher` / `article-field-fixer` / `complex-planner` / `image-generation-executor` / `plan-writer` / `video-generation-executor` | `ls skills/task-planner/companion/agents/`（2026-10-05） | 本任务只改其中 2 个（image/video-generation-executor），禁动其余 4 个 |
| 三宿主部署位 = `~/.zcode` + `~/.claude` + `~/.config/opencode` 三个 `skills/task-planner` | `skills/task-planner/scripts/smart-merge-back.sh:445`（`DEFAULT_DEPLOY_ROOTS` 定义行） | V6 验收 = `smart-merge-back.sh --deploy` 三位逐位 `IDENTICAL`，任一 DRIFT 即 exit 6 |
| Rule 55 机制 = **零新 config 键**（与 43.4/44.4/47.4/52.4 同范式） | design-brief §3.1 第 6 项（55.6） | `config.json` 本任务**零改动**，且 tsv/selftest 登记行末列沿用 `config properties=40` 口径 |
| `selftest-registry.tsv` 列格式 = 4 列：`script` / `domain` / `trigger_scenarios` / `dep_anchors` | `skills/task-planner/scripts/selftest-registry.tsv:1`（表头行） | Phase 3 S3 追加行须 4 列对齐，末列 dep_anchors 写 Rule 55 断言锚（`^55.x` / capability-registry / agnes-quota / scripts/capabilities/） |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；设计插入点+范式锚含时效戳，过期锚须重测 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `skills/task-planner/references/critical-rules.md` | **:593（文件尾）** | Rule 55 插入点=末行 53.5 机制行之后；最新范式块 = `### 53 根源解决与决策管辖`（53.1-53.5），子条范式 = `53.N **动词短语**：正文`（供料 2026-10-05，源=编号账本最大 landed 号 53；行号以实施日重验为准） |
| `skills/task-planner/SKILL.md` | **:304-307** | Rules 索引 bullet 段尾（Rule 50/51/52/53 四条连排）→ Rule 55 bullet 插在 Rule 53 之后（供料 2026-10-05 @078c683） |
| `skills/task-planner/SKILL.md` | **:9 / :267 / :331** | 三处联动锚：:9 Critical Rules 全集行「全集 1-53」；:267 「Rules 1-39（含 Rule 40-53 全集）」；:331 References 表 `critical-rules.md` 行「Rule 53 根源解决与决策管辖」（供料 2026-10-05） |
| `skills/task-planner/scripts/selftest-registry.tsv` | **:1（表头）/ :52（末行）** | 4 列格式；追加第 53 行为 Rule 55 登记（供料 2026-10-05，基线 52 行） |
| `skills/task-planner/scripts/selftest-veto.sh` | **:1-40** | 新建 `selftest-capability-persistence.sh` 的写法范式（断言 + Total 行 + exit 码范式）（供料 2026-10-05） |
| `skills/task-planner/companion/agents/video-generation-executor.md` | **:38-40** | `## 🔒 前置检查（强制）` 段（放行登记/key 核验 HARD_BLOCK 行）→ 复用指向行插入点（供料 2026-10-05，全文 68 行） |
| `skills/task-planner/companion/agents/image-generation-executor.md` | **:38-40** | `## 🔒 前置检查（强制）` 段（输入齐备/key 在位 HARD_BLOCK 行）→ 对称接线插入点（供料 2026-10-05，全文 67 行） |
| `skills/task-planner/references/critical-rules.md` | **:197** | Rule 23.10 独立性四问的「同额度窗口」资源相争条目 → Rule 55.5「当日剩余额度以脚本直查值为唯一取值来源」的衔接面（供料 2026-10-05） |
| `plans/task-v137/task_plan.md` | **:96-123** | 同款 rule-enhancement 计划先例：Phase 标题含 ✅+日期 的 Status 行式、S-unit 7 列表式（供料 2026-10-05 @4bca3dd） |
| `plans/.rule-reservations.jsonl` | **:1-13** | Rule 编号账本；本任务落 land 一行 `{"rule":55,"status":"landed","task_id":"task-v138",...}`（供料 2026-10-05 @078c683） |

<!-- 填写说明：编号清单；末尾挂 FMEA RPN>100 兜底指针 -->
## §4 易错点与禁止假设清单
1. **禁止假设「Agnes 有额度直查端点」**——技能内 `references/api.md` 未记载；Phase 1 必须实调研+实探针取证，查不到就走「端点待确认」PARTIAL 分支，**禁伪造直查成功**（Rule 43.1/51.8）。
2. **禁止硬编码密钥**——`agnes-quota.sh` 必须复用 `agnes_api.py` 的 `get_api_key()` 同源来源；验收 `grep -icE 'sk-[a-z0-9]'` 必须 = 0。
3. **禁止在 critical-rules.md 中间插入或改写既有条款语义**——纯增量追加到文件尾（Rule 36.5）；SKILL.md References 表行内改写是唯一例外，且禁净删。
4. **禁止新 selftest 触碰既有脚本既有断言行**（锚级联防御）——验收含 `git diff --stat` 既有 selftest 零改动。
5. **禁止采信子代理自报 selftest 总数**——总数以主进程逐脚本 `Total` 行求和为准（先例：task-v137 口径）。
6. **禁止修改 `config.json`**——Rule 55.6 零新 config 键承诺。
7. **禁止误占 Rule 54**——54 = task-v136 reserved；本任务 55。
8. **禁止把 `apihub.agnes-ai.cn` 写入脚本/探针**——恒 401 陷阱域。
9. **禁止凭记忆改文件**——本表 §3 行号均为 2026-10-05 @078c683 实测，实施日必须重测（部署位在途写入，锚会漂移）。
10. **禁止 `parallel_groups` 空组被当作可并行**——`[]` = 串行默认，一次只派一行 S-unit（Rule 46.1 单会话单单元）。
11. **禁止只写条款不给执行体挂点**（Rule 53.2 条款死文判例，task-v131 清账）——Rule 55.5 两个 executor SOP 指向行是必需交付物，不是可选优化。
12. **禁止在合并前跳过 v136 冲突复查**——`wt/task-v136`（@4bca3dd，Rule 54）可能在 Phase 5 前推进 master，冲突预期=同区域尾部追加。
- FMEA RPN>100 兜底指针：
  - 端点不可得（RPN=210）→ task_plan.md FMEA 表「Phase 1 / Agnes 无公开额度直查端点」行（22.3 ② 拆细 + ④ 主进程接管，判 PARTIAL）
  - 探针触发额度消耗或风控（RPN=120）→ 「Phase 1 / 探针探到可写端点」行（22.3 ① 改派换策略，立即停探）
  - SKILL.md 行数钉被打破（RPN=108）→ 「Phase 2 / SKILL.md 行数钉」行（22.3 ③ 降档拆细，同任务上调上限并注 task 代号）
  - 脚本硬编码密钥（RPN=120）→ 「Phase 3 / 脚本硬编码密钥」行（22.3 ④ 主进程接管 + D6 硬停点，立即作废重写）
  - 新 selftest 误触既有断言（RPN=112）→ 「Phase 3 / 新 selftest 误触既有脚本断言行」行（22.3 ② 拆细独立成脚本）
  - 合并期 v136 冲突（RPN=120）→ 「Phase 4 / 合并期 v136 已推进 master」行（22.3 ④ 主进程接管 hunk 合流 + 全量回归）
  - 子代理自报总数失真（RPN=140）→ 「Phase 4 / 子代理自报 selftest 总数」行（22.3 ① 改派，主进程求和为准）

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；额外材料路径为台账产物路径，替代 prompt 内联基线 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-S1 web-search-agent（额度端点文档调研） | §1 + §2（Agnes 端点三行）+ §4 第 1/8 条 | `~/.zcode/skills/agnes-ai-generation-skill/references/api.md` + `/mnt/data/dev/task-planner-skill/plans/task-v138/design-brief.md`（§3.3 端点事实段） |
| P1-S2 executor（端点只读探针 ≤3 GET） | §2（Base URL/密钥同源两行）+ §4 第 1/2/8 条 | `/mnt/data/dev/task-planner-skill/plans/task-v138/findings.md`（S1 候选清单落点）+ `~/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py`（`get_api_key()`） |
| P2-S1 executor（critical-rules 追加 Rule 55） | §2（593 行/53.5 尾行）+ §3 第 1 行 + §4 第 3/9 条 | `/mnt/data/dev/task-planner-skill/plans/task-v138/design-brief.md`（§3.1 五子条骨架）+ `skills/task-planner/references/critical-rules.md`（:593 文件尾） |
| P2-S2 executor（SKILL.md 索引三处联动） | §2（SKILL 478 行/三锚）+ §3 第 2/3 行 + §4 第 3/9 条 | `skills/task-planner/SKILL.md`（:304-307 / :9 / :267 / :331）+ `/mnt/data/dev/task-planner-skill/plans/task-v138/task_plan.md`（VC-1 SKILL 判定锚） |
| P3-S1 executor（agnes-quota.sh + capability-registry.md） | §2（capabilities 目录不存在/密钥同源/8 列 tsv 口径）+ §3 第 5 行 + §4 第 1/2/8 条 | `/mnt/data/dev/task-planner-skill/plans/task-v138/findings.md`（P1-探针结论）+ `skills/task-planner/scripts/selftest-veto.sh`（脚本范式） |
| P3-S2 executor（两执行体 SOP 接线） | §2（companion 6 实体）+ §3 第 6/7 行 + §4 第 11 条 | `skills/task-planner/companion/agents/video-generation-executor.md`（:38-40）+ `skills/task-planner/companion/agents/image-generation-executor.md`（:38-40） |
| P3-S3 executor（selftest-capability-persistence.sh + tsv 登记） | §2（基线 51/52 行/4 列格式）+ §3 第 4/5 行 + §4 第 4/6 条 | `skills/task-planner/scripts/selftest-registry.tsv`（:1 表头/:52 末行）+ `/mnt/data/dev/task-planner-skill/plans/task-v138/task_plan.md`（VC-5 断言口径） |
| P4-S1 code-runner-agent（全量回归 52 脚本） | §2（基线 51/52/593/478 四定数）+ §4 第 5 条 | `/mnt/data/dev/task-planner-skill/plans/task-v138/task_plan.md`（VC-5 复验命令全文）+ `plans/.rule-reservations.jsonl`（台账定数锚） |
| P4-S2 code-quality-review（代码面审查） | §4 第 2/3/4 条 + §2（密钥同源行） | `/mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/05-executor-capability-script.md`（P3-S1 diff 摘要） |
| P4-S3 alignment-review（对齐审查收尾） | §1 + §2 + §4 全部 | `/mnt/data/dev/task-planner-skill/plans/task-v138/task_plan.md`（根源覆盖表八工序 ↔ VC 映射） |
| P5 主进程（合并部署簿记） | §2（三宿主部署位/账本两行）+ §3 第 10 行 + §4 第 7/12 条 | `skills/task-planner/scripts/smart-merge-back.sh`（:445 DEFAULT_DEPLOY_ROOTS）+ `plans/.rule-reservations.jsonl` |