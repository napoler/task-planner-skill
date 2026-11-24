# 默认 mini 档「强制步骤保留」面审计 — findings-a

审计范围：仅 `/mnt/data/dev/task-planner-skill/skills/task-planner/`（canonical source）。部署位 `~/.zcode`、`~/.agents` 等未评未改。方法：只读 grep/read 静态审计；因本次唯一可写文件为本文，未执行门脚本夹具，运行时行为结论均标注为静态推断并给置信度。

## 结论摘要

1. 总评 **WARN**：P0×1、P1×6、P2×5；OK×7（允许精简项）。
2. **P0-1**：l0-lite/mini stub 通道明文宣称「零 attest」即可放行受管文件写入；`check-scope.sh` D10 mtime 仲裁不校验锁 → 判据冻结/attest 面被绕过（HIGH）。
3. **P1-1**：attest 对 mini 降 VC 门 enforce→warn、免四锚、免 FMEA；**P1-2**：l0-lite 模板宣称「3-File 回填 / G-gates 全部豁免」与机器门冲突。
4. **P1-3**：④b 保护区清单遗漏仓库根 `AGENTS.md`/`crontab`/通用 `config.json`，且 Write 无行数时保守放行（HIGH/MEDIUM）。
5. **P1-4**：`todo-sync.md` 的 mini 豁免面（B2-B8/B14/B15/B16）大于 `sync-todos.sh` 实际裁剪（B2/B6/B7/B8/B15/B16），文档可诱导跳过 B3/B4/B5。
6. **P1-5**：默认 mini 模板 `mini-lite-type.md` 无 git checkpoint / worktree 隔离 / 保护区 / §十一 引用，B8/B16 被裁；但 SKILL.md 的 worktree 铁律无 mini 豁免（文本门仍在）。
7. **P1-6**：旧 auto-tier 的 env 体量推断与 `TRIVIAL_CODE_TIER` 仍驱动 3 文件/L0 通道，`check-scope.sh` 仍留词面轻量标记描述 → 与 2026-11-24「默认 mini + 砍词面推断」裁决未完全对齐。
8. 负结果：未发现 git status / 禁 `git checkout --` / 禁 `reset --hard` / 危险命令授权 / GIT-BASELINE 门 / 3-File 主体门 / VC 非真空门 有 mini 专用豁免。
9. G4-G11 构成：G4 drift-checker，G5 findings 落盘，G6 3-file gate，G7 质量违规+commit，G8 Todo 同步，G9 逐字会话记录，G10 归档，G11 对齐核查；仅 G4/G9/G10/G11 在 SKILL.md 标注「mini 档豁免」。

## P0 漏洞

### [P0-1] mini/l0-lite stub 路径明示「零 attest」放行受管文件写入（判据冻结面被绕过）
- 检查: A3（stub 路径）＋ A2（attest 计划锁）。
- 位置与原文:
  - `skills/task-planner/scripts/zcode-pretooluse.sh:21` — 「写一个 ≤12 行极简 task_plan.md stub（…含 `plan_tier: mini`…）即解除本写入门并放行受管文件 ≤30 行（check-scope D10 mtime + check-delegation ④b mini 双门，**零新脚本零 attest**）」
  - `skills/task-planner/templates/variant/l0-lite-type.md:7` — 「stub 落盘后 check-scope D10 mtime 仲裁 … + check-delegation ④b mini 通道 … 双门放行受管文件 ≤30 行，零新脚本、零 attest」
  - `skills/task-planner/scripts/check-scope.sh:215-218` — `if [ "$_rp" -nt "$_ref" ]; then … exit 0`；该 D10 分支在 `check-scope.sh:225-251` 的 D10'' attestation 校验**之前**直接返回，无 `.plan-attestation` 校验。
  - `skills/task-planner/scripts/check-delegation.sh:338-359` — mini 命中后仅做保护区 case 与 ≤30 行判断，`exit 0` 分支无 attest 校验。
