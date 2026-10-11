# m14 部署收尾任务书（task-v124 — 供 [sub:deploy] 子代理执行）

## 任务一：两个 skill-agent-router 部署位补「九、内容与媒体类」节

目标文件（仓外部署位，用户已授权范围）：
- /home/terry/.zcode/skills/skill-agent-router/SKILL.md
- /home/terry/.claude/skills/skill-agent-router/SKILL.md

插入位置：各文件「## general-purpose 合法使用场景（仅以下情况）」之前；插入内容（两文件相同，逐字照抄，含空行）：

```
### 九、内容与媒体类

| Agent | 触发场景 | 何时不该用 |
|-------|---------|-----------|
| **image-generation-executor** | 图片生成、图像生成、批量出图、三检闭环（写词核词→试水→三检→扩批） | 纯文本内容创作（走 article-* 系列）；视频链路（走 video-generation-executor） |
| **video-generation-executor** | 视频生成、镜头生成、视频重生成、成片生成（含 G1 放行核验与异步轮询） | 图像层任务（走 image-generation-executor）；草稿 QC 与放行（归 A 侧执行体/用户，隔离铁律） |

```

注意：
- .zcode 位「八、」节已含 complex-planner 行（勿动勿重复）；.claude 位的 complex-planner 行已由主进程补入（勿重复添加）。
- 先 Read 两文件定位锚，再 Edit；改后 grep 复核。

## 任务二：install-companion 双目标分发（以主仓为源）

命令（cwd 无关，脚本自解析；先 dry-run 复核再真跑）：
```
cd /mnt/data/dev/task-planner-skill/skills/task-planner && bash lib/install-companion.sh --dry-run
cd /mnt/data/dev/task-planner-skill/skills/task-planner && bash lib/install-companion.sh
bash lib/install-companion.sh --target /home/terry/.claude
```
预期：每目标 summary 含 2 install（两新 agent）+ 既有同步项（plan-writer、plan-template-kit/references/template-mapping.md 正向更新；其余 cmp 跳过）。

## 任务三：部署核对

- `~/.zcode/agents/image-generation-executor.md` 与 `~/.zcode/agents/video-generation-executor.md` 存在，且与主仓 `/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/` 同名文件 `diff` 一致
- `~/.claude/agents/` 两新文件存在，且仅 model 行经 adapt（`grep '^model:'` 输出不含 `custom:`；预期 `sonnet`），其余 diff 一致
- 两 router：`grep -c '九、内容与媒体类'`=1 且 `grep -c 'image-generation-executor\|video-generation-executor'`≥2；.claude 位 complex-planner 行恰 1 处

## 验收（返回 8 字段时逐项贴原文行）
1. 两 router 九节在位（grep 输出行）
2. 双目标 agents 核对通过（diff / model 行输出）
3. install-companion 双目标 summary 原文（install/update/skip 计数）

## 记录
- 检查点（本会话唯一）：/mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/m14-deploy.md（目录已存在；写入 编辑摘要+双目标 summary+核对表+最终结论 8 字段块）
- findings 追加：`#### [sub:deploy] <标题>` 到 `## Research Findings` 段末
- progress 追加：Phase 5 段「Actions taken」下 `  - [sub:deploy] <摘要>`
- 禁改主仓其他文件；禁止 git 写操作
