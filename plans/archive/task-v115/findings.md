# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:1-executor] 回流普查
- 收编清单：videop1 面 12 独有 variant（audio-voice/character-design/final-assembly/image/motion-camera/multiview-ref/physics-compliance/prompt-struct/qc-defect/script-dev/storyboard/video-prompt）12/12 头部合规（template_type :2 + plan_tier standard :7 + 知识锚全在），拷入后 17→29；77-100 行/件，主题=视频图像生产链 12 工序（详见 checkpoint 第一部分）
- 合并方案：plan-writer.md 两版 cmp=IDENTICAL（分叉已消除，仅补映射表 12 行）；template-guide.md/template-mapping.md 收编 videop1 增量（12 表行/12 决策树行/12 清单行/4 互斥行/12 矩阵行+「不适用」括注）+保留主仓演进（:45-46 行补字/21.4 新句/契约安全行/mini-lite+video+memory-hygiene 既有 4 行）；4 个冲突点逐段判定见 checkpoint 第二部分
- 级联清单：主仓 14 处逐处改法（guide:32/64/66/70/71、README:23/35/74、SKILL:275、critical-rules:357/370、TL-17 :20/:87、skill-split:50、plan-writer 表）+扩展锚 5 处「16 类」残留（kit SKILL:19、init-session:275/294/327、sense:100）；知识锚实测主仓 23/videop1 34/收编后 35（guide:70「应为 22」为主仓既有漂移一并修正）
- 负结果：①knowledge-brief.md:9「维持 22」与 README:23「全部 26 统一含」为主仓既有漂移（实测 23/26 不含锚）②v109 清单行号漂移（critical-rules:348 现 :357、guide:64 videop1 侧 :75）按内容定位 ③.backup 备份目录不入级联面 ④「.md 实际数」口径 39（10 顶层+29 variant）与 videop1 版 38 差 1，Phase 2 以 ls 实测定稿

#### [sub:4-executor] 回归验证
- Phase 3 全量回归（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v115）：42 selftest 逐个 timeout 90s 运行，42/42 rc=0，断言合计 PASS=666 FAIL=0，零超时零 SKIP 异常（skill-modify SKIP=0 属设计内）；selftest-registry 对账 rows=42/actual=42 与 registry.tsv 一致
- 明细留档：plans/task-v115/subagent-state/4-executor-regression.log（42 段 脚本名+rc+Total 原文）；结论 checkpoint：plans/task-v115/subagent-state/4-executor.md
- 负结果：未发现任何 FAIL/rc≠0/超时；回流 29 variant+注释补强后 42 脚本全绿，VC-1「全量 selftest 0 FAIL」成立

#### [sub:5-executor] 对齐审查
- 结论 APPROVED（P0=0/P1=0/P2=2）；四要素逐项证据与 8 字段最终结论块见 checkpoint subagent-state/5-executor.md（Rule 19.1）
- P2-1：init-session.sh:275/:294/:327 与 selftest-template-sense.sh:100 硬编码「16 类」未随 29 级联——属 v096 注释语义（"16 类已知类型零调用"）而非白名单口径声明，白名单=动态派生无行为差异；非 scope 清单文件（Phase 2 不动 scripts/init-session 逻辑），建议后续任务统一收口
- P2-2：README:36/:81「17 个工具脚本」为 scripts/ 目录计数口径（17 工具脚本≠17 variant），属不同实体计数，非漂移；与本次「29 口径」无联动关系，仅登记防误读
- 负结果：29 口径全链互查（variant ls=29/SKILL:275/critical-rules:357,369/kit-SKILL:19/mapping 演进链 16→17→28→29/guide:32,82,90/TL-17:20,87/skill-split:50/knowledge-brief 模板:9 锚 35）实测一致，grep 旧口径零残留（排除演进标注与 .backup 目录）；宪法 §一:30 指针→critical-rules.md:144 Rule 21.4、§九:158 指针→:455 Rule 45 实存；纯注释自证：4 脚本非注释新增行=0（仅 diff 文件头 4 行 `+++`）；守卫锚重跑 TL 21/21+skill-split 41/41 rc=0
