---
id: dispatch-lifecycle-return-contract
title: "子代理生命周期与返回契约"
tags: [返回契约, 派发守卫, 失败兜底, 委派率, 执行体路由]
sources:
  - plans/archive/task-v161-subagent-return-format/findings.md
  - plans/archive/task-v057-subagent-io-contract/findings.md
  - plans/archive/task-v058-plan-dispatch-gate/findings.md
  - plans/archive/task-v058-plan-dispatch-gate/verification.md
  - plans/archive/task-v065-subagent-failure-rescue/findings.md
  - plans/archive/task-v194-subagent-unit-cap/findings.md
  - plans/archive/task-v056-fine-grained-dispatch/findings.md
  - plans/archive/task-v146-drift-check-subagent/knowledge-brief.md
  - plans/archive/task-v153-parallel-scheduling/knowledge-brief.md
  - skills/task-dispatch/references/critical-rules-dispatch.md
updated: 2026-10-22
---

# 子代理生命周期与返回契约

## 结论（可直接复用）

1. **返回契约 = 8 个固定字段严格模板**（task-v161 / Rule 22.4b + `templates/subagent_dispatch.md` §7）：`status:`(done|partial|failed|timeout) / `acceptance:`(n/total pass + 逐项 PASS/FAIL 及 ≤20 字原因) / `files:`(绝对路径 +N/-M) / `evidence:`(file:line 或 命令→关键输出) / `checkpoint:`(绝对路径 + status) / `findings_written:`(小节锚点|none) / `blockers:`(none|一句话) / `confidence:`(HIGH|MED|LOW)。**字段名与顺序不得改、不得增删、无内容填 none、不加标题/前言/总结、8 字段之后不得有任何内容**（需说明写进 `blockers:` 或检查点）。统计/测试类 `acceptance:` **只准贴逐项原文行**，禁自报汇总数字（子代理算术错多次实证，汇总由主进程机械求和）。
2. **污染三层根因，必须三面同治**（task-v161 实证 5 计划 58 份检查点，严格 8 字段合规率仅 **24.1%**（14/58），违规 75.9%）：① **派发 prompt「返回格式」段填写污染**——段内被填 ①②③④⑤⑥ 任务要点/待裁项清单而非 8 字段模板块（用户 mid-turn 实证含重复标题「## 返回格式## 返回格式」=两段拼接痕迹），子代理照指令返回总结式内容属照章办事，非模型漂移；② **agent 定义层输出模板竞争**——`executor.md:45-46` 步骤进度模板、`general-purpose.md:31-48` 任务交付报告、`explore.md:33-38` 发现列表、`plan-bookkeeper.md:35-40`、`plan-writer.md:219` 均未引用 8 字段（正确范式 = `drift-checker.md:29` / `decision-arbiter.md:50` 引用派发契约不自定义模板）；③ **返回回收零机械校验**——`check-dispatch.sh:120` 只查 prompt 含三 key，不校验实际返回。污染传播载体 = `subagent-fallback.sh` bind 生成的 `<type>-fb` 变体正文原样复制源 agent。
3. **两道机械校验 + 主进程闭环**（task-v161）：prompt 侧 `check-dispatch.sh:return_section_check()`（标题唯一 + 段内含 `status:`/`acceptance:`/`checkpoint:`/`confidence:` 四 key + 段内禁序号清单行；违规 exit 2）；返回侧新建 `scripts/check-subagent-return.sh` 四判据 = **字段齐全 / 契约外字段 / 块尾无附加 / 值域**（前缀 `[return-guard]`）。主进程收到返回**先过返回侧校验，PASS 才采信**；VIOLATION = 按 22.8.5 视为 `partial` + 打回重报一次 + 检查点「最终结论」段兜底回填 + Handoff「结论摘要」列记违规形态（契约外字段 / 块后附加 / 纯自然语言）；22.5 的 30s Read 复核义务不变。
4. **生命周期六段 checklist**（task-v057 / Rule 22.4·22.5·22.8）：① 派发 prompt 九字段（目标 1 句 / 输入**首块=计划三文件绝对路径** 22.4a + 材料包路径 + findings 摘要 ≤10 行，brief 在位时引用 `knowledge-brief.md` §1-§5 锚点 / 验收标准 2-5 条可观察证据 / Scope 禁改清单 / worktree 绝对路径 / 时长预算 / 返回格式 8 字段模板 + 路径引用 / checkpoint 路径 / kb 锚）；② 检查点路径 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`（每子代理一文件，seq=Handoff 行号，22.8.1）；③ 落盘时机 T1 编辑完成 / T2 调研出结论 / T3 中间决策 / T4 遇错写「错误与受阻」+ status failed / **T5 写「最终结论」段（= 同一 8 字段块）且 status done，T5 必做防返回消息丢失**（22.8.2）；④ 断点重试（22.8.4）**兜底前必须先 Read 检查点**——有 ≥1 条里程碑或已有产出 → 重试 prompt 注入 `resume_from`（禁重做清单 + 复用已有产出 + 剩余任务），无进度走 22.3 正常兜底，**resume_from 不重置 retry_limit**；⑤ 返回缺失兜底（22.8.5）以检查点「最终结论」段为准；⑥ 只读型 Executor 豁免（22.8.6）检查点由主进程当场代建，子代理 `checkpoint:` 填「绝对路径（待主进程代建）」并附最终结论段。
5. **provider 失败五档兜底（22.3，拆细先于升档）**（task-v065）：① **改派**（换更合适 subagent 类型）→ ② **拆细**（触及 21.1b 上限或预估超 `step_max_minutes` → 回计划层拆小 S-unit 重派，**不改模型档位**，每子任务拆细限 1 次防无限拆分）→ ③ **降档**（haiku→sonnet）→ ④ **主进程接管**（单文件 ≤300 行主进程 Edit）→ ⑤ **AskUserQuestion**；达 `config.json#subagent.retry_limit`（默认 2）**必须 AskUser，禁继续同法重试**。理念：失败第一假设是「任务太大/上下文太长」而非「模型不够强」——升档治标且贵，拆细治本。
6. **失败链外围三档**（task-v065）：22.3.0 **资料先行**（连续失败 ≥2 次 → 先查 help/官方文档禁凭记忆断言，再网络检索既有解法，借鉴落 findings）；22.3.0b **换道义务**（≥2 次失败禁同法第 3 次，换道序=资料先行→子代理隔离→拆解逐个击破，连续 3 次须登记 Handoff `rescue` 列 + progress `[switch-path]` 行）；22.3.1 **provider proactive Scaling**（派发前 `subagent-fallback.sh probe --plan-dir` 预检；失败后 `next <type> provider` + `bind` 生成 `<type>-fb` 变体，**零消耗改派不计 retry_limit**；边界：变体定义随会话启动固化，当前会话不可见 → 新开会话或主进程接管；连续 2 通道全灭 → 22.7 STOP）；22.3.2 **provider 全灭挽救档**（全灭且任务超 ④ 上限时**禁止直接 STOP**，先拆细到每片 ≤300 行再逐片接管，仍无法接管者登记未完成清单交付 = 降级交付点，**禁裸 BLOCKED**）。机器面 `check-rescue-chain.sh`（failed/timeout 三查门控，档位 env > config > fail-open warn）。
7. **STOP 上报最小集六字段（22.7 + 22.7.1）**（task-v065）：① 失败子任务（Phase/S-unit 定位）② 已尝试档位清单（22.3 ①-④ + 22.3.0 评估 + 22.3.3 逐档：动作+结果+失败原因）③ 检查点路径 + 已落盘里程碑数（无检查点=违规）④ 剩余未尝试档位或不适用原因 ⑤ 建议下一步（拆细方案/接管范围/所需决策）⑥ 证据 file:line —— **缺任一 = 摆烂上报，接收方可拒绝受理**；未走完 ①-④ 与 22.3.3 评估仍失败才可 ⑤ STOP，不进 Chain block 交接、不继续派发。
8. **委派率统计口径（机器为事实源）**（task-v058/v064/v153/v185）：`bash scripts/check-delegation.sh stats <plan-dir>` 的 JSON 为唯一依据（占位检测 + Handoff 交叉校验，**不信 Executor 字段自报**）；floor = `config.json#delegation_rate_floor` 默认 **0.7**；rate < floor 时若主进程直做理由命中 Rule 25.3 六项白名单（①纯 git/worktree 编排 ②计划系统文件维护 ③机械验证命令 ④用户显式要求 ⑤22.3 兜底接管 ⑥trivial/mini 直做通道）→ **WHITELIST-EXEMPT 放行**；白名单外理由（如「效率高」「顺手」）= 未登记 → 按 25.4/26 Q5 处置（outcome 最高 PARTIAL）。白名单按**字面关键词**匹配——措辞差一个词面即被卡（v194 实证：「计划系统文件」字面缺失即被卡，修正后 verdict=ok）。
9. **执行体具名路由（禁 general-purpose 默认兜底）**（task-v153 / Rule 52.1·52.2）：选型顺序 = 先查 `references/agent-coverage.md` + 三登记面（SKILL.md 路由表 / skill-agent-router / template-mapping §九§十）→ 矩阵有专用体**必须用**；缺位 → 按族兜底（一等候选 = 具工序 SOP 的 `executor(sonnet-1)` 组合）并在 Executor/S-unit 表**登记兜底理由**；`general-purpose` **仅限跨领域复合/无法归类**，禁「路由表无匹配行」式默认落泛。52.2 三类缺口：A 类须有兜底登记 / B 类登记名须 `test -f` 存在（零容忍）/ C 类实体入矩阵或豁免。Handoff 表 `subagent_type` 写**裸名**——`executor(sonnet-1)` 这类带括号后缀形式被判「未登记子代理类型」violation（v194/v153 复发判例）。
10. **派发守卫机械判据（22.4c）+ prompt 纪律**（task-v057/v153）：PreToolUse hook 对 `Agent` 调用跑 `check-dispatch.sh` —— 须含三文件绝对路径（22.4a）+ `status:`/`acceptance:`/`checkpoint:` 三 key（22.4b）+ `subagent-state/` 路径（22.8.1）；档位 `dispatch_contract_enforce` = off/warn/enforce（enforce → exit 2 列缺项）；无活跃计划或解析异常 → **fail-open 放行**。prompt 内步骤枚举（①-⑮/StepN/行首编号）**≤4**，超出被拦（本会话被拦 5 次实证）。
11. **契约遵守度与模型档位强相关**（task-v057 R4）：同批 mini 档 code-runner 违约 4 项（翻转 progress.md `Status`→complete / 越权填满 Files 列 / 留未替换占位符 / 把 findings.md 拼接两遍致 119→251 行数据损坏），同批 sonnet-1 executor 13 次派发 0 次动 Status、0 次损坏 → 验证类任务改派 haiku-1 executor 而非 mini runner；主进程 22.5 复核按设计兜住（发现→纠正→记录）。

