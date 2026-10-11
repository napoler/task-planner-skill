# Findings & Decisions
<!-- Rule 19.1：子代理返回后紧邻回填；Rule 71：事实结论必带源锚 -->

## Requirements

- R1 完成流程缺归档步骤（用户原话）→ 需在 SKILL.md 终验交付段接线 + 专用脚本
- R2 计划目录堆积是严重缺陷（用户原话）→ 需制度化（Rule 81 + selftest）而非一次性清理
- R3 所有已完成计划全部归档（用户原话）→ 存量批量归档（dry-run→试点→实做）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）

| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| SKILL.md 终验交付段 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:165-184 | ☑ | Research Findings §1 |
| 既有归档先例 | plans/archive/（21 目录）+ commit 714c93b + scripts/plan-hygiene.sh | ☑ | Research Findings §2 |
| 引用面四脚本 | scripts/sync-todos.sh / resolve-plan-dir.sh / set-active-plan.sh / plan-created.cjs | ☑ | Research Findings §4 |
| Rule 20.6 编号账本 | plans/.rule-reservations.jsonl（tail: 77/78/79 landed-parked、80 reserved by v169） | ☑ | Technical Decisions |

## Research Findings

### §1 完成流程末段=无归档步骤（001-explore 勘查 + 本进程直读）
- SKILL.md 终验交付段（skills/task-planner/SKILL.md:165-184）步骤链：Read verification.md → 逐条复验 VC → 委派率统计 → 3-File Gate → 质量门控 → 隔离任务合并回+git 提交核验 → 编号账本 → 交付结论 → delivery-summary → 退出前 check-complete.sh。**全链无归档动作**。
- check-complete.sh 只校验 Phase 完成度与各门控，无归档逻辑；SKILL.md 中"归档"仅 1 处（L46，comet 移交条件"需三件套归档"，语义无关）。
- 证据：plans/task-v170-archive-completed-plans/subagent-state/001-explore.md §1

### §2 既有归档形态=一次性脚本、未持续
- plans/archive/ 现有 21 个目录，全部来自单次提交 `714c93b feat(task-planner): task-v069`（2026-09-14，plan-hygiene.sh --execute 实际 mv）。
- archive 目录不保留 .plan-attestation（历史形态，不追溯）；INDEX.md 单表混列、不列 archive 目录。
- 证据：001-explore.md §2；`git log --oneline -- plans/archive/ | head`

### §3 存量堆积=约 110 个 completed 未归档
- plans/ 根 114 个 task-* 目录：约 110 个 Status=complete 未归档（task-v055 起持续堆积）；约 4 个 in_progress/异常；6 个非 task- 辅助目录（cost-analysis-2026-10-05 / fix-pointer-race-20261007 / incident-reports / task-planner-skill-review 等，天然不命中 task- 前缀过滤）。
- task-v162/v168/v169 未 git 跟踪但为在途（v168 为当前会话指针曾指目标，.session-owner 在场）→ 守卫须 fail-closed 跳过。
- 证据：001-explore.md §3

### §4 引用面=四脚本硬扫 plans/ 根
- set-active-plan.sh（gc 清扫 plans/.plan_required_side/ + 扫 plans/*/.session-owner）/ sync-todos.sh（扫描 plans/*/task_plan.md 生成 INDEX）/ resolve-plan-dir.sh（活跃解析含 mtime 最新 plans/<dir>/task_plan.md）均未排除 archive；plan-created.cjs 已有 archive 前缀跳过先例（L10/L122）。
- 证据：001-explore.md §4

### §5 去留先例=仅 1 次目录级归档
- 历史上目录级归档只有 task-v069 一次（21 个），此后 70+ 任务完成未归档；当时 INDEX 经重跑 sync-todos.sh --index 修正。
- 证据：001-explore.md §5

### §6 S1 补验：glob 行号证据 + 存量三类清单（2026-10-11 explore 002）

**glob 证据**：
- sync-todos.sh:152 forward_sync `done < <(find "$plans_dir" -name "task_plan.md" -type f | sort)`——递归无深度限制，**归档后 archive/<id>/task_plan.md 会被扫入**（需加 `-not -path "*/archive/*"`）
- sync-todos.sh:201 write_index `find -maxdepth 2`——INDEX 生成不会扫进 archive（depth 3）
- resolve-plan-dir.sh:121 `for d in "${PLAN_ROOT}"/*/`——只匹配直接子目录，archive 安全**无需改**（原计划 S5 中 resolve-plan-dir 的 archive 跳过调整为「复核确认」）
- 结论：引用面最小修复集=set-active-plan.sh（复核）+ sync-todos.sh:152（真修）+ resolve-plan-dir.sh（无需修，复核留痕）

