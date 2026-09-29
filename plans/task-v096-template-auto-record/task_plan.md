<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard -->
<!-- interaction_mode: ask -->
<!-- code_review: required -->
<!-- cost_estimate: { main_process_opus: 1, subagent_calls: { executor: 10, code-reviewer: 1 }, estimated_opus_equivalent: 1.62, estimated_savings_vs_naive: 0.55 } -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor 写条款与脚本与 selftest; code-reviewer 审 CR Gate; 合并部署主进程 -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发；v071-v073 同套路轮次佐证） -->

# Task Plan: task-v096-template-auto-record（模板自动记录与三时点主动激活）

## Goal
为 task-planner 落地「模板自动记录与主动激活」：三时点感知网（T1 init-session.sh 机器提示+区块预登记 / T2 critical-rules 34.7 条款+SKILL 三处联动 / T3 check-complete.sh warn 兜底）+ 全自动模板生成合约（34.5 闸门内置生成侧+计数级联），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 init-session.sh / check-complete.sh 两个 .sh 消费侧脚本） |
| `interaction_mode` | `ask`（计划批准呈示 + 终验结论呈示，Rule 28） |

**知识底座**: `knowledge-brief.md`（同目录，§1-§5 五段；执行期材料包按 §5 索引引用）。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | T1 生效：init-session.sh 在 general fallback 与 unknown 类型两分支均 emit `[template-sense]` 并在生成的 task_plan.md 末尾产出「🔁 模板感知」区块；已知类型（如 bugfix）零触发（负例）；下游解析（check-scope/check-3file-gate/check-template-type）不受追加区块影响 | 两分支正例 + 已知类型负例实跑 + 下游脚本对含区块计划实跑 | progress.md Selftest Log + P2 checkpoint |
| VC-2 | T2 条款落地：critical-rules.md 含 34.7（三时点定义+全自动合约+34.5 闸门内置+计数级联），34.1-34.6 快照差集为空（纯追加）；SKILL.md 三处联动完成（L262 摘要行行内/L186 C22 行内改全自动语义/L214 指针），净增 ≤3 行，旧锚子串「Rule 34（P0）模板生命周期门控与沉淀」「\| C22 \|」行首格式保全 | grep '^34.7' + 改前快照 diff + selftest-template-lifecycle TL-14/15 实跑 | critical-rules.md L318+ / SKILL.md / selftest 输出 |
| VC-3 | T3 生效：check-complete.sh 对含感知区块且未登记沉淀/不沉淀理由的计划输出含 `template-sense` 字样 warn（不阻断）；正常计划零误报 | 构造正例/负例计划实测 check-complete warn 段 | P4 checkpoint + 实测输出 |
| VC-4 | 卫星联动：plan-template-kit/SKILL.md 沉淀节含全自动合约+计数级联清单（TL-17 同步要求在列） | grep 全自动/计数级联锚 | skills/plan-template-kit/SKILL.md |
| VC-5 | 全量 selftest 0 FAIL 且 PASS 总数 ≥ P1 实测基线（总数=主进程逐脚本 Total 行求和，禁采信子代理自报）；新 selftest-template-sense 全绿并登记 registry（tsv+sh） | `for f in selftest-*.sh` 逐个跑 + grep registry 登记 | progress.md Selftest Log |
| VC-6 | CR APPROVED + 合并回完成 + install.sh 全量部署三实体位 diff -r 一致 + worktree/分支清理 | code-reviewer 结论 + `diff -r` 输出 + `git worktree list`/`git branch` 复验 | verification.md + 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（仅 L318 后追加 34.7） | 改 34.1-34.6 语义；动其他 Rule；重编号 |
| 脚本 | `scripts/init-session.sh`、`scripts/check-complete.sh`、新建 `scripts/selftest-template-sense.sh`、`scripts/selftest-registry.tsv`(+`.sh` 登记) | 其他脚本；hook 接线（zcode-userpromptsubmit.sh）；`templates/task_plan.md` 模板本体 |
| SKILL | `skills/task-planner/SKILL.md`（三处行内改+指针行，净增 ≤3 行） | 大段新增；动 L9/L214/L429 既有锚子串 |
| 卫星 | `skills/plan-template-kit/SKILL.md`（沉淀节） | template-mapping.md / template-guide.md（本任务无新沉淀，零改） |
| 文档 | `plans/task-v096-template-auto-record/**`（findings/progress/verification/notepad-learnings 各自回填） + `plans/INDEX.md` + ledger | 其他计划目录 |

