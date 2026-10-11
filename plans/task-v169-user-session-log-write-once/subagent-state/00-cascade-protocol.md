# Epoch Cascade Protocol — task-v169 Phase 4 级联单元共用协议

> 本文件为 Phase 4 全部级联单元的共用协议（Rule 35.3 落盘范式）。每个级联单元的任务书引用本协议；执行者首动作=Read 本协议全文 + 本单元任务书全文。
> 范围声明：本协议只覆盖单个级联单元；一个单元=一次派发=一个新检查点，禁批次追加（Rule 46.1）。

## 为什么有这批级联（背景）
task-v169 把 Rule 80 落地进 references/critical-rules.md 并使 SKILL.md 的 Critical Rules 全集索引由 1-76 演进为 1-80。仓内 11+ 个 selftest 用「epoch 宽容锚」断言 SKILL.md 的编号形态（如 `'Critical Rules 1-7[4-9]'`、`40-[567][0-9]`、`Rules 1-(3[1-9]|[4-7][0-9])`），这些锚设计上随编号演进扩展；不扩展则 dry-run 全量回归 FAIL（task-v169 实测 19 FAIL，其中 18 个由锚不覆盖 1-80 触发）。本批单元=把锚扩展到覆盖 1-80 纪元，属机械同步，非功能变更。

## 通用改法（锚扩展映射表）
| 旧锚形态 | 新锚形态 | 说明 |
|----------|----------|------|
| `1-7[4-9]` | `1-[7-8][0-9]` | 覆盖 1-70..1-89（含 1-74..1-79 历史纪元与 1-80） |
| `1-7[0-9]` | `1-[7-8][0-9]` | 同上 |
| `40-[567][0-9]` | `40-[5-8][0-9]` | 覆盖 40-50..40-89（SKILL.md 实态=40-80 全集 ×1） |
| `40-[4567][0-9]` | `40-[4-8][0-9]` | 同上加 40-4x |
| `Rules 1-(3[1-9]` 接竖线并列 `[4-7][0-9])` 的末段 | `[4-8][0-9]` | 3x..8x 全纪元（竖线=ERE 或运算符） |
| ERE 交替集（形如 69、71、7[4-9] 等成员用竖线并列的集合） | 在竖线并列集合的末尾追加成员 80 | 例：`(69、71、7[4-9])` 改为 `(69、71、7[4-9]、80)`；此处竖线=ERE 或运算符，非表格分隔符 |

改法纪律：
- 锚改写必须同时覆盖该脚本内**所有出现位置**：grep 命令字面、ok/bad 消息字面、注释里的锚说明（消息与注释不同步会造成自相矛盾宣告）
- 新锚必须能匹配 SKILL.md 现实文本（`1-80`、`40-80 全集`）；改完必须实跑该脚本验证 PASS，禁止只改不跑
- 禁改断言阈值语义（≥N/=N 不变）、禁改被守护文件（SKILL.md/critical-rules.md 等本体一律不动）、禁改其他 selftest 脚本
- 注释按 Rule 45 追加一行演进记录（task-v169 + 旧锚→新锚理由），对齐该脚本既有演进注释风格

## 通用验收（每个单元都过）
1. 改动脚本 `bash <脚本路径>` 独立跑 PASS（FAIL=0）
2. `bash -n <脚本路径>` 语法通过
3. `git diff --numstat <脚本路径>` 删除行=0（只允许原地替换+注释增行；若 Edison 工具把替换计为 -1/+1，需逐行核对删除行均为替换对旧行）
4. 未触碰守护对象本体与其他 selftest（git status 仅限本单元两个文件以内的改动）

## 工作根与禁改面
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once
- 禁改：SKILL.md、references/critical-rules.md、templates/**、config.json、scripts/check-complete.sh、scripts/init-session.sh、scripts/selftest-registry.tsv、其他 selftest 脚本、plans/task-v168-session-anchor-skill-activation/ 任何文件、~/.zcode/skills/**
- 禁操作：git 写操作、切换分支、删除文件
- 需求锚：本单元=纯机械同步单元，写「不适用（纯机械单元）」即可（Rule 51.1a 豁免口径）

## 粒度与预算
- 每单元粒度 token 以各单元任务书为准（≤2f/100l/15min）；超时立即返回 partial

## 返回与检查点
- 检查点：各单元任务书指定路径；纪律=每完成一文件 Edit 追加带时间戳里程碑行，结束写「最终结论」段（同 8 字段块）置 status: done，受阻写「错误与受阻」段置 status: failed
- 返回格式=派发 prompt 第 7 节 8 字段（status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence），8 字段之后禁任何内容
- 防幻觉契约适用：全部事实性输出带 file:line 或命令原文锚；禁无来源具体化
