# 41 — GLM-5.4 活跃配置逐位部署（D-22）FINAL
源仓 master=1e07d9498c3165951ea66f7c66d8e1b6e515aa33；唯一可写运行位执行体；未派发子代理；未改仓库 skills/plans/记忆/其他 worktree。

## 判向（写前）
A 组 5 文件 × 5 位 sha 各自全等（旧位 f3311098…/1b30c2f5…/cbbdb229…/43417dc6…/b91e9894…）；代表 diff 仅 5.3→5.4、enabled→max、DA-02b+D-22 注记，无自有增量 → 备份后整文件替换 + cmp。
B 组：~/.zcode DA 已 5.4+max，只核不改；~/.zcode CP 仅 :6 enabled→max；其余 4 位 DA 改 :3/:4/:5/:14，CP 改 :3/:5/:6；位自有字段(name 引号/color/injectAgentsMd/字段序)与 ccr enabled 逐字不动。

## 逐位文件清单（34 改动）
A(每位 5)：skills/task-planner/INSTALL.md；skills/task-planner/companion/agents/complex-planner.md；skills/task-planner/companion/agents/decision-arbiter.md；skills/task-dispatch/references/agent-coverage.md；skills/task-planner/scripts/selftest-decision-arbiter.sh → 25/25 cmp PASS，A_IDENTITY_OK=25 BAD=0。
B(zcode 1)：agents/complex-planner.md(:6 max) — agents/decision-arbiter.md 只核(:5 GLM-5.4, :6 max, :14 无 5.3)。
B(agents/claude/opencode/cursor 各 2)：agents/decision-arbiter.md(:3 desc 5.4, :4 model 5.4, :5 max, :14 选 GLM-5.4 强档 max 档) + agents/complex-planner.md(:3 GLM5.4, :5 model 5.4, :6 max)。
B 校验：grep -x -F 每替换行 +存在/-不存在全 PASS；diff -U0 变更行数 DA=8/8/8/8、CP=2/6/6/6/6，与预期完全一致。

## 校验输出（原始命令摘要）
V1 `grep -RIn 'GLM-5\.3\|GLM5\.3' <site>/skills <site>/agents`：改动文件仅 4 行历史锚/位(companion DA :14/:16/:18 + selftest :40「原行为=钉 GLM-5.3」)；`grep -RIn -E '^(model|description|thoughtLevel):.*(GLM-5\.3|GLM5\.3)'` = 0/位。非改动残留 critical-rules-discipline.md、critical-rules-dispatch.md（.agents 另有旧备份目录），不属授权清单，未动。
V2 `grep -RIn '^thoughtLevel:' <site>/agents/{decision-arbiter,complex-planner}.md` → 10/10 = max；ccr/haiku/sonnet 等 enabled 持有者未改。
V3 `grep -c 'DA-02b' selftest-decision-arbiter.sh` = 3/位（新源码自身含 3 处注释，含 `^# DA-02b` 各 1/位）；A 组与源码逐字节相同。
V4 `TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh` → `[verify] summary: 22 pass / 4 fail`，EXIT=1。基线 23/3 的 claude/opencode/cursor SKILL.md 漂移不变；新增 zcode SKILL.md 漂移：canonical SKILL.md 于 05:48 commit c0490005 更新、zcode 位于 04:50 旧版(差 compact-recovery/Git 差异门等)，本次 34 文件不含 SKILL.md，非本次造成；SKILL.md 不在批准清单，未越权同步。
V5 `BACKUP_COUNT=34`；A25+B9=34 改动；备份逐文件 cmp 通过；zcode DA 未改未备份（只核）。

## 备份与回滚
BASE=/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124/glm54-refresh/<site>/<rel>（34 文件，cp -p，无覆盖）。
回滚：逐文件 `cp -p BASE/<site>/<rel> /home/terry/<site>/<rel>` 还原 34 文件，再跑 verify.sh 复核。
遗留：V4 不达基线 23/3；是否单独同步 zcode SKILL.md 交主进程/用户裁决。
