# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner 修复长会话漂移/技能闲置/错误迟纠三类缺陷的**技能逻辑与既有设置**：五个行为锚点植入 SKILL.md 执行循环（R 原话复诵/动作相关性三问/技能激活确认/错误同轮四步/周期三文件对照），Rule 31.1⑤/33.1④ 触发条件扩展，error_loop_enforce/reflect_verify_enforce 翻 enforce——零新 hook、零新脚本、零新 config 键。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: R 锚定复诵步骤在位（SKILL.md 执行循环步骤 1 含「Read 用户需求原文区→progress 段首行复诵本 Phase 服务的 R 条目」强制动作）
  Evidence: `skills/task-planner/SKILL.md:87`（grep "R 锚定复诵"=1，含 [task-v168 2026-10-11 逻辑层锚点] 注释+Why）
- [x] VC-2: 四行为锚点在位（动作相关性三问 2.5c / 技能激活确认 2.5b / 错误同轮四步 3c / 周期性三文件对照 3f）
  Evidence: `SKILL.md:92`(2.5c)/`:93`(2.5b)/`:99`(3c 四步，原句逐字保留)/`:102`(3f)；CR MINOR 修复后三问已从 bullet 升为编号子步
- [x] VC-3: 规则触发条件扩展在位（31.1 含⑤/33.1 含④且原条件语义未改；⑤ 经 CR MAJOR-1 收窄为「预期成功的动作实际失败」+良性非零豁免+22.3 交叉引用）
  Evidence: `critical-rules.md:322`（⑤ 含收窄措辞+两条 Rule 45 注记）/`:345`（④+注记）；原①-④/①-③ grep 逐字在位；`templates/progress.md:49-52` Error Log 含「触发命令/工具」列
- [x] VC-4: 设置层翻档在位（config.json error_loop_enforce + reflect_verify_enforce default=enforce，键总数 314 不变，jq empty 通过）
  Evidence: `config.json:286,302`（git diff 仅 2 行 warn→enforce+description「默认」标注移位）；selftest-error-loop 16/16、selftest-reflect-verify 12/12（钉随演进）
- [x] VC-5: 全量回归 FAIL=0——master 组合态（含并行会话 v166 Rule 76 成果）77 脚本全 PASS
  Evidence: `run-selftests.sh --fresh` → `Total: 77 PASS=77 FAIL=0`（exec log: call_5d6a57ad81c14942a77d5b7b-stdout.log）；期间抓出并修复 v166×v168 行数钉触顶（555→581/558→584）
- [x] VC-6: 红线零越界——零新 hook/零新脚本/零新 config 新键；zcode-pretooluse.sh/Learning Gate 表头识别/REFLECT-GATE 既有逻辑未被改语义（唯一触碰 check-complete.sh=lg_bad_awk 双列修 off-by-one+模板行豁免，属 CR BLOCKER 连带必修）
  Evidence: `git diff 39c41fa..master --stat` = 9 文件全在 scope_files；CR 审查记录 `subagent-state/21-cr-code-review.md`（VC-6 判 PASS）+修复记录 `22-cr-fixes.md`

**终验规则裁定**：6/6 VC 通过 → outcome: **COMPLETE**（已知遗留=机器面封存事项，见 delivery-summary「风险与遗留」）

---

## Phase Gates

### Phase 1: 需求与调研
Status: `complete` — 三报告（01 漂移机制/02 技能激活/03 执行错误）落盘 subagent-state/；findings.md 全回填；plan attest 锁定（SHA 2a9656a1…）
### Phase 2: 逻辑层五锚点
Status: `complete` — SKILL.md +5/-1；31.1⑤/33.1④ +2/-2；progress.md 模板增列 +6/-4；commit 8d5f4be
### Phase 3: 设置层翻档
Status: `complete` — config.json +3/-3；jq empty 通过；commit 5f1c371
### Phase 4: CR 修复与回归
Status: `complete` — CR CHANGES-REQUESTED→F1-F5 全闭环（13adf75）；wt 回归 76/76；master 组合态 77/77（含钉演进 9fce0ff）
### Phase 5: 合并回主仓
Status: `complete` — merge cdf437e+618df79；v166 成果并存实证（Rule 76/C55 在位）；封存分支 wt/task-v168-machine-parked 保留
### Phase 6: 终验交付
Status: `complete` — 本文件+裁决表+delivery-summary

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| 三调研报告（subagent-state/01-03） | 五锚点/31.1⑤/33.1④/翻档逐条可回溯至报告缺口编号（P0-1/P0-2/P0-3/§7） | 符合 |
| critical-rules.md Rule 15/20/31/33/59/64/65/67/75 原文 | 31.1⑤/33.1④ 纯增量不碰原条件；59.3 红线（禁自动代激活）在 2.5b 措辞保留 | 符合 |
| hook 四脚本+check-complete 全文 | check-complete.sh 仅 lg_bad_awk 修复（CR 连带）；表头列识别 rc_col 逻辑未动 | 符合 |

## 委派统计复验（Rule 25.4）

```bash
# 证据（主进程机械统计，Handoff 表 22 行）
子代理执行 Phase 数 / 总 Phase 数 = 5 / 6（Phase 1-4 全子代理执行；Phase 5/6 主进程例外①git 编排②簿记）
派发明细：Explore×3（调研）+ code-assistant×14（S1/S2/翻档/微修/S1/CR 修复/F1-F5/行数钉）+ Code Reviewer×1（独立 CR）
委派率 = 5/6 ≈ 0.83（≥ delegation_rate_floor 0.7）
```

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（幻觉/长程漂移）、R2（确定性+拦截）、R3（周期检查）、R4（错误及时纠正）、R5（技能主动激活） |
| **裁决** | `partial` |
| **解决证据锚** | R1/R3=SKILL.md:87 1.1 R 锚定复诵+:102 3f 周期三文件对照；R2=:92 2.5c 三问；R4=critical-rules.md:322 ⑤+:99 3c 四步+config enforce；R5=:93 2.5b 技能激活确认 |
| **未解决面+原因** | ①用户 piv⊥ 后机器面（锚点卡自动回注/技能扫描/错误信号检测）整体封存未落地，行为锚点依赖模型执行纪律，历史实证纯 LLM 面有失效风险（01-explore §2：v141-v145 drift-check 执行率 0%）；②设置层 enforce 翻档使 Learning/REFLECT 门首次具备阻断力，但其对"未声明 reflect_verify 的计划"仍不生效（门触发条件未改=守存量语义）；③部署未做（§六 需用户授权），当前改动仅在仓库态 |
| **已排除路径** | 机器面代码路线=用户 2026-10-11 明令否决（「一直在改莫名其妙的各种代码问题…完全不是在解决问题」），封存分支保留备 revival |
| **下一步建议** | 1. 用户授权后部署到 ~/.zcode/skills/task-planner（rm+cp 或安装脚本，先对账 diff=0）使行为锚点+enforce 生效；2. 观察 1-2 个真实任务中五锚点的执行率（progress.md 的「R 锚定」行/3f 对照行出现率=行为面实证）；3. 若行为面仍失效再评估封存分支的机器面 revival（届时 hook 回归已有 12 失败模式的前车修法：emit 组装勿嵌套在 re-anchor if 内） |
