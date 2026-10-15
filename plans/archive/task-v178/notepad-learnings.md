# Task Learnings: task-v178 Rule 31.8 诉求层级契约

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
-

## What Worked
- L0-T 纯文本档全链（侦察→mini 计划→attest→单文件追加→16/16+81/81 回归→单 commit）约 10 分钟闭环，流程开销与变更体量成比例（宪法 §四.6 实效验证）

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
- 【执行偏差】用户制度层诉求（修 skill 防复发）被执行体降维为实例层动作（修具体 bug 现场）——类别：执行偏差；根因=规则缺位（修正路由无「诉求层级→交付层级」契约），已由本任务 Rule 31.8 落地修复
- 【口径误差】计划 VC-1 写「grep -c ≥5」但条款为单行格式实际唯一出现——类别：假设未验（写 VC 时未先确认条款行格式）；教训=VC 计数标准先实测文本形态再写；已在 progress.md [corrected] 登记
- 【簿记编辑】notepad 两次 Edit 因原模板末尾已有同义段造成重复段+行尾粘连——类别：假设未验（Edit 前未 grep 全文段结构）；教训=编辑模板文件前先 grep `^## ` 确认既有段位

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
- 【否决】对「修正 skill 确保 bug 不再出现」类诉求做实例层修复（修具体 bug 现场/业务代码）——否决原文：「执行过程偏差到去执行具体bug出现的情况修正 这个不是解决问题是严重的偏差修正」（2026-10-16）；适用范围=一切制度层诉求的执行

## Files Modified
- skills/task-discipline/references/critical-rules-discipline.md（Rule 31 段末追加 31.8，纯增量 +2 行）

## Verification Results
- Verified: 31.8 五段锚全命中（①制度层/②实例层/③双层/④存疑/⑤31.3 衔接）；git diff 2 insertions 0 deletions；selftest-error-loop 16/16；fresh 全量 81 PASS=81 FAIL=0（run=81 reused=0）
- Failed: 无（VC-1 计数口径措辞误差已按实际文本形态修正判定，见 progress.md [corrected]）

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源: Rule 38.7 L0-T 权威全文在 skills/plan-template-kit/references/critical-rules-template.md:49（SKILL.md 已有指针,无缺口）
- 待补齐的知识缺口: 无

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 结构化条目：触发条件 + 防线一句话；31.5 消费侧：下一 Phase 开工前 Read 未消费项，命中同类场景记 [learn-apply] -->
- 触发条件: 用户指令含「修 skill/规则/流程 + 确保不再出现」类表述 | 防线一句话: 交付物=规则文本条款,禁修具体实例,拿不准先问（Rule 31.8）

## 通用规则（General Rules — Rule 31.7）
<!-- [task-v134 Rule 31.7] 从具体案例抽象的通用规则；消费侧优先匹配通用规则 -->
| 规则名称 | 适用条件 | 具体措施 |
|----------|----------|----------|
| 诉求层级先行 | 用户要求修正 skill/规则/流程以确保某类问题不再出现 | 交付物=规则文本条款（最贴近载体），禁修具体 bug 现场；拿不准层级先问（Rule 31.8） |
