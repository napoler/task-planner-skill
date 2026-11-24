status: done

# 10-critic — S11 条款文本独立审查（Rule 103 第二轮复检 / Rule 74 替代条件第 4 项）

审查对象：worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124`，基线 9e42c0b..HEAD(1850c4c) 6 提交 / 7 文件 +31 -25；外加规格 E25 指定的主仓 `/mnt/data/dev/task-planner-skill/AGENTS.md`。
维度：完备性（规格逐条）/ 一致性（跨载体与既有规则）/ 逻辑（28.9 八子条互斥自洽）/ 可执行性（命令与断言）/ 可维护性（载体漂移）。

## 已完成里程碑

- [2026-11-23T18:52Z] 取全量 diff：`git log --oneline 9e42c0b..HEAD` = 6 提交；`diff --stat` = 7 文件 +31/-25；`git status --short` 空（worktree 干净）。
- [2026-11-23T18:54Z] E0 逐字校验：`diff <(sed -n '21p' edit-spec.md) <(grep -m1 '^28\.9 ' critical-rules-discipline.md)` = IDENTICAL；28.9 单行含 ①②③④⑤⑥⑦⑧ 全集；结构 `28.8:64 → 空行:65 → 28.9:66 → 空行:67 → ### 29:68`；净增 2 行（775→777）。
- [2026-11-23T18:56Z] E1a-E25 共 25 条：每条规格 new 串 `grep -F -c` 命中 1、old 串命中 0（E1a/E4/E5/E6/E7 五条 old 已清零）；E25 与规格串逐字一致（差异仅为 printf 无尾换行）。增量算术自洽：+8/-6、+6/-6、+3/-3、+4/-4、+2/-2、+8/-4 合计 = +31/-25，与 `diff --stat` 完全相等 → 规格未点名的既有文字零改动。
- [2026-11-23T18:58Z] 规格自检 1：`grep -rn -o -E "仅单次降级收口停止|单次阻塞降级收口|并停止该目标迭代"` 全仓仅 1 处（discipline:64 保留片语，符合预期）；SKILL.md 469 行（≤581）；discipline 777 行（=775+2）。
- [2026-11-23T19:00Z] 冲突面回读：28.8①-④（:64）、44.3（:185）、44.5（:188）、69.5（:399）、72.1 A①-A④（:450-453）、41.2 G1-G4（:142）、41.5（:146）、95.4/95.7（:640/:643）、97.5（:655）、109.2（:204）、84.3⑤/84.5（VR:24/:40）、反作弊第 9 条与判据冻结协议（V:95/:98）。
- [2026-11-23T19:01Z] 跑既有守护：`bash skills/task-planner/scripts/selftest-decision-arbiter.sh` → `DA-02 FAIL model 非 GLM-5.3 强档`，`Total: 16 PASS=15 FAIL=1`，`EXIT=1`。基线证据：`plans/.../baseline-selftest.log` 中 `selftest-decision-arbiter (rc=0 PASS=16 FAIL=0)`、`Total: 104 PASS=104 FAIL=0`。
- [2026-11-23T19:02Z] decision-arbiter.md 白空格复核：行首制表符 0、行尾空白 0、注释块 `<!--`/`-->` 各 1（S8 返工已清）；frontmatter model=GLM-5.4、thoughtLevel=max、description 含「GLM-5.4 强档(max)」。

## 进行中

（无）

## 两处已登记执行偏差的独立判断

1. D-12（E20 落在反作弊第 9 条禁止句末尾而非「判据冻结协议」句之后）：**认可**。E20 新增串与规格逐字相同（V:95 命中 1），所附着的第 9 条本身即含「唯一合法路径=STOP→用户显式授权→…」，例外紧随其所例外的禁令，语义闭合；判据冻结协议段（V:98）自 attest 起冻结，与「计划期（attest 锁定前）拆分不属中途改判据」不构成矛盾；执行期不可达的 goal 处置由同条末尾 28.9④ 指针承接。结论：落点偏移不产生语义差，无需返工。
2. decision-arbiter.md 注释块闭合符随新增注释移至新末行：**认可**。单开单闭、无制表符/行尾空白，块内缩进与既有行一致，正文未受影响。

