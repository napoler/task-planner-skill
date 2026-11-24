# Knowledge Brief — task-session-regression-20261124（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!-- 本文件为执行期小模型的稳定知识底座：只读本文件即可获得本任务全部已对齐知识；计划期 plan-writer 产出，执行期持续回填 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：给 task-planner 原生 todo 基线组追加必选项 B9/B10/B11（Git 基线/检查点/差异四态处置）+ 压缩恢复「三件套」（A 必保清单入计划/B 压缩恢复包/C 必保机械查证），使脏仓下既有事实不可被无声删除、且每次压缩后在途会话先重读本地计划而非被带偏。
- 背景/动机：StoryLab 会话把 R1 材料包列为「必须保留的事实锚」在 R3 改写成「要删」，执行体照单删，11 条存在性 VC 全绿未检出（F14）；01:45:12 压缩后 SessionStart 只注入新会话开场白 + [task-resume] 无关任务清单，未读 user-session-log 与必保锚材料包（F15/F17）→ 用户 #6 要求压缩后主动重读本地文档。Git 未成为必选 todo（#3/#4）与压缩恢复断点（#6）同为技能侧驱动点缺口。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 基线组 B1-B11 | 原生 todo 的固定必选项，B1-B8 既有（修改后验证/Phase翻转/终验VC/收尾回读/Todo终态/引擎检测/对齐/worktree核验），本任务追加 B9/B10/B11 三个 Git 项 |
| sidecar `.git-baseline.json` | 计划目录内机器证据文件（ref/sha/tree/文件数/差异报告/四态处置），不复制任务语义；plan-state.json 仍是唯一语义权威源 |
| 非侵入快照 | 复制真实 `.git/index` 到工作树外临时索引 → `GIT_INDEX_FILE` 指向它 `add -A` → `write-tree` → `commit-tree -p HEAD` → `update-ref`；真实 index/HEAD/工作树不变，含未跟踪文件 |
| B11 四态处置 | `retained`（换讲法保留，既有事实词≥4字逐片段固定串查当前文件）/`authorized`（真删+用户逐字授权锚）/`restored`（内容==基线 blob）/`fixed`（附后续 checkpoint）；任一不满足=unresolved 阻断 |
| 门档位 env | `TASK_PLANNER_GIT_BASELINE_ENFORCE=enforce|warn|off`（默认 enforce），走 env 不写 config.json（钉值 54） |
| 清哨兵前置门 | `plan-created.cjs` 在清哨兵前校验 B9 基线字段，缺则不清哨兵+非零退出+打印 B9 命令；哨兵不存在会话 late 降级 |
| 三件套·A 必保清单 | 复用既有 `spec_baseline` section，条目 id 用 `MK<n>`（verbatim=既有事实字面片段/anchor=真源/rule=`target=文件\|fixed-string\|retain`/sha=哈希）；修改型任务须非空或登记 `MK-NA` 具理由；material 冲突按 51.15/74.7 STOP→用户授权→Decisions→update→重 attest，零 schema 改动 |
| 三件套·B 压缩恢复包 | 改造既有 `zcode-sessionstart.sh`（不新增 hook）：本会话 side 指针命中在途计划时注入 `[compact-recovery]`（按序必读绝对路径+MK 逐条+Goal/Phase/NextStep/Decisions，本体 ≤80 行，全文写 `.compact-recovery.md`），跳开场白与 [task-resume]；无在途逐字节不变；node 照常维持哨兵 |
| 三件套·C 必保机械查证 | `git-baseline.sh diff` 对每条 MK 做 `grep -qF -- verbatim target`，缺失→unresolved(kind=mustkeep_lost)、禁标 retained；唯一自动合法出口=restore；authorized 须用户逐字授权+Decisions 锚+spec_baseline 按 51.15 更新重 attest；共用两处既有门 |
| 防串台（约束a，R1-I4/D16④ 单一权威源） | hook 内自实现 side-only 解析：本会话 side 指针文件 `plans/.active_plan_side/<sidkey>.active_plan` 存在（sidkey 规范=剥非字母数字取前40再剥 sess 前缀，与 plan-created.cjs normSidkey 一致）且指向的 task_plan.md 存在且未全 complete ⇒ 在途；**不看指针 mtime/TTL**，不调用也不修改 resolve-plan-dir.sh；mtime 兜底/全局 fallback 命中一律不注入（D2 曾绑到他会话计划）；残余风险=hook 只能注入不能确认已读，兜底是 B11 机械查证 |
| 修改型判定（约束b） | 以差异为准：基线差异中 `plans/` 外对既有文件 M 或 D 即修改型，必保清单须非空或 MK-NA；只新增文件不要求 |
| 金样先采（约束c） | 改 hook 前先对「无在途计划」「有在途计划 side 命中」两输入各采 master 版 zcode-sessionstart.sh 输出金样存取证目录作回归对照 |
| 带偏防护（约束d） | 命中在途计划时 `[task-resume]` 未完成任务清单段同样不得注入（独立于 cjs 输出，源于 zcode-sessionstart.sh:16-67），整个 additionalContext 只留恢复包 |
| 基线锚定被修改树（R1-C1/D16①/D17） | git-baseline.sh 仓根取值 `--repo` > env `TASK_GIT_BASELINE_ROOT` > 当前目录 show-toplevel，**禁从 plan-dir 推导**，sidecar 记 repo_root/mode，两处门按 repo_root 跑 diff；`refs/task-baseline/<id>-pre-worktree`=创建 worktree 前主仓脏树只读备份（A1，不参与 B11 对照），`refs/task-baseline/<id>`=B9 在被修改树内建基线（worktree 即 worktree 起点） |
| 四态收紧（R1-I1/D16②③） | fixed 须以登记 MK 事实词固定串查证（禁仅凭 checkpoint ref 自证）；mustkeep_lost 清零合法出口仅 restored / authorized（用户逐字授权+Decisions 锚+spec_baseline 按 51.15 更新重 attest）/ 事实词重新在当前文件查到；MK/MK-NA 计划期登记随 attest 锁定，B11 门校验 sidecar.attest_sha 与当前一致 |

