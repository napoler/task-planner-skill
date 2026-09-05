<!-- template_type: deployment -->
# Task Plan: 全部外围技能部署副本软链化（zcode + claude 全覆盖）

## Goal
把 task-drift-guard / todo-skill 在 `~/.zcode/skills` 与 `~/.claude/skills` 的 4 个实体副本、以及 `~/.claude/skills/plan-resume` 陈旧副本，全部替换为指向 canonical 仓 `skills/<name>` 的软链接；todo-skill 须先收编 `~/.zcode` 最新版（08-29,Bun/TS 迁移版）进仓库,避免运行时回退；备份统一移出技能加载器扫描路径。

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 5 路径均为软链且指向 `skills/<同名>` | readlink 逐一输出 | 命令输出 |
| VC-2 | 经软链内容正确:drift-guard 含 model:haiku;todo-skill 引用 cli_todo-manager.ts(TS 版);claude/plan-resume 含 v0.4 | grep 经软链 | 命令输出 |
| VC-3 | todo-skill 收编已提交（TS 版入库,python 版移除） | git log/show --stat | git |
| VC-4 | 各 skills 根目录无 .bak-* 残留（不被加载器扫成重复技能）;备份集中于 ~/skill-deploy-backups-20260904/ | ls 三个 skills 根 + 备份目录 | 命令输出 |
| VC-5 | repo 工作区干净（仅原有未跟踪目录） | git status --short | 命令输出 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| home | 上述 5 副本路径（mv→集中备份+ln -sfn） | 不新建 ~/.agents/{drift-guard,todo-skill}、~/.zcode/plan-resume（防双重发现）;不动 opencode |
| 仓内 | 仅 skills/todo-skill/**（收编覆盖:SKILL.md/_meta.json/WORKFLOW.md/tools/cli_todo-manager.ts/tools/store.json;git rm 两 .py） | 触碰其他 skill 文件 |
| 范围外 | 并行会话 task-del-skill-baks 的计划与产物不触碰 | — |

**前置裁决（已勘察）**: todo-skill 三方为线性演进（仓 08-12 Python → claude 08-15 +WORKFLOW → zcode 08-29 Bun/TS 迁移+model:haiku）,zcode 版=truth source;store.json 三方一致（121B 样例）;task-drift-guard 两副本与 canonical 逐字节一致（今日归一后果）,替换零内容损失;claude/plan-resume v0.3 全量在 git 387cca4。

## Current Phase
Phase 3 — all complete

## Phases
### Phase 1: todo-skill 收编进仓库
- [x] cp zcode 版 5 文件覆盖仓内 + git rm 两 .py + commit — **186f3a6**(+610/−254)
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排+部署位操作属主进程白名单）

### Phase 2: 5 副本换软链 + 集中备份
- [x] mkdir ~/skill-deploy-backups-20260904;5×(mv → 备份目录;ln -sfn canonical → 原路径)
- **Status:** complete
- **Executor:** 主进程（同上）

### Phase 3: 终验 + 簿记
- [x] VC-1~5 全验;记忆拓扑更新
- [x] 收尾扩展（用户授权"清理残余"）:rm ~/.agents/skills/plan-resume.bak-20260904（删前核实=v0.4 备份 60K,内容已全量收编 dcfa55b,零损失）;三 skills 根零 bak 残留复验 ✓
- **Status:** complete
- **Executor:** 主进程

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（并行会话范围=bak 删除,与本任务零重叠;仓内仅 todo-skill 一处写入） |
| `isolation` | direct（home 部署位操作不适用 worktree;仓内仅机械收编单目录,先例 dcfa55b） |
| `merge_back` | n/a（master 直提收编提交） |

## Notes
- 备份位置刻意选 skills 扫描路径之外:加载器只扫第一层,.bak-* 目录会被识别为重复技能(并行会话今日刚清理同类问题)
- ~/.agents/plan-resume 软链已存在(昨轮),本轮不动;opencode 副本用户仍未点名
- 回滚:rm 软链 && mv ~/skill-deploy-backups-20260904/<name> <原路径>;仓内 git revert 收编提交
