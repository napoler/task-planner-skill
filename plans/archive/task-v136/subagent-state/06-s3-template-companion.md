# Checkpoint 06-s3-template-companion (S3 模板+companion 联动, task-v136/Phase 3)

## 写前锚记录 (pre-write anchors)

写前 grep "Rule 54" 计数: 三文件均 = 0 (干净基线)。
worktree git status: 仅 `M skills/task-planner/references/critical-rules.md` (S2 并行写集, 与本任务写集不相交), HEAD = 4bca3dd。

① templates/delivery-summary.md
- 插入锚: line 32 `- **行为面变化**: [必填行——...]` 与 line 33 `- **交付结论**: COMPLETE / PARTIAL / BLOCKED [引 verification.md Goal Gate outcome]` 之间
- 插入位置: "## 1. 任务说明"（产出/说明区）末 bullet, 新行落 line 33, 交付结论 bullet 顺移至 34

② companion/agents/image-generation-executor.md
- 插入锚: line 36 `- **静默执行**：批次内 0 打断（冻结/D6 除外）；只落检查点不回传叙事；批次末单份收尾报告`（"## 核心能力" 末 bullet, :36 附近静默执行纪律段后）
- 其后为 line 37 空行 + line 38 `## 🔒 前置检查（强制）`; 新行落 line 37

③ companion/agents/video-generation-executor.md
- 插入锚: line 37 `- **QC 回执**：机检+亲检结论、缺陷类别与归因维度、建议处置级别（不自行裁决）`（"## 核心能力" 末 bullet, 等价于 ② 的静默执行段位置）
- 其后为 line 38 空行 + line 39 `## 🔒 前置检查（强制）`; 新行落 line 38

## 硬约束自检
- 每文件恰 +1 行 (1 insertion 0 deletion, 位置行除外); 禁改既有行; 禁案例专属词 (无 EP8/额度数字/cron 字样)

## 写后 git diff 摘录 (post-write evidence)

git diff --numstat (worktree HEAD=4bca3dd):
```
1 0 skills/task-planner/companion/agents/image-generation-executor.md
1 0 skills/task-planner/companion/agents/video-generation-executor.md
1 0 skills/task-planner/templates/delivery-summary.md
```
`git diff --stat` 合计: 3 files changed, 3 insertions(+), 0 deletions(-)。
既有行零改动 (0 deletion; 新增行以 `+` 前缀独立成行, 既有行仅顺移行号)。

## grep 验收记录
- `grep -c "Rule 54"`: delivery-summary=1 / image=1 / video=1 (写前三文件均为 0, 增量恰 +1)
- delivery-summary: `grep -c "54.1"` = 1, `grep -c "54.4"` = 1 (54.5 同锚行内含)
- 禁案例专属词: `grep -nEi "EP8|cron|额度"` 三文件 = none found

## 最终新增行 (各 1 行)
① delivery-summary.md (line 33, "## 1. 任务说明" 末 bullet, 交付结论之后):
`- **真实进展对照（Rule 54.1③/50.3）**: 呈报状态必须按需求原子条目表（Rule 50.1）逐项给真实评级对照——准备物完成、仪式动作、推迟项均不得表述为需求推进；推迟决策附 Rule 54.4 四要素举证；决策依据数据引用落盘锚（Rule 54.5，file#锚点形态，禁裸会话数据）`
② image-generation-executor.md (line 37, 静默执行 bullet 之后, "## 核心能力" 末):
`- **Rule 54 消费（task-v136）**：状态汇报按 54.1 就绪语义（准备物/中间产物 ≠ 需求推进…）+ 资源状态声称附第一手查询证据…54.2 影响矩阵逐项判定…54.4 四要素举证…54.5 引用落盘锚`
③ video-generation-executor.md (line 38, QC 回执 bullet 之后, "## 核心能力" 末):
等价一行, 措辞适配镜头/视频语境 (逐镜头单元判定 / 配额·容量·可用性资源状态 / 轮询中间态≠镜头需求推进)

status: 完成 (S3 写集全部落盘, 验收 4 条全过)