## §2 已验证关键事实（全部带证据锚，禁录未验证推测）

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 基线组 B1-B8 由脚本硬编码带出，**无任何 Git 项** | skills/task-planner/scripts/sync-todos.sh:201-214（B1..B8 八条 baseline_entries） | 这是用户 #4 指出的直接根因；B9-B11 必须加在同一处，否则不进执行视图 |
| 契约面「固定八项 B1-B8」措辞 | skills/task-planner/references/todo-sync.md:35（另 :36/:37/:38/:40 生命周期/门禁/丢失重建/唯一事实源） | 固定八项→十一项须 5 处段落锁步更新；门禁挂钩沿用既有写法 |
| 语义锚 Rule 106.5 两组 todo 驱动对齐 | skills/task-discipline/references/critical-rules-discipline.md:747-750 | B9/B10/B11 作为该子条内扩展，不新增 Rule 编号；清哨兵前校验句落此 |
| B1-B8 字面命中共 6 处 | 本计划期 `grep -rn "B1-B8" skills/`：task-planner/SKILL.md:264、task-discipline/SKILL.md:86、sync-todos.sh:34、sync-todos.sh:201、todo-sync.md:35、templates/task_plan.md:469 | 提及面锁步须覆盖这 6 处 + selftest-skill-collab.sh:114-120（T13 B6 锚）+ registry:23；VC-7 用 grep 计数 6→0 |
| 技能脚本中 Git 安全命令零使用；现有备份仅 SKILL 文字推荐 `git stash push -u`（会动工作树） | F7（`grep -rl -E stash create|commit-tree|write-tree|GIT_INDEX_FILE skills/task-planner/scripts ...` → 0 命中）；worktree-isolation.md:51-54 | 必须新增独立脚本 `git-baseline.sh`，不能指望文字条款 |
| 非侵入快照命令可行且含未跟踪文件 | F7 + 主进程本仓实测；E 设计文档 D.0（mktemp -d 私有索引→cp .git/index→add -A→write-tree→commit-tree -p HEAD→update-ref） | 作为 B9 的标准实现，写进脚本头注 |
| 坑①：临时索引路径必须不存在 | F8（mktemp 生成 0 字节文件 → `fatal: index file smaller than expected`） | 用 `mktemp -d` 拼接不存在的 `index` 名（`mktemp -u` 有竞态） |
| 坑②：不能空索引起步 | F8（skills/task-planner/.git 残留嵌套仓，空索引 add -A 报 `does not have a commit checked out`） | 必须 `cp <git-path index>` 真实索引副本做种子 |
| 坑③：临时索引须在工作树外 | E D.0 关键③（探针仓复现树内混入 `.tmp-index.lock`） | `mktemp -d` 目录在工作树外 |
| 还原命令 | F7/A1：`git restore --source=<快照> --worktree -- <文件>`（对 HEAD 中不存在的未跟踪文件同样有效） | 作为 B11 `restore` 入口，还原后逐字节一致性校验 |
| 性能实测覆盖 E C 节「未验证」 | 主进程本仓亲跑：约 4800 文件入树、含未提交与未跟踪、带残留嵌套 .git，生成当前树 0.77s、对照基线算差异 0.03s，真实 index/HEAD/工作树不变 | 性能不构成阻断；FMEA FM2 rpn 100；以本条为准 |
| config.json 键数钉值 | E D.3（至少 8 处 selftest 硬编码 properties=54；如 selftest-ask-default-timeout.sh:86） | 零新 config 键，门档位走 env；改键级联假红 |
| SKILL.md 脚本计数钉值 | E D.3（:432 scripts 163、:439 机械门 25、:443 selftest 103） | 新增 2 脚本后改 164/104（机械门数不变） |
| 主工作树 4 脚本有他人未提交改动 | 本计划期 `git status --porcelain` 实测 + `git diff --numstat -- skills/task-planner/scripts/`：attest-plan.sh +20/−2、init-session.sh +34/−9、planctl.py +72/−21、task-plan-init.cjs +28/−0 | 新机制放独立脚本，避开这 4 文件；must worktree 隔离 |
| check-complete.sh 终验门只数代码体量 | check-complete.sh:1442-1467 CR-GATE（`baseline_ref`→`git log --grep`→`HEAD~1` 三级 fallback，只判代码文件>3 或 diff>50 行） | 不加 GIT-BASELINE GATE 就漏检删既有事实；这是 11 VC 全绿仍漏的直接机制原因 |
| 现状口径（协调员更正，盘上核对） | 取证 B + 主进程核对：活着设定删除仅 EP001-小说.md:10 一处（约 02:30 删、03:16:12 已回补）；2 份计划历史快照被 .history 轮转删（记录性）；4-12s 硬门 HEAD/工作树各 10 处、节点1/spec-align/SOP 逐集全扫完整；女钓手 ep36-44 属另一会话 | 531KB 未提交 diff=多会话在途未提交，不是回退体量；禁把 531KB 写成倒退规模 |
| 事故对照（四态判据） | user-session-log #1 原话「恶意的倒退掉」；F1：被删的是 scope 内文件里的既有事实（六位嘉宾明星身份） | 「文件在 scope 内」不得自动视为已授权；retained 虚假声明（声称保留「明星向导/本名柯盈」但当前文件查无）须被 T6b 识破 |
| 事故链含压缩断点 | F14：01:03 R1 列必保锚→01:45:12 压缩（摘要必保词计数 0）→02:22:33 R3 未重读 R1 写成删除→02:25 执行删除→11 VC 全绿 | 根因不止 Git，还有「压缩后不重读」；三件套 B（恢复包）直接补这个断点 |
| R1 审计 C-1（基线空转） | subagent-state/plan-audit-r1.md：D.0 快照以 plan-dir 定仓根→plan-dir 在主树而改动在 worktree→B11 门 P1-P5 全程 unresolved==0 恒真空转；D16①/D17 分层修 | snapshot/checkpoint/diff 禁从 plan-dir 推导，须 --repo 锚被修改树；VC-2/3/17 在 worktree 断言并验证主仓未触碰 |
| R1 审计 I-1（fixed 自证）+ I-6（自撞 MUSTKEEP-EMPTY） | plan-audit-r1.md：fixed 仅附 checkpoint ref 可两步绕过；本计划无 MK 条目 | 本计划已登记 MK1-MK5（spec_baseline，S1 验收 jq 计数 ≥5 且随 attest 锁定）；fixed 须 MK 事实词固定串查证；T6c 变异断言 |
| R1 审计 I-2/I-3/I-4/I-5 | 范围 17/13/12 三数并存；S20/S21 串位；在途判定双源（resolve 24h TTL vs cjs 无 TTL）；VC-1/5/8 不可执行 | 范围统一 18 项（jq 机械生成 approved-scope）；S20=部署护栏 VC-18 / S21=合并清理；在途判定 hook 内单一权威源不看 TTL；VC-1 传 plans 目录、VC-5 完整夹具、VC-8 同树三时点 |
| 压缩后实际行为 | F15：01:45:12 压缩后 6 分钟读了 full-sweep-report/plan-state/集文件头，未读 user-session-log 与含必保锚的 R1 材料包 | 恢复包必须把 user-session-log 列为按序必读第 1 项（只给绝对路径不内联） |
| SessionStart 每次压缩触发但注入错位 | F17：9 次压缩↔9 次 SessionStart 一一对应，每次跑 task-plan-init.cjs 注入「新会话」开场白；01:45:12 还注入 [task-resume] 兜售 25 个无关任务标「中断恢复首选」 | 命中在途计划时开场白与 [task-resume] 均不得注入（约束 d），只留 [compact-recovery]；这是用户所说「被带偏」来源 |
| 必保清单无计划级载体 | F16①：该计划无变更标注表/规范基线节，R1 必保事实只活在上下文；D12 | 三件套 A 复用 spec_baseline 登记 MK<n>，零 schema 改动且被 51.15/22.4e/106.7/84.15 四环消费 |
| spec_baseline schema 四字段在位 | schemas/plan-state.schema.json:386-397（required=id,verbatim,anchor；additionalProperties:false）；模板 :64-69 既有 🔒规范基线表 | MK<n> 直接复用该 section，不需改 schema；模板表增 3 行说明 MK 映射格式 |
| 哨兵写入真实行号 | task-plan-init.cjs 哨兵路径定义 :99-101、写入 :159-160（tmp+renameSync）、resume 判定 :201-229（本会话 side 指针命中有效计划时 rmSync 删哨兵并打印「已有有效计划」），轻量分支 :131-151；设计文档所标行号有偏差（主进程逐行核对） | 行号以本次 grep 为准；清哨兵前置门改 plan-created.cjs 不碰哨兵写入本体 |
| hook 严格单行 JSON 契约 | zcode-sessionstart.sh:75-77 `printf '{"additionalContext": %s}' "$(printf ... \| jq -Rs .)"`；sid 提取 :10；cjs 调用 :13 | 恢复包注入后仍须单行 JSON（VC-13 json.load+wc -l==1），超限写文件只注入指引 |

