# 27-executor — task-v131 Phase 7 CR 修复 S-unit（A 批）

- 状态: done
- 范围: worktree /home/terry/task-planner-skill-worktrees/task-v131，仅 2 文件：
  `skills/task-planner/scripts/init-session.sh` + `skills/task-planner/scripts/attest-plan.sh`
- 依据: 26-code-reviewer P1-1 / P2-2 / P2-3；判例 knowledge-brief §4
- 未 commit（按任务要求）

## 1. P1-1（init-session.sh inject_requirement_block 无 Goal 回退 awk）

- 原 :154-186 awk 在 `{ }` 块内使用 pattern-action 混合形式（`$0 ~ /re/ { ... }`），gawk 5.2.1 / mawk 均报 syntax error → 命令替换吞错静默回落 insat=1 → 脚手架插文件顶破坏 frontmatter，且 fail-open WARN 永不触发。
- 修法：整体重写为顶层 if/else 语句链 + END；awk 失败时显式 `WARN → stderr` 再回落 insat=1（fail-open 语义保留，:185-191）。
- 注释修正：① 函数头 :98-99 原「无 Goal 行则插在文件头部注释块之后」表述不实（首行即正文时回落第 1 行亦属语义）→ 改为「头部块（空行/HTML 注释/frontmatter 定界）之后的首正文行之前；首行即正文时回落第 1 行」；② 删除 :158 错误前提注释「mawk 不支持 || &&」（实测 mawk 1.3.4 / gawk 5.2.1 均支持，原注释无实据且误导）。
- **过程中发现并修复 P1-1b（超出 CR 清单但同属本 awk 程序，属范围内缺陷）**：重写时按字面保留的闭行判定 `^-->[[:space:]]*$` 实测不匹配模板常见闭行形态 `     multi-line note -->`（--> 前带文本）→ cmt 永不复位 → 后续正文全被吞为「注释内部」→ last 滑到文件尾 → insat=文件行数+1 越界 → 脚手架静默丢失（实测 5 行文件 insat=6，注入行未出现但日志仍报「已插入」）。修法：闭行判定改为「行内含 -->」（自闭注释与多行闭行同命中，cmt 复位）。已注明原因/时间/原行为。

## 2. P2-2（attest-plan.sh R 行正则）

- `^- \*\*R[0-9]` → `^[[:space:]]*[-*][[:space:]]+\*\*R[0-9]`（接受缩进 + * 号列表项）；错误注释「同时覆盖宽松 **R1** 形态」改为如实描述；缺锚报错文案同步新正则。
- 位置: attest-plan.sh ① What 注释段 + 四锚 grep 段（约 :122-150）。

## 3. P2-3（attest-plan.sh 两锚升级标题行锚）

- 「R→VC 映射」: `grep -q 'R→VC 映射'` → `grep -qE '^#{2,3}.*R→VC 映射'`（##/### 标题行级，正文提及不再满足）。
- 「根源覆盖表」: `grep -q '根源覆盖表'` → `grep -qE '^##[^#].*根源覆盖表'`（仅 ## 级，排除 ### 及更深；正文提及不再满足）。
- 模板/注入脚手架/既有合规计划实测均匹配（bugfix 内置模板 init 生成物 + 6 selftest 夹具全过）。

## 验证证据

| 项 | 结果 |
|----|------|
| `bash -n` 两脚本 | 均 OK |
| /tmp 例 a（正文提及根源覆盖表无标题行 + 三锚齐） | attest rc=1，✗「🧮 根源覆盖表 ## 标题行缺失」拒锁（锚升级生效） |
| /tmp 例 b（缩进 `  - **R1**` + 四锚标题齐） | attest rc=0，[requirement-gate] OK（P2-2 放宽生效） |
| /tmp 例 c（无 Goal 行项目级模板=frontmatter 注释块+`## 其它标题`正文） | init rc=0，插入点=注释块后（首正文行 `## 其它标题` 之前），非第 1 行；双脚手架 21 行在位，WARN=0（P1-1+P1-1b 生效） |
| 回归抽查（bugfix 内置模板无 Goal 行） | init rc=0，插入于 `## Goal`…实为插入于 frontmatter 后首正文行前（`## Goal` 缺失走回退），WARN=0 |
| selftest 六项 | root-resolution 15/15、active-plan 19/19、execution-stability 19/19、methodology 16/16、plan-dispatch 12/12、final-gate-hash 22/22 全 PASS，夹具零修改 |

## 负结果 / 已排除

- 未触碰 2 文件以外任何文件（selftest 夹具因六项全过无需修改，越界分支未触发）。
- 未 commit；worktree 工作区保持 dirty（2 文件变更），交主仓合并合约处理。
- 全角括号/既有历史计划锚匹配：final-gate-hash 22/22 与 root-resolution RR-14（「第 4 锚」=7≥1、[requirement-gate]=2≥2）实测不受影响。

## 恢复点

若后续发现 P1-1b 闭行判定影响 frontmatter `---` 定界场景（当前实测无），回滚锚=init-session.sh :162-191 awk 段。