- 结果: 失败。写受管文件（非保护区、≤30 行）可在无 attestation 哈希锁、无需求原文锚、无 FMEA 的状态下进行；`Rule 20.1`/`51.15`/`111.2` 的「随 attest 锁定」在 stub 路径上无承载（`references/critical-rules.md:109,240`）。
- 影响: 属安全/判据类，非仪式类；红线「迷你≠给执行开漏洞」被击穿。缺省 mini 后该通道由历史上的特殊小改路径变成默认可达路径。
- 建议（只提不改）: stub 通道对受管文件写入加fail-closed条件=`.plan-attestation` 存在且 `plan_sha256` 一致；或禁止 stub 直写受管文件、只允许 gitignore 区。
- 置信度: HIGH（四处原文 + 分支顺序可静态复现；未做运行时夹具）。

## P1 风险

### [P1-1] attest 内 mini 判据降档：四锚豁免 + VC enforce→warn + FMEA skip
- 位置与原文:
  - `skills/task-planner/scripts/attest-plan.sh:259-261` — `[requirement-gate] INFO: plan_tier: mini 豁免(Rule 51.1 mini 档不要求需求原文区块…)`。
  - `skills/task-planner/scripts/attest-plan.sh:301` — `[ "$tier_flag" = "mini" ] && [ "$VCTIER" = "enforce" ] && VCTIER="warn"`；`:306-310` 显示 verification.md 缺失在 warn 档「不阻断」，`:325-330` 显示 VC 命令缺失也「WARNING: … warn 档不阻断」。
  - `skills/task-planner/scripts/attest-plan.sh:499-500` — `[fmea-gate] MINI-TIER SKIP (plan_tier: mini 豁免, Rule 38.4①)`。
- 结果: mini 仍会写锁，但锁定的判据面被压缩；「VC 每项须含可执行验证命令」（`SKILL.md:79`）在 mini 锁定期仅告警。属判据类弱化，非纯仪式。
- 建议: 对涉及受管文件/代码改动的 mini 计划强制 `TASK_PLANNER_VC_ENFORCE=enforce`，或把 verification.md 存在性改为 fail-closed 的结构门。
- 置信度: HIGH。

### [P1-2] l0-lite 模板宣称的豁免面大于机器门实际豁免面
- 位置与原文:
  - `skills/task-planner/templates/variant/l0-lite-type.md:6` — 「其余仪式区块（VC≥2 表 / **3-File 回填** / **G-gates** / FMEA / 知识储备 / 委派统计 / 归档）全部豁免」；`:22` — 「免 VC≥2 表 / 3-File 回填 / G-gates / 归档」。
  - 反证 `skills/task-planner/scripts/check-3file-gate.sh:347-349` — 仅 `elif grep -qm1 'plan_tier: mini' …; then DRIFT_OK=1`；豁免的是 drift 痕迹门（第 7 条件），不是 3-File 主体门（progress 回填 + findings 增量）。
  - 反证 `skills/task-planner/scripts/check-complete.sh:890-891` — `vc_min=5; [ "$PLAN_TIER_MINI" = 1 ] && vc_min=2`，VC≥2 保留；`:985-986` 仅免无 V-N 映射行。
  - 反证 `skills/task-planner/SKILL.md:162-169` — 仅 G4/G9/G10/G11 标注「mini 档豁免」，G5/G6/G7/G8 未标豁免。
- 结果: 执行者若照 l0-lite 模板跳过 3-File 回填/G5-G8，会在 `check-complete` 被拦（若补跑）；而 `l0-lite:22` 说「可随时补跑 check-complete 兜底」=把兜底当可选，形成真实漏做证据链的风险。
- 建议: 把 l0-lite 模板的豁免清单改成与 `SKILL.md:173` 六项一致（审计体/双轮复检/G4/G10/六文档回读/6 条 todo），并明确「3-File 回填与 VC≥2 不豁免」。
- 置信度: HIGH。

