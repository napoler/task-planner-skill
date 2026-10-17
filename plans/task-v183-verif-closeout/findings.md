# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户 R1「以上发现的问题是否都已经解决? 确保所有发现问题都解决了」= 关闭审计 dwfrun-04e929e0 遗留全部未解决问题
- 用户 R2「提高验证/主动发现错误能力」= 3 类已确认漏检（完成声称默认档/目标偏移/语义级产出）要有机器检查兜底
- 范围 = 7 提案 P-02/03/05/06/07/08/09 + P-10 残留 FAIL + P-04 档位裁决（来源 plans/verification-upgrade-2026-10-16/report.md §5/§7）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 审计提案清单 | plans/verification-upgrade-2026-10-16/report.md §5/§7.1 | 是 | Research Findings |
| 判定器范式 | skills/task-planner/scripts/check-evidence-anchor.sh + selftest-evidence-anchor.sh | 是 | Technical Decisions |
| registry 范式 | skills/task-planner/scripts/selftest-registry.tsv（4 列 TAB） | 是 | Technical Decisions |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- P-05 根因：`tr -d '*-#'` 中 `*-#` 被 tr 解析为反向区间（`*`=0x2A > `#`=0x23），多数 locale 报错→tr 失败→keyword 恒空→Rule 65 矛盾检测器死。修法=`*#-`（尾连字符=字面删除 * / # / - 三字符）。实证：矛盾夹具 exit=1、干净 exit=0（periodic-review.sh:89/122/147）。
- P-06 根因：check-drift.sh:187 `grep -oP '\w+'` 纯中文下抽出 0 CJK 词→漂移检测静默跳过。新 check-goal-cjk.sh 走 `od -An -tx1 | awk` 字节态机（本仓 grep=ugrep，POSIX ERE 下 CJK 区间实测不匹配），locale 免疫。实证：本计划 Goal 抽出 15 CJK 词。
- P-02/P-03/P-07/P-08/P-09 各建独立判定器，范式同 check-evidence-anchor（纯 bash+awk 无 python/jq、exit 0/1/2、`[prefix]` 输出、What/Why 双层头注）。
- P-10：报告记的 selftest-vc-gate FAIL 经 `--fresh` 复跑证实为工作流并行期瞬态，**已自愈**（84/84 绿，非当前工作树缺陷）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| isolation=direct（不 worktree） | 37 工作流改动已在 master 未提交，本任务为其收口续作；worktree-from-main 会与 master 未提交态冲突。已呈报用户未否决 |
| P-04=warn（不翻 enforce） | 存量 73/145 计划命中 enforce 会批量失败；config vc_gate_enforce 默认已=warn，无需改；enforce 需先清存量 |
| 7 提案各独立脚本 | 单一职责 + 独立 selftest + 独立 registry 行，符合既有 check-* 族范式 |
| 判定器不接线 check-complete（本批） | 消费侧接线为后续批次；本批=判定器+selftest+registry 落地，保持增量可控 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| attest 拒锁（VC 缺可执行命令） | verification.md 每条 VC 补 `**Verify command**:` 行 + 避免非 VC 段 `- [ ] VC-N` 伪行 |
| 6 新 selftest 的 registry 自登记断言初跑 FAIL | 集中登记 6 行 selftest-registry.tsv 后全转正 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 判定器范式：`skills/task-planner/scripts/check-evidence-anchor.sh`（P-01 落地）
- selftest 范式：`skills/task-planner/scripts/selftest-evidence-anchor.sh`（EA-01..20）
- registry：`skills/task-planner/scripts/selftest-registry.tsv`（90 行）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
