# Verification Contract & Phase Gates

## Goal (1 sentence)
修复子代理返回格式污染：task-planner 体系所有派发子代理的返回消息与检查点「最终结论」段严格遵循 8 字段固定列表格式——prompt 侧段结构校验（check-dispatch.sh return_section_check）+ 契约优先级声明（subagent_dispatch.md §7 三条）+ 条款补强（Rule 22.4b 污染三面）+ 返回侧机械校验（check-subagent-return.sh 四判据）+ selftest 守护（11 断言）五层落地。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 派发契约 §7 含优先级声明+点名禁令+段填写禁令三条款与「优先于你的 agent 定义」字面
  Evidence: worktree templates/subagent_dispatch.md:79/81/83（grep 命中）;8 字段块 status:→confidence: 原样在位（grep -c=2）;git diff +6/-0 既有 :62-77 零改动
- [x] VC-2: Rule 22.4b 含污染三面+主进程动作闭环
  Evidence: worktree references/critical-rules.md:185（awk 22.4b 段内截取命中「污染三面与主进程动作闭环（task-v161）」+「check-subagent-return.sh」）;git diff +1/-0
- [x] VC-3: 双脚本夹具分流
  Evidence: check-subagent-return.sh --selftest 4/4 PASS;summary 契约外字段块→rc=1「VIOLATION 判据二: 契约外字段: summary」;check-dispatch.sh pretool 污染夹具（重复标题+①②③清单+全套必需 key）→rc=2「返回格式段结构违规: C: 段内序号清单行 3 行且缺 key」;干净夹具→rc=0（独立子代理 8-verifier + 主进程两轮复跑一致）
- [x] VC-4: selftest 守护+registry 登记
  Evidence: selftest-subagent-return.sh Total: 11 PASS=11 FAIL=0 rc=0;selftest-registry.tsv 尾行 awk NF=4 首列=selftest-subagent-return.sh;registry 一致性 selftest-registry.sh 5/5（rows=72=actual 72）
- [x] VC-5: 全仓回归 FAIL=0 双轮独立
  Evidence: 子代理轮 72/72 rc=0（regression-run-1.log 103 行+7-code-runner.md acceptance 逐脚本原文行）;主进程轮独立复跑 selftest total=72 rc0=72 fail=0（Bash for 循环 timeout 120 逐脚本实跑）;含新增 selftest-subagent-return.sh 与改造 selftest-dispatch.sh 31/31 不破
- [x] VC-6: SKILL/dispatch-examples 级联
  Evidence: SKILL.md:308 Rule 22 摘要行含「return_section_check」+「check-subagent-return」;dispatch-examples.md:28「注（task-v161）」;git diff --numstat SKILL +1/-1（摘要行既有行内演进模式）+examples +2/-0
