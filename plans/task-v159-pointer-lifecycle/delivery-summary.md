# Delivery Summary — task-v159 指针与部署生命周期根治（D1-D5）

## 说明
用户指令「修复上面发现的问题 并彻底解决」：把 task-v153/delivery-summary 与 pointer-lifecycle-fix.md 判定的全局指针三缺陷+部署中断窗从治标推进到机制层。

## 产出（均已合并 master b6e6e2e 并三 slot 部署 IDENTICAL）
- set-active-plan.sh：gc 全局指针生命周期（dead-ref/completed-ttl 锚定判定→置空回退）+哨兵-side 缺口巡检+side 写入所有权守卫（.session-owner 双形态、in_progress  claimant→不写该键+WARN、--force）+set ROOT fallback 修正
- init-session.sh：同语义所有权守卫（防沿袭 sidkey 互踩）
- check-complete.sh：终验移交提醒（warn 恒 exit 0）
- SKILL.md：计划流程指针移交纪律行
- smart-merge-back.sh：deploy staging→swap→post-verify 三段原子化（D4 修复；--legacy fallback 保留）
- selftest-pointer-lifecycle.sh 新建（PL-01..10，10 断言）+selftest-smart-merge.sh 契约更新（SM-06/SM-14/SM-16 legacy）
- 簿记：plans/task-v159-pointer-lifecycle/（含 design-pointer-fix.md、回归 R1-R5、CR 三轮、五单元检查点）

## 审查与验证
- CR 三轮：R1 CHANGES_REQUESTED（1 BLOCKER+4 MAJOR+3 MINOR）→R2 抓修复反向回归 B1→锚定式修复→R3 **APPROVED**
- 回归五轮：V1 69(2 FAIL 契约漂移)→R2-R4 69/69→R5 合并部署态 **71/71 rc=0 ΣFAIL=0**
- D4 直接回归项：F5 实弹 deploy exit 0+三 slot 后验零差异
- NIT 遗留 3 条（全登记，非阻断）

## 风险点
- gc 的 completed-ttl 只覆盖英文模板状态行（中文「- **状态:** complete」标签不命中=不清理，保守方向不误删）
- 旧位置参数模式 set（无 set 关键字）计划目录内仍 exit 2=设计 scope 外，登记不改
- F1 全局置空语义=回退 mtime 最新（多并行下 sid-less 消费者拿到的是最新计划而非精确集合——side 层才是并行载体，架构边界同 2026-10-07 结论）

## 下一步
- 对象 scripts/set-active-plan.sh：看点=中文状态行兼容（NIT-a）；动作=后续任务把 has_complete 扩为「Status|状态」双语锚定
- 对象 scripts/check-dispatch.sh serial_slot：看点=组间同波并行；动作=富锁 {组名:ts}（Rule 68.2 边界演进，v153 已登记）
- 对象 plans/.active_plan：看点=移交纪律已机制化（本次）；动作=各任务完成时遵 B 提示词移交
