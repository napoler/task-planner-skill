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

#### [sub:main-recon] 插入锚与冲突面侦察（2026-10-10 09:5x，Phase 1）
- critical-rules.md 文末=Rule 71 段（:928-942，EOF），Rule 73 追加位；段标题范式=Rule 71 形（`### 73`+`73.x` 内联编号）
- 规则账本 plans/.rule-reservations.jsonl tail：71=landed(v158)/72=reserved(v160 在途)/**73 空闲**（plans/.rule-reservations.jsonl 末四行）
- SKILL.md 级联点：:9 计数「1-69+70」（v158 漏改的存量缺陷）/:295 详见行/:355 Rule 71 bullet/:381 References 行/C 清单 tail=C50(:231)→C51
- check-complete.sh [judge-gate] 插入位=:1323 goal-gate 段后（standard/full 档三分支范式）
- zcode-posttooluse.sh [judge] 注入位=:336-345 due=1 emit 块（随 drift-rhythm 同发、单行 JSON、env 降档；范式同 :341-347 [context-pressure] TASK_PLANNER_CONTEXT_PRESSURE）
- templates/task_plan.md 🔒 区块插入位=:20 根源覆盖表后/:30 Goal 前
- config.json properties=42（零新键基线）；CLAUDE.md:33/README_zh.md:136,229 计数标签已 1-71（v158 改过）
- 并行事态：worktree v159(2f27fcb)/v160(8f39e23) 在飞；v160 将占 Rule 72+其 SKILL :9 计数将改「1-72」→v156 写「1-71+73」并集可解
- 关键教训（本会话实证）：attest-plan.sh 未带显式路径时经 env sid 解析链误锁其他计划（详见 progress.md Error Log + FMEA RPN=84 行）

#### [main:attest-incident] 误 attest 事故根因与还原（2026-10-10 09:50）
- 现象：attest-plan.sh 无参运行 → env CLAUDE_CODE_SESSION_ID(de2c5bba) 命中 side 指针 v159 → v159 计划被重锁
- 根因：env sid 与 hook sid 双命名空间分叉（env=de2c5bba / hook=5a364a28）；无参调用时解析链不感知当前活跃计划
- 还原：v159 计划内容 09:02 后未动→SHA 575c5d73 不变=功能无损；用 v159 属主 sid(cbab959) 重跑 attest 恢复 attested_by_sid 元数据
- 防线：attest 恒带显式 plan 路径参数；已登记 FMEA RPN=84 行兜底

#### [sub:03-executor-S1] Rule 73 七子条追加落位 critical-rules.md（2026-10-10，Phase 3 S1）
- 动作：在 worktree `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/references/critical-rules.md` 文末（原 :942 Rule 71.7 行之后=EOF）逐字追加 design-draft.md §1 的 Rule 73 全文（`### 73` 块头 + 73.1-73.7 七子条）
- 结果：文件 942→958 行（+16）；`grep -cE '^73\.[1-7] '`=7；`grep -c '^### 73 执行期决策对齐与不变量纪律'`=1（块头落位 :944）；`grep -c '对齐'`=43
- 纯增量证据：`git diff --numstat`=16 0（+16/-0）；hunk `@@ -942,0 +943,16 @@`（仅 EOF 追加，Rule 1-71 既有行零改动，符合 Rule 36.3 纯增量纪律）
- 逐字采用源：plans/task-v156-drift-shield/design-draft.md:39-55（§1 代码块，含块头与七子条）

#### [sub:04-executor] SKILL.md K1-K6 接线 + task_plan 模板 🔒 不变量声明区（2026-10-10，Phase 3 S2）
- 动作：worktree `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment` 内两文件接线——① `templates/task_plan.md` 在根源覆盖表段后/Goal 段前插入「🔒 不变量声明区」区块（材料包 A 节逐字，纯插入）；② `SKILL.md` K1-K6 接线（:9 存量漏计修复 1-69+70→1-71+73；:296 详见行 1-71→1-71+73+列举尾补；:356 后新增 Rule 73 摘要 bullet；:383 References 行 1-71→1-71+73+尾补；C50 后新增 C51 行；委派检查点段末 + 用户新指令处理 D 类表后各加一行 73 引用）
- 结果：`grep -c "Rule 73"`=5（≥4）；`grep -c "C51"`=2（≥1）；`grep -c "1-71+73"`=3（≥1）；模板 `🔒 不变量声明区` 命中 :31；三关键词 不变量=4 / 可变量=2 / 学得量=2（各≥1）
- 纯增量证据：`git diff --numstat`=SKILL.md 8 3 / templates/task_plan.md 10 0（仅两目标文件；SKILL.md 3 处 `-` 均为原地计数/括注改写行，非内容删除）
- 逐字采用源：plans/task-v156-drift-shield/subagent-state/04-executor-S2-materials.md（A 节模板区块 + B 节 K1-K6）

#### [sub:05-executor] templates/deprecated.md 五段废弃模板新建（2026-10-10，Phase 3 S3）
- 动作：worktree `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment` 内新建 `skills/task-planner/templates/deprecated.md`（Rule 73.5 废弃隔离区载体，templates/ 第 12 成员），逐字采用 design-draft.md §2 代码块（:62-93，32 行）
- 结构：头部 WHAT/WHY/WHEN 三要素注释+notepad 分账说明；五段=① 废弃条目登记表（DEP-001 占位，六列含五要素）② 分账说明（与 notepad/四文件罗盘边界）③ 只入不出规则 ④ 消费侧契约（改动前必查双源）⑤ 消歧义词条（Rule 73.6 示范）
- 结果：五段标题 `grep -cE '^## [1-5]\.'`=5；`grep -c '废弃'`=14（≥5）；五要素各≥1（原内容指针2/废弃类型5/废弃原因2/日期3/替代锚2）；WHAT/WHY/WHEN 各=1；分账=2
- 逐字证据：`diff <(sed -n '62,93p' design-draft.md) deprecated.md` → VERBATIM_IDENTICAL（零差异）
- 纯增量证据：`git diff --no-index --numstat /dev/null deprecated.md`=32 0（+32/-0）；worktree `git status --porcelain` 仅 `?? skills/task-planner/templates/deprecated.md` 一行（S1/S2 已提交 917ff95/759f8cb，工作树无其他改动）
- 逐字采用源：plans/task-v156-drift-shield/design-draft.md:62-93（§2 代码块）

#### [sub:06-executor] D4 双承载改造：check-complete.sh [judge-gate] + zcode-posttooluse.sh [judge] 注入（2026-10-10，Phase 3 S4）
- 动作：worktree `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment` 内两脚本改造——① `skills/task-planner/scripts/check-complete.sh` 在 goal-gate 段 `fi`（:1323）后、warn count 段（:1325 注释）前插入 design-draft §4.1 [judge-gate] 段（逐字，纯插入）；② `skills/task-planner/scripts/zcode-posttooluse.sh` due=1 emit 块内，[context-pressure] `_cp` 段后追加 `_jr` 段并将 emit 行尾 `${_cp}`→`${_cp}${_jr}`（逐字 §4.2）
- 结果：`grep -c '\[judge'` check-complete=6 / posttooluse=1（各≥1）；check-complete 含 `[judge-gate]` 前缀 + `TASK_PLANNER_DECISION_JUDGE`；posttooluse 含 `[judge] 变更型决策点评判`；`bash -n` 两脚本 rc=0
- 冒烟证据（fresh 计划 + `TASK_PLANNER_DRIFT_RHYTHM_N=1` 强制 due=1）：输出合法单行 JSON，additionalContext 含 drift-rhythm + context-pressure + `[judge] 变更型决策点评判（Rule 73.1/73.4）…`；`TASK_PLANNER_DECISION_JUDGE=off` 时 [judge] 段零追加（JUDGE_PRESENT=no，向后兼容）
- 纯增量证据：`git diff --numstat`=check-complete 18 0 / posttooluse 5 1；posttooluse 唯一 `-` 行=§4.2 指定 emit 行替换（原文 `${_cp}` 全保留 + 尾附 `${_jr}`，非行为删除）；`git diff --name-only` 仅两文件
- ⚠️ 发现（design-draft §4.1 逐字源潜在缺陷，未擅改，待协调者裁决）：`_jl="$(grep -c '\[judge\]\|\[align\]' ... || echo 0)"` 中 `|| echo 0` 位于命令替换内——零匹配时 `grep -c` 打印 "0" 且 exit 1（ugrep 7.8.4 与 GNU grep 同），故 `_jl` 捕获为 "0\n0"；`[ "$_jl" -eq 0 ]` 报 "integer expression expected" 且判假 → 走 else 分支打印 `[judge-gate] OK (... 0\n0 行 ...)`，即 warn 档永不告警、enforce 档永不 exit 1（门控对目标失败面失效）。同文件既有正确惯用式=:988 `|| true`（替换内）/ :1124 `|| reflect_lines=0`（替换外）。修法=§4.1 内 `|| echo 0`→`|| true`（1 token 变更）。
- 逐字采用源：plans/task-v156-drift-shield/design-draft.md:117-149（§4.1/§4.2 代码块）

#### [sub:06b-executor] [judge-gate] 计数行鲁棒化修复（2026-10-10，Phase 3 S4 修正）
- 缺陷复现：`_jl="$(grep -c '\[judge\]\|\[align\]' ... 2>/dev/null || echo 0)"` 零匹配时 `grep -c` 打印 "0" 且 exit 1 → `|| echo 0` 再补一行 → `_jl` 捕获 `"0\n0"`；`[ "0\n0" -eq 0 ]` 报 `integer expression expected` 且判假走 else，warn 档永不告警 / enforce 档永不 exit 1（门控对目标失败面静默失效，违 Rule 51.1a R3 需求锚）
- 修法（唯一目标文件 `skills/task-planner/scripts/check-complete.sh` [judge-gate] 段 2 行）：计数行 `|| echo 0`→`|| true`（命令替换内不再补行），并紧接 `case "$_jl" in ''|*[!0-9]*) _jl=0 ;; esac` 归零非数字（含空串）
- 隔离 diff 证据：received-state vs current = 仅 1 行删 / 2 行增（`@@ -1330,7 +1330,8 @@`，仅 `_jl` 行，[judge-gate] 段其余零改动）
- 验证证据：`bash -n` rc=0；`grep -c '\[judge'`=6（≥1）；单测零匹配 captured=[0] 且 `[ 0 -eq 0 ]` 无报错 rc=0 / 含 [judge] 文件 captured=[2] 走 OK 分支 / 缺失文件捕获空→归零；enforce 零留痕 exit=1（真阻断）/ off SKIPPED exit=0 / warn 零留痕 exit=0（提示不阻断）
- 冒烟方法：awk 从生产脚本抽取 [judge-gate] case 块逐字入 /tmp harness（禁改生产逻辑），PLAN_DIR_GUESS 指向零留痕 progress.md

#### [sub:07-executor] selftest-decision-drift.sh 新建（DD-01~22）+ registry 登记行（2026-10-10，Phase 3 S5）
- 动作：worktree `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment` 内 ① 新建 `skills/task-planner/scripts/selftest-decision-drift.sh`（chmod +x，范式沿用 selftest-drift-enforcement.sh 的 ok/bad/cnt + DCE-10 部署自适应）；② `selftest-registry.tsv` 末行（第 72 行 selftest-pointer-lifecycle.sh）后追加 1 行（四列 TSV：script/domain/trigger_scenarios/dep_anchors）
- 断言面：DD-01~09=critical-rules Rule 73 块头/七子条=7/分类锚/三问+[align]/三态+🔒/评判点+[judge]/只入不出/消歧义/零新键 env；DD-10~11=deprecated.md 五段标题+五要素；DD-12~13=模板 🔒 区块+三态关键词；DD-14~15=check-complete [judge-gate]+posttooluse [judge] 注入+env；DD-16~17=SKILL Rule 73≥4+C51；DD-18=registry 自登记=1；DD-19=本计划 dogfood 🔒 区块（部署位 SKIP=PASS）；DD-20=config properties=42；DD-21=SKILL 宽锚 1-7[0-9]；DD-22=[align]/[judge] 留痕格式锚
- 验证证据：`bash -n` rc=0；`bash skills/task-planner/scripts/selftest-decision-drift.sh`（worktree 根）→ 22 行全 `PASS`，末行 `Total: 22 PASS=22 FAIL=0`，`EXIT=0`；`grep -c 'decision-drift' selftest-registry.tsv`=1（awk 列数 NF=4）
- 纯增量证据：`git status --short`=仅 ` M selftest-registry.tsv`（+1 行）+ `?? selftest-decision-drift.sh`（新文件，权限 -rwxrwxr-x）；`git diff --numstat` registry=1/0
- 关键设计决策：DD-19 计划文件解析链=worktree/主仓仓根 `plans/task-v156-drift-shield/task_plan.md` 优先，回退本仓绝对路径，均缺失=部署位 SKIP 计 PASS（DCE-10 范式，防仓级文件缺席污染回归）；DD-20 用 `jq '.properties|length'`=42，jq 缺失打 SKIP 计 PASS（同 selftest-requirement-coverage RC-13 口径）；DD-16 计数用 `grep -c 'Rule 73'`（按行计），DD-04 用三问+[align] 命中合计（实测 8）≥3 宽判
- 机器边界（同 73.7）：本守护只锚定规则条/模板区块/留痕格式/门控接线存在性，73.1 分类与 73.2 三问语义面不可静态机检

#### [sub:09-runner] S6 独立复验：selftest 22/22 + judge-gate 三档 + hook 冒烟 + config=42（2026-10-10 13:1x，Phase 4）
- 被测（worktree /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment）：任务书 `scripts/*` 实际落位=skills/task-planner/scripts/{selftest-decision-drift.sh,check-complete.sh,zcode-posttooluse.sh}；config=skills/task-planner/config.json
- ①selftest 独立复跑（cwd=worktree 根）：`bash skills/task-planner/scripts/selftest-decision-drift.sh` → EXIT=0；末行原文 `Total: 22 PASS=22 FAIL=0`（DD-01~22 逐行 PASS，日志 /tmp/selftest-v156-verify.log）
- ②bash -n rc：check-complete.sh=0；zcode-posttooluse.sh=0；selftest=0
- ②[judge-gate] 三档（check-complete.sh:1325-1342 字节抽取入 /tmp harness；`diff <(sed -n '3,20p' harness) segment.txt`=EXTRACTION_BYTE_EXACT；sha256=539badc46a82dcbef61efea77105d6f493ce5d1c150b9473d1af8eb4c0b4433c 双端一致）：off → `[judge-gate] SKIPPED (env TASK_PLANNER_DECISION_JUDGE=off)` rc=0；warn+零留痕 → `[judge-gate] ✗ progress.md 无 [judge]/[align] 留痕行 …` 不阻断 rc=0；enforce+零留痕 → 同 ✗ 行 + rc=1（真阻断）；enforce+含留痕 → `[judge-gate] OK ([judge]/[align] 留痕 2 行, Rule 73.4)` rc=0；缺省(未设 env) → warn 语义 rc=0
- ②hook 冒烟 A（任务书形态 stdin：cwd=worktree/session_id=v156smoke/tool_name=Read）：rc=0；stdout=0 字节（空，验收允许）、stderr=0 字节；解析计划=worktree/plans/task-v152-proactive-context；空输出成因=已交付计划静默 guard 命中 `verification.md:55 - **outcome: COMPLETE**`（age≈9451s，非 24h 链）；副产 plans/.drift-rhythm/v156smoke.state（gitignored，见 .gitignore:11）已取证后清除，worktree git status 前后均空
- ②hook 冒烟 B（/tmp 字节同源副本 sha256=58d23c412aeb68f58c182c1e88d81c1d9950055e2b92cfdd60030323f99fd135 == 生产；fixture cwd + TASK_PLANNER_DRIFT_RHYTHM_N=1 强 due）：物理单行 JSON（wc -l=1 / jq -e OK / jq -sc length=1），additionalContext 含 `[drift-rhythm]…` + `[judge] 变更型决策点评判（Rule 73.1/73.4）…`；TASK_PLANNER_DECISION_JUDGE=off 复跑 → [judge] 零出现、drift 行仍在（降档生效）
- ②副证（非计划内）：B 二跑因 fixture plan mtime 16min>15min 命中 priority-1 → plan-sync 单行 JSON（合法）；该轮 drift due=1 持久（state=count2/last_inject2/due1）→ 下一轮投递，F9/F10/N1 语义亲验
- ③`jq -r '.properties|length' worktree/skills/task-planner/config.json` = 42（与 DD-20 同值）
- 负结果：未发现目标外缺陷；未覆盖=全量 71 脚本回归（S7 范围）、Phase 4 其余 S-unit；progress.md 当前无「Phase 4」段（仅 Phase 1-3），按写契约未创建段/未追加行（本结论落 findings+checkpoint）

#### [sub:10-runner] S7 全量回归 72 脚本 vs 基线：5 个既有脚本 rc=1 非零新增（SKILL 计数锚 +73 级联断裂）（2026-10-10 16:0x，Phase 4）
- 跑批（cwd=worktree 根，HEAD=f6bf03e）：`for f in skills/task-planner/scripts/selftest-*.sh; do out=$(timeout 180 bash "$f" 2>&1); rc=$?; total_line=$(printf "%s\n" "$out" | grep -E "^Total:" | tail -1); printf "%s rc=%s | %s\n" "$f" "$rc" "$total_line" >> plans/task-v156-drift-shield/regression-v156.log; done` → 72 行 `skills/task-planner/scripts/<name>.sh rc=N | Total: …`（产物 regression-v156.log，72/72 行有 Total 行，无超时/缺行）
- Σ awk 逐行求和：基线（71 脚本）`PASS=1039 FAIL=0` → 回归（72 脚本）`PASS=1056 FAIL=5`（自洽核 1039+22−5=1056）；rc 对照：66/71 既有脚本 rc=0 保持不变 + 新脚本 rc=0 + 5 既有脚本 0→1
- 新脚本行：`skills/task-planner/scripts/selftest-decision-drift.sh rc=0 | Total: 22 PASS=22 FAIL=0`
- ⚠️ 5 个既有脚本 rc=1（基线全 rc=0；worktree 根独立复跑 5/5 复现）：`drift-check-subagent rc=1 | Total: 20 PASS=19 FAIL=1` / `parallel-scheduling rc=1 | Total: 9 PASS=8 FAIL=1` / `reliability-institution rc=1 | Total: 16 PASS=15 FAIL=1` / `research-first rc=1 | Total: 12 PASS=11 FAIL=1` / `root-resolution rc=1 | Total: 17 PASS=16 FAIL=1`
- 5 条 FAIL 原文：`DCS-11 FAIL DCS-11 条件缺失`；`P-05 FAIL …上界 skill=71 vs critical=73（应相等）`；`R-09 FAIL SKILL.md 括注锚漂移（含 Rule 40-[567][0-9] 全集=0 应 ≥1 / 1-40=0 应 0）`；`RF-07 FAIL SKILL 双锚…(got=(1,0) expect=(>=1,>=1))`；`RR-09 FAIL SKILL.md 全集 1-(5[3-9]|6[0-9]) 命中=0（应 =1）`
- 因果验证（`git show a538a3a:skills/task-planner/SKILL.md | grep` vs HEAD 同 pattern）：DCS-11 `Rule 40-(69|71) 全集` 1→0；RF-07 `Critical Rules 1-71（含 Rule 40-(65|69|71) 全集` 1→0；R-09 `含 Rule 40-[567][0-9] 全集` 1→0；RR-09 `Critical Rules 全集 1-(5[3-9]|6[0-9])` 1→0（OLD 原文 `…Critical Rules 全集 1-69+70（67-70 均经…`）；P-05 skill_max=71==crit_max=71 → 71 vs 73（S1 新增 Rule 73 致 crit_max=73）
- 根因：S2 K1-K6 把 SKILL.md 计数锚改为 `1-71+73` / `40-71+73 全集`（:9/:300/:387），`+73` 插入破坏 5 个既有守护脚本的宽容锚相邻性匹配 + P-05 动态上界解析（`grep -oE 'Critical Rules 1-[0-9]+'` 取 71）；v149/v151/v154/v158 判例=计数级联必全仓 grep 更新消费断言（本任务 S2 未级联更新这 5 个脚本）
- 禁改清单约束：本单元未改任何源文件（只读跑批+仅写 regression 日志）；修复方向（协调者裁决）：① 5 脚本宽容锚随动（如 40-7[0-9] / ERE 补 +7[0-9] 交替、P-05 解析器兼容 `1-N+M` 写法）或 ② 调整 SKILL 计数行文——任一方案修复后需重跑 S7 复验
- properties 复核：`jq -r '.properties|length' worktree/skills/task-planner/config.json` = 42（零新键）
- 负结果：未发现跑批执行层面异常（无 timeout、无 Total 缺失行、worktree git status 前后干净）；rc 差异全部可归因上述 SKILL 锚级联，未见其他环境/并发因素

#### [sub:11-executor] S9 五脚本宽容锚随动修复（K9 落地）：1-71+73 插入形态全覆盖（2026-10-10，Phase 4）
- 目标：修 5 个存量 selftest 的 SKILL 计数锚/上界解析，覆盖 SKILL.md「1-71+73」/「40-71+73 全集」插入形态；逐字源=design-draft §6 K9 行
- 改动（5 文件各 1 行，纯 pattern 替换，无新增/删除行）：drift-check-subagent DCS-11 `Rule 40-(69|71) 全集`→`Rule 40-(69|71|73)(\+[0-9]+)? 全集`；reliability-institution R-09 `含 Rule 40-[567][0-9] 全集`→`含 Rule 40-[4567][0-9](\+[0-9]+)? 全集`；root-resolution RR-09 `Critical Rules 全集 1-(5[3-9]|6[0-9])`→`Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`；parallel-scheduling P-05 `Critical Rules 1-[0-9]+`→`Critical Rules 1-[0-9]+(\+[0-9]+)?`；research-first RF-07 第二锚 `Critical Rules 1-71（含 Rule 40-(65|69|71) 全集`→`Critical Rules 1-71(\+[0-9]+)?（含 Rule 40-(65|69|71)(\+[0-9]+)? 全集`
- 复验（worktree /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment，cwd=worktree 根）：5 脚本 rc 0→全 0——drift-check-subagent `rc=0 | Total: 20 PASS=20 FAIL=0`；reliability-institution `rc=0 | Total: 16 PASS=16 FAIL=0`；root-resolution `rc=0 | Total: 17 PASS=17 FAIL=0`；parallel-scheduling `rc=0 | Total: 9 PASS=9 FAIL=0`；research-first `rc=0 | Total: 12 PASS=12 FAIL=0`
- 全量回归（72 脚本）：`SCRIPTS_RUN=72 NONZERO_RC=0`——零非零 rc，未破坏任何既有守护面（R2 需求锚：证明新增未破坏既有守护面）
- 负断言保留核验：root-resolution `m=grep -cE '(全集|Rules) 1-(51|53|55)'` 断言行仍在（:111）且 SKILL.md 命中=0；reliability `b=grep -c '1-40'` 断言行仍在（:86）且 SKILL.md 命中=0——判据语义未放宽
- 新锚在 SKILL.md 实测命中：`Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`=1；`(全集|Rules) 1-(51|53|55)`=0；`含 Rule 40-[4567][0-9](\+[0-9]+)? 全集`=1；`1-40`=0；P-05 抽数 max=73（=critical-rules 实测 max 73）；RF-07 第二锚新 pattern=1
- diff 核对：`git diff --numstat`=5 文件各 `1 1`；`git status --short` 仅 5 个 selftest 文件 M
- 负结果：未发现 5 脚本以外的文件被改动；未发现负断言被删除/放宽；未发现全量回归出现新非零 rc

#### [sub:13-executor] CR S8 三修（S10）：judge-gate 档位门控 + DD-14b 断言 + SKILL 分隔符（2026-10-10，Phase 5）
- 目标：修 CR S8 驳回三项——①MAJOR check-complete.sh [judge-gate] 缺 plan_tier 档位门控（F1）②MINOR selftest DD-14 未守护档位门控（F2）③Nit SKILL.md:387 References 表 Rule 73 拼接缺 "/" 分隔。需求锚（51.1a）=R3「周期性评判数据、及时发现错误」；档位门控=让评判点不误伤 mini 档轻任务（豁免契约=C51/SKILL:234）
- ① 改动（逐字源=design-draft §4.1 新版）：check-complete.sh [judge-gate] 段（原 :1325-1342）整体替换为外层 `if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then` 包裹原 case 块（同 :1288 goal-gate 门控范式），else 分支输出 `[judge-gate] SKIPPED (mini 档豁免或计划无 plan_tier: standard|full 标记, Rule 73.4/C51)`；旧裸 case 块零残留（`grep -c '^    case "${TASK_PLANNER_DECISION_JUDGE'`=0，新形态 6 空格缩进 case 在位）
- ② 改动：selftest-decision-drift.sh 新增 DD-14b——awk 抽 judge-gate 段（锚段头 `[judge-gate]` 注释至 `Rule 73.4/C51` else 分支），断言段内含 plan_tier 前置门 + standard|full 判据；头部注释 DD-01~22→+DD-14b、Total 行 22→23
- ③ 改动：SKILL.md:387 `Rule 65 周期性回顾与前后对照 +Rule 73 执行期决策对齐与不变量纪律）`→`…前后对照 / Rule 73 执行期决策对齐与不变量纪律）`（补 "/" 分隔；旧 `+Rule 73 执行期` 残留 grep=0）
- 复验（worktree，cwd=worktree 根）：`bash skills/task-planner/scripts/selftest-decision-drift.sh`→`Total: 23 PASS=23 FAIL=0` rc=0（DD-14b PASS 在位）；`bash -n check-complete.sh` rc=0；`bash -n selftest-decision-drift.sh` rc=0
- judge-gate 档位门控夹具（/tmp harness，awk 抽生产段 26 行 eval，禁改生产逻辑）：standard fixture（`plan_tier: standard`+零留痕）+warn→`[judge-gate] ✗ progress.md 无 [judge]/[align] 留痕行 …`（进入门内）；standard+enforce→exit 1；mini（`plan_tier: mini`）+enforce→`[judge-gate] SKIPPED (mini 档豁免或计划无 plan_tier: standard|full 标记, Rule 73.4/C51)` rc=0；legacy（无 plan_tier 标记）+enforce→SKIPPED rc=0；standard+含 [judge] 留痕→`[judge-gate] OK ([judge]/[align] 留痕 1 行, Rule 73.4)` rc=0
- diff 核对：`git diff --stat`=仅 3 目标文件（SKILL.md / check-complete.sh / selftest-decision-drift.sh）；check-complete 改动=§4.1 新版整体替换（旧 case 块零残留）
- 负结果：未发现三目标文件以外任何改动；未动 judge-gate off/enforce/warn 三档语义与计数行鲁棒化部分；⚠️ selftest-registry.tsv:73 描述仍为「静态 DD-01~22」（Total 已 23），超本单元三目标文件 scope 未改，待协调者裁决

#### [sub:16-executor] alignment MINOR 修正（M1 registry 描述 + M3 存量 selftest 消息/注释）（2026-10-10，Phase 6）
- 目标：修 15-alignment-review 两 MINOR——M1=selftest-registry.tsv:73 decision-drift 行描述「静态 DD-01~22」滞后于实际 23 断言（DD-14b）；M3=5 个存量 selftest ok/bad 消息文案滞后（描述旧正则）+缺 task-v156 演进注释行。需求锚（51.1a）=R5「歧义表述后带解释层，为犯错堵住漏洞」——消息文案=执行体解释层，滞后即歧义源
- M1 改动：selftest-registry.tsv:73 description 列「（静态 DD-01~22；task-v156）」→「（静态 DD-01~23，含 DD-14b 档位门控断言；task-v156）」（NF=4 保持；`grep -c 'DD-01~23'`=1）
- M3 改动（仅消息文案+注释行，正则/负断言零改动）：① selftest-drift-check-subagent.sh DCS-11 ok/bad 消息「40-69/40-71 全集」→「40-(69|71|73)(+N) 全集宽容锚」；② selftest-reliability-institution.sh R-09 头部 R-09 行+ok/bad「40-[567][0-9]」→「40-[4567][0-9](+N)」；③ selftest-root-resolution.sh RR-09 头部行+ok/bad「1-(5[3-9]|6[0-9])（现状 1-62）」→「1-[0-9]+(+N)（现状 1-71+73）」；④ selftest-parallel-scheduling.sh P-05 注释「Critical Rules 1-NN」→「1-NN(+N)」；⑤ selftest-research-first.sh RF-07 ok 消息「头注 1-71 全集」→「1-71(+N) 全集宽容锚」。5 文件各在断言行上方补 1 行演进注释（`# [2026-10-10 task-v156 CR/M 级联] …K9…负断言保留`）
- 复验（worktree，cwd=worktree 根）：5 selftest 各 rc=0 且 Total FAIL=0（DCS 20/20、R 16/16、RR 17/17、P 9/9、RF 12/12）；selftest-registry 5/5（rows=72=actual）；selftest-decision-drift 23/23；全量批跑 72/72 rc=0 nonzero=0
- diff 核对：`git diff --stat`=仅 6 目标文件（+15/-10）；正则行/负断言行逐字未变（DCS-11 三条件、R-09 1-40 负断言、RR-09 m 负断言、P-05 grep -oE、RF-07 cntE 均零改动）
- 负结果：未改 6 目标文件以外任何文件；未改任何正则/断言判据；未触主仓；无 git 写操作

#### [sub:18-executor] 并集解 merge 冲突（7 文件）+ 全量回归 + merge 提交（2026-10-10，Phase 6）
- 目标：worktree wt/v156-decision-alignment 处于 merge master 冲突中止态，按 17-merge-resolution-spec.md 逐文件解冲突（并集=两侧内容全留，我的编号口径让位 C53/1-74 族），跑全量回归，完成 merge 提交。需求锚（51.1a）=R1「规范上以及执行步骤上的逻辑确保整个执行前后不偏移」——并集解=并行任务合流不互相抹杀，Rule 73 落地面不被 v160/v162 冲掉
- F1 critical-rules.md：EOF 冲突解为 71.7→Rule 72→Rule 73→Rule 74 数字序（先 master 的 Rule 72 块，再我的 73 块，最后 master 的 Rule 74 块）；73 块头「衔接 …与在途 Rule 72（task-v160）」→「衔接 …/72（Rule 72 决策分级与用户打断纪律 — task-v160，管分级归属;本条管变更前对齐，互补）」；73.7「合规清单 C51（…C50 由 task-v158 占用…）」→「合规清单 C53（SKILL.md 消费侧;C51/C52 已由 task-v162/task-v160 占用,本任务顺延 C53）」；71.7 取 master 版（计数 1-74）
- F2 SKILL.md（5 处）：:9 计数行取 master 1-74、删「73 为编号预占空号…」子句→「67-72/73/74 均经并行任务合流落地」；:240 三行序 C50→C51(74)→C52(72)→C53(73)（我的行 C51→C53）；:312 取 master 1-74 详见行、Rule 71 后补「、73 执行期决策对齐与不变量纪律」；:377 两 bullet 全留（Rule 73 前、Rule 74 后）；:408 References 行取 master 1-74、Rule 65 后插「 / Rule 73 执行期决策对齐与不变量纪律」
- F3-F7：drift-check DCS-11 正则并集 `Rule 40-(69|71|73|74)(\+[0-9]+)? 全集`（两侧演进注释全留，v156 前 v162 后）；parallel-scheduling crit_max 取 master 两形态 `^(## Rule|###) [0-9]+`、skill_max 我的宽容版 `Critical Rules 1-[0-9]+(\+[0-9]+)?`，我的 v156 注释移至 master 注释后；research-first RF-06 取 master（含 v160/v162 尾注）、RF-07 第二锚宽容化 `Critical Rules 1-[0-9]+(\+[0-9]+)?（含 Rule 40-(65|69|71|74) 全集`、消息「1-NN(+N) 全集宽容锚」；root-resolution 主断言用我的宽容版 `Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`（master 两注释+我的一注释全留），ok/bad 消息「现状 1-74」；registry 三行全留（decision-drift + absorption-discipline + subagent-return）
- F8 selftest-decision-drift.sh：DD-17 `cnt 'C51'`→`cnt 'C53'`+消息「SKILL C53 合规行」；DD-16（Rule 73≥4）/DD-21（宽锚 1-7[0-9]）未动；line 68 awk 分隔符 `/Rule 73\.4\/C51/` 保留（匹配 check-complete.sh 实文本「Rule 73.4/C51」，非 8 目标文件故不改）
- 复验（worktree，cwd=worktree 根）：`grep -rn '^<<<<<<<\|^>>>>>>>\|^=======' skills/`=0；全量 selftest 75/75 rc=0（无 rc≠0 行；log=plans/task-v156-drift-shield/regression-r3-v156.log）；decision-drift Total 23 PASS=23 FAIL=0；merge 提交 0826302「Merge branch 'master' into wt/v156-decision-alignment」；`git status --porcelain`=空
- 负结果：未改 8 目标文件以外任何文件；未动主仓运行文件（仅追加本 findings+progress）；未执行 merge/abort/reset/checkout/push；未用 `git add -A`（逐个 add 8 目标文件）；spec F1 只列「两处口径更新」故 73.7 机器面列表内「计数 1-73/C51 合规行」按「逐字不动」保留

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
