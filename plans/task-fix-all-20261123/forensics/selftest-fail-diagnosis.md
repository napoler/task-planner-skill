# selftest-fail-diagnosis

## 范围与基线
- worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-fix-all-20261123`
- 基线（用户给定，--fresh）：Total 104 PASS=96 FAIL=8
- 本次复核：在 worktree 单跑 8 个 FAIL 脚本 + 定向复现，证据见下。
- 约束：只读诊断；未修改 worktree 文件；报告写入主仓 `plans/task-fix-all-20261123/forensics/`。

## 失败总览

| 脚本 | FAIL | 类别 | 一句话修法 | 依赖 |
|---|---|---|---|---|
| selftest-active-plan.sh | T11 (29/28/1) | C | 测试 env 泄漏：T11 attest 调用未 `-u ZCODE_SESSION_ID -u CLAUDE_SESSION_ID`，导致 resolve/attest 绑定真实会话 sid；按 T11a/T11b 同构 scrub | 独立 |
| selftest-batch-pilot.sh | BP-08 (10/9/1) | A | SKILL.md 实值 440 行，门槛 311 过时；按既有“实值+边距”口径更新上限与注释，说明 440 为当前真实瘦身后基线 | 独立 |
| selftest-enumerate-first.sh | EN-06 (7/6/1) | A | SKILL.md 已升至 `1-110`（3处），测试仍断言 `1-108>=3`；更新 EN-06 为 `1-110>=3` 且保留 `,107` 路由检查（discipline 路由仍止于107） | 与 PR-02/文档纪元相关但可独立修 |
| selftest-execution-stability.sh | T11b (19/18/1) | C | 同 env 泄漏：baseline attest 在有真实 ZCODE/CLAUDE_SESSION_ID 时写入真实 sid，导致“owner=othersid999 后重锁不命中”断言看到旧 sid 未清空；测试应 scrub env 或显式设置 ZCODE_SESSION_ID=sessabc123 | 独立；与 active-plan T11 同根因模式 |
| selftest-registry.sh | T03 (5/4/1) | A/D混合（登记漂移） | registry 有孤儿行 `selftest-md-edit-ops.sh`（registry.tsv:100），实际脚本不存在；核实是否应恢复脚本或删除孤儿登记。当前证据倾向 A：登记与文件不同步 | **根因源**：连带 SRV-11/SRV-12/SR-12 |
| selftest-rule-reserve-pairing.sh | PR-02 (3/2/1) | D | `plans/.rule-reservations.jsonl` 仅有 `110 reserved` 无 `110 landed`，而 SKILL/dispatch 已文档化 Rule 110；需补 landed 配对行（合法 land）或经仲裁作废——不得扩豁免表掩盖 | 独立 |
| selftest-self-resolution.sh | SR-12 (13/12/1) | A（连带） | SR-12 动态比对 `registry行数==selftest脚本数+1`；实际 106!=105，因 registry 含孤儿 `selftest-md-edit-ops.sh`。修 registry 孤儿后应自动通过 | 依赖 registry T03 |
| selftest-summary-readability.sh | SRV-11,SRV-12 (13/11/2) | A（连带） | SRV-11 调 `selftest-registry.sh` 失败（T03孤儿）；SRV-12 9级联中 `selftest-self-resolution.sh` FAIL=1，其余8 PASS。根因同 registry 漂移 | 依赖 registry T03/SR-12 |

## 逐项证据

### 1) selftest-active-plan.sh — T11 FAIL（C 测试环境泄漏）

- 命令：`bash skills/task-planner/scripts/selftest-active-plan.sh` → `Total: 29 PASS=28 FAIL=1`，FAIL=`T11 FAIL rc=1 att_bb=no att_aa=`。
- 断言位置：`skills/task-planner/scripts/selftest-active-plan.sh:150-220`，T11 构造 bb 计划（含 Rule 51.1 四锚），设置 side 指针 `--sid s11`，touch aa 使 mtime 新，再 `(cd $R11 && env CLAUDE_CODE_SESSION_ID=s11 bash $ATTEST --skip-dispatch-check --skip-vc-check ...)`，期望锁 bb。
- 复现（原样，带真实会话 env）：rc=1，stderr 显示 `[attest] ✗ 缺 Rule 51.1 ...` + `缺失锚: ... R 需求行 ... R→VC 映射 ...`，`bb=no aa=no`。说明 attest 未解析到 bb（bb 有四锚），而是解析到了 aa（aa 是裸 `# plan aa`）。
- 根因：`attest-plan.sh:58-60` 用 `up_sid="${ZCODE_SESSION_ID:-${CLAUDE_SESSION_ID:-}}"` 调用 `resolve-plan-dir.sh "$(pwd)" "${up_sid}"`；当前 agent 环境有 `ZCODE_SESSION_ID`/`CLAUDE_SESSION_ID`（已验证 `env | grep ZCODE_SESSION_ID` 存在）。T11 只设 `CLAUDE_CODE_SESSION_ID=s11`，未 scrub ZCODE/CLAUDE_SESSION_ID，因此 resolver 按真实 sid 查找 side 指针，找不到 s11 的 bb，回落 legacy/mtime 选中 aa；aa 缺四锚导致 attest fail-closed。
- 对照：同 fixture 仅增加 `env -u ZCODE_SESSION_ID -u CLAUDE_SESSION_ID CLAUDE_CODE_SESSION_ID=s11 ...` 后 rc=0，`bb=yes aa=no`。
- 判定：**C 测试自身 bug（环境非 hermetic）**。不是功能回归——attest/resolve 行为符合设计。
- 修法：在 T11 的 attest 调用前 scrub `ZCODE_SESSION_ID`/`CLAUDE_SESSION_ID`（与 execution-stability T11a/T11b 使用 `env -u ZCODE_SESSION_ID ...`、active-plan 其他 `call()` 用 `env -u CLAUDE_CODE_SESSION_ID` 的 hermetic 风格对齐；这里需同时 -u ZCODE_SESSION_ID/CLAUDE_SESSION_ID）。不改产品代码。