**强制约束**（简报 §2.3 逐条，全部 P0）:
1. 零新 config 键——T3 纯 warn 语义无门控键，34.7 不挂三档键
2. Rule 1-39 编号冻结——34.7 纯追加，禁重排/重编号
3. `templates/task_plan.md` 模板本体零改动——「🔁 模板感知」区块=init-session.sh 运行时追加
4. hook 接线零改动；UserPromptSubmit 不碰（v091 hook 税，D1 裁决）
5. init-session.sh 系 v095 留守机械层，修改合法性唯一来源=Rule 36.2 归因（用户点名功能增量）；改后 `bash -n` + selftest-plan-tier 及 init-session 相关 selftest 全绿
6. C22 行/Rule 34 摘要行是 grep 锚——行内改时既有子串（「template_type 已过 check-template-type.sh 门控」「Rule 34（P0）模板生命周期门控与沉淀」「`| C22 |`」行首）保全；改前快照差集对账
7. 全部改动 worktree 隔离（保护区文件），逐 Phase git 提交，合并回后 install.sh 全量部署三实体位 + `diff -r` 复验
8. 每个改点 S-unit 动手前先 grep 消费方 selftest 断言（内容型锚必漏，清单只作导航——v095 Error Log Prevention）
9. selftest 总数=主进程逐脚本 Total 行求和，禁采信子代理自报；基线以 P1 实测为准（纸面 584 仅预期）
10. 派发 prompt 的 subagent_type 只写纯 token（executor/code-reviewer/code-assistant），禁括号模型后缀（v095 教训）

## 🧯 FMEA（7 列，RPN 降序）

| ID | Phase·失败模式 | 影响 | S×O×D=RPN | 兜底/检测动作 | 责任 S-unit | 状态 |
|----|---------------|------|-----------|---------------|-------------|------|
| F1 | P2·init-session 追加区块破坏下游解析（check-scope/check-3file-gate/check-template-type 读 task_plan.md） | 下游门控误判/计划解析失败 | 8×5×3=120 | 追加前 grep 下游解析锚；两分支正/负例实测；selftest 兜底（→ knowledge-brief §4 指针） | P2-S1/S2 | open |
| F2 | P3/P8·全自动生成误沉淀一次性任务（34.5 失守） | 模板库污染、泛化性劣化 | 7×4×3=84 | 生成侧双闸门（ls variant 查重+泛化评估强制登记不沉淀理由）写入 34.7 条款；终验 CR 抽查条款完备性 | P3-S1/P8-S1 | open |
| F3 | P3/P5/P6·计数级联遗漏（新 variant 后 TL-17「16 个」断言 FAIL） | selftest 回归 FAIL | 6×5×2=60 | 34.7 条款+卫星 SOP 把计数级联列为生成合约必做步；P6 selftest 断言计数一致性 | P3-S1/P5-S1/P6-S1 | open |
| F4 | P3·C22/Rule 34 摘要行锚断裂（selftest-template-lifecycle TL-14/15 FAIL） | 守护回归 FAIL | 7×5×2=70 | 行内改关键词保全+改前快照差集对账（强制约束 6） | S2 | open |
| F5 | P4/P6·check-complete 新 warn 段误报正常计划 | 终验噪音/误导 | 5×4×2=40 | 区块存在性判定精确（grep「🔁 模板感知」）+正常计划负例断言 | P4-S1/P6-S1 | open |

## Phases（8 Phase；P2-P6 串行派发，P7-P8 收敛）

