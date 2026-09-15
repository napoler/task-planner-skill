# 05-code-assistant — task-v075 P5（B3：v063 遗留清理）

## 里程碑 ① S1（verify.sh 循环补入） — 落盘

**定位依据（Read 实证，非盲改）**：
- `lib/verify.sh:225-233` §9 for 循环段实读：`for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh; do [ -x "$TASK_PLANNER_ROOT/scripts/$_script" ] && pass …`
- 该循环语义=对 scripts/ 下指定脚本做「存在性+可执行性」单点检查，与 methodology 无关——是纯 delegation 三件套检查（§9 头注释明言"task-v055 委派门控三件套"）
- **裁定**：按派发预案 B 分支执行（"若循环语义与 methodology 无关则补入文件内 selftest 全量执行段"）。但该循环即全量段（verify.sh 内唯一 selftest 遍历处，grep `selftest` 全文件命中仅 :227 一处循环列表；无其他 for-in 遍历）→ 实际即在该循环列表追加 `selftest-methodology.sh`（与预案一致，定位依据已记录）
- verify.sh 全文件 grep `selftest` 命中：`:227`（循环）+ 头注释（行 27-28），无第二遍历处

**改动（1 行级 + 注释 4 行）**：
- `lib/verify.sh:227` `for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh; do`
  → `for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh selftest-methodology.sh; do`
- `:225-226` §9 头注释追加 task-v075 P5 说明行（2 行）
- `:27-28` 文件头 Checks 清单 §9 条目追加说明（2 行）

**验证**：
- `bash -n lib/verify.sh` → SYNTAX_OK
- selftest-methodology.sh 权限 `-rwxrwxr-x`（可执行位满足 `:228` `[ -x … ]` 判定）
- 全量 `bash skills/task-planner/lib/verify.sh` 待 S2 完成后一并跑（避免双跑），结果回填本文件

## 里程碑 ② S2（methodology.md 两处出处泛化） — 落盘

**改动（3 处，均在 references/methodology.md）**：
- `:137` 原文 `**出处**：Google DeepMind 2023 文本质量分类法（五维加权思路）（待补：论文具体标题）`
  → `**出处**：业界通行实践/公开报道综合（五维加权思路，原始出处待补，不瞎编）`
- `:158` 原文 `**出处**：Anthropic Claude Code 2024 内部规范（子代理结构化返回）（待补：官方文档链接）`
  → `**出处**：业界通行实践/公开报道综合（子代理结构化返回，原始出处待补，不瞎编）`
- 文末 `:176` 既有「待补项汇总」后追加 1 行「task-v075 P5 出处待补登记」，汇总登记上述两条（注明不可核→已泛化，不编造来源）

**M-03 9 关键词保全**：M-03 断言 grep 的是 9 条「方法名」关键词（Poka-Yoke/FMEA/checkpoint/三级引用/交叉验证/去 AI 化/五维评分卡/8 字段/chunk），出处行改写不含任何方法名关键词 → 实测 33 ≥ 9，PASS。9 方法名关键词（Q4「五维评分卡」/Q5「8 字段」等）原文未动。

## 最终验证（两 S 完成后统一跑）
- `bash -n lib/verify.sh` → SYNTAX_OK
- `bash scripts/selftest-methodology.sh` → `Total: 11 PASS=11 FAIL=0`（M-01..M-11 全 PASS）
- `TASK_PLANNER_ROOT=$(pwd) bash lib/verify.sh` 全量 → `[verify] summary: 26 pass / 0 fail`，RC=0，且输出含 `✓ selftest-methodology.sh exists and is executable` 行（S1 生效实证）
- worktree git status：仅 2 文件 M（lib/verify.sh +6/-1, methodology.md +4/-2），无其他改动
- **负结果检查**：检查了 dependency 链——selftest-methodology.sh（守护方，权限/Total 行/M-03 关键词集）与 verify.sh（消费方，循环列表/§9 注释/头 Checks 清单），未发现冲突；verify.sh 内 selftest 遍历仅 §9 一处（grep 实证），无第二遍历处需补。
