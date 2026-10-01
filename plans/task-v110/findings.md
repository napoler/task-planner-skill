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

#### [sub:1-executor] 影响面普查

**Rule 21.4 全文拆解**（critical-rules.md:144）
- 保留：三证据验收 / 后台槽占用 / 首败兜底链 / 机器守护引用 / Why 实证 / 只读分槽豁免机制
- 演进：「至多 1 个活跃子代理」/「禁止派发下一个」/「互不依赖不构成并行理由」→ 改为「并行默认允许 + 独立性四问守门（四问任一 yes→串行）」
- 废弃：「无论是否依赖，互不依赖不构成并行理由」直接被 10-02 裁决否定

**全库「21.4」引用面（grep 实测，companion/.backup 不计）**
- 硬锚（断言类，须改写）：critical-rules.md:198/371/373/385/400；SKILL.md:47/85/132/192/242/256/275；completion-gate.md:22/26；reference.md:322
- 文档引用（挂演进标注即可）：critical-rules.md:155；methodology.md:86；plan-template-kit/template-guide.md:228；template-mapping.md:255/258；templates/task_plan.md:149
- 代码注释/输出文案：check-dispatch.sh:344/348/371/374；zcode-posttooluse.sh:23；subagent-fallback.sh:284
- 悬挂引用（非 21.4 语义面，顺手修正）：config.json:343（retry_limit 权威源是 22.3）
- 计数锚：MEMORY.md:101 + memory-hygiene-type.md:128（21.4 行数=7，本任务改 :144 行内容不加行→计数保持）

**「串行」措辞面**（排除 21.4 命中重复）
- 保留合法：reference.md:291 linked（串行接力）；examples.md:109
- 须改写：SKILL.md:11；completion-gate.md:19；CLAUDE.md:33（不在 scope_files）；templates/variant/rule-enhancement-type.md:63
- 禁区：宪法 ~/.zcode/AGENTS.md §一（交付时提醒用户）

**check-dispatch.sh serial_slot_check 最小改动点**
- 新增第⑤参 `pg`（parallel-group 开关）：入口 :199/:212 检测 prompt 含 `[parallel-group:` 标记
- 函数 :351 签名扩 `pg="${5:-0}"`；:366 放行条件改 `if [ "$ro" = "1" ] || [ "$pg" = "1" ]`
- 无标记路径（:370-375）零改动→TS-02/03 继续通过
- selftest 新增 TS-07/08；tier-b 零改动
- 已知边界：`[parallel-group:]` 是信任标记，守卫不做四问机器校验（文件集比对方案 B 已裁决不做）

**selftest 断言锚全集**
- selftest-dispatch.sh: TS-02:168 grep '串行'；TS-03:176 grep '串行'；TS-06:203 注释「串行槽释放」
- selftest-tier-b.sh:45 parallel_readonly 夹具；:48 [readonly-parallel] 标记；:67 删声明；:71 grep '只读分槽豁免（[task-v094 T-B1]'
- 结论：只要 :374 拦截文案保留「串行」，TS-02/03 零改动；新用例仅追加

**修订方案三件套已产出**（见 subagent-state/1-executor.md）：
1. Rule 21.4 新文本草案（含演进链 09-12→09-28→10-02 / 并行默认允许 / 独立性四问守门 / 声明制 / 串行保留场景枚举 / 验收纪律不变 / 失败兜底链不变 / 保留只读分槽豁免锚串）
2. 级联清单（逐处 file:line + 改写 vs 挂标注）
3. 守卫改动点（check-dispatch.sh 最小 diff 建议 5 点）


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
