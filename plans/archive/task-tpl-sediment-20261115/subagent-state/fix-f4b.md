# fix-f4b (F4b / CA-14 C-11 部分) — 计数语义逐点判定与修复回执

- 任务: task-tpl-sediment-20261115 F4b（critic R2 轮 C-11 部分，CA-14）
- 需求锚: R3
- Worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115
- 约束遵守: 仅修改 README.md 与 docs/ARCHITECTURE.md（skills/task-planner/ 下）；未改其他文件；未碰 tmp/worktrees/task-clause-generalize-20261115
- 执行时间: 2026-11-15

## 1. 前置定位与证据基线

### grep 基线（修复前）
命令:
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115
grep -n '7 卫星\|7 个卫星\|7 个' skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md
```
输出（5 处命中，与 critic 列出的 4 处语义范围一致，额外含 README:280 同类 rsync 清单计数）:
```
skills/task-planner/README.md:113:**卫星技能随装**（2026-10-12 task-v171 S39 起）：`lib/install-stub.sh:41` `SATELLITE_SKILLS` 数组登记 7 个卫星（4 既有 + 3 新域），安装时整目录 rsync 到各宿主位同级 `skills/<sat>/`；另 3 个收编卫星经 `lib/install-companion.sh` 顶层 `skills/*/` 自动发现机制分发。
skills/task-planner/README.md:150:│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星）
skills/task-planner/README.md:280:| 卫星技能未随 task-planner 装上 | SATELLITE_SKILLS 未登记 | 检查 `lib/install-stub.sh:41` 数组含全部 7 个显式 rsync 卫星 |
skills/task-planner/docs/ARCHITECTURE.md:160:│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星显式 rsync）
skills/task-planner/docs/ARCHITECTURE.md:182:1. `lib/install-stub.sh:41` `SATELLITE_SKILLS` 显式登记 7 个（4 既有 + task-v171 S39 追加 task-dispatch/task-discipline/media-planner）→ `install_satellite_skills()` 整目录 rsync 到宿主位同级 `skills/<sat>/`（源缺失则跳过，向后兼容不阻塞）
```

### SATELLITE_SKILLS 实况（install-stub.sh:41）
命令:
```bash
sed -n '30,50p' skills/task-planner/lib/install-stub.sh
```
关键证据:
```bash
# 另 3 个收编卫星(plan-resume/progress-tracker/task-drift-guard)不在本数组——经 lib/install-companion.sh
# 顶层 skills/*/ 自动发现机制分发(2026-09-04 布局统一口径), 本行只登记 install-stub 显式 rsync 的 8 个
SATELLITE_SKILLS=(plan-research-router plan-template-kit plan-cost-guard plan-collab-router task-dispatch task-discipline media-planner plan-template-advisor)
```
→ 显式 rsync 清单=8 元素（含 plan-template-advisor）；收编卫星=3（独立分发），与 8 互斥计数域。

## 2. 逐点判定表（C-11）

| # | 文件:行 | 上下文原句（修复前关键片段） | 判定集合/语义 | 判定结论 | 理由 | 处理 |
|---|---------|------------------------------|---------------|----------|------|------|
| 1 | skills/task-planner/README.md:113 | `SATELLITE_SKILLS 数组登记 7 个卫星（4 既有 + 3 新域），安装时整目录 rsync...；另 3 个收编卫星经 lib/install-companion.sh...` | SATELLITE_SKILLS/install-stub 显式 rsync 清单（数组 8 元素，含 plan-template-advisor） | **7→8**（且“3 新域”→“4 新域”） | 句首明确指向 `lib/install-stub.sh:41` `SATELLITE_SKILLS` 数组并描述“显式 rsync”分发；实况为 8 元素，含 plan-template-advisor。句尾另记“3 个收编卫星”属 companion 分发域，与 rsync 清单互斥，保持 3 不动正确。 | 修改 |
| 2 | skills/task-planner/README.md:150 | 文件结构注释 `# 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星）` | SATELLITE_SKILLS/install-stub 显式 rsync 清单 | **7→8** | 注释直接绑定 `:41 SATELLITE_SKILLS` 登记数；实况 8。 | 修改 |
| 3 | skills/task-planner/README.md:280 | 故障排查表 `检查 lib/install-stub.sh:41 数组含全部 7 个显式 rsync 卫星` | SATELLITE_SKILLS/install-stub 显式 rsync 清单 | **7→8** | 明确写“显式 rsync 卫星”且指向 `:41` 数组；实况 8。 | 修改 |
| 4 | skills/task-planner/docs/ARCHITECTURE.md:160 | 文件结构注释 `# 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星显式 rsync）` | SATELLITE_SKILLS/install-stub 显式 rsync 清单 | **7→8** | 同 #2/#3，明确“显式 rsync”且绑定 `:41`；实况 8。 | 修改 |
| 5 | skills/task-planner/docs/ARCHITECTURE.md:182 | `SATELLITE_SKILLS 显式登记 7 个（4 既有 + task-v171 S39 追加 task-dispatch/task-discipline/media-planner）→ install_satellite_skills() 整目录 rsync...` | SATELLITE_SKILLS/install-stub 显式 rsync 清单 | **7→8**（并补充 plan-template-advisor 归属说明） | 明确“显式登记…rsync”；实况 8 元素，新增成员为 plan-template-advisor。括号内补充其来源（task-tpl-sediment-20261115）以与实况一致，避免计数与枚举不符。 | 修改 |

