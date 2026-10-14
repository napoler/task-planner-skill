# 03-explore-error-correction — 执行错误即时纠正面盘点与缺口分析

> task-v168 只读调研产出（子代理返回原样落盘，主进程仅追加本节头）。所有锚点均为子代理第一手 grep 复核。

## 1. 规则面现状

- **Rule 31 错误学习闭环**（critical-rules.md:318-328）：31.1 触发四条件（:322）=①用户指出有误 ②同一问题重复反馈≥2 ③用户打断补充新数据 ④check-drift.sh ERROR-LOOP——**全部为用户侧/漂移侧信号，不覆盖执行期工具报错/测试 FAIL**；31.2 4 维归因写 Error Log Root Cause 列（:323）；31.3 修正路由（:324）；31.4 沉淀+Prevention 翻占位（:325）；31.5 消费侧 Learning Gate（:327）；31.6 键 error_loop_enforce 默认 warn + selftest-error-loop.sh（:328）
- **Rule 33 reflect-verify**（:340-349）：33.1 触发①问题解决完成后 ②bugfix 类每 Phase complete 前 ③声明 required（:344）——**触发点在"解决后"不在"出现时"**；33.3 留痕两行 `- [reflect] 反思:`/`- [reflect] 验证:`（:346）；REFLECT-GATE 仅 required 计划校验且默认 warn（:349）
- **Rule 6**（:20-21）错误双写 task_plan Errors + progress Error Log，无具体触发条件
- **Rule 7 三击**（:23-24 + reference.md:226-234）纯 LLM 行为无机器门
- **Rule 22.3 五档兜底**（:177-181）：改派→拆细→降档→主进程接管→AskUser；22.3.0 资料先行（:178）；22.3.0b 换道（:179）——触发点=子代理超时/失败，**不覆盖工具报错/测试 FAIL**
- **Rule 57**（:671-681）每轮测试结果四要素落盘（:675,:677）——管落盘不管 FAIL 后纠正；零新键+selftest-iteration-persistence.sh 静态守护（:681）

## 2. 机器面现状

- **Learning Gate**（check-complete.sh:1103-1211）：Error Log 数据行 Root Cause 非空（`<待沉淀>`/空 FAIL）（:1104-1105）；档位 env TASK_PLANNER_ERROR_LOOP_ENFORCE > config error_loop_enforce > warn（:1108-1109）；L0 skip（:1122-1125）；**仅终验检测，非执行期**
- **REFLECT-GATE**（:1213-1258）：required 计划须 ≥2 行 `- [reflect] `（:1214-1215）；档位 env TASK_PLANNER_REFLECT_VERIFY_ENFORCE > config reflect_verify_enforce > warn（:1216-1217）；L0 skip（:1230-1233）

## 3. 模板面

- progress Error Log 表头（templates/progress.md:45）：`| Timestamp | Error | Attempt | Resolution | Root Cause | Prevention |`；模板行（:47）；**缺「触发命令/工具」列**（不利于根因定位）

## 4. hook 面对错误信号的可见性

- **zcode-posttooluse.sh（全文 370 行）不感知工具失败**：is_error/exit_code/tool_result/stderr 零 grep 命中；现有职责=优先级 1 计划陈旧回写（:245-256）/2 findings 陈旧（:263-290）/3 progress 陈旧（:292-318）/4 todo 同步（:320-325）/5 drift-rhythm 延迟 emit（:327-366）；另有串行槽清锁（:25-35）、TAMPERED 自愈重锁（:115-161）
- **zcode-pretooluse.sh（158 行）同样零感知**；拦截走 stderr+exit 2（:20-23,:42-54），**不落盘不计数**
- 结论：执行期工具报错/测试 FAIL 时 hook 层无任何响应

## 5. 配置与 selftest 守护面

- config.json：error_loop_enforce warn（:279-288）；reflect_verify_enforce warn（:299-304）；retry_count 3（:18-23）；escalation_threshold 3（:190-195）；subagent.retry_limit 2（:351-356）；rescue_chain_enforce warn（:131-140）；provider_fallback enabled（:141-173）
- selftest：selftest-error-loop.sh（31.1 :39/联动 :51/SKILL 摘要 :53/C19 :55/task_plan Errors :78/notepad :80）；selftest-reflect-verify.sh（33 头 :32/33.1 :34）；selftest-iteration-persistence.sh（57.1 :88/SKILL 锚 :127/计数 :134/config 键数 42 钉 :194）

## 6. 缺口清单

### P0
1. 执行期机器可观察错误（工具 exit≠0/测试 FAIL/子代理 failed）无任何触发条款（critical-rules.md:322 四条件全用户侧）
2. hook 层零错误信号感知（两 hook grep 零命中，:1-370/:1-158）
3. 执行期错误纠正无即时门控（Learning/REFLECT 均终验门，check-complete.sh:1103,:1213）

### P1
4. PreToolUse 拦截不落盘不计数（zcode-pretooluse.sh:20-23,:42-54）
5. Rule 33.1 触发点不覆盖"问题出现时"（critical-rules.md:344）
6. Rule 22.3 兜底不覆盖工具报错（:177）
7. Rule 57 不管 FAIL 后纠正（:675）

### P2
8. Error Log 缺「触发命令/工具」列（templates/progress.md:45）
9. Learning/REFLECT 默认 warn 不阻断（config.json:286,:302）

## 7. 设计输入结论

1. **规则扩展**：Rule 31.1 增第 5 触发条件「执行期工具 exit code 非零/测试 FAIL/子代理返回 failed|partial → 错误学习闭环全链」；Rule 33.1 增触发「工具报错/测试 FAIL 出现时 → reflect-verify 即时轮」——纯增量，不改既有 4 条件语义
2. **留痕格式**：progress.md Error Log 增「触发命令/工具」列（模板+存量兼容）；`[error-fix]` 即时纠正留痕行（错误→根因类别→纠正动作→复验结果四要素）
3. **门控落点**：check-complete.sh 新增 ERROR-CORRECTION GATE（Phase complete 窗口内 Error Log 新增行必须 Root Cause 非 `<待沉淀>` 且带纠正复验记录；档位 env TASK_PLANNER_ERROR_CORRECTION_ENFORCE > 新 config 键默认 warn——注：按 59.7 同类零新键纪律应优先 env，config 键由主进程裁决）；执行期 hook 检测错误信号 → 注入 `[error-fix]` 提醒（PostToolUse 新优先级 6）
4. **hook 触点**：zcode-posttooluse.sh 增加工具失败检测（解析 hook stdin JSON 的 tool_result is_error / Bash exit code / stderr 非空）→ 注入即时纠正提醒
5. **禁止越界**：不改 Rule 31.1/33.1/22.3/57 既有语义；不改 Learning/REFLECT-GATE；不改 zcode-pretooluse.sh exit 2 阻断语义；PreToolUse 拦截落盘须 hook 侧安全写（禁写坏计划文件）
