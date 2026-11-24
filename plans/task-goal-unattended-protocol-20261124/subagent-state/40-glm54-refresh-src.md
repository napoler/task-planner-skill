# 40 — GLM-5.4 活跃配置刷新 + thoughtLevel 合法档断言（D-22）
worktree=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-glm54-refresh-20261124  branch=wt/task-glm54-refresh-20261124  base=bdc889d1
规格更正执行：decision-arbiter.md 零改动（其 14/16/18 行 5.3 均在历史/根因注释）；仅 GLM 系活跃字面变更，ccr 系 sonnet/haiku 的 enabled 未动。
diff 摘要（4 文件 +18/-7；decision-arbiter.md 无 diff）：
- companion/agents/complex-planner.md: description GLM5.3→GLM5.4；model GLM-5.3→GLM-5.4；thoughtLevel enabled→max（+1 行 What/Why 注释：合法档 low/high/max，enabled 属 ccr；选 max 因深度规划定位，max 非唯一档）。
- INSTALL.md:142 GLM-5.3→GLM-5.4；agent-coverage.md:13,30 GLM-5.3→GLM-5.4；selftest-decision-arbiter.sh 新增 DA-02b（^thoughtLevel:[[:space:]]*(low|high|max)[[:space:]]*$ 逐行匹配，tl_ok≥1 且 tl_all==tl_ok，拒 enabled/空值/其他档），头注释 16→17 断言，DA-02 原注记后追加裁决注记（原文逐字保留）。
commit=53e986835059c7a70ca928b901e1e34559c73081  git status --short = 空（clean）。
验证1 `$ bash -n skills/task-planner/scripts/selftest-decision-arbiter.sh` → BASH_SYNTAX_OK，exit 0。
验证2 `$ bash skills/task-planner/scripts/selftest-decision-arbiter.sh` → DA-01..16 全 PASS + `DA-02b PASS thoughtLevel 合法档(low|high|max)，enabled/空值/其他档拒绝`；`Total: 17 PASS=17 FAIL=0`；EXIT=0。
验证3 `$ bash skills/task-planner/scripts/selftest-agent-coverage.sh` → AC-01..09 全 PASS；`Total: 9 PASS=9 FAIL=0 SKIPPED=0`；EXIT=0。
验证4 `$ bash skills/task-planner/scripts/run-selftests.sh --fresh` → `Total: 106 PASS=106 FAIL=0 (run=106 reused=0)`，PIPE_EXIT=0。
基线对比=baseline-selftest.log 104 PASS/0 FAIL → 现 106 PASS/0 FAIL（+2 PASS、FAIL 仍 0）。脚本名集合 diff：新增 selftest-compact-recovery、selftest-git-baseline（f31a8a6f task-session-regression-20261124 后于基线快照引入），无缺失；非本次改动导致，未改任何守卫。
验证5 `$ grep -rIn 'GLM-5\.3' skills/` → 仅 5 处历史锚、活跃 0：decision-arbiter.md:14「原选 GLM-5.3 强档」/16「原行为=GLM-5.3 + thoughtLevel: enabled」/18「无 GLM-5.3(非 Flash) 模型」；critical-rules-discipline.md:399「原值 GLM-5.3 + enabled」；selftest-decision-arbiter.sh:40「原行为=钉 GLM-5.3」——均逐字保留。
验证6 GLM 系 frontmatter：complex-planner.md:5 model GLM-5.4 / :7 thoughtLevel max；decision-arbiter.md:4 GLM-5.4 / :5 max。`^thoughtLevel: enabled` 残留 4 处均 ccr 系（drift-checker/haiku-1、image-generation-executor/sonnet-1、video-generation-executor/sonnet-1、history-miner/haiku-1），按授权不动。
说明：complex-planner description 的 GLM5.3（无点号）属活跃字面，依原指令「同文件其他活跃 5.3 字面一并更新」改 5.4；已向协调方报备。
