# task-v168 Phase 4 CR 修复轮检查点（code-assistant 子代理）

工作目录: /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation

## F1 [BLOCKER] selftest 钉值演进 — DONE
- selftest-error-loop.sh:62-70（现 61-70 区域）: EL-12 断言 `default=='warn'`→`'enforce'`，ok/bad 消息同步改「enforce 默认+三档」「缺失/默认非 enforce」，断言行上方加 Rule 45 注释 `[2026-10-11 task-v168 设置层] error_loop_enforce 默认值 warn→enforce（用户 piv⊙ 设置修复），本钉同步演进；禁回退 warn。` + 原文注记；头部注释 EL-12 行同步
- selftest-reflect-verify.sh:45-50（现 45-50 区域）: RV-08 断言 `.default=="warn"`→`"enforce"`，ok/bad 消息同步，同款 Rule 45 注释（键名 reflect_verify_enforce）+ 原文注记；头部注释 RV-08 行同步
- 实证: `bash selftest-error-loop.sh` → Total: 16 PASS=16 FAIL=0, exit 0; `bash selftest-reflect-verify.sh` → Total: 12 PASS=12 FAIL=0, exit 0

## F2 [MAJOR] 31.1⑤ 收窄 — DONE
- critical-rules.md:322: ⑤ 子条改「预期成功的动作实际失败」口径，豁免「良性非零退出（grep 无匹配/test 判定假/预期内非零码）不触发」；既有 Rule 45 注记后追加 `[2026-10-11 task-v168 CR 修复轮] ⑤ 收窄…原因=CR MAJOR-1 过宽触发告警疲劳`
- grep「预期成功的动作实际失败」=1; grep「良性非零退出」=1; EL-01 锚「重复反馈」计数=1 未破坏

## F3 [MAJOR] Learning Gate off-by-one + 模板行误挡 — DONE
- check-complete.sh lg_bad_awk（:1156 起）: ① cell 读 a[c]（Root Cause）+ a[c+1]（Prevention）双列校验（任一为空/`<待沉淀>`/`待沉淀` 即 bad）；② 模板占位行按 lg_tpl_awk 同款模式 `^\|[[:space:]]*\|[[:space:]]*\|[[:space:]]*1[[:space:]]*\|` 豁免 next；③ awk 上方 Rule 45 注释注明修改原因/时间/原行为（原=c+1 单列读 Prevention、原=模板行未豁免）；rc_col 表头识别逻辑未动
- --test 用法确认: 脚本无 --test 选项，无 plan 文件时安全 no-op（exit 0，实证 PASS）
- fixture 实证（/tmp/cr-fx/{A,B,C}，enforce 档 env TASK_PLANNER_ERROR_LOOP_ENFORCE=enforce，余门 off）:
  - A（模板行+1 真实行双列已填）→ exit 0, `[plan] LEARNING-GATE PASSED`
  - B（真实行 Root Cause 已填/Prevention=`<待沉淀>`）→ exit 1, `LEARNING-GATE FAILED … 行 11`（含行号）
  - C（仅模板占位行）→ exit 0, PASSED 静默不阻断
  - fixture 已清理（rm -rf /tmp/cr-fx）
- 回归: selftest-final-gate-hash.sh exit 0（门控 hash 键未破）

## F4 [MINOR] 动作相关性三问 2.5c 编号 — DONE
- SKILL.md:92: bullet `- **动作相关性三问…` → `2.5c **动作相关性三问（每动作前默念）**：…`（与 2.5b 同级 2 空格缩进，位置在 2.5b 之后、2.6 之前不变，正文零改动）
- grep「2.5c **动作相关性三问」=1

## F5 [NIT] 31.1⑤↔22.3 交叉引用 — DONE
- critical-rules.md:322 ⑤ 子条末尾追加「（与 Rule 22.3 兜底链次序：执行期信号先按本条记 31 链留痕，provider/子代理失败换道以 22.3 为主，两条链并行不互斥）」
- grep「与 Rule 22.3 兜底链次序」=1

## 最终结论
5/5 修复项全部闭环。git status 仅含 5 个规格文件（SKILL.md / critical-rules.md / check-complete.sh / selftest-error-loop.sh / selftest-reflect-verify.sh），无规格外改动。
status: done; acceptance: 6/6 pass; confidence: HIGH。
