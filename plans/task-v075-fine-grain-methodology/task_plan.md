<!-- template_type: rule-enhancement -->
<!-- [2026-09-16 plan-writer] 按 templates/variant/rule-enhancement-type.md 结构完整填充 -->

# Task Plan: task-v075 — S-unit 细粒度机器门控 + methodology 开关键消费兑现 + 部署 3 实体位

## Goal
机器化强制小步快跑（attest S-unit 数值门控 + dispatch 长度/打包检测 + fmea_enforce 双点消费 + v063 遗留清理），全量 selftest 0 FAIL 后合并 master、部署 3 实体位并 push GitHub。

## 任务参数
| 字段 | 值 |
|------|-----|
| task-id | `task-v075-fine-grain-methodology` |
| template_type | rule-enhancement（调用方锁定，勿加反引号——check-template-type.sh 表格提取不剥反引号，2026-09-16 实测） |
| knowledge_brief | plans/task-v075-fine-grain-methodology/knowledge-brief.md（五段 §1-§5 已填，§5 与本计划 S-unit 表「输入」列互链） |
| reflect_verify | `required`（Rule 33 自示范：每个问题解决动作后 progress.md 落 `[reflect] 反思:/验证:` 两行） |
| interaction_mode | `silent`（Decisions Made 登记：端到端交付指令 + 自治执行环境 + v074 silent 先例；交付报告附静默决策清单） |
| git_commit | 逐 Phase 提交（Rule 27；scope 限定本 Phase 产物，禁 `git add -A`；commit 风格 `feat/fix(task-planner): task-v075/P<n> …`） |
| 仓 canonical | skills/task-planner/（master @ 3e9a451） |
| worktree_path | /mnt/data/dev/task-planner-skill-worktrees/task-v075-fine-grain-methodology |
| branch | wt/task-v075-fine-grain-methodology（自 master 3e9a451；宪法 §11.2 集中目录） |
| scope_files | `skills/task-planner/{scripts/check-plan-dispatch.sh, scripts/check-dispatch.sh, scripts/attest-plan.sh, scripts/check-complete.sh, scripts/selftest-plan-dispatch.sh, scripts/selftest-dispatch.sh, scripts/selftest-methodology.sh, lib/verify.sh, references/methodology.md, templates/task_plan.md, templates/variant/rule-enhancement-type.md, SKILL.md, references/critical-rules.md, CHANGELOG.md, README_zh.md}` |
| 非 scope 说明 | plans/ 簿记（INDEX.md/ledger）入 P10 收尾提交；不动 config.json（step_max_*/prompt_max_chars/fmea_enforce/dispatch_contract_enforce 键均既有，本轮仅首次被消费，无新键） |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 7 个 .sh 脚本 + 门控行为变更） |
| `interaction_mode` | `silent` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| V1 | attest 数值门控生效：check-plan-dispatch.sh 对预估时长 >15min 的 S-unit 行与输入列 >2 个文件路径的行拒绝（exit 1 + `[plan-dispatch] ✗` 行）；不可解析/空时长行输出显式 `SKIPPED` 行且不阻断；`bash scripts/attest-plan.sh <含超限行的夹具计划>` 拒绝锁定 | 主进程实测 3 case（超限行拒绝 / SKIPPED 行放行 / 全合规通过）+ `bash scripts/selftest-plan-dispatch.sh` Total 行 FAIL=0 | check-plan-dispatch.sh 输出 / selftest-plan-dispatch.sh Total 行 |
| V2 | check-dispatch.sh 三项增量（prompt 长度 wc -m vs 3000 / 单 prompt 打包 ≥2 个不同 S-unit ID / knowledge-brief 引用缺失 warn）挂 dispatch_contract_enforce 分档，默认 warn 档行为不回归（既有七项缺项判定与 fail-open 路径语义不变） | `bash scripts/selftest-dispatch.sh` Total FAIL=0 + 主进程对既有合规 prompt 实测 warn 档输出 diff 与基线一致 | check-dispatch.sh 输出 / selftest-dispatch.sh Total 行 |
| V3 | fmea_enforce 三档行为分化可观测：off=check-complete 跳过 FMEA 段检查；warn=FMEA 段缺失/RPN 数据行=0/RPN>100 无兜底登记时打印警告继续；enforce=同条件 exit 1 | selftest-methodology.sh 新增断言 + 主进程对含/不含 FMEA 段的两份夹具计划各实测 1 次三档 | check-complete.sh 输出（三档各 1 次）/ selftest-methodology.sh Total 行 |
| V4 | 全量 selftest 回归 0 FAIL：`for f in skills/task-planner/scripts/selftest-*.sh; do bash $f; done` 逐脚本 Total 行求和计数，总数=主进程亲跑求和（**禁采信子代理自报总数**，Rule 17/v074 先例）；lib/verify.sh 全量含 selftest-methodology 且 0 FAIL | 主进程逐脚本跑完记录 progress.md Selftest Log；`bash skills/task-planner/lib/verify.sh` 输出无 FAIL | progress.md Selftest Log / verify.sh 输出 |
| V5 | 模板/文档同步点无遗漏：templates/task_plan.md S-unit 表注释含 NNmin 时长格式契约；templates/variant/rule-enhancement-type.md 含 7 列 S-unit 表示范行；SKILL.md 与 critical-rules.md 对应条款（21.1b/22.4/25.1/33.6 范式）标注「机器校验已生效」；grep 复验：`grep -n "NNmin" templates/task_plan.md` ≥1、`grep -c "机器校验已生效\|机械校验" SKILL.md references/critical-rules.md` 覆盖 21.1b/22.4 对应行 | 主进程逐点 grep 复验 + Read 2 模板文件相关行 | 各文件对应行 |
| V6 | 部署 3 实体位对账=0：`bash skills/task-planner/scripts/smart-merge-back.sh <worktree> --deploy` 对 ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner diff 空（IDENTICAL×3） | smart-merge-back 对账输出 | P10 执行输出 / progress.md |
| V7 | push 后远端一致：`git push origin master` 后 `git rev-parse origin/master` == 本地 `git rev-parse HEAD`；worktree 已 remove + 分支已删 | `git rev-parse` 双值比对 + `git worktree list` 无 task-v075 残留 | git 命令输出 |

