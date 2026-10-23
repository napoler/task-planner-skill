# CR Review — wt/task-tplrender-20261024 (合并前全量审查)

范围: `git -C <worktree> diff master...HEAD`（b983b3b / dc426c1 / da7a3a4，12 文件 +252/-30）
方法: 静态阅读 + 实弹复现（/tmp 临时 plans/<id>/ 跑真实 init-session.sh 两遍 + 探针文件）

## 逐维度结论

1. **sed/bash 正确性** — PASS。`_sed_escape_repl`（init-session.sh:105）顺序 `\`→`&`→`|` 正确（实弹值 `a&b|c\d`、`x/y/z` 均原样落地）；定界符 `|` 避开 `/`；GNU `sed -i` 与既有 init-session.sh:861 同款假设（与注释 L694 引用已过时，见 NIT-2）。
2. **fail-closed rc 链** — PASS。实弹：正文残留 `{{BOGUS_TOKEN}}` → rc=1 + `[render] FAIL` + `[init] ERROR` exit 1（init-session.sh:994-1005）；调用侧 `if ! render_template` 无吞错路径。`_strip_html_comments`（:119）awk 区间：单行 `<!-- -->`、跨行、无闭合均已验证（无闭合=吞后续，见 NIT-1）。
3. **幂等性** — 首次/二次 init 产物 md5 逐字节相同（跳过重拷 + 渲染 no-op）。**但见 BLOCKER-1**：对「已含内容的既有文件」渲染会改写 legacy 形态。
4. **兼容映射安全性** — PASS 实弹（探针文件）: `<task-id>`→id、`<task>`→id、`<task-name>` 不被 `<task>` 误伤（pattern 需闭合 `>`）、`[DATE]`/`[YYYY-MM-DD HH:MM]` 无子串覆盖、`${TASK_PLANNER_ROOT:-…}` 死串修复且后缀保留。
5. **模板改动** — PASS。7 模板机械占位全token化（grep 残留=NONE）；`{{VAR}}` 契约示例全部落在单行 HTML 注释内（7 文件 line2 均 `-->$`），与残留正则 `\{\{[A-Z_]\w*\}\}` 互斥成立，实弹零误报。
6. **selftest 适配** — PASS/收紧。PT-26 由「占位符在」→「精确 `# Task Plan: pp` + 无 `[Brief Description]` 残留」更严；SL-07 由全文 `6/6` 计数→锚定 echo 语句 `-cF … -eq 1`，防注释撞词且保留防重复语义。
7. **SKILL.md** — PASS。L41 新增 bullets 与相邻 `**auto-tier…**`/`**会话隔离指针**` 风格一致，未触 frontmatter（`model: opus` 区），无段冲突。

## 发现

### BLOCKER-1 [数据完整性 / P0 Rule 80.2] init-session.sh:994 `for _rf in *.md` 对既有（非本轮新建）文件也执行渲染 → 改写 append-only 逐字记录
- 原文: `for _rf in *.md; do` … `[ -e "$_rf" ] || continue` … `render_template "$_rf"`
- 原因: 渲染循环无「本轮新建」过滤，重复 init（脚本多处注释明确以此为预期场景）会对已存在的 `user-session-log.md` 等重新跑 8 条 legacy 映射与 `{{}}` 校验。实弹复现（plans/demo-task-id）:
  - 逐字条目「请把 [DATE] 换成真实日期，并把 <task-id> 展开」→ 二次 init 后静默变为「请把 2026-10-24 … 并把 demo-task-id 展开」，直接违反 Rule 80.2「只写不改／已写条目冻结」与本块注释自称的「二次 init 零变化」。
  - 同一记录若含 `{{FOO_BAR}}` → 二次 init rc=1 fail-closed，阻断恢复流程。
  - 既有 `.session-log-baseline` 首条 sha 会因改写失配 → SESSION-LOG GATE 误报 tamper。
- 修复方向: 仅对本轮真正 `copy_template` 新建的文件渲染（维护 created 列表），或渲染前 `[ -f ]` 且排除既有文件 / 显式跳过 `user-session-log.md`。
- 置信度: HIGH（行为实弹复现；触发需重复 init，正常首次 init 不受影响）

### NIT-1 [_strip_html_comments 失败面] init-session.sh:119 无闭合 `<!--` 会吞掉其后全文 → 残留校验 fail-OPEN
- 原文: `awk '/<!--/,/-->/ {next} {print}'`
- 原因: 未闭合注释区间会一直吞到 EOF，其后未定义 token 不被校验（实弹 `<!-- unclosed` 后 `{{D}}` 未捕获）。当前 7 模板注释均配平（`<!--`=`-->`），无现网影响；且 awk 失败时管道输出空 → grep 无匹配 → rc=0，同属 fail-open。
- 修复方向: 可选——校验前先断言注释配平，或用 `^[[:space:]]*<!--` 仅剥离整行注释。
- 置信度: HIGH（边界行为），当前无实害。

