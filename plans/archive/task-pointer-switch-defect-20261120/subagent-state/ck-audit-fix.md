# ck-audit-fix: 计划文档审计修正（R1 REJECTED 后修正轮）

- task_id: task-pointer-switch-defect-20261120
- time: 2026-11-20T22:05:00+08:00
- status: done (plan-doc fix round)
- scope: 仅计划文档修正 task_plan.md / verification.md / progress.md；未改 findings.md、未改 user-session-log.md、未改技能源文件
- prompt: /mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120/subagent-state/01-audit-fix-prompt.md

## 实读锚点核实（worktree 只读）
- init-session.sh:1205-1207 freshness fallback 抢用分支 `SIDKEY="$_sent_sid"`（D3 身份不确定路径）
- init-session.sh:1229-1256 claimant in_progress -> `SKIP_SIDE_WRITE=1` + skip WARN（当前现状，待执行期 CA-1 修复）
- init-session.sh:1235 claimant 判定当前为裸 `grep -qi 'Status.*in_progress'`（待 CA-2/G3 修复）
- set-active-plan.sh:259-278 claimant 守卫整体；:265 skip 文案；:266 `SKIP_SIDE_WRITE=1`；:273 claimant 判定裸匹配；:278 `exit 0`
- zcode-posttooluse.sh:154-156 `owner==SID` 前置才重锁（删 owner 后回切首轮 Edit 不重锁，次 prompt 可报 PLAN TAMPERED）——支撑 I-2/CA-4/FMEA
- 调用点实读：zcode-sessionstart.sh:72(gc, `|| true`)、selftest-active-plan.sh:16(`SET=...`)、selftest-pointer-lifecycle.sh:13(`SET=...`)、task-discipline/scripts/plan-hygiene.sh:123(提示性)、plan-doctor.sh:56(提示性)；未见 hook 调 `set-active-plan.sh set`

## 12 项修正对照
1. C-1 verification.md VC-3：重写为①正向锚定正则调用（含 `[-*]`/`Status:`/`(\*\*)?` 兼容）②反向剥注释后无裸 `grep -qi 'Status.*in_progress'`；明确“规范修复前红/后绿”。Phase V-1.2 同步。
2. C-2 verification.md VC-5：重写为 `git status --porcelain --untracked-files=all` 全量判别；scope 允许清单 4 文件；过滤非 scope 变更与新增 `.sh/.cjs/.ts`；注明修复前红/后绿；Phase V-4.1 同步。
3. I-1 task_plan.md：CA-1 扩锚至 `init-session.sh:1205-1207,1229-1256`，补 G1 门控（fallback 抢用置 `_sid_fallback=1` 时保留 skip+WARN 不直写；env/sidmap 身份确定才通告+直写）；CA-6/selftest 补 fallback 夹具断言；根源覆盖表/G1/S1/Decisions 同步。
4. I-2 task_plan.md：CA-4 补回切口径“首个工具动作前先 `bash attest-plan.sh` 或先触发一次 prompt 重建 owner 再 Edit task_plan.md”；纳入 VC-4 锚点；根源覆盖表+VC-4 表述+S3+G4+FMEA(Phase2,RPN120)+Decision 同步。
5. I-3 task_plan.md：Goal 区增加边界声明（init 新计划与收口后回切一次成功；同会话两在途皆 in_progress 手动切换依设计仍走 `--force`，VC-2 仅验收提示清晰）；VC-2 措辞对齐；CA-2 登记可选增强“阻塞者选取改为 owner mtime 最新”。
6. I-4 progress.md：重录真实调用点（zcode-sessionstart.sh:72 gc/selftest-active-plan.sh:16/selftest-pointer-lifecycle.sh:13/plan-hygiene.sh:123 提示性/plan-doctor.sh:56 提示性；无 hook 调 set）并结论“保持 exit 0 安全”；替换原空泛评估段。
7. W-1 task_plan.md：锚定正则兼容非加粗 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`；KQ2 补结论与样本 `plans/task-goal-autonomous-20261117/task_plan.md:7`；CA-2/CA-6/G3/S1/S2/VC-3/Decision 补非加粗不漏判夹具。
8. W-2 task_plan.md：CA-3 锚点修正为 `set-active-plan.sh:259-278` 守卫整体 / `:265` 文案 / `:266` SKIP_SIDE_WRITE / `:278` skip exit 0；根源覆盖表/S2 同步。
9. W-3 verification.md：VC-4 与 V-2.2 的 E 块区间锚改为「目标切换判定（E 类」起至下一个 `###` 标题边界（awk `/目标切换判定（E 类/{flag=1;print;next} flag&&/^### /{exit} flag{print}`）。
10. W-4 verification.md：VC-1 补断言“同会话旧 owner 残留时 set 输出『指针未切换』”（含 third-inprog 夹具与 `set-active-plan.sh` 调用）；V-3.1 同步。
11. Q-1 task_plan.md:27：`用户已确认` → `推断（理解镜像 #1，原话『同步开发的技能没有问题』）`。
12. N-1 progress.md：Phase `[Title]` 占位清理为“计划编写记录(complete)”+Phase 1~4 各自命名且全 pending（与 task_plan 对齐）；5Q/底部记录同步；末尾追加 `[plan-audit-R1-fix]` 行。

## 自查
- `{{ }}` 模板残留：仅 task_plan.md/progress.md 文件头渲染契约注释中的 `{{VAR}}` 说明（非待填占位）；未引入新占位。
- 锚点均基于实读：init 1205-1207/1229-1256/1235、set 259-278/265/266/273/278、posttooluse 154-156、调用点行号如上。
- 未新建脚本/hook 基建要求；未改 findings.md、未改 user-session-log.md。

## 下一步（执行期，未在本轮实施）
- 按修正后 task_plan Phase 1 S1/S2 在 worktree 修改 init-session.sh/set-active-plan.sh（含 G1 fallback 门控、锚定正则、skip 文案），再 Phase 2 SKILL、Phase 3 selftest/VC 证据、Phase 4 合并回与同步。
