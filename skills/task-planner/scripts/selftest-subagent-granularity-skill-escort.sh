#!/usr/bin/env bash
# selftest-subagent-granularity-skill-escort.sh — task-v144: Rule 59「子代理拆分粒度硬门与技能伴飞纪律」静态守护（59.6 机制锚自写机器面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v144 全链落点在位（对齐 selftest-iteration-persistence.sh / selftest-capability-persistence.sh 范式），
#   共 23 条编号断言 SG-01..SG-23：
#     · critical-rules.md（Rule 59 条款本体，SG-01..SG-11）:
#         SG-01 `^### 59 ` 标题=1；SG-02 `^59\.[1-7] ` 七子条=7；SG-03 块首说明含 task-v144（来源任务锚）
#         SG-04..SG-10 七子条字面锚各 =1（59.1 粒度三值硬门 / 59.2 技能伴飞 / 59.3 执行前技能扫描 / 59.4 能力预防判据 / 59.5 分段执行锚 / 59.6 机制守护 / 59.7 零新 config 键）
#         SG-11 59.3 行双语义锚「可用强化技能」∧「仅提示用户可手动激活」各 ≥1（R5 用户触发型技能设计语义核心）
#     · templates/task_plan.md（S-unit 表双列 + 契约注释，SG-12..SG-14）:
#         SG-12 S-unit 表表头行「粒度(三值)」=1（行锚定，契约注释行另有同字面不误计数）；SG-13 表头行「伴飞技能」=1（同上，59.1/59.2 计划侧机器载体）
#         SG-14 `enforce` ≥2（契约注释 ①②③ 行 enforce 档语义锁定）
#     · templates/knowledge-brief.md（技能扫描载体，SG-15）:
#         SG-15 「§6 可用强化技能清单」段锚 =1（59.3 扫描结果的落盘出口）
#     · templates/subagent_dispatch.md（任务书侧，SG-16..SG-17）:
#         SG-16 「### 伴飞技能」子节锚 =1（59.2 派发侧注入载体）
#         SG-17 「九字段」锚 ≥1（22.4 既有字段面未被 59.2 注入顺手破坏）
#     · scripts/check-dispatch.sh（enforce 硬门机器面，SG-18..SG-19）:
#         SG-18 「Rule 59.1 粒度三值硬门」提示串 ≥1（超限拒锁语义）
#         SG-19 「Rule 59.2 伴飞路径不存在」提示串 ≥1（伴飞路径存在性校验语义）
#     · scripts/analyze-splits.sh（拆分体检机器面，SG-20）:
#         SG-20 文件在位且可执行（59.6 机器面双脚本之一）
#     · config.json（零新键声明，SG-21）:
#         SG-21 `granularity|skill_escort|escort_skill` 键字面 =0（59.7 零新 config 键声明的机器佐证）
#     · 脚本自身（SG-22/SG-23）:
#         SG-22 SCRIPT_DIR 自定位行在位（仓库/worktree/三宿主部署位三处可跑结构锚）
#         SG-23 头注释 What+Why 齐备（Rule 45 双层注释）
#   运行方式：`bash scripts/selftest-subagent-granularity-skill-escort.sh`（只读 grep/test，零写入）；
#   逐行打印 `SG-NN PASS/FAIL <说明>`，末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析（`$SKILL_ROOT/references/...`、`$SKILL_ROOT/templates/...`、
#   `$SCRIPT_DIR/check-dispatch.sh`、`$SCRIPT_DIR/analyze-splits.sh`、`$SKILL_ROOT/config.json`），
#   保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 59.6 机制锚，task-v144 2026-10-08）:
#   用户 R1-R6 核心诉求（需求锚 R6：「总之就是存在严重的缺陷 子代理拆分细致拆分 以及 任务分段执行」）=
#   计划期粒度三值 enforce 硬门 + 派发侧技能伴飞注入 + 执行前技能扫描 + 能力预防判据 + 分段执行锚。
#   Rule 59 主体是 LLM 行为面条款，若条款锚/模板双列/伴飞子节/check-dispatch enforce 提示串被后续裁剪误删，
#   条款即变死文（53.2 零载体判例反向清账）；本脚本=条款死文探测器，锚丢即 FAIL 报警。
#   断言口径=只锁 59 新增锚 + 既有锚（九字段）防破坏（Rule 36.5 纯增量，防锚级联 55.6 同范式）；
#   SG-21 负断言锁 59.7 零新键声明与 config 面一致（键膨胀=配置面失控面）。
# 依赖：bash + grep。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# SKILL_ROOT 支持 env 覆盖（SG_SKILL_ROOT）：负断言自测时指向临时破坏副本目录，worktree 本体零触碰；默认=脚本上级目录
SKILL_ROOT="${SG_SKILL_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CRIT="$SKILL_ROOT/references/critical-rules.md"
TPLAN="$SKILL_ROOT/templates/task_plan.md"
KBRIEF="$SKILL_ROOT/templates/knowledge-brief.md"
DISP="$SKILL_ROOT/templates/subagent_dispatch.md"
CHK="$SCRIPT_DIR/check-dispatch.sh"
ASPL="$SCRIPT_DIR/analyze-splits.sh"
CONFIG="$SKILL_ROOT/config.json"
SELF="$SCRIPT_DIR/selftest-subagent-granularity-skill-escort.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SG-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SG-%s FAIL %s\n' "$1" "$2"; }

