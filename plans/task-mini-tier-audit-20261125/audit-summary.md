# audit-summary.md — 默认 mini 档「todo+模板+升级链」挖掘汇总（2026-11-25）

> 方法：双子代理独立审计（A=强制步骤保留面 agent-quality-auditor，B=升级触发链面 general-purpose）+ 主进程逐组盘上复核（A 四组、B 六组锚点全部复现）+ 本会话 dogfood 实测 + 四部署位对账。证据全文：[findings-a.md](findings-a.md)、[findings-b.md](findings-b.md)。本任务只挖掘不修复，修复提案待批。

## 一、三诉求判定

| 用户诉求 | 判定 | 要点 |
|---|---|---|
| ① mini 的 todo/模板是否存在问题 | **存在问题（WARN 级）** | 模板豁免面>机器门、todo 豁免口径漂移、mini 骨架缺 git/worktree 承载、attest 对 mini 三门实质空转（详见 P0/P1） |
| ② mini 不能抛弃 git 安全等强制步骤 | **主门守住，两处真实漏洞** | worktree 铁律/禁 `reset --hard`/危险命令授权/VC 非空/3-File 主体/Git 基线终验/双组 Todo 均无 mini 豁免（A 负结果清单）；漏洞=stub 通道「零 attest」直写受管文件（P0-A1）+④b 保护区清单缺口与 Write 无行数 fail-open（P1-A3） |
| ③ mini 运行中触发升级=核心 | **链路可用但有结构性弱点** | dogfood 实证端到端成功（17min 触发：set→TU-1→render→删旧锁→state→emit 全链）；弱点=跨工具三部署位零升级通道（P0-B1）等 4 P0/6 P1（详见下） |

## 二、P0（6 项，需修）

1. **[P0-B1] 非 ZCode 工具完全没有自动升档通道**：`lib/install-stub.sh:79/119/169/208` claude/cursor/opencode 的 PostToolUse 全挂 `check-doc-sync.sh`（零 tier 逻辑，主进程复核确认）；SKILL.md 升档条款只锚 hook（:51/:173），文本兜底条款锚「修复类新指令」非运行时长 → 三部署位 mini 执行再久永远 mini。
2. **[P0-B2] 幂等粒度=会话非计划**：`zcode-posttooluse.sh:241-242` `.tier_state/<sid>.state`，注释自认「一次会话一次升级」→ 同会话第二个 mini 计划永不升级；无 session_id 会话共用 `default.state` 退化共享。
3. **[P0-B3] 升级链全静默 fail-open**：`:285-303` set/add/render/mkdir/mv 每步 `\|\| return 0` 且输出全丢 → 「已 set 未 render/TU-1/state」静默半升级态被 `:243` 永久跳过，与宪法「错误必须曝光」冲突。
4. **[P0-B4] 计时字段缺失=双门全灭**：`templates/plan-state.json:6` `created_at:""` 原值 + init-session JSON init 失败仅 WARN fail-open → 无 JSON/空 created_at 计划软硬双门永不触发且零提示（`:251-266`）。
5. **[P0-A1] stub/l0-lite 通道「零 attest」直写受管文件**：`zcode-pretooluse.sh:21` + `templates/variant/l0-lite-type.md:7` 明文承诺；`check-scope.sh:212-222` D10 mtime 仲裁先于 D10'' attestation 校验 `exit 0`；`check-delegation.sh:336-362` mini 通道无锁校验 → 判据冻结/attest 面被默认可达路径绕过（「精简≠开漏洞」红线正中）。
6. **[P1-B3→升 P0] 完结守卫对对象型 outcome 失效**：`planctl.py:183` outcome 权威形态=对象 `{"result":...}`，而 hook `:244` `(.outcome // "") \| test(...)` 对对象必 rc=5 → 已完结 mini 计划仍可被升档+删锁。确定性 bug（非边界猜测，jq 实测）。

## 三、P1（8 项）

