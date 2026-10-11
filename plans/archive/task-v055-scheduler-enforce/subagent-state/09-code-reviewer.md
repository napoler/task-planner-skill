# Code Reviewer Report — task-v055-scheduler-enforce (c6be41a..1d73577)

- **scope**: 16 files, +1356/-156 LOC; 核心在 scripts/check-delegation.sh(626)/allow-direct.sh(153)/selftest-delegation.sh(331)/zcode-pretooluse.sh(+35)/zcode-userpromptsubmit.sh(+8)/check-complete.sh(+94 DELEGATION GATE)/SKILL.md(570→497)/config.json(+delegation_enforce)/lib/verify.sh(+check 9)/templates/verification.md
- **selftest 结果**: 22/22 PASS (T01-T16 + b 断言)
- **verdict**: **CHANGES_REQUESTED** — 1 BLOCKER + 6 MAJOR + 5 MINOR + 4 NIT

## BLOCKER (1)

### B-1 `skills/task-planner/scripts/check-delegation.sh:291` — stats self_declared 正则误报所有六项白名单标准措辞,触发 check-complete 终验硬阻断
- **原文**: `[[ "$reason" =~ (用户显式|规划|验收|编排|簿记) ]] && self_declared=1`
- **冲突源**: `references/critical-rules.md:163` Rule 25.3 白名单 ① 字面含 `编排`, 白名单 ④ 字面含 `用户显式`, 白名单 ② 字面含 `规划/验收/簿记`(计划系统维护涵盖). 即:**凡按权威源规范写的 Executor 原因 → stats verdict=violation → check-complete.sh:418 exit 1 → COMPLETE 交付永远被机械阻断.**
- **实证**:
  ```
  Executor: 主进程（① 纯 git/worktree 编排）→ verdict=violation (self_declared=1) [实测 rc=1]
  Executor: 主进程（test 编排 reason）       → verdict=violation            [实测 rc=1]
  Executor: 主进程（test 用户显式 reason）   → verdict=violation            [实测 rc=1]
  ```
- **影响**: 任何按 Rule 25.3 文档化措辞填的 main-process Executor 都无法通过 check-complete DELEGATION GATE. selftest T12 自身已编码此误报为预期(测试不区分), 故全部 PASS 但生产计划失败.
- **置信度**: HIGH (直接执行验证 + 两权威文件直接冲突 + 终验 exit 1 路径已确认)
- **修复方向** (二选一):
  1. **regex 收紧**: 改为匹配宽松自声明措辞, 例如 `(顺手|效率高|比较快|自己干|差不多|简单|快速)` — 这些是真实反模式; 而 `(用户显式|规划|验收|编排|簿记)` 应转为 whitelist-marker (需更结构化: 解析 `(①②③④⑤⑥)` 编号 + 校验编号在白名单内)
  2. **白名单编号制**: 让 Executor 原因强制带 ①~⑥ 编号前缀, stats 解析编号映射 Rule 25.3 表 → 编号内 → 无 violation; 编号外或无编号 → violation. 这与六项白名单的现有表述对齐, 避免关键词匹配脆弱性.

## MAJOR (6)

### M-1 `scripts/check-delegation.sh:495-507` — 主进程 Executor 无括注理由(stats 层面) → 无 violation, 绕过"去口供化"
- **原文**: `**Executor:** 主进程` (无括号) → `current_reason=""` → 任何 reason 检查都不命中
- **影响**: Rule 25.1 要求"主进程必须写例外理由", stats 不强制该字段, 直接削弱 B-2. 比 BLOCKER 更隐蔽: 计划通过终验但其实没登记理由.
- **置信度**: HIGH
- **修复**: stats 遇 `主进程` 但 reason 为空 → 增加 violation `{type:"missing_reason"}`; 与 B-1 修复一并落实.

