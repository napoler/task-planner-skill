# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner 技能族内新建独立技能 `context-corrector`（否定/矛盾触发→上下文与历史文档整理纠正 SOP）+ 新增 Rule 98（纪律域触发纪律）+ 既有触发点文本接线，纯文本条款档零新增机器守卫，落地 master 后全量 selftest 零回归。

---

## Verification Contract (≥5 items, objective standards)

> 以下五条全部 PASS = COMPLETE。`<wt>` = /mnt/data/dev/task-planner-skill-worktrees/task-ctxcorrect-20261103

- [ ] VC-1: 新技能在位且 frontmatter 完整（name/description/tools），SOP 含双触发面判据（用户否定/前后文矛盾）
  **Verify command**: `test -f <wt>/skills/context-corrector/SKILL.md && grep -c '^name: context-corrector' <wt>/skills/context-corrector/SKILL.md && grep -c '前后文矛盾' <wt>/skills/context-corrector/SKILL.md` → 1 / ≥1
  Evidence: P4 命令输出
- [ ] VC-2: Rule 98 五子条在纪律域在位（98.1 用户显式/98.2 自主矛盾/98.3 整理优先/98.4 下游阻断/98.5 边界互引）+ Rule 31/65 交叉指针
  **Verify command**: `grep -n '^### 98' <wt>/skills/task-discipline/references/critical-rules-discipline.md && grep -c '前后文矛盾' <wt>/skills/task-discipline/references/critical-rules-discipline.md && grep -c 'context-corrector' <wt>/skills/task-discipline/references/critical-rules-discipline.md` → 全 ≥1
  Evidence: P4 命令输出
- [ ] VC-3: 触发点接线完成：task-planner SKILL C 矛盾类处置句+Rule 31 衔接句含 `context-corrector` 指针；Rule 全集索引 1-97→1-98 且纪律域列表含 98；`1-97` 旧纪元在 SKILL.md/critical-rules.md 计数面清零
  **Verify command**: `grep -c 'context-corrector' <wt>/skills/task-planner/SKILL.md && grep -c '1-97' <wt>/skills/task-planner/SKILL.md <wt>/skills/task-planner/references/critical-rules.md` → 前者≥2，后者各=0
  Evidence: P4 命令输出
- [ ] VC-4: 既有 selftest 全量回归 FAIL=0（纪元锚级联锁步后无回归）
  **Verify command**: `cd <wt> && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -3` → 汇总 FAIL=0
  Evidence: P4 命令输出（红锚按 FMEA 兜底逐个修复后复跑）
- [ ] VC-5: 收口：merge commit 在 master + worktree/分支无残留 + 规则账本 98 reserve/land 双行
  **Verify command**: `git -C /mnt/data/dev/task-planner-skill log --oneline -3 && git -C /mnt/data/dev/task-planner-skill worktree list && grep -c '"rule":98' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl` → merge 提交可见 / 无 task-ctxcorrect-20261103 行 / ≥2
  Evidence: P5 命令输出

---

## Phase Gates

### Phase 1: 机制缺口调研与级联面扫描
**Goal**: 缺口矩阵+级联面清单+编号 98 可用性结论落 findings.md；attest 锁
**Depends on**: none
**Done when**:
- [ ] findings.md「机制缺口矩阵」段在位（六既有机制逐条判缺口）
- [ ] findings.md「级联面清单」段含逐行 file:line 锚
**Verification**:
- [x] V-1.1: `grep -c '机制缺口矩阵\|级联面清单' <plan-dir>/findings.md` ≥1（映射 VC-1 前置事实）
- [x] V-1.2: attest-plan.sh 通过（Rule 98 自动登记 reserve；映射 VC-5 前置簿记）→ 锁定 70372cf3（V-2.2 单位修正后重锁 6d80f1b0）

Status: `complete` Last verified: 2026-11-03（attest 通过后翻格）

