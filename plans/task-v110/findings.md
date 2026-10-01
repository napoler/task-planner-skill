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
