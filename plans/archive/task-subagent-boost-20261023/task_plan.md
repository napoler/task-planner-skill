# Task Plan: 子代理激活率与并行推进率制度化强化（Rule 96）
<!-- frontmatter（Rule 16/34.1/38.7） -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）
- **R1**: 「有些任务可以通过子代理…子代理中是可以切换模型，就是切换大模型或小模型，这种来提高质量，或者说节省成本，各种的灵活优化。但是当前的情况，它都放在主代理执行，就没有这种优化的力度…存在严重的就是子代理拆分不够使用不够频繁的行为，就是很多任务都可以…放在子代理中执行，但是实际运行中缺少这种机制。比如说最简单的制定计划这些，还有就是调研分析各种都可以拆分到子代理」<sub>（[目标]）</sub>
- **R2**: 「存在子代理中是可以进行并行推进的，这才是最大的优势之一。但是当前的情况利用率非常之低。比如说简单的行为吧。我发现很多时候并行子代理只有一个，那么这就是说明问题。很多时候很多任务是可以并行执行的，但是实际执行的时候它都只会开一个并行子代理」<sub>（[目标]）</sub>
- **R3**: 「我希望你可以优化一下，比如说提高子代理的激活率。也就是说，在遇到什么问题，比如说遇到制定计划可以子代理，遇到分析问题可以子代理…让模型主动去开启子代理来执行任务。还有就是并行的时候，比如说可以在制定计划就中明确掉，哪些是可以使用子代理，哪些是可以并行执行…是否存在互相依赖，如果不依赖，那么就可以互相并行执行」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | critical-rules.md 存在激活默认矩阵条款（子代理触发类别清单+主进程亲自执行=例外需理由），模板/调度承载面同口径 |
| R2 | VC-1, VC-3 | 存在并行硬条款（依赖标注+无依赖并行组+同消息并发+指标留痕），selftest 断言可机械判定 |
| R3 | VC-2, VC-4, VC-6 | 模板承载（计划期并行组标注）+全量回归绿+部署位生效（新会话可加载） |

### 🗣️ 用户会话逐字记录（Rule 80 专档指针）
- **专档路径**：`plans/task-subagent-boost-20261023/user-session-log.md`
- **只写不改铁律**：条目 append-only（Rule 80.2）；恢复协议：先读专档再读本计划

## 🧮 根源覆盖表（Rule 53.1）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划期拆分 | 无"必须派发"默认档，主进程亲做无门槛 | Rule 96 激活默认矩阵+例外白名单条款 | VC-1 |
| 计划期并行标注 | 依赖关系不显式，并行组声明流于形式 | 计划模板并行组标注强化条款 | VC-2 |
| 执行期派发 | 执行体串行惯性，无同消息并发纪律 | Rule 96 并行组同消息派发硬条款 | VC-1 |
| 度量闭环 | 激活数/并行宽度无留痕无报告 | 指标留痕子条+总结报告字段 | VC-3 |
| 制度生效 | 规则改了部署位不生效 | 纪元级联+回归+部署位同步 | VC-4, VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1-R3 原文；VC-1~VC-6；新增 Rule 编号=96；管辖二分（禁改写 21.4/22/46/52 既有语义，只增量互引）；§十一 worktree 隔离 | task_plan.md 本表+Goal |
| 🔀 可变量 | Rule 96 子条划分与措辞、模板落点选择、S-unit 批次切分、selftest 断言条数、修复轮次 | - |
| 📈 学得量 | 锚点形态/纪元级联实测清单、部署位实测差异 → findings.md | findings.md |