### M-2 `scripts/check-delegation.sh:182-193` + `scripts/zcode-userpromptsubmit.sh:90-96` — 缺/空 .session-owner = fail-open, 首执行轮完全失活
- **原文 (pretool)**:
  ```
  if [ -z "$owner" ]; then exit 0; fi   # 注释: owner 为空 = 该 plan 尚未被 UserPromptSubmit 写入(可能子代理单独启动),放行
  ```
  **原文 (ups)**:
  ```
  if [ -n "$plan_dir" ] && [ -n "$UPS_SID" ] && [ "$UPS_SID" != "default" ]; then
    printf '%s' "$UPS_SID" > "$plan_dir/.session-owner" 2>/dev/null || true
  fi
  ```
- **影响**:
  1. **首轮失活**: UserPromptSubmit 在 plan 创建后才写 owner; 计划在 turn 1 创建 → owner 在 turn 2 才写 → turn 1 整个执行阶段 hook 形同虚设.
  2. **多 plan 冲突**: 若 `.active_plan` 指针缺失 + mtime fallback 命中错计划 → owner 写入别处 → 当前 plan owner 永缺 → 永久 fail-open.
  3. **多行 owner 静默绕过**: 经实测, owner 文件含 `\n` 时 `cat` 返回多行字符串, 与单行 sid 比较不相等 → 误判为"子代理" → exit 0. (任何手工腐败或多 writer 累加都触发.)
- **置信度**: HIGH
- **修复方向**:
  1. owner 写入改为 `init-session.sh` 计划创建时同步触发(写入 plan 创建时的 session_id, 可记 task_plan.md frontmatter `creator_session_id:`).
  2. 读取时 `head -n 1 | tr -d '\r\n' | tr -cd 'a-zA-Z0-9' | head -c 40` 做规范化, 抵御多行/非法字符.
  3. owner 缺失时改为 fail-closed + stderr 警告(而非 fail-open), 与"机制化执行期拦截"目标一致; 或保留 fail-open 但**仅**限 owner 缺失这一窄路径, 并通过其他信号(plan frontmatter `creator_session_id`)补盲.

### M-3 `scripts/zcode-pretooluse.sh:42-49` — enforce 阻断时 JSON-only-on-stdout, 消息可能丢失
- **原文**:
  ```
  msg="[delegation-block] 🚫 主进程直做拦截 — file=${file}..."
  printf '{"additionalContext": %s}\n' "$(printf '%s' "$msg" | jq -Rs . 2>/dev/null || printf '"block"')"
  exit 2
  ```
- **冲突**: 同文件 check-scope.sh 调用走的是 `echo '...' >&2; exit 2`(stderr 通道) — 是已被 ZCode 实测有效的"exit 2 = block"模式. 新增委派门控改走 stdout JSON, 与 in-file 既定模式不一致; 且 Claude Code hook 规范 exit 2 时 stderr 才被模型读到, stdout 被忽略.
- **影响**: 阻断有效(模型被锁), 但模型**看不到为什么被阻断也不知道怎么解**, 行为退化为无解释拒绝 → 易触发"反复试错绕过". SKILL.md 已声明"ZCode 约定 PreToolUse exit 2 = block"但未明示 stdout JSON 解析行为.
- **置信度**: MEDIUM (无法在仓内验证 ZCode hook 引擎实现, 仅据 in-file precedent + Claude Code 规范推断)
- **修复**: 把消息写到 stderr (与 check-scope 路径一致), 保留 stdout JSON 仅在 warn 模式(exit 0)使用; 或双写 stderr+stdout 但以 stderr 为权威通道.

