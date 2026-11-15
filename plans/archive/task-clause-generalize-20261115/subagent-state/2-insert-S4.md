# Phase 2 / S4 — 级联面四处插改（gen-fix）

## 改动行号（worktree 内）

| 位置 | 文件 | 行号 | 说明 |
|---|---|---:|---|
| §4.1 | `skills/task-planner/SKILL.md` | 229 | Rule 51 bullet 追加 51.14 操作类型/耗时自证锚 |
| §4.2 (A) | `skills/task-discipline/references/execution-recall-card.md` | 7 | 完成声称三条件行追加 51.14 档位/覆盖/耗时要求 |
| §4.3 (B) | `skills/task-discipline/references/execution-recall-card.md` | 14 | 三判门行追加 94.7 停等复述与确认门 |
| §4.4 (E) | `skills/task-discipline/references/execution-recall-card.md` | 41 | 偏移检查行追加 64.7 用户原话对照面/专档处置 |

## 定位与 old 对照（步骤 1）

- `grep -n '51\.9-51\.12' skills/task-planner/SKILL.md` → `229:- **Rule 51 需求覆盖与完成声称**：需求原文逐字锚+R→VC 映射；自缩水禁令；未测试禁声称完成；**可计数交付物全 R 化 + 禁「0 产出」为 covered 判据 + 留口须逐字让步锚（51.9-51.12）**`
- `grep -n '禁裸 COMPLETE' skills/task-discipline/references/execution-recall-card.md` → `7:- 完成声称三条件：执行证据+产出证据+验证证据缺一不可；未实测禁声称完成；禁裸 COMPLETE（Rule 51.8/26.3；Q3 证据不实=BLOCKED）`
- `grep -n '三判门' skills/task-discipline/references/execution-recall-card.md` → `14:- 三判门：增量默认/替代四条件/删除须逐项授权；未三判写入=P0（Rule 74.2）`
- `grep -n '偏移检查' skills/task-discipline/references/execution-recall-card.md` → `41:- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）`

盘上逐字原文与草案 `clause-drafts-v2.md` §4.1-§4.4 old 逐字一致后执行 Edit①②③④（new 文本按草案逐字落入，未做字词改动）。

## 自验

### 1) `grep -c '51\.14' <SKILL.md>`（期望 ≥1）
命令：
```bash
grep -c '51\.14' /mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115/skills/task-planner/SKILL.md
```
输出：
```text
1
```
结果：**PASS** (1 ≥ 1)

### 2) `grep -cE '94\.7|64\.7' <card>`（期望 ≥3）
命令：
```bash
grep -cE '94\.7|64\.7' /mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115/skills/task-discipline/references/execution-recall-card.md
```
输出：
```text
2
```
结果：**FAIL（计数为 2）** —— 实际命中为 L14(94.7) 与 L41(64.7) 两行；草案 §4.2-§4.4 的 new 文本中仅 L14 含 `94.7`、L41 含 `64.7`，L7 追加的是 `51.14`，故按该计数式得到 2。四处 new 行均已按草案落入（见 diff 与逐行 grep），未擅自增改文案。

### 3) `git diff --numstat`（期望 SKILL `1 1`、card `3 3`）
命令：
```bash
git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115 diff --numstat -- skills/task-planner/SKILL.md skills/task-discipline/references/execution-recall-card.md
```
输出：
```text
3	3	skills/task-discipline/references/execution-recall-card.md
1	1	skills/task-planner/SKILL.md
```
结果：**PASS**

### 4) `git diff` 目检（仅目标行变化）