### Phase 2: worktree 建成 + 新建 context-corrector 技能
**Goal**: worktree 在位 + SKILL.md 全文（frontmatter+触发判定+SOP 六步+边界互引+非目标声明）
**Depends on**: Phase 1
**Done when**:
- [ ] `git -C <wt> status --short` 显示 `?? skills/context-corrector/`
- [ ] SKILL.md ≤5K 字符（宪法 §九 推荐值）
**Verification**:
- [x] V-2.1: 在 worktree 内跑 VC-1 的 Verify command（映射 VC-1）→ name=1/前后文矛盾=3
- [x] V-2.2: `wc -m <wt>/skills/context-corrector/SKILL.md` ≤5000（字符口径=宪法 §九「单文件 ≤5K 字符」；CJK 3 字节/字符故不用 wc -c 字节口径；实测 3924；映射 VC-1）

Status: `complete` Last verified: 2026-11-03（worktree 在位+SKILL.md 3924 字符/V-2.1/2.2 PASS）

### Phase 3: Rule 98 条款 + 触发点接线 + 1-98 纪元级联
**Goal**: Rule 98 五子条+31/65 指针+task-planner/task-discipline 接线+全仓 1-98 锁步，worktree 内 commit
**Depends on**: Phase 2
**Done when**:
- [x] worktree 内 `git status --short` 仅 scope_files 变更
- [x] 级联 grep 复核：`grep -rn '1-97' <wt>/skills/task-planner/` 计数面=0（注释/历史锚除外逐行人工判定；selftest 脚本锚=级联锁步面归 P4 兜底）
**Verification**:
- [x] V-3.1: 在 worktree 内跑 VC-2/VC-3 的 Verify command（映射 VC-2/VC-3）
- [x] V-3.2: `git -C <wt> log --oneline -2` 本 Phase 产物 commit 在位（Rule 27；映射 VC-5 前置）→ 5e6e472

Status: `complete` Last verified: 2026-11-03（主进程逐行 Read 复核 S5/S6 全命中）

### Phase 4: 回归与独立复验
**Goal**: selftest 全量 FAIL=0 + 独立复验 VC-1/2/3
**Depends on**: Phase 3
**Done when**:
- [x] run-selftests.sh 汇总 FAIL=0（命令输出粘贴 progress.md）→ Total: 94 PASS=94 FAIL=0（RC=0，首轮 FAIL=2=纪元锚红→锁步 6ad1686 后复跑绿）
- [x] 独立复验记录落本文件 Phase 4 段
**Verification**:
- [x] V-4.1: 跑 VC-4 的 Verify command（映射 VC-4）→ 94/94 FAIL=0
- [x] V-4.2: 独立上下文复跑 VC-1/2/3 三条 Verify command 并记录输出（映射 VC-1/2/3 独立面；verifier 首派**编造输出**（tool_uses=1 未执行命令即拼写「原始输出」，所引 L216/allowed-tools 与磁盘不符）→ §三 P0 判例，主进程磁盘实测接管：VC-1 1/3、VC-2 644:### 98/3/5、VC-3 2/0/0+1-98 三处 L9/L210/L253，3/3 PASS；verifier 回报作废不计证据，Errors 表已登记）

Status: `complete` Last verified: 2026-11-03（VC-4/独立面 3/3 PASS；纪元锚 2 脚本锁步 commit 6ad1686）

### Phase 5: 合并收口
**Goal**: 全 VC 复验→smart-merge-back→清理 worktree/分支→账本 land 98→check-complete→归档→交付总结
**Depends on**: Phase 4
**Done when**:
- [ ] 主仓 `git status --short` 无 scope_files 未提交变更
- [ ] 交付总结五要素（Rule 48/76）输出 + 遗留登记（部署位同步待授权）
**Verification**:
- [ ] V-5.1: 跑 VC-5 的 Verify command（映射 VC-5）
- [ ] V-5.2: `bash /home/terry/.zcode/skills/task-planner/scripts/check-complete.sh <plan-dir>` exit 0（映射 Goal）

Status: `pending` Last verified: —

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 纪律域规则文风体例 | Rule 98 段头尾注体例（「目标：…判定面=…衔接 Rule …既有条款原文零改动」）对照 31/65/95 段 | 终验填 |
| 纪元级联判例 | P3 级联 grep 复核记录（progress.md 行） | 终验填 |
| 同族技能体例 | context-corrector SKILL.md frontmatter 与 task-drift-guard 逐字段对照 | 终验填 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
（P5 粘贴 JSON 输出）
```
