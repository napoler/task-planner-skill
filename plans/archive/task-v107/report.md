# task-v107 深度审查报告（内容质量 / 稳定性 / 执行与部署）

日期 2026-10-02 · 执行体 sub:8-executor（汇总）· 结论源 = 8 份 checkpoint + findings.md（全部只读材料）· v107-对齐审查修正：条目计数以 §3 表格数据行实数为准（42 条 = EX-1×1 + P1×7 + P2×27 + 待复核×5 + 核验通过/负结果×2；sub:10 抓出「44 条」漂移已更正）

## 1. 执行摘要

- 审查范围：task-planner 项目 10 skill（主 + 9 卫星）× 文档面/脚本面/部署位三维；材料 = Phase 1 机械回归 + Phase 2 四波内容审查 + Phase 3 三宿主 diff 对账。
- 方法：42 selftest 逐脚本回归（v106 基线 660/0 对照）+ bash -n 语法扫描 75 脚本 + diff -rq 部署对账 + 四维文档审查（引用实存/计数锚/结构/过期数字），每条断言附 grep/find 第一手证据。
- 稳定性结论：全绿——75 脚本 0 语法 FAIL；42/42 selftest rc=0，PASS 660 / FAIL 0，与 v106 基线完全一致。
- 内容质量结论：四波合计 **42 条条目（P1×7 / P2×27 / 待复核×5 / 核验通过或负结果×2，口径=§3 表格数据行）**，主进程抽验全证实；缺陷集中于「计数锚漂移链 + 安装口径文档簇」。
- 执行维结论：「第二套部署缺 8 技能」误判已证伪撤销（~/.opencode 为 ~/.config/opencode 软链，单一活跃部署）；关键实存问题 = **~/.zcode 位 videop1 双向漂移（部署位 28 variant vs 主仓 16）**，本会话 skill 加载源即 .zcode 位，影响面最高。
- 处置：授权修复候选 R-01~R-15（主仓文档面，Phase 5 worktree 隔离逐项授权）；跨项目归属（videop1 12 variant 回流与否）与 4 项待复核列待裁决清单。
- 本报告本身为 Phase 4 产出，Phase 6 须 alignment-review 收尾 + 变更记录三要素（§6）。

## 2. 三维分节

### 2.1 内容质量（Phase 2 四波）
- 波1 主文档面（sub:3）：SKILL.md + critical-rules.md 五维。编号面全干净（Rule 1-44 连续、C1-C33 连续、19 条引用路径全实存）；问题在计数锚（5 文件/21/13 过期）与「Rules 1-39（含 40-44）」括注矛盾。
- 波2 references+templates（sub:4）：task_plan 模板 worktree_path 旧约定、knowledge-brief 计数 20≠22；config 11 键对拍全 PASS。
- 波3 卫星 9 技能（sub:5）：plan-cost-guard 17.5「>15 STOP」主侧无源（P1）；6 技能零问题。
- 波4 根目录 6 文档（sub:6）：19 项，根级 scripts/ 口径全面失效 + session-catchup.py 幽灵（P1×2）；INSTALL_zh 安装清单整簇过期（13 变体/37 键/55 脚本/1.3MB 全 ≠ 实测）。
- 根因合并呈现（互引）：① 计数漂移链 20→21→22（波2 P1-2 ⟷ 波1 P-2，grep 锚随 variant 沉淀未回写）；② variant 13→16 链（波1 P-3 ⟷ 波4 D6-03）；③「Rules 1-N」过期链 P-4/P2-3/D6-11（机器锚 WF-10「1-39」为 v097 宽容设计，改需连 selftest 同改）；④「5→6 文件」链 P-1/D6-10/D6-12；⑤ session-catchup 口径链 D6-02/C-P6。

### 2.2 稳定性（Phase 1 回归）
- 75 脚本 bash -n：0 FAIL（checkpoint 1-code-runner）。
- 42/42 selftest rc=0、PASS 660/FAIL 0，与 v106 基线一致；特例 selftest-final-gate-hash.sh 无 Total 行（结果行 PASS=22 已计入）（checkpoint 2-code-runner）。
- 结论：机械守卫面（RL/R 系列 + registry 42=42）在当前 HEAD 全绿，v106 交付未回退。

