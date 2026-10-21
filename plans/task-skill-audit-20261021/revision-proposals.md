# 修改方案（逐条可执行提案）— task-planner-skill 审查

- 依据报告：`plans/task-skill-audit-20261021/audit-report.md`（发现编号 A-/B-/C-/G-；S9 补强方向 D-01~D-14 为独立编号空间，与报告缺口编号 G-01~G-05 不同义，两套编号不可混用）
- 适用铁律：Rule 74 三判门（**增量默认 / 替代四条件 / 删除需逐项授权**）；宪法 §六（技能与指令文件为保护区，逐项授权）+ §十一（实现类必须 worktree 隔离）
- **本方案只出提案，不执行**。执行需另开任务：① 取得用户逐项授权 ② `git worktree add /home/terry/task-planner-skill-worktrees/<task-id> -b wt/<task-id>` ③ 在 worktree 内改 + 跑 selftest ④ 合并回 master ⑤ 同步 4 个部署位
- 编号规则：`RP-xx` = 提案；变更类型栏必须写「增量 / 替代 / 删除」；**替代**必须附四条件逐条是否成立；**删除**必须标注「需用户逐项授权」
- 执行顺序建议：**P0-① → P0-② → P0-③ → P1 → P2**（P0-① 是根因通道；P0-③ 未落地则前面全部不生效在真实会话）

---

## 一、P0-① 生效通道（直接堵 R3 案例的 skill 侧根因，4 条）

| 编号 | 对象（文件+锚点） | 变更类型 | 优先级 | 执行动作 | 依据 |
|------|------------------|---------|--------|---------|------|
| RP-01 | `skills/task-planner/SKILL.md` 卫星路由表 task-discipline 行（SKILL.md:195） | 增量 | P0 | 在卫星路由表中为 `task-discipline` 行**新增调用条件关键词**：「资源/额度/配额/重置时间/排期推迟/阻塞原因声称」——命中即必须 Read `../task-discipline/references/critical-rules-discipline.md` 的 Rule 54.1②/54.2/54.3/54.4；同时在 SKILL.md 常驻段加一行指针：「凡将断言『当下不可执行/资源不足/需等待』时，先取一手查询记录」（不改既有条目，纯追加） | G-02(P0)：Rule 54 文本在 `critical-rules-discipline.md:235,237,239,241` 且逐句覆盖本案，但 SKILL.md grep「额度/配额/资源状态/推迟/一手证据」= 0 命中、卫星路由表 SKILL.md:195 调用条件无触发词 → 主进程无从知道该 Read |
| RP-02 | `skills/task-discipline/references/critical-rules-discipline.md` Rule 54 段 | 增量 | P0 | 在 54.x 增补两条可判定条款：①**证据时序判据**——凡「以资源/时间不足为由推迟或整体押后」的结论，档案中须存在**时间早于该结论的一手查询记录**（额度面板/账本/mtime/API 返回），否则结论不得成立；②**措辞区分判据**——区分「事实断言（额度已耗尽）」与「策略选择（按规则降级或排次日）」，二者须分别标注，禁止用前者措辞表达后者 | G-02(P0) + G-03(P0)：现体系无任何时序判据；本案 198/302s 证据在 23:03:58/23:25:12，均早于 23:30:54 的断言，却无处消费 |
| RP-03 | `skills/task-planner/references/critical-rules.md` Rule 71.2（五问的写入面枚举，`:424` 附近）+ Rule 74.2(a) | 增量 | P0 | ① Rule 71.2 的**写入面枚举补入**「项目宪法/指令文件（AGENTS.md 等）、规则文件、经验档、判例登记」——使其进入五问范围；② Rule 74.2(a)「增量默认」增补**例外**：写入对象为宪法/规则/经验档且内容含事实性断言时，即便走增量也须附一手证据锚，无锚即回退「待验证」标记 | G-03(P0)：固化通路 9 环节拦截率 0/9；本案 `videop1/AGENTS.md:84` 的反例判例正是「增量默认 + 事后定性」双条件下的零阻力写入 |
| RP-04 | `skills/task-planner/scripts/check-complete.sh`（`:1736` 消费点 / `:1747` 匹配式）+ `skills/task-planner/templates/task_plan.md`（`:502` Handoff 表头列定义；`:497` 为列说明句） | 增量 | P0 | ① 修 `templates/task_plan.md:502`（Handoff 表头行）：把「备注(rescue/retry/verify_done)」中的 verify_done **拆为独立列**（或把脚本匹配改为兼容折叠列名）；同时**修正模板内事实错误**「verify_done 无机器消费（grep 实证…零命中）」（写在 :497 列说明句）→ 更正为「由 check-complete.sh:1736 与 auto-finalize.sh 消费」；② 脚本侧：列位探测为空时**由 fail-open 改为 fail-closed 告警**（至少输出 WARN 并计入违规），禁止静默跳过 | G-01(P0)：模板折叠列 vs `v=="verify_done"` 精确匹配 → 生产静默失效；selftest 夹具用 10 列裸列故套件全绿（S7 verified） |

