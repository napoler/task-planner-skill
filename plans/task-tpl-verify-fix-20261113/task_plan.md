# Task Plan: 模板验证区块缺失与模板-门对齐修复（先修模板skill再按其纠正他处）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染；尖括号中文占位=模型填写面，脚本禁碰 -->
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「我发现当前的模板存在很多问题   比如验证机制 模板中缺失验证区块」<sub>（[目标]）</sub>
- **R2**: 「也就是说明同样地问题出在 模板编辑skill 那么可能问题出在 模板skill 也必须同步纠正」<sub>（[目标]）</sub>
- **R3**: 「你需要先修正模板skill然后按照 模板skill执行纠正其他错误的问题」<sub>（[目标]+顺序铁律：先模板 skill 后他处）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 五处模板-门漂移清单落盘（file:line）；模板补验证区块（**Verify command** 结构）|
| R2 | VC-2, VC-3 | 模板文件与 plan-template-kit（模板 skill）同步修正，契约互恰 |
| R3 | VC-4, VC-5, VC-6 | 按修正后口径纠正他处（SKILL 注释块/存量面）+冒烟证明新模板可用+部署生效 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-tpl-verify-fix-20261113/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结（Rule 80.2）
- **恢复协议**：会话恢复先读专档（#1 至最新），再读 task_plan.md
- **理解镜像**：每条逐字条目后同号配对（Rule 80.7）

## 🧮 根源覆盖表（Rule 53.1）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 模板文件 | S-unit 表 11 列（96 类别）vs 校验器 10 列；Goal 单元表列名缺空格；Phase4 示例无 S-unit 表；Batch Report 空默认 | Phase 2 S1 | VC-2 |
| 验证模板 | verification.md 模板无 **Verify command** 行结构（用户实锤「缺失验证区块」） | Phase 2 S2 | VC-2 |
| 模板 skill | plan-template-kit 契约文档未承载列序/验证区块契约 → 模板与门漂移无防线 | Phase 2 S3 | VC-3 |
| 传播面 | SKILL.md S-unit 注释块仍教 11 列口径；存量 variant/项目级模板可能同漂移 | Phase 3 S4/S5 | VC-4 |
| 可用性证明 | 修完无冒烟=不知道新模板真能一次过门 | Phase 4 S6 | VC-5 |

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1-R3 逐字原文；VC 表六条；顺序铁律（先模板 skill 后他处）；10 列 S-unit 新口径；零新脚本/零新 hook（§四.6） | 本文件；task-docmod-recheck 判例 |
| 🔒 不变量 | 不碰在途他任务文件（plan-resume/todo-skill/workflow-model-tiers/task-skillfix-audit 等）与 wt/task-v168-machine-parked | 冲突扫描 |
| 🔀 可变量 | 模板具体措辞/引导文案；冒烟目录路径；S-unit 拆分 | - |
| 📈 学得量 | 冒烟实测发现的新漂移项 | findings |