### 2.3 执行与部署（Phase 3 对账，含 videop1 分叉披露）
- .claude / .opencode 位：9/10 IDENTICAL；task-planner 仅主仓多 2 个 .backup-20261001-* 目录；plan-resume 主仓独有 tests/（不部署，正常）。
- **~/.zcode 位（本会话 skill 加载源）= 双向漂移 P1-高（EX-1）**：task-planner 内容 differ（plan-writer.md、selftest-template-lifecycle.sh），且部署位多 **12 个 templates/variant/*-type.md（28 vs 主仓 16，videop1 视频家族线在部署位就地迭代）**；plan-template-kit template-guide/template-mapping differ。影响面：.zcode 宿主加载的 task-planner 与主仓规则已分叉，双向风险=主仓修复不回灌 / 部署位新规则不进主仓与 selftest。
- 池软链 33/33 健康（11 池×3 宿主，相对软链全实存、目标字符串一致）。
- 误判撤销：findings [sub:S3]「~/.config/opencode/skills 第二套旧部署缺 8 技能」证伪——~/.opencode 软链 → ~/.config/opencode 同 inode 3436922，单一活跃部署，Rule 44 在位（checkpoint 7-executor）。

## 3. 问题总表（全量，含证据出处；严重度沿用各波判定）

### 3.1 执行维
| ID | 严重度 | 锚点 | 一句话 | 证据出处 | 修复建议 |
|----|--------|------|--------|----------|----------|
| EX-1 | P1-高 | ~/.zcode/skills/task-planner/templates/variant/（28 vs 主仓 16）+ companion/agents/plan-writer.md + scripts/selftest-template-lifecycle.sh + plan-template-kit/references/{template-guide,template-mapping}.md | videop1 项目线在 .zcode 位就地迭代 12 variant，与主仓双向分叉；本会话加载源即 .zcode | checkpoint 7（diff -rq 原文 /tmp/sub7-diff.log） | 裁决归属后走 install-companion/smart-merge-back 单向归一（见 §5 跨项目项） |

### 3.2 波1 主文档面（P1×2 / P2×4）
| ID | 严重度 | 锚点 | 一句话 | 证据出处 | 修复建议 |
|----|--------|------|--------|----------|----------|
| P-1 | P1 | skills/task-planner/SKILL.md:64 | 「5 个文件」验证锚过期，init-session.sh:3/:210 实测建 6（v067 加 knowledge-brief.md） | checkpoint 3 §P-1 | :64 改 6 文件并补 knowledge-brief.md |
| P-2 | P1 | critical-rules.md:75（Rule 16） | 验收锚 grep -rl … wc -l = 21，实测 22，机械执行会误判 FAIL | checkpoint 3 §P-2 | 锚值 21→22（与波2 P1-2 同根同改） |
| P-3 | P2 | critical-rules.md:361/:317 | 「13 个 variant/13 变体」vs 实测 16 | checkpoint 3 §P-3 | 13→16 或注明 standard 档排除清单 |
| P-4 | P2 | SKILL.md:246/:304 | 「Rules 1-39（含 40-44）」逻辑矛盾；「1-39」为 selftest WF-10 机器锚 | checkpoint 3 §P-4 | 收敛 1-44 须同源改 WF-10（selftest-workflow-orchestration.sh:52-57）+4 索引文档；或保留机器锚改括注口径（待裁决） |
| P-5 | P2 待复核 | SKILL.md:9 frontmatter | references 摘要仅枚举至 Rule 36，37-44 未列，是否属索引面口径存疑 | checkpoint 3 §P-5 | 裁决索引面口径后补齐或豁免 |
| P-6 | P2 待复核 | task_plan 知识储备行（:61） | 引 skills/task-planner/scripts/install-companion.sh 实测 MISSING（实位 lib/，主进程已修计划） | checkpoint 3 §P-6 | 已修；报告留痕即可 |

### 3.3 波2 references+templates（P1×2 / P2×6 / 待复核×2）
| ID | 严重度 | 锚点 | 一句话 | 证据出处 | 修复建议 |
|----|--------|------|--------|----------|----------|
| P1-1 | P1 | templates/task_plan.md:249 | worktree_path 示例仍旧约定 `../<repo>-wt-*`，宪法 §11.2 已立新规范 | checkpoint 4 §P1-1 | 改 `<repo-parent>/<repo>-worktrees/<task-id>`，与 worktree-isolation.md:37 同文 |
| P1-2 | P1 | templates/knowledge-brief.md:9 | grep 锚计数「维持 20」过期，实测 22（与 P-2 同根）；卫星 template-guide:77 已写 22 | checkpoint 4 §P1-2 | 20→22 与 template-guide 同源改 |
| P2-1 | P2 | references/worktree-isolation.md:46+71 | 双「## 4.」章节号 | checkpoint 4 §P2-1 | 改 4/5/6 连续编序 |
| P2-2 | P2 | references/methodology.md:4/:232 | SKILL.md:82/:159/:81/:156 行号锚偏移（实测 :76/:153） | checkpoint 4 §P2-2 | 去行号改章节名锚 |
| P2-3 | P2 | references/batch-quality-gate.md:135 | 「隶属 Rules 1-36」与现行 1-44 脱节（P-4 同家族） | checkpoint 4 §P2-3 | 去「1-36」或改 1-44 措辞 |
| P2-4 | P2 | references/batch-quality-gate.md:111 | 「publish 唯一提到批量的 variant」过期（video:63/video-fix:91,96 亦含） | checkpoint 4 §P2-4 | 改「publish/video/video-fix」 |
| P2-5 | P2 | references/dispatch-examples.md:5 | 「DX-01..DX-03 守护」vs selftest-dispatch.sh 实测 DX-01..DX-05b | checkpoint 4 §P2-5 | 改「DX-01..DX-05b」 |
| P2-6 | P2 | templates/variant/{diagnostic,publish,research,writing}-type.md 头 4 行 | 4 文件缺 `<!-- template_type: X -->` 注释行（12/16 有），gate 不受影响但形态不统一 | checkpoint 4 §P2-6 | 补 4 行注释声明 |
| T-1 | 待复核 | writing:11-12 / research:14 / publish:15,34,90 | VC 表引 4 个不存在脚本（article_json_editor.py 等，全仓 find 0 命中），疑为目标项目侧示例值 | checkpoint 4 §T-1 | 裁决：加「示例值（目标项目相对）」注脚而非删除 |
| T-2 | 待复核 | 8 个 13 节标准 variant | 缺委派统计/Handoff 登记/Drift Log 区块（主模板有；Rule 25.4/22.5 措辞「必填」） | checkpoint 4 §T-2 | 主进程确认 plan-writer 是否补全；若模板即终态则升 P1 |

### 3.4 波3 卫星 9 技能（P1×1 / P2×4 / 待复核×1）
| ID | 严重度 | 锚点 | 一句话 | 证据出处 | 修复建议 |
|----|--------|------|--------|----------|----------|
| C-P1 | P1 | plan-cost-guard/SKILL.md:21 | 17.5「>15 次强制 STOP」主侧 critical-rules.md:84 无源（仅 ≥10 AskUserQuestion） | checkpoint 5 §C-P1 | 删「>15 强制 STOP」或主侧增补该档（同源同改，v093 教训）；cost-control.md:33 三处口径统一 |
| C-P2 | P2 | plan-cost-guard/references/{cost-control.md:168,cost_log.md:69} + plan-template-kit/references/template-mapping.md:26 | 卫星侧裸 `references/critical-rules.md` 指针落空 | checkpoint 5 §C-P2 | 改 `../task-planner/references/critical-rules.md` |
| C-P3 | P2 | plan-template-kit/references/template-mapping.md:31-44/:128-146 | 枚举 14 < 实测 16（缺 video-type、mini-lite-type） | checkpoint 5 §C-P3 | §一 补 2 文件 + §六 补 2 速查行 |
| C-P4 | P2 | plan-template-kit/references/template-guide.md:63/:65 | 「26 个 .md」「23/26」过期（实测 25；:69/:77 锚=22 三口径互斥） | checkpoint 5 §C-P4 | :63 改 25、:65 改 22/25 |
| C-P5 | P2 | progress-tracker/SKILL.md:192 | 边界表引幽灵技能 plan-bookkeeper（仓+三部署位均无） | checkpoint 5 §C-P5 | 改指实存承接方（task-planner 主进程簿记职能）或注「已移除」 |
| C-P6 | 待复核 | plan-resume/SKILL.md:246 + plan-cost-guard/references/billing.md:40,58 + task-planner/SKILL.md:57 | session-catchup 技能名/脚本名混用（实为 scripts/session-catchup.ts） | checkpoint 5 §C-P6 | 三处统一「task-planner scripts/session-catchup.ts」口径 |

### 3.5 波4 根目录 6 文档（P1×2 / P2×17）
| ID | 严重度 | 锚点 | 一句话 | 证据出处 | 修复建议 |
|----|--------|------|--------|----------|----------|
| D6-01 | P1 | README_zh.md:59/67/266; CONTRIBUTING*.md dev-loop/PR 段 | 根级 `bash scripts/{install,validate,uninstall}.sh` 全失效（根无 scripts/；实位 skills/task-planner/；validate.sh 不存在=lib/verify.sh） | checkpoint 6 §D6-01 | 命令改 `skills/task-planner/install.sh` + `lib/verify.sh` 口径 |
| D6-02 | P1 | README_zh.md:46/80/150; INSTALL_zh.md:61/239-245 | session-catchup.py 幽灵（实为 .ts；仓内 .py 仅 1 个 score-plans.py） | checkpoint 6 §D6-02 | 三处改 .ts + node/bun 运行时口径 |
| D6-03 | P2 | INSTALL_zh.md:296-299 | 「13 变体」（缺 mini-lite/video/video-fix）vs 实测 16 | checkpoint 6 §D6-03 | 清单刷新 16 全枚举（与 P-3 同根） |
| D6-04 | P2 | INSTALL_zh.md:300-303 | 「references 12」混入卫星 4 文件，主侧实 8 | checkpoint 6 §D6-04 | 拆「主 8 + 卫星 4 组」或注明归并口径 |
| D6-05 | P2 | INSTALL_zh.md:285-291 | 「scripts 55 / selftest×19」vs 实测 81 项 / 42 | checkpoint 6 §D6-05 | 刷新或写「以 ls 为准」+日期 |
| D6-06 | P2 | INSTALL_zh.md:282 | 「config.json 37 键」vs properties=40（WF-13 同源锚） | checkpoint 6 §D6-06 | 改 40 |
| D6-07 | P2 | INSTALL_zh.md:3 | 「都装到 ~/.claude 单目录」vs 实为 5 工具 per-tool 软壳（detect-tools.sh:18-22） | checkpoint 6 §D6-07 | 改「按检测工具各装软壳」 |
| D6-08 | P2 | INSTALL_zh.md:42-47/166-175/258/263 | 卸载/验证命令幽灵（uninstall 实 flag 集、validate.sh 不存在） | checkpoint 6 §D6-08 | 改 skills/task-planner/ 下实位命令 |
| D6-09 | P2 | INSTALL_zh.md:315 | 英文链接死链 INSTALL.md/README.md（根 0 命中；与 README_zh:217 矛盾） | checkpoint 6 §D6-09 | 删段或改指 skills/task-planner/ 下实存英文版 |
| D6-10 | P2 | CLAUDE.md:25-30 + CONTRIBUTING*.md 树 | 模板树漏 knowledge-brief.md（第 6 计划文件，与 P-1 同根） | checkpoint 6 §D6-10 | 三处树补 1 行 |
| D6-11 | P2 | README_zh.md:136/229 + CLAUDE.md:32 | 「Rules 1-39」过期，实测至 44（P-4 家族） | checkpoint 6 §D6-11 | 三处改 1-44（机器锚同源，待裁决） |
| D6-12 | P2 | README_zh.md:153 | 「5 个模板文件」vs init-session 6/6 | checkpoint 6 §D6-12 | 改 6 |
| D6-13 | P2 | CONTRIBUTING*.md 树 + README_zh 树 + CONTRIBUTING:24 | 根树漏 LICENSE/4 根 md；「plans/ gitignored」与 git 实态矛盾 | checkpoint 6 §D6-13 | 补树 + 改 plans/ 注记 |
| D6-14 | P2 | INSTALL_zh.md:309 | 「总大小约 1.3 MB」vs du 2.0M | checkpoint 6 §D6-14 | 改 ≈2.0MB |
| D6-15 | P2 | INSTALL_zh.md:61-63 | python3≥3.8 前置基于 .py 假设（并入 D6-02） | checkpoint 6 §D6-15 | 随 D6-02 修 |
| D6-16 | P2（负结果） | CHANGELOG.md:89 | ARCHITECTURE.md §2.6 指针实存——核验通过，无问题 | checkpoint 6 §D6-16 | 无需修复 |
| D6-17 | P2 | README_zh.md:62 | 「--target DIR 自定义」幽灵参数（实 flag 无 --target） | checkpoint 6 §D6-17 | 随 D6-07 修 |
| D6-18 | P2 | INSTALL_zh.md:285 | 「含 .py 镜像」口径错（实为 .ts） | checkpoint 6 §D6-18 | 随 D6-02/D6-05 一并刷 |
| D6-19 | P2（待复核→已查证） | CHANGELOG.md:119,121,125 | 2.0.0 称新增仓根 README.md/INSTALL.md，git log 2337ce0 已移入 skills/task-planner/ 并删仓根英文版，CHANGELOG 无「删除」回填 | checkpoint 6 §D6-19 | CHANGELOG [Unreleased] 补「删除」段 |

## 4. 授权修复候选清单（Phase 5，D6 逐项授权；均限主仓 skills/ 与根 md，锚点+修法明确）

> 排除：EX-1（跨项目归属，见 §5）；P-4/D6-11/P2-3 的「1-39」机器锚部分（涉 selftest WF-10 设计权衡，见 §5，仅括注措辞可修）。

| # | 波次映射 | 锚点 | 修法（一句话） |
|---|----------|------|----------------|
| R-01 | P-1, D6-10, D6-12 | SKILL.md:64 / CLAUDE.md:25-30 / CONTRIBUTING*.md 树 / README_zh.md:153 | 「5 文件」→「6 文件」并补 knowledge-brief.md 行（三处树 + 两处文案） |
| R-02 | P-2, P1-2 | critical-rules.md:75 / templates/knowledge-brief.md:9 / plan-template-kit template-guide.md（:63/:65 簇归 R-04） | 知识储备 grep 锚 21/20 → 22（与 template-guide:77 口径对齐） |
| R-03 | P1-1 | templates/task_plan.md:249 | worktree_path 示例改 `<repo-parent>/<repo>-worktrees/<task-id>`，同 worktree-isolation.md:37 |
| R-04 | C-P4, C-P3 | plan-template-kit/references/template-guide.md:63,65 / template-mapping.md:31-44,128-146 | 26→25、23/26→22/25；mapping §一 补 video/mini-lite 2 条 + §六 补 2 速查行 |
| R-05 | P-3, D6-03 | critical-rules.md:361,317 / INSTALL_zh.md:296-299 | 「13 variant」→16（含 mini-lite/video/video-fix 枚举刷新） |
| R-06 | C-P1 | plan-cost-guard/SKILL.md:21（+cost-control.md:33） | 删「>15 次强制 STOP」，与主侧 17.5（critical-rules.md:84 仅 ≥10 AskUserQuestion）对齐 |
| R-07 | C-P2 | cost-control.md:168 / cost_log.md:69 / template-mapping.md:26 | 裸 `references/critical-rules.md` → `../task-planner/references/critical-rules.md` |
| R-08 | C-P5 | progress-tracker/SKILL.md:192 | 边界表 plan-bookkeeper 行改指实存承接方或注「已移除」 |
| R-09 | D6-01 | README_zh.md:59/67/266 + CONTRIBUTING*.md dev-loop/PR 段 | 根级 `bash scripts/*.sh` → `bash skills/task-planner/install.sh` / `lib/verify.sh` / `uninstall.sh` 口径 |
| R-10 | D6-02, D6-15, D6-18 | README_zh.md:46/80/150 / INSTALL_zh.md:61,239-245 | session-catchup.py → session-catchup.ts + node/bun 口径；python3 前置行删/改可选 |
| R-11 | D6-04, D6-05, D6-06, D6-14 | INSTALL_zh.md:282-309 | 安装清单刷新：refs 主 8+卫星 4 / scripts 81 项 42 selftest / config 40 键 / ≈2.0MB（含核对日期 2026-10-02） |
| R-12 | D6-07, D6-17 | INSTALL_zh.md:3 / README_zh.md:62 | 安装模型改「5 工具 per-tool 软壳」；删 --target 幽灵参数 |
| R-13 | D6-08 | INSTALL_zh.md 卸载/验证段 | 改 `skills/task-planner/uninstall.sh`（实 flag 集）+ `lib/verify.sh` |
| R-14 | D6-09, D6-19 | INSTALL_zh.md:315 / CHANGELOG.md [Unreleased] | 英文死链改指 `skills/task-planner/{INSTALL,README}.md`；CHANGELOG 补 2337ce0「删除」回填 |
| R-15 | P2-1..P2-6（波2 六条 P2） | worktree-isolation.md:46,71 / methodology.md:4,232 / batch-quality-gate.md:111,135 / dispatch-examples.md:5 / 4 variant 头 4 行 | 章节连续编序；去行号锚；批量 variant 枚举 publish/video/video-fix；「隶属」去 1-36；DX-01..DX-05b；补 4 行 template_type 注释 |

## 5. 待裁决清单（Phase 5 主进程/用户裁决）

1. **误判撤销记录**：findings [sub:S3]「~/.config/opencode/skills 第二套旧部署缺 8 技能」——Phase 3 证伪撤销（~/.opencode 软链 → ~/.config/opencode 同 inode 3436922，单一活跃部署，Rule 44 在位；checkpoint 7）。另 P-6 install-companion.sh 路径错已由主进程修计划（lib/ 非 scripts/）。
2. **设计权衡项**：SKILL.md:246/:304「Rules 1-39（含 40-44）」宽容锚措辞（v097 设计；「1-39」是 selftest WF-10 机器锚 selftest-workflow-orchestration.sh:52-57，断言命中≥6）。改 1-44 须连 WF-10 自测断言 + 4 索引文档（含 D6-11 三处 README/CLAUDE）同源同改——建议 Phase 5 单列一 D6 项，或维持机器锚仅修括注口径「（1-39 存量锚 + 40-44 新增）」。
3. **跨项目归属项（只列不修）**：EX-1 videop1 双向漂移——.zcode 位 task-planner 多出的 12 个 video 家族 variant（部署位 28 vs 主仓 16）+ plan-writer.md / selftest-template-lifecycle.sh / plan-template-kit 2 references 的内容分叉，属 videop1 项目线资产；回流与否及归一方向（install-companion 单向部署 or 主仓收编）须 videop1 侧与主仓侧共同裁决。
4. **待复核×4（实质待裁决口径；表格标注口径为待复核×5，差 1 = P-6 计划路径已由主进程处置留痕）**：P-5（SKILL.md:9 frontmatter 索引面口径）/ T-1（variant VC 表 4 脚本示例值口径，建议注脚）/ T-2（8 标准 variant 缺 3 区块，是否由 plan-writer 补全，否则升 P1）/ C-P6（session-catchup 三处口径统一）。
5. **异常记录（非本任务范围）**：~/.config/opencode/skills 下 `superpowers` 软链指向 superpowers/skills（checkpoint 7 记录项）。

## 6. 变更记录（42.6.3 三要素：what/why/how-verify）

| 变更 | what | why | 验证 |
|------|------|-----|------|
| 新建 plans/task-v107/report.md（本文件） | Phase 4 三维汇总 + P0-P2 问题总表 + R-01~R-15 候选 + 待裁决 | task_plan S1（VC-2/VC-3 载体） | Read 结构核六段齐备；主进程抽验 ≥3 条锚点复现 |
| task_plan.md / findings.md / progress.md 更新 | Phase 4 状态翻转（主进程）+ [sub:8] 行追加 + checkpoint 8 落盘 | Rule 19 三文件契约 | progress Phase 4 段含 [sub:8]；subagent-state/8-executor.md 含最终结论 8 字段块 |

> P0 级问题：本次三维审查未发现 P0（无数据丢失/不可恢复面）；最高级 = EX-1（执行维 P1-高）与 7 条内容面 P1。
