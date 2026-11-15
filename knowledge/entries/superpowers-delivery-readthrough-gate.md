---
id: superpowers-delivery-readthrough-gate
title: "superpowers 创作链交付前通读审查门（final-readthrough 技能+三接线）"
tags: [superpowers, quality-gate, final-readthrough, delivery]
sources: [plans/task-finalread-20261116/, ~/.agents/skills/final-readthrough/SKILL.md, ~/.agents/skills/executing-plans/SKILL.md, ~/.agents/skills/subagent-driven-development/SKILL.md, ~/.zcode/skills/using-superpowers/SKILL.md]
updated: 2026-11-16
---

# superpowers 创作链交付前通读审查门

**问题**：创作产出（剧本/分镜脚本）多次分段编辑后无人通读成品全文——逐任务审查只见局部 diff，sdd 的 final review 是 code-reviewer（diff 向/代码向），「文件即成品」的内容型交付（锚定首尾对照图说明未落实到逐个分镜类全局缺陷）无门拦截（缺口证据：改前 executing-plans/SKILL.md:33-38 直进 finishing；判例原话 plans/task-finalread-20261116/user-session-log.md #1）。

**制度解法**（2026-11-16 落地，纯文本条款零脚本）：
1. 新技能 `final-readthrough`（~/.agents/skills/final-readthrough/SKILL.md）：七铁律=整读（最后一次编辑后 Read 全文到末尾，未整读=未审查）/逐单元核对（每个分镜逐个查，抽查≠全查）/全局一致性（编号/术语/占位/首尾呼应）/需求对照/多文件逐一整读/留痕裁决（修复后必须重新整读，循环到 PASS）/反作弊（Read 实际范围=证据，只读改动段冒充通读=虚假完成）
2. executing-plans：新 Step 3 通读门（REQUIRED SUB-SKILL: superpowers:final-readthrough），原 Step 3 顺延 Step 4（:36-37/:79）
3. subagent-driven-development：流程图节点/边+正文段+Integration+Red Flags 四锚点（:66/:82-83/:221-223/:396-397/:421）
4. using-superpowers 双位（zcode+agents）Red Flags :51 同文本 IDENTICAL——「The work is done, hand it over」念头在入口拦截

**验证模式**：Verifier 独立只读取证（逐 VC 贴命令输出）+主进程 diff/grep 交叉双取证面；备份 md5 先行（agents 位非 git，改动前 cp 至计划目录 backups/）；zcode 位走 worktree（基点=main，merge --no-ff 5cd47a2）。

## 已验证关键事实
| 事实 | 证据 | 影响 |
|------|------|------|
| executing-plans/subagent-driven-development 仅 ~/.agents/skills 位 | ls 2026-11-16 | 改动只落 agents 位无镜像负担 |
| ~/.zcode 仓默认分支=main（无 master） | git branch --show-current | worktree 基点先实测 |
| Rule 25.3 六项白名单编号（①git 编排②计划系统文件③机械验证④用户显式⑤兜底接管⑥trivial/mini） | task-discipline/references/critical-rules-dispatch.md:108 | Executor 例外理由必须带编号否则 stats verdict=violation |
| Executor 字段须纯执行体名 | plans/task-finalread-20261116/progress.md Error Log | 内联长注释会被 check-delegation 误解析成主进程直做 |
| 保护区（~/.agents/skills）主进程 Write 被 delegation-block 拦 | 本任务 2026-11-16 实测 | 保护区编辑一律派子代理，主进程只 git 编排/复核 |

## 易错点与禁止假设
1. 禁止假设 ~/.zcode 仓分支为 master（实测 main）
2. 禁止主进程直写保护区技能文件（守卫强制委派；绕行须用户 allow-direct.sh 显式确认）
3. content 交付的「最终审查」≠code review——sdd final reviewer 是 diff 向，通读门补的是「成品整体被读过」这一缺失动作
