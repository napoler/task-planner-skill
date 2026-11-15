# 经验卡：task-v186-understanding-mirror

| 字段 | 内容 | 证据锚 |
|------|------|--------|
| task_id | task-v186-understanding-mirror | plans/archive/task-v186-understanding-mirror/task_plan.md:1 |
| outcome | complete（已归档入库 plans/archive/；合并收口干净） | plans/archive/task-v186-understanding-mirror/progress.md:118-137; commit c094530 |
| goal_摘要 | 为 Rule 80 增补 80.7「理解镜像」：逐字记录后同号配对模型理解镜像（非权威对照面、append-only），用于回溯理解偏差；在 worktree 隔离开发、全量回归零破坏后合并回 master。 | plans/archive/task-v186-understanding-mirror/task_plan.md:30-33,55-66; plans/archive/task-v186-understanding-mirror/findings.md:1-6 |
| 关键决策 | 落点=Rule 80 子条 80.7（零新 Rule 号/零全集级联）；同文件配对块而非独立第 8 文件以控 blast radius；镜像非权威、冲突以逐字原文为准、append-only 更正；worktree 隔离+merge --no-ff 收口。 | plans/archive/task-v186-understanding-mirror/task_plan.md:19-28,60-76; plans/archive/task-v186-understanding-mirror/findings.md:96-105 |
| 成功要素 | worktree 创建后隔离实施（attest 锁定+worktree 基线 6b3378f）、子代理分工（S1/S2/drift/code-runner/CR/Verifier/alignment）配合主进程亲验、commit 9c560d2 后 merge --no-ff d6a63a6 并核验 grep+worktree list=0 清理；全量回归 91/91 FAIL=0。 | plans/archive/task-v186-understanding-mirror/progress.md:24-33,84-101,118-137,139-147; plans/archive/task-v186-understanding-mirror/task_plan.md:68-72 |
| 失败教训 | 派发契约实测三连拦：反引号包裹路径致 `[ -f ]` 身份判定失败、8 字段模板冒号字面问题、knowledge-brief §引用缺失——以裸路径+带冒号模板+brief 锚点修正放行（流程/提示词层教训，非代码缺陷）。 | plans/archive/task-v186-understanding-mirror/findings.md:68-74 |
| 可复用资产 | worktree 回合标准证据链（attest/基线→scope 改动→独立回归→merge --no-ff→grep 核验→worktree 清理→簿记）；80.7 配对格式模板与 dogfood 先例；派发 prompt 裸路径/模板格式避坑经验。 | plans/archive/task-v186-understanding-mirror/progress.md:24-33,118-137; plans/archive/task-v186-understanding-mirror/user-session-log.md:10-19; commit 8074969; commit bcfd507 |
| 用户偏好信号 | 用户要求“逐字记录+模型理解同步记录”形成配对，便于回溯理解偏差并及时纠正；强调逐字专档只写不改/权威序保持。 | plans/archive/task-v186-understanding-mirror/user-session-log.md:10-19; plans/archive/task-v186-understanding-mirror/task_plan.md:3-16 |
| 证据锚 | plans/archive/task-v186-understanding-mirror/task_plan.md:1-76; plans/archive/task-v186-understanding-mirror/progress.md:1-147; plans/archive/task-v186-understanding-mirror/findings.md:1-110; plans/archive/task-v186-understanding-mirror/user-session-log.md:10-19; plans/archive/task-v186-understanding-mirror/knowledge-brief.md:1-40; commit bcfd507; commit 8074969; commit c094530。 | 同左 |