### Phase 1: 基线与隔离区
- [x] 全量 selftest 基线实测：**35 脚本 584 PASS/0 FAIL**（progress.md Phase 1 段）
- [x] worktree 已建立：/mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record（@ de8e8fe）
- [x] 改动点消费方断言清点完成（findings P1 段：init-session×5/PT-13 三锚保全、check-complete×8 但 final-gate-hash 沙箱副本可编辑、T6 窗口零位移、SKILL 行数钉安全）
- **Status:** complete
- **Executor:** 主进程（例外理由：Rule 25.1 白名单——① git worktree 编排属主仓 git 操作必须主进程；③ 全量基线求和纪律禁子代理自报总数，硬约束 9）

### Phase 2: T1 init-session 感知块
- [x] general fallback 与 unknown 两分支 emit `[template-sense]` + 运行时追加「🔁 模板感知」区块 ✅（+55 行纯追加；两块互斥幂等；unknown WARNING 保留；mini 正交保全）
- [x] 已知类型零触发负例 + 下游脚本兼容实测 + bash -n ✅（bugfix 负例 0；check-template-type/check-scope/check-3file-gate 对含区块产物全过；五 selftest 32/16/19/19/18 全绿；PT-13 三锚保全）
- **Status:** complete
- **Executor:** executor
<!-- 前置: 先 grep 下游解析锚与 mini tier 分流正交性（knowledge-brief §4 条 10，F1 兜底） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | general fallback 分支（L149-165 决议为 general 时）emit+追加区块 | executor | scripts/init-session.sh:149-165（fallback 链 PDIR default>env>general）+ knowledge-brief §2 F5/§3 A6/A8 + §4 条 1/10 | 模拟空 template_type 运行：输出含 `[template-sense]` 且生成 task_plan.md 末尾含「🔁 模板感知」区块；bugfix 已知类型负例零触发；check-template-type 对含区块计划实跑正常 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P2-S1-executor.md |
| S2 | unknown 分支（L183-186）emit+追加区块+回归自验 | executor | scripts/init-session.sh:183-186（unknown WARNING 分支）+ knowledge-brief §3 A7/A8 + §4 条 5/9 | 未知类型输入触发 emit+区块；`bash -n` 0；selftest-plan-tier 与 init-session 相关 selftest 全绿 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P2-S2-executor.md |

### Phase 3: 条款层（T2）
- [x] critical-rules.md 纯追加 34.7 ✅（L319 单行追加，快照 diff 零位移实证；Rule 编号 170→171；TL/KB/MP 绿）
- [x] SKILL.md 三处联动 ✅（摘要行行内/C22 行内全自动语义/指针行净增 1；「Rule 34（P0）模板生命周期门控与沉淀」子串 -F 保全；429→430；四 selftest 绿）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | 写入 34.7 全文（纯追加，禁动 34.1-34.6） | executor | references/critical-rules.md:313-318（Rule 34 现行六子条，L390 末行）+ knowledge-brief §1（合约定义）/§3 A1 + §4 条 3/5/7 | `grep '^34.7'` 命中；改前快照 diff 证明 L313-318 零变化；Rule 编号完整性（34.1-34.7 连续） | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P3-S1-executor.md |
| S2 | SKILL.md 三处行内联动+锚保全 | executor | skills/task-planner/SKILL.md:262,186,214（摘要行/C22/沉淀段）+ knowledge-brief §2 F2-F4/§3 A2-A4 + §4 条 4/6 | 三处 grep 新语义命中；旧锚子串保全（强制约束 6 清单）；`wc -l` 净增 ≤3；selftest-template-lifecycle TL-14/15 绿 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P3-S2-executor.md |

### Phase 4: T3 终验层
- [x] check-complete.sh 增 warn 抽查段 ✅（+10 行 :561-570 fmea-gate 段后；正/负例×2 实测；退出码零变化；8 个消费 selftest 绿；主进程亲验零误报；commit 6079c0b 内容接受、越权登记 Error Log）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | 新增 template-sense warn 段：plan 含「🔁 模板感知」且未登记沉淀/不沉淀理由 → 输出含 template-sense 的 warn | executor | scripts/check-complete.sh:486-517（fmea-gate warn 范式：`[fmea-gate] ⚠` 不阻断）+ knowledge-brief §3 A9 + §4 条 3 | 正例（含区块未登记）warn 命中；负例（正常计划）零输出；负例（已登记理由）零输出；bash -n 0 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P4-S1-executor.md |

