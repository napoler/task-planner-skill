# Audit Report — task-planner Skill | task-v053-skillfix-deploy | Phase 1 (Audit)

> 只读审计,未修改任何 skill 文件。审计对象:`/mnt/data/dev/task-planner-skill-worktrees/task-v053-skillfix-deploy/skills/task-planner/`(worktree 副本,与 canonical master 89a29ae 一致)。
> 检查点文件:`/mnt/data/dev/task-planner-skill/plans/task-v053-skillfix-deploy/subagent-state/01-general-purpose.md`
> 完成度:8/8 已知缺陷取证 + 新缺陷扫描 + 修复建议汇总。

---

## A 文件清单与覆盖(S59)

### A.1 顶层文件(10)

| 文件 | 行数 | 用途 |
|------|------|------|
| `SKILL.md` | 614 | 主入口 + frontmatter(9 条 references) |
| `reference.md` | 285 | Manus context engineering 原则 |
| `examples.md` | 414 | 执行示例 |
| `INSTALL.md` | 270 | 安装指南 |
| `MIGRATION.md` | 195 | 迁移指南 |
| `README.md` | 204 | 项目说明 |
| `uninstall.sh` | 78 | 卸载脚本 |
| `install.sh` | 211 | 安装脚本 |
| `config.json` | 183 | 配置 |
| `tests/smoke.sh` | 77 | 烟雾测试(2026-09-04 后已升级) |

### A.2 references/(10 文件)

| 文件 | 行数 | 用途 |
|------|------|------|
| `critical-rules.md` | 209 | 27 条核心规则 |
| `template-guide.md` | 269 | 模板使用指南 |
| `template-mapping.md` | 195 | 模板映射决策树 |
| `cost-control.md` | 171 | 成本控制细则 |
| `batch-quality-gate.md` | 133 | 批量质量门控 |
| `worktree-isolation.md` | 89 | 工作树隔离合约 |
| `todo-sync.md` | 70 | Todo 同步契约 |
| `billing.md` | 61 | 计费模式 |
| `completion-gate.md` | 33 | 完成门控 |
| `goal-gate.md` | 17 | Goal Gate 规则 |

### A.3 scripts/(24 文件) + lib/(5 文件) + templates/(15 文件) + companion/(3 文件)

均已 ls + wc -l 验证;关键路径:`zcode-pretooluse.sh`(48 行)、`sync-todos.sh`(268 行)、`check-complete.sh`(264 行)、`check-conflicts.sh`(179 行)、`check-drift.sh`(319 行)、`init-session.sh`(134 行)、`check-3file-gate.sh`(136 行)、`lib/verify.sh`(189 行)。

### A.4 关键文件存在性验证

✅ `references/cost-control.md` 存在(171 行)
✅ `references/batch-quality-gate.md` 存在(133 行)
✅ `tests/smoke.sh` 存在(77 行)
✅ `lib/verify.sh` 存在(189 行)
✅ `templates/task_plan.md` 存在(386 行)

---

## B 已知缺陷逐项取证(8 项)

