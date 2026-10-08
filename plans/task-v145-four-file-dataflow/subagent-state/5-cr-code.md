# 5-cr-code — task-v145 .sh 改动代码质量审查（code-quality-review）

- status: done
- 裁决: **APPROVED**（维度覆盖 14/14，P0/P1 = 0；4 条 P2 非阻断）
- 审查对象: wt/task-v145 相对 a7c01a8 的 4 个 .sh
  - check-dispatch.sh +63/-0（scan_contract_narrowing 60.2 lint）
  - check-3file-gate.sh +68/-5（--require-kb 60.5）
  - ledger-append.sh +11/-1（kb_distill 枚举）
  - selftest-four-file-dataflow.sh 新增 113 行（FF-01..18）
- 工作树: /mnt/data/dev/task-planner-skill-worktrees/task-v145（HEAD b65af69）
- files: none（只读审查，未改任何文件）

## 证据（机器可复现）

### 正确性与边界（实跑）
- gate --require-kb 五态：kb_distill 锚点后→exit0；锚点前(2019<2020)→exit1(T9)；kb mtime 晚于锚点→exit0；无 kb 文件→exit1；无 Started 锚点退化 stale→exit1。全符 60.5。
- lint 双条件：neg1(只写检查点+无锚点)→exit1；neg2(主进程回填+你不用写 同行)→exit1；pos(含 `可写=仅追加`)→exit0；bare(主进程回填 无否定)→exit0；跨行 只写检查点→exit1。
- 参数兼容：不传旗标 old vs new 输出逐字节 IDENTICAL；--require-kb 前置/后置位置均生效；多余位置参数与旧行为一致（忽略）。
- pretool 三档：enforce→exit2、warn→exit0+计数文件落盘、off→skip，实测通过。
- 全量 57 selftest：worktree 与 a7c01a8 基线（56 脚本）同为 15 脚本 nonzero；逐脚本输出 diff 仅 selftest-registry(:6 计数)/self-resolution(SR-12 计数) 随 +1 脚本同步，registry 预存在漂移口径不变 → 本改动引入 FAIL=0。

## 非阻断观察（P2，4 条）
1. [P2] selftest-four-file-dataflow.sh:77 FF-08 断言 `kb_distill_activity()`≥2，与头注释 :14「=1」不一致；≥2 由 gate 头注释(:21)+定义(:126)满足，真正调用点 :181（`kb_distill_activity;` 无括号）未计入 → 删调用仍 PASS，未锁「定义调用」集成。progress main:4-R2「定义+调用=2」为误判。建议改无括号计数或锚调用行。
2. [P2] selftest-four-file-dataflow.sh:82 FF-09 `kb_distill`≥2 由 ledger 注释满足（5 处中仅 1 处为 VALID_EVENTS 实改），建议锚 `VALID_EVENTS=.*kb_distill`。
3. [P2] check-dispatch.sh:159-175 lint 漏报边界：A2「主进程回填+否定续文」限同行（跨行不判）；B 锚点全文任一出现即短路放行。均为文件内显式注释的降误报取舍。
4. [P2] selftest cnt()(:65) 对缺失文件返回空串 → `[ "" -eq N ]` 触发 bash 整数错误到 stderr（失败方向正确 fail-closed，仅噪声）。

## 其余维度（通过）
命名/注释(What+Why+日期/任务/原行为, Rule 45)齐备；零新 config 键(properties=42 未变, FF-15 PASS)；scope 8 文件全落 task_plan scope_files；无 TODO/死代码/未释放资源；风格与邻近代码一致。
