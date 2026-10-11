# Checkpoint: 19-drift-checker — task-v169 合并前偏移检查（Rule 61 载体）

status: done
执行体: drift-checker 职能（dispatch 原定 haiku-1，provider 拒后按 Rule 22.3① 改派 general-purpose 执行同一任务书，职能不变）
模式: 只读仓库；唯一写入=本 checkpoint 文件；零 git 写操作
时间: 2026-10-11

## 对照基准

| 项 | 值 | 来源 |
|----|----|------|
| 主仓 master HEAD | 618df79 | `git -C <main> rev-parse master`（经 worktree `git log --oneline -3` 首行核对一致） |
| worktree 分支 | wt/task-v169-user-session-log-write-once | `git branch --show-current` |
| worktree HEAD | 618df79（== master，分支 0 提交） | `git log master..HEAD --oneline \| wc -l` = 0 |
| worktree 工作区 | 26 项未提交变更（24 M + 2 ??） | `git status --short \| wc -l` = 26 |
| 需求锚（用户原话） | R1/R4/R5（任务书 §1 逐字） | user-session-log.md #1（main repo，:17-19） |

## 逐项对照记录（带证据锚）

### A. 需求锚 R1-R6 → 产物覆盖

- R1（每次任务需求记录在文档体系内）：plans/task-v169-user-session-log-write-once/user-session-log.md 存于主仓，含 #1（发起原话逐字，:17-19）/ #2「继续」（:21-23）/ #3「继续」（:25-27）三条。init 自动化建档=CA-3 产物（init-session.sh `copy_template "user-session-log.md"` grep=1）。→ 覆盖。
- R4（记录在 Task Plan 文档中）：实现=append-only 外置专档 + task_plan.md 指针区块。依据=Decisions Made（task_plan.md:341：attest 哈希锁下任何追加即 [PLAN TAMPERED]，记录类内容必须外置）。指针区块在案（task_plan.md:32-36：「🗣️ 用户会话逐字记录」+ 专档路径 + 只写不改铁律 + 恢复协议三行）；模板侧指针 `grep -c 'user-session-log' templates/task_plan.md`=2。R6「继续」=silent 授权，Decision 已登记。判定：字面载体与用户表述有差异（Task Plan 正文 → 专档+指针），属已登记的技术约束适配决策，核心意图（记录/可恢复/只写不改）无缺。→ 覆盖（附决策说明，非漂移）。
- R5（只写入不修改）：专档头「只写不改铁律（Rule 80.2）」+ append-only（user-session-log.md:5）；模板三要素 `只写不改/append-only/逐字抄录` 经 selftest SL-01 断言；check-complete.sh SESSION-LOG GATE 只写语义门控 + SL-01..10 静态断言守护。→ 覆盖。
- R2/R3（一手资料/会话异常不丢）：Rule 80.4 恢复协议=专档为用户意图权威源（模板 :20-22 + 指针区块第 3 行 + critical-rules.md:1058 三载体一致，CR D3 实证）。→ 覆盖。

### B. VC-1..VC-6 对照（本代理独立抽查 + CR 既有证据）

| VC | 抽查证据（worktree 内命令实跑） | 判定 |
|----|-------------------------------|------|
| VC-1 | `grep -c '6/6' scripts/init-session.sh`=1；`grep -c 'copy_template "user-session-log.md"'`=1；e2e 由 findings.md:35（/tmp/v169-e2e 7 文件+幂等二跑）在案 | PASS |
| VC-2 | `test -f templates/user-session-log.md` 存在；`grep -c 'user-session-log' templates/task_plan.md`=2≥1 | PASS |
| VC-3 | `grep -cE '^80\.[1-6] ' references/critical-rules.md`=6；`grep -c '1-80' SKILL.md`=3；`grep -c '\| C56 \|' SKILL.md`=1；`wc -l SKILL.md`=558≤581（INV-4） | PASS |
| VC-4 | `grep -c 'session-log-gate' check-complete.sh`=6；`grep -c 'TASK_PLANNER_SESSION_LOG_ENFORCE'`=4；五 fixture 三态由 findings.md:66（sub:05）+ CR D1 复验在案 | PASS |
| VC-5 | 本代理实跑 `bash scripts/selftest-session-log.sh` → `Total: 10  PASS=10  FAIL=0` rc=0（SL-01..10 逐条 PASS 输出在案）；`grep -c 'selftest-session-log.sh' selftest-registry.tsv`=1 | PASS |
| VC-6 | 本代理未重跑全量（规避 runner 缓存写盘，守只读 mandate）；采信 CR 冷跑证据 findings.md:135：空缓存强制 `Total: 78 PASS=78 FAIL=0 (run=78 reused=0)` + sub:17（findings.md:127-129） | PASS（转引证据） |

