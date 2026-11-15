# clause-drafts — task-crossvalidate-20261115（Rule 108 交叉验证纪律）

## §1 Rule 108 条款全文（落位：`skills/verification-gate/references/critical-rules-verification.md` EOF `:58` 后追加）

### 108 交叉验证纪律（隔离上下文多角度识别执行错误与虚构；2026-11-15 task-crossvalidate-20261115）

108.1 **定义与触发面**：交叉验证=对同一验证对象由 ≥2 个上下文隔离、视角互异的验证路径独立产出结论并交叉比对的方法论。触发面任一命中即强制：① 交付终验含 L2+ 档位完成声称（51.14 口径）② 多文件变更集（≥2 受管文件）终验 ③ 子代理验证类产出（Verifier/复检体/critic 结论）被采信前 ④ 用户明确要求。mini/L0 档豁免。与既有面分工：84.4/84.7/Rule 103 为构成路径，本条提供交叉比对与分歧处置总框架（互补不复写）。

108.2 **独立重推导（反虚构第一原则）**：验证路径禁以被验证方自我声称/回报文本作证据，只可作定位索引；结论必须从盘上产物/命令重跑/diff 实测独立推导；验证者材料包须剥离或标注执行者完成声称段为 untrusted（判例=subagent-verifier-fabricated-output-20261103 判例：verifier 未执行命令即拼写「原始输出」，claimed 行号/字段与盘上全不符）。

108.3 **双视角交叉**：两路径视角互异且信息源不共用——机械面=可执行命令/脚本/计数重跑（run-verification.sh/selftest/grep 计数）；语义面=对抗性挑刺（critic）或全新复检体全文回读（103.3a）。两路径独立执行禁串阅对方结论（并行派发或材料隔离）；单路径结论禁标「已交叉验证」。

108.4 **分歧升级协议**：两路结论不一致→禁合并平均/择优采信→第三方裁决=decision-arbiter 派发或主进程盘上实测第三方重推导；裁决留痕（Decisions Made/checkpoint/progress）。一致→PASS 且双锚记录（两路径证据路径均记）。

108.5 **伪造识别信号与全量复核**：回报的行号/字段/计数/路径与盘上实测不符=造假第一信号→立即判该产出不可信→抽样转全量盘上复核→记 findings 判例；伪造证据零豁免（对齐 Rule 26）。

## §2 verification.md 模板 CV 区块（落位：`skills/task-planner/templates/verification.md` `:127` 后、`:131` 前插入）

```md
## 交叉验证记录（Rule 108）
<!-- 触发面见 critical-rules-verification.md 108.1（L2+/≥2受管文件/子代理验证产出采信前/用户明确要求）；mini/L0 豁免。未触发登记：`未触发（原因）`；触发但单路径=FAIL。 -->

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| {VC/交付物/产出} | {cmd + exit/摘录 + 证据路径} | {复检体/critic + 结论 + 证据路径} | 一致 PASS / 分歧→{第三方裁决+留痕} |
```

## §3 级联 spec（逐文件精确变更清单）

1. `skills/verification-gate/references/critical-rules-verification.md`（锚 EOF `:58` 后）  
   - **旧→新**：在末行 `84.14 ... 零新 check-complete GATE 零新 config 键。` 后追加空行 + §1 全文（`### 108 ...` 至 `108.5 ...`）。
2. `skills/verification-gate/SKILL.md`  
   - `:4` description：`VC 逐条复验。` → `VC 逐条复验、交叉验证识别执行错误与虚构。`（触发词加「交叉验证」）
   - `:24-31` 调用时机：末项后追加 `7. 终验/子代理产出采信前需隔离双视角交叉验证或识别伪造信号时（Rule 108）`
   - `:87` References 表首行：`| \`references/critical-rules-verification.md\` | 验证域规则全文（Rule 84.1-84.6 + 迁移的 VC 规则/子代理验证协议） |` → `| \`references/critical-rules-verification.md\` | 验证域规则全文（Rule 84.1-84.14,108 + 迁移的 VC 规则/子代理验证协议） |`
3. `skills/task-planner/SKILL.md`  
   - `:220` 路由行 rule 列：`| verification-gate | 任务验证全链路 | ... | VC 可执行化设计/执行期 V-N 校验/终验 VC 复验/子代理验证/统一验证入口（Rule 84） |` → `...（Rule 84,108） |`
   - `:224` 枚举句尾：`（均 task-discipline 卫星））——**非核心域规则勿在本技能展开**（Rule 82 回归防线）。` → `（均 task-discipline 卫星））、Rule 108 交叉验证纪律域（verification-gate 卫星）——**非核心域规则勿在本技能展开**（Rule 82 回归防线）。`；并将本行与 `:9`、`:267` 中 `1-107` → `1-108`
   - `:9`：`（其余 90 条按域归 12 卫星，见文末「卫星路由表」）` → `（其余 91 条按域归 12 卫星，见文末「卫星路由表」）` 且 `1-107`→`1-108`
   - `:267`：`Critical Rules 核心域 1-107 全集索引...` → `Critical Rules 核心域 1-108 全集索引...`
