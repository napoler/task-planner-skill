<!-- template_type: rule-enhancement -->
# Task Plan: v132 — 72h 事故修复缺口 gap-fill（G1-G4）

<!-- plan_tier: standard | execution_lane: L1 -->
<!-- interaction_mode: silent（授权链：/goal + 事故报告 §6 用户 2026-10-05 显式授权「彻底修改」全部六项，见 plans/incident-reports/2026-10-05-72h-remediation-gap.md 头注） -->
<!-- code_review: required -->
<!-- worktree_path: /home/terry/task-planner-skill-worktrees/task-v132 (branch wt/task-v132) -->
<!-- session_id: afd0b28ec78a4e8ca9f0acde60eeaaf7 -->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
> 来源：plans/incident-reports/2026-10-05-72h-remediation-gap.md（其自身锚定用户授权原文）；逐条抄录 gap 文档 G1-G4 要点原文

- **R1**: 「G1：check-complete.sh VC-GATE 外增 R-COVERAGE 门——delivery-summary『需求覆盖核对』区块行数=计划 R 行数、状态枚举 covered/partial/uncovered 且带证据路径、任一 R uncovered/partial 且无 Decisions 让步登记→拒 COMPLETE 只可 PARTIAL；档位复用既有键 vc_gate_enforce。selftest：RC 锚+负例（缺行/裸 uncovered 无让步→不得 COMPLETE）」
- **R2**: 「G2：Rule 51 增 51.7 子条『纠正=回锚重译，非设计增量』（纠正原话追加为新 R 行不改写旧行；受影响 VC 同步改写+Decisions 登记纠正编号；重建执行体前重过 attest/dispatch 门）+ 通用窗口口径一致性 lint（从🎯锚定行提取需求窗口词→扫描计划与载荷计量窗口词，口径不一致即警报，不绑死 72h 字面；负例须含「一个月→7 天」样张）。selftest：51.7 文本锚+lint 正/负例」
- **R3**: 「G3：重锁文案收紧（『无 Decisions 纠正/让步登记的重锁视为篡改信号』）+ init-session.sh silent 路径锚哈希即时落盘 .plan-attestation。selftest：hook 文案锚+init 静态锚」
- **R4**: 「G4：critical-rules.md 51.1 判例库追加本事故（『一个月→72小时两次改写、四环绿灯，2026-10-05』，报告路径作锚）」
- **R5**: 「基于 v131 已落地机制实施，禁止与 init 注入/attest 三锚门/派发需求锚重复或冲突」（gap 文档开工前置原文）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据 |
|---|---------|----------|
| R1 | VC-3 | R-COVERAGE 门三态实测（缺行拒/齐过/裸 uncovered→PARTIAL）|
| R2 | VC-1, VC-2 | 51.7 锚 grep=1；lint 正例静默+负例（一个月→7 天）警报实测 |
| R3 | VC-4 | hook 文案锚 grep + init silent 锚哈希落盘实测 |
| R4 | VC-1 | 判例行 grep（含报告路径锚）|
| R5 | VC-5 | 与 v131 机制零冲突=全量回归 0 FAIL |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 锁定面 | 计划四锚已有门 | （v131 已覆盖，无缺陷）| — |
| 终验面 | 完成声称无机器核对覆盖表（51.3 仅人工）| G1 R-COVERAGE 门 | VC-3 |
| 纠正面 | 纠正指令被当新设计增量改写旧行（事故直接成因）| G2 51.7 回锚纪律 | VC-1 |
| 口径面 | 窗口词转译无检测 | G2 lint | VC-2 |
| 注入面 | TAMPERED 重锁可被滥用洗白 | G3 文案收紧+哈希即落 | VC-4 |
| 判例面 | 事故教训未入判例库 | G4 | VC-1 |

## Goal
落地 72h 指令篡改事故修复的 P1/P2 缺口 G1-G4（P0 三项已由 v131 落地），全量 selftest 0 FAIL 后合并部署四位。51.7=Rule 51 内子条（无新顶格编号，rule-reserve check 确认）。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（重 diff：脚本+条款） |
| `对齐审查` | alignment-review skill（42.6.2） |
| `自动超时默认项` | silent 无询问点 |
| `质量审查工具` | code-reviewer agent + alignment-review skill |
| `interaction_mode` | silent（授权链见 frontmatter） |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 51.7 子条+51.1 判例追加锚在位（含报告路径） | grep 逐锚 | critical-rules.md |
| VC-2 | 窗口 lint 正例静默/负例警报（一个月→7 天样张） | lint 实测输出 | progress.md |
| VC-3 | R-COVERAGE 门三态：缺行→拒；covered 齐→过；uncovered 无让步→禁 COMPLETE | 三例实测 | progress.md |
| VC-4 | hook 文案锚+init silent 锚哈希即时落盘 | grep+生成实测 | progress.md |
| VC-5 | 全量 selftest 0 FAIL（主进程求和）+与 v131 机制零冲突 | 逐脚本求和 | progress.md |
| VC-6 | code-reviewer APPROVED + alignment APPROVED | 审查返回 | plans/task-v132/ |
| VC-7 | 合并 master+四位 IDENTICAL+簿记 | diff+git log | progress.md |

