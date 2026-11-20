# S2 派发指令：set-active-plan.sh claimant 判定锚定+skip「指针未切换」语义（G3+G4）

## 执行区（只改 worktree 内单文件）
- /mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/set-active-plan.sh
- 禁碰其他文件

## 背景（自包含）
S1 已修 init-session.sh（同仓同构修复参照：worktree 内 init-session.sh :1244-1265 的锚定正则与文案风格）。本单元修 set 侧手动切换路径的同款问题：claimant 判定 :261 附近用 `grep -qi 'Status.*in_progress'` 全文匹配（注释/散文误命中）；skip 文案 :265「已被在途计划 X 声明，skip 写入防沿袭互踩」无「指针未切换」前缀（exit 0 易误读成功）。

## 修改要求（先 Read set-active-plan.sh:240-295）
1. **claimant in_progress 判定锚定**（:261 附近裸 grep 处）：改为与 init-session.sh :1255 同款
   `grep -Eq '^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress' "$PLAN_ROOT/$claimant/task_plan.md"`
2. **skip 文案前缀**（:265）：改为 `[active-plan] WARN: 指针未切换：side 键 sid=${SID} 已被在途计划 ${claimant} 声明，skip 写入防沿袭互踩；--force 可覆盖`（保持 stderr；--force 覆盖分支 :264 文案不动）
3. **exit code 保持 0**（调用点已评估：zcode-sessionstart.sh:72 gc/selftest×2/plan-hygiene.sh:123/plan-doctor.sh:56 提示性，无 hook 依赖 set 子命令退出码；结论登记在案）
4. **可选增强（做，低成本高价值）**：claimant 扫描（:245-257 附近 for ownfile 循环）从 glob 字母序首命中改为「owner 文件 mtime 最新的命中者优先」——现状字母序导致阻塞者是任意计划而非最近活跃计划，文案误导。实现提示：循环内收集匹配项时比对 `stat -c %Y` 或 `find -printf`，取 mtime 最大者。
5. **注释规范**：修改处 What+Why 注明 2026-11-20 task-pointer-switch-defect-20261120（现象/根因/修法）；禁止行尾注释复述旧 grep 调用字面（VC-3 静态反向断言会假红）；旧实现说明放行首 # 整行注释。
6. 修改最小化：gc 分支（:195-199 已锚定逻辑）禁动；--force/--sid 解析、原子写、全局指针分支不动。

## 自验（/tmp 夹具）
- 夹具 B：claimant task_plan=`- Status: in_progress`（非加粗）+ owner=sess<sid>，set target-b --sid → 输出含「指针未切换」、side 无 target-b、exit 0
- 夹具 A：claimant 仅注释 `<!-- Status: in_progress -->` 无状态行 → fail-open 写入 side=target-a
- 夹具 C：claimant 含散文行 `- Update phase status as you progress: pending → in_progress → complete` + `- **Status:** complete` → fail-open 写入
- mtime 增强：两个 claimant（a-claimant 早/prose-claimant 新）同 sid owner，set target → WARN 中 claimant=mtime 新者

## acceptance
- 四夹具全过；git diff 仅本文件；bash -n 过；gc 分支 diff 无变化