# 提取某子条行（行首 `59.N ` 去前缀后的单行文本），供语义锚 grep
line59() { sed -n "s/^59\.$1 //p" "$CRIT" | head -1; }

# SG-01 critical-rules.md `^### 59 ` 标题行计数=1
# What：断言 Rule 59 章节标题唯一。
# Why：标题行是章节识别锚；=1 保证未被重复插入（尾脏写）也未被误删（条款失主）。
n="$(grep -cE '^### 59 ' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md '### 59 ' 标题锚 =1"; else bad 01 "critical-rules.md '### 59 ' 计数=$n（应 =1）"; fi

# SG-02 critical-rules.md `^59\.[1-7] ` 七子条计数=7
# What：断言 59.1-59.7 七条子条主体行（行首 `59.N `）全在位。
# Why：七子条是 59 全部语义（硬门/伴飞/扫描/预防/分段/机制/零新键）的唯一文本落点；缺任一条 = 条款本体被裁剪。
n="$(grep -cE '^59\.[1-7] ' "$CRIT" || true)"
if [ "$n" -eq 7 ]; then ok 02 "critical-rules.md '59.x ' 七子条锚 =7"; else bad 02 "critical-rules.md '59.x ' 计数=$n（应 =7）"; fi

# SG-03 Rule 59 块首说明行含 task-v144（来源任务锚）
# What：断言 `### 59 ` 标题行正文含来源任务代号 `task-v144`。
# Why：条款需可溯源（Rule 20.6 编号账本）；缺 task 代号 = 条款失去来源登记，回归期无法对账。
if grep -E '^### 59 ' "$CRIT" | grep -q 'task-v144'; then
  ok 03 "Rule 59 块首说明行含 task-v144"
else
  bad 03 "Rule 59 块首说明行缺 task-v144 来源锚"
fi

# SG-04 59.1 子条锚 =1（粒度三值硬门）
# What：断言 `59.1 **粒度三值硬门` 字面锚恰 1 处。
# Why：59.1 是用户 R1/R3/R6「拆分细致」的计划期机器落地载体——锚丢=三值硬门无条款依据。
n="$(grep -cF '59.1 **粒度三值硬门' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 04 "critical-rules.md 59.1「粒度三值硬门」=1"; else bad 04 "critical-rules.md 59.1 锚命中=$n（应 =1）"; fi

# SG-05 59.1 行含 `enforce` ≥1（硬门档位语义锚）
# What：断言 59.1 行内出现 `enforce` 档位词。
# Why：59.1 核心=SKIPPED 提示升级为 enforce 硬阻断；行内 lose enforce 字样 = 档位升级语义被裁（提示档回退风险）。
n="$(line59 1 | grep -cF 'enforce' || true)"
if [ "$n" -ge 1 ]; then ok 05 "critical-rules.md 59.1 行含 'enforce'（$n）"; else bad 05 "critical-rules.md 59.1 行缺 'enforce'（档位升级语义被裁）"; fi

# SG-06 59.2 子条锚 =1（技能伴飞）
# What：断言 `59.2 **技能伴飞` 字面锚恰 1 处。
# Why：59.2 是用户 R2「单个子代理不具备skill」的注入机制载体——锚丢=伴飞纪律无条款依据。
n="$(grep -cF '59.2 **技能伴飞' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 06 "critical-rules.md 59.2「技能伴飞」=1"; else bad 06 "critical-rules.md 59.2 锚命中=$n（应 =1）"; fi