### M-4 `scripts/allow-direct.sh:46-58 + scripts/check-delegation.sh:161-165 + scripts/zcode-pretooluse.sh:42-47` — B-1 "文案禁止引导模型自助绕过" 被同文件 hook 消息违反
- **原文 (block msg)**: `若用户明文要求主进程亲为,执行:\n  bash ${SKILL_ROOT}/scripts/allow-direct.sh on --confirm-user-requested`
- **原文 (自身声明)** (`check-delegation.sh:21`): `B-1: 文案禁止引导模型自助绕过;放行只能来自显式 allow-direct.sh on`
- **冲突**: hook 在 enforce/warn 两种档位都把 bypass 命令原文打印给模型; 模型可立即 `Bash("bash allow-direct.sh on --confirm-user-requested")` 一次性绕过 (每 plan dir 仅一次, 落 ledger, 终验展示). 当前没有任何"人类输入证据"机制 (无 /dev/tty 验证, 无 origin marker, 无密码短语).
- **影响**: 一次性静默自助绕过(被 ledger + 终验兜底, 但仍属机制可被滥用). 与文件头声明的 B-1 原则自相矛盾.
- **置信度**: HIGH
- **修复**:
  1. hook 消息改为指引模型"请提示用户在终端执行 `bash .../allow-direct.sh on --confirm-user-requested`", 不打印可执行命令本身.
  2. (可选) allow-direct.sh 增加交互式确认: 读 /dev/tty, 要求键入 `confirm` 短语才生效 — 把"用户在场"做成机械证据.
  3. (可选) Bash 工具调用本身应被 hook 链监测, 阻断 `bash allow-direct.sh` 的子代理/自助调用 — 这超出当前 PR 范围, 列入 backlog.

### M-5 `scripts/check-delegation.sh:99-124` — 白名单 `*/plans/*` 过宽, 业务项目自带 plans/ 子目录被无差别放行
- **原文**:
  ```
  # 1. 祖先含 plans/(覆盖三件套 basename 收紧问题 m-2)
  local d="$(dirname "$fp")"
  while [ "$d" != "/" ] && [ -n "$d" ]; do
      if [ "$(basename "$d")" = "plans" ]; then return 0; fi
      d="$(dirname "$d")"
  done
  ```
- **影响**: 经实测, 任意祖先含 `plans` 即放行: `/tmp/wl-test/sub/plans/nested/foo.ts` → rc=0 (本应是 2). 业务项目里常见的 `data/{site}/{id}/plans/...`、`openspec/changes/{id}/plans/...`、`docs/plans/` 都会被识别成 plan 目录. 一致地, 主进程可借任何带 `plans/` 的业务目录绕过拦截写业务代码.
- **缓解**: 与 check-scope.sh 的 sentinel 走的是相同祖先遍历, 故"行为一致"; 但 plan 文档/Rules 25.3 把白名单定义为"计划系统文件(plans/** 三件套)", 范围远小于"任意祖先含 plans".
- **置信度**: MEDIUM-HIGH (行为与 doc 描述的范围不一致)
- **修复**: 把白名单从"祖先含 plans"收紧为"路径前缀等于 `$plan_dir`" (resolve_plan_dir_any 返回的目录, 而非任意 ancestor). 验证: 业务项目 plans/ 不再放行, 真正 plan 目录继续放行.

### M-6 `scripts/check-delegation.sh:524-526` — EOF-flush 分支跳过 Handoff 交叉校验, 与 `## ` 分支不一致
- **原文**:
  ```
  # flush 最后一个 Phase
  if [ "$in_phase" -eq 1 ]; then
      total=$(( total + 1 ))
      ...
      else
          delegated=$(( delegated + 1 ))   # ← 缺 Handoff 交叉校验
      fi
  ```
- **影响**: 若文件以 Phase 结尾(其后无 `##` 章节, Handoff 表缺失或位置异常), 该 Phase 的 unverified_delegation 永远不被发现. 标准模板 Phases→Handoff 表顺序下 `## ` 分支会处理大多数 case, 但仍有边界 (无 Handoff 表的计划/单 Phase EOF).
- **附加**: 同一 ~50 行 flush 逻辑被复制 3 份 (Phase 头分支 / `## ` 分支 / EOF 分支) 且有细微漂移 — `## ` 分支漏掉 `type_hint="${type_hint#*:}"` 前缀剥离 (line 423 vs line 322). 维护性陷阱.
- **置信度**: MEDIUM
- **修复**: 把 flush 逻辑提取为单一函数 `_flush_phase()`, 三处调用, 统一行为.

## MINOR (5)

