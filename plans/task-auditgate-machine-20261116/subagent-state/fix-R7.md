# fix-R7 — 修复轮 7（R7 REJECTED 五项计划面修复）

- 起始时间：2026-11-17T05:35 起
- 执行体：Plan Writer（独立上下文）
- 工作目录：/mnt/data/dev/task-planner-skill
- 任务书：`subagent-state/fix-R7-prompt.md`
- 输入：progress.md [plan-audit-R7] 段 + R7 登记时点同步段；`subagent-state/audit-R7.md`

## 动工前计划（逐项）

| 项 | 目标 | 落点 |
|----|------|------|
| I-1 | `问题清单` token 容忍全角/半角括注后接冒号（ERE `^- 问题清单([（(][^）)]*[）)])?:`）+ 真实 R6 段字节形态 fixture 正例（r7）+ 保留规范示意形态正例（r3）；`审计体:`/`轮次:` 维持字面 | verification.md:15/16/17、task_plan.md:78/:141/:275、knowledge-brief.md:27/:69、findings.md:41/:52/:91、progress.md:76 |
| I-2 | VC-1 增 r5（fixture a：REJECTED 段内裸文 APPROVED → rc1）与 r6（fixture b：后随 H2 块锚定 APPROVED → rc1）；VC-3 补两行为用例；判据改逐约束承重归属 | verification.md:15/17/23 |
| W-2 | VC-3 补「无声明 → rc0 且输出含 SKIP legacy-no-decl」用例；VC-1 判据提及该分支 fixture 承重 | verification.md:15/23、task_plan.md:78/:275 |
| Q-1 | 聚合边界仅认 H2 的写作规范依赖显式登记（后随块必须 H2；H3/粗体则静默退化，checker 注释须登记） | verification.md:15、knowledge-brief.md:27、progress.md 占位区 append、task_plan.md:141/:275 |
| Q-2 | progress.md 缺失/不可读=rc2（fail-open+WARN）；存在但空=rc1（无留痕）；VC-3 rc2 用例=删除文件 | verification.md:15/:23、task_plan.md:141/:275、knowledge-brief.md §4 |
| 簿记 | R7 修复轮 H2 段追加；Handoff/派发算术同步；verification 5Q+交叉验证、task_plan Current/Next 同步 | progress.md、task_plan.md:205/:209/:440、verification.md:200/:207-211 |

