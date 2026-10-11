# fixa-executor 检查点 — task-v154 Fix-A 断言行联演进（DCS-11 / RF-06 / RF-07）

> 任务：Fix-A 断言行联演进（S8 回归 2 处级联修复）。
> worktree：/mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter（branch wt/v154-decision-arbiter，HEAD=3322259）。
> 写入范围：仅 A1/A2 两脚本 + 本检查点。SKILL.md / critical-rules.md 零触碰（git status 复核为空）。

## 时间
- 执行：2026-10-10 03:33（+0800）

## diff --numstat（两文件）
```
2	1	skills/task-planner/scripts/selftest-drift-check-subagent.sh
2	2	skills/task-planner/scripts/selftest-research-first.sh
```

## A1 改动（selftest-drift-check-subagent.sh，+2/-1）
- DCS-11 grep 条件：`Rule 40-65 全集` → `Rule 40-69 全集`（line 59 实断言）
- ok 11 说明文字：`索引括注 40-65 全集` → `索引括注 40-69 全集`
- 注释块演进史追加（line 58 后新增 1 行，措辞）：
  `# [2026-10-10 task-v154 S5 接线演进] 'Rule 40-65 全集'→'Rule 40-69 全集'：Rule 66(v151)/69(v154) 已落地，章节引言行欠账修正同步`

## A2 改动（selftest-research-first.sh，+2/-2）
- RF-06：grep 模式 `'1-66'` → `'1-69'`；说明文字 `SKILL 1-66 计数` → `SKILL 1-69 计数`；行尾演进注释追加：
  `# 2026-10-10 task-v154 S5 接线演进 '1-66'→'1-69'（Rule 69 落地，1-69 章节引言行修正同步）`
- RF-07：pair 第二模式 `Critical Rules 1-66（含 Rule 40-65 全集` → `Critical Rules 1-69（含 Rule 40-69 全集`；说明文字 `头注 1-66 全集` → `头注 1-69 全集`；行尾同款演进注释追加。
- RF-08（C44 行）未动。

## 两脚本运行尾部输出
### A1 `bash skills/task-planner/scripts/selftest-drift-check-subagent.sh`
```
DCS-11 PASS 索引括注 40-69 全集+Rule 61 偏移检查子代理化 保全+Rule 61 摘要 bullet
Total: 20 PASS=20 FAIL=0
A1 exit=0
```
（DCS-11 转 PASS，其余 19 断言无回退）

### A2 `bash skills/task-planner/scripts/selftest-research-first.sh`
```
FAIL RF-06 SKILL 1-69 计数≥3(三处联动) (got=1 expect>=3)
PASS RF-07 SKILL 双锚(bullet 全角括号+头注 1-69 全集)
Total: 12 PASS=11 FAIL=1
A2 exit=1
```
（RF-07 转 PASS；RF-06 仍 FAIL）

## 阻塞项（RF-06，规格内在冲突，需主进程裁决）
- 根因：RF-06 断言语义=`三处联动`（SKILL.md 三处 1-NN 锚计数 ≥3）。S5 仅更新三处中的 1 处（SKILL.md line 286 `Critical Rules 1-69（含 Rule 40-69 全集`），另两处仍为旧值：
  - line 9（References 索引行）：`Critical Rules 全集 1-66（…）`
  - line 368（References 表行）：`Critical Rules 1-66（含 Rule 13-18/…）`
  实测 `grep -c '1-69' SKILL.md = 1`、`grep -c '1-66' SKILL.md = 2`。
- 冲突：验收要求 `A2 全 PASS`，但同书要求 `SKILL.md 零触碰`；把三处锚补齐（1-66→1-69）正是主进程 next_step 的 Fix-B「钉值上调」范围。二者在 Fix-A 单批内不可兼得。
- 说明：RF-06 `≥3` FAIL 实为「三处联动已断裂」的正确告警（非误报），不应通过降门限掩盖。
- 建议（推荐 A）：先执行 Fix-B 钉值上调（line 9/368 → 1-69），再复跑 A2，RF-06 自然转 PASS（届时 1-69 计数=3）。注意 Fix-B 会把 line 368 的 `Critical Rules 1-66` 一并演进，需同步核对依赖该串的 SR-07/TS-05/RC-11/LA-12 四守卫（均 `≥1`）。
- 备选 B：若 Fix-A 必须单批自足 PASS，将 RF-06 门限 `3`→`1`（与 SR-07/TS-05/RC-11/LA-12 的 `≥1` 口径一致），但会丢失「三处联动」语义——需主进程显式授权（本执行体未自行改动）。
- 备选 C：RF-06 改宽容锚 `1-6[0-9]` 保持 ≥3（同仓 CD-18/IP-12 宽容正则先例），可兼容 1-66/1-69 过渡态——同属规格外改动，需授权。

## 零触碰复核
- `git status --short -- skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md` = 空（未触碰）。
- `git status --short` 仅两脚本 M。
