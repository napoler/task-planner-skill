# Verification Contract & Phase Gates

## Goal (1 sentence)

将 zcode 部署位 2026-09-10/11 两批 10 文件前向更新收编回 canonical master（c9309aa），完成文档联动、selftest 验证、部署 9 位对账复验，无回归，并产出未收录改进分析清单。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 10 漂移文件全部收编，合并后 canonical 与部署侧逐文件 diff=0
  Evidence: worktree 收编后 10/10 `diff -q` 全等（检查点 02-executor.md §S1 证据 2 + 主进程复核 Bash 输出）;合并 c9309aa 后重部署 3 位 diff -rq 全零（检查点 04-deploy.md §S2 复验 + 主进程抽验 zcode 位 IDENTICAL）
- [x] VC-2: 文档联动净零或已同步，无悬空指针
  Evidence: commit 7419e43（critical-rules.md Rule 22.9 补 sess 前缀剥除+gc 扩扫 side 哨兵、Rule 22.4c 补三级解析 warn 降级+文件身份判定,共 3 处最小修订 +2/-2）;README/SKILL.md 随 10 文件收编自动一致;docs/ARCHITECTURE.md 仅文件名列表经审计不阻塞（检查点 01-gp-audit.md 联动面列）
- [x] VC-3: selftest 全量 fail=0（≥v059 基线 90 用例,无新增文件）
  Evidence: worktree 内 5 套件 active-plan 13 + dispatch 12 + delegation 38 + plan-dispatch 6 + fallback 21 = 90 用例 fail=0 EXIT=0×5（检查点 03-runner.md）;部署后 zcode 位抽跑 dispatch 12/12 + active-plan 13/13（检查点 04-deploy.md §S2 复验）
- [x] VC-4: 合并回 master 后重部署 task-planner 3 位 diff -rq 全 IDENTICAL + verify.sh 全 pass
  Evidence: 3 位（zcode/claude/opencode）rm -rf + cp -rL 后 diff -rq EXIT=0×3;TASK_PLANNER_ROOT 各位 verify.sh 25 pass/0 fail EXIT=0×3（中性 CWD,主进程 /tmp 抽验一致）;执行位保留、__pycache__ 零残留（检查点 04-deploy.md）
- [x] VC-5: 无回归——companion 6 位 + plan-writer agent 2 位只读复验不变
  Evidence: companion 6 位（todo-skill×2/task-drift-guard×2/plan-resume×2）diff -rq 全零差异;plan-writer zcode 位 IDENTICAL、claude 位仅第 7 行 model 行适配差异（预期,未动）（检查点 04-deploy.md §S3）
- [x] VC-6: 全程工作树隔离 + 簿记完整
  Evidence: worktree wt/task-v060-drift-collect（基线 bb34bf2）内 e749017+7419e43 两 commit → merge --no-ff 生成 c9309aa;`git worktree remove` + `branch -d` 已清（git worktree list 仅主仓）;INDEX 刷新+attest 复锁+簿记 commit 于 Phase 5 完成（progress Phase 5 段）

---

## Phase Gates

### Phase 1: 漂移审计与方向判定
**Goal**: 10 文件逐文件 diff 审计,判定收编方向,产出改进语义清单
**Depends on**: none
**Done when**: 方向判定有第一手证据;结论落盘 findings + 检查点
**Verification**:
- [x] V-1.1: 检查点 01-gp-audit.md 含 10 文件审计表 → 存在
- [x] V-1.2: 子代理反向判定经主进程特征探针复核修正（grep `_side` 6/2/5 vs 0 + 命中行原文）→ findings #1
Status: `complete` Last verified: 2026-09-11

### Phase 2: worktree 收编 + 文档联动
**Goal**: 10 文件拷入 worktree + critical-rules 联动修订 + 逐 Phase 提交
**Depends on**: Phase 1
**Done when**: 10 文件与部署侧逐字节一致;联动完成;scope porcelain 空
**Verification**:
- [x] V-2.1: commits e749017(+428/-95)+7419e43(+2/-2) → git log
- [x] V-2.2: selftest-dispatch 12/12 免改写实证 → 检查点 02 §S2a
Status: `complete` Last verified: 2026-09-11

