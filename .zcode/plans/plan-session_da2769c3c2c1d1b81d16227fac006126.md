# 让「轻量豁免档」真正可用 —— 用极简 stub 替代死掉的关键词豁免

## 复述你的需求
- 现状痛点:模型判定「L0-T / 简单修复」需要豁免后,写入门(hook)仍拦截,被迫走整套 task-planner + 564 行模板 + attest。你实测:「关键词豁免未生效, hook 仍拦截」。
- 你的裁决:**以后不搞华而不实的东西**;遇需豁免的轻量任务,继续遵循模板,但用**最简单的步骤/模板**执行——即在原模板基础上建一个更简的极简 stub,真正跑通,别堆死仪式。

## 根因(已验证, file:line)
1. **写入门 `check-scope.sh`**:`_lightweight_release`(:152)只放行 `tmp//output//.cache//gitignore` 区,**明确拒受管文件**(:157-170)→ 写 AGENTS.md/规则 .md 必被拦。
2. **关键词豁免是死路**:`task-plan-init.cjs:25-28,108` 依赖 SessionStart stdin 的 prompt,而 SessionStart 载荷无 prompt → `promptText` 恒空 → `.plan_lightweight` 标记永不写入(check-scope.sh:108-109 自注)。但 `zcode-pretooluse.sh:21` 仍广告「加『简单修复』跳过」= 误导文案(全仓仅此一处)。
3. **L0-T 只停在文档**:`critical-rules-template.md:51` + `critical-rules-discipline.md:201`「L0-T 分支待接线,先文本态生效」= 无机器面。
4. **可复用的放行点(零新脚本)**:
   - check-scope **D10 mtime 仲裁**(:206-222):只要 `plans/*/task_plan.md` 存在且 mtime 晚于哨兵 `created_epoch`(恒有,task-plan-init.cjs:129)→ 放行,**不看内容**。
   - check-delegation **④b mini 通道**(:336/区):活跃 `task_plan.md` 含 `plan_tier: mini` 且目标非保护区 → 主进程直写 ≤30 行放行。
   - `plans/*/*.md` 已被双门白名单(check-scope ②:72-79;check-delegation:159)→ **写 stub 本身永不被拦**。
   - `resolve-plan-dir.sh` level-3 mtime fallback(:118-135)保证新写 stub 能被找到。

## 核心洞察
写一个 **≤12 行、含 `plan_tier: mini`** 的极简 `task_plan.md` stub,就同时满足两门 → **无需任何新 hook 脚本、无需 attest**。这就是「在原模板基础上的更简单步骤」。复用既有 D10 + ④b,最符合「不要华而不实」。

## 改动清单(源仓 `/mnt/data/dev/task-planner-skill`,worktree 内做,窄范围)
1. **新增极简模板** `skills/task-planner/templates/variant/l0-lite-type.md`(~12 行):`template_type: l0-lite` + `plan_tier: mini`(复用 ④b token)+ 一行 Goal(目标文件+变更)+ 一行 VC-1(grep/Read 复验)+ 一行 scope + 一行「本档豁免:VC≥2 表 / 3-file 回填 / G-gates / 归档」。无 FMEA/知识储备/Handoff。
2. **修死文案** `skills/task-planner/scripts/zcode-pretooluse.sh:21`:把「加『简单修复』/『就改一行』跳过(Change #2)」→「轻量/单文件小改:写 l0-lite 极简 stub(`mkdir -p plans/task-{id}` + ≤12 行 `task_plan.md` 含 `plan_tier: mini`)即解除本写入门并放行受管文件 ≤30 行;`plans/` 写入本就豁免」。**只改文案,不动任何拦截逻辑。**
3. **L0-T 接线(两处双载)**:`plan-template-kit/references/critical-rules-template.md:49-51` 与 `task-discipline/references/critical-rules-discipline.md:199-201`:`L0-T 待接线` → 落地口径=「写 l0-lite stub(含 `plan_tier: mini`)→ check-scope D10 + check-delegation ④b 双门放行,零新脚本零 attest」。
4. **注册新模板 + 计数级联**(本仓高频坑,须全扩展名扫):`template-mapping.md`(29→30 类 + l0-lite 行 + 38.3 白名单)+ `template-guide.md`(variant 表、42→43 .md、35/39→35/40 知识储备计数,l0-lite 入 38.3 豁免名单)+ 逐处对齐 `selftest-plan-tier.sh` / `selftest-skill-split.sh` / `selftest-skill-collab.sh` 的模板计数锚。
5. **(可选最小)** `task-plan-init.cjs:140` 触发词提示加一行注释:「关键词检测在当前 hook 链不可达(SessionStart 无 prompt),轻量档请写 l0-lite stub」——仅注释,不改 `LIGHTWEIGHT_KW` 逻辑。

## 验收
- 手工复测:建 `plans/task-x/task_plan.md`(≤12 行,`plan_tier: mini`)+ 在位哨兵 → `check-scope.sh` 对一个受管 `.md` 返回 exit 0(D10 放行);`check-delegation.sh pretool` 对该 stub + 受管文件 ≤30 行返回 exit 0(④b 放行)。
- `run-selftests.sh` 全 registry 零回归(含新 l0-lite 计数锚)。
- `zcode-pretooluse.sh:21` 新文案 grep 复验;`grep 'L0-T 分支待接线'` 应 0 命中。
- 部署:`cp` 新模板 + 改动的 `zcode-pretooluse.sh` + 两个 references 到 `~/.zcode/skills/task-planner/`,与源仓 diff=0(新会话生效)。

## 风险/边界(如实声明)
- **并行会话 mtime 抢占**:`resolve-plan-dir` level-3 是全局 mtime,多会话同时有 plans 时可能选中他人 stub。本次**不修**(既有已知面;要修=加 side 指针,又回到「华而不实」,且非本任务范围)。
- **l0-lite 免全套仪式**是边界:仍可随时补跑 `check-complete`;≥3 文件 / 多模块 / 新脚本须回落 standard,不适用 l0-lite。
- 计数级联须全扩展名扫描 + selftest 复核(仓内多次翻车判例)。

## 不做(遵「不要华而不实」)
- 不加 `allow-light.sh` / 新 marker 脚本 / 新 selftest registry 行(除非某计数锚确需)。
- 不合并精简 L0/L0-E/mini/mini-lite/trivial 整套体系(宽范围,需另行裁决)。
- 不做 prompt 透传的 hook 大手术。

## 收尾动作(实施后)
- 落一条 feedback 记忆:「轻量豁免=极简 stub,禁堆华而不实的仪式/脚本」作为长期工作准则。
- 本次任务自身按 L0-lite 哲学轻量执行(worktree + 最小改动 + 单 commit + selftest + 部署),示范该机制。