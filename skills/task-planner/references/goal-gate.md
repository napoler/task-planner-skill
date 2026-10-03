# Goal Gate — 目标完成判定

每个 `task_plan.md` 必须含 **Verification Contract**（VC 表）。

## VC 规则

1. **≥5 条 VC**：客观、可测试、可追溯
2. **每 phase ≥2 条 V-N**：映射到 VC 编号
3. **phase 间门控**：V-N 未全 PASS → 不进下一 phase
4. **终验必做**：全 phase complete ≠ 目标完成；必须逐条 VC 复验
5. **升级阈值**：同一 V-N 重试 3 次 FAIL → AskUserQuestion

## 退出标准

- **COMPLETE**：全 VC PASS，无遗留
- **PARTIAL**：VC PASS 但有已知遗留缺陷（列出 + 建议）
- **BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户
- **VC 分级语义（Rule 50）**：内容任务可按原子验收条目表做分级/加权评级（PASS/PARTIAL/FAIL 逐条 + 加权总分），作为二元三态之上的细化形态；不改变上述三态语义与五条 VC 规则。
