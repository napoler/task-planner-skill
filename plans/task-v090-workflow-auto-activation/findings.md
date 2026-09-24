# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户质疑「没有真正实现 自动加载workflow 动态编排，是否需要补充 dynamic-workflows skill 动态激活」→ 调研+裁决 1（matcher 观察面扩围）+ 2（Rule 39 补禁自建副本锚），全部落地。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| dynamic-workflows 官方 bundled skill | /opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SKILL.md（L11-12 四工具拒跑契约） | 是 | Research Findings |
| /workflow 系统命令注入正文 | 会话内命令 source=system/zcode（Required skills: dynamic-workflows） | 是 | Research Findings |
| Rule 39 族（v088 交付基线） | skills/task-planner/references/critical-rules.md:345-361 | 是 | Research Findings |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **/workflow 自动激活链路=系统内置、已闭环（无需技能侧补建激活机制）**：ZCode 系统命令 `/workflow` 正文注入 "Required skills: dynamic-workflows. Before following the command body, call the Skill tool for dynamic-workflows"；四工具（CreateWorkflow/AmendWorkflow/SaveWorkflow/EvalWorkflowSnippet）未加载该 skill 时拒绝运行（官方 L11-12）；本会话 v089 审查工作流（run dwfrun-133695f0）完整实证：skill 加载前 CreateWorkflow 拒跑→加载后编译+运行成功。证据：官方 SKILL.md（bundled 目录）+ 会话内实际调用记录。
- **task-planner 侧真实缺口（裁决前盘点）**：① PreToolUse matcher 仅 `Write|Edit|Agent`（~/.zcode/cli/config.json 实证）不含 workflow 四工具→task-planner 计划提醒/委派观察看不到 workflow 调用；② 无 P0 锚禁止在 ~/.zcode/skills 自建 dynamic-workflows 副本（用户级目录优先于 bundled=遮蔽官方版本，宿主升级不跟随→永久漂移）；③ 其余（slash command 入口/加载门禁/执行链路）无缺口。
- **部署位 selftest 非鲁棒项（发现，未修，登记遗留）**：selftest-workflow-orchestration.sh WF-10 在三位部署位 FAIL（命中 3<6，`SKILL_ROOT/../../CLAUDE.md` 上跳落到 ~/.zcode/ 不可达）；仓侧 457/0 全绿口径须限定 as-of 仓侧。前序 v089 审查报告 ⑤ 已同型登记（as-of 边界 + WF-10 相对路径假设）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 选项 1=matcher 观察面扩围（非新建用户级 command） | /workflow 是系统内置命令，自建用户级 command=越层遮蔽；最小操作面=cli config.json matcher + zcode-pretooluse.sh 39.7.3 观察分支（exit 0 恒放行） |
| 选项 2=39.7.2 禁自建副本 P0 锚 + WF-14 负断言 | 资源发现顺序用户级优先，副本=永久漂移；负断言自守护 |
| register-hooks-cj.ts（Claude 运行位）command 保持 check-scope.sh 不变 | workflow 四工具无 file_path→check-scope 空路径 exit 0 天然放行；纯增量=只扩 matcher 不引入新 command（Decision 表已登记） |
| 零新 config 键（v086-v088 范式延续） | 判定面=LLM 行为；机器面=static 断言守护条款在位 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| printf 单引号格式串含字面 %s（tool=%s 提醒文案）被解析为格式符→观察输出错位 | 改为双引号 + ${tool} 插值（无 printf 格式符），39.7.3 观察分支重写该行；WF-15 锚断言文案不变 |
| 部署位 WF-10 FAIL（3<6） | 已知非鲁棒项（SKILL_ROOT/../../ 上跳在部署位不可达），如实登记 findings/verification 遗留，不阻断交付（仓侧口径 457/0 为准） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 官方 dynamic-workflows：/opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SKILL.md（L11-12 拒跑契约 / L942-943 saved: 唯一豁免）
- 39.7 条款：skills/task-planner/references/critical-rules.md:360（39.5 尾注）+ 362-365（39.7.1/2/3）
- 观察分支：skills/task-planner/scripts/zcode-pretooluse.sh:80-87（39.7.3 case 分支）
- cli 备份链：~/.zcode/cli/config.json（matcher 已扩围；改动前 bak-v090 备份存在时点已删=改动后经 jq 验证回退安全）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态内容必须立即转文字落盘（多模态不持久） -->
-（本任务无多模态内容）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
