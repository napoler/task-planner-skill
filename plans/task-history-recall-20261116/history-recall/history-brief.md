# 历史经验简报：worktree 隔离与合并回（merge back）

## 元信息
- 主题：worktree 隔离与合并回（merge back）
- 日期：2026-11-16
- 检索范围：/mnt/data/dev/task-planner-skill/plans 含 archive/（git --all）
- 模式：任务上下文内（消费方=本任务 task-history-recall-20261116，dogfood 实测）
- 候选任务数 N：3

## §1 候选清单与排除理由
| task-id | 状态 | 入选/排除理由（证据锚） |
|---|---|---|
| task-crossprojauth-20261104 | partial/未归档（mini stub） | 入选：Rule 100/101 worktree 规范本体任务（commit ec72683） |
| task-v186-understanding-mirror | complete（归档） | 入选：worktree 回合标准证据链实证（progress.md:118-137） |
| task-specmode-integration-20261115 | complete（归档） | 入选：近期 worktree merge+部署+清理全链实践与三条失败教训（findings.md:114-121） |
| task-v164-pointer-worktree-local | complete（归档） | 排除：worktree 仅手段非主题（指针瞬态化主题） |
| task-v182-git-snapshot-commits | complete（归档） | 排除：双提交纪律主题，worktree 仅承载面 |
| s77-p2-fix / skill-audit-s77-fix | complete | 排除：worktree 仅手段 |
| task-v135 / task-v141 | complete（归档） | 排除：早期 desync 教训已沉淀于 worktree-isolation.md 模板层

§1 注（实测教训）：路由命中后必须 ls 验证目录实名存在性——本次「crossprojauth 在 archive」「v186 裸名」两处假设落空，靠枚举实名修正；该教训待 CR 后回灌 SKILL.md SOP 路由步。

## §2 跨任务结论四维
### 1 成功模式
- worktree 全链 SOP 成型且被复用：attest 锁定→隔离实现→回归→merge --no-ff→核验→清理（锚：plans/archive/task-v186-understanding-mirror/progress.md:118-137）
- 制度层 Rule 100/101（tmp/worktrees/<task-id> 路径规范+起点锚定+终点主动合并+冲突=收口义务）（锚：commit ec72683）
- stash 窗口合并法绕过 plan-resume 遗留暂存态阻断（锚：plans/archive/task-specmode-integration-20261115/findings.md:114-121）
- 部署 diff=0+push ahead=0 收口模式（锚：cards/task-crossprojauth-20261104.md:9）

### 2 失败教训（频次+根因聚类）
- [频次 2][聚类 管线环境阻断] merge 被遗留暂存态/对端活跃 workflow 阻断 → stash 窗口合并法（锚：specmode findings.md:114-121；v195 同款判例）
- [频次 1][聚类 回归断言钉值] BP-08 行数钉回归（SKILL.md 行数变更触发钉值失败）→ 实值+边距+追加不改写（锚：specmode findings.md:114-121）
- [频次 1][聚类 派发契约] 派发契约三连拦（反引号路径/模板字面/brief 锚）→ 裸路径+冒号模板+brief 锚（锚：task-v186-understanding-mirror/findings.md:68-74）

### 3 用户偏好演变
- 逐字记录+理解镜像配对，回溯理解偏差（锚：plans/archive/task-v186-understanding-mirror/user-session-log.md:10-19）
- 「调用非复制」集成观+task-planner=忠实记录者+调度者（锚：plans/archive/task-specmode-integration-20261115/user-session-log.md:37-46）
- L0-lite 最小 stub 轻量豁免先例（锚：plans/task-crossprojauth-20261104/task_plan.md:17-18）

### 4 可复用资产
- Rule 100/101 纪律条款族（锚：commit ec72683）
- worktree 回合标准证据链 SOP（锚：task-v186-understanding-mirror/progress.md:118-137）
- stash 窗口合并法（锚：specmode progress.md:67-77）
- 行数钉维护策略：实值+边距、追加不改写（锚：specmode findings.md:114-121）
- 派发 prompt 裸路径/冒号模板避坑（锚：task-v186-understanding-mirror/findings.md:68-74）

## §3 建议
- Phase 5 merge 预留 stash 窗口合并法预案（依据：specmode/v195 判例）
- 部署=文件级 cp+diff -rq 全对账（依据：crossprojauth/specmode 两卡成功模式）
- BP-08 行数钉核查：S5 +1 行后跑 --fresh 全量对照——已实测：FAIL=5 与 master 基线 5 一致，行数钉相关失败面零新增（依据：specmode 卡失败教训(1)+本任务 S8 实测）
- 路由步经验回灌 SOP：路由命中后 ls 验证目录实名存在性（依据：§1 注实测教训）
- 收口模式=diff=0+push ahead=0（依据：两卡成功模式）

## §4 证据锚索引
| task-id | 卡路径 | 关键源锚 |
|---|---|---|
| task-crossprojauth-20261104 | cards/task-crossprojauth-20261104.md | task_plan.md:1-23; commit 8db66b8/6583f14/ec72683/2f4540d |
| task-v186-understanding-mirror | cards/task-v186-understanding-mirror.md | progress.md:118-137; commit c094530/bcfd507/8074969 |
| task-specmode-integration-20261115 | cards/task-specmode-integration-20261115.md | progress.md:117-133; commit a349a89/c5b891d/6e9dcfc |

## §5 未覆盖面
- 已查：INDEX 主表+git log --all --grep worktree（通道 A/B）+3 任务五文档（限 80 行）+git 提交面
- 未查到/未覆盖：crossprojauth（mini stub）无 progress/findings/user-session-log 可挖（卡内已标未查到）；早期 desync 任务（v135/v141）未入选（教训已沉淀模板层）

## §6 护栏自检
- 候选任务：上限 8，实际 3
- 子代理：1 个，每代理上限 3 任务，实际 3
- 简报行数：上限 150，实际 73

> 无锚结论禁写；查不到如实标未查到。
