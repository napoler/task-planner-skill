<!-- template_type: rule-enhancement -->
execution_lane: L2
<!-- 适用场景: task-planner 技能规则/条款增强——新增/修订条款、流程接线、模板与守护同步 -->
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1

# Task Plan: 指令理解迭代与歧义门控确认改进（task-intent-iter-20261117）

## 🎯 用户需求原文（Rule 51.1）

- **R1**: 「明明用户一直表示了需是对模板体系进行升级，然后竟然…去做乱七八糟的事情…对用户的指令的理解存在严重的缺陷。」<sub>（[目标]）</sub> — 见 user-session-log.md #1
- **R2**: 「在复述完用户指令之后，然后做一个…迭代模块…用户原始指令，模型理解指令一，然后模型思路2…大体思路3，类似这样迭代个三四次展示…展示出…当前解决当前问题的大体思路…粗稿…让用户明确的展示出大体的方向是什么…在这方面进行改进技能」<sub>（[目标]）</sub> — 见 user-session-log.md #1
- **R3**: 「不是所有的任务都需要去需要用户确认的…明确的任务…为什么还要停下来去询问用户呢…对于模型Agent来说，理解用户的指令…存在多处歧义的情况下，才需要去与用户沟通…模糊的指令…候选的方案有很多种，比如说是有三四种的时候，你才需要列出来…哪种是需要确认…而不是一股脑的…无论什么用户的指令明确不明确，都需要再确认一次」+示例（发文/提交代码明确不问；“维护一下日志”模糊才问）<sub>（[目标]/[约束]）</sub> — 见 user-session-log.md #2
- **R4**: 「推荐方向进行」<sub>（[目标]）</sub> — 见 user-session-log.md #3

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1,R2 | VC-1, VC-3 | 规则/流程/模板载体中存在“复述后 3-4 轮理解迭代草稿（原始指令→理解→思路/候选→大体方向）”的制度化定义与展示/留痕要求，强调执行前方向可见与可纠偏 |
| R3 | VC-2, VC-3 | 明确“明确任务免无价值确认、歧义/多候选(典型3-4)才选项确认”的歧义门控原则落地（ask/silent 与既有门控边界清晰），不破坏 D6/不可逆等硬停 |
| R2,R3 | VC-4 | SKILL/模板/交互描述与自测守护同步更新，与 28.2.1/80.7/109/51.1/反造谣等约束兼容 |
| R1-R4 | VC-5 | 变更可追溯、交付说明含改动点与验证证据 |

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象 | 取证方式 | 落盘锚 | 状态 |
|--------|----------|---------|--------|------|
| ① 自身样本 | SKILL.md/critical-rules-discipline.md/critical-rules.md/config.json/模板/selftest-interaction.sh/resolve-interaction-mode.sh | Read+子代理Explore梳理 | progress.md, 会话分析 | ☑ |
| ② 对标样本 | 既有 28.2.1、80.7 理解镜像、8.1.1 目标切换复述、Rule 72/28.3 选项规范 | 仓内规则对照 | discipline/SKILL 文本 | ☑ |
| ③ 外部约束 | 用户 R1-R4 原话与推荐方向确认 | user-session-log.md | user-session-log.md #1-#3 | ☑ |

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1-R4 |
| **裁决** | `partial`（进行中） |
| **解决证据锚** | 本计划与即将落地的规则/技能/模板/自测变更 |
| **未解决面+原因** | 尚未完成代码/文档改动与验证 |
| **已排除路径** | 全任务一刀切强制确认（与 R3 冲突） |
| **下一步建议** | 实施方案 A：新增理解迭代+歧义门控条款，接线 SKILL/模板，自测守护，同步验证 |

## Goal
在 task-planner 技能体系中制度化“复述后 3-4 轮理解迭代草稿（方向可见、可早纠偏）+ 歧义门控确认（明确不问、歧义/多候选才选项确认）”，修复指令理解偏移与无价值确认问题，并与现有门控/自治/反造谣约束兼容。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（规则/流程/模板/脚本自测改动，按规则增强流程验证） |
| `session_id` | `sess_intent_iter_20261117` |
| `worktree_path` | 直接在源仓改动（用户明确授权改进技能；受控范围内） |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/templates/user-session-log.md`, `skills/task-planner/templates/task_plan.md`, `skills/task-planner/config.json`, `skills/task-planner/scripts/selftest-interaction.sh`（按需最小增量） |
| `interaction_mode` | `ask` |
| `new_rule` | 留空（28.x 子条增补，非顶层新 Rule 编号） |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | discipline 规则新增“理解迭代草稿（3-4轮）”定义，含轮次骨架、展示目的、纠偏与留痕、与28.2.1/80.7/51.1/反造谣边界 | Read 规则段落 | `skills/task-discipline/references/critical-rules-discipline.md` |
| VC-2 | 规则明确歧义门控：明确任务不阻塞/不无价值确认；仅歧义/多候选/关键不明时选项确认；silent/goal/44.3/mini 降级留痕与硬停不豁免 | Read 规则段落 | 同上 |
| VC-3 | task-planner SKILL/核心索引接线该模块（新指令/计划前对齐时机、ask展示与免确认分支、与委派衔接） | Read 变更片段 | `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md` |
| VC-4 | 模板/config/自测守护同步（理解迭代承载或提示、interaction 描述一致、selftest-interaction 新增静态锚且通过） | Read + bash 自测 | templates, config.json, `bash skills/task-planner/scripts/selftest-interaction.sh` |
| VC-5 | 交付说明列出改动文件、行为变化与验证结果，满足 R1-R4 | 对话交付+证据 | 本会话输出 |

## Phase 0: 现状分析与计划定稿（已完成）
- [x] 复述用户指令并完成 4 轮理解迭代草稿，获“推荐方向进行”确认
- [x] 子代理 Explore 梳理现有 28.2.1/80.7/D1/委派与守护脚本现状
- [x] 新建计划目录并初始化

## Phase 1: 规则与流程改造（核心）
- [x] 在 discipline Rule 28 新增 28.2.2（理解迭代+歧义门控）
- [x] 更新 task-planner SKILL.md 接线（新指令处理/初始化/D1前理解对齐、合规提示）
- [x] 更新 critical-rules.md 索引/Rule 1 衔接（如需）

## Phase 2: 模板与配置同步
- [x] 更新 user-session-log.md（及必要模板）支持理解迭代草稿留痕
- [x] 更新 config.json interaction_mode 描述与一致性文案

## Phase 3: 守护与验证交付
- [x] 扩展 selftest-interaction.sh 静态守护并运行通过
- [x] 回读关键 diff/片段，输出变更说明与验证证据

## Decisions Made
| 决策 | 理由 | 时间 |
|------|------|------|
| 采用推荐方案 A（理解迭代+歧义门控，明确免确认） | 用户 R3/R4 明确 | 2026-11-17 |
| 意图切换：从 task-tplsys-upgrade-20261117 切换到本任务 | 本轮目标为改进技能指令理解机制，与模板体系升级任务三要素无交集 | 2026-11-17 |
