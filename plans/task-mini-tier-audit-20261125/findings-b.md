# findings-b.md — mini 档升级触发链只读审计（2026-11-25）

> 范围：`skills/task-planner/` 源码（canonical），只读取证；B1-B10 逐项对照。行号均为审计时工作树状态。

## 结论摘要
1. B1 通过：`phases/findings/research/delegations` 均为顶层数组，`phase-done` 写 `"complete"`，hook jq 路径与值域一致，无"信号永假"字段错配。
2. B2 三信号仅认 JSON：mini 执行若只改 MD（SOFT_ONLY），步骤门三信号全死，只剩 45min 硬兜底；证据链见 P1-1。
3. B3 `created_at` 缺失/非法/未来 → 硬软双门同时 fail-open（L266 `case ... return 0`），零升级零提示。
4. B3 老计划 resume 后按创建时刻算 elapsed，首个工具调用即升档；naive 时间被当 UTC，UTC+8 可虚增 8h。
5. B4 幂等键是 `<sid>` 而非计划：同一会话第二个新 mini 计划永不升级（`L241` 注释自认）。
6. B5 升级动作链逐步 `|| return 0` + 输出全丢，可出现"档位已改但无 TU-1/无注入/无 state"的静默态。
7. B6 rm 旧锁后无机器门兜底重锁：`--verify` 未锁定 rc=2，而 userpromptsubmit 仅在锁文件存在时才校验。
8. B7 无 mini→standard 之外的再升级通道；JSON 档位枚举只有 standard/mini（full 仅模板语义）；无降级回写。
9. B8 claude/cursor/opencode 部署位 PostToolUse 挂 `check-doc-sync.sh`，其中零 tier/plan-state 逻辑；无主进程自查升档条款兜底。
10. B9 两个 env 名在代码/emit/SKILL.md 共 6 处拼写完全一致，未发现拼写 bug；config.json 无对应键（env-only）。
11. B10 `selftest-tier-b.sh` 18 断言全是 v094 旧 Tier B 项，升级链零覆盖；仅 `selftest-context-pressure.sh` 静态数 emit。
12. 附加 P1：完结计划 `outcome` 是对象时 hook 的 `test()` 抛错 rc=5，完结守卫失效（可误升档+删锁）。
13. 附加 P1：emit 宣称"G4-G11 不再豁免、无需重写计划文档"与 mini-lite 骨架缺 standard 硬锚、SKILL 豁免表不自洽。

## P0 失效模式

**P0-1（B8）非 ZCode 工具完全没有自动升档通道。**
- `skills/task-planner/SKILL.md:51` "升档双判据 ... **由 posttooluse hook 自动升级 standard 检查面**"；`:173` 再次锚定"由 hook 自动升级 standard（[tier-upgrade] 注入 ...）"。
- `skills/task-planner/lib/install-stub.sh:79` `"PostToolUse": ... check-doc-sync.sh`（Claude）；`:119`/`:169` cursor/opencode frontmatter 同样是 `name: PostToolUse` → check-doc-sync.sh；`:208` 同。
- `skills/task-planner/scripts/check-doc-sync.sh:1-25` 职责仅 "Detect task_plan.md staleness"；全文 `grep -n 'tier\|plan-state'` 零命中（见复核清单 9）。
- `skills/task-planner/lib/verify.sh:204` "SKILL.md frontmatter 从未承载 zcode hooks"；canonical `SKILL.md:19` 仅注释 `# hooks: <TOOL-ADAPTED ...>`。
- SKILL.md 中唯一"升档铁律"是 `:42`/`:181` "修复类请求命中 L0/mini/trivial/L0-E，一律先升 L1 standard"——触发锚是"新指令/修复类"，不是运行时长/步骤门，不能兜底。结论：claude/cursor/opencode 的 mini 计划执行再久也留在 mini。