### 2) selftest-batch-pilot.sh — BP-08 FAIL（A 基线漂移）

- 命令：`bash skills/task-planner/scripts/selftest-batch-pilot.sh` → `Total: 10 PASS=9 FAIL=1`，`BP-08 FAIL SKILL.md 行数 440 超 311`。
- 断言：`skills/task-planner/scripts/selftest-batch-pilot.sh:75-80`，`[ "$lines" -le 311 ]`；注释记录阈值演进 558→275→285→292→306→311，口径“实值+5边距”。
- 实值：`wc -l skills/task-planner/SKILL.md` = 440。
- 判定：**A 基线漂移**。SKILL.md 真实内容已增长到 440（包含 Rule 108/109/110 纪元、审计门等合法演进），不是功能损坏；门槛 311 失去回归意义。
- 修法：将 BP-08 上限按既有口径更新为 `440+边距`（建议 445 或 450，需在注释中写明实值 440 与增长原因：Rule 108-110/审计门等结构性增量），同步更新断言消息与注释链。**不能**无说明地随意放大；也不能改 SKILL 逻辑来迎合旧门槛。

### 3) selftest-enumerate-first.sh — EN-06 FAIL（A 基线漂移）

- 命令：`bash skills/task-planner/scripts/selftest-enumerate-first.sh` → `Total: 7 PASS=6 FAIL=1`。
- FAIL：`EN-06 SKILL.md 含 '1-108' >=3 处(0) 且含 ',107' 路由`。
- 断言：`skills/task-planner/scripts/selftest-enumerate-first.sh:95-104`，要求 `grep -c '1-108' >=3` 且 `grep -q ',107'`。
- 实值：`SKILL.md` 中 `1-108` 字面出现 0 次；`1-110` 出现 3 次（L9,L312,L424）；discipline 路由行 L298 仍含 `,107` 末尾；L308 含 `84,108`。
- 判定：**A 基线漂移**。Rule 110 已在 SKILL 文档化（`1-110 全集索引`），纪元从 1-108 推进到 1-110；测试锚点未随纪元更新。功能/规则文本无缺失证据。
- 修法：更新 EN-06 期望为 `1-110 >=3`；保留 `,107` 路由存在检查（discipline 路由当前仍止于 107，证据 L298）。同步更新头注释/诊断文案中的 1-108 字面。**不要**为了通过而删除检查或把阈值降为 >=0。

### 4) selftest-execution-stability.sh — T11b FAIL（C 测试环境泄漏）

