# F 组 spec：Rule 75 补强 75.9-75.12（task-crossprojauth-20261104 R6）

任务仓：/mnt/data/dev/task-planner-skill（L0-T 主仓直改）。全程 cd 仓根执行。
检查点：plans/task-crossprojauth-20261104/subagent-state/06-executor-rule75-r6.md（每里程碑追加；最终结论必写入）

## 背景（自包含）
用户 R6 指令（逐字锚 plans/task-crossprojauth-20261104/task_plan.md「[R6 扩展]」块）：技能实际工作中搜索利用率过低、自行脑补；判例 session_4906f3feaa579b867883b2e37f2422c6（用户多次强调「参考热门短剧套路」执行体仍脑补跳搜索；搜索失败后未降级浏览器；该会话原文 ReadSessionContext 检索未命中[2026-11-04]，判例锚以 task_plan.md R6 用户原话行为准，禁引用未验证的会话细节）。Rule 75 既有 75.0-75.8 原文**零改动**，本组纯增量追加 4 子条 + selftest 加 3 断言行。

## S1 追加 75.9-75.12 到 `skills/plan-research-router/references/critical-rules-research.md`
文件现 68 行，### 75 段末行=「- 机制面：LLM 行为面守门；零新 config 键、零新脚本；衔接 Rule 21.4/21.1b/46.1/58/75.1/75.8 机制面自锚。」
在该行后（文件尾）追加 **`plans/task-crossprojauth-20261104/subagent-state/clause75-r6.md` 全文（逐字，勿改写）**，追加前空一行。

## S2 selftest 加 3 断言行 `skills/task-planner/scripts/selftest-proactive-research.sh`
1. 头注释 L5 行（`…共 15 条编号断言 PR-01..PR-15`）补注：` [2026-11-04 task-crossprojauth-20261104-R6] 增 PR-16..PR-18（Rule 75.9/75.10/75.11 文本锚）`
2. PR-09 断言行（`ge "PR-09 critical-rules 75.7 机制子条(零新键声明)"…`）之后插入 3 行（沿用 ge/cnt 原语，锚在 $CR）：
   ```bash
   ge "PR-16 critical-rules 75.9 用户明示参考诉求 P0 触发面子条(R6)" "$(cnt '^75\.9 ' "$CR")" 1
   ge "PR-17 critical-rules 75.10 调研通道降级链子条(R6)"         "$(cnt '^75\.10 ' "$CR")" 1
   ge "PR-18 critical-rules 75.11 无证据禁脑补子条(R6)"            "$(cnt '^75\.11 ' "$CR")" 1
   ```
3. 尾行 `echo "Total: 15 PASS=$PASS FAIL=$FAIL"` → `echo "Total: 18 PASS=$PASS FAIL=$FAIL"`

## S3 自检 3 条（输出摘要写检查点）
V1 `grep -c '^75\.9 ' skills/plan-research-router/references/critical-rules-research.md` =1 且 `grep -c '^75\.10 '` =1 且 `grep -c '^75\.11 '` =1 且 `grep -c '^75\.12 '` =1
V2 `grep -c '^75\.8 '` 仍 =1（75.0-75.8 原文零改动核验）
V3 `bash skills/task-planner/scripts/selftest-proactive-research.sh` rc=0 且末行 `Total: 18 PASS=18 FAIL=0`

## 禁止
- 不得 git commit / 部署 / 跑 run-selftests 全量回归（主进程收口）
- 不得改 75.0-75.8 原文、config.json、其他 selftest 脚本、宪法 AGENTS.md
- 不得越 spec；与 E 组（rule102/hook/级联）文件零交集，若发现 E 组正在写同文件=STOP 报告主进程，不抢写

## 返回
≤300 字：S1-S3 完成状态+V1-V3 实测值+偏差清单（无则写「无」）。