**存量三类清单**（plans/ 直接子目录 118 + 根级文件 2 = 120）：
- 类① 可归档候选 53 个（task-* ∧ task_plan.md ∧ Status=complete ∧ 无 owner ∧ 无指针）：v060/v062/v064/v065/v066/v067/v068/v069/v072/v073/v077/v081/v082/v084/v088/v092/v097/v099/v100/v101/v102/v103/v104/v105/v106/v108/v109/v110/v111/v112/v113/v114/v115/v116/v117/v121/v124/v125/v128/v130/v131/v132/v137/v138/v139/v143/v144/v145/v148/v154/v155/v158/v161
- 类② 禁归档 62 个：v142/v165/v170(status=in_progress)、v146(无 Status 行异常)、v160/v163/v164/v166/v168/v169(active 指针)、v055-v159 约 53 个带 .session-owner（其中多为历史残留陈旧标记）、task-planner-skill-review(无 task_plan)
- 类③ 辅助 5：cost-analysis-2026-10-05、fix-pointer-race-20261007、incident-reports、INDEX.md、round-retrospective-2026-10-04.md
- v162/v168/v169 判定：三者 Status=complete；v168/v169 有 active 指针+owner→禁；v162 无指针、owner 2026-10-10 10:58（会话已死）→ 陈旧，可归档（git 未跟踪→mv 兜底）

