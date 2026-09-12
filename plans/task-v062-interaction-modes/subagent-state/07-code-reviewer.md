# 07 Code Reviewer — task-v062 交互双模式（Code Review Gate）

- **status**: completed
- **task_id**: code-review-v062
- **verdict**: CHANGES_REQUESTED（P0=0 / P1=2 / P2=3 / P3=4）
- **scope 复核**: `git diff d7fab2a..HEAD --stat` = README/SKILL/plan-writer/config/critical-rules/resolve(新)/selftest(新)/templates，与计划 scope_files 一致；`git status --short` 干净
- **基线命令**:
  - `bash -n` 两脚本均 OK；`bash scripts/selftest-interaction.sh` → 8/8 PASS EXIT=0
  - 6 套件全量：active-plan 13/0 + delegation 38/0 + dispatch 18/0 + fallback 21/0 + interaction 8/0 + plan-dispatch 6/0 = 104 PASS / 0 FAIL（VC-4 ≥96 达标），跑后台 worktree 仍 clean
- **P1-1（解析器与真实写法口径漂移，含静默错误）**: `scripts/resolve-interaction-mode.sh:63-70` 只接受值列**纯** `ask|silent`，真实计划值列带注解（本计划 `task_plan.md:13` `| \`interaction_mode\` | \`silent\`（用户直接下令…） |`）→ ② 层判非法 → 静默降级 ③ → 输出 `ask`（实测：`bash scripts/resolve-interaction-mode.sh plans/task-v062-interaction-modes` = `ask`，与本计划声明 silent 矛盾）；stderr 0 字节，无任何诊断
- **P1-2（VC-2 联动漏项）**: SKILL.md `:384`（baseline `:382`，22.3 兜底链第 5 行 AskUserQuestion）无 Rule 28 注记；findings 联动表 #3 明确要求 :148/:382/:291 三处注记，实际只落 :149/:293（+新增 :80/:280）
- **P2 发现**: ② 层无诊断输出（§五 错误必须曝光 vs 28.1 降级语义）；selftest 未覆盖"值列带注解"与顶层 `.interaction_mode` 形状（正是漏掉 P1-1 的原因）；`\s` 为全仓唯一 GNU 扩展用法（macOS BSD grep 下多空格行不匹配），其余脚本统一用 `[[:space:]]`
- **P3 发现**: trap 仅 EXIT（无 INT TERM）；run_case `local num` 未用 + assert FAIL 行重复打印编号；脚本头 "fail-open 语义" 措辞与实际"降级到最保守默认 ask"不符；README "19 键" vs config `properties` 实为 22（基线 18/21，属既有偏差非本次引入）
- **冲突检查（维度 5）**: Rule 28 D6 与 Rule 11 drift BLOCKED / 22.7 连续失败 STOP / Rule 26 Q3 语义一致，无矛盾；Rule 7 三击（reference.md:226「3次后: 升级用户」）未被 D6 列举，但 check-drift.sh:284 CRITICAL ERROR-LOOP → drift 层覆盖，判 LOW 风险
- **jq 缺失**: 实测（PATH 去 jq）config default=silent → `ask`，env silent → `silent`，rc=0，与 28.1/28.5 fail-safe 描述一致（仓内并存 failopen/nojq/fail-closed 三种旧范式，本脚本取向=保守默认，可接受）
- **结论**: P1 两条须修（解析器值列容忍度 + SKILL.md:384 注记）后复跑 6 套件；其余 P2/P3 建议同轮合并

## 候选修复预验证（/tmp 副本，未动 worktree 任何文件）
- P1-1 修复 = ② 层改为 `awk -F'|' '{print $3}' | sed -E 's/^[[:space:]]*`?([A-Za-z_]+)`?.*$/\1/'` + grep `^|[[:space:]]*`
- 结果：真实 plans/task-v062-interaction-modes → `silent`（修复前 `ask`）；模板占位行 → `ask`；`banana` 行 → `ask`（降级保留）；无注解行 → `silent`；**修后 8/8 PASS EXIT=0 不变**
- worktree 复核：`git status --short` 仍为空（只读审查无副作用）
