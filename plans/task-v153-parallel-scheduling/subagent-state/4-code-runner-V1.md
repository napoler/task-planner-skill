# 4-code-runner-V1（回归单元）检查点 — 全量 selftest 回归

- 时间: 2026-10-10 00:5x（本会话）
- 范围: worktree `/mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling/skills/task-planner/scripts/` 全量 `selftest-*.sh`（65 个，含新增 selftest-parallel-scheduling.sh）
- 跑批方式: cd 技能根后逐脚本 `bash <script>` 执行（单脚本 timeout=240s），rc 与完整 stdout/stderr 原文落盘
- 日志: `/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/regression-v1.log`（1229 行→追加汇总段，含 `===== <script> rc=N =====` 分段全文 + 逐脚本汇总段）
- 逐脚本行数据: 全 65 行已回贴主进程返回消息（数据源 /tmp/v153-v1-summary.txt，会话内机械生成）

## 结果（机械求和）

- 总计: N=65, rc=0 → 58, rc≠0 → 7, ΣFAIL=9
- 新增脚本行: `scripts/selftest-parallel-scheduling.sh rc=0 | Total: 9 PASS=9 FAIL=0`
- 对照基线（/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/baseline-selftest.log，64 脚本全 rc=0）差异 rc≠0 行共 7（全部 FAIL>0，基线无此类行）:
  1. `selftest-lane-advancement.sh rc=1 | Total: 14 PASS=13 FAIL=1`（LA-12）
  2. `selftest-requirement-coverage.sh rc=1 | Total: 23 PASS=22 FAIL=1`（RC-11）
  3. `selftest-research-first.sh rc=1 | Total: 12 PASS=10 FAIL=2`（RF-06/RF-07）
  4. `selftest-root-resolution.sh rc=1 | Total: 17 PASS=16 FAIL=1`（RR-09）
  5. `selftest-self-resolution.sh rc=1 | Total: 13 PASS=12 FAIL=1`（SR-07）
  6. `selftest-split-pattern-library.sh rc=1 | Total: 13 PASS=11 FAIL=2`（SP-02/SP-11）
  7. `selftest-tool-selection.sh rc=1 | Total: 12 PASS=11 FAIL=1`（TS-05）
- 其他行差异: `selftest-registry.sh` 原文由 `(registry rows=64, actual selftest=64)` → `(registry rows=65, actual selftest=65)`（新增脚本登记后预期内 +1）

## 根因（实测验证，置信度 HIGH）

- 工作树 Phase 3 提交（5c5b3f6）把 SKILL.md 计数锚 `1-66` → `1-68`，且词组序由「Critical Rules 全集 1-66」变为「Critical Rules 1-68 全集」：
  - `grep -c 'Critical Rules 1-66' SKILL.md` = 0（工作树实测；1-68 计数=3）→ 断言仍钉 `1-66` 的 5 脚本 FAIL（LA-12 / RC-11 / RF-06+RF-07 / SR-07 / TS-05 同源）
  - 宽容正则 `Critical Rules 全集 1-(5[3-9]|6[0-9])` 因「全集」位移命中=0 → RR-09 FAIL（selftest-root-resolution.sh:99-115 断言原文）
- 模式库新增 P12（split-pattern-library.md:110）使 `grep -c '^### P'`=12（钉值 =11）与低档模型贡献行=12（钉值 =11）→ SP-02/SP-11 FAIL（selftest-split-pattern-library.sh:24-26,65-67）
- 先例证据: 前一规则任务（v151）对同批脚本做过「钉值级联 '1-65'→'1-66'」（selftest-lane-advancement.sh:131 注释原文），其 final-regression.log 同批脚本全 rc=0；本工作树未做对应重钉
- 环境排除: 被检文件按 SCRIPT_DIR 相对解析（selftest-research-first.sh:35-41 原文），确认读的是工作树副本；非路径/环境误报

## 结论与移交

- R3「零新增失败硬门」当前未达：相对基线新增 7 个 rc≠0 脚本（ΣFAIL=9）；新增脚本本身通过、其余 58 脚本与基线一致。
- 处置建议（交主进程裁决）: 老测试钉值重钉需修改 worktree 内文件，本回归单元按组域写隔离禁止修改，仅报告。可选路径: ① 派新执行单元在 worktree 重钉该 7 脚本（走钉值级联先例口径）后重跑本回归 ② 合并面统一处理。
