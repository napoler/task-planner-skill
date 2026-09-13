# 01-general-purpose — task-v065 Phase 1 审计（skill-fix Phase 1 诊断）

status: done
started: 2026-09-13
finished: 2026-09-13
target: /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue/skills/task-planner/
exit_summary: 审计完成，worktree `git status --porcelain` 空（只读约束遵守）；产出 diagnostic-report.md（552 行）

## 最终结论

用户核心诉求「子代理失败后挽救而非摆烂」判定：**文本齐备、机制全缺**。
- 全库 `grep -rniE "salvage|挽救|摆烂|放弃"` → 零命中（92 文件）
- 无任何脚本/hook 观测「子代理失败」事件；check-dispatch.sh:48 的 7 个检查项全是派发前 prompt 内容
- 唯一失败相关机制 3 处：check-dispatch.sh（派发前）、subagent-fallback.sh（仅 provider + 人工调用）、.dispatch-inflight 串行锁

统计：**P0 8 条 / P1 14 条 / P2 5 条**（诊断报告 §6）

## 已确认 F 编号（失败挽救链路，报告 §1）

- F-1 [P0] 五档兜底无机械门控（SKILL.md:378/380/390-394 + critical-rules.md:124；零脚本校验失败后动作）
- F-2 [P0] check-plan-dispatch.sh:30 legacy 判定键="执行体" → 实测 v065（6 Executor 行/0 S-unit 表）输出 `legacy plan(无执行体列),跳过门控` exit 0，且 .plan-attestation 已 15:48 成功锁定 = 门控被实际绕过
- F-3 [P1] 22.7「连续失败 ≥2 次 → 强制 STOP」（critical-rules.md:132）未限定"已走完挽救链"，与 21.4/22.3「拆细先于升档」冲突
- F-4 [P0] STOP/BLOCKED 无「已尝试挽救清单」要求（22.7 全文 32 字；SKILL.md:403 仅泛述"不留证据"）
- F-5 [P1] Handoff 表无 rescue/挽救状态列（templates/task_plan.md:345 有 findings 落点/checkpoint/verify_done，缺 rescue；subagent-fallback.sh:241/:277 只在 JSON note 里写自由文本建议）
- F-6 [P1] subagent-fallback.sh:260 把 `timeout` 并入 provider 升档（违背 21.4 首败即拆细）；:270 编号 ③④ 应为 ④⑤；:280 枚举漏 ②拆细（写成 ①换类型→②降档→③接管→④AskUser）
- F-7 [P0] provider 改派本会话不可兑现（SKILL.md:405/critical-rules.md:125 如实登记），而 ④ 主进程接管限"单文件 ≤300 行"（:124）→ >300 行场景无挽救路径
- F-8 [P0] silent 模式死结：22.7 是 D6 硬停点不可静默豁免（critical-rules.md:219）+ 28.4 silent 不调 AskUserQuestion（:221）+ 第 5 档"推荐项"未定义 → autonomous 必挂起
- F-9 [P1] D3「③ 降档前询问」（:219）与 SKILL.md:388 五档表（第 4 档后才问）矛盾

## 规范违规（报告 §2）

P0：V-1（SKILL.md:5 allowed-tools 缺 AskUserQuestion/WebSearch/WebFetch，实测 AskUserQuestion 用 4 次/WebSearch 5 次/WebFetch 2 次）、V-2（7 个 variant 模板把 Skill() 放进 Executor=子代理的 Phase）、V-3（=F-2 机制面）
P1：V-4（sync-todos.sh:77 subject 丢 title，phase_title 死变量，与 todo-sync.md:18/SKILL.md:72 矛盾；status 未清洗）、V-5（sync-todos.sh:38 PLANS_DIR=$(pwd)/plans 无向上解析）、V-7（plan-created.cjs:65-72）、V-8（attest-plan.sh:31 ls -t）、V-9（VC 零机械校验 + 模板无 per-Phase V-N）、V-11（S75 D1：companion model UUID/plan-writer.md:95 cwd/worktree-isolation.md:49 硬编码）、V-12（S75 D3：SKILL.md:68/template-guide.md:12/template-mapping.md:102,104）、V-13（S75 D2：3 个 .ts 无 @configurable）、V-14（S76 D2：check-delegation.sh:196 + allow-direct.sh:118 无锁追加账本，而 ledger-append.sh:132 有 flock）、V-16（lib/verify.sh:227 缺 selftest-methodology.sh 等 5 个）
P2：V-6（sync-todos.sh:91-99 重复函数）、V-10（methodology.md:4 锚点 :81→:82/:156→:159）、V-15（subagent-fallback.sh:40 内置 10000 vs config 20000）、V-17（template-guide.md:106 引用不存在的 templates/task_plan-research.md）、V-18（critical-rules 实为 1-28，frontmatter/References 表写 1-27）

