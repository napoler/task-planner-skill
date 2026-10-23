# Delivery Summary — task-subagent-boost-20261023（Rule 96 子代理激活默认与并行推进强化）

> 收口：2026-10-24，簿记收口员（S10，工作流子代理）。执行载体=dynamic-workflow（用户点名 /workflow）。

## 一、做了什么

按用户两点诉求落地 Rule 96（编号 96 经 attest 台账预留、95 被并行任务占用未碰），增量立法零改写 21.4/22/46/52 既有语义，全链生效：

- **R1 激活率** → **96.1 激活默认档矩阵**（A1 制定计划~A7 创作七类可判定触发，默认派发子代理；主进程收窄为例外白名单、须登记一句话理由）+ **96.2 模型分档**（计划期正向三档：轻 haiku-1 / 中 sonnet-1 / 重 GLM5.3·Opus 级既有通道）
- **R2 并行率** → **96.3 计划期并行硬标注**（≥2 无依赖必须声明并行组，未声明且未论证=计划缺陷）+ **96.4 执行期同消息并发派发** + **96.5 指标留痕**（激活子代理数/最大并行宽度）+ **96.6 管辖边界**（执行强化层，冲突以被引条款为准）
- 承载面全同步：核心枚举 `,96`、SKILL.md 纪元 1-94→1-96、两模板锚定行、新 selftest 机器门、zcode/cursor 部署位

**核心目标裁决**：R1/R2 = **solved**（证据见 task_plan.md「核心目标达成裁决」表）；终验 outcome 按 Rule 26.3 程序帽=最高 PARTIAL（回填滞后违规已登记并在本收口闭合）——目标达成与程序合规两轴分记。

## 二、产出清单（绝对路径）

| 产出 | 路径 |
|------|------|
| Rule 96 正文（:186-214） | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md |
| 核心枚举扩员（:193） | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md |
| 级联+编排指针（:9/:16/:195/:209/:245/:252） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md |
| 模板承载（:327/:495-497；:34） | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md、…/templates/subagent_dispatch.md |
| 机器门 SA-01..15（新增） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-subagent-activation.sh |
| registry/runner 随动 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv、…/run-selftests.sh |
| 草案+检查点链（9 份） | /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/draft-rule96.md、subagent-state/{1,2,3,4,5,6,8a,8b,9}-*.md |
| 簿记三文件+本摘要 | /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/{task_plan,findings,progress}.md、delivery-summary.md |
| 部署位（8 文件×2 位） | /home/terry/.zcode/skills/** 与 /home/terry/.cursor/skills/**（16/16 diff=0） |
| 合并提交 | master **cecacfb**（merge --no-ff，双亲 6d60e02+e319ee3，零冲突；worktree 提交 e319ee3=8 files +135/-10） |

## 三、审查详情

- **CR 双视角（VC-5）**：8a alignment-review 视角 **VERDICT: APPROVED**（subagent-state/8a-cr-alignment.md:8，nit 4 条不阻断）+ 8b critic 视角 **VERDICT: APPROVED**（subagent-state/8b-cr-critic.md:41，问题清单 6 条均非 BLOCKER）。增量立法核验=21.4(:25-32)/22(:48-79)/46(:112-130)/52(:133-143) 权威区间零 hunk（8a §一.1 git diff 实证）。
- **回归（VC-4）**：回归门=绿（工作流 gate 记录）。plan 目录归档证据=检查点 6（编辑 1 补落后涉 dispatch.md 的 15 个既有 selftest 重跑全绿）+检查点 8b（24 脚本串行实跑全 rc=0）；**如实登记**：93 脚本全量 runner 输出未归档 plan 目录（7-regression.md 不存在），本收口会话亲跑新 selftest 于合并后 master 复证 `Total: 15 PASS=15 FAIL=0, EXIT=0`（断言数=15 与 ask 一致）。
- **部署（VC-6）**：16/16 diff=0（zcode+cursor × 8 文件）；锚复核两侧一致（dispatch.md 96.1 均 :192、core critical-rules.md `,96` 各 1 命中、`^96\.[1-6] ` 计数=6）；`.drift-rhythm/` 零触碰。
- **委派统计（96.5 留痕）**：子代理执行 Phase 5/5=100%，主进程仅编排簿记（白名单②）；激活子代理数=10（检查点证实），最大并行宽度=3（并行组①调研），并行组共 3 组。

## 四、风险与遗留

1. **部署误伤（待用户授权处置）**：首次 cp 未剥离 `skills/` 前缀，误写入两部署位历史遗留镜像树 `~/.zcode/skills/skills/`、`~/.cursor/skills/skills/`（非加载路径、运行影响=零）：7 个同名既有文件被覆盖（原内容无备份不可精确还原）、1 个误新建已 rm——正确位不受影响；待用户裁决「正确位回写还原」或「整树清理」（subagent-state/9-merge-deploy.md §4/§5）。
2. **README/docs 级联欠账**：skills/task-planner/README.md:36/:68/:81/:123 与 docs/ARCHITECTURE.md 六处仍 1-94 旧纪元（无 selftest 因此红；8b 问题④）——随下次部署 lane 同步。
3. **全量回归输出未归档**：93 脚本 runner 输出仅存在于工作流运行记录，plan 目录无 7-regression.md（VC-4 采信 gate 记录+两处抽样证据）。
4. **措辞歧义（nit 级）**：96.3 对恰 2 个 S-unit 串行计划的例外通道与 68.2 门槛失配（8b 问题②，96.6 可自愈）；96.5 两指标无 delivery-summary 模板槽（8b 问题③，本摘要已按 96.5 口径报告）；run-selftests.sh:11/:79 注释钉 77/73 延续基线失真（实测 93 个）。
5. **收尾动作未做**：worktree/分支未清理（§十一.3.5）、未 push（全程未获授权）、归档（check-complete+archive-plan）待主进程。
6. **既有债（非本变更）**：selftest-dispatch.sh:238 共享 /tmp 固定路径计数文件，并行跑同 suite 必互踩（本次实证假阳性），建议 mktemp 隔离。

## 五、下一步建议

1. **用户裁决**：镜像树处置（第 1 条）——授权回写还原或清理 `~/.zcode/skills/skills/`、`~/.cursor/skills/skills/`。
2. **主进程收尾**：check-complete exit 0 → set-active-plan --clear → archive-plan → `git worktree remove /mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023` + `git branch -d wt/task-subagent-boost-20261023`；push 待授权。
3. **级联补账**：下次部署 lane 一并同步 README/docs 六处纪元字面 + run-selftests.sh 注释钉校真 93/88（一行 sed）。
4. **实效观察**：新会话按 96.5 指标（激活子代理数/最大并行宽度）观察激活率与并行宽度实效，若仍偏低再评估加码（96.1 类别扩员或例外白名单收窄）。
5. **小修可选**：96.3 例外句一行扩句消歧（S-unit 总数 <3 时按 68.2 同款三轴格式登记）。

## 六、本收口会话亲验记录（证据=本会话实跑）

- `bash skills/task-planner/scripts/selftest-subagent-activation.sh` → 15 PASS=15 FAIL=0, EXIT=0
- `git log --oneline -4` → 顶部 cecacfb merge commit；`git worktree list` → 本任务 worktree 仍在位（未清理，如实登记）
- `grep -n '96\.1' …/critical-rules-dispatch.md` → :192；`grep -n ',96' …/critical-rules.md` → :193；`grep -c '^96\.[1-6] '` → 6
- `bash ~/.zcode/skills/task-planner/scripts/attest-plan.sh` → 结果见 progress.md「attest 重锁记录」
