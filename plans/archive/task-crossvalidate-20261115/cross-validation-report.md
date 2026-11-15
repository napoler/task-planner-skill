# 交叉验证实弹报告（Rule 108 dogfood — task-crossvalidate-20261115）

> 本报告即新条款 108.1-108.5 的首个实弹应用：对 Phase 2 落地产出（worktree fix commit 2abe3ec 后终态）执行双视角交叉验证。机械面与语义面独立执行、禁串阅。

## 验证对象

Rule 108 交叉验证纪律落地产出（5 文件+守护脚本+registry，worktree commit 8097063→2abe3ec 终态）

## 交叉验证记录

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定 |
|----------|------------------------|--------------------------|------|
| Rule 108 五子条款（规则文 108 块） | 主进程独立重跑：`grep -cE '^108\.[1-5]'`→5；`grep -q fabricated-output`→PASS（VC-1 判据，2026-11-15 本报告撰写时实跑） | critic 轮1 R1 维度A：五子条承载 R1/R3/R4/R5（R2 零载体 MINOR 已修）；轮2 M1/m2 核验 PASS | 一致 PASS |
| 双 SKILL 级联+路由（84,108/1-108/91 条） | 主进程独立重跑：`grep -c 'Rule 84,108'`→1、`1-108`→3、`1-107`→0；`其余 91 条`→2、94 残留→0（VC-2 判据实跑） | critic 轮1 维度C 指出 M1 计数错误（94→应为 91）；轮2 复核算式 108−3 预留−14 核心=91 与先例锁步 | 一致 PASS（经 108.4 分歧处置后） |
| 模板 CV 区块（验证步骤承载） | 主进程独立重跑：`grep -q '交叉验证记录'`→PASS（VC-2 判据实跑） | critic 轮1 维度B m1（步骤承载段 MINOR，登记遗留）；轮2 无升级 | 一致 PASS |
| 守护脚本 CV-01..06 | 主进程独立重跑：`bash selftest-cross-validation.sh`→`Total: 6 PASS=6 FAIL=0` EXIT=0；registry 行在位（VC-3 判据实跑） | critic 轮2 负向实测：删 `### 108 ` 标题→CV-01/02 FAIL rc=1；删调用时机 Rule 108 行→CV-03 FAIL——断言非真空；轮1 M2（块锚+局部化）已修 | 一致 PASS |
| 全量回归 | code-runner-agent 双跑：主仓基线 FAIL=3 vs worktree FAIL=2（2≤3 零新增；两失败脚本双跑同在=预存） | critic 轮1/轮2 五脚本复跑 rc 全 0；registry 5/5 rows=98/actual=98 | 一致 PASS |

## 交叉验证判定

**一致 PASS**（双路径终态结论一致；分歧已按 108.4 协议处置闭环）

## 分歧与处置记录（108.4 协议实弹）

- **分歧 D1（计数口径）**：主进程级联A 派发稿写「其余 94 条」（108−14 的错误算式）vs critic 轮1 依草案+预留注释判 91。处置=禁合并平均→主进程第一手重推导（critical-rules.md:141 预留注释+archive task-serial-sync 1-107→90 先例+clause-drafts §3 原文 91）→**证实 critic 正确、主进程误判**→fix commit 2abe3ec 修回 91 条×2→critic 轮2 复核锁步。留痕：findings F7 勘误行+Technical Decisions+checkpoint 6/8。
- **方法论印证**：该分歧正是 R4 反虚构机制的首个实弹捕获——主进程转译稿错误未流入交付物，被「独立复检+盘上重推导」双路径拦下；108.2（声称只作索引）与 108.5（盘上不符即复核）在本次应用中直接生效。

## 双路径证据锚

- 机械面：本报告撰写时的实跑输出（VC-1/2/3 判据+fix 项 grep，全部 2026-11-15 当日重跑非转引）
- 语义面：subagent-state/6-critic-recheck.md（轮1 CHANGES_REQUESTED 五维全列）→ subagent-state/7-fix-cr.md（修复回执 4/4+五脚本绿）→ subagent-state/8-critic-r2.md（轮2 APPROVED 4/4+负向实测）
- 判例锚：subagent-verifier-fabricated-output-20261103（108.2 条款判例）；本次 D1 分歧为其正面印证（复核者不可信任何一方声称，含主进程自己）
