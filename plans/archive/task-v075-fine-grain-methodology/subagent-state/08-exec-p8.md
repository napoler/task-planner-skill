# Checkpoint: P8 executor（S1 双文档条目）

## 状态
- 完成时间: 2026-09-16（session 内 P8 派发后执行）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v075-fine-grain-methodology
- scope: 仅 CHANGELOG.md + README_zh.md 两文件（未改代码/模板/条款/脚本）

## 里程碑
1. 两文件落盘 ✅
   - CHANGELOG.md: +5 行（5 条新条目在 `[Unreleased] / ### 新增` 顶部，v074 既有条目保持原序不动，无标题重复）
   - README_zh.md: +8/-2 行（项目结构树 +3 行脚本职责句；配置段 JSON 示例 +1 行 fmea_enforce；$schema 段 +1 句运行键消费说明）

## 条目摘要（供验收对照）
| 文件:line | 内容 | 来源证据 |
|---|---|---|
| CHANGELOG.md:12 | A1 S-unit 数值门控（NNmin≤step_max_minutes=15 / 输入 token≤step_max_files=2 / SKIPPED 显式化 / selftest T09-T12 8→12） | commit c506349 + check-plan-dispatch.sh:167-182 注释 + progress P2 段 |
| CHANGELOG.md:13 | A2 三项增量（长度 wc -m vs 3000 / ≥2 S-unit ID 打包 / brief 引用提示，挂 dispatch_contract_enforce 三档；FG-01..04 18→22；本仓 default=enforce 实测=部署即硬阻断） | commit 6c51c24 + check-dispatch.sh:242 fine_grain_checks + findings P3 行 |
| CHANGELOG.md:14 | B1 fmea_enforce 双点（attest FMEA 门控段三档+--skip-fmea-check 逃生+legacy fail-open；check-complete 终验无逃生口；M-08..M-11 7→11） | commit fdff22b + attest-plan.sh:119-172 + progress P4 段 |
| CHANGELOG.md:15 | B3 遗留清理（verify.sh §9 补 selftest-methodology 遍历，全量 26 pass/0 fail；methodology.md 两处不可核出处泛化+待补登记） | commit 685b206 + methodology.md:137/158 现状 + progress P5 段 |
| CHANGELOG.md:16 | P6/P7 模板/条款同步（NNmin 契约注释、7 列 S-unit 表示范、SKILL 4 处 + critical-rules 5 处「机器校验已生效」、SKILL 535 行不变；「各 selftest 只增不减，总数以 P9 实跑为准」按任务书不写具体总数） | commit 5d215b6/9f75354 + progress P6/P7 段 |

## 自查
- grep -c "task-v075": CHANGELOG=5, README=2（均 ≥1）✅
- git diff 新增行 `grep "\](" ` 无命中（0 悬空链接）✅
- config enforce 事实按 findings P3 行如实写（「本仓 dispatch_contract_enforce.default = enforce 实测=部署即硬阻断」），未写「预计/应该」✅
- 数字口径全部取自 progress P2-P7 段主进程复跑记录（12/0、22/0、11/0、17/0、26/0），未自造总数 ✅

## 偏差
- README ①②处未单独成段扩写（项目结构树原无 check-plan-dispatch/check-dispatch 行，按「行位替换优先、禁新增大段」原则在既有 scripts/ 树内插 3 行职责句；fmea_enforce 键说明按既有 JSON 示例模式在配置段补 1 行 + $schema 段 1 句）——实质覆盖 3 处指定内容，偏差在形式不在内容。

## 风险
- 1. README 配置段 JSON 示例原为虚构简化键集（非 config.json 全文），新增行与示例非 schema 严格对应——但该段本就是示例段（原 8 键均非逐字配置），风险=低。
- 2. P9 全量回归定数后若 selftest 总数与 CHANGELOG「只增不减」表述冲突，需回填总数行——按任务书 P9 实跑后处理。
