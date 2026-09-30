---
template_type: rule-enhancement
plan_tier: standard
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    executor: 4
    code-reviewer: 1
  estimated_opus_equivalent: 1.4
  estimated_savings_vs_naive: 0.8
---

# Task Plan: task-v100-review-library — 10 个通用质量审核技能兜底池（review-library）

<!--
  WHAT: 在 task-planner 内建 review-library 兜底池（10 个通用质量审核技能,随部署分发三平台）+ Rule 42.2 检测链插入兜底池层（三级→四级）+ SKILL C30 措辞同步 + selftest-review-library.sh 守护。
  WHY: 用户 2026-09-30 指令「补充10个通用的质量审核技能 用于后期没有覆盖时候进行兜底质量 提高质量」——v099 Rule 42 是按需检测制（缺口才补建）,本任务补上"预建通用兜底池"层:检测三级均未命中时先查内置池,池也没有才走 42.3 补建。
  Rule 32 禁令交互（登记）: v099 notepad 否决的是「每项目≥10 个固定配额」制度（用户自评"过于呆板"）;本指令为用户主动重提并细化=「一次性预建 10 个通用兜底技能」（语义不同:兜底池 vs 每项目配额）,按 Rule 32.4 新证据处置,出处已标注。
  交互模式: silent（/goal 自主会话延续）。
  B 类澄清（用户 2026-09-30 追加「十个不同的质量审查skill 覆盖不同的场景 比如 代码审查 撰写审查 图片审查 等」）: 点名场景=代码/撰写/图片;清单调整 performance-review→image-review（用户点名场景优先;性能面由 code-quality/general 覆盖）,登记于本头注+Decisions。
-->

