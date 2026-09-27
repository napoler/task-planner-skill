# 检查点 11 / code-assistant / S11 template-guide 计数三处修正

status: complete
commit: e5a402d (wt/task-v092-guard-quirk-fixes, 基线 35cd075)

## 执行记录
1. 读主仓 findings.md S4 节（含 Phase 4 修正指令 5 条字面值）
2. 实测三数（worktree）：templates/*.md=10、variant/*.md=15、grep 锚=22
3. Edit 4 处（≤12 行 diff 约束下合并 S4 指令 2/3）：
   - :60 §2.3 → 「5 核心 + 3 辅助 + 15 variant = 23 个模板；另有 knowledge-brief.md（第 6 计划文件）/shared-tracker.md（Rule 30 区块模板）不入此口径，templates/ 实际 25 个 .md」
   - :62 §2.4 标题 → 「22/25 个模板文件统一含 — mini-lite/knowledge-brief/shared-tracker 三者例外」
   - :66 验收 → 「应为 22；例外：knowledge-brief、shared-tracker、variant/mini-lite-type」
   - :67 task_plan 系 → 「主模板 + 15 variant，含锚 14——mini-lite 除外」（直接关联措辞，防 :62/:66 与 :67 矛盾）
   - :74 §2.5 → 「现为 22（= 25 − 3 无锚例外…）」（S4 指令 4 字面值 + 保持 knowledge-brief 不计入逻辑）
4. 验证：`grep -n "21 个\|应为 21\|维持 20"` rc=1 零残留；diff=单文件 5+/5-
5. 提交 e5a402d，worktree status 干净

## 偏离 S4 字面值说明
- S4 指令 2/3/4 合并执行（:62 标题与 :66 验收同属「统一标题条」相关措辞），总 diff 5 行 < 12 行上限
- S4 指令 1（:32 §2.2 表补两行）与指令 5（:69 脚本引用）不在本任务三处范围，未执行——:69 现状已由 S9 接库后描述为「默认形态/列限形态」，与 S4 预期接库形态一致，无需再改

## template-mapping.md 同型漂移（只登记不修，登记内容见主仓 findings.md S11 节）
- :26「13 类」、§六表缺 mini-lite-type/video-type 两行、:191 白名单注释 5 文件 vs 实 6

## 负结果/排除项
- 主仓 skills/ 零触碰；其他 worktree 零触碰
- 簿记写入：主仓 plans/task-v092-guard-quirk-fixes/ findings.md + progress.md + 本文件
