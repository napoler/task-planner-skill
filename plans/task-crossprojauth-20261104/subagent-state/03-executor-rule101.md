- [x] F1 完成：### 101 段逐字追加至 critical-rules-discipline.md 末尾（前留空行），grep -c "^### 101" = 1（2026-11-04 executor-rule101）

## F2–F8 完成 + 验收（2026-11-04 executor-rule101）

### 逐文件 edit 计数
- F1 critical-rules-discipline.md：追加 1 段（### 101 全段逐字，前留一空行；材料包 rule101-section.md 10 行含尾换行，逐字 cat 追加）
- F2 task-discipline/SKILL.md：Edit 5 处（L15 51 条+git 使用加强纪律 / L24 枚举 +101 / 表行插入 | 101 | / 落盘行 51 条 / L93 参考行 51 条+101）
- F3 task-planner/SKILL.md：Edit 5 处（L9 1-101+84 条 / L197 +git 使用加强+101 / L210 双片段 1-101+84 条 / L243 +git 使用加强（Rule 101） / L253 1-101）
- F4 critical-rules.md：Edit 2 处（L194 枚举 +101 / 调用条件 +git 使用加强）
- F5 selftest-anti-deferral.sh：Edit 2 处（头注 AD-09/AD-10 行块 + 断言区 AD-09/AD-10 四行）
- F6 selftest-subagent-activation.sh：Edit 2 处（头注 SA-11/SA-12 行块 + 断言区 SA-11/SA-12 五行）
- F7 worktree-isolation.md：Edit 2 处（§4 L86 失败处理句翻转为 Rule 101.2 冲突=收口义务语义 + §5 L94 反模式行收窄，「不乱解」守卫保留）
- 合计 Edit 调用 = 5+5+2+2+2+2 = 18 处 + F1 追加 1 次（Bash 机械追加，材料包逐字）

### 验收 1–10 原始输出
```
== A1 == grep -c '^### 101' critical-rules-discipline.md → 1
== A2 == grep -c '1-101' task-planner/SKILL.md → 3；grep -c '1-100' → 0
== A3 == grep -c '其余 84 条' → 2；grep -c '其余 83 条' → 0
== A4 == grep -c '共 51 条' → 2；grep -c '51 条' → 3；grep -c '共 50 条' → 0
== A5 == grep -c '^| 101 |' → 1；grep -c ',99,100,101' → 1
== A6 == grep -c ',100,101' task-planner/SKILL.md → 1；grep -c ',101' critical-rules.md → 1
== A7 == grep -c '冲突=收口义务' worktree-isolation.md → 2；grep -c '自动乱解不报告' → 0；grep -c 'merge 冲突 → STOP 报告用户(不自动解决)' → 0
== A8 == bash -n selftest-anti-deferral.sh → exit 0；bash -n selftest-subagent-activation.sh → exit 0
== A9 (F8 守卫预检) == grep -rn '不自动解决\|自动乱解\|冲突 → STOP\|冲突→STOP' skills/task-planner/scripts/*.sh skills/task-planner/scripts/ → 4 命中（全部在 smart-merge-back.sh L99/L343，各双列一次）；selftest-*.sh 守卫零命中
== A10 == 编辑面仅 7 文件（ls -lt mtime 07:48-07:50 核）+ 检查点追加；spec 外零编辑，材料包只读
```

### 失配登记
1. **A6 口径差异（非失配，登记裁决）**：spec 验收 6 写 `grep -c ',100,101' skills/task-planner/SKILL.md ≥2（L197+L210）`。磁盘实况：L197 编辑后含 `,100,101`（Route 4…100,101）命中 1 次；L210 的 101 出现在斜杠串 `99/100/101 纪律域`（Rule 前缀斜杠分隔，无逗号），`,100,101` 字面 grep = 0。即 A6 首半按 spec 字面 `≥2` 判 FAIL（实际 1），但 L210 已按 spec 第 3 条 old→new 逐字完成（`…99/100/101 纪律域` 已落盘，grep '99/100/101 纪律域' = 1 可证）。判定：编辑忠实于 spec old→new 映射，A6 的 `≥2` 阈值是 spec 侧 grep 字面与 L210 实际斜杠语境的口径误差，非 executor 改法偏差——主进程回归时若用 `grep -c ',100,101' ≥2` 判 FAIL 属 spec 阈值问题。
2. **F8 smart-merge-back.sh 旧措辞残留（spec 授权内不动，登记主进程裁决）**：`skills/task-planner/scripts/smart-merge-back.sh:99` 注释 `#   7 = MERGE_CONFLICT (merge 冲突, STOP 语义 — 不自动解决, 报告用户…)` 与 `:343` 运行输出 `echo "[V6] MERGE_CONFLICT: STOP — 冲突不自动解决, 报告用户" >&2` 仍保持旧「冲突=停等点」语义（脚本 exit 7 = 冲突原样上抛，不代解）。按 F8 只读约束未改该文件（也不在 7 文件编辑清单内）。此为脚本行为层与 Rule 101.2「冲突=收口义务（调用方逐条走 41.1 消解链）」的语义落差：脚本自身 STOP 语义不变是设计内保守边界（脚本不代解，义务在调用方 LLM 侧），是否需第三轮随动（更新 L99 注释口径/保持原样）交主进程裁决。selftest-*.sh 守卫对旧措辞零命中，无需随动。
3. old 字面失配（old 与 spec 不一致）：无——7 文件所有 old 片段均与磁盘实况逐字匹配（Rule 100 级联后现状），零最小同义修正。

### 最终结论
F1–F8 全部落盘完成，验收 1–8 PASS；A6 存在 spec 阈值口径误差 1 处（L210 斜杠语境）、A9 命中 smart-merge-back.sh 旧措辞 2 行（spec 授权不动、已登记待主进程裁决）、零 old 失配。未跑全量回归（主进程统一执行）。
