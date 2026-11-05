# 03 轻技能 frontmatter lint（主进程兜底，provider 连拒 frontmatter-linter/Simple Agent）
生成：2026-11-05 · 机械工具=skill-fix validate_skill + detect_drift（bun 1.4.0）· 只读
## 结论
8 技能全部 validate valid=true；name=目录名 全对；无 P0/P1；drift_issues 统一=2（config_not_externalized 系统性项，P2）
## frontmatter 现状矩阵
| skill | valid | model | agent | 显式P0行 | 判定 |
|---|---|---|---|---|---|
| context-corrector | true | haiku | (未配) | 无 | P2 |
| error-fix-prompt-forge | true | (未配) | (未配) | L65 | P2 |
| iterative-optimizer | true | (未配) | (未配) | L78 | P2 |
| plan-collab-router | true | (未配) | (未配) | 无 | P2 |
| plan-cost-guard | true | (未配) | (未配) | 无 | P2 |
| plan-research-router | true | (未配) | (未配) | 无 | P2 |
| plan-template-kit | true | (未配) | (未配) | 无 | P2 |
| task-drift-guard | true | haiku | (未配) | 无 | P2 |
## 说明
- model 未配=走宿主默认（ZCode skill frontmatter 非强制 model，非缺陷）；context-corrector/task-drift-guard 配 haiku
- 建议（P2，非强制）：统一决定是否给轻技能配 model 口径；P0 铁律缺显式行的 5 个可在头部补一行 P0 定位（S18）
