# 部署位一致性 diff 抽样 + selftest 真实基线

- 任务：`task-project-audit-20261123`
- 检查时间（UTC）：2026-11-22T16:05:52Z（selftest 启动时间戳）
- 检查者：子代理（只读诊断；selftest 实跑；仅写本检查点）
- 仓库：`/mnt/data/dev/task-planner-skill`
- 约束遵守：未修改技能/配置/计划文件；仅运行只读 diff/find/ls/wc/python3 与指定 selftest；本文件为唯一主动写入产物。

## 1. 部署一致性抽样（21 技能 × 2 部署位）

比对范围：仓库 `skills/<name>/` vs `/home/terry/.zcode/skills/<name>/` 与 `/home/terry/.agents/skills/<name>/`。
方法：对每个同名技能目录执行 `diff -rq`，范围限定为 `SKILL.md` 与 `scripts/`（存在则比对）；三态 `IDENTICAL / DRIFTED / MISSING`。
证据命令：Python3 脚本遍历 `skills/` 21 个目录，分别对两个部署位运行 `diff -rq`（见本次会话执行记录）。

### 1.1 21 行矩阵

| # | skill | zcode位 (`~/.zcode/skills`) | agents位 (`~/.agents/skills`) |
|---|---|---:|---:|
| 1 | context-corrector | IDENTICAL | IDENTICAL |
| 2 | error-fix-prompt-forge | IDENTICAL | IDENTICAL |
| 3 | iterative-optimizer | IDENTICAL | IDENTICAL |
| 4 | longform-continuity | IDENTICAL | IDENTICAL |
| 5 | md-edit-ops | IDENTICAL | IDENTICAL |
| 6 | media-planner | IDENTICAL | IDENTICAL |
| 7 | plan-collab-router | IDENTICAL | IDENTICAL |
| 8 | plan-cost-guard | IDENTICAL | IDENTICAL |
| 9 | plan-history-recall | IDENTICAL | IDENTICAL |
| 10 | plan-research-router | IDENTICAL | IDENTICAL |
| 11 | plan-resume | IDENTICAL | IDENTICAL |
| 12 | plan-template-advisor | IDENTICAL | IDENTICAL |
| 13 | plan-template-kit | IDENTICAL | IDENTICAL |
| 14 | progress-tracker | **DRIFTED** | IDENTICAL |
| 15 | task-discipline | IDENTICAL | IDENTICAL |
| 16 | task-dispatch | IDENTICAL | IDENTICAL |
| 17 | task-drift-guard | IDENTICAL | IDENTICAL |
| 18 | task-planner | IDENTICAL | **DRIFTED** |
| 19 | todo-skill | IDENTICAL | IDENTICAL |
| 20 | verification-gate | IDENTICAL | IDENTICAL |
| 21 | workflow-model-tiers | IDENTICAL | IDENTICAL |

### 1.2 漂移统计

- 总技能数：21
- `zcode` 位：IDENTICAL 20 / DRIFTED 1 / MISSING 0
- `agents` 位：IDENTICAL 20 / DRIFTED 1 / MISSING 0
- 漂移技能数（任一部署位漂移）：**2**（`progress-tracker`@zcode, `task-planner`@agents）

### 1.3 漂移细节（证据）

#### D1. `progress-tracker` — zcode 位 DRIFTED

- 现象：`diff -rq` 报告 `Only in /home/terry/.zcode/skills/progress-tracker: scripts`。
- 证据：
  - 仓库 `skills/progress-tracker/` 内容：`references/`, `SKILL.md`（无 `scripts/`）。
  - `/home/terry/.zcode/skills/progress-tracker/scripts/` 存在 `ledger-append.sh`（70 行，头部注释含 `[2026-11-06 fix(skillfix-b0)/P0-04] 新增; Why: progress-tracker SKILL.md 原用裸 >> "$LEDGER_FILE"`）。
  - `/home/terry/.agents/skills/progress-tracker/scripts/` 不存在（与仓库一致）。
- 根因（证据支持的推断）：zcode 部署位包含仓库未收录的 `scripts/ledger-append.sh`（部署位比仓库多文件）；agents 位与仓库一致。可能是修复已部署到 zcode 但未同步回仓库/未同步到 agents。
- 严重度：**P1**（部署一致性缺口；仓库与运行部署不一致，存在“修复在部署位丢失/分叉”风险）。
- 建议（仅文字）：核对 `ledger-append.sh` 是否应纳入仓库 `progress-tracker/scripts/`；若应纳入，同步三处（repo/zcode/agents）并补 selftest/说明；若为过时残留，按授权清理部署位。保护区，未改。

#### D2. `task-planner` — agents 位 DRIFTED

- 现象：`diff -rq` 报告 `Files .../skills/task-planner/SKILL.md and /home/terry/.agents/skills/task-planner/SKILL.md differ`；`scripts/` 无差异。
- 证据：`diff -u` 共 11 行差异，仅 1 处内容差异（Step 4.5 段落）：
  - 仓库/zcode 版本包含：`细则→references/worktree-isolation.md §4.5+§4.6；**方向根本错误且阈值命中（96.7/103.8b）→走 §4.6 弃旧开新**：评估归因+用户确认→提取有效数据(salvage-manifest)→从基线牵新 wt/<task-id>-rN→新计划 restarted_from 登记，旧计划 outcome=RESTARTED(非 CANCELLED)（细则→§4.6）`
  - agents 部署位缺少上述 §4.6 弃旧开新/RESTARTED 语义，止于 `细则→references/worktree-isolation.md §4.5`。
