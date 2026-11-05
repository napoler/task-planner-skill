动作：修复 Rule 104 级联引起的两个 selftest 断言（仅改 worktree 内指定脚本）

修改：
- selftest-dual-qc.sh: DQ-08 纪元锚从 '1-103' 改为宽容窗 '1-1[0-9][0-9]'，'其余 86 条' 改为宽容窗 '其余 8[0-9] 条'，注释及输出文案同步；阈值（≥3/=2/=1）保持不变；行11尾追加演进注释
- selftest-batch-pilot.sh: BP-08 上限 275→285（比较值+文案两处），行63/行11 注释追加 Rule 104 结构性增量登记

两脚本输出原文：
DQ-01 PASS ^103.[1-8] 计数=8
DQ-02 PASS ### 103 段标题在位
DQ-03 PASS 同步完整性=4/核对清单=2/关联面=1
DQ-04 PASS 升一档=2/封顶=3/decision-arbiter=4
DQ-05 PASS 只读不改=1/不重做=1/输出精简=1
DQ-06 PASS 复检升档衔接（Rule 103.4）=1
DQ-07 PASS 衔接（Rule 103）=1/84.7.2 为其先例面=1
DQ-08 PASS 纪元窗=3/其余 8[0-9] 条=2/Rule 103 双轮质检与同步完整性域=1
DQ-09 PASS 3h 双轮质检（Rule 103）=1/103.6 同步核对清单=3
DQ-10 PASS 统一收口序列=1/含 user-session-log
DQ-11 PASS 双轮质检模板锚齐全/## 7. 返回格式在位
DQ-12 PASS 双轮质检声明区块/多文件变更集预判
DQ-13 PASS 22.4b 八字段契约保全（不得增删）=1
DQ-14 PASS registry 已登记 selftest-dual-qc
Total: 14 PASS=14 FAIL=0
---
selftest-dual-qc.sh exit: 0

BP-01 PASS 18.9 试点先行硬门
BP-02 PASS 18.10 单件失败禁批量（投毒红线）
BP-03 PASS 18.11 宁慢勿错
BP-04 PASS 18.1-18.11 编号连续各 1 次
BP-05 PASS SKILL.md 卫星路由表 task-discipline 行含 Rule 18（摘要行瘦身后由路由表承载）
BP-06 PASS batch-quality-gate §二表 18.9-18.11 三行
BP-07 PASS §八 试点先行硬门详解
BP-08 PASS SKILL.md 行数 280 ≤285
BP-09 PASS CD-19 宽容锚子串保护（隶属 Rules 1-36..1-77 全集宽容, 含 77）
BP-10 PASS CHANGELOG task-v083 条目
Total: 10 PASS=10 FAIL=0
---
selftest-batch-pilot.sh exit: 0
