# S34-general-purpose 检查点（task-v184 S3+P-03 / S4+P-09 合并执行）

执行体: general-purpose；两单元同改 attest-plan.sh 串行合一，[align] 排程优化。
仓库: /mnt/data/dev/task-planner-skill。config 五键 S2 已前置落位，本任务零 config 改动零级联。

## M1 契约（前置 Read 实录）

### check-step-placeholders.sh（P-03 判定器）
- 参数契约: `<plan-dir>`（读取面 = `<plan-dir>/task_plan.md`，头注「输入: <plan-dir>/task_plan.md（唯一读取面）」）
- 扫描面: 仅 `### Phase N` 起、下一 `## ` 标题止的段内 `- [ ]` / `- [x]` 步骤行（Phase 外散文不进判定面）
- 判定（两步 AND）: ① 模糊动词字面命中（词表 `优化一下|处理一下|看看|检查下|完善|提升|改进一下|做一下|搞定|跑一下测试|等`）∧ ② 无任何具体锚（路径 token / .ext / ≥2 连续 ASCII 词）= 占位
- 输出: `[step-placeholder] ✗ <行号> 不可执行步骤: <原文>`
- 退出码: 0=无缺陷; 1=存在占位步骤; 2=plan-dir/task_plan.md 缺失
- → 调用用 `"$plan_dir"`（plan-dir 契约，无需换 plan_file）

### check-tier-consistency.sh（P-09 判定器）
- 参数契约: `<plan-dir>`（`用法: bash check-tier-consistency.sh <plan-dir>`）
- 声明抽取: `^plan_tier:` / `^execution_lane:` 行首锚定（排除 HTML 注释伪声明）
- 体量指标: lines / phases（`^#{2,4} Phase[数字]`）/ vc（`VC-N` 去重）/ sunit（`S-N` 去重）/ scope（「执行范围限制」表数据行）
- 判定: 仅当声明 mini 或 L0/L0-T 时触发
  - mini 体量复核（Rule 38.1 四条件机器近似）: phases > 2 ∨ vc ≥ 5 ∨ sunit ≥ 3 ∨ lines > 150
  - L0 禁滥用复核: 多 Phase ∨ 多文件（scope > 3）∨ 重门控（sunit ≥ 3）
- 输出: `[tier-consistency] ✗ ...` / `[tier-consistency] SKIP (无档位声明 ...)`
- 退出码: 0=一致（或无判定面）; 1=不一致; 2=输入缺失
- → 调用用 `"$plan_dir"`（plan-dir 契约，无需换 plan_file）

## M2 双接线

### 接线 1（S3/P-03）— 计划步骤占位符接线
- 插入位置: P-08 块（原 282-314）后、VC 门段内（`if [ ! -f "$vfile" ]` else 体），现 350-384
- 替换项: 脚本→check-step-placeholders.sh; rvc_→sp_（sp_tier/sp_script/sp_rc）; [rvc-coverage]→[step-placeholder]; 键 step_placeholder_enforce / env TASK_PLANNER_STEP_PLACEHOLDER_ENFORCE / 默认 enforce
- 注释头: `[2026-10-17 task-v184-S3/P-03] 计划步骤占位符接线` + What（Phases 段步骤行硬占位符+软模糊词，上方门链只看结构不看步骤可执行性=漏检类③）/ Why（R1+report §5 P-03 接线+判定器内分档，enforce=enforce 时 rc=1 拒锁）
- 调用: `bash "$sp_script" "$plan_dir"`（plan-dir 契约，无需适配）
- 档位解析: env > config.json `.step_placeholder_enforce // .properties.step_placeholder_enforce.default` > enforce（回退链与 P-08 同构）

### 接线 2（S4/P-09）— 档位声明外部复核接线
- 插入位置: template-tier 解析段（resolve_template_tier，原 120-160）整段尾、需求门（51.1）之前，现 161-195。选此位置因 attest 无独立 plan_tier 复核段，template-tier 段是「档位解析」语义最近邻；先于需求门执行=先校验 plan_tier 声明再供 51.1 mini 豁免消费
- 替换项: 脚本→check-tier-consistency.sh; sp_→tc_（tc_tier/tc_script/tc_rc）; [step-placeholder]→[tier-consistency]; 键 tier_consistency_enforce / env TASK_PLANNER_TIER_CONSISTENCY_ENFORCE / enforce
- 注释头: `[2026-10-17 task-v184-S4/P-09] 档位声明外部复核接线` + What（plan_tier 自声明 vs Rule 38.1 体量判据外部复核=mini/L0 滥用入口）/ Why（R1+report §5 P-09 复用 38.1 判据为单一 truth source）
- 调用: `bash "$tc_script" "$plan_dir"`（plan-dir 契约，无需适配）
- 档位解析: env > config.json `.tier_consistency_enforce // .properties.tier_consistency_enforce.default` > enforce

