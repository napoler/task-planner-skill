# Knowledge Brief — task-v139（任务知识简略要点）

## §1 任务速览与核心概念
消除技能「遇简单障碍即推给用户」惰性根因：Rule 41.1 消解链前插「⓪ 直接修复」步骤；Rule 53.3 增补「明显可判判据」具体化条款。单文件（critical-rules.md）两处行内替换，worktree 隔离执行。

## §2 已验证关键事实
- Rule 41.1 现状（critical-rules.md:429 主仓/master 同步）：消解链五步①-⑤全为流程动作，缺「直接动手修」首步
- Rule 53.3 现状（L591）：有禁推诿原则，但判据抽象，具体场景无法对号入座
- worktree wt/task-v139 基于 master a86b8ba，目标两行已确认在位（grep 计数=2）
- 修改为纯行内插入，既有锚文本全保留，预期不破 selftest 锚（Phase 2 验证）

## §3 关键文件锚点表
| 文件 | 锚 | 用途 |
|------|-----|------|
| worktree critical-rules.md | 「消解优先原则」（41.1 行） | Step 1 替换定位 |
| worktree critical-rules.md | 「决策管辖二分」（53.3 行） | Step 2 替换定位 |
| 主仓 plans/task-v139/subagent-state/S1-executor.md | 检查点 | S1 里程碑落盘 |

## §4 易错点与禁止假设清单
- 禁止改动两目标行之外的任何行（41.x/53.x 相邻条款零触碰）
- 禁止在主仓直接改 skills/ 文件（只在 worktree 内操作）
- Edit old_string 必须从文件实读内容复制，禁止凭记忆构造（tab/全角括号差异会失配）

## §5 S-unit 材料包索引
- S1（executor）：修改 diff 全文内联于派发 prompt（Step 1/Step 2 精确替换指令）；检查点 subagent-state/S1-executor.md
