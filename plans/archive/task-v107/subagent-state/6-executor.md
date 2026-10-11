# [sub:6-executor] 检查点 — 根目录 6 文档内容质量审查

## 里程碑
- [sub:6] M1 三文件+brief 读取完成, 6 文档全文通读完成 (2026-10-02)
- [sub:6] M2 维度1 数字面对拍完成: 75 脚本/42 selftest/10 skill/16 variant/11 池/25 templates .md/Rule 1-44 基线已复测确认
- [sub:6] M3 维度2 结构引用对拍完成: 根 scripts/ 不存在(install/validate/uninstall 实位 skills/task-planner/), INSTALL_zh 英文链接死链, CLAUDE/CONTRIBUTING 模板树缺 knowledge-brief.md
- [sub:6] M4 维度3 安装口径对拍完成: install.sh 实 flag={--canonical/--tools/--no-verify/--no-backup/--dry-run}; 默认目标=5 工具 per-tool 软壳(claude-code/zcode/opencode/cursor/continue); install-companion.sh 实位 lib/ ✓
- [sub:6] M5 问题清单定稿 + 最终结论落盘

## 实测基线复测证据（本次一手）
- `ls skills/*/scripts/*.sh | wc -l` → 75（其中 task-planner 72 .sh + plan-resume score-plans.py + 2 其他 = 75）
- `ls skills/task-planner/scripts/selftest-*.sh | wc -l` → 42；全仓 `find skills -name 'selftest-*.sh'` → 42
- `ls skills/` → 10 目录（task-planner + 9 卫星）；`find skills -maxdepth 2 -name SKILL.md` → 10
- `ls skills/task-planner/templates/variant/ | wc -l` → 16；`find templates -name '*.md'` → 25（顶层 9 + variant 16）
- `ls skills/task-planner/review-library/ | wc -l` → 11
- `grep -nE '^### 4[0-4]' skills/task-planner/references/critical-rules.md` → Rule 40(:393)/41(:404)/42(:415)/43(:430)/44(:439) 实存，max = 44
- `ls -A`(根目录) → 无 scripts/；`find . -name 'install.sh' -o -name 'validate.sh' -o -name 'uninstall.sh'` → 仅 skills/task-planner/{install.sh,uninstall.sh}，validate.sh 全仓不存在
- `test -e skills/task-planner/scripts/session-catchup.py` → MISSING；`session-catchup.ts` 存在
- `find skills -name '*.py'` → 仅 1 个（skills/plan-resume/scripts/score-plans.py）
- config.json properties=40，展开 defaults 叶子键=52
- `du -sh skills/task-planner` → 2.0M（INSTALL_zh 声称约 1.3MB）
- companion/agents/ → 3 文件（plan-writer/article-batch-publisher/article-field-fixer）✓ 与 README_zh:114 一致
- lib/install-companion.sh 实存（8575 字节，:1 注释声明布局）✓

## 三维结论
- **维度1 数字面**：README_zh 基本一致（16 variant✓、config 示例 9 键与 prompt_max_chars=3000✓）；**INSTALL_zh 安装内容清单 2026-09-16 核对后已全面过期**（13 变体/12 refs/scripts 55 个/37 键/1.3MB 全部 ≠ 实测）；CLAUDE/CONTRIBUTING 无数字断言（仅目录结构）。
- **维度2 结构引用**：根级 `scripts/` 不存在是最大口径断裂——README_zh 快速开始/验证/CONTRIBUTING 全部 dev-loop 命令 `bash scripts/install.sh|validate.sh|uninstall.sh`（根级）执行即失败；CLAUDE.md/CONTRIBUTING 双份模板树漏 knowledge-brief.md；INSTALL_zh 英文链接指向不存在的 INSTALL.md/README.md；README_zh 树漏 LICENSE；CONTRIBUTING 树漏 4 个根 md；「5 个模板文件」vs init-session 实测 6/6。
- **维度3 安装口径**：install.sh 实 flag 与文档描述零交集（--target/--force/--uninstall 均不存在）；默认安装模型=5 工具 per-tool 软壳（非「~/.claude 单一目录 + cp 文件」）；uninstall.sh 实 flag={--canonical/--keep-canonical/--keep-backups/--dry-run}；install-companion.sh 文档指向 lib/ 路径正确。验证面=lib/verify.sh（18 pass 历史口径），validate.sh 已不存在。

