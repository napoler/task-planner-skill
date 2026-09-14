# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话锚定：审核+优化当前技能（task-planner）→ 提交 GitHub → 本地各平台部署（9 位拓扑,本键盘授权完整链路）
- 修复范围：已诊断 8 项存量缺陷 + 审计新发现;范围外进 deferred-issues.log

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| memory/task-planner-repo-deploy-flow.md | ~/.zcode/cli/memories/.../task-planner-repo-deploy-flow.md | ☑ | Technical Decisions(部署 SOP/verify.sh 缺口) |
| memory/task-planner-known-defects-20260905.md | 同目录 | ☑ | Research Findings(缺陷①-⑥) |
| memory/task-planner-awk-scope-extraction-bug.md | 同目录 | ☑ | Research Findings(缺陷⑦) |
| 审计检查点 01-general-purpose.md | plans/task-v053-skillfix-deploy/subagent-state/ | ☑(主进程已 Read 复核,W2) | Research Findings 全部 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **审计结论（2026-09-06,子代理 general-purpose,检查点 01）**：8 项已知缺陷全部仍存在,均带 file:line 取证。关键实证：缺陷⑦ awk 区间提取 buggy 输出 1 行 vs 状态机 3 行（/tmp/scope_test.md 实测）；缺陷⑨ init-session.sh 从 /tmp 运行把 PLAN_ROOT 解析为 / （Permission denied 仅被 set -e 救场）；缺陷⑧ verify.sh 无 main 入口,verify_installation 从未被调用,stdout 全空。证据：subagent-state/01-general-purpose.md §B/§F
- **缺陷⑦是唯一功能阻塞**：Rule 23.5 scope 解析/Rule 27.2 提交范围/Rule 23 冲突检测三处全部空转（检查点 §E.2）
- **新发现**：#10 SKILL.md:300 Rule 16 自指矛盾（随双源收敛一并解决）；#11 path_existence_validator.ts 解析误报（skill-fix 工具层,deferred）；#12 template-mapping.md:193 示范正确 awk 但实现违反（随缺陷⑦解决）
- **SKILL.md frontmatter 无 hooks: 块**（注释说明按平台注册）→ verify.sh 第 8 项对全量实体副本会假阴性,修复需适配
- **脚本批次交付（检查点 02,重派轮 1）**：awk ×4 状态机化/init-session 守卫/verify.sh 三态+main/check-complete porcelain 预检;smoke 17 pass/0 fail
- **文档批次交付（检查点 03,重派轮 2——轮 1 产出被脚本批次 git checkout 误毁）**：6 项全落地,21.5 计数=1,SKILL.md 614→570 行,template-mapping.md 零改动,S62 无悬空
- **主进程实测发现 check_scope_porcelain 三处边界缺口（已手术刀修补）**：① 混合仓内外路径 → git pathspec 整体 fatal → porcelain 恒空 → 假 clean（实测 `git status -- skills/... /home/...` 输出 fatal）;② 切词集漏 、(U+3001) → 两路径粘单 token;③ 裸文件名（无斜杠）被路径过滤器丢弃 → 脏文件漏检。三修后合成仓三分支实测：clean 2 paths/脏文件 exit 1 列出/全仓外 skip,全部符合预期（progress.md Phase 3 段）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| verify.sh 修为三态模型（软链/薄壳/全量实体副本）+ main 入口（BASH_SOURCE 守卫,兼容 smoke.sh source 调用） | 现拓扑=全量实体副本,两态判定必然误报;smoke.sh check5 是 source+显式调函数,main 入口须防 source 触发 |
| verify.sh 全量副本模式新增 cmp 语义（stub SKILL.md vs canonical 字节比对） | 部署漂移检测正是部署流程需要的 verify 能力,替代不可信的两态结论 |
| 双源分化采用方案 A（SKILL.md §任务模板库 555-614 收敛为指针,critical-rules.md:59 删双指） | 审计纠缠度=39 行重复（65%）,收敛代价 1 处 Edit,template-mapping.md 为单一权威源 |
| check-complete.sh porcelain 预检采用"安全降级"设计（scope 解析不出→warn 跳过;解析出且脏→exit 1） | 防 scope 表 prose 误判造成假失败,同时保住 Rule 27.3 硬门控语义 |
| init-session.sh 守卫=父目录 basename 必须为 plans | 实测 /tmp 运行 PLAN_ROOT=/ 险些写根目录;守卫 7 行,失败 exit 1 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| path_existence_validator.ts 对 3 个真实存在文件误报 MISSING | skill-fix 工具层缺陷,超出本任务范围 → deferred-issues.log |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