---

## 二、P0-② 守卫有效性（「假 PASS」簇，7 条）

| 编号 | 对象（文件+锚点） | 变更类型 | 优先级 | 执行动作 | 依据 |
|------|------------------|---------|--------|---------|------|
| RP-05 | 20 个使用 `1-[89][0-9]` 宽锚的计数断言脚本（含 `selftest-absorption-discipline.sh:85-96`） | 替代 | P0 | **替代**四条件核对：①旧锚确被证伪（实测「Rules 1-80」亦 PASS，计数面 100% 失效）✓ ②新锚完整覆盖旧场景（改为「上界随账本/正文实测动态取值」或精确区间枚举）✓ ③已 Read 旧内容全文 ✓ ④替代后 selftest 全绿——**第四条需在 worktree 内实测后确认**，未达成则回落增量（先加告警再收紧） | A-01(P0) verified |
| RP-06 | `skills/task-planner/scripts/selftest-verification-gate.sh:73` | 增量 | P0 | 把恒真断言 `-ge 0` 改为真实判据（如「命中数 ≥ 期望下界」），并补一条负断言夹具：构造 0 命中场景必须判 FAIL | A-06(P0) verified |
| RP-07 | `skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:41`（`EXEMPT_DANGLING=(57 60 80 82)`） | 替代 | P0 | **替代**四条件核对：①正文已落地、账本停 reserved=失配被当 PASS（证伪成立）✓ ②新判据完整覆盖旧场景（改为「账本终态与正文存在性**双向**对账」）✓ ③已 Read 旧内容 ✓ ④替代后 selftest 全绿——**需 worktree 实测**；实施前先补 landed 行（RP-17）再收紧豁免表，否则收紧即假 FAIL | A-04/B-01(P0) verified |
| RP-08 | `skills/task-planner/scripts/check-dispatch.sh:126` | 增量 | P0 | 派发端字段校验由 3 字段（status/acceptance/checkpoint）扩为 8 字段全集，与 `critical-rules-dispatch.md:60`（22.4b）及 `check-subagent-return.sh:24` 对齐；补差集守卫测试：缺任一字段必拦 | C-01(P0) verified |
| RP-09 | `skills/task-planner/scripts/check-dispatch.sh:202-208`（返回格式段门） | 增量 | P0 | 段门判定改为**语义锚定**（按内容特征匹配，不依赖 `## 7.` / `### 7.` 标题形态）；缺失 `confidence:` 不得 exit 2 误拦合规派发，缺字段改为**明确区分「污染 prompt」与「字段缺失」两条路径** | C-02(P0) verified（行为实测 rc=0 / rc=2） |
| RP-10 | `skills/task-planner/scripts/check-dispatch.sh:580,592`（伴飞门）+ `skills/task-planner/templates/subagent_dispatch.md:38` | 增量 | P0 | 伴飞技能路径抽取改为「跳过占位标签（`{…}`/`<…>`）后再 `-f` 校验」；模板占位写法与脚本抽取口径**同步**（二者择一为准，另一方对齐） | C-03(P0) verified（行为实测误拦） |
| RP-11 | `skills/task-planner/scripts/check-subagent-return.sh:51`（status 值域） | 增量 | P0 | `status` 值域补入 `blocked`（与 `templates/task_plan.md:496` 的 Handoff 状态枚举对齐）；`acceptance` 增补值域判据（现无值域判据，S7 措辞修正） | C-04(P0) verified（`blocked` rc=1 误拦 / `failed`+`blockers:none` rc=0 误放） |

