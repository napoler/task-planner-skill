# Checkpoint — [sub:04-executor] S9 research/code-edit 调研触点

- **status**: done
- **S-unit**: S9（dispatch: sub:04-executor, checkpoint 04-executor-s9）
- **需求锚**: R7「尤其相应的模板…我希望可以在模板中加入一些调研的步骤」（Rule 51.1a）
- **知识简报**: plans/task-v163-proactive-research/knowledge-brief.md §2/§3
- **rule 依据**: Rule 75.6（模板层定制：research-type 深化=三态判定行+现成方案行；code-edit 加 GitHub/官方文档检索行）

## 目标
在 worktree 两个 variant 模板植入调研触点：① research-type.md（三态判定行+现成方案行）；② code-edit-type.md（GitHub/现成方案检索行）。

## 动作
纯增量追加调研触点行到两 variant 模板「📚 必要知识储备」区块末尾（「填写规则」段后 / 下一 `##` 标题前），与 S10 同级 sibling（script-dev/deployment）插入锚一致。

## 产出锚（绝对路径）
1. `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/variant/research-type.md`
   - 变更 +3/-0 行（120→123）；新触点行落位 :55、:56（「填写规则」:53 后 / `## 🧰 工具选择与编排` 前）
2. `/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research/skills/task-planner/templates/variant/code-edit-type.md`
   - 变更 +2/-0 行（171→173）；新触点行落位 :60（「填写规则」:58 后 / `## Current Phase` 前）

## 新增行原文
- research :55 = `- **调研需求三态（Rule 75.1）**：本模板任务默认 NET-RESEARCH——调研策略制定 Phase 必须登记检索关键词+渠道（63.2 四步链）+预期产出形态到计划「🔍 调研需求与检索计划」区块`（step ② 逐字原文）
- research :56 = `- **现成方案/资料优先（Rule 75.3）**：调研动手前必须先检索现成资料/类似研究（官方文档/GitHub/竞品公开资料）——评估借鉴/适配后落地，禁重复造轮子，未检索就自研=违规`（objective/Rule 75.6 要求的「现成方案行」，step ② 未给逐字文本，按 Rule 75.3 语义补齐，与 sibling 行文风格一致）
- code-edit :60 = `- **现成方案检索（Rule 75.3/75.4）**：代码编辑前必须先 GitHub 检索现成实现（gh CLI 搜仓库/issues）+官方文档——检索到现成实现评估借鉴/适配，未检索就自研=违规`（step ③ 逐字原文）

## 验证证据（第一手命令输出）
- `grep -n "Rule 75.1\|Rule 75.3\|Rule 75.4" variant/research-type.md variant/code-edit-type.md` → research-type.md:55/:56、code-edit-type.md:60（2 文件均命中，2/2 PASS）
- `git diff --numstat` → `3 0 research-type.md` / `2 0 code-edit-type.md`（纯追加，零删除）
- `git diff` 全文 → 仅 `+` 行，零 `-` 行（既有内容零改动）
- md5 BEFORE→AFTER：research `16476b93a7fb0aa7f88dc5f90ef4f46e`→`40f4ff766381eeff3ba2b3639c2c38b3`；code-edit `a500dbaccf7f05ba232f9e442176dceb`→`ab220e0ba5c5c1ae4a24acd07a4e7874`
- `wc -l`：research 120→123 / code-edit 171→173
- `git status --short`：仅新增 code-edit-type.md / research-type.md 两 M 条目（本会话写入面）；其余 M 为并行既有产物，未触碰

## 偏差说明
- objective 写 research-type「（三态判定行+现成方案行）」，但 step ② 仅给出三态行逐字文本；scope 明确允许 research-type +1~2 行。据 Rule 75.6（research-type 深化=三态判定行+现成方案行）与 S2 探索结论（research-type 缺「判定面/现成方案」两类触点）补齐第 2 行（现成方案），以满足 objective 与 Rule 75.6。code-edit 严格按 step ③ 单行。

## 结论
两 variant 模板调研触点落盘，diff 仅追加、既有内容零改动，grep 2/2 命中。验收 2/2 pass。

## 禁区遵守
- 未修改 scope 外任何文件；未做 git 操作；未网络访问。