## 约束自检（开工前）
- 逐字锚 task_plan.md:16-18 / user-session-log.md：不动
- 不新增 `[plan-audit-RN]` 段（R7 修复轮段用 `## 2026-11-17 R7 修复轮…` H2）
- 禁碰 skills/**、禁创建仓库脚本（mock/fixture 全在 /tmp）

## 进度
- [x] 读任务书 + progress.md + audit-R7.md + 三计划文件 + findings/kb
- [ ] I-1 落盘
- [ ] I-2 落盘
- [ ] W-2/Q-1/Q-2 落盘
- [ ] 簿记同步
- [ ] /tmp 判别性实测（I-1 新旧对照、I-2 四变体、VC-1 端到端）
- [ ] 八机械门重跑
- [ ] 三约束自证

## 完成后回填
（见下方追加段）

## 完成后回填（2026-11-17）

### 处置结果（全部实际 Edit 落盘）
| 项 | 结果 | 落点 |
|----|------|------|
| I-1 | `问题清单` 容忍全角/半角括注后接冒号（ERE `^- 问题清单([（(][^）)]*[）)])?:`）；`审计体:`/`轮次:` 维持字面；VC-1 增 r7 真实生产形态正例（R6 字节形态），保留 r3 规范示意形态正例；VC-3 同步双正例 | verification.md:15/16/17/23、task_plan.md:78/141/275、knowledge-brief.md:27/69(+§4-17)、findings.md:41/52/91、progress.md:76 |
| I-2 | VC-1 增 r5（fixture a 段内裸文 APPROVED → rc1，抓仅锚定实现）与 r6（fixture b 后随 H2 块锚定 APPROVED → rc1，抓仅边界实现）；末断言 `r1..r7`；VC-3 补两用例；判据改逐约束承重归属 | verification.md:15/17/23 |
| W-2 | VC-3 补「无声明 → rc0 且输出 `[audit-gate] SKIP legacy-no-decl`」用例；VC-1/plan VC-1 标注 fixture 承重 | verification.md:15/23、task_plan.md:78/275 |
| Q-1 | 三处契约：「聚合边界仅认 `^## `（H2）——后随块必须用 H2 标题，H3/粗体则静默退化，checker 注释登记」；progress 占位区 append 写作规范行；本段 H2 自证 | verification.md:15、kb:27(+§4-16)、task_plan.md:78/141/275、progress.md 占位区 |
| Q-2 | 「progress.md 缺失/不可读=rc2（fail-open+WARN）、存在但空=rc1」；VC-3 rc2 用例=删除文件 | verification.md:15/23、task_plan.md:78/141/275、kb §4-16 |
| 簿记 | R7 修复轮 H2 段（处置+实测+门+三约束+复跑留痕）；Handoff #17/#18；派发算术 14 次（+4 排队=18）；task_plan Current/Next；verification 交叉验证+5Q | progress.md、task_plan.md:205/209/440/447-465、verification.md:200/207-211 |

### /tmp 判别性实测（真实输出，`/tmp/r7t`）
```
I-1  OLD(strict) rc=1 :: FAIL 缺问题清单（字面）   |   NEW(tolerant) rc=0 :: PASS
I-2  fixture   full  onlyb  onlya  old
     real_r6    0     0      0      0
     spec       0     0      0      0
     mid        1     1      1      0
     fxa        1     0*     1      0      (*假 PASS)
     fxb        1     1      0*     0      (*假 PASS)
VC-1 full  rc=0  SUBS r1=1 r2=1 r3=0 r4=1 r5=1 r6=1 r7=0
VC-1 onlyb rc=1  SUBS r5=0（fixture a 抓）
VC-1 onlya rc=1  SUBS r6=0（fixture b 抓）
VC-1 old   rc=1  SUBS r4=0 r5=0 r6=0
VC-1 strict rc=1 SUBS r7=1（旧 token 判据在真实形态必失败 → r7 承重）
补充：缺失 rc=2 / 空 rc=1 / chmod000 rc=2 / 无声明 rc=0+SKIP / mini×L1 rc=1 / mini rc=0 / L1+skip rc=1(按留痕)
bash -n：mock rc=0、vc1.mock rc=0、vc1.mock.subs rc=0；VC-1 命令反引号计数=0
```

### 八机械门（2026-11-17 真实 rc，全 0）
```
check-plan-dispatch.sh     rc=0（2 条非阻断 WARN；SKIPPED=0）
check-delegation.sh stats  rc=0  rate=0.800 violations=[] verdict=ok
check-rvc-coverage.sh      rc=0  R=3 VC=6 映射行=3
check-vc-nonvacuous.sh     rc=0  6 条 VC 无真空命令
check-template-type.sh     rc=0  rule-enhancement
check-tier-consistency.sh  rc=0  standard/L1 lines=491 phases=5 vc=6 sunit=0 scope=4
check-step-placeholders.sh rc=0  扫描 22 行
check-goal-cjk.sh          rc=0  16 个 CJK 词
```

### 三约束自证
- ① R1-R3 逐字锚 `task_plan.md:16-18` 未动（sed 输出与本轮开工前一致）。
- ② `user-session-log.md` 未动：sha256 前 12 位 `d12cd51f8604`、4355 B、mtime `2026-11-16 23:39:23.409788871 +0800`。
- ③ 未新增 `[plan-audit-RN]` 段：段数=7（R1-R7）；行首锚定 APPROVED=1（仅 R6）；未锚定 token=7（追加前 6，+1 为本段 fixture 意见文本元引用，非审计段级结论）。

### 未改
`skills/**`（工作树中 3 个 skill + CLAUDE.md/README_zh.md 的修改 mtime 均为 2026-11-15 22:07，早于本任务，非本轮引入）、`user-session-log.md`、其他计划目录、仓库脚本；mock/fixture 全在 `/tmp/r7t`。
