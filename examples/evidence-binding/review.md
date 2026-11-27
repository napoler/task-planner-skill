# 证据绑定 + 派生 MD 保护 — 审查实物（Rule 113.10）

- 目标：证明 `check-evidence-binding.sh` 与派生 MD 直写保护可被机器判别（正例 + 负控制 + mutation）。
- 会话内实测基线：worktree `wt/task-comet-trust-learning-20261127` @ 782e70b9；`<WT>` = 该 worktree 绝对路径。
- 接口校正：brief 内联示例把 JSON 经 stdin 管道喂给 `check-scope.sh`，但盘上脚本只读位置参数
  （`TOOL="$1"` / `FILE_PATH="$2"`，真实 hook `zcode-pretooluse.sh:18` 亦为 `bash check-scope.sh "$tool" "$file"`）；
  下表 C2/C3 按真实接口实测，stdin 管道版本恒 rc=0，不构成负控制。

## 审查命令与判据

| ID | 命令 | 预期 | 实测 |
|---|---|---|---|
| C1 | `bash skills/task-planner/scripts/selftest-evidence-binding.sh` | `PASS=4 FAIL=0 SKIP=0`, rc=0 | `PASS TC-01..TC-04`；`Total: PASS=4 FAIL=0 SKIP=0`；rc=0 |
| C2 | `env -u TASK_PLANNER_SID bash skills/task-planner/scripts/check-scope.sh Write "$WT/plans/task-demo/task_plan.md"` | rc=1，输出 `[scope] BLOCKED 派生 MD 禁止直接写入` | rc=1，4 个派生 MD basename 均 BLOCKED |
| C3 | `env -u TASK_PLANNER_SID TASK_PLAN_ALLOW_RENDER=1 bash skills/task-planner/scripts/check-scope.sh Write "$WT/plans/task-demo/task_plan.md"` | rc=0 | rc=0，4 个派生 MD basename 均放行 |
| C4 | `printf '{"schema_version":1}' > "$D/plan-state.json"; bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'a%.0s' {1..64})"` | rc=1（mutation 存活） | `[evidence-binding] rc1: no current-version binding for a.md`；rc=1 |

C4 说明：brief 原表写作「删 `evidence_binding` 字段后重跑 C2」，但 C2 是派生 MD 门、不读该字段；
盘上对应 mutation 控制是 `selftest-evidence-binding.sh` TC-04 / `check-evidence-binding.sh`（上表已按真实门校正）。

## 派生 MD 门的判别性

- 失败先行：插入保护段前 `selftest-scope-boundary.sh` 为 `PASS=8 FAIL=1`（TC-08 红）；插入后 `PASS=9 FAIL=0`，rc=0。
- 负控制覆盖 `task_plan.md` / `findings.md` / `progress.md` / `verification.md` 四个 basename，均 rc=1；正例同四路径持 `TASK_PLAN_ALLOW_RENDER=1` 均 rc=0。
- 语义边界：仅收紧上述 4 个 basename；`plan-state.json` 等其它 `plans/` 路径与 `tmp/` 路径放行 rc=0。
- 已知边界：保护段位于节② plans/ 祖先豁免与节③ basename 豁免之前；无 render 令牌时任何位置形态（主工作树/worktree）下落在 `*/plans/*/` 的这 4 个文件均被拦。
