---
template_type: rule-enhancement
plan_tier: standard
---

# Task Plan: task-v105-pool-host-enumerable — review-library 池成员提升为宿主可枚举 skill

<!--
  WHAT: 11 个 review-library 池成员以相对软链挂载到三宿主顶层 skills/<member>/（宿主发现面=顶层枚举,嵌套池不可见）:smart-merge-back --deploy 成功后自动挂载(install_pool_links,冲突跳过+回滚语义);install-companion 分发池成员 SKILL.md(顶层已有独立 skill 不覆盖);RL-14/15 守护。用户 2026-10-01 裁决:「池成员提升为宿主可枚举 skill」。
  WHY: 用户目标「can be triggered either explicitly or by its declared conditions」——池成员嵌套在 task-planner/review-library/ 下,宿主 available-skills 只枚举顶层,11 成员不可被 /<name> 显式触发;opencode 顶层已有独立 security-review(4 月手工副本)必须保留不覆盖。
  交互模式: silent(用户「fix」裁决+AskUserQuestion 已选范围)。主进程直接撰写计划(白名单②)。
-->

## Goal
review-library 11 池成员以相对软链挂载到三宿主顶层 skills/<member>/(宿主可枚举):smart-merge-back.sh 增 install_pool_links(部署对账通过后自动挂载,冲突跳过 LINK-WARN+挂载失败回滚,不改 exit 码);install-companion.sh 增池成员单文件分发(目标独立 skill 不覆盖);RL-14/15 断言;全量 selftest 0 FAIL(41 脚本 ≥652)后合并、三部署位 IDENTICAL+挂载亲验(.zcode/.claude 各 11 链,opencode 10 链+security-review 保留)、push GitHub、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | task-v105-pool-host-enumerable |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable |
| `branch` | wt/task-v105-pool-host-enumerable(基线 master@084a92a) |
| `scope_files` | scripts/smart-merge-back.sh(install_pool_links); lib/install-companion.sh(池分发); scripts/selftest-review-library.sh(RL-14/15+头注释级联) |
| `interaction_mode` | silent |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | smart-merge-back.sh:install_pool_links 函数在位(相对软链语义/冲突跳过 LINK-WARN/挂载失败回滚/不改 exit 码)+deploy_reconcile 通过后调用 | grep+Read |
| VC-2 | install-companion.sh:task-planner 分支内池成员 SKILL.md 单文件分发+「独立 skill 不覆盖」语义(目标存在且内容不同→skip+WARN) | grep+Read |
| VC-3 | RL-14/15 在位(挂载锚+分发锚)+头注释 RL-01..13→15 级联+selftest-review-library `Total: 15 PASS=15 FAIL=0` | bash |
| VC-4 | 全量回归 41 脚本 0 FAIL 且 PASS ≥652(主进程定数;selftest-smart-merge 零回归=挂载输出行不破既有断言) | bash 全量 |
| VC-5 | 合并部署 push 清理+挂载亲验:三部署位 IDENTICAL;.zcode/.claude 顶层各 11 软链(readlink 指向 task-planner/review-library/<m> 且 SKILL.md name 可读);opencode 10 链+security-review 保留(LINK-WARN);ls-remote 终验 | ls+readlink+grep |
| VC-6 | 边界零回归+CR APPROVED(diff 面 3 文件全在 scope) | CR 结论 |

**终验规则**: 全 VC → COMPLETE;遗留 → PARTIAL;3 次无效 → BLOCKED(41.4 前置)。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 脚本 | smart-merge-back.sh 尾部部署成功段增函数+1 处调用;install-companion.sh skills 循环 task-planner 分支 | 改动 deploy_reconcile/validate_slot/原子替换既有逻辑 |
| 守护 | selftest-review-library.sh RL-14/15 | 其他 selftest 逻辑 |
| 配置 | (无) | config.json 零改动;池内容/SKILL.md 零改动 |
| 宿主 | 仅软链创建/校验;**禁止覆盖/删除任何顶层既有条目**(opencode security-review 保留) | rm 顶层真实目录 |

## 📚 必要知识储备
| 名称 | 定位 | ☑ |
|------|------|---|
| smart-merge-back 部署循环(:560-622,deploy_reconcile 调用点/exit 路径) | scripts/smart-merge-back.sh | ☑ |
| install-companion skills 分发循环(:150-190,task-planner continue 分支) | lib/install-companion.sh | ☑ |
| RL-12/13 断言范式+头注释计数 | scripts/selftest-review-library.sh | ☑ |
| opencode 独立 security-review(保留不动) | ~/.config/opencode/skills/security-review | ☑ |
| 宿主 symlink 探测结论(可读,name 解析✓) | 2026-10-01 探针 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 池成员嵌套在 task-planner/review-library/ 下,宿主 skill 发现面只枚举顶层 skills/<name>/SKILL.md→11 成员不可被 /<name> 显式触发;且物理复制到顶层会造成 12×3 份副本漂移(正是 alignment-review 要防的)。解=相对软链挂载(单一维护源,池更新自动同步)+冲突跳过(独立 skill 不覆盖)。软链可读性已探针实证。
- [x] 能交付 / [x] 唯一目标 / [x] 方法清晰

