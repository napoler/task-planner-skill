<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-planctl-trigger-20261125

- task_id: `task-planctl-trigger-20261125`
- 时间: created_at=2026-11-24T18:16:47Z / updated_at=2026-11-24T19:17:41Z

## Requirements
- 用户原话镜像(2026-11-25)：skill 中 planctl.py 权重被恶意降低，定位段「核心=四文件罗盘管理(task-v171 分层后)」完全没有提及 planctl.py，导致后期执行技能时核心触发完全没有被激活、直接手写四文件造成错误；一直解决技能问题一直本末倒置，核心触发不解决则所有产物都不会得到有效激活。要求恢复 planctl.py 的核心触发权重。
- 范围外(不改)：critical-rules.md 规则正文与 references 细节文档、不新增脚本/机器门/hook(文本优先铁律)、~/.claude/settings.json 等个人配置；tier-deadzone 在途计划保持原状不回滚。

## Findings
| id | text | source | tags |
|---|---|---|---|

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- claude-settings 分支 heredoc 表格4行+footer 转义丢失=前代遗留缺陷(三历史版本字节一致)；修复前生成 claude 薄壳=空变量表+反引号执行报错；r3 已修,复演产物表格字面变量 — install-stub.sh 字节取证+复演产物 /tmp/stub-r3-*
- install.sh 对 zcode 位 rsync 扫描 ~194854 项(位内 .git 大仓)→单位安装>10min；快速通道=直调 generate_stub_skill_md(tool_name hook_style out_path)重生成薄壳 — /tmp/install-r2.log+ps 证据
- critic R1 八项归置: 修 C-1/I-1/I-5+额外修 claude 转义; 遗留待批 I-2/W-1/W-2/NIT 全部留痕待授权 — critic R1 报告+diff 98a67002/e8155481
- drift-checker Rule 61 三态判定=ALIGNED(簿记滞后属收口事项非偏移,checkpoint 落计划目录 subagent-state/01-drift-checker.md);audit 门 verdict 枚举仅 APPROVED/REJECTED,drift 判定改登记 research — drift-checker 返回报告

## Technical Decisions
| Decision | Rationale |
|---|---|
| [intent-switch] 自 task-tier-deadzone-fix-20261125(执行中途中断)切至本修复任务；tier-deadzone 保持 in-flight 原状(P1 complete/夹具已建)，本任务收口后可回切 | 用户 2026-11-25 新指令三要素(计划/交付物/对象)与 tier-deadzone 无交集=D 类新任务边界；Rule 94 计划隔离 |
| [re-lock] 本计划 attest 基线(init 落盘)后的数据填充与例行状态翻转均属计划获批流程内写入；每次 render 后按 hook 分支①重跑 attest 重锁，本条为全程重锁统一前置登记 | Rule 51.7 重锁前置=Decisions 登记；本条覆盖机械性重锁，语义级重规划仍须单独登记 |
| [tier] mini→standard：保护区多文件手术（母版定位段+薄壳生成器+四端点部署闭环）体量超 mini 判据（≤15min/≤5文件），且 attest 派发门按 standard 面校验 | 同族先例=tier-deadzone 同日取 standard（多文件保护区手术复杂度已知）；运行时升级链触发同样以步骤门信号为准 |
| 登记待批遗留清单:I-2 smart-merge-back --deploy 整树覆盖薄壳且 deploy_reconcile/verify 双门难抓(修复可被合法流程静默回退)/W-1 ENGINE_BLOCK 无回归门/W-2 install 脏树静默跳 pull/NIT README+ARCHITECTURE 文档滞后——按 R2 范围约束+文本优先铁律本轮不实施,待用户授权后独立任务 | critic R1 四项遗留的诚实边界:文本修复已闭环,机器门/脚本改造属范围扩张需显式授权 |

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
