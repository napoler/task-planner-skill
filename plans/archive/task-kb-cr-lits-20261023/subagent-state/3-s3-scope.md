# S3 check-scope.sh 定点缺陷修复（L-7 + L-8）检查点

- task: task-kb-cr-lits-20261023 / Phase 1 S3
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023（分支 wt/task-kb-cr-lits-20261023）
- 改动文件（唯一）: skills/task-planner/scripts/check-scope.sh（git status: M，未 commit）
- 状态: done（修复完成 + 行为自测通过）

## 1. diff 摘要（git diff --stat: +58 / -21）

### L-7（同构判定重复 → 抽函数）
- 新增 `_is_artifact_or_gitignored_path`（check-scope.sh:128-140 区段）：机械产物区（`$ROOT/tmp/|output/|.cache/` case 前缀）∨ gitignore 区（`git -C "$ROOT" check-ignore -q`），判定顺序与原版逐字一致（case 先、check-ignore 后，双命中返 0）；形态参照 check-delegation.sh:260 is_mechanical_artifact_path，但含 gitignore 区扩展。纯判定，无 echo/无副作用。
- 新增 `_artifact_zone_label`（:141-149 区段）：文案子区标签（「机械产物区」vs「gitignore 区」），纯 case 前缀、不调 git；复刻原版「case 优先」文案选取规则，防双命中路径文案漂移。
- `_lightweight_release` 口径①（原 :121-130）与口径②（原 :133-142）的 case + git check-ignore 重复判定全部改为调用 `_is_artifact_or_gitignored_path`；echo 文案模板化（`$_zone` 展开后与原文逐字一致）：
  - 口径①: `✅ 轻量档放行（会话级标记 X + 机械产物区|gitignore 区 P）`
  - ⚠: `轻量档标记存在但目标非机械产物区（P）→ 按仓库受管文件拦截`（不变）
  - 口径②: `✅ 机械产物区|gitignore 区放行（P 不构成仓库受管文件变更）`
- 注释锚修正：口径① How 注「与本文件 :99 边界声明」→「与上方 ④ 边界声明」（头注扩行导致 :99 行号锚失效，改节号锚）。

### L-8①（头注 exit code 放行来源枚举）
- 原 2 行 `0 = ALLOWED (…)` 扩为 10 行枚举（按实际代码逐条）：空 FILE_PATH / 无项目根 / 写 plans/ 目录（节②）/ 豁免文件名（节③）/ D10 check-time 仲裁（节⑤）/ D10'' attestation 仲裁（节⑤）/ P1 会话级轻量标记 .plan_lightweight + 机械产物区∨gitignore 区（节④ 口径①）/ P1 机械产物区 tmp|output|.cache ∨ gitignore 区（节④ 口径②，legacy 哨兵在位经同入口放行，节⑥）/ 无哨兵（节⑥）。

### L-8②（放行留痕 echo stdout → >&2）
- 改 5 处放行留痕 echo 加 `>&2`：口径① 机械产物区 / 口径① gitignore 区 / ⚠ 标记在位非产物区 / 口径②（两区合一模板）/ D10'' attestation 仲裁放行。阻断文案（🚫，原 :223-231/:242-250）保持 stdout 不动（不在本项 CR 范围）。

## 2. L-8② 消费面判定证据与结论

**判定：无「stdout 被展示为放行原因文本」的消费面证据 → 改 >&2（已执行）。**

