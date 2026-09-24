# Verification Contract & Phase Gates

## Goal (1 sentence)

按用户确认的选项 1+2：Rule 39 族追加 39.7（动态激活边界 + 禁自建副本 P0 锚 + matcher 观察扩展）并扩围 PreToolUse matcher（ZCode 运行位 cli config.json + 仓内 pretooluse 观察分支 + register-hooks 同步），零新 config 键、三位部署。

---

## Verification Contract (逐条终验)

- [x] VC-1: critical-rules.md 含 39.7 三子条（39.7.1 系统链路闭环 / 39.7.2 禁自建副本 / 39.7.3 matcher 观察扩展）+ 39.5 尾观察面注记
  Evidence: `grep -c '39\.7' references/critical-rules.md` = 5（L360 注记 + L362 头 + L363/364/365 三子条）；master 复核通过
- [x] VC-2: zcode-pretooluse.sh 对 workflow 四工具仅观察（exit 0），Write/Edit/Agent 既有分支零改动
  Evidence: L80-87 观察分支（`CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet)` case + [workflow-observe] 提醒）；模拟 stdin 三工具 rc=0；printf 格式符缺陷已修（文案改 ${tool} 插值）
- [x] VC-3: register-hooks-cj.ts PreToolUse matcher 含 workflow 四工具（command 保持 check-scope.sh 不变）
  Evidence: L129 `matcher: 'Write|Edit|CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet'` + L125-128 注释注记
- [x] VC-4: ~/.zcode/cli/config.json PreToolUse matcher=7 工具名
  Evidence: `jq '.hooks.events.PreToolUse[0].matcher'` 输出 `Write|Edit|Agent|CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet`（P0 基础设施，用户 09-25 显式授权「1，2」；备份链=改动前 cp .bak-v090 后删=经 jq 验证后清理）
- [x] VC-5: selftest WF-13..16 PASS（仓侧 Total 16 PASS=16 FAIL=0）
  Evidence: `bash scripts/selftest-workflow-orchestration.sh`（master）→ WF-13/14/15/16 全 PASS，Total: 16 PASS=16 FAIL=0
- [x] VC-6: worktree 全量 27 selftest 回归 0 FAIL（457/0，基线 453 + 新增 4）
  Evidence: 主仓 master 全量求和 PASS=457 FAIL=0（27 脚本）；worktree 内执行时同口径 457/0
- [x] VC-7: 三位部署 diff=0 + 部署位 selftest
  Evidence: 4 文件（critical-rules/pretooluse/register-hooks/selftest-wf）×3 位定向 cp 后逐文件 `diff -q` 全空；部署位 wf selftest 15/16——**唯一 FAIL=WF-10（部署位 `SKILL_ROOT/../../` 上跳不可达，命中 3<6），属 v089 审查报告 ⑤ 已登记的已知非鲁棒项**，本次不扩围（避免超范围改 4 selftest 上跳解析），如实登记遗留；WF-13..16 部署位全 PASS

---

## 委派统计复验（Rule 25.4）

P1-P4 全主进程直做：P1/P3/P4=② 计划簿记+③ 机械验证（白名单②③）；P2=④ 用户显式授权（改 cli config.json 属 P0 基础设施，用户 09-25「1，2」逐字授权）。委派率 0 → 全理由命中 25.3 白名单 → **WHITELIST-EXEMPT**。

## 质量门控统计（Rule 26）
- Q1-Q6 触发 0 项，豁免 0 项，未处置 0 项
- Evidence 抽查 ≥3 条：VC-4 jq 输出 / VC-5 Total 16 / VC-7 diff 全空，均可复现

## Goal Gate (终验)

```
## Goal Verification — 选项 1+2 落地
- [x] VC-1: 39.7 三子条在位（grep 命中 5）→ PASS
- [x] VC-2: pretooluse 观察分支 exit 0（模拟三工具）→ PASS
- [x] VC-3: register-hooks matcher 扩围 → PASS
- [x] VC-4: cli config.json matcher=7 工具 → PASS
- [x] VC-5: WF-13..16 PASS（Total 16）→ PASS
- [x] VC-6: 全量 457/0 → PASS
- [x] VC-7: 部署 diff=0；部署位 15/16（WF-10 已知遗留）→ PASS（含遗留登记）

 outcome: PARTIAL
 遗留（不阻断交付，均已登记）：
  1. WF-10 部署位上跳路径非鲁棒（3<6）——v089 审查报告 ⑤ 同型登记；修复=单独任务
  2. printf 文案教训已沉淀 progress Error Log（${tool} 插值范式）
```
