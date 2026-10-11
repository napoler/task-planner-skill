# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:01a-explore] S1 检索链条款盘点

**条款清单（40 条 file:line）**

critical-rules.md（/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md）：
- Rule 63 节头 :785 — 检索优先与反推诿纪律总纲
- 63.1 目标公理 :789 — 解决问题=唯一不变目标；推诿=违规
- 63.2 检索优先 :791 — 知识缺口第一反应=主动检索；四步链（本地→帮助面→官方文档/网络→社区）
- 63.3 反推诿禁令 :793 — 「不知道」穷尽检索链并附证据前禁止作答
- 63.4 有理有据边界 :795 — 检索结论附来源锚；禁编造；查证无解按 58.5 收场
- 63.5 互补关系 :797 — 与 Rule 60/22.3.0/35/41/58 触发面分工声明
- 63.6 机制 :799 — selftest-research-first.sh 守护 + subagent_dispatch 契约行 + C44
- Rule 22.3.0 资料先行档 :178 — 失败>=2 次后先走资料档再换道
- Rule 22.3.0b 换道义务 :179 — 失败>=2 次强制换道评估序
- Rule 41.1 消解优先 :444 — 遇问题第一反应=自动消解；消解链含 5 替代路径检索
- Rule 41.4 升级前置清单 :448 — AskUser/STOP 前必过消解清单
- Rule 58 节头 :674 — 调研分析证据纪律总纲
- 58.1 证据面清单 :678 / 58.2 对标取证强制 :680 / 58.3 结论-证据锚定 :682 / 58.4 手段目标二分 :684 / 58.5 完成裁决门 :686 / 58.6 因果链 :688 / 58.7 机制 :690
- Rule 60 节头 :696 — 主动解决问题泛化行为原则
- 60.1 :700 / 60.2 枚举替代方案 :702 / 60.3 质量损失排序 :708 / 60.4 :714 / 60.5 :716 / 60.6 :718 / 60.7 :724 / 60.8 机制 :730

SKILL.md（/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md）：
- critical-rules.md 描述行 :9 / 产出落盘映射 :113-125 / C41 :223 / C44 :227 / Rule 58 摘要 :347 / Rule 60 摘要 :349 / Rule 63 摘要 :352 / github 调研行 :424-425 / 综合调研行 :429 / 五档兜底行 :477 / 调研类操作外迁 :525-527

skill-collaboration.md（/mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md）：
- research-assistant 行 :61 — 网络调研路由 / browser-use 行 :62 — 网页访问路由

subagent_dispatch.md（/mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md）：
- 检索优先契约 :27 — 子代理侧 Rule 63 传播

**三空白面标注（S1 核心结论）**

1. 计划期强制调研需求分析（本地可解/需调研/必须联网三态 + 关键词）：**空白**——63.2 管「不知道时检索」、22.3.0 管「失败>=2 次后检索」，均不覆盖计划期预分析；task_plan 模板无对应区块
2. 执行期反死磕（不等失败计数的主动检索触发）：**空白**——63.2 仅限知识缺口、22.3.0 需失败>=2 次；「没不知道但自研低效」面无覆盖（用户 R1 核心痛点）
3. 外部工具（浏览器/GitHub CLI）强制使用与安装建议：**空白**——skill-collaboration.md:61-62 为「可用时路由」非「强制使用」；全仓无「必须使用 gh CLI/浏览器」条款、无「缺失→建议安装」机制

**引用点确认（避免重复定义）**：75.1 引用 63.2 四步链+22.3.0 动作序；75.2 引用 63.2+22.3.0b 新增「不等失败计数」触发面；75.5 引用 60.2+skill-collaboration.md:61-62 新增「强制+安装建议」

**附带发现**：SKILL.md:527 引用的 research-routing.md 在 plan-collab-router/references/ 下不存在（悬空引用，登记不修——非本任务 scope）

#### [sub:01b-explore] S2 模板触点与插入锚

**① templates/task_plan.md 区块结构（关键行号）**：:8 用户需求原文 / :15 R→VC 映射 / :20 根源覆盖表 / :30 Goal / :38 Code Review 配置 / :57 VC / :87 核心目标裁决 / :104 Goal 单元表 / :116 执行范围限制 / :137 必要知识储备 / :156 核心问题定义 / :173 证据面清单 / :187 Current Phase / :194 Next Step / :203 工具选择 / :217 Phases / :308 隔离决策 / :325 FMEA / :340 Todo 同步 / :356 Key Questions / :367 Decisions / :379 Errors / :392 Notes / :404 Drift Log / :413 Batch Report / :431 委派统计 / :443 Handoff 表

**安全插入锚**：「🔍 调研需求与检索计划」区块插 :171 后 / :173 前（核心问题定义段末→证据面清单前）。解析脚本引用面（check-plan-dispatch/check-complete/sync-todos/attest）均不敏感于此插入。**禁插入**「执行范围限制」区块（:116-135）中间——该区块被 plan_parse_scope 提取。

**② 4 variant 调研触点现状**：
- research-type.md：有调研执行面（:20-23 VC 行/:36 执行范围/:51 知识储备/:63-95 Phase 行），**缺**判定面/现成方案/GitHub/浏览器触点
- code-edit-type.md：**完全空白**（仅 :58 引用格式说明）
- script-dev-type.md：**完全空白**
- deployment-type.md：**完全空白**（:41/:76/:106 为文件范围/环境清单/CI 配置，非调研触点）

**③ plan-template-kit 插入点**：
- template-guide.md：§2.6「新模板调研需求判定条目」插 :91 后 / :94 前（§2.5 末→§三 前）；备选 §五场景 6（:234-243 后/:247 前）
- template-mapping.md §九：:254-300（机制适用性矩阵）；注记插 :299 后 / :301 前

**关键结论**：4 variant 均无「调研需求判定」触点；模板插入点全部避开解析锚；脚本解析面无冲突。

#### [sub:03-main] S3 级联锚面盘点（主进程 grep 实测）

**SKILL.md 计数位（当前=master 实态，已被并行会话推进）**：
- :9 — "Critical Rules 全集 1-69+70" 形态（需确认当前值）
- :298 — "Critical Rules 1-72（含 Rule 40-71 全集…+ Rule 72 决策分级与用户打断纪律）"
- :385 — References 表行 "Critical Rules 1-72（…+Rule 70（task-v155）+Rule 72（task-v160））"
- ⚠️ 并行会话（v160）已在 master 推进计数至 1-72；本任务级联目标=1-75（覆盖 72/73/74 在途）