4. `skills/task-planner/scripts/selftest-enumerate-first.sh`（EN-06 纪元演进，阈值不变）  
   - `:9` 注释：`1-107`→`1-108`、`,107`→`,108`；`:92` 注释同改  
   - `:93`：`grep -c '1-107'` → `grep -c '1-108'`；`:94`：`,107`→`,108`  
   - `:95`：`'1-107'`→`'1-108'`、`,107`→`,108`；`:97` 同改
5. `skills/task-planner/templates/verification.md`（锚 `:127` 后、`:131` 前）  
   - **旧→新**：在 `> **验证独立性**：...（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）` 行与 `---`/`## 5-Question Reboot Check` 之间插入空行 + §2 区块 + 空行。
6. 新建 `skills/task-planner/scripts/selftest-cross-validation.sh`（形态对齐 `selftest-verification-gate.sh` `:1-40` 路径解析与 PASS/FAIL 计数）：
```bash
#!/usr/bin/env bash
# selftest-cross-validation.sh — Rule 108 交叉验证纪律静态守护（CV-01..CV-06）
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SATELLITE_ROOT="$(cd "$TP_ROOT/../verification-gate" && pwd)"
SAT_CRIT="$SATELLITE_ROOT/references/critical-rules-verification.md"
SAT_SKILL="$SATELLITE_ROOT/SKILL.md"
TP_SKILL="$TP_ROOT/SKILL.md"
TP_TPL="$TP_ROOT/templates/verification.md"
REG_TSV="$SCRIPT_DIR/selftest-registry.tsv"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'CV-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'CV-%s FAIL %s\n' "$1" "$2"; }
# CV-01 108.1-108.5 子条各≥1
if grep -qE '^108\.1 ' "$SAT_CRIT" && grep -qE '^108\.2 ' "$SAT_CRIT" && grep -qE '^108\.3 ' "$SAT_CRIT" && grep -qE '^108\.4 ' "$SAT_CRIT" && grep -qE '^108\.5 ' "$SAT_CRIT"; then ok 01 "规则文 108.1-108.5 子条锚在位"; else bad 01 "规则文 108.1-108.5 子条锚缺失"; fi
# CV-02 判例锚
if grep -q 'subagent-verifier-fabricated-output-20261103' "$SAT_CRIT"; then ok 02 "判例锚 subagent-verifier-fabricated-output-20261103 在位"; else bad 02 "判例锚缺失"; fi
# CV-03 verification-gate SKILL 含 Rule 108
if grep -q 'Rule 108' "$SAT_SKILL" || grep -q '108' "$SAT_SKILL"; then ok 03 "verification-gate SKILL 含 Rule 108 指针"; else bad 03 "verification-gate SKILL 缺 Rule 108"; fi
# CV-04 task-planner SKILL 含 Rule 108 且路由行含 108
if grep -q 'Rule 108' "$TP_SKILL" && grep -q 'Rule 84,108' "$TP_SKILL"; then ok 04 "task-planner SKILL 含 Rule 108 且路由行含 84,108"; else bad 04 "task-planner SKILL 缺 Rule 108 或路由 84,108"; fi
# CV-05 模板含交叉验证记录区块
if grep -q '交叉验证记录（Rule 108）' "$TP_TPL"; then ok 05 "verification 模板含交叉验证记录（Rule 108）"; else bad 05 "verification 模板缺交叉验证记录区块"; fi
# CV-06 registry.tsv 含 selftest-cross-validation 行
if grep -q '^selftest-cross-validation.sh' "$REG_TSV"; then ok 06 "registry.tsv 含 selftest-cross-validation 行"; else bad 06 "registry.tsv 缺 selftest-cross-validation 行"; fi
TOTAL=$((PASS+FAIL)); echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"; [ "$FAIL" -eq 0 ] && exit 0 || exit 1
```
7. `skills/task-planner/scripts/selftest-registry.tsv` 追加行（4 列，tab 分隔）：  
   `selftest-cross-validation.sh	CV-01..06 交叉验证纪律守护(Rule 108)：108.1-108.5 子条/判例锚/verification-gate 与 task-planner SKILL 接线/路由84,108/模板CV区块/registry自登记	critical-rules-verification.md Rule 108 段改动 / verification-gate 与 task-planner SKILL 及模板级联改动	critical-rules-verification.md;SKILL.md(verification-gate);SKILL.md(task-planner);templates/verification.md;scripts/selftest-registry.tsv`