## Goal
在 `skills/task-planner/review-library/` 内建 10 个通用质量审核技能（每个=SKILL.md,frontmatter+触发条件+审查清单+证据要求+输出合约 APPROVED/CHANGES_REQUESTED,各 40-70 行）,随 task-planner 部署分发三平台;Rule 42.2 检测链由三级扩为四级（插入「④ task-planner 内置 review-library 兜底池」层,位于环境 agents 与"缺口"之间）;SKILL.md C30 行措辞同步;新建 selftest-review-library.sh（RL-01..10）守护;全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL、push GitHub、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新建 10 个 SKILL.md=主审面+Rule 42.2 修订） |
| `session_id` | task-v100-review-library |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library` |
| `branch` | `wt/task-v100-review-library`（基线 master@539adcc,2026-09-30 实测） |
| `scope_files` | `skills/task-planner/review-library/**`(10 新技能); `references/critical-rules.md`(仅 42.2 行修订); `SKILL.md`(仅 C30 行措辞); `scripts/selftest-review-library.sh`(新); `scripts/selftest-registry.tsv`(+1) |
| `interaction_mode` | `silent` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|----------|
| VC-1 | review-library 恰 10 个技能目录,每个含 SKILL.md 且 frontmatter（name/description）+触发条件+审查清单+「APPROVED」输出合约四要素齐备;10 个 name 互异且与清单一致 | `ls review-library \| wc -l`=10;逐文件 frontmatter/四要素 grep;RL 断言 | worktree review-library/ + RL-01..04 |
| VC-2 | 10 个技能覆盖 10 类通用审核面：general/code-quality/test-quality/security/image/content-quality/documentation/data-quality/ui-quality/release（各 SKILL.md 内含该领域具体审查清单项 ≥8 条,非空壳） | 逐文件审查清单条目计数 ≥8;领域关键词 grep | review-library/ + RL-05 |
| VC-3 | Rule 42.2 检测链四级化:42.2 行含「④ task-planner 内置 review-library 兜底池」层且「均未命中=缺口」语义保留;标题「三级」→「四级」;既有①②③层原文零改动;C30 行「三级」措辞同步为四级（含兜底池） | grep 42.2 行四要素+C30 行;diff 证明 42.2 外 CRIT 零改动 | worktree CRIT:420 区 + RL-06/07 |
| VC-4 | 新 selftest-review-library.sh（RL-01..10）全 PASS 且 registry +1 双向一致;全量回归（40 脚本）0 FAIL 且总 PASS ≥ 628+12（主进程双形态求和定数） | bash 新 selftest + selftest-registry.sh + 全量求和 | progress.md Selftest Log |
| VC-5 | 合并部署 push 清理闭环:smart-merge-back --deploy 三位 IDENTICAL（含 review-library 分发到位:部署位 `ls review-library \| wc -l`=10）;push origin master 成功（ls-remote 终验）;worktree/branch 清理 0/0 | 部署位亲验 + push/ls-remote | progress.md Phase 4 |
| VC-6 | 边界零回归:CRIT 42.2 行外零改动（Rule 1-43 原文零触碰）;config.json 零改动;SKILL.md 仅 C30 行内改写;CR Gate（code-reviewer 隔离）APPROVED | git diff 面+CR 结论 | progress/CR checkpoint |

**终验规则**: 全 VC 通过 → COMPLETE;有遗留 → PARTIAL;≥1 VC 三次重试无效 → BLOCKED（升级前过 41.4 清单附「已尝试清单」）。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 新技能库 | `skills/task-planner/review-library/<10 目录>/SKILL.md`（新建,恰 10 个） | 其他任何新文件;用户级/项目级 skills 目录写入（兜底池只进 task-planner 内置,随部署分发） |
| 条款 | `references/critical-rules.md` :420 42.2 行改写（三级→四级+④层）+ :423 42.5 内「三级检测顺序锚」→「四级检测顺序锚」注释性同步（B 类扩围） | Rule 1-41 其余任何行;42.3-42.4/43.x 原文 |
| SKILL | `skills/task-planner/SKILL.md` C30 行「三级顺序」→「四级顺序（含内置兜底池）」+ :276 Rule 42 摘要行「三级顺序」→「四级顺序」（B 类扩围 2026-09-30:级联实测 4 处措辞非计划预估 2 处） | C30/C31/摘要行其他措辞 |
| 测试 | `scripts/selftest-review-library.sh`(新 R-01..10);`scripts/selftest-registry.tsv`(+1);`scripts/selftest-self-resolution.sh`（SR-12 动态口径根治,B 类扩围 2026-09-30:硬编码行数 40 被 v100 registry+1 打破——v099 同款第 2 次复发,改动态比较=脚本数+表头,断言语义等价且免未来级联） | 其他 selftest 脚本 |
| 配置 | （无） | config.json 零新键 |
| 计划 | `plans/task-v100-review-library/**` | 其他 plans/ |

**执行前自我检查:** [x] scope 内 [x] 有必要 [x] 用户明确要求（本任务即用户指令本体）

## 📚 必要知识储备
| 类别 | 名称 | 定位 | 必读 | 已确认 |
|------|------|------|------|--------|
| 内部 | Rule 42 全节（42.1-42.5+引言） | CRIT :414-432 | 必读 | ☑ |
| 内部 | C30 行现文 | SKILL :195 | 必读 | ☑ |
| 内部 | selftest-self-resolution.sh SR 范式 | scripts/ | 必读 | ☑ |
| 内部 | registry 四列格式 | tsv :1-40 | 参考 | ☑ |
| 内部 | v099 notepad 否决方案段（Rule 32 出处） | plans/task-v099/notepad-learnings.md | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: Rule 42 按需检测制在"三级均未命中"场景下需现场补建（慢）——预建 10 个通用兜底技能进 task-planner 内置池后,检测四级命中即可直接消费（快且质量稳定）,未覆盖场景兜底质量提高;10 个技能文件+检测链插入=问题解决,可交付。
- [x] 解决后能交付吗？能（池+检测链+守护+部署=交付）
- [x] 不解决其他白费吗？是（本任务唯一目标）
- [x] 方法清晰可执行？是（D2 已裁:10 目录+42.2 四级化+守护）

## Current Phase
（终态）Phase 5 complete — outcome: COMPLETE

## Next Step
交付报告呈示;簿记 push 收尾。
主进程建 worktree（@539adcc）+ worktree 内全量基线求和（双形态正则）落 progress.md。

## 🧰 工具选择与编排（Rule 40 计划期分析）

| Phase | 命中工具面 | 理由 |
|-------|-----------|------|
| P1 | ①git 编排+③机械验证+②簿记 | worktree/基线求和白名单 |
| P2 | ③ executor 子代理 S1-S5 串行 | 10 技能撰写=内容组判断型（sonnet-1 档）;42.2 修订=轻量编辑（haiku-1） |
| P3 | ③ executor（新 selftest）+ ⑥ 主进程全量求和 | 判断型+白名单③ |
| P4 | ① git 编排全链 | merge/deploy/push/cleanup |
| P5 | ③ code-reviewer + ②⑤ 簿记终验 | CR 隔离+白名单 |

**workflow 编排判定（40.4）**: 未命中——P2 内 S1→S4 串行强依赖（S1 范式锚定后续 9 个质量一致性）,S5 依赖 S1-S4;用户未点名 /workflow → 维持 21.4 串行。
**/goal 对齐（40.3）**: 本计划 Goal+VC 即会话目标证据源;/goal 用户侧命令技能不可代调（40.3 披露纪律）。

