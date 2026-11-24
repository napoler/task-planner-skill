status: done

# 22-critic — 执行期增量复审（第二轮：对齐增量 E26-E30 + 上轮发现闭环复核）

审查对象：worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124`
基线 `9e42c0b` → HEAD `ee254abd`（9 提交 / 9 文件 +39/-31；工作树干净）
维度：完备性（E26-E30 逐字）/ 一致性（跨载体模型字面）/ 逻辑（69.5 新句自洽）/ 可执行性（守护与命令）/ 可维护性（漂移再生面）

## 已完成里程碑

- [2026-11-24T04:5xZ] 取 diff：`git diff --stat 9e42c0b HEAD` = 9 文件 +39/-31；`git status --short` 空；`git log --oneline` = 9 提交（新增 17705c10 / c8cc87b1 / ee254abd）。
- [..] 增量算术自洽：numstat 加总 = +39/-31（11+1+2+6+8+3+4+2+2 / 9+1+2+6+4+3+2+2+2）；三提交统计 3+/3-、5+/3-、1+/1- 无夹带。
- [..] E26-E29 逐字：规格 177/181/185/189 行 new 串 → 盘上各命中 1 次，对应 old 串命中 0 次。
- [..] E30 逐字：规格 197-199 行注释块与盘上 39-41 行 `diff` = IDENTICAL；规格 202 行断言与盘上 43 行 IDENTICAL；旧 What/旧断言 `grep -c` 均 = 0。
- [..] 实跑守护：`selftest-agent-coverage.sh` → 9 PASS / 0 FAIL / EXIT=0；`selftest-decision-arbiter.sh` → 16 PASS / 0 FAIL / EXIT=0（DA-02 PASS "model 逐字=GLM-5.4 强档(max)"）。
- [..] AC-04 机制实测（验证 D-15）：`printf 'decision-arbiter(D1, GLM-5.4 强档 max)' | grep -oE '[a-z][a-z0-9]+(-[a-z0-9]+)*'` → `decision-arbiter` + `max`；去掉 max 后仅 `decision-arbiter`。GLM 全大写故 `lm-5` 不成 token。
- [..] 全仓字面面复核：`grep -rn "decision-arbiter" skills | grep GLM` → 仍剩 3 处旧字面（见 W-5/W-6/N-1）；`grep -rn "GLM-5\|GLM5" skills/*/scripts` → 仅 selftest-decision-arbiter.sh 内 5 处（含历史注记），无第二处脚本钉模型。
- [..] 结构：discipline 777 行（28.8:64 / 28.9:66 / ### 29:68 未动）；SKILL.md 469 行（≤581）。

## 上轮 C/I/W/N 逐条闭环判定

1. **C-1 已闭环**。`selftest-decision-arbiter.sh:43` = `if grep -qF 'account:zai-individual-coding-plan/GLM-5.4' "$ARBITER"; then ok 02 "model 逐字=GLM-5.4 强档(max)"`；实跑 16/0。锚仍单串逐字（强度未变）。
2. **I-1 已闭环（本条载体）**。`critical-rules-discipline.md:399` 现为「model=`.../GLM-5.4`，thoughtLevel max——…；原值 GLM-5.3 + enabled（对齐 complex-planner 强档先例）在当前宿主派发必败（Reasoning level unsupported），2026-11-24 用户裁决改为现值，禁降档改判，frontmatter 为 truth source」。原值/现值/禁降档三者同句可判、方向一致（5.3+enabled→5.4+max 为升档，无「降档」歧读冲突）。同族残留见 W-5/W-6。
3. **W-4 已闭环**。`agent-coverage.md:40` = `| 28 | 判断/裁决 | decision-arbiter(D1, GLM-5.4 强档) |`；D-15 的机制前提经实测成立（见里程碑），退 max 是唯一不放宽豁免名单的解法。
4. **N-1 未闭环**。`decision-arbiter.md:14` 仍为「Why 强模型: …选 GLM-5.3 强档(对齐 complex-planner 先例)；低频重推理，不占高频预算。」属措辞残留（语义可由 :16-19 注记还原），维持 N。

## 新发现（本轮增量引入/暴露）

### W-5（W）`skills/plan-template-kit/references/template-mapping.md:305` — 规格把 decision-arbiter 行误归为 complex-planner 引用而豁免，矩阵现仍写 GLM-5.3
- 原文：「机械判断（41.3 直做） | decision-arbiter(GLM-5.3) |」
- 反证：`grep -n complex-planner template-mapping.md` = 0 命中——该文件根本无 complex-planner 字样；其唯一 GLM-5.3 就在 decision-arbiter 行。而 edit-spec.md:173 写「描述 complex-planner 的 GLM-5.3 字样（…template-mapping.md…）一律不动」，归类事实错误。
- 后果：模板选型表把执行体标为 GLM-5.3；按 103.4「派发 model 参数显式指定」的链路，计划期可据此指定本宿主不存在的模型，派发失败后只能退 critic 降级（28.9④），R4 修复面留缺口。当前无 selftest 守该字面。
- 建议：`decision-arbiter(GLM-5.3)` → `decision-arbiter(GLM-5.4)`（该列非 AC-04 解析面，加 max 无风险，但为与 agent-coverage 同构可只写版本号）。
- 置信度：HIGH

### W-6（W）`skills/task-dispatch/references/critical-rules-dispatch.md:245` — 103.4 仍写「质量争议升级 decision-arbiter GLM-5.3 强档」，与「派发 model 参数显式指定」相邻
- 原文：「重档→封顶同档（独立上下文已消除污染增量；质量争议升级 decision-arbiter GLM-5.3 强档）。派发 model 参数显式指定，禁降档复检」
- 问题：该从句是 decision-arbiter 专属（非泛指档位），规格却以「泛指档位描述」豁免（edit-spec.md:173）；派发侧规则正文与 69.5「frontmatter 为 truth source」相左，执行体按本条显式传 model 即复现 R4 的派发失败。
- 建议：改为「decision-arbiter GLM-5.4 强档」。若坚持不改，须在 progress 登记残余风险（派发失败→critic 降级）。
- 置信度：HIGH

### W-7（W）`skills/task-planner/scripts/selftest-decision-arbiter.sh:41` — 注释称「断言随 frontmatter 锁步」，但 DA-02 只钉 model，thoughtLevel=max 无守护
- 原文：「用户裁决对齐宿主可用配置 GLM-5.4 + max，断言随 frontmatter 锁步（仍为逐字锚，强度不变）。」
- 问题：判例的报错正是 reasoning level（enabled 不受支持）；若日后 thoughtLevel 回落 enabled，DA-02 仍 PASS，R4 修复静默失效。唯一防线是 VC-6 的一次性 grep（task_plan.md:75），无持续回归面。
- 对 D-13 的判断：D-13（零新断言）作为范围约束成立且理由可接受（计划零新 selftest），**不据此升 I**；但「断言随 frontmatter 锁步」的措辞高估了覆盖面。
- 建议（不扩范围版）：注释改述为「model 断言随 frontmatter 锁步；thoughtLevel 由 VC-6 一次性核验」，并在 progress 登记该残余风险。
- 置信度：HIGH

### N-3（N）`skills/task-planner/scripts/selftest-decision-arbiter.sh:43` — DA-02 对整份 agent 文件 grep，而非 frontmatter 行段
- 原文：「if grep -qF 'account:zai-individual-coding-plan/GLM-5.4' "$ARBITER"; then ok 02 …」
- 问题：若日后注释/正文写入完整 model 串（当前 :16-19 只写 GLM-5.3），frontmatter 回退仍可通过。基线即如此，非本轮引入。
- 建议：与 VC-6 同构，用 `sed -n '1,12p' "$ARBITER" | grep -qF ...` 收窄面。
- 置信度：HIGH

## 上轮其余发现的重判（均维持原级，不升 I）

- **W-1 维持 W**。`verification-gate/SKILL.md:68` =「拆分项全 PASS ⇒ PARTIAL，未全 PASS 或未拆分 ⇒ BLOCKED」缺「且残余风险清单已登记」；对照 `critical-rules-verification.md:40` 有该合取项，`28.9④` 只写「连同残余风险清单定态」——三载体两种口径。不升 I：PARTIAL 分支自身仍要求「有已知遗留」列表，最坏是终态留痕弱化而非误判 COMPLETE。
- **W-2 维持 W**。`28.9`(discipline:66) ④「仅此一次」/⑤「续推的 gap key 集合 ⊆ 已登记集合（无新增可执行项）=固定点达成」之间仍无非子集分支；第二轮起 verifier 带新 key 时无受权动作（执行体易自选忽略或重开归因）。不升 I：无条款禁止执行新类 A 项，实际后果是判据模糊而非硬死锁。
- **W-3 维持 W**。`critical-rules.md:204` 仍「改走 decision-arbiter→AskUser 上报用户裁决」后接「(goal 语境：不 AskUser…)」；`task-planner/SKILL.md:124` 同型两句相邻。不升 I：goal 覆盖句紧邻同分句，就近读取的纠正成本低。
- **Q-1 维持 Q**。「永不自动（预算外，即使 goal）=D6 类…」仍为枚举且无「未列预算内即预算外」兜底；靠「41.5/72.1/97.5 的『询问/等待』在 goal 语境下即此形态」+⑧ 名单反推。不升 I：指针链可闭合，缺的是默认拒绝一句。
- **Q-2 维持 Q**。`28.8④` 仍「必须按 94.7 停下复述并呈报，禁静默续扩」，与 28.9 前言「28.8①-④原文语义保留，仅其硬门处置由②明确取代」靠一揽子声明衔接；28.8④ 本身未加注。不升 I：28.9 前言已显式取代处置。
- **N-2 维持 N**。`critical-rules.md:134` 仍「续推指令按 28.9③-⑤ 幂等处理，2026-11-24）（禁空转重问死循环）」双括注；与规格逐字一致，属规格文风。

## 负结果报告（预期有但未发现 / 已排除）

- 增量夹带：三提交 numstat 与 E26-E30 逐条增量相加 = 全量 +39/-31，排除顺手改/格式化。
- E30 之外无第二处脚本钉模型（`grep -rn "GLM-5\|GLM5" skills/*/scripts` 仅命中该文件）。
- SKILL.md 的 decision-arbiter 行（:119/:124/:164/:469）均不带模型字面，无需同步。
- 69.5 新句与 69.1/69.2/69.6、DA-09/DA-12/DA-16 无冲突（实跑 16/0 佐证）。
- complex-planner 的 GLM-5.3 + enabled 保持原样（complex-planner.md:5-6、INSTALL.md:142、agent-coverage.md:13/30），符合 D-13 的授权边界，不是漏改。
- 未排除项：第二轮全量 run-selftests 未由本单元执行（只读 Scope，且写缓存），仅单脚本实跑+主进程另行核对；本轮结论不依赖全量结果。

## 自审段

1. E26-E30 逐字对照 → PASS（new=1/old=0 ×4；注释块与断言 diff IDENTICAL）。
2. 69.5 新句自洽性通读 → PASS（原值/现值可判、禁降档语义保留、无内部矛盾；「对齐 complex-planner 强档先例」现为对原值的追述，且 complex-planner 确实仍为 5.3+enabled）。
3. 上轮 10 条逐条闭环/重判 → PASS（C-1/I-1/W-4 已闭环；N-1 未闭环；其余 6 条维持原级并给不升 I 理由）。
4. 新发现 4 条均含 file:line+原文+后果+建议，无一条依赖推测 → PASS。
5. 只读合规：未改任何仓库文件，未做 git 写操作，未派发子代理；唯一写入=本检查点。

## 验证摘要

总发现 14（上轮 10 条重判 + 新 4 条）/ 已验证 14 / 通过率 100%。

## 最终结论

0 CRITICAL / 0 IMPORTANT → **APPROVED**（W-5/W-6/W-7 建议在部署前或后续任务处理，不阻断本轮）。