## §3 关键文件锚点表（执行期照此定位，禁凭记忆改文件）

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/sync-todos.sh | :201-214（:34 文案） | 硬编码 B1-B8 八条 baseline_entries（task_id/phase/status/subject），--json 输出；本任务追加 B9-B11 + evidence 字段 |
| skills/task-planner/references/todo-sync.md | :34-40 | S1 两组结构：基线组固定八项、生命周期、门禁挂钩、丢失重建、mini 豁免、唯一事实源；本任务改十一项+四态 |
| skills/task-discipline/references/critical-rules-discipline.md | :747-750 | Rule 106.5 通用基线组 B1-B8 语义+门禁挂钩；本任务落 B9-B11 草案（E B.4）+清哨兵前校验句 |
| skills/task-planner/SKILL.md | :264；:190/:192/:207；:432/:439/:443 | 基线组钉值；Phase翻转/S-unit提交/终验执行循环；脚本 163/机械门25/selftest103 计数 |
| skills/task-discipline/SKILL.md | :86 | Rule 106 摘要行「两组 todo B1-B8」→B1-B11 |
| skills/task-planner/templates/task_plan.md | :469-471 | 基线组 B1-B8 模板标题+门禁句，B9-B11 加短命令 |
| skills/task-planner/scripts/check-3file-gate.sh | 头注第6/7条件后 | Phase 翻转门链；本任务加第8条件读 last_diff.unresolved（E B.3） |
| skills/task-planner/scripts/check-complete.sh | :1442-1467 | CR-GATE 代码 diff 体量判定；后插 GIT-BASELINE GATE |
| skills/task-planner/scripts/plan-created.cjs | 清哨兵处（307 行文件，工作树无未提交改动） | 清哨兵前加 B9 baseline 字段校验，缺则不清+打印 B9 命令 |
| skills/task-planner/scripts/selftest-skill-collab.sh | :114-120 | T13 B6 引擎检测双载体锚；本任务扩 T13c/T13d |
| skills/task-planner/scripts/zcode-sessionstart.sh | :10/:13/:75-77（task-resume 段 :16-67） | SessionStart 注入：sid 提取/node 调用/jq -Rs 严格单行 JSON；本任务在 node 后插入在途判定与 [compact-recovery]，跳开场白与 [task-resume] |
| skills/task-planner/scripts/lib/plan-recovery.sh | 新增 | mustkeep/recover/empty-check 三函数，hook 与 git-baseline.sh 共用；jq 可选+md-fallback |
| skills/task-planner/schemas/plan-state.schema.json | :386-397 | spec_baseline_item 四字段；MK<n> 复用，零 schema 改动 |
| skills/task-planner/templates/task_plan.md | :64-69 | 既有 🔒规范基线表（Spec-Baseline）；增 3 行说明 MK<n> 四列映射与 MK-NA 格式 |
| skills/task-dispatch/references/critical-rules-dispatch.md | :66 | 22.4e 规范基线派发强制携带；补一句 MK<n> 原样携带禁转译 |
| skills/task-planner/scripts/selftest-registry.tsv | :23（skill-collab 行）；表头 :1 | registry 自登记新 selftest 一行 |
| tmp/forensics/task-session-regression-20261124/E-design-git-baseline.md | :42-79（D.1 改动表）/ :99-145（B 机制）/ :149-169（C 边界）/ :172-262（E 变异测试） | 文件级改动清单、B9-B11 文案与 sidecar、档位豁免、T1-T10 断言 |
| plans/task-session-regression-20261124/user-session-log.md | #1-#5（:42-95） | 用户原话逐字专档（append-only），R 行权威源，决策前必读 |

