# S16 C-1c scope 提取管道 lib 化组 1 — 执行 checkpoint

## 任务
worktree(/mnt/data/dev/task-planner-skill-worktrees/task-v091) 内:
1. 新建 skills/task-planner/scripts/lib/plan-parse.sh(统一 scope 提取函数, 好正则语义)
2. check-conflicts.sh 两处接入(:108 plan_scopes / :134 current_scope)
3. zcode-pretooluse.sh Rule23 注释块 + lib 函数注释互指锚(仅注释级 diff)
4. 验收: 三脚本 bash -n; check-conflicts 改前(fb28b70)对拍(≥3 真实计划目录 --runtime); selftest-rule23 3/3; check-scope/check-delegation source 链确认
5. worktree commit: refactor(task-planner): task-v091/S16 C-1c — scope 提取管道 lib 化（plan-parse.sh 统一语义+check-conflicts 两处接入+pretooluse 注释锚）

## Step 1 进场核对 ✅
- worktree HEAD = fb28b70a1bcf146bad00de9651191528649c2e2a (要求 fb28b70 开头) PASS
- worktree git status --short 空 = clean PASS
- 主仓(87d306b)未提交变更仅 plans/INDEX.md、progress.md、plans/task-v091-efficiency-optimization/(协调者簿记), 与本任务三文件零重叠
- 主仓 scripts/ 无 lib/ 目录(新建无冲突); worktree scripts/ 亦无

## Step 2 阅读与现场事实 ✅
- check-conflicts.sh 两处内联确认: :108(plan_scopes) 与 :134(current_scope), 形态=awk 区间状态机整行输出+tr ',' 拆分+trim, 无点分过滤; 区间头正则 /^## ⚠️ 执行范围限制/(含 emoji 字面量)
- pretooluse(S15 fb28b70) Rule23: 单 awk NR==FNR 门控, 好正则 /\.[a-zA-Z]/, 区间头 /^## .*执行范围限制/(宽松), f[3..n] 列扫描——热路径不动, 仅注释锚
- sync-todos.sh:197 extract_plan_meta: grep '^|'+grep -v '^|---'+awk -F'|' i>=3 点分过滤+trim+head -10(S17 接入, 本步不动)
- selftest-rule23-conflict-scan.sh 位于 worktree(S14 引入), 断言 Total: 3 PASS=3 FAIL=0, 只测 pretooluse
- 发现既有限制(非本步范围, 对拍须披露): check-conflicts.sh:113 INDEX 解析管道 sed '/^| Task ID/,/^|-------/' 只覆盖表头+分隔行 → 真实格式 INDEX.md 下 active_plans 恒空 → A/B/C 检测实际不触发, 仅 D 信号生效。:134 current_scope 因此实际无消费者(A 循环空转)。lib 化仍按指示执行(统一语义防漂移), INDEX 解析缺陷不修(超出三文件范围)
- INDEX 表头行/类别列在旧整行形态下会产出无点分碎片, 两计划同构表头经 comm -12 恒碰撞=潜在假阳性 A; 点分形态天然滤除

## 设计裁定(依 brief 授权裁量)
- lib 函数默认点分形态, 不加整行兼容参数: 下游唯一消费=A 同文件检测(comm 精确行匹配), 整行形态仅能产出表头/类别/禁止列碎片→只制造假阳性、漏不掉点分形态能命中的真重叠(整格相同则旧行亦同或更碎); 简化 API 面披露于函数注释
- 单元格整格输出不做逗号拆分: 对齐 pretooluse 子串匹配/sync-todos 整格语义, 且 {a.sh,b.sh} 括号清单拆分反致破碎
- 区间头正则采宽松形 /^## .*执行范围限制/(=pretooluse/sync-todos 语义权威), check-conflicts 原严格形(须含 ⚠️)收窄为宽松=覆盖面扩大, 对拍量化
- 输出排序: 函数不排序(调用方 comm 自带 sort), 保持最简