- **[P1-B4] 「至少完成调研后升档」用户裁决未成硬前置**：jq 信号三选一（phase complete/findings/research/delegations），phase 完成或仅有派发即升档；commit c78df608 自述裁决原文 vs 实现口径不一致（`zcode-posttooluse.sh:270-274`）。
- **[P1-B5] 删旧锁后重锁纯靠自觉**：`:293-295` rm attestation；`attest --verify` 无锁 rc=2 且 userpromptsubmit 无锁时全静默 → standard 重锁无机器门兜底（升级侧注释自认）。
- **[P1-B6] emit 文案与机器面矛盾**：「G4-G11 不再豁免」（SKILL 豁免表仅 G4/G9/G10/G11）、「无需重写计划文档」（mini-lite 骨架缺 standard 硬锚，attest 重锁必 fail-closed 拒锁——`:289-292` 注释自认）。
- **[P1-B7] 档位梯只有 mini/standard 二级**：schema enum 无 full；standard 扛不住无再升级/上抛通道；无降级回写（正向 OK）。
- **[P1-B8] selftest 升级链零覆盖**：`selftest-tier-b.sh` 18 断言全为 v094 旧项（主进程实跑 18/18 绿但不测升级链）；仅 `selftest-context-pressure.sh` 静态数 emit=13；双判据/步骤门/幂等/失败语义/outcome 对象/env 名全部无 mutation 断言。
- **[P1-A1] attest 对 mini 三门实质空转**：需求区块豁免（:259-261）+VC enforce→warn（:301）+FMEA skip（:499-500）；主进程实测锁定空骨架 RC=0（含「checkbox 步骤 0 行」判无缺陷）。
- **[P1-A3] ④b 保护区清单缺口**：漏仓库根 `AGENTS.md`/任意 `*/AGENTS.md`/`crontab`/通用 `config.json`；Write 工具 lines_arg 非数字时 `exit 0` fail-open 绕 ≤30 行上限（`check-delegation.sh:339-358`）。
- **[P1-A4] todo 豁免口径漂移**：`todo-sync.md:39` 写「B2-B8、B14/B15/B16」豁免（≈10 条）> `sync-todos.sh:531` 实裁 6 条（B2/B6/B7/B8/B15/B16）→ 文档可诱导跳过 B3/B4/B5。

（另有 P2×9：A=旧 auto-tier env 链与词面残留未清干净、mini 骨架缺 git checkpoint/worktree/基线登记承载、config 阈值口径漂移、SOFT_ONLY 仅 warn 属既有裁决、G11 文案 vs 机器门；B=naive 时间虚增 8h、resume 即升档语义、effective 阈值=16min（整数下取+严格 >）。详见 findings-a/b。）

## 四、OK-允许精简（仪式类，未触碰安全底线）

VC 表+验证区块保留（mini vc_min=2 降数量不删门）、VC 非空门无 mini 分支、3-File 主体门保留（仅免 drift 子门）、Git 基线终验门保留（仅 L0-E/legacy 跳过）、保护区 case 拦截（缺口见 P1-A3）、危险命令/worktree 文本门无 mini 豁免、完成三条件无 mini 豁免、双组 Todo 结构保留（裁 6 基线条目）、升级后检查面恢复按清单执行（dogfood 实证）。

## 五、dogfood 实证记录（本会话=活体测试）

- 本计划 task-mini-tier-audit-20261125 以 mini init（16:44:07Z），10 余次真实 posttooluse 跨越阈值窗口均未触发——**经 date -u 核查非 bug**：整数分钟下取 + 严格 `>` 使有效触发点=16min，各次调用落在 elapsed=14/15（此前「当场失效」的中间判断已被证据纠正，如实记录）。
- 17:01:08Z bash -x 注入实跑：全链依次执行 set→TU-1 登记→render→删旧锁→state 原子写→emit；终态四件套验证通过（JSON/MD 双面 standard、TU-1×1、.tier_state/<sid>.state 存在、旧锁按设计移除）。
- 步骤门信号饥饿实证：空骨架 phase-start 报「phases 中未找到」；phases 需手动 planctl add 后才有信号源；delegations 在 mini 直做通道按设计恒空；findings 依赖 warn-only 的 SKILL.md:271 CLI 硬条款（SOFT_ONLY 判例）→ mini 下步骤门实际依赖 findings/research 一路（F-1）。

## 六、逐文件修复提案（待批，本任务未改任何技能/模板/脚本）

