#!/usr/bin/env bash
# selftest-capability-persistence.sh — task-v138: Rule 55「可复用能力落盘纪律」静态守护（自写 55.6 机器面）
#
# What（守护对象清单 + 运行方式）:
#   静态断言 Rule 55 新增锚全部在位且既有锚未被破坏（Rule 36.5 纯增量守护），共 20 条 CP-01..CP-20：
#     CP-01/02/03 critical-rules.md：`^### 55 ` 标题=1、`^55\.[1-6] ` 六子条=6、块首说明行含 task-v138
#     CP-04/05/06 SKILL.md：`Rule 55` ≥3、`40-55` =1、`40-53` =0（演进完成，样式参照 RR-16 演进后口径）
#     CP-07/08/09 references/capability-registry.md：文件在、表头 8 列、agnes-quota 行 8 字段全非空
#     CP-10..13 scripts/capabilities/agnes-quota.sh：存在、`bash -n` 通过、无硬编码密钥、头注释含 Rule 55
#     CP-14/15 companion/agents/{video,image}-generation-executor.md：各含 `capability-registry` ≥1
#     CP-16 config.json：.properties 键数=40（零新 config 键声明锚，沿用 tsv 末列既有口径）
#     CP-17/18 脚本自身：SCRIPT_DIR 自定位行在位（仓库/worktree/部署位三处可跑）、头注释 What+Why 齐备
#     CP-19/20 scripts/capabilities/agnes-quota.sh 运行时判定（本地 mock 实跑，F1 修复回归钉）：
#              CP-19 404 模式 → exit≠0 + 失败语义且禁含成功 verdict；CP-20 200 模式 → exit 0 + verdict 含「未填充」
#   运行方式：`bash scripts/selftest-capability-persistence.sh`（只读 grep/jq，零写入）；
#   逐行打印 `CP-NN PASS/FAIL <说明>`，末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析（`$SCRIPT_DIR/../references/...`、`$SCRIPT_DIR/../companion/agents/...`、
#   `$SCRIPT_DIR/../config.json`、`$SCRIPT_DIR/capabilities/...`），保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 55.6 机制锚，task-v138 2026-10-05）:
#   55.6 声明 Rule 55 的机器面 = 本脚本静态守护；判定面=LLM 行为（复用前置检查/权威来源取舍/首次成功落盘），
#   非机器触发，故零新 config 键（与 43.4/44.4/47.4/52.4 同范式）——CP-16 把「零新键」机器化。
#   只断言 Rule 55 新增锚、绝不触碰既有 selftest 断言行（防锚级联：新守护脚本自身不得改写既有脚本任何行）；
#   CP-06（`40-53`=0）与 CP-05（`40-55`=1）配对，锁死「纪元演进已收口」——防后续任务改写 SKILL.md 时
#   旧纪元字面残留（锚级联漂移）。条款写完但无机器守卫 → 回归期可被静默删改（task_plan 根源覆盖表第 ⑦ 行），
#   本脚本即该防复发的固定落盘资产（对应 R1「常用/可复用功能及时落盘到固定脚本」的自守护实例）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 python3，二者皆缺打 SKIPPED 不 FAIL，fail-open 非静默——
#       打印提示行，与 selftest-reliability-institution.sh R-12 / selftest-media-dispatch.sh MD-08 先例一致）。
#       CP-19/20 运行时判定需 python3 + curl + timeout（任一缺失打 SKIPPED 不 FAIL，同 fail-open 口径）；
#       mock 仅监听 127.0.0.1 随机端口，零外网依赖，timeout 20 保护，teardown 清理临时目录与后台进程。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
REG="$SKILL_ROOT/references/capability-registry.md"
CAP="$SKILL_ROOT/scripts/capabilities/agnes-quota.sh"
AGENT_VIDEO="$SKILL_ROOT/companion/agents/video-generation-executor.md"
AGENT_IMAGE="$SKILL_ROOT/companion/agents/image-generation-executor.md"
CONFIG="$SKILL_ROOT/config.json"
SELF="$SCRIPT_DIR/selftest-capability-persistence.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'CP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'CP-%s FAIL %s\n' "$1" "$2"; }

