# Findings & Decisions

## Requirements
- 用户指令（原话）："将最新修改版本安装到各个平台当中"
- 语义：以 canonical 仓 /mnt/data/dev/task-planner-skill（master ad7900d）为 truth source，把所有平台部署位同步到最新
- "各平台" = ~/.zcode / ~/.claude / ~/.agents / ~/.config/opencode 四平台的 task-planner 系 skill 部署位

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 记忆 task-planner-repo-deploy-flow.md | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/ | 已消费 | Research Findings（部署拓扑 8 位清单 + cp -rL SOP） |
| plans/INDEX.md | plans/INDEX.md | 已消费 | Research Findings（task-active-plan 状态差异） |

## Research Findings
- **部署位现状调查（2026-09-05 12:10，diff -rq + deep-diff + sha256 三重验证）**：
  - 8 个既有部署位（~/.zcode/skills/{task-planner,todo-skill,task-drift-guard}、~/.claude/skills/{task-planner,todo-skill,plan-resume,task-drift-guard}、~/.agents/skills/plan-resume）与 master ad7900d **字节级一致**（diff 0 条；SKILL.md 哈希 0e56bb1d… 相同；task-planner 位 96 文件 804K）。说明凌晨 active-plan 合并会话（03:39-03:40）已完成这 8 位部署，只是记忆未更新
  - 唯一落后位：~/.config/opencode/skills/task-planner——63 文件 524K 旧薄壳（canonical 96 文件），缺 docs/lib/tests/install.sh/uninstall.sh 与 5 个新脚本（check-3file-gate/ledger-append/plan-doctor/resolve-plan-dir/set-active-plan），SKILL.md/references/critical-rules.md/templates/* 均为旧版
- **task-active-plan 状态差异**：plans/INDEX.md 仍标 in_progress 0/5，但其 task_plan.md 内 outcome 已记 COMPLETE（2026-09-05 merge ad7900d），git 亦已合并——INDEX 是 sync-todos 未刷新的陈旧状态，非真实未完成。已向用户报告，未擅改该计划状态

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| opencode 位纳入本次部署 | 用户指令"各个平台"；该位确为 task-planner 部署位且落后 33 文件；与其他 8 位同构同步 |
| 8 个既有位不重写 | diff 已证明一致，重写是无谓风险（写入最小化 §五） |
| opencode 同步前 tar 备份到 /tmp | 快照替换 rm 前留回滚保险（/tmp/opencode-task-planner-backup-20260905.tar.gz 124K） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| init-session.sh 在仓根误跑（漏 `cd $_`）：4 模板写仓根 + 指针误写 /mnt/data/dev/.active_plan（脚本 `PLAN_ROOT="$(cd .. && pwd)"` 在仓根运行时指向仓外目录） | 已删除全部误写文件（git status 对照确认均为新增未跟踪项）；于 plans/task-deploy-master-20260905 正确重建；改进建议见 Resources |

## Resources
- 部署 SOP 依据：记忆 task-planner-repo-deploy-flow.md "How to apply"（rm -rf + cp -rL + diff -r 复验）
- 回滚资产：/tmp/opencode-task-planner-backup-20260905.tar.gz
- init-session.sh 健壮性缺陷（未修，超本任务范围，建议后续在仓内修）：脚本无"CWD 必须是 plan 子目录"守卫，在仓根运行会污染仓根与仓外上级目录；可加 `[ -f ../.active_plan ] || [ "$(basename $PWD)" != "$(basename $(git rev-parse --show-toplevel))" ]` 类守卫或检查 PWD 在 plans/ 下
- resolve-plan-dir.sh 指针解析链实测：plans/.active_plan 存在时指针优先，缺失时回退 mtime 最新（task-active-plan 曾以此被选中）

## Visual/Browser Findings
- （无多模态信息）
