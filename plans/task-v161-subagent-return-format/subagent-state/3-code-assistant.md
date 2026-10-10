# S3 检查点 — check-subagent-return.sh (code-assistant)

## 进度日志
- T1 完成: Read 材料包(3-prompt-material.md)全文 + Read 风格参照 check-dispatch.sh(前缀 [return-guard] 已仿其 rc 语义); Read v152 污染样本 (findings.md 指向 plans/task-v152-proactive-context/subagent-state/2-executor-S1.md:32, status 与 acceptance 之间混入 summary: 行) → 夹具二原文据此构造。
- T2 完成: 实现 /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-subagent-return.sh (93 行 ≤95; 头部注释含 What/Why 双层; 零 config 键)。
  - 判据一: FIELDS 8 字段逐个 grep -qE "^[[:space:]]*c:" (行首锚定+容忍行前空白)
  - 判据二: grep -oE '^[[:space:]]*[a-z_]+:' 去 8 字段白名单 → 输出点名违规字段名
  - 判据三: awk 状态机(逐行存 lines[], 记最后 confidence: 行号, END 向后扫描; 禁 next 防区间坍缩) 显式豁免 ``` 围栏行与纯空白
  - 判据四: status/confidence 逐值 case 值域匹配
- T3 完成: 自跑四条命令全部通过 (evidence 见下)。
- 额外边界验证(超出材料包要求的自检): 值域负例 (status: ok / confidence: very-high 均 rc1 点名判据四); 行前空白 + 尾部 ``` 围栏豁免 rc0; 文件入参合规 rc0; --help 输出头部注释。
- T5: 最终结论段已写(下方 8 字段块)。

## 最终结论

```
status: done
acceptance: 4/4 pass — [1:PASS bash -n 零语法错 2:PASS --selftest 4 夹具全 PASS rc=0 3:PASS 4 单夹具 stdin 分流 rc0/rc1/rc1/rc1 4:PASS 93 行≤95 且头部注释含职责/用法/夹具说明]
files: /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-subagent-return.sh (+93/-0)
evidence: check-subagent-return.sh:1-21 (头部注释 What+Why); bash -n → "SYNTAX_OK"; bash <脚本> --selftest → "[selftest] fixture-1..4 PASS" rc=0; printf 合规块|bash → "[return-guard] PASS" rc=0; summary 污染块 → "VIOLATION 判据二: 契约外字段: summary" rc=1; 块尾附加块 → "VIOLATION 判据三: 块尾附加行 L9: ## 附:验收细节" rc=1; 自然语言块 → "VIOLATION 判据一: 缺字段 status:" rc=1; wc -l = 93
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/subagent-state/3-code-assistant.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```

## 备注
- 未触碰禁改清单内任何文件 (check-dispatch.sh / critical-rules.md / SKILL.md 均只读未动); 无 git 写操作; 未碰 ~/.zcode/agents/** 与主仓文件。
