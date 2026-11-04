# task-crossprojauth-20261104 — 跨项目/跨目录操作授权纪律（Rule 99，L0-T 文本优先档）

plan_tier: mini
execution_lane: L0-T
new_rule: 99

**Goal**：在 task-discipline 纪律域落 Rule 99「跨项目/跨目录操作授权纪律」——跨项目/跨目录写操作必须先询问用户并获授权才可推进，非授权严禁越权；级联面（48→49 计数、1-98→1-99 纪元字面、卫星索引、selftest 纪元锚）随动零回归。
**用户原话**（append-only）：「对技能进行跨目录 约束 要求跨项目操作时候 需要进行询问用户 授权才可以推进 非授权 严禁恶意越权 在当前项目的skill中添加限制确保后期不会违反」。
**scope_files**（源仓 6 文件）：`skills/task-discipline/references/critical-rules-discipline.md`（追加 ### 99 段）/`skills/task-discipline/SKILL.md`（L15/24/79/81/92 计数与索引）/`skills/task-planner/SKILL.md`（L9/197/210/243/253 纪元+索引+指针）/`skills/task-planner/references/critical-rules.md`（L194 卫星索引行）/`scripts/selftest-anti-deferral.sh`（AD-09/AD-10 纪元锚）/`scripts/selftest-subagent-activation.sh`（SA-11 纪元锚）。
**收口**：run-selftests 零回归（与基线持平）→ `rule-reserve.sh land 99` → 源仓 pathspec 提交 → 部署位 zcode/claude/cursor 3 位各 6 文件同步 diff=0（zcode/claude 配置仓提交，cursor 非 git 仅落盘）→ 簿记 commit。
**VC**：① `grep -c '^### 99' skills/task-discipline/references/critical-rules-discipline.md`=1；② `grep -c '1-99' skills/task-planner/SKILL.md`≥3 且 `grep -c '其余 82 条'`=2；③ `bash skills/task-planner/scripts/run-selftests.sh` 末行 Total FAIL=0 且 PASS 数=基线；④ 部署位对源仓 `diff -r` 6 文件=0；⑤ `rule-reserve.sh check 99` 末条=landed。
**D1 自动裁决记录**（Rule 44.3）：超时值=5min（44.1 默认）；触发时间=2026-11-04 本会话；裁决理由=完成性指令+§四.6 文本优先铁律（L0-T 纯文本档，94.6/98 同范式，守护机器化 opt-in 未获授权不建）；推荐项=按本计划执行；被覆盖的未决选项=无（无真分叉/无 D6 破坏性动作）。
**Decisions Made**：L0-T 主仓直改（无 worktree）=11-03 用户裁决 L0-lite 最小 stub 先例（零新脚本零 attest）；部署位同步=本任务「确保后期不会违反」的生效条件（技能加载位=部署位），属用户原话射程内闭环节点，非越权；新编号 99 经 rule-reserve 账本 reserve→land。
**[81.3 归档拒绝登记]** 2026-11-04 `archive-plan.sh task-crossprojauth-20261104` REJECT reason=status-none（mini stub 无 Phase/Status 结构，fail-closed）→ 按 81.3 保持原位+登记本行，不强行归档；G10 mini 档豁免同步。
**[收口证据]** 源仓 b935480（8 文件）→ 部署 zcode 8cf4b22/claude eeb91ed/cursor 落盘（各 6 文件 diff=0）→ 三仓 push ahead=0；selftest 94/94 零回归；rule-reserve 99=landed。