# CP-01 critical-rules.md `^### 55 ` 标题行计数=1
# What：断言 Rule 55 章节标题唯一（`### 55 可复用能力落盘纪律…`）。
# Why：标题行是章节识别锚；=1 保证未被重复插入（多次追加=文件尾脏写）也未被误删（条款失主）。
n="$(grep -cE '^### 55 ' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md '### 55 ' 标题锚 =1"; else bad 01 "critical-rules.md '### 55 ' 计数=$n（应 =1）"; fi

# CP-02 critical-rules.md `^55\.[1-6] ` 六子条计数=6
# What：断言 55.1-55.6 六条子条主体行（行首 `55.N `）全在位。
# Why：六子条是 55.1 复用前置检查/55.2 权威来源优先/55.3 首次成功落盘/55.4 固定位置格式/55.5 执行体接线/
#      55.6 机制的唯一文本落点；缺任一条 = Rule 55 条款本体被裁剪（防后续改写 critical-rules.md 时误删 55.x 段）。
n="$(grep -cE '^55\.[1-6] ' "$CRIT" || true)"
if [ "$n" -eq 6 ]; then ok 02 "critical-rules.md '55.x ' 六子条锚 =6"; else bad 02 "critical-rules.md '55.x ' 计数=$n（应 =6）"; fi

# CP-03 Rule 55 块首说明行含 task-v138（来源任务锚）
# What：断言 `### 55 ` 标题行正文含来源任务代号 `task-v138`。
# Why：条款需可溯源（Rule 20.6 编号账本/任务代号可追溯）；缺 task 代号 = 条款失去来源登记，回归期无法对账。
if grep -E '^### 55 ' "$CRIT" | grep -q 'task-v138'; then
  ok 03 "Rule 55 块首说明行含 task-v138"
else
  bad 03 "Rule 55 块首说明行缺 task-v138 来源锚"
fi

# CP-04 SKILL.md `Rule 55` 计数 ≥3（摘要行/C 检查项/References 索引三处联动）
# What：断言 SKILL.md 中 `Rule 55` 出现 ≥3 次（Rules 索引 bullet + References 表行 + 全集/摘要锚）。
# Why：SKILL.md 是执行期入口；条款只在 critical-rules.md 而 SKILL 无联动 = 消费侧不可发现（53.2 条款死文反例）。
#      ≥3 与 P2-S2 三处联动承诺对齐（防后续只改一处造成索引面失守）。
n="$(grep -c 'Rule 55' "$SKILLMD" || true)"
if [ "$n" -ge 3 ]; then ok 04 "SKILL.md 'Rule 55' 计数 $n ≥3"; else bad 04 "SKILL.md 'Rule 55' 计数=$n（应 ≥3）"; fi

# CP-05 SKILL.md `40-55` 计数=1（新纪元全集声明）
# What：断言 SKILL.md 出现 `40-55` 恰 1 次（Rules 40-55 全集声明行）。
# Why：纪元演进后全集声明必须指向 55；=1 防漏改（仍写旧区间）或重复声明（多处不一致）。
n="$(grep -c '40-55' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 05 "SKILL.md '40-55' 全集声明 =1"; else bad 05 "SKILL.md '40-55' 计数=$n（应 =1）"; fi

# CP-06 SKILL.md `40-53` 计数=0（旧纪元字面零残留，演进完成断言）
# What：断言 SKILL.md 不再出现旧区间 `40-53`。
# Why：与 CP-05 配对锁死演进收口——旧纪元字面残留 = 索引自相矛盾（锚级联漂移），
#      样式参照 RR-16 演进后口径（task-v131 先例：断言旧字面=0）。
n="$(grep -c '40-53' "$SKILLMD" || true)"
if [ "$n" -eq 0 ]; then ok 06 "SKILL.md '40-53' 旧纪元字面 =0（演进收口）"; else bad 06 "SKILL.md '40-53' 计数=$n（应 =0，旧纪元残留）"; fi

# CP-07 capability-registry.md 文件存在
# What：断言 Rule 55.4 唯一索引文件 `references/capability-registry.md` 在位。
# Why：55.1 复用前置检查的第一检索面；文件丢失 = 已落盘能力不可发现，复用纪律整体失效。
if [ -f "$REG" ]; then ok 07 "capability-registry.md 存在"; else bad 07 "capability-registry.md 缺失（$REG）"; fi

