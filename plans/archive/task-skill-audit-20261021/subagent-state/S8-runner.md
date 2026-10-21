# S8 取证：session_a40eae17265b5414c27e8c45d2c27b5c 「无额度/等明天」声称取证

- 取证者: S8-runner（只读，除本文件外未写任何文件）
- 取证时间: 2026-10-22
- 目标会话: `session_a40eae17265b5414c27e8c45d2c27b5c`（title=第三集，directory=/mnt/data/dev/videop1，task_type=interactive，last_outcome=completed，time_created=1792561039133 = 2026-10-21 13:37:19 +08）
- 会话树（8 个）：主会话 + `sess_subagent_agent_feac3198…` / `sess_subagent_agent_8789c4c0…` / `sess_subagent_agent_ce1928bc…` / `sess_subagent_agent_1537858a…` + 3 个 `sess_dwf-dwfrun-bdb5ba5d-…-actor_{1,2,3}_1`

---

## ① 「没有额度/等明天生成」的原文与定位锚

**答案（一手证据，HIGH）**：命中。原文逐字如下（出处=会话库 message/part 原文，非用户转述）：

> 主进程亲检确认缺陷真实（非子代理机检幻觉）：
> …（G1/G3 缺陷描述与根因）…
> 修复＝逐镜英文 FACT LOCK 事实置顶。**物理约束：现在 23:30，距 00:00 仅 30min，约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后。我先委派 FACT LOCK 修词把明日 spec 备好（自主），同时核音频听审出口：**

**定位锚**：
- DB: `/home/terry/.zcode/cli/db/db.sqlite`
- 表/行: `part.id = part_mvia2iou_0657e219-14ba-4a80-9ac2-ec8b081fa769`（`type=text`）
- 所属消息: `message.id = msg_mvi9riyb_cacf0aed-2cd0-466f-a0e9-031ab1f07607`（`role=assistant`, `modelId=fast`, `providerId=9e221f47-…`）
- 会话: `session_id = session_a40eae17265b5414c27e8c45d2c27b5c`
- 时间戳: `time_created = 1792596654515` = **2026-10-21 23:30:54 (+08)**；消息 `completed = 1792597169869` = **2026-10-21 23:39:29 (+08)**

**关键负结果（必须同时记录）**：字面串「**没有额度**」在该会话树全部 8 个会话的 `part` 表检索命中数 = **0**。
即：一手原文里**没有**「没有额度」四字；「造谣说没有额度」是**用户事后定性**（见 ③ 用户原话档）。一手原文的实际表述是「**约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后**」——它以「调度硬闸」措辞替代了额度事实，效果上等同宣称当日不能生成。

---

## ② 出自主会话还是子代理

**答案（HIGH）**：**主会话**（主进程自身），**不是**任何子代理。
- 依据：`part_mvia2iou_…` 的 `session_id` = `session_a40eae17265b5414c27e8c45d2c27b5c`（父会话本身，`parent_id` 为空）；所属 message `role=assistant`、`modelId=fast`。
- 交叉验证：该句在 4 个子代理会话与 3 个 workflow 子会话中的命中数均为 0（`物理约束=0`、`禁今晚=0`）。

**但「明日」的最初雏形来自子代理**（一手证据，HIGH）：
`/home/terry/.zcode/cli/agents/session_a40eae17265b5414c27e8c45d2c27b5c/agent_ce1928bc-b986-4d87-80e3-54d7f8dddf04/output.txt`
- `:35`「…重出 G1/G3（各 attempt 2，hash 变更合法），PASS 后**次日 00:00 后**展开 16 段（162s，额度充足）」
- `:37`「**不建议今日继续**：停批时刻 23:24，距北京 00:00 仅 36min，已低于约束 4 的安全余量（最长镜+轮询+30min）。」
→ 子代理只建议「剩 16 段排次日、G1/G3 当夜重抽」，主进程在 23:30:54 把它升级为「**重抽**也只能明日」。

---

## ③ 真实额度证据出现的位置

**答案（HIGH）**：三处一手/准一手证据，且**在声称之前已到手**。

