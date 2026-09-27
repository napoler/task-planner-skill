# S19 C-1e: UPS 6 组字段提取 → 单 awk — checkpoint (COMPLETE)

- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091
- commit: aff5e06 (parent 24e6609), 仅改 skills/task-planner/scripts/zcode-userpromptsubmit.sh (+60/-8)
- 方案: 单 awk BEGIN 内 getline 两遍(遍1 行级: goal/next_step/current 走剥注释流+decisions 走原始流; 遍2 RS="### Phase" 取首个 in_progress 记录+复刻删空行/注释区间), printf 以 \x1e 分隔输出 5 字段, bash 参数展开拆出
- 关键语义发现(对拍纠出的建模错误): GNU sed "/<!--/,/-->/d" 区间起点行只开区间, 终点模式自下一行起匹配——同行含 <!-- 与 --> 只开不闭; 首版按"同行开闭"建模导致 S1/S5 对拍 FAIL, 修正后 5/5 PASS
- 验收:
  - bash -n 通过
  - 对拍 5 场景(正常全字段/空字段/缺失字段兜底/default-sid 无 .cwd/边界对抗: 注释内 ### Phase 分割+注释内 decoy in_progress+tab 空单元格+未闭合注释到 EOF), stdout+rc 逐字节一致, PASS=5 FAIL=0
  - 计时 21 次/版本(S1 夹具, EPOCHREALTIME): 旧中位 248.111ms, 新中位 194.631ms (省 ~53ms/条消息, harness 环境无 resolver/check-conflicts)
- 风险: 计划文本若含 \x1e 分隔符字段解析会错位(实际计划文件不含该控制符); gawk 运行时 RS 赋值语义已实测与 -v RS 一致(awk=GNU Awk 5.2.1)
- /tmp 夹具已清理; 下一步可回主会话报告或由 S20 继续