# CP-08 capability-registry.md 表头 8 列
# What：断言注册表表头行（首个 `|` 行）列数 =8（55.4 规定 8 列：名称|脚本路径|用途|调用方式|数据来源端点|输出形态|verified 日期|任务来源）。
# Why：列契约是消费方解析锚；列数漂移 = 下游按列取值错位（如把端点当输出形态），索引不可机读。
hdr_cols="$(awk -F'|' '/^\|/{print NF-2; exit}' "$REG" 2>/dev/null || true)"
if [ "$hdr_cols" = "8" ]; then ok 08 "capability-registry.md 表头 8 列"; else bad 08 "capability-registry.md 表头列数=$hdr_cols（应 8）"; fi

# CP-09 agnes-quota 登记行存在且 8 字段全非空
# What：断言注册表含 `agnes-quota` 数据行，且该行 8 个字段均非空白。
# Why：agnes-quota.sh 是 Rule 55.4 首个落盘实例；登记行 8 字段必填（55.3 登记义务）——
#      任一字段空 = 能力登记不完整（如缺 verified 日期则无法判断实测状态），复用方无从调用。
if grep -qE '^\| *agnes-quota ' "$REG"; then
  fields="$(awk -F'|' '/^\| *agnes-quota /{n=0; for(i=2;i<NF;i++){f=$i; gsub(/^[ \t]+|[ \t]+$/,"",f); if(f!="")n++} print n; exit}' "$REG")"
  if [ "$fields" = "8" ]; then ok 09 "agnes-quota 登记行 8 字段全非空"; else bad 09 "agnes-quota 登记行非空字段=$fields（应 8）"; fi
else
  bad 09 "agnes-quota 登记行缺失"
fi

# CP-10 scripts/capabilities/agnes-quota.sh 存在
# What：断言固定能力脚本目录下 agnes-quota.sh 在位。
# Why：55.4 固定落点；脚本丢失 = 注册表指向死路径（条款死文同构），复用前置检查命中后无法执行。
if [ -f "$CAP" ]; then ok 10 "scripts/capabilities/agnes-quota.sh 存在"; else bad 10 "agnes-quota.sh 缺失（$CAP）"; fi

# CP-11 agnes-quota.sh `bash -n` 语法通过
# What：断言脚本可被 bash 解析（无语法错误）。
# Why：能力脚本被复用方直接 `bash` 调用；语法错误 = 首次复用即失败（落盘资产不可执行）。
if [ -f "$CAP" ] && bash -n "$CAP" 2>/dev/null; then ok 11 "agnes-quota.sh 'bash -n' 通过"; else bad 11 "agnes-quota.sh 语法错误或不可读"; fi

# CP-12 agnes-quota.sh 无硬编码密钥
# What：断言脚本内无 `sk-<alnum>` / `cpk-` 形态密钥字面（`grep -icE` =0）。
# Why：55.4 明确禁硬编码密钥（复用既有同源密钥解析）；FMEA RPN=120 高风险项——密钥入脚本 = 凭据泄露 + 部署位污染。
n="$(grep -icE 'sk-[a-z0-9]|cpk-' "$CAP" 2>/dev/null || true)"
if [ "$n" = "0" ]; then ok 12 "agnes-quota.sh 无硬编码密钥（grep=0）"; else bad 12 "agnes-quota.sh 检出硬编码密钥 $n 处"; fi

# CP-13 agnes-quota.sh 头注释含 Rule 55
# What：断言脚本头注释含 `Rule 55`（来源条款溯源）。
# Why：Rule 45 双层注释 + 条款溯源要求；缺 = 后续维护者不知脚本归属哪条纪律（误删/误改风险）。
n="$(grep -c 'Rule 55' "$CAP" 2>/dev/null || true)"
if [ "$n" -ge 1 ]; then ok 13 "agnes-quota.sh 头注释含 Rule 55（$n 处）"; else bad 13 "agnes-quota.sh 缺 Rule 55 溯源注释"; fi

