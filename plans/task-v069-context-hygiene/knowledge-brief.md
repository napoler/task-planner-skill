# Knowledge Brief: task-v069 上下文与工作文件主动维护（Rule 29）

> 任务知识简略要点（第 6 计划文件，五段：速览/已验证事实/文件锚点/易错点/S-unit 材料包索引）
> 生成时间: 2026-09-14 | 生成方: 主进程（规则层快速调研 + Explore 子代理报告）

## §1 速览

task-planner skill 现有"缺→补"链路完整（[plan-compass] 提醒、3-File Gate、check-3file-gate.sh），
但"多→删"链路完全空白：上下文退场（标记 superseded/压缩）、工作文件归档（35 个 completed 任务目录）、
INDEX 统计修正、worktree 遗留清扫均无机制化支撑。本任务新增 Rule 29 条款 + 2 个机械脚本 + 3 个
config 键 + 1 个 selftest，形成对称的"主动维护"能力域。

## §2 已验证事实

| 事实 | 证据路径 |
|------|---------|
| Rule 29 编号未被占用（全仓 grep "Rule 29" 零命中） | Explore 报告 §2 |
| config.json 现有 29 个顶级键，additionalProperties:false | skills/task-planner/config.json:347 |
| plans/INDEX.md 统计: complete=35, in_progress=0, pending=0 | plans/INDEX.md:87 |
| plan-created.cjs:122 已有 "archive 前缀目录跳过" 约定（消费侧已预留） | scripts/plan-created.cjs:122 |
| set-active-plan.sh gc 仅清 .plan_required_side/.active_plan_side 指针文件，不碰任务目录 | scripts/set-active-plan.sh:125-143 |
| check-delegation.sh 白名单已放行 plans/ 下 .md/.json（:154）与 SKILL_ROOT 自身（:166-169） | scripts/check-delegation.sh:139-175 |
| 13 个 selftest 脚本，基线 213/0（v068 后全量） | scripts/selftest-*.sh |
| sync-companion.sh 有反向拉回陷阱，部署必须用定向 cp | 记忆 task-planner-repo-deploy-flow |
| worktree 集中目录规范: /home/terry/<repo>-worktrees/<task-id>（宪法 §11.2） | ~/.zcode/AGENTS.md §11.2 |
| Rule 19 子条款 19.7/19.8 顺序已乱（19.8 在 19.7 之前），新追加放 19.7 行之后 | references/critical-rules.md:90-97 |

## §3 文件锚点

| 文件 | 锚点 | 说明 |
|------|------|------|
| references/critical-rules.md:218 | Rule 28 末尾（:226） | Rule 29 追加位置 |
| references/critical-rules.md:87-97 | Rule 19 节 | 上下文退场与 Rule 19 的关系 |
| SKILL.md | §Critical Rules 清单 + §Rule 28 段落之后 | Rule 29 章节插入位置 |
| config.json:347 | additionalProperties:false 行 | 新键注册位置（.properties 内） |
| scripts/check-delegation.sh:139-175 | 白名单 | 新脚本路径确认（plans/ 下 .md/.json 已放行） |
| scripts/selftest-methodology.sh:47-95 | 7 用例范本 | selftest 结构参考 |
| scripts/selftest-execution-stability.sh:93-143 | T11a/b 行为级断言 | selftest 行为级断言参考 |
| plans/INDEX.md:10-44 | 35 completed 任务目录清单 | plan-hygiene.sh 归档输入 |

## §4 易错点

1. **config.json additionalProperties:false** — 新增键必须先注册进 .properties，否则 jq 读取失败走 fail-open
2. **plan-hygiene.sh 归档后 INDEX 统计回归** — sync-todos.sh --index 全量重写特性，归档后必须重跑 --index
3. **部署 3 实体位用 sync-companion 反向拉回陷阱** — 必须用定向 cp（rm+cp -rL），部署后 diff -r 复验
4. **Rule 19.7/19.8 顺序已乱** — 新追加放 19.7 行之后，不要顺手交换（scope 外）
5. **worktree 内 git status 不干净时禁止合并** — 合并回前置条件：worktree 内 git status --short 为空
6. **主仓 plans/ 有未提交变更（9 个文件）** — 合并时注意不卷入 plans/ 目录（plans/ 不入库）

## §5 S-unit 材料包索引

| S-unit | 材料包内容 | 来源 |
|--------|-----------|------|
| S1.1 | ①现有 Rule 1-28 结构 ②Rule 29 设计要点（29.1-29.6）③19.x 编号现状 | references/critical-rules.md + Decisions Made 表 |
| S1.2 | ①SKILL.md §Critical Rules 清单结构 ②Rule 29 章节模板 ③Rule 28 章节风格参考 | SKILL.md:§Critical Rules + references/critical-rules.md:218 |
| S2.1 | ①selftest-methodology.sh 范本 ②check-3file-gate.sh exit code 语义 ③config.json jq 读取方式 | scripts/selftest-methodology.sh + scripts/check-3file-gate.sh |
| S2.2 | ①plans/INDEX.md 35 completed 清单 ②plan-created.cjs archive 前缀逻辑 ③set-active-plan.sh gc TTL 模式 | plans/INDEX.md + scripts/plan-created.cjs:122 |
| S2.3 | ①config.json 29 键结构 ②check-delegation.sh 白名单（:139-175） | config.json + scripts/check-delegation.sh |
| S3.1 | ①selftest-methodology.sh 范本 ②selftest-execution-stability.sh 行为级断言 ③2 个新脚本可测面 | scripts/selftest-methodology.sh + scripts/selftest-execution-stability.sh |
| S3.2 | ①13 个 selftest 列表 ②基线 213/0 ③运行方式 | scripts/selftest-*.sh |