| # | 缺陷 | 现状判定 | file:line + 原文摘录 |
|---|------|---------|---------------------|
| 1 | SKILL.md frontmatter `references:` 缺 2 条 | **仍存在** | `SKILL.md:7-17` frontmatter 仅 9 条,缺 `references/cost-control.md`(实际 171 行)与 `references/batch-quality-gate.md`(实际 133 行);正文 `SKILL.md:300-345` 多处引用(`详见 references/cost-control.md`、`详见 references/batch-quality-gate.md`) |
| 2 | critical-rules.md Rule 10 悬空指针 | **仍存在** | `references/critical-rules.md:33` 原文:"详见 `reference.md § 重规划触发`"。`reference.md` 中只有 `## § Chain Handoff Contract` 下的 `重规划触发条件`(line 279),无独立 `§ 重规划触发` 节;frontmatter 描述 line 8 自称含 `Chain 重规划触发`,加剧误导 |
| 3 | 模板决策树双源分化 | **仍存在(高度纠缠)** | (a) SKILL.md §任务模板库 lines 555-614(59 行)与 `references/template-mapping.md` §一/六 lines 7-40+123-152(60+ 行)内容近乎逐字重复(模板清单、决策树、互斥关系表);(b) `references/critical-rules.md:59`(Rule 16)同时引用 `SKILL.md §「任务模板库」` + `references/template-mapping.md`(双源);(c) `SKILL.md:300`(Rule 16 描述)指向 `§任务模板库`(自指),`SKILL.md:577` 决策树与 `template-mapping.md:9` 决策树字符级一致 |
| 4 | Rule 14 主进程禁改清单缺 .sh | **仍存在** | `references/critical-rules.md:53` 原文:"主进程禁止直接 Edit/Write 业务代码(`.ts/.tsx/.js/.jsx/.py/.go/.rs/.java/.c/.cpp/.h/.hpp`)"——`.sh` 未列入。同时 `SKILL.md:173` Code Review Gate 范围显式 `排除 .sh/.toml/.cfg`,印证 `.sh` 被治理层视为"非代码";`lib/install-stub.sh`(246 行)是 skill 修复关键产物,却无任何派发/审查规则覆盖(grep 显示只被 install.sh / README / ARCHITECTURE.md 引用) |
| 5 | critical-rules.md 约 129 行重复段 | **仍存在** | `references/critical-rules.md:117` 出现 `21.5 **拆分自检(动工前)**...`;`references/critical-rules.md:135` 在 Rule 22.7 与 Rule 23 之间再次出现 `21.5 **拆分自检(动工前)**...`(两段文字完全一致,夹在 Rule 22 与 Rule 23 之间,显然为 Rule 错位复制) |
| 6 | Rule 27.3 porcelain 校验非脚本硬门控 | **仍存在** | `references/critical-rules.md:206` 原文:"提交后 `git status --porcelain -- <scope 文件>` 必须为空;非空 = 有遗漏"。`scripts/check-complete.sh` 全文 grep 无 `porcelain` / `git status`(只 grep 到 batch/complete/aggregator 相关逻辑);`scripts/check-3file-gate.sh` 同样无 porcelain;`scripts/check-conflicts.sh:38-52,169-172` 有 porcelain 调用但作用域是全局冲突检测而非 Rule 27.3 的"提交后 scope 校验"。Rule 27.3 当前为纸面规则,无脚本兜底 |
| 7 | 区间式 awk scope 提取失效(gawk 5.2) | **仍存在(已实测)** | **实证**:用最小样本(见下方)对比两种 awk 模式——buggy:`awk '/^## .*执行范围限制/,/^## /'` → 输出 1 行(仅标题);state-machine:`awk '/^## ⚠️ 执行范围限制/{f=1; next} /^## /{f=0} f && ...'` → 输出 3 行(数据行)。**buggy 模式因起始行同时匹配 `^## ` 终止模式导致区间内只含起始行本身,scope_files 提取恒空**。受影响文件:① `scripts/zcode-pretooluse.sh:32,37`(并发冲突检测);② `scripts/sync-todos.sh:97,180`(extract_plan_meta,scope_files)。`scripts/check-conflicts.sh:108,134` 与 `scripts/check-drift.sh:205` 使用 state-machine 写法(template-mapping.md §八示范),不受影响 |
| 8 | lib/verify.sh stub_is_symlink_mode() 两态误报 | **仍存在** | `lib/verify.sh:39-43`:`stub_is_symlink_mode` 仅在部署位为指向 canonical 的软链时返回 0;**脚本头部声明 Usage 为 `verify_installation`,但脚本本身只定义函数、不调用**——直接 `bash lib/verify.sh` 仅因 `TASK_PLANNER_ROOT` 未设置而 exit 1(行 22);`TASK_PLANNER_ROOT=/home/terry/.zcode/skills/task-planner bash lib/verify.sh`(部署位是实体副本非软链)→ exit 0 且**无任何输出**(函数未调用);canonical 验证同样静默 exit 0。**两态均不报告任何 check 结果**;Rule 25.4 终验期的安装健康门控实质失效 |
| 9 | init-session.sh CWD 无守卫 | **仍存在(已实测)** | `scripts/init-session.sh:128` 原文:`PLAN_ROOT="$(cd .. && pwd)"`。**实测**:从 `/tmp` 运行 `bash init-session.sh test` → 成功生成 task_plan/findings/progress/notepad/verification 5 个文件到 `/tmp`;`PLAN_ROOT` 解析为 `/`;line 129 写 `${PLAN_ROOT}/.active_plan` 即 `//.active_plan` → Permission denied(被 set -e 救了一命,否则会向文件系统根目录写垃圾文件)。**最佳守卫插入点**:line 13(`set -e` 之后)加 `[ "$(basename "$(dirname "$(pwd)")")" = "plans" ]` 校验,失败时 exit 1 + 提示"必须在 plans/<task-id>/ 目录下运行"。当前实现违反 init-session.sh 头部注释隐含的前置条件(隐含要求"在 plans/{task-id}/ 内运行") |