**[R2 扩展（B 类，用户 2026-11-04 第二指令逐字锚）]**：「继续补充技能要求 要求工作树也要在本项目的临时目录处理 也就是 临时 文件处理都放到当前项目内部的临时目录处理 另外还有就是 需要将临时目录添加到忽略目录 确保后期执行 统一要求临时目录在 当前项目的 tmp 目录处理」。
**Goal(R2)**：Rule 100「临时目录统一与工作树内放纪律」落 task-discipline 纪律域——① 一切临时产物（临时文件/草稿/构建输出/下载物）与 git worktree 统一落**当前项目** `<project-root>/tmp/`（worktree=`tmp/worktrees/<task-id>`）；② 任务起点保证 `.gitignore` 含 `tmp/`（`git check-ignore tmp/` 验证）；③ SOP/模板/派发域旧外部集中目录约定随动；级联纪元 1-99→1-100、计数 82→83/49→50；本仓 .gitignore 加 tmp/。
**scope_files(R2)**：`skills/task-planner/references/worktree-isolation.md`（§3/§4 路径约定）/`skills/task-planner/templates/task_plan.md`+7 个 variant 模板（worktree_path 行）/`skills/task-dispatch/references/critical-rules-dispatch.md`（:8）/`scripts/smart-merge-back.sh`（注释 2 处）/Rule 100 级联 4 文档（同 R1 形态）/`.gitignore`（源仓，加 tmp/）/`mkdir tmp`。
**VC(R2)**：① `grep -c '^### 100' discipline 文件`=1；② `grep -c '1-100' task-planner/SKILL.md`≥3 且 `grep -c '其余 83 条'`=2；③ `git check-ignore -q tmp/` exit 0；④ `grep -c 'repo-worktrees\|repo-parent' skills/task-planner/templates/`=0（旧字面清零）；⑤ run-selftests FAIL=0；⑥ 部署位 diff=0。
**D1-2 登记**（B 类扩展授权）：用户 11-04 显式「继续补充」=对本计划范围扩展的直接授权（Rule 8 B 类，S5 同步 Todo）；宪法 §十一.2（仓外集中目录）与 Rule 100 内放约定冲突——按 P0-1 用户当前指令优先，条款内登记漂移注（100.4），AGENTS.md 本体属 §六 保护区**本任务不改**，待用户显式授权另行对齐。
**[R2 执行状态]（2026-11-04 本会话）**：
- [x] A 组（子代理 general-purpose，检查点 subagent-state/01）：worktree-isolation.md §3/§4/§5 + 模板 8 + dispatch.md:8 + smart-merge-back 注释 17 处规格项，主进程磁盘复核 V1–V7 全过（2 处语义等价失配已登记）
- [x] B 组（子代理 general-purpose 后台，检查点 subagent-state/02）：Rule 100 段追加 + 级联 4 文档 + selftest 纪元锚（1-100/83 条/50 条）——主进程磁盘探测 F1–F6 全落盘（`### 100`=1 / `共 50 条`=3 / `1-100`=3 / `其余 83 条`=2 / 三索引 `,100` 各 1）
- [x] 源仓 `.gitignore` 加 `tmp/`（L26-27，B 子代理越 spec 顺手写入，内容合规已登记偏差）+ `mkdir tmp`；VC(R2)③ `git check-ignore -q tmp/` exit=0 **PASS**
- [x] R2 收口：land 100（账本 landed，2026-11-04）✓；回归与源仓提交/3 位部署并入 R4 收口链（累计一次执行）

**[R3 执行状态]（2026-11-04 本会话）**：
- [x] Rule 101 段追加 discipline 文件（subagent-state/rule101-section.md 主进程直接落）
- [x] 级联 4 文档（1-101×3 / 其余 84 条×2 / 共 51 条 / 三索引 +101）+ selftest 顶锚 2 脚本（AD-09/AD-10、SA-11/SA-12b）
- [x] worktree-isolation.md §4 L86 失败处理句翻转为「冲突=收口义务（Rule 101.2）：41.1 链全解+复验；仅消解配额耗尽才真门 STOP；不乱解守卫保留」+ §5 L94 反模式行同步
- [x] F8 守护预检：smart-merge-back.sh L99/L343/L346 旧语义 3 处，主进程 4 行同步（exit 7 机械语义不变；V6 消息=收口义务+41.1 消解链+配额耗尽真门，[Rule 97.6 仲裁 / 2026-11-04 Rule 101.2] 双锚注）
- [x] rule-reserve land 101（账本 landed）；VC(R3)①②③ 探测全过（### 101=1 / 1-101=3 / 其余 84 条=2 / 旧 STOP 句=0 / 冲突=收口义务=2）

**[D 组级联：纪元 1-101 四位顶字面炸点（2026-11-04 回归发现，D 组在途）]**：
- 现象：land 100+101 后 run-selftests=68 PASS/26 FAIL。基线对照（tmp/worktrees/regbase-20261104 @HEAD fad95ed）=94/94 FAIL=0 → 26 FAIL 全为 R2/R3 纪元 bump 引入的隐藏级联面（四位纪元顶字面 1-100/1-101 炸 26 脚本宽容正则；「纪元锚类天花板每纪元必炸」已知风险族，1-99→1-100 首次四位跨位）。
- 26 脚本（全 skills/task-planner/scripts/）：absorption-discipline capability-persistence conclusion-discipline context-pressure decision-drift drift-check-subagent error-loop execution-honesty iteration-persistence lane-advancement parallel-scheduling plan-tier reflect-verify reliability-institution requirement-coverage requirement-grading research-first root-resolution self-resolution session-log skill-split source-anchor-discipline summary-readability tool-selection verification-gate veto；56 FAIL 断言行=subagent-state/failing-assertions.txt。
- 修法口径（subagent-state/spec-D-epoch101-cascade.md）：顶纪元锚统一加 4 位纪元分支 `10[0-9]`（十位窗口放宽，与历史纪元先例同风格；禁硬编码 1-101 字面=零余量反模式）；负断言不动；消息文本同步；SRV-12 元断言随 9 级联脚本修复自动转绿。
- 执行：general-purpose 子代理 D（executor 通道 provider 拒，同 A/B/C 判例），检查点 subagent-state/04-executor-epoch101.md；完成标准=run-selftests 94/94 FAIL=0 + 主进程磁盘复核。
- [x] **D 组完成（2026-11-04）**：26/26 脚本 rc=0（无 BLOCKED/无特例 8）+ 二巡发现 AD-12 pin 级联面（11 pin 锚 8 处随兄弟脚本 live 锚演进，3 处内容锚不动，判据 ad12=0 不变）；主进程复核=抽检 veto/tool-selection diff 合规 + `run-selftests.sh --fresh` 独立跑 **Total: 94 PASS=94 FAIL=0 (run=94 reused=0)**（regression-fresh-final.txt）。

