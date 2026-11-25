# 升级模板 → JSON 原生模板：产出实物与审查清单

> 本目录回答两个问题：**产出的模板长什么样**、**后期如何审查**。
> 证据采集：2026-11-25，worktree `wt/task-json-template-recommend-20261125`（基点 master `6053d885`）。
> 实物来源：仓库既有权威产物，**未虚构、未改写生产模板**；生产 JSON 为单行压缩，本目录的 `upgraded/*.template.json` 是同一对象的 pretty-print（`json.load` 语义等价已实测），仅用于人读审查。

## 1. 实物清单（可直接打开看）

| 文件 | 作用 | 来源 |
|---|---|---|
| `original/rule-clause-cascade-type.md` | 项目级 MD 模板（升级对象） | `.zcode/plan-templates/rule-clause-cascade-type.md` 逐字节复制 |
| `upgraded/rule-clause-cascade.template.json` | 升级后的 JSON 权威源（pretty-print） | `skills/task-planner/templates/json/rule-clause-cascade.template.json` 的语义等价可读版 |
| `upgraded/rule-clause-cascade-type.md` | 同步后的 MD 教学视图 | 同上 MD 逐字节复制（升级改变的是权威源，MD 正文骨架不变） |
| `original/research-type.md` / `upgraded/research-type.md` | 含勾选条目的 MD 教学视图 | `skills/task-planner/templates/variant/research-type.md` 逐字节复制 |
| `upgraded/research.template.json` | 含 checklist 的 JSON 权威源（pretty-print） | `skills/task-planner/templates/json/research.template.json` 语义等价可读版 |
| `review.md` | 本文件：逐字段对照 + 审查命令 + 实际输出 | 本次采集 |

## 2. 产出模板长什么样（字段级对照，以 rule-clause-cascade 为例）

| 层级 | 字段 | 实际值 / 形态 | 审查要点 |
|---|---|---|---|
| 顶层 | `schema_version` | `1` | 必须为 1，`planctl init --template-json` 拒其他值 |
| `meta` | `template_type` | `rule-clause-cascade` | 必须与 MD 机读头 `<!-- template_type: ... -->` 同值 |
| `meta` | `name` / `summary` | 中文可读名 / 一句摘要 | 选型清单的展示面 |
| `meta` | `scenarios[]` | 5 项（规则增款/条款修订/纪律域级联同步/Rule 编号增补·子条插段/卫星路由与计数联动） | 缺口判定依据：JSON 已有但场景不覆盖 → 适配版候选 |
| `meta` | `features[]` | Goal / VC 表（≥2）/ Phase 骨架 / 执行范围限制 / 必要知识储备 | 与 MD 的 `##` 区块一一对应 |
| `meta.lineage` | `level` / `parent` / `base` / `spec_version` / `pruned` / `pruned_reason` | `derived` / `../task_plan.md` / `../task_plan.md` / `1` / `[]` / `""` | derived 必含 parent+base；裁剪须登记在 `pruned` |
| `sections[]` | `id` / `anchor` / `level` / `kind` / `required` | 5 段：`sec-goal`/`sec-vc`/`sec-phases`/`sec-scope-limits`/`sec-knowledge` | id 全模板唯一；anchor 即 MD `##` 标题 |
| `kind=ref` | `ref.path` + `ref.renderer` | `goals→goal_statement`、`vcs→vc_table`、`phases→phases_table`、`scope_limits→scope_limits_table` | **复用核心渲染器**，机器锚不漂移；模板侧不得自带同形锚 |
| `kind=blocks` | `blocks[].kind` / `text` | `note`（markdown）承载必要知识源清单，与 MD `:38-40` 逐字同源 | 勾选/表格用 `checklist`/`table`，禁只在 MD 写 `- [ ]` |

**原始 MD → 产出的差异**：MD 仍是 40 行教学视图（机读头 + `## Goal`/`## VC 表（≥2）`/`## Phase 骨架`/`## 执行范围限制`/`## 必要知识储备` + JSON 指针注）；新增的是 JSON 权威源，`plan-state.json` 从此只写 `template_ref`/`template_doc`/`template_checks`，**不再写 `template_body`**（避免整份 MD 读入 JSON 再吐出的无意义 roundtrip）。