---

## C 新缺陷与范围外清单

### C.1 新发现缺陷

| # | 缺陷 | file:line |
|---|------|-----------|
| 10 | **SKILL.md Rule 16 引用文本与决策树位置不一致**:`SKILL.md:300` Rule 16 写"详见下方 §任务模板库",但 §任务模板库 在 line 555(距 Rule 16 描述 255 行),不属于"紧邻";`SKILL.md:577` 决策树与 `template-mapping.md:9-24` 字符级重复 | `SKILL.md:300`、`SKILL.md:577-594` |
| 11 | **path_existence_validator 解析误报**:实测 `bun /home/terry/.zcode/skills/skill-fix/tools/path_existence_validator.ts ... --scope all` → 误报 `references/todo-sync.md`、`references/worktree-isolation.md`、`references/critical-rules.md` 为 MISSING(P0);`ls` 确认三文件均存在(70/89/209 行)。判定:**已知工具缺陷,非真缺陷**——3 个文件路径形式合法,误报源可能是 validator 对 frontmatter 路径列表的解析逻辑(可能将 markdown 链接 `[text](path)` 与裸路径混淆,或对 frontmatter `references:` 列表项中的 `- references/foo.md: 描述` 形式解析失败) | 工具:`/home/terry/.zcode/skills/skill-fix/tools/path_existence_validator.ts` |
| 12 | **template-mapping.md §八 验证命令示范正确 awk,但被 zcode-pretooluse.sh/sync-todos.sh 反向违反**:`template-mapping.md:193` 示范了正确的 state-machine awk(`{f=1;next} /^## /{f=0}`),但 SKILL.md 子代理路由表把 template-mapping.md 标记为权威,实际两个调用方未遵守——文档与实现不一致 | `template-mapping.md:193` vs `zcode-pretooluse.sh:32`、`sync-todos.sh:97,180` |

### C.2 范围外(一句话登记,不动)

- **`skills/plan-resume/`、`skills/todo-skill/`、`skills/task-drift-guard/`** 三个同仓技能:`ls` 确认目录存在且各有 SKILL.md/README/config.json/scripts;未被本次任务波及,但未做深度审计。
- **bash -n 语法检查**:`scripts/*.sh` 与 `lib/*.sh` 全量 22 个 .sh 文件全部 `bash -n` exit 0;`.ts/.cjs/.ps1` 未做语法检查(超出 audit 范围)。
- **`tests/smoke.sh`** 现状:存在(77 行),头部注释说明 5 项检查(目录结构、bash -n、check-complete.sh/verify.sh 运行);本次未执行 smoke.sh(只读审计阶段)。

---

## D 修复建议汇总(最小修复描述,不改文件)

