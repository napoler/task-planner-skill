# 经验卡：task-v186-understanding-mirror
| 字段 | 内容 | 证据锚 |
|------|------|--------|
| task_id | task-v186-understanding-mirror | plans/archive/task-v186-understanding-mirror/task_plan.md:1 |
| outcome | complete（归档；merge d6a63a6+清理收口） | plans/archive/task-v186-understanding-mirror/progress.md:92 |
| goal_摘要 | 为 Rule 80 增补 80.7 理解镜像（逐字+同号配对，非权威/append-only），worktree 隔离实施+回归后合并回 master。 | plans/archive/task-v186-understanding-mirror/task_plan.md:1,19 |
| 关键决策 | 落点=Rule 80 子条 60.7 理解镜像——字符勘误：正确=80.7；同文件配对块控爆炸半径；镜像非权威、冲突以逐字原文为准；派发契约 lint 三连拦→裸路径修正。 | plans/archive/task-v186-understanding-mirror/task_plan.md:19-22; plans/archive/task-v186-understanding-mirror/findings.md:36 |
| 成功要素 | attest 5c3dfd4e+worktree 基线 6b3378f 隔离实施→commit 9c560d2→merge --no-ff d6a63a6→核验→worktree 残留=0；回归 91/91 FAIL=0。 | plans/archive/task-v186-understanding-mirror/progress.md:18,34,65,72 |
| 失败教训 | 派发契约 lint 三连拦（反引号路径/模板字面）→裸路径+冒号模板+brief 锚修正放行（提示词层教训）。 | plans/archive/task-v186-understanding-mirror/findings.md:36 |
| 可复用资产 | worktree 回合标准证据链（attest→隔离→回归→merge→核验→清理）；派发 prompt 裸路径避坑。 | plans/archive/task-v186-understanding-mirror/progress.md:65,72 |
| 用户偏好信号 | 逐字记录专档（append-only 只写不改）要求。 | plans/archive/task-v186-understanding-mirror/user-session-log.md:3-4 |
| 证据锚 | 各字段锚汇总=上表证据锚列全路径形态；另 commit bcfd507/8074969/c094530 | 同左 |
