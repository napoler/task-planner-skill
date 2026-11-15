# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 引入交叉验证方法论识别执行错误（[目标]）/ R2 隔离上下文+多角度保产出稳定（[手段]）/ R3 更快识别产出错误缺陷（[手段]）/ R4 不信模型自我虚构，伪造须及时识别（[目标]）/ R5 固化到技能与步骤（[手段]）——逐字原文见 user-session-log.md #1，映射见 task_plan.md R→VC 表

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### F1 落点文件结构（Explore 侦察 2026-11-15）
- critical-rules-verification.md 共 58 行；条款形态=`### 84 <标题>`(:11) 块+正文行首编号子条（84.1:15/84.2:17/84.3:19/84.4:27/84.5:35/84.6:46/84.7:48/84.14:58=EOF，无 ####）；**Rule 108 追加锚=EOF(:58 后)新 `### 108 <标题>` 块**，前锚 :58 原文不改
- verification-gate/SKILL.md 94 行：description :4（触发面）/调用时机 :24-31/执行步骤 :33（Step1:35/2:49/3a:57/3b:63）/脚本索引 :74/References :87
- 影响：108 追加 EOF+SKILL 三处补触发与指针，零破坏既有 84.x 锚

### F2 selftest 注册与运行机制
- registry.tsv 4 列=script/domain/trigger_scenarios/dep_anchors（:1 表头；样本 :2/:3）；98 行
- run-selftests.sh **glob 遍历 selftest-*.sh 自动发现**（:55/:113/:118），非读 registry；新增 selftest 无需改 run-selftests.sh，**但必须登记 registry.tsv 否则 selftest-registry.sh 一致性检查失败**（:34 该脚本自身亦登记）

### F3 「1-107」纪元级联族（全枚举，排除 .backup）
- SKILL.md :9/:224/:267 三处 '1-107' 字面
- selftest-enumerate-first.sh EN-06（:9/:92/:93/:95/:97）：断言 SKILL.md 含 '1-107'≥3 且 discipline 路由行含 ',107'
- 结论：纪元演进 1-107→1-108 需改 SKILL.md 三处+EN-06 五处字面（阈值 -ge 3 不变）；**',107' 断言不受影响**（Rule 108 归 verification-gate 不属 task-discipline，SKILL.md:210 的 ",105,106,107" 不动）；另 SKILL.md:220 verification-gate 路由行当前仅 "Rule 84" 需加 108

### F4 触发面档位现状
- 51.14 L1-L4 条款实际在 **skills/task-planner/references/critical-rules.md:107**（task-discipline 无 51.14 命中），消费点 SKILL.md:230+execution-recall-card.md:7
- Rule 103 双轮质检在 critical-rules-dispatch.md:225（103.1 :229/103.2 :231）
- Rule 84 子条：84.1:15/84.2:17/84.3:19/84.4:27/84.5:35/84.6:46/84.7:48/84.14:58
- 防撞车：verification-gate 域内 '交叉' 仅 templates/verification.md:97「Handoff 交叉校验」既有用语，Rule 108 需避开歧义措辞
- 影响：108.1 触发面对齐 51.14 档位口径（core :107），与 84.4/84.7/103 构成互补框架不复写

### F5 verification 模板与守护面
- task-planner/templates/verification.md 140 行：VC 段 :10-31/Phase Gates :34-78/知识储备 :80/委派统计 :87/质量门控 :103/Goal Gate :109-128/5Q :131-140
- **CV 区块安全插入点=:127（验证独立性引用行）后、:131（5-Question 标题）前**，段尾追加式不触碰 VC/Phase/Gate 既有锚
- 守护面：仅 selftest-verification-gate.sh 引用 templates/verification.md（:23 SAT_TPL=**卫星**模板 skills/verification-gate/templates/verification.md；VG-03 :52-58 断言卫星模板 Verify command 串；VG-13 :148-156 守护 84.7）——主模板段尾追加风险低

### F6 判例锚格式先例
- 实例1 execution-recall-card.md:7 `（task-drift-fakeqc-20261115 判例锚）`；实例2 core critical-rules.md:107 `判例锚：…（判例=task-drift-fakeqc-20261115 判例）`
- Rule 108 判例锚沿用：`（判例=subagent-verifier-fabricated-output-20261103 判例）`同款格式

