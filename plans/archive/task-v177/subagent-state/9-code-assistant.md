# 9-code-assistant checkpoint — task-v177 S6（variant 模板止血）

status: done

## 改动（2 文件，仅模板面）

### skills/task-planner/templates/variant/image-type.md（3 处 + 3 处注释）
1. **Phase 5（:73）多抽卡 N 候选**：保留多抽卡+批量出 N 候选（自主迭代能力保留），
   新增「主进程按命中的三检/QC 判据自选定并逐件登记淘汰记录（随 P7 收尾交付附上，用户不逐项拍板）；
   仅 N 轮修词重抽耗尽仍不达验收 = STOP 上抛用户（必带逐轮缺陷证据+4 维归因+推荐三件套）」。
2. **Phase 6（:81）修词重抽环**：新增「每轮自主取舍重抽/换词并记命中判据+淘汰理由，
   N 轮耗尽仍不达验收才 STOP 上抛且必带数据+推荐三件套」。
3. **Phase 7（:88）Rule 70 四要素 ④ 动作项**：原「动作（选定/重抽+默认项）」→
   「动作（主进程按命中判据自选定+淘汰记录随交付附上+默认项；用户仅在 N 轮耗尽仍不达验收时收到带数据上抛）」。
4. 三处各附注 `（2026-10-15 task-v177 Rule 86：可测问题禁问——重抽/选定=模型自主迭代职责，禁抛用户）`。

### skills/task-planner/templates/variant/video-fix-type.md（1 处 + 1 处注释）
- **Phase 2（:45）三连败 STOP 门**：原「强制停批+4 维归因+用户三选项裁决」→
  「强制停批+主进程 4 维归因后自主择路（重抽/换词/换参取舍权在主进程，逐轮记命中判据+淘汰理由并留痕
  progress.md）；仅规则冲突/不可逆动作/预算追加三类例外允许上抛且必带推荐三件套（我的推荐+依据+验证方式，
  缺一=无效上抛）」。附注同上（注明「原『选项裁决呈用户』范式废止」）。

## 级联核查
- `grep "选定\|三选项" scripts/selftest-*.sh` 全量钉位核查：
  - **selftest-rule86-autonomous-decision.sh:77 AA-10** 钉 image-type.md 「选定/重抽」=0（负断言，本就预期由本次修正转绿）→ 已 PASS。
  - **selftest-channel-fast-fail.sh:61-62 CF-06** 钉 `critical-rules.md` 的「83.2 快速失败三选项」——**钉的是规则文件本体而非 variant 模板，非本任务目标，未动**；该脚本复跑 6/6 PASS 无回归。
  - 其他 selftest 对「选定」「三选项」无其他钉位。
- 结论：无需要级联改动的 selftest。

## 验收（全过）
- `grep -n "（选定/重抽）\|用户三选项" image-type.md video-fix-type.md` → 0 命中（grep exit=1）
- `bash scripts/selftest-template-sense.sh` → Total: 8 PASS=8 FAIL=0
- `bash scripts/selftest-rule86-autonomous-decision.sh` → **AA-10 PASS**，Total: 10 PASS=10 FAIL=0
- `bash scripts/selftest-channel-fast-fail.sh` → 6/6 PASS（无回归）

## 范围纪律
- 仅改 2 个 variant 模板文件；worktree 中 git status 显示的其他 M 文件（media-planner /
  task-discipline / selftest-* 等）为并行单元已 land 的变更，本单元未触碰。