**脚本宽容锚清单（需扩 7x 纪元覆盖 75）**：
| 脚本 | 当前锚 | 处置 |
|------|--------|------|
| selftest-self-resolution.sh:81 | `1-(6[0-9]|7[0-2])` | 扩 `7[0-5]` |
| selftest-tool-selection.sh:64 | `1-(6[0-9]|7[0-2])` | 扩 `7[0-5]` |
| selftest-root-resolution.sh:114 | `1-(5[3-9]|6[0-9]|7[0-2])` | 扩 `7[0-5]` |
| selftest-conclusion-discipline.sh:72 | `1-7[0-2]` | 扩 `1-7[0-5]` |
| selftest-research-first.sh:76 | `1-(69|71|72)` | 扩 `1-(69|71|72|75)` 或改宽容 |
| selftest-requirement-coverage.sh:132 | 注释称覆盖 1-69/1-72 | 实测正则确认+扩 |
| selftest-lane-advancement.sh:136 | 注释称覆盖 1-69/1-72 | 实测正则确认+扩 |
| selftest-parallel-scheduling.sh:108 | `1-72` | 扩 `1-7[0-5]` |
| selftest-context-pressure.sh:99 | `1-(69|71)` | 扩 `1-(69|71|75)` |
| selftest-research-first.sh:75 | `1-[67][0-9]` | 已覆盖 75 ✓ |
| selftest-veto.sh:13 | `1-(3[1-9]|[4-7][0-9])` | 已覆盖 75 ✓ |
| selftest-skill-split.sh:80 | `1-(3[0-9]|[4-7][0-9])` | 已覆盖 75 ✓ |
| selftest-reflect-verify.sh:61 | `Rules 1-(3[5-9]|[4-7][0-9])` | 已覆盖 75 ✓ |
| selftest-workflow-orchestration.sh:70-76 | `1-68/1-71` 变体族 | 实测确认+扩 |

**registry.tsv**：72 行（selftest 脚本数+表头，新脚本 +1 后行数自洽）

**S3 结论**：级联面=SKILL.md 3 处计数位 + 14 脚本宽容锚（9 处需扩/确认，5 处已覆盖）；并行并集解时保留各会话演进记录注释。

#### [sub:02-executor] S5 Rule 75 条款落盘

**动作**：在 worktree 的 critical-rules.md EOF 纯增量追加 Rule 75 条款块（草案取自 task_plan.md「📜 Rule 75 条文草案」正文，行 226-244）。

**产出锚**：
- 目标文件：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/references/critical-rules.md`
- 变更：+20/-0 行（970→990）；行 972=`### 75` 节头，行 976-990=75.0-75.7 子条
- 子条锚行号：75.0 :976 / 75.1 :978 / 75.2 :980 / 75.3 :982 / 75.4 :984 / 75.5 :986 / 75.6 :988 / 75.7 :990

**验证证据（第一手命令输出）**：
- `grep -nE "^75\.[0-7] "` → 8/8 命中（976-990）；`grep -n "^### 75 "` → 1 命中（972）
- `git diff --numstat -- critical-rules.md` → `20	0`（零删除，纯增量）
- `diff <(sed -n '972,990p' critical-rules.md) <(sed -n '226,244p' task_plan.md)` → IDENTICAL（0 diff，字节级与草案一致，无转译/缩写/合并）
- 既有 Rule 63/71/72 标题计数=8（未改动）；文件末尾以 75.7 机制条收尾

**结论**：Rule 75 条款块完整落盘，语义与草案字节级一致，既有 Rules 1-72 零改动。VC-1 的条款锚面（75.0-75.7 子条 grep 全命中）达成。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/02-executor-s5.md`（status: done）

#### [sub:02b-executor] S6 CHANGELOG 条目落盘

**动作**：在 worktree 的 CHANGELOG.md `## [Unreleased]` → `### 新增` 段顶部追加 task-v163 条目（照既有 `- **...** — ...` bullet 格式）。

**产出锚**：
- 目标文件：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/CHANGELOG.md`
- 变更：+1/-0 行（168→169）；新增条目位于行 12，`### 新增` 段头=行 10，原首条 Rule 67（task-v152）顺移至行 13
- 条目原文：`- **task-v163** — Rule 75 网络调研主动激活与外部数据依赖纪律（计划期调研需求三态分析/执行期反死磕主动检索/GitHub 与浏览器等外部工具强制/模板层调研触点定制；selftest-proactive-research.sh 守护；SKILL 计数级联 1-72→1-75；零新 config 键）`

**验证证据（第一手命令输出）**：
- `git diff --stat -- CHANGELOG.md` → `CHANGELOG.md | 1 +` / `1 file changed, 1 insertion(+)`
- `git diff -- CHANGELOG.md` → 单条 `+` 行，无 `-` 行（既有条目零改动，纯追加）
- `wc -l CHANGELOG.md` → 169（原 168，+1 自洽）
- Read 复核：行 12=新增条目，行 13=Rule 67（task-v152）原条目内容未变

**结论**：CHANGELOG.md [Unreleased] 段顶部 task-v163 条目落盘，diff 仅追加、既有条目零改动。VC 达成。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/02b-executor-s6.md`（status: done）

#### [sub:03-executor] 模板调研区块落盘

**动作**：在 worktree 的 `skills/task-planner/templates/task_plan.md` 插入「🔍 调研需求与检索计划（Rule 75.1）」区块（三态表 + 检索关键词列 + 豁免声明行），位置 = 原 :171（`**如果无法回答核心问题，禁止开始任务！**`）后 / 原 :173（`## 🔍 证据面清单（Rule 58.1`）前。纯增量，既有内容零改动。

**产出锚**：
- 目标文件：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/task_plan.md`
- 变更：+10/-0 行（507→517）；新 heading 落位行 173；原 `## 🔍 证据面清单（Rule 58.1` 由 :173 顺移至 :183

**验证证据（第一手命令输出）**：
- `grep -n '## 🔍 调研需求与检索计划（Rule 75.1' task_plan.md` → `173:## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）`
- `wc -l task_plan.md` → 517（原 507，+10 自洽）
- `grep -c '^## ' task_plan.md` → 30（原 29，+1 = 仅新增区块，既有 29 个标题零变）
- `git diff --stat -- task_plan.md` → `10 insertions(+)`，0 deletions（纯追加，无删除行）
- 解析锚复核：`## Goal`(:30)、`## 🎯 Goal 单元表`(:104)、`## ⚠️ 执行范围限制`(:116)、`### Phase 1-5`、`- **Status:**` 全部在位，行号仅 +10 平移，零破坏

**结论**：模板调研需求三态区块落盘，diff 仅追加、既有区块/解析锚零改动。VC 达成（验收 3/3 pass）。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/03-executor-s7.md`（status: done）

#### [sub:03b-executor] 计划期载体落盘

**动作**：在 worktree 落盘 Rule 75.1 计划期两载体（S8）：① `companion/agents/plan-writer.md` 产出契约必填字段表末尾追加 1 行「调研需求区块（Rule 75.1）」撰写义务 bullet；② `scripts/check-plan-dispatch.sh` 在 Rule 68 段后 / `# ── 输出 ──` 前追加 Rule 75.1 advisory 校验段（非 mini 计划缺「🔍 调研需求与检索计划」区块 → echo WARN，不 add_violation、不改 exit）。纯增量，既有内容零改动。

