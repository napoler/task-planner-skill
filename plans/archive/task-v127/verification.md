# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner 技能增加「内容要求权重分级与评级」能力（Rule 50）：复合需求（存在性+程度约束）原子拆解 × 权重分级 × 分级评级，消除"只判有泪痣、忽略不注意看不到"的双断链缺陷。

---

## Verification Contract（终验逐条复验 — 2026-10-04 主仓 HEAD 38e562e）

- [x] VC-1: Rule 50 条款完整（### 50 标题+50.1-50.6 六子条），既有 Rules 零语义改动（纯增量）
  Evidence: `grep -n '^### 50' skills/task-planner/references/critical-rules.md` → :522；`grep -c '^50\.'` → 6；合流后 :545 起 Rule 51（v129）并存，1-49 原文零改动
- [x] VC-2: 零新 config 键（properties 保持 40）
  Evidence: `jq '.properties | length' skills/task-planner/config.json` → 40
- [x] VC-3: 原子验收条目表契约+泪痣 P/H+E/H 双条目样例在位（类型 P/E × 层级 H/S × 权重 × 判定刻度；程度双向判）
  Evidence: critical-rules.md :522-543（50.1 五列结构+50.2 默认 H+50.3 双向判+样例表两行）；三模板「评级契约」区块同构
- [x] VC-4: 消费侧落点（3 媒体 variant 模板评级契约区块+goal-gate VC 分级语义行）
  Evidence: templates/variant/{image-type(:40 起),character-design-type,qc-defect-type(:28)} 各含「📐 评级契约（Rule 50）」区块；references/goal-gate.md :18 分级语义行（退出标准后纯增量）
- [x] VC-5: SKILL.md 联动（全集行+摘要 bullet+媒体路由消费点；净增 ≤10 行）
  Evidence: SKILL.md :9「Critical Rules 全集 1-51（…50 内容要求权重分级与评级、51 需求覆盖与完成声称门控…）」※合流演进出 1-51 纪元（本任务原改 1-50，v129 Rule 51 合流后扩含 51，锚演进链 1-49→1-50→1-51）；:287 Rule 50 bullet；:364 路由行「+评级契约（Rule 50）」；本侧净增 +1 行（449→450），合流后 452 行 ≤558 钉上限
- [x] VC-6: 级联锚扩口径使新字面合法+全量回归 0 FAIL（fresh 复跑复核）
  Evidence: 终态 47 脚本全绿——PASS 合计 724 / FAIL=0（主仓合流级联修复 4ef8ec8 后逐脚本机械求和；`grep -E "FAIL=[1-9]"` 零命中）；fresh 独立复跑 4 脚本与执行期记录逐字一致（S9，checkpoint 12-s9-verifier.md）；级联锚演进=PT-08/CD-11 扩 `1-5[0-9]`、skill-split T-主 452、RG-06 宽容式、LA-11 去尾锁、RC-15 负断言 ^50→^52
- [x] VC-7: 新建守护 selftest-requirement-grading.sh 全绿+registry 登记行在位
  Evidence: `bash skills/task-planner/scripts/selftest-requirement-grading.sh` → Total: 7 PASS=7 FAIL=0（主进程两轮亲跑）；registry.tsv 含 requirement-grading 行（48 行，含 v129 coverage 行共存）

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: Requirements & Discovery — complete
两 explore 并行（仓内面/外部技能面）4/4+4/4 验收；findings §Requirements/§Research Findings 回填；检查点 01/02 status: done。

### Phase 2: Planning & Structure — complete
plan-writer（22.3① 改派 general-purpose）产出 task_plan+knowledge-brief；attest 锁定 c4ffe059…；用户 yes 批准。

### Phase 3: Implementation — complete
波 1（S1-S4 并行组）+波 2（S5-S7 并行组）全部 done；主进程逐一 Read 复核+第一手亲跑验证；worktree commits 211f59d/5bcb0ff。

### Phase 4: Testing & Verification — complete
S8 全量 46 脚本回归（唯一 FAIL=skill-split 449 锚过窄→S10 修锚 450 归零）；S9 fresh 复验+alignment-review APPROVED（P0=0 P1=0）；commit 3e782f4。

### Phase 5: Delivery — complete
S11 Code Review Gate APPROVED（零 P0/P1，P2×2 备注）；master 合流（v129 Rule 51 撞点四文件冲突解：50/51 并存+1-51 纪元+registry 双保留+锚 452）；合流级联 5 脚本修复归零（S12，4ef8ec8）；smart-merge-back → **merged(38e562e)**；部署 3 位全 IDENTICAL（zcode 位自保护 REJECTED→按 SOP 手动 rm+cp 后 0 差异）；worktree remove+branch -d 清理完成。

---

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（Phase 3 实现、Phase 4 验证全子代理；Phase 1 调研由 2 explore 子代理承担） |
| 主进程直做 Phase 清单 | Phase 2（白名单② 计划系统文件）、Phase 5（白名单①② git 编排/部署/簿记） |
| 子代理派发总次数 | 16 次（2 explore+1 plan-writer 失败+1 改派+4+2+1 波次实现+1 runner 失败+1 改派+1 fresh+1 CR+1 锚级联+1 合流修复） |
| 委派率 | 0.4 < 0.7 → **WHITELIST-EXEMPT 放行**（直做理由全命中 Rule 25.3 ①②；Plan Writer/code-runner 两次 provider 失败改派亦留痕） |

## 质量门控统计（Rule 26 / Rule 42）

| 门 | 结果 |
|----|------|
| 3-File Gate（19.5） | 各 Phase complete 前 check-3file-gate.sh exit 0（P1/P3/P4 实测留痕） |
| Code Review Gate | APPROVED（S11 隔离审查，零 P0/P1） |
| alignment-review（42.6.2） | APPROVED（S9 五维扫描 10 变更文件） |
| attestation | c4ffe059… 锁定，合流重规划（D8/D9）随 Phase 簿记登记 |
| 内容质量门控 | n/a（代码组任务） |

## 遗留与风险

- P2×2（CR 备注，均非缺陷）：①新 selftest 100644 非可执行位（与仓内 16 个既有脚本惯例一致）；②RG-02 `^50\.` 计数未来可被行首 "50." 文本虚增（误宽方向，阈值 ≥6 有裕量）
- master 后续演进若再动 SKILL.md 行数，skill-split T-主 452 锚需联动（演进链 440→…→452）
- v124（图像/视频生成执行体）落地后建议在其 QC 工序模板挂接 Rule 50 条目表（消费点已由 50.5 预留）
