# S9 Code Review 检查点（覆盖 S9 CR + S10 文档面 alignment 两单元，主进程降为一派）

- task: task-kb-cr-lits-20261023 / Phase 3 S9
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023（分支 wt/task-kb-cr-lits-20261023）
- diff 面: `git diff 923aa54..HEAD` = 7 commit / 8 文件 / +110 −40
- 判据源: plans/task-kb-cr-lits-20261023/{task_plan.md(VC-1~6+CA-1~7), verification.md, findings.md}
- 本审查为只读：未修改任何被审文件（`git status --short` 仍仅 `?? plans/` `?? tmp/`，与审查前一致）

---

## 一、逐 L 项判定表

| L 项 | 登记待修方向 | 实测落点（file:line） | 判定 | 证据 |
|------|-------------|----------------------|------|------|
| L-1 | 两处 k8s glob 口径一致（双 glob 并集） | check-delegation.sh:251 / :351 | PASS | 两清单逐条比对**四组全同**（skills/agents/commands+config+基础设施+k8s），k8s 项两侧均为 `*/.k8s/*|*/k8s/*`；fail-closed 并集，无 fail-open 残留 |
| L-2 | LANE 精确 token 解析 + 仅 L0-E 豁免 | check-tier-consistency.sh:63 / :131-147 | PASS | 精确 token `L[012]([_-][A-Za-z0-9]+)*`；族入口 `L0 ∨ L0-T`；单 Phase/cap/S-unit 三项对 L0-T 全量生效（D-L2b）；实测 l0e 1→0、l0 1→1、l0t 0→0、l0t2ph 1→1、l1 0→0（base vs new 对拍） |
| L-3 | RC-28 守护 51.13 | selftest-requirement-coverage.sh:589-606 | PASS | 行锚 + 3 个 scoped 语义锚；实跑 `Total: 28 PASS=28 FAIL=0`；锚点在 critical-rules.md:106 实测齐全且段内各 1 |
| L-4 | 头注 RC 计数同步 | selftest-requirement-coverage.sh:8 | PASS | `head -12 \| grep -c 'RC-01..RC-28'` = 1 |
| L-5 | 两文档计数 = 实测值 | README.md:4/:81/:127；ARCHITECTURE.md:4/:114/:115/:136 | PASS | 独立实测复算：卫星 11 文件顶层唯一编号 3+3+1+3+1+4+1+44+11+4+1 = **76**，核心 14，无跨文件重号；`58+17+1=76` 算术自洽；critical-rules.md `wc -l` = **203** |
| L-6 | 文案改真语义（零行为变更） | task-plan-init.cjs:35-38/:118-123 | PASS | diff 仅 1 行字符串 + 9 行注释；`node --check` SYNTAX_OK；`grep -c '跳过计划门控'` = 0；`promptText.includes(kw)` 描述与 :63/:108 实码一致；无其他文件引用旧文案 |
| L-7 | 机械产物判定抽单函数双调用 | check-scope.sh:128-150/:165/:173 | PASS | 函数定义 1 处 + 调用 2 处（口径①/②）；base vs new 七场景对拍**文案逐字相同、rc 完全相同**（仅输出流变化，属 L-8②）；`_artifact_zone_label` 复刻「case 优先」防双命中文案漂移 |
| L-8① | 头注放行来源枚举 | check-scope.sh:22-35 | PASS | 9 条枚举与代码 ①-⑥ 实际分支逐条对应（空路径/无根/plans//豁免表/D10/D10''/轻量标记/机械区+gitignore/无哨兵）|
| L-8② | 留痕 >&2 需先查 hook 消费面 | check-scope.sh:167/:170/:175/:249 | PASS（判定可采信，且强于其声称） | zcode-pretooluse.sh:18-25 只读 rc，阻断文案自产；**额外佐证**：:152/:88 以 stdout 输出 `{"additionalContext":...}` JSON，旧实现在放行路径往 stdout 写 `[PLAN-GUARD]` 文本会污染该 JSON 协议 → 改 stderr 实际修掉一个潜在协议污染面；register-hooks-cj.ts:130 注册面 file_path 恒空 → 脚本 :43 早退，无影响 |
| L-8③-a | delegation 注释日期统一 | check-delegation.sh:437（10-07→09-07） | PASS | commit 7ab28e2 实际日期 = `2026-09-07`；全文件 task-v055-fix-review 族 10 处均 09-07，原 :437 为唯一异值 → 改向正确，非篡改历史 |
| L-8③-b | 模板路径基准统一 | templates/task_plan.md:355 | **FAIL（见 MAJOR-1）** | `<skill>` 占位符语义 = 技能根（selftest-doc-script-paths.sh:28/:81），而 `kb-sync-from-plan.sh`/`kb-rebuild-index.sh` 实体在**仓库根** `scripts/`（技能 scripts/ 下 0 命中）→ 改后路径不存在 |