**产出锚**：
- plan-writer.md：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/companion/agents/plan-writer.md`，变更 +2/-0 行（289→291）；新 bullet 落位 :139（`| **s_unit_id** |` 行后）
- check-plan-dispatch.sh：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/scripts/check-plan-dispatch.sh`，变更 +13/-0 行（663→676）；新段 :653-664（段头 :653，WARN 行 :662）；原 `# ── 输出 ──` 段 :653-663 平移至 :666-676

**验证证据（第一手命令输出）**：
- `grep -n "调研需求区块（Rule 75.1）" plan-writer.md` → `139:- **调研需求区块（Rule 75.1）**：...`（命中）
- `grep -n "WARN Rule 75.1" check-plan-dispatch.sh` → `662:        echo "[plan-dispatch] WARN Rule 75.1: 非 mini 计划缺..."`
- `bash -n check-plan-dispatch.sh` → SYNTAX OK
- `bash scripts/selftest-plan-dispatch.sh` → `Total: 12 PASS=12 FAIL=0`（RC=0，零回归）
- 行为夹具（mktemp/hermetic）：非 mini 缺区块 → rc=0 + WARN count=1；非 mini 含区块 → WARN count=0；`plan_tier: mini` 缺区块 → WARN count=0（豁免生效）——确认纯 advisory（退出码零变化）
- md5 基线：plan-writer.md `0eea1780f3a2e830237542e3d1519855` / check-plan-dispatch.sh `40bc0d4765e15d68b832fd6f699cbe19`（scope 禁 git，以定向 Edit + Read 复核替代 diff）

**结论**：Rule 75.1 计划期两载体落盘，advisory 行为符合「非 mini 缺失即 warn、不拒锁」；mini 档/含区块零告警；既有 selftest 零回归。VC-2 的计划期载体锚面（plan-writer 契约行 + dispatch advisory 段）达成（验收 3/3 pass）。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/03b-executor-s8.md`（status: done）

#### [sub:04c-executor] 模板生成判定条目落盘

**动作**：在 worktree 的 plan-template-kit 两文件落盘「新模板调研需求判定条目」（S11，需求锚 R8）：① `skills/plan-template-kit/references/template-guide.md` 在 §2.5 后插入 §2.6「新模板调研需求判定条目（Rule 75.6）」，含 research/code-edit·script-dev/deployment/其他 四类模板的调研触点三态判定表 + 「判定结果必须写入模板」收口句；② `skills/plan-template-kit/references/template-mapping.md` 在 §九 机制画像 blockquote 末尾追加 `> **Rule 75 注记（task-v163）**` 指向 §2.6。纯增量，既有内容零改动。

**产出锚**：
- template-guide.md：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/plan-template-kit/references/template-guide.md`，变更 +13/-0 行（303→316）；新 §2.6 落位 :92-104（heading :92），`## 三、引用方式` 由 :94 平移至 :107
- template-mapping.md：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/plan-template-kit/references/template-mapping.md`，变更 +1/-0 行（316→317）；新注记落位 :300，`## §十 工具选择映射` 由 :301 平移至 :302

**验证证据（第一手命令输出）**：
- `grep -n "2.6 新模板调研需求判定条目\|Rule 75.6" template-guide.md` → `92:### 2.6 新模板调研需求判定条目（Rule 75.6 — task-v163）`（命中）
- `grep -n "research-type | 必需" template-guide.md` → `98:| research-type | 必需（NET-RESEARCH） | 调研类任务默认需网络调研 |`
- `grep -n "Rule 75 注记（task-v163）" template-mapping.md` → `300:> **Rule 75 注记（task-v163）**：...`（命中）
- 既有锚复核：`## §十 工具选择映射` :302（原 :301，+1 平移）；`## 三、引用方式` :107（原 :94，+13 平移）；§2.5 :87 不变——既有内容零改动
- 行数自洽：guide 316（§2.5→§三 由 7 行间距扩为 20 行 = +13）；mapping 317（§十 +1 平移 = +1）
- md5 基线（scope 禁 git，以定向 Edit + Read/grep 复核替代 diff）：template-guide.md `6e03e33f06e94942151bda7220f1891a` / template-mapping.md `92eaf2cce26bbc67e785583ba58f29a5`

**结论**：模板生成技能已补充「是否需调研」判定条目（template-guide.md §2.6 三态表 + template-mapping.md §九 Rule 75 注记），满足 R8；既有解析锚/章节仅行号平移、内容零改动；diff 仅追加。验收 3/3 pass。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/04c-executor-s11.md`（status: done）

#### [sub:04b-executor] script-dev/deployment 调研触点

**动作**：在 worktree 两个 variant 模板的「📚 必要知识储备」区块末尾纯增量追加调研触点行（S10，对应 R7「在模板中加入一些调研的步骤」）：① `script-dev-type.md` 追加 GitHub 现成实现检索行（Rule 75.3/75.4）；② `deployment-type.md` 追加官方文档/现成方案优先行（Rule 75.3）。既有内容零改动。

**产出锚**：
- `script-dev-type.md`：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/variant/script-dev-type.md`，变更 +2/-0 行（112→114）；新触点行落位 :80（「必要知识储备」表末行 :78 后 / `## 🚨 Drift Log` 前）
- `deployment-type.md`：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/variant/deployment-type.md`，变更 +2/-0 行（182→184）；新触点行落位 :64（`**填写规则**` 段 :62 后 / `## Current Phase` 前）

**新增行原文**：
- script-dev :80 = `- **GitHub 现成实现检索（Rule 75.3/75.4）**：脚本开发前必须先 GitHub 检索现成实现（gh search repos/code）+官方示例——评估借鉴/适配后落地，未检索就自研=违规`
- deployment :64 = `- **官方文档/现成方案优先（Rule 75.3）**：部署配置前必须先查官方文档（Doc Search Agent）+社区成熟方案（Docker/nginx/k8s 官方示例）——禁凭记忆直接写配置`

**验证证据（第一手命令输出）**：
- `grep -n "Rule 75.3" variant/script-dev-type.md variant/deployment-type.md` → `script-dev-type.md:80` / `deployment-type.md:64`（两文件各命中 1 行，2/2 PASS）
- `git diff --numstat` → `2	0`（两文件各 +2/-0；+2 = 1 触点行 + 1 空行分隔）
- `git diff` 全文 → 仅 `+` 行，零 `-` 行（既有内容零改动，纯追加）
- md5 BEFORE→AFTER：script-dev `bb8b1f51d93b1dd551a33dd340c0a462`→`40905ec664e87d09b48cb20a9fd5d194`；deployment `81e853842f1d49dbb675a0948c062762`→`bd436449714511600c926254539bbee9`
- `wc -l`：script-dev 112→114 / deployment 182→184