# SG-07 59.2 行含 `首动作 Read` ≥1（注入形态语义锚）
# What：断言 59.2 行内出现 `首动作 Read`。
# Why：59.2 规定伴飞注入形态=「路径+首动作 Read」（工具面事实：仅 3 agent 有 Skill 工具，Read 全量具备）；
#      该字样丢失 = 注入路径机制被改写（如误改为依赖 Skill 工具），与工具面事实脱钩。
n="$(line59 2 | grep -cF '首动作 Read' || true)"
if [ "$n" -ge 1 ]; then ok 07 "critical-rules.md 59.2 行含 '首动作 Read'（$n）"; else bad 07 "critical-rules.md 59.2 行缺 '首动作 Read'（注入形态语义被裁）"; fi

# SG-08 59.3 子条锚 =1（执行前技能扫描）
# What：断言 `59.3 **执行前技能扫描` 字面锚恰 1 处。
# Why：59.3 是用户 R5「技能库 200+ 从未被扫描激活」的治理载体——锚丢=计划期技能选型无落点。
n="$(grep -cF '59.3 **执行前技能扫描' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 08 "critical-rules.md 59.3「执行前技能扫描」=1"; else bad 08 "critical-rules.md 59.3 锚命中=$n（应 =1）"; fi

# SG-09 59.4 子条锚 =1 且行含 `先拆细再派`（能力预防判据）
# What：断言 `59.4 **能力预防判据` 字面锚 =1，且 59.4 行含 `先拆细再派`。
# Why：59.4 是用户 R4「模型能力不够无法正确运行」的计划期预防载体——22.3 理念前移的唯一措辞落点，
#      缺「先拆细再派」= 预防语义回退为执行后兜底（22.3 原态）。
a="$(grep -cF '59.4 **能力预防判据' "$CRIT" || true)"
b="$(line59 4 | grep -cF '先拆细再派' || true)"
if [ "$a" -eq 1 ] && [ "$b" -ge 1 ]; then ok 09 "critical-rules.md 59.4「能力预防判据」=1 且行含 '先拆细再派'"; else bad 09 "critical-rules.md 59.4 锚=$a（应=1）/ '先拆细再派'=$b（应≥1）"; fi

# SG-10 59.5 子条锚 =1 且行含 `分段`（分段执行锚）
# What：断言 `59.5 **分段执行锚` 字面锚 =1，且 59.5 行含 `分段`。
# Why：59.5 是需求锚 R6「任务分段执行」的直接载体——标题锚已锁、正文「分段」语义再锁一次（防正文裁空壳）。
a="$(grep -cF '59.5 **分段执行锚' "$CRIT" || true)"
b="$(line59 5 | grep -cF '分段' || true)"
if [ "$a" -eq 1 ] && [ "$b" -ge 1 ]; then ok 10 "critical-rules.md 59.5「分段执行锚」=1 且行含 '分段'（$b）"; else bad 10 "critical-rules.md 59.5 锚=$a（应=1）/ '分段'=$b（应≥1）"; fi

# SG-11 59.3 行双语义锚：`可用强化技能` ∧ `仅提示用户可手动激活` 各 ≥1
# What：断言 59.3 行内两个关键短语均在位。
# Why：前者=59.3 扫描结果区块名（与 knowledge-brief §6 段名同字面，SG-15 锁载体侧）；后者=用户触发型技能
#      （disable-model-invocation）设计语义的显式禁令（59.3 尾句），缺 = 主进程越权代激活禁令无落点。
a="$(line59 3 | grep -cF '可用强化技能' || true)"
b="$(line59 3 | grep -cF '仅提示用户可手动激活' || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 11 "critical-rules.md 59.3 行含 '可用强化技能'($a) ∧ '仅提示用户可手动激活'($b)"; else bad 11 "critical-rules.md 59.3 行 可用强化技能=$a / 仅提示用户可手动激活=$b（各应 ≥1）"; fi

# SG-12 templates/task_plan.md S-unit 表表头行「粒度(三值)」=1（59.1 计划侧机器载体）
# What：断言 task_plan.md S-unit 表表头行（行首 `| ID `）含 `粒度(三值)` 恰 1 处（行锚定，防契约注释行同字面误计数）。
# Why：三值列是 analyze-splits.sh / check-dispatch.sh enforce 门的机器输入列——表头丢列 = 硬门无数据源（守门形同虚设）。
n="$(grep -cE '^\| ID .*\| 粒度\(三值\) \|' "$TPLAN" || true)"
if [ "$n" -eq 1 ]; then ok 12 "templates/task_plan.md 表头行「粒度(三值)」=1"; else bad 12 "templates/task_plan.md 表头行「粒度(三值)」计数=$n（应 =1）"; fi

