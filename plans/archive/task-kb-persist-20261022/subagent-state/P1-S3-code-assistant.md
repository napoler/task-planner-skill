# P1-S3 检查点 — kb-sync-from-plan.sh（Code Assistant）

日期: 2026-10-22 | 状态: PASS（全部自测通过）

## 交付物
- 创建: `/home/terry/task-planner-skill-worktrees/kb-persist-20261022/scripts/kb-sync-from-plan.sh`（79 行，≤80 达标，chmod +x 已验证 `-rwxrwxr-x`，零外部依赖：bash+awk+grep+date+wc）
- 保留自测产出: `knowledge/entries/_draft-task-v122-rule47-media-dispatch.md`（47 行，含 frontmatter + §2/§3/§4 原文 + 精炼指引 HTML 注释）
- worktree git status: 仅 `?? knowledge/` 与 `?? scripts/` 两个新增目录，plans/archive 零改动

## 脚本行为规格落地
- 用法 `kb-sync-from-plan.sh <plan-dir>`；缺参 exit 2；目录不存在 exit 3；无可蒸馏内容 exit 1
- 仓库根探测: `git -C "$(dirname "$0")/.." rev-parse --show-toplevel`，回落 `dirname` of 脚本父目录（任意 CWD 可运行）
- 目录规范化: `cd "$1" && pwd -P`（解 symlink，sources 记真实路径）；task-id 仍取入参 basename（允许别名目录生成规范 id）
- 主源: awk 按 `^##` 且 `$2 ∈ {§2,§3,§4}` 提取三段原文（各段=标题行到下一 `^##` 前）
- 占位检测: kb 缺失 / 含「（待填充」/ 行数<75 **且** §2-§4 提取为空（合取，避免短实质 kb 误判）→ fallback findings.md `^##` 标题+各标题下前 3 非空行骨架；两者皆无 → exit 1
- draft: frontmatter（id/title/tags/sources/updated）+ 正文 + 末尾精炼指引注释；同名已存在 → 覆盖并在 stdout 注明

## 自测记录（命令 → 结果）
1. `bash scripts/kb-sync-from-plan.sh /tmp/task-v122-rule47-media-dispatch`（/tmp 符号链接 → worktree `plans/archive/task-v122`，因字面名目录在 archive 不存在）→ **exit 0**，产出 47 行 draft；head -20 抽查含 frontmatter 五键 + §2 表格实质内容。重跑一次 → stdout 出现「注: 同名 draft 已存在，覆盖」分支验证 PASS。该 draft 保留在位。
2. 占位 fallback: `grep -l "（待填充" plans/archive/*/knowledge-brief.md` **命中 0 份**（现有 114 份 kb 均无该占位特征——与规格假设「58 份占位」不符，已核）→ 改用判据链中「kb 缺失」分支验证: `plans/archive/task-3file-enforce`（无 kb、findings.md 134 行）→ **exit 0**，draft 来源行标注「findings.md (占位 fallback 骨架)」PASS；测试产物已删。
3. `bash scripts/kb-sync-from-plan.sh plans/archive/no-such-dir` → 报错 **exit 3**（非 0）PASS。
4. 补测: 空目录（kb/findings 皆无）→ 报「无可蒸馏内容」exit 1 PASS；缺参 → exit 2 PASS；`bash -n` 语法 PASS。

## 偏差与风险报告
- **偏差**: 规格自测 1 指向 `plans/archive/task-v122-rule47-media-dispatch`，该目录实际不存在（该任务在 archive 中名为 `task-v122`，内容为 Rule 47 媒体派发任务，已 grep 确认）。处置: 用 /tmp 符号链接以字面名调用脚本（sources 仍指向 worktree 真实路径），未触碰 plans/archive（只读铁律）。
- **偏差**: 规格假设 114 份 kb 中 58 份含「（待填充」占位特征，实测 grep 命中 0 份。脚本判据已完整实现（含该特征）；fallback 分支经「kb 缺失」判据验证。后续若发现占位特征 kb，`grep -q "（待填充"` 判据直接生效，无需改脚本。
- **风险**: 行数组 `$2` 匹配依赖标题格式 `## §N xxx`（§N 为第 2 个字段），现有 kb 全量符合；若未来 kb 标题改格式需同步 awk 条件。
- 负结果核查: 已检查依赖文件 kb-sync 目标路径 `knowledge/entries/`（原本不存在，脚本 mkdir -p 创建）；与 plans/archive 下 114 份 knowledge-brief.md 抽样（task-v122/v139/fix-pointer-race）无冲突；未修改 worktree 任何既有文件（git status 仅两个 ?? 新增目录）。
