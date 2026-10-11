# 26-code-reviewer — task-v131/Phase 7 Code Review Gate（重 diff 全量审查）

- 状态: done
- 审查对象: worktree /home/terry/task-planner-skill-worktrees/task-v131（branch wt/task-v131）相对 master 全量 diff（7 commit，25 文件 +624/-55）
- 判定: CHANGES_REQUESTED（2×P1，其余 P2/advisory）
- 只读审查，未改任何被审文件

## 结论摘要
| 级别 | 位置 | 标题 |
|------|------|------|
| P1 | scripts/init-session.sh:154-186 | awk 无 Goal 回退程序语法非法（gawk/mawk 均 setence error）→ 静默置 insat=1 插文件顶（破 frontmatter），且与函数头/fail-open 文档不符 |
| P1 | SKILL.md:266 | VC-4 声称「:251 索引修正（含补 Rule 50）」未落地：该行仍 `含 Rule 40/.../49/51`，缺 50/52/53，且未在 diff 中改动 |
| P2 | selftest-agent-coverage.sh:196-207 | AC-09 精确行数锚 =128 与 skill-split 的 `-le` 上界惯例不一致，易漂移 |
| P2 | scripts/attest-plan.sh:123-146 | R 行正则 `^- \*\*R[0-9]` 只认行首非缩进形态；注释自称覆盖「宽松 `**R1**`」不实 |
| P2 | attest-plan.sh:140-146 / init-session.sh:118-120 | 锚级 grep 子串判定可被「正文提及」满足（设计如此，弱化项，已在 CR 提示） |
| P2 | references/critical-rules.md 45.7 | 死路径改指 plans/task-v111/progress.md（存在且确载存量清单摘要），合规但「清单登记处」口径偏松 |

## 证据（原文引用）
1. init-session.sh:161 `$0 ~ /^[[:space:]]*$/ || $0 ~ /^---$/ { last=FNR; next }` 位于 `{ ... }` 规则块内 → gawk 5.2.1 / mawk 1.3.4 均报 `syntax error`；实测 `awk '{ $0 ~ /a/ { print } }'` 亦非法（块内不可用 pattern-action 形式）；函数头 :99 声明「无 Goal 行则插在文件头部注释块之后」、:158 声明「mawk 不支持 || &&」均为不实前提。定位: `/home/terry/task-planner-skill-worktrees/task-v131/skills/task-planner/scripts/init-session.sh:154-186`。
2. SKILL.md:266 （master :251 同文，diff 中为 context 行未改）。
3. run: selftest-root-resolution 15/15、requirement-coverage 15/15、agent-coverage 9/9、skill-split 41/41、registry 5/5 全绿。
4. attest 正例 rc=0 / 缺锚负例 rc=1 / mini 豁免 rc=0 三态实测符合基线。
5. check-dispatch advisory（:411-419）经代码路径核对：仅 echo stderr，不改 $hits/不改 exit → 不阻断成立。

## 负结果/已排除
- 全角括号历史判例：attest 四锚门 grep 均为「前缀/子串」判定（非行尾锚定），全角尾随字符不误伤（实测正例 rc=0）。
- 纯增量纪律（36.5）：critical-rules 既有规则语义未被覆盖改写；Rule 16 措辞修（35→35/39）系事实修正且计划已授权，实测 35/39 属实；45.7 死路径修法经 `git log -S` + 文件存在性双验为真。
- 幂等：inject_requirement_block 双跑锚数不增（实测 req=1/cover=2 稳定）。
- registry T02 双向核对通过（51/51）。
- ARCHITECTURE 数字实测吻合（references 9 / templates 10+29 / scripts 90 / lib 6）。
- 后端无 SQL/网络/认证面，无注入类漏洞面。

## R1-R7 载体闭环（抽样）
- R1/R4/R5→Rule 53.1/53.2 + 根源覆盖表（模板/init/attest 四锚）在位；R2→51.1 计划侧载体双机制在位；R3/R7→53.3 管辖二分在位；R6→53.4 返工核算在位。载体三选一（机制/守卫/载体）对 53.x 成立；唯 P1-2 索引行未随 Rule 53 同步=级联漏改。

---

## 复审轮（task-v131/Phase 7 CR Gate 复审）— 终判 APPROVED