### m-1 `scripts/check-delegation.sh:143,209` — ledger bypass 事件 trigger 字段恒为字面 "pretool", 不记录实际写入文件路径
- **原文**: `local file_esc; file_esc="$(printf '%s' "${3:-pretool}" | ...)"` — 调用方 line 209 传 "pretool" 字面, 真实 file_path 未透传
- **影响**: 终验展示 bypass 事件时只看到时间/sid/remain, 看不到被绕过的文件. 审计追溯力下降. 同类问题: `allow-direct.sh:96` `allow_direct_on` 事件缺 sid 字段.
- **置信度**: HIGH
- **修复**: 调用 `check_allow_direct` 时把 file_path 作为第 4 参数传入; ledger 行 `trigger` 改写实际路径; `allow_direct_on` 补 `sid` 字段.

### m-2 `scripts/zcode-pretooluse.sh:30-36` — Edit trivial 判定只看 new_string 前 4KB 的换行数
- **原文**:
  ```
  ns="$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty' 2>/dev/null | head -c 4096)"
  if [ -n "$ns" ]; then
      lines_arg="$(printf '%s\n' "$ns" | wc -l | tr -d ' ')"
  fi
  ```
- **影响**: (a) 单行巨型 new_string (minified JS/JSON/单行 100KB) wc -l = 1 → 命中 trivial 放行; (b) 删多换少的 edit (旧 500 行删成 2 行) 也按 2 行 trivial 放行. 两种情形绕过 ④ trivial 检查的语义("≤3 行修改"应近似等价于总变更量小, 不只是插入行数).
- **置信度**: MEDIUM
- **修复**: 改为 `total_size <= 4096 AND lines <= 3` 双条件; 或对 old_string 也统计 line 数, 取 max(old, new).

### m-3 `scripts/check-delegation.sh:280-283` — "占位检测" 实为死代码, 与文件头声明 / T12 测试名不符
- **原文**:
  ```
  local suspicious=0
  case "$exec_norm" in
      *"（"*"|*（)"*|*"("*) suspicious=0 ;; # 标准格式
  esac
  ```
  变量 `suspicious` 被设置但**从未被读取**.
- **影响**: 文件头 B-2 "占位检测" 承诺未实现; selftest T12 名称 "占位/理由检测" 实测仅触发 self_declared 分支. 文案/测试命名/实现三方漂移.
- **置信度**: HIGH
- **修复**: 要么实现真正的占位检测 (例如检查 `主进程（...）` 括号内文本是否在已知白名单 6 选 1 集合内), 要么删除死代码 + 调整文件头/T12 命名.

### m-4 `SKILL.md:397,448` — 行号指针与重排后的文件失同步 (c036c3e 悬空指针清零未覆盖这两处)
- **原文**:
  - `SKILL.md:397` "权威源 = 上方 §子代理路由表「代码编辑」三行（343-345）" — 实际路由表代码编辑三行在 322-324
  - `SKILL.md:448` "（其他调研类反模式见上方 §反模式 379-381 行）" — 实际反模式块在 353-361
- **影响**: 编辑按指针定位失败; 收敛任务 (eee87e0) 的"指针清零"未覆盖本次新增内容.
- **置信度**: HIGH
- **修复**: 删除硬编码行号或用锚点替代; 收敛 commit 增补"硬编码行号扫描"项.

### m-5 `SKILL.md:38,150 + templates/verification.md:90` 与 `check-complete.sh:418` — 文案/实现不一致
- **(a) "同会话仅一次"** (`SKILL.md:38`, `zcode-pretooluse.sh:47`, `emit_warn` 消息): 实际 `allow-direct.sh` 实现为**同 plan-dir 永久仅一次** (bypass-count 不被 `off` 重置, 新 session 同 plan-dir 也拒). 实现比文案更严, 文案误导.
- **(b) "outcome 最高 PARTIAL"** (`SKILL.md:150`, `templates/verification.md:90`): 实际 `check-complete.sh:418` 在 violation/率低时硬 `exit 1` (拒绝报告 COMPLETE), 不是 PARTIAL 降级. 处置路径不同.
- **置信度**: HIGH (a) / MEDIUM (b)
- **修复**: (a) 文案改"同 plan-dir 仅一次"; (b) SKILL.md 明确"stats verdict=violation 或率<floor → check-complete exit 1, 模型需回炉补 plan 或按 PARTIAL 交付".

