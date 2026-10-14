---
name: verification-gate
description: 任务验证全链路唯一权威域——创建任务时把 VC（Verification Contract）设计成可执行验证命令、执行期 V-N 逐项校验、终验 VC 逐条复验。当创建/更新 task_plan.md 的 VC 表、Phase 标记 complete 前校验 V-N、执行终验交付复验、子代理返回 done 需 Read 复核时触发。也适用于：用户要求"验证规则/验证脚本/可验证性/所有产出都要验证"、VC 条目缺可执行命令需回炉、需要机器强制验证覆盖的场景。task-planner 第 11 卫星（Rule 82 分层）。
model: haiku
---

# Verification Gate — 任务验证全链路卫星

任务验证域独立技能（task-planner 第 11 卫星，Rule 84 建制）。把「验证」从主技能罗盘管理中解耦为独立域：**规则/模板/SOP 在本卫星**，主技能各执行步骤显式引用本卫星。

## 定位：验证全链路唯一权威

本卫星管任务验证的**三个阶段**，覆盖「所有产出以及执行都有验证」的闭环：

| 阶段 | 时点 | 职责 |
|------|------|------|
| ① 计划期 VC 设计 | 创建/更新 task_plan.md 的 VC 表时 | VC 可执行化——每条 VC 必须带可运行验证命令（Rule 84.1） |
| ② 执行期 V-N 校验 | Phase 标记 complete 前 | Phase Gates 的 V-N 逐项校验 + 子代理产出 Read 复核（Rule 84.4） |
| ③ 终验 VC 复验 | 全 Phase complete 后交付前 | 逐条跑 VC 命令/查证据，出 COMPLETE/PARTIAL/BLOCKED（Rule 84.5） |

**与主技能边界**（Rule 82 禁镜像）：主技能 task-planner 只管四文件罗盘（计划制作+记录文档管理）；verification.md 契约的**设计规则与终验 SOP 全文在本卫星**，主技能 SKILL.md 只留指针。

## 调用时机（命中任一即调用）

1. 创建/更新 task_plan.md 的 Verification Contract（VC 表）时——plan 制作循环步骤
2. Phase 标记 complete 前校验 V-N（Phase Gates）时
3. 终验交付阶段复验 VC 时（主技能「终验交付」步骤入口）
4. 子代理返回 "done" 需 Read 实际产出复核时（Rule 84.4）
5. 用户要求"验证规则/验证脚本/可验证性/所有产出都要验证"时
6. attest-plan.sh 校验 VC 可执行性门失败回炉时

## 执行步骤

### Step 1: VC 设计（计划期）

1. 打开/编辑 `templates/verification.md`（本卫星模板），填写 VC 表
2. **每条 VC 必填三要素**（Rule 84.1 可执行性纪律）：
   - 验证命令：可运行的 bash 命令（如 `bash scripts/check-x.sh <plan>`）或路径+关键行（如 `grep -c 'Rule 84' file.md`）
   - 判据：命令输出的 PASS/FAIL 判定标准
   - 证据落点：verification.md 对应 VC 的 Evidence 字段
3. VC 条数：standard ≥5 / mini ≥2 / L0 ≥1（沿用 goal-gate 规则）
4. VC 设计完成 → attest-plan.sh 的 VC 可执行性门自动校验（缺命令=拒锁回炉）

### Step 2: V-N 校验（执行期，Phase complete 前）

1. Read verification.md 当前 Phase 段的 V-N 项
2. 逐项执行验证命令，确认 PASS
3. V-N 未全 PASS → 禁止 Phase 翻 complete（goal-gate 规则 3）
4. 子代理产出：Read 实际文件复核（不信任 "done" 自报）后才勾 Handoff verify_done
5. 回填门控：`bash <skill>/scripts/check-3file-gate.sh <plan-dir>` exit 0 才可翻转

### Step 3: VC 复验（终验期，交付前）

1. Read verification.md 的 Goal Gate 段
2. 逐条 VC 执行验证命令，对照判据出 PASS/FAIL
3. 可用统一入口：`bash <skill>/scripts/run-verification.sh <plan-dir>`（解析 VC 命令自动执行汇总）
4. 质量门控统计（Rule 26 面）+ 委派统计（Rule 25.4 面）按模板段核查
5. 出 outcome：全 VC PASS → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户
6. 终验前跑 `bash <skill>/scripts/check-complete.sh`（21 门总门，exit 0 才可交付）

## 脚本引用索引（机械层留守主技能 scripts/）

按 Rule 82「机械层留守」先例，验证相关机械脚本在主技能 `task-planner/scripts/`（hook/init/selftest 深度集成，禁迁移防断链）。本卫星按其 SOP 调用：

| 脚本 | 功能 | 调用阶段 | 路径 |
|------|------|---------|------|
| `check-3file-gate.sh` | 执行中回填门（Phase 翻 complete 前） | 执行期 | `<skill>/scripts/` |
| `attest-plan.sh` | 计划锁定聚合门（含 VC 可执行性门） | 计划期 | `<skill>/scripts/` |
| `check-complete.sh` | 终验总门（21 门：VC-GATE/R-COVERAGE/goal-gate 等） | 终验期 | `<skill>/scripts/` |
| `check-plan-dispatch.sh` | 计划期派发型 Phase S-unit 校验 | 计划期 | `<skill>/scripts/` |
| `run-verification.sh` | **本卫星**统一验证执行入口（逐条跑 VC 命令） | 终验期 | `./scripts/`（本卫星） |
| `selftest-verification-gate.sh` | **本卫星**静态守护（Rule 84 锚） | 回归 | `./scripts/`（本卫星） |

## References

| 文档 | 用途 |
|------|------|
| `references/critical-rules-verification.md` | 验证域规则全文（Rule 84.1-84.6 + 迁移的 VC 规则/子代理验证协议） |
| `templates/verification.md` | Verification Contract 模板（VC 可执行化 + Goal Gate + Phase Gates + 质量门控统计） |
| `scripts/run-verification.sh` | 统一验证执行入口（解析 verification.md VC 命令→逐条执行→PASS/FAIL 汇总） |
| 主技能引用面 | `task-planner/SKILL.md` 卫星路由表 + 计划期/执行期/终验三处步骤指针 |
