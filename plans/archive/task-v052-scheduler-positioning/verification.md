# Verification Contract & Phase Gates

## Goal (1 sentence)

消除 task-planner 技能「主进程亲自执行」的定位矛盾与例外面漏洞（定位声明/白名单收窄/delegation_rate_floor/25.3 白名单/兜底登记）,worktree 内实施并合并回 master。

---

## VC 复验（终验 2026-09-06,每条带证据）

| # | 判定标准 | 结果 | 证据 |
|---|----------|------|------|
| VC-1 | SKILL.md 含「主进程 = 调度管理器」P0 定位行;「鼓励使用，非强制」零残留 | ✅ | grep 计数 1 / 0（progress.md Phase 3 Test Results;主仓 89a29ae 复验命中） |
| VC-2 | 主进程 Edit 例外收敛三件;「纯配置/计划文件」+「AGENTS.md 文档」旧白名单措辞零残留 | ✅ | grep 0 残留（SKILL.md+critical-rules.md） |
| VC-3 | config.json 含 delegation_rate_floor(0.7) 可解析;`<50%` 5 处零残留 | ✅ | python3 json.load OK;grep '<50%' = 0 |
| VC-4 | Rule 25.3 六项白名单;兜底表#3 绑定登记;模板 canned 理由对齐 | ✅ | grep 六项白名单 ×1 / 白名单⑤ ×1 / Rule 25.3 白名单 ×2 |
| VC-5 | smoke 回归 exit 0;merge --no-ff;worktree+分支清理 | ✅ | 17 pass/0 fail（Handoff#1 检查点已 Read）;merge 89a29ae;worktree list 仅主仓 |

**终验规则**：全部 VC 通过 → outcome: **COMPLETE** ✅

## 质量门控统计（Rule 26）

| 项 | 触发 | 处置 |
|----|------|------|
| Q1 跳过 VC 复验 | 否 | — |
| Q2 压缩验证 | 否 | — |
| Q3 证据不实 | 否（抽查 Evidence 全部可复现） | — |
| Q4 未 Read 子代理产出 | 否（Handoff#1 检查点已 Read,status: done） | — |
| Q5 委派率 | 否（10% 但直做理由全在 Rule 25.3 白名单内,25.4 不降级） | — |
| Q6 批量违规 | 否（非批量任务） | — |
| 豁免登记 | 无 | — |

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0.5 / 5 |
| 主进程直做清单（含理由） | P1 ①②;P2 ②;P3 ④;P5 ①②（六项白名单编号） |
| 委派率 | 10%（白名单内 → 不降级） |

## 遗留

- 9 个部署位仍为 48340c0,重部署待用户授权（deferred-issues.log D5）
- deferred-issues.log D1-D4（范围外缺陷,不阻塞交付）
