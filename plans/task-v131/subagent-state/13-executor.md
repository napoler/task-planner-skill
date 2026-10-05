# 检查点 13-executor — task-v131 Phase 4 S-unit（selftest-root-resolution.sh 静态守护）

日期：2026-10-05
执行体：executor（单 S-unit）
worktree：/home/terry/task-planner-skill-worktrees/task-v131（HEAD=535be31，Phase 3 产物之上）

## 产出
- 新建 1 文件：`skills/task-planner/scripts/selftest-root-resolution.sh`（chmod +x；未 commit；git status 仅此一新增 untracked，未触碰其他文件）
- 15 编号用例 RR-01..RR-15，grep -cF 固定串断言，PASS/FAIL 计数 + `Total: 15 PASS=14 FAIL=1` 行（格式同构 selftest-requirement-coverage.sh / selftest-agent-coverage.sh）
- 头注释 Rule 45 四要素（What/Why/When/How）+ 断言口径注释（=1 锁唯一落点 / ≥n 锁存在性 / 负断言 =0）

## 验证证据
1. `bash -n` 语法：SYNTAX OK
2. worktree 内 `bash scripts/selftest-root-resolution.sh` 实跑：
   - RR-01..RR-13, RR-15 共 14 条 PASS
   - **RR-14 FAIL**（如实报告，不硬凑）：
     - 子锚 A「第 4 锚」=6 ≥1 通过（attest-plan.sh L13/124/145/147/151 等）
     - 子锚 B `check_requirement_block` =0，应 ≥2，**未通过**
     - 根因（第一手证据）：契约要求 attest-plan.sh 含函数字面 `check_requirement_block`（定义+调用），但 Phase 2 S-unit P2-S3 实际将锁定门实现为 `[requirement-gate]` 内联门（attest-plan.sh L137-151，字面 `[requirement-gate]` 命中 2 处，见 L139/L151 echo），全 skill 目录 `grep -rn check_requirement_block` 零命中（含 lib/）
     - 脚本 RR-14 保持契约原文断言（FAIL 即漂移证据），用例注释内已注明实际实现形态，供 verifier 二选一裁定：① 契约改断言为 `[requirement-gate]` ≥2；② 实现侧补 `check_requirement_block` 函数封装（定义+调用 ≥2）
3. 锚点计数核对（写脚本前第一手预扫，与实跑一致）：
   - critical-rules.md：53.1/53.2/53.3/唯一权威边界/53.4/三元组/53.5/51.1a 各 =1；Q7 惰性推诿=2；Q8 无根治判据=2；「或无客观判据的真实偏好二选」=0（critic P0 收口钉住，RR-15 PASS）
   - SKILL.md：Rule 53 bullet=1（L306）；C36=1（L204，行内含「根源覆盖表」）；Critical Rules 全集 1-53=1（L9）；1-51 残留=0
   - task_plan.md 🎯=1 / 🧮=1；rule-enhancement-type.md 🎯=1；subagent_dispatch.md「需求锚（Rule 51.1a」=1
   - init-session.sh：inject_requirement_block=3（L91 注释/L125 定义/L488 调用）≥2；根源覆盖表=13≥1

## 已知遗留 / 移交
- **RR-14 契约漂移**（唯一 FAIL，P1）：需 verifier/编排者裁定上列二选一；裁定后本脚本或 attest-plan.sh 对应改断言/改实现并重跑全 PASS
- registry 登记悬挂（P2）：本单元 scope 仅 1 文件，`selftest-registry.tsv` 未登记本脚本——selftest-registry.sh T02 双向核对会对新增未登记脚本 FAIL；后续 S-unit（或本单元裁定时）须补 1 行 registry 登记（范式见 selftest-agent-coverage.sh 行 L51）
- 不 commit（按契约）；worktree 干净度仅差上述 1 untracked 文件

## 恢复点
- 若 verifier 裁定改实现（补 check_requirement_block 函数）：attest-plan.sh L137-151 内联门重构为函数封装（定义 1 + 调用 1 = 2），重跑 `bash scripts/selftest-root-resolution.sh` 应 Total: 15 PASS=15 FAIL=0
- 若裁定改契约：本脚本 RR-14 子锚 B 改断言 `grep -cF '[requirement-gate]' "$ATTEST"` ≥2，重跑同上