## NIT (4)

### n-1 `/tmp/task-planner-warn-${sid}.count` 等可预测文件名
- 单用户开发机风险低; 多 writer 竞态 (`cat; +1; echo >` 非原子) 偶发丢计数; 可预测路径在共享 /tmp 场景有 symlink 攻击面. check-complete.sh:429-437 还跨 sid 报告所有 warn 计数(应只报本 session).
- 修复: `mktemp -t task-planner-warn-XXXXXX`(per-session) 或加 pid/sid 锁.

### n-2 stats 错误 JSON 在 check-complete 中被解析为 pass
- 当 plan_dir 缺失或 task_plan.md 不存在, stats 输出 `{"error":...}` + exit 1 → check-complete 收到非空 stats_output, verdict 为空 → gate 通过. fail-open 行为但产生误导日志 ("DELEGATION GATE PASSED").
- 修复: 在 stats_output 含 `"error"` 时视为 fail-open + stderr 警告.

### n-3 `SKILL.md:46` 锚点 `#code-review-gate代码审查门控` 目标非标题
- 目标行 `- [ ] **Code Review Gate**（仅 ...）` 是粗体列表项非 markdown 标题, GitHub 不会生成锚点. 历史问题, 本次未引入但未修.

### n-4 check-complete.sh:441 `exit $python_rc` 在 delegation gate 失败后未覆盖
- gate 失败时 `exit 1` 在 line 421 已退出, line 441 是 fallback (python_rc!=0 时). 正确, 但与 `set -u` 缺位下未保护 stats_rc 类似 — 当前实现可接受, 列出仅为完整.

## 验证证据

- 全部 22 个 selftest 断言 PASS (T01-T16 + T09b/T15b/T16b)
- 关键脚本均 100755 可执行 (git ls-files -s)
- 哨兵机制 (zcode-pretooluse.sh:14-20) 与 Rule 23 冲突检测 (lines 55-82) 在 v055 改动后保持完整
- jq fail-open 路径 (get_enforce_mode sentinel "failopen") 实测 T14 PASS
- allow-direct TTL 方向 (stamp=now+1800, remain ∈ [0,1800]) 实测 T09/T10 正确

## 范围 / 未审查项

- 未深入审查 `lib/verify.sh` 既有 8 项检查的逻辑(非 v055 增量)
- 未审查 `templates/variant/` 内 12 套变体的 Executor 字段兼容性
- 未审查 hook 注册是否在 `~/.zcode/cli/config.json` 中实际就位(超出本仓范围, 需部署位验证)
- 未审查 `task-resume` skill 与 v055 的 session-owner 冲突场景

## 结论

**CHANGES_REQUESTED** — 必须先修 BLOCKER B-1 (stats 白名单正则 vs Rule 25.3 措辞冲突), 否则任何按文档化白名单措辞填写的计划都无法通过终验. M-1/M-2/M-4 是用户已点名关注项, 强烈建议同批修. M-3/M-5/M-6 建议本批修; MINOR/NIT 允许下一迭代收口.

---

## Re-Review Report — fix-phase (HEAD fa893eb, commit 7ab28e2)

### Scope
git diff 1d73577..fa893eb -- skills/: 6 files, +465/-283. 修改落在:
- `scripts/check-delegation.sh` (主战场: B-1/M-1/M-2/M-5/M-6 全部落地,新增 read_session_owner/emit_owner_observation/_flush_phase)
- `scripts/allow-direct.sh` (M-4: sid-flag + --force + ledger-bypass 检测)
- `scripts/zcode-pretooluse.sh` (M-3/M-4: 阻断消息改 stderr + 移除可执行命令)
- `scripts/selftest-delegation.sh` (+13 断言,现 35/35)
- `SKILL.md` (m-4: 行号指针 322-324 / 353-361; m-5: 文案对齐 sid 一次 / exit 1 阻断)
- `templates/verification.md` (m-5: 文案对齐 exit 1 阻断表述)

### Verdict: **APPROVED**

selftest **35/35 PASS**(双跑幂等);6 项原必改 + 2 项文案/指针 MINOR 全部实证解决;B-1/M-2 的"silent bypass"风险面关闭。