# CP-14 video-generation-executor.md 含 capability-registry ≥1
# What：断言视频生成执行体 SOP 含 `capability-registry` 复用指向。
# Why：55.5 执行体接线（防条款死文，53.2 反例 task-v131 判例）；缺 = 视频额度查询仍现场发明（Rule 55 立法对象）。
n="$(grep -c 'capability-registry' "$AGENT_VIDEO" 2>/dev/null || true)"
if [ "$n" -ge 1 ]; then ok 14 "video-generation-executor.md 接线 capability-registry（$n）"; else bad 14 "video-generation-executor.md 缺 capability-registry 接线"; fi

# CP-15 image-generation-executor.md 含 capability-registry ≥1
# What：断言图像生成执行体 SOP 含 `capability-registry` 复用指向（与 CP-14 对称）。
# Why：55.5 对称接线；两执行体缺任一 = 接线非对称，某类生成任务退回现场发明。
n="$(grep -c 'capability-registry' "$AGENT_IMAGE" 2>/dev/null || true)"
if [ "$n" -ge 1 ]; then ok 15 "image-generation-executor.md 接线 capability-registry（$n）"; else bad 15 "image-generation-executor.md 缺 capability-registry 接线"; fi

# CP-16 config.json .properties 键数=40（零新 config 键声明锚）
# What：断言 config.json 顶层 properties 键数保持 40。
# Why：55.6 承诺「零新 config 键」（与 43.4/44.4/47.4/52.4 同范式）——键数膨胀 = 有人给 Rule 55 加了机器门控键，
#      突破既定零新键范式（机制漂移，需走 Rule 36 流程）。沿用 tsv 末列既有口径 `config properties=40`。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 16 "config.json properties 键数 40（零新增）"; else bad 16 "config.json properties 键数=$keys（应 40，零新键被破坏）"; fi
elif command -v python3 >/dev/null 2>&1; then
  keys="$(python3 -c "import json;print(len(json.load(open('$CONFIG'))['properties']))" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 16 "config.json properties 键数 40（python3 校验）"; else bad 16 "config.json properties 键数=$keys（应 40）"; fi
else
  printf 'CP-16 SKIPPED jq/python3 均缺失，无法校验 config.json 键数（安装任一后重跑）\n'
fi

# CP-17 脚本自身 SCRIPT_DIR 自定位行在位（三处可跑结构锚）
# What：断言本脚本含 SCRIPT_DIR 自定位 idiom（`$0` 或 `BASH_SOURCE[0]` 形式皆可）。
# Why：仓库/worktree/三宿主部署位路径深度不同；自定位行是相对解析的根——被硬编码路径替换则三处仅一处可跑。
#      （容忍两种 idiom：先例 selftest-veto/media-dispatch 用 BASH_SOURCE[0]，本规格文字用 $0。）
if grep -qE 'SCRIPT_DIR="\$\(cd "\$\(dirname ' "$SELF"; then
  ok 17 "脚本 SCRIPT_DIR 自定位行在位"
else
  bad 17 "脚本缺 SCRIPT_DIR 自定位行（硬编码路径风险）"
fi

# CP-18 脚本头注释 What+Why 齐备（Rule 45 双层注释）
# What：断言本脚本头部注释含 `What` 与 `Why` 两个标记。
# Why：Rule 45 双层注释要求（What=做什么/Why=为何这样做）；守护脚本自身也须示范该纪律（防只写代码不写取舍）。
if grep -q '# What' "$SELF" && grep -q '# Why' "$SELF"; then
  ok 18 "脚本头注释 What+Why 齐备（Rule 45）"
else
  bad 18 "脚本头注释缺 What 或 Why（Rule 45）"
fi

# CP-19/20 agnes-quota.sh 运行时判定回归钉（本地 mock 实跑，2026-10-05 F1 修复守护）
# What：用 python3 本地 mock（仅绑 127.0.0.1、随机端口）注入 AGNES_QUOTA_BASE 实跑 agnes-quota.sh，覆盖两条运行时路径：
#   CP-19（404 模式）：两计费端点返回 404 → 脚本必须 exit≠0 且输出失败语义，禁含「计费层已回传数值」。
#   CP-20（200 模式，subscription 含 1e8 占位）：两计费端点返回 200 → 脚本必须 exit 0 且 verdict 含「未填充」。
# Why：F1=非 2xx 失败被伪报成功（R3「完全不对的结果」根因）；纯静态 grep 无法守护运行时判定逻辑，
#      必须实跑脚本咬合「非 200 不得落成功 verdict」——这是 Rule 55.2「禁伪成功」的机器面（CP-11 只验语法、不验判定）。
if command -v python3 >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 && command -v timeout >/dev/null 2>&1; then
  MOCK_DIR="$(mktemp -d)"
  MOCK_PID=''; MOCK_PORT=''
  mock_cleanup() { [ -n "$MOCK_PID" ] && kill "$MOCK_PID" 2>/dev/null; rm -rf "$MOCK_DIR"; }
  trap mock_cleanup EXIT

  cat > "$MOCK_DIR/mock.py" <<'PYEOF'