## 产出文件清单

- `/mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/10-critic.md`（本检查点，唯一写入）
- 未改任何被审文件；未做 git 写操作；未派发子代理。

## 错误与受阻

（无。selftest-decision-arbiter.sh 为只读脚本，跑测未产生文件改动。）

## 自审段（Rule 103.2，逐条验收自核）

1. 25 条编辑逐条核对与零未点名改动 → 自核 PASS。证据：E0 diff IDENTICAL；25 条 new 各 1 / old 各 0；+31/-25 分解与 stat 相等；E25 主仓 :24 逐字一致；worktree `git status` 空。
2. 整体条款文本分析（八子条自洽 / 冲突面 / D6 / A①A④ / 28.8④ / 判据冻结 / decision-arbiter 同步）→ 自核 FAIL。根因：decision-arbiter 配置切换未传导至其守护与规则载体（C-1/I-1/W-4/N-1），另有 84.5 与 SKILL.md 的 PARTIAL 判据不对称（W-1）。已逐条给 file:line 与修复建议，无一条依赖推测。
3. 两处已登记偏差独立判断 → 自核 PASS（结论见上，均认可并给理由）。
4. 遗留缺口：未跑全量 `run-selftests.sh`（会写缓存文件，违反本单元只读 Scope）；改以单脚本实跑 + 基线日志比对取证，结论对 VC-3 已具决定性（DA-02 rc=1 ⇒ 104/0 不成立）。

## issues[]（10 条：C1 / I1 / W4 / Q2 / NIT2）

