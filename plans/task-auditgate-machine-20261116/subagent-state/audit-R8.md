# R8 复审检查点 — task-auditgate-machine-20261116

- 轮次: R8（范围化复审）
- 状态: DONE
- 完成时间: 2026-11-17
- 范围: ①R7 五项修复闭环（I-1/I-2/W-2/Q-1/Q-2）+ 判别性抽测 ②修复引入新缺陷 ③历轮遗留升级必要性
- 需求锚: R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」（逐字锚 task_plan.md:16-18 与 user-session-log.md:12 一致）
- 只读确认: 除本检查点外未写任何仓库文件；mock/fixture 全在 /tmp/r8mock /tmp/r8mock/fx5 等临时目录

## 一、R7 五项修复闭环（逐项盘上核验）

| 项 | 结论 | 盘上证据 |
|----|------|---------|
| I-1 容忍 token + 双正例 + 四处同步 | 通过 | verification.md:15 判据 `^- 问题清单([（(][^）)]*[）)])?:`；VC-1 命令含 r3（规范）+ r7（真实 R6 字节形态）；task_plan:78/:141/:275、kb:27/§4-10/§4-17、progress:76、findings:50/91 均含容忍口径 |
| I-2 r5/r6 独立负例 + 逐约束承重 | 通过（独立复现） | verification.md:17 fixture a/b 实存；末断言 r1..r7 全链；verification.md:23 承重归属「边界↔b/锚定↔a/全缺↔r4」 |
| W-2 legacy SKIP 用例 | 通过 | verification.md:15/:23「无声明 → rc0 且输出 `[audit-gate] SKIP legacy-no-decl`」；自建 mock 实测 rc0+token |
| Q-1 H2 前提三处登记 + progress 占位行 | 通过 | verification.md:15、kb:27+/§4-16、task_plan:78/:141/:275、progress:78（append 行，未改写既有行） |
| Q-2 rc 分层 | 通过 | verification.md:15/:23、kb §4-16、task_plan:78/:141/:275；mock 实测：缺失 rc2 / 空 rc1 / chmod000 rc2 |

## 二、判别性抽测（自建参照 mock，未抄 fix-R7 代码）

方法：按 verification.md VC-1 判据独立实现 `/tmp/r8mock/check.sh`（lane 优先 + 容忍 token + H2 聚合边界 + 结论行 ERE 行首锚定 + rc0/1/2），
再从 verification.md:17 逐字提取 VC-1 命令（`bash -n` 通过、反引号计数=0），仅把 `C=` 换成 mock 后执行。

| 变体 | VC-1 rc | r1..r7 实测 | 判定 |
|------|---------|-------------|------|
| full（完全加固） | 0 | 1,1,0,1,1,1,0 | 七态与期望全一致 |
| onlyb（仅边界） | 1 | 1,1,0,1,**0**,1,0 | r5/fixture a 抓住 |
| onlya（仅锚定） | 1 | 1,1,0,1,1,**0**,0 | r6/fixture b 抓住 |
| old（全缺） | 1 | 1,1,0,**0**,0,0,0 | r4/r5/r6 抓 |
| strict token | 1 | 1,1,0,1,1,1,**1** | r7 承重确证 |

行为态（mock 直测）：真实 progress.md 现状（末审计段=R7 REJECTED）→ rc1（fail-closed 正确，R8 登记前不放行）；真实 R6 段字节形态 → rc0；缺失→rc2+WARN；空→rc1；chmod000→rc2；无声明→rc0+SKIP legacy-no-decl；mini 单独→rc0；mini×L1→rc1；L2→必审；L1+`[plan-audit-skip]` 不旁路（rc1）。
→ 与 fix-R7 段（progress:423-431）声称的矩阵逐格一致，R7 判别性结论独立成立。

## 三、新缺陷面（②）