### C. 超范围改动排查

- `git diff master --name-only` 24 项 + `git status ??` 2 项 = 26 文件，`grep -v '^skills/task-planner/'` 计数=0 → 100% 在 skills/task-planner/ 内。
- plans/task-v168-*：git status/diff 零 plans/ 条目；worktree 内 plans/task-v169-user-session-log-write-once 目录不存在（计划文件仅在 main 仓未跟踪态，不随分支合并）→ v168 零触碰（INV-6 守住了）。
- ~/.zcode 部署位越界检查：`ls ~/.zcode/skills/task-planner/templates/user-session-log.md` 不存在；`grep -c '1-80' ~/.zcode/.../SKILL.md`=0；`grep -c 'selftest-session-log' ~/.zcode/.../selftest-registry.tsv`=0 → 部署尚未发生（Phase 6 事项），无提前越界写入。
- config.json：diff 名面 0 命中；`jq '.properties\|keys\|length' config.json`=42（INV-5 零新 config 键守住）。
- `git diff master --name-only | grep -iE 'config\.json|hook|\.claude|settings'`=0 → 零 hook/配置/注入机制文件。

### D. v168 用户否决方向边界（「机器面代码为主方案被否决」→ 设置层修复）

- 证据来源校正：任务书称 findings.md Phase 1 记录该否决——findings.md 全文无 Phase 1 段、无「机器面否决」记录（已 grep 'v168\|否决\|为主方案' 全量核对，仅命中负结果面/隔离纪律行）。改用一等证据：master git log commit cdf437e「merge: task-v168 逻辑/设置层改造……机器面封存 wt/task-v168-machine-parked 不合入」+ 9fce0ff/618df79（v168 设置层合并链）。
- v169 diff 边界实测：26 文件全部为 templates/规则文档/技能内 scripts（init/check-complete/selftest/registry/SKILL/critical-rules），零 hook 文件、零 config.json 键、零注入机制改造；新增 SESSION-LOG GATE 是 check-complete.sh 内既有门控体系的增量（插于 run_report_lint 后/CR-GATE 前，findings.md:64），属技能自足设置层，非 hook/注入机制。→ 边界守住。

### E. CA-1..CA-10 与 git 证据逐条对齐

| CA | 对象 | git 证据 | 对齐 |
|----|------|---------|------|
| CA-1 | templates/user-session-log.md 新增 | ?? 未跟踪新文件；SL-01/02 PASS | ✓ |
| CA-2 | templates/task_plan.md 指针区块 | M，diff +6/0 纯插入（findings.md:26） | ✓ |
| CA-3 | init-session.sh 建档块 | M，+24/0；6/6 字面=1 | ✓ |
| CA-4 | critical-rules.md Rule 80 | M，+17（findings.md:40 记 +16/0，stat 显示 17 含演进记录行差异，均为纯追加） | ✓ |
| CA-5 | SKILL.md 级联 | M，stat 10 行（6 替换+2 插入+…，numstat 6/4 findings.md:46）；1-80=3/1-76=0/558 行 | ✓ |
| CA-6 | check-complete.sh GATE | M，+37/0 纯追加 | ✓ |
| CA-7 | selftest-session-log.sh 新增 | ?? 未跟踪新文件；实跑 10/10 | ✓ |
| CA-8 | selftest-registry.tsv | M，+1/0 | ✓ |
| CA-9 | 18 个 epoch 级联脚本 | M 名面实测 18 个 selftest-*.sh（另 registry 计第 19 个 selftest- 文件）逐一在案：absorption/capability/context-pressure/drift-check/error-loop/execution-honesty/iteration/lane/reflect-verify/reliability/requirement-coverage/research-first/root-resolution/self-resolution/skill-split/summary/tool-selection/veto | ✓ |
| CA-10 | 本任务专档种子化 | user-session-log.md #1/#2 在案（另 #3） | ✓ |