### Phase 3: worktree 内验证
**Goal**: selftest 全量 + verify.sh 确认零回归
**Depends on**: Phase 2
**Done when**: 90 用例 fail=0;verify fail 均定性为预期
**Verification**:
- [x] V-3.1: 5 套件 EXIT=0×5 fail=0 → 检查点 03
- [x] V-3.2: verify 22/3 的 3 fail 定性（部署滞后×2+计划状态×1）→ Phase 4 归零复验
Status: `complete` Last verified: 2026-09-11

### Phase 4: 合并回 master + 部署 9 位对账
**Goal**: merge 回 master,重部署 3 位,9 位+agent 2 位对账
**Depends on**: Phase 3
**Done when**: merge commit 生成;3 位 diff=0;verify 25/0×3;companion/agent 无新差异;worktree 清理
**Verification**:
- [x] V-4.1: c9309aa + worktree list 仅主仓 → git log/list
- [x] V-4.2: 3 位 diff 零 + verify 25/0×3 + 主进程抽验 → 检查点 04
Status: `complete` Last verified: 2026-09-11

### Phase 5: 簿记收尾与交付
**Goal**: 终验文档 + INDEX/attest/簿记 commit + 记忆更新 + 交付分析清单
**Depends on**: Phase 4
**Done when**: 本文件 VC 全勾;check-complete exit 0;簿记 commit;用户收到分析清单
**Verification**:
- [x] V-5.1: check-complete.sh exit 0
- [x] V-5.2: 簿记 commit + 记忆 deploy-flow 更新基线 c9309aa
Status: `complete` Last verified: 2026-09-11

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| task-planner-repo-deploy-flow.md | 9 位拓扑清单/收编方向判定范式/rm+cp -rL 重部署 SOP 均按记忆执行 | 符合 |
| v059 同构先例 | 流程同构（审计→收编→selftest→合并→重部署对账）,验证口径对齐 90 用例+verify 25/0 | 符合 |

## 委派统计复验（Rule 25.4）

```bash
# 证据（stats 命令原文输出,2026-09-11）
bash ~/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"main_direct":[{"phase":"5 簿记收尾与交付","executor":"主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Phase 5=白名单②;Phase 4 内 S1=白名单①）
- [x] 委派率 0.800 ≥ 0.7,verdict=ok

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（hook compass 误报指向已交付的 v059 计划,经核实为 legacy 指针残留+hook 会话级扫描行为,非本计划违规,已记 progress Error Log 与 findings;不构成 Q1-Q6 任一类降质行为）
- [x] Evidence 抽查 ≥3 条:①检查点 01/02/03/04 均可 Read 且与 git log/diff 输出交叉一致;②c9309aa 合并 diff 与检查点数字一致（11 文件 +430/-97）;③verify 25/0 主进程独立复跑复现
- [x] 豁免登记:无
- [x] 无未处置违规 → outcome 不降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 收编部署侧 10 文件前向更新回 canonical 并对账 9 位
对照 Verification Contract 逐条复验：
- [x] VC-1: 10 文件 diff=0（检查点 02/04 + 主进程抽验）→ PASS
- [x] VC-2: 联动 3 处最小修订 7419e43 → PASS
- [x] VC-3: selftest 90 用例 fail=0 → PASS
- [x] VC-4: 3 位 diff 全零 + verify 25/0×3 → PASS
- [x] VC-5: companion 6 位+agent 2 位无新差异 → PASS
- [x] VC-6: c9309aa + worktree 清理 + 簿记 → PASS

 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 5（终验完成,簿记收尾） |
| 2 | Where am I going? | 簿记 commit + 记忆更新 + 交付报告 |
| 3 | What's the goal? | 收编 10 文件前向更新回 canonical,9 位对账无回归 |
| 4 | What have I learned? | See findings.md（部署侧哨兵私有化套件+check-dispatch 三级解析曾游离于仓库外） |
| 5 | What have I done? | See progress.md（5 Phase 全 complete） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（本任务收尾后清零） |