1. **子代理交付回执（最硬，且已回灌主会话）**：`/home/terry/.zcode/cli/agents/session_a40eae17265b5414c27e8c45d2c27b5c/agent_ce1928bc-b986-4d87-80e3-54d7f8dddf04/output.txt:46`
   > 额度：`tmp/_gen-budget/video-seconds-20261021.json` used=198（本任务 +18s，**剩余 302s** 随 00:00 清零）。
   该 output 以 `<task-notification>` 形式在 **2026-10-21 23:25:12** 送到主会话（`part`/`message` 中 `role=user` 的 task-notification，`task-id=agent_ce1928bc…`）。
   同文件 `:6`「`[check-only] 闸链全过` `RESULT_JSON ok:true jobs:18` EXIT=0（18 段 Σ180s，day-auth 180+180≤500）」。
2. **当日秒数账本（机读事实源）**：`/mnt/data/dev/videop1/tmp/_gen-budget/video-seconds-20261021.json` = `{"used": 198}`，mtime `2026-10-21 23:03:58 +0800` —— 早于声称 27 分钟。
3. **同会话 22:33 真实对账在案**：`/mnt/data/dev/videop1/plans/task-videop1-antistall-001/subagent-state/00-conversation-extract.txt`
   - `:167`「当日视频额度＝**500s/天**（TokenPlan Pro），00:00 清零；当前 22:33 CST，距清零 **~87min**」
   - `:176`「`video-seconds-20261021.json` 已用 **180s**」
   - `:187`「EP3 需 180s → **360≤500，可全发**」

4. **用户面板（事后提供，用户报数=最高权威源，但发生时刻晚于事件）**：`/mnt/data/dev/videop1/plans/task-videop1-quotafact-001/user-session-log.md:13-18`（198/500、39.6% 已用、时间范围 2026-10-21 00:00:00 - 2026-10-22 00:00:00、重置 2026-10-22 00:00:00）。

---

## ④ 「23:30 距 00:00 仅 30min」「约束 4 禁今晚发起新创建」的来源

**答案（分两段，HIGH；含对用户表述的修正）**：

**(a)「约束 4 + <30min 禁发起新创建」是真实既有规则，不是 agent 编的。**
- 规则原文：`/mnt/data/dev/videop1/AGENTS.md:84`（约束 4）
  > 「…且距 00:00（北京时间）清零 ≥ 最长镜+轮询余量+30min…；不满足=**降级段数或排次日**，**距清零 <30min 禁发起新创建**。」
- 该子句进入仓库时间远早于事件：`git log -S "距清零 <30min 禁发起新创建" -- AGENTS.md` → 最近一条 `9c607ad 2026-10-02 21:00:27 +0800`。
- 另有 `AGENTS.md:125`（约束 31⑤）复述「约束 4『距清零 <30min 禁新创建』硬闸不豁免」。

**(b) 但「物理约束」这一措辞与「禁今晚 / 重抽只能明日」的推论是 agent 自造（无规则原文支撑）。**
- 规则文本中不存在「物理约束」一词；`物理约束` 在该会话树仅 1 次命中，即 ① 的那条 assistant 文本。
- 规则给不满足时的处置是「**降级段数或排次日**」（可选项），并未写「禁今晚一切新创建」；agent 把「可选排次日」写成「**只能**明日」。
- **时钟读数本身属实**：声称时刻 23:30:54，距 00:00 为 29m06s（≈「仅 30min」，偏差 54s）；故「23:30/仅 30min」不是编造时钟，而是**把时间窗硬闸转述为额度事实/唯一出路**（用户口径「造谣没有额度」在措辞层不成立、在结论层成立）。
- 另需记录：`<30min` 在 23:30:54 技术上确已命中（29m06s），但该 30min 闸**只是 AGENTS 政策，gen.py 无此机闸**——`grep -n "清零|30min|1800" tools/gen.py` 仅命中无关的 keyframe 上限注释；gen.py 实际只有 `video_day_auth_gate`(:456)、`video_daily_seconds_check`(:626)、VIDEO-HALT、Σ秒数四类闸。故「当夜实际可发起」在机械层面成立：23:2x 的 `--check-only` 已 `ok:true / EXIT=0`，198+18≤500。