### F7 worktree 落地回执（P2 五单元主进程盘上复核，2026-11-15）
- 条款插入：规则文 +12 行（58→70），`^108\.[1-5]`=5/`^### 108`=1/`^### 84`=1/判例锚=1 全 PASS
- 级联A：verification-gate/SKILL.md Rule 108=3（description :3/调用时机 :32/References）；task-planner/SKILL.md Rule 84,108=1、1-108=3（:9/:224/:267）、1-107=0、其余 94 条=2（:9/:224 顺带修正陈旧计数）；issues=该单元自报 numstat +2/-1 与实际 3/2 有 1 行出入（内容面已核实无碍）
  - **[F7 勘误 2026-11-15 critic 轮1 M1 证实]**「其余 94 条」为主进程误判——草案原写 91 正确（108 落地 105−预留 77/78/79−核心 14=91；先例 archive/task-serial-sync 1-107→90）；已在 fix commit 2abe3ec 修回 91 条×2。本条为交叉验证方法论首个实弹捕获案例：主进程转译稿错误被独立复检+第一手重推导拦下
- 守护脚本：selftest-cross-validation.sh +78 行 chmod+x bash -n OK；CV-03 修订落实（`|| grep -q '108'`=0）；registry.tsv 新行 4 列 tab 实测；实跑 5/6（CV-05 预期 FAIL=模板未落时点）
- 模板区块：verification.md +7 行，`交叉验证记录（Rule 108）`=1、`^## ` 9→10、段序=验证独立性/---/CV 区块/5Q 全 PASS
- worktree git 面恰好 6 变更（5 M+1 新增脚本），scope 零越界

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| EN-06 级联仅改 '1-107'→'1-108'（:9/:92/:93/:95/:97），',107' 断言保持不动 | F3 侦察结论：',107' 守护的是 discipline 路由行（SKILL:210 真实未变）；verification-gate 路由守护由新 CV-04 覆盖。草案偏差已裁决修正 |
| selftest CV-03 收紧为仅 grep 'Rule 108'（删 `|| grep -q '108'` 兜底） | 任何行号串都会命中 '108'，断言过宽=真空守护；SKILL:4 description 编辑后必含 'Rule 108' 字面 |
| Rule 108 判例锚采用 `（判例=subagent-verifier-fabricated-output-20261103 判例）` | F6 格式先例对齐（execution-recall-card.md:7 形态） |

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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:2-drift-p2] Phase2 偏移检查
- 判定：✅ALIGNED（P2 落地产出与计划 scope/Goal/R1-R5 一致，可翻转）
- 证据1：worktree `8097063` `diff HEAD~1 --stat` 恰 7 文件（critical-rules-verification.md/SKILL×2/templates/verification.md/selftest-cross-validation.sh/selftest-registry.tsv/selftest-enumerate-first.sh），无 scope 外；`git status --short` 干净
- 证据2：`grep -cE '^108\.[1-5]'`=5、`grep -c '1-107' skills/task-planner/SKILL.md`=0、`selftest-cross-validation.sh` EXIT_CODE=0；enumerate-first diff 仅纪元字面 1-107→1-108 且阈值`-ge 3`/`,107`断言未变（非 test-gaming）
- 64.7：user-session-log.md #1（2026-11-15 /goal）R1-R5 原话在位，Goal∩原话交集成立；主仓 plans/ 外脏改（CLAUDE.md/README_zh.md/skills/plan-resume/SKILL.md）无证据归属本任务

#### [sub:1-regression] 回归分账
- 主仓：`Total: 97 PASS=94 FAIL=3 (run=97 reused=0)` Failed: selftest-active-plan selftest-execution-stability selftest-rule-reserve-pairing
- worktree：`Total: 98 PASS=96 FAIL=2 (run=98 reused=0)` Failed: selftest-active-plan selftest-execution-stability
- 判定：worktree FAIL(2) ≤ baseline FAIL(3) PASS，无新增 FAIL（减少 selftest-rule-reserve-pairing）