## 三条已知线索（报告 §3.7）

① plan-created.cjs → 复现：只读模拟 readdirSync 首个命中 = plans/task-3file-enforce/task_plan.md（真实活跃 = v065；共 32 个计划目录）→ 与父计划观察项逐字吻合；「无计划仍 exit 1」恒不触发
② sync-todos.sh --json → 主假设（无 S-unit 列导致未收录）**排除**：显式传 plans 目录时 v065 正常收录（grep -c v065 = 1）。真实根因 = :38 无向上解析，按 SKILL.md:297 init 流程 cd 进 plan 目录后跑 SKILL.md:72 的命令 → `{"error":"no_plans_dir"}`
③ attest-plan.sh → 复现：同 ① / F-2，最严重一条（P0 门控已实际放行本计划）

## 机械扫描（报告 §3，全绿项与异常项）

- bash -n：42 个 shell 文件全 exit=0（scripts/*.sh 33 + install/uninstall/lib 6/tests 1）；bun build --no-bundle 3 个 .ts 全 0；node --check 2 个 .cjs 全 0
- S64：bun 存在；path_existence_validator --scope all → verdict PASS（references 6/scripts 15 全 OK，P0=0/P1=0）。盲区：不扫 references/*.md 内文（V-17 因此漏报）；命中时输出常量标签 `.zcode/skills/<n>/scripts/<n>` 易误读（登记 §5 D-1/D-2）
- S75 D1 = 72 命中（分类见 V-11）；D3 = 5 命中；D2 = 3 个 .ts 缺 @configurable
- S76：D1 ✅ / D2 ⚠ P1（V-14）/ D3 ✅ / D4 ✅（3 处状态写均 tmp+rename）
- TODO/FIXME/空壳扫描：零命中（仅 mktemp XXXXXX 与 stub 薄壳正当用法）

## 负结果（已检查未发现问题）

- subagent-state 检查点机制存在且齐备（critical-rules.md:133-138 / templates/subagent_dispatch.md:80-88 / check-dispatch.sh:48,226）
- templates/subagent_dispatch.md（派发 prompt 模板本体）零 Skill( 命中
- Handoff 模板未漏 findings 落点/verify_done（仅缺 rescue，见 F-5）
- 22.4a 三文件读写契约与模板 §2 一致，无自相矛盾
- SKILL.md Goal 语句（:29）与全文 grep 模糊动词（优化/改善/增强/提升/改进/完善/加强/促进）→ 零命中，S47/S48 通过
- 全库无 TODO/FIXME/空壳脚本

## 产出

- 诊断报告：/mnt/data/dev/task-planner-skill/plans/task-v065-subagent-failure-rescue/diagnostic-report.md（552 行，§0-§6 + 修复清单排序表）
- 本检查点：/mnt/data/dev/task-planner-skill/plans/task-v065-subagent-failure-rescue/subagent-state/01-general-purpose.md

## 交接提示（给 Phase 2 主进程）

- L1（Phase 3 必改，P0）：F-2/V-3（check-plan-dispatch.sh:30 一行修复，解锁全部门控）→ F-1（新建 check-rescue-chain.sh）→ F-4（22.7.1 STOP 6 字段）→ F-7/F-8（无解场景兜底）→ V-1/V-2
- Phase 2 整合时请抽查复核：F-2 的实测输出（可自行复跑 §3.7-③ 命令）、V-2 的 7 处 file:line、V-7 的 readdir 模拟结论
- V-9 与 F-1 共用 check-complete.sh 改动，建议同批提交