证据（grep 全调用面）：
1. `/home/terry/.zcode/cli/config.json:46` — 注册的 PreToolUse 命令 = `bash /home/terry/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh`（check-scope 不直接注册于 config）。
2. `zcode-pretooluse.sh:18` — 唯一 stdout 侧调用：`TASK_PLANNER_SID=… bash "$SKILL_ROOT/check-scope.sh" "$tool" "$file"`，随后**只读 `rc=$?`**（:19-20），不捕获/不展示其 stdout；rc=1 时阻断反馈由 zcode-pretooluse.sh 自行 `echo … >&2` + `exit 2`（:21）。stdout 侧 JSON 注入协议（`{"additionalContext"}`）只消费 zcode-pretooluse 自身输出（:152/:88），check-scope 的非 JSON `[PLAN-GUARD]` 行不构成该协议载荷。
3. `register-hooks-cj.ts:129-130` — 仅对 workflow 四工具直接注册 check-scope（ZCode 运行位），该 matcher 下 file_path 恒空 → 脚本 :32 空路径即 exit 0、零输出。
4. `~/.zcode/hooks` 目录不存在；`grep -rn 'PLAN-GUARD'`（除 check-scope 自身与 task-plan-init.cjs 注释）无任何断言/消费。
5. selftest 对 check-scope 的断言仅 grep 关键字计数（`memories` ≥1、`knowledge-brief.md` ≥1），与 stdout/stderr 通道无关。

结论依据与决定：放行留痕纯诊断面，stdout 无任何消费方 → 依 CR 建议改 `>&2`，对齐 zcode-pretooluse.sh:44「阻断反馈走 stderr」既有惯例；阻断（🚫）文案不在 L-8② 范围，不动。

## 3. 行为自测输出（临时 git 仓 $WT/tmp/scope-selftest/repo，测后已清理）

仓 setup：git init + plans/ + .gitignore(ignored/) + 哨兵 zztest.plan_required + 标记 zztest.plan_lightweight（sid=zz-test→sidkey=zztest）。运行 `TASK_PLANNER_SID=zz-test bash check-scope.sh Write <path>`：

| 场景 | 期望 | 实测 |
|---|---|---|
| 哨兵+标记, repo/tmp/foo（口径①机械区） | 0 + 放行文案 | rc=0, stderr `✅ 轻量档放行（会话级标记 zztest.plan_lightweight + 机械产物区 …/tmp/foo）` |
| 哨兵+标记, repo/ignored/x（口径①gitignore 区） | 0 | rc=0, stderr `✅ 轻量档放行（…+ gitignore 区 …/ignored/x）` |
| 哨兵+标记, repo/src/foo.js（受管） | 1 | rc=1, stdout 🚫 阻断文案（原文不变）+ stderr ⚠「标记存在但目标非机械产物区」 |
| 哨兵+无标记, repo/tmp/foo（口径②机械区） | 0 | rc=0, stderr `✅ 机械产物区放行（…/tmp/foo 不构成仓库受管文件变更）` |
| 哨兵+无标记, repo/ignored/y（口径②gitignore 区） | 0 | rc=0, stderr `✅ gitignore 区放行（…/ignored/y 不构成仓库受管文件变更）` |
| 哨兵+无标记, repo/src/a.js | 1 | rc=1, stdout 🚫, stderr 空 |
| 无哨兵, src/foo.js / tmp/foo | 0 静默 | rc=0, stdout/stderr 均空 |

- `bash -n` 语法通过；selftest 关键字断言复核：`grep -c memories`=2（T1 ≥1 过）、`grep -c knowledge-brief.md`=1（T4 ≥1 过）。
- 放行留痕全部走 stderr、stdout 空 —— L-8② 生效验证。
- 测试临时仓与 /tmp/scope-test.stderr.tmp 已删除（$WT/tmp/ 残留 vc2-l0* 系其他 S-unit 产物，未触碰）。

## 4. 遗留 / 风险

1. 阻断文案（🚫，stdout echo）仍走 stdout：不在 L-8② 范围（CR 只点了放行留痕）；且 zcode-pretooluse.sh 侧已有 stderr 阻断兜底（rc=1 时自产 stderr 文案），双份阻断文本（stdout 🚫 + stderr 兜底）为既有行为，未改。如需统一 >&2 属后续 CR 项。
2. 外部行号锚漂移：本次头注扩行使 `zcode-userpromptsubmit.sh:36` 引用的 `check-scope.sh:85` 等跨文件行号锚进一步失准（既有问题，非本次引入；本 S-unit 范围约束不碰其他文件，未修，登记待后续）。
3. worktree 内其他文件（README/ARCHITECTURE/check-delegation/task-plan-init.cjs 等）为 S1/S2 已改产物，S3 未触碰。
4. 未 commit（任务约束）；合并回契约由主控执行。
