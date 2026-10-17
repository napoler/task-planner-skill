# 交付总结 — task-v183 验证能力升级收口（关闭审计 dwfrun-04e929e0 遗留全部未解决问题）

## ① 说明（做了什么）
关闭审计工作流 `dwfrun-04e929e0`（技能验证能力升级）遗留的**全部 7 条未落地提案**，使 3 类已确认漏检（完成声称默认档 / 目标偏移 / 语义级产出质量）都有机器检查兜底。

逐条落地：
| 提案 | 缺陷面 | 落地 | 验证 |
|------|--------|------|------|
| **P-05** | periodic-review.sh `tr -d '*-#'` 反向区间→tr 报错→Rule 65 矛盾检测器 100% 死 | 三处改 `tr -d '*#-'`（尾连字符=字面）+ 头注 | 矛盾夹具 exit=1 / 干净 exit=0 |
| **P-02** | VC 真空命令（true/echo ok）无拦截 | 新增 check-vc-nonvacuous.sh | selftest 13/13 |
| **P-03** | 模糊步骤（「优化一下」）全链通过 | 新增 check-step-placeholders.sh | selftest 10/10 |
| **P-06** | 纯中文 Goal CJK 分词 locale 脆弱→漂移检测静默跳过 | 新增 check-goal-cjk.sh（纯 bash+awk+od 字节态机，locale 免疫） | selftest 11/11 |
| **P-07** | 门 fail-open 降级静默，故障与通过不可区分 | 新增 check-gate-degraded.sh（[gate-degraded] 留痕） | selftest 16/16 |
| **P-08** | R→VC 映射无机器校验 | 新增 check-rvc-coverage.sh（双向覆盖） | selftest 9/9 |
| **P-09** | 档位自声明无外部体量复核 | 新增 check-tier-consistency.sh | selftest 8/8 |
| **P-04** | 存量 73/145 命中 enforce 档位裁决 | 裁决=**warn**（保存量兼容）；当前 config 默认已=warn，**无需改 config** | config 现状确认 |

**P-10**（报告记的 selftest-vc-gate FAIL）经 `--fresh` 真值复跑证实为工作流并行期**瞬态，已自愈**（84/84 绿）。

## ② 产出（交付物，可定位）
- 修复：`skills/task-planner/scripts/periodic-review.sh`（P-05，3 处 tr + 头注）
- 新增 6 判定器：`skills/task-planner/scripts/check-{vc-nonvacuous,step-placeholders,goal-cjk,gate-degraded,rvc-coverage,tier-consistency}.sh`
- 新增 6 selftest：`skills/task-planner/scripts/selftest-{vc-nonvacuous,step-placeholders,goal-cjk,gate-degraded,rvc-coverage,tier-consistency}.sh`
- registry 登记：`skills/task-planner/scripts/selftest-registry.tsv`（+6 行，registry 行数 84→90）
- 计划簿记：`plans/task-v183-verif-closeout/{task_plan,progress,verification,findings,delivery-summary}.md`

## ③ 审查详细（如何验证）
- **逐 selftest**：6 新脚本自测全绿（13/10/11/16/9/8，Total 行 FAIL=0）
- **registry 一致性**：`selftest-registry.sh` → registry rows=90, actual selftest=90（T02/T03 双向一致）
- **全量回归**：`bash skills/task-planner/scripts/run-selftests.sh --fresh` → **Total: 90 PASS=90 FAIL=0**（基线 84→90，**0 新增失败**）
- **真实数据 smoke**：6 判定器对 `plans/task-v183-verif-closeout` 各跑一次，全 exit=0；`check-rvc-coverage` 另对 task-v146 报真阳性（VC-5 无 R 映射）
- **P-06 效果实证**：`check-goal-cjk` 对本计划 Goal 抽出 **15 个 CJK 词**（旧 `grep -oP '\w+'` 抽出 0）
- **P-05 效果实证**：`periodic-review.sh` 矛盾夹具 exit=1（检测器复活）、干净夹具 exit=0

## ④ 风险（必须列举）
1. **接线未做（非本任务范围）**：7 条新判定器本批只建独立脚本+selftest+registry，**尚未接入 check-complete 门链**（P-02/06/08 等消费侧接线为后续批次）。判定器可独立 `bash check-*.sh <plan-dir>` 调用，但自动门控需另开接线任务。
2. **P-04=warn 保留**：存量 73/145 计划不受 enforce 阻断；若日后要翻 enforce 需先清理存量。
3. **语义级机器检查仍缺失**（report §7.3 high）：全部机器检查止于格式/计数/存在性/词法/路径归属层，内容级张冠李戴（文件真实但内容无关）仍无机器兜底——本批未扩大该面（§四.6 文本优先，不擅自扩基建）。
4. **部署位未同步**：新增脚本在主仓 `skills/task-planner/scripts/`，`~/.zcode/skills` 等部署位未同步（归后续部署任务，需用户授权）。
5. **git 未提交**：全部改动在 master 工作树未提交（会话约束「禁止 git 写操作」，Rule 90 收尾快照需用户授权后执行）。

## ⑤ 下一步建议
- **可选·接线批次**：将 P-02/06/08/09 判定器接入 check-complete 门链（消费侧 shell-out + 档位键），另开任务。
- **可选·部署**：同步新脚本到 `~/.zcode/skills` 等部署位（需授权）。
- **可选·收口**：Rule 90 git 快照提交本任务改动（需授权 git 写操作）。
- **非阻塞**：语义级机器检查（§7.3 high）单独立项。
