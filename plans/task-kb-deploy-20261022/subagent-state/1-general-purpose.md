# 独立复核记录：task-planner 技能「部署位同步」

- 复核角色：独立验收方（general-purpose 子代理，只读核验）
- 复核时间：2026-10-22
- 核验对象（只读）：
  - 仓库源 `/mnt/data/dev/task-planner-skill/skills/task-planner`（git repo, master）
  - 部署位 `~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.cursor/skills/task-planner`
- 写入范围：仅本检查点文件。未修改任何部署位文件，未修改仓库除本文件外任何文件，未执行任何 git 写操作（无 add/commit/push/checkout/reset/stash）。

---

## 逐项结论

### 项 1 — 三位模板含「归档计划」「知识提取入库」两步 → PASS

命令：
```
grep -cE '归档计划|知识提取入库' <位>/templates/task_plan.md
```
实测（四位同源，合并 grep 计数均为 2）：
| 位置 | 合并计数 | 「归档计划」单计 | 「知识提取入库」单计 |
|---|---|---|---|
| repo skills/task-planner | 2 | 1 行 | 1 行 |
| ~/.zcode | 2 | 1 行 | 1 行 |
| ~/.claude | 2 | 1 行 | 1 行 |
| ~/.cursor | 2 | 1 行 | 1 行 |

关键行（repo 源，行号 353 / 355，四位内容一致）：
- `- [ ] 归档计划：check-complete exit 0 后先 bash <skill>/scripts/set-active-plan.sh --clear 再 bash <skill>/scripts/archive-plan.sh <task-id> --root <plans根>（Rule 81；守卫拒绝时登记理由不强移）`
- `- [ ] 知识提取入库（条件式：项目存在 scripts/kb-sync-from-plan.sh 知识库机制则必做；不存在则登记「跳过：无知识库机制」）：bash scripts/kb-sync-from-plan.sh <plan-dir> 生成 draft → 精炼改名 → bash scripts/kb-rebuild-index.sh`

判定依据：计划 VC-2 判据为 `grep -c "归档计划\|知识提取入库" ... ≥2（三位同）`，实测三位均为 2 → 达标。

### 项 2 — critical-rules.md 含 Rule 93 相关内容 + 51.9-51.13 子条 → PASS

命令：
```
grep -oE 'Rule 93' <位>/references/critical-rules.md | wc -l            # 字面 "Rule 93"
grep -o '92,93' <位>/references/critical-rules.md | wc -l               # Rule 93 的卫星路由索引锚
grep -oE '51\.(9|10|11|12|13)' <位>/references/critical-rules.md | wc -l
```
实测（四位完全一致）：
| 位置 | 字面 "Rule 93" | 路由索引 "92,93" | 51.9-51.13 出现次数 / 行数 |
|---|---|---|---|
| repo 源 | 0 | 1 | 10 次 / 5 行 |
| ~/.zcode | 0 | 1 | 10 次 / 5 行 |
| ~/.claude | 0 | 1 | 10 次 / 5 行 |
| ~/.cursor | 0 | 1 | 10 次 / 5 行 |

说明（避免误判为缺陷）：Rule 93（规范再召回纪律）**本就不在核心技能 critical-rules.md 内**——按 Rule 82 分层，核心在位 14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83），Rule 93 已分层至 task-discipline 卫星；核心 critical-rules.md 以「卫星路由索引」形式承载其指针（第 194 行 task-discipline 条目列 `...,85,86,87,88,89,90,92,93`）。故「Rule 93 相关内容」= 路由索引锚命中，计数 1 > 0。
51.9/51.10/51.11/51.12/51.13 五条子条在 core critical-rules.md 第 98/100/102/104/106 行逐条在位，四位一致。

### 项 3 — zcode 位 vs 仓库源 diff -rq 差异文件数 = 0 → PASS

命令：
```
diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner ~/.zcode/skills/task-planner
```
输出（完整，仅 1 行）：
```
Only in /home/terry/.zcode/skills/task-planner/.drift-rhythm: .drift-rhythm
```
剔除 `.drift-rhythm` 运行态后差异文件数 = **0**（`diff -rq ... | grep -v '\.drift-rhythm' | wc -l` = 0）。且无 "Only in 仓库源" 的缺失文件。

### 项 4 — claude/cursor 位 vs 仓库源差异文件数 = 9，且集合与预期一致 → PASS

命令：
```
diff -rq <repo源> ~/.claude/skills/task-planner
diff -rq <repo源> ~/.cursor/skills/task-planner
```
剔除 `.drift-rhythm` 后差异文件数：claude = **9**，cursor = **9**（不多不少）。
两位的 9 个差异文件集合完全相同，且与预期 flavor 清单**逐项一致**：
1. install.sh
2. lib/install-stub.sh
3. README.md
4. docs/ARCHITECTURE.md
5. scripts/register-hooks-cj.ts
6. scripts/session-catchup.ts
7. scripts/sync-ide-folders.ts
8. SKILL.md
9. templates/session-handoff.md

