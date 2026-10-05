# 8-executor-fix — task-v137 审查修复波 checkpoint

状态：done（4/4 验收 PASS；未提交，待主进程 commit/merge_back）
时间：2026-10-05，worktree=/home/terry/task-planner-skill-worktrees/task-v137

## 修复项（3 处行内改词，零净增删行）

1. 【P0】references/critical-rules.md:146 — 「禁双份供料由 Rule 22 §9(上下文预算,禁贴全文)既有纪律承载,本条引用不重述」→「禁双份供料由 `templates/subagent_dispatch.md` §9(上下文预算,禁贴全文)承载,本条引用不重述」。该行已不含 '22.4' 子串（防 T6 行号提取误命中，与 P0-1 规避循环闭合）
2. 【P2-1】templates/variant/rule-enhancement-type.md:100 —「台账供料简报（B8 编号账本+审计台账路径等）」→「台账供料简报（Rule 编号账本+审计台账路径等）」
3. 【P2-1 延伸】templates/knowledge-brief.md:50（§3 示例行）—「:557-567」「### 52」「供料 2026-10-05，源=B8 landed 最大号」→ 占位符「:<起-止>」「### <NN>」「供料 <日期>，源=编号账本最大 landed 号」

## 8 字段回执（与最终返回一致）

- status: done
- acceptance: 4/4 — ①PASS grep -c 'Rule 22 §9'=0 且 :146 不含 '22.4'（双 grep 均 0）②PASS grep -rnw 'B8' 命中 0（裸子串 3 处全为 selftest-dispatch-grain.sh 的 TB8 测试变量名，系既存 task-v094 测试编号而非台账 B8 代号，词边界复核排除）③PASS 三文件 wc -l 改前=改后（实测基线 593/123/68；注意指令所写 591 与实测改前值 593 不符，以「零净增减」实义 PASS，改前基线已存证）④PASS selftest-knowledge-brief.sh Total:16 PASS=16 FAIL=0，T6 报 21.2(145)+22.4(168)，168 为 22.4 真实定义行
- files: 3 绝对路径各 1 行行内改写，~3/+0/-0（references/critical-rules.md:146、templates/variant/rule-enhancement-type.md:100、templates/knowledge-brief.md:50）
- evidence: 见下
- checkpoint: 本文件，状态 done
- findings_written: none（主进程回填）
- blockers: none
- confidence: HIGH

## 命令→关键输出（存证）

```
cd /home/terry/task-planner-skill-worktrees/task-v137/skills/task-planner
grep -c 'Rule 22 §9' references/critical-rules.md            → 0
sed -n '146p' references/critical-rules.md | grep -c '22\.4'  → 0
sed -n '146p' | tail -c 80  → …禁双份供料由 `templates/subagent_dispatch.md` §9(上下文预算,禁贴全文)承载…
grep -rnw 'B8' .                                                 → (exit 1, 0 命中)
grep -rn 'B8' . | wc -l                                          → 3（均 selftest-dispatch-grain.sh:107-109 的 $TB8，既存测试变量名，非 B8 台账代号）
wc -l（改前=改后）→ 593 references/critical-rules.md / 123 templates/variant/rule-enhancement-type.md / 68 templates/knowledge-brief.md
bash scripts/selftest-knowledge-brief.sh → [PASS] T6 critical-rules 21.2(145)+22.4(168) 命中且 100<行号<200；Total: 16  PASS=16  FAIL=0
```

## 遗留提示（非本单元范围，仅登记）

- 审查报告 P2-2（T6 grep -F 行号提取脆弱）与本 P0-1 的 (a) 方案含 selftest 收紧，本修复波指令只授权 3 处行内改词，scripts/ 未动 → T6 现行写法在 :146 已无 '22.4' 子串的前提下 T6 复跑正常；是否收紧 selftest 锚归主进程决策
- 本波改动落在 worktree 内未 commit；四部署位同步（zcode/claude/opencode/cursor）由主进程在 merge_back 后执行
