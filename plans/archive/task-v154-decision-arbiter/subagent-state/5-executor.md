# 检查点 — S5 executor（SKILL.md 接线 + 触发点标记，task-v154）[parallel-group:p2-wiring]

- 时间: 2026-10-10
- 唯一写入目标: /mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter/skills/task-planner/SKILL.md
- 唯一元写入: /mnt/data/dev/task-planner-skill/plans/task-v154-decision-arbiter/subagent-state/5-executor.md
- 写入性质: 10 处纯插入（新行）+ 1 处事实性欠账修正（③，1 行改行）＝ 11 处增量
- 编辑纪律: 全部以内容锚唯一命中后再 Edit（每处 Edit 前先 Grep 原文样例确认唯一）

## 11 处写入逐项锚（插入后行号，worktree SKILL.md 当前态）
| 序 | 项 | 插入后行号 | 锚（原始行号→内容样例） | 性质 |
|----|----|-----------|------------------------|------|
| ① | 路由表新行 | 417 | 原 409 `\| **漂移检测（高频）** \|` 之后 | 纯插入 +1 |
| ② | Critical Rules 清单 Rule 69 行 | 344 | 原 338 `- **Rule 66（goal 单元固化` 之后 | 纯插入 +1 |
| ③ | 描述欠账修正 | 286 | 原 281 `详见 \`references/critical-rules.md\`（Critical Rules 1-66（含 Rule 40-65 全集…` | 改行 +1/-1 |
| ④ | T1 标记 | 80 | 原 79 `- [ ] **思维方法论问题解构…并附 T4 推导链…` 之后（同级缩进=0） | 纯插入 +1 |
| ⑤ | T2 标记 | 470 | 原 461 `> 「prompt 过大…」…` 之后、原 463 `**触发条件**(任一):` 之前 | 纯插入 +1 |
| ⑥ | T3 标记 | 477 | 原 467 `- 同一子任务**连续失败 ≥2 次**…` 之后、原 469 `**登记**(Rule 22.5):` 之前 | 纯插入 +1 |
| ⑦ | T4 标记 | 92 | 原 90 `     - **3a. 子代理产出回填（19.1）**…` 之后（同级缩进=5） | 纯插入 +1 |
| ⑧ | T5 标记 | 104 | 原 101 `    - ⚠️ DRIFT → 记录 progress.md，警觉继续` 之后（同级缩进=4） | 纯插入 +1 |
| ⑨ | T6 标记 | 153 | 原 149 `  - **门控**：\`code-review\` 输出 \`APPROVED\`…` 之后（同级缩进=2） | 纯插入 +1 |
| ⑩ | 合规清单 C46 行 | 223 | 原 218 `\| C45 \| goal 单元自查（Rule 66）…` 之后 | 纯插入 +1 |
| ⑪ | 外部 skill 引用行 | 383 | 原 376 `\| 外部 skill \| \`drift-checker\` agent 偏移检查执行载体…` 之后 | 纯插入 +1 |

- 插入后行号映射（git diff -U0 hunk 头）: `@@ -79,0 +80 @@`（T1）/`@@ -90,0 +92 @@`（T4）/`@@ -101,0 +104 @@`（T5）/`@@ -149,0 +153 @@`（T6）/`@@ -218,0 +223 @@`（C46）/`@@ -281 +286 @@`（③ 改行）/`@@ -338,0 +344 @@`（Rule 69 行）/`@@ -376,0 +383 @@`（外部 skill）/`@@ -409,0 +417 @@`（路由行）/`@@ -461,0 +470 @@`（T2）/`@@ -467,0 +477 @@`（T3）＝ 11 hunk

## diff --stat / numstat（纯新增证据）
```
 skills/task-planner/SKILL.md | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)
11	1	skills/task-planner/SKILL.md
```
- 唯一 deletion = ③ 欠账修正行（原 281→现 286），其余 10 处 0 删除（既有行零改动）
- 追加前 wc -l = 511；追加后 wc -l = 521（+10 净行 = 10 插入；③ 改行净 0）

## ③ 项完整 diff（事实性欠账修正行，deletions=1 / insertions=1）
```diff
-详见 `references/critical-rules.md`（Critical Rules 1-66（含 Rule 40-65 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化 / Rule 63 检索优先与反推诿纪律 / Rule 64 偏移检查留痕强制与节奏化触发纪律 / Rule 65 周期性回顾与前后对照））：
+详见 `references/critical-rules.md`（Critical Rules 1-69（含 Rule 40-69 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化 / Rule 63 检索优先与反推诿纪律 / Rule 64 偏移检查留痕强制与节奏化触发纪律 / Rule 65 周期性回顾与前后对照 / Rule 66 goal 单元固化与 /goal 驱动推进 / Rule 69 判断裁决子代理化与驳回打回））：
```
- 改动点仅两处: ①`1-66`→`1-69` 且 `40-65`→`40-69`；②`Rule 65 周期性回顾与前后对照` 括注后追加 ` / Rule 66 goal 单元固化与 /goal 驱动推进 / Rule 69 判断裁决子代理化与驳回打回`。其余描述字面未动 → PASS
- 披露（标签漂移）: 任务书写「References 表 critical-rules.md 行」，但任务书给出的 find 串 `Critical Rules 1-66（含 Rule 40-65 全集` 经 Grep 全库**唯一命中** `## Critical Rules` 章节引言行（原 281），非正文 `## References` 表 `references/critical-rules.md` 行（原 362，其字面为 `Critical Rules 1-66（含 Rule 13-18/21-23/25-28 关键条款…`，不含 `含 Rule 40-65 全集`）。按任务书「锚定位纪律：编辑一律以内容锚匹配为先」以内容锚为准 → 改 281。若 S7 需同步 362 行描述，属本单元未授权范围，登记待主进程裁决。