import sys, http.server
mode = sys.argv[1]
portfile = sys.argv[2]
if mode == '200':
    BODY = (b'{"object":"billing_subscription","has_payment_method":true,'
            b'"soft_limit_usd":100000000,"hard_limit_usd":100000000,'
            b'"system_hard_limit_usd":100000000,"access_until":0}')
    CODE = 200
else:
    BODY = b'{"error":{"code":"","message":"mock error"}}'
    CODE = 404
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(CODE)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(BODY)))
        self.end_headers()
        self.wfile.write(BODY)
    def log_message(self, *a):
        pass
srv = http.server.HTTPServer(('127.0.0.1', 0), H)
open(portfile, 'w').write(str(srv.server_address[1]))
srv.serve_forever()
PYEOF

  start_mock() {
    : > "$MOCK_DIR/port"
    python3 "$MOCK_DIR/mock.py" "$1" "$MOCK_DIR/port" >/dev/null 2>&1 &
    MOCK_PID=$!
    local i=0
    while [ ! -s "$MOCK_DIR/port" ] && [ "$i" -lt 100 ]; do sleep 0.1; i=$((i+1)); done
    MOCK_PORT="$(cat "$MOCK_DIR/port" 2>/dev/null || true)"
  }
  stop_mock() { [ -n "$MOCK_PID" ] && kill "$MOCK_PID" 2>/dev/null; MOCK_PID=''; }

  # --- CP-19：404 模式 → exit≠0 + 失败语义，禁含成功 verdict ---
  start_mock 404
  if [ -n "$MOCK_PORT" ]; then
    out19="$(AGNES_API_KEY='mock-test-key' AGNES_QUOTA_BASE="http://127.0.0.1:$MOCK_PORT" timeout 20 bash "$CAP" --json 2>&1)"; rc19=$?
    stop_mock
    if [ "$rc19" -ne 0 ] && printf '%s' "$out19" | grep -qE '无法判定|失败|不可达' \
       && ! printf '%s' "$out19" | grep -q '计费层已回传数值'; then
      ok 19 "agnes-quota.sh 404 模式 exit=$rc19 + 失败语义（F1 回归钉：禁伪成功）"
    else
      bad 19 "agnes-quota.sh 404 模式未咬合（exit=$rc19，需 exit≠0+失败语义且禁含成功 verdict）"
    fi
  else
    stop_mock
    bad 19 "mock(404) 启动失败（端口未就绪）"
  fi

  # --- CP-20：200 模式（1e8 占位体）→ exit 0 + verdict 含「未填充」 ---
  start_mock 200
  if [ -n "$MOCK_PORT" ]; then
    out20="$(AGNES_API_KEY='mock-test-key' AGNES_QUOTA_BASE="http://127.0.0.1:$MOCK_PORT" timeout 20 bash "$CAP" --json 2>&1)"; rc20=$?
    stop_mock
    if [ "$rc20" -eq 0 ] && printf '%s' "$out20" | grep -q '未填充'; then
      ok 20 "agnes-quota.sh 200 模式 exit=0 + verdict 含未填充（成功路径未回归）"
    else
      bad 20 "agnes-quota.sh 200 模式未咬合（exit=$rc20，需 exit=0 且 verdict 含未填充）"
    fi
  else
    stop_mock
    bad 20 "mock(200) 启动失败（端口未就绪）"
  fi

  mock_cleanup
  trap - EXIT
else
  printf 'CP-19 SKIPPED python3/curl/timeout 缺失，无法运行 mock 负向断言（安装后重跑）\n'
  printf 'CP-20 SKIPPED python3/curl/timeout 缺失，无法运行 mock 正向断言（安装后重跑）\n'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
