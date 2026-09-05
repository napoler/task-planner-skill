# Verification Contract & Phase Gates

## Goal (1 sentence)

plan-resume 升 v0.5:恢复触发点模型自主打分选任务并续推至完成(不再等用户抉择),task-planner 侧契约同步,全部验证通过后合并回 master。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: plan-resume SKILL.md 标识 v0.5,含自主推进两/三触发点与五守卫
  Evidence: `grep -c "v0.5" skills/plan-resume/SKILL.md` = 14;§6 决策路由 + §7.1 触发表 + §7.4 过滤表 + §7.5 推进纪律(守卫五条)Read 确认(worktree 42c31b7)
- [x] VC-2: 旧契约"仅报告不续推"不再是恢复场景的无例外规则
  Evidence: grep 三文件,唯一命中 = critical-rules.md:149 新 24.5 的"取代旧'只报告不续推'"注记本身;plan-resume SKILL.md 旧 L8 硬约束句已由双模式契约表替换
- [x] VC-3: Rule 24 重写与 SKILL.md 行为一致;24.3 事故句清除;扫描顺序统一"之前"
  Evidence: `grep "phase_status_map.*Unreleased" critical-rules.md` = 0 命中;critical-rules.md:143 与 SKILL.md:126 语义均为"DRIFT CHECK 之前"
- [x] VC-4: config.json 存在且被脚本读取;bash -n 全过;py_compile 过
  Evidence: select-and-resume.sh L29-56 config 加载(缺省兜底);bash -n ×4 OK;python3 -m py_compile score-plans.py OK(终验命令输出)
- [x] VC-5: smoke.sh 含 v0.5 用例且全绿
  Evidence: `bash tests/smoke.sh` → 总计 39/39 PASS,FAIL=0(含 config 兜底/skip_states 硬排除/默认自主标记/outside-repo 符号链接真实触发/--dry-run 覆盖)
- [x] VC-6: CHANGELOG 含 v0.4 补记 + v0.5 条目;README 同步
  Evidence: CHANGELOG.md [Unreleased] 新增段 3 条(v0.4 补记/v0.5 自主化/companion 原条目)+变更段 2 条+修复段 1 条;README.md 双模式契约段
- [x] VC-7: worktree 合并回 master,merge_back=merged(01061db);部署端核实;合并后 Read 复验
  Evidence: merge commit 01061db(git log);主仓 grep v0.5=14/Rule24 新标题 L143;部署端 diff -rq IDENTICAL×2(~/.agents 与 ~/.claude)

**终验规则**: 全部 VC 通过 → COMPLETE。

## 委派统计(Rule 25)

- 子代理执行 Phase:Phase 2 脚本改造(code-assistant×2 次派发) + Phase 4 测试翻修(code-assistant×2 次派发)= 2/5 Phase 含子代理执行
- 主进程直做清单(全部有登记例外理由):Phase 1 worktree 簿记(git 操作无可委派类型);Phase 2/3 .md 契约条款(Rule 14 纯文档白名单);Phase 4 CHANGELOG(纯文档);Phase 5 合并回约(主仓操作子代理无上下文)
- 子代理产出均已 Read/复跑复核:select-and-resume.sh 关键逻辑 grep + 沙箱功能复测;smoke 39/39 主进程亲自重跑

## 质量门控统计(Rule 26)

- V-N 全勾且 Evidence 非空 ✓;无 Handoff 未 verify 项 ✓
- Q1-Q6: 无跳步/无伪造证据/无批量降质;code_review Gate 代码文件 0 个(改动全为 .md/.sh/.json,按 Gate 过滤规则不在范围)→ 零范围 APPROVED
- 抽查 3 条 Evidence 可复现:VC-4/VC-5 命令均重跑确认

## Outcome

COMPLETE
