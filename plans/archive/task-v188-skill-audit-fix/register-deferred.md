# 不动项登记（task-v188 技能审计修复）

> 本轮 skill-fix 审计发现中，以下 4 项**不在本轮修复范围**（P0 基础设施 / 范围外 / 需用户决策），登记备查。
> 其余 P1 引用一致性 + P1 硬编码路径 + P2 文档卫生已修复（见 task_plan.md 批次 1-3）。

---

## 1. [P0/BLOCKED] F1 — bun 缺失致 task-planner 工作流第一步不可运行

- **标准**: S74（运行时实证）+ S2（I/O 契约）
- **现状**:
  - `scripts/session-catchup.ts:1` `#!/usr/bin/env bun`（274 行，sha256=3ade7fb1）
  - `SKILL.md:40` 指引「运行 `bun scripts/session-catchup.ts` 检测中断恢复点」
  - `register-hooks-cj.ts:1` 同 bun shebang（install.sh:164 有降级，影响小）
  - `sync-ide-folders.ts:1` 用 `npx ts-node`（ts-node 亦缺失）
  - 实测 `command -v bun` 无输出；`command -v node` → v22.22.0 可用
- **本任务不动理由**: 属**运行时基础设施决策**（装 bun vs 改 node vs bash 降级），非文本面修复；用户指令「修正以上发现的问题」未含基础设施变更授权（§五 安全底线：运行环境变更需显式确认）。
- **需要的决策**:
  - ① 目标部署机若有 bun → 登记「安装 bun」为前提，判 BLOCKED 是环境级；
  - ② 否则把 3 个 .ts 改写为 `#!/usr/bin/env node` + 类型剥离（node v22 普遍可用）；
  - ③ 或提供 bash 等价降级路径（SKILL.md:40 改「bun 可用则跑，缺失降级 5Q Reboot 读三文件」）。
- **影响面**: task-planner 初始化第一步（跨会话中断恢复点检测）不可运行；install.sh 已有部分降级但不覆盖 session-catchup。
- **修复方向**: 决策后按 skill-fix 阶段 3 实施（改写脚本 + 更新 SKILL.md 指引 + 跑 cross_caller_aligner.ts 扫引用面）。

---

## 2. [P1] F5 — .claude 与 .zcode 平台路径混用（非纯示例）

- **标准**: S75 D3（平台一致性）
- **现状**:
  - `SKILL.md:47` 正文把平台路径写进可执行指引（`~/.claude/...` / `~/.zcode/...` 混用）
  - `init-session.sh` 平台覆盖与正文口径矛盾
  - `install.sh` / `plan-doctor.sh` / `smart-merge-back.sh` 双平台探测属**合理多工具部署设计**（有 .backup/claude-stub 佐证）
- **本任务不动理由**: 双平台探测是多工具部署模型的合理设计（非缺陷）；仅「正文可执行指引混用 + init-session.sh 口径矛盾」需修，但涉及**部署位基础设施**（§十一 11.1 命中：修改运行中基础设施），需用户显式授权。
- **需要的决策**: 是否统一平台口径（正文改 `${TASK_PLANNER_ROOT}` + init-session.sh 双平台探测对齐 SKILL.md:43）。
- **影响面**: 仅 SKILL.md 正文指引 + init-session.sh 平台覆盖逻辑；不影响已验证的 install.sh 双平台探测。
- **修复方向**: 决策后改 SKILL.md:47 正文为 `${TASK_PLANNER_ROOT}` 通用形式 + init-session.sh 双平台分支对齐。

---

## 3. [P1] F11 — task-planner I/O 契约无 JSON Schema + verify_io

- **标准**: S67（I/O JSON Schema）
- **现状**: `SKILL.md:201-203`「## I/O 契约」为纯文本（7 文件产出契约 + check-complete 输入/输出），无机器可校验的 JSON Schema 断言。
- **本任务不动理由**: 补 JSON Schema + verify_io 断言属**新增机器校验层**（诊断报告标 P1 但建议「或登记为已知缺口」）；本轮聚焦引用一致性 + 硬编码路径 + 文档卫生（P1/P2 文本面），未含 I/O Schema 化授权。
- **需要的决策**: 是否补 JSON Schema + verify_io（成本：7 文件契约 + check-complete 各配 schema + verify_io 断言脚本）。
- **影响面**: 无（仅缺机器校验层，I/O 契约三要素 Input/Output/Example 已齐 ✓）。
- **修复方向**: 决策后为「7 文件产出契约」和「check-complete 输入/输出」配 JSON Schema + verify_io 断言。

---

## 4. [P1] S76 — todo-skill cli_todo-manager.ts writeFileSync 非原子 + 固定 store.json 无锁

- **标准**: S76（并行安全）
- **现状**: todo-skill 的 `cli_todo-manager.ts` 用 `writeFileSync`（非原子写，ENOSPC 非原子写可截断为 0 字节，见 2026-10-03 实证）；固定 `store.json` 无锁，并行子代理同时写有竞争风险。
- **本任务不动理由**: 涉及 todo-skill（独立技能）的**运行时代码修改** + 并发锁机制设计（范围外：本轮审计对象是 task-planner 卫星族，todo-skill 独立）；非文本面修复。
- **需要的决策**: 是否对 todo-skill 做原子写改造（write→tmp+rename）+ store.json 加锁（flock 或串行队列）。
- **影响面**: todo-skill 并行写入安全性；不影响 task-planner 卫星族。
- **修复方向**: 决策后改 cli_todo-manager.ts 原子写 + store.json 加锁。

---

## 登记说明

- 本登记为**只读备查**，本轮不做任何修改。
- 4 项均可在后续独立任务中按「决策 → 实施 → 验证」流程处理。
- 若用户后续授权修复，按 skill-fix 阶段 2（确认）→ 阶段 3（实施）流程执行。
