# Verification Contract & Phase Gates

## Goal (1 sentence)

修复 v091 遗留四组守卫缺陷（check-conflicts.sh INDEX 解析恒空+自计划跳过恒不等、check-drift.sh 两 quirk+:205 区间 awk 第 5 处复制、template-guide.md:69 文档锚漂移+计数过时），全量 selftest ≥518 PASS/0 FAIL，合并部署后三实体位 diff -r IDENTICAL。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 四组缺陷先稳定复现（Phase 1），修复后逐一反证不复现
  Evidence: 复现=findings.md S1 节（1a sed 区间提前终止逐段实测 stage1-5/1b 相对 vs 绝对 bash -x trace）+S2 节（3a 四夹具误报表/3b 五段管道实测/3c 探针组 P1-P7）；反证=S5-S9 修复记录（repo-s5 夹具 active_plans 非空+跨计划冲突 A 触发+自计划跳过、s8 四夹具+probe-e、s9 四夹具 pre/post）+Code Review 独立复跑三组负向验证（初值还原/去列限/自跳过反转均转红）→ PASS
- [x] VC-2: 仓侧全量 selftest 全绿且不低于基线 ≥518 PASS/0 FAIL
  Evidence: worktree S13 主进程逐脚本实跑求和 525/0（33 脚本全 rc=0，progress.md Phase 5 段逐脚本清单）+主仓合并后终验复跑 525/0（d82720e）；算术闭环 518 基线+1(CC-07)+6(CD-01..06)=525 → PASS
- [x] VC-3: CC-06 夹具随修复同步改造，selftest-check-conflicts 全 PASS 且断言语义有效（非恒真恒假）
  Evidence: S7=7bdd6ff 改造后 7/7 PASS（CC-06 冲突 A 计数==1+行内容逐字锁+CC-07 自计划零冲突）；负向验证双断言破坏实验转红（findings S7 节）+夹具与主仓 plans/INDEX.md:8-9 逐字节一致（sed 剥壳 diff） → PASS
- [x] VC-4: 合并 master 后三实体位与仓侧 diff -r 逐位 IDENTICAL
  Evidence: merge d82720e + smart-merge-back --deploy 三位 IDENTICAL（脚本自报）+ 主进程独立 diff -r ×3 全 0（.zcode/.claude/.config/opencode）+ sha256 同文件跨位一致抽查 → PASS
- [x] VC-5: 范围外零触碰+无功能性删除
  Evidence: git diff f15c285..d82720e --stat 恰 7 文件（5 代码+registry.tsv+template-guide.md）与 scope 表逐一对应；Code Review scope 纪律审查确认无越界混入；Rule 36.4 删除清单=空（全部为缺陷行为恢复，删除基线=git 历史） → PASS

---

## Phase Gates

### Phase 1: 取证——四组缺陷机理实证
**Goal**: 四组缺陷根因全部实证锁定，禁止猜根因后修
**Done when**: S1-S4 全 done 且证据落 findings ✓（1a/1b/3a/3b/3c/计数归因六结论）
**Verification**: V-1.1 复现证据（→VC-1）✓ V-1.2 接库裁决（S3 25 格矩阵）✓
Status: `complete` Last verified: 2026-09-27

### Phase 2: worktree + check-conflicts 修复+夹具改造
**Goal**: 1a/1b 修复+CC-06/07 至修复后语义
**Done when**: S5/S6/S7 三提交且 selftest 全绿 ✓
**Verification**: V-2.1（→VC-1）✓ V-2.2（→VC-3）✓
Status: `complete` Last verified: 2026-09-27

### Phase 3: check-drift 修复
**Goal**: 3a 初值+3b/3c 接库列限
**Done when**: S8/S9 两提交+正反夹具+3 调用方零波及 ✓
**Verification**: V-3.1（→VC-1）✓ V-3.2 38 计划单参 byte-identical ✓
Status: `complete` Last verified: 2026-09-27

### Phase 4: template-guide 锚+计数
**Goal**: 行号锚→章节锚+三声明实测对齐
**Done when**: S10/S11 两提交+旧值零残留 ✓
**Verification**: V-4.1 grep ':65'=0 ✓ V-4.2 三实测数自洽 ✓
Status: `complete` Last verified: 2026-09-27

