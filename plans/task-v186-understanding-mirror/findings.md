# Findings & Decisions

## Requirements
- R1-R5 逐字锚=user-session-log.md #1（配对镜像首例 dogfood）；机制诉求=「逐字 ↔ 模型理解」同步配对，供回溯定位理解偏差

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 已消费 | 结论落点 |
|--------|------|--------|---------|
| Rule 80 现行全文 | 核心 critical-rules.md:129-144 | ☑ | §80.7 草稿（衔接 80.2/80.3/80.4） |
| templates/user-session-log.md | 第 7 文件模板 | ☑ | §S2 任务书 |
| selftest-session-log.sh SL-01..11 | scripts/selftest-session-log.sh:1-85 | ☑ | §SL 锚影响分析 |

## Research Findings

### 落点考证（2026-10-17）
- Rule 80 现有 80.1-80.6（核心 critical-rules.md），辖域=用户会话逐字记录专档——本诉求（理解同步记录）即其辖域延伸 → 子条 80.7 增补（19.8 增补判例），**零新 Rule 号、零全集 1-9x 级联、零新 config 键**。
- SL-01..11 断言面：模板三关键词（只写不改/append-only/逐字抄录）、条目格式 `## #N`、恢复协议、80.1-80.6 六子条锚、指针区块在案、SESSION-LOG GATE、init 建档块、SL-08 负断言（指针区块禁「当前条目数|最近一条」类可变计数）、SL-09 零新键——**全部正向锚不受增量影响；SL-08 新增行为说明行不含计数词，安全**；不新增断言（L0-T opt-in）。以 S3 实跑为准。
- 指针区块模板唯一载体=templates/task_plan.md（grep 实证单文件）。

### 方案取舍（为什么同文件配对块而非独立第 8 计划文件）
- 独立文件需动 init-session.sh 建档块+存在性复核、check-complete 门控、模板、selftest 四处机械面（blast radius 大、违反 L0-T 比例）；
- 同文件配对块：逐字面（权威）与镜像面（对照）同屏，回溯即对照；80.4 权威序天然保持；机械面改动仅模板格式块。

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| 80.7 子条/同文件配对/非权威面/append-only 更正 | 见 task_plan.md Decisions Made |

### 80.7 草稿（交付物本体；S1 逐字转写源，亦落盘 s1-brief.md）

```markdown
80.7 **理解镜像（模型理解同步记录，task-v186）**：主进程在每条逐字条目落盘的同一动作中，紧随其后追加一条同号配对的「理解镜像」块（格式 `### #N 理解镜像 | 日期`，口径源=templates/user-session-log.md）——内容=模型当时对该条用户请求的整理理解，要点化 ≤10 行（任务对象/范围边界/验收期望/约束假设择要有；琐碎消息可一行）。**定位与约束（四条）**：① 镜像=非权威对照面，唯一用途=回溯时与逐字原文对照、定位错误是否源于理解偏差（判例锚=plans/task-v186-understanding-mirror/user-session-log.md #1）；与逐字原文冲突一律以逐字原文为准（80.4 权威序延伸），禁以镜像改写需求、禁替代 R 行逐字锚（Rule 51.1 不受影响）；② append-only 同 80.2——理解事后演进时追加「### #N 理解镜像更正 | 日期」新块（注明改判要点与依据），禁改旧镜像一字；③ 写入者=主进程单写（80.3 同面），子代理只读；④ 逐字条目与镜像块一对一配对（同编号），禁只录其一。**机制（文本优先 L0-T——对齐 86.7/89.6/90.6/92.7 范式）**：判定面=LLM 行为+模板格式锚，零新增守护脚本/零新 config 键（selftest-session-log.sh SL 断言面不扩——机器化 opt-in，仅用户显式要求才建）；首例 dogfood=task-v186 自身专档。
```

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 全局活跃指针指向 task-v184（并行会话在途，开场 TAMPERED 告警同源） | init 已设本任务指针；继续 side 指针隔离惯例 |

## Resources
- 落点：/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md（Rule 80 段 :129-144）
- 模板：skills/task-planner/templates/user-session-log.md、templates/task_plan.md（指针区块）
- 指针：skills/task-planner/SKILL.md :188（Rule 80 指针行）、:126（G9 行）

## Visual/Browser Findings
（本任务暂无多模态发现——未产生截图/PDF/网页证据）