## Goal
先修正模板体系（templates/task_plan.md + templates/verification.md 补**验证区块**与 10 列口径 + plan-template-kit 契约同步），再以修正后口径清单驱动纠正全部同源漂移面（SKILL 注释块/存量模板/项目级覆盖），冒烟证明新模板一次过门，三部署位同步生效。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯模板/文档文本；CR 由 42.7 风险信号触发时走 critic，上任务判例） |
| `session_id` | `sess_30f4af3e-d8b0-4caf-b7bb-f5f443aeb163` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113` |
| `scope_files` | `skills/task-planner/templates/task_plan.md`, `skills/task-planner/templates/verification.md`, `skills/plan-template-kit/SKILL.md`, `skills/plan-template-kit/references/*（实测锚位定）`, `skills/task-planner/SKILL.md（仅 S-unit 注释块）`, `.zcode/plan-templates/*（若项目级覆盖同漂移）` |
| `interaction_mode` | `ask` |
| `对齐审查` | [登记] Phase 4 含 103.3 独立复检（模板契约↔门行为互恰） |
| `自动超时默认项` | [D1: 推荐项=按已展示计划执行/5min]；[冒烟目录: 推荐项=plans/tmp-smoke-tplfix 用完即删/5min] |
| `new_rule` | 留空（无新 Rule 编号——模板层修复，契约落在 plan-template-kit 既有条款域） |
| `质量审查工具` | 103.3 复检=general-reviewer；冒烟=check-plan-dispatch 实测 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：验证动作默认独立子代理执行（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 取证落盘：五处模板-门漂移清单（本会话 attest 三轮实录）+模板源定位（templates/task_plan.md 含 96 类别/verification 模板无 Verify command） | grep findings | `test $(grep -cE '96 类别|Verify command|对应 S-unit' /mnt/data/dev/task-planner-skill/plans/task-tpl-verify-fix-20261113/findings.md) -ge 4` |
| VC-2 | 模板修正：task_plan.md 模板 S-unit 表=10 列且无「96 类别」列名、Goal 单元表含「对应 S-unit/Phase」、Phase 4 示例带 S-unit 表；verification.md 模板每 VC 条目含 `**Verify command**:` 行格式 | grep 模板 | `! grep -q '96 类别' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && grep -q '对应 S-unit/Phase' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && test $(grep -c 'Verify command' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/verification.md) -ge 1` |
| VC-3 | 模板 skill 同步：plan-template-kit 含「验证区块（Verify command 契约）」与「S-unit 10 列序」条款 | grep | `test $(grep -rn 'Verify command' /mnt/data/dev/task-planner-skill/skills/plan-template-kit/ | wc -l) -ge 2` |
| VC-4 | 他处纠正：全仓 skills/ 模板与注释面「96 类别」作为列名/列指引的残留=0（负面/口径迁移表述除外，清单驱动登记）；SKILL.md 注释块口径=目标列内（An）前缀 | grep | `test $(grep -rn '96 类别' /mnt/data/dev/task-planner-skill/skills/ | grep -vE '（An）前缀|已废止|10 列' | wc -l) -eq 0`（口径定义落 findings §4） |
| VC-5 | 冒烟+回归：smoke 计划（新模板渲染+最小语义填充）过 check-plan-dispatch 零拒锁项；run-selftests=基线（2 预存 FAIL 不变） | 实跑 | 冒烟输出落 findings/checkpoint；`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -1` |
| VC-6 | 部署生效：scope 变更文件 × 三位 diff=0；三仓 push | diff 逐对 | 例：`diff /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md /home/terry/.zcode/skills/task-planner/templates/task_plan.md`（全对清单落 progress） |

**终验规则**：全部 VC 通过 → COMPLETE；通过但有登记遗留 → PARTIAL；≥1 失败且 3 次重试无效 → BLOCKED。

## 🛡 双轮质检与同步完整性声明（Rule 103）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 2/3 全部实质产出 S-unit + Phase 4 复检 |
| 豁免登记 | none |
| 多文件变更集预判 | Phase 2+3（模板两文件+kit+SKILL 注释+项目级覆盖）→ 翻转前 103.6 清单四族 |

## 🎯 核心目标达成裁决（Rule 58.5 — 终验填写）
| 字段 | 值 |
|--------|-----|
| **目标型需求** | R1, R2, R3 |
| **裁决/证据/遗留** | （终验填写） |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 漂移取证 | 五处漂移+模板源定位落 findings | 命令：VC-1 grep ≥4 | Phase 1 | pending |
| G2 | 模板修正 | 两模板文件补验证区块+10 列口径 | 命令：VC-2 三条 grep | S1+S2/Phase 2 | complete |
| G3 | kit 同步 | plan-template-kit 契约条款在位 | 命令：VC-3 grep | S3/Phase 2 | complete |
| G4 | 他处纠正 | 存量面清单驱动清零 | 命令：VC-4 残留=0 | S4+S5/Phase 3 | complete |
| G5 | 冒烟回归 | 新模板一次过门+selftest 基线 | 命令：VC-5 实跑记录 | S6/Phase 4 | complete |
| G6 | 部署生效 | 三位 diff=0+三仓 push | diff 形态：逐对空 | Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板 | skills/task-planner/templates/task_plan.md、templates/verification.md | 其他模板（variant 16 类若实测同漂移，逐个登记后入列） |
| 模板 skill | skills/plan-template-kit/SKILL.md + references/（实测锚位定） | 其他卫星 |
| 注释块 | skills/task-planner/SKILL.md（仅 S-unit 表注释块口径行） | SKILL 其他段 |
| 项目级覆盖 | .zcode/plan-templates/*（若与修正后模板漂移） | 盲改（先 diff 判方向） |
| 计划/冒烟 | plans/task-tpl-verify-fix-20261113/**；plans/tmp-smoke-tplfix/（用完即删） | 其他任务目录 |

**执行前自我检查**: 文件在列表中？修改必要？用户要求？→ 全 Yes 才执行。

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|------|-----------|----------------|------------------------|---------|
| CA-1 | templates/task_plan.md S-unit 表头+示例行+注释块 | 更新 | 替代（11 列口径被 check-plan-dispatch 10 列定位证伪） | 「模板存在很多问题」（R1） | attest 三轮实录①（findings §1） | 11 列→10 列（去 96 类别列，类别=目标列内（An）前缀） |
| CA-2 | templates/task_plan.md Goal 单元表列名 | 更新 | 替代（「对应S-unit」被 66.5 校验「对应 S-unit」证伪） | 同上 | attest 实录③ | 补空格 |
| CA-3 | templates/task_plan.md Phase 4 示例段 | 新增 | 增量 | 同上 | attest 实录④（Executor≠主进程无表=拒锁） | 示例补最小 S-unit 表 |
| CA-4 | templates/task_plan.md Batch Report 区块 | 更新 | 增量（填实值引导，非空默认） | 同上 | attest 实录⑤ | 每字段填「n/a（理由）」引导形态 |
| CA-5 | templates/verification.md VC 条目模板 | 更新 | 增量 | 「模板中缺失验证区块」（R1 实锤） | attest 实录②（vc-gate 拒锁） | 每 VC 条目加 `**Verify command**: <纯命令>` 行+判据引导 |
| CA-6 | plan-template-kit SKILL/references | 更新 | 增量 | 「模板skill 也必须同步纠正」（R2） | 模板-门漂移无契约防线 | 验证区块契约+10 列序条款 |
| CA-7 | ~~task-planner/SKILL.md S-unit 注释块~~ **处置=无锚可改**（S4 实测 SKILL.md 零命中「96 类别/Rule 104.3」——教学面=模板本体，已由 CA-1 修复；执行体诚实 blocked 未瞎插） | 更新 | 无锚登记 | 「按照 模板skill执行纠正其他错误的问题」（R3） | S4 checkpoint 04 | 关闭（无锚） |
| CA-8 | .zcode/plan-templates/* 项目级覆盖 | 更新 | 增量（若 diff 判定同漂移；初勘仅 knowledge-brief.md） | 同上 | init 模板优先级 | S5 diff 判向 |
| CA-9 | task-dispatch/references/critical-rules-dispatch.md Rule 104 条款三处（:244 括注「计划期 96 类别列」/:278「模板 S-unit 表含 96 类别列」/:256 速查表列头加防歧义半句） | 更新 | 替代（同 CA-1 判定：旧口径被 10 列定位证伪） | 同上（R3） | 主进程亲验 grep（2026-11-13）：dispatch.md:244/256/278 | 措辞→（An）前缀+10 列口径；:256 速查表自身列头保留+半句注明 |
| CA-10 | task-planner/scripts/selftest-subagent-activation.sh SA-19（:97-99 断言模板含 96 类别≥2 处=**机器守卫强制旧口径**） | 更新 | 替代（断言随口径走，EN-06 同性质纪元维护） | 同上（R3） | 主进程亲验 grep（2026-11-13） | SA-19 翻转为新口径断言（（An）前缀示范在位+10 列表头） |
| CA-11 | task-planner/scripts/selftest-subagent-granularity-skill-escort.sh SG-12/SG-13（断言模板表头「粒度(三值)/伴飞技能」唯一=1——**第六处漂移：门断言落后于 CA-3 正当新增的 Phase4 示例表**；S6 冒烟抓到，主仓 23/23 vs worktree 21/23 定性=本任务引入） | 更新 | 替代（断言随契约走：22.6 要求每派发 Phase 附表，示例表合法） | 同上（R3） | S6 checkpoint 06+主进程单跑对照 2026-11-13 | 断言翻转 =1 → ≥1（注明判例 task-tpl-verify-fix-20261113） |

## 📚 必要知识储备（任务知识库对齐）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范 | 用户宪法 §四（文本优先） | /home/terry/.zcode/AGENTS.md | 必读 | ☑ |
| 内部 | 判例任务全档（attest 三轮实录+模板-门五漂移） | plans/archive/task-docmod-recheck-20261112/（findings/progress） | 必读 | ☑（本会话一手） |
| 内部 | check-plan-dispatch.sh 列定位（$4/$5/$7/$8） | skills/task-planner/scripts/check-plan-dispatch.sh:246-278 | 必读 | ☑（上任务已读） |
| 内部 | attest-plan.sh vc-gate 判据 | skills/task-planner/scripts/attest-plan.sh:244-285 | 必读 | ☑ |
| 内部 | 现行模板全文 | skills/task-planner/templates/{task_plan,verification}.md | 必读 | ☐（S1/S2 执行体首动作） |

## ⚠️ 核心问题定义
**核心问题**: 模板教的东西与机器门要的东西漂移（五处实录），且模板 skill（plan-template-kit）无契约防线——模板缺失验证区块是用户实锤、attest 实录佐证的同一根因。
**判断**: 解决后（模板+kit+传播面修正+冒烟）→ 新计划一次过门可证 → 能交付；不解决 → 每个新任务都在 attest 处重复三轮翻车。✔✔✔

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词 | 渠道 | 产出形态 | 网络解难 |
|---------------|------|-----------|------|---------|---------|
| 全部 | LOCAL-ONLY | 不适用（本仓模板/脚本/上任务实录即全部输入） | 不适用 | findings 清单 | 否 |

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象 | 取证方式 | 落盘锚 | 状态 |
|--------|---------|---------|-----|------|
| ① 自身样本 | 本会话 attest 三轮拒锁实录（五漂移）+上任务 progress Error Log | 会话一手+归档档 | findings §1 | ☑ |
| ② 对标样本 | 机器门期望（check-plan-dispatch/attest/check-complete 判据源码行） | 上任务已读源码 | findings §2 | ☑ |
| ③ 外部约束 | 无（纯内部工程） | n/a | findings | ☑ |

## Current Phase
Phase 1

## Next Step
展示计划 → 等用户 yes → attest 锁定 → 建 worktree → Phase 2 S1-S3 派发

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| 1 | 会话一手+grep | 取证已在手，模板源已定位 |
| 2-3 | Agent（general-coder）+git worktree | 技能/模板文件写入须派发+隔离 |
| 4 | Agent（code-runner-agent+general-reviewer） | 冒烟实跑+独立复检 |
| 5 | 机械守卫+主进程 git | 白名单①② |

**workflow 编排判定**: 未命中 39.8（S-unit 真依赖链）→ 21.4 声明制（S1∥S2→S3；S4→S5）
**/goal 对齐**: 未用 /goal；本计划 Goal+VC 即证据源