### Phase 5: 卫星联动
- [x] plan-template-kit/SKILL.md 沉淀节补全自动合约+计数级联清单 ✅（+2 bullets 34→36 行；TL-17 同改要求在列；mapping/guide 零改；TL/MP 绿）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | 卫星沉淀节补 34.7 全自动合约与计数级联清单 | executor | skills/plan-template-kit/SKILL.md 沉淀指针节（已含 34.3→34.2 四点同步指针）+ knowledge-brief §3 A12 + §1 合约 | grep「全自动」与「计数级联」锚命中；template-mapping/template-guide 零改（git diff 证明）；TL-16/17 仍绿 | 10min | pending | plans/task-v096-template-auto-record/subagent-state/P5-S1-executor.md |

### Phase 6: selftest-template-sense 新建 + registry
- [x] 新建 selftest-template-sense.sh ✅（6 断言 case-1..6 行为级全绿；mktemp+trap 零仓库写入；调试 1 轮合规）
- [x] 登记 registry ✅（tsv +1 行 rows=36=actual 双向核对；registry 5/0；回归 TL 18/0+PT 32/0）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | 编写 selftest-template-sense.sh（对齐 selftest-template-lifecycle.sh 范式） | executor | scripts/selftest-template-lifecycle.sh:75-81（TL-14/17 断言范式）+ knowledge-brief §1 触发样例 + §2 registry 行 | 新脚本 6 断言全 PASS；单用例调试 ≤2 轮，超则记 blockers 交主进程 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P6-S1-executor.md |
| S2 | registry 双落点登记+单脚本复跑 | executor | scripts/selftest-registry.tsv + selftest-registry.sh（35 行既有格式）+ knowledge-brief §2 F9 | grep 新脚本名在 tsv 与 sh 双命中；单脚本 Total=6/0 FAIL | 10min | pending | plans/task-v096-template-auto-record/subagent-state/P6-S2-executor.md |

### Phase 7: 全量验证 + 合并 + 部署
- [x] worktree 内全量 selftest 复跑 ✅（36 脚本 590/0，主进程白名单③）
- [x] 合并前置检 ✅（status 干净/5 提交完整/VC-1~5 沿途证据齐）
- [x] 主仓合并+清理 ✅（smart-merge-back V1-V6 全过，merge=ed8712d；worktree/分支已清理）
- [x] 三实体位部署 ✅（diff -r 15/15 IDENTICAL+位上 sense 6/0）
- **Status:** complete
- **Executor:** executor（S1/S2）+ 主进程（S3/S4；例外理由：Rule 25.1 白名单① git 编排/合并属主仓操作，③ 部署位复验与基线对账须主进程终裁）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | 全量 selftest 复跑+回归修复 | executor | worktree 内 scripts/selftest-*.sh（36 个）+ knowledge-brief §4 条 8 + §2 F11 | 自报总数仅参考；0 FAIL 或 blockers 清单交主进程 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P7-S1-executor.md |
| S2 | 合并前置检清单核验 | executor | worktree `git status`/`git log` + VC-1~VC-5 证据 + knowledge-brief §4 条 12 | status 干净、逐 Phase 提交 ≥7、VC 复验表全勾 | 10min | pending | plans/task-v096-template-auto-record/subagent-state/P7-S2-executor.md |
| S3 | merge --no-ff + worktree 清理 | 主进程（白名单①：主仓 git 编排，宪法 §11.3） | knowledge-brief §4 条 12 + P7-S2 检查点 | `git log` 含 merge commit；`git worktree list` 无残留；`git branch` 无 wt/task-v096-* | 10min | pending | plans/task-v096-template-auto-record/subagent-state/P7-S3-main.md |
| S4 | install.sh 部署+diff -r 复验 | 主进程（白名单③：部署位终裁+基线对账禁委派） | skills/task-planner/install.sh + knowledge-brief §2 F9 | 三实体位 diff -r 一致；36 脚本全量求和 ≥ P1 基线且 0 FAIL（主进程实跑） | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P7-S4-main.md |

