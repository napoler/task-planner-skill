<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-template-catalog-20261122

- task_id: `task-template-catalog-20261122`
- 时间: created_at=2026-11-22T01:33:58Z / updated_at=2026-11-22T02:03:06Z

## Requirements
- 新增 template-catalog.sh 脚本，list 检索当前项目级 + 用户级模板，输出模板名/简介/适配场景/功能，JSON 可消费
- base + 31 variant 模板头加统一 template_meta 注释块（从现有注释提炼，不动门控锚）；脚本解析缺失时启发式回退
- 任务初期调用脚本拿清单 → 按场景/功能匹配 template_type → 传 init-session.sh，匹配流程化写入 SOP
- 脚本支持 add/clone/derive：基于模板克隆/派生，幂等+备份+同名拒锁+dry-run+lineage 注入
- 用法与示例注入 SKILL.md（:41/:45）+ plan-template-kit 交叉指针，确保后续有效调用
- 守红线：不引 SQLite/SQL 引擎(D1)；不加 PreToolUse 硬门；不动存量计划文档；不新增 selftest/机器门；软堵不变

## Findings
| id | text | source | tags |
|---|---|---|---|
| F1 | 无 SQLite 实现（全仓无 sqlite3/.db，planctl.py:46 是 JSON 倒排索引）；用户「SQL」为检索口述，D1=文件扫描+JSON 清单，不引 SQL 引擎 | Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核 |  |
| F2 | init-session.sh --list(:21-53) 仅人读枚举、单项目 scope、无 JSON/场景/功能字段，需新脚本扩展 | Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核 |  |
| F3 | 31 variant template_type 齐全但简介/场景/功能散落散文（video:5 单行 / code-edit:2-4 三行标签），D2=统一 template_meta 注释块 | Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核 |  |
| F4 | 可复用：init-session.sh:64-79 发现 / :82-97 复制 / check-template-type.sh:15-18 白名单 / install-companion.sh:84-149 幂等 / inject-template-lineage.sh lineage | Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核 |  |
| F5 | SKILL.md:45 模板优先级行为主注入点；plan-template-kit 纯知识层只做交叉指针，不承载脚本 | Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核 |  |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 无 SQLite 实现（全仓无 sqlite3/.db，planctl.py:46 是 JSON 倒排索引）；用户「SQL」为检索口述，D1=文件扫描+JSON 清单，不引 SQL 引擎 — Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核
- init-session.sh --list(:21-53) 仅人读枚举、单项目 scope、无 JSON/场景/功能字段，需新脚本扩展 — Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核
- 31 variant template_type 齐全但简介/场景/功能散落散文（video:5 单行 / code-edit:2-4 三行标签），D2=统一 template_meta 注释块 — Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核
- 可复用：init-session.sh:64-79 发现 / :82-97 复制 / check-template-type.sh:15-18 白名单 / install-companion.sh:84-149 幂等 / inject-template-lineage.sh lineage — Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核
- SKILL.md:45 模板优先级行为主注入点；plan-template-kit 纯知识层只做交叉指针，不承载脚本 — Explore×3 (agent_d3f8d819 / f55c91e9 / 83b3acc2) + 主进程 Read 复核

## Technical Decisions
| Decision | Rationale |
|---|---|
| D1 查询方式=文件扫描+可选 JSON 清单缓存，不引 SQLite | 零新依赖、无索引一致性成本、贴合 JSON 权威源；用户澄清问题未答，按推荐项自主决策 |
| D2 元数据载体=模板头统一 template_meta 注释块 | 元数据随模板走不漂移，改动限 skills/templates/ 属改进 skill，不碰 plans/ 存量计划 |
| clone 与 add 语义合并（原话「添加或者克隆…就是克隆嘛」） | 避免重复实现，add 作为 clone/new 统一入口 |
| 修 M-04 回归用文本措辞改法（FMEA 预演→FMEA 规划），不改门判据 | template_meta feature 含精确短语致 grep -c 计数变2；守守门判据不可改红线，最小措辞修改即恢复 |

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
