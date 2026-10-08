# task-v146 executor checkpoint (S9 守卫锚宽容化③)

## 状态: FINAL

## 任务摘要
修复 selftest-self-resolution.sh (SR-08) 和 selftest-execution-honesty.sh (EH-09) 的级联断言，
因 SKILL.md 索引括注从 40-55 演进到 40-61（Rule 61 落地）。

## 修改清单
- [x] selftest-self-resolution.sh: SR-08 正则 40-5[3-9] → 40-(5[3-9]|6[0-9])，bad 文案同步，追加级联注记，头部注释面同步
- [x] selftest-execution-honesty.sh: EH-09 正则 40-5[3-9] → 40-(5[3-9]|6[0-9])，ok/bad 文案同步，追加级联注记

## 验收标准
- 两脚本自跑 SR-08/EH-09 PASS
- FAIL 集合 = 各自基线
- diff 仅 2 文件
- 未 commit

## 进度
- [x] 检查点创建
- [ ] 读取目标文件
- [ ] 修改 selftest-self-resolution.sh
- [ ] 修改 selftest-execution-honesty.sh
- [ ] 自跑验证
- [ ] 检查点 FINAL