## 证据锚

| 事实 | 锚 |
|----|----|
| 契约文本不缺，缺执行层优先级与校验；污染主源 5 个 agent 定义层坐标；正确范式（drift-checker/decision-arbiter 引用契约）；污染传播载体（bind 复制源 agent）；守卫盲区（check-dispatch.sh:120） | plans/archive/task-v161-subagent-return-format/findings.md:23-27 |
| 合规率 24.1%（14/58）与违规分类；契约外字段样本（status 与 acceptance 之间混入 `summary:`）；块后附加 22 行样本 | plans/archive/task-v161-subagent-return-format/findings.md:30-32 |
| 用户 mid-turn 实证（返回格式段被填 ①-⑥ 清单 + 治理缺口） | plans/archive/task-v161-subagent-return-format/findings.md:36-38 |
| 污染三面 + 主进程闭环（四判据 / VIOLATION 视为 partial + 打回 + Handoff 记形态） | plans/archive/task-v161-subagent-return-format/findings.md:42-44 |
| prompt 侧 return_section_check 判据与 rc=2 复现；返回侧 check-subagent-return.sh 四判据 + selftest | plans/archive/task-v161-subagent-return-format/findings.md:54-62,66 |
| 正确范式 agent 的 8 字段返回写法（「按派发 prompt 8 字段模板返回」） | plans/archive/task-v146-drift-check-subagent/knowledge-brief.md:96 |
| 模板原状（§2 无三文件 / §7 为 5 行占位骨架）+ 12 次派发 0 次传三文件 | plans/archive/task-v057-subagent-io-contract/findings.md:22 |
| 「8 字段之后不得有任何内容」与「禁 git 写操作、只读 diff/status/log 允许」两处补漏 | plans/archive/task-v057-subagent-io-contract/findings.md:30 |
| mini 档 4 项契约违约 vs sonnet-1 executor 13 次 0 违约；16 次派发 8 字段 15/15 | plans/archive/task-v057-subagent-io-contract/findings.md:42,51 |
| 计划期派发机制现状（Rule 25.1/22.6 已落地；S-unit 表缺「执行体」列）；无脚本校验 = 纯文本约束失效模式 | plans/archive/task-v058-plan-dispatch-gate/findings.md:22-24 |
| 委派率机器口径 + 占位检测/Handoff 交叉校验（不信自报） | plans/archive/task-v058-plan-dispatch-gate/verification.md:77 |
| 失败挽救「文本齐备、机制全缺」+ F-1..F-9（F-6 五档写成四档 / F-7 provider 全灭无路径 / F-8 裸 BLOCKED 死结） | plans/archive/task-v065-subagent-failure-rescue/findings.md:47-48 |
| F-3/F-4/F-5/F-8/F-9 落地（换档语义 / STOP 六字段 / rescue 列 / silent 例外 / 询问时点） | plans/archive/task-v065-subagent-failure-rescue/findings.md:59 |
| F-6 timeout 独立分支拆细优先 + 五档全序 tier_order；F-7 22.3.2 全灭挽救档 | plans/archive/task-v065-subagent-failure-rescue/findings.md:60 |
| 委派率比较反转 bug（0.714 合规计划被 exit 1 假阴性，v056 R7） | plans/archive/task-v056-fine-grained-dispatch/findings.md:55-58 |
| 委派率白名单字面卡口实测；Handoff 裸名判例（带括号后缀 → 未登记 violation） | plans/archive/task-v194-subagent-unit-cap/findings.md:59-60 |
| 现行条文：22.3 五档 / 22.3.0-22.3.2 / 22.4(a-c) / 22.5 / 22.7 / 22.7.1 / 22.8.x / 25.3 / 52.1-52.2 | skills/task-dispatch/references/critical-rules-dispatch.md:53-73,105,133-139 |

