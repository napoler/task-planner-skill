# Checkpoint — 04-executor（task-v132 Phase 2 S3: selftest RC-16..20 + registry 行内更新）

写入时间：2026-10-05；状态：本 S-unit 完成，未 commit（任务书要求）。

## 已完成步骤
1. Read 计划三文件材料包 + 03-executor.md 检查点（R-COVERAGE 门实现口径/实测节）+ 主仓 knowledge-brief §1
2. 扩 `skills/task-planner/scripts/selftest-requirement-coverage.sh` RC-15 后追加 RC-16..20（净增 5 用例，15→20），范式对齐既有 RC-xx（What/Why 双层注释+ok/bad 结构+Total 行）
3. registry.tsv requirement-coverage 行第 3 字段尾部追加「+RC-16..20（task-v132 51.7/lint/R-COVERAGE 守护）」——python3 断言式最小替换（以 git HEAD 原行为基准，前后 tab 计数=3 断言，仅第 3 字段变化，判例=v131 registry 事故防手打整行）
4. 验证全 PASS（见下）；未 commit；夹具跑毕即删（mktemp 自建，/tmp 无本任务残留）

## 用例与实测证据
- RC-16：critical-rules.md 三锚各 =1（'51.7 **纠正=回锚重译'/'一个月→72小时两次改写'/'2026-10-05-72h-instruction-mutation.md'，:559/:567 行实测）
- RC-17：check-window-consistency.sh 在位可执行（-f ∧ -x）；正例夹具（mktemp，锚 R 行=「一个月」+subagent-state 载荷「30天」同族异值）exit 0 无 ⚠；负例（载荷「7 天」跨族无豁免）exit 1 有 ⚠
- RC-18：check-complete.sh 含 'R-COVERAGE'=4 ∧ 'rcov-gate'=5（均 ≥1，03-executor 锚字面口径）
- RC-19：mktemp 最小夹具（🎯 区块 R1+R2 行 + VC 表 5 行 + 1 Phase 2 条 V-N 映射 + Decisions 无让步；summary 缺 R2 行）enforce 档 exit=1，stderr 含 `[rcov-gate] ✗ R-COVERAGE FAILED ... 拒 COMPLETE 只可 PARTIAL`
- RC-20 双断：(a) 裸 uncovered 无让步（Decisions 行文案避开 R1 字面+让步关键词）enforce exit=1 拒 COMPLETE；(b) uncovered+Decisions 含「R1 显式让步」行 enforce exit=0 且 stderr 含 `[rcov-gate] PARTIAL 语义提示`（放行语义）
- 证据区口径按 03-executor issues 1：非空 ∧ ∉{无,—,N/A}（RC-19 R1 covered 行证据非空即合规；RC-20 uncovered 行证据=「无」不影响 uncovered 判定）

## 验证结果（原文摘录）
- `bash selftest-requirement-coverage.sh` → `Total: 20 PASS=20 FAIL=0` exit=0
- `bash selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=51, actual selftest=51)` exit=0
- registry 行 NF=4 断言：`awk -F'\t'` 输出 `NF=4`，f3=「Rule 51 六子条 / SKILL.md bullet+C35 / delivery-summary 区块 / config 零新键+RC-16..20（task-v132 51.7/lint/R-COVERAGE 守护）」
- git diff 确认本单元仅 2 文件改动：selftest-requirement-coverage.sh（+286 行净增含注释）+ selftest-registry.tsv（1 行内 3 字段尾部追加）

## 踩坑登记（负结果/坑位报告）
1. **bash 5.2 组语法陷阱**：`{ printf '%s\n' \ 'last' \n} > file`（组闭合 `}` 前一行以续行反斜杠结尾）在 bash 5.2 报 `syntax error: unexpected end of file / done`——反斜杠把 `}` 并入 printf 参数列致组永不闭合。修法=组闭合行前最后一项去掉续行反斜杠（脚本内 10 处全部修正，bash -n 通过）
2. **门控执行序**（探针实测）：VC-GATE 在 R-COVERAGE 门之前且 enforce 档违规即 exit 1——RC-19/20 夹具若 VC 表 <5 行或 Phase V-N <2 条，会在 VC-GATE 处先行 exit 1，rcov-gate 永不到达。故夹具最小化构造含 VC 表 5 行+2 条 V-N 映射（注释已登记）
3. **rcov_concession_registered 判定陷阱**：让步判定在「Decisions Made」区块 grep 同含 R 编号+让步关键词（让步/uncovered/partial）的行——负例 (a) 的 Decisions 行文案若同时出现 R1 字面与关键词即被误判已登记而误放行（首轮 RC-20 负例 exit=0 即此因）。修法=负例行文案刻意全避开两组词，正例 (b) 行保留「R1 显式让步」双命中（注释已登记踩坑注）
4. **window-lint 载荷面**：lint 只扫 task_plan.md + `subagent-state/*.md` 载荷目录，载荷文件放 plan-dir 根目录不计数（首轮 RC-17 负例 exit=0 即此因）。修法=载荷落 `subagent-state/01-executor.md`（注释已登记）

## 交棒 / 遗留
- 未 commit；worktree 内 git status：` M references/critical-rules.md`（Phase 1）、` M scripts/check-complete.sh`（S2）、` M scripts/selftest-registry.tsv`（本单元）、` M scripts/selftest-requirement-coverage.sh`（本单元）、`?? scripts/check-window-consistency.sh`（S1）
- 遗留观察（非本单元范围）：RC-20 PASS 文案含「exit=0=0」双 0 排版小瑕（printf 拼接产物，无语义影响，可下轮顺带修）
- registry 行改动与 task-v131 registry 事故判例同构防护：本行仅第 3 字段尾部纯文本追加，NF=4 断言通过
