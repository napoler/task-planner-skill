# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:1-executor] 根目录刷新
- 结论:README_zh.md+INSTALL_zh.md 六类过期口径全部刷新完成,验收 grep 零残留通过
- 实测对照表(WT=/mnt/data/dev/task-planner-skill-worktrees/task-v116,2026-10-02):
  | 口径 | 旧值 | 新值(实测证据) |
  |------|------|----------------|
  | variant 数 | 13/16 变体 | 29 类(含 video/image 家族 12 类;ls templates/variant=29,grep audio/character/image/motion/multiview/physics/prompt-struct/qc/storyboard/video=12) |
  | config.json 键 | 37 键 | 40(properties len,python 实测) |
  | scripts 规模 | 55 个 | 81 项(.sh 72 个,含 42 selftest selftest-*.sh;scripts/ 总项=81) |
  | 计划文件 | 5 个 | 6 个(init-session.sh:340 六文件循环 task_plan/findings/progress/notepad-learnings/verification/knowledge-brief) |
  | Rules 编号 | 1-39 | 1-45(critical-rules.md Rule 号最大 45) |
  | 总大小 | 1.3MB | 2.0M(du -sh skills/task-planner) |
  | 安装脚本位 | bash scripts/install.sh | skills/task-planner/install.sh(实 flag:--canonical/--tools/--no-verify/--no-backup/--dry-run;无 --target/--uninstall/--force) |
  | 校验 | bash scripts/validate.sh | skills/task-planner/lib/verify.sh(输出 [verify] summary: N pass / N fail) |
  | 卸载 | bash scripts/uninstall.sh / --uninstall | skills/task-planner/uninstall.sh(实 flag:--canonical/--keep-canonical/--keep-backups/--dry-run) |
  | session-catchup | .py(python3) | .ts(bun/node;INSTALL 依赖表 python3 行→bun/node+jq) |
  | 模板总数 | 「26 个模板」类 | 39(find templates -name '*.md'=39;顶层 10+variant 29) |
  | 英文链接 | 根 INSTALL.md/README.md 死链 | skills/task-planner/{INSTALL,README}.md |
  | 安装模型 | ~/.claude 单目录+--target | 多工具软壳(detect-tools 五工具:claude-code/zcode/opencode/cursor/continue) |
- 修改文件:WT README_zh.md(9 处)+INSTALL_zh.md(14 处);未触碰 skills/,未 git add/commit(git status 仅 2 文件 M)
- checkpoint:plans/task-v116/subagent-state/1-executor.md

#### [sub:2-executor] 回归与对齐
- 回归:42 selftest 全运行(单脚本 timeout 90s),41 rc=0;**selftest-workflow-orchestration.sh rc=1:WF-10 FAIL "Rules 1-39 命中总和 4 <6"**——根因=Phase 1b(85ab33b)将 README_zh.md:136,229 "Rules 1-39"刷新为"Rules 1-45"(实测数字),WF-10 断言锚(scripts/selftest-workflow-orchestration.sh:52-57)未随动,属守卫锚级联漏网(FMEA RPN48);逐文件实测 SKILL.md=2/CLAUDE.md=1/README_zh.md=0/skills/task-planner/README.md=1
- 对齐四要素:diff↔意图 5 处全过(SKILL.md:64 六文件/cost-guard:21 STOP 档删除/cost-control:33 对齐/progress-tracker:192 清账/README+INSTALL 数字簇);引用实存全过(install.sh/uninstall.sh/lib/verify.sh/session-catchup.ts 均 EXISTS);守卫锚 TL+skill-split 重跑 PASS(21/41 FAIL=0)
- **旧表述残留(未修,v116 scope 外)**:① billing.md:54 `>15 次 强制 STOP` 门控表行(R-06 漏网,billing.md 不在 scope_files;部署位同残留)② CLAUDE.md:24,43,54,81 `session-catchup.py` ×4(实为 .ts)③ CONTRIBUTING.md/CONTRIBUTING_zh.md `bash scripts/install.sh` ×8(含幽灵 flag --force/--target)④ P2:check-scope.sh:80 白名单/memory-hygiene 模板例句/CHANGELOG:140 历史条目/template-guide.md:143 行号锚漂移
- 证据:plans/task-v116/subagent-state/2-executor.md §1/§2(全部命令可重跑)

#### [sub:3-executor] 终验回归
- 回归(主仓 HEAD 70b9f38,33c7325 为其祖先):42 selftest 全运行(timeout 90s 包裹,无一超时)→ **42/42 rc=0 FAIL=0**
- sub:2 唯一 FAIL 复验清零:selftest-workflow-orchestration.sh `Total: 16 PASS=16 FAIL=0` rc=0 ✓——dirty 区已含 WF-10 锚口径扩展(扩 `Rules 1-45` 演进全集锚,守卫意图不变);逐文件实测 SKILL.md 1-39=2、CLAUDE.md 1-39=1、README_zh.md 1-45=2、skills/task-planner/README.md 1-39=1 → TOTAL=6 ≥6
- registry.tsv(selftest-registry.tsv)非脚本核验:43 行=表头 1+42 行;双向 diff vs 磁盘 42 个 selftest-*.sh=零差集;selftest-registry.sh 断言 `registry rows=42, actual selftest=42` 独立复验一致
- 零写入仓库:git status Pre/Post 完全一致(2 项 M=.dispatch-inflight 戳+workflow-orchestration dirty 修复,均 pre-existing,非本回归引入)
- 遗留(v116 scope 外,需主进程裁决是否立 v117):billing.md:54 幽灵 STOP 档 / CLAUDE.md session-catchup.py×4 / CONTRIBUTING×2 bash scripts/install.sh×8 / P2 模板例句与行号锚漂移(同 sub:2 §2.2,本次未新增未消除)
- 证据:plans/task-v116/subagent-state/3-executor.md §1/§2/§3(42 行逐项原文 rc+Total;全部命令可重跑)
