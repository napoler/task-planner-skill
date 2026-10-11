# task-v132 交付总结 — 72h 事故修复缺口 gap-fill（G1-G4）

**交付结论：COMPLETE**（2026-10-05；merge 54f6fe2；终态 51 脚本 PASS=777 FAIL=0 主进程求和；四位部署位 IDENTICAL）

## 一、任务说明
落地指令篡改事故（一个月→72h）修复提案 §6 的 P1/P2 缺口 G1-G4（P0 三项已由 task-v131 落地；授权链=gap 文档头注用户 2026-10-05 显式授权全部六项）。开工前置三条件（v131 合并/四位部署/无重叠未提交）核验满足后启动。

## 二、产出清单
- **G4+G2 条款面**：references/critical-rules.md — Rule 51.7「纠正=回锚重译，非设计增量」（纠正原话追加新 R 行禁改写旧行=事故直接成因的结构性禁止）+51.1 判例库追加事故判例（报告路径锚 plans/incident-reports/2026-10-05-72h-instruction-mutation.md）+51.6 机制条款事实同步
- **G2 机器面**：scripts/check-window-consistency.sh 新建（🎯锚行窗口词提取→计划+载荷扫描，同族异值警报；词表族化不绑死字面；数字边界豁免；判例/事故语境豁免）+ attest-plan.sh 锁定时接线（warn 级 [window-lint]，51.7 声称落地）
- **G1**：check-complete.sh R-COVERAGE 门（51.3 完成声称对照机器化：R 行数双向对齐/状态枚举/证据非空/partial·uncovered 无让步→拒 COMPLETE 只可 PARTIAL；复用 vc_gate_enforce；行首锚定防交叉引用误报）
- **G3**：zcode-userpromptsubmit.sh TAMPERED 文案收紧（无 Decisions 纠正/让步登记的重锁=篡改信号 STOP）+init-session.sh silent 路径两级锚哈希即时落盘（env 第一优先+resolve-interaction-mode.sh 权威链）
- **守护**：RC-16..22（51.7 锚/lint 正负例/R-COVERAGE 负例/hook 文案锚/init 静态锚）+RC-01 七子条升档+RR-09 语境锚演进；registry rows=51↔actual=51
- **部署**：四位（zcode/claude/opencode/cursor）与真源 diff=0；备份 ~/skill-deploy-backups-v132-151215/（2.7MB）

## 三、审查详细信息
- CR+ALIGN 双镜头两轮：首轮双 CHANGES_REQUESTED（3×P1+4×P2+P0 工作树状态异常）→ 修复批 A/B+C（R 行首锚定/让步收紧/lint 边界+接线/silent 权威链/枚举同步）→ Round-2 **CR APPROVED** + ALIGN 剩 51.6 枚举 P1 → 事实同步清账（grep+selftest 双证据）。plans/task-v132/subagent-state/06-code-reviewer.md
- 全量回归两轮 777/0（777=770+RC-16..22 对账）；v131 计划 master vs v132 check-complete 输出逐字节 IDENTICAL（零回归实证）
- 委派：8 个子代理 S-unit（executor×7+code-reviewer 复审 2 轮）；主进程直做=git/部署/簿记/两处 §11.5 例外 4 微修（51.6 同步+RR-09 锚）均登记

## 四、风险点
1. 行为面待真实任务观察（R-COVERAGE 门在 enforce 档首次真实 PARTIAL 场景的表现；lint 词表对新窗口词族的覆盖随用例扩充）
2. resolver 占位行遮蔽 P2（预存语义：init 自生成计划首行 interaction_mode 指导行遮蔽后续真实行；env 主通道不受影响）——登记 deferred
3. G3 两级锁定的兜底级用 --skip-dispatch/fmea（既有逃生开关先例；51.1 四锚硬门实测不可被 skip 绕过）——Decisions 已登记裁量依据
4. lint attest 接线为 warn 级（警报不拒锁）——升 enforce 需真实误报率数据沉淀后再裁决

## 五、下一步建议
1. 新会话冒烟：silent 模式 init → 观察 .plan-attestation 即时落盘+attest 时 [window-lint] 表现（对象=任意新 plans/<task>/）
2. 词表演进：首次真实窗口冲突警报后回填词表（对象=check-window-consistency.sh 词表变量）
3. resolver 占位行 P2：下轮维护任务（对象=resolve-interaction-mode.sh :64 head -n1 语义）

## 📋 需求覆盖核对表（Rule 51.3）
| R | 需求（gap 文档 G1-G4+R5） | 覆盖 | 证据 |
|---|--------------------------|------|------|
| R1 | G1 R-COVERAGE 门+selftest 负例 | **covered** | check-complete.sh rcov-gate×5 锚；RC-18..20；六例三态实测（progress/03-executor） |
| R2 | G2 51.7 子条+窗口 lint+正负例 | **covered** | :567 锚；lint 六边界用例+样张钉住；RC-16/17；attest 接线 warn 级实测 |
| R3 | G3 重锁文案+silent 锚哈希+锚 | **covered** | hook :74 文案锚；init 两级落盘三路径实测；RC-21/22 |
| R4 | G4 判例追加+报告路径锚 | **covered** | :559 grep=1 含报告路径 |
| R5 | 基于 v131 机制零重复冲突 | **covered** | 全量 777/0；v131 计划输出逐字节 IDENTICAL；lint/门均为新增挂点不触碰 v131 四锚门语义 |
