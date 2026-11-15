---
id: dispatch-init-delegation
title: 初始化首动作委派范式（L1+ 计划产出子代理化）
tags: [首动作委派, 计划期单写者, 收据契约, 会话绑定边界, dogfood, 部署对账]
sources:
  - plans/archive/task-initdelegation-20261115/task_plan.md
  - plans/archive/task-initdelegation-20261115/findings.md
  - plans/archive/task-initdelegation-20261115/progress.md
  - skills/task-planner/SKILL.md
updated: 2026-11-15
---

# 初始化首动作委派范式

> 主题级合成：L1+ 任务 init 后把「需求分析+计划文档创建」整体派发计划子代理（首实例 dogfood=task-initdelegation-20261115 自身），主代理只回收最小收据；条款落位 SKILL.md「计划制作循环」`[A] 初始化首动作委派（L1+）`（L50-58，commit 51e8631/8b69a16，critic 三轮 APPROVED）。

## 结论（可直接复用）

1. **职责切分**：主代理保留=skill 激活+init 机械子动作+派发+收据回收（盘上 Read 复核，84.4）+user-session-log 逐字落盘（80.1）+计划展示+D1 确认+attest 锁定；会话绑定脚本（init-session/attest/set-active/plan-created/哨兵清理）禁由子代理执行（会话态竞争）。执行体首选 Plan Writer，provider/档位失败降级 general-purpose 并留痕（dogfood 实证：首派 `reasoning-level-missing`→降级成功）。（来源：task-initdelegation-20261115）
2. **收据=提炼面而非替代面**：派发/返回仍走 22.4a/b/c 派发全契约（22.4b 八字段返回，机械守卫不变）；主代理回收的最小收据=从八字段返回+盘上复核提炼 `{task_id, files_created[], open_questions[], 摘要}`（≤20 行）。禁在 SKILL 条款里发明与八字段零交集的"返回格式"——会撞 check-dispatch enforce 门。（来源：同上 CR R1 P1-1）
3. **计划期单写者例外须显式声明**：计划产出子代理=计划文档计划期单写者（隔离决策区块含 check-conflicts.sh 判读由其起草；执行期子代理仍按 22.4a 只读）；既有「冲突分析」bullet 补「子代理已起草时=复核/校正，不重写」消双写歧义。遗留对账缺口：62.3（knowledge-brief 主进程单写）未引未改，靠 plan-writer 产出契约缓解——下个条款维护窗口收口。（来源：同上 CR R1 P1-2/P1-3+R3 WARNING）
4. **适用面=L1+，轻量豁免不变**：L0/mini/trivial/L0-E 不适用首动作委派（Rule 38.6/38.7 比例原则）；条款写明"禁止误读为所有场景一律加仪式"。（来源：同上 R2）
5. **路径引用教训（CR R2 阻塞-1）**：SKILL.md 根层相对引用只需一级深度（`companion/agents/plan-writer.md`）；`../../task-planner/...` 是 references/ 子目录（两级深）惯例，平移到技能根即悬空——改引用必在引用处 `test -f` 实锚解析，平台中立≠臆测相对深度。（来源：同上）
6. **部署对账口径（Q3 实证）**：先逐位 `diff -rq` 摸底判向→scope 文件级 cp（cp 前后 md5 记录）→`diff -q` 复验→位上既有差异只登记不动；~/.agents 位=骨架态部分拷贝（无 references/，SKILL.md 指针悬空=既有状态），同步前必须识别，禁整目录盲同步。（来源：同上 P4+CR P2-8）
7. **BP-08 行数钉并行演进**：双任务同改钉值冲突→并集解（双方注释行全保留+阈值 max+补组合态实值记录行）；后续增量按线性链续写（先例链 275→285→300→305，边距≥5 口径）。（来源：同上 P3/P4）
8. **归档指针守卫实证**：他会话 side 指针残留（hook 每提示刷新 mtime 致 gc 永不清）会以 active-pointer 拦归档；处置=判向（查其当前工具产物证其已转向他任务）→指针文件隔离改名（`*.active_plan` glob 逃逸+内容可恢复）→归档→留痕。archive-plan.sh `--root` 参数=**plans 目录本身**非仓根。（来源：同上 P5）
9. **dogfood 即证据**：本任务自身 init→计划产出（子代理）→收据回收→展示→attest 全链即新范式首实例，降级/复核/收据全留痕——条款类任务优先自食其果验证可执行性。（来源：同上 Phase 0）

## 易错点速查

- Verify command 行禁带 markdown 反引号（runner 整行当命令替换→exit 127）；runner 会把 Phase Gates V-N 命令沿用最近 VC 编号误标并覆盖同名 evidence（口径注记须诚实）。Goal 单元表/S-unit 状态列全 complete 时，progress 每段须有精确格式 `- **R 锚定**：` 行+对应 `[goal:Gn] 完成证据` 行，否则 goal-gate/state-mismatch 拦 check-complete。
- 回执逐项先 grep 自证再发送——「已注明」类声称先于动作执行=虚假回执（CR R2 实证抓获）。