### Phase 5: selftest 补写+全量回归
**Goal**: 行为级用例锁修复语义+全量 ≥518/0
**Done when**: S12 六用例+S13 525/0 ✓
**Verification**: V-5.1（→VC-2）✓ V-5.2 负向验证非恒真 ✓
Status: `complete` Last verified: 2026-09-27

### Phase 6: CR Gate+合并+部署+终验
**Goal**: APPROVED 后合并部署三实体位 IDENTICAL
**Done when**: CR APPROVED+d82720e 合并+部署 diff -r ×3=0+worktree 清理 ✓
**Verification**: V-6.1（→VC-4）✓ V-6.2（→VC-5）✓
Status: `complete` Last verified: 2026-09-27

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| materials/defect-evidence.md（必读） | 全部 S-unit 按其锚点执行；S1 实测推翻其 2 个候选根因并精确化（如实记录 findings S1） | 符合 |
| worktree-isolation.md（参考） | worktree 新路径规范+11.3 合约全过（干净合并+清理） | 符合 |
| v078 固定 sid 教训 | S12 夹具 mktemp 每次唯一+trap 清理（CR 复核确认） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":6,"phases_delegated":4,"main_direct_count":2,"delegation_rate":0.667,"main_direct":[{"phase":"5 …","reason":"S13 全量回归主进程白名单③机械验证命令（mini 档 Provider 拒绝实证）"},{"phase":"6 合并+部署+终验","reason":"白名单① git/worktree 编排+② 簿记"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均登记白名单内例外理由（Phase 5 混合=S12 executor+S13 白名单③；Phase 6 白名单①②）
- [x] rate 0.667 < 0.7 但 main_direct 全部带白名单标识 → **WHITELIST-EXEMPT 放行**（v091 同款口径）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 3 项（Q1 attest 锁定 32f81499/重锁；Q2 派发契约——S1 首派遭 dispatch-block 拦截一次补全契约 token 后放行；Q5 Rule 36 归因+36.4 空清单+CR Gate APPROVED），豁免 0 项，未处置 0 项
- [x] Evidence 抽查 ≥3 条：①check-conflicts.sh:152 修复行主仓 Read 复验 ②check-drift.sh:132/:220 两修复点 grep 实证 ③template-guide.md ':65' 零残留 ④主仓全量 525/0 独立复跑（均主进程第一手，非采信子代理自报）
- [x] 豁免登记：无
- [x] 无未处置违规 → outcome 不降级

## Goal Gate (终验)

```
## Goal Verification — 修复四组守卫缺陷，selftest ≥518/0，三实体位 IDENTICAL
- [x] VC-1: 复现+反证证据链（findings S1-S4 ↔ S5-S12）→ PASS
- [x] VC-2: 525/0（worktree+主仓双口径）→ PASS
- [x] VC-3: CC-06/07 改造+负向验证 → PASS
- [x] VC-4: diff -r ×3 = 0 → PASS
- [x] VC-5: 7 文件 scope 精确对应+零删除 → PASS

 outcome: COMPLETE
```

### 遗留与已登记面（如实披露，不阻塞 COMPLETE）
1. **check-drift.sh:274/:284 check_error_loop 区间 awk = 3c 同型第 6 处**（CR minor 发现，f15c285 既存未触碰，探针实证表体 0 行入管道）——建议后续任务与 3c 家族统一清理
2. **template-guide.md:32 §2.2 表缺 mini-lite/video 两行 + template-mapping.md :26「13 类」/§六表/:191 白名单注释同型漂移**（S4/S11 实测登记，超本任务 scope）——建议后续文档对账任务
3. **S13② plan glob 顶层形态 / UPS stat 慢源 / Tier B 7 项 / WF-10**——维持既有 deferred 不变（本任务范围外清单）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 交付（遗留 3 面已登记） |
| 3 | What's the goal? | 见 Goal |
| 4 | What have I learned? | findings.md（区间 awk 家族第 5/6 处、Handoff token 纯净形态） |
| 5 | What have I done? | progress.md（S1-S13+CR+合并部署） |
| 6 | Which tasks need processing? | INDEX 待处理区清零 |