## Phases

### Phase 1: 漂移取证与证据落盘
- [x] 五处模板-门漂移清单（上任务 attest 三轮实录，会话一手）
- [x] 模板源定位（templates/task_plan.md 含 96 类别；verification 模板无 Verify command——init 渲染实录）
- [x] findings.md 回填 + 知识储备确认（V-1.1 实跑 PASS 2026-11-13）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由: ② 计划系统文件簿记——取证为本会话一手，无需再派）

### Phase 2: 修正模板 skill 与模板文件
- [x] 建 worktree（/mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113，自 master 4d269d1）
- [x] S1-S3 派发（S1∥S2→S3 全 done：checkpoint 01/02/03）
- [x] 规范召回（S-unit 3 个完成时点——上任务召回卡已读且本任务复用同卡纪律，[recall] 见 progress Phase 2 段）
- [x] 103.6 同步核对清单（四族：同族字面/引用互恰/部署镜像=S5 承接/selftest 断言=CA-9~11）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** general-coder

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6）templates/task_plan.md：S-unit 表 11→10 列+Goal 列名补空格+Phase4 示例表+Batch 实值引导（CA-1~4） | 继承 | worktree 路径 + findings §1 五漂移与 §3 修正文本逐字 | 96 类别 列名=0；对应 S-unit/Phase 在位；Phase4 示例含表 | 15min | 1f/60l/15min | 无 | - | pending |
| S2 | （A6）templates/verification.md：每 VC 条目补 **Verify command** 行格式+判据引导+禁占位说明（CA-5） | 继承 | worktree 路径 + findings §1② 与 attest:244-285 判据 | 模板内 **Verify command** 命中≥1 且含禁占位引导 | 10min | 1f/25l/10min | 无 | - | pending |
| S3 | （A6）plan-template-kit SKILL+references：验证区块契约+10 列序条款（CA-6） | 继承 | worktree 路径 + findings §3 条款草案 | kit 内 Verify command 命中≥2；10 列口径在位 | 15min | 2f/40l/15min | 无 | S1,S2 | pending |

