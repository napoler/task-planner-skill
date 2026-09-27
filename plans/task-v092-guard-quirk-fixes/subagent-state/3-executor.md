# S3 executor checkpoint（2026-09-27）

## 状态
- status: done（全部 5 步完成；findings.md/progress.md 回填为最后落盘动作）

## 已完成里程碑
1. Read findings.md S2 节（S3 备料 4 种子 + open_questions ①拆分归属）✅
2. Read lib/plan-parse.sh 全文（46 行）+ check-drift.sh:196-253 消费侧 + defect-evidence.md 缺陷3 + 3 调用方消费锚 ✅
3. /tmp 夹具 5 组对拍（t1 两列竖线收尾 / t2 三列竖线收尾含禁止列 / t3 逗号+方向1边界 / t4 无范围表 / t5 三列无尾竖线），5 提取变体（V0 原管道 / V1 lib整格 / V1tr lib+拆 / V2 lib列限i3 / V2tr 列限+拆）×5 夹具 = 25 格矩阵，全落盘 /tmp/s3-evidence/matrix.txt（216 行）✅
4. 仓内量化：38 计划中 17 个字段4+含点分内容（lib 原样会误收禁止/说明列）✅
5. mawk 交叉验证 T2（与 gawk 逐字节一致）✅；v092 真实计划 V0 空 / V1 7格(混3格禁止列) / V2 4格(=允许列本意) ✅

## 裁决结论（已写入 findings.md `### S3 接库裁决`）
**接库 + 参数扩展（可选列限参数，默认=现行为）+ 消费侧保留 tr 拆逗号**
- 消费侧需「逐条清单」（:234-240 逐行 while read + 双向 grep -qF 子串）；整格/拆逗号在常规样张判定一致，唯方向1包含场景有分歧（T3 实证）
- lib 必须补列限：T2/T5 实证禁止列反向风险（T5 整案零检出）；仓内 17/38 计划受影响面
- 可选第2参数默认空=现行为 → check-conflicts:139/:166、sync-todos 内联副本、pretooluse 语义锚三调用方零行为变化
- 状态机化替代案可行但不劣于接库案（改动面相当却保留第5处复制），不并列

## 关键证据路径
- /tmp/s3-evidence/matrix.txt（25 格判定矩阵）
- /tmp/s3-fixtures/t{1..5}-*/plans/task-x/{task_plan.md,progress.md}
- /tmp/s3-harness.sh（消费侧逐字复刻 check-drift.sh:213-245）

## Phase 3 S9 注意（详见 findings S3 节末）
列限定「仅字段3」；tr/trim/grep -v 消费侧保留；selftest 须含禁止列反向样本；check-drift.sh 无 SCRIPT_DIR 需补（参照 check-conflicts:19）
