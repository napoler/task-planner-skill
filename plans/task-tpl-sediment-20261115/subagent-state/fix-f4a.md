# fix-f4a checkpoint (C-10/C-11 partial, CA-14)

- status: done
- goal: 在 worktree 修正 C-10 路径深度断链，并逐点判定 install-stub.sh 中 “7 卫星/7 个” 计数语义（仅改明确应改的；其余保持不动并给理由）
- worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115

## C-10：路径深度断链修正
- 文件：`skills/task-planner/references/critical-rules.md`
- 位置：:201（卫星路由索引表中 `plan-template-advisor` 行）
- 修改前：`规则全文见 ../plan-template-advisor/SKILL.md ...`（相对 `skills/task-planner/references/` 为一层向上，到 `skills/task-planner/`，无法到达 `skills/plan-template-advisor/`）
- 修改后：`规则全文见 ../../plan-template-advisor/SKILL.md ...`
- 实测自验（worktree 内）：
  - `ls -la /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115/skills/plan-template-advisor/SKILL.md` 存在（-rw-rw-r--, 5282 bytes）
  - `ls -la /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115/skills/task-planner/references/../../plan-template-advisor/SKILL.md` 解析存在（同上）
- 结论：C-10 已修正（路径改为 `../../plan-template-advisor/SKILL.md`）。

## C-11（install-stub.sh）：计数语义逐点判定
命中（grep -rn "7 卫星\|7 个卫星\|7 个"）：
- :22（文件头注释）
- :246（函数注释）
- :304（调用处注释）

### 逐点判定表
| 位置 | 原文（摘录） | 判定 | 依据（上下文原句/语义） | 处理 |
|---|---|---|---|---|
| `:22` | `plan-collab-router/task-dispatch/task-discipline/media-planner 共 7 个) whole-dir → ...` | **指向“卫星技能安装集合（显示列举集合）”语义，当前集合已扩为 8 个** | 上下文列举 4 项并写“共 7 个”；同文件 `SATELLITE_SKILLS` 数组（:41）现为 8 元素：`plan-research-router, plan-template-kit, plan-cost-guard, plan-collab-router, task-dispatch, task-discipline, media-planner, plan-template-advisor`。该句描述“rsync satellite skills…”的总数说明，需与数组一致。 | **已改为 8 个**（改为 `共 8 个（含 plan-template-advisor）` 口径并保持后续括注一致性）。 |
| `:246` | `[task-v095 P7] 卫星技能整目录安装: 仓库顶层 skills/ 下 7 个卫星(4 既有+task-v171 S39 追加 3 新域, ... )` | **指向“卫星技能集合数量/阶段说明”，与数组 8 不一致（应为 8）** | 紧接其后 :255-276 使用 `for sat in "${SATELLITE_SKILLS[@]}"` 遍历；:41 数组为 8 项。注释写“下 7 个卫星(4 既有+task-v171 S39 追加 3 新域, 零 scripts/config/hook...)”，与当前数组（已含 `plan-template-advisor`）不符。 | **已改为 8 个**（改为“8 个卫星…”并保留其余说明）。 |
| `:304` | `# [task-v095 P7] 7 卫星技能（task-v171 S39 起 4→7）整目录安装到工具位同级 skills/ 目录` | **指向“卫星技能集合数量（显示清单计数）”，与数组 8 不一致（应为 8）** | 调用 `install_satellite_skills "$stub_dir"`，该函数遍历 `SATELLITE_SKILLS`（:41, 8 项）。注释“7 卫星技能（task-v171 S39 起 4→7）”与当前实际 8 项不符（数组已加入 `plan-template-advisor`）。 | **已改为 8 个**（改为“8 个卫星技能（task-v171 S39 起 4→7→8）”或等价清晰表述）。 |

### SATELLITE_SKILLS 与注释一致性（全文件确认）
- `SATELLITE_SKILLS` 定义（:41）：8 元素 = `[plan-research-router, plan-template-kit, plan-cost-guard, plan-collab-router, task-dispatch, task-discipline, media-planner, plan-template-advisor]`（与 `python3` 计数一致，len=8）。
- 使用点：`:255` `for sat in "${SATELLITE_SKILLS[@]}"; do`（遍历数组，动态计数）。
- 注释中仍残留“7 个/7 卫星”的表述有 3 处（:22, :246, :304），均指“集合规模/显示计数”，与当前数组 8 不一致，已按上表逐点改为 8 并保留历史阶段注记（如 `4→7→8`）。
- 注释中明确说明“另 3 个收编卫星...不在本数组——经 lib/install-companion.sh 顶层 skills/*/ 自动发现机制分发…”的文字未改动（该段不含“7/8 卫星”计数口径，不在本次范围内）。

## 证据（实测）
1. `ls .../skills/plan-template-advisor/SKILL.md` 存在（worktree）。
2. `ls .../skills/task-planner/references/../../plan-template-advisor/SKILL.md` 解析存在（worktree）。
3. `grep -rn "plan-template-advisor/SKILL.md" .../skills/task-planner/references/critical-rules.md` 显示 :201（修改前后对照见上文）。
4. `grep -rn "7 卫星\\|7 个卫星\\|7 个" .../skills/task-planner/lib/install-stub.sh` 命中 :22,:246,:304（修改后已更新为 8）。
5. `grep -rn "SATELLITE_SKILLS" .../skills/task-planner/lib/install-stub.sh` 显示定义 :41 与遍历 :255；数组 len=8（python3 验证）。
6. `sed -n '...'` 输出片段用于支撑“逐点判定表”的上下文引用（见本文件与工具输出）。

## acceptance（自验）
- C-10：critical-rules.md:201 已改为 `../../plan-template-advisor/SKILL.md`，相对路径可解析到该文件。OK。
- C-11：对 :22、:246、:304 逐点给出判定（均为“指集合规模/显示计数，数组现为 8，需改为 8”）并完成修改；数组/遍历逻辑未变，仅注释/计数文案对齐。OK。
- 未改动 worktree 内除上述 2 个文件之外的任何文件：OK（本次仅改 `skills/task-planner/references/critical-rules.md` 与 `skills/task-planner/lib/install-stub.sh`）。
- 未触碰 `tmp/worktrees/task-clause-generalize-20261115`：OK（仅操作 task-tpl-sediment-20261115 worktree）。

## issues / 风险
- 仅做文本/注释与路径修正，未执行安装脚本跑通（不在本任务范围）。若后续运行 `install-stub.sh`，行为以当前 `SATELLITE_SKILLS`（8 项）为准，注释已对齐。 
- `install-companion.sh` 顶层 `skills/*/` 自动发现机制会额外分发其它卫星（含 3 个收编卫星说明在注释中保留），本次未改该机制。

## handoff
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-tpl-sediment-20261115/subagent-state/fix-f4a.md