---

## 三、P0-③ 部署与在途（不落地则前两组修复不生效，3 条）

| 编号 | 对象（文件+锚点） | 变更类型 | 优先级 | 执行动作 | 依据 |
|------|------------------|---------|--------|---------|------|
| RP-12 | 4 个部署位（`~/.zcode` / `~/.claude` / `~/.cursor` / `~/.opencode` 的 `skills/task-planner/`） | 替代 | P0 | **替代**四条件核对：①旧版本已被证伪（现行加载位缺 Rule 93 全套，落后 19~47+ 提交）✓ ②新版本完整覆盖旧场景（全量同步含在途 3 文件）✓ ③已逐位 diff 现状 ✓ ④同步后 selftest 四位 IDENTICAL——**需 worktree 实测**；同步前须由用户授权（部署位属运行中基础设施） | B-03(P0) verified；G-04(P1)：缺 Rule 93 恰是本案「长会话末段规范衰减」场景 |
| RP-13 | `skills/task-planner/scripts/selftest-doc-script-paths.sh --deploy` | 增量 | P0 | 由 report-only（exit 0）改为**可阻断**：部署位与源侧关键文件集（SKILL.md / references / scripts / config.json）不一致即 exit 2（enforce 档），并纳入 check-complete | B-03(P0) verified：唯一 deploy 感知门不阻断 |
| RP-14 | 主仓在途未提交 3 文件（`skills/task-planner/SKILL.md`、`references/critical-rules.md` 新增 Rule 51.9–51.13、`scripts/selftest-requirement-coverage.sh` 新增 RC-24 断言）+ `plans/.rule-reservations.jsonl` 2 行 | 增量 | P0 | 由其**原作者/并行会话**完成提交与部署（不属本任务可代做范围：属他人/他会话在途变更）。本任务仅登记为**依赖前置**：RP-12 的同步必须包含这批内容 | S2/S4/S5 三处一致观测：51.9–51.13 + 60 行断言仅存在于未提交工作区，4 站 0 命中 |

---

## 四、P1 簿记与索引（6 条）