- 根因（证据支持的推断）：agents 部署位 `task-planner/SKILL.md` 落后于仓库当前版本，缺少 Rule 96.7/103.8b 方向根本错误“弃旧开新”分支说明。
- 严重度：**P1**（保护区部署漂移；agents 位行为指令弱于仓库，可能导致执行策略不一致）。
- 建议（仅文字）：在获得授权后，将仓库 `task-planner/SKILL.md` 同步到 agents 部署位；同步前 Read+diff+确认。保护区，未改。

## 2. selftest 真实基线（实跑）

### 2.1 执行信息

- 命令：`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh`
- 工作目录：`/mnt/data/dev/task-planner-skill`
- 启动时间（UTC）：`2026-11-22T16:05:52Z`
- 运行方式：后台执行 + 日志轮询（因全量耗时较长）
- 完成观测：日志出现最终 `Total:` 行；后台任务退出码 1（与 FAIL>0 一致）
- 用法确认：已读取 `run-selftests.sh` 头部，支持 `--fresh`（忽略缓存全量重跑）。

### 2.2 真实结果

- 总脚本数：**104**
- PASS（脚本级）：**96**
- FAIL（脚本级）：**8**
- run=104 reused=0
- 汇总行（原文）：`Total: 104 PASS=96 FAIL=8 (run=104 reused=0)`
- FAIL 清单（原文）：`Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-rule-reserve-pairing selftest-self-resolution selftest-summary-readability`

> 说明：不采信计划文本中的历史口径；以上为本次 `--fresh` 实跑输出。

### 2.3 FAIL 样本复跑（区分真实问题 vs 环境/依赖）

对 8 个 FAIL 脚本逐个单独复跑并截取尾部。结果均为脚本内断言 FAIL，未见命令不存在/权限拒绝/网络依赖等典型环境错误。

| FAIL 脚本 | 单跑结果 | 失败点（证据摘要） | 初判 |
|---|---:|---|---|
| selftest-active-plan | 29 PASS=28 FAIL=1 | `T13 PASS 13` 后 `T14 PASS 14`，汇总显示 1 FAIL（需进一步定位具体断言行） | 真实脚本失败（待定位） |
| selftest-batch-pilot | 10 PASS=9 FAIL=1 | `BP-08 FAIL SKILL.md 行数 440 超 311` | 真实断言失败（文档行数门槛/基线漂移） |
| selftest-enumerate-first | 7 PASS=6 FAIL=1 | `EN-06 ... SKILL.md 含 '1-108' >=3 处(0) 且含 ',107' 路由` | 真实断言失败（规则编号/路由文本不匹配） |
| selftest-execution-stability | 19 PASS=18 FAIL=1 | `T11b FAIL ... 改内容后 owner=othersid999 -> 重锁不命中...` | 真实断言失败（hook 自愈/重锁行为不符预期） |
| selftest-registry | 5 PASS=4 FAIL=1 | `T03 FAIL 孤儿行: selftest-md-edit-ops.sh`；`registry rows=105, actual selftest=104` | 真实断言失败（registry 与实际 selftest 文件不一致） |
| selftest-rule-reserve-pairing | 3 PASS=2 FAIL=1 | `PR-02 FAIL reserved 无对应 landed（非豁免悬空编号:110...）` | 真实断言失败（规则编号配对/悬空编号） |
| selftest-self-resolution | 13 PASS=12 FAIL=1 | `SR-12 FAIL registry 漂移（selftest-self-resolution 命中 2 应 >=1 / 总行数 106 应 105=脚本数+表头）` | 真实断言失败（registry 漂移） |
| selftest-summary-readability | PASS=11 FAIL=2 WARN=0 | `SRV-11 FAIL: registry 登记...`；`SRV-12 FAIL: 9 级联脚本(pass=8 fail=1 expect 9/9)` | 真实断言失败（registry 登记+级联脚本失败传播） |

## 3. 判定汇总

| 项 | 现象 | 证据 | 根因（证据边界内） | 严重度 | 建议（仅文字） |
|---|---|---|---|---:|---|
| 部署位一致性 | 21 技能中 2 个漂移 | `diff -rq` 矩阵；D1 显示 zcode 多 `progress-tracker/scripts/ledger-append.sh`；D2 显示 agents `task-planner/SKILL.md` 缺 §4.6 弃旧开新语义（11行diff） | repo 与 zcode/agents 部署位存在未同步变更；方向分叉（zcode 多文件、agents 落后） | P1 | 授权后做三处一致性同步：确认 ledger-append.sh 归属，补齐/回收；同步 task-planner SKILL.md 到 agents；同步后复跑部署 diff + 相关 selftest |
| selftest 基线 | 104 脚本，96 PASS / 8 FAIL | `run-selftests.sh --fresh` 实跑汇总行；8 FAIL 单跑尾部输出 | 多为仓库当前状态与 selftest 期望不一致（registry 漂移/规则编号与文案门槛/SKILL 行数/行为断言）；未见环境依赖失败证据 | P1 | 按 FAIL 分类修复：先清 registry 漂移（registry/self-resolution/summary-readability 关联），再核 rule 编号与 SKILL 文案/行数门槛，最后单独定位 active-plan 与 execution-stability 行为断言；修复后 `--fresh` 全量复跑 |

## 4. 证据与边界说明

- 本报告只覆盖“部署位一致性抽样（SKILL.md+scripts）+ selftest 实跑基线”，不代表仓库全部质量结论。
- selftest 单跑在已执行过 `--fresh` 后进行，个别脚本可能受缓存/状态影响；但失败模式与全量 FAIL 清单一致，且错误为断言/内容不匹配，未见环境缺依赖特征。
- 保护区文件未修改；未执行任何写入修复动作。