# SG-13 templates/task_plan.md S-unit 表表头行「伴飞技能」=1（59.2 计划侧机器载体）
# What：断言 task_plan.md S-unit 表表头行（行首 `| ID `）含 `伴飞技能` 恰 1 处（行锚定：契约注释行另有同字面，全文裸计数=2 属预期）。
# Why：伴飞列是任务书 §2 注入 + check-dispatch.sh ⑦ 路径校验的数据源列——表头丢列 = 伴飞注入链断头。
n="$(grep -cE '^\| ID .*粒度\(三值\) \| 伴飞技能 \|' "$TPLAN" || true)"
if [ "$n" -eq 1 ]; then ok 13 "templates/task_plan.md 表头行「伴飞技能」（紧随粒度列）=1"; else bad 13 "templates/task_plan.md 表头行「伴飞技能」计数=$n（应 =1）"; fi

# SG-14 templates/task_plan.md `enforce` ≥2（契约注释档位语义）
# What：断言 task_plan.md 中 `enforce` 出现 ≥2 次（契约注释 ①预估时长超限 / ②输入 token 超限 行）。
# Why：契约注释是 S-unit 填写侧的档位提示（超限=enforce 档硬阻断拒锁回炉重拆）；<2 = 填写侧档位提示被裁，
#      作者面与脚本面（check-dispatch enforce）脱钩。
n="$(grep -c 'enforce' "$TPLAN" || true)"
if [ "$n" -ge 2 ]; then ok 14 "templates/task_plan.md 'enforce' 计数 $n ≥2"; else bad 14 "templates/task_plan.md 'enforce' 计数=$n（应 ≥2，档位提示被裁）"; fi

# SG-15 templates/knowledge-brief.md 「§6 可用强化技能清单」段锚 =1
# What：断言 knowledge-brief.md 含 `§6 可用强化技能清单` 段标题恰 1 处。
# Why：59.3 扫描结果（技能名/路径/匹配点/激活方式四列区块）的落盘出口=该段；段丢 = 扫描无载体（条款死文变体），
#     且 S-unit 伴飞列失去取值源。与 SG-11 前半「可用强化技能」字面同语义双锁（定义在 critical-rules，载体在模板）。
n="$(grep -cF '§6 可用强化技能清单' "$KBRIEF" || true)"
if [ "$n" -eq 1 ]; then ok 15 "templates/knowledge-brief.md「§6 可用强化技能清单」=1"; else bad 15 "templates/knowledge-brief.md「§6 可用强化技能清单」计数=$n（应 =1）"; fi

# SG-16 templates/subagent_dispatch.md 「### 伴飞技能」子节锚 =1
# What：断言 subagent_dispatch.md 含 `### 伴飞技能` 子节标题恰 1 处。
# Why：59.2 派发侧注入载体=任务书该子节（取值规则/注入格式/首动作 Read 三行）；子节丢 = 任务书无伴飞字段（R2 回归）。
n="$(grep -cF '### 伴飞技能' "$DISP" || true)"
if [ "$n" -eq 1 ]; then ok 16 "templates/subagent_dispatch.md「### 伴飞技能」子节=1"; else bad 16 "templates/subagent_dispatch.md「### 伴飞技能」计数=$n（应 =1）"; fi

# SG-17 templates/subagent_dispatch.md 「九字段」≥1（22.4 既有字段面防破坏）
# What：断言 subagent_dispatch.md 中 `九字段` 出现 ≥1 次。
# Why：59.2 伴飞子节是 22.4 九字段任务书的增量扩展而非替代；既有「九字段」字样丢失 = 改写者顺手删改了
#     22.4 原有字段面（超 59 范围的越界改动信号，Rule 36.5 纯增量反证锚）。
n="$(grep -cF '九字段' "$DISP" || true)"
if [ "$n" -ge 1 ]; then ok 17 "templates/subagent_dispatch.md「九字段」计数 $n ≥1（既有 22.4 面未被破坏）"; else bad 17 "templates/subagent_dispatch.md「九字段」计数=0（22.4 既有字段面被顺手改动）"; fi