### [P1-3] ④b mini 直做通道保护区清单有缺口，Write 无行数时无条件放行
- 位置与原文:
  - `skills/task-planner/scripts/check-delegation.sh:339-351` — case 表含 `*/skills/*`、`*/.zcode/AGENTS.md`、`*/.agents/AGENTS.md`、`*/.zcode/cli/config.json`、`*docker-compose*|*/.env*|*Dockerfile|*nginx.conf`、`*package.json|*pyproject.toml|*/.github/*|*/.gitlab-ci.yml|*/.k8s/*|*/k8s/*`。
  - 缺口: 仓库根 `AGENTS.md`、任意 `*/AGENTS.md`、`crontab`、通用 `config.json` 均不匹配上述 case（全仓 grep 仅见 `check-delegation.sh:249,347-348` 两处 AGENTS.md 模式，无 crontab）。
  - `skills/task-planner/scripts/check-delegation.sh:353-358` — 「不可校验（Write 工具 lines_arg="-" 或非数字）→ 保守放行（保持原行为）」`case "$lines_arg" in ''|-*|*[!0-9]*) exit 0 ;;` → Write 绕过 ≤30 行上限。
  - `skills/task-planner/scripts/selftest-tier-b.sh:28` — 断言仅覆盖 `bash "$CKD" pretool "$SKILL_ROOT/SKILL.md" default 5`（skills 路径），无 AGENTS.md/crontab/Write 负例。
- 结果: mini 默认下，非保护区但受宪法 §五/§六保护的落地文件可被主进程直写；`check-scope.sh:254-257` 的轻量放行也仅限机械产物区（`check-scope.sh:157-170` 明示「不放开仓库受管文件写入」）。
- 建议: ④b 与 `is_protected_path()` 同源改为 `*AGENTS.md|*/AGENTS.md|*crontab|*/config.json`，Write 无行数改 fail-closed；补 selftest 负例。
- 置信度: MEDIUM（静态 pattern 比对；未跑运行时夹具）。

### [P1-4] mini Todo 豁免面文档 > 机器：可诱导跳过终验 VC/回读/Todo 终态
- 位置与原文:
  - `skills/task-planner/references/todo-sync.md:39` — 「mini 档豁免口径：B1 不豁免（修改后验证无小任务例外）；**B2-B8**、B14、B15、B16 随 mini 档既有豁免面」。
  - `skills/task-planner/scripts/sync-todos.sh:527-533` — `if [[ "$mini_baseline" -eq 1 ]]; then case "$tid" in B2|B6|B7|B8|B15|B16) continue ;;`；实际保留 B3（终验 VC 复验）/B4（收尾回读）/B5（Todo 终态）/B9-B14。
  - `skills/task-planner/SKILL.md:173` — 「基线 todo 裁 6 条（B2/B6/B7/B8/B15/B16，sync-todos）」与脚本一致。
- 结果: `todo-sync.md` 是「基线组固定清单唯一事实源」（同文件 :40），若执行者按文档跳过 B3/B4/B5，与机器事实不一致。双组同步本身在 mini 保留（`SKILL.md:175-177` S1-S5、`:59` S1 强制），被裁的是基线组条目而非双组结构。
- 建议: 把 `todo-sync.md:39` 收窄为与脚本一致的 6 条，并注明 B9-B11 Git 基线项不裁。
- 置信度: HIGH。

### [P1-5] 默认 mini 骨架缺 git/worktree/§十一 承载，B8/B16 被裁
- 位置与原文:
  - `skills/task-planner/templates/variant/mini-lite-type.md:8` — 「38.3 区块白名单: 仅 Goal/VC/执行范围限制表/单 Phase/Handoff 表, 增其他仪式区块=模板违约」；全文（`:1-50`）无 `git checkpoint`、`worktree`、`§十一`、`保护区`、`危险命令` 字面。
  - 对照主模板 `skills/task-planner/templates/task_plan.md:350` — 「Git checkpoint（git-rework-guard）… `git add <scope 文件> && git commit`」；`:426-441` — 「🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）… 契约详见 …/worktree-isolation.md」。
  - `skills/task-planner/scripts/sync-todos.sh:531` 裁 B8（worktree 核验）/B16（合并回+回归）；`references/todo-sync.md:36` 原文「B8 未勾=实现类不得直接改主树」、B16 需 `.isolation.merge_back` 含 `merged(`。
  - `skills/task-planner/scripts/init-session.sh:1102-1106` — mini 档不写 `template_body`，`planctl.py:1781` 的领域附录对 mini 豁免，故 variant 正文不会经 render 回流补进 task_plan.md。
