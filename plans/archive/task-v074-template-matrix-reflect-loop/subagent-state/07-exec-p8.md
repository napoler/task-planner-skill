# S1 check-scope.sh 哨兵误拦修复（D10'' attestation 仲裁）— 完成检查点

时间：2026-09-16 | 执行体：executor（sonnet 档）| 状态：✅ complete

## 改动
- 文件：/mnt/data/dev/task-planner-skill-worktrees/task-v074-p8fix/skills/task-planner/scripts/check-scope.sh（153→180 行）
- 插入位置：D10' mtime 判定块（:106-123）之后、既有拦截 echo（原 :126）之前，新增 D10'' 分支（:125-150）
- 注释锚：`[2026-09-15 task-v074 P8] D10'' attestation 仲裁，fail-closed`（:125）

## D10'' 三条件（全满足才 exit 0，任一缺失走既有拦截，不放宽）
1. 本会话 side 指针存在：`$ROOT/plans/.active_plan_side/$_sidkey.active_plan` 或 `sess$_sidkey.active_plan`（两形态循环试）
2. 指针内容非空（= 计划目录名）且 `$ROOT/plans/<目录名>/task_plan.md` 存在
3. 同目录 `.plan-attestation` 存在，其 `plan_sha256=` 字段（sed 提取，大小写不敏感 tr A-F→a-f）与 `sha256sum task_plan.md` 一致
   - 格式依据：实读主仓 plans/task-v074-template-matrix-reflect-loop/.plan-attestation（attest-plan.sh:109 写 `plan_sha256=<hash>`）

## 自测证据（/tmp 沙箱，真实 sha256，全部 PASS）
- `bash -n` → SYNTAX_OK
- case1（哨兵旧 epoch + side 指针 + 计划 + 有效 attestation）→ exit 0 ✅
- case2（同上但 attestation hash 篡改 deadbeef…）→ exit 1 ✅
- case3（无 side 指针新会话模拟，仅哨兵）→ exit 1 ✅
- case4（无哨兵）→ exit 0 ✅（现状回归）
- case4b（无哨兵 + sess 前缀指针 + 大写 hash）→ exit 0 ✅
- case5（有哨兵 + sess 前缀指针 + 大写 hash）→ exit 0 ✅（大小写不敏感验证）
- case5b（同 case5 场景篡改 hash）→ exit 1 ✅
- /tmp 沙箱已清理（rm -rf，CLEANED ×2）

## 防护不弱化论证
- 新会话无 side 指针 → for 循环两文件均不存在 → `_d10pp_plan_dir` 空 → 不进入 D10'' → 走既有拦截（case3/case5b 实证）
- attestation 被篡改 → hash 不等 → 不命中（case2/case5b 实证）
- `set -eu` 兼容：`|| true` / head / tr 管道均在赋值内，无裸管道在 set -e 上下文中触发（head 致 SIGPIPE 风险被 `|| true` 兜住）

## 遗留提示（供 S3/主进程）
- 本分支仅影响有会话 side 指针的恢复路径；global/legacy 哨兵路径行为不变
- 未改主仓与部署位（worktree 内改动，待主进程合并部署）

# S2 check-complete.sh VC-GATE 兼容 - **V-N:** 紧凑格式（D11）— 完成检查点

时间：2026-09-16 | 状态：✅ complete

## 改动（worktree scripts/check-complete.sh + selftest-vc-gate.sh）
- vcgate_grep_map：并集第二模式 `^[[:space:]]*-[[:space:]]*\*\*V-N:[[:space:]]*\*\*.*VC-[0-9]+`，行去重计数
- vcgate_count_substantive：新增第 3 参 vc_defs；compact 行去重计 1，且其引用的全部 VC token 须 ∈ vc_defs（`grep -qxF -f` 逐字匹配，fail-closed；vc_defs 空=无 VC 表时兼容放行=既有语义）
- 逐 Phase 段阈值自适应 `_vn_thresh`：段内无逐 P-N 行且存在 compact 行 → 1（v065 起 compact 格式每段仅 1 行整行映射）；否则保持 2（novn/逐 P-N 段不放松）
- 映射目标校验段（原 :536-540）：VC token 提取改为「逐 P-N 行 + compact 行」并集后对照 vc_defs，紧凑行中未定义 VC（如 VC-99）仍报「映射目标缺失/未定义 VC」
- selftest-vc-gate.sh 追加 T08（compact 合规 → PASSED）/T09（compact 引用 VC-99 → enforce FAILED + 映射目标缺失）；T03 断言保持 `0 < 2`（novn 无 compact 行，阈值 2，回归保护）

