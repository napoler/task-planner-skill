# P8-S1 Code Reviewer checkpoint — task-v096 Code Review Gate

date: 2026-09-29 | range: de8e8fe..ed8712d (7 files, +191/-2)

## verdict: CHANGES_REQUESTED（P1 x2 实证，同根一处修复）

## 已验证通过项
1. 零改动核实: critical-rules.md 仅 +1 行(34.7), 34.1-34.6 零字符; templates/ config.json plan-template-kit/references/ 均 diff 为空; PT-13 三锚(tier 分流 L191/variant 路由/mini-lite)保全, init-session.sh 纯追加 55 行 0 删除
2. SKILL.md 三处: 摘要行旧 L262→新 L263 子串逐字保全; C22 行首 `| C22 |` + 前半句(门控/逃生/机器门)逐字保留; 净增 1 行(429→430) ≤3
3. 34.7 条款: 三时点完整; 全自动合约与 34.5 自洽(双闸门内置生成侧+不沉淀理由收场); 计数级联+TL-17 在列; TL-17 现锚 16 个未动(未沉淀新 variant) — selftest-template-lifecycle 18/18 绿
4. general 机读注释声明真实: templates/task_plan.md 无三形态标记(实证), 纯 general 兜底产物确实过不了 check-template-type(attest 34.1 门 enforce 档拒锁), 区块注释使其 exit 0 — 改进声明成立
5. check-complete warn 段: 纯 echo >&2 无 exit, 退出码零变化; 正例(selftest case-5)/负例判定式验证
6. selftest-template-sense 6 断言全为行为级(真跑 init/check-complete 查产物), 非恒真; mktemp+trap 清理; registry 36=36, 新行 4 tab 字段
7. 全量 selftest: 36 脚本 TOTAL PASS=590 FAIL=0 — 行为不变判据成立

## 发现（P1）
- P1-1 mini 档误触发: P2-S1 条件 `[ -z "$TEMPLATE_TYPE" ] && [ -f task_plan.md ]` 缺 `TASK_PLAN_SRC=task_plan.md` 守卫(P2-S2 有, 同构不一致)。实测 tier=mini + 空类型 → mini-lite 产物 L1 mini-lite 标记后被追加 L47 `<!-- template_type: general -->` 双标记; 违反块内自声明正交性 + 破坏 mini-lite 38.3 区块白名单。当前 gate grep -m1 首行注释→mini-lite 胜出门控未坏, 但属脆弱耦合
- P1-2 已知类型重跑误触发: 实测 init proj bugfix 后二次 init proj(无类型参) → 向 bugfix 产物追加 general 区块(L152), 同产物双标记。幂等 grep 只防同区块重复不防此路径
- 修复(一处): P2-S1 条件补 `[ "$TASK_PLAN_SRC" = "task_plan.md" ]`; selftest 补 mini×sense 负例

## P2
- check-complete 排除式 `已沉淀` 三字面匹配过宽: 计划任意处出现该词(如提及"已沉淀 3 个 variant")即静默吞 warn, 边缘误抑制; warn 级低危
