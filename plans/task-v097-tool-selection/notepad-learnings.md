# Task Learnings: task-v097-tool-selection

## New Requests
- 2026-09-30 /goal 自主会话: 优化当前 skill 确保可以结合 /workflow /goal 等这里工具来动态优化执行;模板引入依据不同任务选择不同的工具;模板/工具创建 skill 加入主动分析引入最合适有效的工具。→ 已落地 Rule 40 六子条+模板区块+卫星映射+plan-writer 契约（COMPLETE,52b434f）

## What Worked
- 「任务书落盘+短 prompt 引用」派发形态: 全程 6 次派发零超长/零缺 token 拦截（Rule 35.3 标准化）
- 对策 b（「Rules 1-39（含 Rule 40 …）」括注保字面子串）: WF-10 计数与 4 处宽容正则锚全保,零断言改动零 scope 扩围
- plan-writer 侦察+knowledge-brief 材料包互链: 执行期 6 次派发全部按 §5 索引取材料,零盲找
- executor 对逐字插入与验收矛盾时拒绝擅改凑数（P4 两次 partial）——Rule 26 精神的良好样本

## What Didn't Work
- 任务书验收口径两次缺陷（P4-S1/S2 验收①grep≥2 vs 逐字文本 1 处）[假设未验]: 根因=写验收标准前未对「逐字插入文本」自测 grep 计数,阈值凭感觉定。预防=验收锚先对产物自测（计划硬约束 5 已有,执行面补验收侧）
- 首派 P2-S1 连续两次被派发守卫拦截（缺三文件 token/prompt 超长）[规则缺位]: 已固化为标准形态（见 What Worked）并登记 Decisions Made

## 🚫 被否决方案（User Rejected — Rule 32）
- （本任务无新增用户否决;历史禁令源=各任务 notepad 本段+memory,计划期 32.2 检查已做未命中）

## Files Modified
- 主仓 master（经 52b434f+CR P2-a commit）: critical-rules.md(+11)/SKILL.md(433 行)/templates/task_plan.md(+14)/mini-lite-type.md(+1)/subagent_dispatch.md(+1)/template-mapping.md(+15)/template-guide.md(+11)/companion/agents/plan-writer.md(+1)/selftest-skill-split.sh(上限 433+注释)/selftest-tool-selection.sh(新建 12 断言)/selftest-registry.tsv(+1)
- 部署位: 三位 skills/task-planner IDENTICAL+~/.zcode、~/.claude agents/plan-writer.md 同步

## Verification Results
- Verified: 全量 37 脚本 604/0;三位 diff -r IDENTICAL;CR APPROVED;委派率 0.571 verdict=ok(白名单豁免);worktree/分支清理 0/0
- Failed: 无阻塞;遗留 4 项见 verification.md 遗留披露段（.gitignore 增补留用户/frontmatter 括注维持现状/opencode agents 现状保持/契约新会话生效）

## 📚 必要知识储备备注
- 本次新发现的知识源: install-companion.sh v2.2.2 平台 model 行适配（zcode=custom:<uuid>:<slug> / claude=纯档位名）——对账 companion 部署位时 frontmatter model 行差异=机制内预期
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: SKILL.md frontmatter 索引（L10 区）缺 Rule 40 括注（CR P2-c,PT-08 锚约束下暂不动）

## Notes for Next Time
- 触发=任务书含逐字插入内容+grep 类验收: 防线=写验收阈值前先对插入文本自测计数
- 触发=改 SKILL.md 行数或计数措辞: 防线=P1 级联清单先行（5 处 ≤558/≤433+4 宽容锚+WF-10 计数,对策 b 括注形态）,SKILL 净增必同步 skill-split 上限
- 触发=install-companion 部署后对账: 防线=frontmatter model 行差异属平台适配;备份目录会污染对账面→移出 ~/skill-deploy-backups-*/
- 触发=派发 executor 改技能文件: 防线=任务书落盘+三文件契约 token+checkpoint 先行（本任务全程零失败派发的形态）
