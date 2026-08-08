# Goal Gate — 目标完成判定

目标模式自动运行：每个 `task_plan.md` 必须包含 **Verification Contract**（VC 表），初始化时 `init-session.sh` 同步创建 `verification.md`。

## 流程

```
规划时写 VC → 每 phase 完跑 V-N 验证 → 全 phase complete → 终验 Goal Gate
```

## Verification Contract 规则

1. **≥5 条 VC**：客观、可测试、可追溯（不写"看起来 OK"）
2. **每 phase 绑定 ≥2 条 V-N**：映射到 VC 编号或自定义
3. **phase 间门控**：V-N 未全部 PASS → 不进下一 phase
4. **终验必做**：全 phase complete ≠ 目标完成；必须跑 Goal Gate（逐条 VC 复验）
5. **升级阈值**：同一 V-N 重试 3 次 FAIL → 告诉用户 + AskUserQuestion

## 退出标准

- **COMPLETE**：全 VC PASS，无遗留阻塞 → 交付
- **PARTIAL**：VC PASS 但有已知遗留缺陷 → 列出 + 建议后续
- **BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策

## 相关标准

- Std 43-46: Goal 语句 / VC / Phase 验收 / /goal 触发
- Std 47-52: Goal 质量铁律（禁止模糊词、VC 冲突检测、证据路径）
- Std 42: 质量 > 速度（bypass 必须显式授权）