- [x] VC-7: 内置 agent 定义层污染源未越权修改+待授权登记
  Evidence: task_plan.md Decisions「不修改 ~/.zcode/agents/**」行+执行范围限制禁区行;worktree git status 8 面全在 scope 内;~/.zcode/agents 零改动（本任务未触碰）;待授权项将落 delivery-summary.md「待裁决」区块

---

## Phase Gates

### Phase 1: Requirements & Discovery（根因定位）
**Goal**: 三层根因定位+58 份实证量化
**Depends on**: none
**Done when**: findings 两节调研+用户判例归档
**Verification**: V-1.1 污染主源 file:line 锚（executor.md:45/general-purpose.md:31-48/explore.md:33）✓;V-1.2 实证 14/58=24.1% 合规率 ✓
Status: `complete` Last verified: 2026-10-10

### Phase 2: Planning & Structure
**Goal**: 计划+worktree+attest 三件套
**Depends on**: Phase 1
**Done when**: 5 gate OK 锁定+worktree 基点对账+pg 组声明
**Verification**: V-2.1 attest SHA 410790ee 四锚四 gate ✓;V-2.2 parallel_groups frontmatter 补齐（守卫双条件）✓
Status: `complete` Last verified: 2026-10-10

### Phase 3: Implementation
**Goal**: 六件产物（契约/条款/双脚本/守护/级联）
**Depends on**: Phase 2
**Done when**: 六 S-unit done+主进程逐件独立复验
**Verification**: V-3.1 六件 diff 纯度（+1/+6/+31/+93new/+90new/+1registry/+1-1/+2）✓;V-3.2 偏差登记（S6 超时未返 partial/S1 前言行/S5 验收口径裁决）✓
Status: `complete` Last verified: 2026-10-10

### Phase 4: Testing & Verification
**Goal**: 72 脚本回归+VC-1..7 独立复验
**Depends on**: Phase 3
**Done when**: FAIL=0 双轮+7 VC 全 PASS+委派 stats verdict=ok
**Verification**: V-4.1 rc0=72 fail=0（两轮）✓;V-4.2 VC 7/7（复验员 6/7+VC-5 progress 回填后闭环）✓;V-4.3 stats rate=0.6 verdict=ok violations=[] ✓
Status: `complete` Last verified: 2026-10-10

### Phase 5: Delivery
**Goal**: 合并 master+部署登记+交付总结
**Depends on**: Phase 4
**Done when**: merge --no-ff+worktree/branch 清理+delivery-summary 五要素含待授权项
**Verification**: V-5.1 合并后 master Read 关键文件+git log 复验;V-5.2 交付对比账本
Status: `in_progress` Last verified: 2026-10-10

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| subagent_dispatch.md §7 契约 | 修复以既有 8 字段契约为锚纯增量 | 符合（:62-77 零改动,追加三条） |
| critical-rules.md Rule 22 族 | 22.4b 段内追加,22.4c 机器面同步 | 符合（段内追加+守卫增强同 task 编号） |
| selftest 风格(selftest-dispatch.sh) | 新 selftest 仿其断言输出格式 | 符合（Total/PASS/FAIL 行+rc 语义） |
| registry 登记制(task-v150 教训) | selftest-registry.tsv 4 列 tab 追加 | 符合（NF=4 首列校验过） |
| Handoff 裸名纪律(v150 教训) | 类型名去 (model) 后缀 | 符合（stats violations=[]） |

## 委派统计复验（Rule 25.4）

```bash
bash skills/task-planner/scripts/check-delegation.sh stats plans/task-v161-subagent-return-format
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"Phase 2","executor":"主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）"},{"phase":"Phase 5","executor":"主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）"}],"violations":[],"verdict":"ok"}
```
（以上为机器 stats 实际输出摘要,原文含完整 main_direct 明细;violations 初始为 3 条 unverified_delegation——根因=Handoff 类型名带 (haiku-1) 后缀（v150 已知坑复发）,裸名化+pg0 两行补登后复跑 violations=[]）

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单例外理由（Phase 2=②计划系统文件维护;Phase 5=①git 编排+②簿记）
- [x] stats verdict=ok（非 violation）——delivery 放行

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查:本任务属技能文档/脚本变更,Q1 需求覆盖=verified(findings 转译核对+VC 覆盖 7/7);Q2 边界=8 面 diff 均在 scope;Q3 幻觉风险=全部结论带 file:line/命令输出锚;Q4 验证=双轮跑批+独立复验;Q5 造谣=无未验证声称（S5 裁决如实登记矛盾）;Q6 遗留=无阻断项
- [x] Evidence 抽查 ≥3 条:①subagent_dispatch.md:79-83 ②critical-rules.md:185 ③check-dispatch.sh:195 return_section_check+主进程夹具 rc=2 输出——均可 Read/复现
- [x] 豁免登记:无（无用户显式豁免需求;VC-5 FAIL→progress 回填为内部闭环非豁免）
- [x] 无未处置违规——outcome 不降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 子代理返回 8 字段格式纪律修复
对照 Verification Contract 逐条复验：
- [x] VC-1: subagent_dispatch.md:79/81/83 三条款+优先级句（8 字段块原样） → PASS
- [x] VC-2: critical-rules.md:185 污染三面+动作闭环 → PASS
- [x] VC-3: --selftest 4/4+summary rc1 点名+污染 pretool rc=2 段结构违规+干净 rc=0 → PASS
- [x] VC-4: selftest 11/11+registry 4 列登记 → PASS
- [x] VC-5: 72/72 FAIL=0 双轮独立（子代理+主进程） → PASS
- [x] VC-6: SKILL.md:308+dispatch-examples.md:28 级联 → PASS
- [x] VC-7: agent 定义层零越权+待授权登记 → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付（部署同步=待用户授权项,见 delivery-summary）。

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 5 Delivery（verification 已 COMPLETE） |
| 2 | Where am I going? | 合并 master→清理 worktree→delivery-summary |
| 3 | What's the goal? | 子代理返回 8 字段纪律五层修复（见上 Goal 句） |
| 4 | What have I learned? | findings.md（三层根因+实战证据:general-purpose 在优先级声明下返回纯 8 字段块） |
| 5 | What have I done? | progress.md（Phase 1-4 complete,六件产物+双轮回归+VC 7/7） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（v161 本任务收尾） |

**行为面遗留（如实登记）**：agent 定义层（~/.zcode/agents/executor.md:45 步骤进度模板/general-purpose.md:31-48 任务交付报告/explore.md:33 发现列表）的输出模板竞争未被本任务修改（越界未授权）——S1 优先级声明+主进程机械校验为覆盖层;根治需用户授权修改内置 agent 定义,已列 delivery-summary 待裁决。
