# P4 checkpoint (executor sonnet-1, 2026-09-15)

## S1: init-session.sh env 兜底 + 动态派生白名单 — completed
- 改动: scripts/init-session.sh:55-80（TEMPLATE_TYPE 改 "${2:-${TASK_TEMPLATE_TYPE:-}}"；VALID_TYPES 改 general+ls variant/*-type.md 派生；删硬编码 12 类清单）
- 自测 (全 /tmp, 已清理):
  a. TASK_TEMPLATE_TYPE=bugfix → task_plan.md 首行 `<!-- template_type: bugfix -->`, exit 0, 路由日志 "Template routing: task_plan.md <- variant/bugfix-type.md" 命中
  b. TASK_TEMPLATE_TYPE=nonexistent → "WARNING: unknown template_type" 与 "Falling back to generic" 各 1 次, task_plan.md 回退 generic 模板, exit 0
  c. 无 env 无参数 → 无路由日志, generic 模板 (现状回归)
  d. bash -n 通过

## S2: selftest 双件新建 — completed
- 新建: scripts/selftest-reflect-verify.sh (57 行, RV-01~RV-09 共 9 条断言)
  - RV-01~07: critical-rules.md Rule 33 头 + 33.1~33.6 逐条锚(33.3 逐字 [reflect] 锚 / 33.4 ≤3 轮+Rule 22.3 / 33.5 notepad What Worked / 33.6 reflect_verify_enforce+REFLECT-GATE+selftest-reflect-verify)
  - RV-08: config.json jq 断言 reflect_verify_enforce default=warn + enum 三档
  - RV-09: check-complete.sh REFLECT-GATE 锚(gate 计数≥4 / TASK_PLANNER_REFLECT_VERIFY_ENFORCE / "- [reflect] " 计数锚 / SKIPPED 分支≥2)
  - 初跑 RV-04 FAIL 根因: critical-rules.md:276 正文以反引号包裹变体「- [reflect] 反思」, 无裸半角空格形式 → 锚定改为逐字 [reflect] 字样, 复跑 9/9 PASS
- 新建: scripts/selftest-template-lifecycle.sh (70 行, TL-01~TL-13 共 13 条断言)
  - TL-01~07: critical-rules.md Rule 34 头 + 34.1~34.6 逐条锚(34.2 三点同步 / 34.3 三条件 INDEX+ledger+点名 / 34.4 ≤100 行 / 34.5 查重防滥用 / 34.6 template_gate_enforce)
  - TL-08: config.json jq 断言 template_gate_enforce default=warn + enum 三档
  - TL-09~11: check-template-type.sh 动态派生(ls variant+general, 反证无硬编码副本) / attest 集成 check-template-type+--skip-template-check / init-session TASK_TEMPLATE_TYPE+ls variant(P4-S1 产出)
  - TL-12/13 行为级: mktemp /tmp/tl-selftest.XXX 造 template_type=bugfix → exit 0 PASS; nonexistent → exit 1 PASS; rm -rf 清理(ls 复核 tmp-cleaned)
- acceptance: `bash scripts/selftest-reflect-verify.sh` Total: 9 PASS=9 FAIL=0 exit 0; `bash scripts/selftest-template-lifecycle.sh` Total: 13 PASS=13 FAIL=0 exit 0

## S3: VT-10/EL-11 锚点修复 — completed
- grep -rn "Rules 1-3" scripts/*.sh 全库扫: 命中仅 2 文件 4 行(selftest-veto.sh:13,51 + selftest-error-loop.sh:14,59), 无其他隐含锚
- 改动: selftest-veto.sh:13,51 VT-10 → `grep -qE 'Rules 1-3[1-4]'`(label 改 Rules 1-3x); selftest-error-loop.sh:14,59 EL-11 → 同法(原 1-3[12] 已含 1-33/1-34, 规格要求统一为 1-3[1-4])
- 验证: SKILL.md:273 现含 "Rules 1-32" → 命中; P5 改为 "Rules 1-34" 后 `grep -qE 'Rules 1-3[1-4]'` 仍命中(两阶段间不回归 FAIL)
- acceptance: `bash scripts/selftest-veto.sh` Total: 13 PASS=13 FAIL=0 exit 0; `bash scripts/selftest-error-loop.sh` Total: 16 PASS=16 FAIL=0 exit 0
- 复核: grep -rn "Rules 1-3" scripts/*.sh 仅剩已修宽容锚 4 行; /tmp 无遗留; git status = 3 modified + 2 new(untracked), 无 commit

## 最终结论 (P4 S1→S2→S3 全部完成)
- S1 completed: init-session.sh:55-80 env 兜底(TASK_TEMPLATE_TYPE)+动态派生白名单(general+ls variant/*-type.md), 四自测全过(/tmp 已清理)
- S2 completed: selftest-reflect-verify.sh(57行,9断言)+selftest-template-lifecycle.sh(70行,13断言,含2行为级), 双 Total FAIL=0 exit 0
- S3 completed: VT-10/EL-11 宽容锚 1-3[1-4], 双 selftest PASS(13+16), 全库 grep 扫描无遗漏锚
- 工作区: worktree 内 git diff --stat = init-session.sh +17/-4 级, selftest-veto/error-loop 各 +2/-2, 2 新脚本 untracked; 未 commit(遵硬约束); 主仓零触碰
