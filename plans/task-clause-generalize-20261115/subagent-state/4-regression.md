# 回归复跑检查点（F4/F7 后复跑）

## 汇总
- `Total: 97 PASS=88 FAIL=9 (run=97 reused=0)`
- Failed: `selftest-active-plan selftest-doc-script-paths selftest-execution-stability selftest-media-agents selftest-rule-reserve-pairing selftest-source-anchor-discipline selftest-subagent-return selftest-summary-readability selftest-workflow-orchestration`

## comm 子集判定
命令：
```bash
comm -13 <(grep -E '^\[FAIL\]' /mnt/data/dev/task-planner-skill/tmp/regression-final-20261115.txt | awk '{print $2}' | sort -u) <(grep -E '^\[FAIL\]' /mnt/data/dev/task-planner-skill/tmp/regression-generalize-final.txt | awk '{print $2}' | sort -u)
```
原文输出：
```text
(空，无输出)
```

## 结论
- **PASS**：`regression-generalize-final.txt` 的失败集是 `regression-final-20261115.txt` 的子集（无新增失败）。