### Phase 8: CR Gate + 终验簿记
- [x] CR Gate ✅（首轮 CHANGES_REQUESTED 2×P1+1×P2 沙箱复现 → fix-phase 78f8e0e 一处守卫双杀+selftest 8 断言 → 复审 APPROVED 含 bite test 咬合验证；79a82e2 已合并+三位重同步）
- [x] 主进程 VC 逐条勾验 ✅（verification.md 全 VC PASS：36 脚本 592/0/部署 15/15/委派 verdict=ok WHITELIST-EXEMPT）
- [x] 簿记 ✅（INDEX/ledger/memory/push 于交付报告前完成）
- **Status:** complete
- **Executor:** code-reviewer（S1）+ 主进程（S2；例外理由：Rule 25.1 白名单⑤ CR Gate 终验裁决与终验结论定级属主进程终裁，② 簿记落盘）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 检查点路径 |
|----|------------|--------|------------------------|-------------|---------|------|------------|
| S1 | CR 审查 wt 分支全量 diff | code-reviewer | worktree diff（P1 基线..HEAD）+ knowledge-brief §1 合约 + §4 条 6/7 | APPROVED/BLOCKED 结论+问题清单落检查点；锚保全与 34.5 条款完备性专项核对 | 15min | pending | plans/task-v096-template-auto-record/subagent-state/P8-S1-code-reviewer.md |
| S2 | 终验簿记+呈示 | 主进程（白名单⑤②：终验裁决+簿记） | verification.md + 六 VC 证据 + knowledge-brief §2 F11 | 六 VC 全勾；INDEX/ledger 条目落盘；结论呈示用户 | 10min | pending | plans/task-v096-template-auto-record/subagent-state/P8-S2-main.md |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（v095 已交付合并 aa092cc..de8e8fe 已 push，无并行冲突面） |
| `isolation` | `worktree`（保护区文件命中宪法 §11.1 条款 1/4） |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record |
| `branch` | wt/task-v096-template-auto-record |
| `merge_back` | pending（P7-S3 完成后回填 merged(<commit>)） |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ | 2026-09-29 | 计划创建即建 |
| Phase 2 | ☐ |  | executor 串行 |
| Phase 3 | ☐ |  | executor 串行 |
| Phase 4 | ☐ |  | executor |
| Phase 5 | ☐ |  | executor |
| Phase 6 | ☐ |  | executor，单用例调试 ≤2 轮 |
| Phase 7 | ☐ |  | S1/S2 派发 + S3/S4 主进程 |
| Phase 8 | ☐ |  | CR Gate + 呈示 |

## ❓ Key Questions
1. KQ1：「🔁 模板感知」区块追加格式是否干扰 check-scope/check-3file-gate/check-template-type 对 task_plan.md 的解析？（P2-S1 前置 grep 裁决，F1 兜底）
2. KQ2：T1 追加点实现位置——fallback 决议点内联还是脚本尾统一追加，才能与 mini tier 分流（L189-194）正交？（P2-S1 内定，验收含分流负例）
3. KQ3：34.7 全自动生成执行体写 plan-writer 还是 code-assistant？（P3-S1 条款措辞留「plan-writer 或 code-assistant」双选项，终验期按上下文路由）
4. KQ4：基线 584/0 是否随环境漂移？（P1 实测定锚，VC-5 以实测为准）

