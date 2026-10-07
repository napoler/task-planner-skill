# Subagent Checkpoint: sub:18-code-assistant (S18 CR 闭环收尾 P2-2/P2-3/P2-5 + FG 键级联)

## 8 字段结论

```
status: done
acceptance: 4/4 pass — [1:PASS 四脚本实跑 SG 23/23+analyze-splits rc 1/0 判据不变+dispatch 31/10/11 FAIL=0+final-gate-hash 22/22 FAIL=0] [2:PASS registry.tsv 本任务行「59.1-59.8 八子条」行内改写] [3:PASS SG 守护头注释+SG-02 断言+registry 三同步/FG 键级联注释齐备] [4:PASS git diff 本 S-unit 仅 5 目标文件]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v144/skills/task-planner/scripts/selftest-subagent-granularity-skill-escort.sh(+7/-5); .../scripts/selftest-registry.tsv(+1/-1); .../scripts/analyze-splits.sh(+3/-1); .../scripts/check-dispatch.sh(+4/-0); .../scripts/selftest-final-gate-hash.sh(+5/-2)
evidence: selftest-subagent-granularity-skill-escort.sh→`Total: 23 PASS=23 FAIL=0`(SG-02 八子条=8 过); analyze-splits.sh 双 fixture→超限 3f/150l/20min rc=1「拆成 2 个子单元」/合规 1f/45l/10min rc=0; selftest-dispatch.sh→`Total: 31 PASS=31 FAIL=0`、selftest-dispatch-grain.sh→`Total: 10 PASS=10 FAIL=0`、selftest-fine-grain-steps.sh→`Total: 11 PASS=11 FAIL=0`; selftest-final-gate-hash.sh→`PASS=22 FAIL=0`(原 PASS=21 FAIL=1); git diff 本 S-unit 5 文件逐一核过, 其余 M 文件=前序 S17 产物
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v144/subagent-state/18-code-assistant.md (status: done)
findings_written: #### [sub:18-code-assistant] CR 闭环收尾四项（findings.md 段末追加）; progress.md Phase 3「Actions taken」下追加 [sub:18]
blockers: none
confidence: HIGH
```

## 逐项明细

1. **P2-2 八子条统一**：SG-02 断言 `^59\.[1-7] `=7 → `^59\.[1-8] `=8（59.8 关系澄清子条对齐 58.8/60.7 惯例入守护）；SG-04..SG-10 保持前七条字面锚，59.8 由 SG-02 行首计数覆盖（与 58.8 同范式不加独立字面断言）；registry.tsv :57 行 trigger 列行内改写。三同步=头注释 L8-10+断言 L71-76+registry。
2. **P2-3 注释修正**：analyze-splits.sh :148 原注「缺段按 0 计——部分填报也体检已报值」与实现相反（regex 三段不命中→SKIPPED 放行不计违规，与头注释口径一致）→ 改正+级联注释。
3. **P2-5 local 卫生**：check-dispatch.sh fine_grain_checks 顶部 local 补 fmax lmax mmax gtok gfv grange gl gm esrcs er epath p（⑥⑦ 新增变量，原泄漏外层变量域；行为零变化，grep 核实无 raw/g1/g2/g3/over/kk 之类——那些属 analyze-splits.sh 不属本函数）。
4. **FG 键级联**：selftest-final-gate-hash.sh 键④枚举五键→六键补 subagent.step_max_lines（S17 check-plan-dispatch :128-129 ⑤-c 新消费），头注释 L16 同步五键→六键+级联注释；实跑 FAIL=1→FAIL=0（PASS=21→22）。

## 负结果

- git diff 本 S-unit 仅 5 目标文件；worktree 其余 M 文件（SKILL.md/critical-rules.md/check-plan-dispatch.sh）=前序 S17 既有产物零触碰
- periodic-review PR×4 登记遗留未触碰（禁修面）
- 未 git add/commit
