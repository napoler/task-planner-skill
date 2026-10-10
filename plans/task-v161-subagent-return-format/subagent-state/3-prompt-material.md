# S3 材料包 — check-subagent-return.sh 功能规格（子代理 Read 本文件后实现）

## 目标文件（worktree 内唯一可写新文件）
/home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-subagent-return.sh

## 风格参照（只读）
/home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/check-dispatch.sh（仿其 bash 风格/rc 语义/输出前缀 [dispatch-guard] 形态,本脚本前缀用 [return-guard]）

## 用法
- `check-subagent-return.sh <file>`：校验文件内容
- `check-subagent-return.sh`（无参）：读 stdin
- `check-subagent-return.sh --selftest`：内置 4 夹具自检
- `check-subagent-return.sh --help`

## 校验判据（任一不过 = VIOLATION,exit 1;全过 = stdout `[return-guard] PASS`,exit 0）
- 判据一（字段齐全）: 以下 8 字段各 ≥1 行命中（行首锚定,容忍行前空白）:
  `^status:` `^acceptance:` `^files:` `^evidence:` `^checkpoint:` `^findings_written:` `^blockers:` `^confidence:`
- 判据二（契约外字段）: 除上述 8 字段外出现 `^[a-z_]+:` 形态行即违规（如 `summary:`——v152 实证污染样本;输出点名违规字段名）
- 判据三（块尾无附加）: 最后一个 `^confidence:` 行之后不得再有非空内容行;允许尾部 ``` 围栏行与纯空白（awk 状态机逐行扫描,禁 next 写法防区间坍缩,``` 围栏行显式豁免）
- 判据四（值域）: status 值 ∈ done|partial|failed|timeout;confidence 值 ∈ HIGH|MED|LOW

## --selftest 4 夹具（内存构造即可,不写临时文件）
- 夹具一（合规）: 8 字段齐全标准块 → 期望 rc 0 + PASS
- 夹具二（契约外字段）: status: done 后紧跟 `summary: <长文本>` 再接其余字段（v152 实证形态）→ 期望 rc 1 且输出点名 summary
- 夹具三（块尾附加）: 合规 8 字段块后追加「## 附:验收细节」+两行说明 → 期望 rc 1
- 夹具四（纯自然语言）: 无任何 8 字段的自然语言段落 → 期望 rc 1
- 断言输出逐夹具 `[selftest] fixture-N PASS/FAIL`;任一 FAIL → --selftest exit 1

## 硬约束
- bash,总行数 ≤95 行;头部注释含职责/用法/夹具说明（Rule 45 What+Why 双层）
- 零 config 键:固定行为,不读 config
- bash -n 零语法错

## 完成后自跑
`bash -n <脚本>`、`bash <脚本> --selftest`、三个单夹具命令（echo ... | bash <脚本>）,输出全部写回 evidence 字段。