## 自测证据
- `bash -n` 两脚本 SYNTAX_OK
- `bash selftest-vc-gate.sh` → Total: 11 PASS=11 FAIL=0（T01-T09 全 PASS，含旧 T01-T07 回归）
- 真实计划：`bash check-complete.sh /mnt/data/dev/task-planner-skill/plans/task-v074-template-matrix-reflect-loop/task_plan.md` → rc=1（P8 阶段 3/4 未完成属正常），输出中「V-N 映射 0 < 2」不再出现（compact 行已被计入）
- 全量 selftest（19 脚本）：15/12/38/18/16/11/7/8/12/11/11/11/16/11/13/17/31/16/19 PASS，全部 FAIL=0
- /tmp 测试夹具已清理

## 关键裁定
- compact 段 vn_total>vn_sub 的 target_bad 判定对 compact 行不再产生误报（vn_total 去重后 = vn_sub = 1）
- vn_thresh 探测放在 rm segf 之前（_compact_grep 基于 segf 内容）；set -u 兼容（${_x:-0}）

# S3 文档联动 13 处 + CHANGELOG — 完成检查点（含重大偏离说明）

时间：2026-09-16 | 状态：✅ complete（在主仓验证，见 deviations）

## 重大偏离（必须主进程知悉）
- 派发指定的 worktree /mnt/data/dev/task-planner-skill-worktrees/task-v074-p8fix **已不存在**（目录被清理）；
  S1/S2 的全部编辑（check-scope D10''、check-complete D11、selftest T08/T09）此前已落地且被主进程
  合并进 master：commit 10ba3d1（fix(task-v074/P8)，10 files +169/-47）→ merge 0f85da8 → 簿记 fd4116a/4504c4b。
  即 S3 文档 13 处 + CHANGELOG v074 条目实际已由主进程随 10ba3d1 一并完成。
- 本检查点因此执行「主仓实跑复核」替代 worktree grep（主仓 = 合并后状态）。

## 逐项 grep 复核结果（主仓 /mnt/data/dev/task-planner-skill，全部通过）
| 规格项 | 复核命令/位置 | 结果 |
|---|---|---|
| critical-rules :59 "13 类"+rule-enhancement 枚举 | grep -n "共 13 类" → :59 含 rule-enhancement | ✅ |
| critical-rules :283 "13 变体" | grep -n "13 变体" → :283 | ✅ |
| critical-rules :289 "既有 13 变体" | :289 命中 | ✅ |
| template-mapping :26 "既有 13 类" | :26 命中 | ✅ |
| template-guide :32 "13 个" | :32 `### 2.2 Variant 模板（13 个…` | ✅ |
| template-guide :48 变体表 rule-enhancement 行 | :48 `\| variant/rule-enhancement-type.md (v2,沉淀) \| 技能规则增强/新增 Rule/门控守护 \| 条款锚 / 三档键 / selftest 守护 \|` | ✅ |
| template-guide :60 "13 variant = 21" | :60 命中（含 2026-09-16 P8 核对注记） | ✅ |
| 验收命令实跑 | `grep -rl '## 📚 必要知识储备' templates/ \| wc -l` = 21 | ✅ |
| CHANGELOG [Unreleased] v074 条目（Rule 33/34/init env/VC-GATE/D10''/SKILL 联动） | :12-21 全段齐（Added+Changed 风格对齐） | ✅ |
| CLAUDE.md :32 "Rules 1-34" | 命中 | ✅ |
| CLAUDE.md :70 新模板指引（三点登记+init 白名单动态派生免改脚本） | `### 添加新模板` 段含 "init-session.sh 白名单自 variant/ 目录动态派生，无需改脚本" | ✅ |
| README_zh :134/:227 "Rules 1-34" | 双处命中 | ✅ |
| INSTALL_zh 清单重生成 | 清单段含 scripts 55 个/templates 核心 6+辅助 4+variant 13/references 12/总大小 1.3M；:267 `TASK_TEMPLATE_TYPE=bugfix bash … init-session.sh smoke-test` env 示例 | ✅ |
| 全仓残留活断言 | grep "Rules 1-10\|12 类\|12 变体" → 仅 CHANGELOG:21 描述性"12→13 修正记录"（非活断言，合规保留） | ✅ |
| 全量 selftest | 19 脚本逐个 bash 全 PASS/FAIL=0 | ✅ |

## 负结果报告
- 检查了 13 处文档改动点 + CHANGELOG + INSTALL 清单 + 2 个脚本 + selftest：全部在位且与规格一致。
- 未发现 12 类/12 变体/Rules 1-10 活断言残留（CHANGELOG 历史描述除外）。
- 排除风险：主仓 plans/ 簿记文件（attestation/sentinel/session-owner）的 git status 脏点属会话运行时产物，非本任务写入。