- 结果: 文本层隔离铁律仍在（`SKILL.md:202`「实现类任务一律首选 git worktree 隔离…禁止就该安全默认向用户发起确认」；`check-conflicts.sh:105` 同口径），未发现 mini 专用豁免；但默认骨架/提醒层掉了 git checkpoint 与 worktree 核验，属 reminder/evidence 风险而非已证实的绕过。
- 建议: 在 mini-lite 白名单内加一行「实现类仍按 §十一 worktree 隔离 + 单 S-unit commit checkpoint」，B8 对实现类保留（或改由机器门校验 isolation 决策）。
- 置信度: MEDIUM（模板全文与裁项原文确凿；是否实际直改主树取决于执行者）。

### [P1-6] 2026-11-24 裁决未完全落地：旧 auto-tier env 与词面描述仍存活
- 位置与原文:
  - `skills/task-planner/scripts/init-session.sh:642-644` — 「词面推断（.plan_scope 方案）被用户裁决否弃——推断本身即主观判断」，`:649-651` 缺省 mini；
  - 但 `:602-637` 保留 `TASK_SCOPE_FILES/TASK_SCOPE_MODULES/TASK_EST_MINUTES/TASK_EST_LINES/TASK_SCOPE_FILE_LIST` 的 `_trivial_code` 判定，`:655-656` `TRIVIAL_CODE_TIER=1`；`:766-770` 该标记触发 3 文件裁剪；`:897-898` 传 `--trivial` 给 lane-detect → L0 通道。
  - `skills/task-planner/SKILL.md:54` 仍写「主进程从用户指令解析 scope 文件列表与预估行数以 env 传入…第四条件命中 mini+L0+trivial 三文件缩减档（Rule 38.6）」。
  - `skills/task-planner/scripts/check-scope.sh:104` — 「task-plan-init.cjs 检出轻量/机械词面…写 <sidkey>.plan_lightweight」；`templates/variant/l0-lite-type.md:5` — 「触发词面：轻量 / 单文件 / 纯文本 / 就改一处…」；`zcode-pretooluse.sh:21` 仍以「轻量/单文件小改」描述触发 stub。
- 结果: init 的档位判定已改（mini 缺省），但 env 体量事实仍决定**文件集/通道**，词面描述仍在 hook/模板/门注释中存活；与「默认 mini + 砍词面推断」存在口径冲突，且 3 文件档的实际触发依赖无调用方的 env（`init-session.sh:642` 自承「全仓无调用方提交 → 机制从未触发」）。
- 建议: 明确把 `TRIVIAL_CODE_TIER` 降级为纯历史兼容并注明不再作为安全判定；清理/标注 check-scope:104 与 l0-lite:5 的「词面」措辞，避免被解读为仍可凭词面降档。
- 置信度: HIGH（冲突原文逐字可复现；是否构成"未砍干净"取决于裁决对 env 事实的边界解释）。

## P2 建议

### [P2-1] G4-G11 文案与 SKILL.md 豁免面不一致
- `scripts/zcode-posttooluse.sh:219,304` — 「VC 阈值恢复 standard、**G4-G11 不再豁免**、收尾回读恢复全量六文档」；但 `SKILL.md:162,167,168,169` 仅 G4/G9/G10/G11 标「mini 档豁免」，G5（findings 落盘）/G6（3-file gate）/G7（违规+commit）/G8（Todo 同步）从未豁免。文案在升级语境偏保守（安全侧），但会让审计误判 mini 实际豁免面。建议改为「G4/G9/G10/G11 恢复」。