**结论**：两 variant 模板调研触点落盘，diff 仅追加、既有内容零改动。VC-3 模板层触点面由 S10 贡献 2 行（≥4 variant 触点由 S9/S10 合并达成，S11 已补模板生成判定条目 §2.6）。验收 2/2 pass。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/04b-executor-s10.md`（status: done）

#### [sub:04-executor] research/code-edit 调研触点

**动作**：在 worktree 两个 variant 模板的「📚 必要知识储备」区块末尾纯增量追加调研触点行（S9，对应 R7「在模板中加入一些调研的步骤」+ Rule 75.6 模板层定制）：① `research-type.md` 深化——追加三态判定行（Rule 75.1）+现成方案行（Rule 75.3）；② `code-edit-type.md` 追加 GitHub/现成方案检索行（Rule 75.3/75.4）。既有内容零改动。

**产出锚**：
- `research-type.md`：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/variant/research-type.md`，变更 +3/-0 行（120→123）；新触点行落位 :55、:56（「填写规则」:53 后 / `## 🧰 工具选择与编排` 前）
- `code-edit-type.md`：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/variant/code-edit-type.md`，变更 +2/-0 行（171→173）；新触点行落位 :60（「填写规则」:58 后 / `## Current Phase` 前）

**新增行原文**：
- research :55 = `- **调研需求三态（Rule 75.1）**：本模板任务默认 NET-RESEARCH——调研策略制定 Phase 必须登记检索关键词+渠道（63.2 四步链）+预期产出形态到计划「🔍 调研需求与检索计划」区块`
- research :56 = `- **现成方案/资料优先（Rule 75.3）**：调研动手前必须先检索现成资料/类似研究（官方文档/GitHub/竞品公开资料）——评估借鉴/适配后落地，禁重复造轮子，未检索就自研=违规`
- code-edit :60 = `- **现成方案检索（Rule 75.3/75.4）**：代码编辑前必须先 GitHub 检索现成实现（gh CLI 搜仓库/issues）+官方文档——检索到现成实现评估借鉴/适配，未检索就自研=违规`

**验证证据（第一手命令输出）**：
- `grep -n "Rule 75.1\|Rule 75.3\|Rule 75.4" variant/research-type.md variant/code-edit-type.md` → `research-type.md:55` / `:56` / `code-edit-type.md:60`（两文件均命中，2/2 PASS）
- `git diff --numstat` → `3	0	research-type.md` / `2	0	code-edit-type.md`（纯追加，零删除）
- `git diff` 全文 → 仅 `+` 行，零 `-` 行（既有内容零改动，纯追加）
- md5 BEFORE→AFTER：research `16476b93a7fb0aa7f88dc5f90ef4f46e`→`40f4ff766381eeff3ba2b3639c2c38b3`；code-edit `a500dbaccf7f05ba232f9e442176dceb`→`ab220e0ba5c5c1ae4a24acd07a4e7874`
- `wc -l`：research 120→123 / code-edit 171→173
- `git status --short`：仅新增 code-edit-type.md / research-type.md 两 M 条目（本会话写入面）；其余 M 为并行既有产物

**偏差说明**：objective 写 research-type「（三态判定行+现成方案行）」，step ② 仅给三态行逐字文本，scope 允许 +1~2 行；据 Rule 75.6 与 S2 探索结论（research-type 缺判定面/现成方案）补齐现成方案行，code-edit 严格按 step ③ 单行。

**结论**：两 variant 模板调研触点落盘，diff 仅追加、既有内容零改动。VC-3 模板层触点面由 S9 贡献 research 2 行 + code-edit 1 行。验收 2/2 pass。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/04-executor-s9.md`（status: done）

#### [sub:05-executor] selftest-proactive-research 新建

**动作**：在 worktree `skills/task-planner/scripts/` 新建 `selftest-proactive-research.sh`（S12，Rule 75.7 机制面静态守护，PR-01..15 共 15 条断言）——对齐 `selftest-research-first.sh` 范式（头注 What/Why + `ok/bad/eq/ge/cnt/cntF` 助手 + 逐行 `PASS/FAIL PR-NN` + 末行 `Total: 15 PASS=x FAIL=y` + 全 PASS exit 0 / 任一 FAIL exit 1）。只读 grep，零写入；被检路径全部相对 `SCRIPT_DIR` 解析（仓库/worktree/部署位三处可直接跑）。

**产出锚**：
- `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/scripts/selftest-proactive-research.sh`，新建 81 行（+81/-0，chmod +x，`bash -n` SYNTAX OK）

**断言清单**：
- PR-01..09（条款本体）：`critical-rules.md` `^### 75 ` =1 ∧ `^75\.0 `..`^75\.7 ` 八子条各 ≥1（公理/计划期三态/反死磕主动激活/现成方案优先/GitHub 检索/外部工具强制/模板层定制/机制）
- PR-10..12（计划期载体）：`templates/task_plan.md` 含 `## 🔍 调研需求与检索计划（Rule 75.1` ∧ `companion/agents/plan-writer.md` 含 `调研需求区块（Rule 75.1）` ∧ `scripts/check-plan-dispatch.sh` 含 `Rule 75.1 调研需求区块 advisory`
- PR-13（模板生成技能）：`skills/plan-template-kit/references/template-guide.md` 含 `2.6 新模板调研需求判定条目`
- PR-14（registry 自登记）：`selftest-registry.tsv` 含 `selftest-proactive-research.sh` 登记行
- PR-15（零新键）：`config.json` `"properties"` 计数=基线 4 ∧ Rule 75 键字面=0

**验证证据（第一手命令输出）**：
- `bash selftest-proactive-research.sh` → `PASS PR-01..PR-13`（13 条）+ `FAIL PR-14 registry 含本脚本登记行 (got=0 expect>=1)` + `PASS PR-15 config 零新键(properties=4 ∧ Rule75 键字面=0)`；`Total: 15 PASS=14 FAIL=1`；`EXIT=1`
- `wc -l` → 81；`bash -n` → SYNTAX OK；`chmod +x` 已设
- 路径解析复核：`GUIDE=$SCRIPT_DIR/../../plan-template-kit/references/template-guide.md` → 实测命中 `template-guide.md`（17228 字节）
- config 基线：`grep -c '"properties"' config.json`=4；`grep -c proactive_research|proactive-research|proactive_search`=0
- `git status --short`（worktree）→ `?? skills/task-planner/scripts/selftest-proactive-research.sh`（唯一本会话新增面）

**偏差/阻塞说明（PR-14）**：`selftest-registry.tsv` 尚无本脚本登记行（`grep -c`=0）。按 task_plan.md Phase 5 S-unit 表，registry 登记行属 **S13**（"selftest-registry.tsv +1 行"）；本 dispatch scope 明确"禁止修改其他任何文件"且"本会话只执行本 S-unit（Rule 46.1）"，故未写入 registry 行（避免越权 + 避免 S13 重复行）。PR-14 为前向守护，已在脚本头注注明"S12 期该断言为前向守护（待 S13 后转绿）"。

