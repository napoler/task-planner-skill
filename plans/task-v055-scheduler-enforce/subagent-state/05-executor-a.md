# 05-executor-a.md — 执行期拦截组 checkpoint

## 任务
task-v055/Phase 3 第一批:执行期委派门控(主进程=调度器机制化强制)。
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v055-scheduler-enforce (分支 wt/task-v055-scheduler-enforce)

## 状态: 全部完成(6 文件交付 + 18/18 自测 PASS + 已 commit)

## 交付文件(6)
1. `skills/task-planner/scripts/zcode-userpromptsubmit.sh` (修改, +8 行)
   - UPS_SID 计算后追加 [2026-09-07 task-v055] 块:写 `<plan-dir>/.session-owner`(单行纯文本)
   - 实测验证: 喂入 {"session_id":"test-sid-abc123"} → session-owner=testsidabc123(tr -cd 过滤 '-')
2. `skills/task-planner/scripts/check-delegation.sh` (新建, ~430 行)
   - pretool 模式 6 段判定链: ①无计划放行 ②子代理 sid 放行(≠.session-owner) ③白名单(plans 祖先/plan-templates/.zcode/plans/SKILL_ROOT) ④trivial ≤3 行 ⑤allow-direct 30min+ledger ⑥违规→enforce exit2 / warn 注入+/tmp 计数
   - stats 模式: 状态机解析 Phase 段,委派率+main_direct+violations JSON;占位检测(自声明字样→violation)+Handoff 交叉校验(unverified_delegation)+needs_git_evidence
   - jq fail-open: jq 缺失/解析失败 → "failopen" sentinel → exit 0 + stderr 记录(m-4)
3. `skills/task-planner/scripts/zcode-pretooluse.sh` (修改, +35 行)
   - 哨兵检查后插入委派门控: Write/Edit/ApplyPatch 过滤 → new_string 截 4KB 后 wc -l → check-delegation pretool → exit2 时输出教育式 additionalContext(含 allow-direct.sh 引导,B-1 合规)
   - 原有哨兵/Rule 23 冲突检测完整保留
4. `skills/task-planner/scripts/allow-direct.sh` (新建, ~170 行)
   - on --confirm-user-requested(缺参数拒绝 exit2;二次 on 拒绝 exit3)/off/status
   - .allow-direct 内容=now+1800 epoch;bypass-count 单会话上限;ledger-delegation.jsonl 记录
5. `skills/task-planner/config.json` (修改, +9 行)
   - properties.delegation_enforce: enum[enforce,warn] default=enforce;原有 required/配置不动
6. `skills/task-planner/scripts/selftest-delegation.sh` (新建, ~270 行)
   - 18 断言覆盖 T01-T14(含 T08/T09/T12 双断言)

## 自测结果(证据: /mnt/data/dev/task-planner-skill/plans/task-v055-scheduler-enforce/tmp/enforce-demo.txt)
Total: 18  PASS=18  FAIL=0  (T01-T14 全 PASS, EXITCODE=0)

## 执行期发现并修复的 bug(调试记录)
1. `while read <<< "$plan_text"` heredoc 死循环 → 改 mktemp + `done < "$tmp_plan"`
2. set -u 下 BASH_REMATCH unbound → 全部 `${BASH_REMATCH[N]:-}` 兜底
3. **BASH_REMATCH 被 flush 块内的 [[ =~ ]] 匹配重置** → phase_name 空;修复: if 匹配后立即捕获 _r1/_r2 再 flush(顺序敏感)
4. Phase 3 后紧跟 ## 顶层章节 → in_phase=0 不 flush 丢 Phase → ## 截断分支补完整 flush
5. **CONFIG_JSON 层级错误**(SKILL_ROOT=scripts/,config.json 在上一级)→ get_enforce_mode 恒 failopen → 全部拦截失效;修复 `../config.json`
6. allow-direct 有效期判定方向反了(age=now-stamp,stamp 是过期时刻)→ 改 remain=stamp-now ∈[0,TTL]
7. selftest T14 shim 在 /tmp noexec → 移 $HOME

## commit
- 待填: 见 git log wt/task-v055-scheduler-enforce 顶部(本次 commit 后补充)

## 遗留问题(移交后续批次/verifier)
1. `get_enforce_mode` 在 config 缺 delegation_enforce 字段时 fallback "enforce"(非 failopen)——是否符合意图需 architect 确认
2. stats 的 Executor 类型提示提取假设格式 `type（model）`,裸类型(如 `database-optimizer` 无括号)也兼容;但含空格的 subagent_type 会匹配失败
3. check-delegation.sh pretool 的 cwd 解析依赖 $PWD,hook 调用时 ZCode 传的 cwd 字段未使用(与 zcode-pretooluse.sh 现状一致,统一改造属后续批次)
4. selftest 未覆盖 ApplyPatch 分支的 new_string 提取(ApplyPatch 无 new_string 字段,恒传 "-")
