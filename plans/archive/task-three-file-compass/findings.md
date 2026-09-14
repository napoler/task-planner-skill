# Findings & Decisions

## Requirements
<!-- Captured from user request (2026-09-04) -->
- 强制三文件体系：task_plan.md（主线控制面板）+ findings.md（调研/发现/决策）+ progress.md（会话日志/测试结果）
- 痛点 1：执行过程"没有及时罗盘"——只有 task_plan.md，findings/progress 未被及时补充，信息滞留易失上下文 → 偏差产生
- 痛点 2：所有内容都直接改 task_plan.md 大文件 → 单文件负担膨胀
- 对齐 Manus 五原则：文件系统即记忆 / 计划复述 / 错误持久化 / 目标追踪 / 完成验证
- 要求 2-Action Rule 生效：每 2 次查看类操作（view/browser/search/read/grep）后必须同步 findings.md

## Research Findings
<!-- 2026-09-04 现状侦察（仓库 = canonical，安装副本落后一个 Rule 26 版本，合并后需部署同步） -->

1. **init 链路正常，不是病灶**：`init-session.sh:83` 循环创建 5 文件（findings/progress/notepad-learnings/verification + task_plan），实测空目录运行 5 文件齐全（2026-09-04 20:53 实证）。
2. **终验门是最大缺口**：`check-complete.sh`（217 行）只查 Phase 状态/Batch Report(Rule 18.6)/Aggregator(Rule 23.6)，**全文无任何 findings/progress 引用**——Rule 19.2/26-Q2 只存在于文档规则，工具层不强制 → 执行者不回填无任何后果。
3. **PostToolUse hook 是第二缺口**：`zcode-posttooluse.sh` 优先级 1 只催 task_plan.md 回写、优先级 2 只催 Todo 同步，**无 findings/progress 提醒**；且优先级 1 文案"Edit task_plan.md 回写进度"把一切回写压力导向大文件——正是用户痛点 2 的推手之一（本会话 21:05 实测触发 [plan-sync]，文案实证）。
4. **规则层已有一部分**：SKILL.md Rule 19（3a/3b/3c/3d 落盘点）+ critical-rules.md 19.1-19.4 + 2-Action Rule(Rule 3) + 产出落盘映射表——但缺：终验门联动、task_plan.md 瘦身条款、及时性量化阈值。
5. **模板层已可用**：templates/findings.md（97 行，含 2-Action 引导）/ progress.md（125 行，Actions taken/Files/Test Results/Error Log 结构与 Rule 19.2 对齐）——无需改动，改动集中在规则与脚本。
6. **check-drift.sh 已消费 progress/findings**（VC-COVERED/GOAL-DRIFT/SCOPE 检测），说明消费端模式成熟，check-complete.sh 补门符合既有架构。
7. **config.json 阈值集中管理**（"all mutable numbers live here" 原则）：新增 findings/progress 陈旧阈值应入 config.json properties（注意 `additionalProperties: false`，posttooluse 用 `.properties.<key>.default` 路径读取）。
8. **state 文件格式**：posttooluse state = `<count> <epoch> <cooldown_left>`（空格分隔，cut 取字段）——扩展冷却字段须向后兼容（缺失字段兜底 0）。
9. **check-complete.sh 由 Stop hook 调用**，头注释 "Always exits 0" 与实际行为（batch/aggregator exit 1）已矛盾——本次改动顺手修正该注释。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新条款挂 Rule 19 下（19.5 终验门 / 19.6 瘦身 / 19.7 及时性链路），不开顶层 Rule 27 | 用户痛点 = Rule 19 执行不力；集中修订避免碎片化；SKILL.md 索引/终验/C 清单同步引用 |
| stub 判定 = 「文件行减去模板文件行集合后，实质内容 <3 行」 | 模板自身 2.5-4.4KB，字节阈值会误判；行集合扣除法确定性可判 |
| 缺失/stub → exit 1 硬门；task_plan.md >500 行 → 仅 WARNING | 硬阻断膨胀会 brick 长任务；回填缺失才阻断（对齐 Rule 26 惩罚哲学：可判定 + 确定性） |
| posttooluse 提醒优先级队列：plan 陈旧 > findings 陈旧 > progress 陈旧 > todo 计数；每次最多 1 条 + 独立冷却字段 | 防三连轰炸；state 扩展为 5 字段向后兼容 |
| 陈旧 plan 提醒文案改为内容分流（状态→task_plan / 结论→findings / 动作→progress，细节只留指针） | 直接治理痛点 2，从提醒源头导向三文件分工 |
| 不改 ~/.zcode/cli/config.json（hook 注册不动） | zcode-posttooluse.sh 已注册在用，仅增强脚本内容 |
| 部署副本同步放 Phase 5（合并后） | 安装副本落后仓库一个 Rule 26 版本，需一并补齐 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 上轮误将未发生的 Phase 2-5 预标 complete（违反三证据铁律） | 2026-09-04 21:05 已全部回退为真实状态，Drift Log 留痕；后续状态翻转只在产出落盘后执行 |

## Resources
- 仓库 canonical：/mnt/data/dev/task-planner-skill/skills/task-planner/
- 安装副本（落后）：/home/terry/.zcode/skills/task-planner/（HEAD 65031a5，缺 Rule 26）
- planning-with-files 原始理念（用户提供）：三文件 + Hooks（PreToolUse 复诵/PostToolUse 提醒/Stop 验证）+ 2-Action Rule + 5Q Reboot
- 宪法条款：§11.1（skill 保护区 → worktree 强制）、§11.2（worktree 集中目录路径规范）、Rule 26（质量门控范式：可判定触发式 + 确定性惩罚映射）

## Visual/Browser Findings
-（本任务无多模态操作）
