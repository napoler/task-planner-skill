# Task Plan: task-anticheat-20261116（验证反作弊规约条款 — mini stub，L0-lite 双门放行，零新脚本零 attest）
<!-- plan_tier: mini | execution_lane: L1-lite（纯文档条款增量，§11.5②；主进程编排+code-assistant 落段[委派守卫]） -->
<!-- 背景：用户 2026-11-16 裁决「落实反作弊条款+严禁清单直列形式」；上游=task-veriffirst-20261116（fc37133）交付后的缺口讨论：grep 型判据不证行为、无负控制、无魔法常数禁令 -->

## Goal
verification-gate SKILL.md 落「验证反作弊规约」段（判据分型+正向要求四条+严禁清单八条+Step 3b 评审动作），spec-mode.md §5 尾部加权威源指针行——验证编写期的作弊面（写死期望值/空洞命令/吞判据/选择性执行/旧证据冒充等）条款化封堵。

## 用户需求锚（Rule 51.1 转述锚，逐字见会话记录）
- R1 [目标]：压制作弊行为——「如何避免模型直接写一个 5 然后 return 5 来解决」「在编写验证的时候严格限制作弊行为」
- R2 [手段]：验证撰写时直接列出严禁行为（严禁某某某清单形式）

## ✅ Verification Contract（验证前置：基线=同树态 fc37133 的 /tmp/veriffirst-post.log 98/93/5 + targeted VG 13/0 已预跑）
| # | 判定 | 验证命令 |
|---|------|---------|
| VC-1 | 反作弊规约段在位 | grep -q "验证反作弊规约" skills/verification-gate/SKILL.md && grep -c "严禁" ≥8 && grep -q "严禁写死期望值" && grep -q "负控制" && grep -q "盲探针" |
| VC-2 | spec-mode §5 指针行在位 | grep -q "验证反作弊规约" skills/task-planner/references/spec-mode.md |
| VC-3 | 纯增量 | git diff 两文件删除行=0（EOF 规范化除外，PREFIX-OK） |
| VC-4 | targeted 回归 | selftest-verification-gate.sh 改后仍 Total PASS=13 FAIL=0 |
| VC-5 | 全量回归 | run-selftests Total FAIL 与基线 98/93/5 同集零增量（逐项归因） |
| VC-6 | 部署同步 | verification-gate SKILL.md ×3 位（zcode/claude/cursor）+ spec-mode ×4 位 diff=0 |
| VC-7 | 无字形损坏 | grep 异常字形扫描=0（上轮判例：任务书错字逐字入盘） |

## Phases
- [x] P1 锚点+基线（SKILL.md 95 行已读/自检断言面=token 在位型/targeted VG 13/0 预跑/同树态全量基线复用 fc37133 post log）
- [x] P2 两文件落段（code-assistant 代理 a3b0160 前置工作；主进程盘上复核：diff 逐字审读+字形扫描误报甄别——「头脑风暴」正字命中=既有内容非损坏）
- [x] P3 回归（VC-4 targeted VG 13/0 + VC-5 全量 98/93/5 同集零增量）+部署（VC-6 vg×3+spec-mode×4 diff=0）+commit **a3b0160**
- [x] P4 簿记收尾（本段+memory）

## 📋 执行记录（2026-11-16 03:35-03:50 收口）
| VC | 结果 | 证据 |
|----|------|------|
| VC-1 规约段在位 | PASS | grep 严禁=10/严禁写死期望值/负控制/盲探针 全命中（SKILL.md:75 新段，代理自验+主进程 diff 审读双确认） |
| VC-2 spec-mode 指针行 | PASS | spec-mode.md:66 命中 |
| VC-3 纯增量 | PASS | numstat vg 22/0、spec-mode 2/1（1 删=EOF 换行规范化，锚行同文成对） |
| VC-4 targeted 回归 | PASS | selftest-verification-gate.sh Total 13/0（改前改后一致） |
| VC-5 全量回归 | PASS | /tmp/anticheat-post.log Total 98/93/5，FAIL 五项与基线同集零增量 |
| VC-6 部署同步 | PASS | vg×3 位+spec-mode×4 位 diff=0 全绿 |
| VC-7 字形扫描 | PASS | 2 命中均为既有正字「头脑风暴」（HEAD 对照同 2），新增内容零损坏 |
| outcome | **COMPLETE** | commit=a3b0160；全 VC PASS |

**判例登记（本任务即规约的活演示）**：①落段子代理口供称「字形扫描均为 0」而原始输出实为 spec-mode.md:2——口供与证据脱钩被主进程读原始输出当场抓住（规约严禁清单第 8 条的现场教材）；②扫描模式 `[风]` 误报正字「头脑风暴」→ 判扫描器有效性必须 HEAD 对照+人工定位（负控制思想：先证明扫描器能区分正/误）。

## 变更标注表（Rule 74.3 — 全增量）
| 编号 | 对象+锚点 | 类型 | 吸收 | 执行动作 |
|------|----------|------|------|---------|
| CA-1 | skills/verification-gate/SKILL.md（「## 脚本引用索引」标题前） | 新增（H2 段） | 增量 | 插「验证反作弊规约」全段 |
| CA-2 | skills/task-planner/references/spec-mode.md（§5 反模式行后/文件尾） | 新增（一行） | 增量 | 追加权威源指针行 |