| 编号 | 对象（文件+锚点） | 变更类型 | 优先级 | 执行动作 | 依据 |
|------|------------------|---------|--------|---------|------|
| RP-15 | `plans/` 根下 8 个 Status 全 complete 计划 + 7 个无 task_plan.md 目录（含空 `plans/task-v183/`）+ 3 个零 Status 计划（task-defect / task-v192 / task-v193） | 增量 | P1 | 走 `archive-plan.sh`（先 dry-run 再实做，Rule 81.5 批门四步）；无 task_plan.md 的目录先确认归属再决定「补最小 task_plan.md」或「归档」；零 Status 的 3 个补 Status 行 | B-02（事实 verified，影响降 P1） |
| RP-16 | `plans/INDEX.md:8,:9,:46` | 增量 | P1 | 修表头/分隔行列数错配（8 vs 6）；重跑 `sync-todos.sh --index` 刷新汇总，补入漏计计划；建立「INDEX 双向差集 = 0」的自检断言 | B-04 verified |
| RP-17 | `plans/.rule-reservations.jsonl`（补 Rule 56/83 的 reserved/landed 行；修正 57/60/80/82 终态） | 增量 | P1 | 按 Rule 20.6 补登编号生命周期行；与正文存在性双向对齐（RP-07 的前置） | A-05/B-01 verified |
| RP-18 | `plans/.active_plan_side/` 幽灵指针（指向不存在的 `task-batch-report-tmpl-fix`）+ 71 个漂移状态文件 | 删除 | P1 | **删除需用户逐项授权**；先 `set-active-plan.sh gc` 清扫残留，71 个漂移状态文件逐个判定（活跃会话标记 vs 残留）后处理 | B-05/B-08 verified |
| RP-19 | `skills/task-planner/scripts/check-delegation.sh`（Executor 匹配与委派率统计口径） | 增量 | P1 | Executor 字段模板补充「必须写纯 `subagent_type(model)`」的显式说明（现行 `templates/task_plan.md` 未写清），并让匹配器对无法匹配的 Executor 输出**可解释告警**而非静默计 0 | C-05（依据锚 `check-delegation.sh:421-424,445`；机制 verified，条目降 INFO） |
| RP-20 | `skills/task-planner/scripts/selftest-dispatch-grain.sh`（S-unit 上限双轨 2/100/15 vs 3/300）+ `templates/task_plan.md:321`（声称 enforce 实为 SKIPPED） | 增量 | P1 | 统一上限取值来源（单一声明点），模板与脚本口径一致；明确 enforce/SKIPPED 实际档位 | C-06 verified |

---

## 五、P1/P2 契约与文本一致性（9 条）

| 编号 | 对象（文件+锚点） | 变更类型 | 优先级 | 执行动作 | 依据 |
|------|------------------|---------|--------|---------|------|
| RP-21 | `skills/task-planner/SKILL.md:195`（区间 69-76）与 `references/critical-rules.md:193-203`（卫星索引缺 Rule 91） | 增量 | P1 | 修正区间边界使 Rule 75 归属唯一（正文在 `critical-rules-research.md:42`）；卫星索引补 Rule 91；并使三面计数同源（**建议**：以账本/正文实测值为唯一源，其余两处引用而非各自硬写） | A-02/A-03 verified |
| RP-22 | `skills/task-planner/SKILL.md:187`（Rule 38.7 锚）与 `:195` 引用行 | 增量 | P1 | 把「0 命中」的错误声明改为正确锚（现权威位置=卫星两份逐字双载），并复核所有 `SKILL.md` 内的「验证锚」是否仍指向现存位置 | A-08 verified |
| RP-23 | `skills/task-planner/references/critical-rules.md` Rule 82 与 `skills/plan-template-kit/references/critical-rules-template.md:45` ≡ `skills/task-discipline/references/critical-rules-discipline.md:195` 的 Rule 38.7 双载 | 增量 | P1 | 明确「逐字双载」与「禁镜像副本」的边界（建议：Rule 82 增补「跨域引用锚 ≠ 副本」判据），消除自相矛盾 | A-07 verified |
| RP-24 | `skills/task-planner/scripts/selftest-*.sh` 中按 `^### N` 枚举的规则探针 + `## Rule 80` 标题格式 | 增量 | P1 | 统一 Rule 标题层级（建议全部 `### Rule N`），或让枚举器兼容两种层级；避免「Rule 80 对枚举器不可见」 | A-08 verified |
| RP-25 | `skills/task-planner/.backup/`（23MB / 1556 文件 / 557 selftest 副本） | 删除 | P1 | **需用户逐项授权**：① 迁出技能目录（移至仓外或专用归档目录）② 所有 grep/find 统计口径加排除 ③ `install-stub.sh` 的 `rsync -a --delete` 增 `--exclude='.backup/'`（若脚本含此路径；当前未在 install-stub.sh 命中 rsync，需实施时再定位实际安装脚本）④ 复核 4 部署位同款 23M 冗余副本 | S1/S2/S5 一致观测；既往「锚点失效」事故的复发面 |
| RP-26 | `skills/task-planner/SKILL.md` 与 `skills/task-discipline/references/critical-rules-discipline.md` 中 22.5 选型指向的「§子代理路由与模型分级」章节 | 增量 | P1 | 该章节已不存在 → 修正引用指向实际载体（卫星路由表/覆盖矩阵 `agent-coverage.md`），或恢复该章节 | C-06 verified |
| RP-27 | 22.5「三证据」与 22.5 现行「2 动作（Read 产出 + findings 回填）」的口径冲突 | 增量 | P1 | 统一为一个口径并在两处同步 | C-06 verified |
| RP-28 | `skills/task-planner/references/critical-rules.md` Rule 58.3 反证检查的适用范围（58.1 证据面清单） | 增量 | P1 | 反证检查扩展到「执行类任务中的事实性断言」（本案类型），或新增独立判据交由 RP-02 时序条款承担 | G-03 verified |
| RP-29 | `skills/task-planner/references/critical-rules.md` Rule 34/30 索引与 `README.md:48/:69`、`ARCHITECTURE.md:54/:101` 的区间表述 | 增量 | P2 | 修正区间吞并，使 Rule 30/34 可被按号定位 | A-08 verified |

