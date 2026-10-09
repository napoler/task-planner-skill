## 检查点：selftest 单元（parallel-group 守卫组）

### 里程碑 1：现状勘查完成（worktree 实测）
- critical-rules.md：`### 68` 标题=1，`^68\.[1-7] ` 七子条=7 → T1/T2 锚已就绪
- templates/task_plan.md:279 S-unit 表头含「前置依赖」列 → T3 锚已就绪
- SKILL.md：C46 行=1（:220），Rule 68 引用=5，「Critical Rules 1-68」上界与 critical-rules 实测最大编号 68 一致 → T5 锚已就绪
- check-plan-dispatch.sh：Rule 68 校验段尚未在位（守卫单元并行施工中）→ T4 采用「硬锚在位则硬断言 / 未落位则 WARN-SOFT 降级、不计 FAIL」双层口径
- split-pattern-library.md：P12「依赖分批并行」尚未在位（文档单元并行施工中）→ T9 同双层口径
- registry 现 65 行，追加本脚本行后 =66
- 决策：自跑 exit 判定只认核心断言 FAIL；T4/T9 软降级不影响 exit，锚落位后下次运行自动升硬

### 里程碑 2：selftest 脚本实装完成
- 新建 scripts/selftest-parallel-scheduling.sh（150 行，P-01..P-09 九断言，形态对齐邻族 G-01..09：assert/计数/exit 语义、SCRIPT_DIR 相对路径解析、Total 行）
- 双层口径：P-04（守卫段三锚）/P-09（P12 双锚）——锚在位则硬断言、未落位 SOFT 不计 FAIL（双轨施工窗口期设计，落位后自动升硬）
- 计数锚全部动态求值（P-05 上界对照 critical-rules 实测最大编号 68；禁硬编码当前态，§4 易错点 1）
- T 清单映射：T1=P-01 / T2=P-02 / T3=P-03 / T4=P-04 / T5=P-05 / T6=P-06 / T7=P-07 / T8=P-08 / T9=P-09

### 里程碑 3：registry 行追加
- selftest-registry.tsv 末尾追加 1 行（4 列 tab 分隔，script/domain/trigger_scenarios/dep_anchors 对齐既有行；dep 锚 7 项）；行数 65→66（含表头）

### 里程碑 4：自跑通过（worktree 实测）
- `bash scripts/selftest-parallel-scheduling.sh` exit=0，Total: 9 PASS=7 FAIL=0（P-04/P-09 SOFT——守卫单元与文档单元并行施工中未落位，符合双轨预期）
- `bash scripts/selftest-registry.sh` exit=0：registry rows=65, actual selftest=65（registry 行计数口径=数据行 65，含本单元新行；selftest 脚本总数 65 含本脚本）
- 负结果报告：检查了 critical-rules/templates/SKILL/config/registry/check-plan-dispatch/split-pattern-library 七处依赖锚；未发现冲突（P-07 零新键 grep 0 命中实测）；排除风险：P-05 上界动态对照吸收 v152 Rule 67 级联漂移、P-08 锁定 21.4 不回退

### 里程碑 5：最终验收实测 + 修正记录
- 守卫单元已落盘 check-plan-dispatch.sh（Rule 68 校验段 9 锚 + hard 依赖-同组串 4 + advisory 组内全同串 2）→ P-04 自动升硬 PASS；仅 P-09（文档单元 P12）保持 SOFT
- 最终自跑：Total: 9 PASS=8 FAIL=0，exit=0
- registry 自校验（worktree 含本单元+守卫单元全部落盘后）：rows=65, actual selftest=65，双向一致 exit=0
- 勘误（主进程回填参考）：任务书指示「registry 行数=65」基于勘查初期计数（漏表头 1 行 + 未计本单元新增），以 worktree 实测口径为准：registry 数据行=65、selftest 脚本=65（含 selftest-parallel-scheduling.sh 本体），双向一致
- diff --stat master scripts/ 现含 3 文件：check-plan-dispatch.sh（守卫单元产物，+163 行，非本单元 scope）/ selftest-registry.tsv（本单元 +1 行）/ selftest-parallel-scheduling.sh（本单元新建 152 行，untracked 故不入 diff）——本单元 scope 严格 2 文件，无越界