## 问题清单（ID/严重度/锚点/证据/修复建议）

| ID | 严重度 | 锚点 | 问题 | 证据 | 修复建议 |
|----|--------|------|------|------|----------|
| D6-01 | P1 | README_zh.md:59/67/266; CONTRIBUTING.md:44-56,89,119-120,136-137; CONTRIBUTING_zh.md:44-56,89,119-120,136-137 | 根级 `scripts/{install,validate,uninstall}.sh` 全部命令入口失效：仓根无 scripts/ 目录，install.sh/uninstall.sh 实位 skills/task-planner/，validate.sh 全仓不存在 | `find . -name install.sh -o -name validate.sh -o -name uninstall.sh` → 仅 `./skills/task-planner/{install.sh,uninstall.sh}`；根 `ls -A` 无 scripts | 快速开始/dev-loop/PR 清单命令改为 `bash skills/task-planner/install.sh` + `bash skills/task-planner/lib/verify.sh` 口径（或恢复根级 shim 后改文档） |
| D6-02 | P1 | README_zh.md:46,80,150; INSTALL_zh.md:61,239-245 | `session-catchup.py` 幽灵文件：实为 session-catchup.ts（skills/task-planner/scripts/session-catchup.ts），.py 不存在；python3≥3.8 前置与 jsonschema 排查段亦基于 .py 假设 | `test -e .../session-catchup.py` → MISSING；`find skills -name '*.py'` → 仅 1 个 score-plans.py | 三处引用改 .ts（node/bun 运行时口径），前置依赖表 python3 行删除或改「可选」 |
| D6-03 | P2 | INSTALL_zh.md:296-299 | 安装内容清单「variant/ 13 变体」+ 13 个具名枚举（缺 mini-lite/video/video-fix）实测 16；「(2026-09-16 核对)」标记已过期 | `ls templates/variant/ | wc -l` → 16；13 枚举=实测 16 − {mini-lite-type, video-type, video-fix-type} | 清单刷新为 16 变体全枚举，核对日期改 2026-10-02 |
| D6-04 | P2 | INSTALL_zh.md:300-303 | 「references/ (12 个: …billing/template-guide/template-mapping/methodology/skill-collaboration/todo-sync/worktree-isolation/batch-quality-gate/cost-control)」实测 task-planner/references/ 仅 8 个（batch-quality-gate/completion-gate/critical-rules/dispatch-examples/goal-gate/methodology/todo-sync/worktree-isolation）；12 口径混入 4 个卫星 skill 自带 references（plan-cost-guard billing+cost-control / plan-template-kit template-guide+template-mapping / plan-collab-router skill-collaboration） | `ls skills/task-planner/references/` → 8 文件；billing/template-guide/template-mapping/skill-collaboration/cost-control 实位各卫星 skill 目录 | 清单拆「主 references 8 + 卫星 4 组」或注明跨 skill 归并口径 |
| D6-05 | P2 | INSTALL_zh.md:285-291 | 「scripts/ (55 个 … selftest-*.sh ×19)」实测 scripts/ 顶层 81 项（72 .sh + 2 .ps1 + 2 .cjs + 3 .ts + 1 .tsv + lib/），selftest 42 个 | `ls skills/task-planner/scripts | wc -l` → 81；`ls scripts/selftest-*.sh | wc -l` → 42 | 刷新为 81 项/42 selftest（或写「以 ls -R 为准」并更新日期） |
| D6-06 | P2 | INSTALL_zh.md:282 | 「config.json (JSON-Schema 阈值配置, 37 键)」实测 properties=40（展开 defaults 叶子=52） | `python3 json.load → properties=40` | 改 40 键（与 selftest WF-13 锚 config 键数 40 同源） |
| D6-07 | P2 | INSTALL_zh.md:3 | 「两种方式最终都安装到 ~/.claude/skills/task-planner/SKILL.md」——install.sh 实测多工具检测模型：per-tool 软壳默认目标含 ~/.zcode / ~/.opencode / ~/.cursor / ~/.continue（detect-tools.sh:18-22），且 install.sh 实际 flag 无 --target（只有 --canonical/--tools/--no-verify/--no-backup/--dry-run） | detect-tools.sh:18-22 五行工具映射；install.sh:34-38 flag 解析 | 默认安装口径改「按检测到的工具各装一个软壳」；--target 用法删除或映射到 --canonical |
| D6-08 | P2 | INSTALL_zh.md:42-47,44,47,166-175,172,258,263 | 卸载/验证命令幽灵：`scripts/install.sh --uninstall`、`scripts/uninstall.sh`、`scripts/validate.sh`（根级）均不存在；uninstall.sh 实 flag={--canonical/--keep-canonical/--keep-backups/--dry-run}（无 --target/--force） | uninstall.sh:25-28 case 块；validate.sh 全仓 0 命中 | 卸载段改 `bash skills/task-planner/uninstall.sh`；验证段改 `bash skills/task-planner/lib/verify.sh` |
| D6-09 | P2 | INSTALL_zh.md:315 | 英文链接死链 `[English Install Guide](INSTALL.md) · [English README](README.md)` —— 仓根无 README.md/INSTALL.md | `ls` 根目录 + `test -e README.md` → MISSING | 删除该段或改指 README_zh/INSTALL_zh（与 README_zh:217「暂无独立英文文档」口径一致） |
| D6-10 | P2 | CLAUDE.md:25-30; CONTRIBUTING.md:19-23; CONTRIBUTING_zh.md:18-23 | 双份模板树漏 `templates/knowledge-brief.md`（第 6 计划文件，init-session.sh:340 六文件循环）；CLAUDE 树缺 reference.md/examples.md/INSTALL.md/README.md 同级文件非必须，但 knowledge-brief 属功能面遗漏 | init-session.sh:340 `for f in task_plan.md findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md` | 三处树补 knowledge-brief.md 行（与 sub:3 P-1「5 文件锚过期」同根，主侧树面） |
| D6-11 | P2 | README_zh.md:136,229; CLAUDE.md:32 | 「Rules 1-39」索引锚过期，实测 critical-rules.md 主编号至 Rule 44（:393/404/415/430/439） | `grep -nE '^### 4[0-4]' references/critical-rules.md` → 40/41/42/43/44 五行 | 三处改「Rules 1-44」（与 sub:3 P-4 家族同源同改，含 selftest 机器锚） |
| D6-12 | P2 | README_zh.md:153 | 「init-session.sh ← 创建 plans/task-XXX/ 及 5 个模板文件」实测 6/6（knowledge-brief.md 第 6 文件，init-session.sh:351 `6/6 planning files verified`） | init-session.sh:3/:338/:351 | 改「6 个模板文件」 |
| D6-13 | P2 | CONTRIBUTING.md:10-25; CONTRIBUTING_zh.md:9-25; README_zh.md:94-140 | 根目录树不全：CONTRIBUTING 双份漏 LICENSE/README_zh/INSTALL_zh/CHANGELOG（README_zh 树漏 LICENSE 单列）；实测根含 LICENSE/.claude/.zcode/progress.md（git tracked，sub:6 发现 plans/ git tracked，与 CONTRIBUTING:24「plans/ gitignored」断言不符——.gitignore 无 plans/ 条目） | `ls -A` 根目录；`git ls-files plans/ \| head` → plans/INDEX.md 等 tracked；`.gitignore` 全文无 `plans/` | CONTRIBUTING 树补 4 根 md + LICENSE；「plans/ (gitignored)」改注「plans/ 多数归档文件入库，运行时指针文件 .session-owner 等 gitignore」 |
| D6-14 | P2 | INSTALL_zh.md:309 | 「总大小约 1.3 MB」实测 `du -sh skills/task-planner` → 2.0M | du 输出 | 刷新为 ≈2.0MB |
| D6-15 | P2 | INSTALL_zh.md:61-63 | 前置依赖表「python3 ≥ 3.8: session-catchup.py + JSON 验证」基于 .py 假设（见 D6-02），实测仓内 .py 仅 1 个（plan-resume score-plans.py，非 task-planner 本体） | find 证据同 D6-02 | 同 D6-02 修复后此表行删改 |
| D6-16 | P2 | CHANGELOG.md:89 | 指针 `skills/task-planner/docs/ARCHITECTURE.md §2.6` 实存 ✓（ARCHITECTURE.md:115 `### 2.6 Companion 同步器设计决策`）——负结果项，无问题；但同段「2026-09-16 task-v074 P10 修正原悬空章节号 §4.5.2」说明历史悬空已修，本项仅记录核验通过 | grep 命中 | 无需修复 |
| D6-17 | P2 | README_zh.md:62 | 「默认安装位置：~/.claude/skills/task-planner/。可通过 --target DIR 自定义」——install.sh 无 --target flag（实测 flag 见 D6-07），--target 幽灵参数 | install.sh:34-38 | 同 D6-07 修复 |
| D6-18 | P2 | INSTALL_zh.md:285 | 「55 个」清单自注「含 .ps1/.py/.ts 镜像」——.py 镜像不存在（session-catchup 为 .ts），口径错 | find .py 证据 | 刷新时一并修正 |
| D6-19 | P2 | CHANGELOG.md:119,121,125 | 2.0.0 条目称仓根新增 `README.md`/`INSTALL.md`——commit 2337ce0（refactor: move v2 multi-tool work into skills/task-planner/ subdir）将其移入 skills/task-planner/ 并删去仓根英文版，CHANGELOG 无「### 删除」回填（git 已证实，非待复核） | `git log --diff-filter=D --oneline -- README.md INSTALL.md` → `2337ce0 refactor: move v2 multi-tool work into skills/task-planner/ subdir`；`ls skills/task-planner/README.md skills/task-planner/INSTALL.md` → 均实存 | CHANGELOG [Unreleased]「删除」段补记仓根英文文档移除；INSTALL_zh:315 死链改指 `skills/task-planner/INSTALL.md`/`README.md` |