- 命令：`bash skills/task-planner/scripts/selftest-execution-stability.sh` → `Total: 19 PASS=18 FAIL=1`，`T11b B1 负例 ... FAIL`。
- 断言：`skills/task-planner/scripts/selftest-execution-stability.sh:140-180`。T11b 建立 baseline attest（owner=sessabc123），改 plan 内容，改 owner=othersid999，再以 `session_id=sess-abc123` 跑 posttooluse hook，期望 `plan_sha256` 仍为旧值且 `attested_by_sid` 重置为空串（防洗白）。
- 复现（按脚本逻辑，环境含真实 ZCODE_SESSION_ID/CLAUDE_SESSION_ID）：baseline attest 后 `attested_by_sid=sess_subagent_agent_c7e5ce37-...`（真实会话），hook 运行后 attestation 未变（hash 旧、sid 仍真实 sid）。脚本用 `env -u ZCODE_SESSION_ID bash "$ATTEST"...` 建 baseline，但未 `-u CLAUDE_SESSION_ID`；`attest-plan.sh:656` 取 `attest_sid="${ZCODE_SESSION_ID:-${CLAUDE_SESSION_ID:-}}"`，因此 CLAUDE_SESSION_ID 泄漏进 baseline。
- 对照：scrub `ZCODE_SESSION_ID` 和 `CLAUDE_SESSION_ID` 后 baseline `attested_by_sid=""`，T11b 逻辑通过（`stored==h1? yes bysid_empty? yes`）。
- 判定：**C 测试自身 bug（环境泄漏）**。hook 的“owner!=SID 不重锁”行为是正确的；T11b 期望“bysid 重置为空”是基于 baseline 由空 sid 建立的前提，该前提在当前环境不成立。
- 修法：T11b（及 T11a baseline，如需要一致性）attest 调用改为 `env -u ZCODE_SESSION_ID -u CLAUDE_SESSION_ID bash "$ATTEST" ...`。不改 hook 产品逻辑。

### 5) selftest-registry.sh — T03 FAIL（A 登记漂移 / D 清理项）

- 命令：`bash skills/task-planner/scripts/selftest-registry.sh` → `Total: 5 PASS=4 FAIL=1 (registry rows=105, actual selftest=104)`，`T03 FAIL 孤儿行: selftest-md-edit-ops.sh`。
- 断言：`skills/task-planner/scripts/selftest-registry.sh:37-40`，T03 检查 registry 行指向的脚本实际存在。
- 证据：`skills/task-planner/scripts/selftest-registry.tsv:100` 有 `selftest-md-edit-ops.sh` 行；`ls skills/task-planner/scripts/selftest-md-edit-ops.sh` = MISSING；`git log --all -- <path>` 无记录，`git status --short` 无。实际 selftest 文件 104 个，registry 数据行 105 个。
- 判定：**A 基线漂移（登记与实际不同步）**。若该测试本应存在则为 D（待补文件）；但当前 worktree 无该文件且无历史痕迹，优先按登记漂移处理。不可简单删断言。
- 修法：核实 `selftest-md-edit-ops.sh` 是否应在本 worktree 存在（检查主仓/上游分支）。若应存在则恢复文件并保持 registry；若已废弃则从 `selftest-registry.tsv` 删除孤儿行，并在提交说明中记录原因。修复后需重跑 registry/self-resolution/summary-readability 级联。

### 6) selftest-rule-reserve-pairing.sh — PR-02 FAIL（D 真实待补 landed 配对）

- 命令：`bash skills/task-planner/scripts/selftest-rule-reserve-pairing.sh` → `Total: 3 PASS=2 FAIL=1`，`PR-02 FAIL reserved 无对应 landed（非豁免悬空编号:110；豁免表=57 60 80 82...）`。
- 断言：`skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:79-97`，reserved 必须有 landed 配对，非豁免悬空即 FAIL。
- 证据：`plans/.rule-reservations.jsonl` 尾部：109 reserved+landed 成对，110 仅 `{"rule":110,"status":"reserved","task_id":"task-model-tier-dispatch-20261119","ts":"2026-11-19","note":""}` 无 landed。SKILL.md L312/L9/L424 已写 `Rules 1-110... Rule 110 任务分级×模型档位强制匹配域（dispatch 卫星）`，dispatch critical-rules 有 `### 110`。
- 判定：**D 真实待补**。文档/规则已落地但编号账本未配对 landed，不是测试误报。扩豁免表会掩盖真实不变量。
- 修法：为 rule 110 追加合法 landed 行到 `plans/.rule-reservations.jsonl`（保持 JSONL 格式、task_id/ts/note 与实际落地一致），使 reserve↔land 成对。前提是确认 Rule 110 已真实落地（当前证据支持）。

