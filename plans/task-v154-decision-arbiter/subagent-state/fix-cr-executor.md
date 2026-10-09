# fix-cr-executor 检查点（task-v154 CR fix-phase）

**时间**：2026-10-10
**worktree**：/mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter（branch wt/v154-decision-arbiter @ 6e1202f 起点）
**来源**：S10 code-quality-review（P1=1 DA-16 可移植性 / P2×2 awk ,0 + 文件缺失 stderr）；S9 P2-01 CHANGELOG 未登
**改动文件**：仅 2 个（DA 脚本 + worktree 仓根 CHANGELOG）

---

## ① `skills/task-planner/scripts/selftest-decision-arbiter.sh`（DA-16，行 89-96 段）

### diff 逐行（git diff 原文）
```
@@ -89,7 +89,10 @@
 # DA-16 零新 config 键负断言
 # What: config.json 无 arbiter 键字面 (=0) 且新增面（decision-arbiter.md + Rule 69 段）无 _enforce 新键声明 (=0)。
 # Why: 69.6 承诺零新 config 键（判定面=LLM 行为+静态守护）——键字面出现=有人给判断裁决加机器门控键（机制漂移）。
-if [ "$(grep -cE 'arbiter' "$CONFIG")" -eq 0 ] && [ "$(grep -cE '[a-z_]+_enforce' "$ARBITER")" -eq 0 ] && [ "$(awk '/^### 69 /,0' "$CRIT" | grep -cE '[a-z_]+_enforce')" -eq 0 ]; then ok 16 "..."; else bad 16 "..."; fi
+# [2026-10-10 task-v154 CR fix] P1 可移植性：原写法 grep -cE '[a-z_]+_enforce' 的 `+` 量词在非 GNU/ugrep 的 POSIX grep 下当字面量，_enforce 计数恒 0（负断言假阴性、守护失效）；修法=两处均改 POSIX BRE/ERE 通吃的 [a-z_][a-z_]*_enforce（去掉 + 量词依赖）。
+# [2026-10-10 task-v154 CR fix] P2-1 awk 范围：原写法 awk '/^### 69 /,0' 的 `,0` 结束模式是 GNU awk 扩展（POSIX awk 要求范围结束为 pattern）；修法=显式锚范围 /^### 69 /,/^### 7[0-9] /（69 为末节、下一规则号锚当前不存在→等价至 EOF，未来加 70+ 段自动收口）。
+# [2026-10-10 task-v154 CR fix] P2-2 stderr 噪音：文件缺失时 grep 报 No such file 且 [ "" -eq 0 ] 触发 integer expression 报错；修法=文件读取加 2>/dev/null 静默 + 计数比较改字符串 = "0"（判定不变：在位正常计数、缺失则空串≠"0"→FAIL）。
+if [ "$(grep -cE 'arbiter' "$CONFIG" 2>/dev/null)" = "0" ] && [ "$(grep -cE '[a-z_][a-z_]*_enforce' "$ARBITER" 2>/dev/null)" = "0" ] && [ "$(awk '/^### 69 /,/^### 7[0-9] /' "$CRIT" 2>/dev/null | grep -cE '[a-z_][a-z_]*_enforce')" = "0" ]; then ok 16 "..."; else bad 16 "..."; fi
```

### 三处修复要点
| # | 修复 | 原写法 | 修法 | 验证 |
|---|------|--------|------|------|
| P1 | `[a-z_]+_enforce` 可移植性 | `grep -cE '[a-z_]+_enforce'`（`+` 量词在 POSIX grep 下当字面量→假阴性） | `grep -cE '[a-z_][a-z_]*_enforce'`（BRE/ERE 通吃），ARBITER + CRIT 两处均改 | `printf 'some_key_enforce\n' \| grep -cE '[a-z_][a-z_]*_enforce'` → 1（真阳性保持）；`printf 'x+_enforce\n'` → 0（不误匹配字面 +） |
| P2-1 | awk `,0` 范围 | `awk '/^### 69 /,0'`（GNU awk 扩展） | `awk '/^### 69 /,/^### 7[0-9] /'`（显式锚范围） | `diff <(旧) <(新)` → 空（逐字节等价，10 行）；`[0-9]+` 变体自匹配起始行仅 1 行=错误写法，已排除 |
| P2-2 | 文件缺失 stderr 噪音 | `grep -cE 'x' "$f"` + `[ "" -eq 0 ]`（No such file + integer expression 双噪音） | 文件读取加 `2>/dev/null` + 计数比较改 `= "0"`（字符串） | 缺失文件：旧式打印 `[: : integer expression expected` exit=2；新式无 stderr exit=1（FAIL 保持）；在位 0 匹配 → exit=0（PASS 保持） |

