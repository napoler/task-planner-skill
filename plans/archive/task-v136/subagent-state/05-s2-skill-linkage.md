# 05 S2 SKILL.md Rule 54 联动写入 — 检查点（并行组 g-linkage）

状态: in_progress → 完成前更新
wc -l 前基线: SKILL.md = 478 行

## 一、写入前现状锚（行号 + 原文）

| 点 | 位置 | 现状原文（截取） |
|----|------|------------------|
| P1 摘要区末行 | SKILL.md:307 | `- **Rule 53（根源解决与决策管辖 — task-v131）**：…零新 config 键+selftest-root-resolution.sh 守护（53.5）`（其后 :308 空行、:309 `## Completion Gate`） |
| P2 索引行 | SKILL.md:267 | `详见 \`references/critical-rules.md\`（Rules 1-39（含 Rule 40-53 全集））：` |
| P2b References 表行 | SKILL.md:331 | `…/ Rule 52 执行体专业化优先与覆盖矩阵维护 / Rule 53 根源解决与决策管辖） \|` |
| P3 合规清单末行 | SKILL.md:205（C37） | `\| C37 \| 未验证优点宣传核查（Rule 43.5/43.6 + Rule 51.8 + 53.5-Q9）：…（机器面=selftest-reliability-institution R-13..R-16 + selftest-requirement-coverage RC-23 静态断言，测试证据人工核查；mini 档豁免） \| ☐ \|`（:206 空行后为 `### 🔁 原生 Todo 同步`） |

写入前 grep 基线: `Rule 54` =0 / `C38` =0 / `40-54` =0 / `Rules 1-39` 命中 =2（:267/:331）/ `含 Rule 40-53 全集` =1（:267）

## 二、锚级联全扫记录（v118/v131/v132 强制先扫后改）

扫描命令: `grep -rn "Rules 1-\|Rule 40-5\|40-53" <worktree>/skills/task-planner/scripts/`

### 受影响断言锚（必须一行改齐，宽容正则优先）
1. `selftest-reliability-institution.sh:77-79`（R-09）: `grep -c '含 Rule 40-53 全集'` ≥1 → :267 改 40-54 后命中 0 会 bad → 改宽容正则 `grep -cE '含 Rule 40-5[3-9] 全集'`
2. `selftest-self-resolution.sh:71-74`（SR-08）: `grep -c '含 Rule 40-53'` ≥1 → 同上改 `grep -cE '含 Rule 40-5[3-9]'`
3. `selftest-root-resolution.sh:161-168`（RR-16）: idxline `grep -qF 'Rule 40-53'` 主断言 → 改 `grep -qE 'Rule 40-5[3-9]'`（兜底判定 50/53 保留原样）

### 未受影响结论（全部核查，逐一记录）
- `'Rules 1-39'=2 且 '1-40'=0` 主锚断言（selftest-requirement-coverage RC-11 / selftest-tool-selection TS-05 / selftest-self-resolution SR-07 / selftest-lane-advancement LA-12）: 本次 :267/:331 的 "Rules 1-39" 字面与 "1-40" 负断言均不动（40-54 不含 "1-40" 子串）→ 未受影响
- `Rules 1-3[1-9]` / `1-3[5-9]` / `1-3[5-8]` 宽容区间锚（selftest-veto VT-10 / selftest-batch-pilot BP-09 / selftest-conclusion-discipline CD-18/19 / selftest-reflect-verify RV-10 / selftest-error-loop EL-11 / selftest-skill-split）: 仍命中 "Rules 1-39" → 未受影响
- selftest-workflow-orchestration WF-10/WF-11（4 索引文档 1-39+1-45 合计≥6、1-38 残留=0）: 对象是索引文档，SKILL.md 1-39 字面不变 → 未受影响
- `'| C37 |'`=1 断言（selftest-reliability-institution R-16 :113）: C38 新行不含 `| C37 |` → 未受影响
- `'^### 53 '`=1 条款侧锚（RR-17）: 本次不改 critical-rules.md → 未受影响
- `selftest-registry.tsv:40/48/52` 内 "Rule 40-53"/"Rules 1-39" 为登记描述文本非断言锚 → 不修改（登记于此，供后续任务决定是否刷新）
- 行数断言 `≤558`（selftest-knowledge-brief T2b :38 / selftest-skill-collab T10 :82 / selftest-execution-stability T8b :72）: 478 + 净增 2 = 480 ≤ 558 → 不上调
- `selftest-execution-honesty.sh` 当前不存在（ls 确认 No such file）: 54.6/C38 文本按任务指令引用该脚本名（task-v136 同 Phase 交付物），无现存断言冲突（全仓 grep "execution-honesty" 仅命中 critical-rules.md 54.6 原文）