## 📋 Decisions Made
| # | 决策 | 理由 |
|---|------|------|
| D1a | 激活策略=三时点感知网（T1 init-session 机器提示+区块预登记 / T2 34.7 条款 / T3 check-complete warn 兜底），不碰 UserPromptSubmit hook | 用户 D1 裁决①（AskUserQuestion，2026-09-29）；v091 实证 hook 税是最大慢源 |
| D1b | 模板创建=全自动静默生成（不问用户）；34.5 防滥用闸门内置生成侧（ls variant 查重+泛化性评估，不足→登记不沉淀理由而非硬生成） | 用户 D1 裁决②（同上）；避免终验期 AskUserQuestion 打断；闸门前置防模板库污染 |
| D2 | template_type=rule-enhancement | 新增 Rule 子条（34.7）+SKILL 联动+selftest 守护，与 variant/rule-enhancement-type 触发面精确匹配；非 bugfix/code-edit |
| D3 | 本任务自身预计不沉淀新 variant（rule-enhancement 已存在）；计数级联仅作为 34.7 条款内容落地，非本任务执行项 | variant ls 实测 16 个已含 rule-enhancement；硬约束 2/3 联动 |
| D4 | 思路复述已呈示（2026-09-29，计划确认消息内 4 行：Phase 序列/执行体/门控兜底/隔离交付），用户显式 yes 批准 | Rule 28 interaction_mode=ask；呈示=主进程职责，plan-writer 只产出文档 |
| D5 | worktree 隔离 + 逐 Phase 提交 + 合并回后 install.sh 三实体位部署 | 宪法 §11.1 保护区命中；简报 §2.3 硬约束 |

## 🤝 Subagent Handoff 登记表（Rule 22.5，执行期回填）
| Seq | Phase | subagent_type | 任务一句话 | checkpoint 路径 | 状态 | 返回摘要 |
|-----|-------|---------------|-----------|-----------------|------|---------|
| 1 | P2 | executor | init-session general 分支感知块（区块追加函数化供复用） | plans/task-v096-template-auto-record/subagent-state/P2-S1-executor.md | done | 5/5 验收过；+26 行；发现 general 产物基线过不了模板门已修 |
| 2 | P2 | executor | init-session unknown 分支感知块 | plans/task-v096-template-auto-record/subagent-state/P2-S2-executor.md | done | 正/负/幂等/正交全过；裁量=显式 general 不触发已登记 |
| 3 | P3 | executor | critical-rules 34.7 纯追加 | plans/task-v096-template-auto-record/subagent-state/P3-S1-executor.md | done | 单行追加零位移；170→171；三 selftest 绿 |
| 4 | P3 | executor | SKILL.md 三处联动 | plans/task-v096-template-auto-record/subagent-state/P3-S2-executor.md | done | 净增+1；锚差集空；移交 P7 复核 C22 措辞与 warn 标签一致性 |
| 5 | P4 | executor | check-complete warn 段 | plans/task-v096-template-auto-record/subagent-state/P4-S1-executor.md | done | +10 行三例实测；越权 commit 内容接受已登记 Error Log |
| 6 | P5 | executor | plan-template-kit 沉淀节联动 | plans/task-v096-template-auto-record/subagent-state/P5-S1-executor.md | done | +2 bullets；mapping/guide 零改；TL/MP 绿 |
| 7 | P6 | executor | selftest-template-sense 新建+registry | plans/task-v096-template-auto-record/subagent-state/P6-S1-executor.md | done | 6/0+registry 36=36；调试 1 轮合规 |
| 8 | P7 | 主进程 | 全量 selftest+合并前置检（白名单③接管） | plans/task-v096-template-auto-record/subagent-state/P7-main.md | done | 590/0+merge ed8712d+部署 15/15 |
| 9 | P8 | code-reviewer | CR Gate 全量 diff 审查 | plans/task-v096-template-auto-record/subagent-state/P8-S1-code-reviewer.md | done | CHANGES_REQUESTED（2×P1+1×P2 沙箱复现）；fix 后复审 APPROVED（P8-rereview.md bite test） |

## 📚 必要知识储备
| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 计划目录 | 设计简报（唯一需求与设计权威源） | plans/task-v096-template-auto-record/subagent-state/01-plan-writer-brief.md | ☑ |
| 计划目录 | 知识底座五段（材料包索引） | plans/task-v096-template-auto-record/knowledge-brief.md §1-§5 | ☑ |
| 规则条款 | Rule 34 现行六子条（34.7 插入点） | references/critical-rules.md:313-318 | ☑ |
| 脚本范式 | fmea-gate warn 段范式 | scripts/check-complete.sh:486-517 | ☑ |
| 脚本范式 | TL 断言范式+计数级联守护 | scripts/selftest-template-lifecycle.sh:75-81 | ☑ |
