# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 54「执行诚实性与即时执行纪律」（54.0-54.6 七子条+selftest 守护+SKILL/模板/companion 联动），因果链全链分析驱动（F1-F5 全覆盖），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Rule 54 条款完整（54.0-54.6 七子条+54.0 总则+54.1 资源状态子句+54.5 落盘子句；措辞任务类型无关）
  Evidence: 主仓 `skills/task-planner/references/critical-rules.md:595-610`（grep -cE "^54\.[0-6]"=7）；案例词扫描=0（S1 验收+CR 独立扫描双确认）；条款号引用 19/19 真实（align 审查逐条 grep）
- [x] VC-2: SKILL.md 联动（摘要行/C38/索引/References+净增 ≤10+行数纪律）
  Evidence: `SKILL.md:206 C38 / :268 Rule 40-54 / :309 摘要 / :333 References / :9 全集 1-54`；wc -l 478→480（净+2）；CR 复核 PASS
- [x] VC-3: 消费侧联动（delivery-summary +1/双 companion 指针各+1/notepad 案例登记）
  Evidence: `templates/delivery-summary.md:34`；`companion/agents/image-generation-executor.md:37`；`companion/agents/video-generation-executor.md:38`；`plans/task-v136/notepad-learnings.md`（31.4 四段沉淀+Notes for Next Time 五条）；grep "Rule 54" 各=1
- [x] VC-4: selftest-execution-honesty.sh 守护+全量回归 0 FAIL（主进程独立求和）
  Evidence: 新脚本 14 断言 FAIL=0+破坏测试双向可触发；全量 52 脚本 **798/0**（基线 784+14；主进程 raw 重算与两次子代理实跑三方一致；master 合流后复跑仍 798/0）；progress.md Selftest Log
- [x] VC-5: 合并回+部署 3 位+编号 land+worktree 清理
  Evidence: master merge commit **b2d38e5**；3 位 IDENTICAL（~/.zcode / ~/.claude / opencode，smart-merge-back --deploy 输出+md5sum 抽验）；`plans/.rule-reservations.jsonl` rule 54 landed；worktree 已 remove+branch -d
- [x] VC-6: 因果链证据表+54 条款可回溯
  Evidence: `plans/task-v136/findings.md`「因果链证据表（VC-6 载体）」段——5 节点+5 箭头全双锚（T#+file:line），A1 诚实降级 partially-verified（使能边）；无锚声称=0（03 检查点 §五自查声明）

**终验规则结果**: 全部 VC 通过 → COMPLETE

---

## Phase Gates

### Phase 1: 隔离与基线
**Done when**: worktree 在册+基线定数+插入锚确认
Status: `complete`（2026-10-05；基线 784/0 主进程 raw 重算定数；worktree 已于 Phase 6 清理）

### Phase 2: EP8 因果链全链分析
**Done when**: 逐节点双锚验证+证据表落 findings
Status: `complete`（4/5 箭头 verified+A1 使能边；锚漂移+2 发现并复核）

### Phase 3: 条款+消费侧联动写入
**Done when**: S1/S2/S3 写入+主进程亲验
Status: `complete`（条款+17/联动 7 处/锚级联 4 脚本）

### Phase 4: selftest 守护
**Done when**: 新 selftest PASS+破坏测试可触发
Status: `complete`（EH-01..14；破坏测试 2 例）

### Phase 5: 全量回归+修复
**Done when**: 全量 0 FAIL 且 ≥基线
Status: `complete`（798/0；skill-split 行数钉修复；registry 登记）

### Phase 6: 审查 Gate+合并回+部署+簿记
**Done when**: 双 Gate 通过+合并部署+簿记
Status: `complete`（align CHANGES_REQUESTED→P1 全修；CR APPROVED→建议全采纳；合流零冲突；b2d38e5；3 位 IDENTICAL）

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| Rule 49-53 块范式 | 54 块格式与 53.5/49.5 末条机制镜像（CR 复核） | 符合 |
| selftest-veto.sh 范式 | EH 脚本 $SKILL 定位/Total/exit 逐字同构（CR 抽验） | 符合 |
| v133 交付模式 | 条款+C 行+selftest 断言套路复刻 | 符合 |
| 任务档案（findings+01/03 检查点） | S1 条款映射直接消费 03 检查点 §四 | 符合 |
| EP8 实录档案 | 因果链每节点 T# 锚引用，引句逐字一致（S0 校验） | 符合 |

## 委派统计复验（Rule 25.4）

- 子代理执行 Phase 数 / 总 Phase 数: **6 / 6**（P1 基线跑批=general-purpose（mini provider 2 连拒改派）；P2=S0 executor；P3=S1/S2/S3 executor×3；P4=S4 executor；P5=S5 executor；P6=align+CR+修复×2 子代理）
- 主进程直做清单（白名单内）: git/worktree 编排+合并部署（白名单①）；计划系统文件三件套/INDEX/ledger/notepad（白名单②）；机械验证命令与独立重算（白名单③）；attest/rule-reserve/INDEX 簿记（白名单②）
- 委派率: **1.0**（≥0.7，无白名单外直做）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查: 触发 0 项豁免 0 项；Q3 伪造面=0（基线汇总 762→784 修正即 43.1/54.0 纪律的实例执行，非违规——发现即修、如实登记）
- [x] Evidence 抽查 ≥3 条: ①critical-rules.md:595-610（主仓 Read）②3 位部署 md5sum IDENTICAL ③52 脚本独立求和 798/0（三方一致）
- [x] 豁免登记: 无
- [x] 未处置违规: 无

## Goal Gate (终验)

```
## Goal Verification — Rule 54 落地+因果链驱动+合并部署
- [x] VC-1: 主仓 7 锚+措辞合规 → PASS
- [x] VC-2: SKILL 5 联动锚+净增+2 → PASS
- [x] VC-3: 3 文件指针+notepad 沉淀 → PASS
- [x] VC-4: 14 断言+52 脚本 798/0 → PASS
- [x] VC-5: b2d38e5+3 位 IDENTICAL+land+清理 → PASS
- [x] VC-6: 证据表全双锚+无锚声称=0 → PASS

 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终验 COMPLETE（2026-10-05） |
| 2 | Where am I going? | 交付总结呈报；deferred 1 项（registry 存量行号锚迁移）入后续清理 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | findings.md + notepad-learnings.md |
| 5 | What have I done? | progress.md 六 Phase 段 |
| 6 | Which tasks need processing? | plans/INDEX.md（v136 已 complete） |
