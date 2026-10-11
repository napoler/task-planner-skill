# S18 C-1f check-conflicts 9 处 git 调用合并 — 执行 checkpoint

## 任务
worktree(/mnt/data/dev/task-planner-skill-worktrees/task-v091) 内:
1. 新建 skills/task-planner/scripts/selftest-check-conflicts.sh(五类信号行为级夹具, 先补后动)
2. check-conflicts.sh 9 处 git 调用合并集约化(护栏=五信号输出语义一致+UPS 侧调用耗时下降)
3. 验收: selftest 前后全 PASS + 逐信号输出对比 + git 调用计数对比; 双文件单独 commit
不修不扩散: INDEX 解析缺陷(:118 一带 sed 区间)、:145 自计划跳过字符串相等; S16 source 关系保持

## Step 1 进场核对 ✅
- worktree HEAD = 28221a70a6... (要求 28221a7 开头) PASS; worktree status clean PASS
- 主仓 87d306b 的未提交(plans/INDEX.md/progress.md/plans/task-v091-...)系协调者簿记, 零重叠

## Step 2 现场事实 ✅
- 静态口径 grep -c 'git ' = 9(含 L34 command -v git; 真实 git 子命令 8 处: rev-parse×1 + status×2 + worktree×4 + branch×2)
- 重复对: init ②worktree(--porcelain 计数+普通列表)=2 次、③branch(计数+列表)=2 次
- UPS(zcode-userpromptsubmit.sh:136)每消息调 --runtime: 慢路径(有活跃 plan)3 次(rev-parse/status/worktree), 快路径(无活跃 plan 在 L137 exit)仅 1 次
- 提案原文(efficiency-proposal.md:132): "9 处 git 调用合并(先补行为级 selftest 再动)"

## Step 3 selftest 前置 ✅(C-1f 改动前基线)
- 新建 selftest-check-conflicts.sh(~190 行, 风格对齐 selftest-rule23-conflict-scan.sh)
- 6 夹具全部 /tmp mktemp hermetic git 仓(局部 -c user.* 身份; stderr.txt 落仓外防 ?? 污染 porcelain——首版夹具缺陷已修):
  CC-01 init ①+⑤(?? hooks/ 计数+porcelain 列表行+基础设施子信号) CC-02 init ②(附属 worktree 计数+路径行)
  CC-03 init ③(wt/leftover 计数+列表行) CC-04 init ④(INDEX 待处理区 2 条列表行) CC-05 init 全绿(✓ 行+rc=0)
  CC-06 runtime 冲突 A(分隔行置尾畸形可解析 INDEX——S16 对拍先例, 如实覆盖 A 可触发形态, 不构成对真实格式 INDEX 的覆盖声明)
- **改前基线: Total: 6 PASS=6 FAIL=0 exit 0**(对 28221a7 现行实现全 PASS); 头注披露 INDEX 解析缺陷 deferred 不修

## Step 4 改动与方案裁定 ✅(两次实证迭代)
- 方案一(已回退): 探测合并——status 单调用兼任仓库探测+信号①采集(runtime 3→2, init 6→3)。输出全 IDENTICAL、selftest 6/6, 但配对计时(20 对×2 组, 交替+双向)主仓 runtime 中位 +37~+44ms 系统性回归(37/40 同向); 变体二分定位(X=rev-parse 先行+其余新体 → 与 old 持平; Y=平铺 status 先行 → +44ms)锁定机制: **status 作为首个仓库子命令拖慢其后 plans/* 37 目录 stat+date fork-exec 链**。净负优化, 回退并在代码注释留证
- 路径伪影排除: 早期 new(/mnt/data) vs old(/tmp) 对比含 ~40ms 文件系统惩罚; 双 /tmp 复测后最终版 runtime -9ms/init -3ms(无回归)
- 最终落地: ②worktree 两次调用→cc_worktree_list() 惰性单次采集(计数=行数等价于 '^worktree ' 计数, 列表同一 tail/sed 管道逐字节一致; 惰性保 runtime 快路径 1 次调用不触发); ③branch 两次调用→单次变量消费; 探测/porcelain 采集保持原形; 修改处注释 [2026-09-27 task-v091 C-1f]
- S16 source 关系(lib/plan-parse.sh 两处 plan_parse_scope)零触碰

## Step 5 验收 ✅
- bash -n PASS
- selftest: **改前 Total: 6 PASS=6 FAIL=0 → 改后 Total: 6 PASS=6 FAIL=0**
- 逐信号语义对拍(old=28221a7 导出+配套 lib vs new), git 调用 wrapper 计数, 全部 stdout/rc IDENTICAL:
  A 主仓 init: git 6→4, rc 1=1 | B 主仓 runtime: 3→3, rc 1=1 | C 夹具 runtime 慢路径: 3→3, rc 1=1(冲突 A 行含交集文件 byte 一致) | D runtime 快路径: 1→1 | E 非 git 目录: 探测语义 IDENTICAL(均"非 git 仓库,跳过" rc=0)
- 静态计数: **grep -c 'git ' 改前 9 → 改后 6**(注释措辞已净化不污染口径)
- 计时(双 /tmp 消路径差, 30 对): runtime 中位 -9ms / init 中位 -3ms——无回归; 探测合并方案若保留将为 +44ms(已证伪留档)
- 对拍缺陷披露: 首轮 old 导出未带 lib/ 目录致 source 失败 plan_parse_scope 恒空(C 场景假 DIFFER), 重建 old/scripts/lib/ 后消除——对拍环境必须带配套 lib

## Step 6 commit ✅
- commit **24e6609**(父 28221a7) 2 files +200/-5, 提交后 worktree clean
- message: perf(task-planner): task-v091/S18 C-1f — check-conflicts 9 处 git 调用合并（五信号 selftest 前置锁定，UPS 热路径）
- /tmp 清理: task-v091-s18 全删(含全部夹具/变体/对拍脚本), 零残留

## 遗留与风险
- UPS runtime 路径 git 次数 3→3 持平(探测合并是唯一 3→2 途径, 实证负优化): UPS 该脚本真实耗时大头在 plans/* 37 目录 stat+date 循环(~500ms, 代码未动, 属 C-1 其他子项范畴)
- 已知缺陷(deferred, 本步未修未扩散): INDEX 解析 sed 区间只覆盖表头+分隔行→真实格式 active_plans 恒空(A/B/C 不触发); :145 自计划跳过字符串相等恒不等——均按指示登记
- selftest CC-06 依赖畸形 INDEX 构造, 若未来修 INDEX 解析缺陷需同步改造该夹具(头注已披露)
