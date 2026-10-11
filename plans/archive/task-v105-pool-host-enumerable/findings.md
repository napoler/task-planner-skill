# Findings & Decisions
## Requirements
- 用户裁决(2026-10-01,AskUserQuestion):「池成员提升为宿主可枚举 skill」——11 个 review-library 成员须可被宿主 /<name> 显式触发,保留嵌套池语义(Rule 42.2 ④层),opencode 独立 security-review 保留
- 落地=相对软链挂载(smart-merge-back --deploy 自动)+install-companion 单文件分发+RL-14/15;零 config 改动;池内容零改动

## Research Findings
- [P0 实测 2026-10-01] master=084a92a;宿主发现面=顶层 skills/<name>/SKILL.md(实证:plan-resume 顶层被枚举,嵌套池 11 成员不在 available-skills);symlink 探针实证可读(name: general-review 解析✓);opencode 顶层冲突仅 security-review(2026-04-10 手工副本,12202B SKILL+10189B cloud-infrastructure-security.md,英文,与池成员不同内容——保留);.zcode/.claude 顶层对 11 名全干净
- [机制锚] smart-merge-back.sh:deploy_reconcile 调用点 :609,成功分支 echo IDENTICAL 后=挂载插入位;exit 0 在 :623;install-companion.sh:skills 循环 :167-190,`[ "$skill_name" = "task-planner" ] && continue` :172=分发插入位;sync_one 幂等(cmp 等同 skip)
- [基线] 41 脚本 650/0;config 键 40;RL Total 13

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 相对软链(非复制/非绝对路径) | 单一维护源零漂移;slot 原子替换后相对目标仍有效;可移植 |
| 挂载=deploy 成功后增强段 | exit 语义不变保 SM selftest;LINK-WARN 仅输出 |
| install-companion 仅 SKILL.md 单文件 | 池成员零 scripts/config;最小面 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
-

## Visual/Browser Findings
-
