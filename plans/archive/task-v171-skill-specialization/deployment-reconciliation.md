# task-v171 部署位只读对账清单

> 生成：2026-10-12（merge-back 1036781 后主进程只读对账）
> 口径：`diff -rq 主仓 skills/task-planner <部署位>` 差异行计数；**只读，未写任何部署位**；写入需用户授权后跑 install-stub.sh。

## 一、task-planner 部署位差异（落后 master 合并态 1036781）

| 部署位 | 差异行 | 说明 |
|--------|--------|------|
| `~/.zcode/skills/task-planner` | 83 | 落后 8 Phase 拆分产出（SKILL/critical-rules/selftest 锚/契约） |
| `~/.claude/skills/task-planner` | 83 | 同上（与 zcode 同源全量副本） |
| `~/.config/opencode/skills/task-planner` | 83 | 同上 |
| `~/.cursor/skills/task-planner` | 130 | 落后更多（残存更旧版本，历史同步不全） |

> 差异主体=本任务将 65 条规则移出核心 + selftest 锚重定向 + SKILL.md 瘦身 218 行 + BP-08 钉 275 + install-stub 注册 3 新卫星。
> 部署位仍为合并前 e82dd42 时代全量副本，故行数差异集中于 critical-rules/SKILL/selftest 锚。

## 二、新卫星部署位（预期未部署）

| 新卫星 | 部署位状态 | 说明 |
|--------|-----------|------|
| task-dispatch | ABSENT | install-stub SATELLITE_SKILLS 已注册；部署位写入待授权 |
| task-discipline | ABSENT | 同上 |
| media-planner | ABSENT | 同上 |

## 三、7 收编卫星（既有部署位，需同步 2 处改动）

plan-research-router / plan-template-kit / plan-collab-router / plan-cost-guard /
plan-resume / progress-tracker / task-drift-guard —— 各新增 `references/critical-rules-<域>.md`
+ SKILL.md 路由段。部署位若已存在则需增量同步；写入同样待授权。

## 四、授权后部署命令（本次未执行）

```
# 全量同步 task-planner 4 位 + 3 新卫星（install-stub 已注册卫星经 companion rsync）：
bash skills/task-planner/install.sh --tools zcode,claude,opencode,cursor
```

## 五、写入执行结果（2026-10-12 用户授权后）

用户回复「1,2」授权部署 → 执行 `install.sh --tools zcode,claude,opencode,cursor`（默认保留备份）。

- **部署成功**：3 新卫星（task-dispatch/task-discipline/media-planner）+ 7 收编卫星 + 核心 task-planner 全量同步 4 位；子代理隔离上下文验证=4 位 × 3 新卫星递归 diff 全空（与主仓 1036781 逐字节一致）；frontmatter 三字段齐全、task-dispatch 6 脚本在位。
- **规则计数澄清**：task-discipline 实为 **36 条编号规则**（grep `^### N ` 得 36；此前误报 48=把 Rule 70 的 70.1-70.6、Rule 72 的 72.1-72.6 共 12 个子小节标题也计入——这些是 master 源既有 `### N.x` 子标题格式，逐字迁移保留，非额外规则/非漂移）。task-dispatch 实为 **11 条**（12,13,14,21,22,23,25,46,52,59,68）。
- **install verify 4 fail = pre-existing 欠账，非 task-v171 引入**：verify 报 4 位各 1 文件「hardcoded $HOME/.zcode/skills/task-planner 路径」。核实主仓 1036781 vs 基点 e82dd42：check-doc-sync（2）/smart-merge-back（2）/selftest-tier-b（1）的 $HOME 硬编码在 e82dd42 即存在（task-v171 零新增），selftest-decision-drift/subagent-return 无 $HOME 命中。功能无影响（$HOME 运行时展开正确），属部署位历史欠账，不在本次拆分范围。
- **cursor 位 130 差异**：授权后已随全量同步消除（递归 diff 全空）。

> 结论：部署位已同步主仓 1036781；4 verify fail 为 pre-existing，登记备查，不影响 task-v171 交付正确性。
