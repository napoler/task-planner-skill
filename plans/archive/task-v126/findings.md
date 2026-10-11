# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## Technical Decisions
- **Rule 49 净增行预算**：bullet +1 + C34 +1，其余 3 处行内改写净增 0 → 总净增 2 行（上限 10）；T2b ≤558 余量充足
- **推进检查点落位**：SKILL:85 执行循环步骤 2.5 行尾行内括注（消费点=验收后决策，派发逻辑内聚；对比新开 2.7 步骤省 2-3 行且避免步骤枚举断言级联）

## Resources（Phase 1 锚位与基线）
- 基线：worktree master@0f077ae，44 selftest = 666 PASS / 0 FAIL
- 复盘报告：plans/round-retrospective-2026-10-04.md（F1 撞号/F2 串行槽锁/F4 派发摩擦）
- 锚位：SKILL:9,85,199,282,306；critical-rules.md:504（文末追加）；SR-07 主锚 `Rules 1-39`=2 不动

#### [sub:1-executor] S1 Rule 49 条款块落地（回执）
- 产出：critical-rules.md:506-520 纯追加 16 行（### 49 标题+引言+缺口段+49.1-49.5）
- 主进程三证据复核：Read :506-520 内容完整 ✓；grep -c '^49\.[1-5]'=5 ✓；git diff 纯追加 16 insertions/0 deletions ✓
- 关键语义抽查：「推进三条件」「跨 Phase 前移合法」「Phase complete 翻转语义不变」「汇合点强串行」「零新 config 键」五锚全在位

#### [sub:2-executor] S2 SKILL.md 四锚五处联动（回执）
- 产出：SKILL.md 447→449 行（净增+2）；五处=甲 :9 全集 1-49+追加 49 短语 / 乙 :85 步骤 2.5 行尾推进检查括注 / 丙 :200 C34 行 / 丁 :284 Rule 49 bullet / 戊 :306-308 References 括号追加
- 主进程三证据复核：五处 Read/grep 抽查全在位 ✓；grep 'Rule 49'=4+References1；grep -c 'Rules 1-39'=2 且 '1-40'=0 ✓；wc -l=449 ✓

#### [sub:3-executor] S3 selftest 守护落地（回执）
- 产出：scripts/selftest-lane-advancement.sh（LA-01..LA-14，14 断言全 PASS）+ selftest-registry.tsv 45→46 行登记
- 主进程三证据复核：亲跑 Total 14 PASS=14 FAIL=0 exit 0 ✓；registry wc=46 ✓；git status 仅两文件 ✓；S3 自跑 selftest-registry.sh 5/5（rows=45 actual=45 双向核对）✓
- 断言设计亮点：LA-12/13 主锚守护与 SR-07 同口径（Rules 1-39=2 / 1-40=0）；LA-14 jq 键数=40 零新键口径与 43.4/44.4/47.4 一致

#### [CR] Code Review Gate（code-quality-review，2026-10-04）
- 结论：**APPROVED**（P0=0 P1=0 P2=0）
- 审查对象：scripts/selftest-lane-advancement.sh（新建 146 行）+ selftest-skill-split.sh（1 行锚演进）
- 证据：单跑 `Total: 14 PASS=14 FAIL=0` exit 0（可复现：cd worktree scripts 后 bash selftest-lane-advancement.sh）；全量 45 脚本 702 PASS/0 FAIL（修复后）；skill-split 41/41
- 维度要点：LA-05 grep -qF 防方括号正则陷阱 ✓；LA-14 jq 缺失 SKIPPED fail-open 非静默（MD-08/R-12 先例同构）✓；What/Why 双层注释 14 断言全覆盖（Rule 45）✓；纯只读零副作用 ✓；与 selftest-media-dispatch.sh 逐段同构（ok/bad/Total/exit 语义）✓

#### [sub:4-code-runner-agent→executor] S4 全量回归（回执）
- 初跑：45 脚本 701/1（FAIL=skill-split T-主 行数锚 ≤447 被 SKILL 449 推爆——预期内增行级联，非缺陷）
- 修复（主进程白名单⑥单行）：skill-split:41 锚 447→449（演进链 440→442→444→447→449），commit 6f0a9de
- 复跑：**45 脚本 702 PASS / 0 FAIL**（final-gate-hash 22 条口径已含：基线真实 688=666+22 漏计，688+14 新增=702 自洽）
- 改派记录：code-runner-agent(mini) provider 拒绝 → executor(sonnet-1) 承接（22.3①，v122 先例同款）

#### [align] alignment-review 收尾（Rule 42.6.2）
- 结论：**APPROVED**（P0/P1=0）
- 证据：447/448/449 锚全扫零残留（除已修 skill-split:41）；术语「单元线」critical-rules 5 处=SKILL 5 处；编号事实=「全集 1-49」+ ^49 锚 6 行（1 标题+5 子条）；registry 46 行双向核对（selftest-registry.sh 5/5 rows=45=actual）
- 变更记录三要素：范围=critical-rules.md:506-520+SKILL 五处+新 selftest+registry+skill-split:41；冲突处理=skill-split 行数锚 447→449（裁决依据=净增 2 行系 Rule 49 联动预期产物）+pg-p2 撤销（F2），未决残留=无；文档状态=残留冲突 0

## 删除基线声明（Rule 36.3，C24）
- 删除性行为清单=**无**（本任务纯增量）：critical-rules.md 纯追加 16 行（Rule 49 块）；SKILL.md 行内改写 3 处+净增 2 行（bullet/C34）；selftest-lane-advancement.sh 新建；registry +1 行；skill-split 单行锚值演进（447→449，非删除）。零功能性删除、零语义改写（Rule 36.5）。