### [P2-2] G11「mini 档豁免」与机器门不符（写入锁方向）
- `SKILL.md:169` — 「机器门=check-complete.sh ALIGN-ANCHOR GATE（enforce=缺锚阻断，**mini 档豁免**）」；`scripts/check-complete.sh:1787-1790` — `ALIGN_ANCHOR_TIER="$(resolve_align_anchor_tier)"; if [ "$ALIGN_ANCHOR_TIER" != "off" ]; then align_anchor_gate ... || exit 1; fi`，无 mini 判定（实际对 mini 也执行）。建议统一文案为「不豁免」。

### [P2-3] config 阈值与 template 口径漂移
- `config.json:407` — 「判定=计划 frontmatter plan_tier: mini ∧ **scope ≤2 文件** ∧ ≤15min ∧ 单模块」；`templates/variant/mini-lite-type.md:2,30` 已改「≤5 文件」；`scripts/check-plan-dispatch.sh:96-98` 阈值改 7 行（5 数据行）并注明「文案字面『>2』保留不改」。建议同步 config 描述与断言锚，避免 MISMATCH 误报。

### [P2-4] mini 骨架未提示规范基线/进度产出基线登记
- `templates/variant/mini-lite-type.md:8` 的白名单无 `🔒 规范基线`；`scripts/planctl.py:1647-1652` 仅在 JSON `spec_baseline` 非空时渲染该段（无 mini 豁免，但也不主动提示）；`references/critical-rules.md:109` 要求「无基线候选须显式写 none-justified，禁静默遗漏」。建议在 mini-lite 加一行基线登记提示（含 none-justified）。

### [P2-5] SOFT_ONLY 仅 WARN，mini 默认放大直接 Edit MD 空间
- `scripts/attest-plan.sh:82-84` — 「warn-only 空壳检测（SOFT_ONLY 信号）… 用户裁决不加拦截门」；`:101` — 「WARN: plan-state.json 业务数据为空而 task_plan.md 已被手工填写」。已有用户裁决，不新增门；建议只在 mini 审计复核清单中列为人工必查项（用户裁决优先，文本提示即可）。

## OK-允许精简（仪式类，未触碰安全底线）

1. **[OK] VC 表与验证区块保留**：`templates/variant/mini-lite-type.md:19-26` 仍有 `Verification Contract` 表 + 「终验规则: 全部 VC 通过 → COMPLETE（VC ≥2…）」；`templates/verification.md:14-30` 保留 `**Verify command**` 行；`scripts/check-complete.sh:890` mini `vc_min=2`、`:891` `vn_thresh_base=1`（降数量阈值，不删门）。
2. **[OK] VC 非真空门不降档**：`scripts/check-complete.sh:1039-1044` `run_vc_nonvacuous` / `run_rvc_coverage` 在 VC_GATE_TIER!=off 时无条件接线；`:810-832` enforce 档拒 COMPLETE，无 mini 分支。
3. **[OK] 3-File 主体门保留**：`scripts/check-3file-gate.sh:347-349` 只豁免 drift 子门；`scripts/selftest-tier-b.sh:46` 锁定 T-B7「纯实施 Phase 一行声明句」；`SKILL.md:119` 对 mini 无豁免措辞。
4. **[OK] Git 基线终验门保留**：`scripts/check-complete.sh:1492-1505` 仅 `execution_lane: L0-E` 与 legacy-no-json 跳过；mini 计划（无 L0-E 声明）走 `git-baseline.sh diff --final`，rc=1/3 默认 exit 1（`:1527-1535`）。`sync-todos.sh:492-494` 的 B9/B10/B11 Git 基线 todo 不在 mini 裁剪表。
5. **[OK] 保护区写入门保留**：`scripts/check-delegation.sh:335-363` 明确「保护区(§六: skills/agents/commands/AGENTS.md/cli config/基础设施)永不放行 — mini 直做红线」；`scripts/selftest-tier-b.sh:28` 断言「mini 保护区仍拦截」。缺口见 P1-3。
6. **[OK] 危险命令/工作树文本门无 mini 豁免**：全仓 grep 未在 `zcode-pretooluse.sh`/`zcode-posttooluse.sh` 找到 `rm -rf`/`eval`/`curl|bash` 的 mini 放行分支；`SKILL.md:202` worktree 铁律与 `check-conflicts.sh:105` 无 mini 例外；`references/worktree-isolation.md:24` 同样无 mini 例外。
7. **[OK] 完成三条件与轻量裁剪边界**：`references/methodology.md:75` 「批内每单元独立三证据验收（执行记录 / 产出 Read 复核 / 验证证据）」无 mini 豁免；`references/critical-rules.md:107` 的 51.14 一行式例外仅限「单文件 ≤3 行 trivial 修改的自述」且只免耗时项。
8. **[OK] 双组 Todo 同步在 mini 保留**：`SKILL.md:59` S1「每 Phase 一条原生 Todo；禁止只建计划不建 Todo」、`:175-177` S1-S5 五时机无 mini 豁免；`sync-todos.sh:481-504` 双组结构先全量构造，再仅按 mini 跳过 6 条基线项。
9. **[OK] 缺省档自动升级检查面恢复**：`scripts/zcode-posttooluse.sh:243-304` 的 `tier_upgrade_check` 在 mini 且（15min+步骤门 / 45min 兜底）时 `planctl set plan_tier=standard` 并注入 `[tier-upgrade]`；`:285-289` 还处理 mini-lite 骨架导致旧锁失配的 stale 锁问题（属升级链，本次只核保留面）。

