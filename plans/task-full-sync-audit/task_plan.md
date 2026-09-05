<!-- template_type: audit -->
# Task Plan: 今日大改后全仓一致性体检与彻底同步

## Goal
对今日系列变更（plan-resume v0.4 收编 dcfa55b、companion→顶层迁移 4728906/1957fec、todo-skill TS 收编 186f3a6、全软链化）做系统性一致性审计：找出所有未同步的引用（安装脚本/架构与使用文档/模板/hooks/校验脚本/示例）并彻底修复,产出体检报告,确保零遗漏。

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 五类陈旧模式全仓 grep 仅剩白名单命中（CHANGELOG 历史条目、刻意保留的迁移说明） | grep 清单对照白名单 | 命令输出 |
| VC-2 | 本轮改动脚本全部 bash -n 通过;install-companion/sync-companion --dry-run 行为正常 | 命令输出 | 命令输出 |
| VC-3 | 文档描述的布局与实际一致(ARCHITECTURE/INSTALL/README/CLAUDE.md/CONTRIBUTING 等交叉核对) | 逐文件 Read | 命令输出 |
| VC-4 | hooks/校验脚本引用的工具与路径全部存在(todo TS 工具/verify.sh 检查项) | ls + bash -n + verify.sh 干跑 | 命令输出 |
| VC-5 | ~~四根全部软链~~ **修订**(F3 裁决):opencode hooks 走 frontmatter,不可换软链 → opencode/cursor 保持薄壳且刷新至与 canonical 一致;zcode/claude/agents 全软链 | verify 18/0 + cmp 薄壳↔canonical + readlink | 命令输出 |
| VC-6 | 体检报告落盘 plans/task-full-sync-audit/(findings+fixes+residual) | Read 报告 | 文件 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 仓内(worktree) | 扫描发现的不一致文件(文档/脚本/模板),逐项记录后修 | 无审计记录的顺手改 |
| home | ~/.config/opencode/skills/task-planner 换软链(mv→集中备份+ln -sfn) | 触碰 opencode 下其他无关 skill |
| 范围外 | plan-resume v0.5 内容合并(独立待立项);CHANGELOG 历史条目不改写 | — |

## Current Phase
Phase 4 — all complete（报告: report.md;合并 f281ecd,实现 49b6215）

## Phases
### Phase 1: 系统性扫描
- [x] Explore 子代理超时终止(40min),主进程五类模式快扫兜底完成——文本层干净,命中均白名单
- [x] 主进程行为层:verify.sh 实跑 5 fail(定性=stub 模型残留);20 脚本 bash -n;opencode 架构裁决
- **Status:** complete
- **Executor:** Explore(终止,兜底覆盖) + 主进程

### Phase 2: 分类裁决 + worktree 修复
- [x] F1 verify.sh 软链模型适配;F2 .backup/ 出库+.gitignore;F3 opencode 裁决=薄壳再生成;F4 INDEX 刷新;全部记录于 findings.md/report.md
- **Status:** complete
- **Executor:** 主进程

### Phase 3: 验证 + 合并
- [x] verify 18 pass/0 fail(模拟合并形态);bash -n;双 dry-run → merge --no-ff **f281ecd** → worktree/分支清理
- **Status:** complete
- **Executor:** 主进程

### Phase 4: opencode 收编 + 终态报告
- [x] opencode 薄壳再生成 + 内嵌 .git/.backup 移集中备份;VC-5 三根软链+opencode/cursor 薄壳终态确认;体检报告落盘 report.md(VC-6)
- **Status:** complete
- **Executor:** 主进程

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（并行会话范围=bak 清理,已完结;仓内修复走 worktree） |
| `isolation` | worktree（仓内文件修改）;部署位 direct |
| `merge_back` | merged(f281ecd),实现 49b6215 |

## Notes
- 五类扫描模式:①companion/skills 残留 ②todo_manager.py/python3 todo 残留 ③版本/数量陈述过时(plan-resume 2 脚本等) ④布局描述过时(companion 语义/顶层不在安装流) ⑤路径陈述过时($HOME/dev/task-planner、旧发现顺序)
- 白名单原则:CHANGELOG 历史条目不改写;描述"迁移自 companion/skills"的说明句保留
