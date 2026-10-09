# S14 材料包：check-complete.sh report-lint 段实现规格

> 目标：在 worktree 内 `skills/task-planner/scripts/check-complete.sh` 的 rcov-gate 段之后追加 report-lint（交付总结轻量校验，fail-open warn，**绝不改任何既有 exit 语义**）。依据=task-v155 Rule 70.6 + Rule 48 可定位性。

## 插入位置
- grep -n "rcov-gate" 定位 rcov-gate 逻辑段；在该段结束之后、下一个顶层函数/主流程之前插入独立函数（如 `run_report_lint()`），并在主流程与 rcov-gate 调用点同层级追加一处调用。风格（printf 到 stderr、缩进、变量命名）与 rcov-gate 段一致。

## 函数逻辑（三项轻量检查，全 warn 级）
1. 定位 delivery-summary.md：复用脚本既有计划目录变量；文件不存在 → `printf '[report-lint] SKIPPED (fail-open: 无 delivery-summary.md, 不影响终验)\n' >&2` 后直接返回。
2. 检查① 产出清单路径形态：「## 2. 产出清单」标题行至下一个 `^## ` 之间的表格数据行（排除表头/分隔行），若 ≥2 行不含 `/`（绝对路径或仓内路径形态）→ `printf '[report-lint] ⚠ 产出清单存在无路径行 (Rule 48.2/70② 可定位性)\n' >&2`。
3. 检查② 下一步建议三要素：「## 5. 下一步建议」区至文件尾/下一 `^## `，若不含「看点」或不包含「动作」→ warn「下一步建议缺看点/动作定位三要素 (Rule 48.4/70④)」。
4. 检查③ 待裁决定位：「待裁决」字样所在行若含「待裁决」但同行无路径形态（`/` 或 `http`）→ warn「待裁决项缺对象定位 (Rule 70②)」。
5. 全部检查只 `printf '[report-lint] ⚠ ...' >&2`，**禁止**：改 exit code、写 FAIL 计数、return 非 0 传播。

## 头注释（What+Why，Rule 45）
- 用途：交付总结呈报可审批性轻量守护（Rule 48/70）；消费方=check-complete 终验；fail-open 理由=exit 语义是交付门控承重墙，warn 不阻断；依据=task-v155。

## 验收（对应任务书 §3）
bash -n 通过；`grep -c "report-lint" check-complete.sh` ≥4；新增行中 `exit 1` 出现=0 且既有行零删除；行为冒烟=/tmp 造最小样例+主仓只读对照 exit code 一致。
