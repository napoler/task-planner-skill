# 4-aligner checkpoint — task-v117 对齐审查（alignment-review, fresh 上下文，2026-10-02）

审查人: aligner 子代理（只读，未改仓内任何文件；本 checkpoint=写入面唯一例外）
审查对象: master a54e60e（task-v117 已合并：P1 321ae79 + P2 7b9ff95 + P3 d03d498 + merge a54e60e）
知识底座: plans/task-v117/knowledge-brief.md §2/§4/§5

## 三组验收面结果

### G1 口径一致性 — PASS
- `grep -rn '13 变体' CONTRIBUTING.md CONTRIBUTING_zh.md CLAUDE.md skills/` → rc=1 0 命中 ✅
  （全仓 '13 变体' 残留仅存 CHANGELOG.md:52 历史条目〔v074 P10 叙事，历史段豁免〕+ plans/ 历史任务目录〔非判定面〕）
- `grep -rn 'validate\.sh'` 同域 → rc=1 0 命中；CHANGELOG.md:117,134 与 `[2.0.0]` 段 `--target/--force` 属历史条目（v1.0 旧安装器），豁免 ✅
- `--force` 命中面甄别:
  - skills/task-planner/INSTALL.md:148 = `install-companion.sh` 的 flag 面——lib/install-companion.sh:32 实 flag 集含 `--force`，非幽灵 ✅
  - allow-direct.sh ×11 / smart-merge-back.sh ×7 / selftest-smart-merge.sh ×5 / check-delegation.sh / zcode-pretooluse.sh = 该工具真实 flag（zcode-pretooluse.sh:50 提示语「加 --force」与 allow-direct.sh 实位一致）✅
  - CONTRIBUTING(_zh).md 判定面 0 命中 ✅（P1 S4 修复面确认）
- `py_compile` 命中: CONTRIBUTING.md:73,115 / CONTRIBUTING_zh.md:73,115 = Python 章节的通用 Python 脚本断言。仓内真实存在 skills/plan-resume/scripts/score-plans.py（find . -name '*.py' 实测），断言非幽灵。P1 清账对象 R-10=CLAUDE.md「py_compile session-catchup.py」幽灵行，实测 CLAUDE.md:79 已为 `bun skills/task-planner/scripts/session-catchup.ts`（v117 R-10 清账注记在位）✅
- C-P6 session-catchup 全路径口径: CLAUDE.md:79 单点实测统一「task-planner scripts/session-catchup.ts」全路径 ✅

### G2 部署面 — PASS
- `diff -rq` 仓 skills/{task-planner,plan-cost-guard,plan-template-kit,plan-resume} vs 三宿主（~/.zcode / ~/.claude / ~/.config/opencode）各一次：
  唯一输出 = task-planner/companion 仓内独有 `.backup-20261001-071943`、`.backup-20261001-071945`（=计划豁免面，findings.md:51「companion/ .backup-* gitignore 覆盖可择机清理」同源）；**零 differ 行** ✅
- VC-5 锚: selftest-workflow-orchestration.sh md5 四位一致 = 7b120cf4b0b4c725f8271c41b400cf43（仓 + zcode + claude + opencode）✅
- worktree 残留: `git worktree list` 仅主 worktree a54e60e [master]；`git branch | grep 'wt/'` 0 条 → 11.3-5 清理在位 ✅
- 宿主独有内容未被改动（diff 无宿主侧 Only in / differ）✅

### G3 数字/计数面 — PASS
- INSTALL_zh.md:310 口径行「39 个模板、29 类 variant、81 项 scripts、8 个 references」vs 实测:
  - variant: `ls skills/task-planner/templates/variant/*.md | wc -l` = 29 ✅
  - 模板: `find templates -name '*.md'` = 39（顶层 10 + variant 29）✅
  - 脚本: `ls skills/task-planner/scripts/ | wc -l` = 81 ✅
- SKILL.md:9 frontmatter「Critical Rules 全集 1-45」具名 37-45（37 任务类型机制画像/38 任务难度分级/39 动态工作流编排/40 harness/41 自主消解/42 质量审查/43 执行可靠性/44 自动超时/45 注释完整性）；正文 :305 索引面「Critical Rules 1-39（…Rule 37…Rule 45）」同口径（v116 括注式写法，progress.md:73 已登记）✅
- WF-10 四索引 grep 实测: `Rules 1-39`（SKILL.md 2:247,305 + skills/task-planner/README.md 1:67 + CLAUDE.md 1:33）= 4；`Rules 1-45`（README_zh.md 2:136,229）= 2；合计 **6 ≥ 6 压线达标（零余量，与 knowledge-brief §2「WF-10 压线 6=6」一致）** ✅
- P3 三守卫口径扩展实测在位（d03d498，15+/9-，断言语义零改动，label「[task-v117 口径扩展]」在位）:
  - RT-08 selftest-ask-default-timeout.sh:59-63: `grep -E '1-4[0-9]' | grep -vcE '1-45'` 加白范式 ✅
  - CD-12 selftest-conclusion-discipline.sh:68-69: 1-34 反回退锚保留 ✅
  - PT-08 selftest-plan-tier.sh:74-76: 字面锚改「Critical Rules 全集 1-45」grep ✅
- VC-3 双区块抽查: `grep -L` 委派统计/Handoff 登记表 = 仅 mini-lite-type.md 缺委派统计（Rule 38.3 设计豁免，progress.md:77 留痕在位）✅

### 负结果报告（检查了但无违规）
- `--force` 全仓甄别: 排除了 4 类命中可能性（install-companion 实 flag / 脚本实 flag / selftest 夹具 / CONTRIBUTING 判定面）——无一幽灵
- py_compile 4 处命中: 排除 session-catchup 幽灵可能性（P1 已清，CLAUDE.md:79 bun 口径在位）
- 部署 diff: 排除 4×3 组合下任何宿主侧漂移——仅仓内 .backup 目录豁免项
- 计划面: plans/ 目录 grep 命中全部属历史任务记录（v074/v082/v107/v116/v117 自身），非判定面

## 结论
**PASS** — 三组验收面（G1 口径一致性 / G2 部署面 / G3 数字计数面）全过；P3 三守卫扩展口径在位；WF-10 压线 6=6 零余量登记为已知风险（非本任务引入，CD-12 双锚同步压线）。

## 追加复验（checkpoint 写入后补做）
- T-2 双区块全量复验: variant=29；缺「委派统计」= 仅 mini-lite-type.md（Rule 38.3 豁免）；缺「Handoff」= 0 家 → 委派统计 28/29 + Handoff 29/29（mini-lite 既有简化表，与 progress.md:78 口径一致）✅
- `py_compile.*session-catchup` 全仓（.md/.sh 判定面）= 0 命中（rc=1）✅ R-10 清账确认
- 主仓 porcelain: 仅 plans/ 计划系统未提交面（plans/task-v116/.dispatch-inflight、plans/task-v117/、60-explore checkpoint 未入库），属 S5 计划系统白名单② 待 commit 面，非 skills 面漂移 ✅