## Goal
在 task-planner 技能族新增 Rule 96（子代理激活默认化 + 并行推进硬条款）并完成模板承载、机器门、纪元级联回归与部署位同步，使"可委派默认委派、无依赖默认并行"在新会话成为可执行默认姿态。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | task-subagent-boost-20261023 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023` |
| `scope_files` | `skills/task-planner/**`（critical-rules.md/SKILL.md/templates/*）、`skills/task-planner/scripts/selftest-*`、registry、部署位副本 |
| `interaction_mode` | `silent` |
| `对齐审查` | required（收尾 alignment-review 视角 CR，Phase 4 内执行） |
| `自动超时默认项` | 全部询问点默认=推荐项+5min（44.2 低区分度项直裁登记） |
| `new_rule` | `96` |
| `质量审查工具` | alignment-review（对齐）+ critic（挑刺）双视角，登记于 Phase 4 |

## ✅ Verification Contract
> **验证独立性**：验证动作由工作流独立子代理执行；主进程自测不作数（Rule 33.3）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 96 条款落地：编号 96 经 rule-reserve 无冲突，含 ①激活默认触发类别矩阵 ②主进程亲自执行=例外需理由 ③计划期依赖标注+无依赖并行组 ④执行期同消息并发 ⑤指标留痕（激活数/并行宽度）子条 | Read+grep worktree/merged 文件 | `skills/task-planner/critical-rules.md` §96 |
| VC-2 | 承载面同步：SKILL.md 级联/编排段指针、subagent_dispatch 与 task_plan 模板含新条款锚定措辞 | selftest 断言/ grep | 新 selftest 断言输出 |
| VC-3 | 机器门落地：新增 selftest 脚本全绿并登记 registry.tsv | 运行新脚本 exit 0 | `bash skills/task-planner/scripts/selftest-subagent-activation.sh` |
| VC-4 | 全量回归零破坏：selftest 全套 FAIL=0（纪元级联 1-94→1-96 后） | 运行全量 runner | worktree 内全量输出 |
| VC-5 | CR 双视角通过：alignment-review 视角 + critic 视角均 APPROVED（或 BLOCKER 全闭环） | 检查点 verdict | `subagent-state/*cr*.md` |
| VC-6 | 合并+部署生效：master `merge --no-ff` 完成；zcode/cursor 部署位变更文件 diff=0（任一位写权限被拒则如实登记 PARTIAL） | git log + diff/cmp | merge commit + 部署对账输出 |

**终验规则**：全部 VC → COMPLETE；有遗留 → PARTIAL（列明）；3 次重试无效 → BLOCKED。
> `code_review: required` → 终验前必须过 CR Gate（Phase 4）。

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2 |
| **裁决** | **solved**（R1/R2 目标本体达成：条款+模板+机器门+级联+部署全链落地；另记：终验 outcome 按 Rule 26.3 程序帽=最高 PARTIAL——执行期 findings/progress 回填滞后违规已登记 progress.md Error Log 第 5 行并在本收口闭合，目标达成与程序合规两轴分记） |
| **解决证据锚** | R1=skills/task-dispatch/references/critical-rules-dispatch.md:192（96.1 激活默认档矩阵 A1-A7+主进程窄白名单）+:200 起（96.2 模型分档），selftest SA-02..05 PASS（本收口会话于合并后 master 复跑：`bash skills/task-planner/scripts/selftest-subagent-activation.sh` → 15 PASS=15 FAIL=0 EXIT=0）；R2=同文件 96.3/96.4/96.5，SA-06..08 PASS+模板承载（templates/task_plan.md:327/:495-497、templates/subagent_dispatch.md:34）；部署生效=merge cecacfb+两部署位 16/16 diff=0（subagent-state/9-merge-deploy.md §3） |
| **未解决面+原因** | solved 无必填。遗留风险面（非 R1/R2 目标未达，详 delivery-summary 风险节）：①README/docs 纪元级联欠账（README.md:36/:68/:81/:123、docs/ARCHITECTURE.md 六处仍 1-94）；②部署误伤历史遗留镜像树 7 文件待用户授权处置；③全量 93 脚本回归输出未归档 plan 目录（gate=绿为工作流记录）；④96.3 两 S-unit 例外措辞歧义（8b 问题②） |
| **已排除路径** | 不适用（solved） |
| **下一步建议** | ① `skills/task-planner/README.md`+`docs/ARCHITECTURE.md`：纪元 1-94→1-96 级联随下次部署 lane 一并同步；② `~/.zcode/skills/skills/` 与 `~/.cursor/skills/skills/` 历史遗留镜像树：请用户裁决正确位回写还原或整树清理；③ `run-selftests.sh:11/:79` 注释钉校真 93/88（一行 sed）；④ 新会话按 96.5 指标（激活子代理数/最大并行宽度）观察实效后评估是否再加码；⑤ §十一.3.5 收尾：`git worktree remove` + `git branch -d wt/task-subagent-boost-20261023`（实测 worktree 仍在位未清理） |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 调研映射 | 三路并行冻结规则承载面/纪元锚/部署位与编号 | 检查点 1/2/3 四节齐（路径+行号） | S1-S3/Phase 1 | complete（subagent-state/1/2/3-*.md 齐） |
| G2 | 起草 | Rule 96 全文+逐文件编辑计划+断言清单定稿 | draft-rule96.md 存在且含六子条+编辑表 | S4/Phase 2 | complete（draft-rule96.md 六子条+6 编辑+15 断言；检查点 4） |
| G3 | 实现 | worktree 内条款文本+机器门+级联全部落地 | git status 变更清单与编辑计划一致 | S5-S6/Phase 3 | complete（8 文件 +135/-10=e319ee3；检查点 5/6） |
| G4 | 验证 | 回归 FAIL=0 且 CR 双 APPROVED | 全量 runner 输出+CR 检查点 | S7-S8/Phase 4 | complete（回归门=绿 per 工作流 gate+CR 双 APPROVED；全量输出未归档 plan 目录已注记） |
| G5 | 收口 | merge 回 master+部署位 diff=0+簿记交付 | merge commit+对账输出+delivery-summary | S9-S10/Phase 5 | complete（cecacfb+16/16 diff=0+delivery-summary 落盘） |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | `skills/task-planner/critical-rules.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/templates/**` | 其他 skill 文件 |
| 机器门 | `skills/task-planner/scripts/selftest-*.sh`、registry 台账 | scripts/ 其他脚本（rule-reserve 台账写入除外） |
| 簿记 | `plans/task-subagent-boost-20261023/**` | 其他计划目录（含 task-nopause-execfirst-20261023 禁触碰） |
| 部署位 | zcode/cursor 登记位（Phase 5 按映射表同步） | 运行态其他基础设施 |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|------|-----------|----------------|----------------|---------|
| CA-1 | critical-rules.md#Rule 96（新增段） | 新增 | 增量 | 「提高子代理的激活率…主动去开启子代理」 | R1/R3 | 落激活默认矩阵+例外白名单子条 |
| CA-2 | critical-rules.md#Rule 96（新增段） | 新增 | 增量 | 「并行子代理只有一个…如果不依赖，那么就可以互相并行执行」 | R2/R3 | 落依赖标注+并行组+同消息并发子条 |
| CA-3 | SKILL.md（级联+编排指针行） | 修改 | 增量 | 「可以在制定计划就中明确掉，哪些是可以使用子代理」 | R3 | 级联 1-94→1-96+编排段指针 |
| CA-4 | templates/subagent_dispatch、task_plan 模板 | 修改 | 增量 | 「制定计划就中明确掉，哪些…可以并行执行」 | R3 | 模板加并行组/激活默认锚定措辞 |
| CA-5 | scripts/selftest-*（新脚本+registry+纪元锚） | 新增·修改 | 增量 | （制度生效手段） | R3 | 新断言+registry 登记+级联更新 |
| CA-6 | 部署位（zcode/cursor 登记位） | 更新 | 增量 | （新会话生效） | R3/VC-6 | 变更文件同步+对账 |

## 📚 必要知识储备
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | critical-rules.md Rule 21.4/22/46/52/59 | 仓内 `skills/task-planner/critical-rules.md` | 必读 | ☑ |
| 项目内部 | worktree-isolation.md | `skills/task-planner/references/worktree-isolation.md` | 必读 | ☑ |
| 项目内部 | Rule 94 部署任务先例 | `plans/`（886f060 归档，含 zcode/cursor 位映射） | 参考 | ☑ |
| 项目内部 | selftest 脚本族与 registry 约定 | `skills/task-planner/scripts/` | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 子代理激活与并行推进在技能层有条款（21.4/§一矩阵）但缺"默认档+硬条款+度量"，导致实践中主进程亲做、并行宽度≈1。解决后交付=规则+模板+机器门+部署位全链生效。方法=增量立法（Rule 96）+承载面同步+selftest 断言+CR 双视角+合并部署。
- [x] 解决后结果能交付（新会话加载生效）
- [x] 不解决则诉求落空
- [x] 方法清晰可执行

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|----------|--------------|--------------|
| 全部 | LOCAL-ONLY（豁免声明：制度内部规则任务，证据源全在仓内：规则文本/selftest/部署位/归档计划，无外部数据依赖） | - | 仓内 Grep/Read | findings 小节 | 不适用 |

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象 | 取证方式 | 落盘锚 | 状态 |
|--------|---------|---------|--------|------|
| ① 自身样本 | 现行 21.4/22/46/52 条款文本+dispatch/task_plan 模板 | Explore 映射（S1） | 检查点 1 | ☐ |
| ② 对标样本（58.2 强制） | Rule 94 部署任务先例（886f060）+v110 并行演进判例（21.4 落地先例） | 读归档计划+git log（S1/S3） | 检查点 1/3 | ☐ |
| ③ 外部约束 | 用户宪法 §一/§十一（委派矩阵/worktree 铁律）；Rule 59 粒度硬门 | 读载体文件（S1） | 检查点 1 | ☐ |

## Current Phase
Phase 5（complete——收口完成）

## Next Step
交付后主进程动作：check-complete exit 0 → set-active-plan --clear → archive-plan；同批 §十一.3.5 清理（git worktree remove + git branch -d wt/task-subagent-boost-20261023）；push 未获授权不执行

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | Agent 子代理×3 并行（Explore/锚点扫描/部署位勘察） | 三路只读映射互不依赖，同一消息并行 |
| Phase 2 | Agent 子代理 planner | 起草在隔离上下文完成，主进程只收结论 |
| Phase 3 | Agent 子代理 executor×2 并行 | 文本编辑与脚本/级联文件集不相交 |
| Phase 4 | world.run 门（selftest runner）+Agent Verifier/critic | 回归机器可判；CR 需独立视角 |
| Phase 5 | Agent 子代理（Git Master/plan-bookkeeper 类） | 合并与簿记机械执行 |

**workflow 编排判定（Rule 40.4）**: 命中 39.8「用户点名」——用户经 /workflow 显式要求动态工作流承载本任务 → CreateWorkflow 路由，执行期按 39.8 三件套。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；未使用 /goal 命令。

## Phases

### Phase 1: Requirements & Discovery（三路并行调研映射）
- [x] 规则承载面映射（激活/并行/委派相关条款+模板+缺口）——含落点校正：Rule 96 正文落卫星 dispatch.md（1-rule-mapper.md §一）
- [x] selftest 纪元锚行清单冻结（1-94 全形态）——2-anchor-mapper.md §0：scripts/ 宽容正则化天然覆盖 1-96
- [x] 部署位映射+Rule 96 编号空闲复核——3-deploy-reserve.md §1+rule-reservations 尾行
- [x] 三检查点落盘 `subagent-state/{1,2,3}-*.md`（mtime 01:03/01:08/01:20）
- **V-N:** VC-1, VC-2（承载面与级联输入冻结）
- **Status:** complete（2026-10-24）
- **Executor:** Explore（general，workflow fan-out×3）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 映射激活/并行/委派条款承载面与缺口 | Explore(general) | 检查点 plans/task-subagent-boost-20261023/subagent-state/1-rule-mapper.md；扫 skills/task-planner/{critical-rules.md,SKILL.md,templates/} | 检查点含承载表（文件+行号+现状+缺口） | 15min | 2f/100l/15min | 无 | - | done |
| S2 | 冻结 selftest 纪元锚行清单（1-94 全形态） | Explore(general) | 检查点 …/2-anchor-mapper.md；扫 skills/task-planner/scripts/ | 检查点含 file:line:形态 级联清单 | 15min | 2f/100l/15min | 无 | - | done |
| S3 | 部署位映射+96 编号空闲复核 | Explore(general) | 检查点 …/3-deploy-reserve.md；读 plans/ 部署先例+rule-reserve 台账 | 检查点含部署位路径表+编号结论 | 15min | 2f/100l/15min | 无 | - | done |

### Phase 2: 起草 Rule 96（draft + 编辑计划）
- [x] 六子条全文（激活默认矩阵/例外白名单/依赖标注并行组/同消息并发/指标留痕/管辖边界）——draft-rule96.md §2（01:30 落盘）
- [x] 逐文件编辑计划（锚点→新文本）+ selftest 断言清单——draft §3 六编辑+§4 SA-01..15（检查点 4 acceptance 3/3）
- **V-N:** VC-1, VC-2
- **Status:** complete（2026-10-24）
- **Executor:** planner（general）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S4 | 产出 draft-rule96.md（全文+编辑计划+断言清单） | planner(general) | 检查点 1/2/3 三份+draft 落盘 plans/task-subagent-boost-20261023/draft-rule96.md | 六子条齐+每处编辑带锚点 | 15min | 2f/100l/15min | 无 | S1、S2、S3 | done |

### Phase 3: Implementation（worktree 内并行落地）
- [x] S5 条款文本落地（critical-rules.md/SKILL.md/templates）——4 文件 10 处编辑锚全命中（5-text-editor.md 逐文件状态表）
- [x] S6 机器门落地（新 selftest+registry+纪元级联+96 预留登记）——SA-01..15 全绿+rows=93/actual=93；编辑 1 孤儿面经 owner 裁决扩射程补落（6-machine-gate.md 批次 E/F）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete（2026-10-24；未 git commit 遵守，合并归 S9）
- **Executor:** executor（general，workflow 并行×2）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | 按 S4 编辑计划在 worktree 落条款文本 | executor(general) | WT=/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023；draft-rule96.md 编辑表 | 逐文件 grep 锚点命中 | 15min | 2f/100l/15min | 无 | S4 | done（射程外编辑 1/6 如实上报交接） |
| S6 | 新 selftest+registry+纪元级联+预留登记 | executor(general) | 同 WT；S4 断言清单+S2 级联清单（批次执行,每批 ≤2 文件） | 新脚本 exit 0+级联清单清零 | 15min | 2f/100l/15min | 无 | S4 | done（含编辑 1 扩射程补落，15/15 绿） |

### Phase 4: Testing & Verification（回归门+CR 双视角）
- [x] 全量 selftest FAIL=0（修复循环 ≤3 轮）——回归门=绿（工作流 gate 记录）；plan 目录归档证据=检查点 6（15 个 dispatch 相关 selftest 重跑全绿）+检查点 8b（24 脚本串行 rc=0）；注：93 脚本全量 runner 输出未归档 plan 目录（subagent-state/7-regression.md 不存在，如实登记）
- [x] alignment-review 视角 + critic 视角双检——双 VERDICT: APPROVED（8a:8 / 8b:41）
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete（2026-10-24）
- **Executor:** Verifier（general）+ critic（general）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | 全量回归+修复循环,绿后 worktree 提交 | Verifier(general) | WT 全量 runner 输出 | FAIL=0+commit 生成 | 15min | 2f/100l/15min | 无 | S5、S6 | done（回归门=绿 per 工作流 gate；e319ee3；无独立检查点，归档证据见检查点 6/8b） |
| S8 | CR 双视角（对齐+挑刺）出 verdict | critic(general) | WT git diff+S4 draft | 双 verdict 检查点落盘 | 15min | 2f/100l/15min | alignment-review | S7 | done（8a/8b 双 APPROVED） |

### Phase 5: Delivery（合并部署+簿记收口）
- [x] merge --no-ff 回 master+关键文件复验——cecacfb（双亲 6d60e02+e319ee3，零冲突；git log 本收口亲验）
- [x] zcode/cursor 部署位同步+diff 对账——16/16 diff=0+锚复核一致；事故=镜像树 7 文件误覆盖待授权（9-merge-deploy.md §4）
- [x] 簿记收口（progress/裁决/delivery-summary）——本收口（S10）完成
- [ ] 归档：check-complete exit 0 后 set-active-plan --clear + archive-plan（交付后主进程动作，本收口不做；worktree/分支清理同批，实测仍在位）
- **V-N:** VC-5, VC-6
- **Status:** complete（2026-10-24；S9+S10 范围；归档项=交付后主进程动作）
- **Executor:** 主进程→委派 Git Master/plan-bookkeeper（workflow 内子代理）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | 合并回 master+部署位同步对账 | Git Master(general) | WT 干净+S3 部署位映射 | merge commit+diff=0 表 | 15min | 2f/100l/15min | 无 | S7、S8 | done（cecacfb+16/16 diff=0；检查点 9） |
| S10 | 簿记收口+delivery-summary 落盘 | plan-bookkeeper(general) | plans/task-subagent-boost-20261023/ 三文件 | delivery-summary 五要素齐 | 15min | 2f/100l/15min | 无 | S9 | done（本收口：三文件回填+delivery-summary+attest 重锁） |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（主仓仅 plans/ 未跟踪目录；skills 面无未提交变更；并行任务 task-nopause-execfirst 仅占编号 95 不相交） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023` |
| `branch` | `wt/task-subagent-boost-20261023` |
| `merge_back` | `merged(cecacfb)`（merge --no-ff 双亲 6d60e02+e319ee3，ort 零冲突；worktree+分支未清理=遗留动作，见 Next Step） |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|--------------|
| Phase 3 | 级联清单遗漏致回归红 | 6 | 5 | 3 | 90 | S2 清单驱动+修复循环 ≤3 轮（22.3② 拆细重派） |
| Phase 4 | 回归 3 轮仍红 | 8 | 3 | 2 | 48 | 停环登记 BLOCKED 面向用户（22.3⑤），禁无限打转 |
| Phase 5 | 部署位写权限被拒 | 5 | 4 | 2 | 40 | 如实登记 PARTIAL+留待授权，禁静默跳过（54 执行诚实） |

## 🔁 原生 Todo 同步（S1–S5）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1-5 | ☑（G1-G5 映射） | 2026-10-23 | 工作流阶段即 todo |

## Key Questions
1. 激活默认与"勿过度委派"的边界如何措辞才能既提率又不为单行命令付派发开销？→ 例外白名单子条解决（S4 起草裁决）
2. 并行组声明的机器可判定形态是什么？→ 计划模板依赖列+执行体同消息条款+指标留痕断言（S4/S6）
3. 96 落地后 95（并行任务）落地时级联怎么办？→ 级联写宽容形态，95 任务按其自己清单再级联（登记 Decisions）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 96 增量立法，不改写 21.4/22/46/52 | 管辖二分（Rule 87/13.3），既有条款语义冻结 |
| 编号取 96 | 95 已被并行任务 task-nopause-execfirst-20261023 占用（其 Goal 明示 Rule 95） |
| 承载工作流 = dynamic-workflow（用户点名 /workflow） | 39.8 用户点名；拓扑=3 并行调研→起草→2 并行实现→回归门+CR→合并部署 |
| worktree 隔离（已建） | §十一 P0：技能文件修改强制隔离 |
| 部署位同步纳入 Phase 5 | 用户明示指向部署位技能（R3"新会话生效"意图）；对账 diff=0 为准 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| 编辑 1 孤儿面：S5/S6 射程均不含 task-dispatch 卫星文件，新 selftest 首跑 10 红 | 1 | owner 裁决扩射程+S6 补落（逐字节 diff=0），复跑 15/15 绿 | 任务书写入卫星落点射程（详 progress.md Error Log 第 1 行） |
| 部署 cp 未剥离 skills/ 前缀误伤遗留镜像树 7 文件 | 1 | 误新建已 rm；7 覆盖文件待用户授权，正确位 16/16 diff=0 | cp 前 dry-run 列目标+逐文件 ls（详 Error Log 第 2 行） |
| SA-14 设计锚失配（59.4 无「超档拆细不升档」字串） | 1 | 补 59.4 真实原文锚守卫增强，断言数仍 15 | 断言锚 grep 亲证后入设计稿（详 Error Log 第 3 行） |
| findings/progress 回填滞后触发 plan-compass 升级警告 | 1 | 本收口归并回填闭合；终验 outcome 按 Rule 26.3 帽=最高 PARTIAL | Phase 边界安排簿记子代理增量回填（详 Error Log 第 5 行） |

## Notes
- 工作流运行记录 = 执行事实源；主进程回收结论后回填本计划 Handoff/裁决区块
- 修复循环上限 3 轮，超限 BLOCKED 升级用户

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4 — 终验前填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 5 / 5（Phase 1-4 全子代理执行；Phase 5=S9 合并部署子代理+S10 簿记收口子代理） |
| 主进程直做 Phase 清单 | 无（主进程仅编排/派发/结论回收+本收口簿记归并=25.3 白名单②） |
| 委派率 | 100%（5/5）；96.5 指标留痕：激活子代理数=10（S1-S6、S8a/S8b、S9、S10，检查点证实）/S7 回归由 world.run 门承载；最大并行宽度=3（并行组① S1/S2/S3）；并行组共 3 组（组①调研、组②实现 S5/S6、组③CR 8a/8b） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
> 执行事实源 = dynamic-workflow run 记录（每子代理一卡+检查点落盘）；主进程回收终态后回填本表关键行。

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|--------|
| 1-3 | 2026-10-24 01:03-01:20 | Explore×3 | 承载面/纪元锚/部署位映射 | done | 落点校正=Rule 96 正文落卫星 dispatch.md；scripts/ 宽容正则免改；96 编号空闲 | 检查点 1 §一/2 §0/3 §1 | findings·勘察 | subagent-state/{1,2,3}-*.md | 并行组①（宽度 3） |
| 4 | 2026-10-24 01:27-01:30 | planner | 起草 Rule 96 | done | 六子条全文+6 编辑计划+15 断言设计；增量合规零改写 | 检查点 4 acceptance 3/3 | findings·起草 | draft-rule96.md | 依赖 1-3 |
| 5-6 | 2026-10-24 01:54-01:55 | executor×2 | 文本+机器门落地 | done | 4 文件 10 编辑锚命中；SA-01..15 绿+registry 配平；编辑 1 孤儿面经 owner 裁决扩射程补落 | 检查点 5 状态表/6 批次 A-F | findings·实现 | subagent-state/{5,6}-*.md | 并行组② |
| 7 | 2026-10-24（Phase 4） | Verifier | 全量回归+修复循环 | done | 回归门=绿（world.run 门记录）；无独立检查点归档 | 检查点 6 §复跑（15 脚本绿）+8b §二（24 脚本 rc=0） | progress·Phase 4 | （7-regression.md 未落盘，如实登记） | 全量输出未归档 plan 目录 |
| 8 | 2026-10-24 02:08/02:14 | critic×2 | CR 双视角 | done | 双 VERDICT: APPROVED；nit/问题清单均非 BLOCKER | 8a:8 / 8b:41 | findings·CR | subagent-state/{8a,8b}-cr.md | 并行组③ |
| 9 | 2026-10-24 02:21 | Git Master | 合并+部署同步 | done | merge=cecacfb 零冲突；16/16 diff=0；镜像树事故如实登记待授权 | 检查点 9 §1/§3/§4 | findings·部署 | subagent-state/9-merge-deploy.md | 未 push |
| 10 | 2026-10-24（本收口） | plan-bookkeeper | 簿记+交付 | done | 三文件回填+delivery-summary 五要素+attest 重锁 | 本目录四文件 | 全文 | delivery-summary.md | 依赖 9 |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → general 兜底（16 类之外：技能规则制度化任务）
- Rule 34.3②: 终验时评估沉淀 variant（倾向不沉淀：单发型制度任务）；处置登记：不沉淀理由=载体为 critical-rules 规则条款而非任务类型模板