## 三、指令冲突记录
任务 inputs 写「唯一可写: SKILL.md」，但同任务点 4 明令「凡断言锚受影响的脚本一行改齐」——按具体指令优先执行：SKILL.md（主）+ 3 个 selftest 脚本断言行（锚级联，宽容正则，v136 label）。

## 四、写入后验收（grep 原文 + wc -l）

- wc -l: 前 478 → 后 480，净增 +2 ≤10（diff: SKILL.md 4 个 hunk = +2 行净增/1 处行内替换×2 行）
- ① `grep -c "Rule 54"` = **3**（:206 C38 行 / :309 摘要行 / :333 References 行）——满足 ≥3
- ② `grep -c "C38"` = **1**（:206）
- ③ `grep -c "40-54"` = **1**（:268 索引行「含 Rule 40-54 全集」）——满足 ≥1
- ④ wc -l 净增 = +2（478→480）≤10 ✓；≤558 三脚本行数断言未越界，未上调（480 ≤ 558）
- ⑤ 锚级联全扫记录见第二节（受影响 3 处已宽容正则改齐 + RC-15 前移 1 处；未受影响结论逐条在册）
- ⑥ git diff 我方写入 = 5 文件（SKILL.md + 4 脚本）；git status 中 critical-rules.md/companion×2/delivery-summary.md 的 M 为同 Phase S1/S3 并行产出，非 S2 触碰（S2 对 critical-rules.md 只读）

### 追加发现（超出任务点 4 扫描式，按「凡断言锚受影响一行改齐」处置）
- `selftest-requirement-coverage.sh` RC-15 负断言 `grep -c '^54\.'`=0 被同 Phase S1 落地的 54.0-54.6（7 处 `^54.`）破坏 → 防线前移至 `^55.`（=0 PASS），带 v136 label。原 RC-15 设计意图（防 54 号被并行任务误占）因 S1 合法占用 54 而完成使命，按 v125/v131 重锚先例演进。

### 脚本回归（改锚后全量跑，均 Total FAIL=0）
- selftest-reliability-institution: R-09 PASS / Total 16 PASS=16 FAIL=0
- selftest-self-resolution: SR-08 PASS / Total 13 PASS=13 FAIL=0
- selftest-root-resolution: RR-16/17 PASS / Total 17 PASS=17 FAIL=0
- selftest-requirement-coverage: RC-15 PASS / Total 23 PASS=23 FAIL=0
- 零副作用核验: selftest-tool-selection Total 12/12 PASS、selftest-lane-advancement Total 14/14 PASS

### 写入后 grep 原文（关键锚）
- `:268 详见 \`references/critical-rules.md\`（Rules 1-39（含 Rule 40-54 全集））：`
- `:309 - **Rule 54（执行诚实性与即时执行纪律 — task-v136）**：54.0 有依据原则总则 / 54.1 就绪语义+资源状态第一手 / 54.2 阻塞影响矩阵 / 54.3 仪式性进展禁令 / 54.4 推迟举证四要素 / 54.5 决策依据落盘与引用义务 / 54.6 机制=零新 config 键+selftest-execution-honesty.sh 守护（54.6）`
- `:206 | C38 | 执行诚实性与即时执行自查（Rule 54）：对外声称（状态/资源/阻塞/里程碑/完成/统计）已附第一手证据锚（54.0）；…（机器面=selftest-execution-honesty.sh 静态断言，声称可回溯/矩阵/举证人工核查；mini 档豁免） | ☐ |`

### 硬约束自查
- 净增 ≤10 行: ✓（+2）
- 51.8/43.5/43.6/49-53 摘要行既有文本: ✓ 未动（diff 仅 4 hunk：C38 新增 / 268 行内 / 309 新增 / 333 行内追加）
- 案例专属词（EP8/视频/图像/额度数字/cron）: ✓ C38 与摘要行均无（grep 复核：C38 行仅含通用机制词）
- `Rules 1-39`=2 主锚与 `1-40`=0 负断言: ✓ 未动，仍命中

状态: completed

