# 检查点 12 / executor（原派 code-runner-agent 遭 Provider 拒绝，Rule 22.3③ 升档改派，主进程已登记兜底）/ S12 check-drift 行为级回归用例补写

status: complete
commit: 8b3bab0 (wt/task-v092-guard-quirk-fixes, 基线 e5a402d)

## 执行记录
1. 读 worktree 现状：check-drift.sh（3a 初值 `local prev_status="none"` 实证在 :132）、selftest-check-conflicts.sh 骨架（ok/bad/diag + `Total: %d PASS=%d FAIL=%d` + `exit $((FAIL>0))`）、lib/plan-parse.sh 列限语义、selftest-registry.tsv/.sh 机制（T02 新增未登记→FAIL ⇒ 必须登记）
2. 读主仓 findings.md S2/S8/S9 节取夹具与修复语义（fixture-a/c/b/d 序列、t1/t2/t5/t4 形态）
3. 新建 skills/task-planner/scripts/selftest-check-drift.sh（+155 行，6 用例正反双向，/tmp mktemp 唯一夹具 + trap 清理，CD_TARGET 环境变量支持负向验证指向副本）
4. registry 登记行插入 selftest-registry.tsv 自登记末行之前（awk NF=4 核验）
5. 实跑：6/6 PASS（`Total: 6 PASS=6 FAIL=0`）exit 0；bash -n 通过
6. 负向验证：/tmp 副本（含 lib/）:132 初值 sed 还原为 "pending" → CD_TARGET 指副本 → CD-01/02/05 转红（CRITICAL PHASE-SKIP 误报复现 drift_score=3 rc=1）、CD-03/04/06 保持绿、Total: 6 PASS=3 FAIL=3 NEG-EXIT=1 ⇒ 非恒真得证；副本已清理，本体 grep 复核仍 "none"、复跑 6/6 PASS
7. registry 对账：selftest-registry.sh T01-T05 全 PASS（rows=33/actual=33）
8. 提交 8b3bab0：diff HEAD~1 --stat 仅 selftest-check-drift.sh(+155) + selftest-registry.tsv(+1)，worktree status 干净
9. 回写主仓 findings.md「### S12 修复记录」+ progress.md 新建 Phase 5 段（含改派兜底注记）

## 用例清单（结果全 PASS）
- CD-01 3a 正向：全 complete → 零 PHASE-SKIP + INFO PHASE-ORDER + rc=0
- CD-02 3a 正向：complete,in_progress,pending（S8 缺陷面）→ 同上 rc=0
- CD-03 3a 反向：pending,complete,pending 真越级 → CRITICAL PHASE-SKIP 恰 1 条 + rc=1
- CD-04 3b 正向：三列表越权+禁止列文件均报 BREACH（forbidden/secret.py, hack/evil.py）且允许列 src/main.py 不误报 rc=1
- CD-05 3b 负向：无范围表 → SCOPE-NONE rc=0（fail-open 保持）
- CD-06 两列表越权 → BREACH 含 hack/evil.py rc=1

## 开发期缺陷（已修，调试 2 轮内）
- CD-02/CD-03 两处 mk_case 调用漏传第 5 参 scope → `set -u` 下 `$6: unbound variable`，各补 `"-"` 即修

## 勘误登记（已写入 findings S12 节）
- 初值行 :122（S2/S8 记载）现位于 **:132**：S8 +4 注记（→:126）+ S9 头部设施 +6 行（→:132），后续引用以 :132 为准

## 负结果/排除项
- 未修改 check-drift.sh / lib/plan-parse.sh / 其他任何脚本（diff 仅两文件实证）
- 未触碰主仓 skills/**、其他 worktree、task_plan.md（状态回写归主进程）
- CD-05 在负向验证中连带转红属预期（其夹具用 complete 相位，还原缺陷经 rc 断言显形），非用例缺陷
- probe-e（pending,pending,complete）与 CD-03 同判定路径，未重复设案（findings S8 已有证据）
