# S1 审计检查点 | task-v060-drift-collect
审计人: general-purpose 子代理(01-gp-audit) | 时间: 2026-09-11
方向约定: `diff -u <部署侧 D> <仓库侧 R>`;`<` 行=部署侧独有 / `>` 行=仓库侧独有
基线证据: R 仓 HEAD = bb34bf2;47a4db5(task-v059)收编了 active-plan-race 两文件(resolve/set-active)后,check-scope/plan-created/task-plan-init 自 2337ce0(08-29 refactor move)后零提交。部署侧 mtime 09-10 22:43(8 文件)/ 09-11 01:35(README/SKILL/check-dispatch/sessionstart 4 文件)。

## 逐文件审计

| 文件 | 批次 | 方向判定 | 改进摘要 | 文档联动面 |
|------|------|---------|---------|-----------|
| README.md | 09-11 01:35 | 前向领先 | 部署侧(+)描述会话私有哨兵机制:plan-created.cjs"双清除(本会话 side + legacy 双清除,含计划存在性验证)"、task-plan-init.cjs"会话私有哨兵(plans/.plan_required_side/<sidkey>)"、zcode-sessionstart"sid 缺失不写哨兵 fail-open"、`[task-planrequired-race]` 哨兵私有化说明块、`[task-path-identity]` 派发路径身份判定说明块。仓库侧(-)仅写旧版"哨兵清除"/"SessionStart 哨兵"一行。 | 纯 README 树注释,随脚本收编自动一致;`docs/ARCHITECTURE.md` L67/L76 仅文件名列表无机制描述,不阻塞,建议顺带核对 |
| SKILL.md | 09-11 01:35 | 前向领先 | 部署侧(+)在"执行流程图"补:哨兵会话私有化段(sidkey=uuid core 剥 sess 前缀、写入位置=plans/ 祖先根、resume 判定、legacy 只读兼容)、plan-created 双清除+存在性验证、门控 D10 check-time 自动仲裁、task-path-identity 身份判定注记。仓库侧(-)仅旧版单行哨兵描述。 | 与 `references/critical-rules.md` Rule 22.9 相邻区(哨兵/active-plan)需核对一致;`INSTALL.md` hook 说明(若含哨兵描述)需核对 |
| scripts/check-dispatch.sh | 09-11 01:35 | 前向领先(⚠ 见①) | 部署侧(+)两项:①`[task-planrequired-race]` 三级解析+warn 降级——env 显式→enforce;prompt 自声明(task_plan.md 声明目录真实存在)→enforce;均不命中→resolve 链兜底降级 warn(exit 0),根治 B5 全局指针被并发会话翻转误拦(当日 4 次实锤);②`[task-path-identity]` scan_missing 三文件分支改文件身份判定:双存在→stat -c %d:%i inode 比对(bind mount 免疫),任一缺失→目录 inode 或 realpath -m 规范串比对,废除无效 alt/pd_real 拼写。 | ⚠ 仓库侧 `selftest-dispatch.sh`(12 用例,T01-T12,自 1d2fbf4 入册)基于旧语义:T05 断言 `[dispatch-warn]`(stdout)+warn 计数文件,T12 尾斜杠 normalize——收编后 T05/T12 预期必变(T05 未锚定时 warn 行改 stderr `[dispatch-guard] ⚠` 且无计数文件),必须同步改写/重跑 selftest;`references/critical-rules.md` 22.4 系列描述需核对 |
| scripts/check-scope.sh | 09-10 22:43 | **反向异常 ⚠(P0)** | 部署侧(+)是 08-29 重构基线旧版:哨兵=`<root>/.plan-required` 固定位置 + 从 PWD 向上 4 级盲搜;无项目根解析(≤6 级找 plans/ 祖先);无 TASK_PLANNER_SID 会话侧;无 D10/D10' check-time 仲裁;拦截 case 内联在豁免 case 的 `*)` 分支。仓库侧(-)是进化版:会话私有 side 哨兵 `plans/.plan_required_side/<sidkey>.plan_required`、项目根解析、D10' 会话锚定仲裁(resolve-plan-dir 命中且 plan 晚于 created_epoch 放行)、legacy 降级固定位置、拦截独立成段(143 行 diff 差)。 | 收编=把仓库侧新版覆盖部署侧;无文档需新增(仓库版才是正源);联动面=零,但覆盖后部署侧 hook 行为变更(SessionStart 写 side 哨兵后 check-scope 才认得) |
| scripts/plan-created.cjs | 09-10 22:43 | **反向异常 ⚠(P0)** | 部署侧(+)旧版:用法注释 `~/.claude/skills/...`(zcode 环境错误路径);验证=存在比哨兵 mtime 新的 plan;清除=单 `<root>/.plan-required`。仓库侧(-)进化版:sid 三级提取(stdin JSON → TASK_PLANNER_SID → CLAUDE_CODE_SESSION_ID)+ normSidkey 剥 sess 前缀;存在性验证(任一有效 task_plan.md 即清,不再 mtime 仲裁);双清除=legacy(带"比它新才清"保护,避免清他会话 gate)+ 本会话 side 哨兵;注释改 `~/.zcode`。 | 无独立文档联动;但 README/SKILL 的 plan-created 描述须与仓库版一致(09-11 批已改,收编即对齐) |
| scripts/resolve-plan-dir.sh | 09-10 22:43 | 前向领先 | 部署侧(+)`[task-planrequired-race D11]` norm_sid 追加"剥 sess 前缀",与 task-plan-init/check-scope/set-active 四处 canon 对齐(D8),根治 Bash env 裸 uuid 与 hook 侧 sess 前缀双命名空间分裂;其余解析链字节不变。 | 仓库侧当前无 sess 剥除→收编为净增量;`references/critical-rules.md` L139 Rule 22.9 的"规范化=剥非字母数字取前 40"措辞需补 sess 前缀条款 |
| scripts/set-active-plan.sh | 09-10 22:43 | 前向领先 | 部署侧(+):① norm_sid 同补 sess 前缀剥除(canon 四处对齐);② gc 扩展清扫 `plans/.plan_required_side/` mtime>24h 的 `*.plan_required`(side 哨兵 TTL 对齐 resolve 侧)+ 输出多一行"gc 清除过期 side 哨兵 N 个"。 | 同上 Rule 22.9 gc 描述需补 side 哨兵清扫;README `set-active-plan.sh` 一行注释(仓库版已含 set/gc/--show)无需变 |
| scripts/task-plan-init.cjs | 09-10 22:43 | **反向异常 ⚠(P0)** | 部署侧(+)旧版:无条件写 `<CWD>/.plan-required` 全局共享哨兵(跨会话 B1/B2/B4 互写竞态根因)。仓库侧(-)进化版:stdin `.session_id` 提取(env TASK_PLANNER_SID 降级,缺失 fail-open 不写)+ normSidkey + 项目根解析(向上 ≤10 级找 plans/ 祖先,无项目不写)+ 原子写(临时文件+rename)+ `created_epoch` 字段(D10 仲裁锚点)+ resume 判定(本会话 side 指针指向有效计划则撤哨兵,不读全局不做盲 adoption)。 | 与 check-scope/plan-created/README/SKILL 的哨兵私有化描述整体联动;INSTALL.md hook 段若引用哨兵位置需核对 |
| scripts/zcode-pretooluse.sh | 09-10 22:43 | 前向领先 | 部署侧(+):① 哨兵检查段从 stdin 提取 session_id 经 `TASK_PLANNER_SID` 透传 check-scope.sh(会话私有化配套);② Agent 分支 B5 根因注记(子代理 sid/命名空间分裂→回退全局被翻转误拦,守卫侧修复指向 check-dispatch)。仓库侧(-)仅旧版直调 check-scope + 无注记。 | 无独立联动(注释+一行透传);收编后与 check-scope 新版(仓库)语义自洽 |
| scripts/zcode-sessionstart.sh | 09-11 01:35 | 前向领先 | 部署侧(+):① 读 stdin 提 sid 经 TASK_PLANNER_SID 透传 task-plan-init.cjs(会话私有 side 哨兵);② INIT_CJS 改 BASH_SOURCE 派生,废除内嵌 `/home/terry/.zcode/...` 绝对路径字面量(部署/迁移即坏的 L10 缺陷,对齐本文件既有范式);③ gc 输出 `1>/dev/null` 抑制,保"单行 JSON"hook 契约(gc stdout 曾混入破坏 ZCode 严格 JSON 校验)。 | 无独立联动;是 task-plan-init.cjs 收编的配套(仓库版依赖 TASK_PLANNER_SID,必须同批收编) |

