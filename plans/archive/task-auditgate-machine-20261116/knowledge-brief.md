# Knowledge Brief — task-auditgate-machine-20261116（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：在 task-planner 落地计划审计门机器强门（attest `[audit-gate]` 锁定前对 L1+ 校验 APPROVED、轻量档 `[plan-audit-skip]` 放行、独立 checker + selftest 正负例），并以 Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 且断言 `[audit-gate]` 输出（自举实测）验证机器门行为有效。
- 背景/动机：`task-planaudit-20261116` 已落地文本审计门（SKILL.md:68-77 + Rule 109），CA-6 机器面当时仅为候选；用户 2026-11-16 授权实施并要求测试（user-session-log.md #1）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 计划审计门 | Rule 109 / SKILL.md 68-77 规定的定稿前 critic 审计机制，APPROVED=0 CRITICAL+0 IMPORTANT 且连续一轮零新发现 |
| `[plan-audit-R<N>]` | `progress.md` 中按 R 维度记录审计轮次/问题/修复/结论的留痕段，末段 APPROVED 为锁定判据 |
| `[plan-audit-skip]` | 仅轻量档（mini/L0/L0-T/L0-E）生效；L1+ 写 skip 仍拒锁，唯一逃生=`--skip-audit-check` 参数+WARN+交付披露 |
| 机器强门 | `attest-plan.sh` 锁定前硬校验门（失败 exit≠0 且不写 `.plan-attestation`）；区别于文本条款 |
| 独立 checker | `check-plan-audit-gate.sh` shell-out 判定器，rc 0/1/2 与 attest 门链同构，便于 fixture 测试 |
| 逃生旗标 | `--skip-audit-check`（仅 argv 参数同型，不提供 env 逃生），跳过检查并 WARN，纳入缓存键防陈旧 PASS 回放 |
| worktree 隔离 | 实现期在 `tmp/worktrees/task-auditgate-machine-20261116`（分支 `wt/...`）开发，完成后 merge back + deploy |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| attest 门链顺序与插入锚点 | `skills/task-planner/scripts/attest-plan.sh:540-562`（window-lint 后、`hash=` :562 前、写 attestation :570） | `[audit-gate]` 必须插在 window-lint 后 hash 前；失败不得写 `.plan-attestation` |
| skip/缓存范式四点一致 | `attest-plan.sh:26-31,32-45,88,93-99` | 新增 `--skip-audit-check` 须同步变量/参数/`_attest_cksum`/缓存回放 WARN；cksum 同时纳入 `skip_audit`+`TASK_PLANNER_AUDIT_GATE_ENFORCE`+`sha256(progress.md)`，否则 skip/档位翻转/留痕变更会回放陈旧 PASS |
| requirement-gate 现用 `grep -qm1 'plan_tier: mini'` | `attest-plan.sh:218` | 审计门档位判定不复用此粗匹配，改用精确 `^plan_tier:`/`^execution_lane:` 解析 |
| 精确档位解析契约 rc 0/1/2 | `skills/task-planner/scripts/check-tier-consistency.sh:60-63` | checker 采用 lane 优先：`execution_lane: L1/L2` 必审、mini×L1 按最严；显式 standard/full 必审；L0/L0-T/L0-E/mini 跳过；无声明输出显式 `[audit-gate] SKIP legacy-no-decl`（禁静默） |
| 先例 APPROVED 末段聚合命令 | `plans/archive/task-planaudit-20261116/verification.md:30`、`progress.md:119,148,194-195` | checker 复用 awk 末段 `^## \[plan-audit-R[0-9]+\] ` 聚合（转义形态以先例 verification.md:30 为准）+ `grep -q "结论: \*\*APPROVED\*\*"`；`-revision` 段自然排除；APPROVED 段还须含 `审计体:`+`轮次:`+`问题清单` 最小形态（`问题清单` 容忍括注，见本行 R7 I-1）；**R6a 加固（2026-11-17 主进程 /tmp 一手实测）：上述先例命令在中间态假阳性**——末段 buf 从最后一个 `[plan-audit-RN]` 头延伸到 EOF，会吞进后随修复轮块中**反引号内的元引用**（如修复轮收据自证行「无审计段级 `结论: **APPROVED**` 预写」），实测 `head -304` 截断态与「REJECTED 段 + 元引用修复轮块」fixture 均 rc=0 假 PASS（未审也放行）；checker 实现须 ① **聚合边界止于下一个 `## `（H2）行**（含 `## 2026-11-17 R<N> 修复轮`、`## 审计留痕占位` 等任何 H2）② **结论判定用 ERE 行首锚定** `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*`（禁匹配反引号内/行中元引用）；**存量先例档案不改写**（其验证时点恰为终态，同形态未暴露）；**R7 I-1 修正（2026-11-17）**：最小形态 token `问题清单` 须**容忍全角/半角括注后接冒号**（判据正则 `^- 问题清单([（(][^）)]*[）)])?:`，ERE）——唯一 APPROVED 段真实字节形态为 `- 问题清单（留档，不阻断）:`，按字面连写冒号判据会使 checker 对真实 plan-dir 恒 rc1；`审计体:`/`轮次:` 维持字面（真实段无括注，r7 fixture 覆盖）。**R7 I-2**：两约束各配独立负例——fixture a（REJECTED 段内裸文 `结论: **APPROVED**` 意见文本）抓「仅锚定实现」假 PASS、fixture b（后随 H2 块内含正规锚定 APPROVED 行）抓「仅边界实现」假 PASS。**R7 Q-1**：聚合边界仅认 `^## `（H2）——审计段后随块**必须用 H2 标题**（H3/粗体标题则边界不生效、约束静默退化；写作规范依赖，checker 注释须登记该前提）。**R7 Q-2**：`progress.md` 缺失/不可读=rc2（fail-open+WARN）、存在但空=无留痕 rc1。 |
| `[plan-audit-skip]` 已为既有 token | `skills/task-planner/SKILL.md:70`（1处）、`references/critical-rules.md:202,208`（2处） | 判别性不用 skip token 计数增量；语义=仅轻量档生效，L1+ 写 skip 仍拒锁；负例以“无 APPROVED 且无 skip 行”为基线 |
| checker rc=2 语义 | `check-tier-consistency.sh:1-70`、`check-vc-nonvacuous.sh:1-120` 先例 | rc2=fail-open+显式 `[audit-gate] WARN 判定器输入异常` 输出行（与既有 shell-out 先例一致），selftest 覆盖 |
| git 范围断言时点与路径 | 主仓工作树现有他任务未提交修改；本任务改动在 `tmp/worktrees/task-auditgate-machine-20261116` / `wt/` 分支（2026-11-17 R2 审计 N1 实测） | VC-6 范围断言必须用 worktree 路径 + `git ls-files --others` 纳入 untracked，且在 merge-back 前执行；部署位 diff 后置 V-5.2（N1） |
| 会话绑定脚本禁子代理执行 | `skills/task-planner/SKILL.md:56`（边界：`init-session.sh`/`attest-plan.sh`/`set-active-plan.sh` 等禁子代理执行） | 自举实测归主进程 Phase 5 S2，merge-back 后用主仓新 attest；子代理只做全量回归（N2） |
| 109.7 机器面禁令现文 | `skills/task-planner/references/critical-rules.md:210` | 不改写 109.7；追加 109.8 限定授权范围=attest [audit-gate]+checker+selftest，其余仍禁 |
| selftest 范式 ok/bad + mktemp fixture | `selftest-vc-nonvacuous.sh:29-174`、`selftest-tier-consistency.sh:1-138`、`selftest-plan-dispatch.sh:12-30` | 新 selftest 采用静态+行为、`/tmp` 夹具、trap 清理、`Total: PASS=x FAIL=y`、exit $FAIL |
| registry 4 列且 T02/T03/T05 约束 | `skills/task-planner/scripts/selftest-registry.tsv:1`、`selftest-registry.sh` | 必须新增 `selftest-plan-audit-gate.sh` 行，否则 T02 fail |
| 基线负断言（2026-11-16） | `grep -c audit-gate` attest/SKILL/critical-rules=0；`check-plan-audit-gate.sh` absent；`selftest-plan-audit-gate.sh` absent；registry 行=0 | VC-1/2/3/4 判别性成立；`plan-audit-skip` SKILL=1/rules=2 为既有基线 |
| config properties 键数 53 | `skills/task-planner/config.json`（既有 selftest-session-log SL-09 键数断言背景） | 审计门 enforce 采用 env-only `TASK_PLANNER_AUDIT_GATE_ENFORCE`，零新 config 键 |
| `grep -c` 零命中双零陷阱（R4 C-1，本机实测） | `grep -c '"audit' config.json` → 打印 `0` 且 exit 1；`$(... \|\| echo 0)` 追加第二个 0 → 变量=`0\n0` → `test` 报 `integer expression expected` rc=2 | 「未新增键」类断言禁写 `$(grep -c ... \|\| echo 0) -eq 0`；改 `test -f <file> && ! grep -q <pat> <file>`（缺文件 fail-closed、grep rc1 经 `!` 翻转为成功） |
| 本机 `grep` 实为 ugrep | `grep --version`（本轮 W-1 合成仓实测：ERE `(a\|b)$` 尾锚与 `-vE` 行为符合 POSIX） | `$` 尾锚与交替分组可安全使用；`grep -c` 零命中仍 rc=1（与 GNU 一致） |
| 全量 selftest 存量基线 7 FAIL（2026-11-17 实测，R4b 已冻结为对照集合） | `bash skills/task-planner/scripts/run-selftests.sh --fresh` → `Total: 99 PASS=92 FAIL=7 (run=99 reused=0)`；`Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability` | VC-6 已改判「**同集零增量**」：`Failed:` 集合==`task_plan.md` Phase 1 冻结 7 名单且 `FAIL=7`，**不判绝对 `FAIL=0`**（断言面仍全量回归、不缩子集）。7 条属他任务在途遗留（skills/** 面），执行期不得当作本任务回归失败；合法漂移须 `[baseline-shift]` 留痕 + 同步字面量，**禁静默放宽** |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `skills/task-planner/scripts/attest-plan.sh` | :26-45 | skip 旗标变量声明与参数解析（`--skip-*`） |
| `skills/task-planner/scripts/attest-plan.sh` | :84-99 | `_attest_cksum` 缓存键构造与缓存命中 WARN 回放 |
| `skills/task-planner/scripts/attest-plan.sh` | :540-562 | window-lint 末段与 `hash=` 取用（新 [audit-gate] 插入点） |
| `skills/task-planner/scripts/check-tier-consistency.sh` | :1-70 | `^plan_tier:`/`^execution_lane:` 解析、rc 0/1/2、`[tier-consistency]` 前缀（checker 范式源） |
| `skills/task-planner/scripts/check-vc-nonvacuous.sh` | :1-120 | rc 0/1/2 与 `[vc-nonvacuous]` 前缀、attest shell-out 同构范式 |
| `skills/task-planner/references/critical-rules.md` | :194-212 | Rule 109 审计门 109.1-109.7 + Why；:210 为机器面禁令（109.8 插入于 109.7 与 Why 间） |
| `skills/task-planner/SKILL.md` | :68-77 | 审计门文本条款区块（分档/裁决/迭代/留痕/阻断；补机器面一行） |
| `skills/task-planner/scripts/selftest-vc-nonvacuous.sh` | :29-174 | ok/bad 计数、mktemp 夹具、`Total: PASS=x FAIL=y`、exit 断言风格 |
| `skills/task-planner/scripts/selftest-tier-consistency.sh` | :1-138 | 静态锚+行为 fixture 双层结构 |
| `skills/task-planner/scripts/selftest-plan-dispatch.sh` | :12-30 | TMP+trap 清理、assert 辅助、attest 集成 fixture 形态 |
| `skills/task-planner/scripts/selftest-registry.tsv` | :1-5 | 4 列表头与登记行格式（新增 selftest 必登记） |
| `plans/archive/task-planaudit-20261116/progress.md` | :119-208 | R1/R2 REJECTED + R3 APPROVED 留痕段范式（末段聚合判据源） |
| `plans/archive/task-planaudit-20261116/verification.md` | :28-31 | VC-6 awk 末段 APPROVED 验证命令（纯命令、非真空） |

## §4 易错点与禁止假设清单
1. 禁止改写 109.7 原文；只能在 109.7 与 Why 段之间追加 109.8，且 `^### 109 ` 定义仍唯一（Rule 74 增量默认）。
2. 禁止把 `[plan-audit-skip]` 计数增量当判别性新 token——它在 SKILL/rules 已存在（1/2）；判别性以 `[audit-gate]`/`--skip-audit-check`/新文件为准。且 skip 仅轻量档生效：L1+ 写 skip 必须拒锁，唯一逃生=`--skip-audit-check` 参数+WARN+披露。
3. 禁止在 checker 中用粗匹配 `plan_tier: mini` 截断 L0-T/L0-E；必须行首锚定并识别 `L0|L0-T|L0-E|L1|L2` 与 `mini|standard|full`；lane 优先——`execution_lane: L1/L2` 必审，mini×L1 冲突按最严必审。
4. 禁止遗漏 `skip_audit`、`TASK_PLANNER_AUDIT_GATE_ENFORCE`、`sha256(progress.md)` 入 `_attest_cksum` 与缓存回放 WARN，否则 `--skip-audit-check`/档位翻转/APPROVED 追加都会命中旧 PASS 缓存。
5. 禁止在 selftest fixture 中污染真实 `plans/`、指针或账本；夹具一律 `/tmp` + trap 清理；正负 fixture 各用独立 task_plan 内容或每例清理 `/tmp/attest-cache-*`（缓存隔离用例覆盖 enforce→off→enforce 不复用）。
6. 禁止新增 config.json 键或改 properties 键数；enforce 仅 env-only `TASK_PLANNER_AUDIT_GATE_ENFORCE`。
7. 禁止把 Verify command 写成真空（`true`/`echo`/占位串）或含反引号；命令须引用本 VC 产出物且可执行。
8. 禁止在本计划落盘中预写 `[plan-audit-R<N>] APPROVED` 冒充 D1 走门实证；行为面实证由执行期 critic 审计真实产生。
9. 禁止把 rc2 当硬失败：rc2=fail-open+显式 `[audit-gate] WARN 判定器输入异常` 输出行；selftest 覆盖输入缺失用例。
10. 禁止 APPROVED 仅凭“结论: **APPROVED**”一行通过：末段还须含 `审计体:`+`轮次:`+`问题清单` 最小形态，缺任一=FAIL；**`问题清单` 判据须容忍全角/半角括注后接冒号**（真实段形态 `- 问题清单（留档，不阻断）:`；按字面连写冒号=对真实 plan-dir 恒误拒，R7 I-1）。
11. 禁止对无声明 legacy 计划静默跳过：checker 必须输出 `[audit-gate] SKIP legacy-no-decl`；Phase 5 交付披露登记存量迁移（9 无声明 +7 个 standard/L1 无留痕（未归档在途口径，含已 complete 未归档）；存量不重锁+首版 warn 起步建议）。
12. FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 2 缓存键未纳入 skip/enforce/progress 哈希」（RPN 160）、「Phase 5 回归 FAIL 或部署位不一致」（RPN 192）、「Phase 5 自举实测口径错配」（RPN 108）行。
13. 禁止在主仓工作树做范围断言：他任务未提交修改会无条件误判，且本任务改动在 wt/ 分支不可见；必须 worktree 路径 + `ls-files --others --exclude-standard` 纳入 untracked + merge-back 前执行（N1）。范围断言命令本体在 task_plan.md「Phase 5 S2 内嵌命令」（fail-closed：worktree 缺失/git 失败/grep rc≥2/越界均 exit1 且不写 PASS 行）；**唯一权威证据=Phase 5 S2 merge-back 前追加的 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 行**（S2 命令为 `echo ... >> progress.md` 文件末尾追加，留痕归属 Phase 5 段仅为语义归属），VC-6 Verify 仅复核留痕（**全文件严格 token 正则** `^\[scope-check\] <ISO8601> SCOPE-OK diff=N untracked=N$`——**禁用段锚 awk**：段锚只读 `### Phase 5:` 区间，会让 EOF 追加的留痕恒落段外致终验必 FAIL，R5 I-1 实证），**不得 live 断言 worktree 存续**（R4 I-1：S2 强制清理后 live `test -d "$WT"` 必败）。白名单文件级分支必须尾锚 `$`（否则 `SKILL.md.bak` 类副产物静默放行，R4 W-1）；`grep` rc 必须显式捕获（仅 0/1 合法，rc=2 须 exit1，R4 N-1）。
14. 禁止自举实测由子代理执行或在 merge-back 前用主仓旧脚本跑：执行体=主进程，时点=merge-back 后，路径=主仓新脚本，断言=rc0 + `grep [audit-gate]` 实质行（N2；SKILL.md:56 会话绑定脚本禁子代理）。
15. 缓存命中率取舍：progress.md 进 cksum 使命中率归零，是正确性优先的有意设计；不得为性能回退（N6）。
16. Q-1/Q-2 契约（R7 固化）：聚合边界仅认 `^## `（H2）——**审计段后随块必须用 H2 标题**（H3/粗体标题则边界不生效、两约束静默退化；checker 注释须登记该前提；本计划 progress.md 修复轮/登记块均按 `## ` H2 追加）；`progress.md` **文件缺失/不可读=rc2**（fail-open + 显式 `[audit-gate] WARN 判定器输入异常`）、**存在但空=无留痕 rc1**——两者语义不同，selftest 的「rc2 输入缺失」用例须**删除文件**（非清空文件）。
17. 最小形态 token 须匹配生产字节形态（R7 I-1）：判据不得只按规范示意形态（`- 问题清单: 无`）编写；须以真实留痕段字节形态（如 `- 问题清单（留档，不阻断）:`）做**正例 fixture**，否则 checker/selftest 与真实 plan-dir 脱钩（VC-5 自举实测必失败）。`审计体:`/`轮次:` 当前无括注风险，维持字面。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-S1 | §1 + §2(A,B,C) + §3(attest/tier/archive) | `skills/task-planner/scripts/attest-plan.sh`、`skills/task-planner/scripts/check-tier-consistency.sh`、`plans/archive/task-planaudit-20261116/progress.md` |
| P1-S2 | §1 + §2(D,E,F) + §3(selftest/registry/rules/SKILL) | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh`、`skills/task-planner/scripts/selftest-tier-consistency.sh`、`skills/task-planner/scripts/selftest-registry.tsv`、`skills/task-planner/references/critical-rules.md`、`skills/task-planner/SKILL.md` |
| P3-S1 | §2(A,B,C) + §3(checker 范式/attest 锚点) + §4(3,9,10) | `skills/task-planner/scripts/check-tier-consistency.sh`、`skills/task-planner/scripts/attest-plan.sh`、`plans/archive/task-planaudit-20261116/verification.md` |
| P3-S2 | §2(A,B) + §3(attest skip/cksum/hash) + §4(4,6,9) | `skills/task-planner/scripts/attest-plan.sh`（:26-45,84-99,540-562,570） |
| P3-S3 | §2(D,F) + §3(selftest 范式/registry) + §4(2,5,6,10) | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh`、`skills/task-planner/scripts/selftest-tier-consistency.sh`、`skills/task-planner/scripts/selftest-plan-dispatch.sh`、`skills/task-planner/scripts/selftest-registry.tsv` |
| P4-S1 | §2(E) + §3(critical-rules 109) + §4(1,2) | `skills/task-planner/references/critical-rules.md:194-212` |
| P4-S2 | §2(E) + §3(SKILL 审计门/registry) + §4(1) | `skills/task-planner/SKILL.md:68-77`、`skills/task-planner/scripts/selftest-registry.tsv` |
| P5-S1 | §2(D,F) + §4(5,6,7,9,10) | `plans/task-auditgate-machine-20261116/verification.md`、`plans/task-auditgate-machine-20261116/task_plan.md`（VC Verify commands） |
| P5-S2 | §1 + §4(8,11) + §2(C) | `plans/task-auditgate-machine-20261116/progress.md`（执行期由 critic 写 [plan-audit-R<N>]）、`plans/archive/task-planaudit-20261116/progress.md` |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 本任务为 rule-enhancement 计划落地，需遵循 SKILL 门控/VC/attest 契约 | 主进程/子代理按需 Read（Skill 调用） |
| verification-before-completion | `/home/terry/.zcode/skills/verification-before-completion/SKILL.md` | P5 回归与完成声称前证据闭环 | 子代理 prompt 挂载 |
| systematic-debugging | `/home/terry/.agents/skills/systematic-debugging/SKILL.md` | checker/attest/selftest 负例失败时根因定位 | 子代理按需触发 |
| test-driven-development | `/home/terry/.agents/skills/test-driven-development/SKILL.md` | selftest 正负例 fixture 先于实现/伴随实现设计 | 子代理按需触发 |
| receiving-code-review | `/home/terry/.agents/skills/receiving-code-review/SKILL.md` | D1 critic 审计反馈处理与修订收敛 | 子代理/主进程按需 |
| comet | `/home/terry/.zcode/skills/comet/SKILL.md` | 复杂实施调度（若用户选择） | 用户手动触发（仅提示） |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/archive/task-auditgate-machine-20261116` → 生成 `knowledge/entries/_draft-task-auditgate-machine-20261116.md`
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 `knowledge/README.md` 与 `knowledge/entry-template.md`（主题级合成、Rule 71 无源不写、sources 仓相对路径）

## §8 微修轮 4b 教训补录：回归判据设计（2026-11-17）

| 教训 | 事实/证据 | 对计划设计的影响 |
|------|----------|------------------|
| **绝对零判据在共享仓必被击穿** | 本仓 `run-selftests.sh` 覆盖 `skills/task-planner/scripts/` 全部 selftest，其中 7 条属他任务在途未实现面（如 `selftest-registry` 待 `selftest-md-edit-ops.sh` 落地）。本任务 VC-6 若写「`FAIL=0`」，Phase 5 终验必 FAIL，outcome 强制非 COMPLETE | 跨任务共享仓的回归 VC 必须写成「**冻结基线集合 + 判无新增**」（同集零增量），并在计划期把基线 `Total:`/`Failed:` 行原文冻结成对照块；禁把绝对零写进 VC |
| **「同集」必须同时断言计数 + 名单整行** | R4b 干跑 TC-B2：计数仍 `FAIL=7` 但把 `self-resolution` 换成 `fake-swap`，仅断言 `FAIL=7` 会误放行；加 `^Failed: <7 名单>$` 整行等值后 rc=1 | 回归断言= `Total` 行 `FAIL=N` **且** `Failed:` 行两端锚整行等值；只做计数断言 = 可被「同数不同集」绕过 |
| **冻结必配漂移凭据条款** | 他任务随时可能收口，硬编码 `FAIL=7`/名单会在执行期合法失真；无条件放松又等于开规避口 | 计划必须同步写 `[baseline-shift] <ISO8601> <新 Total> | <新 Failed> | <原因>` 留痕条款，并要求同步更新冻结块与 Verify command 字面量；「未留凭据而判据松动=违规」，把放松变成需审计的动作 |
| **判据变更要扫全同义面** | 同一判据在本计划散在 6 处（R→VC 映射 / VC-6 行 / G5 单元表 / Phase 5 步骤 / S-unit 验收 / Notes），另有 verification 的判据+Evidence+Verify+Gogate | 改判据=全量 grep 同义词（`FAIL=0`/`0 FAIL`/`回归`）扫全仓计划文件后逐处改，否则下一轮审计必抓残留矛盾 |

## §9 修复轮 5 教训补录：断言时序与产出位置互洽（2026-11-17）

| 教训 | 事实/证据 | 对计划/测试设计的影响 |
|------|----------|----------------------|
| **断言捕获时点必须紧跟各自用例** | VC-2 原形把负例断言组写在正例执行之后，而正例在同一 `$T` 建 `.plan-attestation` → `test ! -f` 恒假 → n 恒=1 → 整命令无 PASS 路径（R5 C-1；/tmp mock 实测 old rc=1 / new rc=0，插桩显示 old `n=1` vs new `n=0`） | 多用例共享 fixture 的命令，**每用例的断言必须紧随其执行并立即捕获到独立变量**（`n=$?`/`p=$?`），末尾只汇总变量；或每用例独立 `$T1/$T2`。写命令后必须按真实顺序推演「谁先建了什么共享状态」 |
| **产出物写入位置必须与消费断言的定位方式互洽** | S2 用 `echo ... >> progress.md` 文件末尾追加，VC-6 却用 awk 只读 `### Phase 5:` 段 → 留痕恒落段外，终验必 FAIL（R5 I-1；三态实测：段内 rc=0 / EOF rc=0（全文件形态）/ 无留痕或畸形 rc=1） | 判定「留痕断言」前先确定产出的物理写入位置：文件末尾追加 → 用**全文件严格 token 正则**（`^\[scope-check\] <ISO8601> SCOPE-OK diff=N untracked=N$`）；仅当产出确实定向插入某段时才可用段锚。S-unit 验收的 grep 若位置不敏感，会掩盖该缺陷——验收须与终验断言同形态 |
| **漂移条款需「逐名归因 + 独立复核」双闸** | 仅凭一行 `[baseline-shift] <原因>` 自述即可改判据字面量 → 本任务自身新增 FAIL 也能以「他任务收口」名义吸收（R5 W-1） | 冻结-漂移类条款必须写双闸：① 逐名归因（新增/消失的每个名单条目指认他任务/提交锚，无法指认的新增 FAIL 不得吸收）；② 漂移后重走独立文本审计（critic 简版复审并留痕），禁主进程自裁 |
| **stale 状态块要与簿记同步改** | 微修轮 4b 只同步了 task_plan 的 Current Phase/Next Step，verification.md 的 5-Question Reboot Check 仍停在「R1 REJECTED / R2 复审待跑」（R5 W-2） | 每次轮次推进，`Current Phase`/`Next Step`/`5-Question Reboot Check`/交叉验证记录四处**同时**更新；会话恢复读的是这些块，过期块=错误断点 |
| **时点性 gate 必须标注适用期** | V-1.1 基线负断言（`audit-gate` 计数=0 + checker 不存在）在 Phase 3 落地后天然为假（R5 Q-1） | 基线类 gate 行尾必注「仅 <时点> 执行；产物落地后自然失效，终验不复跑本 gate」，避免终验复跑误判 |