## 负结果（核验通过项）
- README_zh.md:130 「variant/ 16 个 template_type 变体（含 mini-lite/rule-enhancement/video/video-fix）」✓ 与实测 16 一致
- README_zh.md:242-251 config.json 9 键示例全部实存（properties 40 键含这 9 键），prompt_max_chars=3000 ✓（config.json:422）
- README_zh.md:114 「companion/agents/ 3 个伴生 agent」✓（plan-writer/article-batch-publisher/article-field-fixer）
- README_zh.md:139 billing.md → ../plan-cost-guard/references/billing.md 软链注记 ✓（billing.md 实位 plan-cost-guard/references/）
- INSTALL_zh.md:307 「companion agent 变更后需重跑 lib/install-companion.sh」✓ lib/install-companion.sh 实存（8575B）
- CONTRIBUTING 双份 scripts/ 树（install/uninstall/validate 三文件列于「仓库根 scripts/」）与 D6-01 同根，已并入 D6-01
- 6 文档内未发现版本断言（v2.0.0/1.0.0 仅 CHANGELOG 历史条目，与 git tag 面不在本次三维范围）
- 技能数 10/池 11/42 selftest/75 脚本基线在本次对拍中作为基准复测确认，6 文档中无直接声称这些数字的锚（除 INSTALL_zh 过期的 55/19/13/12 已列入 D6-03..05）