---

## 二、逐 commit 摘要（射程核对：均在 scope_files 8 文件内，单目的 commit，无顺手重构）

| commit | 文件 | 面 | 越权/副作用 |
|--------|------|----|------------|
| 93e998c | check-delegation.sh（3+/3-） | L-1 两行 glob + L-8③ 一行日期 | 无（其余条目逐字未动） |
| df8502b | check-scope.sh（58+/21-） | L-7 抽 2 函数 + L-8① 头注 + L-8② 4 处 >&2 | 无（阻断文案仍 stdout，非本项射程） |
| 5abd917 | task-plan-init.cjs（10+/1-） | L-6 纯文案/注释 | 零行为变更（已逐行核） |
| 1f4da9d | templates/task_plan.md（1+/1-） | L-8③ 路径基准 | **射程内但方向本身错误** → MAJOR-1 |
| b69ed9e | selftest-requirement-coverage.sh（21+/1-） | L-3 RC-28 + L-4 头注 | 无（纯增量，锚先实测后写） |
| 9484bb2 | check-tier-consistency.sh（10+/6-） | L-2 + printf 参数化 | 无（首轮「单 Phase 收窄」已按 D-L2b 回退，实测确认） |
| 3544076 | README.md + ARCHITECTURE.md（7+/7-） | L-5 计数 74→76 + 行数注 193→203 + 括注拆分 | 无（仅计数词/括注，历史纪元注保留） |

---

## 三、分级别缺陷清单

