# Verification Contract & Phase Gates — task-v120

## Goal (1 sentence)

complex-planner 以纯增量方式联入 task-planner 技能 2 处升级叙事（SKILL.md:349 + critical-rules.md:149），行数不变，定向部署 2 文件×3 位，v119 D4 清账。

---

## Verification Contract

- [x] VC-1: SKILL.md 规划行超限动作列同时含 `升级 ComplexProblemSolver`（保留，grep -c=2：:339+:349）与 `complex-planner`（新增）
  Evidence: worktree/master SKILL.md:349（主进程 sed -n 一手复核 05:35）；grep 原始输出存 subagent-state/1-code-assistant.md
- [x] VC-2: critical-rules.md :149 原句保留（grep -c=1）且括注含 complex-planner
  Evidence: `Complex Problem Solver(高复杂度规划类亦可升级 complex-planner,GLM5.3/Opus 级备用)`（sed+grep 一手提取）
- [x] VC-3: 行数不变——SKILL.md=444、critical-rules.md=483（改前/改后双测一致）
  Evidence: wc -l 输出（progress.md Phase 1；master 53936ec 基线复测 R6 同值）
- [x] VC-4: 全量 selftest TOTAL=43 FAIL=0 + smoke 17/0（基线随 v118 新增 dispatch-grain 上移至 43，D7 修订）
  Evidence: 命令输出（progress.md Phase 2；接管记录 subagent-state/2-code-runner-agent.md）
- [x] VC-5: 部署前方向审计（3 位 diff 恰好只含本任务 2 行改动=无未收编前向更新）+ 定向部署后 3 位×2 文件 diff=0（6/6）
  Evidence: audit diff 输出（仅 349c349/149c149）+ `ALL 6 DIFF=0 ✅`（progress.md Phase 3）
- [x] VC-6: merge 6961857 落 master；worktree/分支清零；v119 memory D4 状态更新
  Evidence: git log + worktree list + memory 文件 diff（本次簿记）

---

## Phase Gates

### Phase 1: 两处行内纯增量改
- [x] V-1.1 → VC-1/VC-2（双锚+保留证据）
- [x] V-1.2 → VC-3（行数 444/483 不变；表格列数 8=8）
Status: `complete` Last verified: 2026-10-03 05:35（主进程一手 sed/grep/wc 复核，commit 562c457）

### Phase 2: 全量 selftest 回归
- [x] V-2.1 → VC-4（TOTAL=43 FAIL=0）
Status: `complete` Last verified: 2026-10-03 05:4x（执行体=主进程接管白名单③，计划预案内，1 次拒绝即接管零重试）

### Phase 3: 合并回 + 定向部署 + 终验簿记
- [x] V-3.1 → VC-5（方向审计+6/6 diff=0）
- [x] V-3.2 → VC-6（merge 6961857 + 清理 + memory）
Status: `complete` Last verified: 2026-10-03

---

## 委派统计复验（Rule 25.4）

机器口径：`{"rate":0.333,"verdict":"ok","violations":0}`（delegated=1/3）
- [x] 主进程直做白名单核对：P2=白名单③（机械验证命令，计划预案"1 次拒绝即接管"——晨间 v119 已实证 mini provider 不可用）；P3=白名单①②③（git 编排+簿记+机械 diff）
- [x] rate 0.333 < 0.7 但全部直做理由命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行**（首轮 verdict=violation 系 P2 Executor 字段缺白名单关键词，补"Rule 25.3 白名单③"后 verdict=ok）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 0，豁免 0，未处置 0
- [x] Evidence 抽查 3 条：VC-1（sed -n 349p 一手）✓、VC-4（TOTAL=43 FAIL=0）✓、VC-5（ALL 6 DIFF=0）✓
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate

```
## Goal Verification — complex-planner 联入升级叙事（纯增量、行数不变、部署 3 位）
- [x] VC-1 → PASS  - [x] VC-2 → PASS  - [x] VC-3 → PASS
- [x] VC-4 → PASS  - [x] VC-5 → PASS  - [x] VC-6 → PASS
 outcome: COMPLETE
```

**Rule 36 合规记录**：36.2 归因=v119 D4 遗留+用户显式选"2"；36.3 删除基线=零删除（纯增量子句/括注）；36.4 语义改写 2 项=D2/D3 随 D1 批准确认；36.5 纯增量✓；36.6 回归=selftest 43/0。

**未验证显式登记**：无——全部 VC 均有第一手机器证据。（GLM 行为级冒烟仍属 v119 遗留建议，非本任务 VC 范围。）