## 主进程复核清单（只读、可直接执行）

```bash
cd /mnt/data/dev/task-planner-skill
# R1 P0-1：确认 stub 文案 + D10 mtime 在 attest 仲裁之前 exit 0
grep -n '零 attest\|零新脚本零 attest' skills/task-planner/scripts/zcode-pretooluse.sh skills/task-planner/templates/variant/l0-lite-type.md
grep -n 'exit 0\|D10.*attestation\|\.plan-attestation' skills/task-planner/scripts/check-scope.sh | sed -n '1,40p'
# R2 P1-1：attest 的 mini 降档三处
grep -n 'mini 豁免\|VCTIER="warn"\|MINI-TIER SKIP' skills/task-planner/scripts/attest-plan.sh
# R3 P1-2 / P1-4：模板宣称豁免面 vs 机器实际裁剪
grep -n '3-File 回填\|G-gates' skills/task-planner/templates/variant/l0-lite-type.md
grep -n 'B2|B6|B7|B8|B15|B16\|B2-B8' skills/task-planner/scripts/sync-todos.sh skills/task-planner/references/todo-sync.md skills/task-planner/SKILL.md
# R4 P1-3：保护区 pattern 覆盖与 mini 负例断言面
sed -n '335,363p' skills/task-planner/scripts/check-delegation.sh
grep -rn 'AGENTS\.md\|crontab' skills/task-planner/scripts/check-delegation.sh skills/task-planner/scripts/selftest-tier-b.sh
# R5 P1-5 / OK-1：mini-lite 骨架缺安全锚 vs 主模板保留
grep -n -i 'git checkpoint\|worktree\|§十一\|保护区\|危险命令' skills/task-planner/templates/variant/mini-lite-type.md || true
grep -n 'Git checkpoint\|🔀 隔离决策' skills/task-planner/templates/task_plan.md
# R6 OK-2/3/4：终验门保留面
grep -n 'vc_min=2\|run_vc_nonvacuous\|DRIFT_OK=1\|SKIP lane-L0-E\|git-baseline' skills/task-planner/scripts/check-complete.sh skills/task-planner/scripts/check-3file-gate.sh | head -40
# R7 A5：旧 auto-tier 生态与词面残留
grep -n 'TRIVIAL_CODE_TIER\|TASK_SCOPE_FILE_LIST\|词面推断\|缺省轻量档 mini' skills/task-planner/scripts/init-session.sh
grep -rn '词面\|plan_lightweight' skills/task-planner/scripts/check-scope.sh skills/task-planner/templates/variant/l0-lite-type.md
# R8 G4-G11 清单与升级文案
sed -n '156,173p' skills/task-planner/SKILL.md
grep -n 'G4-G11 不再豁免' skills/task-planner/scripts/zcode-posttooluse.sh
```