#### [sub:2-critic-recheck] Phase3 独立复检
- A R覆盖：R1/R3/R4/R5 有载体（108.1/.3/.5+双SKILL/模板）；R2「不依赖更高模型」负向约束 108 全文零载体（MINOR）
- B 条款质量：五子条可 grep+108.1 分工句在位；缺「机制」声明段（84.14:58 有）与卫星执行步骤承载（MINOR×2）
- C 级联：四锚 :9/:220/:224/:267 全改、1-107 残留=0、103.3a/decision-arbiter 非幻锚；但 SKILL.md:9/:224「其余 94 条」错（应 91=108−14−3 未落地 77/78/79，先例 1-107→90），MAJOR
- D 守护：CV 6/6+EN 7/7 exit0 非真空；CV-01 缺 `^### 108 ` 段标题锚（EN-01 先例有）+CV-02/03/05 退回全文 grep，MAJOR；三计数窗 [89]/9x 放行错误计数
- E test-gaming：条款与 clause-drafts §1 逐字 IDENTICAL、CV-03 收紧、EN-06 ,107 属域修正（非放水）；实质偏离仅 M1
- CR 结论：**CHANGES_REQUESTED**（2 MAJOR=M1 计数 94→91 / M2 CV-01 补段标题锚+SEC108 局部化；5 MINOR+2 NIT）→ checkpoint subagent-state/6-critic-recheck.md

#### [sub:3-fix-cr] 复检修复（M1/M2/m2）
- M1：worktree `skills/task-planner/SKILL.md` 两处 `其余 94 条`→`其余 91 条`（`grep -c '其余 94 条'`=0，`grep -c '其余 91 条'`=2）
- M2：`selftest-cross-validation.sh` 强化——CV-01 增 `^### 108 ` 块标题锚；CV-02 改为 `sed` 提取 `^### 108` 块内判例锚；CV-03 改为 `sed` 提取 verification-gate SKILL「调用时机」段内判定 `Rule 108`；CV-05 断言串改 `^## 交叉验证记录（Rule 108）`；PASS/FAIL 计数与退出码形态保持
- m2：`skills/verification-gate/references/critical-rules-verification.md` 108.3 句末追加「交叉验证的识别力来自隔离上下文与视角互异，不要求更高模型档位。」（grep=1）
- 验收：4/4 组 PASS；五脚本全 exit 0（CV 6/6, EN 7/7, DQ 14/14, AD 12/12, SA 20/20）
- 证据：checkpoint `subagent-state/7-fix-cr.md` (done)

#### [sub:4-critic-r2] 复检轮2
- M1 PASS：`grep -c '其余 91 条'`=2/`'其余 94 条'`=0；算式 108−3 预留（critical-rules.md:141）−14 核心（:180）=91，与 archive task-serial-sync progress.md:88 先例一致；残留 WARNING=F7:55 仍记「94 条…陈旧计数」未同步
- M2 PASS：CV :17 `^### 108 ` 块锚、`grep -c 'sed -n'`=2（:27/:35）、CV-05 :50 标题锚；负向实测删块标题→CV-01/02 FAIL rc=1、删调用时机行→CV-03 FAIL，四条判据均收窄未放宽
- m2 PASS：critical-rules-verification.md:66 108.3 含「不要求更高模型档位」；五脚本实跑 rc=0（6/6,7/7,14/14,12/12,20/20）
- CR 结论：**APPROVED**（零 BLOCKER/MAJOR；NIT×2=CV sed 区间含终止行代偿、SKILL:210 路由行缺 102 属预存）

#### [sub:3-drift-p3] Phase3 偏移检查
- 判定：✅ALIGNED（4/4 PASS）— Phase3 回归/复检链/dogfood 与 R1/R3/R4 对齐，scope 无漂移
- 证据1：worktree 8097063→2abe3ec 干净(3文件+49/-13)、cross-validation-report.md 判定「一致 PASS」、selftest-cross-validation.sh EXIT=0(6/6) 复核 V-3.1
- 证据2：CR链 6(CHANGES_REQUESTED)→7-fix-cr→8(APPROVED)闭环；D1 可追溯 findings F7勘误+clause-drafts.md:39+critical-rules.md:141+报告
- test-gaming：fix 仅收窄断言(CV-01块锚/CV-02,03局部化/CV-05标题锚)未放宽；基线 3→2 分账未操纵
