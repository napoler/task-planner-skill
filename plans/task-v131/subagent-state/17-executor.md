# 17-executor — task-v131 Phase 5 S1（INSTALL.md 薄壳口径→全量副本）

Status: completed
Date: 2026-10-05
Worktree: /home/terry/task-planner-skill-worktrees/task-v131 (branch wt/task-v131)

## 修改内容（1 文件：skills/task-planner/INSTALL.md）
1. `:33`（原行 33，行 5 安装步骤）原「✅ Install stub：每个检测到的工具创建薄壳 stub（SKILL.md + scripts + references + templates）」
   → 改为「✅ Install：将本仓 `skills/task-planner/` 安装源**全量副本**同步到各宿主位——`~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`、cursor 位；hooks 注册于各宿主配置（zcode 位=`~/.zcode/cli/config.json`，claude 位=`~/.claude/settings.local.json` 经 register-hooks-cj.ts）」
2. `:35`（Verify 步骤）之后新增 3 行注释块（Rule 45 修改三要素）：
   原因=M-1 审计（薄壳口径 vs 实盘全量副本两套口径）；时间=2026-10-05；原行为=「创建薄壳 stub」表述，并声明「stub」一词在 §2/§5 保留为脚本命名历史术语（install-stub.sh 等），非部署形态描述。

## 第一手证据（实盘核实，非推测）
- `diff -rq ~/.zcode/skills/task-planner/scripts <worktree>/skills/task-planner/scripts` 有差异但仅为 task-v130/v131 增量（findings H-1 已登记：zcode 位 3 文件领先真源，Phase 1 已回填）；目录结构 = 全量副本形态（scripts/references/templates/config/companion 全在），非薄壳
- `~/.zcode/cli/config.json:28,42,55` grep 命中 `bash /home/terry/.zcode/skills/task-planner/scripts/zcode-*.sh` 4 hooks（SessionStart/PreToolUse/PostToolUse）→ zcode 位 hooks 确注册于宿主配置
- `~/.claude/skills/task-planner/`、`~/.config/opencode/skills/task-planner/`（注意：物理路径是 `~/.config/opencode`，非 `~/.opencode`——与 L-5 同口径）、`~/.cursor/skills/task-planner/` 均含 config.json/scripts/INSTALL.md 等全量内容 → 四位全量副本成立
- `~/.config/opencode/config.json` 与 `~/.cursor/skills/task-planner/config.json` 存在（宿主配置侧 hooks 载体实证）

## 验证结果（worktree 内）
- `grep -c "全量副本" INSTALL.md` = 2（≥1 达标）
- `grep -n "薄壳" INSTALL.md` = 1 处（:37），位于新增历史说明注释内（否定/历史语境：「原表述…与实盘不符」「非指针引用薄壳」）→ 符合验收残留口径，已如实记录于此
- `git diff --stat` = `skills/task-planner/INSTALL.md | 4 +++-`，仅 1 文件（3 insertions, 1 deletion）
- 未 commit（遵照指令）

## 未动清单（负结果）
- install-stub.sh / detect-tools.sh / README.md / ARCHITECTURE.md 均未触碰（Phase 5 S2/S3 与 Phase 6 范围）
- §2/§5 中的「stub」术语保留（属历史命名，本 S-unit 验收口径=「薄壳」grep，非「stub」grep）

## 遗留提示（供主进程）
- `lib/install-stub.sh` 头注释仍写「thin stub that delegates to canonical」（M-1 材料包 install-stub:262 行），Phase 5 S2 同步时建议一并改全量副本口径
- 本文件 `:33` 修后行号为 :33（新增注释块使后续行 +3）