## Phases

### Phase 1: 基线测绘 + worktree 隔离
- [x] worktree 建立 @539adcc,porcelain=0
- [x] worktree 内基线复测: 全量 selftest 双形态求和（基线 39 脚本 628/0）+ wc SKILL=439/CRIT=432 + registry 40 行
- [x] Rule 32 出处复核: v099 notepad 否决段 Read+本计划头注交互登记确认
- **V-N:** VC-4, VC-6（基线定数=回归对照;出处复核=禁令边界确认）
- **Status:** complete
- **Executor:** 主进程（① 纯 git/worktree 编排 + ③ 机械验证（求和纪律禁子代理自报）——Rule 25.3 白名单）

### Phase 2: review-library 10 技能 + Rule 42.2 检测链四级化
- [x] S1: 撰写范式锚定技能 general-review/SKILL.md（兜底的兜底,质量标杆:四要素齐+审查清单 10 条+43.1 证据要求引用）供 S2-S4 对标
- [x] S2: code-quality-review + test-quality-review + security-review（各按 S1 范式,领域清单 ≥8 条）
- [x] S3: content-quality-review + documentation-review + data-quality-review
- [x] S4: image-review（用户点名场景,B 类澄清替换 performance）+ ui-quality-review + release-review（至此恰 10 个）
- [x] S5: Rule 42.2 行改写（三级→四级+插入「④ task-planner 内置 review-library 兜底池（10 类通用技能,`review-library/`）」层,①②③原文保留,「均未命中=缺口」保留）+ SKILL.md C30 行「三级」→「四级（含内置兜底池）」措辞同步
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（S1 建议档位 sonnet-1 / S2-S4 建议档位 sonnet-1 / S5 建议档位 haiku-1;21.4 串行 S1→S5,范式锚定强依赖）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | general-review 范式技能 | executor | sonnet-1 | 本计划 Goal 区（四要素合约）+43.1 条文（CRIT :423 区） | 文件 ~70 行;四要素+清单 10 条;frontmatter 合规 | 15min | pending |
| S2 | code/test/security 三技能 | executor | sonnet-1 | S1 范式 + 各领域清单要求 | 3 文件各 ≥8 条清单;范式同构 | 15min | pending |
| S3 | content/documentation/data 三技能 | executor | sonnet-1 | S1 范式 | 同上 | 15min | pending |
| S4 | image/ui/release 三技能 | executor | sonnet-1 | S1 范式 | 同上;`ls review-library`=10 | 15min | pending |
| S5 | Rule 42.2 四级化+C30 同步 | executor | haiku-1 | CRIT :420 现文+SKILL C30 行 | diff 仅 2 行改写;①②③原文零改动 | 10min | pending |

### Phase 3: selftest 守护 + registry + 全量回归
- [x] S6: 新建 scripts/selftest-review-library.sh（RL-01..10,对齐 SR 范式:恰 10 目录/每目录 SKILL.md/frontmatter name+description/四要素/APPROVED 合约/10 领域名清单/42.2 四级措辞/C30 四级措辞/registry 行/config=40）+ registry.tsv +1（40→41）
- [x] 主进程全量回归定数（40 脚本双形态求和,0 FAIL 且 ≥628+12）
- **V-N:** VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）（S6;主进程回归求和=③机械验证——Rule 25.3 白名单③,注解挪注）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S6 | selftest-review-library + registry | executor | sonnet-1 | selftest-self-resolution.sh 范式 | RL-01..10 全 PASS;bash -n 过;tsv 41 行 rows=actual | 15min | pending |

