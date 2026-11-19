# Retrofit SOP — 模板规范 spec_version 存量改造

> 机制化来源：`task-variant-upgrade-20261113` 判例（模板升级≠一处修；教学面四族=主模板+kit+variant+守卫，须同轮闭环）。当前规范版本权威源：`skills/plan-template-kit/SKILL.md` 的 `spec_version=<N>` 声明。

## 六步流程

1. **kit 规范版本递增**：在 kit `SKILL.md` 将 `spec_version=<N>` 递增为 `<N+1>`（唯一权威源；同步必要说明文字）。不跳号、不并行多版本。
2. **注册表新增/修订原则行**：更新 `references/principle-template-registry.md`（原则→模板区块映射、豁免与守卫断言），与新规范一致；必要时同步 `references/template-mapping.md` / `references/template-guide.md` 计数与契约（四点同步面）。
3. **产出过时清单**：运行 `bash skills/plan-template-kit/scripts/scan-template-spec.sh --target-spec <新N>`，收集所有 `OUTDATED`/`MISSING` 模板清单与 `OUTDATED: <count>` 汇总作为改造输入（rc=1 为预期）。
4. **逐模板改造**：按清单改造 base/variant（优先复用 `scripts/inject-template-lineage.sh`、覆盖守卫等可脚本化面；同质批量脚本化，禁手工逐文件漂移）。豁免模板（mini-lite/l0-lite 等显式豁免）按注册表口径处理并登记理由。
5. **守卫复验**：`scan-template-spec.sh --target-spec <新N>` 期望 `OUTDATED: 0` 且 rc=0；运行 `check-template-principles.sh`/`check-template-type.sh` 及模板相关 selftest 族全绿；全量 `run-selftests.sh` FAIL 集与动工前基线对比零新增。
6. **登记与收口**：在任务 `findings.md`/进度记录写明改造范围、清单与证据锚；在本 SOP 尾部「版本历史」表追加一行（spec_version/日期/变更/任务），与 kit 声明保持一致后合并。

## 版本历史

| spec_version | 日期 | 变更 | 任务 |
|--------------|------|------|------|
| 1 | 2026-11-20 | 初版（lineage+原则注册表+守卫） | task-antiregress-tplgov-20261120 |