### Phase 3: 按修正后模板纠正他处
- [x] 原 S4（SKILL 注释块）诚实 blocked→**无锚关闭**（CA-7）；亲验发现真传播面×2（SA-19 守卫+dispatch Rule 104）→CA-9/CA-10 派发纠正 done（checkpoint 05）
- [x] 103.6 清单（残留分类=1 负向守卫字面；EA-19 实跑 20/20）
- **V-N:** VC-4, VC-2
- **Status:** complete
- **Executor:** general-coder

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S4 | （A6）task-planner/SKILL.md S-unit 注释块：96 类别列指引→目标列内（An）前缀口径+示例行 10 列（CA-7） | 继承 | worktree 路径 + findings §3 口径文本 | 注释块 10 列口径在位且与新模板一致 | 10min | 1f/12l/10min | 无 | S3 | pending |
| S5 | （A6）清单驱动扫存量：全仓 skills/ 模板/注释面 96 类别列名残留清零+.zcode/plan-templates 覆盖位 diff 判向同步（CA-8） | 继承 | worktree 路径 + grep 清单法（findings §4） | VC-4 残留 grep=0；覆盖位 diff 登记在案 | 15min | 2f/20l/15min | 无 | S4 | pending |

### Phase 4: 冒烟与独立复检
- [x] 冒烟：tmp 计划按新模板渲染+最小填充→check-plan-dispatch 零拒锁项→用完即删 ✅ EXIT:0（checkpoint 06）；冒烟抓到第六漂移（SG-12/13）→CA-11 闭环
- [x] selftest 基线对照（SG 修复后 97/95/2=基线）
- [x] 103.3 复检（general-reviewer：**APPROVED** 五维零 CHANGES，checkpoint 08）
- **V-N:** VC-5, VC-2
- **Status:** complete
- **Executor:** code-runner-agent

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S6 | （A7）冒烟：tmp 计划按新模板渲染+最小填充→check-plan-dispatch 零拒锁→用完即删；selftest 基线对照 | 继承 | worktree 路径 + findings §3 新模板口径+冒烟法（渲染→填最小语义→跑门→删） | 冒烟输出零拒锁项+selftest 尾行=基线（2 预存）落 checkpoint | 15min | 1f/30l/15min | 无 | S5 | pending |
| S7 | （A3）103.3 独立复检：模板契约↔门行为互恰+五漂移修法逐项核 | general-reviewer | worktree 路径 + 变更 diff 清单+findings §1-§3 对照面 | 回执 APPROVED 或整改闭环清单 | 15min | 1f/50l/15min | 无 | S6 | pending |