**P0-2（B4）幂等粒度=会话，不是计划。**
- `zcode-posttooluse.sh:235` `local sfile="$plans_root/.tier_state/${sid}.state"`；`:241` "幂等：本会话已升级过不再执行（跨计划共享 sidkey 语义=一次会话一次升级）"；`:242` `[ -f "$sfile" ] && grep -q '^upgraded=1' ... && return 0`。
- 同会话内第一个 mini 升档写入 `upgraded=1`（`:299`），同会话第二/第三个 mini 计划在 `:242` 直接 return 0；无 task-id 维度、无 per-plan state。
- SID 在本 hook 内不会为空：`:22` 从 `session_id` 提取后 `:23` `SID="${SID:-default}"`；`$(dirname "$plan_dir")` 作为 plans_root 传入（`:307`）。但缺失 session_id 的所有会话共用 `.tier_state/default.state`，等价于退化共享文件；若直接调用且 sid 为空，文件名为 `.state`（`${sid}.state`）。
- 实测 `plans/.tier_state` 当前不存在（尚无任何运行时升档痕迹）。

**P0-3（B5）升级链失败全静默，且可能留下半升级态。**
- `:285` `planctl set ... >/dev/null 2>&1 || return 0`；`:287` `planctl add ... decisions ... >/dev/null 2>&1 || return 0`；`:288` `render ... || return 0`；`:297` `mkdir -p ... || return 0`；`:300-303` mv 失败 `return 0`。全链无日志、无 stderr、无重试。
- 顺序后果：`set` 成功而 `add`/`render`/`mkdir` 任一失败 → JSON 已是 standard，下一轮 `:243` `jq -e '.plan_tier == "mini"' || return 0` 直接跳过，TU-1 决策、emit 文案、幂等标记全部缺失，用户永远看不到升级；`add` 的 TU-1 若因 `:1255-1256` 重复 id 拒绝，同样静默（planctl.py:1256 `"decisions 条目已存在"`）。
- 与宪法 §五"错误必须曝光"冲突；无 `|| echo` / 兜底重试 / 补偿回滚（`:284` 注释反而声明"前一步成功但后一步失败时不回滚"）。

**P0-4（B3）计时字段缺失=软硬双门全灭（fail-open）。**
- `:238` `[ -f "$pdir/plan-state.json" ] || return 0`；`:251-265` 从 `created_at` 解析 elapsed，异常 `except: pass` 输出空；`:266` `case "$elapsed" in ''|*[!0-9]*) return 0 ;; esac`。
- `templates/plan-state.json:6` `"created_at": ""` 是 init 模板原值，只有 `planctl init` 会填（planctl.py:829 `doc["created_at"] = now_iso()`）。`init-session.sh:1108-1125` init 失败时仅 `WARN ... JSON mode fail-open, 存量 MD 流程继续` → 无 JSON 或空 created_at 的计划永不触发双门，且无任何升级侧提示。
- 实测（隔离 Python）：`fromisoformat('')` → ValueError；未来时间 → `-5`（命中 L266 非数字模式）；无时区字符串 → 按 UTC 处理，UTC+8 本地时间虚增 480 分钟。

## P1 风险

**P1-1（B2）信号写入方与 SOFT_ONLY 证据链。** `init-session.sh:762-770` 的 3 文件分支条件是 `TRIVIAL_CODE_TIER=1`（"task_plan.md + progress.md + verification.md"），`:765` 明说"非 trivial 档（含既有 mini 档）保持 5 文件全量"；但 `:1091-1111` JSON 权威源对所有 mini 也初始化（`_json_init_tier="mini"`）。mini SOP 并未豁免 JSON 记帐：`SKILL.md:271` "所有状态与语义数据变更必须通过 planctl.py"；`:110` "每次子代理/调研 Skill 返回后紧邻一次 `planctl add --section research` + render"；`:95` phase-start。写入方即主进程调用 planctl（`planctl.py:485-491` phases、`:492-494` findings、`:539-541` research、`:511-514` delegations）。失效链：历史判例 `attest-plan.sh:101` 仅 `WARN ...（SOFT_ONLY 信号 ...）`，`plans/task-project-audit-20261123/forensics/plan-drift.md:128` 记 "JSON 342B 空业务字段，MD 48253B ... attest 仅 WARN 不阻断" → JSON 三字段全空 → hook `:270-275` 步骤门恒空 → 仅 `:280` 45min 硬兜底；`research` 缺失时 `// []` 也不会报错，静默降级。