**session-owner 新鲜度语义（主进程直读）**：set-active-plan.sh:240 写 side 键前扫 plans/*/.session-owner 防撞键；owner 文件内容=sess id，无 TTL 机制。v055 owner mtime=2026-09-09（32 天前=历史残留）、v162=2026-10-10（35h 前）。→ 守卫设计：**指针（全局+side）硬拦无例外；owner 仅新鲜（<24h，与 side 指针 TTL 同惯例）才拦；Status≠complete 或无 Status 行一律拦**。按此口径可归档总量≈53+53=106 个（与 001「约 110」估算量级吻合）。

**risks**：
- v146-drift-check-subagent 无 Status 行→fail-closed 跳过（禁把异常当 complete）
- 批量实做后 INDEX 以 dry-run 清单对账；陈旧 owner 目录归档后 owner 文件随目录移入 archive/ 作历史记录，不删

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| new_rule=81 | 编号账本：77/78/79 留 wt/task-v168-machine-parked 封存未 land（task-v168 计划 L71 原话"未 land 于本分支产出"）、80 被 task-v169 预留；attest 查重兜底 |
| 归档形态=git mv plans/<id> → plans/archive/<id>，内部文件不动 | plans/ 任务目录全 git 跟踪（git ls-files 实证）→ 可 revert；沿用 21 目录先例；plan-created.cjs archive 跳过先例复用 |
| 守卫 fail-closed：active 指针（全局+side）/.session-owner/Status≠complete 一律 exit 1；仅「已在 archive」幂等放行 | 误归档在途=数据面事故；v168/v162/v169 在途实证需要保护 |
| [ARCHIVE-GATE]=warn 不阻断 | check-complete.sh 恒 exit 0 语义不破；防复发提醒而非新硬门 |
| INDEX 只列在根任务，archive 任务退出 INDEX | 用户诉求=根目录只留在途；archive/ 目录+git 历史为完整索引 |
| 机制实现进 worktree；存量批量归档在合并回后主仓执行 | 主仓 plans/INDEX.md 有并行会话未提交变更（check-conflicts 信号①），data 面改动避开合并冲突 |
| interaction_mode=silent | 用户指令明确无分叉；v168/v169 同场景先例；D6 硬停点保留 |

## Issues Encountered

| Issue | Resolution |
|-------|------------|
| 001-explore 子代理无写工具，检查点未落盘 | 调查报告随 Agent 返回值完整回收，本文件 §1-§5 即其证据固化（Rule 22.8 精神：结论已入持久层） |
| task-v168 task_plan.md attest 哈希不符（hook [PLAN TAMPERED]） | 已只读核验并确认（见 §7）；非本任务范围、非本会话所为，按 §11.4 不动该文件，列入交付报告请用户处置 |
| drift-check 003 判 DRIFT：本计划 Phase 1 簿记未同步（task_plan.md L179 仍 in_progress/S1 未勾/Next Step 陈旧） | 机械修复当日完成：Phase 1 翻 complete、Current Phase→2、Next Step 更新、Drift Log 登记；教训=进度簿记必须三文件同源翻转 |

## Resources

- 勘查检查点（子代理返回固化）：plans/task-v170-archive-completed-plans/subagent-state/001-explore.md（待 S1 派发时由 explore 重建写入；本文件 §1-§5 已等价固化）
- 归档先例提交：714c93b（plan-hygiene.sh --execute）
- 规格参照：skills/task-planner/scripts/plan-hygiene.sh（既有 plans 卫生脚本）

## Visual/Browser Findings

- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

## §8 S2 实现事实（archive-plan.sh，worktree commit 05ccb12）

- 文件: worktree skills/task-planner/scripts/archive-plan.sh（213 行，Rule 45 双层注释头）
- 契约落地核验（主进程 Read 全文）: 幂等先行（L141 ALREADY_ARCHIVED exit 0）→ 守卫 fail-closed（L92 active 指针全局+side、L102 owner mtime<1440min 才拦、L113-120 全 Status equal 且 total>0）→ 执行（L129 git ls-files 判定→git mv/mv 兜底）
- 与契约定稿的偏差两处（均记为可接受，CR 复核面）: ①缺省 root 改为「脚本位置上溯找 .git（限 4 级）」而非「上溯仓根」表述——等价且更健壮（fuse 慢盘 depth 限）②dry-run 中 candidate 行输出为 `SKIP <id> (candidate/none)`——契约定稿原文即此措辞，保留
- 事故记录（Rule 31 闭环全过程见 progress.md Error Log）: S2 探针误归档主仓 task-v060→当次恢复→主进程独立核验干净；教训=S15 任务书须硬性 dry-run 先行
- 证据锚: 004-code-assistant-s2.md（acceptance 6/6）；worktree git log 05ccb12；主仓 git status 该目录零变更

## §9 执行期环境变化（并行会话观测）

- 2026-10-12 00:05 主仓 git status 新增 `?? plans/task-v171-skill-specialization/`——第四并行会话出现（task-v171），与本任务无交集（不同 scope 文件）；batch 守卫对未 complete 目录天然跳过
- [conflict] hook 对本计划四文件持续误报 v168 冲突：判据=v168 .session-owner 在场+活跃指针，本会话写入全部限于 plans/task-v170*，实际零重叠；按 §11.4 不触碰其他计划目录

## §12 Phase 4/5 执行事实（接线+cascade 两轮+试点）

- worktree 产物=24 commits@618df79..ebdf4f4（033-drift-check 实测，diff --name-only=32 文件全 skills/task-planner/**）：机制件（archive-plan.sh 05ccb12/SKILL 接线 622508a/Rule 81 9363e8d/引用面 29c968a+4122454/ARCHIVE-GATE 77e4c65/selftest 8f8a987/registry de7eb65）+ 级联两轮（g-cascade 7 单元钉值/锚/epoch；g-cascade2 九单元 16 断言扩围含 AD-12 pin 连带 ebdf4f4）
- Round 1 回归 15 FAIL 全部定位为 epoch 族并用 base 快照对照证实系本任务引入（非存量）——证据=020 checkpoint；Round 2 终态 78/78 FAIL=0
- 试点实证（主仓）：task-v055-scheduler-enforce 已归档（commit ce89682，git status rename 实证）；幂等 ALREADY_ARCHIVED；守卫 v170 status-incomplete REJECT
- 移交清单（032 checkpoint）：候选 100；跳过=status-incomplete 8/status-none 1（v146）/active-pointer 5/not-a-plan-dir 9；估算对账=100+3 迁移+1 已归档=104
- 过程教训：①派发 prompt 路径笔误（v070）使 6 个 g-cascade2 单元与 4 个 runner 单元走到「路径裁决」分支（checkpoint 落错目录）——已迁移归位+rm 游离目录；主进程派发前必须自查三文件路径字面 ②epoch 级联存在「pin 字面」暗面（AD-12 精确 pin 被 cascade2 扩围破除）——扩围单元须自查 pinning 族 selftest

| 项 | 值 |
|----|----|
| attestation 锁定值 | plan_sha256=a35c941f6a418999e31256a3f7ae0798132cf49d23f61ba64403f6210ca42038（attested_at=2026-10-11T21:55:55+08:00） |
| 现文件 sha256 | dc600b0b5f25167a15a6c242fe6b1ca829f0bb8ab4c633047b911dfc9eb1dabb |
| mtime 对比 | .plan-attestation=21:55:55.833 < task_plan.md=22:02:47.431（锁定后约 7 分钟被修改） |
| 结论 | task_plan.md 在获批锁定后被修改且未重 attest，hook [PLAN TAMPERED] 判定准确；本会话未写过该文件（本会话写入全部限于 plans/task-v170*），修改者为持有该计划的并行会话（sessf68c3…）收尾簿记时漏重锁 |
| 处置 | 不动该文件（§11.4 并行尊重+非本任务 scope）；列入交付报告请用户/该会话处置：要么按 Rule 51.7 登记 Decisions 后重跑 attest-plan.sh 重锁，要么回滚文件到锁定版本 |