| # | 文件 | 提案 | 对应 |
|---|---|---|---|
| 1 | `lib/install-stub.sh:79/119/169/208` + SKILL.md:51/173 | 非 zcode 三位补等价 tier hook（或挂 zcode-posttooluse.sh tier 段）；SKILL.md 加「无 hook 工具主进程在 Phase 翻转/收尾回读时自查升档」文本条款 | P0-B1 |
| 2 | `zcode-posttooluse.sh:241-242,297-299` | 幂等键 `<sid>` → `<sid>+<task_id>`（或 state 内 upgraded_plans[]）；emit 节流与 set 动作解耦 | P0-B2 |
| 3 | `zcode-posttooluse.sh:285-303` | 每步失败改 emit `[tier-upgrade] FAIL <step>` 显性曝光；render 失败允许下轮补偿而非永久跳过 | P0-B3 |
| 4 | `zcode-posttooluse.sh:251-266` | created_at 缺失/非法/未来不再静默：emit 警告或回退 updated_at/mtime 锚；naive 时间拒绝并告警 | P0-B4 |
| 5 | `zcode-posttooluse.sh:244` | 完结守卫兼容对象型 outcome：`(.outcome.result? // "")` | P0-6 |
| 6 | `zcode-pretooluse.sh:21` + `check-scope.sh:212-222` + `check-delegation.sh:336-362` + `templates/variant/l0-lite-type.md:7` | stub 直写受管文件加 fail-closed 条件（`.plan-attestation` 存在且哈希一致）或禁 stub 直写受管文件；④b 补 `*/AGENTS.md`/`*crontab*`/通用 `*/config.json`；Write 无行数改 fail-closed | P0-A1/P1-A3 |
| 7 | `attest-plan.sh:259-261/301/499-500` | 涉受管文件/代码改动的 mini 强制 VC enforce（不降 warn）或 verification.md 存在性 fail-closed | P1-A1 |
| 8 | `references/todo-sync.md:39` | 豁免口径收窄为脚本实裁 6 条，注明 B3/B4/B5 与 B9-B11 Git 基线项不裁 | P1-A4 |
| 9 | `templates/variant/l0-lite-type.md:6,22` + `templates/variant/mini-lite-type.md` 白名单 | 豁免清单对齐 SKILL.md:173 六项；白名单内加一行「实现类仍按 §十一 worktree 隔离+单 S-unit commit checkpoint」 | P1-A2/P2 |
| 10 | `init-session.sh:602-656/766-770` + `SKILL.md:54` + `check-scope.sh:104` | 旧 auto-tier env 链标注「历史兼容不作安全判定」或清理；词面措辞清除 | P2-A6 |
| 11 | `zcode-posttooluse.sh:304` | emit 文案改「G4/G9/G10/G11 恢复」「升级后须补 R/VC 区块并重 attest」 | P1-B6 |
| 12 | `zcode-posttooluse.sh:270-274` + SKILL.md:51/173 | 步骤门与「至少完成调研」裁决对齐：或把 research 设为软阈值必要信号、或明文修订裁决口径 | P1-B4 |
| 13 | `lib/verify.sh:117-124` | 硬编码路径检查白名单扩展 fallback 惯例三脚本（或三脚本改走 TASK_PLANNER_ROOT 覆盖惯例），恢复 verify 绿基线 | F-2 |
| 14 | 新增 `selftest-tier-upgrade.sh`（须批准：宪法文本优先铁律） | 夹具+mutation 断言：双判据各分支/幂等新粒度/失败语义/outcome 对象/env 名；纳入 run-selftests.sh | P1-B8 |
| 15 | `schemas/plan-state.schema.json:26` + `planctl.py:648/421` | 评估 full 档入 enum（standard 再升级通道）；或明文裁决二档封顶 | P1-B7 |

## 七、边界与诚实声明

- 部署位四点核心文件 IDENTICAL（diff -q 实测）；hook 仅注册 zcode 位（`~/.zcode/cli/config.json`）=P0-B1 部署侧佐证。本审计只读源码仓，未动任何技能/模板/脚本；唯一写入=本计划目录三份 findings/summary 文件与 plan-state 簿记（含 dogfood 升级副产物 TU-1/删旧锁，系升级链设计行为）。
- 运行时夹具仅覆盖升级链主链路与 jq 判据；stub 通道/④b 拦截的负例夹具未实跑（静态置信 HIGH/MEDIUM 标注见 findings-a）。
- verify 现状 27 pass/4 fail：FAIL=三脚本×四部署位 `$HOME` fallback 链被硬编码检查标红（合法 env 覆盖/守卫默认，白名单仅豁免 check-doc-sync.sh 一家），上次已知绿=aa3a59a8 时代 21/21，转红窗口未逐 commit 定位（提案 #13 修复后回归验证）。
