# Verification Contract & Phase Gates

## Goal (1 sentence)

让 task-planner 设计期主动识别「共享内容维护」场景，接入 progress-tracker 技能（.zcode/ledger/ 多平台跟随）作为项目级认领追踪权威源（Rule 30），杜绝后期重复混乱。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 30.1-30.5 五子条已写入 critical-rules.md（识别/创建复用/认领登记/防冲突/机制，权威源=progress-tracker 账本）
  Evidence: `grep -n "^30\." ~/.zcode/skills/task-planner/references/critical-rules.md` → 5 条全命中
- [x] VC-2: SKILL.md 联动（Rules 1-30 摘要行 + Rule 30 摘要行 + 设计期检查点 + References 表 2 行）且 skill-collaboration.md 登记 progress-tracker 协同行
  Evidence: selftest ST-06/07/10 PASS；`grep -c "progress-tracker" references/skill-collaboration.md` ≥1
- [x] VC-3: selftest-shared-tracker.sh 新建（11 断言）并全量跑通
  Evidence: `bash scripts/selftest-shared-tracker.sh` → Total: 11 PASS=11 FAIL=0
- [x] VC-4: 3 实体位定向部署后 3 位 diff -r 一致 + 双仓 commit+push
  Evidence: diff -r 均 OK；canonical 760c2a3 / ~/.zcode bf43250 已 push origin
- [x] VC-5: 无回归破坏（全量 selftest 0 FAIL + 3-File Gate exit 0）
  Evidence: 全量 15 selftest 199 PASS/0 FAIL；check-3file-gate.sh exit 0

---

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 4 |
| 主进程直做 Phase 清单 | Phase 1-4（例外理由:②设计裁定+计划系统 / ⑥≤40 行文档脚本微调 / ③机械验证 / ①git 编排+簿记，全命中 Rule 25.3 白名单） |
| 委派率 | 0.0 < 0.7 → WHITELIST-EXEMPT |

## 质量门控统计（Rule 26）

| 触发 | 处置 |
|------|------|
| 无降质行为触发（双 selftest 破限即时修上限而非跳门控；拦截走 allow-direct 正规 bypass） | n/a |

## outcome

全部 VC 通过 → **COMPLETE**