**结论**：脚本本体（S12 核心交付）落盘且 14/15 断言 PASS；唯一 FAIL=PR-14 依赖 S13 registry 登记行（本 dispatch scope 外）。S13 落盘后重跑即 `Total: 15 PASS=15 FAIL=0`。验收 14/15。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/05-executor-s12.md`（status: partial）

#### [sub:05b-executor] registry 登记

**动作**：在 worktree `skills/task-planner/scripts/selftest-registry.tsv` 末行纯增量追加 `selftest-proactive-research.sh` 登记行（S13，Rule 75.7 机制面 registry 自登记；四列格式 `script \t domain \t trigger_scenarios \t dep_anchors` 对齐既有行）。

**产出锚**：
- 目标文件：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/scripts/selftest-registry.tsv`，变更 +1/-0 行（73→74）；新行落位 :74
- 新行原文（tab 分隔四列）：`selftest-proactive-research.sh` | `Rule 75 网络调研主动激活与外部数据依赖纪律静态守护 PR-01..15（task-v163）` | `75.0-75.7 子条锚/模板调研区块/plan-writer 契约行/dispatch advisory 段/guide §2.6 判定条目/registry 自登记/config 零新键` | `references/critical-rules.md;templates/task_plan.md;companion/agents/plan-writer.md;scripts/check-plan-dispatch.sh;skills/plan-template-kit/references/template-guide.md;scripts/selftest-registry.tsv;config.json`

**验证证据（第一手命令输出）**：
- `grep -n "selftest-proactive-research.sh"` → `74:selftest-proactive-research.sh ...`（命中 1 行）
- `wc -l` → 74（基线 73，+1 自洽）；末行 `awk -F'\t' '{print NF}'` → 4（四列格式对齐）
- `head -n 73 selftest-registry.tsv | md5sum` → `b38d88123b85e55dac8ab0364fa7ca20`（= 基线全文件 md5 → 既有 73 行字节级零改动，diff 仅追加）；全文件 md5 `b38d88123b85e55dac8ab0364fa7ca20` → `c2209f93b93365f0c5c9c27aa126eb36`
- 行 73 复核：`selftest-pointer-lifecycle.sh`（原末行）内容未变
- 复跑 S12 守护：`bash selftest-proactive-research.sh` → `Total: 15 PASS=15 FAIL=0`，`EXIT=0`（PR-14 registry 自登记由 partial 转绿）

**结论**：registry 登记行落盘，四列格式对齐、行数自洽（+1）、既有 73 行字节级零改动（diff 仅追加）。S12 守护 15/15 全 PASS。S13 验收 2/2 pass。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/05b-executor-s13.md`（status: done）

#### [sub:05c-executor] SKILL 级联与全仓锚修齐

**动作**：S14 在 worktree 完成 Rule 75 的 SKILL.md 级联 + 全仓宽容锚扩展（需求锚 R6）。① SKILL.md 三处计数位 1-72→1-75（行 9/299/387）+ Rule 75 摘要 bullet（行 363）+ 合规清单行（行 235，**C52**）；② 11 个 selftest 宽容锚扩至覆盖 75 纪元；③ CLAUDE.md/README_zh.md 计数标签 1-71→1-75。

**产出锚**：
- SKILL.md：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/SKILL.md`，+2 净增行（538→540；三处计数位为行位替换零净增，净增=Rule 75 bullet + C 行）
- scripts/：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/scripts/` 下 11 脚本（见下）
- 文档：`…/CLAUDE.md`（:33）、`…/README_zh.md`（:136/:229）

**验证证据（第一手命令输出）**：
- `grep -c "1-75" SKILL.md` = **3**（行 9/299/387）；`grep -c "1-72" SKILL.md` = **0**
- `wc -l SKILL.md` = **540**（原 538，+2 自洽）
- `grep -n "Rule 75（网络调研主动激活" SKILL.md` → `363`（bullet）；`grep -n "^| C52 " SKILL.md` → `235`；`grep -c "^| C51 |"` = 1（Rule 72 行保留）
- 锚覆盖直测（对 SKILL.md `grep -cE`）：self-resolution/tool-selection/requirement-coverage/lane-advancement `Critical Rules 1-(6[0-9]|7[0-5])`=2；root-resolution 全集锚=1；research-first RF-07 `1-(69|71|72|75)`=1；context-pressure c1 `1-(69|71|75)`=4 / c2 `1-(69|71|72|75)`=2；source-anchor `1-7[125]`=3；research-first RF-06 `1-[67][0-9]`=4；workflow-orchestration 族合计 9——全部 ≥ 各自阈值
- `bash -n` 11 改动脚本 → 全 OK
- 全量回归（`for f in selftest-*.sh`）→ **pass=71 fail=2**（基线 pass=70 fail=3）：**selftest-parallel-scheduling.sh P-05 由 FAIL→PASS**（skill_max 72→75 == crit_max 75）

**偏差说明（B 类事实修正 — C51→C52）**：落盘 prompt/dispatch 写「追加 C51」，task_plan 写「接续最大 C 编号（当前 C50→C51）」。worktree 基线（master ba5ee1c 含 v160 合流）实测 **C51 已被 Rule 72（task-v160）占用**（SKILL.md:234），最大 C=51。依 task_plan「接续最大 C 编号」总则追加 **C52**（避免重复编号缺陷），C51（Rule 72）原样在位。

**新增发现（S3 清单未列）**：`selftest-source-anchor-discipline.sh:39` SA-07 计数锚 `1-7[12]`（≥2）在 1-75 后命中 0 → 扩 `1-7[125]`。S3 清单 14 项中 `conclusion-discipline:72`/`parallel-scheduling:108` 经实测为**注释/动态断言**（活跃锚 `1-[4-7][0-9]` / skill_max==crit_max 已覆盖 75），仅补注释不改正则。

**文档级联**：CLAUDE.md:33 与 README_zh.md:136/:229 的 `Rules 1-71`→`Rules 1-75`（grep "1-7" 命中才改规则）；skills/task-planner/README.md:72 `Rules 1-69`（无 1-7 命中，且被 CD-18 `Rules 1-6[0-9]` 断言，不动）。

**负结果报告**：SKILL.md 行数上限断言（≤555/≤558）实测 540 未超，**无需上调**（prompt 预期「同步上调」未触发）；5 处「已覆盖 75 的宽容锚」（research-first:75/veto:13/skill-split:80/reflect-verify:61）实测 ≥1 确认无需扩；全仓 active 断言残留 `7[0-2]` 字面=0。

**结论**：SKILL 级联（三处 1-75 + bullet + C52）与全仓宽容锚（11 脚本）修齐完成，S14 验收 4/4 pass；全量回归由 3 FAIL 降至 2 FAIL（parallel-scheduling 修复）。**残留 2 FAIL 属 S14 scope 外**（见 blockers），需主进程/相关 S-unit 处置。

**blockers（S14 scope 外）**：
1. `selftest-decision-grading.sh` DG-03——根因=S5 Rule 75 条文块含 `[sub:01a-explore]`（`:`+`0`）被 `sed -n '/^## Rule 72/,$p'` 段尾捕获；建议改 Rule 75 文本或修 DG-03 段界（critical-rules.md / v160 脚本，S14 禁改）。
2. `selftest-plan-tier.sh` PT-15——根因=S7 templates/task_plan.md:175 注释含字面 `plan_tier: mini`，init 缺省场景误判；建议注释改写（templates/task_plan.md，S14 禁改）。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/05c-executor-s14.md`（status: done）