### 复跑验证（worktree 内 + 任意 CWD，stderr=0）
```
[worktree CWD] bash skills/task-planner/scripts/selftest-decision-arbiter.sh
DA-16 PASS 零新 config 键：arbiter=0 且新增面无 _enforce 键
Total: 16 PASS=16 FAIL=0   EXIT=0   stderr bytes=0
[/tmp] cd /tmp && bash <绝对路径>/selftest-decision-arbiter.sh
Total: 16 PASS=16 FAIL=0   EXIT=0   stderr bytes=0
bash -n → OK
```

---

## ② `CHANGELOG.md`（worktree 仓根，P2-01 补登）

### 插入位置
`## [Unreleased]` → `### 新增` 段**首条**（第 10 行 `### 新增` 后，第 12 行 = 新 task-v154 条目；第 13 行起为既有 v149 条目）。**仅插入 1 行，既有条目零改动**。

```
10: ### 新增
11: (空行)
12: - **Rule 69 判断裁决子代理化与驳回打回纪律（task-v154）** — 2026-10-10 落地用户目标「…」：…
13: - **Rule 65 周期性回顾与前后对照恢复+技能全载体对齐（task-v149）** — …（原文未动）
```

### 条目全文（单行，逐字段对齐 v153 条目风格）
`- **Rule 69 判断裁决子代理化与驳回打回纪律（task-v154）** — 2026-10-10 落地用户目标「主进程遇判断类问题（方案终裁/失败定级/验收争议/DRIFT 处置/CR 分歧）时以强模型独立裁决出口取代硬决，并以驳回打回闭环保证裁决被执行」：新增 companion/agents/decision-arbiter.md（GLM-5.3 强档执行体=四态裁决 APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE + 驳回单五要素 + T1-T6 六触发点矩阵 + drift-checker/critic/meta-corrector/complex-planner 四邻管辖二分）；references/critical-rules.md 末尾纯追加 Rule 69 六子条（…69.1-69.6…）；SKILL.md 判断/裁决路由行 + 合规清单 C46 + 执行流程 T1-T6 触发点标记 6 处 + 计数 1-66→1-69 修正；references/agent-coverage.md 判断/裁决 28 行 + 计数同步；references/template-mapping.md §九§十登记；新增 scripts/selftest-decision-arbiter.sh（DA-01..16 静态守护，registry 登记闭环）+ selftest-agent-coverage.sh AC-09 上界 129→130 演进；零新 config 键。触发点=计划期终裁·兜底换道·失败定级·验收争议·DRIFT 处置·CR 分歧六场景。`

### diff --stat / numstat
```
 CHANGELOG.md                                             | 1 +
 skills/task-planner/scripts/selftest-decision-arbiter.sh | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)
numstat CHANGELOG.md = 1  0   （纯插入，零删除）
git status --short → 仅 M CHANGELOG.md / M selftest-decision-arbiter.sh
```

---

## 异常/偏差登记
- **worktree CHANGELOG 缺 v153 条目**：wt/v154 分支 base（5afba9c）早于 v153 合入 master（master 有 v153、worktree 无），故「`### 新增` 段顶部」在 worktree 实态= v149 条目之前（v153 不在该副本）。已按运行指令「### 新增 段顶部」插入，落位即全段首条，时间序（v154 > v153 > v149）正确；未来合并 master 时 v153 将落在 v154 与 v149 之间。**未做 merge（超范围，任务书明令只碰 2 文件）**。
- P2-2 采用 `2>/dev/null`（任务书首选）+ 字符串比较 `= "0"`：前者静默 grep 的 No such file，后者消除 S10 所指 `integer expression expected`（`2>/dev/null` 单独不足以消除后者——`|| true` 同 S10 建议亦不消除），二者职责不同、非冗余，PASS/FAIL 判定不变。
