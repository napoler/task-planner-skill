# 偏移检查检查点 — task-v147-research-first（Rule 61 载体语义 / 只读检测）

> 检查触发点：Phase 2 标记 complete 后（Rule 15.1 触发时机表）
> 检查体：偏移检查执行体（只读；本文件=唯一写权限，22.8 契约）
> 检查时间：2026-10-08
> 被检产物：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first` commit `5fac178`（8 文件 +38/-15）

## T1 判定（结论先行）

**status: ALIGNED**

Phase 2「worktree 创建与规则文本落地」全部动作落在计划 scope 文件清单内，VC-1/VC-2/VC-3 判据逐条实测通过，无计划外文件改动、无业务逻辑越界；唯一偏差（额外命中 3 个 selftest 脚本 vs 计划「≤2 个」约束）已在 findings 偏差登记 + Handoff 备注中记录并授权续做，且属 Rule 63 落地后守卫必然级联的强制同步，非漂移。

## T2 证据（逐条锚）

### 2.1 VC 判据实测（worktree HEAD=5fac178）
- **VC-1**：`grep -cE '^63\.[1-6] ' critical-rules.md` = **6**；`grep -c '^### 63 '` = **1**；`git show 5fac178 -- critical-rules.md` 无任何 `-` 删除行 = **纯追加 +18/-0**。头注/正文零改动。
- **VC-2**：`grep -c "1-63" SKILL.md` = **3**（:9 全集行 / 详见行 / 知识库表行）；`grep -c "Rule 63" SKILL.md` = **4**（摘要 bullet + C44 + 详见行 + 表行）；**C44 行在位**（:213）。SKILL.md diff = +5/-3，仅三处计数 + bullet + C44，其余行零改动。
- **VC-3**：`grep -n "Rule 63" subagent_dispatch.md` = **:27**，含「检索/不知道/来源锚/禁编造」全语义（检索优先契约行）；diff = +1/-0。
- **CHANGELOG.md**：`[Unreleased]/新增` 头部 Rule 63 条目在位（+1/-0）。

### 2.2 scope_files 边界（8 文件逐一核对）
| # | 文件 | 计划清单归属 | 判定 |
|---|------|-------------|------|
| 1 | `references/critical-rules.md` | 规则文档（尾部追加 Rule 63） | ✓ 纯追加 |
| 2 | `SKILL.md` | 技能主文档（1-62→1-63×3 + bullet + C44） | ✓ |
| 3 | `templates/subagent_dispatch.md` | 派发模板（§2 契约行） | ✓ |
| 4 | `scripts/selftest-four-file-dataflow.sh` | 守护脚本（FF-16 宽容化） | ✓ 计划内 |
| 5 | `scripts/selftest-evidence-goal-gate.sh` | 守护脚本（锚扫描命中「其他 selftest-*.sh」#1） | ✓ |
| 6 | `scripts/selftest-iteration-persistence.sh` | 守护脚本（锚扫描命中「其他 selftest-*.sh」#2） | ✓ |
| 7 | `scripts/selftest-requirement-coverage.sh` | 守护脚本（锚扫描命中「其他 selftest-*.sh」#3） | ⚠ 超「≤2」上限，见 T3-1 |
| 8 | `CHANGELOG.md` | 变更日志 | ✓ |

- 全部 8 文件均落在 scope「允许的文件」类别内，**无类别外文件**（无其他 references/*.md、其他模板、其他业务 scripts）。
- 4 个 selftest 脚本 diff 逐行审阅：**全部为 `^63\.`→`^64\.` 锚宽容化 + 注释同步**，零业务逻辑改动；`selftest-requirement-coverage.sh` 仅 :162 注释、:171 新增演进史注释、:172 断言行。

### 2.3 无计划外改动
- worktree `git status --short` = 干净，无未提交残留。
- 无保护区外文件、无其他 plans/ 目录、无基础设施配置被触碰。

### 2.4 Handoff 三证据链（rows 1-4，Rule 22.5）
- 1 S1：done，结论「63.1-63.6 逐字落地 +18/-0 纯追加」+ 证据（grep=6/1+diff）+ findings 落点 + checkpoint `1-executor.md` + verify_done ☑。
- 2 S2：done，结论「四锚+CHANGELOG 落位；AC2 系判据过度指定，计划 VC-2 实测过」+ 证据 + findings + checkpoint `2-executor.md` + ☑。
- 3 S3：done，结论「:27 单行逐字插入 +1/-0」+ 证据 + findings（主进程兜底回填）+ checkpoint `3-code-assistant.md` + ☑。
- 4 S4：done，结论「FF-16/EG-16/IP-14 三文件 63.x→64.x 共 10 处；FF 复跑 18/18；RC-15 登记未改→已授权续做」+ 证据（主进程复跑 FF=18/18、RC=23/23）+ findings（含 RC-15 追加）+ checkpoint `4-executor.md` + ☑。
- 三证据链（结论摘要 / file:line 证据 / checkpoint）**完整闭合**，无缺环。

## T3 观察项（非偏移，登记供收口复核）

1. **S4 额外命中 3 文件 > 计划「≤2 个」上限（唯一偏差，已登记+授权）**：计划 scope 允许「锚扫描命中的其他 selftest-*.sh（宽容化，≤2 个，逐个登记）」，实际额外命中 EG-16/IP-14/RC-15 共 3 个。findings「偏差登记」段记录「实际命中 3 个额外文件，改 2 个、登记 RC-15 不改」，随后「RC-15 收尾（task-v147 追加）」记录其被宽容化（:162/:173，复跑 RC=23/23 PASS）；Handoff row4 备注「超 ≤2 上限 → 已授权续做」。**判定非漂移依据**：① 文件类别在 scope 白名单内（非计划外文件）；② RC-15 的 `grep -c '^63\.'`=0 负断言在 Rule 63 落地后必 FAIL（实测落地后 `^63.` 命中 6），宽容化为**强制级联同步**而非主动扩范围；③ 偏差已登记 + 主进程授权，处理方式符合 22.3/偏差登记范式。建议 Phase 4/5 复核时确认授权出处（本计划文件内为 Handoff 备注口径）。
2. **Phase 2 单元表 S1-S4 行状态仍为 `pending`**：Phase 2 段落 Status=complete、Handoff rows 1-4=done，但 S1-S4 明细行「状态」列未翻转为 done（簿记滞后，非内容偏移），建议收口补齐。
3. **Phase 3 段落 Status=in_progress**：与 Handoff S5=queued、「下一 Phase 待派发」一致（当前阶段开启态），非偏移。
4. **S2 验收 AC2 FAIL 已裁决**：progress [main] 记录 AC2 系「验收判据过度指定（grep 模式含全角括号）」，计划 VC-2 原判据实测通过（1-63×3 / Rule 63×4 / C44 在位）——主进程裁决与本次实测一致，非偏移。

## T4 建议（收口动作）

- 保持当前方向：Phase 2 无实质漂移，可继续派发 Phase 3（S5 selftest-research-first.sh 新增 + registry 登记）。
- Phase 2 收口回填：task_plan Phase 2 单元表 S1-S4 行状态 pending→done。
- Phase 4/5 复核：RC-15 超限授权的书面出处（当前仅 Handoff 备注），确保偏差闭环可追溯。

## T5 最终结论

**status: ALIGNED** — Phase 2 落地内容与 VC-1/VC-2/VC-3 逐条对齐（实测 6/1、1-63×3、Rule 63×4、C44、dispatch :27），8 文件全部落在 scope 类别内且无类别外/计划外改动，Handoff 三证据链完整；唯一偏差（额外 selftest 脚本 3>2）已登记+授权+属强制级联，非漂移。confidence: HIGH。

---
<!-- 只读检测体：本文件为唯一写入物（22.8 检查点契约）；未写 findings/未改任何计划正文 -->