## §4 易错点与禁止假设清单
1. 禁止把 Git 未执行归咎执行方——用户 #3 裁决：这是技能缺驱动点的缺陷（D5），归因口径不得漂移。
2. 禁止改 `planctl.py`/`init-session.sh`/`attest-plan.sh`/`task-plan-init.cjs`——均有他人未提交改动（+154/−32 合计），新机制放独立脚本。
3. 禁止新增 config.json 键或 Rule 编号——selftest 钉值 properties=54；B9-B11 用 Rule 106.5 子条款，档位走 env。
4. 禁止把 sidecar 当任务语义权威源——plan-state.json 仍是唯一语义源，sidecar 只存机器证据。
5. 禁止用 `IDX=$(mktemp)` 或空索引起步——两个实测坑（§2）；临时索引须工作树外。
6. 禁止「文件在 scope 内 = 删除已授权」——事故删的正是 scope 内既有事实；四态处置按 §1 判据。
7. 禁止把 531KB 未提交 diff 当倒退体量（§2 现状口径）；禁止把本任务范围扩到 StoryLab 项目级技能（该会话自行修复，F5）。
8. 禁止让新门卡死存量在途计划——档位默认恒为 enforce：JSON 权威源在途计划无 sidecar→门 FAIL 并打印 B9 命令，跑 snapshot 建 late=1 基线、终验报告披露「late 基线之前的删除不在对照范围」后放行；仅无 plan-state.json 的 legacy MD 计划 SKIP+WARN；env warn/off 逐次披露逃生口；L0-E/纯只读 n/a；禁静默 PASS（FMEA FM1/AR4）。
9. 禁止 raw `rm -rf` 真实仓；变异测试草稿仓 fixture 只在 `tmp/forensics/.../mutation-fixture` 内构造，不碰本仓真实 `.git`。
10. 当前 phase 已完结的信息以 plan-state.json 为准，MD 视图是 render 派生，禁止手工 Edit task_plan.md/progress.md/verification.md/findings.md。
11. 禁止恢复包串台：仅 resolve-plan-dir.sh 命中本会话 side 指针才注入 [compact-recovery]；mtime 兜底/全局 fallback 解析到的计划可能是他会话在途计划（D2 判例），不得注入且行为逐字节不变。
12. 禁止压缩后注入无关任务清单：命中在途计划时 [task-resume] 段（源于 zcode-sessionstart.sh:16-67，独立于 cjs）同样不得注入；整段 additionalContext 只留恢复包，否则在途会话被带偏（F17/约束 d）。
13. 修改型判定以差异为准（非模板/档位启发式）：plans/ 外既有文件出现 M 或 D 即修改型，必保清单须非空或 MK-NA；只新增文件不要求（约束 b）。
14. MK 事实词固定串用 `grep -qF --`，verbatim 含正则元字符/换行/多字节不得走正则；目标文件不存在视同丢失→mustkeep_lost；禁标 retained（G.1.C）。
15. 「不做」清单（边界，禁自作主张扩范围）：G.5 写入前拦截（PreToolUse exit 2）默认不做——只覆盖 Write/Edit/ApplyPatch、误报停摆（Rule 95）、B11 diff+restore 已全覆盖可还原，仅用户点名才 env TASK_PLANNER_MUSTKEEP_PRETOOL=on opt-in；G2-11 UPS 并入必保清单不改——职责重叠/token 翻倍/双源漂移。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表 FM1（新必选项卡死存量计划，392）、FM3（多会话并发归属，336）、FM4（主工作树 4 脚本冲突，392）、FM5（橡皮图章，270）、FM7（首写早于 B9，240）、FM8（恢复包串台，392）、FM9（单行 JSON 契约破坏，315）、FM10（MK 粒度卡死，336）、FM11（无关任务清单带偏，441）；R1 审计后 VC-17（worktree 基线空转变异）与 VC-18（部署护栏）为对应机器兜底。

