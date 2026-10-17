# S1 任务书 — 80.7 条款与 SKILL 指针（task-v186）

## 编辑 1：核心规则文件追加 80.7
文件：`<worktree>/skills/task-planner/references/critical-rules.md`
- Read 该文件 Rule 80 段（约 :129-146）：80.6 行（以 `80.6 **守护机制` 开头）之后、`<!-- [2026-10-12 task-v170 S4 追加]` 注释行之前。
- 用 Edit 在 80.6 行之后插入：一个空行 + 下面这段全文（逐字，禁改一字）：

```
80.7 **理解镜像（模型理解同步记录，task-v186）**：主进程在每条逐字条目落盘的同一动作中，紧随其后追加一条同号配对的「理解镜像」块（格式 `### #N 理解镜像 | 日期`，口径源=templates/user-session-log.md）——内容=模型当时对该条用户请求的整理理解，要点化 ≤10 行（任务对象/范围边界/验收期望/约束假设择要有；琐碎消息可一行）。**定位与约束（四条）**：① 镜像=非权威对照面，唯一用途=回溯时与逐字原文对照、定位错误是否源于理解偏差（判例锚=plans/task-v186-understanding-mirror/user-session-log.md #1）；与逐字原文冲突一律以逐字原文为准（80.4 权威序延伸），禁以镜像改写需求、禁替代 R 行逐字锚（Rule 51.1 不受影响）；② append-only 同 80.2——理解事后演进时追加「### #N 理解镜像更正 | 日期」新块（注明改判要点与依据），禁改旧镜像一字；③ 写入者=主进程单写（80.3 同面），子代理只读；④ 逐字条目与镜像块一对一配对（同编号），禁只录其一。**机制（文本优先 L0-T——对齐 86.7/89.6/90.6/92.7 范式）**：判定面=LLM 行为+模板格式锚，零新增守护脚本/零新 config 键（selftest-session-log.sh SL 断言面不扩——机器化 opt-in，仅用户显式要求才建）；首例 dogfood=task-v186 自身专档。
```

## 编辑 2：SKILL.md Rule 80 指针行
文件：`<worktree>/skills/task-planner/SKILL.md`（约 :188）
- old：`- **Rule 80 用户会话逐字记录**：user-session-log.md append-only 只写不改；恢复先读专档`
- new：`- **Rule 80 用户会话逐字记录**：user-session-log.md append-only 只写不改；恢复先读专档；每条逐字后同号配对理解镜像（80.7，非权威对照面）`

## 编辑 3：SKILL.md G9 合规行
同文件（约 :126），在 G9 行的 `会话恢复先读专档再读 task_plan.md（80.4）` 之后、`（机器面=` 之前插入 `；理解镜像已同号配对（80.7）`——即把 `（80.4）（机器面=` 改为 `（80.4）；理解镜像已同号配对（80.7）（机器面=`（仅此一处，勿动行内其他文字）。

## 自验（worktree 根）
- `grep -c "^80.7 \*\*理解镜像" skills/task-planner/references/critical-rules.md` =1
- `grep -c "理解镜像" skills/task-planner/SKILL.md` ≥2
- `grep -c "80.8\|80\.9" skills/task-planner/references/critical-rules.md` =0（未越界新增）

## 检查点
Write `/mnt/data/dev/task-planner-skill/plans/task-v186-understanding-mirror/subagent-state/2-s1-executor.md`（status+各 grep 原始输出+改动处数）。old_string 不匹配→STOP 记录实际字面，禁猜改。