## 字面词 grep 计数（唯一写入目标内，写入后）
- `grep -c "decision-arbiter"` = **10** 行（occurrences `grep -o | wc -l` = 12）
- `grep -c "Rule 69"` = **11** 行
- 明细（decision-arbiter）: line 80(T1)/92(T4)/104(T5)/153(T6)/223(C46, 2 occurrences)/344(Rule 69 行, via selftest-decision-arbiter.sh)/383(外部 skill, 2 occurrences)/417(路由行)/470(T2)/477(T3)
- 明细（Rule 69）: line 80/92/104/153/223/286/344/383/417/470/477 = 11

## 验收标准逐条自查
1. `grep -c "decision-arbiter" SKILL.md ≥11` → **未达（=10 行；occurrences=12）**：11 项写入清单全部落地，含该 token 的**独立行**为 10（⑩/⑪/② 各行内含 token 但计 1 行）。任务书括注 `①②④-⑨⑥处+⑪` 自身求和=9，与 `≥11` 不自洽；occurrence 口径（12）满足 ≥11。判定：spec 忠实实现，计数口径差异，登记待主进程核（未擅自增行凑数，遵 §一 禁扩范围）
2. `grep -c "Rule 69" SKILL.md ≥8` → **PASS（=11 行）**
3. 既有行零改动（除 ③ 披露行 deletions=1/insertions=1）→ **PASS**（numstat = 11/1，唯一 deletion = ③）
4. `git diff --numstat` 总计 = 新增 ≤14 行 + 1 改行 → **PASS**（11 新增 ≤14；1 改行）
5. T1-T6 六标记各含对应条款号（69.1 Tn）→ **PASS**（line 80=T1 / 470=T2 / 477=T3 / 92=T4 / 104=T5 / 153=T6，各含 `Rule 69.1 Tn`）
6. 全部插入位置内容锚唯一命中 → **PASS**（每处 Edit 前 Grep 确认唯一；③ 见上披露）

## 措辞一致性核对（与 companion/agents/decision-arbiter.md）
- 四态字面一致（APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE）: C46 行引用 `REJECT-REWORK`/`ESCALATE-USER`、Rule 69 行引用四态 → PASS
- T1-T6 触发点措辞与 agent 文件「触发场景（六触发点）」表逐条对齐（T1 方案终裁/T2 兜底换道/T3 失败定级/T4 验收争议/T5 DRIFT 处置/T6 CR 分歧）→ PASS
- 管辖二分/检测本体不替代（T5 标 `检测本体仍=drift-checker，不双跑`）→ PASS
- 条款号引用准确（Rule 69 六子条 69.1-69.5 引自 critical-rules.md line 862-871 原文；T1-T6 挂 69.1）→ PASS

## 决策披露（主观判断点，供主进程复核）
1. **T1/T4/T5/T6 缩进**：任务书标「同级缩进」但字面样例给 2 空格；T4 锚（3a）实为 5 空格、T5 锚（DRIFT 行）实为 4 空格、T1 锚为 0 空格、T6 锚为 2 空格。按「同级缩进」字面义=与锚行同缩进 → 分别落 0/5/4/2（T6 字面=锚=2 无差）。避免 2 空格行插入 5 空格子列表造成 markdown 列表降级。措辞字面未改。
2. **⑪ 落位**：任务书字面 ` / decision-arbiter agent …` 起于 ` / `（暗示表内 cell 续写），但验收「既有行零改动，除第 ③ 项…1 改行」要求 ⑪ 为纯插入。为满足「1 改行」，⑪ 落为 376 行之后的**独立新行**（原样字面）。副作用：该行在 References 表后成游离段（表本体完整，仅尾随一行独立文本）。如主进程更重表整洁，可改 in-cell 续写（代价：376 行变改行，numstat 变 12/2，与本验收「1 改行」冲突）。

## 边界
- 仅写 SKILL.md + 本检查点两个文件；未触碰主仓 skills、其他 worktree、references/、scripts/、companion/；未改动 SKILL.md 既有行（③ 披露行除外）。
- worktree 既有他人改动（plan-template-kit/references/template-mapping.md、task-planner/references/agent-coverage.md）非本单元所为，未触碰。
