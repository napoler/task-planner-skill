# Findings: 弃旧开新机制固化

## 勘察（Explore 子代理 + 主进程复核，2026-11-22）
- 现有 §4.5 已有"方向彻底错→丢弃分支从头来"半条出口，但缺：触发阈值/有效数据提取/旧计划终态/新分支新计划命名/从基线牵新版本命令序列。
- 可复用骨架：Rule 96.7（>40 派发/>60min）、Rule 103.8b（同文件第3轮返工 STOP）、Rule 102.1e（取消登记不删条目）、Rule 61 drift-checker、decision-arbiter 归因、D 类意图切换登记载体、Rule 100 worktree 路径。
- 制度层诉求（Rule 31.8）→ 交付物=规则文本+模板锚，非脚本/hook。
- 4 部署位勘察 16/16 identical；基线 master（main 非祖先）。

## 设计裁决
- 未答澄清项按推荐自决：①触发=阈值→评估→用户 yes；②旧计划 RESTARTED + 分支留档。
- 新分支命名 `wt/<task-id>-rN`，新计划 `plans/<task-id>-rN/`，salvage-manifest 复用 findings/Decisions 载体。
