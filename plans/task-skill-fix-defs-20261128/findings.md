<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-skill-fix-defs-20261128

- task_id: `task-skill-fix-defs-20261128`
- 时间: created_at=2026-11-27T22:22:35Z / updated_at=2026-11-28T02:50:46Z

## Requirements
- 按审计 10 DEF 逐个修改优化，确保 skill 可用性（P0 优先；用户 /goal 原话 2026-11-28）
- 模板驱动改造：SKILL.md 主文件只留薄壳，不适合主文件的内容迁入 references/templates，用模板驱动任务推进
- 借鉴 comet 与 Superpowers 方案（Superpowers=skill-size 字节门/触发契约；comet=证据绑定/蒸馏消费链）
- 合并回 master+部署对账+全量回归不劣化（项目标准闭环）

## Findings
| id | text | source | tags |
|---|---|---|---|
| F-SPEC-SCAN | [spec-scan] n=27 must=2 ref=25 at=2026-11-27T22:24:20Z | spec-scan |  |
| F1 | CO-1 comet 考察完成：6 可移植（决策四分类S/证据绑定扩展M/失败止损计数M/恢复四态M/dirty worktree 归因S/schema 责任绑定L）+3 已在位防重复造轮子；S5 消费 S 级两项（四分类协议+dirty 归因），M/L 级登记 backlog | reports/comet-lessons.md | P1 |
| F2 | EX-3 C 簇完成：20 标题归一 ### Rule N（115/118/119 转 #### 消裸数字）+计数钉 :186 更新+verify.sh:304-323 全量副本位 hooks 检查+双 selftest 正负控制（4/4+6/6 亲跑复验绿）+FF-01/FF16 锚同改；杂散目录 fix-defs-202- 已清理 | reports/report-ex3.md | P2 |
| F3 | EX-2 B 簇完成：attest-plan.sh:87-131 SOFT_ONLY fail-closed（_so_enforce 逃生阀+attest 模式 exit 1）+check-dispatch.sh 语义锚扫描（证据锚 证据｜验收｜VC\d｜V-\d + 范围锚 禁改｜只读｜范围 等，legacy 跳过）+selftest-softonly-gate.sh 三向 3/3+selftest-dispatch 31/31+grain 10/10 亲跑复验绿 | reports/report-ex2.md | P2 |
| F4 | EX-1 A 簇完成：SKILL.md 328行/86722B→175行/28042B（-68%），锚面保留（核心执行引擎/路由表/规则指针/循环主干），迁出段入 plan-workflow-details.md §命令速查与脚本索引+init-session.sh:1471 指针同改；BP-08 双钉（行≤185/字节≤30734）11/11；planctl schema 子命令+getattr(args,id) 修复；管道转义 19 selftest/50 锚超阈登记 backlog。亲验发现缺陷：schema 子命令 --plan-dir 误设必填（VC5 判据会 127），登记统一修复器 | reports/report-ex1.md | P2 |
| F5 | 全量回归 124 脚本 FAIL=39（基线 3，新增~36 锚断裂）：模式 A=标题归一计数锚（AR-01）/模式 B=mini 夹具空壳撞新 fail-closed 门（PT-18/28，修夹具不放宽门）/模式 C=SKILL.md 迁移锚重指向 references（FF-11/13）+已知缺陷 planctl schema --plan-dir 必填；已派 FIX-1 统一修复（SDD 单 fixer），验收=FAIL≤3 且剩余归因非本任务文件 | /tmp/st-fix.out | P3 |
| F6 | FIX-1 完成（partial）：11 脚本修复+schema --plan-dir 可选+py_compile 绿，全量 39→28（部分修复在全量跑之后，真实剩余集待 FIX-2 重测）；剩余=迁移锚重指向为主+execution-stability 夹具语义；已派 FIX-2 续修（R1 重指向/R2 补迁/R3 最小回锚三决策规则+SKILL 钉值硬约束+效率纪律） | reports/report-fix1.md | P3 |
| F7 | FIX-2 完成：23 脚本 R1 重指向+4 R2 补迁 PWD_REF+3 B 模式夹具补语义锚/业务数据+registry.tsv 补 3 行；全量 124 脚本 123/1；唯一剩余 execution-stability T11a/T11b 经 master 未改版同跑对照=预存基线（17/2 同失败）确证非本任务引入。报告文件 report-fix2.md 回执声称已写但盘上缺失（子代理报告失实判例），以本计划 findings+亲跑全量输出为准 | /tmp/st-final.out+master 对照 /tmp/es-master.out | P3 |
| F8 | 亲跑全量 122/2：plan-tier 5 FAIL（PT-18/19/28/31/32）为 FIX-2 修复不完整残留——夹具 VC 命令真空被 vc-nonvacuous enforce 拦+MINI-TIER SKIP 锚位；execution-stability 已实证基线。已派 FIX-3 单脚本聚焦收尾（禁改门本体，只修夹具对齐检测口径），报告须 ls 验证真实写入 | /tmp/st-final.out+/tmp/pt.out | P3 |
| F9 | comet S 级借鉴消费结论：决策四分类阻塞协议+Dirty worktree 归因闸门两项经评估登记 backlog（完整落地需新 Rule 编号 land 机制+纪元级联+selftest，属独立任务防范围膨胀，对齐 D1）；已在位项（证据当前版本绑定/三态 verdict/blocking 账本）与 comet 机制等效不重复造轮子；M/L 级三项同登 backlog | reports/comet-lessons.md | P3 |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- [spec-scan] n=27 must=2 ref=25 at=2026-11-27T22:24:20Z — spec-scan
- CO-1 comet 考察完成：6 可移植（决策四分类S/证据绑定扩展M/失败止损计数M/恢复四态M/dirty worktree 归因S/schema 责任绑定L）+3 已在位防重复造轮子；S5 消费 S 级两项（四分类协议+dirty 归因），M/L 级登记 backlog — reports/comet-lessons.md
- EX-3 C 簇完成：20 标题归一 ### Rule N（115/118/119 转 #### 消裸数字）+计数钉 :186 更新+verify.sh:304-323 全量副本位 hooks 检查+双 selftest 正负控制（4/4+6/6 亲跑复验绿）+FF-01/FF16 锚同改；杂散目录 fix-defs-202- 已清理 — reports/report-ex3.md
- EX-2 B 簇完成：attest-plan.sh:87-131 SOFT_ONLY fail-closed（_so_enforce 逃生阀+attest 模式 exit 1）+check-dispatch.sh 语义锚扫描（证据锚 证据|验收|VC\d|V-\d + 范围锚 禁改|只读|范围 等，legacy 跳过）+selftest-softonly-gate.sh 三向 3/3+selftest-dispatch 31/31+grain 10/10 亲跑复验绿 — reports/report-ex2.md
- EX-1 A 簇完成：SKILL.md 328行/86722B→175行/28042B（-68%），锚面保留（核心执行引擎/路由表/规则指针/循环主干），迁出段入 plan-workflow-details.md §命令速查与脚本索引+init-session.sh:1471 指针同改；BP-08 双钉（行≤185/字节≤30734）11/11；planctl schema 子命令+getattr(args,id) 修复；管道转义 19 selftest/50 锚超阈登记 backlog。亲验发现缺陷：schema 子命令 --plan-dir 误设必填（VC5 判据会 127），登记统一修复器 — reports/report-ex1.md
- 全量回归 124 脚本 FAIL=39（基线 3，新增~36 锚断裂）：模式 A=标题归一计数锚（AR-01）/模式 B=mini 夹具空壳撞新 fail-closed 门（PT-18/28，修夹具不放宽门）/模式 C=SKILL.md 迁移锚重指向 references（FF-11/13）+已知缺陷 planctl schema --plan-dir 必填；已派 FIX-1 统一修复（SDD 单 fixer），验收=FAIL≤3 且剩余归因非本任务文件 — /tmp/st-fix.out
- FIX-1 完成（partial）：11 脚本修复+schema --plan-dir 可选+py_compile 绿，全量 39→28（部分修复在全量跑之后，真实剩余集待 FIX-2 重测）；剩余=迁移锚重指向为主+execution-stability 夹具语义；已派 FIX-2 续修（R1 重指向/R2 补迁/R3 最小回锚三决策规则+SKILL 钉值硬约束+效率纪律） — reports/report-fix1.md
- FIX-2 完成：23 脚本 R1 重指向+4 R2 补迁 PWD_REF+3 B 模式夹具补语义锚/业务数据+registry.tsv 补 3 行；全量 124 脚本 123/1；唯一剩余 execution-stability T11a/T11b 经 master 未改版同跑对照=预存基线（17/2 同失败）确证非本任务引入。报告文件 report-fix2.md 回执声称已写但盘上缺失（子代理报告失实判例），以本计划 findings+亲跑全量输出为准 — /tmp/st-final.out+master 对照 /tmp/es-master.out
- 亲跑全量 122/2：plan-tier 5 FAIL（PT-18/19/28/31/32）为 FIX-2 修复不完整残留——夹具 VC 命令真空被 vc-nonvacuous enforce 拦+MINI-TIER SKIP 锚位；execution-stability 已实证基线。已派 FIX-3 单脚本聚焦收尾（禁改门本体，只修夹具对齐检测口径），报告须 ls 验证真实写入 — /tmp/st-final.out+/tmp/pt.out
- comet S 级借鉴消费结论：决策四分类阻塞协议+Dirty worktree 归因闸门两项经评估登记 backlog（完整落地需新 Rule 编号 land 机制+纪元级联+selftest，属独立任务防范围膨胀，对齐 D1）；已在位项（证据当前版本绑定/三态 verdict/blocking 账本）与 comet 机制等效不重复造轮子；M/L 级三项同登 backlog — reports/comet-lessons.md