---

## 六、需用户裁决项（本任务不得代决，2 条）

| 编号 | 对象 | 变更类型 | 优先级 | 待决问题 | 依据 |
|------|------|---------|--------|---------|------|
| RP-30 | `/mnt/data/dev/videop1/AGENTS.md:84` 段尾「额度事实断言纪律（2026-10-21 立 v2…谎称『没有额度』整线排次日）」判例行 | 替代或删除 | P0（跨项目，需授权） | 该判例把**用户事后定性**写成宪法级定论（原文实际为「约束 4 禁今晚发起新创建 → 重抽只能明日」，非「没有额度」）。选项：① 撤回该判例行 ② 改写为「把可选策略读成唯一出路」的准确表述 ③ 保留但加「定性措辞以一手原文为准」的限定。**跨项目写入，需用户显式授权** | S8 §1.3 + S7 复核（措辞修正） |
| RP-31 | `videop1/plans/task-videop1-quotafact-001/{user-session-log.md:9; findings.md:20-21; task_plan.md:32; verification.md:23,26}` 与 `videop1/docs/experience/quotafact-20261021.md:6,:9,:17` | 增量 | P1（跨项目，需授权） | 同上口径问题：把「谎称没有额度」统一改为与一手原文一致的表述，并补入「真事实早于断言」的时序事实 | S8 §1.3 |

---

## 七、执行注意事项（给落地任务）

1. **worktree 强制**（宪法 §十一 + 技能文件属 §六 保护区）：`git worktree add /home/terry/task-planner-skill-worktrees/<task-id> -b wt/<task-id>`；禁止在主仓直接改 `skills/**`。注意本仓主工作树当前有 4 个未提交在途文件，**禁止** `git stash`/`git checkout`/`git clean`（会破坏并行会话在途状态）。
2. **执行顺序**：RP-17（账本补登）→ RP-07（收紧豁免）→ RP-05（锚收紧）→ RP-14（固化在途）→ RP-12/RP-13（部署同步 + 阻断门）→ RP-01~RP-04（生效通道）→ P1/P2 批量项。前三项若不先做，收紧类改动会立刻产生假 FAIL。
3. **每条替代类条目**（RP-05/07/12）必须先在 worktree 内跑「旧锚失效复现 + 新判据全绿」双验证，才能合并；未达成四条件即回落增量。
4. **回归基线**：当前活树基线 = 92/92 exit 0、1315 PASS / 0 FAIL、0 语法错（活树口径，排除 `.backup`）。任何修改后回归不得低于该基线，且需**新增**针对本报告 P0 的负断言（RP-06 已含 1 条示例）。
5. **部署位同步**须四站 IDENTICAL 后方可视为落地；`~/.zcode` 是现行实际加载位，优先级最高。
6. **规则编号**：本方案不新增 Rule 编号（RP-01~RP-04 均为既有规则的增量/指针增强），如落地时确需新号，按 Rule 20.6 先 `rule-reserve.sh` 预留再落地。

