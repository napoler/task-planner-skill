# S10 code-quality-review 检查点

**审查对象**：task-v154 Phase 4 CR — 5 个 bash selftest 脚本（worktree `/mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter`）
**审查时间**：2026-10-10
**审查方式**：只读审查 + 语法检查 + 实跑验证

---

## 结论

```
verdict=CHANGES_REQUESTED（P0=0, P1=1, P2=2）
```

---

## 问题清单

### P1（合并前必须修）

**[P1] selftest-decision-arbiter.sh:92 — DA-16 BRE `+` 量词依赖 GNU/ugrep 扩展，POSIX 环境假阴性**

- **问题**：`grep -cE '[a-z_]+_enforce'` 在 BRE 中 `+` 作为量词是 GNU/ugrep 扩展。在 POSIX 兼容 grep（BSD grep、busybox）上 `+` 是普通字符，模式匹配字面 `+`，导致 `_enforce` 键计数恒为 0，断言假阴性（永远 PASS，守护失效）。
- **证据**：当前系统 ugrep 7.8.4 实测 `foo_enforce` 匹配 `[a-z_]+_enforce`（exit=0 输出 1），确认 GNU 扩展语义生效；仓内无其他 selftest 使用 BRE `+` 量词先例（grep 全仓仅此一处）。
- **建议修法**：改为纯 POSIX BRE `grep -cE '[a-z_][a-z_]*_enforce'`（去掉 `+` 量词依赖），或改用 ERE `grep -Ec '[a-z_]+_enforce'`。两处 `[a-z_]+_enfix` 均需改（行内两处：ARBITER 文件 grep + CRIT awk 管道后 grep）。

### P2（建议不阻断）

**[P2] selftest-decision-arbiter.sh:92 — DA-16 awk 范围模式 `/^### 69 /,0` 依赖 GNU awk 扩展**

- **问题**：`awk '/^### 69 /,0'` 中范围结束用数字 `0` 是 GNU awk 扩展，POSIX awk 要求范围结束为 pattern（如 `/^### 69 /,/$/`）。mawk 等非 GNU awk 可能报错或行为未定义。
- **证据**：当前系统 gawk 5.2.1 实测正常输出 10 行；仓内无其他脚本用 `/start/,0` 范围模式先例（grep 全仓仅此一处）。
- **建议修法**：改为 `awk '/^### 69 /{p=1} p'` 或 `sed -n '/^### 69 /,$p'`，兼容 POSIX。

**[P2] selftest-decision-arbiter.sh:92 — DA-16 文件缺失时 `integer expression expected` 报错污染 stderr**

- **问题**：CONFIG/ARBITER/CRIT 任一文件缺失时，`grep -cE` 返回空字符串，`[ "" -eq 0 ]` 触发 `bash: [: : integer expression expected` 错误消息。条件为 false 走 bad（守护行为正确），但 stderr 报错干扰输出可读性。
- **证据**：`ARBITER=/nonexistent; [ "$(grep -cE 'arbiter' "$ARBITER")" -eq 0 ]` → `integer expression expected`，exit=2。
- **建议修法**：命令替换加 `2>/dev/null || true` 兜底，或改用 `grep -cE 'pattern' "$file" 2>/dev/null || true`。

---

## 审查重点逐项结论

### 1. 新脚本质量（selftest-decision-arbiter.sh）

| 检查项 | 结论 | 证据 |
|--------|------|------|
| 变量引用/quotes 安全（set -u） | PASS | 所有变量引用均带双引号，`${BASH_SOURCE[0]}` 安全，无未定义变量风险 |
| grep 模式转义 | PASS（BRE 字符类 `[1-6]` 语义正确） | DA-07 `grep -c 'T[1-6] '` 实测匹配 6 个 T 标记（agent 文件行 33-38 格式 `T1 `..`T6 ` 带尾随空格）；DA-12 `grep -c 'Rule 69.1 T[1-6]'` 实测计数 6 ≥5 |
| 错误处理（文件缺失） | P2 — 行为正确但 stderr 报错 | 文件缺失时所有 grep 返回 2 → 条件 false → bad FAIL（守护正确）；DA-16 `[ "" -eq 0 ]` 额外产生 `integer expression expected` 报错 |
| POSIX 兼容性 | P1 — BRE `+` 量词 + awk `/,0` 范围 | 见问题清单 P1/P2 |
| 硬编码绝对路径 | PASS | 无硬编码路径，全部经 `SCRIPT_DIR`/`SKILL_ROOT` 自定位，任意 CWD 执行验证通过（/tmp 下 16/16 PASS） |

### 2. 断言表达力（DA-01..16）

