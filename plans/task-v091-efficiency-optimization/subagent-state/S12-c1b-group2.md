# S12 检查点 — C-1b 位点组 2：config 双层路径修复（jq 单层路径 → 顶层覆盖优先）

- task: task-v091-efficiency-optimization / subagent: S12 (executor)
- date: 2026-09-27
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091（HEAD 基准 de69956 = S11 组1；未 commit，改动留在工作区）
- status: complete

## 1. 改动文件（4 个，均 bash -n 通过，未 commit）

| 文件（worktree 内绝对路径） | 修复位点 | 键 |
|---|---|---|
| skills/task-planner/scripts/check-dispatch.sh | :131（原 :130） | dispatch_contract_enforce |
| 同上 | :270（原 :268） | prompt_max_chars（.subagent.prompt_max_chars 三层） |
| skills/task-planner/scripts/subagent-fallback.sh | :48/:50/:52/:54（原 :46-52） | provider_fallback.enabled / variant_types / fallback_slugs / probe_timeout_ms（.provider_fallback.X 三层） |
| skills/task-planner/scripts/check-complete.sh | :115（原 :114） | delegation_rate_floor |
| 同上 | :472（原 :470） | fmea_enforce（任务指定） |
| 同上 | :541/:707/:809/:847/:880 | vc_gate_enforce / error_loop_enforce / reflect_verify_enforce / skill_modify_enforce / mechanism_profile_enforce |
| skills/task-planner/scripts/check-plan-dispatch.sh | :75（原 :74） | plan_tier_enforce（任务指定，S11 移交位点） |

共 14 处表达式改动 + 12 行注释，范式统一：`.X // .properties.X.default // <原兜底>`（嵌套键 `.subagent.X // .properties.subagent.properties.X.default // <原兜底>`、`.provider_fallback.X // .properties.provider_fallback.properties.X.default // empty`）。

## 2. 扫描结论（同款缺陷新增 9 处，超出指定 4+1 点）

grep 逐一确认：指定 4 点 + 同款扫描新增 10 处（dispatch_contract_enforce、delegation_rate_floor、vc_gate_enforce、error_loop_enforce、reflect_verify_enforce、skill_modify_enforce、mechanism_profile_enforce 7 处顶层键 + 已含在指定内的 prompt_max_chars/provider 组）。全部 14 处已按范式修复。

不动项（结构不同/已正确，零改动）：
- check-dispatch.sh :312（step_max_steps，已是正确 `.properties.subagent.properties.X.default` 双层路径 — 与 S11 保留 check-plan-dispatch :120 同决策）
- check-plan-dispatch.sh :117-118（S11 已修）、:122（step_max_steps 正确路径）
- subagent-fallback.sh :64（v2 provider 表）、:82-83（baseURL/apiKey）、:145+（meta/自造 JSON）— 非 config.json schema 读取
- check-complete.sh :400-431（stats_output JSON）— 非 config 读取

## 3. 验证证据（夹具 /tmp/c1b2-test/run.sh，表达式自改动文件与 git show HEAD: 动态提取对拍）

- case① 顶层覆盖：14 键全部读出覆盖值（prompt_max_chars→2500、provider 4 键→test-*、fmea→enforce、plan_tier→off、delegation_rate_floor→0.5、其余→off/enforce）；enabled 夹具将 schema 默认翻 false + 顶层 true → 读出 true，证明顶层覆盖优先
- case② 原版对拍：10 个顶层键 old vs new 输出逐值 SAME；4 个 provider_fallback 键 DIFF（old 恒 empty = 被修复缺陷本身；new=schema 默认，与脚本内置默认 CFG_* 逐字相同 → 消费者可见行为零变化，无回归）
- case③ 空 config {}：全部落原兜底（3000/enforce/warn×7/0.7/empty×4）
- `bash -n` 4 文件全部 PASS；git diff 逐行核验仅 14 表达式 + 12 注释行

## 4. 风险/遗留（如实登记）

1. jq `//` 对 false 的 falsy 语义：`provider_fallback.enabled=false` 顶层覆盖会被 `//` 跳过落 schema 默认 true（case④ 实测输出 true）。改动前该键恒 empty → 消费者同样恒 true → 无回归，但 kill-switch（subagent-fallback.sh :257 `!= "true"` → escalation）对 false 覆盖仍不生效。如需支持 false 覆盖，须改用 null-safe 形态（`if .provider_fallback.X != null then ... end`），超出本组「照范式修复」授权，留后续裁决。
2. config.json 顶层覆盖键与 schema `additionalProperties: false` 冲突：jq 不校验 schema，运行时读取无影响；但严格 schema 校验场景下覆盖键会报 additionalProperties。本组不处理（既有约定即双层结构）。
3. 原文件中提及旧路径的注释行（如 check-dispatch.sh :40/:266-267、:116/:118、check-plan-dispatch.sh :29/:43、check-complete.sh :875 注释）按纪律未改动，与新注释并存。

## 5. 返回 8 字段

- status: complete
- files_written: 4（worktree scripts，未 commit）+ 本检查点
- evidence: 见 §3
- key_decisions: 嵌套键 override 形态按 S11 同构（.subagent.X / .provider_fallback.X 顶层对象优先）；同款扫描 9 处一并修复；provider 组原兜底 empty 保持
- risks: §4.1 false 覆盖 falsy 语义（无回归、留证待裁决）
- next: 主进程验收 + VC 复验 + 合并回合约（worktree 内 git status 需为干净后 merge）
- fallback_used: none
- checkpoint_path: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S12-c1b-group2.md