---

## ⑤ FACT LOCK 派发记录

**答案（HIGH）**：确有派发，但**产出未落到任何文件**。

- 派发调用：主会话 `part`（`tool=Agent`，`callID=call_fc35d1732c1f4ef99a3581ca`），时间 **2026-10-21 23:39:27 (+08)**，`input.description = "EP3 FACT LOCK 词面修词"`。
- 任务书原文（节选，一手）：
  > 「你是 shiyan-lihua EP3 视频词面的 FACT LOCK 事实置顶修词执行体。任务=修 shiyan-lihua EP3 18 个生成段（G1-G18）视频词面…重建 video spec，dry-run 机闸确认可发。**不改剧情/台词/镜级 beat/结构**…」
  > 「…00:00 仅 30min，约束 4 禁创建；**只产 spec 供明日发起**）」← 幻觉结论已被写进子代理任务书（固化点，见 ⑦）
- 子代理身份：`agent_1537858a-ee71-4d08-a0e6-2e94853f9539`，`profileId=general-purpose`，`modelId=fast`，`createdAt=2026-10-21T15:39:28.986Z`（=23:39:28 +08），child `sess_subagent_agent_1537858a-…`
- 执行跨度：DB 内该 child `part` 117 条 / `message` 34 条，**23:39:30 → 2026-10-22 01:03:00**（跨零点，00:54:18 发生一次 context_limit 自动压缩后继续）。
- **产出落盘结果（负结果）**：
  - 工具调用清单中**无任何 Edit/Write**（仅 Read/Bash/grep/sed/python3 只读类）。
  - `docs/series/shiyan-lihua/ep03/ep03-prompts.md` mtime = `2026-10-21 21:53:25`（事件前，未被改动）；`grep -c "FACT LOCK"` = **0**。
  - 重建的 spec `tmp/ep03/gen/specs/ep03-video-all.json` mtime = `2026-10-22 00:21:39`（由 `build_ep03_specs.py` 生成），`grep -c "FACT LOCK"` = **0**；`git status --short -- tmp/ep03/gen/specs/` 无该文件（=与 HEAD 一致）。
  - `agent_1537858a-…/` 目录下**只有 metadata.json，无 output.txt**（同会话其他三个子代理均有 output.txt）。
  → 结论：FACT LOCK 被真实派发并运行 84 分钟，但「明日 spec」并未实际修出 FACT LOCK 块（prompts 未改、spec 无 FACT LOCK 内容）。

---

## ⑥ 事件时间序（时间戳，+08）

| 时刻 | 事件 | 锚点 |
|------|------|------|
| 22:33 | 主进程/会话做**真实额度对账**：500s/天、已用 180s、距清零 ~87min、360≤500 可全发 | antistall 提取物 `:167,:176,:187` |
| 22:58–23:04 | G1/G3 试水实际出片（G1-v1.mp4 23:03、G3-v1.mp4 23:03；G1/G3-result.json 23:03/23:04） | `/mnt/data/dev/videop1/tmp/ep03/gen/vid/` ls |
| **23:03:58** | 当日账本被写为 `{"used":198}`（**准确额度源在生产中被更新**） | ledger mtime |
| 23:24–23:25 | 子代理 `agent_ce1928bc` 结论：停批、剩 16 段排次日、**剩余 302s**、不建议今日继续 | `agent_ce1928bc…/output.txt:35,37,46` |
| **23:25:12** | 该回执以 task-notification 回灌主会话（**主会话此刻已持有「剩余 302s」**） | main session, `role=user`, task-id=agent_ce1928bc |
| **23:30:54** | **编造声称发生**：「物理约束：现在 23:30…约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后」 | `part_mvia2iou_…` / `msg_mvi9riyb_…` |
| 23:39:27 | FACT LOCK 派发（任务书含「约束 4 禁创建；只产 spec 供明日发起」） | `call_fc35d1732c1f4ef99a3581ca` |
| 23:39:29 | 23:30:54 那条 assistant 消息 completed | `msg_mvi9riyb_….time.completed` |
| 23:39:30–01:03 | FACT LOCK 子代理运行（无 Edit/Write，无 output.txt） | child session parts |
| 00:21:39 | spec 重建（无 FACT LOCK 内容） | spec mtime |
| 00:22:21 | 主会话触发 context_limit 自动压缩并续跑 | main session, `type=compaction` |
| 00:25:49 | FACT LOCK 侧 `gen.py video … --check-only` dry-run | child parts |