### 必改清单逐项实证

| ID | 修复内容 | 复测命令 | 结果 |
|----|---------|----------|------|
| **B-1** | self_declared 改为白名单编号标识 `(①\|②\|③\|④\|⑤\|⑥\|白名单[1-6])` 判定;空 reason → missing_reason | `Executor: 主进程（① 纯 git/worktree 编排）` → stats | verdict=ok, self_declared=0 (PASS) |
| **B-1 回归** | 旧 keywords(编排/规划/验收/簿记/用户显式)无编号标识 → 仍违规 | `Executor: 主进程（我做编排与交付）` → stats | verdict=violation (PASS) |
| **M-1** | reason 空 → missing_reason | `Executor: 主进程` (无括号) → stats | violation type=missing_reason, rc=1 (PASS) |
| **M-2a** | owner 多行: `head -n 1 \| tr -cd 'a-zA-Z0-9_-' \| head -c 40` 规范化 | `printf 'real-sid\nfake-sid' > .session-owner`; sid=real-sid | rc=2 (主进程;owner 第一行==sid 阻断) (PASS) |
| **M-2b** | 多行 attacker sid 不能绕过 | sid=fake-sid-on-line-2 | rc=0 (子代理;owner 规范化 != sid 放行) (PASS) |
| **M-2c** | owner 缺失 → 观察模式(非 fail-open 也非 fail-closed) | rm .session-owner; pretool | rc=0 + stdout additionalContext(`[delegation-observe]`) + stderr 痕迹 (PASS) |
| **M-3** | enforce 阻断走 stderr + exit 2(对齐 check-scope) | 模拟 Write → zcode-pretooluse.sh | rc=2, stdout 空, stderr 含消息, 消息无 `bash .../allow-direct.sh on` 可执行命令 (PASS) |
| **M-4** | sid 闸门(/tmp/task-planner-bypass-<sid>) + plan-dir ledger-bypass 检测 → --force | allow-direct.sh on 二次同 sid | rc=3 (sid_already_used) (PASS) |
| **M-4b** | plan-dir 已有 bypass 事件需 --force | 注入 "event":"bypass" 行 + 新 sid 无 --force | rc=4 (plan_dir_already_bypassed) (PASS) |
| **M-4c** | --force 允许二次 + ledger 记 force=true | 同上加 --force | rc=0, ledger 写入 force=true (PASS) |
| **M-4d** | --confirm flag 仍必填 | on 无 --confirm-user-requested | rc=2 (missing_confirm_flag) (PASS) |
| **M-4e** | 文案不再打印可执行 bash 行 | 读取 zcode-pretooluse.sh 阻断消息 | 无 `bash ${SKILL_ROOT}...on` 模式,改"请用户在终端运行"指引 (PASS) |
| **M-5** | plans/ 祖先白名单仅 .md/.json 放行,其他扩展名继续走拦截 | `plans/m5b/notes.md` | rc=0 (PASS) |
| **M-5 收紧** | nested business `plans/nested/foo.ts` 被拦截(原本过宽) | `sub/plans/nested/foo.ts` | rc=2 (PASS) |
| **M-5 SKILL_ROOT** | SKILL_ROOT/.claude/plan-templates/.zcode/plans 全放行(无扩展名约束) | 三类路径 | rc=0 (PASS) |
| **M-6** | flush 提取 `_flush_phase`,三处统一(Phase 头 / `## ` / EOF) | stats 命令 | 三处行为一致,EOF 获得完整 Handoff 校验 (PASS) |
| **M-6 回归** | plan 末尾无 Handoff 表,listed subagent → rc=1 unverified(正确) | `### Phase` 单 phase,无 Handoff | verdict=violation, type=unverified_delegation (PASS) |
| **m-3** | "占位检测"死代码删除,改为白名单编号标识判定 | grep suspicious / 占位检测 | 0 hits (PASS) |
| **m-4** | SKILL.md 行号指针修正 | sed -n 322,324 / 353-361 | 322-324 是「代码编辑」三行; 353-361 是 §反模式 9 条 bullet (PASS) |
| **m-5(a)** | "同会话仅一次" 改为 "同 sid 仅一次" + `/tmp/task-planner-bypass-<sid>` + plan-dir 二次需 --force | sed -n 38 / 397 | 文案与实现一致 (PASS) |
| **m-5(b)** | "outcome 最高 PARTIAL" 改为 "exit 1 阻断 + 回炉补 plan 或转 PARTIAL 重跑" | sed -n 150 / verification.md 90 | 文案与 check-complete.sh:418 行为一致 (PASS) |