#### [sub:05d-executor] DG-03/PT-15 回归修复

**动作**：修复本任务产出引入的 2 个 selftest 回归（Rule 75 条款块 + 模板注释触发既有断言误判），仅 2 处措辞修正、语义不变。① `critical-rules.md:974` Rule 75 来源段 `归因（findings.md [sub:01a-explore] 三空白面实证）` → `归因（findings 盘点段三空白面实证）`（去 `[sub:01a-explore]`，消除 `:0` 被 DG-03 `:\s?[0-9]+` 命中——DG-03 段界 `sed -n '/^## Rule 72/,$p'` 会捕获 Rule 75 来源段）；② `templates/task_plan.md:175` 调研区块注释 `豁免：plan_tier: mini 任务整体豁免（Rule 38.3 区块白名单同口径）` → `豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）`（去 `plan_tier: mini` 字面，消除 init 缺省复制 general 源后产物被 PT-15 误判为 mini 档）。

**产出锚**：
- critical-rules.md：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/references/critical-rules.md`，行 974 单处替换
- templates/task_plan.md：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/task_plan.md`，行 175 单处替换

**验证证据（第一手命令输出）**：
- 修复前基线：`selftest-decision-grading.sh` → `DG-03 FAIL: Rule 72 段行号引用形态命中=1`（`Total: PASS=11 FAIL=1`）；`selftest-plan-tier.sh` → `PT-15 FAIL init 缺省场景复制源异常`（`Total: 32 PASS=31 FAIL=1`）
- 修复后：`selftest-decision-grading.sh` → `DG-03 PASS: Rule 72 段无行号引用形态` + `Total: PASS=12 FAIL=0 WARN=0`，rc=0
- 修复后：`selftest-plan-tier.sh` → `PT-15 PASS init 缺省场景=general 源（无 mini 标记）` + `Total: 32 PASS=32 FAIL=0`，rc=0
- 残留复核：`grep -c "01a-explore" critical-rules.md`=0；`grep -c "plan_tier: mini" templates/task_plan.md`=0；`sed -n '/^## Rule 72/,$p' critical-rules.md | grep -cE ':\s?[0-9]+'`=0
- 新措辞在位：`grep -n "归因（findings 盘点段三空白面实证）"` → 974；`grep -n "豁免：mini 档任务整体豁免"` → 175
- 未误伤 mini 路径：`PT-16 PASS init TASK_PLAN_TIER=mini 复制 mini-lite`（mini-lite 模板自身 `plan_tier: mini` 标记仍在，仅 general 源注释去字面）

**结论**：2 处回归修复完成，两 selftest 全 PASS（DG 12/12、PT 32/32），既有内容零改动（仅 2 处措辞）。S14 blockers 第 1、2 项（DG-03/PT-15）关闭。

**检查点**：`/mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/subagent-state/05d-executor-fix.md`（status: done）

#### [sub:06-reviewer] CR Gate 审查结论

**verdict: CHANGES_REQUESTED**（conf: HIGH；审查对象=worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research` 全链 27 文件 diff vs master，base=ba5ee1c）

**审查面与结果（6/6 审查重点已执行）**
- 正确性：`selftest-proactive-research.sh` 15 断言（PR-01..15）实跑 `Total: 15 PASS=15 FAIL=0` exit 0，覆盖 Rule 75 七子条（实为八子条 75.0-75.7）+三载体+registry+config 零新键 — PASS
- 既有内容零改动：11 个宽容锚脚本 diff 均为「锚正则+注释」级，判据（≥/eq 阈值）零变更；`critical-rules.md` +20/-0、`task_plan.md` +10/-0 纯追加 — PASS
- 纯增量：critical-rules/task_plan/variant/plan-writer/template-kit 全部 diff 仅 `+` 行 — PASS
- 锚级联一致性：14 个改动/关联脚本实跑全绿（conclusion 24/24、context-pressure 9/9、lane 14/14、parallel 9/9、requirement 23/23、research-first 12/12、root 17/17、self-resolution 13/13、source-anchor 12/0、tool-selection 12/12、workflow 16/16、decision-grading 12/0、plan-tier 32/32、plan-dispatch 12/12） — PASS（附 1 项声明一致性缺陷，见下）
- 注释完整性：新脚本头注 What+Why 双层完整，check-plan-dispatch advisory 段含 WHY + 档位口径说明 — PASS
- 安全：无危险命令（rm -rf/curl|bash/eval 均无）、无硬编码密钥、只读 grep、`bash -n` 全 OK — PASS

**发现清单**

🔴 **[正确性/一致性]** `skills/task-planner/references/critical-rules.md:990` — 75.7 消费侧引用「合规清单 C51」与 SKILL.md 实态矛盾
- 原文: "消费侧=SKILL.md 摘要 bullet + 合规清单 C51 + `templates/subagent_dispatch.md` 检索契约行延伸"
- 原因: SKILL.md 新增行实为 `| C52 |`（Rule 75）；且 worktree 基线 C51 已被 Rule 72（决策分级）占用——75.7 若按 C51 落必撞号。同一改动内文本与产物自相矛盾（该段曾走 fix-wave，此引用未随 C51→C52 修正）。
- 修复: 将 75.7「合规清单 C51」改为「合规清单 C52」。
- 置信度: HIGH

🔴 **[合并阻断/计数唯一性]** `skills/task-planner/SKILL.md:235` — 合规清单 C 编号与 master 撞号（合并即产生重复 C52）
- 原文: "| C52 | 网络调研主动激活自查（Rule 75）"
- 原因: worktree 基线 ba5ee1c 的 C52 空闲、C51=Rule72；master 已前进 5 提交（v162 落 Rule74→C51、Rule72→C52，实测 master SKILL.md:234-236 = C50/C51(Rule74)/C52(Rule72)）。合并后 master C52=Rule72 与本行 C52=Rule75 重复。task_plan「并行合流撞 75」FMEA 只覆盖 Rule 编号，未覆盖 C 编号。
- 修复: 合并对账时把 Rule 75 合规行重编号为 C53 并同步 75.7 引用；且 task_plan 合并合约第 3 条「主仓无与任务范围重叠的未提交变更」已被打破（master 与 worktree 同改 SKILL.md/critical-rules.md/多 selftest），须 STOP 报告用户并按并集解重定基线后重验。
- 置信度: HIGH

🟡 **[声明-载体一致性]** `skills/task-planner/references/critical-rules.md:990` — 75.7 声称 `templates/subagent_dispatch.md` 检索契约行「延伸」但未落盘
- 原文: "`templates/subagent_dispatch.md` 检索契约行延伸（75.2 反死磕条款传播到子代理侧）"
- 原因: `git diff HEAD --numstat -- templates/subagent_dispatch.md` 为空（零改动）；该文件仅既有 :27「检索优先契约（Rule 63，task-v147）」，无 Rule 75.2 新触点行，"延伸"无对应产物。
- 修复: 或在 subagent_dispatch.md 追加一行 Rule 75.2 反死磕主动检索触发点，或删除 75.7 中该声称。
- 置信度: MED

🟡 **[声明准确性]** `skills/task-planner/references/critical-rules.md:972` — 声明「Critical Rules 全集 1-75」但本分支及 master 均无 Rule 73
- 原文: "### 75 网络调研主动激活与外部数据依赖纪律（P0 — task-v163，目标：...）"
- 原因: worktree CR 实有 71/72/75；master CR 实有 71/74（`grep -nE '^### 7[0-9] '` 实测无 `### 73`，全文无 task-v156）。合并后仍缺 73，"1-75" 声明名不副实（master 现存 1-74 同缺口，属既有欠账，非本任务引入）。
- 修复: 合并后核 Rule 73 落地状态，按实态修正声明或补齐 73（建议登记为既有欠账而非本任务阻塞）。
- 置信度: MED

