# Delivery Summary — task-v156-drift-shield（Rule 73 执行期决策对齐与不变量纪律）

## 1. 任务说明

用户 2026-10-10 三连发反馈（R1-R6，全部 [目标] 型）承载任务：把「长会话执行严重漂移」（调研 6 分钟假完成/视频剪纸风被改 3D 风/参考母图逻辑违背）的制度化修复落地为 task-planner 技能 Rule 73 全链——决策点分类→对齐三问→三态标注→强制评判→废弃隔离→消歧义六位一体。worktree 隔离开发（wt/v156-decision-alignment,base a538a3a）,7 个 skill 文件+1 新模板+1 新 selftest,合并回 master（merge commit 18ec78e,含与 v160(Rule 72)/v162(Rule 74) 的并集解）并 --deploy 四部署位 IDENTICAL。

## 2. 产出清单

| 产出 | 路径（绝对） | 状态 |
|------|------------|------|
| Rule 73 七子条 | `skills/task-planner/references/critical-rules.md`（:951 起 ### 73 块,73.1-73.7;+45 行含并集解） | 已合并部署 |
| SKILL 六级联 | `skills/task-planner/SKILL.md`（计数 1-74 族/Rule 73+74 bullet/C51-C53 合规行/两处决策点引用/References） | 已合并部署 |
| 新模板 deprecated.md | `skills/task-planner/templates/deprecated.md`（五段废弃隔离区,Rule 73.5 载体） | 已合并部署 |
| 🔒 不变量声明区 | `skills/task-planner/templates/task_plan.md`（三态标注区块;本计划 dogfood 实例同步） | 已合并部署 |
| 双承载 | `skills/task-planner/scripts/check-complete.sh`（[judge-gate] plan_tier 门控三档）+`scripts/zcode-posttooluse.sh`（[judge] 节奏注入,env 降档） | 已合并部署 |
| 新 selftest | `skills/task-planner/scripts/selftest-decision-drift.sh`（DD-01~23,23/23 PASS）+`selftest-registry.tsv` 登记行 | 已合并部署 |
| 级联修复 | 5 个存量 selftest 锚宽容化（K9:覆盖 1-74/+NN 双形态,负断言全保留） | 已合并部署 |
| 计划簿记 | `plans/task-v156-drift-shield/**`（task_plan/findings/progress/verification/design-draft/subagent-state 18 检查点/3 轮回归日志） | 待提交入库 |

## 3. 审查信息

- **Code Review Gate**:首轮 CHANGES_REQUESTED（MAJOR×1=judge-gate 缺 plan_tier 门控/MINOR×1=DD-14 断言弱/Nit×1=分隔符）→ S10 fix-phase → 复检 **APPROVED**（三发现全 CLOSED,0 MAJOR/0 BLOCKER/0 新发现;harness 3 档×3 env 实证）。检查点:`plans/task-v156-drift-shield/subagent-state/12-code-reviewer-S8.md`、`14-code-reviewer-recheck.md`。
- **alignment-review 收尾**:PASS/APPROVED（0 BLOCKER;MINOR×4 已修:M1 registry 描述/M2 区块序/M3 消息文案/M4 ΣPASS 双记 1061/1062 口径附注）。检查点:`subagent-state/15-alignment-review.md`。
- **回归**:R1 全量 ΣFAIL=5（级联漏改实证,FMEA RPN=210 行兑现）→ S9 修复 → R2 主进程独立复跑 72/72 rc=0 ΣFAIL=0 → merge 并集解后 R3 75/75 rc=0。日志:`regression-{v156,r2-v156,r3-v156}.log`。
- **委派统计**:`check-delegation.sh stats` → verdict=ok,3/6 Phase 委派,3 个主进程直做 Phase 全命中 Rule 25.3 白名单（WHITELIST-EXEMPT）;Handoff 登记表 15 行。
- **drift 检查**:五轮回全 ALIGNED（61.5 兜底轨;drift-checker provider 拒启×3 债务在册,GOAL 12/12）。

## 4. 风险点（必须列举）

- **运行期行为效果未实战**:Rule 73 的语义面（73.1 决策点识别/73.2 三问执行）不可静态机检（73.7 已如实披露）——机制存在性全证,真实会话漂移率下降待新会话实战冒烟。
- **drift-checker provider 拒启债务**:本会话 3 次 provider 拒启（同 task-v157 判例）,后续 Phase 走 61.5 兜底轨;需新会话/部署位补派验证。
- **并行合流 ongoing**:master 在本任务执行期从 a538a3a 前进至 d45e8e2（v160/v162 落地）,并集解已处理 7 文件;后续 v163/v164 合流时,SKILL 计数与 C 编号可能再需并集（宽锚已预留容错）。
- **账本补正登记**:rule-reserve 73 的 attest 期登记漏落,Phase 6 补正（reserve+land 两步行,ledger 有痕）。

## 5. 下一步建议

- **新会话实战冒烟**（对象:`skills/task-planner/references/critical-rules.md` Rule 73 段;看点=六机制行为面;动作=在下一真实任务中执行并核对 [align]/[judge] 留痕+[judge-gate] warn/hook 注入/deprecated 登记/消歧义消费是否按设计发生）。
- **drift-checker 补验**（对象:本计划 subagent-state/;看点=61.5 债务;动作=provider 恢复后对本计划跑 Phase 1-6 漂移复检）。
- **INDEX/账本入库提交**（对象:`plans/task-v156-drift-shield/`+`plans/INDEX.md`+`plans/.rule-reservations.jsonl`;看点=Rule 27.3 终验门;动作=`git add` scope 产物后 `docs(plans)` 提交）。
- **部署位 spot check**（对象:`~/.zcode/skills/task-planner` 等四部署位;看点=--deploy 已对账 IDENTICAL;动作=新会话中确认 hook 生效,[judge] 注入实弹）。

---
数据源:`plans/task-v156-drift-shield/verification.md`（VC/58.5/Goal Gate）、`progress.md`（全 Phase+Error Log）、`findings.md`（调研与子代理结论）、`subagent-state/01-18`（检查点全集）、`ledger-main.jsonl`（13 tick）。
