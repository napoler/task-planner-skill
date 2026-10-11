# checkpoint — sub:15-code-quality-review（P4-S2 代码面审查）

> 任务：task-v138 全部 bash 脚本类落盘资产的代码面质量审查（只读；零仓库写入——仅 findings/progress 回填 + 本检查点）。
> **基准修正（如实登记）**：派发时 worktree 已合并回 master 并被移除（`git worktree list` 仅主仓；merge=`1992566`，其后 v136/v139 已合入）。审查改用 git 对象库 `62561a1`（worktree 末态 HEAD）为基准；已核验两目标脚本在 62561a1 与当前 master **逐字节一致**（md5 `4ae35b9dfe38926da0e00b778c2c83b3`，`git diff 62561a1..HEAD -- <两脚本>` 为空）。
> 审查对象：① `skills/task-planner/scripts/capabilities/agnes-quota.sh`（185 行）；② `skills/task-planner/scripts/selftest-capability-persistence.sh`（177 行）；③ diff `b03fd36..62561a1`（4 处纪元同步 + SKILL/executor/registry/tsv 接线）。

## 里程碑
- [x] M1 计划三文件 + knowledge-brief §4 红线 + 两脚本全文 + 任务 diff 全文读取
- [x] M2 六维审查（正确性/安全性/可移植性/注释/守卫质量/禁推算合规）
- [x] M3 实跑验证：guard（基线+负向孤本+5 组变异）；agnes-quota 退出码 2/3/4 + 主路径实跑 + 泄漏扫描 + F1 mock 复现
- [x] M4 回填 findings.md（+41 行）+ progress.md（+1 行）+ 本检查点

## 关键证据
- guard 基线: `bash skills/task-planner/scripts/selftest-capability-persistence.sh` → `Total: 18 PASS=18 FAIL=0` rc=0（仓库 cwd 与 `/` cwd 两处同）
- 负向孤本（/tmp 无树副本）: `Total: 18 PASS=2 FAIL=16` rc=1（两 PASS=CP-17/18 自检；与 sub:13 报告一致）
- 变异咬合 ×5（/tmp 镜像 @62561a1，各 rc=1）: 注入 `cpk-deadbeef0000`→CP-12 FAIL；删 `55.6` 行→CP-02 FAIL（计数=5）；SKILL `40-55`→`40-53`→CP-05/06 FAIL；删 video 接线→CP-14 FAIL；替换 SCRIPT_DIR→CP-17 FAIL
- live 主路径: human rc=0（`key_source: bashrc:export (cpk-fB...guim)`、subscription/usage 均 200、verdict=未填充）；`--json` 8 行纯 JSON，jq rc=0；真实 key 全字面在 human/JSON/stderr 三输出零泄漏
- 退出码: `--bogus` rc=2 / 无候选 rc=3 / 死代理全连接失败 rc=4
- F1 mock 复现（/tmp/v138-code-review/mock401.py，仓外）: /agnesapi→404、billing→401 → `"subscription": null` + verdict「计费层已回传数值...」+ rc=0
- 合规扫描: 无硬编码密钥（grep=0）；无绝对路径/apihub；仅计数器算术；config properties=40；tsv 末行列数=4

## 最终结论（8 字段）
status: done
acceptance: 5/6 pass — [1:FAIL 2:PASS 3:PASS 4:PASS 5:PASS 6:PASS]
files: /mnt/data/dev/task-planner-skill/plans/task-v138/findings.md (+41/-0); /mnt/data/dev/task-planner-skill/plans/task-v138/progress.md (+1/-0); /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/15-code-quality-review.md (new); /tmp/v138-code-review/（mirror+5 变异+负向+mock+输出日志，仓外测试件）
evidence: guard → "Total: 18 PASS=18 FAIL=0"(rc=0, repo & / 两 cwd); 负向孤本 → "PASS=2 FAIL=16"(rc=1); 5 变异 → CP-12/02/05+06/14/17 各 FAIL(rc=1); live → human rc=0 key_source=bashrc:export 两 200 verdict=未填充, --json jq rc=0, key 三输出零泄漏; 退出码 2/3/4 实测; mock → subscription:null + 「计费层已回传数值」rc=0（F1 锚 agnes-quota.sh:150-160/:116）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/15-code-quality-review.md (status: done)
findings_written: plans/task-v138/findings.md `#### [sub:15-code-quality-review]`（位于 ## Research Findings 段末、## Technical Decisions 之前）
blockers: F1（agnes-quota.sh 错误路径伪成功判定，可复现）为 CHANGES_REQUESTED 阻塞项——按计划 Phase 4 S2 契约，闭环前不得进 Phase 5/标 COMPLETE
confidence: HIGH