💬 **[卫生]** `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/plans-baseline.md`、`regression-baseline.md`（worktree 根）— 未跟踪 scratch 文件
- 原文: git status `?? plans-baseline.md` / `?? regression-baseline.md`
- 原因: task_plan「执行范围限制」未列 worktree 根级文件；合并前应清出，避免进入主干。
- 修复: 删除或迁移至 `plans/task-v163-proactive-research/`，合并前确认 `git status` 干净。
- 置信度: HIGH

**负结果报告（检查了哪些 / 未发现什么）**
- 已审文件（worktree 绝对路径全量 27 项 diff + 1 新脚本）：critical-rules.md、SKILL.md、CHANGELOG.md、CLAUDE.md、README_zh.md、plan-writer.md、task_plan.md、template-guide.md、template-mapping.md、4×variant、check-plan-dispatch.sh、selftest-registry.tsv、selftest-proactive-research.sh（新）、11×宽容锚 selftest — 全部 Read/diff 核对。
- 未发现：SQL 注入/XSS/路径遍历/认证绕过类安全缺陷（本仓为纯文档+静态 grep 脚本，无网络/DB/用户输入面）；无危险命令注入（无 eval/无未引号变量用于 rm）；无敏感信息硬编码。
- 已排除：11 宽容锚脚本引入回归（实跑全绿）；selftest-proactive-research.sh 语法/断言缺陷（bash -n OK + 15/15 PASS）；check-plan-dispatch advisory 误阻断（纯 echo WARN，不改 exit，mini 档豁免，plan-dispatch 12/12 PASS）；既有内容被覆盖删除（全部 diff 纯追加或锚正则级）。
- 未能验证（scope/条件所限）：全量 73 脚本回归 FAIL=0 属 VC-6，须主进程逐 Total 行求和复判（本轮仅验证 14 个改动/关联脚本）；三部署位 diff=0（VC-8）须合并后由 smart-merge-back 输出核对。
- 悬空引用（既有，非本任务引入，登记不修）：SKILL.md 引用的 research-routing.md 在 plan-collab-router/references/ 下不存在（findings [sub:01a] 已录）。

#### [sub:06b-executor] CR 修复（06-reviewer CHANGES_REQUESTED → 3 项闭环）
- 目标: 修复 CR Gate 的 2 Blocker + 1 Suggestion（合规清单编号撞号 + 自述锚不一致 + 触点行缺失）。
- 修改 1（Blocker②）: `skills/task-planner/SKILL.md:235` 合规清单 `| C52 | 网络调研主动激活自查（Rule 75）` → `| C53 |`（内容不变，仅重编号；master C52=Rule 72 已占用，重编号避让）。
- 修改 2（Blocker①）: `skills/task-planner/references/critical-rules.md:990` 75.7 机制子条 `合规清单 C51` → `合规清单 C53`（与 SKILL.md 实态对齐，消除自述 vs 实态错位）。
- 修改 3（Suggestion③）: `skills/task-planner/templates/subagent_dispatch.md:28` §2 检索优先契约行（原 :27）后追加 1 行「**反死磕触点（Rule 75.2）**：执行中遇阻（不知道/不确定/报错/选型）第一动作=评估网络检索，同一思路连续尝试 ≥2 次无外部输入→必须转入检索，禁以本地死磕为默认路径」——落实 75.7 声称的「subagent_dispatch.md 检索契约行延伸（75.2 反死磕条款传播到子代理侧）」。
- 验证（grep 原文）: `^| C53 | 网络调研主动激活自查（Rule 75）` 命中 SKILL.md:235；`C52.*Rule 75` 无残留（grep rc=1）；`合规清单 C53` 命中 critical-rules.md:990；`反死磕触点（Rule 75.2）` 命中 subagent_dispatch.md:28。
- numstat（vs worktree base HEAD）: SKILL.md 5/3、critical-rules.md 20/0、subagent_dispatch.md 1/0（SKILL/critical 数字含前序 S5/S14 累积；本 S-unit 增量=SKILL 1 行替换 + critical 1 处措辞 + dispatch +1 行）。
- 范围: 仅 3 文件；未触 C51（Rule 72，避让归并侧处理）；未做 git 操作；未网络访问。
- 未决（移交主进程，非本 S-unit scope）: reviewer blocker④ Rule 73 欠账核实、blocker⑤ worktree 根 scratch 文件清理、合并基线重定（master 前进至 d45e8e2）。
- 置信度: HIGH

#### [sub:06c-reviewer] CR 复验结论