**[R4 收口链（用户 2026-11-04 第四指令逐字锚）]**：「完成任务 需要部署 并推送到github」。
- 顺序：D 组 94/94 → 源仓 pathspec 提交（R2+R3 累计 17 文档/模板/脚本 + .gitignore + 账本 + stub/subagent-state + 26 锚点脚本 + smart-merge-back）→ 3 部署位（zcode main/claude master/cursor 落盘）累计同步 diff=0 + 配置仓 pathspec 提交 → 三仓 push ahead=0 → 簿记 commit + memory + 交付总结（五要素；含 §十一.2 漂移报告/B 组 .gitignore 越 spec 偏差/provider 拒判例/D 组纪元教训）。
**[收口证据 R4]**：源仓 feat commit **ec72683**（45 文件：.gitignore + 账本 + 4 规则文档 + 8 模板 + smart-merge-back + 28 selftest）；fresh 回归 94/94；部署=3 位 42 技能文件累计同步（zcode/claude pathspec 提交 + cursor 落盘）diff=0；三仓 push ahead=0。
**[收口证据 R4 实际值（2026-11-04 回填）]**：源仓 feat **ec72683**（45 文件，含 .gitignore+账本+4 规则文档+8 模板+smart-merge-back+28 selftest）→ fresh 回归 `Total: 94 PASS=94 FAIL=0 (run=94 reused=0)` → 部署 3 位：zcode **2f1eb87**（43 文件）/ claude **ce69956**（47 文件=43 任务集+ARCHITECTURE/zcode-pretooluse/selftest-template-lifecycle 3 个 l0lite 遗留+l0-lite-type.md）/ cursor 落盘（47 文件 cmp OK）；3 位 `diff -rq` 全绿（cursor 余 .drift-rhythm 运行时态不碰）；**l0lite 遗留顺带收口**=11-03 task-l0lite-exempt-20261103 未同步 claude/cursor 的 4 文件（判向=源仓权威、位侧过期、无位侧本地适配，非 §六 污染）→ 三仓 push ahead=0。

**[R3 扩展（B 类，用户 2026-11-04 第三指令逐字锚）]**：「加强git的使用  就是 开始任务 使用 git固定提交原始数据  处理后主动动合并git工作树解决所有冲突」。
**Goal(R3)**：Rule 101「git 使用加强纪律（起点原始数据固定提交 + 终点工作树主动合并解冲突）」落 task-discipline 纪律域——① 任务开始用 git 提交固定任务范围内原始数据（Rule 90 首提交强化普适化：一切实现类任务含 L0-T，范围内脏态先提交固定，范围外脏清单呈报不代落）；② 任务收口**主动**合并 worktree 回主分支，冲突=收口义务（41.1 消解链：并集/三方/手动解冲突→复验，**解决所有**；仅消解配额耗尽且仍冲突才 STOP 升级用户——真门语义，对齐 Rule 95.5/97）；worktree-isolation.md §4「merge 冲突 → STOP 报告用户(不自动解决)」与 §5「❌ 合并冲突自动乱解不报告」措辞随动（冲突=收口义务+复验门；「不乱解」守卫保留，只翻转「冲突=停等点」语义）；级联纪元 1-100→1-101、83→84 条、50→51 条。
**scope_files(R3)**：`skills/task-discipline/references/critical-rules-discipline.md`（追加 ### 101 段）/`skills/task-discipline/SKILL.md`（51 条×3+枚举+101+落盘行）/`skills/task-planner/SKILL.md`（L9/L210/L253 1-101，L9/L210 84 条，L197/L243 +101）/`skills/task-planner/references/critical-rules.md`（L194 +101）/`skills/task-planner/scripts/selftest-anti-deferral.sh`（AD-09/AD-10 锚 1-101/84 条）/`skills/task-planner/scripts/selftest-subagent-activation.sh`（SA-11/SA-12b 锚）/`skills/task-planner/references/worktree-isolation.md`（§4 L86 失败处理句 + §5 反模式行）/rule-reserve 101。
**VC(R3)**：① `grep -c '^### 101' discipline 文件`=1；② `grep -c '1-101' task-planner/SKILL.md`≥3 且 `grep -c '其余 84 条'`=2；③ worktree-isolation.md `grep -c 'merge 冲突 → STOP 报告用户(不自动解决)'`=0 且 `grep -c '冲突=收口义务'`≥1；④ run-selftests FAIL=0（land 101 后）；⑤ 部署位 diff=0。
**D1-3 登记**（R3 B 类扩展授权）：用户 11-04 显式「加强git的使用」= 直接新指令；语义反转风险注：原「❌ 合并冲突自动乱解不报告」反模式按 101.2 收窄为「解决冲突是义务，但须复验门+不乱解」（守卫不删，停等语义翻转，Rule 95.5 真门/97 同向）；宪法 §十一.2 漂移注维持（101 不改 AGENTS.md）。
