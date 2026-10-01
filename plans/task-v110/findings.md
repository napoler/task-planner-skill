# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:1-executor] 影响面普查

**Rule 21.4 全文拆解**（critical-rules.md:144）
- 保留：三证据验收 / 后台槽占用 / 首败兜底链 / 机器守护引用 / Why 实证 / 只读分槽豁免机制
- 演进：「至多 1 个活跃子代理」/「禁止派发下一个」/「互不依赖不构成并行理由」→ 改为「并行默认允许 + 独立性四问守门（四问任一 yes→串行）」
- 废弃：「无论是否依赖，互不依赖不构成并行理由」直接被 10-02 裁决否定

**全库「21.4」引用面（grep 实测，companion/.backup 不计）**
- 硬锚（断言类，须改写）：critical-rules.md:198/371/373/385/400；SKILL.md:47/85/132/192/242/256/275；completion-gate.md:22/26；reference.md:322
- 文档引用（挂演进标注即可）：critical-rules.md:155；methodology.md:86；plan-template-kit/template-guide.md:228；template-mapping.md:255/258；templates/task_plan.md:149
- 代码注释/输出文案：check-dispatch.sh:344/348/371/374；zcode-posttooluse.sh:23；subagent-fallback.sh:284
- 悬挂引用（非 21.4 语义面，顺手修正）：config.json:343（retry_limit 权威源是 22.3）
- 计数锚：MEMORY.md:101 + memory-hygiene-type.md:128（21.4 行数=7，本任务改 :144 行内容不加行→计数保持）

**「串行」措辞面**（排除 21.4 命中重复）
- 保留合法：reference.md:291 linked（串行接力）；examples.md:109
- 须改写：SKILL.md:11；completion-gate.md:19；CLAUDE.md:33（不在 scope_files）；templates/variant/rule-enhancement-type.md:63
- 禁区：宪法 ~/.zcode/AGENTS.md §一（交付时提醒用户）

**check-dispatch.sh serial_slot_check 最小改动点**
- 新增第⑤参 `pg`（parallel-group 开关）：入口 :199/:212 检测 prompt 含 `[parallel-group:` 标记
- 函数 :351 签名扩 `pg="${5:-0}"`；:366 放行条件改 `if [ "$ro" = "1" ] || [ "$pg" = "1" ]`
- 无标记路径（:370-375）零改动→TS-02/03 继续通过
- selftest 新增 TS-07/08；tier-b 零改动
- 已知边界：`[parallel-group:]` 是信任标记，守卫不做四问机器校验（文件集比对方案 B 已裁决不做）

**selftest 断言锚全集**
- selftest-dispatch.sh: TS-02:168 grep '串行'；TS-03:176 grep '串行'；TS-06:203 注释「串行槽释放」
- selftest-tier-b.sh:45 parallel_readonly 夹具；:48 [readonly-parallel] 标记；:67 删声明；:71 grep '只读分槽豁免（[task-v094 T-B1]'
- 结论：只要 :374 拦截文案保留「串行」，TS-02/03 零改动；新用例仅追加

**修订方案三件套已产出**（见 subagent-state/1-executor.md）：
1. Rule 21.4 新文本草案（含演进链 09-12→09-28→10-02 / 并行默认允许 / 独立性四问守门 / 声明制 / 串行保留场景枚举 / 验收纪律不变 / 失败兜底链不变 / 保留只读分槽豁免锚串）
2. 级联清单（逐处 file:line + 改写 vs 挂标注）
3. 守卫改动点（check-dispatch.sh 最小 diff 建议 5 点）