| # | 涉及文件 | 最小修复描述 | 优先级 |
|---|---------|-------------|--------|
| 1 | `SKILL.md:7-17` | frontmatter `references:` 列表追加 2 行:`- references/cost-control.md: ...`(照抄 line 300-310 的描述风格)与 `- references/batch-quality-gate.md: ...`(照抄 line 73-83) | P1 |
| 2 | `references/critical-rules.md:33` | 改 Rule 10 文字为"详见 `reference.md § Chain Handoff Contract 中的 重规划触发条件`"(精确指向 line 279 实际节);同步修正 `SKILL.md:8` frontmatter 描述中的 "Chain 重规划触发" → "Chain Handoff Contract 中的重规划触发条件",`SKILL.md:339` 同步 | P0 |
| 3 | `SKILL.md:555-614` vs `references/template-mapping.md:7-152` | **方案 A(推荐)**:SKILL.md §任务模板库收敛为单一指针("详见 `references/template-mapping.md` §一/§六"),删 line 555-594 的模板清单与决策树与互斥关系三块;`references/critical-rules.md:59` 同步删"SKILL.md §「任务模板库」+"。**方案 B(defer)**:接受双源,在 SKILL.md §任务模板库头部加"权威源:references/template-mapping.md;本节为速查镜像,修改请回写主源";**纠缠度评估**:三块重复(模板清单 13 行 + 决策树 16 行 + 互斥关系 10 行 = 39 行 ≈ 模板决策树总规模 65%);SKILL.md 一旦删 39 行,可腾出空间放 Rule 引用 | P1,**建议方案 A(do)** |
| 4 | `references/critical-rules.md:53` | Rule 14 扩展名清单追加 `.sh`(主进程禁止直接 Edit/Write `.sh` 业务脚本);`SKILL.md:173` Code Review Gate 范围同步去掉 `.sh` 排除(把 `.sh` 纳入审查);`lib/install-stub.sh` 类关键脚本自然落入治理 | P1 |
| 5 | `references/critical-rules.md:135` | 删 line 135-136 的重复 `21.5 **拆分自检**` 段;原 line 117 的 21.5 为正本;顺手核对 Rule 编号连续性(22 之后直接 23,无空号) | P0 |
| 6 | `references/critical-rules.md:206` + `scripts/check-complete.sh` | Rule 27.3 增加脚本钩子要求:在 check-complete.sh 的 python block 之前插入 `if git rev-parse --git-dir >/dev/null 2>&1; then scope_porcelain="$(git status --porcelain -- <scope_files 拼接>)";[ -n "$scope_porcelain" ] && { echo "[plan] Rule 27.3 violation: scope 内存在未提交变更"; exit 1; }; fi`(约 8-10 行 bash 预检);同步在 verification.md C? 项加一条勾选项;非 git 目录走 27.3 的 "[git-commit] 跳过" 通道 | P0 |
| 7 | `scripts/zcode-pretooluse.sh:32,37` + `scripts/sync-todos.sh:97,180` | **3 处** `awk '/^## .*执行范围限制/,/^## /'` 全部替换为 state-machine 写法(参照 `template-mapping.md:193` 与 `scripts/check-conflicts.sh:108`):`awk '/^## ⚠️ 执行范围限制/{f=1; next} /^## /{f=0} f && /\|.*\|.*\|/ && NF>2' "$plan" \| grep '^\|' \| grep -v '^\|---' \| ...`(注意三处后续管道逻辑各异,只替换 awk 模式部分) | **P0(功能阻塞)** |
| 8 | `lib/verify.sh` | 双重修:① line 186-188(目前 `return 0/1`)改为脚本顶层 main:line 19 之后加 `if [ "${1:-}" != "--help" ]; then verify_installation; fi`;② line 39-43 stub_is_symlink_mode 加注释说明"实体副本部署位是历史 install.sh 路径(`cp -r` 实体副本),非软链是合法状态,但本函数用于分支判定,不是 fail 标记"——确保 line 60-66 的 entity 分支正确归类为"实体副本(历史兼容)"而非 fail | P1 |
| 9 | `scripts/init-session.sh` | line 13(`set -e` 之后)插入 CWD 守卫:`if [ "$(basename "$(dirname "$(pwd)")")" != "plans" ]; then echo "[init] ERROR: 必须在 plans/<task-id>/ 目录下运行(当前 CWD 父目录: $(dirname "$(pwd)"))" >&2; exit 1; fi`(7 行新增);同步 `SKILL.md:96` 已暗示此前置条件,文档无需改 | P0 |
| 10 | `SKILL.md:300` + `SKILL.md:577-594` | 跟随缺陷 3 的方案 A 收敛后,Rule 16 引用变为指向 `references/template-mapping.md` 单一权威,无需额外修改 | P1(随 3 一并) |
| 11 | 工具层 | path_existence_validator.ts 的 frontmatter `references:` 列表项解析需修(独立工单,本次不修 audit 工具) | out-of-scope |
| 12 | `template-mapping.md:193` | 文档正确,实现未跟随——不需改文档,改实现(同缺陷 7) | out-of-scope(随 7) |