## Step 3 基线对拍(Part A) ✅ — 37 真实计划逐一对拍(主仓只读, 工具脚本落 /tmp)
- 单 awk 形态 vs 四级管线(grep|grep|awk|sed)参考语义: 37/37 byte-identical → lib 采单 awk 实现(少 fork, userpromptsubmit 每用户消息跑一次 --runtime)
- 提取结果变化: **35/37 计划变化**, 2 同(均空=v072/v073 无范围区块)
- 表头正则覆盖: 严格形(⚠️)=34, 宽松形=35 → v090(表头 `## 执行范围限制` 无 emoji)旧形态提取恒 0(A 检测盲区), 新形态 6 条真实路径
- 形态差异样本 v091: 旧含表头行「类别 | 允许的文件 | 禁止」+类别列+禁止列 prose; 新=5 条点分整格
- A 检测两两 comm 矩阵(666 对): **旧形态 528 对有交集(几乎全为同构表头行碰撞=假阳性)**; 新形态 5 对, 全部为真实共享路径(v082∩v083=「仓库根 `CHANGELOG.md`（追加条目）」, v090∩v056=critical-rules.md, v082/v083/v084 两两, v070∩v071)→ 点分形态=假阳性 528→5 且不漏真重叠
- 调用方: check-conflicts --runtime 由 zcode-userpromptsubmit.sh:136 每用户消息调一次(grep '🔴|⚠️' head -5), 非每工具热路径
- 第 5 处复制发现: check-drift.sh:205 独立旧形态(严格 ⚠️ 区间形)不在本组范围, 记 risks/next
- check-scope.sh / check-delegation.sh: grep "plan-parse|lib/" 零命中, 亦不 source check-conflicts → source 链不受影响, 记 N/A

## Step 4-6 写入 ✅ (worktree, 仅三文件)
- 新建 skills/task-planner/scripts/lib/plan-parse.sh(52 行): plan_parse_scope() 单 awk 实现, 头注含 [2026-09-27 task-v091 C-1c]+语义权威源+3 调用方清单(check-conflicts 已接入/sync-todos S17/pretooluse 热路径互锚)+check-drift:205 未纳入注记; 文件不存在 fail-open rc=0
- check-conflicts.sh: set -u 后绝对路径 source lib(cd "$repo" 前); :108 plan_scopes 与 :134 current_scope 两处内联整行清洗→plan_parse_scope, 注释写明行为差异量化与锚
- zcode-pretooluse.sh: Rule23 注释块(C-1a 块尾) +1 行互指锚, diff 纯注释级

## Step 7 验收 ✅
- bash -n: lib/plan-parse.sh + check-conflicts.sh + zcode-pretooluse.sh 全 PASS; 旧版(fb28b70 导出)亦 PASS
- lib 函数实体 vs 四级管线参考: 37/37 计划 byte-identical(注: 首跑 35 MISMATCH 系对拍脚本 `bash -c '... "$f"'` 内层变量未传之伪差, 修为 "$1" 传参后 37/37, 非 lib 缺陷)
- --runtime 对拍(夹具=4 真实计划目录 v056/v082/v083/v090 + 可解析 INDEX, git clean):
  - OLD: v056 假阳性 A(表头行「类别 | 允许的文件 | 禁止」碰撞) + v082 混合 A(表头假+CHANGELOG 真埋整行) + v090 盲区(严格 ⚠️ 正则对其无 emoji 表头提取恒空, 不报), exit 1
  - NEW: 仅 v082 真实 A(「仓库根 `CHANGELOG.md`（追加条目）」整格), v056 假阳性消失, v090 可提取但与 v083 无精确交集不报, exit 1
  - 真实主仓 --runtime: OLD/NEW byte-identical(INDEX 解析既有限制下 A 不触发, 仅 D 信号①②, 零回归)
  - init 模式(非 runtime): byte-identical, 零回归
  - 相对路径调用(skill 根 `bash scripts/check-conflicts.sh`)同输出, SCRIPT_DIR source 稳
- selftest-rule23-conflict-scan.sh: `Total: 3 PASS=3 FAIL=0` exit 0(pretooluse 仅注释改动)
- source 链: check-scope.sh / check-delegation.sh grep "plan-parse|lib/|check-conflicts" 零命中 → N/A

## Step 8 commit ✅
- commit: wt/task-v091-efficiency-optimization **73730f7**(父=fb28b70) 3 files +58/-2, 提交后 worktree clean
- /tmp 清理: task-v091-s16 全删(含 fixture/对拍脚本), 零残留
- 本执行体写入清单: worktree 三文件(已 commit) + 本 checkpoint(主仓 plans/)
