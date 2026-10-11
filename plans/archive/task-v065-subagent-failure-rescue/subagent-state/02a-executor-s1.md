
## Init/勘察 (2026-09-13) — worktree + 目标脚本现状确认
- WT=/home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue branch=wt/task-v065-subagent-failure-rescue HEAD=c31f3dc clean=Y
- P0 复现: check-plan-dispatch.sh 对「- **Executor:** 行 + 无 S-unit 表」计划输出 legacy → rc=0（应 rc=1）
- 关键约束: 模板+30 个真实计划全部用 `- **Executor:**`；v058 selftest 夹具用裸 `**Executor:**`(无 dash) → F-2 修复后 T01-T03/T06 夹具须补 dash 前缀，否则判 legacy 破坏既有断言
- jq 存在: /usr/bin/jq jq-1.7（jq 缺失路径须用受限 PATH 模拟实测）
- 基线: bash selftest-plan-dispatch.sh → 6 PASS=6 FAIL=0 rc=0

## F-2 完成 (check-plan-dispatch.sh legacy 判定键) — 修复生效
- 改动: 判定键 `grep -q "执行体"` → `grep -qE "^- \*\*Executor:\*\*"`；文案改「legacy plan(无 `- **Executor:**` 行)」；文件头注释补 2026-09-13 task-v065 S-1 F-2 记录
- 证据1: `bash -n check-plan-dispatch.sh` → rc=0
- 证据2: 违规夹具(有 `- **Executor:**` 行/无 S-unit 表) → `[plan-dispatch] ✗ Phase 1: 缺 S-unit 表或数据行(Rule 22.6)` rc=1（修复前 rc=0 legacy 放行）
- 证据3: legacy 夹具(无 dash-Executor 行) → `[plan-dispatch] legacy plan(无 \`- **Executor:**\` 行),跳过门控` rc=0
- 回归: 30 个 dash-Executor 真实计划 → 21 PASS / 9 FAIL；9 个中 8 个 HEAD 原文为 legacy 放行(旧 bug 漏放)，1 个(v053)本来就 FAIL；9 个计划「执行体」出现次数全为 0（v057/v056 的 S 表缺「执行体」列，其余无 S 表）→ 判定为**真阳性**非回归
- 风险 F-2-a: 本任务自身 v065 计划 Phase 1/3/4 无 S-unit 表 → 终验 check-complete.sh 会在 PLAN-DISPATCH 门 exit 1（修复前被 legacy bug 掩盖）

## F-1 脚本完成 (check-rescue-chain.sh 新建) — 档位语义/三查/--json/exit 全按规格
- check-rescue-chain.sh (新, 247行→含修订 约250行): Handoff 区块状态机扫描; failed|timeout 行三查(checkpoint非空/rescue留痕/subagent-state 文件存在[列内路径或 {seq}-{agent_type}.md 模式, 含 001→01 补零归一]); 档位 env TASK_PLANNER_RESCUE_CHAIN_ENFORCE > config rescue_chain_enforce.default > fail-open warn(jq 缺失 stderr 说明); off 档提前 exit 0; --json 手写转义不依赖 jq
- 证据: bash -n rc=0; 参数错误(无参/坏目录/未知选项) rc=2; enforce 违规 rc=1; warn/off 恒 rc=0; jq 缺失(受限PATH无jq) fail-open warn rc=0 + stderr "jq 不可用 — fail-open 降级 warn 档"; --json 输出单行合法 JSON(stdout 行数=1, jq 复解析通过)
## 接入 check-complete.sh + config.json 完成
- check-complete.sh +20行: PLAN-DISPATCH 门后接入, enforce 违规 rc=1 时阻断 complete(exit 1 + RESCUE-CHAIN GATE FAILED), warn/off/参数错误不阻断; 脚本缺失 fail-open
- 证据 E2E: 合成 complete-phase 夹具+failed Handoff 行 → 默认 warn 档 check-complete rc=0(仅打印警告); TASK_PLANNER_RESCUE_CHAIN_ENFORCE=enforce → rc=1 "[plan] RESCUE-CHAIN GATE FAILED" — 两档语义实测
- config.json +11行: properties.rescue_chain_enforce {enum:[enforce,warn,off], default:warn} 插入 content_quality_enforce 与 provider_fallback 之间(对齐既有 enforce 键块); jq 校验 default=warn/enum=3 通过
## 真实夹具演示 (warn 档) 完成
- 证据: 真实计划 /mnt/.../plans/task-v065-subagent-failure-rescue 原样 → "[rescue] ✓ 挽救链路完好 (failed/timeout 行=0...)" rc=0; 合成 +1 failed 行 → "[rescue] Handoff 行 155: 状态=failed checkpoint列空, rescue列缺失..., checkpoint文件缺失" + warn 不阻断 rc=0; --json verdict=violation
## selftest 全绿完成
- selftest-plan-dispatch.sh: 6→8 用例(T07 有 - **Executor:** 行无表→rc=1 拦截; T08 无 Executor 行 legacy→rc=0 放行; 旧夹具 T01-T03/T06 补 dash 前缀保持 modern 判型; T04 裸 Executor 保持 legacy 判型); T07 夹具 vs HEAD 原文脚本 rc=0(误放行) vs 修复后 rc=1 → 真回归测试
- selftest-rescue-chain.sh(新): 11 断言全 PASS(T01 enforce违规rc=1 / T02 rescue齐rc=0 / T03 无failed行rc=0 / T04 off档rc=0 / T05 warn默认rc=0 / T06a+b --json合同 / T07 rescue列缺失违规 / T08 timeout+模式命中 / T09 参数错误rc=2 / T10 无plan fail-open)
## commit 待执行
- 6 文件: check-plan-dispatch.sh(M) / check-rescue-chain.sh(new) / check-complete.sh(M) / selftest-plan-dispatch.sh(M) / selftest-rescue-chain.sh(new) / config.json(M); 工作树 git status 仅此 6 文件

## commit 完成 — 1b84ca3, worktree 干净
- 证据: `git add` 恰好 6 文件(无 git add -A) → `git commit` → `1b84ca3cc85adaa8ced7dffae620ce2f6c3ba811`; diffstat: 6 files changed, 487 insertions(+), 12 deletions(-); commit 后 `git status --short` 为空
- S-1 全部里程碑: Init / F-2 / F-1 / 接入+config / selftest 全绿 / commit = done