```json
[
  {
    "key": "C-1",
    "severity": "C",
    "state": "open",
    "location": "skills/task-planner/scripts/selftest-decision-arbiter.sh:41",
    "title": "E23 改 model 为 GLM-5.4 后，DA-02 守护断言仍锁 GLM-5.3，selftest 由绿转红（exit 1）",
    "evidence": "if grep -qF 'account:zai-individual-coding-plan/GLM-5.3' \"$ARBITER\"; then ok 02 \"model 逐字=GLM-5.3 强档\"",
    "observed": "DA-02 FAIL model 非 GLM-5.3 强档；Total: 16 PASS=15 FAIL=1；EXIT=1；基线 baseline-selftest.log= rc=0 PASS=16 FAIL=0、Total 104 PASS/0 FAIL",
    "impact": "违反 Rule 74 替代条件④（替代后既有守护/selftest 全绿），并使 VC-3（task_plan.md:72 要求 FAIL=0 且 PASS=104）在执行期机械验证必然失败；Rule 28.9④ 的独立仲裁出口依赖 decision-arbiter 可派发，而其守护现状与前端配置自相矛盾。",
    "fix": "改 DA-02 断言为 `account:zai-individual-coding-plan/GLM-5.4` + 新增 thoughtLevel=max 断言（或合并为 model+thoughtLevel 双固定串），同步脚本头 What 注释（:39）与 ok 文案；重跑该脚本达 16/0。",
    "confidence": "HIGH"
  },
  {
    "key": "I-1",
    "severity": "I",
    "state": "open",
    "location": "skills/task-discipline/references/critical-rules-discipline.md:399",
    "title": "Rule 69.5 仍以规则正文声明 model=GLM-5.3、thoughtLevel enabled，与 E23 后的 frontmatter 直接背离",
    "evidence": "model=`account:zai-individual-coding-plan/GLM-5.3`，thoughtLevel enabled——判断质量依赖推理深度，对齐 complex-planner 强档先例，禁降档改判，frontmatter 为 truth source",
    "impact": "Rule 74 条件②（替代范围完整覆盖旧场景）未满足：执行体按 69.5 字面会恢复 5.3（本宿主必败，28.9④ 仲裁出口再断），且 69.5 是 selftest DA-02 旧断言的语义来源，载体漂移会反复再生 C-1。",
    "fix": "69.5 内把 model 字面改为 GLM-5.4 + thoughtLevel max（保留「frontmatter 为 truth source」与「禁降档改判」语义，可加 2026-11-24 变更注记），与其指针对齐。",
    "confidence": "HIGH"
  },
  {
    "key": "W-1",
    "severity": "W",
    "state": "open",
    "location": "skills/verification-gate/SKILL.md:68",
    "title": "E19 的 PARTIAL 判据缺「残余风险清单已登记」合取项，与 84.5 / 28.9④ 不对称",
    "evidence": "拆分项全 PASS ⇒ PARTIAL，未全 PASS 或未拆分 ⇒ BLOCKED",
    "compare": "84.5（critical-rules-verification.md:40）=「拆分项全 PASS 且残余风险清单已登记 ⇒ PARTIAL（不得判 COMPLETE）」",
    "impact": "同一状态（拆分项全 PASS 但残余清单未登记）按 84.5 判 BLOCKED、按 SKILL.md 判 PARTIAL，读者只靠 SKILL.md 时会放宽终态门；属跨载体判定不对称，非硬矛盾。",
    "fix": "E19 补「且残余风险清单已登记」六字（与 84.5 逐字对齐），或在句末加「详见 Rule 84.5」。",
    "confidence": "HIGH"
  },
  {
    "key": "W-2",
    "severity": "W",
    "state": "open",
    "location": "skills/task-discipline/references/critical-rules-discipline.md:66",
    "title": "28.9④「仅此一次」与⑤「gap key ⊆ 已登记集合」之间缺非子集分支：第二次及以后续推携带新 gap key 无处置路径",
    "evidence": "④ **首次续推=差异归因（仅此一次）** / ⑤ 续推的 gap key 集合 ⊆ 已登记集合（无新增可执行项）=固定点达成",
    "impact": "协议的核心承诺是「续推幂等」，但只定义了首轮归因与子集固定点；verifier 在第二轮起追加新 gap key（判例正是 verifier 反复翻转）时，③只导流到④、④已用尽，执行体只能自选（忽略真缺口或重开归因循环），与目标「不再翻转/空转」相悖。",
    "fix": "⑤ 增一句分支：「gap key 非子集时，仅对新增 key 执行一次类 A/B/C/D 归因（不重判已登记 key），登记后即回落固定点应答」。",
    "confidence": "HIGH"
  },
  {
    "key": "W-3",
    "severity": "W",
    "state": "open",
    "location": "skills/task-planner/references/critical-rules.md:204",
    "title": "109.2 同一段内先新增「goal 语境不 AskUser」，随后既有句仍写「改走 decision-arbiter→AskUser 上报用户裁决」",
    "evidence": "连续 ≥3 轮无实质进展→呈报用户裁决（goal 语境：不 AskUser，独立仲裁一次后按 28.9②④ …）；…命中后禁止继续自动派发同类修复，改走 decision-arbiter→AskUser 上报用户裁决",
    "compare": "同型双指令亦见 skills/task-planner/SKILL.md:124（E10 之后仍留存前句 AskUser 指令）",
    "impact": "局部文本自相矛盾，只靠 28.9⑧ 的全局终点覆盖兜底；低档执行体按就近原则读到后一句会发起提问，直接撞 28.9①（AskUser 0 次）。",
    "fix": "在两处既有 AskUser 句后各加 6-10 字「（goal 语境按 28.9⑧ 覆盖：登记待授权清单，不提问）」，或调整语序使新句位于其后。",
    "confidence": "MED"
  },
  {
    "key": "W-4",
    "severity": "W",
    "state": "open",
    "location": "skills/task-dispatch/references/agent-coverage.md:40",
    "title": "覆盖矩阵判断裁决行仍标「decision-arbiter(D1, GLM-5.3 强档)」",
    "evidence": "| 28 | 判断/裁决 | decision-arbiter(D1, GLM-5.3 强档) | 在位（Rule 69 载体，task-v154…）",
    "impact": "选型矩阵是派发前的档位依据，标签陈旧会诱导按 5.3 复述档位；同族内与 frontmatter 漂移（与 I-1 同因）。",
    "fix": "改为「GLM-5.4 强档(max)」。",
    "confidence": "HIGH"
  },
  {
    "key": "Q-1",
    "severity": "Q",
    "state": "open",
    "location": "skills/task-discipline/references/critical-rules-discipline.md:66",
    "title": "28.9② 的「永不自动」为纯枚举且无兜底句，97.5③ 预算配额追加 / ④ 合规边界模糊未落入枚举",
    "evidence": "永不自动（预算外，即使 goal）=D6 类不可逆/破坏性/删除数据/强推/对外不可撤回发布/花钱（…）；指令未明示为任务对象的 skills/**…；推翻用户显式否决项…；超 28.8④ 上界的范围扩张。",
    "compare": "97.5（:655）四类门含「③ 预算与配额追加（超预算属用户专属）」「④ 合规边界模糊（红线不可由代理裁量）」",
    "impact": "两项既不在预算内正列举，也不在「永不自动」枚举中；仅靠④四分类「B=预算外」反推才能落地。若读者以②列举为封闭集，存在把合规红线当预算内静默自决的读法（安全向偏差）。",
    "fix": "② 末尾加一句「未列入预算内者一律按预算外处理（登记待授权清单，不执行）」；或在永不自动枚举补「预算/配额追加」「合规红线裁量」两项。",
    "confidence": "MED"
  },
  {
    "key": "Q-2",
    "severity": "Q",
    "state": "open",
    "location": "skills/task-discipline/references/critical-rules-discipline.md:64",
    "title": "28.8④「超上界必须停下复述并呈报」与 28.9②「超上界=预算外→登记后继续、禁停表」的处置口径需确认",
    "evidence": "执行中交付单元数超过已登记上界…必须按 94.7 停下复述并呈报，禁静默续扩。",
    "compare": "28.9 前言称「28.8①-④原文语义保留，仅其硬门处置由②明确取代」；② 称「登记…后继续执行其余可执行项，该项保持未执行，禁停表等待」",
    "impact": "上界判定与「A① 范围边界」对齐（D-11 已解决）；仅处置动作（停 vs 不停、复述是否保留）依赖前言的一揽子取代声明，28.8④ 原文未加注，存在双读。",
    "fix": "在 28.8④ 句末加「（goal 语境：按 28.9② 登记待授权清单后继续，上界内复述并登记）」，把「停表」与「复述留痕」分开表述。",
    "confidence": "MED"
  },
  {
    "key": "N-1",
    "severity": "N",
    "state": "open",
    "location": "skills/task-planner/companion/agents/decision-arbiter.md:14",
    "title": "注释块内既有 Why 行仍写「选 GLM-5.3 强档(对齐 complex-planner 先例)」",
    "evidence": "Why 强模型: 判断质量依赖推理深度，选 GLM-5.3 强档(对齐 complex-planner 先例)；低频重推理，不占高频预算。",
    "impact": "E24 变更注记（:16-19）已解释「原行为=GLM-5.3 / 修法=GLM-5.4+max」，语义可还原；仅该行自身读起来像现行选型，属措辞残留。",
    "fix": "把「选 GLM-5.3 强档」改为「选 GLM 强档（2026-11-24 起 GLM-5.4 + max，见下条注记）」，或在行末加「（已被 2026-11-24 注记取代）」。",
    "confidence": "HIGH"
  },
  {
    "key": "N-2",
    "severity": "N",
    "state": "open",
    "location": "skills/task-planner/references/critical-rules.md:134",
    "title": "66.2 新增片语与既有括号句相邻，形成「…2026-11-24）（禁空转重问死循环）」两个并列括注",
    "evidence": "续推指令按 28.9③-⑤ 幂等处理，2026-11-24）（禁空转重问死循环），判例 sess_3cb0a759。",
    "impact": "可读性瑕疵，不影响判定语义；与 E15 规格逐字一致（非执行偏差）。",
    "fix": "把日期移入内层括号或改为「…幂等处理；2026-11-24）（禁空转重问死循环）」，或合并为单括号两句。",
    "confidence": "HIGH"
  }
]
```

