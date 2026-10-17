# CR Gate 检查点 — task-v184 代码审查

- 审查对象: `git diff b83ad92..HEAD -- skills/`（30 文件，+1057/-61）
- 审查时间: 2026-10-17
- 审查方式: 只读（未修改任何文件；跑批用临时 /tmp 夹具，仓库零写入）
- 裁决: **APPROVED**（可进入终验交付；5 条 P3 建议 + 2 条 Nit，无 P1/P2）

## 审查范围与验证手段

| 文件 | 改动量 | 验证手段 |
|------|--------|---------|
| attest-plan.sh | +141（cksum 第 7 参数组 + 4 接线块） | 通读 + set 选项核对 + jq 路径实测 |
| check-complete.sh | +93（2 函数 + 2 调用点） | 通读 + 调用分支归属核对 + 范式对照 |
| check-3file-gate.sh | +66（第 6 条件 + 编号 6→7） | 通读 + set -e 安全性核对 |
| check-evidence-anchor.sh | +150（CLAIM_MATCH 层） | 通读 + 8 场景边界实测（/tmp 夹具） |
| config.json | +6 键 | properties 计数 + jq 路径实测 |
| selftest-gate-injection.sh | +400（新建） | 实跑 11/11 绿 |
| selftest-evidence-anchor.sh | +99（CLAIM-01..06） | 实跑 26/26 绿 |
| 23 个级联 selftest | 键数 47→53 等 | grep 抽查 + 3 个实跑（23/23、22/22、14/14） |

## 维度 1: 正确性 — PASS

**1.1 三态一致性（env > config > 默认）** — 一致。
- config.json 6 新键 default: 5×enforce + 1×warn(claim_match)，与各自 description 声明一致。
- jq 路径实测（config 为 JSON Schema 风格，键在 properties 下）:
  - `jq -r '.tier_consistency_enforce // .properties.tier_consistency_enforce.default // "enforce"'` → `enforce` ✓
  - goal_cjk → `enforce`（config default），claim_match → `warn` ✓
- attest-plan.sh:174-178（tier）/292-298（vnv）/324-331（rvc）/347-354（sp）四块 jq 回退 enforce，与 config 一致。
- check-3file-gate.sh:296 goal_cjk 回退 `warn` 仅覆盖「jq 缺失」环境降级（config description 明示「jq/config 缺失回落 warn」），非缺陷。

**1.2 fail-open 路径** — 与既有范式一致，不误放行真缺陷。
- 脚本缺失 → stderr `[gate-degraded]` 痕迹 + 放行（attest-plan.sh:232-233/306-307/337-338/363-364；check-complete.sh:802-805/846-849；check-3file-gate.sh:297-298）。
- rc=2（输入异常/无判定面）→ fail-open 放行，各调用点注释一致。
- 既有范式（check-complete.sh:753-763 run_evidence_anchor）同口径，判定器须先有判定面才 rc=1，fail-open 不掩盖真缺陷。

**1.3 rc 聚合** — 未被新块改变。
- check-complete.sh 新函数在 `if [ "$python_rc" -eq 0 ]`（:447）分支内，enforce FAIL 用 `exit 1`（:821/865）同既有 VC-GATE；warn/off `return 0`，不改 python_rc 聚合（末尾 `exit $python_rc` :2066）。
- attest-plan.sh 无 set -e（`set -uo pipefail` :22），`bash "$tc_script"; tc_rc=$?`（:181）rc 捕获安全，warn 档不会误触发退出。
- check-3file-gate.sh 有 set -e（`set -euo pipefail` :50），新代码 `_gcj_out="$(bash ...)" && _gcj_rc=0 || _gcj_rc=$?`（:305）用 OR 列表保护，安全（注释 :304 已声明）。
- check-evidence-anchor.sh `set -u`（:82）无 set -e，claim_match_check 内无 rc 捕获风险。

**1.4 cksum 第 7 参数组对齐** — 对齐。
- attest-plan.sh:85-88：`printf '%s|%s|%s|%s|%s|%s|%s'`（7 个 %s）对应 7 组实参（hash/skip_dispatch/skip_template/skip_fmea/skip_vc/三env组/五env组），第 7 组含 5 新 env（VC_NONVACUOUS/RVC_COVERAGE/STEP_PLACEHOLDER/TIER_CONSISTENCY/GOAL_CJK）。档位枚举 enforce/warn/off 不含 `|`，不破坏组结构。

## 维度 2: 注入验收真实性 — PASS

**2.1 走真实门链（非自说自话）** — 是。
- GI-01/02（vc-nonvacuous 负/正）、GI-03/04（rvc-coverage 负/正）走 `bash "$CC"`（check-complete.sh 真实门链），实跑 11/11 绿。
- GI-09/10（goal-cjk 负/正）走 `bash "$CG"`（check-3file-gate.sh 真实门链），实跑绿。
- GI-11 档位矩阵抽验（env=off rc 1→0 转变），实跑绿。

**2.2 双向锁定** — 成立。
- 每门负例（注入缺陷→拦截 rc≠0 含门标签）+ 正例（缺陷消除→rc=0 含 ✓）成对。
- GI-11 第三向（档位降级 rc 转变）补全矩阵。

