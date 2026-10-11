# 02-code-assistant 检查点（P2 S1+S2：check-plan-dispatch.sh S-unit 数值门控 + selftest）

## 里程碑
- [x] ① 已读输入：task_plan.md（P2 段+KQ1）/ findings.md（Research A 节）/ check-plan-dispatch.sh 全文（139 行）/ selftest-plan-dispatch.sh 全文（137 行）/ config.json（step_max_* 键确认）/ attest-plan.sh:80-97（tcfg jq 范式参照）
- [x] ② S1 落盘：check-plan-dispatch.sh 增 S-unit 数值门控（文件头 KQ1 口径注释 + STEP_MAX_MIN/STEP_MAX_FILES jq 解析回退段 + ⑤-b 数据行逐行校验）
  - 关键实现点：① 时长 $7 须 ^[0-9]+min$ 且 ≤15（超限记违规）；② 输入 $5 路径 token 计数 ≤2；③ 时长不可解析/空 → 打印 `[plan-dispatch] SKIPPED Phase N S<n> 时长不可解析` 不阻断；④ 违规沿用 add_violation 风格 exit 1
  - 踩坑记录：`grep -c -oE` 实测忽略 -o（命中行数计=恒 1），改用 `grep -oE | wc -l` 逐 token 计数；KQ1 正则由任务书原式 `(^|[[:space:]])` 前缀形态修正为尾部锚定 `[^ ]+\.(sh|md|json|ts|js|py|cjs)`（grep -o 下前缀式会误带前导空白/分号）
  - 四夹具实测（/tmp/v075-p2-fixtures/）：16min 行 rc=1 + `✗ ... 预估时长 16min > step_max_minutes(15)`；3 路径行 rc=1 + `✗ ... 输入列 3 个文件路径 > step_max_files(2)`；空时长行 rc=0 + SKIPPED 行；全合规 rc=0 + ✓ 行。bash -n 通过
- [x] ③ S2 落盘：selftest-plan-dispatch.sh 新增 T09-T12 四断言（hermetic mktemp 夹具，沿用既有 assert 风格与末行 Total 格式），Total 8→12 只增不减
- [x] ④ 最终验证与结论
  - S1 attest 三夹具实测：16min 超限 `bash attest-plan.sh` rc=1 且输出 `✗ ... 预估时长 16min > step_max_minutes(15)` + 拒绝锁定；空时长 SKIPPED 夹具 rc=0 锁定成功（stderr 有 SKIPPED 行，另 template-gate 因夹具无 template_type 出既有 warn 档告警，与本门控无关）；全合规夹具 rc=0 锁定成功
  - S2 selftest Total 行原文：`Total: 12 PASS=12 FAIL=0`（T01-T08 既有断言行为不变，新增 T09 16min 拒绝 / T10 3 路径拒绝 / T11 空时长 SKIPPED 放行 / T12 全合规通过）
  - `bash -n` 两文件均通过；worktree 内 git status 仅 2 文件 modified（check-plan-dispatch.sh / selftest-plan-dispatch.sh），config.json 未动，未触碰主仓与其他 worktree
  - 结论：complete。偏差：KQ1 正则由任务书原式 `(^|[[:space:]])` 前缀形态修正为尾部锚定式（grep -o 口径更稳，判定语义等价）；路径 token 计数实现用 `grep -oE | wc -l` 替代 `grep -c`（grep -c 忽略 -o 实测恒 1，已在脚本注释登记）

