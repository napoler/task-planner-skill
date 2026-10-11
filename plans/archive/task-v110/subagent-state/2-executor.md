# checkpoint 2-executor — Phase 2 规范重写+引用面级联（task-v110，批次一=件 1+件 2）
status: done

## 里程碑
- M1 (done) 方案权威源 1-executor.md 全文 Read + 级联文件内容锚定位（行号偏移实测）
- M2 (done) 件 1 落地：critical-rules.md Rule 21.4 整段替换（:144 起 6 段式）+ 锚串全角括号修复
- M3 (done) 件 2 critical-rules.md 级联 6 处（22.4a/25.2/39 导语/39.1/39.4/40.4）
- M4 (done) 件 2 SKILL.md 7 处 + completion-gate/reference/methodology 3 文件 + 模板面 5 文件
- M5 (done) 验收 grep 三断言 + git diff --stat 文件集核对（10 文件与级联清单一致）
- M6 (done) 最终结论段 + findings/progress 回填

## 行号偏移披露（方案行号 → 实测行号，内容锚一致）
| 方案位置 | 实测 |
|---------|------|
| 21.4 正文 :144 | :144 起（新文本 6 段至 :149，21.4 计数仍=7） |
| 22.4a :155 | :162 |
| 25.2 :198 | :205 |
| 39 导语 :371 | :378 |
| 39.1 :373 | :380 |
| 39.4 :385 | :392 |
| 40.4 :400 | :407 |

## 关键实施细节
1. **锚串修复**：方案件 1 草案写「只读分槽豁免([task-v094 T-B1]」（半角），实测 selftest-tier-b.sh:71 grep 锚为全角 `只读分槽豁免（\[task-v094 T-B1\]`（od -c 证据：357 274 210 = U+FF08）→ 新文本用全角，`grep -c`=1 保留（tier-b 断言 0 改动）
2. **旧措辞清除策略**：「至多 1 个活跃子代理」绝对化表述不复现（废止登记句改述为「至多 1 活跃」缩写）；「互不依赖不构成并行理由」旧独立断言句在全部引用面（SKILL/reference/completion-gate/templates）清零；critical-rules.md:146 废止登记处保留带 [EVOLVED] 语境引号提及 1 处=演进记录非残留
3. **语义统一短语**：级联各引用面统一用「按 21.4 调度铁律/独立性守门（声明组并行/未声明串行，10-02）」；fan-out 两处（SKILL:132/:242、reference.md:322）翻转为「声明组并行」
4. **linked 场景保留**：reference.md:312/316 linked 串行接力归入 21.4 串行保留场景①（四问③ 输入依赖），措辞弱化「铁律」定性
5. **本批次未动**（Scope 禁改）：scripts/check-dispatch.sh、selftest-*.sh、zcode-posttooluse.sh（件 3 守卫归 S2 批次）；subagent-fallback.sh:284「按 Rule 21.4 对照 21.1b」指向保留语义失败兜底段，无需改
6. **越 scope 未动项登记**：config.json:343 retry_limit 悬挂引用 21.4→22.3 / CLAUDE.md:33 串行措辞 / MEMORY.md:101 计数锚（Phase 4）

## 验收 grep 实测
- `grep -rn "至多 1 个活跃子代理" skills/`（排除 companion）→ 0 命中
- `grep -rn "互不依赖不构成并行理由" skills/` → 1 命中（critical-rules.md:146 废止登记句，带 [EVOLVED] 演进标注）
- `grep -c '只读分槽豁免（\[task-v094 T-B1\]' critical-rules.md` = 1
- `grep -c "21\.4" critical-rules.md` = 7（memory-hygiene 计数锚保持）
- `git diff --stat` = 10 files, 36 insertions(+), 26 deletions(-)：critical-rules/SKILL/reference/completion-gate/methodology/template-guide/template-mapping/task_plan 模板/rule-enhancement-type/subagent_dispatch 各 1=级联清单 md 面 10 文件全齐，无越面文件

## 最终结论
status: done
acceptance: 3/3 pass — ①Rule 21.4 新文本落地（critical-rules.md:144-149，并行默认+四问守门+声明制+串行 5 场景+演进链 09-12→09-28→10-02）+级联 10 文件逐处完成 ✅ ②`grep -rn "至多 1 个活跃子代理"` 零残留 +「互不依赖不构成并行理由」仅 21.4 内 [EVOLVED] 废止登记 1 处 + 锚串 grep -c=1 ✅ ③`git diff --stat` 10 文件与级联清单一致（件 3 守卫文件未动）+checkpoint 含最终结论 8 字段块 ✅
files: /mnt/data/dev/task-planner-skill-worktrees/task-v110/skills/task-planner/references/critical-rules.md (+14/-7); .../SKILL.md (+7/-7); .../reference.md (+3/-3); .../references/completion-gate.md (+5/-3); .../references/methodology.md (+1/-1); .../templates/subagent_dispatch.md (+1); .../templates/task_plan.md (+1/-1); .../templates/variant/rule-enhancement-type.md (+1/-1); /mnt/data/dev/task-planner-skill-worktrees/task-v110/skills/plan-template-kit/references/template-guide.md (+1/-1); .../template-mapping.md (+2/-2); 计划面 findings.md(+1 段)/progress.md(+1 行)/subagent-state/2-executor.md(新建)
evidence: critical-rules.md:144（21.4 新标题「子代理调度铁律…演进链 09-12…→10-02 并行默认+独立性守门」）:146（锚串全角括号 `只读分槽豁免（[task-v094 T-B1]` grep -c=1）:392（39.4 [EVOLVED] 调和改写删「21.4 文本零改动」条款）; SKILL.md:132（fan-out 翻转「按 Rule 21.4 声明组并行（成员通过独立性四问即组内并行；10-02）」）; grep -rn "至多 1 个活跃子代理"→exit=1 零命中; git diff --stat→10 files changed, 36 insertions(+), 26 deletions(-)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/2-executor.md (status: done)
findings_written: #### [sub:2-executor] Rule 重写级联
blockers: none
confidence: HIGH
