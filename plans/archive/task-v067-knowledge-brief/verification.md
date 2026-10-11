# Verification Contract & Phase Gates — task-v067-knowledge-brief

## Goal (1 sentence)

在 task-planner 技能中将计划期「必要知识储备」从清单式升级为要点产物式：新增 knowledge-brief（任务知识简略要点）五段产物并全链路接入（模板/init-session/SKILL.md/critical-rules/plan-writer agent/config+selftest），确保执行期小模型只读 brief 即可稳定执行。

---

## Verification Contract（终验复验 2026-09-13）

- [x] VC-1: templates/knowledge-brief.md 存在（五段）且 init-session.sh 端到端建出 6/6 文件
  Evidence: 主进程 /tmp 实测 `[init] 6/6 planning files verified` + 六文件 ls；模板 §1-§5 五段 `grep -c "^## §"`=5；S1 验收 + selftest T1/T3
- [x] VC-2: SKILL.md 强化落地+指针行+净增 ≤10（wc ≤520）
  Evidence: SKILL.md 513 行（510+3）；:509-512 采集/STOP 保留+提炼+引用三层；:316 References 指针行；diff +4/-1
- [x] VC-3: critical-rules.md 21.2/22.4 补 brief 句 + 22.4a 契约未扩展（KQ2 轻量裁定）+ selftest-dispatch 无回归
  Evidence: :115/:127 补句；`git diff -U0 | grep -E "^[+-]22\.4[ac]"`=0；selftest-dispatch 18/18（零波及实证）
- [x] VC-4: plan-writer.md 更新 brief 产出职责 + Phase 5 后 2 部署位对齐
  Evidence: :45 技能/:113 契约表（禁凭记忆编造）/:192 禁止空壳/:4 description，grep 4 命中；Phase 5 部署位 md5/model 行核验（见 Phase 5 补记）
- [x] VC-5: config knowledge_brief_enforce（default warn）+ 新 selftest 全绿 + 全量 0 fail
  Evidence: config :101-110（properties 合规）；selftest-knowledge-brief 16/16；全量 12 套件 196 例 0 fail（基线 180+16 无回归）；smoke 17/0
- [x] VC-6: 跨文件一致（键名/路径五处）
  Evidence: knowledge_brief_enforce 于 config+SKILL 同拼写、变体 0；knowledge-brief 于 9 文件引用一致（SKILL/critical-rules/mapping/guide/模板/dispatch/plan-writer/init-session/check-scope）；template-guide :65 锚计数 20 未变
- [x] VC-7: Code Review APPROVED + 合并回 + 部署对账（skills 3 位+agent 2 位）
  Evidence: Code Reviewer（agent_ed3dfc55）VERDICT=APPROVED（2 条 P3 注释建议登记遗留，KQ3 经其 legacy 计划实测 exit 0 零回归）；merge 与部署见 Phase 5 补记

**终验规则核对**：7/7 VC 通过 → outcome: **COMPLETE**

## Phase Gates

| Phase | Status | 关键证据 |
|-------|--------|---------|
| 1 调研 | complete | checkpoint 01（8 领域锚点+KQ2 波及面+plan-writer 0 命中空档）|
| 2 设计 | complete | findings「Phase 2 设计定稿」KQ1-4+五段骨架+接入链 11 行；计划修订重 attest f230e1fc/35422a39 |
| 3 实现 | complete | S1-S6 全 done（Handoff 02-07 ☑），commit b21eaff，12 文件（10 改 2 新）|
| 4 验证 | complete | 全量 196 例 0 fail + smoke 17/0 + VC-6 一致性 + Code Review APPROVED |
| 5 合并部署 | complete | 见下方 Phase 5 补记 |

### Phase 5 补记
- smart-merge-back.sh --deploy：V1-V6 全 OK → merge commit（见 progress.md Phase 5）→ skills 3 位 IDENTICAL
- plan-writer agent 2 位定向 cp：~/.zcode/agents 原样 cp；~/.claude/agents cp 后 model 行 sed sonnet；md5/grep 核验（未跑 sync-companion）
- worktree 清理 + 主仓 Read 复验（详见 progress.md Phase 5 段）

## 📚 必要知识储备符合性核验
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 本仓技能源码/模板/守卫脚本 | Phase 1 explore 8 领域锚点 + 各 S-unit 先 Read 再改 | 符合 |
| config 新键范式（fmea/skill_collab 块） | S6 镜像 schema + :327 additionalProperties 合规 | 符合 |
| 本任务自身 brief（自产种子样本） | plans/task-v067-knowledge-brief/knowledge-brief.md 由 init-session 建档（主仓）——注：本计划创建于 v066 基线（5 文件时代），brief 未补建属预期，种子样本由 findings Phase 2 定稿节承担 | 符合（口径注记） |

## 委派统计复验（Rule 25.4）
```json
{"phases_total":5,"phases_delegated":2,"delegation_rate":0.4,"verdict":"ok"}
```
- [x] 主进程直做 Phase 均白名单内（Phase 2=② 设计本职；Phase 4=③ 机械验证；Phase 5=①② git/簿记）→ WHITELIST-EXEMPT 放行
- 补充：实际子代理派发 9 次（plan-writer/explore/executor×6/Code Reviewer），全程串行 Rule 21.4；S4 返回消息截断 1 次（rescue 列已登记，产出以主进程复验为准）

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 0 项（S4 返回缺失已按 22.8.5 处置并登记 Handoff rescue 列）；豁免 0；未处置 0
- [x] Evidence 抽查 ≥3：① init 6/6 主进程 /tmp 实测 ② 22.4a/c diff=0 主进程 grep ③ 全量 selftest 主进程亲跑 196 例
- [x] Rule 19.7 升级警告 1 次（progress 回填迟）已按 26.3 登记 progress.md Error Log 并当场处置
- [x] 未处置违规：无 → outcome 不降级

## 遗留项（非阻断）
| # | 内容 | 建议 |
|---|------|------|
| D-1 | knowledge_brief_enforce 三档流程层执行，无 hook 机械校验（enforce 语义预留） | 后续轮接 attest/check-plan-dispatch 校验 |
| D-2 | CR P3×2：check-3file-gate.sh:42 注释措辞易误读（建议注明「仅文案 5→6」）；selftest T5b 对循环重构形态存在假阴可能（:48-50 注释已覆盖） | 后续清理轮 |
| D-3 | init-session.ps1（PowerShell 旧链路）仍 4 文件 | 后续对齐或下线 |
| D-4 | 本计划创建于 5 文件时代，plans/task-v067-knowledge-brief/knowledge-brief.md 未补建（种子样本由 findings Phase 2 节承担） | 可选补建 |

## Goal Verification（Goal Gate）
- [x] VC-1 → PASS　[x] VC-2 → PASS　[x] VC-3 → PASS　[x] VC-4 → PASS　[x] VC-5 → PASS　[x] VC-6 → PASS　[x] VC-7 → PASS

 outcome: **COMPLETE**

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终验交付 |
| 2 | Where am I going? | 交付报告 + task-v068 候选立项 |
| 3 | What's the goal? | 见顶部 Goal |
| 4 | What have I learned? | findings.md（KQ1-4/接入链/plan-writer 空档） |
| 5 | What have I done? | progress.md（5 Phase 全程） |
| 6 | Which tasks need processing? | task-v068（执行稳定性增强）候选 |
