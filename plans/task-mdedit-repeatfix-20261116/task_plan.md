<!-- template_type: l0-lite -->
<!-- plan_tier: mini -->
<!-- 38.3 最小白名单豁免档（Rule 38.7 L0-T）：2 文件（hook 脚本+SKILL.md）∧ ≤15min；免 attest/免 3-File 全量回填/免委派统计 floor（mini→0.0）；check-scope D10 + check-delegation ④b 双门放行 -->

# Task Plan: md-edit-ops 触发条件修正——同文件重复编辑计数触发

## Goal
修正 hook advisory 触发判据：新增「会话内同一 .md 文件第 2 次起编辑」计数触发（用户判例=逐处单行小改致行号/锚点漂移改错，单次体量判据漏掉该模式），并同步 md-edit-ops SKILL.md「何时不用」条款（预估 ≤15min）。

## ✅ Verification Contract
| VC-1 | 同文件第 2/3 次单行 Edit 触发漂移提醒（含次数），第 1 次静默；跨文件计数独立；Write 重置基线；plans/ 豁免不变；大编辑原提醒路径不回归 | 模拟 JSON→运行位脚本，逐例 exit+输出 grep |
| VC-2 | SKILL.md「何时不用」含同文件连续小改漂移条款 | grep md-edit-ops/SKILL.md |

## ⚠️ 执行范围限制
| 改什么（≤2） | 禁碰什么 |
| worktree skills/task-planner/scripts/zcode-pretooluse.sh（advisory 块内纯增量 ≤20 行）；worktree skills/md-edit-ops/SKILL.md（1 行） | 既有阻断/委派逻辑；其他任何文件；部署位直接写（部署走对账复制） |

## 📝 Decisions Made
| 触发设计=会话内计数器（/tmp/task-planner-mdedit-count-<sid>/<path-hash>.count；Write 重置=新基线；jq 失败 fail-open 默认 seq=1） | 真实风险单元=同文件编辑序列（行号/锚点漂移），非单次体量；计数器是 hook 无状态下最小编程面（warn-count 先例） |
| 指引措辞=「合并为一次 md-edit-ops 指令单提交」 | 一次改三处场景的正解=指令单对当前内容统一预校验+原子提交 |
| 免 attest/免 plan-writer 委派（mini 豁免档） | Rule 38.6/38.7 比例原则；l0-lite 先例（task-l0lite-exempt-20261103） |

## 🎯 用户需求原文（R 锚）
> 单行改动仍然都用 Edit…它多次Edit这个文件之后就改错了…一次性对这个文件改三处，第一行…第二次还是按第二行或者第三行…第一行改动之后可能变成四行，然后但是再改第二行，然后就出现了错误。（逐字锚=user-session-log.md #1）
