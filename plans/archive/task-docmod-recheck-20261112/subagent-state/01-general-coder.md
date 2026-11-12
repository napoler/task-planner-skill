# 01-general-coder 检查点（Rule 106 追加）

- 时间戳: 2026-11-13 (session execution)
- 任务: 在隔离 worktree 的 `skills/task-discipline/references/critical-rules-discipline.md` 末尾追加 Rule 106 段（106.1/106.2/106.3/106.5），按 findings.md `§Rule106 草案` 逐字定稿。
- 修改文件: `/mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112/skills/task-discipline/references/critical-rules-discipline.md`
- 新增段起止行号: 721-732（标题行 721；子条 723/725/727/729；末行为 732）

## 做了什么
1. 只读定位：Read findings.md 草案与目标文件末尾，确认 Rule 105 段结束于 L719（总行 719），观察既有格式（`### N 标题` + 空行 + `N.x **...**` 子条 + 空行分隔）。
2. 纯增量追加：在文件末尾追加空行 + `### 106 ...` 标题 + 106.1/106.2/106.3/106.5 全文（与草案一致，含判例 sess_1378b365/G22-05a 与 Why 行）；未改 Rule 105 及以上任何既有内容；未触碰 worktree 内其他文件；未 git commit。

## 自检 1: `grep -cE '106\.[1-5]' <目标文件>`
命令:
```bash
cd /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112 && grep -cE '106\.[1-5]' skills/task-discipline/references/critical-rules-discipline.md
```
输出:
```text
5
```

## 自检 2: `cd worktree && git diff --stat`
命令:
```bash
cd /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112 && git diff --stat
```
输出:
```text
 .../task-discipline/references/critical-rules-discipline.md | 13 +++++++++++++
 1 file changed, 13 insertions(+)
```

## 自检 3: `git diff <目标文件>`（确认无删除行，纯 + 行）
命令:
```bash
cd /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112 && git diff skills/task-discipline/references/critical-rules-discipline.md
```
输出:
```diff
diff --git a/skills/task-discipline/references/critical-rules-discipline.md b/skills/task-discipline/references/critical-rules-discipline.md
index 6840b52..7f3fa4b 100644
--- a/skills/task-discipline/references/critical-rules-discipline.md
+++ b/skills/task-discipline/references/critical-rules-discipline.md
@@ -717,3 +717,16 @@ C 级问题必须自动修复+登记（Decisions Made `auto:` 行或 progress.md
 105.4 **适用边界**：本条管「可枚举小集合的匹配/存在性判断」；大仓代码搜索/海量日志排查（不可枚举集合）仍走关键词检索（Explore 路由/Rule 63.2 检索链），本条不适用。边界判据=候选集合能否一次列出完整清单供人工目检（数值口径同 105.1）。
 
 105.5 **反例锚（判例存档）**：2026-11-06 用户判例——素材命名全集几十个，执行体用「装备车/二层/飞桥/帘/天幕」命名族关键词全库搜索，漏掉用户点名的合规件，归因「搜索面太窄」后错误决定 asset-first 路线；正确动作=ls 素材目录全量列出，在完整清单上选择匹配。
+
+### 106 文档修改复检纪律（task-docmod-recheck-20261112 落地；判例=sess_1378b365「G22-05a 三方时间口径不一致仍放行」——段标题 40-46s / 台词〔全稿41-45s〕〔全稿46-49s〕/ 段末 46s 拆点互相矛盾且自检字段仍写 PASS）
+
+106.1 **写后回读门（过程期，P0）**：对仓库受管文档（.md/配置/数据/内容稿）的每次修改（Edit/Write/脚本批量改写均算），在该修改步声称完成前，必须完成两项复检：① 修改点落盘内容与意图一致（Edit 成功 ≠ 语义正确）；② 该文档的跨字段不变量链（时间轴/编号/ID/拆点/交叉引用等相互约束字段）未被本次修改破坏。复检一行留痕 progress.md（`[recheck] 对象×不变量×结论`）。与 Rule 20.5 边界：20.5 豁免「确认写入成功」型重读（内容仍在上下文），不豁免「跨字段一致性」型复检（校验对象在本次修改点之外、上下文中未必有）。判例：G22-05a 任一轮修改后做一次不变量回读即可当场拦截三方矛盾。
+
+106.2 **派生值先定基准（P0）**：结构化文档中存在派生关系的字段（例：段标题时间区间 ⊇ 各台词秒段、拆点=相邻段公共边界、镜内秒段 ⊆ [0,镜长]），修改任一派生值前必须先锚定基准值（明确以哪一侧为准=source of truth），再沿派生链全链重算所有受影响字段；禁止只改一处、其余字段保留旧值。判例：C87 拆分只改段标题与拆点、台词双轨秒段未全链重算 → 18 处镜内溢出。
+
+106.3 **同文件二次修改全量回归（P1）**：同一文件在本任务内被第 ≥2 次修改后，复检面自动升级为「全文档不变量回归」——对该文档全量重跑其不变量校验（非只看本次 diff、非只扫修改点），全绿才可放行；此后每轮修改均须全量回归，禁止「上一轮验过、本轮只看增量」。与 Rule 67.1 分工：67.1 管「≥3 次往复」的上下文压力评估与升级，106.3 管「≥2 次修改后」的一致性回归，互补不替代。判例：修复器 v4→v6 每轮局部修补，口径漂移累积到终验仍未收敛。
+
+106.5 **两组 todo 驱动对齐（P0，2026-11-13 用户 B 扩展指令）**：每个计划的执行视图由两组**原生 todo**（TodoWrite/Task 系统条目，禁止只存计划文档）构成，S1 建组缺一=计划不得进入执行：
+- **通用基线组**（全任务恒存在，与任务类型无关，清单唯一事实源=todo-sync 契约）：**B1** 修改后验证与复检留痕（Rule 106.1/106.2/106.3，持续项：status=in_progress 直至终验，完成判据=期间全部 `[recheck]` 留痕齐备）；**B2** Phase 翻转前 V-N 校验（Rule 84.3，每 Phase 一次）；**B3** 终验 VC 全复验（Rule 84.5）；**B4** 收尾回读梳理（Rule 84.14，连续一轮零新发现）；**B5** Todo 终态同步（S4，含基线组自身）。
+- **任务步骤组**：Phase/S-unit 映射（todo-sync S1 既有契约不变）。
+基线组与门禁硬挂钩：B1 未勾=修改步不得声称完成；B2 未勾=Phase 不得翻 complete；B3/B4 未勾=不得出 outcome；S3 `[plan-sync]` 回写两组都要处理，基线组条目丢失=当次立即重建（防丢弃）。Why：todo=执行视图唯一事实，门禁挂 todo 使「流程缺失/丢弃」在下次同步时可见；B1 设计为持续项避免逐次修改的 todo 刷屏。
```

