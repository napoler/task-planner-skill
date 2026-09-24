# Task Plan: task-v090 — /workflow 自动激活边界锚定 + 守卫观察面扩展

## Goal
用户确认选项 1+2：① 在 Rule 39 族追加 39.7（动态激活边界：系统链路闭环如实披露 + 禁自建 dynamic-workflows 副本 P0 锚 + matcher 观察扩展语义）；② PreToolUse matcher 扩围至 workflow 四工具（harness 侧 ~/.zcode/cli/config.json + 仓内 zcode-pretooluse.sh 观察分支 + register-hooks-cj.ts 同步），hook 对 workflow 工具仅观察不阻断（39.5 边界不变）；零新 config 键，纯增量，selftest 追加 WF-13..16 守护。

## 📐 template_type: rule-enhancement | plan_tier: standard | code_review: required | git_commit: 逐 Phase

## 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|------|-----------|------|
| 规则 | skills/task-planner/references/critical-rules.md | 其他 Rule 改写 |
| 守卫 | skills/task-planner/scripts/zcode-pretooluse.sh | check-dispatch/check-scope 语义改动 |
| hook 注册 | skills/task-planner/scripts/register-hooks-cj.ts | 其他 event 注册 |
| 守护 | skills/task-planner/scripts/selftest-workflow-orchestration.sh | 其他 selftest 改写 |
| 簿记 | CHANGELOG.md | 其他文档 |
| 计划 | plans/task-v090-workflow-auto-activation | 其他 plans 目录 |
| harness | ~/.zcode/cli/config.json | 其他 hooks/config 改动 |

> 改动注记（不进 27.3 提取）：critical-rules=仅 39.5 注记+39.7 追加；pretooluse=新增 39.7.3 观察分支；register-hooks=matcher 一行扩围；selftest=WF-13..16 追加；CHANGELOG=[Unreleased] 一条；config.json=PreToolUse matcher 字段（P0 已授权）。

## Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | critical-rules.md 含 39.7 三子条（39.7.1 系统链路闭环 / 39.7.2 禁自建副本 P0 / 39.7.3 matcher 观察扩展），39.5 尾注 39.7② 观察面 | grep '^39\.7' 命中 + 子条锚 |
| VC-2 | zcode-pretooluse.sh 对 workflow 四工具仅观察（注入提醒 exit 0），Write/Edit/Agent 既有分支逐字节不变 | diff 旧版 + 模拟 stdin 输入三工具各跑一次 |
| VC-3 | register-hooks-cj.ts PreToolUse matcher 含 workflow 四工具 | grep matcher |
| VC-4 | ~/.zcode/cli/config.json PreToolUse matcher=Write\|Edit\|Agent\|CreateWorkflow\|AmendWorkflow\|SaveWorkflow\|EvalWorkflowSnippet | jq 读取 |
| VC-5 | selftest WF-13..16 PASS（39.7 锚 + matcher 锚 + 用户级无副本负断言 + SKILL 行数上限 558 不动） | 跑脚本 Total FAIL=0 |
| VC-6 | worktree 全量 selftest（27 脚本）回归 0 FAIL | 逐脚本跑 Total 求和 |
| VC-7 | 三位部署 diff=0 + 部署位 selftest PASS | diff -r + 部署位跑 |

## Phases

### Phase 1: 规则层 39.7 + 39.5 注记（纯追加）
- [x] 39.5 尾追加「39.7② 观察面扩展」注记
- [x] 39.6 后追加 39.7（三子条）
- - **V-N:** VC-1
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划/规则簿记属 25.3 白名单②计划系统文件维护——规则文件本身按用户显式授权修改，见 Decisions）