### MAJOR-1 模板 kb-* 命令路径基准改错（指向不存在的路径）
- 位置: `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023/skills/task-planner/templates/task_plan.md:355`
- 原文: `bash <skill>/scripts/kb-sync-from-plan.sh <plan-dir>` / `bash <skill>/scripts/kb-rebuild-index.sh` / `条件式：项目存在 <skill>/scripts/kb-sync-from-plan.sh 知识库机制`
- 原因: `<skill>` 在本仓约定 = **文档所属技能根**（`skills/task-planner`，见 selftest-doc-script-paths.sh:28「`<skill>` 占位符 = 文档自身所属技能（替换为 skills/<名>）」与 :81 替换实现）。而两个 kb 脚本实体在**项目根** `scripts/`（`ls skills/task-planner/scripts | grep -i kb` 零命中；`ls /mnt/data/dev/task-planner-skill/scripts` = kb-rebuild-index.sh / kb-search.sh / kb-sync-from-plan.sh），知识库目录 `knowledge/` 亦在项目根。改后：① 三处引用全部指向不存在路径（zcode/claude/cursor 三部署位同样无该脚本）；② 语句自相矛盾（「项目存在」+ 技能根路径）；③ 该行是「条件式必做」步骤——按此执行会判定「不存在」→ 登记「跳过：无知识库机制」→ 下游每个新计划的**知识提取入库步骤被静默跳过**。
- 未被机器面拦住的理由（如实披露）: selftest-doc-script-paths.sh:101 扫描面仅 `skills/*/SKILL.md` + `skills/*/references/*.md`，**不含 templates/** → 该错误无静态守护（这也是全量 92/92 PASS 仍漏过它的原因）。
- 修复: 该行 3 处引用回退为项目相对基准 `bash scripts/kb-sync-from-plan.sh` / `bash scripts/kb-rebuild-index.sh`，条件式恢复「项目存在 `scripts/kb-sync-from-plan.sh`」；尾注改为说明**基准差异**而非「统一」——例如 `<!-- 路径基准：本行两脚本属项目根 scripts/（非技能根），与上行 353 的 <skill>/scripts/ 技能脚本不同基准 -->`。若确认要统一到技能根，则须先在 `skills/task-planner/scripts/` 落脚本实体（超出本任务射程，不推荐）。
- 备注: 本项与计划 CA-7 登记的「统一为 `<skill>/scripts/`」方向冲突——即登记方向本身失准，需主进程修订 CA-7/Decisions 后由执行体回改（S5 检查点 §5 已自留「可单独回退该 token」的口子）。
- 置信度: HIGH

### MAJOR-2 验收证据未落登记位置（progress.md 仍为空白模板）
- 位置: `/mnt/data/dev/task-planner-skill/plans/task-kb-cr-lits-20261023/progress.md`（79 行 = 未填模板，`grep -c '2026-10-23'` = 0）
- 原文: `### Phase 1: [Title]` / `- Actions taken:` / `| Test | Input | Expected | Actual | Status |`（全部占位符未替换）
- 原因: verification.md VC-2「Evidence: 四组 exit code 记录 progress.md Test Results 段」/ VC-5「记录在 progress.md + CR diff 审查」把 progress.md 定为证据落点；S8 检查点亦自述「结果落 progress.md」。实况为空 → 证据链断在登记位置（证据只存在于子代理检查点）。且 Rule 19.2 3-File 回填门控（check-3file-gate.sh）在 Phase 翻转前硬校验 progress Phase 段，现状会阻断 Phase 4。
- 修复: 把 subagent-state/8-s8-regression.md 与 2-s2-tier.md 的实测输出回填 progress.md Phase 1/2 段（Actions/Files/Test Results 三项），Phase 1/2 Status 与 task_plan.md 同步（现仍为 in_progress/pending，与 S1-S8 全部 done 不符）。
- 置信度: HIGH（非代码缺陷，属 bookkeeping/证据面）

### NIT-1 check-tier-consistency.sh 头注输出样例已过时
- 位置: `skills/task-planner/scripts/check-tier-consistency.sh:25`
- 原文: `[tier-consistency] ✗ 声明 execution_lane=L0 但形态超出轻量通道: <指标>`
- 原因: 本次把 3 条 printf 改为 `execution_lane=%s`，实测可输出 `execution_lane=L0-T`（我复跑 l0t2ph 夹具输出原文如此），头注样例只列 `=L0`。
- 修复: 头注改为 `execution_lane=L0|L0-T`（`selftest-tier-consistency.sh:128` 的 grep 断言用 L0 夹具，不受影响）。
- 置信度: HIGH

### NIT-2 ⚠ 诊断行属「拦截原因」而非「放行留痕」，改动略超 L-8② 字面
- 位置: `skills/task-planner/scripts/check-scope.sh:170`
- 原文: `echo "[PLAN-GUARD] ⚠ 轻量档标记存在但目标非机械产物区（$_fp）→ 按仓库受管文件拦截" >&2`
- 原因: L-8② 字面是「留痕 echo 走 stdout」；该行是阻断路径的诊断文案。消费面实测仍只读 rc（zcode-pretooluse.sh:18-25），故无行为影响且与「反馈走 stderr」惯例一致——建议保留，仅登记为「略超字面、无消费面影响」。
- 修复: 无需回改；若要求严格贴字面，可仅在头注/注释注明该行同批迁移的理由。
- 置信度: HIGH

### NIT-3 VC-4 判据字面不可满足（历史纪元注保留 74）
- 位置: `plans/task-kb-cr-lits-20261023/verification.md:24` 证据段「旧值 74 零残留」
- 原文: `后两处文档表述=N 且旧值 74 零残留`
- 原因: README.md:4 与 docs/ARCHITECTURE.md:122 仍含「非核心 73→74 条」「卫星 73→74 条」，位于 `<!-- -->` 历史纪元注内（属冻结演进链，不应溯改）；且 VC-4 的验证命令 grep 含 `74`，会命中这些历史注。
- 修复: 判据措辞改为「正文现行计数词零残留（历史纪元注保留）」；不改文件内容。
- 置信度: HIGH

### NIT-4 两文档新增纪元注的插入方向不一致
- 位置: `skills/task-planner/README.md:4`（新注**追加在** v191/v195 之后）vs `skills/task-planner/docs/ARCHITECTURE.md:4`（新注**前置在** v191/v195 之前）
- 原文: `--><!-- 2026-10-21 task-v195：Rule 93 规范再召回入纪律域，非核心 73→74 条 --><!-- [2026-10-23 task-kb-cr-lits-20261023 L-5 扩面` / `<!-- [2026-10-23 ... L-5 实测 ...] --><!-- 2026-10-19 task-v191`
- 原因: 各自「就地插入」，形成同族注释跨文件排序约定不一（语义无损、selftest 宽容正则锚全绿）；ARCHITECTURE §4「纪元演进史」列表未加同批条目，双处演进链有轻微 split 风险。
- 修复: 任选其一——把 ARCHITECTURE 新注移到链尾（与 README 同向），或 §4 演进史补一行「2026-10-23 L-5 计数实测纠正」。
- 置信度: MEDIUM

### NIT-5 头注扩行使既存跨文件行号锚进一步漂移（非本次引入）
- 位置: `skills/task-planner/scripts/zcode-userpromptsubmit.sh:36`、`skills/plan-template-kit/references/template-guide.md:157`、`skills/plan-template-kit/references/template-mapping.md:222`
- 原文: `check-scope.sh:85` / `check-scope.sh:59` / `check-scope.sh:66`
- 原因: 实测 base 923aa54 的白名单 case 在 :78（不在 :59/:66），说明锚在改前即失准（属「登记不修②」既有缺陷族）；本次头注 +11 行使漂移再 +11（白名单现位于 :89）。无行为面影响（仅注释）。
- 修复: 归入已登记不修项②时注明「本次 +11 行使漂移扩大，建议下次改节号/函数名锚替代行号」。
- 置信度: HIGH

### NIT-6 L0-E 豁免无体量兜底（D-L2 已裁决，建议注释登记兜底面）
- 位置: `skills/task-planner/scripts/check-tier-consistency.sh:129-131`
- 原文: `# L0-E 豁免: 纯执行档（权重 0 口径: 零受管变更 ∧ 产物落 gitignore 区, SKILL.md:187）`
- 原因: 声明 `execution_lane: L0-E` 即整体绕过单 Phase/文件 cap/S-unit 三项；SKILL.md:187 的 L0-E 定义本为「免计划免 attest」（正常不产生 task_plan），故豁免对合规 L0-E 合理；但误标 L0-E 的重计划在 check-tier 侧无兜底。实际兜底面存在于委派门（check-delegation.sh:373-377：④c 直做通道仍要求 `is_protected_path` 为假 ∧ 机械产物区）——建议注释补一句指出该兜底面，防后人误以为零守卫。
- 修复: 注释追加「误标兜底面=`check-delegation.sh` ④c（受管/保护区写入仍拦）」。
- 置信度: MEDIUM（机制确定，是否算缺陷取决于口径）

---

## 四、文档面（S10 alignment）结论

| 核对项 | 结论 | 证据 |
|--------|------|------|
| 计数口径与实测自洽 | PASS | 逐卫星顶层唯一编号 11/44/3/3/4/3/1/1/1/4/1（dispatch/discipline/media/research/template/collab/cost/resume/progress/drift/verification）= 76；跨文件无重号；核心按 `### N`+`## Rule N` = 14（80 为 `## Rule 80` 形态）；14+76 = 90 |
| 括注拆分算术 | PASS | 58 = 11+44+3；17 = 3+4+3+1+1+1+4；58+17+1 = 76，且「3 新域/7 收编/1 验证域」与 11 卫星分组一一对应 |
| 77/78/79 措辞 | PASS（无缺陷） | 账本 `plans/.rule-reservations.jsonl:55-57` 三条均 `"status":"abandoned"` + note「编号作废(abandoned)」→ 文档「已废弃不计」用词准确 |
| 行数注 | PASS | `wc -l references/critical-rules.md` = 203（worktree 与 base 923aa54 同为 203，193 确为 v191 历史快照值）|
| 纪元注释保留 | 可接受（NIT-4/NIT-3） | 历史链 73→74 与 193 快照保留是正确的「不改写历史」处理；仅新增注插入方向与 VC-4 字面需微调 |
| 「登记不修」4 项是否确属射程外 | 基本成立，附 2 条修正 | ① 阻断文案 stdout：L-8② 原文点名「留痕」且举例行号均为放行 echo → 射程外成立（且 zcode-pretooluse.sh:21 有 stderr 兜底，改它属另一缺陷族）；② 跨文件行号锚：确属既有（base 即错）+ 文件不在 scope_files → 成立，但漂移幅度因本次 +11（NIT-5）；③ 路由表编号列（v195 前快照）：属独立缺陷族、文件为 SKILL.md/ARCHITECTURE.md 路由行（非计数口径）→ 成立；④ registry.tsv:48「八子条」历史口径 → 成立（历史记录面）|

---

## 五、负结果报告（检查过但未发现问题的面）

- 全量回归（我独立复跑，非采信 S8）：`for s in skills/task-planner/scripts/selftest-*.sh` 全部 rc=0；selftest-requirement-coverage `28 PASS=28 FAIL=0`、selftest-tier-consistency `8 PASS=8 FAIL=0`、selftest-doc-script-paths 等 30+ 脚本零 FAIL。
- check-scope 抽函数等价性：以 base 脚本（`git show 923aa54:`）与 HEAD 脚本对同一夹具七场景（轻量标记+机械区/轻量标记+gitignore/轻量标记+受管/无标记+机械区/无标记+gitignore/无标记+受管/无哨兵）对拍 → rc 全同、文案逐字相同，仅输出流按 L-8② 由 stdout 迁 stderr。
- check-tier 语义：base vs new 五夹具 exit 对拍 1→0 / 1→1 / 0→0 / 1→1 / 0→0，L0-E 误判根治且 L0-T 单 Phase 不回退（与 D-L2b 一致）。
- L-1 保护区清单：两处四组条目**逐条全同**，无遗漏差项。
- 安全面：本次 diff 仅含注释/字符串/路径字面与纯 bash 判定重构；无 eval/命令注入新增面（`_artifact_zone_label` 用 printf 字面，`_is_artifact_or_gitignored_path` 保持 `git -C ... -- "$_fp"` 引号保护）；无路径遍历/权限面变更。
- 明确排除：无 SQL/XSS/认证面（纯本地 bash/cjs 门控脚本，无网络/DB/模板渲染）。
- L-6 零行为变更：逐行核 diff（1 行字符串 + 9 行注释），`node --check` 通过，全仓无其他引用旧文案。

---

## 六、总裁决

代码语义面 8 项中 7 项 PASS、L-8③-b 因**计划登记方向本身失准**产出错误路径（MAJOR-1，一行可修）；另有 1 项验收证据未落登记位置（MAJOR-2，bookkeeping）。NIT 6 项均不阻断。

VERDICT: CR CHANGES REQUIRED

（范围声明：修复面仅 2 处——templates/task_plan.md:355 三 token 回退项目相对基准 + progress.md Phase 1/2 回填；其余全部 APPROVED，无需回炉 S1-S8。）

---

# 七、二轮复查（增量，2026-10-23）

## 复查范围（只做增量，不重审全量 diff）
核心核对 862d4db（MAJOR-1 回退）+ progress.md 现态（MAJOR-2）+ 6 NIT 处置。diff 面现为 8 commit（7 原 + 862d4db），`git status --short` 仍仅 `?? plans/` `?? tmp/`。

## R1-1 [一轮 MAJOR-1] 已修 → 关闭（PASS）
- diff 实体：`git show 862d4db` = 单文件单行（1+/1−），`:353` 未动（`set-active-plan.sh` / `archive-plan.sh` 仍 `<skill>/scripts/`）。
- 路径与实体一致性：改后 3 处引用 = `scripts/kb-sync-from-plan.sh`（条件式 + 调用）/ `bash scripts/kb-rebuild-index.sh`；`ls /mnt/data/dev/task-planner-skill/scripts/ | grep -i kb` = kb-rebuild-index.sh、kb-search.sh、kb-sync-from-plan.sh（完全命中）；`knowledge/README.md` 亦在仓根；技能侧 `ls skills/task-planner/scripts/ | grep -i kb` = NONE（证非技能根）。
- 双轨注明语义正确：「归档/模板类命令 `<skill>/`=技能根；kb-* 脚本实体在仓库根 scripts/（项目相对），勿混统一」。该表述同时消解了「条件式：项目存在 …」与路径基准的自相矛盾。
- 结论：MAJOR-1 CLOSED（修复方式与我一轮建议一致，含注释层防复发）。

## R1-2 [一轮 MAJOR-2] 撤回 → 关闭（时点差，非误判）
- 读取面自证：本轮首个 `ls -la` 记录 `progress.md 4725 字节 / mtime 2026-10-23 02:46`，当次 `sed -n '1,60p'` 读到纯模板（79 行：`### Phase 1: [Title]` / `- Actions taken: -` / 空 Test Results 表）——读取结果与当时文件态一致，非读错对象、非读错文件。
- 现态（`stat`）：4923 字节 / 81 行 / mtime `2026-10-23 03:13:24`，文件尾追加 `## Phase 1: 修复（in_progress）` 段，6 条证据行在位（:74 [backfill] / :75 [complete] / :76 [vc] / :77 [decision] / :78 [drift] / :79 [complete]），`grep -cE 'S1-S7|drift|VC-1|92/92'` = 6。
- 判定：回填时点（03:13）晚于我的读取时点 → 一轮发现「当时为真、现态已消解」，撤回该条并 CLOSED；不接受「误判」定性，属先后顺序事实。
- 客观复核：`bash check-3file-gate.sh <主仓 plans 目录>` rc=1，但**失败项只剩第 7 条 drift 门控**，条件 1-5（含 progress 内容面）已 PASS → 反证 progress 证据面确已满足。

## R2-1 [二轮增量发现｜阻断-簿记，非本次 diff 引入] drift 痕迹门控可复现不通过
- 位置：`/mnt/data/dev/task-planner-skill/plans/task-kb-cr-lits-20261023/`（无 `ledger-*.jsonl`）；检查点 `subagent-state/drift-check-phase1.md`（仅存在于 worktree）
- 原文（门控判据）：`for f in "${PLAN_DIR}"/subagent-state/*-drift-checker.md`（`check-3file-gate.sh:197`）；`$0 ~ /"event":"drift_check"/`（`:185`）
- 原因：① 计划目录内无 `ledger-*.jsonl` → 「ledger 含 drift_check 行」一路不通；② 唯一 drift 检查点名为 `drift-check-phase1.md`，不匹配 glob `*-drift-checker.md`（该名来自 22.3 降档 general-purpose 承接，非 drift-checker 载体）；③ `subagent-state/` 只在 worktree，主仓计划目录无该子目录。实测 `bash check-3file-gate.sh /mnt/data/dev/task-planner-skill/plans/task-kb-cr-lits-20261023` = rc=1，输出仅 `[drift-gate] Rule 64.2: 本 Phase 窗口内无 drift_check 痕迹…`。
- 修复（零代码改动，任选其一）：(a) `ledger-append.sh` 追加一条含 `drift_check` 事件的行；(b) 在主仓计划目录建 `subagent-state/1-drift-checker.md`（内容指向 `drift-check-phase1.md`）；(c) task_plan.md 登记 `drift_exempt: <Phase 号>`（不推荐——本 Phase 实有偏移检查，豁免属失真）。
- 置信度：HIGH
- 定级说明：不计入本次 CR 缺陷分级（非本次改动引入、不影响代码语义/行为），但属 **Phase 3 翻转 / Phase 4 合并前置动作**，未清则 Phase 4 会被 check-3file-gate 拦。

## NIT 处置确认（6 条，登记不修）
NIT-1（tier 头注输出样例未含 `=L0-T`）、NIT-2（⚠ 诊断行随批迁 stderr，略超「留痕」字面）、NIT-3（VC-4「74 零残留」字面不可满足，历史纪元注保留）、NIT-4（两文档新纪元注插入方向不一致 + §4 演进史未加条目）、NIT-5（跨文件行号锚 base 即错、本次再 +11）、NIT-6（L0-E 豁免兜底面未注明）——全部按「登记不修」接受，无需回改。另确认：**templates/ 未纳入 `selftest-doc-script-paths.sh:101` 扫描面**（仅 `skills/*/SKILL.md` + `skills/*/references/*.md`）归入同一独立缺陷族登记，属模板路径类错误的机器守护缺口（本次 MAJOR-1 正是靠人工 CR 才拦住的）。

## 二轮总裁决

代码/文档面：MAJOR-1 修复实证正确（CLOSED）、MAJOR-2 现态已消解（CLOSED）、6 NIT 登记不修；二轮新增 R2-1 属簿记面 Phase 4 前置动作，零代码改动且不回炉任何 S-unit。

VERDICT: CR APPROVED WITH NITS

（准入口径：diff 面 8 commit 语义/行为/安全面全部通过；残余面 = 6 NIT 登记不修 + R2-1 需在 Phase 4 前补 drift 留痕。）
