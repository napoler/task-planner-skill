# Checkpoint: 01-explore-hooks (task-v068-execution-stability)

- **time**: 2026-09-14
- **agent**: Explore（mini）, seq 01, Phase 1 S1
- **status**: done（子代理无 Write 工具,本文件由主进程按返回全文落盘）
- **消耗**: subagent_tokens≈3254k, tool_uses=45, 629s; acceptance 6/6

## ① 哨兵拦截点（HIGH）
- zcode-pretooluse.sh:17-23 sid 透传 → check-scope.sh:87-131 side 哨兵判定（sidkey 规范 L80-83）；rc=1 → PreToolUse exit 2
- 白名单：check-scope.sh:54-61 plans/ 祖先豁免；L65-73 文件名豁免表（含 knowledge-brief 等）
- **~/.zcode/cli/memories/** 不在哨兵白名单（check-scope.sh grep memories=0；memories 豁免仅在 check-delegation.sh:171,两套独立机制）→ E1 修复点 = check-scope.sh:65-73

## ② plan-created.cjs 缺陷与 gc（HIGH）
- sid 获取链 :37-58（stdin JSON → TASK_PLANNER_SID → CLAUDE_CODE_SESSION_ID → ZCODE_SESSION_ID/CLAUDE_SESSION_ID）
- **v060 缺陷确切行 = L169-177 else 分支**：非交互无 sid → sidkey='' → 仅打印「跳过会话 side 哨兵清除(fail-open)」但 L182 仍走成功文案 exit 0 ——「显示成功实未删」根因
- 已有 >24h gc：set-active-plan.sh:125-143（find -mmin +1440 扫两侧），zcode-sessionstart.sh:33 SessionStart 顺带执行
- 风险：哨兵不存在路径零日志（E1 类问题无痕迹）

## ③ .session-owner 认领链路（E3 根因,MED 需环境实证）
- 写入点 zcode-userpromptsubmit.sh:99-112：owner 空或==本 sid 才写 + 原子写 side 指针；前提 L100 UPS_SID != "default"
- **E3 根因候选（按概率）**：1) ZCode UserPromptSubmit stdin 未携带 .session_id（L24 拿空→default→恒不写）——与 zcode-pretooluse.sh:60-62 sid 命名空间分裂同源；2) CWD 解析不到活跃计划 L33 提前 exit；3) **zcode-userpromptsubmit.sh 不读任何 CLAUDE_CODE_SESSION_ID 兜底（对比 resolve-plan-dir.sh:31 / attest-plan.sh:34 均有 env 兜底）——sid 源最弱**
- delegation-observe 注入：check-delegation.sh:112（文案）+ 258-262（NO_OWNER 触发）；每次 Write/Edit 经 zcode-pretooluse.sh:40 调 pretool 模式；**不跑 stats**（stats 仅终验手动）

## ④ TAMPERED 检测点与 PostToolUse 挂点（HIGH）
- 唯一比对脚本 attest-plan.sh:79-84（verify: 0 匹配/1 TAMPERED/2 未锁定）；检测调用方仅 zcode-userpromptsubmit.sh:49-56（每轮 prompt 校验）——Pre/PostToolUse 均无比对
- PostToolUse（zcode-posttooluse.sh）挂点可行：输入含 .tool_name(L26)/.session_id(L20)/.cwd(L18)，编辑路径可 jq 取；attest-plan.sh 非交互可调（L32-49 有 env 兜底；--skip-dispatch-check 可跳）；**.plan-attestation 无 sid 字段（:68 只写 sha/路径/attested_at）→ S2 护栏需借 .session-owner 或新增 attested_by_sid**
- PostToolUse 现有职责：Agent 清串行槽(L23-33)/计划探测(L34-44)/24h+完结静默(L46-54)/6 阈值(L56-71)/9 字段 state(L79-99)/四级提醒(L105-189)

## ⑤ E4 慢源（KQ3 判定：与 E3 部分同根,非全同）
- 单次 Write/Edit 子进程估算 40-60：pre jq×3 + python3 abspath + check-scope D10 段(resolve+touch/ref L101-118) + check-delegation(resolve_plan_dir_any L60-81 **7 级盲找×每级完整 resolve**,O(N_plans) stat + jq + owner 缺失再 jq) + **Rule 23 段(zcode-pretooluse.sh:91-102 循环 30+ 计划,每计划 awk×2+grep+basename,O(N) 子进程)**
- 判定：E4 真慢源 = Rule 23 全 plans/ 循环 + 盲找重复 resolve（本仓 32 计划放大）；observe 注入本身轻（一次 jq -Rs）→ **KQ3 答：不同根**；S3 修 E3 同时建议 Rule23/盲找量化优化列入风险（本任务不动,防 FMEA 216 削拦截链）

## ⑥ config 键（HIGH）
- 顶层 properties 实核 **28 键**（含 provider_fallback/subagent 两对象键），additionalProperties:false（L337）新键必须入 .properties
- 阈值键现值：todo_sync_interval_calls=10(post L58)/plan_update_interval_minutes=15(post L59)/stale_remind_cooldown_calls=10(post L60)/findings_stale_minutes=20/progress_stale_minutes=25/compass_escalate_after=2/prompt_note_interval=10(ups L88)/delegation_enforce=enforce/dispatch_contract_enforce=enforce/vc_gate_enforce=warn
- **hook_* 前缀无占用,hook_self_heal_enforce 未撞名**；config 无 plan_sync_interval 键（grep 0,实际名 plan_update_interval_minutes）

## 三、S1-S3 改动点清单（勘察结论）
- S1a check-scope.sh:65-73 豁免表加 `$HOME/.zcode/cli/memories/`* → exit 0（修 E1 本体）
- S1b plan-created.cjs:169-177 sidkey 缺失兜底：清「plans/.active_plan_side/<sidkey>.active_plan 不存在(无认领)或 mtime>24h」的 side 哨兵（指针存在性护栏防误删他会话活跃哨兵,KQ1）+ 补日志
- S2 zcode-posttooluse.sh L34-44 后挂点：编辑 file_path==task_plan.md 且 .session-owner==本 sid → 自动 attest-plan.sh --skip-dispatch-check 重锁（sid 不匹配维持 TAMPERED;attestation 可加 attested_by_sid 字段）
- S3a zcode-userpromptsubmit.sh:24-25 UPS_SID 补 env 兜底链 ${CLAUDE_CODE_SESSION_ID:-${ZCODE_SESSION_ID:-}}（与 resolve/attest 侧对齐,E3 根因修复）
- S3b check-delegation.sh:108-114/258-262 observe 注入加会话级节流（/tmp/task-planner-observe-${sid}.flag,owner 初始化成功后停注）

## 四、风险注记（最脆弱段）
1. check-scope.sh:101-118 D10 仲裁：resolve 静默失败（|| true L103）退化「存在即拦」无日志
2. check-delegation.sh:60-81 resolve_plan_dir_any：7 级盲找×每级 O(N) resolve + $HOME/.zcode/plans 兜底跨项目命中他人计划（无会话归属校验）——最易误放行
3. zcode-pretooluse.sh:78-104 Rule 23：30+ 计划 awk 循环 + 仅 basename 匹配跨任务误报风险
4. plan-created.cjs:169-177 缺陷段哨兵不存在路径零日志
5. zcode-userpromptsubmit.sh:99-112 owner 读 tr -cd 'a-zA-Z0-9' 丢 _- 字符,与 check-delegation L96 'a-zA-Z0-9_-' 规范不一致（sid 含下划线时永远 mismatch）——**休眠地雷,S3 顺带对齐**

## 五、负结果
- grep memories @ check-scope.sh=0；grep plan_sync_interval 全仓=0；grep attest @ pre/posttooluse=0（observe 不走 stats,stats 无 hook 调用方）