## 自审（Rule 103.2，本次变更风险与确认点）
- 风险1：草案含 106.1/106.2/106.3/106.5 但无 106.4 正文（findings 仅有 106.4 决策/兼容措辞说明），已按草案逐字落盘，编号间断需上游确认是否后续补条。
- 风险2：`grep -cE '106\.[1-5]'` 计 5，覆盖四个子条标号但未单独校验 106.4 缺失；人工核对为仅 106.1/106.2/106.3/106.5 四条。
- 确认：diff 纯新增（13 行插入，1 文件），Rule 105 及以上内容未改，未 git commit，未触碰其他文件。

---

## 追加：插入 106.4（回补）
- 时间戳: 2026-11-13 (follow-up append)
- 变更: 在 `106.3`（L727）与 `106.5`（原 L729）之间插入空行 + `106.4 **验证对象=交付物本体（P0）**` 段（用户指定原文），保持其余内容零改动。
- 新段行号范围: **L729**（`106.4` 子条文本），前后各空行 L728/L730；`106.5` 顺延至 **L731**，Rule 106 段整体现为 L721-L734。

### 自检: `for i in 1 2 3 4 5; do grep -c "106\.$i" <目标文件>; done`
输出:
```text
2
2
2
1
1
```
说明：106.1/106.2/106.3 计数为 2，因对应子条标题行各 1 次 + 106.5(B1) 内引用 `Rule 106.1/106.2/106.3` 各 1 次；106.4、106.5 各 1 次。逐子条标题行均存在（见 `grep -n '^106\.'`：723/725/727/729/731）。

### 自检: `git diff --stat skills/task-discipline/references/critical-rules-discipline.md`
输出:
```text
 .../references/critical-rules-discipline.md               | 15 +++++++++++++++
 1 file changed, 15 insertions(+)
```
仍为单文件纯新增。

### 自审
- 106.4 已按用户给定正文插入 106.3 与 106.5 之间，判例与两态兼容表述完整；106.1/106.2/106.3/106.5 原文未改动。
- `grep -c "106\.$i"` 因 106.5 行内对 106.1-106.3 的引用而对前三项返回 2，属预期（非重复子条）；子条标题行覆盖 1-5 全齐。