## 3. 消费后的渲染实物（截取 `task_plan.md:57-68`，standard 档 research 模板）

```
## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|---|---|---|---|---|
| 规范/标准 |  |  | 必读/参考 | ☐ |
...
- [x] 规范/标准 · 已确认        ← planctl set --field checked 改 JSON 后 render 得到
- [ ] 官方文档 · 已确认
```

`plan-state.json`：`template_ref = skills/task-planner/templates/json/research.template.json`，`template_checks[]` 共 6 条，首条 `{"id":"KN-规范标准已确","checked":true}`；无 `template_body`。

## 4. 审查命令与判据（8 条，全部实跑；证据为本次真实输出）

| # | 命令 | 预期 | 实测输出 |
|---|---|---|---|
| C1 | `python3 -m json.tool upgraded/research.template.json >/dev/null` | exit 0 | `PASS C1: valid JSON` |
| C2 | `grep -nF 'template_type' upgraded/research-type.md` + `json.load(...).meta.template_type` | 两者同值 | MD `5:<!-- template_type: research -->`；JSON `research` |
| C3 | `template-catalog.sh list --json --scope all` 过滤 `type=research` | `source=json` 且 `preferred=true` | `[('json', True, '.../research.template.json'), ('legacy', False, '.../research-type.md')]` |
| C4 | `TASK_PLAN_TIER=standard TASK_TEMPLATE_TYPE=research bash init-session.sh exhibit-std` | 路由到 JSON；`plan-state.json` 含 template_ref/doc/checks、无 template_body | `Template routing: JSON 权威模板 <- json/research.template.json`；`plan-state.json initialized (JSON mode)`；checks=6 |
| C5 | `planctl.py set --section template_checks --id 'KN-规范标准已确' --field checked --value true` + `render` + `grep -F -- '- [x] 规范/标准 · 已确认' task_plan.md` | 命中渲染行 | `rendered: [...4 files]`；渲染视图出现 `- [x] 规范/标准 · 已确认` |
| C6 | 只手改 MD：`- [ ] 官方文档 · 已确认` → `- [x] ...`，再跑 `check-state-consistency.sh <plan-dir>` | **FAIL**（负控制） | `[state-mismatch] S-3 check KN-官方文档已确: JSON checked=0 但 task_plan.md 勾态=[x]`；`rc=1` |
| C7 | `planctl.py render` 回正后重跑同门 | PASS | `[state-consistency] PASS`；`rc=0` |
| C8 | `check-template-type.sh <plan-dir>/task_plan.md` | exit 0 | `[template-gate] OK: template_type=research`；`rc=0` |

**PASS 标准**：8 条全部得到上表输出。任一不符即不得进入条款归纳阶段。

## 5. 已知边界（审查时必须知道，避免误判）

- **默认 mini 档会改选 `mini-lite.template.json`**：不显式给 `TASK_PLAN_TIER=standard` 时，`init-session.sh` 按 Rule 38 默认 mini 并把 JSON 权威源切到 mini-lite，`template_checks` 为空（实测 `template_ref=.../mini-lite.template.json`，checks=0）。因此审查勾选往返**必须**按 C4 显式 `TASK_PLAN_TIER=standard`；这不是缺陷，是轻量档既有语义。
- 生产 JSON 模板保持单行压缩，本目录的 pretty-print 仅为审查视图；二者必须 `json.load` 语义等价（已实测）。
- `rule-clause-cascade` 模板无 `checklist` block，勾选往返用同为生产模板的 `research` 演示；机制相同（`template_checks` 扁平条目 + JSON 权威勾选）。

## 6. 后期审查流程（固定动作）

1. 打开 `upgraded/*.template.json`（已 pretty-print），按 §2 字段表逐行核对。
2. 跑 §4 的 C1–C8，逐条比对输出；C6 必须 FAIL、其余必须 PASS。
3. 任何条款/脚本改动后，重跑 C1–C8 + `selftest-template-json.sh` 的 TJ-09/TJ-10；示例实物与条款锚不一致即视为回归。