### 判定汇总
- 指 **SATELLITE_SKILLS/install-stub 显式 rsync 清单**（数组 8 元素，含 plan-template-advisor）→ 5 处，全部 7→8（#1 同步 3 新域→4 新域）。
- 指 **收编卫星数量**（CA-11 后=7 为正确值）→ 0 处命中；文中“另 3 个收编卫星”表述保持不变（正确）。
- 指 **旧「卫星总数」口径**（现应为 12）→ 0 处命中于本次 grep 模式；“12 卫星路由表”等正确表述未被本次模式匹配，未误改。
- 指 **其他集合**（如 install-companion 另分发数）→ 0 处需改动；README:113 尾句保留“另 3 个收编卫星…”正确。

## 3. 实施变更（仅 2 文件）

### git diff -- skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md
```diff
diff --git a/skills/task-planner/README.md b/skills/task-planner/README.md
index f72dadd..40cfed2 100644
--- a/skills/task-planner/README.md
+++ b/skills/task-planner/README.md
@@ -110,7 +110,7 @@ Rules 1-97 全集索引：**核心在位 14 条**（1,2,3,5,19,20,26,51,62,66,80
 
 > [2026-10-05 task-v131 审计 L-5 修正] opencode 物理部署位 = `~/.config/opencode/skills/task-planner`；`~/.opencode` 为其 symlink 兼容入口（实测 `~/.opencode -> ~/.config/opencode`）。
 
-**卫星技能随装**（2026-10-12 task-v171 S39 起）：`lib/install-stub.sh:41` `SATELLITE_SKILLS` 数组登记 7 个卫星（4 既有 + 3 新域），安装时整目录 rsync 到各宿主位同级 `skills/<sat>/`；另 3 个收编卫星经 `lib/install-companion.sh` 顶层 `skills/*/` 自动发现机制分发。
+**卫星技能随装**（2026-10-12 task-v171 S39 起）：`lib/install-stub.sh:41` `SATELLITE_SKILLS` 数组登记 8 个卫星（4 既有 + 4 新域），安装时整目录 rsync 到各宿主位同级 `skills/<sat>/`；另 3 个收编卫星经 `lib/install-companion.sh` 顶层 `skills/*/` 自动发现机制分发。
 
 ---
 
@@ -147,7 +147,7 @@ ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/
 │   ├── attest-plan.sh / check-plan-dispatch.sh / rule-reserve.sh / ledger-append.sh / smart-merge-back.sh  # 守卫与簿记
 │   └── selftest-*.sh ×92 + selftest-registry.tsv  # 自测守护族（不逐列）
 ├── lib/                                     ← Installer 库（6 个）
-│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星）
+│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 8 卫星）
 │   ├── install-companion.sh                 # 顶层 skills/*/ 自动发现分发（含另 3 个收编卫星）
 │   ├── detect-tools.sh / backup.sh / migrate-refs.sh / verify.sh
 ├── tests/
@@ -277,7 +277,7 @@ bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/run-selftest
 | 旧部署位与新部署位冲突 | `user-invocable: true` 双注册 | 删除旧 stub 后重启 agent |
 | 升级后行为异常 | 部署位仍指向旧版 | `cd ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner} && git pull` 后重启 agent |
 | check-doc-sync 误判 STALE | fallback 链未含 canonical | 检查 `check-doc-sync.sh` 的 `for _c in` 列表 |
-| 卫星技能未随 task-planner 装上 | SATELLITE_SKILLS 未登记 | 检查 `lib/install-stub.sh:41` 数组含全部 7 个显式 rsync 卫星 |
+| 卫星技能未随 task-planner 装上 | SATELLITE_SKILLS 未登记 | 检查 `lib/install-stub.sh:41` 数组含全部 8 个显式 rsync 卫星 |
 
 详见 [INSTALL.md §5 故障排查](INSTALL.md)。
 
diff --git a/skills/task-planner/docs/ARCHITECTURE.md b/skills/task-planner/docs/ARCHITECTURE.md
index 574c4f0..3d19d8f 100644
--- a/skills/task-planner/docs/ARCHITECTURE.md
+++ b/skills/task-planner/docs/ARCHITECTURE.md
@@ -157,7 +157,7 @@ ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/
 │   ├── attest-plan.sh / check-dispatch.sh / check-plan-dispatch.sh / rule-reserve.sh / ledger-append.sh / smart-merge-back.sh 等
 │   └── selftest-*.sh ×92 + selftest-registry.tsv
 ├── lib/                                     ← installer 库（6 脚本）
-│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 7 卫星显式 rsync）
+│   ├── install-stub.sh                      # 每工具部署位安装（:41 SATELLITE_SKILLS 登记 8 卫星显式 rsync）
 │   ├── install-companion.sh                 # 顶层 skills/*/ 自动发现分发（含另 3 个收编卫星）
 │   └── detect-tools.sh / backup.sh / migrate-refs.sh / verify.sh
 ├── tests/  └── smoke.sh
@@ -179,7 +179,7 @@ ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/
 - hooks 注册于各宿主配置：zcode 位 = `~/.zcode/cli/config.json`，claude 位 = `~/.claude/settings.local.json`（经 `scripts/register-hooks-cj.ts`），非 SKILL.md frontmatter
 
 **卫星技能随装**（两条链路并存）：
-1. `lib/install-stub.sh:41` `SATELLITE_SKILLS` 显式登记 7 个（4 既有 + task-v171 S39 追加 task-dispatch/task-discipline/media-planner）→ `install_satellite_skills()` 整目录 rsync 到宿主位同级 `skills/<sat>/`（源缺失则跳过，向后兼容不阻塞）
+1. `lib/install-stub.sh:41` `SATELLITE_SKILLS` 显式登记 8 个（4 既有 + task-v171 S39 追加 task-dispatch/task-discipline/media-planner、task-tpl-sediment-20261115 追加 plan-template-advisor）→ `install_satellite_skills()` 整目录 rsync 到宿主位同级 `skills/<sat>/`（源缺失则跳过，向后兼容不阻塞）
 2. `lib/install-companion.sh`（install.sh Phase 5.6）自动发现仓库顶层 `skills/*/`（排除 task-planner 本体）→ 覆盖另 3 个收编卫星（plan-resume/progress-tracker/task-drift-guard）
 
 ---
```

## 4. 验收复跑

### post-fix grep（两文件）
命令:
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115
grep -n '7 卫星\|7 个卫星\|7 个' skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md || echo "(no matches)"
```
输出:
```
(no matches)
```

### 结论
- 两目标文件中不再存在 `7 卫星|7 个卫星|7 个` 命中；本次命中全部属于“SATELLITE_SKILLS/install-stub 显式 rsync 清单”语义，已与实况（8 元素，含 plan-template-advisor）对齐。
- “另 3 个收编卫星”表述保持不变（正确域）；未发现需 12 化的旧总数表述命中；未盲改收编=7 类正确表述（本次 grep 未命中该语义）。

## 5. 遗留/风险
- 未运行全量 selftest（本批次限定 2 文件计数语义修正）；与 F16 记录的预存全量基线 FAIL（selftest-active-plan T11、selftest-execution-stability T11b，另案）无关。
- 仅按 `7 卫星|7 个卫星|7 个` 模式逐点判定两目标文件；若存在其他表述形式的同义矛盾计数不在本模式覆盖内（本次未发现）。
