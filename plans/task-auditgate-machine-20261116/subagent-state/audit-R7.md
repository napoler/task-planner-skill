# audit-R7 — 独立审计体（R7 复审轮）

- 起始时间：2026-11-17
- 工作目录：/mnt/data/dev/task-planner-skill
- 模式：只读审查（仅本检查点可写）
- 复审范围四面：①R6a 加固闭环 ②登记时点簿记 ③修复引入新缺陷 ④历轮遗留升级必要性

## 进度
- [x] 读取任务书
- [x] 读三计划文件 + knowledge-brief + progress.md R5/R6/R6a 段 + 5Q 块 + fix-R6a.md
- [x] 面①：R6a 两约束语义核验 + /tmp 四态/八态判别性抽测（NEW/OLD/仅边界/仅锚定 四变体）
- [x] 面②：簿记核验（锚定计数=1、AP/REJ 计数、Handoff 16 行与派发算术、5Q 双块比对）
- [x] 面③：新缺陷排查（R1-R3 锚、user-session-log mtime+sha、审计段数=6、八机械门、列解析 SKIPPED=0、tracked 修改时点）
- [x] 面④：遗留升级必要性评估
- [x] 裁决与发现清单

## 实测要点（盘上证据）
- `grep -cE '^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*' progress.md` = 1；REJECTED=5；`^## \[plan-audit-RN\]` 段数=6，末段=R6（314 行）。
- 八机械门（正确参数）全 rc=0；`check-plan-dispatch` SKIPPED 计数=0；`check-tier-consistency` lines=489（R6a 收据记 478）。
- user-session-log：mtime 2026-11-16 23:39:23.409788871、4355B、sha256 前 12 位 d12cd51f8604（未变）。
- R1-R3 锚 task_plan.md:16-18 与 user-session-log.md:12 一致。
- 受版本控制的工作树修改（CLAUDE.md/README_zh.md/3 个 skill）mtime=2026-11-15 22:07，均早于本任务，R6a 未触碰 skills/**。
- VC-1 Verify command 反引号=0；`sprintf("%c",96)` 实跑生成 `` `结论: **APPROVED**` `` 正确。
- /tmp mock 四变体跑 VC-1 命令：NEW=rc0（r1=1 r2=1 r3=0 r4=1）／OLD=rc1（r4 假 PASS 被抓）／**仅边界(only1)=rc0**／**仅锚定(only2)=rc0**。
- 追加两 fixture：a=REJECTED 段内含裸文 `结论: **APPROVED**`（无正规结论行）→ only1 rc=0 假 PASS、NEW rc=1；b=后随 H2 块含正规锚定 APPROVED 行 → only2 rc=0 假 PASS、NEW rc=1。
- spec-literal mock（要求 `问题清单:` 连写）跑真实 plan-dir → rc=1「形态残缺」；放宽为 `问题清单` → rc=0。根因：唯一 APPROVED 段 progress.md:316 为 `- 问题清单（留档，不阻断）:`。

## 发现清单
- I-1 [IMPORTANT] `问题清单:` 最小形态 token 与唯一 APPROVED 审计段实际形态不符 → spec-faithful checker 对真实 plan-dir 必 rc1（VC-5/自举实测确定性失败），或实现方私自放宽致判据漂移且无 fixture 覆盖真实形态。
- I-2 [IMPORTANT] VC-1 r4 / VC-3 用例集无法判别「只做其一」：仅边界或仅锚定实现均通过 VC-1 命令；并各有一条独立假 PASS 路径（fixture a/b）。
- W-1 [WARNING] progress.md 5-Question 仍停 R6 态（"待 D1"/"登记 [plan-audit-R6]"），与 verification.md:207、task_plan Current Phase/Next Step 的 R6a/R7 态不一致。
- W-2 [WARNING] 无声明 `SKIP legacy-no-decl` 无可执行判据（VC-1 四态、VC-3 用例集均无）；既有面，非 R6a 引入。
- Q-1 [QUESTION] 聚合边界只认 H2 `## `；后随块若写 H3/粗体标题则约束失效（约定未强制）。
- Q-2 [QUESTION] progress.md 存在但为空 → rc1 还是 rc2 未定义（VC-1 r1 期望 1；VC-3 有"rc2 输入缺失"）。
- N-1 [NIT] task_plan.md:440 派发算术：critic×6+plan-writer×7+排队 ≠「16 次派发」（表内 12 done + 4 queued）。
- N-2 [NIT] R6a 收据 `lines=478` 已不可复现（现 489，登记编辑后未补复跑留痕）。

## 裁决
结论: **REJECTED**（0 CRITICAL / 2 IMPORTANT / 2 WARNING / 2 QUESTION / 2 NIT）