---

## E 关键决策点

### E.1 双源分化(缺陷 3)纠缠度结论

- 重复规模:SKILL.md §任务模板库(59 行,line 555-614) vs template-mapping.md §一+§六+§七(约 60 行,line 7-40 + 123-152),实质重复 39 行(模板清单 13 行 + 决策树 16 行 + 互斥关系 10 行)
- Rule 16 引用链:`critical-rules.md:59` 双指 SKILL.md + template-mapping.md;SKILL.md:300 自指 §任务模板库;template-mapping.md:33+ §八验证命令示范自身权威
- **建议:DO(方案 A)**——SKILL.md §任务模板库收敛为指针段(~5 行),腾出空间容纳 §任务模板库当前被 Rule 16 隐式要求的"知识储备章节对齐"展开说明;39 行重复消除换来 1 个权威源,符合 §二 P0"禁止未授权跨多源叙事"原则;唯一风险:Rule 16 描述(`critical-rules.md:59`)目前同时引用 SKILL.md + template-mapping.md,需同步删去 SKILL.md 引用——单一改动即可,非破坏性

### E.2 阻塞级缺陷

**缺陷 7(scope_files awk 失效)= 唯一功能阻塞项**:Rule 23.5 依赖 scope_files 解析,Rule 27.2 提交范围依赖 scope_files 解析,Rule 23 冲突检测依赖 scope_files 解析——三处 awk 全部失效意味着**当前任何并发 plan 都不会触发 Rule 23 报警,且 git 提交无法用 scope 校验**。建议作为 Phase 2 第一修复项。

---

## F 验证证据

- **缺陷 7 实测样本**:`/tmp/scope_test.md`(8 行,含「## ⚠️ 执行范围限制」节)
  - buggy 模式输出:`## ⚠️ 执行范围限制` (1 行,仅标题,scope_files 恒空)
  - state-machine 模式输出:`| 类型 | 路径 | 说明 |` 等 3 行(数据行齐全)
- **缺陷 9 实测样本**:`cd /tmp && bash init-session.sh test` → 退出 0(因 set -e + Permission denied 救场,否则会写 `/active_plan`),生成 5 个 plan 文件到 /tmp
- **缺陷 8 实测样本**:`TASK_PLANNER_ROOT=/home/terry/.zcode/skills/task-planner bash lib/verify.sh` → exit 0,**stdout 完全无输出**(verify_installation 函数未调用)
- **bash -n 全量**:`scripts/*.sh` + `lib/*.sh`(22 个 .sh)全部 exit 0,无语法错误
- **范围外验证**:`ls skills/{plan-resume,todo-skill,task-drift-guard}/SKILL.md` 全部存在

---

## G 落盘确认

- 检查点文件已写入:`/mnt/data/dev/task-planner-skill/plans/task-v053-skillfix-deploy/subagent-state/01-general-purpose.md`
- 审计全程未修改 `skills/task-planner/` 下任何文件
- 所有断言带 file:line + 原文摘录,可由 Phase 2 修复阶段复核