表外文件：0（26 = scope_files 8 项 + 18 epoch 脚本，无一项在声明范围外）。

## 三态判定结论

**判定 = aligned（可合并）**

依据汇总：
1. 需求锚 R1-R6 全覆盖（专档 3 条逐字记录 + Rule 80 + 模板 + init 建档 + GATE + selftest）；R4 载体适配为「专档+指针」系 attest 哈希锁约束下的已登记决策（task_plan.md:341），核心意图无缺，不构成漂移。
2. VC-1..VC-6 全部有证据链（本代理独立抽查 grep/selftest 实跑 + CR 全量证据），无失败项。
3. 超范围改动=0：diff 100% 在 skills/task-planner/ 声明范围内；plans/task-v168-* / ~/.zcode 部署位 / config.json（properties=42）零触碰。
4. v168 否决方向守住：零 hook/配置/注入机制改造，全部改动在规则/模板/脚本设置层（master log cdf437e 机器面封存为先例边界）。
5. CA-1..CA-10 与 git 名面逐条对齐，无表外文件。

### 附注（不改变 aligned 结论的事项，供主进程 Phase 6 参考）

1. 任务书簿记误差：任务书称「改动面=19 文件」，git 实况=26 文件（24 tracked M + 2 untracked）。19 疑指含行修改文件数（5 个纯插入文件：critical-rules/check-complete/init-session/registry/task_plan 之外）。属任务书侧计数误差，非 worktree 漂移。
2. findings.md 无任务书所称「Phase 1 机器面否决记录」，边界证据已用 master git log 替代取证（见 D 节）。
3. 分支 wt/task-v169-user-session-log-write-once 当前 0 提交、26 文件全未提交（HEAD==master==618df79）：Phase 6 `git merge --no-ff` 前主进程需先在 worktree 提交，否则合并为空操作。
4. CR N1 nit（Rule 77-79 编号空洞，findings.md:138）：并行 v168 已 park 的预留号问题，级联锚 `1-[7-8][0-9]` 已覆盖，零机器影响；属既有登记 nit，不构成 v169 偏移。
5. task_plan.md:166 知识储备表记「11 脚本」而 Phase 4 实际级联 18 脚本：findings.md:57-61 已记录 dry-run 19 FAIL 的归因过程（18 锚扩+1 修正），计划内估计值与执行面差异有据可查，非漂移。

## 建议 Drift Log 行文本（供主进程写入 task_plan.md「## 🚨 Drift Log」表；该表列=时间/检测结果/涉及VC/结论）

| 2026-10-11 | drift-checker 合并前偏移检查（Rule 61，改派 general-purpose 代行）：R1-R6 需求锚与 VC-1..VC-6 全覆盖（专档 3 条逐字+Rule 80+模板+init 建档+GATE+selftest 10/10）；diff 实况 26 文件（24 M + 2 ??，任务书「19 文件」系簿记误差）100% 在 skills/task-planner/ 声明面内，CA-1..CA-10 逐条对齐无表外文件；v168 否决方向守住（零 hook/config/注入机制改造）；plans/task-v168-*、~/.zcode 部署位、config.json（properties=42）零触碰；分支 0 提交/26 文件未提交需 Phase 6 先 commit。判定=aligned | VC-1..VC-6 | aligned（可合并） |

## 未覆盖面

- 全量回归（VC-6）未由本代理重跑：受「只读仓库」 mandate 约束（runner 指纹缓存可能写盘），采信 CR 冷跑 78/78 FAIL=0 证据；如需本代理独立冷跑复验，请主进程明示授权写缓存后另行派发。
- init-session.sh e2e（VC-1 temp-dir 7 文件断言）未由本代理重跑：采信 findings.md:35 既有证据（含 e2e 命令与输出摘录）。
- v168 用户否决原始对话记录未在 v169 findings.md 找到（见 D 节），边界判定以 master git log 为一等证据替代。
