# P8 复审 checkpoint — task-v096 CR fix-phase 复审

date: 2026-09-29 | 范围: ed8712d..79a82e2 (3 files +57/-6) | 前轮: P8-S1-code-reviewer.md (CHANGES_REQUESTED)

## verdict: APPROVED

## 逐条验证（前轮发现 → 修复）
- P1-1 mini 误触发 → 消除。init-session.sh L284-285 P2-S1 条件补 `! grep -q 'template_type:'`；mini-lite 产物首行有标记 → 不触发。沙箱实测(tier=mini+空类型): mini-lite标记=1 区块=0 general注释=0 sense输出=0
- P1-2 known-type 重跑误触发 → 消除。L316-318 P2-S2 同款守卫追加(来源守卫保留,双条件)。沙箱实测(bugfix 后空类型重跑): bugfix标记=1 区块=0 general注释=0
- P2 「已沉淀」无锚定字面量 → 消除。check-complete.sh L571 排除式删 `|已沉淀` 分支。实测: 未登记但正文提及「已沉淀 3 个 variant」→ 修复前 warn=0(被吞,git show ed8712d 版本复现) / 修复后 warn=1；有效登记(全角冒号) → warn=0 不误报
- 幂等去重共存: general 兜底重跑实测 区块=1(不翻倍) 注释=1 二次输出=0，守卫+幂等 grep 正交正确

## selftest
- selftest-template-sense: Total 8 PASS=8 FAIL=0 (case-7/8 新增)
- selftest-template-lifecycle: 18 PASS=18 FAIL=0
- selftest-plan-tier: 32 PASS=32 FAIL=0

## 用例咬合性(bite test, 旧脚本全树快照 shadow run)
- case-7 场景对 ed8712d 版 init: 区块=1 general注释=1 → 新 case-7 断言 0/0 能咬住
- case-8 场景对旧版: 区块=1 general注释=1 → 新 case-8 断言 0 能咬住
- case-7/8 均真跑 init 查产物, mktemp -d + trap cleanup, 零仓库写入

## 范围核查
- diff 仅 3 文件(check-complete/init-session/selftest-template-sense), bash -n 双脚本 OK, 工作区脚本 == 79a82e2(diff=0)
- 安全: 无新增注入面/网络/危险命令; 模板标记实证: mini-lite 首行有标记, templates/task_plan.md 0 标记(general 兜底正例仍触发), bugfix variant 1 标记

## 残留(不阻断, 超修复范围)
- 🟡 守卫 pattern 'template_type:' 未锚定行首/注释语法, 产物正文含该字样(如 v096 计划本身含 1 处)会抑制感知块; 后果 warn 级且下游 check-template-type 缺标记仍可见(fail-visible)。建议后续收紧为 `^<!-- template_type: `
- 💬 check-complete.sh L568 注释示例「不沉淀理由: 无沉淀价值」用半角冒号+空格(3a 20), 按正则不构成有效登记(正则要求冒号后紧跟非空白), 注释示例与语义自相矛盾; 旧版同语义非回归
