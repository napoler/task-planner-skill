#!/usr/bin/env bash
# selftest-split-pattern-library.sh — task-v150 S6: Rule 21.6 拆分模式库机器面静态守护
# 用法：bash scripts/selftest-split-pattern-library.sh（只读零写入，幂等可重复运行；SP-01..13 逐行 PASS/FAIL，
# 末行 Total，全 PASS exit 0 / 任一 FAIL exit 1）。范式对齐 selftest-media-dispatch.sh（同构骨架）。
# 守护面：库文件 11 模式/来源锚/低档贡献行/消费契约/未吸收登记/伴飞表路径 + critical-rules-dispatch 21.6.1-21.6.6 六子条 +
# 既有 21.1b/21.4/`### 22` 锚未破坏（36.5 纯增量）+ SKILL.md 接线（双文件各 ≥1）+ dispatch 模板 No-Placeholder 契约行。
# （[task-v171 2026-10-12] Rule 21/22 分层后归属 task-dispatch，critical-rules 断言目标=critical-rules-dispatch.md）

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# [task-v171 回归修复 2026-10-12 派发域搬迁] 现象: SP-01..SP-13 中 7 条 FAIL(库文件缺失连带计数全 0)｜
# 根因: split-pattern-library.md 随派发域迁至 skills/task-dispatch/references, 旧路径 $SKILL_ROOT/references 为空｜
# 修法: 改锚 $SKILL_ROOT/../task-dispatch/references/split-pattern-library.md(git 纯改名, P1-P12/伴飞表/来源锚原样)
LIB="$SKILL_ROOT/../task-dispatch/references/split-pattern-library.md"
# [task-v171 回归修复 2026-10-12 规则分层搬迁] 现象: SP-04..07 FAIL(21.6 子条/### 22 头/21.1b/21.4 关键句在核心已不存在)｜
# 根因: P7 核心瘦身后 Rule 21/22 归属 task-dispatch, 断言锚仍指核心 critical-rules.md｜
# 修法: CRIT 改指 CRIT_DP(task-dispatch/references/critical-rules-dispatch.md); SP-08 的 SKILL.md ≥3 接线随
#   S33 瘦身合并为单入口, 改双 SKILL.md 各 ≥1(task-planner 派发纪律指针行 + task-dispatch 卫星展开面)
CRIT_DP="$SKILL_ROOT/../task-dispatch/references/critical-rules-dispatch.md"
DP_SKILL="$SKILL_ROOT/../task-dispatch/SKILL.md"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
DISP="$SKILL_ROOT/templates/subagent_dispatch.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SP-%s FAIL %s\n' "$1" "$2"; }

# SP-01 库文件在位（21.6.1 消费面唯一载体，缺文件=拆分决策链断链）
if [ -f "$LIB" ]; then ok 01 "库文件在位"; else bad 01 "库文件缺失 $LIB"; fi

# SP-02 模式数 =12（P1-P12 设计契约冻结量；多=未冻结名混入，少=模式被裁）
# [2026-10-09 task-v153 级联单元] 模式数 11→12：task-v153 新增 P12（计划期并行分组调度）已冻结进设计契约，
# 库文件 split-pattern-library.md 现 P1-P12 共 12 模式；钉值同步递推（v151 级联先例：条款落地即钉值 +1）
n="$(grep -c '^### P' "$LIB" 2>/dev/null || true)"
if [ "$n" = "12" ]; then ok 02 "模式数 12（P1-P12）"; else bad 02 "模式数 $n（应 =12）"; fi

# SP-03 伴飞表 ≥6 数据行 且 表内 / 路径逐一 [ -f ]（21.6.5 消费面「≥6 行」契约；守卫不得严于契约；
# 路径失效=低档模型首动作 Read 即失败，机器锁死 kb §5⑤ 已验证路径，防漂移）
rows="$(awk '/^## 伴飞映射表/{f=1} f && /^\|/ && !/^\|-/' "$LIB" | grep -c '^|')"
miss=0; tot=0
while IFS= read -r p; do
  tot=$((tot+1)); [ -f "$p" ] || { miss=$((miss+1)); printf 'SP-03      路径缺失 %s\n' "$p"; }
done < <(awk '/^## 伴飞映射表/{f=1} f && /^\|/ && !/^\|-/' "$LIB" | grep -o '/[^ |)]*SKILL\.md' | sort -u)
if [ "$rows" -ge 6 ] && [ "$miss" = "0" ]; then
  ok 03 "伴飞表数据行 $rows ≥6 且路径 $tot 条全部存在（0 缺失）"
else
  bad 03 "伴飞表数据行 $rows（应 ≥6）或路径缺失 $miss/$tot 条"
fi

