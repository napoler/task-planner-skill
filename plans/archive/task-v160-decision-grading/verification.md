# Verification Contract & Phase Gates — task-v160-decision-grading

## Goal (1 sentence)

task-planner 技能建立 Rule 72 决策分级与用户打断纪律：A 级重大变更（推翻已确认计划要素/不可逆/对外）必须询问用户、禁擅自执行；C 级琐碎事项禁止上抛用户、必须自动消解+登记；媒体产物基础性质检（物理常识错误）设为执行体硬门、不合格禁送审代审。

## Verification Contract

- [x] VC-1: Rule 72 条文在位（72.1-72.6 六子条+三级关键词）
  Evidence: `grep -c "^## Rule 72" references/critical-rules.md`=1、`grep -c "^### 72\.[1-6] "`=6；DG-01/DG-02 PASS（三级词 A 级必须询问/C 级禁止询问/基础质检硬门各 ≥1）
- [x] VC-2: 触点修补零缺口（6 文件）
  Evidence: critical-rules 28.3/41.2/41.3/44.2/44.5 五处指针+image-type/multiview-ref-type 送审质检硬门+companion×2 熔断分级，逐一 grep 命中（DG-05/08/09/10/11 PASS）
- [x] VC-3: 机器守护在位
  Evidence: `bash scripts/selftest-decision-grading.sh`→exit 0 `Total: PASS=12 FAIL=0 WARN=0`；registry.tsv 登记行 NF=4
- [x] VC-4: 全量回归零破坏（合并后 master 72 脚本 ΣFAIL=0）
  Evidence: Round 6/7 合并态 72/72 rc=0；master 合并后复跑 72/72 fails=0（progress.md Phase 6/8 段）
- [x] VC-5: 行为实证（三级条款文本在位且语义完整）
  Evidence: `grep -c "A 级（必须询问" critical-rules.md`≥1、`grep -c "C 级（禁止询问"`≥1、`grep -c "基础质检硬门"`≥1；media 模板含「物理常识错误」「禁上抛代审」
- [x] VC-6: 合并回+部署
  Evidence: master merge commit `6a3a2f2`；smart-merge-back --deploy→部署位逐位 IDENTICAL；worktree/branch 已清理
- [x] VC-7: 双审查 APPROVED（CHANGES 闭环）
  Evidence: code-quality-review APPROVED（P0/P1=0；P2+3Nit→S13a/b/c/d 修复）+alignment-review APPROVED（索引残留 P2→S13c 修复）；修复项全部复验通过

## Phase Gates
- Phase 1-5: complete（P1 归因/P2 条文接线/P3-P4 触点/P5 守护）
- Phase 6: complete（Round 1-4：65/69→69/69；12 处级联清账）
- Phase 7: complete（双审查 APPROVED+CHANGES 闭环+Round 4 69/69）
- Phase 8: complete（合并态 UA-UG 13 文件并集解+UZ 交叉修复+Round 6/7 72/72+merge 6a3a2f2+land 72）Last verified: 2026-10-10

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| critical-rules Rule 41/44/47/50/69/70/72 | Rule 72.5 关系表逐条核对 | 符合 |
| v155 归因材料（5 Whys） | findings.md 引用对齐 | 符合 |
| selftest 范式+registry 纪律 | DG 同构 RRV；registry NF=4 | 符合 |
| worktree 隔离 SOP | §十一全流程（创建→开发→冲突解→合并→清理） | 符合 |

## 委派统计复验（Rule 25.4）
```json
{"phases_total": 8, "delegated": 7, "main_process": 1, "rate": 0.875, "verdict": "PASS"}
```
- [x] 主进程直做 Phase（P8 合并/部署/簿记）已登记白名单例外理由（① git/worktree 编排+② 计划系统簿记）
- [x] rate 0.875 ≥ 0.7 floor；verdict 非 violation

## 质量门控统计（Rule 26）
- [x] Q1-Q6 触发 0、未处置 0（Q3 伪造证据=0；全部验收来自第一手命令输出与子代理检查点交叉复验）
- [x] Evidence 抽查 3 条：DG 12/12 自跑、master 回归 72/72、部署位 diff=0
- [x] 无用户显式豁免需求；无未处置违规 → outcome=COMPLETE

## 需求覆盖核对表（Rule 51.3 — 交付必载）
| 需求# | 用户原话（摘） | 判定 | 证据路径 |
|-------|--------------|------|---------|
| R1 | 无关紧要的交用户决策，重大的毫不犹豫恶意修改掉（换风格不问） | covered | Rule 72.1 A 级/C 级（critical-rules.md Rule 72 段）；72.2 呈报禁令；DG-01/02 |
| R2 | 生成方式这么重大的决定…完全违背之前所有计划，完全不通知用户 | covered | 72.1 A 级①+72.2（未询问即执行=最高档违规）；触点 T1/T2 |
| R3 | 猫咪五条腿这种基础性错误审核不出来，让用户主动审核 | covered | 72.4 基础质检硬门+media 送审模板 T5（DG-09）；companion T6（DG-10） |
| R4 | 一小时任务跑十几分钟就被无关紧要事情打断 | covered | 72.3 琐碎上抛禁令（C 级禁问+打断预算=0）；T3/T4 |
| R5 | 在无关紧要事情上一直骚扰用户、卡住整个执行 | covered | 72.3+C 级自动消解登记；A/B/C 三级全域覆盖（VC-2 六触点） |

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3/R4/R5（全部） |
| **裁决** | **solved** |
| **解决证据锚** | VC-1..VC-7 全 PASS：Rule 72 条文（critical-rules.md Rule 72 段）→6 触点引用→DG-01..12 静态守护+双审查闭环 |
| **未解决面+原因** | 无 |
| **已排除路径** | 无 |

## Goal Gate
```
## Goal Verification — Rule 72 决策分级与用户打断纪律
- [x] VC-1: 条文在位（grep 1+6 子条） → PASS
- [x] VC-2: 6 触点文件引用零缺口 → PASS
- [x] VC-3: selftest 12/12+registry 登记 → PASS
- [x] VC-4: master 72/72 ΣFAIL=0 → PASS
- [x] VC-5: 三级关键词+质检硬门文本在位 → PASS
- [x] VC-6: merge 6a3a2f2+部署 IDENTICAL → PASS
- [x] VC-7: 双审查 APPROVED+CHANGES 闭环 → PASS
outcome: COMPLETE
```

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 8 complete（全部终态） |
| 2 | Where am I going? | 交付用户（delivery-summary.md） |
| 3 | What's the goal? | Rule 72 三级决策纪律+质检硬门 |
| 4 | What have I learned? | findings.md（归因/13 文件并集解/级联清账） |
| 5 | What have I done? | progress.md（8 Phase 全记录） |
| 6 | Which tasks need processing? | 用户第三条反馈的总结模板半边（v161 已覆盖派发/返回格式源，总结模板面待用户确认立项） |