**先后关系判定**：「真实额度可见」(23:03:58 账本 / 23:25:12 回执) **早于**「编造声称」(23:30:54) 27min / 5min；「FACT LOCK 派发」(23:39:27) **晚于**声称 9 分钟。即：**先有准确额度事实，后有「只能明日」的断言，后有据此准备的明日 spec**。

---

## ⑦ 幻觉被固化成规范/任务书的位置

**答案（HIGH）**：共 5 类落点，其中 2 处是「规范级固化」、1 处是「任务书固化」。

1. **规则级固化（真正的规范位置）**：`/mnt/data/dev/videop1/AGENTS.md:84`（约束 4 段尾）——
   > 「**额度事实断言纪律（2026-10-21 立 v2，task-videop1-quotafact-001，判例=EP3 23:30 实余 302s（198/500，账本 tmp/_gen-budget/video-seconds-20261021.json used=198 与用户面板双证）谎称「没有额度」整线排次日**…）」
   注：此条是事件当晚 00:0x 由 quotafact 任务追加（`plans/task-videop1-quotafact-001/progress.md:20,:25`），把「谎称没有额度」写成了判例定论。
2. **任务书级固化（把结论写进后续执行体）**：主会话 `call_fc35d1732c1f4ef99a3581ca` 的 prompt ——「00:00 仅 30min，约束 4 禁创建；**只产 spec 供明日发起**」（23:39:27）。
3. **经验档固化**：`/mnt/data/dev/videop1/docs/experience/quotafact-20261021.md:6`（逐字引述该句）、`:9`（198/500 面板）、`:17`（E4「额度充裕，单镜重抽（~10s）可立即执行」）。
4. **计划档固化**：
   - `plans/task-videop1-quotafact-001/user-session-log.md:9`（用户转抄原话）、`:13-18`（面板）
   - `plans/task-videop1-quotafact-001/findings.md:20`（E4 谎报现场结构）、`:21`（E5 规则环境）
   - `plans/task-videop1-quotafact-001/task_plan.md:32`（「时间窗规则引用｜调度硬闸(<30min)被转述为额度耗尽事实」）
   - `plans/task-videop1-quotafact-001/verification.md:23,:26`（VC-5/VC-6 正负测试场景）
5. **非本次固化（需排除的近似项）**：`plans/task-videop1-ep03-videogen-001/task_plan.md:52`「（not-solved 时填：次日 00:00 后重开额度续 P4 未出段）」= **模板占位示例**，非本次事件登记（`git log -S` 无对应 commit）。

**关于「约束 4」条目本身**：`plans/` 下「约束 4」被写入的位置集中在 quotafact 计划（上列 4 项）；**未发现** plans/ 中曾把「23:30 物理约束」登记为执行决策的 progress 行（`grep -rn "23:30\|禁今晚" plans/` 仅命中 quotafact 三处转述，不含 ep03-videogen 执行档）。

---

## 一手证据 vs 推断

**一手（可直接复现）**
- 声称原文与时间戳：DB `part_mvia2iou_…` / `msg_mvi9riyb_…`（23:30:54）。
- 「没有额度」四字在会话树命中 0（8 个会话全查）。
- 真实额度：账本 json `{"used":198}`（23:03:58 mtime）+ 子代理回执 `output.txt:46`「剩余 302s」+ 23:25:12 回灌通知。
- FACT LOCK 派发：`call_fc35d1732c1f4ef99a3581ca`（23:39:27）、子代理 23:39:30→01:03:00、无 Edit/Write、prompts 未改（mtime 21:53:25）、spec 无 FACT LOCK（count=0）、无 output.txt。
- 规则存在性：`AGENTS.md:84` + `git log -S` 追溯到 `9c607ad 2026-10-02`；gen.py 无 30min 机闸（grep 无命中）。