**verdict: APPROVED**（conf: HIGH；复验对象=worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research` 06b 修复后实态，2026-10-10）

**3 项修复逐项验证（grep 原文复现）**
1. Blocker①（75.7 自述锚错位）：`critical-rules.md:990` 现文「消费侧=SKILL.md 摘要 bullet + 合规清单 C53 + `templates/subagent_dispatch.md` 检索契约行延伸」——C51→C53 已修正，与 SKILL.md 实态一致 — PASS
2. Blocker②（合规清单撞号）：`SKILL.md:235` = `| C53 | 网络调研主动激活自查（Rule 75）`；`grep "C52.*Rule 75"` rc=1 零残留；worktree 全仓 `grep -rn "C52"`（task-planner/ + plan-template-kit/）零命中；master HEAD d45e8e2 实测合规行=C50(Rule71)/C51(Rule74)/C52(Rule72)——C53 为下一空闲编号，合并后零撞号 — PASS
3. Suggestion（dispatch 触点行缺失）：`subagent_dispatch.md:28` 新增「**反死磕触点（Rule 75.2）**：执行中遇阻（不知道/不确定/报错/选型）第一动作=评估网络检索，同一思路连续尝试 ≥2 次无外部输入→必须转入检索，禁以本地死磕为默认路径」——git diff 确认 +1/0 纯追加，75.7「检索契约行延伸」声称已有对应产物 — PASS

**修复后回归补证（fix 发生在全量回归之后，必须重跑）**
- 全量 selftest 重跑（worktree 73 脚本）：rc 全 0、FAIL=0。70 个标准 `Total:` 格式逐行求和 + 3 个非标格式脚本（final-gate-hash `PASS=22 FAIL=0` / source-anchor-discipline `12 pass, 0 fail` / user-instruction-priority `ALL PASS`）逐一人工核验 rc=0 FAIL=0；唯一 FAIL 令牌命中=iteration-persistence 断言文本 "PASS-FAIL=3"（计数描述，非失败）
- 机器守护：selftest-proactive-research.sh 15/15 PASS（EXIT=0）
- 零破坏面确认：无任何 selftest 断言引用 C52/C53 字面（grep 零命中），重编号不触碰机器守护
- 原 CR nit（worktree 根 scratch 文件 plans-baseline.md / regression-baseline.md）已不在 git status 未跟踪清单——一并关闭（现存未跟踪面仅 selftest-proactive-research.sh 本体，合法交付物）

**残留移交项（非本复验 scope，主进程合并门处置）**
1. master 已前进至 d45e8e2（v162 合流），合并基线重定仍需按并集解执行（原 blocker② 合并合约第 3 条打破项属合并门，非修复验收门）
2. Rule 73 欠账（master/worktree 均无 `### 73` 节头）——既有欠账，登记不修
3. 合并后复核点：worktree C53 行与 master C50-C52 行并集预期零冲突，合并结果无需再重编号

**负结果报告**：已检查 worktree 三修复文件（critical-rules.md:990 / SKILL.md:235 / subagent_dispatch.md:28）+ 全仓 C52 引用面 + 73 脚本回归 + 机器守护复跑；未发现新 Blocker/Suggestion；已排除重编号引发守护断言破坏、dispatch 行破坏模板解析（相邻行零改动）两类可能。

#### [sub:06d-align] 对齐审计结论

**verdict: ALIGNED**（conf: HIGH；审计对象=worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research` 全链 vs master `af321a3`，2026-10-11）

**master 时点状态（第一手 grep 实证）**
- SKILL.md 计数位：`1-74`（行 9/305/394 三处）；合规清单：C50(Rule71)/C51(Rule74)/C52(Rule72)/C53(Rule73)；无 C54、无 Rule 75
- critical-rules.md：`### 71`/`## Rule 72`（子节头 72.1-72.5）/`### 73`/`### 74` 四节在位；无 Rule 75
- master 已前进 5+ 提交（v162 Rule 74 合流、v164 指针瞬态化、v165 内置 agent 输出模板）

**worktree vs master 并集解（union resolution）**
1. **SKILL.md 计数位**：master `1-74` → 合并后 `1-75`（worktree 三处已改 1-75，master 1-74，取并集=1-75）
2. **合规清单行**：worktree C53 与 master C53(Rule73) 撞号 → **worktree C53 重编号为 C54**（master C50-C53 保留，C54=Rule 75 为下一空闲编号）；75.7 自述锚同步 C53→C54
3. **critical-rules.md**：master 有 Rule 71/72/73/74，worktree 追加 Rule 75（EOF）→ 并集=Rule 71-75 连续
4. **11 个宽容锚 selftest 脚本**：worktree 锚正则扩展（`7[0-2]`→`7[0-5]` 或等效），master 无并行改动 → 取 worktree 版本
5. **check-plan-dispatch.sh**：worktree +13 行 advisory 段，master 无并行改动 → 取 worktree 版本
6. **templates/task_plan.md**：worktree +10 行调研区块，master 无并行改动 → 取 worktree 版本
7. **variant 模板 ×4**：worktree 各 +2/+3 行触点，master 无并行改动 → 取 worktree 版本
8. **plan-template-kit ×2**：worktree +13/+1 行，master 无并行改动 → 取 worktree 版本
9. **plan-writer.md / subagent_dispatch.md**：worktree +2/+1 行，master 无并行改动 → 取 worktree 版本
10. **CHANGELOG.md / CLAUDE.md / README_zh.md**：worktree 各 +1 行，master 无并行改动 → 取 worktree 版本
11. **selftest-registry.tsv**：worktree +1 行，master 无并行改动 → 取 worktree 版本
12. **selftest-proactive-research.sh**：worktree 新建 81 行，master 无此文件 → 取 worktree 版本

**C54 修正验证（第一手命令输出）**
- `grep -n 'C54' SKILL.md` → `235:| C54 | 网络调研主动激活自查（Rule 75）...`（命中）
- `grep -c 'C53' SKILL.md critical-rules.md` → `0`/`0`（零残留）
- `bash selftest-proactive-research.sh` → `Total: 15 PASS=15 FAIL=0`（EXIT=0，C54 修正不触碰机器守护）

**变更记录（34 文件 + 1 新建）**
- 修改 33 文件：critical-rules.md(+20)、SKILL.md(+2)、CHANGELOG.md(+1)、CLAUDE.md(+1)、README_zh.md(+1)、plan-writer.md(+2)、task_plan.md(+10)、template-guide.md(+13)、template-mapping.md(+1)、4×variant(各+2/+3)、check-plan-dispatch.sh(+13)、subagent_dispatch.md(+1)、selftest-registry.tsv(+1)、11×宽容锚 selftest(各+1~3 行锚正则)
- 新建 1 文件：selftest-proactive-research.sh(81 行)
- C54 修正：SKILL.md:235 C53→C54、critical-rules.md:990 C53→C54

**回归基线**：worktree 全量 73 脚本 73/73 PASS（1100 断言 FAIL=0）；master 基线未跑（合并后由 smart-merge-back 三部署位对账覆盖）

**残留移交项（合并门处置）**
1. Rule 73 欠账已关闭——master 已有 `### 73`（v156 落地），worktree 声明「1-75」名实相符
2. 合并后三部署位 diff=0 由 smart-merge-back --deploy 输出核对
3. 合并后全量回归由 smart-merge-back 触发