**终验规则**：全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED（Rule 3）。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 脚本 | skills/task-planner/scripts/check-plan-dispatch.sh, check-dispatch.sh, attest-plan.sh, check-complete.sh, selftest-plan-dispatch.sh, selftest-dispatch.sh, selftest-methodology.sh（本轮新增/修改 7 件） | 其他 scripts/*（含 verify.sh 之外的全量入口脚本；verify.sh 属 lib/ 单列） |
| 校验/文档修正 | skills/task-planner/lib/verify.sh（§9 循环补 1 行）, references/methodology.md（仅 :137/:158 两处不可核出处改泛化表述+保留待补登记） | methodology.md 其他内容；references/ 其他文件 |
| 模板 | templates/task_plan.md（S-unit 表注释 1 处）, templates/variant/rule-enhancement-type.md（补 7 列 S-unit 表示范行） | 其他模板/变体内容 |
| 条款/文档 | SKILL.md（≤10 行净增纪律，行位替换优先）, references/critical-rules.md（仅对应条款「机器校验已生效」标注，改既有规则语义=禁止） | 新增 Rule 编号（本轮无新 Rule，只兑现既有条款的机制化） |
| 交付文档 | CHANGELOG.md, README_zh.md（各 1 条目，仓根） | 其他根目录文档 |
| 簿记 | plans/INDEX.md + ledger（仅 P10 主进程收尾提交） | 子代理触碰 plans/ 簿记 |

**强制约束**：
- 改 SKILL.md 前先 `grep -rn "Rules 1-" skills/task-planner/scripts/` 扫全库锚断言一次修齐（v074 先例，锚定级联防连锁 FAIL）
- selftest 断言一律 hermetic（mktemp 夹具范式对齐 selftest-methodology.sh 既有 7 断言写法），对真实仓只读
- 派发契约：executor/code-assistant prompt 必含计划三文件绝对路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）
- P2-P8 严格串行派发（Rule 21.4），一次一个 S-unit、验收一个再派下一个

## 📚 必要知识储备
| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 本任务 knowledge-brief（§2 已验证事实 + §3 锚点） | plans/task-v075-fine-grain-methodology/knowledge-brief.md | ☑ |
| 项目内部 | template-gate 三档解析范式（新门控挂载参照） | scripts/attest-plan.sh:80-97 + config.json:81 | ☑ |
| 项目内部 | selftest hermetic 夹具范式 | scripts/selftest-methodology.sh（96 行 M-01..M-07） | ☑ |

## Phases（10 Phase，派发严格串行）

| Phase | 目标 | 状态 |
|-------|------|------|
| P1 隔离与基线 | worktree 建立 + 全量 selftest 基线 | complete |
| P2 A1 attest 数值门控 | check-plan-dispatch.sh 增 S-unit 数值校验 + selftest 用例 | complete |
| P3 A2 dispatch 三项增量 | check-dispatch.sh 长度/打包/brief 引用 + selftest 用例 | complete |
| P4 B1 fmea_enforce 消费 | attest-plan.sh + check-complete.sh 双点接入 + selftest-methodology 用例 | complete |
| P5 B3 v063 遗留清理 | lib/verify.sh §9 补循环 + methodology.md 两处出处修正 | complete |
| P6 模板同步 2 文件 | task_plan.md NNmin 契约注释 + rule-enhancement-type.md 7 列表示范 | complete |
| P7 条款同步 2 文件 | SKILL.md + critical-rules.md 对应条款「机器校验已生效」标注 | complete |
| P8 交付文档 2 文件 | CHANGELOG.md + README_zh.md 条目 | complete |
| P9 全量回归定数 | 主进程逐脚本 Total 行求和 + verify.sh 全量 | complete |
| P10 合并部署推送簿记 | merge + smart-merge-back --deploy 3 位 + 清理 + push + INDEX/ledger | complete |

### Phase 1: 隔离与基线
- [x] 建 worktree /mnt/data/dev/task-planner-skill-worktrees/task-v075-fine-grain-methodology（branch wt/task-v075-fine-grain-methodology 自 master 3e9a451）；勿动任何既有 worktree/分支
- [x] 全量 selftest 基线（主进程逐脚本 Total 行求和，记 progress.md Selftest Log 基线行；当前预期 301 PASS/0 FAIL 口径，以实跑为准）
- [x] worktree 内 grep 复验插入点锚（check-plan-dispatch.sh:84-124 循环段 / check-dispatch.sh scan_missing / check-complete.sh:453 附近 / lib/verify.sh:225-235）
- 证据：基线 301/0（/tmp/v075-baseline.txt）+ 锚点 5/5 命中（findings Resources 段）
- **V-N:** V4（基线是回归对比前提）
- **Status:** complete
- **Executor:** 主进程（例外理由：① git/worktree 编排 + 基线定数属 Rule 25.3 白名单①③；基线求和=机械验证，禁采信子代理自报总数）

### Phase 2: A1 — check-plan-dispatch.sh S-unit 数值门控
- [x] check-plan-dispatch.sh 增两项逐行数值校验：预估时长列须解析为 `NNmin` 且 ≤config step_max_minutes(15)；输入列文件路径计数 ≤step_max_files(2)；不可解析/空时长行 → 打印显式 `SKIPPED` 行（v074 P10 fail-open 显式化先例），不阻断
- [x] selftest-plan-dispatch.sh 增对应用例（超限时长拒绝 / 超限文件数拒绝 / SKIPPED 放行 / 全合规通过，hermetic 夹具）
- 证据：worktree commit c506349；selftest 12/0（主进程复跑）；attest 端到端夹具 rc=1 双违规齐捕（progress.md P2 段）
- **V-N:** V1, V4
- **Status:** complete
- **Executor:** code-assistant（sonnet-1）

<!-- S-unit 派发单元表（Rule 22.6；材料包摘要锚点见 knowledge-brief §5） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 数值门控实现 | 继承 | skills/task-planner/scripts/check-plan-dispatch.sh:84-124（Phase 扫描循环+settle_phase 段，需在此插入时长/文件数逐行解析；config 读取参照 :80 tcfg jq 范式）+ brief §2/§3 | `bash scripts/attest-plan.sh <夹具含 16min 行>` exit 1 且 stderr 含 `✗`；`<夹具含空时长行>` 输出 SKIPPED 行且 exit 0；bash -n 通过 | 12min | complete |
| S2 | selftest 用例 | 继承 | skills/task-planner/scripts/selftest-plan-dispatch.sh 全文（既有断言范式+末行 Total）+ brief §4 | `bash scripts/selftest-plan-dispatch.sh` Total FAIL=0，新增 ≥4 断言（超限/超限/SKIPPED/合规） | 10min | complete |

### Phase 3: A2 — check-dispatch.sh 三项增量
- [x] check-dispatch.sh 增：① prompt 总长 `wc -m` vs config prompt_max_chars(3000) ② 单 prompt 内出现 ≥2 个不同 S-unit ID（`S<n>` 字面集合计数）打包检测 ③ knowledge-brief 引用缺失提示（prompt 含计划三文件路径但 brief 存在且未引用节锚点 → warn 提示）
- [x] 三项全部挂既有 dispatch_contract_enforce 分档（enforce=阻断/warn=告警计数/off=跳过），默认 warn 档对既有合规 prompt 行为零回归；selftest-dispatch.sh 增对应用例
- 证据：worktree（P3 提交见 progress）；selftest 22/0（主进程复跑）；主进程双探针（合规静默 rc=0 / 超长 5488 字符告警+enforce 阻断）；config 实测 default=enforce（见 findings）
- **V-N:** V2, V4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 三项检测实现 | 继承 | skills/task-planner/scripts/check-dispatch.sh:48-120（scan_missing 函数+档位分档段，三级解析 :167-179 语义不可动）+ config.json:57-67（dispatch_contract_enforce 键）+ brief §2/§4 | 超长 prompt（>3000 字符）warn 档输出计数警告；含 `S1`+`S2` 双 ID prompt 检出打包；brief 缺失引用出提示；既有合规 prompt 输出与基线 diff 一致 | 13min | complete |
| S2 | selftest 用例 | 继承 | skills/task-planner/scripts/selftest-dispatch.sh 全文（既有断言+hermetic 范式）+ brief §4 | `bash scripts/selftest-dispatch.sh` Total FAIL=0，新增 ≥3 断言覆盖三项 | 10min | complete |

### Phase 4: B1 — fmea_enforce 双点消费
- [x] attest-plan.sh 增 FMEA 门控段（挂载范式参照 template-gate :80-97：resolve_fmea_tier env>config>warn；FMEA 段存在 + RPN 表数据行 ≥1 + RPN>100 行须含兜底登记列非空；warn=打印警告继续 / enforce=exit 1 / off=跳过，逃生 `--skip-fmea-check` 须披露）
- [x] check-complete.sh 同逻辑接入终验（计划声明 `fmea_enforce: enforce` 或 config 档 enforce 时缺失 FMEA 数据行 = 终验 FAIL；warn 档打印警告继续）
- [x] selftest-methodology.sh 新增 ≥3 断言守护三档分化（M-08+ 续编号，hermetic 夹具）
- 证据：三档×双点实测矩阵（progress P4 段）+ selftest 7→11（主进程复跑 11/0）+ 主进程双档探针复现
- **V-N:** V3, V4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | attest 门控段 | 继承 | skills/task-planner/scripts/attest-plan.sh:77-120（resolve_template_tier+fail-open 显式化段=挂载范式；fmea_enforce 键原文与 FMEA 段标题锚在实现时按范式自查，非主输入——保持输入 ≤2 路径合规）+ brief §2/§4 | 无 FMEA 段计划：warn 档打印警告继续锁定成功 / enforce 档 exit 1 / off 档无输出；--skip-fmea-check 可达 | 13min | complete |
| S2 | check-complete 终验接入 | 继承 | skills/task-planner/scripts/check-complete.sh:453-472（既有门控段插入点范式）+ S1 产出 + brief §4 | 两份夹具计划（含 RPN 表/不含）× 三档 6 case 行为分化实测通过；bash -n 通过 | 13min | complete |
| S3 | selftest-methodology 断言 | 继承 | skills/task-planner/scripts/selftest-methodology.sh 全文（M-01..M-07 范式，末行 Total）+ brief §4 | `bash scripts/selftest-methodology.sh` Total FAIL=0，新增 ≥3 断言（三档分化+高 RPN 兜底） | 10min | complete |

### Phase 5: B3 — v063 遗留清理
- [x] lib/verify.sh §9 循环补 `selftest-methodology.sh`（:227 for 列表追加 1 项，v063 遗留①；实核该循环=verify.sh 唯一 selftest 遍历处，+6/-1 含头 Checks 清单同步）
- [x] references/methodology.md:137（Google DeepMind 2023）与 :158（Anthropic 2024 内部规范）两处不可核出处改泛化表述 + 保留「待补」登记（v063 遗留②；不瞎编原文）
- 证据：verify.sh 全量 26/0 含 selftest-methodology 行（主进程复跑）+ selftest 11/0 + diff 两处改写对照（progress P5 段）
- **V-N:** V4, V5
- **Status:** complete
- **Executor:** code-assistant（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | verify.sh §9 补循环 | 继承 | skills/task-planner/lib/verify.sh:225-235（§9 for 循环段，列表加 1 项）+ brief §2 | `bash skills/task-planner/lib/verify.sh` 输出含 selftest-methodology.sh 存在性 pass 行 | 8min | complete |
| S2 | methodology 出处修正 | 继承 | skills/task-planner/references/methodology.md:134-163（Q4 五维评分/Q5 契约复用段，:137 与 :158 两处「待补」原文）+ brief §4 | 两处改泛化表述且文末待补项汇总仍登记；selftest-methodology.sh M-03（9 方法名关键词）仍 PASS | 8min | complete |

### Phase 6: 模板同步（2 文件）
- [x] templates/task_plan.md:182 S-unit 表 HTML 注释补 NNmin 时长格式契约（「预估时长列一律写 NNmin 且 ≤15min，不可解析行 attest 时 SKIPPED 显式化」）
- [x] templates/variant/rule-enhancement-type.md 补 7 列 S-unit 表示范（Phase 2/3 增 S-unit 表行示范，含 NNmin 写法——模板自身示范合规）
- 证据：selftest-template-lifecycle 17/0（主进程复跑）+ NNmin :184 + 7 列表头 :55（progress P6 段）
- **V-N:** V5
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 双模板同步 | 继承 | skills/task-planner/templates/task_plan.md:180-184（S-unit 注释段）+ templates/variant/rule-enhancement-type.md:45-74（Phase 骨架段）+ brief §1/§4 | `grep -n "NNmin" templates/task_plan.md` ≥1；rule-enhancement 模板含完整 7 列表头行；selftest-template-lifecycle.sh 仍 PASS | 10min | complete |

### Phase 7: 条款同步（SKILL.md + critical-rules.md 2 文件）
- [x] critical-rules.md 对应条款标注「机器校验已生效」：21.1b（:114，数值门控已入 check-plan-dispatch）、22.4（:127，prompt 长度/打包检测已入 check-dispatch）、25.1（:169，attest 门控范围更新）、33.6 范式段参照（fmea_enforce 消费方=attest+check-complete）
- [x] SKILL.md 对应行同口径标注 + 净增 ≤10 行纪律（行位替换优先，wc -l 复核；锚定级联 `grep -rn "Rules 1-" scripts/` 先扫）
- 证据：critical-rules 5 处+SKILL 4 处行内扩写（+9/-9，仅增不删语义）；SKILL 535 行不变（T2b ≤540 未触）；锚定级联 3 脚本均宽容锚无连锁（progress P7 段）
- **V-N:** V5
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | critical-rules 标注 | 继承 | skills/task-planner/references/critical-rules.md:114,117,127,132,169（5 条锚点原文）+ P2-P4 产出脚本行为摘要 + brief §4 | 各条款尾标注机器校验方（脚本名+档位）；不改变既有语义（diff 仅增不删） | 10min | complete |
| S2 | SKILL 标注+行数纪律 | 继承 | skills/task-planner/SKILL.md:78,287,291,533（4 处锚点）+ P7 S1 产出 + brief §4 | 同口径标注 2 处以上；`wc -l SKILL.md` 净增 ≤10；全量 selftest 相关断言无 FAIL | 12min | complete |

### Phase 8: 交付文档（CHANGELOG.md + README_zh.md 2 文件）
- [x] CHANGELOG.md 增 task-v075 条目（A1 数值门控 / A2 三项增量 / B1 FMEA 双点消费 / B3 遗留清理，对齐既有条目风格 §2.x 章节）
- [x] README_zh.md 对应说明增补（脚本行为变化 + fmea_enforce 键语义兑现说明，行位替换优先）
- 证据：CHANGELOG [Unreleased] 5 条目（+5）与 commit c506349…9f75354 一一对应；README 3 处增补（+8/-2）；grep 计数 5/2；无新增悬空链接（progress P8 段）
- **V-N:** V5
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 双文档条目 | 继承 | /mnt/data/dev/task-planner-skill/CHANGELOG.md:1-20（既有条目风格锚）+ README_zh.md 脚本说明段 + P2-P5 commit 摘要 + brief §1 | 两文件各含 task-v075 条目且与实现一致（grep "task-v075" 各 ≥1）；无新增悬空链接 | 10min | complete |

### Phase 9: 全量 selftest 回归（定数）
- [x] 主进程逐脚本 `bash skills/task-planner/scripts/selftest-*.sh` 跑完，Total 行逐脚本求和记 progress.md Selftest Log（含 P2-P8 新增断言；基线 P1 对比）
- [x] `bash skills/task-planner/lib/verify.sh` 全量 0 FAIL（含 P5 补入的 selftest-methodology）
- [x] Code Review Gate（code_review: required）：对 P2-P8 全 diff（master..HEAD -- skills/task-planner/）走独立审查视角，记录结论
- 定数：**全量 19 脚本 313 PASS / 0 FAIL**（=基线 301+新增 12：plan-dispatch +4/dispatch +4/methodology +4），逐 Total 行 PASS=/FAIL= 字段直加（/tmp/v075-final.txt）；verify.sh 23/3——3 FAIL 全部=三部署位 SKILL.md 漂移（claude/zcode/opencode，未部署的预期中间态，P10 --deploy 后复跑归零）；Code Review **APPROVED**（无 P0/P1，P3 文档瑕疵 1 条已派原子修复）
- **V-N:** V1, V2, V3, V4
- **Status:** complete
- **Executor:** 主进程（例外理由：③ 机械验证=逐脚本 Total 行求和定数，禁采信子代理自报总数）+ Code Reviewer（Gate 独立视角）

### Phase 10: 合并回 + 部署 3 实体位 + 推送 + 簿记
- [x] 前置三问自检（worktree 内全 Phase 验收完成 / worktree git status 干净 / 主仓无 scope 重叠未提交变更——主仓 plans/ 内变更与实现 scope 零重叠）
- [x] `smart-merge-back.sh <worktree> --deploy`（V1-V6 预检全 OK，MERGED d975ee0 + 3 实体位对账 IDENTICAL×3）
- [x] 清理 worktree + `git branch -d wt/task-v075-fine-grain-methodology`
- [x] `git push origin master` + `git rev-parse` 双值比对（V7：local=remote=d975ee0）
- [x] plans/INDEX.md 登记 v075 + ledger 追加 + findings/progress 收尾回填 + verification.md 终验（chore 提交限 plans/ 范围）
- 证据：MERGED d975ee0 / IDENTICAL×3 / verify 部署后 26/0 / push 3e9a451..d975ee0（progress.md P10 段）
- **V-N:** V6, V7（+ 全部 VC 终验）
- **Status:** complete
- **Executor:** 主进程（例外理由：① git 编排/合并/推送 + ② 簿记——Rule 25.3 白名单①②；部署对账=机械验证白名单③）

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅信号①：主仓未提交变更全在 plans/ 内——.active_plan/2×.plan_required_side 删除 + task-v074 .plan-attestation 修改 + task-v075 untracked 目录；与实现类 scope 零重叠，check-conflicts 等价结论） |
| `isolation` | `worktree` |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v075-fine-grain-methodology |
| `branch` | wt/task-v075-fine-grain-methodology |
| `merge_back` | merged(d975ee0)——smart-merge-back --deploy 三位 IDENTICAL，push 后 local=remote=d975ee0 |

> 宪法 §十一：本任务改 skills/task-planner/**（§六 保护区 + 运行中基础设施），强制 worktree；操作 SOP 见 references/worktree-isolation.md。

## 📊 FMEA 预演（RPN = S×O×D；RPN>100 行须登记兜底动作——本计划将被 P4 新 FMEA 门控校验，自身先合规）
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（对齐 22.3） |
|-------|---------|---|---|---|-----|--------------------------|
| P2 | attest 数值门控误伤存量计划：SKIPPED 语义边界写宽（"不可解析"判定误吞合法行）或写窄（合规行被拒）→ 存量计划 attest 行为漂移 | 7 | 4 | 5 | 140 | 22.3②拆细：S1 验收含「全合规夹具通过」反例断言；误伤存量 → 以 selftest 夹具为准回炉拆 S1 解析逻辑为独立函数再测，不改档位默认 |
| P9 | selftest 计数口径错：子代理自报 Total 与主进程逐脚本求和差（v074 先例 Error Log#2 复发） | 5 | 3 | 4 | 60 | P9 定数只认主进程亲跑；口径差记 progress.md Error Log 后以主进程数为准重写 Selftest Log |
| P10 | 部署漏实体位：3 位对账只跑 2 位或 opencode 位路径拼写错 | 6 | 3 | 4 | 72 | smart-merge-back --deploy 强制三位置对账全 IDENTICAL 才过 V6；漏位 = 立即补 deploy 重跑对账，禁止带缺口交付 |
| P3 | 多 S-unit 打包检测误伤：合法 prompt 引用 S-unit ID 作说明文本被检出 ≥2 | 4 | 3 | 4 | 48 | 判定限定 S<n> 行首/表格式出现（非自由文本）；warn 档默认下误伤代价=计数警告，观察期数据回填后 P9 审 |
| P4 | fmea_enforce enforce 档误伤旧计划（无 FMEA 段的 legacy 计划被 exit 1） | 6 | 3 | 4 | 72 | legacy 判定对齐 check-plan-dispatch :37-40 先例（无 Executor 行 = legacy fail-open）；默认 warn 不回归 |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 09-16 | 主进程直做 |
| Phase 2 | ☑ | 09-16 | 串行① code-assistant |
| Phase 3 | ☑ | 09-16 | 串行② executor |
| Phase 4 | ☑ | 09-16 | 串行③ executor |
| Phase 5 | ☑ | 09-16 | 串行④ code-assistant |
| Phase 6 | ☑ | 09-16 | 串行⑤ executor |
| Phase 7 | ☑ | 09-16 | 串行⑥ executor（含 1 次 SendMessage 补丁） |
| Phase 8 | ☑ | 09-16 | 串行⑦ executor |
| Phase 9 | ☑ | 09-16 | 主进程定数+Code Reviewer（串行⑧） |
| Phase 10 | ☑ | 09-16 | 主进程收尾 |

## Key Questions
1. 「输入列文件路径计数」的判定口径：S-unit 输入列内出现的路径样 token（含 `/` 与 `.sh/.md` 等后缀）计数 ≤2——P2 S1 执行时以 selftest 夹具定死（示例：写 3 个路径必拒），KQ1 裁定写入 check-plan-dispatch.sh 头注释。
2. fmea_enforce 的「RPN>100 行须含兜底登记」判定 = FMEA 表 RPN 列数值 >100 的数据行，其「预设兜底动作」列 trim 后非空——P4 S1 实现时定死正则。
3. check-dispatch 多 S-unit 打包检测仅 warn 档计数、enforce 档才阻断——默认行为变化面需 P3 S2 基线 diff 实测确认（V2 验收条件）。
4. SKILL.md 行数上限断言（selftest-knowledge-brief T2b ≤540）是否被 P7 净增击穿——P7 S2 改前 `wc -l` 预检，超预算改行位替换。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 范围取舍（A1+A2+B1+B3 落地，缓做 6 项） | findings.md Technical Decisions 三行已锁：小步快跑（每项独立可测、单 Phase ≤3 文件）；缓做登记 deferred：Phase 级 S-unit 总量机械化 / R1 前置门脚本化 / R3 checkpoint.jsonl 消费 / content_quality_enforce 消费 / warn 计数纳入终验统计 / 守卫多计划引用锚定歧义（本轮实测：prompt 引用 ≥2 个计划目录时字母序锚定可能错位，登记供后续轮） |
| attest 数值门控默认硬拒绝（沿 check-plan-dispatch 失败=拒绝锁定义务，不可解析行 SKIPPED 显式化） | attest 属计划期，改计划成本低；v074 P10 fail-open 显式化先例（:92-97）；step_max_* 三键 + prompt_max_chars 首次被运行时消费，无新 config 键 |
| A2 三项增量挂 dispatch_contract_enforce 分档、默认 warn | 派发期硬阻断有打断在途任务风险（check-dispatch :167-179 三级解析 fail-open 先例）；warn 计数留观察数据，档位已存在可随时升 enforce |
| B1 FMEA 消费=attest+check-complete 双点、按 fmea_enforce warn/enforce/off 分化 | 兑现 config.json:81-90 键描述「预留（后续轮）」语义；warn 默认不破坏存量计划；off 完全跳过 |
| C20 禁令检查 | 已查 memory + notepad-learnings.md 被否决方案段 = 无 veto 记录、无命中（2026-09-16） |
| silent 模式（interaction_mode: silent） | 用户指令为端到端交付（含部署+push）+ 自治执行环境 + v074 D1/D2 silent 先例；交付报告附静默决策清单；硬停点（连续失败 STOP / 漂移 BLOCKED / 证据不实 / 破坏性操作）两模式一致不可豁免 |
| 本计划自身小步快跑合规示范 | P2-P8 每 Phase ≤2 文件、S-unit 表 7 列齐、时长 NNmin ≤15、输入 ≤2 文件——将被 P2 落地门控与 P4 FMEA 门控校验（FMEA RPN>100 行已带兜底登记） |

## Deferred（登记不执行，供后续轮）
| 项 | 来源 | 理由 |
|----|------|------|
| Phase 级 S-unit 总量机械化（Phase 内 S-unit 行数/总时长上限） | findings A 结论③ | 本轮 6 项已超单轮细粒度预算，总量机械化需先观察 S-unit 分布数据 |
| R1 前置门脚本化（methodology.md R1 前置条件 :17-35 机检） | findings B | R1 判定依赖任务类型语义，机检误伤面大，需先积累 warn 数据 |
| R3 checkpoint.jsonl 消费 | findings B（R3 幂等+checkpoint :53-67） | 依赖 22.8 检查点产物格式稳定，本轮先不动 |
| content_quality_enforce 消费（config.json:71） | findings B | 内容型任务（writing/research/publish）专用门控，与本轮 A/B 主线无耦合，单开一轮 |
| warn 计数纳入终验统计 | findings B（dispatch/knowledge-brief 类 warn 无聚合） | 需先有 ≥2 轮观察数据再定阈值，避免拍脑袋数值 |
| 守卫多计划引用锚定歧义 | 本轮实测发现（prompt 引用 ≥2 个计划目录时字母序锚定可能错位） | check-dispatch 三级解析 :167-179 的已知边界，单开 bugfix 轮处理 |
| check-template-type.sh 值提取不剥反引号/不识别 HTML 注释行 frontmatter | 本轮实测发现（计划值写成 \`rule-enhancement\` 报 INVALID，warn 档放行） | 提取器 :19-27 已剥全角括号注记但不剥 markdown 反引号；单开 1 行修正轮或计划侧规范值格式 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|-----------|
| （执行期回填） |  |  |  |

## Notes
- 三文件分流：状态进本 plan、结论进 findings/progress/notepad（执行期）；plan-writer 只写 task_plan + knowledge-brief。
- commit 风格：`feat(task-planner): task-v075/P<n> — <动作>` + 收尾 `chore(task-planner): task-v075 — 交付簿记 + INDEX/ledger`；Rule 27 scope 限定，禁 `git add -A`。
- 禁在本任务触碰主仓 plans/ 簿记（P10 除外）与既有 worktree/分支。

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 计划创建（2026-09-16） | C20 禁令检查=无命中；范围与 findings Technical Decisions 三行一致，无扩缩 | - | 通过 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 7 / 10（P2-P8 派发；P1/P9/P10 主进程） |
| 主进程直做 Phase 清单 | P1（白名单①③ git 编排+基线定数）、P9（白名单③机械验证）、P10（白名单①②合并部署簿记） |
| 委派率 | 7/10 = 0.70（≥ delegation_rate_floor 0.7） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | 09-16 | plan-writer | 本计划撰写 | complete | task_plan + knowledge-brief 落盘（V0 结构自检通过） | plans/task-v075-fine-grain-methodology/task_plan.md | findings Requirements 段 | plans/task-v075-fine-grain-methodology/subagent-state/01-plan-writer.md | - | 0 | ☑ |
| 2 | 09-16 | code-assistant | P2 S1+S2 | complete | 数值门控落地（时长 NNmin≤15/输入 token≤2/SKIPPED 显式化）；selftest 8→12 全过；偏差=token 正则尾锚定+wc -l 计数（已写入脚本头注释） | worktree c506349 + selftest T09-T12 | findings Technical Decisions P2 行 | plans/task-v075-fine-grain-methodology/subagent-state/02-code-assistant.md | - | 0 | ☑ |
| 3 | 09-16 | executor | P3 S1+S2 | complete | 三项增量落地（+73 行，挂既有档位）；selftest 18→22 全过；基线四项 diff 一致（零回归）；主进程双探针复现 | checkpoint 03 + selftest FG-01..04 | findings Technical Decisions P3 行 | plans/task-v075-fine-grain-methodology/subagent-state/03-exec-p3.md | - | 0 | ☑ |
| 4 | 09-16 | executor | P4 S1-S3 | complete | fmea 双点消费落地（attest +70/cc +52/selftest +80）；三档矩阵+selftest 7→11 全过；主进程双档探针复现 | checkpoint 04 + selftest M-08..M-11 | progress P4 段+findings P4 行 | plans/task-v075-fine-grain-methodology/subagent-state/04-exec-p4.md | - | 0 | ☑ |
| 5 | 09-16 | code-assistant | P5 S1+S2 | complete | verify.sh 补 methodology 遍历（26/0 主进程复跑）；两处不可核出处泛化+登记（M-03 关键词不动）；S1 实核 §9=唯一遍历处走预案 B | checkpoint 05 + verify 26/0 | progress P5 段 | plans/task-v075-fine-grain-methodology/subagent-state/05-code-assistant.md | - | 0 | ☑ |
| 6 | 09-16 | executor | P6 S1 | complete | 双模板同步（+10/-1）：NNmin 机器契约注释+7 列 S-unit 表示范；template-lifecycle 17/0 不回归 | checkpoint 06 + selftest 17/0 | progress P6 段 | plans/task-v075-fine-grain-methodology/subagent-state/06-exec-p6.md | - | 0 | ☑ |
| 7 | 09-16 | executor | P7 S1+S2 | complete | 5+4 处条款行内标注（+9/-9）；SKILL 535 行不变 T2b 16/0；V5 字面缺口（3 处措辞缺「机器校验」）经 SendMessage 补丁修复后 3 处齐 | checkpoint 07 + wc -l 535 | progress P7 段 | plans/task-v075-fine-grain-methodology/subagent-state/07-exec-p7.md | - | 0 | ☑ |
| 8 | 09-16 | executor | P8 S1 | complete | CHANGELOG 5 条目+README 3 处增补（+11/-2），与 P2-P7 commit 一一对应无失实；selftest 总数按任务书留 P9 回填 | checkpoint 08 + grep 5/2 | progress P8 段+findings P8 行 | plans/task-v075-fine-grain-methodology/subagent-state/08-exec-p8.md | - | 0 | ☑ |
| 9 | 09-16 | Code Reviewer | Code Review Gate（code_review: required） | complete | APPROVED：无 P0/P1；六项清单全过（正确性/零回归/档位一致/fail-open 显式化/安全/可维护）；P3 文档瑕疵 1 条转原子修复 | git diff 3e9a451..HEAD（15 files +499/-21） | findings 终验段 | -（审查报告会话内） | - | 0 | ☑ |

## Chain 区块
单 skill 任务，chain_mode=single，无交接。