### 7) selftest-self-resolution.sh — SR-12 FAIL（A 连带 registry 漂移）

- 命令：`bash skills/task-planner/scripts/selftest-self-resolution.sh` → `Total: 13 PASS=12 FAIL=1`，`SR-12 FAIL registry 漂移（selftest-self-resolution 命中 2 应 ≥1 / 总行数 106 应 105=脚本数+表头）`。
- 断言：`skills/task-planner/scripts/selftest-self-resolution.sh:144-149`，`n>=1` 且 `lines==expected`，`expected=$(ls selftest-*.sh|wc -l)+1`。
- 证据：registry 命中 `selftest-self-resolution` 2 次（L38,L76，两行都存在）；`lines=106`，实际 selftest 104 个，expected=105。多出的 1 行是孤儿 `selftest-md-edit-ops.sh`。
- 判定：**A 连带漂移**，根因与 registry T03 相同。SR-12 自身逻辑合理。
- 修法：修复 registry 孤儿（见第5项）后复跑应转绿；不应改 SR-12 期望计算。

### 8) selftest-summary-readability.sh — SRV-11, SRV-12 FAIL（A 连带）

- 命令：`bash skills/task-planner/scripts/selftest-summary-readability.sh` → `Total: PASS=11 FAIL=2 WARN=0`。
- SRV-11：`registry 登记(got 1 expect>=1)+registry.sh PASS` FAIL。断言 `skills/task-planner/scripts/selftest-summary-readability.sh:169-176` 要求 registry 有 `selftest-summary-readability.sh` 行且 `bash $REGSH` PASS。实测登记=1，但 `selftest-registry.sh` 因 T03 孤儿 FAIL。
- SRV-12：`9 级联脚本(pass=8 fail=1 expect 9/9)`。断言 `:179-200` 跑 9 个级联脚本。实测：absorption/context-pressure/lane-advancement/tool-selection/requirement-coverage/research-first/source-anchor-discipline/root-resolution 8 个 PASS；**selftest-self-resolution.sh FAIL**（13/12/1，SR-12 registry 漂移）。
- 判定：**A 连带**。SRV-11/SRV-12 不是自身逻辑错误；它们正确暴露了上游 registry 漂移。
- 修法：先修 registry T03 孤儿行（第5项），连带修复 SR-12/self-resolution 和 SRV-11/SRV-12。无需改 summary-readability 断言。

## 依赖关系

- **registry T03（孤儿 selftest-md-edit-ops.sh）是主根因** → 修一处可连带转绿：`selftest-registry.sh` T03、`selftest-self-resolution.sh` SR-12、`selftest-summary-readability.sh` SRV-11+SRV-12（共 4 个脚本、5 个 FAIL 点）。
- **env 泄漏同模式**：`selftest-active-plan.sh` T11 与 `selftest-execution-stability.sh` T11b 同为测试未 scrub `ZCODE_SESSION_ID/CLAUDE_SESSION_ID`/`CLAUDE_SESSION_ID`。修法相似但位置不同，各自独立。
- **独立基线漂移**：BP-08（SKILL 行数门槛）、EN-06（1-108→1-110 纪元）。
- **真实待补**：PR-02 rule 110 reserved 无 landed（需补账本 landed 行）。

## 建议修复顺序（低风险优先）

1. Registry 孤儿清理/恢复决策（解 4 脚本连带）。
2. active-plan T11 + execution-stability T11b env scrub（纯测试 hermetic 修复）。
3. EN-06 纪元更新（1-108→1-110，保留 ,107）。
4. PR-02 为 rule 110 补 landed 账本行（需确认落地事实）。
5. BP-08 SKILL 行数门槛按“实值+边距”更新并写明理由。

## 非目标 / 禁止

- 不删除断言、不把 FAIL 改 SKIP、不扩豁免表掩盖 rule 110。
- 不改产品 hook/attest 语义来迎合测试环境泄漏；应修测试 hermetic。
- 不在无证据情况下恢复/删除 `selftest-md-edit-ops.sh`；先确认来源。