### Phase 5: 合并、部署与交付
- [x] smart-merge-back（stash 窗口）+三部署位 ALL-SYNCED+三仓 push（源 5a0e410/zcode a2bf941/claude 056e5e0）✅
- [x] 84.14 收尾回读（两轮收敛）+check-complete（exit 0 预期）+归档+kb ✅（kb 入库 tplfix-template-gate-alignment；交付总结 delivery-summary.md；memory 落盘）
- **V-N:** VC-6, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由: ①git 编排+②簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14）
| 轮次 | 发现 | 处置 |
|------|------|------|
| 1 | 五维检查：R1-R3↔VC-1~6 全 PASS；发现 3 项定性：①第六漂移（SG-12/13）=冒烟价值实证，已 CA-11 闭环非遗留 ②CA-7 无锚关闭=诚实处置 ③critic CR 派发被用户拒绝→实测 check-complete CR-GATE 未触发（diff 94 行<阈值），S7 APPROVED 覆盖质量面，非遗留 | 三项分别以 checkpoint/CA 表/门实测留痕 |
| 2 | 零新发现（复扫 CA-1~11 逐行/R→VC 映射/三仓 push 区间/worktree 清理/stash 恢复） | 收敛出口达成，出 outcome=COMPLETE |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | risk（同上任务：在途他任务未提交文件与 scope 无重叠；wt/task-v168-machine-parked 封存不碰） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113` |
| `branch` | `wt/task-tpl-verify-fix-20261113` |
| `merge_back` | `merged(5a0e410，stash 窗口恢复原样，worktree/分支清理零遗留)` |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 兜底（22.3 ①-⑤） |
|-------|---------|---|---|---|-----|------|
| 2 | 模板改出渲染错（init 渲染层占位符误伤） | 7 | 4 | 4 | 112 | ②拆细+S6 冒烟必测 init 渲染（新模板真跑一次） |
| 4 | 冒烟暴露新漂移项 | 6 | 5 | 3 | 90 | ④登记→回 S 单元修→复冒烟（不扩范围盲修） |
| 5 | merge 再次被在途暂存阻断 | 6 | 5 | 2 | 60 | stash 窗口判例复用（上任务两次实证） |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步 | 备注 |
|-------|-----------|---------|------|
| 1-5 | ☑ | 2026-11-13 | 两组结构（任务组 T1-T5+基线组沿用 Rule 106.5） |

## Key Questions
1. .zcode/plan-templates 项目级覆盖是否与仓内模板漂移？（S5 diff 判向回答）
2. 16 类 variant 模板是否也有 96 类别列？（S5 清单回答；有则逐个登记入 scope）
3. 冒烟是否暴露第五处外的新漂移？（S6 回答）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 本计划 S-unit 表直接按 10 列新口径写（目标列内（An）前缀） | dogfood 修正后口径；也验证新写法与门兼容 |
| 不新增 Rule 编号 | 模板层修复归 plan-template-kit 既有条款域（Rule 16/34 模板生命周期），文本优先 |
| 冒烟目录=plans/tmp-smoke-tplfix（用完即删） | plans/ 内临时物不入库；真跑 init 渲染+门校验才是有效冒烟 |
| 验证区块落点=templates/verification.md 模板行结构+kit 契约条款 | 用户实锤「模板缺失验证区块」；vc-gate 判据（attest:244-285）为对照源 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （继承上任务模板-门漂移五项为输入，非本任务错误） | - | - | → findings §1 |

## Notes
- 顺序铁律（R3）：Phase 2（模板 skill+模板）必须先于 Phase 3（他处纠正）完成
- 上任务遗留 NIT×2（todo-sync:36 双标点/selftest 过时文案）不混入本任务（Rule 8.1）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
| 字段 | 值 |
|------|-----|
| `total` | 6（S1-S6 执行单元+S7 复检+SG 修复追加单元，异构编辑/验证） |
| `success` | 7/7（S1-S6+S7；追加 SG 修复单元当轮闭环；S4 诚实 blocked=无锚正确处置） |
| `failed` | 0 |
| `failure_rate` | 0%（S6 PARTIAL 中间态经 SG 修复闭环） |
| `sampled_pass` | 8/8（各单元自检+主进程亲验：残留分类/SG 单跑对照/S6 六步/VC-2~6 终验） |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否 / Q2:无共享写（S1∥S2 异文件） / Q3:能 |
| `rollback_point` | worktree 分支 wt/task-tpl-verify-fix-20261113（已合并清理；合并后回滚点=git revert 5a0e410） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|-------|------|
| 子代理执行 Phase 数 / 总 Phase 数 | 3/5（Phase 2、3、4） |
| 主进程直做 Phase 清单 | Phase 1（白名单②簿记）、Phase 5（白名单①②） |
| 委派率 | 0.6（直做=Phase 1 白名单②/Phase 5 白名单①②，目标 verdict=ok 终验贴 JSON） |
| 激活子代理数 | 9（S1-S7 各 1+SG 修复 1+blocked S4 重定义；critic CR 派发被用户拒绝未计入） |
| 最大并行宽度 | 2（S1∥S2） |
| 串行化例外理由 | S3 依赖 S1/S2 产物；传播面依赖口径定稿；S6 依赖全部落地；真依赖链 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-13 | general-coder | task_plan 模板四漂移修正 | done | 96 类别=0/列名在位/Phase4 表例/Batch 引导；diff 20+/14- | 模板 :143,338,340,357-360,496-507 | §3.1 消费 | subagent-state/01-general-coder-s1.md | - / 0 / ☑ |
| 2 | 2026-11-13 | general-coder | verification 模板验证区块 | done | VC 三行结构+判据锚注释；Verify command=10 | 模板 :12-36,56-59,75-78 | §3.2 消费 | subagent-state/02-general-coder-s2.md | - / 0 / ☑ |
| 3 | 2026-11-13 | general-coder | kit 双契约条款 | done | template-mapping:232-238+guide:167 指针 | kit 两文件 8+ | §3.3 消费 | subagent-state/03-general-coder-s3.md | - / 0 / ☑ |
| 4 | 2026-11-13 | general-coder | SKILL 注释块口径（原 CA-7） | blocked | 诚实 blocked：SKILL.md 零命中→无锚关闭 | grep 实测 0 命中 | CA-7 处置 | subagent-state/04-general-coder-s4.md | - / 0 / ☑ |
| 5 | 2026-11-13 | general-coder | 传播面纠正（dispatch+SA-19） | done | dispatch 三锚新口径+SA-19 翻转；selftest 20/20 | dispatch:244,256,278/selftest:97-99 | CA-9/10 | subagent-state/05-general-coder-propagation.md | - / 0 / ☑ |
| 6 | 2026-11-13 | code-runner-agent | 冒烟+基线回归 | partial→闭环 | 渲染零泄漏/门 EXIT:0/清理干净；抓到 SG 第三 FAIL（第六漂移） | checkpoint 06 六步原文 | §4/CA-11 | subagent-state/06-code-runner-smoke.md | - / 0 / ☑ |
| 7 | 2026-11-13 | general-coder | SG-12/13 断言翻转 | done | SG 23/23；全量 97/95/2=基线 | selftest:13,148-158 | CA-11 | subagent-state/07-general-coder-sgfix.md | - / 0 / ☑ |
| 8 | 2026-11-13 | general-reviewer | 独立复检+对齐审查 | done | **APPROVED** 五维零 CHANGES | checkpoint 08 | 复检回执 | subagent-state/08-general-reviewer-s7.md | - / 0 / ☑ |
| 9 | 2026-11-13 | Simple Agent | kb 条目精炼落库 | done | tplfix-template-gate-alignment.md 入库 INDEX:1 命中 | INDEX 命中行 | knowledge/ | subagent-state/10-simple-agent-kb.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）
| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 触发信号: 命中 rule-enhancement-type.md
- Rule 34.3②: 已知类型不产生沉淀评估区块
- 终验必查: check-template-type.sh gate exit 0
