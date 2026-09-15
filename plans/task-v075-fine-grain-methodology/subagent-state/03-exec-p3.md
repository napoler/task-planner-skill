# P3 executor checkpoint (check-dispatch.sh 三项增量)

## 里程碑 ① S0 基线留档 (2026-09-16)
- 操作: 合规夹具 prompt（mktemp 目录 `$TMPD/plans/pt`，三文件+status:/acceptance:/checkpoint:+subagent-state/ 齐备，252 字符）
- 命令: `TASK_PLANNER_PLAN_DIR=<夹具计划目录> bash scripts/check-dispatch.sh pretool <prompt文件> baseline-sid`
  （档位默认=未设 TASK_PLANNER_DISPATCH_ENFORCE，走 config.json dispatch_contract_enforce.default）
- 基线结果（原文）:
  - rc=0
  - stdout: （空，0 字节）
  - stderr: （空，0 字节）
  - warn 计数文件 `${TMPDIR:-/tmp}/task-planner-dispatch-warn-baseline-sid`: 不存在（合规 prompt 不触发 [dispatch-warn]）
  - `wc -m` = 252（远低于 3000）
- 零回归判据: 改后同命令重跑，rc/stdout/stderr/warn 文件存在性须与基线完全一致
- selftest 基线（改前）: `Total: 18 PASS=18 FAIL=0`

## 里程碑 ② S1 落盘 (2026-09-16)
- 改动: `skills/task-planner/scripts/check-dispatch.sh`（worktree 内）
  - 头注释新增 `[2026-09-16 task-v075 P3-S1]` 段（三项检测口径: ① wc -m vs prompt_max_chars / ② distinct `S<n>` 字面集合计数 `grep -oE 'S[0-9]+'|sort -u|wc -l` ≥2, 行首/非行首一律计、非自由文本豁免, warn 档观察期数据用 / ③ pd 非空 + knowledge-brief.md 存在 + prompt 无 `brief`/`§` → 提示; jq 缺失/键缺失 → 回退 3000 + SKIPPED 说明行, 复用 P2 check-plan-dispatch.sh:63-77 范式）
  - 新增函数 `fine_grain_checks`（:237-287）: 三档处置 = warn(stderr 告警 + 命中项合并写一行计数到既有 `task-planner-dispatch-warn-<sid>` 计数文件, 沿用 :209-212 24h TTL 范式) / enforce(合并 stderr 一行 `[dispatch-block]` + exit 2) / off(经 `cmd_pretool` 既有 `:139` 提前 exit 0 跳过)
  - `cmd_pretool` 两处放行分支（三级解析③兜底 warn 分支 + enforce 档主分支）的「缺项扫描通过后」串行槽检查前置调用 `fine_grain_checks`（只增不改: `git diff` 删除行仅 3 处被替换的既有调用行, scan_missing 七项/三级解析 :187-200/serial_slot_check/成功路径静默 exit 0 语义未动）
- 增量规模: check-dispatch.sh +76/-3 = 净增 73 行（≤120 行约束内; 含头注释口径段）
- 三档实测（mktemp 夹具 `$D/plans/pt`, config prompt_max_chars=3000）:
  - ① 超长 3456 字符 prompt:
    - warn: rc=0, stderr `[dispatch-guard] ⚠ prompt 长度 3456 > 3000`, 计数文件含 `2026-09-16T04:42:30+0800 [dispatch-warn] 细粒度检测: prompt 长度超限(3456>3000)`
    - enforce: rc=2, stderr `[dispatch-block] 🚫 细粒度检测未通过(Rule 22.4 KQ3): prompt 长度超限(3456>3000)`
    - off: rc=0 静默
  - ② 双 S-unit（prompt 末行 `执行 S1 后接 S2 两个 S-unit`）:
    - warn: rc=0, stderr `[dispatch-guard] ⚠ 单 prompt 检出 2 个 S-unit ID（Rule 25.2 逐 S-unit 派发）` + 计数 `多 S-unit 打包(2 个 ID)`; enforce: rc=2 同文案 [dispatch-block]
  - ③ knowledge-brief.md 存在且 prompt 无 brief/§: warn rc=0, stderr `[dispatch-guard] ⚠ 计划含 knowledge-brief.md 但 prompt 未引用节锚点(brief/§), 建议按 Rule 21.2/22.4 引用 brief 相关节` + 计数 `knowledge-brief 未引用`; prompt 追加 `引用 brief §2` 后重跑 → 零细粒度输出（静默）
  - 合规 252 字符 prompt 三档复跑: rc=0, 零新增输出
- 基线 diff 一致性: 改后同命令重跑（默认档位, 未设 TASK_PLANNER_DISPATCH_ENFORCE）rc=0, stdout 0 字节 / stderr 0 字节 / warn 计数文件不存在 —— 与 ①基线留档 完全一致（零回归）
- `bash -n scripts/check-dispatch.sh` OK

## 里程碑 ③ S2 落盘 (2026-09-16)
- 改动: `skills/task-planner/scripts/selftest-dispatch.sh`（worktree 内, +69 行）
  - 新增 FG-01..FG-04 断言（hermetic 独立夹具 `$TMP/fgc/plans/task-fg`, 沿用 TS 序列清锁范式 `fgc_pre`）:
    - FG-01 合规短 prompt + 无 brief → rc=0 且 stdout/stderr 全空且 warn 计数文件不存在（基线一致断言）
    - FG-02 超长 3379 字符 prompt + warn → rc=0 + stderr 含 `prompt 长度` + 计数文件含 `细粒度检测`
    - FG-03 双 S-unit ID（S1/S2 字面）prompt + warn → rc=0 + stderr 含 `S-unit ID`
    - FG-04 knowledge-brief.md 存在 + prompt 无 brief/§ + warn → rc=0 + stderr 含 `knowledge-brief`
  - 既有 18 断言（T01-T12 + TS-01..06）行为不变
- 首跑 3 FAIL 根因: `fgc_pre` 只清 wf 未清锁 → 前一用例 fresh 锁撞 warn 档串行槽告警污染 stderr 断言; 修正为 `rm -f "$FGC_LOCK" "$FGC_WF"`（同 TS-06 清锁路径范式）后全绿
- 结果: `Total: 22 PASS=22 FAIL=0`（改前基线 18/18 → 新增 4 断言, 既有 18 全 PASS 无回归）
- `bash -n scripts/selftest-dispatch.sh` OK

## 状态
- P3 S1+S2 完成; 未 commit（commit 归主进程 Rule 27 编排, executor 交付工作树）
- worktree git status: ` M scripts/check-dispatch.sh` / ` M scripts/selftest-dispatch.sh`（仅 2 个 scope 文件, 无越界）