- 复审对象: commit 5308130（CR-fix）+ f196689（级联锚演进），worktree wt/task-v131，git status 干净。
- 变更文件（7，均在计划 scope 内）: SKILL.md / scripts/attest-plan.sh / scripts/init-session.sh / scripts/selftest-agent-coverage.sh / scripts/selftest-root-resolution.sh / scripts/selftest-reliability-institution.sh / scripts/selftest-self-resolution.sh。

### 原发现逐条复核
| 原发现 | 结论 | 证据 |
|--------|------|------|
| P1-1 init 无-Goal 回退 awk 语法非法 | **已修复** | 830 行程序重写为顶层 if/else+END；`gawk -f prog2.awk` / `mawk -f prog2.awk` 均 rc=0；`bash -n init-session.sh` OK；端到端：无 Goal+frontmatter 文件插入点=注释块后（非第 1 行，frontmatter 完整保留）；首行即正文回落第 1 行 |
| P1-1b 闭行判定 `^-->$` 漏配 `note -->` 致越界 | **已修复** | 闭行改 `if ($0 ~ /-->/)`；实测含 `note -->` 文件 insat 正确（不再滑到文件尾）；自闭注释 `<!-- header -->` 首行文件插入点=第 2 行（正确） |
| P1-1 fail-open WARN 永不触发 | **已修复** | 模拟 awk 失败（shadow 函数）实测 stderr 两条 WARN 均打印，rc=0 不阻断 |
| P1-2 SKILL:266 括注缺 50/52/53 | **已修复** | :266 = 「（含 Rule 40-53 全集）」；新增 RR-16（索引行防级联漏改，含兜底判定）+ RR-17（critical-rules ^### 53 区块锚）；级联 R-09/SR-08 断言（selftest-reliability-institution/self-resolution）随括注同步演进 |
| P2-1 AC-09 精确锚易漂移 | **已修复** | 改 `[ -n "$ml" ] && [ "$ml" -le 128 ]` 上界+空值防护，注释如实（内容完整性交 AC-05） |
| P2-2 R 行正则注释不实 | **已修复** | 放宽 `^[[:space:]]*[-*][[:space:]]+\*\*R[0-9]`；实测缩进 `- **R1**` 与 `* **R2**` 列表项均通过 |
| P2-3 锚级 grep 弱化 | **已修复** | R→VC 升 `^#{2,3}.*R→VC 映射`、根源覆盖表升 `^##[^#].*根源覆盖表`；实测纯正文提及「根源覆盖表」无标题 → 拒锁 rc=1（有效收紧） |
| P2-4 + Nit×2 | 登记接受（诚实载体，口径 Nit 无碍） | 无新动作需求 |

### 新发现（复审轮）— 均非阻断
- 💬 Nit [可用性] `attest-plan.sh` R→VC 标题锚 `^#{2,3}` 不认 `####`（4 级）标题；模板块/注入脚手架均用 `###`，无实害。置信度 HIGH。
- 💬 Nit [潜在边界] init 对「YAML frontmatter（`---` + 内容行）+ 无 Goal」文件插入点为第 2 行（`---` 视为头部后）。模板族全用 HTML 注释标记（实测 39 模板零 YAML FM），无实害。置信度 MEDIUM。

### 独立回归复核（VC-5 铁律：不采信自报）
- 独立逐脚本求和（Total: 行 51 脚本）= PASS_sum 748 + selftest-final-gate-hash 特格式 PASS=22 = **770 PASS / 0 FAIL**，与主进程自报一致；51/51 脚本 rc=0，failed_scripts 空。
- 定点复跑：root-resolution 17/17、reliability-institution 12/12、self-resolution 13/13、agent-coverage 9/9、requirement-coverage 15/15、skill-split 41/41、registry 5/5（双向 51/51）。
- 端到端闭环：`init-session.sh demo research`（变体零载体）→ 注入双区块 → 新收紧四锚门 `attest` rc=0（生成面→锁定面全链 0 误伤）。
- 真实计划面：全部历史 plans 已锁定不受追溯影响；唯一在途 task-v131 计划四锚全过；新收紧锚不误伤在途计划（F3 风险未发生）。
- 全角/缩进/星号/空文件/无 Goal/多行注释 七类边界实测无阻断性缺陷。

终判：**APPROVED**（P0/P1 全清；P2 全处置；仅 2 项 Nit 无实害，不影响合并）。