**2.3 守护缺口（P3-1）** — GI-05/06/07/08 是**判定器直测**（`bash "$SP"`/`bash "$TC"`）+ attest **静态锚**（`grep -c 'task-v184-S3' "$ATTEST"`，:295/335）。静态锚命中注释行（attest-plan.sh:164/353 各 1 处），「删代码保留注释」时假 PASS。头注如实声明降级（:9-12「判定器直测 + attest 静态锚」），非欺骗；但 attest 侧接线无行为回归（attest 走真实门链需完整 plan 夹具，成本高，未做）。

## 维度 3: CLAIM_MATCH 层 — PASS

**3.1 分层档位不影响既有路径层 rc** — 确认。
- check-evidence-anchor.sh:373 `claim_match_check` 在 `if [ "$FAILS" -gt 0 ]` 出口**之前**调用。
- warn 档：仅 `printf '[claim-mismatch] ⚠ ...'`，不改 FAILS（:448-451）；off 档：`return 0` 整层跳过（:388）；enforce 档：`FAILS=$((FAILS + 1))`（:445）计入 rc=1。
- CLAIM-06 双向验证「零声明面夹具 → 无 claim-mismatch 且 ✓ 证据锚全过」（实跑绿），证明既有路径层 rc 等价性。

**3.2 形态正则边界** — 字符串等值（非数值解析），8 场景实测全符合预期（/tmp 夹具，跑毕即删）：
| 场景 | 声明 | 文件内容 | 实测 | 预期 |
|------|------|---------|------|------|
| A 右边界 | PASS=90 | PASS=900 | mismatch | ✓ 不误当 90 |
| B 键分离 | Total: 90 PASS=90 | PASS=90 | mismatch(Total) | ✓ 逐键核对 |
| C 文件侧空格 | PASS=90 | PASS= 90 | mismatch | ✗ 误报面（warn 兜底）|
| D 异键 | PASS=90 | Total: 90 | mismatch | ✓ 不互等 |
| E 声明侧归一 | Total:  90 | Total: 90 | clean | ✓ tr 归一有效 |
| F 精确等 | PASS=90 | PASS=90 | clean | ✓ |
| G 前导零 | rc=0 | rc=00 | mismatch | ✓ 字符串等值 |
| H 左边界 | PASS=90 | XPASS=90 | mismatch | ✓ 防 XPASS 命中 |

- 「Total: N PASS=N 中 N 的数值比对」= **字符串等值**（grep 正则字面），非数值解析。对 `Total: 90 PASS=90` vs `PASS=90` 变体：逐键核对，声明含 Total 而文件无 Total 行 → missing（声明了就要有，合理）；声明仅 PASS 而文件含 Total+PASS → PASS 命中不报。不会漏报（文件缺键即报），不会把 Total 当 PASS 互等。

**3.3 误报面（P3-2）** — 文件侧 `PASS= 90`（等号后空格）不归一 → mismatch。真实证据文件（run-verification.sh 输出）格式固定，且默认 warn 档兜底，属「146 存量误报基线」量化对象，头注已声明（check-evidence-anchor.sh:57-58「数字子串」）。

## 维度 4: 级联准确性 — PASS

**4.1 53 键断言与 config 一致** — 一致。
- `jq '.properties | keys | length'` 实测 = 53。
- 抽查 3 个 selftest 键数断言：selftest-channel-fast-fail.sh:45-46（CF-03=53）、selftest-requirement-coverage.sh:167（RC-13=53）、selftest-lane-advancement.sh:93（=53）均更新到位。
- 全局 grep 确认 10+ 处 47→53 级联完整。

**4.2 历史注释未误改** — 确认。
- 所有注释改动均为必要级联：47→53（键数基线演进）、84.1-84.6→84.1-84.7（VG-02 子条）、新增 task-v184-S* 标记。
- 无与本次改动无关的注释改动（grep 全量 diff 扫查）。

**4.3 selftest 行为隔离** — RVC 隔离 6 处（EA-16/17/19 + RC-2/19/20 + final-gate-hash run_cc），必要（既有夹具普遍无 R→VC 映射表，RVC 默认 enforce 会抢先 exit 1）。

## 维度 5: 可维护性 — PASS（有改进建议）

**5.1 同构接线块重复度（P3-3）** — attest-plan.sh 4 块（tier:174-215 / vnv:289-322 / rvc:327-360 / sp:347-378）结构完全同构（tier 解析 + 脚本检查 + rc 三分支 + fail-open + exit），每块 ~30 行共 ~120 行重复。
- 当前可接受：克隆范式与 check-complete.sh run_evidence_anchor 一致（仓库既有风格），四块行为一致性强。
- 建议（非必须）：抽通用函数 `run_shell_gate <env_var> <config_key> <script_path> <label> <fail_msg>`，4 块各 1 行调用，后续新增门成本 1 行而非 30 行。
- check-complete.sh 的 resolve_*_tier 已部分抽象（每门 1 个 resolve 函数 + 1 个 run 函数），与 attest 的 inline 解析风格不同但同效。