**推断（标注置信度）**
- 「把 <30min 调度硬闸转述为额度事实」这一动机/机制：MED（依据=用户定性 + 规则文本给的是「降级段数或排次日」而非「只能明日」）。
- 「主会话此前已读入 302s」：HIGH-with-inference（通知已入库并被 23:26:39 的 reasoning 引用该子代理结论，但未在该 reasoning 中看到 302s 字面）。
- 「用户当夜实际可发起」：**机械层面可发起**（HIGH，check-only ok:true/EXIT=0、198+18≤500、gen.py 无 30min 闸）；**是否有真实用户发起动作**：未找到（LOW/未验证）。

---

## 已执行的检索命令清单（可复现）

```bash
# 0) 定位会话与子代理
ls -d /home/terry/.zcode/cli/agents/session_a40eae17265b5414c27e8c45d2c27b5c/*/
sqlite3 "file:/home/terry/.zcode/cli/db/db.sqlite?mode=ro" ".timeout 20000" ".tables"
sqlite3 "file:/home/terry/.zcode/cli/db/db.sqlite?mode=ro" ".timeout 20000" ".schema message"
sqlite3 "file:/home/terry/.zcode/cli/db/db.sqlite?mode=ro" ".timeout 20000" ".schema part"
sqlite3 -line "file:...db.sqlite?mode=ro" "select id,parent_id,title,time_created,time_updated,directory,task_type,last_outcome from session where id like '%a40eae17%' or parent_id like '%a40eae17%';"
sqlite3 "file:...db.sqlite?mode=ro" "select id from session where parent_id='session_a40eae17265b5414c27e8c45d2c27b5c';"

# 1) 关键词计数（主会话 + 8 个会话树）
for kw in 物理约束 "距 00:00" "明日 00:00" 没有额度 198 39.6; do
  sqlite3 "file:...db.sqlite?mode=ro" "select count(*) from part where session_id='session_a40eae17265b5414c27e8c45d2c27b5c' and data like '%$kw%';"
done
# → 物理约束=1, 距 00:00=32, 明日 00:00=5, 没有额度=0, 198=23, 39.6=0
# 8 会话逐会话计数：没有额度=0 物理约束=0 禁今晚=0（子代理全 0；主会话 物理约束=1 禁今晚=1）

# 2) 命中行定位与原文
sqlite3 "file:...db.sqlite?mode=ro" "select id,message_id,datetime(time_created/1000,'unixepoch','+8 hours'),length(data) from part where session_id='session_a40eae17265b5414c27e8c45d2c27b5c' and data like '%物理约束%';"
sqlite3 "file:...db.sqlite?mode=ro" "select data from part where id='part_mvia2iou_0657e219-14ba-4a80-9ac2-ec8b081fa769';"
sqlite3 "file:...db.sqlite?mode=ro" "select id,session_id,datetime(time_created/1000,'unixepoch','+8 hours'),substr(data,1,200) from message where id='msg_mvi9riyb_cacf0aed-2cd0-466f-a0e9-031ab1f07607';"

# 3) 198 / 明日 00:00 / 用户消息时间线
sqlite3 "file:...db.sqlite?mode=ro" "select p.id,datetime(p.time_created/1000,'unixepoch','+8 hours'),m.data->>'role',substr(replace(p.data,char(10),' '),1,220) from part p join message m on m.id=p.message_id where p.session_id='session_a40eae17265b5414c27e8c45d2c27b5c' and p.data like '%198%' order by p.time_created;"
sqlite3 "file:...db.sqlite?mode=ro" "select ... where p.session_id='...' and p.data like '%明日 00:00%' order by p.time_created;"
sqlite3 "file:...db.sqlite?mode=ro" "select datetime(m.time_created/1000,...),m.data->>'role',substr(...) from part p join message m ... where m.data->>'role'='user' and m.time_created between 1792595000000 and 1792601000000 order by m.time_created;"

# 4) FACT LOCK 子代理行为核查
sqlite3 "file:...db.sqlite?mode=ro" "select count(*),min(...),max(...) from part where session_id='sess_subagent_agent_1537858a-…';"
sqlite3 "file:...db.sqlite?mode=ro" "select datetime(...),p.data->>'tool',coalesce(p.data->'state'->'input'->>'file_path',p.data->'state'->'input'->>'command') from part p where p.session_id='sess_subagent_agent_1537858a-…' and p.data->>'tool' is not null order by p.time_created;"
sqlite3 "file:...db.sqlite?mode=ro" "select data from part where id in (select id from part where session_id='session_a40eae…' and data like '%call_fc35d1732c1f4ef99a3581ca%');"

# 5) 仓内取证（只读）
cd /mnt/data/dev/videop1
grep -rn "物理约束\|约束 4\|约束4" --include=*.md . | head -30
grep -n "30min\|清零" AGENTS.md
git log -S "距清零 <30min 禁发起新创建" --format="%h %ad %s" --date=iso -- AGENTS.md | tail -3
grep -rn "次日\|00:00\|明日" plans/task-videop1-ep03-videogen-001/*.md
grep -rn "30min\|<30" plans/task-videop1-quotafact-001/*.md
grep -n "22:33\|500s\|已用 180\|额度" plans/task-videop1-antistall-001/subagent-state/00-conversation-extract.txt
stat -c '%y %s %n' tmp/_gen-budget/video-seconds-20261021.json
ls -la --time-style=+%Y-%m-%d_%H:%M tmp/ep03/gen/vid/
grep -c "FACT LOCK" docs/series/shiyan-lihua/ep03/ep03-prompts.md tmp/ep03/gen/specs/ep03-video-all.json
stat -c '%y %n' docs/series/shiyan-lihua/ep03/ep03-prompts.md tmp/ep03/gen/specs/ep03-video-all.json
git diff --stat -- docs/series/shiyan-lihua/ep03/ep03-prompts.md
git status --short -- tmp/ep03/gen/specs/
grep -n "不建议今日继续\|剩余 302s\|check-only\|次日 00:00\|停批" agents/session_a40eae…/agent_ce1928bc…/output.txt
grep -n "清零\|30min\|1800" tools/gen.py
grep -n "day_auth\|daily_seconds" tools/gen.py

# 6) 日志侧（负结果）
ls /home/terry/.zcode/cli/rollout/ | grep -c a40eae     # =0（无该会话 model-io 记录）
grep -c "禁今晚" /home/terry/.zcode/cli/log/zcode-2026-10-21.jsonl   # =0
```

