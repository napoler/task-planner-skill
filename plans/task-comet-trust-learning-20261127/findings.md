<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-comet-trust-learning-20261127

- task_id: `task-comet-trust-learning-20261127`
- 时间: created_at=2026-11-26T22:41:31Z / updated_at=2026-11-27T04:30:23Z

## Requirements
- 从 Comet 提炼可信度机制并按地基→入口→出口融合进 task-planner
- 保住项目核心=长线会话记录的数据基础、长任务稳定性；底座不可拆
- 交付=设计spec+writing-plans实施计划；不改源码/不部署/不提交

## Findings
| id | text | source | tags |
|---|---|---|---|

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- Comet 可信度根因=把决策/验收/证据/状态/失败/恢复变成有归属有绑定有阻塞的显式协议；本项目缺消费侧门（SOFT_ONLY/假绿门/伪造证据判例） — 两子代理调研+主进程盘上抽查
- SDD Task1-2 完成：evidence_binding 字段注册（schema+planctl 校验面）与证据绑定校验门（path+sha256 双匹配、负控制）；reviewer 两轮各抓出真实缺陷并修复 — worktree commits 1933ee49/85ae068c/edd4cf91/782e70b9 + task-1/2 review 报告
- Task3 发现 brief 与 check-scope.sh 控制流冲突（节② plans/ 祖先 exit 0 提前放行），D6 裁决前移 abs_path+保护段；负控4派生MD全rc=1、正例rc=0、零新增FAIL — worktree commit 52e19f4e + task-3-report.md + D6 决策
- Task4 零断言guard落地：2历史零断言脚本补真断言(PASS=9/6)，guard 对假零断言rc=1/真断言rc=0，全量118/115/FAIL3 与基线一致、guard命中0 — worktree commit c293dd8a + task-4-report.md
- Task5 三态verdict落地：check-verdict.sh 要求 BLOCKED 须 confirmed:true；TDD红→绿+mutation；全量119/116/FAIL3 基线零新增；Total118→119 因新增selftest — worktree commit 06f00dd4 + task-5-report.md
- Phase2 完成：Task4 零断言guard（修绕过：标签前缀优先解析）、Task5 三态verdict（BLOCKED须confirmed:true），全量119/116/FAIL3基线零新增；reviewer 累计抓出并修复4类真实缺陷 — worktree commits 5ce7a24f/06f00dd4 + task-4/5 review
- Task6 用户门账本落地：decisions blocking/confirmed 双注册、check-complete 拒锁+fail-closed（修复5种权威源损坏形态rc2）、存量兼容；RED2/1→GREEN4/0，全量120/117/FAIL3零新增 — worktree commits 00636c3e/5f9059c6 + task-6 review
- 终审3必修由单 fixer 一次性修复：7b824116 verdict 跳模板字面行取末条真实 outcome；b47c85db 证据绑定按 recorded_at/version 选当前条目+planctl (path,version) 审计追加；115dea34 缓存 p=f=0 时实跑取真实输出供断言守卫。主进程复跑：verdict 模板+BLOCKED 未确认 rc1/已确认 rc0；针对性 selftest 4/0、6/0、9/0；bash -n 与 py_compile OK — worktree d44ca180..115dea34 diff + 主进程复跑
- 修复后复审 READY TO MERGE（三必修判别探针全通过、无新增假绿）；最终通读 PARTIAL→审查实物同步修订 dfac9677（verdict/evidence-binding review 计数与判别口径对齐代码）；merged 74bab18f；install.sh --no-backup 后默认 4 位 verify 27 pass/4 fail（4 项 hardcoded paths 为既有基线），22 变更文件中 19 个 skills 文件在 4 位逐字节 IDENTICAL — re-review agent_02b6448a + readthrough agent_25d55a82 + git log + verify log /tmp/comet-install.log + 全文件 cmp 循环

## Technical Decisions
| Decision | Rationale |
|---|---|
| 交付范围=方案+writing-plans；优先级=地基优先（状态/证据→验收→决策/断点）；第3-6节设计全部通过 | 用户 AskUserQuestion 三次选定；两侧根因调研独立收敛到消费侧门优先 |
| 用户追加要求：真正开始前先打 Git 阶段性 tag（大范围重构基线锚点）。tag 沿用既有轻量风格，命名 baseline-before-comet-trust-refactor-20261127-064717，指向当前 HEAD ced991e4 | 重构涉及面广需可追溯/可回退锚点；tag 只指向已提交 commit，不纳入 28 项未提交变更（含他任务杂物） |
| [tier-upgrade] 运行 59 分钟，触发原因：步骤门：findings/research（软阈值 15min / 硬阈值 45min），自动升级 standard 检查面 | 用户 2026-11-24/25 裁决：软阈值15min须联合步骤门(phase complete/findings/delegations) 或 硬阈值45min兜底，零主观判断 |
| 本阶段设计/计划文档（spec 措辞修正 + writing-plans 实施计划）在 docs/ 下产出，豁免 worktree 隔离 | 宪法 §11.5②纯文档非实现类 + 用户明确交付=方案+实施计划；本阶段不改任何 skills/ 源码、不部署、不提交；worktree 从 master checkout 看不到未提交的 spec 文档，隔离无意义 |
| worktree-required 门与 SOP §158（文档留主仓）冲突，经用户授权用 Bash heredoc 落盘设计过程文档；仅 docs/superpowers/ 两份，不动 skills/ 源码 | 门把过程文档误分类为 delivery=1；实现阶段（Task 0 Step3 起）仍严格在 worktree 内进行 |
| Task 4 为 2 个历史零断言 selftest（user-instruction-priority/verify-io）补真断言后再启用零断言 guard，保持回归 FAIL==基线2 | 用户裁决：避免破坏回归判据且真正消除假绿；基线实测 selftest 117/115/2、verify 27/4 |
| Task3 brief 插入位置与盘上控制流冲突：check-scope.sh 节② walk-up(:73-81)对 plans/ 祖先路径直接 exit 0，保护段插其后必失效；裁决采纳 implementer 选项0——把 abs_path 计算+派生MD保护段前移到节②(:71)之前，仅对4个派生MD收紧，其余 plans/ 放行语义不变 | controller 盘上复查证实(:71 abs_path、:73-81 早退、:90-92 basename豁免、:183 真锚点)；属执行细节技术修正非G门用户决策；负控rc=1唯一有效位置 |
| 终审 NEEDS FIX：3 必修（P0 check-verdict 取首个 outcome 致模板字面行假绿；P0 check-evidence-binding 不读 version/recorded_at 致旧 hash 放行；P1 run-selftests 缓存合成 0/0 致幻影 FAIL）；按 SDD 派 ONE fixer 一次性修复，保留 Minor 到后续独立任务 | 终审实测复现三缺陷；逐条派修复违反 SDD 单 fixer 规则；三项均不改 Total=121 |
| 部署对账范围按 install.sh 默认 4 位（zcode/claude/opencode/cursor）；~/.agents 位按 smart-merge-back.sh :615/:850 明示为全局保护区、需 TASK_PLANNER_DEPLOY_SLOTS env 显式覆盖，未经授权不直写，登记为已知边界 | 宪法 §六/项目 AGENTS §2：部署位只走 install.sh 官方链路；.agents 明确排除默认部署，避免越权投毒 |

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
