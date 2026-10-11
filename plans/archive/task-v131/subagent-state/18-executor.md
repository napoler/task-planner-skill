# 18-executor — task-v131 Phase 5 S2（install-stub.sh 口径注释同步：薄壳→全量副本）

Status: completed
Date: 2026-10-05
Worktree: /home/terry/task-planner-skill-worktrees/task-v131 (branch wt/task-v131)

## 实际路径
任务材料包写的 `scripts/lib/install-stub.sh` 不存在；实存路径 =
`/home/terry/task-planner-skill-worktrees/task-v131/skills/task-planner/lib/install-stub.sh`
（find 全 worktree 唯一命中，只动该 1 文件）。

## 修改内容（1 文件：skills/task-planner/lib/install-stub.sh，16+/2-）
三处口径修正，均带 Rule 45 三要素（原因/时间 2026-10-05/原行为）：
1. **头注释 :2** 原「lib/install-stub.sh — Install per-tool thin stub that delegates to canonical」
   → 「Install a full copy of task-planner (scripts/references/templates/config) into each host stub dir」
   + 4 行修正注：原表述与实盘不符，审计 M-1 核实实盘=全量副本同步（安装源=本仓
   skills/task-planner/，四位宿主位 ~/.zcode / ~/.claude / ~/.config/opencode / ~/.cursor 下
   skills/task-planner/ 均为完整副本，无指针引用薄壳）；「stub」保留为脚本/函数命名历史术语，不改文件名与函数名。
2. **头注释 Effect 块（原 :8-14）** 在 rsync 三行后补 3 行口径注：上述 rsync 即全量副本同步，
   「stub_dir」为脚本命名历史术语保留。
3. **install_stub_for_tool 内 rsync 处（原 :262 附近）** 在 `# Rsync content dirs` 行后补 4 行
   口径修正注：原口径把宿主位描述为 thin stub，实盘=全量副本同步，sed 重写只是副本内路径本地化。

保留项（验收口径要求）：
- 文件名 install-stub.sh、函数 install_stub_for_tool / generate_stub_skill_md /
  install_satellite_skills、变量 stub_dir、echo 日志「[install-stub]」——全部未改（历史术语）。
- 生成模板内（claude/zcode/opencode-frontmatter heredoc 内的「适配薄壳」标题）未动：
  那是产出 SKILL.md 的文档文案而非本脚本口径注释，超出本 S-unit 单文件注释修正范围（如主进程
  需同步可在后续 S-unit 处理，负结果登记于此）。

## 第一手证据
- 全 worktree find 定位：`find . -name install-stub.sh` 唯一命中 = skills/task-planner/lib/install-stub.sh
- install.sh:134 调用链实证：`install_stub_for_tool "$tool" "${TOOL_STUB_ROOT[$tool]}" ...`，
  detect-tools.sh:17-23 TOOL_PROBES 四位宿主（claude/zcode/opencode/cursor/continue 探测 5 路，
  审计 M-1 口径以实盘在用的四位为准）
- 17-executor 检查点已登记实盘核实：四位宿主位目录含 config.json/scripts/全量内容 = 全量副本形态

## 验证结果（worktree 内）
- `bash -n skills/task-planner/lib/install-stub.sh` = 通过（exit 0，输出 "bash -n OK"）
- `git diff --stat` = 2 文件：INSTALL.md（4+/1-，Phase 5 S1 产物 17-executor 未 commit，主进程
  编排预期内）+ lib/install-stub.sh（16+/1-，本 S-unit 唯一改动）；**本 S-unit diff 仅 1 文件**
- 未 commit（遵照指令）

## 未动清单（负结果）
- 脚本执行代码零改动（纯注释，rsync/sed/chmod 逻辑逐行未动；git diff 确认无代码行变更）
- 头注释「Idempotent: overwrites existing stub files」:24 行未动（「stub files」=历史术语语境，非部署形态描述）
- ARCHITECTURE.md / README.md / detect-tools.sh 未触碰（Phase 5 S3 / Phase 6 范围）

## 遗留提示（供主进程）
- heredoc 生成模板内「适配薄壳」文案（:56/:126/:177 附近）仍写「本薄壳只声明…」，与全量副本
  实盘同方向偏薄壳口径；如需彻底清账属新 S-unit 范围，本 S-unit 未越界
- 主进程合并前需把 S1 的 INSTALL.md 未提交 diff 与本 S-unit 一并编排 commit（§11.3 契约）