**5.2 注释 What/Why 完整性** — 完整。
- 每接线块含：日期 + task-v184-S* 标记 + What（机制）+ Why（审计/report 依据）+ 档位解析链 + fail-open 说明 + 降档 env 提示。符合 Rule 45 双层注释。
- check-3file-gate.sh:37-45 修改说明块 What/Why/兼容三要素齐备。
- selftest-gate-injection.sh 头注 What（守护对象+11 断言清单）+ Why（机制锚）+ 运行方式 + 依赖。

**5.3 隔离面不完整（Nit-1）** — 既有 selftest 只隔离了 RVC_COVERAGE（6 处），未隔离 VC_NONVACUOUS/STEP_PLACEHOLDER/TIER_CONSISTENCY/GOAL_CJK。当前无缺陷：既有 selftest 夹具 VC 命令均为真实命令（grep 无 `Verify command: true`），步骤无占位符，plan_tier 均 standard，新门不触发。但未来若夹具引入真空 VC 或占位步骤，新门会抢先 exit 1 干扰既有断言。建议补隔离或加注释声明夹具免疫前提。

## 发现清单（无 P1/P2）

| 编号 | 严重度 | 对象 | 问题 | 建议修法 |
|------|--------|------|------|---------|
| P3-1 | P3 | selftest-gate-injection.sh:295,335 | GI-05/07 attest 静态锚 grep 注释 ID（task-v184-S3/S4），「删代码保留注释」假 PASS；attest 接线无行为回归 | 改 grep 稳定锚（如 `bash "$sp_script"` 或 `check-step-placeholders.sh` 脚本名）；或补 attest 行为注入（完整 plan 夹具走 attest 拒锁） |
| P3-2 | P3 | check-evidence-anchor.sh:433-441 | 文件侧 `PASS= 90`（等号后空格）不归一→mismatch 误报面 | warn 兜底已足；若要收紧，文件侧 grep 前加 `tr -s '[:space:]' ' '` 归一（与声明侧 claim_pairs_from_ev 对称） |
| P3-3 | P3 | attest-plan.sh:174-378 | 4 同构接线块 ~120 行重复 | 抽通用 run_shell_gate 函数（非必须，当前克隆范式一致可接受） |
| Nit-1 | Nit | 既有 selftest 隔离面 | 只隔离 RVC，未隔离 VC-NONVACUOUS/STEP-PLACEHOLDER/TIER-CONSISTENCY | 补 env=off 隔离或注释声明夹具免疫前提 |
| Nit-2 | Nit | check-3file-gate.sh:305 | `2>/dev/null` 与 evidence-anchor 头注「caller 不得裹 2>/dev/null」约定有张力 | 判定器明细走 stdout（已确认），裹 stderr 不影响判定；但诊断可见性弱于约定，建议改 `2>&1` 或注释声明例外 |

## 验证协议（复现证据）

- jq 路径实测: 4 门 enforce + goal_cjk enforce + claim_match warn（见 1.1）。
- 边界实测: 8 场景全 OK（见 3.2 表）。
- selftest 实跑: gate-injection 11/11、evidence-anchor 26/26、requirement-coverage 23/23、final-gate-hash 22/22、lane-advancement 14/14（均 PASS）。
- 全量跑批: 90 个注册 selftest（registry 92 行含表头+空行）后台执行 **300s 工具超时中断**（exit 124，非 FAIL；中断前无任何 FAIL 行输出）。**未完成全量绿确认**——已实跑的 5 个关键 selftest（gate-injection/evidence-anchor/requirement-coverage/final-gate-hash/lane-advancement）全绿，级联键数另经 jq/grep 静态核对。全量 90/90 绿以提交信息 + 计划记录为准（本审查未独立复现）。

## 裁决

**APPROVED** — 可进入终验交付。

理由:
1. 无安全漏洞/数据丢失/竞态/API 破坏（P0 面无命中）。
2. 正确性四维（三态/fail-open/rc 聚合/cksum 对齐）全部经实测确认。
3. 注入验收走真实门链双向锁定，守护缺口（GI-05/07 静态锚）已如实声明降级。
4. CLAIM_MATCH 分层档位经双向验证不影响既有路径层 rc，数值边界 8 场景全符合预期。
5. 级联 53 键与 config 实际一致，历史注释未误改。
6. 5 条 P3 + 2 条 Nit 均为改进建议，不阻断交付。

风险与未收敛面（如实披露）:
- attest 侧接线（P-02/P-03/P-08/P-09）在 attest-plan.sh 无行为级 selftest（仅静态锚），接线静默断裂风险由「判定器直测 + attest 静态锚」降级守护。终验期消费面（check-complete.sh）有 GI-01/02/03/04 行为回归覆盖。
- CLAIM_MATCH  enforce 档当前默认 warn（存量误报基线观察期），误报收敛后升 enforce（分档裁决范式）。
- goal_cjk 的 FAIL 路径（Goal 含 CJK 但 0 词）在 GI-09 中未单独触发（靠 drift-gate 或逻辑拦截），因真实分词器对常见中文能抽出词，难以构造 0 词夹具。