| 断言 | 守护目标 | 表达力评估 |
|------|----------|------------|
| DA-01 | agent 文件存在 | 真实守护，`-s` 检查非空 |
| DA-02 | model 逐字锚 | 真实守护，`-F` 固定串 |
| DA-03..06 | 四态字面 | 真实守护，四态各 1 断言，覆盖裁决消费协议枚举面 |
| DA-07 | 驳回单五要素 + T1-T6 | 真实守护，实测 T 标记计数 6 |
| DA-08 | 管辖二分四邻 | 真实守护，四邻词各 1 断言 |
| DA-09 | Rule 69 六子条 | 真实守护，六子条各 1 断言 |
| DA-10 | [arbiter-reject] 留痕 | 真实守护 |
| DA-11 | 路由表判断/裁决行 | 真实守护 |
| DA-12 | SKILL 触发点标记 ≥5 | 真实守护，实测计数 6 |
| DA-13 | C46 合规行 | 真实守护 |
| DA-14 | 覆盖矩阵 28 行 | 真实守护 |
| DA-15 | registry 自登记 | 真实守护（自指） |
| DA-16 | 零新 config 键负断言 | 真实守护，但 BRE `+` 量词可移植性缺陷（P1） |

**无恒真/恒假断言**：16 条断言均对应可观察的文件内容锚点，无永真/永假模式。

### 3. 修复改动最小性

| 文件 | 改动 | 最小性评估 |
|------|------|------------|
| selftest-agent-coverage.sh | AC-09 上界 129→130 + 演进注记 | PASS — 仅锚值 + 注记，无逻辑改写 |
| selftest-drift-check-subagent.sh | DCS-11 头注 40-65→40-69 + 断言字符串 | PASS — 仅锚值 + 注记，无逻辑改写 |
| selftest-research-first.sh | RF-06 '1-66'→'1-6[0-9]' + RF-07 '1-66'→'1-69' | PASS — 仅锚值演进 + 注记，无逻辑改写 |
| selftest-goal-unit-goal-mode.sh | G-09 钉值 515→526 | PASS — 仅钉值 + 注记，无逻辑改写 |
| selftest-skill-split.sh | T-主钉值 515→526 + 演进链 | PASS — 仅钉值 + 演进链追加，无逻辑改写 |

### 4. 仓内风格一致性

| 检查项 | 结论 | 证据 |
|--------|------|------|
| ok()/bad() 函数体例 | PASS | `printf 'DA-%s PASS/FAIL %s\n'` 与 selftest-drift-check-subagent.sh:22-23 `printf 'DCS-%s PASS/FAIL %s\n'` 完全同构 |
| 双层注释（What/Why） | PASS | DA-01..16 均有 What/Why 双层注释，与仓内 selftest 风格一致 |
| SCRIPT_DIR/SKILL_ROOT 定位 | PASS | 与 selftest-agent-coverage.sh:28-29 等同构 |
| Total 行 + exit 约定 | PASS | `printf 'Total: %d PASS=%d FAIL=%d\n'` + `exit $((FAIL > 0))` 与仓内一致 |
| 头注用途/输入/运行方式 | PASS | 头注含 What/Why/运行方式/演进史注记位，风格一致 |

---

## 验证证据

```
# 语法检查（6 文件全 PASS）
bash -n selftest-decision-arbiter.sh → syntax OK
bash -n selftest-agent-coverage.sh → syntax OK
bash -n selftest-drift-check-subagent.sh → syntax OK
bash -n selftest-research-first.sh → syntax OK
bash -n selftest-goal-unit-goal-mode.sh → syntax OK
bash -n selftest-skill-split.sh → syntax OK

# 主审脚本实跑（worktree CWD）
bash skills/task-planner/scripts/selftest-decision-arbiter.sh
→ DA-01..16 全 PASS, Total: 16 PASS=16 FAIL=0, EXIT=0

# 任意 CWD 执行（/tmp）
cd /tmp && bash /mnt/.../selftest-decision-arbiter.sh
→ 16/16 PASS, EXIT=0

# DA-07 T 标记计数
grep -c 'T[1-6] ' skills/task-planner/companion/agents/decision-arbiter.md → 6

# DA-12 触发点标记计数
grep -c 'Rule 69.1 T[1-6]' skills/task-planner/SKILL.md → 6

# DA-16 awk 管道
awk '/^### 69 /,0' skills/task-planner/references/critical-rules.md | wc -l → 10
awk '/^### 69 /,0' skills/task-planner/references/critical-rules.md | grep -cE '[a-z_]+_enforce' → 0

# BRE + 语义（GNU/ugrep 扩展）
printf 'foo_enforce\n' | grep -cE '[a-z_]+_enforce' → 1（匹配）
printf 'x+_enforce\n' | grep -cE '[a-z_]+_enforce' → 0（不匹配，证明 + 作为量词）
printf 'foo_enforce\n' | grep -cE '[a-z_][a-z_]*_enforce' → 1（POSIX BRE 等效）

# 仓内 BRE + 先例
grep -rn "grep -cE.*\[a-z_\]+" skills/task-planner/scripts/*.sh | grep -v decision-arbiter → 无（仅 decision-arbiter 一处）
```