# SP-04 21.6.1-21.6.6 六子条锚 ≥6（条款本体；缺任一=拆分质量条款失守；[task-v171 2026-10-12] 目标=CRIT_DP）
n="$(grep -cE '21\.6\.[1-6]' "$CRIT_DP" 2>/dev/null || true)"
if [ "$n" -ge 6 ]; then ok 04 "21.6 子条锚(1-6) $n ≥6"; else bad 04 "21.6 子条锚(1-6) $n（应 ≥6）"; fi

# SP-05 `### 22` 结构锚仍在（21/22 分界；被误删=53.3 二分管辖失去边界依据；目标=CRIT_DP）
if grep -q '^### 22 子代理规模限制' "$CRIT_DP"; then ok 05 "结构锚 '### 22 子代理规模限制' 在位"; else bad 05 "结构锚 '### 22' 缺失（分界被破坏）"; fi

# SP-06 负断言：21.1b 关键句仍在（21.6 纯增量禁改 21.1-21.5 既有文本，锁步级三值上限条款本体；目标=CRIT_DP）
if grep -q '步级(S-unit)派发粒度上限' "$CRIT_DP"; then ok 06 "21.1b 关键句 '步级(S-unit)派发粒度上限' 在位"; else bad 06 "21.1b 关键句缺失（存量条款被破坏）"; fi

# SP-07 负断言：21.4 调度铁律关键句仍在（P0 铁律与 21.6 拆分面相邻，锁句防调度面非对称修改；目标=CRIT_DP）
if grep -q '子代理调度铁律' "$CRIT_DP"; then ok 07 "21.4 关键句 '子代理调度铁律' 在位"; else bad 07 "21.4 关键句缺失（调度铁律被破坏）"; fi

# SP-08 库引用双 SKILL.md 各 ≥1（[task-v171 2026-10-12] 原 ≥3 单文件四锚随 S33 瘦身合并）
# 旧形态: SKILL.md 内 ≥3 处 split-pattern-library 引用(S4 接线四锚)。S33 后核心 SKILL.md 仅留派发纪律指针 1 处
# 入口, 库的权威展开面归卫星 task-dispatch SKILL.md——等价守护=两文件各 ≥1(入口仍在+卫星有展开), <1 即断锚
n1="$(grep -c 'split-pattern-library' "$SKILLMD" 2>/dev/null || true)"
n2="$(grep -c 'split-pattern-library' "$DP_SKILL" 2>/dev/null || true)"
if [ "$n1" -ge 1 ] && [ "$n2" -ge 1 ]; then ok 08 "库引用 task-planner=$n1 + task-dispatch=$n2 各 ≥1"; else bad 08 "库引用断裂（task-planner=$n1 task-dispatch=$n2，应各 ≥1，S4 接线断锚）"; fi

# SP-09 dispatch 模板 No-Placeholder 契约行在位（21.6.4 任务书侧载体；被删=模板与 Rule 脱钩）
if grep -q 'No-Placeholder 契约' "$DISP"; then ok 09 "dispatch 模板 No-Placeholder 契约行在位"; else bad 09 "dispatch 模板 No-Placeholder 契约行缺失"; fi

# SP-10 来源锚 ≥10（每模式五要素之一，锁「池内实践非凭空新造」证据链，Rule 21.2 可追溯）
n="$(grep -c '来源' "$LIB" 2>/dev/null || true)"
if [ "$n" -ge 10 ]; then ok 10 "来源锚 $n ≥10"; else bad 10 "来源锚 $n（应 ≥10，来源证据链断裂）"; fi

# SP-11 低档模型贡献行 =12（/goal 锚定硬约束；<12=有模式退化为无贡献声明的泛化条目，任务动机失守）
# [2026-10-09 task-v153 级联单元] 11→12：P12 模式已冻结进库并带贡献声明行（SP-02 同源递推），硬约束钉值同步 +1
n="$(grep -c '对低档模型执行明确性的贡献' "$LIB" 2>/dev/null || true)"
if [ "$n" = "12" ]; then ok 11 "低档模型贡献行 12（每模式一行）"; else bad 11 "低档模型贡献行 $n（应 =12，硬约束）"; fi

# SP-12 消费契约段 + 未吸收登记段双锚（消费纪律库侧载体 + 53.3 管辖显式记录，缺=库边界/消费面失锚）
a="$(grep -c '^## 消费契约' "$LIB" 2>/dev/null || true)"
b="$(grep -c '^## 未吸收登记' "$LIB" 2>/dev/null || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 12 "消费契约段 + 未吸收登记段双锚在位"; else bad 12 "库段锚缺失（消费契约=$a 未吸收登记=$b）"; fi

# SP-13 （加分）库内 'Rule 21.6' 引用（库与 Rule 互为锚，防库被复制带走后与条款脱钩）
if grep -q 'Rule 21\.6' "$LIB"; then ok 13 "库内 'Rule 21.6' 引用在位"; else bad 13 "库内 'Rule 21.6' 引用缺失"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
