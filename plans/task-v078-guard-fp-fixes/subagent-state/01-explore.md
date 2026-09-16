# 01 Explore 考古检查点（task-v078，2026-09-17，主进程自子代理返回消息代写，锚点已复验）

## ① 提醒链对已交付计划误报
- 唯一生成源：`skills/task-planner/scripts/zcode-posttooluse.sh`（PostToolUse hook）
- 触发点：计划文档陈旧 L156（emit :158）；findings L175（升级 L184/emit :188、常规 :194）；progress L204（升级 :212、emit :216/:222）
- 活跃计划解析：L43 → resolve-plan-dir.sh（side 指针优先，TTL 24h）
- 既有豁免：L100 `grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan"` → :101 `exit 0`；>24h 静默 :97
- **误报根因**：L100 只查 task_plan.md，而本仓约定 outcome 写在 verification.md（v076/v077 均如此）→ 豁免永不触发
- 修复点：L100 后补 verification.md 兜底分支（同目录 verification.md，同正则，-qi 容前导空格）
- config 阈值键：todo_sync_interval_calls:198 / plan_update_interval_minutes:204 / stale_remind_cooldown_calls:215 / findings_stale_minutes:221 / compass_escalate_after:227 / progress_stale_minutes:233（无总开关；读侧 :106-119，SKILL_ROOT :105）
- selftest 现状：compass/stale **零覆盖**；selftest-execution-stability.sh :16 POSTTOOL 定义、:42 T3 静态、:106-107/:133-135 T11a/b 行为执行（fixture 无 outcome/verification.md——加兜底不改既有行为）

## ② check-dispatch 打包检测误计示例 ID
- 本体：L264 `grep -oE 'S[0-9]+' "$pf" | sort -u`（全位置匹配，注释 L45-47 定死口径）；L265 计数 / L266 ≥2 判定 / L267 文案 / L269 hits；warn 分支 L278-285，enforce exit 2 L286-287
- 档位：get_mode L113-127（dispatch_contract_enforce，config:61 default enforce）
- selftest-dispatch.sh：FG-01 L219-240 基线 / FG-02 L242-252 超长 / **FG-03 L254-264 多 S-unit 检测**（:256 prompt、:261 断言 'S-unit ID'）/ FG-04 L266-276 brief；无 enforce 档用例、无豁免用例
- **设计陷阱（考古证实）**：不能以「prompt 含 subagent-state/」作豁免锚——L68/290/300 显示所有合规派发的检查点路径都在 subagent-state/ 下，单条件豁免=废掉打包门
- **采用豁免锚**：`任务书`（中文词）+`subagent-state/` 双条件同时命中 → Rule 35.3 落盘任务书范式（v077/v078 实战 prompts 均含「任务书」措辞；常规派发用「检查点/材料包/知识包」不会命中）→ 打包检测出 SKIPPED 提示不阻断（复杂度归模型判断，对齐 P11 裁决）

## ③ 簿记杂项（主进程自处理）
- variant 模板（rule-enhancement-type.md L5）来源不明改动已留档还原（diff 存 progress Error Log）
- .gitignore 已补 `plans/**/.session-owner`（check-ignore 验证生效）
- 旧哨兵 038d...plan_required（v075 P11 4cc6635 误入库）删除待随簿记提交 staged
- 并行信号：plans/task-v079-skill-modify-conservatism/（05:35 裸模板存根，非本会话所建）——不碰不提交，报告用户