### Phase 4: 合并回 + 三位部署 + push + 清理
- [x] 只读预检（origin 领先量=0/主仓 porcelain 无 scope 重叠）→ smart-merge-back --deploy（三位 IDENTICAL+部署位 `ls review-library`=10 亲验）→ push origin master（ls-remote 终验）→ worktree/branch 清理 0/0
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（① git 编排 + ② merge_back 簿记 + ③ 机械验证——白名单）

### Phase 5: CR Gate + 终验簿记
- [x] CR Gate: code-reviewer 隔离审查全量 diff（10 SKILL.md 内容质量主审+42.2 修订+新 selftest）;APPROVED 才终验
- [x] 终验簿记: verification.md 全 VC/委派率/check-complete（簿记提交后）/INDEX/notepad/memory/收尾
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）（CR 隔离审查）+ 主进程（② 计划系统文件簿记 + ⑤ 终验机械复核——Rule 25.3 白名单②⑤）
### Phase 5: CR Gate + 终验簿记
- [x] CR Gate: code-reviewer 隔离审查全量 diff（10 SKILL.md 内容质量主审+42.2 修订+新 selftest）;APPROVED 才终验
- [x] 终验簿记: verification.md 全 VC/委派率/check-complete（簿记提交后）/INDEX/notepad/memory/收尾
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）+ 主进程（② 簿记 + ⑤ 终验机械复核）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（P1 复扫:信号①=plans 指针+本目录,零 scope 重叠） |
| `isolation` | worktree（skills/ 运行中基础设施,§11.1 强制） |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library |
| `branch` | wt/task-v100-review-library（基线 master@539adcc） |
| `merge_back` | pending |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 兜底（22.3 对应档） |
|-------|---------|---|---|---|-----|---------------------|
| P2 | 技能文件空壳化（清单条目<8 或无领域针对性）→ 兜底池名存实亡 | 7 | 4 | 3 | 84 | S1 范式锚定+S2-S4 输入列携范式+CR 内容质量主审;空壳→回炉重写（22.3②） |
| P2 | Rule 42.2 改写伤及①②③层或「缺口」语义 | 8 | 3 | 3 | 72 | diff 单行核验+「均未命中=缺口」grep 硬断言;伤及即 git restore 单行重写（⑥） |
| P3 | 新 selftest 断言锚漂移（10 计数/领域名拼写） | 6 | 4 | 3 | 72 | 断言锚先 grep 实测再写入（v099 教训）;FAIL 单断言修复 |
| P4 | 部署位 DRIFT/push 冲突 | 6 | 3 | 3 | 54 | smart-merge-back fail-closed;push 前预检+ls-remote 终验（v099 教训） |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 备注 |
|-------|-----------|------|
| P1-P5 | S1 映射计划批准后建立 | 5 条 |

## Key Questions
1. 兜底池为何放 task-planner 内置而非用户级 skills？（答:随部署分发版本受控;Rule 42.2 检测由 task-planner 自身消费（Read/Skill 加载）无需 ZCode 原生发现;避免污染用户级目录——v098 39.7.2 遮蔽教训同源原则）
2. 10 类覆盖面依据？（答:通用兜底=按产出物类型切分:代码/测试/安全/性能/内容/文档/数据/UI/发布+general 兜底的兜底;每类独立 SKILL 便于 42.2 按任务类型精准命中）
3. Rule 32 否决交互？（答:v099 否决「每项目≥10 配额」;本任务=用户主动重提「一次性 10 个通用兜底」语义不同,出处已标计划头注）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 兜底池位置=task-planner 内置 review-library/（非用户级 skills） | 随部署分发/版本受控/Rule 42 直接消费;用户级写入需逐项授权且无分发机制 |
| silent: Rule 32 出处标注——v099 否决「固定配额」不阻本任务「一次性兜底池」 | 用户主动重提+语义细化（兜底池 vs 每项目配额）;Rule 32.4 新证据处置 |
| silent: 42.2 三级→四级为 v099 条款纯增量插入（④层） | 用户本指令的直接制度化落点;①②③原文零改动 |
| silent: S1 先写 general-review 范式锚定再批量 | 10 个技能质量一致性靠范式对标;43.3 候选预验证精神（范式即已验证候选） |
| silent: push 授权沿用用户 09-30 持久指令（部署+GitHub 备份） | v098/v099/v100 三度确认的持久工作流 |
| silent: 模板/SKILL 摘要行改动新会话生效 | 会话加载面快照语义 |
| B 类澄清（用户 09-30）: 10 场景清单 performance→image（用户点名「图片审查」） | 用户点名场景优先;性能面由 code-quality/general 覆盖;10 个技能=10 个不同场景（代码/测试/安全/图片/撰写/文档/数据/UI/发布/通用） |
| silent: 「三级→四级」级联面 4 处（CRIT :420/:423 + SKILL :195/:276）,B 类扩围登记 | P1 实测级联面>计划预估（锚定级联三层教训再现）;42.5 为注释性同步,selftest-reliability R-03 仅锁「均未命中=缺口」语义不受影响 |
| silent: SR-12 级联断裂根治（动态口径）,B 类扩围登记 | v099 改锚值 40 后 v100 registry+1 又断——硬编码行数必然随新脚本登记级联断裂;动态比较（=脚本数+表头）断言语义等价且永久免此断点;主进程白名单③修正 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 本任务自身即 Rule 42.2 四级检测链的首个消费示范: 检测=review-library 从 0→10
- 禁止在新增文本产生「1-4x」越界数字字面;「Rules 1-39」字面 2 处不动

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