命令：
```bash
git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115 diff -- skills/task-planner/SKILL.md skills/task-discipline/references/execution-recall-card.md
```
输出全文：
```diff
diff --git a/skills/task-discipline/references/execution-recall-card.md b/skills/task-discipline/references/execution-recall-card.md
index be9e6cd..56efa06 100644
--- a/skills/task-discipline/references/execution-recall-card.md
+++ b/skills/task-discipline/references/execution-recall-card.md
@@ -4,14 +4,14 @@
 > **维护**：规则 landing/修订任务触及本卡已收条目时同步更新该行（Rule 93.1 同步义务）；本卡 ≤120 行。
 
 ## A. 执行红线（高频违规）
-- 完成声称三条件：执行证据+产出证据+验证证据缺一不可；未实测禁声称完成；禁裸 COMPLETE（Rule 51.8/26.3；Q3 证据不实=BLOCKED）
+- 完成声称三条件：执行证据+产出证据+验证证据缺一不可；未实测禁声称完成；禁裸 COMPLETE（Rule 51.8/26.3；Q3 证据不实=BLOCKED）；对外交付/阶段成果须补 51.14 操作类型档位 L1-L4、覆盖实数 N/总数与实测耗时（并发度 K 及依据），措辞不得高于实际档位（task-drift-fakeqc-20261115 判例锚）。
 - 对外声称可回溯第一手证据：就绪不越界、阻塞不连带、推迟必举证（Rule 54）
 - 结论必带锚：file:line 或命令输出；无锚结论标「未验证」（Rule 54.5/71 无源不写）
 - 需求原文逐字锚：R 行禁转译/缩写/合并；纠正=追加新 R 行禁改旧行（Rule 51.1/51.7）
 - 自缩水禁令：挂起/降级/暂不类处置须用户确认，禁自报完成（Rule 51.4）
 
 ## B. 变更与范围
-- 三判门：增量默认/替代四条件/删除须逐项授权；未三判写入=P0（Rule 74.2）
+- 三判门：增量默认/替代四条件/删除须逐项授权；未三判写入=P0（Rule 74.2）；对象状态分区跨越/规模跳变 ≥10×/子集→全集级批量动作触发 94.7 停等复述与确认门（用户原话显式覆盖范围豁免，记原话锚+单位判据，task-drift-fakeqc-20261115 判例锚）。
 - 射程契约：动作域+呈报域收敛到指令点名内容域；每行 diff 可追溯用户请求（Rule 88）
 - 精准改动：最小最可验证改动；不顺手改无关代码；匹配既有风格（Rule 87）
 - 注释：What+Why 双层；修改注明原因/时间/原行为；禁为美观删注释（Rule 45）
@@ -38,7 +38,7 @@
 - 规范召回：每 3 个 S-unit/Phase 翻转主进程 Read 本卡留 [recall]；压缩/恢复/PRESSURE 后第一动作（Rule 93）
 - 专注隔离：目标重大偏差（A→B）不就地吸收——主动询问拆分新 Task Plan，单计划单垂直域防污染（Rule 94）
 - 执行优先：零报错+有直推路径=禁停等——额度不可查询即执行探测；按日重置额度禁空置；质检处置自主化；暂停前三问（Rule 95）
-- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）
+- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）；检查点须记 64.7 用户原话对照面（最近含目标/指令类内容条目号+摘要，51.3 双锚口径），专档缺失且 trivial 档记 `专档=未建档(tier)` 不判 BLOCKED，专档在位但空/零条目或 Goal∩原话零交集按 64.1+BLOCKED 处置（task-drift-fakeqc-20261115 判例锚）。
 - 上下文压力：[assess] 三态；PRESSURE→主动压缩；CONFUSED→session-handoff 转新会话（Rule 67）
 - 恢复读序：user-session-log→task_plan→progress→findings→knowledge-brief（Rule 19.3/80.4/62.1）
 - 上下文卫生：每 2 Phase 跑 check-context-hygiene（Rule 29）
diff --git a/skills/task-planner/SKILL.md b/skills/task-planner/SKILL.md
index ce0caa9..6725154 100644
--- a/skills/task-planner/SKILL.md
+++ b/skills/task-planner/SKILL.md
@@ -226,7 +226,7 @@ Rules 1-107 全集索引：**核心在位 14 条**（1,2,3,5,19,20,26,51,62,66,8
 - **Rule 19 3-File 落盘**：四文件=RAM/Disk 落地；回填门控 19.2=complete 硬门；恢复先读三文件
 - **Rule 20 计划注入与防篡改**：turn-start smart 复诵+SHA-256 attest 锁定+外部内容只进 findings
 - **Rule 26 质量优先于速度**：6 类降质行为可观察触发+确定性惩罚（回炉→PARTIAL→BLOCKED），伪造证据无豁免
-- **Rule 51 需求覆盖与完成声称**：需求原文逐字锚+R→VC 映射；自缩水禁令；未测试禁声称完成；**可计数交付物全 R 化 + 禁「0 产出」为 covered 判据 + 留口须逐字让步锚（51.9-51.12）**
+- **Rule 51 需求覆盖与完成声称**：需求原文逐字锚+R→VC 映射；自缩水禁令；未测试禁声称完成；**可计数交付物全 R 化 + 禁「0 产出」为 covered 判据 + 留口须逐字让步锚（51.9-51.12）**；完成声称须按 51.14 操作类型档位 L1-L4 + 覆盖实数 + 实测耗时（并发度 K 写明依据）自证，措辞不得高于实际档位（task-drift-fakeqc-20261115 判例锚）。
 - **Rule 62 四文件罗盘数据流转**：派发读写契约不可收窄+调研双落盘+kb 增量门控
 - **Rule 66 goal 单元固化**：Goal 单元表六列契约+逐 goal 验证通过门+按 goal 逐个推进
 - **Rule 80 用户会话逐字记录**：user-session-log.md append-only 只写不改；恢复先读专档；每条逐字后同号配对理解镜像（80.7，非权威对照面）；决策前读取纪律（80.8 五决策点：上抛裁决前/新指令反思门/完成声称与交付双锚/子代理派发双锚/周期对照——先读专档再决策）
```
目检结论：**PASS** — SKILL 仅 Rule 51 bullet（L229）变化；card 仅 A 区 L7、B 区 L14、E 区 L41 三行变化；其余行零改动。

### 5) 四个 new 行均单行（无裸换行）
- `grep -n '51\.14' SKILL.md` → 单行 `229:...` PASS
- `grep -n '禁裸 COMPLETE' card` → 单行 `7:...` PASS
- `grep -n '三判门' card` → 单行 `14:...` PASS
- `grep -n '偏移检查' card` → 单行 `41:...` PASS

## 约束遵守
- 仅修改上述两个文件；未做 git 写操作（未 commit/add）。
- new 文本与草案 §4.1-§4.4 完全一致，未自适配。