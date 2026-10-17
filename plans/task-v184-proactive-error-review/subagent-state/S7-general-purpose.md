# S7 general-purpose 检查点 — selftest-evidence-anchor CLAIM_MATCH 断言 + 文案收尾（task-v184）

**任务**：给 `selftest-evidence-anchor.sh` 扩 CLAIM-01..06 行为断言（锁 S6 落地的 CLAIM_MATCH 层），
并收尾 `selftest-verification-gate.sh` :4 行文案（84.6→84.7）。

## 改动清单（2 文件，纯增量）

| 文件 | 改动 | 行数 |
|------|------|------|
| `skills/task-planner/scripts/selftest-evidence-anchor.sh` | 头注 20→26 条/四组→五组 + CLAIM_MATCH 组说明；新增 `okc`/`badc` 助手（CLAIM 前缀，区别于既有 `ok`/`bad` 的 EA 前缀）；追加 CLAIM-01..06 断言块（注释标 task-v184-S7） | +87 |
| `skills/task-planner/scripts/selftest-verification-gate.sh` | :4 行 What 注释「84.1-84.6 子条文本锚」→「84.1-84.7 子条文本锚」 | 1 行 |

## 断言设计（逐条对照 S6 M3 实测期望）

夹具统一用既有 `make_fixture`（造 task_plan.md + delivery-summary.md，R1 证据格=入参）+ 追加 `ea.md`
（≥5 行）作被引文件；档位走 `env -u`（默认）/ `enforce` / `off`（config `claim_match_enforce.default=warn`
已在 config.json 固化）。全部 mktemp 于 /tmp，跑毕 `rm -rf`。

| 断言 | 夹具 R1 证据格 | ea.md 内容 | 档位 | 期望 | 实测 |
|------|---------------|-----------|------|------|------|
| CLAIM-01 | `ea.md:5 Total: 90 PASS=90` | `Total: 80 PASS=80` | 默认 warn | rc=0 + `[claim-mismatch] ⚠` | PASS |
| CLAIM-02 | 同 C01 | 同 C01 | enforce | rc=1 + `[claim-mismatch] ✗` | PASS |
| CLAIM-03 | `ea.md:5 Total: 80 PASS=80` | `Total: 80 PASS=80` | 默认 warn | 无 mismatch 行 rc=0 | PASS |
| CLAIM-04 | `Total: 90 PASS=90`（无路径 token） | — | 默认 warn | SKIP 无 mismatch rc=0 | PASS |
| CLAIM-05 | `ea.md:5 Total: 90 PASS=90` | `Total: 80 PASS=80` | off | 整层跳过无 CLAIM 输出 rc=0 | PASS |
| CLAIM-06 | `artifact.md:2`（干净无声明串） | — | 默认 warn | 无 claim-mismatch + ✓ 证据锚全过 | PASS |

关键实现点：
- `okc`/`badc` 助手：既有 `ok()`/`bad()` 硬编码 `EA-%s` 前缀，CLAIM 断言需 `CLAIM-%s` 前缀，故新增
  同构助手（PASS/FAIL 计数器共享，Total 行不变）。
- 默认档用 `env -u TASK_PLANNER_CLAIM_MATCH_ENFORCE` 显式清 env，免疫环境变量泄漏。
- ⚠/✗ 行走判定器 stdout，`2>&1` 全捕获；用 `grep -qF` 固定串匹配避免多字节正则问题。
- CLAIM-04 的 R1 格无路径 token → 主路径层不判（无 token 不触发 judge_token），CLAIM 层 SKIP，双 rc=0。

## 验收（全绿）

| 项 | 命令 | 结果 |
|----|------|------|
| 1 | `bash selftest-evidence-anchor.sh` | `Total: PASS=26 FAIL=0` rc=0（20 EA + 6 CLAIM） |
| 2 | `bash run-selftests.sh --only evidence-anchor` | `1 PASS=1 FAIL=0` rc=0 |
| 3 | `bash selftest-verification-gate.sh` | `Total: PASS=13 FAIL=0` rc=0（VG-02 已按 84.1-84.7 校验） |
| 4 | `bash selftest-registry.sh` | `registry rows=91, actual selftest=91`（断言增量不新增行） |
| 5 | `bash run-selftests.sh --only gate-injection` | `1 PASS=1 FAIL=0` rc=0 |
| 6 | `git status --short` | 仅 2 目标文件 M（+ S6 遗留 check-evidence-anchor.sh M），无 git 写 |

## 限制 / 未做事项

- 未改 registry（selftest-evidence-anchor 已登记，断言增量不新增行，符合 Rule 36.5 纯增量）。
- 未扩 CLAIM_PATTERNS 词表（四形态已覆盖任务要求；新增形态属 S6 词表职责，非 S7 断言面）。
- 未做 CLAIM_MATCH 与路径层档位交互的端到端（EA-16..20 已覆盖路径层端到端；CLAIM_MATCH 端到端由
  check-complete 真链在 enforce 档的 CLAIM-02 行为断言间接覆盖，未另起 check-complete 夹具）。

## 风险

- 低：CLAIM-01/02 夹具的 R1 证据格同时含路径 token 与声明串，依赖判定器「同格抽取」设计（S6 已落地）；
  若未来抽取规则变更（如声明串被误判为 token），CLAIM-01/02 会 FAIL 暴露——属预期守护行为。
- 文案改动（84.6→84.7）零断言影响，VG-02 校验子条锚≥6 仍 PASS。