- R1-R3 逐字锚未动（task_plan:16-18 ↔ user-session-log.md:12）。
- user-session-log.md：4355 B / mtime 2026-11-16 23:39:23.409788871 +0800 / sha256 前12 `d12cd51f8604` 未变。
- 审计段 7 个（R1-R5 REJECTED / R6 APPROVED / R7 REJECTED）；行首锚定 APPROVED=1（progress:316，R6）；无新增 [plan-audit-RN] 段。
- 17 条 Verify command 反引号计数全 0；check-plan-dispatch 列解析无报错（4 个 Phase 表、SKIPPED=0）。
- 八机械门全 rc=0（dispatch/rvc/nonvacuous/template/tier(lines=491)/step-placeholder(22行)/goal-cjk/delegation rate=0.800 verdict=ok）。
- Handoff #17/#18 在位；派发算术 14（critic×7+plan-writer×7）+4 排队=18 与表行数一致。
- 仓库既有 M 文件 mtime=2026-11-15 22:07（早于本任务）；config.json 无 `"audit` 键。

## 四、发现清单

- W-1[WARNING] `task_plan.md:80/256/257/277` — R7 新增判别用例只落在 verification.md VC-3，未同步到 task_plan 的 VC-3 行、Phase 2 规格定稿清单、Phase 3 S3 验收清单（S3 输入列亦未指 verification.md）。S3 执行体按验收清单建 selftest 可能漏建 r5/r6/r7/legacy SKIP 用例，而 VC-3 机器判据仅「脚本 exit 0 + registry 行」无法发现。建议：四处补列或 S3 输入列显式指向 verification.md:23。
- Q-1[QUESTION] `verification.md:15` — 最小形态「`审计体:`/`轮次:` 维持字面」未说明是段内子串还是行首独立行；r3（审计体内联于轮次行）与 r7（独立行）共同隐含「子串即可」，建议补一句钉死，避免 S1 实现误取行首独立行导致 r3 必败返工。
- N-1[NIT] `progress.md:96` — 5-Question「Where am I」仍写「R7 修复轮待派」，与 task_plan:205/209、verification.md:207 的「修复轮 7 已收口」不同步（登记时点同步类，R6/R7 已两次同型留档，无新影响）。
- N-2[NIT] `findings.md:50` — 「checker 复用同形」仍指先例未加固聚合命令，与同文件 :179-208 R6a 加固段、kb:27、verification.md:15 矛盾（研究记录内被后续段推翻，建议就地加指针）。

## 五、历轮遗留升级必要性（③）

- R6 N-3（progress-hash 缓存失效显式用例）：仍留档，VC-2/VC-3「缓存隔离」已覆盖语义，无新增失败证据 → 维持。
- R7 W-1（5Q 滞后）已复现为 N-1：属登记时点同步节奏，无交付影响 → 维持留档，不升级。
- R7 W-2/Q-1/Q-2 已闭环（见上）；R4/R5 留档项未出现新证据 → 维持，不升级。
- 无升级为 CRITICAL/IMPORTANT 的论据。

## 六、负结果报告（预期可能有但未发现）

- 未发现 R7 修复引入的判据自相矛盾（verification.md:15 判据 ↔ :17 命令 ↔ :23 VC-3 用例三面一致）。
- 未发现 R6a 两约束在四处描述中的语义漂移（task_plan:38/:78/:141/:275、verification:15、kb:27）。
- 未发现 new [plan-audit-RN] 段、APPROVED 预写、或 R1-R3 锚点改写。
- 未发现 Verify command 反引号包裹/真空命令（check-vc-nonvacuous rc=0 复核）。
- 未发现 user-session-log 变更、config 新增键、skills/** 本轮改动。
- 未发现表格管道列错位（R6a 修复后复现无 SKIPPED 报错）。

## 裁决

发现合计 4（0 CRITICAL / 0 IMPORTANT / 1 WARNING / 1 QUESTION / 2 NIT）→ 结论: **APPROVED**