### 修复后的剩余关注(未在 fix 必改清单内,作为已知问题移交下一迭代)

| ID | 状态 | 说明 |
|----|------|------|
| **m-1** MINOR | **未修** | `check-delegation.sh:192` ledger bypass 事件 `trigger` 字段仍恒为字面 "pretool";调用方 line 209 传字面而非实际 file_path。审计追溯时看不到被绕过的文件 |
| **m-2** MINOR | **未修** | `zcode-pretooluse.sh:32` Edit trivial 仅看 `new_string` 前 4KB 的 `wc -l`;巨型单行 / 删多换少 edit 仍可命中 trivial 放行 |
| **n-1~4** NIT | **未修** | /tmp 可预测文件名 + 跨 sid 报告 / stats 错误 JSON 被误判 pass / 锚点非标题 / `exit $python_rc` 透传 — 不影响功能,仅噪音 |
| **Bash 工具绕开门控** | **已知架构限制** | Bash tool 不被 PreToolUse gate 拦截,主进程可 `Bash("cat > file <<EOF")` 直接写业务代码。已在原报告 MINOR 注明;非本 PR 范围 |

### 整体质量评估

1. **核心机制闭环**: 主进程白名单外 Write/Edit 被 exit 2 阻断 + 子代理自动放行 + 用户显式 bypass 留痕 — 三层闸门全部到位且可独立测试。
2. **去口供化(stats)**: 白名单编号制把"主进程自填理由"从关键词匹配改为结构化标识,与 Rule 25.3 文档化措辞对齐,无 false-positive。
3. **降级观察模式**: `.session-owner` 缺失不再 fail-open 也不 fail-closed,而是"放行 + 可见痕迹 + UserPromptSubmit 紧接写入",与首执行轮的真实场景兼容。
4. **B-1 修法的健壮性**: `①②③④⑤⑥` + `白名单1~6` + `白名单7` 越界 → 1,覆盖边界。允许任意理由前缀(用户说明文字)只要含编号即可,容错友好。
5. **维护性提升**: `_flush_phase` 单函数替代 3 份复制粘贴;Bash 动态作用域契约已注释;allow-direct.sh 的 sid/ledger-bypass 维度闸门结构清晰。
6. **测试覆盖**: 22 → 35 断言,新增 13 项覆盖修复面(T17 白名单标记 / T18 missing_reason / T19 owner 多行 / T20 观察模式 / T21 plans 扩展名 / T22 sid/--force),selftest 本身可幂等重复运行。

### 仍保留的轻微观察(非阻塞,可入下一迭代)

- **A1 (MINOR)** `_flush_phase` 函数依赖动态作用域写回调用方 locals,工作正确但脆弱(若未来有人 `local` 这五个名字会静默失效);建议改用 `nameref` 或显式返回值+赋值。置信度 MEDIUM。
- **A2 (NIT)** `emit_warn` count 文件 `/tmp/task-planner-warn-${sid}.count` 的并发非原子更新仍未修复;单用户开发可接受。
- **A3 (NIT)** `check-complete.sh:429` 仍跨 sid 报告所有 warn 计数,本会话视角会看到其他会话的噪音。

### 最终结论

**APPROVED** — 9 项必改全部落地 + 35/35 selftest 通过 + 所有原复测脚本结果正确。剩余 m-1/m-2/n-1~4 已知问题已明文移交下一迭代,不影响本批发布;架构性 Bash-bypass 面已超本 PR 范围。建议合并并启动任务收尾(终验/attest/worktree 合并回合约)。