## 📦 Batch Report
| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——10 技能撰写虽为多文件,但每技能领域异质需独立判断,非同构单元批量;按 43.3 各 S-unit 独立验收） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0% |
| `sampled_pass` | 0 |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否（异质内容非同构批量）/Q2:有（RL 断言+CR 主审）/Q3:能（worktree 可回滚） |
| `rollback_point` | master@539adcc |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 2 / 5（P2、P3;P5-CR 部分） |
| 主进程直做 | P1（①③）/ P4（①②③）/ P5（②⑤）——白名单内 |
| 委派率 | 预期 0.4 → 25.4a WHITELIST-EXEMPT 判定 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-09-30 | executor | P2-S1 general-review 范式技能 | done | 50 行四要素+15 条清单,7/7 验收过（主进程抽验范式达标） | 01-exec-p2s1.md | findings Research | plans/task-v100-review-library/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-09-30 | executor | P2-S2 code/test/security 三技能 | done | 各 50 行清单 14 条;security P0 定义;7/7 过 | 02-exec-p2s2.md | findings Research | plans/task-v100-review-library/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-09-30 | executor | P2-S3 content/documentation/data 三技能 | done | 各 50 行清单 12/11/11;content 事实错误=P0;6/6 过 | 03-exec-p2s3.md | findings Research | plans/task-v100-review-library/subagent-state/03-exec-p2s3.md | - / 0 / ☑ |
| 4 | 2026-09-30 | executor | P2-S4 image/ui/release 三技能 | done | 51/50/50 行清单各 11;池 10/10 建成;image 证据段「实际查看禁未看下结论」 | 04-exec-p2s4.md | findings Research | plans/task-v100-review-library/subagent-state/04-exec-p2s4.md | - / 0 / ☑ |
| 5 | 2026-09-30 | executor | P2-S5 Rule 42.2 四级化+C30/摘要同步 | done | 四级化+4 处级联;三级字面清零;R-03 仍 PASS;5 脚本 0 FAIL | 05-exec-p2s5.md+主进程复核 | findings Research | plans/task-v100-review-library/subagent-state/05-exec-p2s5.md | - / 0 / ☑ |
| 6 | 2026-09-30 | executor | P3-S6 selftest-review-library+registry | done | RL-01..10 首跑 10/0（RL-09 锚修正登记）;tsv 41 行;SR-12 级联断裂主进程动态口径根治（B 类扩围）;全量 638/0 | 06-exec-p3s6.md+主进程定数 | findings Research | plans/task-v100-review-library/subagent-state/06-exec-p3s6.md | - / 0 / ☑ |
| 7 | 2026-09-30 | code-reviewer | P5 CR Gate | done | 首审 CHANGES_REQUESTED（1 P1+2 P2）→fix-phase 主进程修复→复验 **APPROVED**（7 专项全 PASS,P1 全池零残留亲证） | 07-cr-p5.md（含 fix-phase 段） | verification CR 段 | plans/task-v100-review-library/subagent-state/07-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知类型（rule-enhancement 序列）;终验处置登记: 不沉淀理由:已知类型第 N 次消费,34.3 三条件不命中新沉淀点（终验登记）