### Phase 2: 守卫观察面扩展（zcode-pretooluse + register-hooks + cli config）
- [x] zcode-pretooluse.sh 在 case 分支追加 workflow 四工具观察分支（39.7②：注入提醒 + exit 0；Write/Edit/Agent 分支零改动）
- [x] register-hooks-cj.ts PreToolUse matcher 同步扩围
- [x] ~/.zcode/cli/config.json matcher 扩围（P0 已授权）
- - **V-N:** VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:④ 用户显式授权选项 1 + ②③ 簿记/机械验证）

### Phase 3: 守护 + 回归 + 簿记
- [x] selftest-workflow-orchestration.sh 追加 WF-13..16
- [x] worktree 全量 27 selftest 回归
- [x] CHANGELOG.md [Unreleased] 追加条目
- - **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:③ 机械验证 + ② 簿记白名单）

### Phase 4: 合并回 + 部署 + 终验
- [x] 合并回 master：git merge --no-ff wt/task-v090 → df8149f（主仓 skills 无重叠未提交变更，零冲突）
- [x] 清理 worktree + 分支（worktree remove + branch -d，遗留 wt/ 分支=0）
- [x] 三位部署：4 文件定向 cp + 逐文件 diff 全空（WF-10 部署位 FAIL=已知「SKILL_ROOT/../.. 上跳不可达」非鲁棒项，登记遗留不阻断）
- [x] 主仓全量 27 selftest PASS=457 FAIL=0；部署位 wf selftest 15/16（仅 WF-10 已知项）
- [x] verification.md 逐条 VC-1..7 复验 + 委派统计（WHITELIST-EXEMPT）；outcome=COMPLETE
- - **V-N:** VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排 + ② 簿记——Rule 25.3 白名单①②）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 选项 1 落地方式=harness config.json matcher 扩围 + 仓内 pretooluse 观察分支（非新建用户级 slash command） | 调研实证：/workflow 是 ZCode 系统内置命令（命令正文注入 Required skills 加载指令），链路已闭环；仓内自建用户级命令属越层遮蔽，违背 39.7.1 系统侧原则；用户选 1=「扩 matcher 观察面」，本计划按调研结论映射到最小操作面 |
| register-hooks-cj.ts matcher 扩围不含 Agent（保持 'Write\|Edit\|CreateWorkflow\|AmendWorkflow\|SaveWorkflow\|EvalWorkflowSnippet'） | Claude 运行位注册器原 matcher 仅 Write\|Edit（无 Agent），本任务纯增量=在原基础上加 workflow 四工具，不顺手扩 Agent（Rule 36.5 纯增量纪律）；ZCode 运行位 cli config.json 保持 Agent 不变 |
| 选项 2=39.7.2 禁自建副本 P0 锚（负断言 selftest WF-13） | 用户选 2；发现顺序 ~/.zcode/skills 优先于 bundled，自建副本遮蔽官方版本=永久漂移 |
| hook 观察分支 exit 0 恒放行 | 39.5 披露边界：workflow 内部非 hook 强制；观察≠守卫，不新增阻断语义、不新增 config 键（v086-v088 零键范式） |
| 隔离=worktree | §十一 P0：改 skills/ 保护区命中；用户并行开发期禁主树直写运行中基础设施 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| （无——本任务执行顺利） | - | - | - |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | 模拟 stdin 测试漏覆盖某工具名 | 3 | 2 | 3 | 18 | 22.3② 拆细逐工具补测 |
| P4 | 部署位 selftest 因相对路径解析 FAIL（WF-10 已知非鲁棒） | 3 | 3 | 3 | 27 | 如实登记部署位口径，主仓口径为准（前序 v077 教训） |

## Key Questions
1. 39.7 是否需 SKILL.md 联动（行数上限 558 不动→不动 SKILL.md，仅 critical-rules + selftest）？→ 判定：39.7 子条在 critical-rules，SKILL 协同路由行已含 Rule 39 指针，不扩 SKILL（避免 558 上限联动 4 selftest）。
2. register-hooks-cj.ts matcher 扩围与 cli config.json 是否双写？→ 是：仓内注册器是安装器 source of truth，config.json 是运行态。
