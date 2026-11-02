<!-- template_type: l0-lite -->
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

> l0-lite：写此 stub 后直接改目标文件；免 VC≥2 表 / 3-File 回填 / G-gates / 归档，可随时补跑 `check-complete` 兜底；≥3 文件 / 多模块 / 新脚本 → 回落 standard 全量模板。