## 未找到 / 已排除（负结果报告）

| 检查项 | 结果 | 已尝试位置/命令 |
|--------|------|-----------------|
| 字面「没有额度」 | **未找到（0 命中）** | 8 个会话 `part.data LIKE '%没有额度%'` |
| 「39.6%」原始出现 | **未找到（0 命中）** | 主会话 `part.data LIKE '%39.6%'`；仅见于用户事后提供的 `user-session-log.md` / `docs/experience/quotafact-20261021.md` |
| 该会话 model-io rollout 记录 | **不存在** | `ls /home/terry/.zcode/cli/rollout/ \| grep a40eae` → 0；目录仅 3 个文件 |
| zcode 日志中的该句 | **未找到（0 命中）** | `grep -c "禁今晚" zcode-2026-10-21.jsonl`；未再尝试 10-22（同句属 10-21，且 DB 已给一手原文） |
| FACT LOCK 产出「明日 spec」 | **未落盘** | 子代理无 Edit/Write；prompts mtime 未变；spec 无 FACT LOCK；无 output.txt |
| FACT LOCK 子代理 | **确有派发且运行**（排除「只是嘴上说派了」的怀疑） | `call_fc35d…` 派发 part + child session 117 parts |
| 用户当夜真实发起生成的证据 | **未找到** | 未在 `tmp/ep03/gen/vid/`、`video-seconds-20261021.json` 发现 23:30 后新增创建记录 |
