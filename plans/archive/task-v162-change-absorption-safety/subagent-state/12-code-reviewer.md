# S12 代码面审查（.sh 改动）— code-reviewer/sonnet-1

- 审查区: /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/
- 范围: git diff 的 .sh 改动（新建 selftest-absorption-discipline.sh + 10 个级联清账脚本）
- 结论: **APPROVED**（无 Blocker，2 项 Suggestion，2 项 Nit）

## 客观证据
- bash -n: 11/11 全通过
- 新建脚本自跑: 14 pass / 0 fail / exit 0
- 10 个改动脚本自跑: 全 exit 0（9/9·20/20·14/14·14/14·23/23·12/12·17/17·13/13·12/12·12/12）
- worktree 全量 selftest 回归: 74 个脚本全 exit 0（含未改动的 workflow-orchestration WF-10 / conclusion-discipline CD-11 / skill-split）
- registry.tsv: 4 列合规（73 行），含新登记行
- 可执行位: selftest-absorption-discipline.sh -rwxrwxr-x（其余 .sh 权限沿用现状）
- 越界改动: 仅 scripts/ 下 11 个 .sh（+SKILL.md/references/templates，非 .sh，属级联载体，非本次 .sh 审查对象）

## 发现
1. 🟡 [断言逻辑] selftest-absorption-discipline.sh:60,63-67 AD-12 `_pin_lit` 判别力弱（匹配历史注释）
   - 原文: `_pin_lit() { grep -qF '1-71' "$1" 2>/dev/null; }` + `_pin_lit "$SCRIPTS/selftest-tool-selection.sh" || ad12=1`
   - 实据: 5 个 _pin_lit 文件的 live 锚已迁 1-71→1-74（本轮 diff），文件内 '1-71' 仅存于迁移注释（如 tool-selection.sh:63-64）；断言因注释文本而 PASS，无法检测 1-74 主锚被静默回退/删除。
   - plan line 223 期望「『1-71』字面=0 或宽容形态覆盖」，实现写成「字面在位」，与 plan 存在措辞背离（已知偏差，plan line 448 登记待 S10 收紧）。
   - 修复方向: _pin_lit 改为断言目标文件的 live 锚（如 grep -cE "Critical Rules 1-74" ≥1），或删除该半侧、统一走 _pin_tol。
   - 置信度: HIGH
2. 🟡 [可维护性/可移植性] selftest-absorption-discipline.sh:80,83 AD-13 硬编码主机绝对路径 + SKIP 当 PASS
   - 原文: `"/mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/task_plan.md"` 与 `ok "AD-13" "自举消费 SKIP（计划文件不在候选路径，非本任务工作区）"`
   - 实据: worktree 的相对候选不存在（worktree/plans/ 无 task-v162 目录），AD-13 实际靠该绝对路径命中主仓计划；换机/CI 时该路径不存在 → SKIP → ok() 报绿，守护静默失效。
   - 修复方向: SKIP 分支改用 ng/skip 中性态或标注 SKIPPED 不计 pass；去掉机器相关绝对路径，或改为环境变量注入。
   - 置信度: HIGH
3. 💬 [健壮性] selftest-absorption-discipline.sh:54 AD-10 fail-open（文件缺失时静默 PASS）
   - 原文: `n=\$(grep -c 'absorption' \"\$CONFIG\" 2>/dev/null); test \"\${n:-0}\" -eq 0`
   - 原因: CONFIG 不存在时 grep 输出空→`${n:-0}`=0→PASS，掩盖 config 缺失；另 plan 口径为「键名=0」，实现为全文任意串=0（当前 =0，结果一致）。
   - 修复: 先 `test -f "$CONFIG"` 再计数。
   - 置信度: MEDIUM
4. 💬 [健壮性] selftest-absorption-discipline.sh:28 AD-03 模式 `:[0-9]` 误报面偏宽
   - 原文: `! grep -qE ':[0-9]' <<<\"\$sec\"`
   - 原因: Rule 74 条文段任何「冒号+数字」散文（如时刻/比例）都会被误判为硬编码行锚；当前段内 0 命中故 PASS，属潜在误红。
   - 修复: 收紧为 `\.(md|sh|tsv|ts):[0-9]+` 或 `:[0-9]+-[0-9]+` 等引用形态。
   - 置信度: MEDIUM

## 负结果
- 未发现安全漏洞（无 eval 注入面：chk 的 eval 串均为脚本内静态字面，无外部输入拼接）
- 未发现越界 .sh 改动（scripts/ 之外无 .sh 变更）
- 未发现语法错误 / 未发现 exit code 异常
- 未发现级联漏改：未改动脚本中的宽容锚（WF-10 `1-(68|69|71)`、CD-11 `1-[4-7][0-9]`、skill-split `1-(3[0-9]|[4-7][0-9])`）仍覆盖 SKILL.md 现状 1-74，全部回归通过