**终验规则**：全 VC 过→COMPLETE；R uncovered→PARTIAL 列明。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 条款 | critical-rules.md（51.7 子条+51.1 判例追加=纯增量） | 改既有条款语义 |
| 脚本 | check-complete.sh（R-COVERAGE 门）、新 scripts/check-window-consistency.sh、zcode-userpromptsubmit.sh（文案）、init-session.sh（silent 锚哈希） | 其他脚本 |
| selftest | selftest-requirement-coverage.sh 扩 RC-16..20 + registry 行内更新 | 新 selftest 脚本 |

**强制约束**：51.7 无新顶格编号（rule-reserve check 51 子条空间）；锚级联前 grep 全扫（判例第 4 次教训——任务书内联指令）；派发契约全套。

## 🔀 隔离决策
worktree /home/terry/task-planner-skill-worktrees/task-v132（branch wt/task-v132）；计划三文件留主仓 plans/task-v132/。

## Phases

### Phase 1: worktree + G2/G4 条款落盘
- **Status:** complete（commit 4d81b28；VC-1 证据=findings §锚清单）
- **Executor:** executor(sonnet-1)（worktree 建立=白名单① 主控先行完成）
- S-unit 表：
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | 51.7 子条（回锚纪律四要素：纠正原话追加为新 R 行不改写旧行/受影响 VC 同步改写/Decisions 登记纠正编号/重建执行体前重过 attest+dispatch 门）+51.1 判例追加（事故句「一个月→72小时两次改写、四环绿灯，2026-10-05」+报告路径锚） | references/critical-rules.md | executor(sonnet-1) |
- V-N: VC-1

### Phase 2: G2 lint + G1 R-COVERAGE 门 + selftest 扩
- **Status:** complete（commit 757ea24+修复链；VC-2/3 证据=findings §机器面）
- **Executor:** executor(sonnet-1)
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | 新建 check-window-consistency.sh（从计划 🎯 锚行提取窗口词→扫描计划全文+subagent-state 载荷，口径不一致警报 exit 1；词表机制不绑死 72h 字面；一个月/72小时/7天/一周/30天/24小时 等窗口词族） | scripts/check-window-consistency.sh | executor(sonnet-1) |
| S2 | check-complete.sh R-COVERAGE 门（三态+复用 vc_gate_enforce 档位+delivery-summary 缺文件时按既有豁免口径 fail-open） | scripts/check-complete.sh | executor(sonnet-1) |
| S3 | selftest-requirement-coverage.sh 扩 RC-16..20（51.7 锚+lint 正负例+R-COVERAGE 负例）+registry 行内 domain 更新 | 2 文件 | executor(sonnet-1) |
- V-N: VC-2, VC-3, VC-5（部分）

### Phase 3: G3 hook 文案 + init silent 锚哈希
- **Status:** complete（commit 53699c1；VC-4 证据=findings §G3）
- **Executor:** executor(sonnet-1)
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | hook TAMPERED 分支文案收紧（重锁前置条件=Decisions 纠正/让步登记，否则视为篡改信号 STOP）+init-session.sh silent 路径生成计划后立即 attest 落盘 .plan-attestation（silent 无人工批准环节=哈希即刻固化防窗口期篡改） | zcode-userpromptsubmit.sh + init-session.sh | executor(sonnet-1) |
- V-N: VC-4

### Phase 4: 全量回归 + CR + align
- **Status:** complete（777/0；CR Round-2 APPROVED；ALIGN Round-2 P1 已清账+P2 登记）
- **Executor:** executor(sonnet-1)+code-reviewer(sonnet-1)（求和复核=主进程白名单③机械验证）
- V-N: VC-5, VC-6

### Phase 5: 合并+四位部署+簿记
- **Status:** complete（merge 54f6fe2；四位 IDENTICAL；VC-7 证据=delivery-summary.md+progress.md）
<!-- merge_back=merged(54f6fe2) -->
- **Executor:** 主进程（白名单①git/部署编排+②簿记）
- V-N: VC-7