**P1-2（B3）时钟语义。** `planctl.py:829` 写 `created_at`=init 时刻；`:419-420` 每次 set/add 只刷 `updated_at`；`planctl.py:1019-1034` `recover` 不重置时钟。hook `:261` 用 `datetime.now(utc) - created` → 老计划 resume 后首个 PostToolUse 立刻满足硬阈值（若有旧锁还会在 `:293-295` 被删）；`:259-260` naive 时间强制视为 UTC → 本地时区写入可偏差数小时。

**P1-3 完结判定对对象型 outcome 失效。** `:244` `(.outcome // "") | test("COMPLETE|BLOCKED")`；schema `schemas/plan-state.schema.json:80,691` outcome 是对象，`planctl.py:183` `"outcome": ({"result"}, {...})`，render `:1961` 输出 `outcome: <result>`。实测 `{"outcome":{"result":"COMPLETE"}}` 上该 jq 表达式 rc=5（test 要求字符串）→ 完结 JSON 计划不在函数内早退；MD 兜底守卫在 `:327`（晚于 `:307` 调用），故 mini+已完结对象 outcome 的计划仍可能升档并删锁。

**P1-4 "至少完成调研"未成为硬前置。** `:220-223` Why 写"至少完成调研后才做决定"，但 `:270-274` 的 jq 顺序是 `phase:complete` → `findings/research` → `delegations` 三选一；phase 完成或仅有派发记录即升档，无 research 也通过；`SKILL.md:51`/`:173` 的文案是"任一"，与 Why 的调研前置口径不一致。

**P1-5（B6）删锁后无机器重锁兜底。** `:293-295` 直接 `rm -f "$pdir/.plan-attestation"`（注释自认 standard 门重锁会被 fail-closed 拒锁，靠"模型自觉补区块"）。`attest-plan.sh:686` `--verify` 无锁 `exit 2`；`zcode-userpromptsubmit.sh:66` 用 `[ -f "$attest_file" ]` 包住校验 → 无锁时完全静默，不注入 "未锁定" 警告（`:307` 的 `attest_line` 兜底文案不属于 TAMPERED 分支）；`planctl.py:2233-2244` `cmd_check` 只有 schema/CHECKS，无 attest 检查。standard 门锁定要求纯文本自觉。

**P1-6 emit 恢复清单与骨架/文档不自洽。** `:304` emit "委派门 floor 恢复 0.7、审计门按 L1 强制、VC 阈值恢复 standard、G4-G11 不再豁免、收尾回读恢复全量六文档 ... 无需重写计划文档"。对照：`check-complete.sh:160-163` floor 0.7→0.0 只在 MD grep `plan_tier: mini` 时生效，`:885-889` VC 5→2/2→1 同理，`check-plan-audit-gate.sh:49` 必审=tier standard/full 或 lane L1/L2；这些都依赖 `:288` render 成功写出 `plan_tier: standard`（`planctl.py:1999`）。但 `:289-292` 自己承认 "升级后计划文档仍是 mini-lite 骨架（无 R 需求行等 standard 硬锚），attest 重锁必被 fail-closed 拒锁"，与 emit "无需重写计划文档" 直接矛盾；"G4-G11" 在 SKILL.md 无对应汇总锚（`:173` 只列 G4/G10/:137/todo 六项，`:139` 才是六文档锚）。审计门实际判定是 "standard/full 或 L1/L2"，非 emit 的"按 L1 强制"。

