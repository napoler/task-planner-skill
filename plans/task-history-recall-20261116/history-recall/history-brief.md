# 历史经验简报：worktree 隔离与合并回（merge back）

## 元信息
- 主题：worktree 隔离与合并回（merge back）
- 日期：2026-11-16
- 检索范围：/mnt/data/dev/task-planner-skill/plans 含 archive/（git --all）
- 模式：任务上下文内（消费方=本任务，dogfood 实测）
- 候选任务数：3 入选+4 排除（清单见 §1）

## §1 候选清单与排除理由
| task-id | 状态 | 入选/排除理由（证据锚） |
|---|---|---|
| task-crossprojauth-20261104 | partial/未归档（mini stub） | 入选：Rule 100/101 worktree 规范本体任务（commit ec72683） |
| task-v186-understanding-mirror | complete（归档） | 入选：worktree 回合标准证据链实证（卡：progress.md:18,65,72） |
| task-specmode-integration-20261115 | complete（归档） | 入选：worktree merge+部署+清理全链实践与失败教训（卡：findings.md:49-52,69-70） |
| task-v164-pointer-worktree-local | complete（归档） | 排除：worktree 仅手段非主题 |
| task-v182-git-snapshot-commits | complete（归档） | 排除：双提交纪律主题，worktree 仅承载面 |
| s77-p2-fix / skill-audit-s77-fix | complete | 排除：worktree 仅手段 |
| task-v135 / task-v141 | complete（归档） | 排除：早期 desync 教训已沉淀于 worktree-isolation.md 模板层

§1 注（实测教训）：路由命中后必须 ls 验证目录实名存在性（本次两处假设落空，靠枚举实名修正）；教训待回灌 SKILL.md SOP 路由步。

## §2 跨任务结论四维
### ①成功模式
- worktree 全链 SOP 成型且被复用：attest→隔离→回归→merge --no-ff→核验→清理（锚：plans/archive/task-v186-understanding-mirror/progress.md:65,72）
- 制度层 Rule 100/101（tmp/worktrees/<task-id> 路径规范+起点锚定+终点主动合并+冲突=收口义务）（锚：commit ec72683）
- stash 窗口法过 plan-resume 遗留暂存态（锚：plans/archive/task-specmode-integration-20261115/progress.md:60；判例二度实证锚 findings.md:70）
- 部署 diff=0+push ahead=0 收口模式（锚：cards/task-crossprojauth-20261104.md:9）

### ②失败教训（频次+根因聚类）
- [频次 2][聚类 管线环境阻断] merge 被遗留暂存态/对端活跃 workflow 阻断→stash 窗口法（锚：specmode findings.md:69-70，v195 判例二度实证锚同格）
- [频次 1][聚类 回归断言钉值] BP-08 行数钉回归→改行数前 grep 行数钉族+实值+5 边距+追加不改写（锚：specmode findings.md:49）
- [频次 1][聚类 派发契约] 派发契约 lint 三连拦→裸路径+冒号模板+brief 锚（锚：task-v186-understanding-mirror/findings.md:36）

### ③用户偏好演变
- 逐字记录专档（append-only 只写不改）（锚：task-v186-understanding-mirror/user-session-log.md:3-4）
- 「调用非复制」集成观+task-planner=忠实记录者+调度者（锚：task-specmode-integration-20261115/user-session-log.md:42-44）
- L0-lite 最小 stub 轻量豁免先例（锚：plans/task-crossprojauth-20261104/task_plan.md:17-18）

### ④可复用资产
- Rule 100/101 纪律条款族（锚：commit ec72683）
- worktree 回合标准证据链 SOP（锚：task-v186-understanding-mirror/progress.md:65,72）
- stash 窗口合并法（锚：task-specmode-integration-20261115/progress.md:60）
- 行数钉维护策略：实值+边距、追加不改写（锚：specmode findings.md:49）
- 派发 prompt 裸路径/冒号模板避坑（锚：task-v186-understanding-mirror/findings.md:36）

## §3 建议
- merge 预留 stash 窗口法预案（依据：specmode findings.md:69-70）
- 部署=文件级 cp+diff -rq 全对账（依据：cards 两卡成功模式）
- BP-08 已实测：S5 +1 行未触发行数钉回归（--fresh FAIL=5 与基线一致）（依据：本任务 S8 实测）
- 路由步经验回灌 SOP：路由命中后 ls 验证目录实名存在性（依据：§1 注）
- 收口=diff=0+push ahead=0（依据：两卡成功模式）

## §4 证据锚索引
| task-id | 卡路径 | 关键源锚 |
|---|---|---|
| task-crossprojauth-20261104 | cards/task-crossprojauth-20261104.md | task_plan.md:1-23; commit 8db66b8/6583f14/ec72683/2f4540d |
| task-v186-understanding-mirror | cards/task-v186-understanding-mirror.md | task_plan.md:1,19-22; progress.md:18,34,65,72,92; findings.md:36 |
| task-specmode-integration-20261115 | cards/task-specmode-integration-20261115.md | task_plan.md:1,24,34; progress.md:60-62,78; findings.md:49-52,69-70; usl:42-44 |

## §5 未覆盖面
- 已查：INDEX 主表+git log --all --grep worktree（通道 A/B）+3 任务五文档（定向 grep 定位）+git 提交面
- 未查到/未覆盖：crossprojauth（mini stub）无 progress/findings/usl 可挖（卡内已标未查到）；早期 desync 任务（v135/v141）未入选（教训已沉淀模板层）

## §6 护栏自检
- 候选任务：上限 8，实际 3 入选+4 排除
- 子代理：1 个，每代理上限 3 任务
- 简报行数：上限 150，实际见 wc -l（机械取值）

> 无锚结论禁写；查不到如实标未查到。