## 📊 FMEA 预演（RPN>100 必有兜底）
| ID | 风险 | 概率 | 影响 | 检测性 | RPN | 兜底动作 |
|----|------|------|------|--------|-----|----------|
| F1 | R-COVERAGE 门误伤既有交付计划（v131 等旧计划 delivery-summary 无标准区块） | 4 | 7 | 4 | 112 | 门仅对 delivery-summary 含「需求覆盖核对」区块或 R 行>0 的计划生效+三态实测+旧计划豁免口径登记 |
| F2 | lint 窗口词误报（中文窗口词歧义） | 5 | 5 | 4 | 100 | 词表族化+负例样张钉住+warn 级起步（exit 1 仅核对样张级明确不一致） |

## Decisions Made
| 时间 | 决策 | 依据 |
|------|------|------|
| 10-05 | silent: 授权链=gap 文档头注用户显式授权 | 事故报告 §6 全部六项 |
| 10-05 | silent: lint 独立脚本+测试挂 requirement-coverage 族（RC-16..20） | 单机制单脚本+避免 registry 膨胀 |
| 10-05 | silent: 51.7 不占新顶格编号 | gap 文档执行要求原文 |
| 10-05 | silent: v132 目录"消失"事件=CWD 持久化 illusion（相对路径误判），非并行会话破坏 | pwd 取证+绝对路径复验全在 |
| 10-05 | silent: G3 两级锁定（兜底 --skip-dispatch/fmea，51.1 四锚硬门不倒退） | 单级对 silent 新计划成功率=0 违背 G3 目的 |
| 10-05 | silent: 修复批范围扩权（attest-plan/SKILL/root-resolution 超原允许清单）| 均为 CR/ALIGN P1 显式点名的必要最小改动（复审 P2 裁定补登记） |
| 10-05 | silent: resolver 占位行遮蔽 P2 登记不阻断（预存语义非 v132 引入）| 影响面=init 自生成计划首行占位，env 主通道不受影响；登记 deferred |
| 10-05 | silent: 51.6 事实同步（六→七子条/deferred→已落地）| 机制条款自述一致性=事实修正非语义改写（Rule 16 措辞先例） |
| 10-05 15:2x | silent: 纠正 C-01（簿记同步：Phase 状态行×5+Handoff 表 8 行回填+Decisions 行——无需求变更，纯 attest 后簿记补全）| Rule 51.7 重锁前置=Decisions 登记纠正编号（G3 自洽） |

## 🔗 Subagent Handoff 登记表
| 时间 | subagent_type | 目标 | 状态 | findings 落点 | checkpoint | verify_done |
|------|--------------|------|------|--------------|-----------|-------------|
| 10-05 12:1x | executor | 51.7+判例落盘（P1） | complete | §锚清单 | subagent-state/01-executor.md | ✅ |
| 10-05 12:3x | executor | 窗口 lint 脚本（P2） | complete | §机器面 | subagent-state/02-executor.md | ✅ |
| 10-05 12:5x | executor | R-COVERAGE 门（P2） | complete | §机器面 | subagent-state/03-executor.md | ✅ |
| 10-05 13:0x | executor | RC-16..20+registry（P2） | complete | §机器面 | subagent-state/04-executor.md | ✅ |
| 10-05 13:1x | executor | hook 文案+init 锚哈希（P3） | complete | §G3 | subagent-state/05-executor.md | ✅ |
| 10-05 13:3x | code-reviewer | CR+ALIGN 首轮（P4） | complete | §Issues | subagent-state/06-code-reviewer.md | ✅ |
| 10-05 14:0x | executor | 修复批 A：R 锚定+lint 边界（P4） | complete | §Issues | subagent-state/07-executor.md | ✅ |
| 10-05 14:2x | executor | 修复批 B+C：接线+解析器+枚举（P4） | complete | §Issues | subagent-state/08-executor.md | ✅ |
| 10-05 14:5x | code-reviewer | CR+ALIGN 复审轮（P4） | complete | §Issues 复审段 | subagent-state/06-code-reviewer.md | ✅ |

## Errors
| 时间 | 错误 | 处置 | Root Cause |
|--------|------|------|------------|
| 10-05 10:5x | 误判 plans/ 整目录消失+疑似并行会话竞态 | pwd 取证=CWD 停留 plans/task-v132，相对路径 illusion；绝对路径复验全部在位 | bash 会话 CWD 持久化+惯性相对路径；防御=关键操作一律绝对路径 |
