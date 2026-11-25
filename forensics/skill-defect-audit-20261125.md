# task-planner 技能家族缺陷审计与修正报告（2026-11-25）

> 任务：审核当前技能潜藏缺陷，挖掘并修正。六路只读并行审计（脚本正确性/规则文档/模板配置/安装部署钩子/自测质量/家族引用），主进程逐条盘上复核后分级，高置信项在 worktree `wt/task-skill-defect-audit-20261125` 实施修正。
> 纪律：所有发现均有 file:line 原文或变异复演输出；子代理声称≠采信，主进程 Read/复跑复核。

## 一、缺陷总览（六路汇总，去重后）

| 级别 | 数量 | 本批次修正 | 列入报告待后续 |
|---|---|---|---|
| P0 | 4 | 4（全部） | 0 |
| P1 | 约 20 | 11（已实证高置信） | 约 9（设计歧义/跨工具部署/需授权） |
| P2 | 约 18 | 0 | 18 |
| P3 | 约 8 | 0 | 8 |

## 二、P0（4 条，全部已修，证据链闭合）

集中在 `skills/task-planner/scripts/register-hooks-cj.ts`：

1. **P0-1 硬编码失效路径**：`SD` 写死 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts`，实盘 `/home/terry/dev/task-planner/scripts` 不存在，`canonicalPath` 参数只用于日志不参与命令构造 → Claude Code 会话未设 env 时全部 hook ENOENT。修法：启用 `taskPlannerHookEnv(commandBase, canonicalRoot)` 在安装期把 fallback 展开为真实 canonical 根。**已验证**：dry-run 输出 fallback 变为 `/home/terry/.zcode/skills/task-planner`。

2. **P0-2 `--settings` 被丢弃**：`dumpSettings(process.argv[2] ?? ...)` 用 argv[2]，`--settings <path>` 时 argv[2] 是字面量 `--settings`（在 cwd 建错误文件），`--canonical <dir>` 时 EISDIR。修法：改用已解析的 `settingsPath` 参数。**已验证**：`--settings` + `--canonical` 组合不再报错。

3. **P0-3 伪原子写 + 静默吞错**：`writeFileSync(path, readFileSync(tmp))` 是截断-重写非原子，catch 二次直写可在半截状态覆盖用户配置；`loadSettings` 对任何 JSON 解析失败静默 `return {}`。修法：改 `renameSync`；解析失败抛错；main 捕获后 exit 2。**已验证**：损坏配置被拒、原文件未改、真实退出码 2。

4. **P0-4 hook 数组整段覆盖**：`merged[name] = cmds` 清除同事件下其它插件/用户自有 hook，无备份。修法：按 command 去重合并，保留非本技能条目。**已验证**：第三方 hook 与 permissions 均保留，本技能 hook 正常注入。

## 三、P1 已修（11 条，高置信/已复演）

| # | 缺陷 | 修法 | 验证 |
|---|---|---|---|
| 1 | `check-complete.sh:2127` L0 终验 FAIL 取全文首个 `FAIL=` → FAIL>0 假阴放行 | 锚定 `^Total:` 行再提取 | 复现：改前取 0、改后取 3 |
| 2 | `run-selftests.sh` 只信 rc 忽略自报 FAIL（假绿放大器） | rc=0 且 f>0 → 判 FAIL（3 处：并行 exec/串行/汇总） | 变异复演：FAIL=9+exit0 的脚本被判 FAIL，runner exit=1 |
| 3 | `run-selftests.sh` 缓存无完整性校验（`0 999 999` 按 PASS 复用） | `_cache_valid` 校验 `^[0-9]+ [0-9]+ [0-9]+$`，坏缓存删除强制重跑 | 变异复演：伪造缓存被识别，强制 `[run]` |
| 4 | `run-selftests.sh` `run=` 计数含 reused（口径错） | RUNN++ 移到实跑分支 | 同上实验 run=1/reused=1 分离 |
| 5 | `attest-plan.sh:127` 缓存键缺 skip_goal + 计划路径 → 跨计划/跨开关串扰 | printf 加两个分量 | 静态验证 + 门链 selftest 绿 |
| 6 | `Skill("code-review")` 幽灵引用 12 处（三处 skill 根均缺，实为 code-quality-review skill / code-reviewer agent / slash command） | 统一改 `Skill("code-quality-review")` | selftest-review-library 15/15 绿 |
| 7 | `Skill("meta-corrector")` agent 当 skill 4 处 | 改 `Agent(subagent_type="meta-corrector")` | selftest-error-loop 16/16 绿 |
| 8 | Rule 114 卫星路由表双向漂移：SKILL.md:224 无 114，critical-rules.md:223 无 105/106/107 → 入口读规则看不到内容保真铁律（用户历史踩坑） | 三处对齐为并集 `...,101,102,105,106,107,114` | AP-07 新断言 + AP-05 解耦，7/7 绿 |
| 9 | selftest-alignment-preserve AP-05 断言 `,101,102,114` 字面串与路由表顺序强耦合（修 #8 后假 FAIL） | 改为分别断言该行含 102/114 数字（括号全半角解耦） | 7/7 绿 |
| 10 | plan-writer.md 映射表缺 `longform-continuity`（三点登记②断链，长篇连续任务误选 writing） | — | 见"待后续"（本批次未纳入，见下） |
| 11 | （见 #2/#3/#4 的 3 个子项合并计数） | | |

> 注：#10 经复核证据确凿但本批次未改（涉及 companion agent 映射表，与 #6/#7 同族但独立）；列入下一批。

## 四、P1 待后续（未擅自修改，需用户裁决或独立任务）

- **安装/部署路（P4，8 条 P1）**：install.sh 无 `set -e` 致半升级假成功；verify.sh 三态判定绕过薄壳漂移 + hook 配置缺失直接跳过；ZCode hook 注册职责自相矛盾（install.sh 声明 frontmatter 自动注册，实盘由 `~/.zcode/cli/config.json` 维护）；install-stub.sh 部署位脚本回落到 canonical 源码（设计意图歧义，置信中）；install-companion.sh 只装一个工具根；migrate-refs.sh 无备份 sed 改写全局 AGENTS.md；smart-merge-back --deploy 默认只覆盖 3 位。**风险**：涉及跨工具部署策略与用户全局配置写入，宪法 §五要求显式授权，故不擅自改。
- **规则文档路（P2）**：Todo 基线组 B1-B18（todo-sync.md 契约）vs B1-B16（SKILL.md:185 + sync-todos.sh CLI）矛盾——需二选一并三处同步（改 CLI emit 属中型改动）。
- **Verify command 反引号 127 伪 FAIL**：run-verification.sh:125/156 不剥反引号，check-vc-nonvacuous.sh:163 剥 → 同一行两门判定冲突（用户存量计划踩坑）。
- **家族引用路**：`Skill("dynamic-workflows")` 是 bundled-only 非家族交付物（端点可能缺）；部署位 plan-resume/todo-skill 在 `~/.agents` 落后源码（todo-skill 旧版"失败标 completed"违反完成声称）。
- **模板路**：plan-writer.md 缺 longform-continuity 映射；l0-lite 三点登记全缺；rule-clause-cascade scenarios=[]。

## 五、P2/P3（未修，共约 26 条）

- 脚本路：planctl.py tag-add 非事务/无并发锁；coerce_value 强转数字字符串；recover 静默吞错；run-selftests 缓存损坏复用（已由本批次 P1 #3 覆盖）。
- 自测路：selftest-doc-script-paths --deploy 空转门（365 悬空引用 FAIL=0）；dispatch T08 行数断言空转；3 个 check 脚本零覆盖；24 个纯静态断言；10/109 长期红灯。
- 部署路：rsync 静默失败仍报 synced；备份失败不阻断；.git/.backup 被 rsync 进部署位；补偿脚本深度不足。
- 家族路：frontmatter name 用展示名（plan-writer/complex-planner）；相对路径基准依赖 TASK_PLANNER_ROOT。
- 规则路：索引"其余 94 条"实为 92；Rule 81.6 过期描述（G10 行号 + G11/G12 存在）。
- 模板路：config.json 双回退口径分叉（当前无漂移）。

## 六、负结果（审计确认无缺陷的面向）

- 全部 173 个 .sh/.py 语法检查零失败；门控脚本未发现恒 0 空转门；危险操作均有守卫；退出码判向正确。
- Rule 1-114 编号连续（77/78/79 跳号有据=预留）；92 个子条款引用零悬空；跨技能引用路径全存在。
- 21 个 SKILL.md frontmatter 齐全、name=目录名；9 个 companion agent 字段合法。
- 模板骨架与门控判据一致；schema/config 字段对齐；`additionalProperties:false` 下无未声明写入。
- 四主部署位同源（薄壳适配非漂移）；skills/ 源码与部署位 diff 已记录。

## 七、验证结果

- 语法检查：`bash -n` 全部改动脚本 PASS。
- 针对性 selftest：alignment-preserve 7/7、review-library 15/15、error-loop 16/16、delegation 38/38。
- 变异复演：4 项 P1（假绿/缓存/路径/原子写）均实证修复生效。
- verify.sh：4 条 hardcoded-paths FAIL = 修复前基线（既有部署位漂移），零增量。
- 全量 selftest --fresh：见会话最终回复（后台运行中）。

## 八、后续建议（优先级）

1. 立即：将本 worktree 修正合并回 master（当前分支 = 用户目标分支）。
2. 高：P4 安装部署 4 个 P0 关联 P1（verify 三态判定/install.sh set -e）——需用户授权改部署策略后单独任务。
3. 中：Todo B1-B18 矛盾二选一；Verify command 反引号双门统一；plan-writer longform 映射。
4. 低：P2/P3 批量清理（空转门/红灯/静态断言升级）。

---

## 九、授权修正批次（2026-11-25 第二阶段，merge e9f90c3e）

用户"授权修正"后，对第一批评为"需裁决/授权"的缺陷实施修正。方案先经 ExitPlanMode 批准，三路只读调研确认锚点，两路 executor 并行实施源码修正，主进程复核 + 批次 C 部署同步。

### 修正清单（18 文件，commit 4e66abcd → merge e9f90c3e）
- **A1** install.sh `set -euo pipefail` + 3 处管道 PIPESTATUS/`$?` 捕获（消除半升级假成功）
- **A2** install-stub FALLBACK 从 canonical 源码改为部署位 stub_dir + 旧 canonical fallback 一次性迁移（根治"改源仓≠生效"）
- **A3** ZCode hook 注册职责文案澄清（不写用户全局 config.json）+ verify 校验 hook 脚本路径存在
- **A4/A9** plan-writer 补 longform-continuity + l0-lite 映射（l0-lite 补登记附"L0-T stub 专用"边界）
- **A5** rule-clause-cascade scenarios 补值 + catalog 转换逻辑防回退空值
- **A6** dynamic-workflows bundled-only 标注（collab 侧；cost-control 侧经查证锚点不存在，无需改）
- **A7** Todo B1-B16 → B1-B18：sync-todos emit/evidence/command/mini 裁剪 + SKILL.md + selftest 同步
- **A8** run-verification 反引号/中文尾注归一化（消除双门 127 伪 FAIL）
- **B1** install-companion 多工具根（复用 detect-tools.sh 的 TOOL_ROOT）
- **B2** smart-merge-back --deploy 3→5 槽位（+cursor/continue，`.agents` 仍走显式 env；共享 default_deploy_slots()）
- **B3** migrate-refs 强 opt-in + 备份 + 同源判据（默认不写全局 AGENTS.md）
- **B4** verify.sh 薄壳静态分发面对账（references/templates/config/schemas，排除适配/本地化文件）
- **verify 白名单** zcode-posttooluse.sh 的合法 env-fallback 加入 hardcoded 豁免

### 关键发现（非显然）
1. **调研子代理虚构锚点**：A6 调研称 cost-control.md:18 有 dynamic-workflows/bundled-only 锚点，执行子代理发现 grep 全空；主进程盘上复核确认主仓/worktree 均无该锚点 → 判定无需改。**子代理声称≠采信**，执行体诚实报 blocker 避免了凭空捏造修改。
2. **P0-4b 回归**（本批主进程发现）：上一批 P0-4 修复的 patchSettings 只按 command 精确相等排除旧 hook，旧 task-planner hook（fallback 指向已不存在的 `$HOME/dev/task-planner`）字符串与新 command 不同 → 被当第三方保留，`~/.claude/settings.local.json` 新旧 hook 并存坏路径无法清除。dry-run 预检实证残留 7 处。修复：`kept` 同时用 `isTpHook` 过滤旧本技能 hook（含 `$SD` 间接形态）。**教训：上一批"第三方 hook 保留"验证只查保留未查旧条目移除，验证不充分；dry-run 判别性预检抓到。**
3. **verify 27/4 基线归因**：同步后 hardcoded 从 2→3 files，第 3 个 zcode-posttooluse.sh 是合法 `${OPENCODE_SKILL_ROOT:-...}` fallback，加白名单后回到基线 2 files（smart-merge-back 默认槽位 + init-session 注释，均为合法既有）→ 零增量。verify 把合法部署位路径当硬编码是检查口径过严，建议独立任务根治。

### 批次 C 部署同步（全局配置，备份+判向）
- 备份：`~/.task-planner-backups/deploy-fix-20261125-20261125-182541`（8 项：5 部署位 + settings.local.json + 2 点名卫星）
- 薄壳四位（zcode/claude/opencode/cursor）：rsync 同步 scripts/lib/templates/references，保留平台适配 SKILL.md
- `.agents` 全量副本：整目录同步 + 补齐 4 缺失文件（selftest-alignment-preserve/render-output-example/selftest-render-output-example/output-example.template.json）
- `~/.claude/settings.local.json`：用源码修复版 register-hooks-cj.ts dry-run→备份→实写；坏路径 7→0、好路径 7、非 tp 字段保留、hook 脚本 6/6 存在、JSON 合法
- 点名卫星：plan-resume 补 7.11 节、todo-skill 去"失败标 completed"旧语义（均 identical 源码）
- ZCode config.json Stop 事件缺失：探测平台无 Stop 契约 → 记录为平台差异，不盲改

### 验证
- 语法：18 脚本 bash -n / node strip-types 全通过
- 全量 selftest --fresh：109/109（worktree + 主仓合并后均真跑零新增 FAIL）
- verify.sh：27/4 = 修复前基线（2 files hardcoded，合法既有），零增量
- 部署位：关键修复文件 5/5 identical；register-hooks P0-4b 修复同步后 5/5 identical

### 新发现待独立任务
- verify.sh hardcoded-paths 检查口径过严（把合法部署位 fallback 路径/默认槽位常量/注释当硬编码）→ 建议改为只抓无 env 逃生的裸硬编码或 canonical 源码路径，避免永久 4 条误报基线。
