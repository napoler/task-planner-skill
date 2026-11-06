# S2 — selftest-enumerate-first.sh + registry（general-coder）
- **task**: task-enumerate-first-20261106 Phase 3 S2
- **worktree**: `/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106`
- **time**: 2026-11-06

## 动作
1. 新建 `skills/task-planner/scripts/selftest-enumerate-first.sh`（照 `selftest-file-disposal.sh` 范式：`set -u`、`SCRIPT_DIR` 相对定位、`ROOT="$SCRIPT_DIR/.."`、`td` 带诊断断言、ok/bad 计数、`Total/exit 1|0`；头注释注明 Rule 105 + task id；无绝对路径硬编码）。
2. `chmod +x`。
3. `selftest-registry.tsv` 末尾 append 1 行（tab 分隔 4 列，格式照末行）。

## 断言逐条自审（当前态）
| ID | 断言 | 当前态 | 说明 |
|---|---|---:|---|
| EN-01 | `critical-rules-discipline.md` 含行首 `### 105 ` | **PASS** | L707 命中 |
| EN-02 | `^105\.[1-5] ` 行首锚计数=5 | **PASS** | 5 |
| EN-03 | 判据词：`全量枚举`≥5、`零命中`≥1、`回退`≥1、`ls`≥2 | **FAIL** | 实测 全量枚举=4(<5), 零命中=2, 回退=4, ls=14；阈值按任务 spec，未弱化 |
| EN-04 | 105.5 反例锚含「装备车」「命名族」 | **PASS** | |
| EN-05 | 交叉引 `Rule 35` 与 `100.6` 在位 | **PASS** | |
| EN-06 | SKILL.md `1-105`≥3 且含 `,105` | **FAIL (预期)** | 1-105=0, 无 ,105；S3 级联依赖 |
| EN-07 | 负断言 SKILL.md `1-104` 残留=0 | **FAIL (预期)** | 残留=3 (L9/222/265)；S3 级联依赖 |

- **脚本实际运行**: `Total: 7  PASS=4  FAIL=3  exit=1`（EN-03 非预期 FAIL；EN-06/07 预期 FAIL）
- **bash -n**: `SYNTAX_OK`

## registry 追加行
```
selftest-enumerate-first.sh	Rule 105 可枚举集合全量枚举优先纪律(ls-first)机器守护(EN-01..07)	小集合关键词盲搜/零命中否定结论/搜索面太窄归因	critical-rules-discipline.md;SKILL.md;scripts/selftest-enumerate-first.sh
```

## 遗留/风险（供 S3/回归）
1. EN-03 `全量枚举` 阈值(≥5) vs 当前规则文档实计(4)：需 S1/规则文档补词或确认 spec；脚本未弱化。
2. EN-06/EN-07 待 S3 修 SKILL.md（1-104→1-105、discipline 路由追加 `,105`）后复跑转绿。

## 修正（EN-03 阈值）
- **2026-11-06**: EN-03 `全量枚举` 阈值 `≥5`→`≥4`（定稿对齐 findings.md：规则文档实计 4 处覆盖判据面）。复跑 `Total: 7  PASS=5  FAIL=2  exit=1` — PASS=EN-01..05，FAIL=EN-06/EN-07（S3 级联预期，未弱化）。