## 易错点

1. **只写「不加前言」不够**：必须显式写「8 字段之后不得有任何内容，需说明写进 blockers 或检查点」——实证 S2 在 8 字段后附加「备注」段，加禁令后即合规。
2. **`acceptance:` 自报汇总数字**：统计类只准贴逐项原文行，汇总由主进程机械求和（子代理算术错多次实证）。
3. **「禁止 git 操作」会被理解为连只读 diff 也禁**：Scope 须写「禁止 git 写操作（add/commit/checkout/reset），只读 diff/status/log 允许」。
4. **prompt 侧守卫只查 key 存在性**：prompt 别处含 `status:` 字面即可蒙混 → 「返回格式」段结构需独立判据（标题唯一 + 四 key + 禁序号清单）。
5. **bind 变体复制污染源**：`<type>-fb` 正文原样复制源 agent（含冲突输出模板），provider 兜底改派时污染面同步扩散。
6. **委派率假阴性**：`check-complete.sh` 委派率比较曾反转（rate≥floor 反而 exit 1），0.714 合规计划被判失败 → 见 exit 1 先核对 stats JSON 再判回炉（v056 R7 → v057 D5 已修）。
7. **白名单理由措辞不对口**：须命中 25.3 六项关键词字面（「计划系统文件」「git 编排」「机械验证」「trivial」等），缺一个即被卡。
8. **provider 全灭直接裸 BLOCKED**：22.3.2 要求先拆细到每片 ≤300 行再逐片接管，仍无法接管者登记未完成清单交付。
9. **失败后跳过 Read 检查点**：22.8.4 要求兜底前先 Read，有进度即注入 `resume_from` 断点续跑，禁从零重做，且不重置 retry_limit。
10. **T5「最终结论」段省略**：返回消息可能整体丢失，T5 未写 = 唯一兜底副本缺失。
11. **general-purpose 兜底无登记**：路由表无匹配行直接落 general-purpose = 违规，须按族兜底并在 Executor/S-unit 表登记理由。
12. **迷你档跑写操作**：mini 档 code-runner 实测能翻转计划文件 Status 与拼接损坏 findings——验证类任务改派 haiku-1 executor。

## 适用场景

- 收到子代理返回消息、判合规与否、决定是否打回时先查本条；
- 写派发 prompt（九字段 + 8 字段返回格式段 + Scope 措辞 + checkpoint 路径 + 步骤枚举数）时先查本条；
- 子代理 failed/timeout 要走兜底、要判 STOP 是否合法时先查本条；
- 统计委派率、判 WHITELIST-EXEMPT、排查 check-complete exit 1 假阴性时先查本条；
- 为 S-unit 选执行体（专用体优先、族兜底、general-purpose 边界）时先查本条。
