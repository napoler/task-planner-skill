# 交付总结 — task-v184 主动错误发现与内容审查能力升级

## ① 说明（做了什么）

回应你的诊断「当前技能核心偏记录/收集信息」：把 v183 已落地但**从未被自动调用**的 7 个判定器中的 5 个接进自动门链（审计终审原话——不接线=「检测器发货即死」），并补齐你最核心诉求的**内容错误审查层**（机器层+规则层双轨）。

| 层 | 交付 | 生效时点 |
|----|------|---------|
| 规划期拦截 | P-02 真空 VC 命令 / P-08 R→VC 缺映射 / P-03 占位模糊步骤 / P-09 档位虚报 → attest-plan.sh 锁定门 | 计划锁定时 |
| 翻转期拦截 | P-06 纯中文 Goal 跑题（148 语料 0 误报数据驱动 enforce）→ check-3file-gate 第 6 条件 | Phase 翻 complete 时 |
| 终验期拦截 | P-02/P-08 → check-complete VC-GATE 段 | 交付终验时 |
| 内容机器层 | CLAIM_MATCH：证据格里声明的结果串（Total/PASS=/FAIL=/exit= 形态）与证据文件**实际内容**交叉核对，不符即报（warn 起步） | 终验期（check-evidence-anchor 内） |
| 内容规则层 | **Rule 84.7 内容审查门**：内容型交付终验前必须独立子代理内容审查（四维度：张冠李戴/数字事实/需求覆盖/错误残留）+结论落盘 | verification-gate 卫星（对后续所有计划生效） |

## ② 产出（交付物，可定位）

- 接线：`skills/task-planner/scripts/attest-plan.sh`（+3 块）/ `check-complete.sh`（+2 函数+2 调用）/ `check-3file-gate.sh`（第 6 条件）
- 内容层：`skills/task-planner/scripts/check-evidence-anchor.sh`（CLAIM_MATCH 层 +145 行）
- 规则条款：`skills/verification-gate/references/critical-rules-verification.md`（84.7 子条）+ `SKILL.md`（引用行）
- 配置：`skills/task-planner/config.json`（+6 档位键，53 键）
- 行为回归：`skills/task-planner/scripts/selftest-gate-injection.sh`（新，11 注入断言）+ `selftest-evidence-anchor.sh`（CLAIM-01..06）+ registry 91 行
- 前序收口：v183 六轮簿记补账→check-complete exit 0+Rule 90 首锚 b83ad92（67 文件落库）
- 本计划全套：`plans/task-v184-proactive-error-review/`

## ③ 审查详细（如何验证）

- **注入式验收**（真实门链，非脚本自测）：`bash skills/task-planner/scripts/selftest-gate-injection.sh` → 11/11（真空 VC 缺映射/占位步骤/档位漂移/跑题 Goal 注入全拦，干净夹具全放）
- **独立回归**：`bash skills/task-planner/scripts/run-selftests.sh --fresh` → **Total: 91 PASS=91 FAIL=0**（独立执行体复现）；registry rows=91=actual
- **独立复验**：Verifier 逐 VC-1..4 重跑全 PASS+84.7 对齐四点 PASS+注入抽验 rc=1（`subagent-state/final-verify.md`）
- **CR Gate**：Code Reviewer 裁决 **APPROVED**（0 P1/P2；P3×5 建议留档 `subagent-state/cr-gate.md`）
- **吃狗粮实证**：新门上线即扫本计划——rvc-coverage 抓到本计划自身 R0 缺映射（真阳性，已修）

### 审查清单（Rule 76.2）

| 文件 | 路径 | 简单描述 |
|------|------|---------|
| attest-plan.sh | skills/task-planner/scripts/ | 锁定期接线 4 门+cksum 纳新 env |
| check-complete.sh | skills/task-planner/scripts/ | 终验期接线 2 门（函数+调用） |
| check-3file-gate.sh | skills/task-planner/scripts/ | 翻转期第 6 条件（goal-cjk） |
| check-evidence-anchor.sh | skills/task-planner/scripts/ | CLAIM_MATCH 内容核对层 |
| config.json | skills/task-planner/ | +6 档位键（结构类 enforce/阈值类 warn） |
| critical-rules-verification.md | skills/verification-gate/references/ | Rule 84.7 内容审查门条款 |
| selftest-gate-injection.sh | skills/task-planner/scripts/ | 五门注入式行为回归（新） |

## ④ 风险（必须列举）

1. **CLAIM_MATCH=warn 档**：60 存量抽样出 2 计划「边界阳性」（引用产出脚本而非输出日志——结果串合法不在脚本里）；升 enforce 前需你裁决此边界（修存量引用 or 保留 warn）
2. ~~部署位未同步~~ **已清账（2026-10-17 用户「同步部署」授权后执行）**：五技能目录（task-planner/verification-gate/task-discipline/task-dispatch/task-drift-guard，覆盖 v183+v184 全改动面）rsync 同步 ~/.zcode + ~/.claude + ~/.opencode 三位，diff 零残留、.drift-rhythm 运行态保留、84.7 条款+新门文件三处在位——新门对新会话即时生效
3. **登记债两笔**（独立任务面）：①check-goal-cjk E5 区间缺口（U+5F64-5FFF 常用字未判 CJK，一行修法备查）②attest 门缓存 cksum 历史键陈旧（首跑必 miss 重跑，方向安全）
4. **CR P3 建议×5**（非阻断）：GI-05/07 attest 侧为 grep 锚/attest 三接线块同构可抽函数等
5. **v183 归档被 live-owner 守卫合规拒绝**（10-18 01:46 后可重试；P01 休眠计划 5 映射缺口同批处理）
6. **「所有错误都审查出来」的诚实边界**：机器层覆盖四形态声明串；纯语义相关性靠 84.7 规则门（模型审查非机器判定），首次消费在后续计划生效

## ⑤ 下一步建议

- **可选·CLAIM_MATCH 升档**：裁决边界阳性处理方案后将 claim_match_enforce 翻 enforce（对象 `skills/task-planner/config.json`，看点=warn→enforce + 存量 2 计划引用修正）
- ~~可选·部署同步~~ **已执行（2026-10-17 用户授权）**：三位五目录零残留收敛
- **可选·归档批次**：2026-10-18 后 `archive-plan.sh --batch`（v183+P01）
- **登记债**：E5 区间一行修 / attest 接线块抽函数（CR P3）
