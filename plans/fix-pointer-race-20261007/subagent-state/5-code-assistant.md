# Subagent Checkpoint 5-code-assistant — Phase4b CR 修复落地

状态: done（2026-10-07）

## 修改摘要（worktree: /mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race/skills/task-planner/scripts/）

1. **init-session.sh**（~629-652 行两级兜底块）sidmap 权威化：
   - 第①级：`_mapped` 采用不再要求目标哨兵 `${_sent_dir}/${_mapped}.plan_required` 存在（目标哨兵已被正常清除属常态）；echo 文案补「目标哨兵缺失属已清除常态」。
   - 第①级前置设 `_sidmap_checked=0`，读到 sidmap 文件存在即置 1（无论映射是否有效）；第②级 guard 追加 `[ "$_sidmap_checked" -eq 0 ]`。sidmap 损坏（_mapped 空）→ 同样跳过 ②（fail-conservative，指针按 env sid 落盘）。
   - 修后语义：① sidmap 在→用映射键；② 无 sidmap→新鲜窗探测；③ 其余→env key 原样。

2. **plan-created.cjs** `sentinelFallbackSidkey`（~77-120 行）同语义权威化：
   - `mapPath` 存在即置 `sidmapAuthoritative=true`（声明移入 try 前）；mapped 有效且 ≠primaryKey 即 return mapped（不再要求 mapped 哨兵存在，console.log 补同文案）；mapped 无效不 return。
   - ② 探测前 `if (sidmapAuthoritative) return primaryKey;`（有身份记录绝不探测，防误删他会话哨兵）。T12h 语义自查通过（映射目标哨兵存在时仍 return mapped，清理照旧）。

3. **resolve-plan-dir.sh** 步骤 1（~58-75 行）env-only 调用方 sidmap 转译：
   - 双形态（`${SID}` / `sess${SID}`）保持优先；两者皆 miss 且 `${PLAN_ROOT}/.plan_required_side/${SID}.sidmap` 存在时，读第一行剥非字母数字取前 40 得 `_mapped_sid`，非空且 ≠SID 则 for 循环顺序探测候选 `${SIDE_DIR}/${_mapped_sid}.active_plan` → `${SIDE_DIR}/sess${_mapped_sid}.active_plan`（存在即选定 break）。TTL/slug 校验逻辑不变仍作用于最终 SIDE_FILE。注释说明动机：init 经 sidmap 把指针落 hook 键名后，env-only 调用方（allow-direct/check-delegation/plan-doctor/posttooluse 清锁/attest 回退）无第二参 sid 需转译命中。

4. **selftest-active-plan.sh**：
   - T12g 判别力加固：主哨兵 62e7uuiddeadbeef.plan_required `touch -d '5 minutes ago'`，另写当前时间诱饵 decoy9999aaaa.plan_required；断言追加 `! -e decoy9999aaaa.active_plan`（直配命中优先于新鲜窗探测，CR 变异实测：无 direct-strip 时会落 decoy）。
   - 新增 T12j（init sidmap 权威+防抢负例：sidmap=038ddeadbeef 无哨兵 + 新鲜诱饵 freshdecoy000001 → 指针落 038d…，诱饵键指针不产生）、T12k（cjs 同语义：deadbeef77→aaaa7777bbbb 无哨兵 + 新鲜哨兵 othercccc1111 → rc=0 且 othercccc1111 哨兵留存）、T12l（resolve env-only 转译：指针 aa00hookdead0001.active_plan=bb + sidmap bb00envdead0001→aa00hookdead0001，无第二参 env-only 调用 → 输出 $R12L/plans/bb/task_plan.md）。
   - 文件头用例清单注释同步补 T12g 加固/T12j/T12k/T12l。

## 验收输出

### a) 语法检查
```
$ bash -n init-session.sh resolve-plan-dir.sh selftest-active-plan.sh && node --check plan-created.cjs
SYNTAX_OK   (全过)
```

### b) selftest-active-plan.sh
```
T01..T14 全 PASS
T12g PASS 12g
T12j PASS 12j
T12k PASS 12k
T12l PASS 12l
Total: 29 PASS=29 FAIL=0
EXIT=0
```

### c) 定向回归
```
$ bash selftest-execution-stability.sh（末 5 行）
[PASS] T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(...)
[PASS] T13a S5 正例: 陈旧计划+verification.md → POSTTOOL 输出无 plan-compass/plan-sync 提醒(兜底豁免生效)
[PASS] T13b S5 因果对照: 同 fixture 删 verification.md → 输出含 plan-compass/plan-sync 陈旧提醒(...)
[PASS] T12 B2 三侧 canon 一致 (pretooluse L17 / UPS L34 / jq 全链路, sid=sess-abc123)
Total: 19  PASS=19  FAIL=0   EXIT=0

$ bash selftest-delegation.sh（末 5 行）
PASS  T_RATE_OK rate>=floor exit0 且比较式 1 处  (exit=0)
PASS  T_RATE_LOW rate<floor exit1  (exit=1)
----------------------------------------
Total: 38    PASS=38  FAIL=0
EXIT=0
```

## 结论
done。4 项 CR 发现全部落地，无 FAIL；未触碰列表外路径，无 git 写命令；生产脚本与规格无冲突（未需回报裁决项）。