## §5 S-unit 材料包索引（与 task_plan.md S-unit 表「输入」列互链）
| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1+§2+§3（取证一致性核对，不重做综合） | E-design-git-baseline.md（A/D 节）+ findings.md F1-F13 + E D.1 改动表（:42-79） |
| S2 | §2（坑①②③）+§3 | E D.0 快照命令（:23-40）+ F7/F8 |
| S3 | §1（sidecar）+§3 | E B.2 登记产物（:113-118） |
| S4 | §1（四态）+§2（现状口径） | E E 节 T4/T9（:224-227/:252-255） |
| S5 | §1（四态判据）+§2（事故对照） | E B.3 防橡皮图章（:126）+ T6/T6b/T7/T8（:235-250） |
| S6 | §2（6 处命中）+§3 | sync-todos.sh:201-214 + E D.1 #2 |
| S7 | §2（check-3file-gate）+§3 | E B.3 Phase 翻转门（:122）+ SKILL.md:190 |
| S8 | §2（CR-GATE）+§3 | E B.3 终验门（:123）+ check-complete.sh:1442 |
| S9 | §2（契约面/语义锚）+§3 | todo-sync.md:34-40 + critical-rules-discipline.md:747-750 + E B.4（:128-136） |
| S10 | §2（6 处命中+计数钉值）+§3 | SKILL.md:264/:432/:439/:443 + task-discipline/SKILL.md:86 |
| S11 | §3 | templates/task_plan.md:469-471 + selftest-skill-collab.sh:114-120 |
| S12 | §2（config 钉值/坑）+§3 | E D.2（:62-72）+ E 节 T1-T11 fixture（:176-196） |
| S13 | §1（四态）+§2（事故对照） | E E 节 T1-T10（:198-261）+ T6b 事故对照 |
| S14 | §2（钉值）+§3 | selftest-registry.tsv:23 + E D.1 #10 锁步 |
| S15 | §2（性能/钉值）+§3 | E D.3 + master-fail-set.txt（执行期 S15 采集） |
| S16 | §1+§2（性能实测）+§4 | E E 节全段 + F12 |
| S17 | §2（4 脚本重叠/6 处命中） | approved-scope.txt（13 项）+ changed-files.txt |
| S18 | §1+§4（全部禁止假设） | changes C1-C13 + spec_baseline SB1-SB4 |
| S19 | §4（worktree/合并护栏） | isolation（plan-state）+ A1 基线 ref |
| S20 | §4（部署护栏） | E D.1 #12（.gitignore 不改）+ AGENTS.md §2 部署口径 |
| S21 | §1（清哨兵前置门）+§4（降级） | plan-created.cjs 清哨兵处 + E B.3 档位（:125）+ 协调员补充(1) |
| S22 | §1（四态）+§2（事故对照） | E 节 T6/T6b/T11（:235-236/:176-196）+ 协调员补充(2) |
| S23 | §1（约束c）+§2（金样） | E G.4 T13 注释（:414）+ master 版 zcode-sessionstart.sh 两输入 |
| S24 | §1（三件套 A/B 载体）+§2（spec_baseline schema/hook 契约） | E G2-2 + G.1.A/B（:298-364）；schemas/plan-state.schema.json:386-397 |
| S25 | §1（约束a/d+带偏防护）+§2（SessionStart 注入错位/task-resume） | E G2-1 + G.1.B；zcode-sessionstart.sh:10/:13/:16-67/:75-77；F17 |
| S26 | §1（约束b+三件套 C）+§2（必保清单无载体） | E G2-3 + G.1.C（:361-364）；F16①/F14；51.15/74.7 |
| S27 | §1（两门共用） | E G2-4；check-3file-gate.sh 第8条件 + check-complete.sh GIT-BASELINE GATE |
| S28 | §2（契约面/语义锚） | E G2-5/G2-6；todo-sync.md:34-40；Rule 106.5:747-750 |
| S29 | §2（模板规范基线表/22.4e） | E G2-7/G2-8；templates/task_plan.md:64-69；critical-rules-dispatch.md:66 |
| S30 | §2（SKILL.md 计数钉值） | E G2-9；SKILL.md:264/:432/:439/:443 |
| S31 | §1（三件套静态锚）+§4（约束a/d） | E G.2 G2-10；selftest 框架沿用 t() |
| S32 | §1（约束a-d）+§2（T12-T15） | E G.4（:379-388）；T12-T15 共 18 断言 |
| S33 | §2（registry/active-plan） | E G2-10 锁步；selftest-registry.tsv；selftest-active-plan.sh |
| S34 | §1（约束a/c/d）+§2（金样/带偏） | E G.4 T12/T13（:390-416）；FX/g12.json+g13-new.json |
| S35 | §1（约束b+三件套 C）+§2（必保清单） | E G.4 T14/T15（:417-438）；FX/mk-restore.json+g15.gate |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）
| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 本任务直接改其核心脚本/契约/模板 | 子代理 prompt 挂载（本仓源码即产物） |
| task-discipline | /mnt/data/dev/task-planner-skill/skills/task-discipline/SKILL.md | Rule 106.5 语义锚落点 | 子代理 prompt 挂载 |
| （无外部强化技能命中） | — | 用户裁决不做泛化框架/新 hook，comet/superpowers 族与本任务形态不符 | 不激活 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022）
- 触发点：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- 入库命令：`bash scripts/kb-sync-from-plan.sh plans/task-session-regression-20261124` → 生成 knowledge/entries/_draft-task-session-regression-20261124.md
- 精炼：draft 机械提取，需人工合并去重→主题化→补证据锚→去除 `_draft-` 前缀
- 索引：`bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- 条目规范：见 knowledge/README.md 与 knowledge/entry-template.md（Rule 71 无源不写）