## Technical Decisions
| Decision | Rationale |
|---|---|
| DEF-04(token 分档)/DEF-07(声明式注册)/DEF-08(selftest 分层)登记 backlog 不在本轮实施（大工程/涉面广），本轮落地 DEF-01/02/03/05/06/10 六项+入口瘦身模板驱动 | 用户 /goal 逐个修改授权+可用性优先；backlog 项单独任务防范围膨胀（§十三 精准改动） |
| SOFT_ONLY warn→fail-closed 属推翻 2026-11-22 用户裁决，依据=2026-11-28 用户 /goal 原话「基于以上分析的内容进行逐个修改 优化确保skill的可用性」构成对审计 DEF-01 改进方向的执行授权；留 TASK_PLANNER_SOFT_ONLY_ENFORCE=off 逃生阀兼容 legacy | Rule 74.7 合规四元组：修改依据=用户原话+审计报告 DEF-01 |
| 借鉴映射：Superpowers tests/skill-size 20KB 字节门→本项目 BP-08 双钉；comet 证据绑定/蒸馏消费→已在位（evidence_binding+knowledge_use），本轮消费 CO-1 考察清单于 S5 收口，可移植增量登记 backlog | 用户点名借鉴 comet+Superpowers；借 IDE 实证模式不空谈 |
| 重锁登记：锁定后经 planctl 合规写入 VC evidence×6/VC4 判据基线校准/criterion 更新/goal done/P1-P3 phase-done/outcome PARTIAL/findings F9/actions A4-A6 致 task_plan.md 哈希变化；本次 attest 重锁=JSON 权威源合法重锁 | Rule 51.7 重锁前置=本决策登记；全变更加走 planctl+render |
| 重锁登记：Handoff 登记表补 7 行真实派发记录（CO-1/EX-1/EX-2/EX-3/FIX-1/FIX-2/FIX-3，Rule 22.5 双条件已满足=产出亲验+findings 回填），致哈希变化后合法重锁 | 同 audit 任务判例：委派门 Handoff 交叉校验要求执行体 token 在表内；全部走 planctl template_doc 写入 |

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