## 最终结论
```
status: done
acceptance: 3/3 pass — [1:三维结论 2:问题清单格式合规 3:检查点落盘]
files: /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/6-executor.md(+1/0); /mnt/data/dev/task-planner-skill/plans/task-v107/findings.md(+0/-0 追加段); /mnt/data/dev/task-planner-skill/plans/task-v107/progress.md(+0/-0 追加行)
evidence: README_zh.md:59 `bash scripts/install.sh` vs `find . -name install.sh` → 仅 ./skills/task-planner/install.sh; INSTALL_zh.md:296 「13 变体」vs `ls templates/variant/ | wc -l` → 16; INSTALL_zh.md:315 `[English Install Guide](INSTALL.md)` vs `test -e README.md` → MISSING; critical-rules.md:439 `### 44` vs README_zh.md:136/CLAUDE.md:32 「Rules 1-39」; init-session.sh:351 `[init] 6/6 planning files verified` vs README_zh.md:153 「5 个模板文件」; detect-tools.sh:18-22 五工具软壳 vs INSTALL_zh.md:3 「都安装到 ~/.claude/skills/task-planner/」
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v107/subagent-state/6-executor.md (status: done)
findings_written: #### [sub:6-executor] 根目录文档审查
blockers: none
confidence: HIGH
```