## Current Phase
Phase 2

## Next Step
主进程建 worktree(@084a92a)+基线复测(41 脚本 650/0)落 progress。

## 🧰 工具选择与编排（Rule 40）
| Phase | 工具面 | 理由 |
|-------|--------|------|
| P1 | ①③ | worktree/基线 |
| P2 | ③ executor S1(sonnet-1 挂载函数)→S2(haiku-1 分发)→S3(haiku-1 RL)串行 | 21.4 |
| P3 | ⑥ 主进程求和 | 白名单③ |
| P4 | ① git 全链+挂载由 --deploy 自动执行 | 白名单① |
| P5 | ③ CR+②⑤ 簿记 | 白名单②⑤ |

**workflow 判定**: 未命中(串行+未点名 /workflow)→21.4 串行。

## Phases

### Phase 1: 基线 + worktree
- [ ] worktree @084a92a,porcelain=0;基线复测(41 脚本 650/0)
- **V-N:** VC-4, VC-6
- **Status:** complete
- **Executor:** 主进程（① 纯 git/worktree 编排 + ③ 机械验证（基线求和纪律禁子代理自报）——Rule 25.3 白名单①③）

### Phase 2: 挂载+分发+守护（S1→S3 串行）
- [ ] S1: smart-merge-back.sh 增 install_pool_links(slotdir→parent=dirname;枚举 slotdir/review-library/*/;逐成员:顶层已存在→[已是我们软链且指向正确]=LINK-OK/[其他]=LINK-WARN 跳过;否则 ln -s task-planner/review-library/<m> <parent>/<m>+frontmatter 校验失败即 rm 回滚;全程 LINK-* 输出不改 exit 码)+deploy_reconcile 通过分支内调用
- [ ] S2: install-companion.sh skills 循环:task-planner 分支改为「池成员分发」——枚举 review-library/*/SKILL.md,目标不存在或与源 byte 等同→sync_one 到 $TARGET_ROOT/skills/<m>/SKILL.md;目标存在且内容不同→WARN「独立 skill 不覆盖」skip
- [ ] S3: selftest-review-library.sh RL-14(smart-merge-back 含 install_pool_links≥1 且 LINK-WARN≥1)+RL-15(install-companion 含 review-library≥1 且 独立 skill≥1)+头注释 RL-01..13→15
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（S1 sonnet-1/S2 haiku-1/S3 haiku-1;21.4 串行）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | 挂载函数+调用 | executor | sonnet-1 | 任务书逐字规格+现文 | 函数+调用点;冲突跳过/回滚/exit 语义;bash -n | 15min | pending |
| S2 | 池分发 | executor | haiku-1 | 任务书规格+现文 | 分发+不覆盖语义;bash -n | 10min | pending |
| S3 | RL-14/15 | executor | haiku-1 | RL-11/12 范式 | Total: 15/0;RL-01..13 零改动 | 10min | pending |

### Phase 3: 全量回归
- [ ] 主进程定数(41 脚本双形态求和:RL 15/0+selftest-smart-merge 零回归+全量 0 FAIL,PASS ≥652)
- **V-N:** VC-4
- **Status:** complete
- **Executor:** 主进程（③ 机械验证（全量求和定数禁子代理自报）——Rule 25.3 白名单③）

### Phase 4: 合并+部署+挂载+push+清理
- [ ] 预检→smart-merge-back --deploy(部署后自动挂载)→三位 IDENTICAL+挂载亲验(.zcode/.claude 11 链/opencode 10 链+security-review 保留)→push(ls-remote)→清理 0/0
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（① git 编排（merge/deploy/挂载/push/cleanup 全链）+ ③ 机械验证（readlink/frontmatter 亲验）——Rule 25.3 白名单①③）

### Phase 5: CR Gate + 终验簿记
- [ ] CR(code-reviewer 隔离审 diff;ECONNREFUSED 时 22.3① 改派 executor+任务书审查规程);APPROVED 才终验
- [ ] 簿记: verification/INDEX/notepad/memory/check-complete(簿记提交后)
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）（CR 隔离审查）+ 主进程（② 计划系统文件簿记 + ⑤ 终验机械复核——Rule 25.3 白名单②⑤）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe(P1 复扫) |
| `isolation` | worktree |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable |
| `branch` | wt/task-v105-pool-host-enumerable(@084a92a) |
| `merge_back` | pending |

## 📊 FMEA
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | install_pool_links 误删/覆盖顶层既有条目 | 9 | 2 | 3 | 54 | 只在「不存在」时 ln;已存在一律跳过(WARN);挂载后校验失败仅 rm 自己刚建的链;禁止 rm 真实目录 |
| P2 | 挂载逻辑改坏 deploy exit 语义(SM selftest 破) | 8 | 3 | 3 | 72 | LINK-* 纯输出不改返回值;P3 selftest-smart-merge 复跑把关 |
| P4 | opencode security-review 被覆盖 | 9 | 2 | 2 | 36 | 冲突跳过语义(S2)+P4 亲验保留+LINK-WARN 留痕 |
| P4 | 软链断链(池升级时 slot 原子替换) | 6 | 2 | 3 | 36 | 相对目标=新 slot 内路径(原子替换后仍有效);挂载幂等每次 deploy 重验 |

## 🔁 原生 Todo 同步
| Phase | 已建 | 备注 |
|-------|------|------|
| P1-P5 | S1 映射批准后建 | 5 条 |

## Key Questions
1. 为什么软链而非物理复制？（答: 单一维护源——池内容升级(v104 类)自动同步到顶层,零漂移;物理复制=12×3 份双源,正是 alignment-review 制度要防的多副本不同步;宿主 symlink 可读性已探针实证）
2. opencode 独立 security-review 怎么办？（答: 保留不动——它是 2026-04 手工副本(含 cloud-infrastructure-security.md),与池成员不同内容;挂载/分发对「顶层已存在且非我们的链」一律跳过+WARN;该位 security-review 保持独立版,池内版本仍可经 task-planner 流程消费）
3. 挂载失败影响部署判定吗？（答: 不影响——挂载是部署成功后的增强段,LINK-WARN 仅输出;deploy exit 语义(REJECTED/DRIFT/IDENTICAL)不变,SM selftest 不破）
4. 宿主何时看到新 skill？（答: available-skills 为会话快照,软链就位后需新会话/重启刷新——与 install-companion 既有注记同语义,非本任务缺陷）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 相对软链挂载(非复制) | 单一维护源+零漂移;探针实证可读;与「多副本同步 P0」制度对齐 |
| silent: 冲突跳过不覆盖(opencode security-review) | 独立 skill 是用户既有资产,覆盖=P0 破坏;跳过+WARN 留痕可审计 |
| silent: 挂载挂 smart-merge-back deploy 成功段(增强段不改 exit) | 每次标准部署自动挂载=「runs automatically」;增强段语义隔离保 SM selftest |
| silent: install-companion 仅分发 SKILL.md 单文件 | 池成员纯文档 skill 零 scripts/config;与卫星整目录复制相比最小面 |
| silent: 主进程直接撰写计划 | 白名单②;plan-writer 档位死亡多度实测 |
| silent: push 沿用 09-30 持久指令 | 用户「部署到各个平台,然后提交到 GitHub 进行备份」多度确认 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 用户原话锚(2026-10-01 裁决):「池成员提升为宿主可枚举 skill」
- 禁「1-4x」越界字面;「Rules 1-39」字面 2 处不动;config 零改动(RT-09 键数 40)
- opencode security-review=2026-04-10 手工副本(10189B cloud-infrastructure-security.md+12202B SKILL.md,英文),非池成员,保留

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

## 📦 Batch Report
| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——非批量） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0% |
| `sampled_pass` | 0 |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否/Q2:有/Q3:能 |
| `rollback_point` | master@084a92a |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 1 / 5(P2;P5-CR 部分) |
| 主进程直做 | P1/P3/P4/P5(①②③⑤——白名单) |
| 委派率 | 预期 0.2 → 25.4a 判定 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-10-01 | executor | P2-S1 smart-merge-back 挂载函数 | done | 35 行纯增零删改;函数+调用+头注释;exit 语义隔离(CR 专项 2 PASS) | 01-exec-p2s1.md+主进程抽验 | findings Requirements | plans/task-v105-pool-host-enumerable/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-10-01 | executor | P2-S2 install-companion 池分发 | done | +21/-1;独立 skill 不覆盖语义;幂等 | 02-exec-p2s2.md | findings Research | plans/task-v105-pool-host-enumerable/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-10-01 | executor | P2-S3 RL-14/15 | done | Total: 15/0;RL-01..13 零改动 | 03-exec-p2s3.md | findings Research | plans/task-v105-pool-host-enumerable/subagent-state/03-exec-p2s3.md | - / 0 / ☑ |
| 4 | 2026-10-01 | code-reviewer | P5 CR Gate | done | **APPROVED**(0 P0/P1;2 Nit 前瞻不阻塞) | 04-cr-p5.md | verification CR 段 | plans/task-v105-pool-host-enumerable/subagent-state/04-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | single |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知类型;终验处置: 不沉淀理由(34.3 不命中,终验登记)
