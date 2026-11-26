---
name: research-channels
description: 本地调研方法论与防遗漏索引。计划期调研阶段强制调用；用户直呼「调研」「先查什么」「查资料」「本地调研」时触发。承载五层方法（枚举→索引→检索→阅读锚定→外部），研究第 0 步=取项目索引，通道失败必须当轮换下一层并留证据。
allowed-tools: "Read, Bash, Grep, Glob, Write, Edit, Agent, Skill"
user-invocable: true
---

# Research Channels

本地调研方法论与防遗漏索引。机制通用、零写死目录——目录数据归项目自己的索引与注册表。

## §定位

- **本技能**：本地证据通道方法论（L1-L4）+ 外部层转交指针（L5）。
- **plan-research-router**：网络/github 路由 SOP。两者互补不重叠；L5 外部调研转 `Skill(skill="plan-research-router")`。
- **research-assistant**：外部多源检索执行链，由 L5/路由侧调用。

## §五层方法速查

| 层 | 名称 | 何时用 | 速查 | 详情 |
|---|------|--------|------|------|
| L1 | 枚举 | 结构未知/先摸骨架 | `ls -la <root>` / `find <root> -maxdepth 2 -type d` / 全量清单 | [§1](references/research-channels.md#1-l1-枚举层) |
| L2 | 索引 | 研究第 0 步/全局清单 | `bash <skill>/scripts/project-inventory.sh --root <root>` | [§2](references/research-channels.md#2-l2-索引层) |
| L3 | 检索 | 知道关键词/文件名 | `find <root> -iname '*kw*'` / `grep -rnE 'a\|b' <root>` | [§3](references/research-channels.md#3-l3-检索层) |
| L4 | 阅读锚定 | 结论落盘/回执 | 逐字摘录 + `file:line` 锚，禁转译改写 | [§4](references/research-channels.md#4-l4-阅读锚定层) |
| L5 | 外部 | 本地证据不足 | 转 `plan-research-router` / `research-assistant` | [§5](references/research-channels.md#5-l5-外部层) |

## §研究第 0 步

任何调研动作前先取项目索引（防遗漏清单完整性保证）：

```bash
# 生成或复用未陈旧索引（exit 0=fresh, 1=stale, 2=missing）
bash <skill>/scripts/project-inventory.sh --root <root> --check || \
  bash <skill>/scripts/project-inventory.sh --root <root>
```

索引 = "全局有什么"的确定性基线；**没进索引 = 没被发现**，索引外区域必须显形处理（补扫或显式排除）。

## §通道失败纪律（P0）

- **任一层命令失败/无结果 → 当轮换下一层并留证据**（失败命令 + 原因一行），禁止停留在单层宣布受限。
- 五层穷尽后才可声明"受限"；声明必须附：已尝试层、各层证据、剩余盲区。
- 禁止跳层/乱序/同一方法死磕 ≥2 次；大输出不硬塞主上下文，委派子代理提炼后带锚回收。

## §结论锚定

- 每条调研结论必须附源锚：`file:line` 或 `命令 + 输出摘要行`。
- 无锚结论 = 未验证，不得作为决策依据写入 plan/findings。

## §消费回执接线

- L4 阅读层产出 =「声明源扫描回执」，落 plan-state `spec_baseline`（`dimension` 为开放标签，机制不枚举）。
- 回执格式与字段见 [§4](references/research-channels.md#4-l4-阅读锚定层)；与 task-planner 的 `spec-scan` / `spec-brief` / `check-spec-baseline` 消费门衔接由 task-planner 侧完成，本技能只声明分工与产出格式。
