<!-- template_type: l0-lite -->
<!-- template_meta: {"type": "l0-lite", "name": "L0 极简小改", "summary": "极简豁免档：单文件小改/纯文本增删/条款插入（≤2 文件且≤15min），仅 Goal 加 VC 加 scope。", "scenarios": ["单文件小改", "纯文本增删", "条款插入/增改", "简单修复", "就改一处"], "features": ["Goal 一句话", "VC-1 单行验收", "执行范围限制", "最小区块白名单"]} -->
<!-- JSON 模板源(task-json-template-20261125)：skills/task-planner/templates/json/l0-lite.template.json — 本 MD 为教学/临时视图；权威源=plan-state.json 的 template_doc/template_checks；勾选请用 planctl set --section template_checks ... -->
<!-- plan_tier: mini -->
<!-- 适用场景：单文件小改 / 纯文本增删 / 条款插入（≤2 文件 ∧ 预估 ≤15min ∧ 单模块）——极简豁免档（Rule 38.7 L0-T 落地）；中/重/多文件/新脚本/跨模块禁用本档 -->
<!-- 触发词面：轻量 / 单文件 / 纯文本 / 就改一处 / 加一条 / 插入一条 / 条款增改 / 简单修复 -->
<!-- 38.3 最小白名单：仅 Goal + 目标文件 + 一行 VC-1 + 一行 scope；其余仪式区块（VC≥2 表 / 3-File 回填 / G-gates / FMEA / 知识储备 / 委派统计 / 归档）全部豁免 -->
<!-- Why：写本 stub 本身永不被拦（plans/ 双门白名单）；stub 落盘后 check-scope D10 mtime 仲裁（task_plan.md 晚于哨兵 created_epoch）+ check-delegation ④b mini 通道（grep 命中 `plan_tier: mini`）双门放行受管文件 ≤30 行，零新脚本、零 attest -->

# Task Plan: [单文件小改任务名]

## Goal
[一句话：改哪个文件 + 加/改什么]（预估 ≤15min）

## ✅ Verification Contract
| VC-1 | 目标文本已落盘（可观察：grep/Read 命中该行） | grep / Read | [目标文件:行 / 输出形态] |

## ⚠️ 执行范围限制
| 改什么（≤2） | 禁碰什么 |
| [目标文件] | [禁改范围 / 禁改文件] |

<!-- [task-perf-default-mini 2026-11-24] What: l0-lite 回落阈值对齐 mini-lite ≤5 文件；Why: >2≤5 的纯文档走 mini-lite，l0-lite 仅保留单文件极简档，避免两档重叠。 -->
> l0-lite：写此 stub 后直接改目标文件；免 VC≥2 表 / 3-File 回填 / G-gates / 归档，可随时补跑 `check-complete` 兜底；多模块 / 新脚本 / >5 文件 → 回落 standard 全量模板。

## 🧩 输出示例与格式契约（Rule 113 · 极简档）
> **展示义务（Rule 113.10 · 项目级强制）**：先向用户展示至少一个完整产出示例实物（真实路径/可读代码块 + 同结构占位模板 + 审查命令与预期输出），再写条款；权威形态=`examples/json-template-upgrade/review.md`；禁仅标题 token。
> 本档至少 1 条：完整示例 + 同结构模板（字段可最小化，但结构必须真实可模仿）。

- 交付物 / 格式：article.json / JSON
- 完整示例：`{"title":"示例标题","count":3}`
- 可复用模板：`{"title":"<TITLE>","count":<INT>}`
- 对应 VC：VC-1
