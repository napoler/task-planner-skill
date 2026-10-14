# 05-s2-userpromptsubmit — S2 UserPromptSubmit hook 扩展（多行 Goal + 锚点卡回注）

- [16:10] 输入材料齐备：01-explore §4-§5（三重收窄证据 :113 Goal 单行、字段集缺 R/不变量）、zcode-userpromptsubmit.sh 全文（注入块 :84-162、组装 :216-230）、plan-anchor.sh（锚点卡 5 字段：## 用户需求原文/不变量/Goal/Current Phase/Next Step + --- 分隔；R 行过滤 `^- \*\*R[0-9]`，不变量过滤 `^| 🔒`）
- [16:20] 修改落盘第 1 版：① awk 遍1 goal 由首行改多行累加 ② 注入组装抽为 build_inject_block(plan, progress_file, anchor_card) 函数（供 --test 直驱同一逻辑，零测试专用副本）③ 新增锚点卡两段（awk 节过滤「用户需求原文」「不变量」，其余 3 字段与既有字段等价不重复）④ 卡缺失降级提示行 `（锚点卡未生成，运行 plan-anchor.sh 生成）` 不报错 ⑤ 头部 --test 全链路（真实 stdin JSON + /tmp fixture，5 断言）⑥ 头注释/函数注释按 Rule 45 注明原因/时间/原行为；零新 config 键
- [16:32] 真实计划实跑暴露 C-1e 复刻态两缺陷并修复：① 自包含注释行（`<!-- WHAT... -->` 同行成对）被「只开不闭」吞成删到 EOF → 真实计划 Goal 误取「执行范围限制」表、Next Step 丢失；② 注释态内 ## 标题行被 continue 吞、不切节。修复 = 自包含注释行整体跳过 + ## 标题行恒切节（对齐 GNU sed 区间语义，闭合计划字节行为不变）
- [16:40] 附带静默：owner 读取改管道 + 外层 2>/dev/null（原 `tr < file 2>/dev/null` 缺文件时 shell 自身 stderr 报 "No such file"，首跑常态噪音；读语义不变）
- [16:45] --test PASS (5/5) rc=0；真实活跃计划注入复跑：Goal 多行全文（Rule 77/78/79 句）✓、R1-R5 全文 ✓、🔒 不变量行 ✓、Next Step/Current Phase/### Phase/Decisions(末3)/progress 尾5 既有字段全在场 ✓、BEGIN/END-PLAN-DATA + 数据非指令标记 ✓（/tmp/s2-real-out2.txt 留档）
- [16:50] 交叉验证：worktree 未跟踪 plan-anchor.sh 与主仓 S1 产出 byte-identical（S1 派发带入，非 S2 修改）；.rule-reservations.jsonl +3 行（rule 77/78/79 reserved）为规划期登记，非 S2 写入；selftest-registry.tsv 两行引用（L29 task-boundary / L59 drift-check）均为措辞锚 grep 检查对象，本次 diff 未改动被 grep 的锚串行，风险排除
- [16:55] 最终结论（status=done）

## 最终结论

status: done
acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation/skills/task-planner/scripts/zcode-userpromptsubmit.sh(+228/-81)
evidence: bash zcode-userpromptsubmit.sh --test → "[zcode-userpromptsubmit] --test PASS (5/5)" rc=0; 真实计划（cwd=主仓 plan 目录）hook 全链路 rc=0，输出含 "Goal: 为 task-planner 落地 Rule 77…"+R1-R5 全文+| 🔒 不变量 行+既有 5 字段（/tmp/s2-real-out2.txt）; git diff --numstat → 228/81
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v168-session-anchor-skill-activation/subagent-state/05-s2-userpromptsubmit.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
