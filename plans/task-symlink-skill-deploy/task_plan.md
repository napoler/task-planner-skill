<!-- template_type: deployment -->
# Task Plan: zcode/claude 的 task-planner 副本改为软链接

## Goal
把 `~/.zcode/skills/task-planner` 与 `~/.claude/skills/task-planner` 两个真实目录副本替换为指向 canonical 仓库 `/mnt/data/dev/task-planner-skill/skills/task-planner` 的软链接，消除部署副本漂移。

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 两路径均为软链接且指向 canonical | `readlink` 两路径输出仓库路径 | 命令输出 |
| VC-2 | 通过软链可读 SKILL.md 且脚本语法完整 | `head` SKILL.md + `bash -n scripts/check-complete.sh` | 命令输出 |
| VC-3 | claude 侧 hooks 注册脚本经软链可见 | `ls ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts` | 命令输出 |
| VC-4 | register-hooks-cj.ts 已收编进 canonical 并提交 | `git log --oneline -1` 含该文件 | git log |
| VC-5 | 原副本完整保留为备份（可回滚） | `du -sh` 两个 .bak 目录非空 | 命令输出 |
| VC-6 | ~/.agents/skills/plan-resume 为软链且指向 canonical companion | `readlink` 输出仓库路径 | 命令输出 |
| VC-7 | v0.4 内容已收编进 companion 并提交（SKILL.md/extract-meta.sh/scan-plans.sh + score-plans.py/select-and-resume.sh） | `diff -r` 部署备份 ↔ companion 仅剩 README/tests 差异；`git log -1` 含收编提交 | 命令输出+git log |
| VC-8 | 经软链可读 v0.4 SKILL.md 且脚本语法完整 | `grep v0.4` 经软链 + `bash -n` 三个 sh + `py_compile` score-plans.py | 命令输出 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| home 目录 | ~/.zcode/skills/task-planner、~/.claude/skills/task-planner（mv→备份+ln -s） | 触碰其他任何 skill 目录 |
| canonical 仓 | 仅新增 scripts/register-hooks-cj.ts（自 claude 副本收编） | 改其他文件 |
| 范围外 | ~/.config/opencode/skills/task-planner 用户未点名 → 不动,仅报告;~/.claude/skills/plan-resume 用户未点名 → 不动,仅报告 | — |

## 🔁 扩展记录（2026-09-04 第二段:plan-resume 软链化）
用户指令:「~/.agents/skills/plan-resume 也需要使用软链接指向当前项目的skill」。勘察发现**分叉演化**,非纯陈旧:
- 仓库 companion = v0.3(387cca4,多格式扫描,tests/);~/.claude 副本 = v0.3 忠实安装(04:24);~/.agents 副本 = **v0.4**(19:55,§7 smart-resume + score-plans.py 加权打分[用户今日拍板算法] + select-and-resume.sh,**不含** v0.3 多格式)
- **决策**:先经官方 `sync-companion.sh --target ~/.agents` 把 v0.4 三文件拉回 companion + 手工收编两个独有脚本并 commit(运行时行为零变化),再换软链;v0.3 多格式特性保留于 git 历史,**v0.3+v0.4 合并为 v0.5 立为后续任务待用户立项**

**前置安全**（已勘察 2026-09-04）:两副本均无备份外独有内容(.git 内部对象/.backup/install.log 除外);claude 副本差异为纯陈旧;副本本身即旧 clone+备份目录将保留,零丢失。

## Current Phase
Phase 6 — all complete

## Phases
### Phase 1: 收编 register-hooks-cj.ts 进 canonical
- [x] 确认 canonical install.sh 引用该文件但仓库未携带
- [x] cp claude 副本的 scripts/register-hooks-cj.ts → canonical scripts/ 并 commit
- **Status:** complete
- **Executor:** 主进程（例外理由:单文件收编+git 编排属主进程白名单）

### Phase 2: zcode 副本换软链
- [ ] mv ~/.zcode/skills/task-planner{,.bak-20260904} && ln -s <canonical> ~/.zcode/skills/task-planner
- **Status:** complete
- **Executor:** 主进程（例外理由:基础设施部署属主进程白名单,无法委派——涉及本会话自身运行依赖）

### Phase 3: claude 副本换软链
- [x] mv ~/.claude/skills/task-planner{,.bak-20260904} && ln -s <canonical> ~/.claude/skills/task-planner
- **Status:** complete
- **Executor:** 主进程（同上）

### Phase 4: 终验 + 收尾
- [x] VC-1~5 全过:双软链指向 canonical✓ SKILL.md 可读+bash -n OK✓ register-hooks-cj.ts 经 claude 软链可见✓ 备份 2.9M/2.3M✓
- [x] 报告:opencode 副本待用户决策;备份目录位置已写入 progress
- **Status:** complete
- **Executor:** 主进程（例外理由:验证与交付属主进程白名单）

### Phase 5: 收编 plan-resume v0.4 进 canonical companion
- [x] sync-companion.sh --target ~/.agents --dry-run 预演 → 实拉 SKILL.md/extract-meta.sh/scan-plans.sh
- [x] cp 部署副本独有 scripts/score-plans.py + select-and-resume.sh → companion/scripts/
- [x] git commit 收编(v0.4 为 canonical 最新;v0.3 多格式留 git 历史) — **dcfa55b**,5 files,+774/-331
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排+基础设施部署属主进程白名单,同 Phase 1 先例）

### Phase 6: ~/.agents/skills/plan-resume 换软链 + 终验
- [x] mv ~/.agents/skills/plan-resume{,.bak-20260904} && ln -s <canonical companion> ~/.agents/skills/plan-resume
- [x] VC-6~8 全验:readlink→canonical✓ 经软链↔备份残差仅 README/tests✓ v0.4 标记可读(5 hits)✓ bash -n x3 OK✓ py_compile OK✓
- **Status:** complete
- **Executor:** 主进程（例外理由:本会话自身运行依赖的 skill 加载路径,同 Phase 2/3）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（home 目录拓扑变更,无并行写冲突面） |
| `isolation` | `direct`（非 git 仓内开发,worktree 不适用;安全机制=mv 保留备份） |
| `merge_back` | n/a |

## Notes
- 主进程直做例外理由:该变更是本会话自身运行依赖(hooks/skill 加载路径),委派子代理会在子会话内操作宿主基础设施,风险更高
- 回滚:rm 软链 && mv <path>.bak-20260904 <path>