逐文件 diff（`diff -u | grep -E '^[+-]'`，claude 与 cursor 输出逐字相同）全部落在两类 flavor 差异内：

A) 调用写法 `node --experimental-strip-types` → `bun run`
- install.sh：3 处（dry 行、cd+执行行、`then:` 提示行）
- lib/install-stub.sh：1 处
- README.md：1 处（故障排查表「hook 不触发」行）
- docs/ARCHITECTURE.md：1 处（hooks 排查行）
- scripts/register-hooks-cj.ts：shebang `#!/usr/bin/env node --experimental-strip-types` → `#!/usr/bin/env bun`；用法注释 1 行；examples 行 1 行
- scripts/session-catchup.ts：shebang；用法注释 1 行
- scripts/sync-ide-folders.ts：shebang；`console.log("Run '... sync-ide-folders.ts' to fix.")` 1 行
- SKILL.md：session-catchup 调用 1 处
- templates/session-handoff.md：中断点检测命令 1 处

B) 随之而来的提示文案（bun not found / install bun）
- install.sh：`WARNING: node not found` → `WARNING: bun not found`；`install node: https://nodejs.org (v22.6+ for --experimental-strip-types)` → `install bun: curl -fsSL https://bun.sh/install | bash`
- scripts/sync-ide-folders.ts：依赖声明 `Node.js >= 18（node --experimental-strip-types 运行）` → `Bun（bun run 运行）`

反证（机械化验证「无非 flavor 差异」）：对 repo 源施加上述 flavor 变换（node→bun 替换 + shebang + 两处文案 + Node.js/Bun 依赖行）后与部署位比对，residual diff lines = 0（install.sh / lib/install-stub.sh / README.md / docs/ARCHITECTURE.md / SKILL.md / templates/session-handoff.md 全为 0）；三个 .ts 文件 residual 仅剩 shebang `#!/usr/bin/env bun`（我方变换脚本把它误写成 `bun run`，属变换脚本自身瑕疵）与 sync-ide-folders.ts 的依赖行（同一原因），实际部署位值正确（`#!/usr/bin/env bun`、`Bun（bun run 运行）`）。→ **9 个文件内不存在 flavor 之外的内容差异**。

### 项 5 — 残留 git 冲突标记扫描 → PASS

命令：
```
grep -rn --binary-files=text -E '<<<<<<< |>>>>>>> ' <位>/skills/task-planner
grep -rnE '^(<<<<<<<|=======|>>>>>>>)' <位>/skills/task-planner
```
实测：三位 `<<<<<<< ` / `>>>>>>> ` 命中数均为 **0**。
`=======` 仅命中 6 处纯装饰性分隔注释（`# ====...` / ` * ====...`，位于 init-session.sh 与 sync-ide-folders.ts），非冲突标记。

### 项 6 — 部署位 selftest 可执行性抽检 → PASS

命令：
```
bash ~/.zcode/skills/task-planner/scripts/selftest-requirement-coverage.sh
bash ~/.claude/skills/task-planner/scripts/selftest-requirement-coverage.sh
bash ~/.cursor/skills/task-planner/scripts/selftest-requirement-coverage.sh
```
实测末行与退出码：
| 位置 | 末行 | exit |
|---|---|---|
| ~/.zcode | `Total: 27 PASS=27 FAIL=0` | 0 |
| ~/.claude | `Total: 27 PASS=27 FAIL=0` | 0 |
| ~/.cursor | `Total: 27 PASS=27 FAIL=0` | 0 |

---

## 附带观察（不属本次 6 项判定范围，供主进程参考）

1. **task-discipline 卫星未同步 Rule 93**：`~/.zcode ~/.claude ~/.cursor` 三位的 `skills/task-discipline/references/critical-rules-discipline.md` 中 `^### 93 ` 标题计数为 0（repo 源为 1），且 `references/execution-recall-card.md` 在三位均**缺失**（repo 源存在）。而三位 task-planner 的 `templates/task_plan.md` 第 312 行、`SKILL.md` 第 95/140 行均引用 `../task-discipline/references/execution-recall-card.md` 与 Rule 93 ——即 task-planner 已同步到位，但它指向的卫星产物尚未同步，落入其他项目时会指向不存在的召回卡文件。本次任务范围仅限 task-planner 技能，不改判该处为 FAIL，仅作提示。
2. **SKILL.md 内无「知识提取」字面**：四位 `SKILL.md` 的 `知识提取` 与 `kb-sync-from-plan` 命中均为 0；知识库两步仅落在 `templates/task_plan.md`（模板收尾段），SKILL.md 未重复承载。此为上游 repo 源现状（源本身即如此），部署位与源逐字一致，不构成部署漂移。

---

## 总判定

项 1 PASS / 项 2 PASS / 项 3 PASS / 项 4 PASS / 项 5 PASS / 项 6 PASS。

**VERDICT: PASS**