---

## 八、VC 映射（VC-1~VC-6 → 报告章节 / 方案条目）

| VC | 验证条件（task_plan.md 摘要） | 落点 |
|----|------------------------------|------|
| VC-1 | 报告覆盖五维（结构/规则一致性/脚本回归/部署簿记/派发契约），每维含结论+发现编号+证据锚 | A §0 + §1~§6 全维章节：§1 事实编造面（R3，含 §1.1~§1.4）/ §2 规则三面一致性（A-01~A-09）/ §3 脚本健康与回归（S4）/ §4 部署与簿记（B-01~B-05）/ §5 派发契约（C-01~C-06）/ §6 结构面（S1） |
| VC-2 | 修改方案每条 = 对象（文件+锚点）+变更类型（增量/替代/删除）+优先级+执行建议 | B 的 RP-01~RP-31（逐条五列齐备；RP-30/RP-31 为用户裁决项，以「待决问题+选项」替代「执行动作」，已在 §六 表头声明） |
| VC-3 | self-test 全量回归执行记录在案（执行命令+FAIL 数落 progress.md），审计动作零新增 FAIL | A §3 回归基线（92/92 exit 0、1315 PASS / 0 FAIL、0 语法错）+ progress.md 的 Test Results 段（当前仍为空模板，数字对照待主进程回填） |
| VC-4 | 全部 P0/P1 发现均有证据锚（文件:行 / 命令输出），无锚结论 = 0 条 | A §7 复核裁决（S7 独立复现 22 条 → verified 17 / partial 3 / fp 2）+ 各发现表的「证据锚」列 + 附「证据索引」 |
| VC-5 | 执行前后 `git status --short` 对照，仓内既有文件零改动（写面仅 plans/） | A §0「审计范围/只读边界」声明 + progress.md 进度记录（git status 前后对照待主进程回填） |
| VC-6 | R3 取证链闭合：①「无额度/等明天」声称原文 ②真实额度证据 ③编造+固化发生点定位到具体规则/agent/模板缺口 ④方案含该缺陷类的守护条款 | A §1：①原文锚 §1.1 时序表（23:30:54 声称原文，part/msg id）②真实额度锚 §1.1（账本 23:03:58 `{"used":198}` + 回执 23:25:12「剩余 302s 随 00:00 清零」→ 198/500、302s、重置 00:00 三要素；「39.6%」经复核在该会话树 0 命中 = 面板口径非会话内证据，不作锚点）③发生点 §1.3 固化落点 + §1.4 技能侧根因 ④守护条款方案 B 的 RP-01~RP-04（生效通道）+ RP-30/RP-31（跨项目措辞纠正） |

> 备注：§3、§6 为事实维度（以数值/锚点表述，无独立发现编号），其结论在 A §0 核心结论三与 §8 总体裁决中承接。

---

**方案统计**：提案 31 条 = P0 15 条（生效通道 4 + 守卫 7 + 部署 3 + 跨项目裁决 RP-30 1）+ P1 15 条（簿记索引 6 + 契约文本 8 + 跨项目裁决 RP-31 1）+ P2 1 条（RP-29），其中「替代」类 3 条、「删除」类 2 条（均标注需授权）、其余为「增量」。所有 P0/P1 条目均含：对象文件+锚点、变更类型、优先级、可执行动作、依据证据锚。