**P1-7（B7）档位梯只有两级 + 无再升级通道。** `schemas/plan-state.schema.json:26` `"plan_tier": {"enum": ["standard","mini"]}`；`../plan-template-kit/references/critical-rules-template.md:42` 虽有 "mini / standard / full 三档"，但 JSON 无法登记 full（`planctl.py:648` 白名单校验 + `:421-423` 写前拒绝）。hook `:243` 仅 `plan_tier == "mini"` 才进入，`:285` 只写 standard；standard 扛不住时没有更高档、没有二次升级/用户上抛 emit。

**P1-8（B10）自测覆盖缺口清单。**
- `selftest-tier-b.sh:2` "task-v094 Tier B 全 7 项守护（T-B1..T-B7 正反夹具）"，`:27-78` 18 条断言全部围绕 check-delegation/check-dispatch/resolve-interaction-mode/文本锚；与升级链零交集。
- `selftest-context-pressure.sh:89-90` 只有静态 `emit_expect=13` + "原 12 + tier-upgrade 注入 1 处"，`:96` `grep -c 'emit '` 计数；不执行 `tier_upgrade_check`。
- 覆盖矩阵：双判据未覆盖；步骤门（phase/findings/research/delegations 各分支）未覆盖；15/45min 阈值与 env 覆盖值未覆盖；幂等 `<sid>` 语义未覆盖；失败语义（set/add/render/mkdir 失败）未覆盖；env 名字面未覆盖；完结 outcome 对象未覆盖；删锁/重锁未覆盖。106 个 selftest-*.sh 中无任何 mutation 判别升级链（复核清单 8）。

## P2 建议
1. 幂等键改 `<sid>+<task_id>` 或读 state 内 `upgraded_plans[]`；保留"一次会话一次注入"可将注入节流与升级动作解耦。
2. 动作链失败改为显眼告警（stderr + 注入一行 `[tier-upgrade] FAIL <step>`），并区分"已 set 未 render"状态；render 失败时下轮允许补偿而非 `:243` 永久跳过。
3. 计时改用 `updated_at` / 显式 resume 锚，或升级前校验 `created_at` 存在且非未来；对 naive 时间拒绝并告警，而非静默按 UTC。
4. 步骤门加 MD 派生视图回退（research/findings 文件名+内容非空）并把 `phase:complete` 与 research 的先后关系写成明确和用户裁决一致的判据。
5. 非 ZCode 部署位补等价 PostToolUse 脚本/显式 `/tier-upgrade` 自查命令；SKILL.md 增加"超时自查升档"主进程条款（文本优先，避免擅建机器门）。
6. 升级后 Inject 文案与 mini-lite 骨架差距对齐：明确"需补 R/VC 区块并重 attest"，删去或改写与 `G4-G11` 全恢复不符的承诺。
7. 新增 `selftest-tier-upgrade.sh`：临时目录夹具 + mutation（破坏 created_at/render/attest/第二计划），断言 rc/emit/文案/env，纳入 `run-selftests.sh`；同步提升静态 emit 基线常量。