### config.json 键位复核
- step_placeholder_enforce: 仅在 `properties.*.default` 路径（default=enforce），顶层无此键 → jq 走 `.properties.*.default` 回退
- tier_consistency_enforce: 同上
- 零 config 改动确认: 未触碰 config.json

## M3 验收证据

### 验收 1: bash -n + 锚计数
```
$ bash -n skills/task-planner/scripts/attest-plan.sh
rc=0
$ grep -c 'task-v184-S3\|task-v184-S4' skills/task-planner/scripts/attest-plan.sh
2
$ grep -n 'task-v184-S3/P-03\|task-v184-S4/P-09' skills/task-planner/scripts/attest-plan.sh
161:    # [2026-10-17 task-v184-S4/P-09] 档位声明外部复核接线。
350:          # [2026-10-17 task-v184-S3/P-03] 计划步骤占位符接线。
```

### 验收 2: 夹具 A 占位步骤（直测）
- 夹具: plans/.fixture-s34a/task_plan.md（`### Phase 1` 段内 `- [ ] 优化一下性能`）
- 命令: `bash skills/task-planner/scripts/check-step-placeholders.sh plans/.fixture-s34a`
- rc=1；关键行: `[step-placeholder] ✗ 7 不可执行步骤: - [ ] 优化一下性能`

### 验收 3: 夹具 B 档位漂移 + 对照（直测）
- 夹具 B: plans/.fixture-s34b/task_plan.md（`plan_tier: mini` + 3 Phase + 6 文件 scope + 5 VC）
- 命令: `bash skills/task-planner/scripts/check-tier-consistency.sh plans/.fixture-s34b`
- rc=1；关键行: `[tier-consistency] ✗ ... Phase 数=3（> 2, mini 应 ≤2 Phase）` + `VC 数=5（≥5 达 standard 级...）`
- 对照干净夹具: plans/.fixture-s34b-clean/task_plan.md（`plan_tier: mini` + 2 Phase + 1 文件 + 0 VC）
- 命令: `bash skills/task-planner/scripts/check-tier-consistency.sh plans/.fixture-s34b-clean`
- rc=0；关键行: `[tier-consistency] ✓ 档位声明与体量一致（plan_tier=mini ... phases=2 vc=0 sunit=0 scope=1）`

### 验收 4: selftests vc-gate
```
$ bash skills/task-planner/scripts/run-selftests.sh --only vc-gate
[run]    selftest-vc-gate (rc=0 PASS=11 FAIL=0)
Total: 1 PASS=1 FAIL=0 (run=1 reused=0)
selftest rc=0
```

### 验收 5: 清理 + git 状态
```
$ rm -rf plans/.fixture-s34a plans/.fixture-s34b plans/.fixture-s34b-clean
残留: <无>
$ git status --short | grep -i 'fixture\|attest-plan'
 M skills/task-planner/scripts/attest-plan.sh
```

## 限制与风险
- 接线层 attest 未实测锁主仓活跃计划（与 S1/S2 同限：无路径参数模式禁锁活跃计划）；验收面=静态 grep 锚 + 判定器直测 + selftests vc-gate
- 门结果缓存 cksum（attest-plan.sh:85）未纳入新两 env（TASK_PLANNER_STEP_PLACEHOLDER_ENFORCE / TASK_PLANNER_TIER_CONSISTENCY_ENFORCE）：与 S2 P-02/P-08 接线同口径（S2 亦未更新 cksum）。后果=翻转新门档位时可能回放陈旧 PASS 缓存；因仅 rc=0 写缓存，方向为 enforce→warn 时 PASS 回放实际安全（warn 更宽松），warn→enforce 时存在陈旧 PASS 缺口。建议后续统一补 cksum（本次守「零级联」未动）
- 夹具 B 触发依赖 phases/vc（判定器 mini 复核机器近似面），非纯文件数（文件数仅 L0 复核用）；夹具含 ≥6 文件 scope 以贴合任务描述

## 未做事项
- 未改 config.json（零 config 改动，两键 S2 已落位）
- 未改 check-step-placeholders.sh / check-tier-consistency.sh（判定器本体不动，仅接线）
- 未改门结果缓存 cksum（见风险）
- 未做 git 写（无 add/commit/stash/merge）

## checkpoint 路径
/mnt/data/dev/task-planner-skill/plans/task-v184-proactive-error-review/subagent-state/S34-general-purpose.md