# SG-18 scripts/check-dispatch.sh 「Rule 59.1 粒度三值硬门」提示串 ≥1
# What：断言 check-dispatch.sh 含超限提示串 `Rule 59.1 粒度三值硬门` ≥1 次。
# Why：该提示串是 enforce 档超限拒锁的行为证据（grep 提示串=锁行为非锁注释）；丢失 = 三值检测分支被裁（守门失效）。
n="$(grep -cF 'Rule 59.1 粒度三值硬门' "$CHK" || true)"
if [ "$n" -ge 1 ]; then ok 18 "scripts/check-dispatch.sh「Rule 59.1 粒度三值硬门」提示串 $n ≥1"; else bad 18 "scripts/check-dispatch.sh「Rule 59.1 粒度三值硬门」=0（enforce 三值检测分支被裁）"; fi

# SG-19 scripts/check-dispatch.sh 「Rule 59.2 伴飞路径不存在」提示串 ≥1
# What：断言 check-dispatch.sh 含伴飞路径缺失提示串 `Rule 59.2 伴飞路径不存在` ≥1 次。
# Why：该提示串是 ⑦ 伴飞路径存在性校验的行为证据；丢失 = 伴飞路径校验分支被裁（子代理首动作 Read 将静默失败）。
n="$(grep -cF 'Rule 59.2 伴飞路径不存在' "$CHK" || true)"
if [ "$n" -ge 1 ]; then ok 19 "scripts/check-dispatch.sh「Rule 59.2 伴飞路径不存在」提示串 $n ≥1"; else bad 19 "scripts/check-dispatch.sh「Rule 59.2 伴飞路径不存在」=0（伴飞路径校验分支被裁）"; fi

# SG-20 scripts/analyze-splits.sh 在位且可执行（59.6 拆分体检机器面）
# What：断言 analyze-splits.sh 文件存在且含可执行权限位。
# Why：59.6 机器面双脚本之一（读 S-unit 表三值列输出超限拆分建议）；文件丢或权限位丢（chmod -x）= 体检链断。
if [ -x "$ASPL" ]; then
  ok 20 "scripts/analyze-splits.sh 在位且可执行"
else
  bad 20 "scripts/analyze-splits.sh 缺失或不可执行（59.6 机器面断）"
fi

# SG-21 config.json 零新键负断言：`granularity|skill_escort|escort_skill` 键字面 =0
# What：断言 config.json 不含 59 体系候选键字面。
# Why：59.7 声明「零新 config 键」（与 43.4/46.5/54.6/55.6 同范式）——若有人给 59 加开关键即范式回退
#      （判定面主体=LLM 行为+模板字段，无需机器键）；口径锁 59 专属候选键字面，防未来合法他键子串误伤（v127 判例）。
n="$(grep -cE 'granularity|skill_escort|escort_skill' "$CONFIG" || true)"
if [ "$n" -eq 0 ]; then ok 21 "config.json 零新键：59 候选键字面命中=0（59.7 零 config 键声明成立）"; else bad 21 "config.json 59 候选键字面命中=$n（应 =0，59.7 零新键声明被破）"; fi

# SG-22 脚本自身 SCRIPT_DIR 自定位行在位（三处可跑结构锚）
# What：断言本脚本含 SCRIPT_DIR 自定位 idiom（`BASH_SOURCE[0]` 形式）。
# Why：仓库/worktree/三宿主部署位路径深度不同；自定位行是相对解析的根——被硬编码路径替换则三处仅一处可跑。
if grep -qE 'SCRIPT_DIR="\$\(cd "\$\(dirname ' "$SELF"; then
  ok 22 "脚本 SCRIPT_DIR 自定位行在位"
else
  bad 22 "脚本缺 SCRIPT_DIR 自定位行（硬编码路径风险）"
fi

# SG-23 脚本头注释 What+Why 齐备（Rule 45 双层注释）
# What：断言本脚本头部注释含 `# What` 与 `# Why` 两个标记。
# Why：Rule 45 双层注释要求（What=做什么/Why=为何这样做）；守护脚本自身也须示范该纪律（防只写代码不写取舍）。
if grep -q '# What' "$SELF" && grep -q '# Why' "$SELF"; then
  ok 23 "脚本头注释 What+Why 齐备（Rule 45）"
else
  bad 23 "脚本头注释缺 What 或 Why（Rule 45）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