## OK-设计如此
- **B1 字段形状核对通过**：`schemas/plan-state.schema.json:33,34,45,36` 四字段均 `"type": "array"`；`:139` phase status 枚举 `pending|in_progress|complete`；`:26` plan_tier 枚举 standard/mini。`planctl.py:1312` `hit[1]["status"] = "complete"`，与 hook `:271` `.status == "complete"` 字面量一致。实测 jq 夹具（复核清单 2/4）三分支均按预期返回。
- **触发频率**：`:307` 调用位于 hook 主流程，clause `:28` 读 tool_name 但 tier 检查不按工具过滤；安装态 `~/.zcode/cli/config.json` PostToolUse 无 matcher（所有工具调用），timeout 8s；`:139` drift 计数先于检查，`:335` 起的冷却/节流在检查之后 → 升档判定本身不节流。`:50` 无活跃计划直接 exit 0（有意为之）。
- **B9 env 名一致**：`:246` / `:248` / `:304` 与 `SKILL.md:51` 两处名字逐字一致；`grep -rnow` 共 6 处，无 `HARD_MINUTE` 等拼写变体；`:247,249` 对非数字/0 回落 15/45，缺省安全。
- **无降级**：`:243` 只放行 mini，`:285` 唯一写入值 standard；全仓无把 plan_tier 写回 mini 的运行时路径（仅 init 写入 mini，planctl.py:826/1094）。升级后 hook 不会把计划改回 mini。
- **依赖与返回码**：`:239-240` jq/python3 缺失即 return 0；`:66-68` emit 用 `jq -Rs` 包装，不污染 hook stdout JSON；`:305` 升级后 exit 0 防双行输出。`bash -n` 与 planctl 语法编译实测通过（复核清单 1）。

## 主进程复核清单
1. `bash -n /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-posttooluse.sh && python3 -I -c "compile(open('/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/planctl.py',encoding='utf-8').read(),'p','exec')" && echo SYNTAX_OK`
2. `jq -c '{phases:.properties.phases.type,phase_status:.definitions.phase.properties.status.enum,findings:.properties.findings.type,research:.properties.research.type,delegations:.properties.delegations.type,plan_tier:.properties.plan_tier.enum}' /mnt/data/dev/task-planner-skill/skills/task-planner/schemas/plan-state.schema.json`
3. `grep -n 'hit\[1\]\["status"\] = "complete"\|doc\["created_at"\] = now_iso()\|"plan_tier": lambda' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/planctl.py`
4. `jq -r 'if ([.phases[]?|select(.status=="complete")]|length)>0 then "phase:complete" elif (((.findings//[])|length>0) or ((.research//[])|length>0)) then "findings/research" elif ((.delegations//[])|length)>0 then "delegations" else "" end' /mnt/data/dev/task-planner-skill/plans/task-mini-tier-audit-20261125/plan-state.json`
5. `printf '%s' '{"outcome":{"result":"COMPLETE"}}' | jq -e '(.outcome // "") | test("COMPLETE|BLOCKED")' >/dev/null; echo "outcome_test_rc=$? (5=guard失效)"`
6. `grep -rnow -e TASK_PLANNER_TIER_UPGRADE_MINUTES -e TASK_PLANNER_TIER_UPGRADE_HARD_MINUTES /mnt/data/dev/task-planner-skill/skills/task-planner /mnt/data/dev/task-planner-skill/docs`
7. `grep -n 'sfile=\|upgraded=1\|\.plan-attestation\||| return 0\|emit "\[tier-upgrade\]' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-posttooluse.sh | head -40`
8. `grep -rn 'tier-upgrade\|TIER_UPGRADE\|tier_upgrade_check' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-*.sh; ls /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-*.sh | wc -l`
9. `grep -n 'PostToolUse' /mnt/data/dev/task-planner-skill/skills/task-planner/lib/install-stub.sh; grep -n 'plan_tier\|plan-state' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-doc-sync.sh; echo "rc=$? (1=零命中)"`
10. `python3 -I -c "from datetime import datetime; datetime.fromisoformat('')" 2>&1 | tail -1; python3 -I -c "print(int((__import__('datetime').datetime.now(__import__('datetime').timezone.utc)-__import__('datetime').datetime.fromisoformat('2026-11-25T10:00:00').replace(tzinfo=__import__('datetime').timezone.utc)).total_seconds()//60))"`
11. `grep -n 'SOFT_ONLY\|仅 WARN' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh; sed -n '126,129p' /mnt/data/dev/task-planner-skill/plans/task-project-audit-20261123/forensics/plan-drift.md`
12. `sed -n '241,249p;269,305p' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-posttooluse.sh`