## 负结果报告（预期有问题但未发现 / 已排除）

- 28.9 八子条互斥自洽：①公理（0 次提问）→②预算矩阵（正列举 + 永不自动 + 预算外处置）→③续推识别（仅自动续推）→④首次归因→⑤固定点→⑥冻结/翻转上限→⑦授权到达→⑧终点覆盖，无两条同时定义同一动作的冲突；⑦ 与 ⑤ 触发源互斥（用户手输 vs 自动续推），③ 已前置声明用户消息优先，未发现竞态。
- D6 类未放行：② 永不自动、⑦ D6 须逐项显式确认、⑧ D6 登记并保持未执行、41.5 D6 等待——四处同向；E19/E18/28.9④ 的「执行期不新增判据行」与反作弊第 9 条冻结语义相容（例外仅限计划期）。
- 72.1 A①/A④ 自治：② 明确不因 A 级名义转预算外，A① 以 28.8④ 交付单元上界为界；⑧ 复述「A①/A④ 与 41.2 G4 处置不变」；72.1 自身「A 级必须询问」与 72.2「必须获显式确认」的张力已由 28.9② 直接声明「不因 A 级名义」覆盖（未单列 72.2，仅作 W 级观察；因 ② 措辞已足，未升 I）。
- 41.2 G1-G4：G1/G3 内容落入 ② D6 类；G2 落入 28.8④/②；G4 自带 silent 分支 → 无未处理冲突。
- 规则编号与账本：`^28\.9 ` 全仓计数 1（无撞号）；`plans/.rule-reservations.jsonl` 无任何 28.x 条目（28.8 亦无）→ 子条无需登记，不构成缺口。
- 结构/白空格：discipline 净增恰 2 行、前后空行合规；decision-arbiter 无制表符/行尾空白，注释块单开单闭。
- 未点名文字改动：+31/-25 与规格 6 组增量逐组相加完全相等，`git diff --name-only` 恰 7 文件，worktree 干净 → 排除「顺手改/格式化」。

## 最终结论

```
status: done
acceptance: 2/3 pass — [1:PASS 2:FAIL 3:PASS]
files: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/10-critic.md
evidence: bash skills/task-planner/scripts/selftest-decision-arbiter.sh → DA-02 FAIL model 非 GLM-5.3 强档 / Total: 16 PASS=15 FAIL=1 / EXIT=1（基线 baseline-selftest.log: selftest-decision-arbiter rc=0 PASS=16 FAIL=0, Total 104 PASS=104 FAIL=0）; diff <(sed -n '21p' edit-spec.md) <(grep -m1 '^28\.9 ' skills/task-discipline/references/critical-rules-discipline.md) → IDENTICAL; 25 条规格串 grep -F -c 均=1、old 串均=0; discipline 28.8:64/28.9:66/### 29:68 结构合规、777 行、八子条 ①②③④⑤⑥⑦⑧ 齐全; SKILL.md 469 行; git diff --stat 9e42c0b..HEAD → 7 文件 +31/-25（= 各单元增量算术和）, git status --short 空; 主仓 AGENTS.md:24 与 E25 规格逐字一致
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/10-critic.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