## 新增文件

`diff -rq -x .git -x __pycache__ -x .session-owner -x install.log D R` → 仅 10 个 "Files ... differ",**零 "Only in"** 行。部署位无新增文件(无新 selftest 等)。

## 总体结论

**存在反向异常(3 文件),其余 7 文件前向领先。** 异常根因:task-v059 收编基线(47a4db5)只收了 resolve-plan-dir.sh 与 set-active-plan.sh 两文件,check-scope.sh / plan-created.cjs / task-plan-init.cjs 在 08-29 重构基线(2337ce0)后未再演进;部署侧 09-10 22:43 的"热修"实际把这三个文件**回退**到了仓库旧版(疑为覆盖式同步误用旧副本),导致部署侧哨兵机制整体停留在 pre-planrequired-race 语义:
- task-plan-init.cjs 写全局共享哨兵 → B1/B2/B4 跨会话竞态在部署侧复发
- check-scope.sh 4 级盲搜 `.plan-required`、无 sid/无 D10 仲裁
- plan-created.cjs 单清 legacy + `~/.claude` 路径注释(zcode 环境错误)
- 连带 zcode-sessionstart.sh 透传的 TASK_PLANNER_SID 在部署侧 task-plan-init 里无消费点(悬空 env)

**收编策略**:仓库→部署单向覆盖全部 10 文件(仓库侧即正源,无任何部署侧独有逻辑丢失——3 个反向文件的部署侧内容均完整存在于仓库 2337ce0 旧版,无信息损失);唯一风险是 check-dispatch.sh 新版(自声明锚定+warn 降级+inode 身份判定)会使仓库 `selftest-dispatch.sh` T05/T12 断言失效,收编后须重跑/改写该 selftest。

### 证据抽查(防臆测,已逐文件复跑 diff)
- README diff `@@ -84,19 +84,16 @@`:仓库行(+)仅 `plan-created.cjs # 哨兵清除` 与部署行(−)`# 哨兵清除(本会话 side + legacy 双清除,含计划存在性验证)`(README:91 vs 91)
- check-scope 部署 L68 原豁免表保留 `init-session.sh|init-session.ps1|session-catchup.py|session-catchup.ts)(` (证据:grep 命中),拦截 case 内联于 `*)` 分支
- 仓库 check-dispatch L55-84:resolve_plan_dir 仍为 "env → resolve-plan-dir.sh" 二级(自 1d2fbf4),与部署三级+自声明不同
- selftest-dispatch L87-88:`T05 同 T02 缺项, warn → 放行且 stdout 含 [dispatch-warn]`、L123 T12 尾斜杠——部署新版 warn 降级走 stderr `[dispatch-guard] ⚠` 且无计数文件,该两用例必失败
