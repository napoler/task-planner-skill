---
id: serial-creation-knowledgesync-rule107
title: "序列创作知识同步三环闭环（Rule 107）：根治跨集/跨章知识丢失的规范面落点与级联形态族"
tags: [rule107, 序列创作, 知识同步, 派发契约, 纪元级联, selftest锁步]
sources: [skills/task-discipline/references/critical-rules-discipline.md, skills/task-dispatch/references/critical-rules-dispatch.md, skills/media-planner/references/critical-rules-media.md, skills/task-planner/templates/subagent_dispatch.md, plans/task-serial-sync-20261115/knowledge-brief.md]
updated: 2026-11-15
---

# 序列创作知识同步三环闭环（Rule 107 落地，task-serial-sync-20261115）

## 问题与方案
多集剧本/多章小说等序列创作中，单元 N+1 只携带本单元要求，上一集的人物/设定/剧情知识无处可传（实证：写剧本上一集知识到下一集丢失）。修复=三环闭环条款（Rule 107，P0）：**107.1 单元完成台账沉淀**（人物状态/世界观/时间线/伏笔五字段 continuity 台账，未更新禁称完成）→ **107.2 动笔前强制回读**（任务书必附前序产出+台账双路径，执行体首动作=完整 Read，摘要不替代原文）→ **107.3 验收一致性核对**（五项逐项对照台账，冲突=FAIL 返工）。工序串行≠知识传递（media 47.7 口径）。

## 落点与锚点（行号以 2026-11-15 主仓实测为准，后续引用须重测）
| 载体 | 锚 | 内容 |
|------|----|------|
| task-discipline critical-rules-discipline.md | :740-753 | Rule 107 六子条全文（权威载体，107.0-107.5） |
| task-dispatch critical-rules-dispatch.md | :64 | 22.4d 派发硬条款：序列单元任务书缺前序产出+台账路径禁派发 |
| media-planner critical-rules-media.md | :27 | 47.7 媒体面指针（与 47.6 物理抽检门叠加=两道门） |
| task-planner templates/subagent_dispatch.md | :30 | §2「前序产出与序列台账」行（非序列任务填 none） |
| task-planner SKILL.md | :9/:210/:223/:266 | 纪元 1-107+全集索引 Rule 107 行+路由表 ,107 |
| selftest-enumerate-first.sh / selftest-dual-qc.sh | :9/:92-99；:11/:97/:100/:102 | EN-06 纪元锁步+DQ-08 计数窗锁步 |

## 易错点（级联形态族与合并陷阱）
1. **级联面=双形态族**：新规则落地除字面纪元（'1-1[0-9][0-9]' 宽容锚）外，必须枚举 selftest 内的**计数窗口断言**——dual-qc DQ-08 '其余 8[0-9] 条' 被 90 条溢出致回归（判例：Error Log 2026-11-15，修复=锁步为 '其余 9[0-9] 条'，commit 2eded71）。
2. **残留判定排除本体引用**：SKILL.md:105「106.1-106.4」区间字面含 '1-106' 属 Rule 106 本体引用，禁改。
3. **git merge 保守拦截**：HEAD 无此文件但 index 已 staged 的他人文件会拦合并（即使 merge 不动该路径）→ stash 窗口合并法（stash push -- pathspec → merge --no-ff → stash pop，staged 态可保留）；先例=task-docmod-recheck。**commit 必带 pathspec**（`git commit -- <paths>`），裸 commit 会扫走 index 内他人 staged 文件（判例=本任务 2b468dc 捎带事故，soft reset 后 pathspec 重提交修复）。
4. **部署位异构**：zcode 位（~/.zcode/skills）四族全量；claude 位（~/.claude/skills）同构；cursor 位（~/.cursor/skills）非 git 仓仅落盘；agents 位（~/.agents/skills）task-planner 为 stub 安装（无 SKILL.md/templates/scripts）——勿假设部署面同构，cp 后逐文件 diff=0 核验。

## 并行与验证范式
- worktree 内多 S-unit 落地不同文件 → [parallel-group] 同消息并发派发（Rule 96.4），逐单元盘上 grep 复核（不信自报）。
- 回归判据用 **Total 行 FAIL 值解析**（`sed -n 's/^Total: .* FAIL=\([0-9]*\).*/\1/p' | tail -1`）对照编辑前基线文件——grep 'FAIL' 行计数恒定无判别力（判例：本任务基线度量两轮修正）。
- 独立复检体（103.3a 全文回读比对条款终稿）是级联漏改的最后防线：DQ-08 即清单外新形态、由复检体兜住。
