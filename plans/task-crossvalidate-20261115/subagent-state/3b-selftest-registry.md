# 3b-selftest-registry checkpoint (T1-T5)

- T1 读取草案/参照: 已读 `/mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/clause-drafts.md` §3 第6/7项；已读参照 `tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-verification-gate.sh :1-40` 对齐形态。
- T2 新建脚本: 已写 `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-cross-validation.sh`（逐字采信草案 + CV-03 修订：仅保留 `grep -q 'Rule 108' "$SAT_SKILL"`，删除 `|| grep -q '108'` 兜底）。`chmod +x` 完成。
- T3 语法与修订校验: `bash -n .../selftest-cross-validation.sh` -> SYNTAX_OK；`grep -c "|| grep -q '108'" ...selftest-cross-validation.sh` -> 0；`grep -c "108\.[1-5]" ...selftest-cross-validation.sh` -> 2（脚本内断言面引用到 108.1-108.5）。
- T4 registry 追加: 向 `tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-registry.tsv` 追加 1 行（真实 tab，`printf '%s\t%s\t%s\t%s\n' ...`）。验证：`tail -1 ... | awk -F'\t' '{print NF}'` -> 4；`grep -c '^selftest-cross-validation.sh' ...` -> 1；末行列数=4。既有行未改动。
- T5 验收命令回读（按需求）:
  - 脚本存在+可执行（-x）+`bash -n` 通过：是（见 T3）。
  - `grep -c "|| grep -q '108'" <脚本>` = 0：是（输出 0）。
  - registry 新行 4 列：`tail -1 | awk -F'\t' {print NF}` = 4 且 `grep -c '^selftest-cross-validation.sh'` = 1：是。
  - `grep -c '108\.[1-5]' <脚本>` ≥1：是（输出 2）。

最终结论（8字段）：
status: done
acceptance: 4/4 pass — [1:PASS 2:PASS 3:PASS 4:PASS]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-cross-validation.sh (+78/-0, new, chmod +x); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-registry.tsv (+1/-0, appended last line only)
evidence: bash -n /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/scripts/selftest-cross-validation.sh -> SYNTAX_OK; grep -c "|| grep -q '108'" .../selftest-cross-validation.sh -> 0; grep -c "108\.[1-5]" .../selftest-cross-validation.sh -> 2; tail -1 .../selftest-registry.tsv | awk -F'\t' '{print NF}' -> 4; grep -c '^selftest-cross-validation.sh' .../selftest-registry.tsv -> 1
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/3b-selftest-registry.md (status: done)
findings_written: none
blockers: none
confidence: HIGH