#### [sub:2-executor] Rule 重写级联
- 件 1 落地：critical-rules.md Rule 21.4（:144 起 6 段式新文本）整段替换——并行默认允许+独立性四问守门（任一 yes→不同组串行）+声明制（frontmatter `parallel_groups:` ∧ `[parallel-group:<组名>]`）+串行保留 5 场景（linked 接力/写类文件集相交/三文件同锚点双写/验收链依赖/用户显式串行）+验收纪律与失败兜底链不变；演进链 09-12→09-28→10-02 入标题；旧「至多 1 个活跃子代理」绝对化表述与「互不依赖不构成并行理由」条款显式登记 10-02 废止
- 锚串修复披露：方案件 1 草案中「只读分槽豁免([task-v094 T-B1]…」用半角括号，实测 selftest-tier-b.sh:71 grep 锚为全角括号 `只读分槽豁免（\[task-v094 T-B1\]`（od -c 证据 357 274 210）——已改回全角，`grep -c` 实测=1 保留
- 件 2 级联 10 文件完成：critical-rules.md（22.4a 括号内断言/25.2/39 导语/39.1/39.4 调和改写/40.4）+ SKILL.md（:47/:85/:132/:192/:242/:256/:275 七处）+ completion-gate.md（:19 段标题+时序图 `[P] 组` 标注+:26 句）+ reference.md（:312/:316/:322 linked 场景①保留串行+fan-out 句翻转）+ methodology.md:86 + plan-template-kit template-guide.md:228/template-mapping.md:255/258 + templates/task_plan.md:149 + variant/rule-enhancement-type.md:63（挂 [EVOLVED 2026-10-02]）+ templates/subagent_dispatch.md:17 新增并行组声明提示行
- 行号偏移披露：21.4 新文本跨 :144-149 六段（方案草案 144 整行→拆段，`grep -c "21.4"` 实测=7 保持 memory-hygiene 计数锚）；级联实际行号 22.4a=:162、25.2=:205、39 导语=:378、39.1=:380、39.4=:392、40.4=:407（方案行号 155/198/371/373/385/400 为 1-executor 普查时行号，内容锚逐一致对）
- 本批次未动 scripts/check-dispatch.sh、selftest-*、zcode-posttooluse.sh（件 3 守卫归批次二/S2）；subagent-fallback.sh:284「按 Rule 21.4 对照 21.1b 评估拆细」指向失败兜底段（保留语义）无需改
- 验收 grep 实测（git diff 前）：`grep -rn "至多 1 个活跃子代理" skills/` 零命中；`互不依赖不构成并行理由` 实测 1 命中=critical-rules.md:146 内 21.4 废止登记句（「…与『互不依赖不构成并行理由』条款均于 10-02 废止」带 [EVOLVED] 语境演进标注，非旧断言残留）；各引用面断言句（SKILL/reference/completion-gate/template 各文件）grep 均 0 命中=旧独立断言句已全清除；锚串 `只读分槽豁免（[task-v094 T-B1]` grep -c=1
- 越 scope 未动项（登记待主进程决策）：config.json:343 retry_limit 悬挂引用 21.4→22.3 / CLAUDE.md:33 串行措辞 / MEMORY.md:101 计数锚（Phase 4 memory 面）

#### [sub:3-executor] 守卫适配
- 件 3 落地：check-dispatch.sh 最小 diff 5 点全齐——入口 warn 兜底路径（现 :199-200）与 enforce 路径（现 :211-212）各加 `pg` 双条件检测（`grep -qm1 'parallel_groups:' $pd/task_plan.md` ∧ `grep -qm1 '\[parallel-group:' $pf`，与 T-B1 只读豁免 ro 检测同范式）；serial_slot_check 第⑤参 `pg="${5:-0}"`；槽占用分支在 ro 放行后新增 `pg=1` 放行分支（文案 `[dispatch-parallel-group] …组内四问责任在计划期声明, 组间串行不变`）；无组标记路径（warn 告警/enforce 拦截两行，现 :381/:384）文案与行为零改动
- 断言级联：selftest-dispatch.sh 新增 TS-07（计划 `parallel_groups: [g1, g2]` 声明 + prompt `[parallel-group:g1]` 标记 + 新鲜锁 + enforce → rc=0 且 stderr 含 `dispatch-parallel-group`）+ TS-08（撤声明撤标记 → 新鲜锁 + enforce 仍 rc=2 且 stderr 含「串行」，TS-02 语义防回归）；TS-01..06 既有行零改动；selftest-tier-b.sh 零改动（T-B1 锚串 `只读分槽豁免（[task-v094 T-B1]` 逐字保留）；selftest-fine-grain-steps.sh 零改动
- 偏差披露：方案件 3 标注入口行 :199/:212，实测内容锚定位（`local ro=0;` 检测行）与方案一致无偏移；新增分支放行使组内共享锁不覆盖（成员放行时不重写时间戳，与 T-B1 只读豁免同处理）
- 验证实测（git diff 前）：`bash -n check-dispatch.sh`/`selftest-dispatch.sh` 语法过；selftest-dispatch 31 PASS/0 FAIL（含 TS-07/08 新增，基线 29→31）；selftest-tier-b 18/0；selftest-fine-grain-steps 11/0；`git diff --stat` 本批=check-dispatch.sh +16/-3 段 + selftest-dispatch.sh +23/-1（批次二 2 文件 35 insertions/4 deletions 计入 12 文件全量 stat）
- 已知边界（如实）：`[parallel-group:]` 为信任标记，守卫不做四问机器校验（文件集比对方案 B 已裁决不做）；清锁机制不变（zcode-posttooluse.sh 本批未动，组内成员返回即清锁=组槽释放）

#### [sub:4-executor] 回归验证
- 42 个 selftest-*.sh 全量回归（Rule 21.4 演进+守卫适配后，worktree 内执行，单脚本 timeout 90s 包裹）：41/42 rc=0；Total 行口径 640 断言=639 PASS/1 FAIL + final-gate-hash 独立收尾 22 PASS（合计 661 PASS/1 FAIL）
- 唯一失败：selftest-knowledge-brief.sh RC=1，Total: 16 PASS=15 FAIL=1，失败断言行（原文）：`[FAIL] T6 critical-rules 21.2(142)+22.4(161) 命中且 100<行号<160`。根因定位：脚本 selftest-knowledge-brief.sh:58 断言窗口上界 160（task-v095 P6 注释「原上限 135」），但 critical-rules.md 中 22.4 段 knowledge-brief 命中行实测行号=161（critical-rules.md:161），1 行越界——守卫窗口未随内容增长再迁移，属测试窗口漂移，非 Rule 21.4 演进语义回归失败
- 非 Total 行说明：selftest-final-gate-hash.sh 采用 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` 收尾格式（无 `Total:` 行），RC=0 全 PASS，非异常
- 关键 PASS 锚：selftest-dispatch.sh 31/31（含新增 TS-07/TS-08 并行组用例）、selftest-tier-b.sh 18/18（T-B1 全角锚串保留）、selftest-fine-grain-steps.sh 11/11、selftest-registry.sh 5/5（registry rows=42, actual selftest=42 对账一致）
- 结论：Rule 21.4 演进+守卫适配未造成 21.4 语义面回归；唯一 FAIL 为既有 knowledge-brief T6 行号窗口（161 vs <160）漂移，需守卫同步上移窗口（脚本 1 处改动，越本 sub scope 只登记不修）
- 逐项 42 行原文：/tmp/sub4-results.tsv；checkpoint→subagent-state/4-executor.md

#### [sub:6-executor-B] 并行实测 B

**记忆目录治理态核查**（只读，`~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/`）
- MEMORY.md 体积 = `wc -c` **12432 字节**（≈12KB，符合预期量级）
- MEMORY.md 索引行数 = `grep -c "^- \["` **58**（符合预期 58）
- `grep -l "STALE 2026-10-02" *.md` 命中 **5** 文件：task-planner-plan-parsing-pitfalls.md / task-v056-fine-grained-dispatch-plan.md / task-v074-template-reflect-loop.md / task-v091-efficiency-optimization.md / task-v093-video-fix-template-intake.md
- `grep -c "UPDATE 2026-10-02" task-planner-repo-deploy-flow.md` = **1**（符合预期）
- 结论：治理态 3/3 全部符合预期；记忆目录零写入；无 git 写操作。并行时间线锚点 start_ts=1790893464 / end_ts=1790893493（checkpoint 原文）

#### [sub:5-executor-A] 并行实测 A

**worktree 模板面核查（verify-tpl，只读，与 verify-idx 并行）**
- ① variant 计数：`ls .../templates/variant/*.md | wc -l` = **17**（符合预期）
- ② template_type 声明：17/17 文件 `grep -c "template_type:"` 全 =1（bugfix/code-edit/deployment/diagnostic/memory-hygiene/migration/mini-lite/performance-tuning/publish/refactor/research/rule-enhancement/schema-migration/test-writing/video-fix/video/writing），无缺声明/重复
- ③ Rule 21.4 新语义（worktree critical-rules.md grep「并行默认允许|独立性四问|parallel-group」head -5）：:145 默认语义 [EVOLVED 2026-10-02]「并行默认允许+独立性四问（任一 yes→不同组串行）」；:146 声明制（frontmatter `parallel_groups:` ∧ `[parallel-group:<组名>]`，未声明者默认串行）；:205 25.2/:392 39.4/:407 40.4 引用面均带 [EVOLVED 2026-10-02] 与新语义一致
- 结论：模板面 3/3 通过；零写入核查面；并行时间线锚点 start_ts=1790893626 / end_ts=1790893640（与组 B 464–493 部分重叠=真并行实证）

#### [sub:7-executor-C] 并行实测 C

**INDEX.md 计划账本态核查**（只读，`plans/INDEX.md`，与 verify-tpl 组同消息并行，文件集不相交）
- 四任务终态行（`grep -o "| task-v10[0-9] | [a-z_]*"` 实测）：v107=complete（:62 表行 + :121 尾注 `✓ (6/6)`）、v108=complete（:63 + :122 `✓ (5/5)`）、v109=complete（:64 + :123 `✓ (5/5)`），表区与「已完成」尾注区双区一致；**task-v110 全文件零命中**——非异常：v110 Phase 3 进行中（merge_back=pending），INDEX 行按计划归 Phase 4 终验簿记时追加，缺失与任务态自洽
- 状态汇总行原文（INDEX.md:126）：`- in_progress: 2 | pending: 0 | complete: 53`；三处口径互证：「已完成」区 ✓ 行 `grep -c`=53=汇总行 complete: 53；主表 `grep -c "^| task-v"`=55=53 complete + 2 in_progress（v093 :48 / v094 :49，与「待处理」区 :67/68 对应）；pending: 0 与主表无 pending 行一致，无矛盾
- 并行时间线证明：本组 start_ts=1790893633 / end_ts=1790893662（两次 date +%s 实测）；与 verify-tpl 组（sub:5-executor-A，626–640）时间**交叠 7s（633–640）**=同消息派发真并行实证；组间文件集不相交（本组仅 INDEX.md / 对方仅 worktree templates/），独立性四问全 no
  - 零写入 INDEX.md；无 git 写操作；除三计划文件契约追加外零其他写入；验收 3/3 pass

#### [sub:8-executor] 对齐审查

**结论: APPROVED（四要素全过，P0=0/P1=0；P2=2 均为已登记已知项）** — worktree `git log master..HEAD`=3 commits（4a68bd7/989d2f2/bbf12a0），累计 skills 面 13 文件 70+/29-（+plans 簿记 6 文件），工作树 clean。

**要素 1 文档↔产出同步**（5 处 diff 原文抽验，全部对应任务意图）:
- critical-rules.md:144-150 diff hunk `@@ -141,7 +141,14`：21.4 单行→6 段式新文本（演进链 09-12→09-28→10-02 入标题 / 并行默认允许+独立性四问 / 声明制 / 串行保留 5 场景 / 验收+兜底链保留）——与 Goal 逐条对应
- check-dispatch.sh diff `@@ -367,6 +371,12`：ro 放行后新增 `pg=1` 分支（原文 `echo "[dispatch-parallel-group] 并行组标记命中(10-02 独立性守门)..." >&2; return 0`）——「守卫最小改动」意图对应
- completion-gate.md:19-28 diff：段标题 `## 多任务同步（按 21.4 调度：声明组并行/未声明串行，10-02）`+时序图 `[P:G1]` 双态——引用面级联意图对应
- SKILL.md:255 diff：Rule 21 摘要行「派发按 21.4 调度铁律——声明并行组内成员可并行（独立性四问通过）、未声明组一次验收一组成员再派下一组成员」
- subagent_dispatch.md:17 diff `+1`：新增并行组声明提示行（frontmatter `parallel_groups:` ∧ `[parallel-group:<组名>]`）

**要素 2 计数/语义联动**（grep 全库实测）:
- 旧绝对化表述「至多 1 个活跃子代理」grep 全库 rc=1 零命中 ✓
- 「互不依赖不构成并行理由」grep 全库实测 1 命中=critical-rules.md:146 废止登记句（带「均于 10-02 废止...翻转为并行前提」语境，非残留）✓
- 锚串 `只读分槽豁免（[task-v094 T-B1]`（全角括号）: selftest-tier-b.sh:71 `grep -q` 断言对 critical-rules.md:146 实测 rc=0 逐字在位；tier-b 18/18 PASS（TB-18「21.4 豁免子条在位」）✓
- `[EVOLVED 2026-10-02]` 标注分布=critical-rules:145/205/378/380/392/407 六处 + variant/rule-enhancement-type:63 一处（与 sub:2 级联 10 文件清单吻合）
- critical-rules 内 `grep -c "21.4"` 实测=7 → memory-hygiene-type.md:128 计数锚「grep 21.4=7」保持 ✓
- 非级联引用面语义一致（无 P1）: memory-hygiene-type:128/137=方法论示例非断言；zcode-posttooluse.sh:23 清锁注释指向 21.4 配对（保留语义）；subagent-fallback.sh:284「按 Rule 21.4 对照 21.1b 评估拆细」指向兜底链（保留语义）

**要素 3 引用完整性**（≥8 条抽验 vs 实现/存在性）:
1. frontmatter 声明键 `parallel_groups:` → check-dispatch.sh:200/214 `grep -qm1 'parallel_groups:' "$pd/task_plan.md"` 双入口 ✓
2. 组标记 `[parallel-group:<组名>]` → check-dispatch.sh:200/214 `grep -qm1 '\[parallel-group:'` ✓
3. `[dispatch-parallel-group]` 输出串 → selftest-dispatch.sh TS-07 `grep -qF 'dispatch-parallel-group'` 断言面一致 ✓
4. 第⑤参 `pg="${5:-0}"` → check-dispatch.sh:355 签名扩展 ✓
5. Rule 7 三击协议 → critical-rules.md:23 `### 7 永不重复失败`+:289 承载 ✓
6. Rule 26 降质 → critical-rules.md:216 `26.1` 在位 ✓
7. 22.3 ②/③ 拆细/降档 → critical-rules.md:158 `22.3` 在位 ✓
8. 22.4a 单写者/只读契约 → critical-rules.md:162 `22.4a` 在位（级联改写「派发本身按 21.4 独立性守门」与新语义一致）✓
9. `[readonly-parallel]` 预置组沿承 → check-dispatch.sh:199/213 ro 检测未动 + tier-b:48 夹具在位 ✓
10. `max_concurrency: 1` 串行兜底（39.4 改写）→ 指向 workflow 官方参数，语义保留 ✓

**要素 4 守卫锚级联**（实测重跑）:
- selftest-dispatch.sh：**Total: 31 PASS=31 FAIL=0**（含 TS-07 组标记放行/TS-08 无标记 rc=2 回归）✓
- selftest-tier-b.sh：**Total: 18 PASS=18 FAIL=0**（T-B1 锚串逐字保留）✓
- selftest-knowledge-brief.sh：**Total: 16 PASS=16 FAIL=0**（T6 窗口 160→200 修正生效，assertion 行含「窗口放宽:Rule 21.4 演进正文膨胀,task-v110」）✓
- TS-01..06 既有断言行零改动：selftest-dispatch.sh diff 仅 2 hunk（@@-134 注释行改「TS-01..08」+@@-206 追加 TS-07/08 块）✓
- 无标记路径零变化（TS-02/03 锚）：master :371/:374 → HEAD :381/:384，两行「Rule 21.4 串行派发铁律」文案逐字未动（git show 对照确认）✓

**P2（已登记不阻断）**: ① check-dispatch.sh:381/384 无标记拦截文案仍称「串行派发铁律」（守卫消息=TS-02/03 回归锚，有意零改动；与 21.4 新标题「子代理调度铁律」存在术语层漂移，属已披露 trade-off）；② 越 scope 未动项维持登记（config.json:343/CLAUDE.md:33/MEMORY.md:101，Phase 4 memory 面+主进程决策，实测 :101 计数锚 21.4=7 仍一致无 P1 化）。

**变更记录（42.6.3 三要素）**: 变更范围=findings.md 仅追加本小节/progress.md 仅追加 1 行；冲突处理结果=无冲突（P2 两项为已知登记项，按最新有效版本保留不改）；文档当前状态=残留冲突=0。

#### [sub:10-executor] 部署对账

**三宿主 v110 变更面对账（主仓 e0527b6 vs 宿主，机械 diff -q 汇总，只记录不修改）**
- 变更面基准=13 文件（git diff --stat e0527b6^..e0527b6 -- skills/：73+/32-）
- **~/.zcode/skills**：13/13 落后（diff -q 全命中）；探针「子代理调度铁律」「parallel_groups」「并行默认允许」命中全=0；critical-rules.md:144 仍为 09-12 旧串行铁律原文（「至多 1 个活跃子代理」grep 命中 1）→ 部署建议：全量同步 task-planner+plan-template-kit 至 e0527b6（本宿主全树漂移 31 文件=多任务积压，同步时应做全树而非仅 13 文件增量）
- **~/.claude/skills**：13/13 落后；探针命中全=0；critical-rules.md:144 旧文在位（与 .zcode 宿主逐字一致）→ 部署建议：全量同步至 e0527b6（plan-template-kit 面漂移浅=guide 15 行/mapping 19 行，可 13 文件+全树复核两步走）
- **~/.opencode/skills**：13/13 落后；探针命中全=0；critical-rules.md:144 旧文在位（同上）→ 部署建议：全量同步至 e0527b6
- 补充事实：三宿主互比仅 2 处 differ（companion/agents/plan-writer.md、scripts/selftest-template-lifecycle.sh，.zcode 与 .claude/.opencode 之间），即三宿主 task-planner 目录基本是同一旧版本快照；主仓侧基线探针命中=「子代理调度铁律」4、「parallel_groups」4（e0527b6 新语义在位确认）；T-B1 锚串 `只读分槽豁免（[task-v094` 三宿主 critical-rules.md 各=1（宿主尚未失锚）
- 变更记录（42.6.3 三要素）: 变更范围=findings.md 仅追加本小节/progress.md 仅追加 Phase 4 行；冲突处理结果=无冲突；文档当前状态=残留冲突=0

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