### NIT-2 [注释准确性] init-session.sh:104/155 引用的「L694 既有 sed -i」行号已失效
- 原文: `脚本 L694 既有 `sed -i` 同款假设`
- 原因: 本次新增 197 行后该 `sed -i` 实际在 init-session.sh:861；硬编码行号易漂移。
- 修复方向: 改为函数名/语义引用，不写行号。
- 置信度: HIGH

### NIT-3 [注释理据] init-session.sh:229 顺序注释称「`<task>` 会吃掉 `<task-id` 前缀」
- 原文: `#    顺序约束: `<task-id>` 必须先于 `<task>`（否则 `<task>` 吃掉 `<task-id` 前缀，`
- 原因: pattern 为带闭合 `>` 的 `<task>`，无法匹配 `<task-id>` 前缀；探针证实两者互不干扰，顺序无关。注释理据不准确（无功能影响）。
- 置信度: HIGH

### NIT-4 [边缘假失败] init-session.sh:994 计划目录若存在名为 `*.md` 的子目录
- 原文: `[ -e "$_rf" ] || continue`
- 原因: `-e` 对目录为真，`render_template` 的 `[ ! -f ]` 返回 1 → 触发 init exit 1（且 WARN 文案「文件不存在」误导）。极低概率。
- 修复方向: `[ -f "$_rf" ] || continue`。
- 置信度: MEDIUM

## 负结果
- 检查路径: skills/task-planner/{SKILL.md, scripts/init-session.sh, scripts/selftest-plan-tier.sh, scripts/selftest-session-log.sh, templates/*.md}, .zcode/plan-templates/knowledge-brief.md
- 未发现: 命令注入（sed 值是变量展开非 eval，无 `eval`）、`set -e`+pipefail 冲突（脚本仅 `set -e` 无 pipefail，管道 rc=tail 安全）、模板漏改/误改语义占位、frontmatter 冲突。
- 已排除: `<task-name>` 误伤、`[DATE]`/`[YYYY-MM-DD HH:MM]` 子串覆盖、契约注释自触雷、selftest 放松断言。
- 语法: `bash -n` 三脚本均 OK。

VERDICT: CHANGES_REQUESTED（BLOCKER-1：渲染循环无差别作用于既有 append-only 记录，重复 init 静默改写用户逐字原文／含 `{{}}` 时误 fail-closed 阻断恢复；建议限定仅渲染本轮新建文件）

---

# 复审轮次 2 — commit fbdf2d2（BLOCKER-1 回炉修复，单轮确认）

范围: `git show fbdf2d2`（init-session.sh +50/-14, selftest-session-log.sh +28）

## 1. BLOCKER-1 修法正确性 — PASS (HIGH)
- `_created_this_round=()` 在 L746 初始化（早于所有 copy 点）。
- 入列点全覆盖 grep 实证：`_init_files` 循环 L761-762 / variant cp 三子分支后 L791 / 通用 `copy_template "task_plan.md"` L819-821 / `user-session-log.md` L840-843。未发现漏入列的 .md 创建点（init 内仅 3 处 copy_template + variant 内 3 处 cp，全部覆盖）。
- 遍历等价性: 首闪 init（目标原不存在）时列表 = 全部新建 .md == 原 `*.md` 新建子集；重复 init 列表=空 → 零渲染。
- 实弹独立复现: 新建 rc=0 且全 token 渲染无残留；二次 init rc=0、user-session-log sha 不变、含 `[DATE]`/`<task-id>`/`{{TEST_KEEP}}` 假条目逐字保留、`## Goal` 手改哨兵保留、无 `[render]` 行。

## 2. 四个 NIT 落实 — PASS
- NIT-2 L104-106：删除硬编码「L694」，改称「lane 定级写入段的既有 sed -i」。✓
- NIT-1 L121-124：新增「已知局限」段，措辞准确（未闭合注释=漏拦不误拦/现网配平/模板侧修复，不做状态机）。✓
- NIT-3 L226-231：明确原理据不成立、探针实证、顺序非正确性约束。✓
- NIT-4 L1030-1032：`[ -e ]`→`[ -f ]`。✓

## 3. SL-12 断言有效性 — PASS (HIGH)
selftest-session-log.sh L173-200：`$INIT`=`$SCRIPT_DIR/init-session.sh`（L28，真脚本），二次 init 后断言 sha 不变 ∧ 假条目在 ∧ Goal 哨兵在 ∧ rc=0。旧 `for *.md` 若恢复 → sha 变 → SL-12 FAIL（上一轮已实证旧码会改写），故为真回归护栏。本地跑 SL 13/13 PASS、PT 32/32 PASS（PT-26 渲染仍生效）。

## 4. 新引入问题 — 无
- 数组在 `set -e`（无 `set -u`）下：`"${_created_this_round[@]}"` 空数组展开为空、循环体不执行，安全（init-session.sh:19 仅 set -e，已核）。
- `+=` 在 if 分支内，copy 失败路径不会误入列（copy_template 失败返回 1 使 if 不成立）。
- SL-12 fixture 复用 `$SL11_TMP`（L118 mktemp、L119 trap EXIT 清理）→ 无泄漏。

VERDICT: APPROVED（BLOCKER-1 已消除并经独立实弹复现 + SL-12 护栏验证；4 NIT 全部落实；无新问题）
