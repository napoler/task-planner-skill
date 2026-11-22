<!-- template_type: l0-lite -->
<!-- plan_tier: mini -->

# Task Plan: Agent 失败会话级留痕收尾（编号冲突修正 + 合并同步）

## Goal
修正 SKILL.md 新增规则 `2.5d Agent 失败会话级留痕` 与既有 `2.5d 变更类型判定（Rule 74）` 的编号冲突（改编号→`2.5e`），随后 commit/合并回 master/同步部署位（预估 ≤15min 收尾）

## ✅ Verification Contract
| VC-1 | SKILL.md 2.5 系列编号唯一（无重复 2.5d，新增规则为 2.5e） | grep | `grep -nE '2\.5[a-z]' skills/task-planner/SKILL.md` 无重号 |
| VC-2 | selftest 零新增 FAIL | bash | 104 PASS=104 FAIL=0（已实测） |
| VC-3 | 改动合并回 master + 部署位 diff=0 | git/diff | 见交付报告 |

## ⚠️ 执行范围限制
| 改什么（≤2） | 禁碰什么 |
| skills/task-planner/SKILL.md（仅编号 2.5d→2.5e） | 禁改既有 Rule 74 条款正文 / 禁改其他规则 / 禁碰保护区 / 禁碰 96.7 委派门与 planctl |

> l0-lite：写此 stub 后仅做编号修正 + git 收尾；零新脚本、零 attest。用户裁决已授权本任务全部改动（保留子代理与 CLI 机制，agent 失败写会话级 ledger 而非 memory）。
