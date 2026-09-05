# Findings & Decisions

## Requirements
用户指令(2026-09-04):「~/.zcode/skills/task-planner/ 和 claude 的 skill 需要修,应该为软链接」——消除部署副本与 dev 仓库的漂移。

## Research Findings
- 三个真实目录副本存在:~/.zcode(2.9M)、~/.claude(2.3M)、~/.config/opencode(2.0M);用户点名前两者,opencode 未授权不动
- 两副本均为独立 git clone(zcode@65031a5 带 8 个漂移文件;claude@16696ff 带 50 个),差异方向全部为 canonical 领先(纯陈旧,无变体分叉);备份外独有内容仅 claude 的 scripts/register-hooks-cj.ts
- canonical 仓 install.sh:159-166 引用 register-hooks-cj.ts 但仓库未携带 → 直接软链会断 claude hooks 注册路径,须先收编
- .git 目录检查:仓库 skills/task-planner/.git 为空目录(git -C 无输出),软链不引入嵌套仓库问题

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| mv 保留备份而非 rm | 保护区操作兜底;副本含各自 .git 历史,保留可回溯任何潜在独有内容 |
| 主进程直做不委派 | 变更是本会话自身运行依赖(hooks/skill 加载路径),子代理操作宿主基础设施风险更高 |
| 绝对路径软链 | 跨 cwd/hook 环境解析稳定 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| cp 相对路径失败(cwd 在计划目录) | 改绝对路径重试成功 |
| check-complete 3-File Gate 拦截 findings.md stub | 本文件即回填;Rule 19.5 新门控首次实战生效 |

## Resources
- 备份:~/.zcode/skills/task-planner.bak-20260904(2.9M)、~/.claude/skills/task-planner.bak-20260904(2.3M)
- 收编提交:56a4337(register-hooks-cj.ts,200 行)
- 回滚命令见 progress.md
