<!-- template_type: migration -->
<!-- 适用场景: Python→TS/Bun 迁移、框架升级、CLI 重写、单语言→多语言、Shebang 切换、API 协议迁移 -->
<!-- 触发关键词: 迁移/升级/重写/切换/转换/兼容 -->
<!-- 推荐 subagent: executor (sonnet-1,跨步骤协调) + code-assistant -->
<!-- execution_lane: L1（默认 standard 全流程；迁移=功能性代码变更+跨文件级联，Rule 38.7 禁 L0；跨系统级大迁移由 init-session.sh/lane-detect.sh 机器升 L2） -->

# Task Plan: [迁移任务名称]

<!-- plan_tier: standard -->
## Goal
[一句话:从哪种实现迁移到哪种实现,达成什么效果(行为等价/性能提升)]

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|----------|
| VC-1 | 旧实现已备份/锁定 | git tag 基线 tag + 归档路径 | `git tag --list "migration-baseline-*"` + 归档目录 |
| VC-2 | 新实现功能等价 | diff 行为对照表(≥90% 用例等价) | `tmp/migration-parity.md` |
| VC-3 | 双跑回归一致 | 新旧并行跑,输出 diff ≤5% | `tmp/dual-run-diff.txt` |
| VC-4 | 旧入口已下线/路由切换 | deprecation warning 或删除 | `grep -r "deprecated" 旧路径` |
| VC-5 | 文档已更新 | README/INSTALL 指向新入口 | git diff 文档 |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2/VC-3 失败 → 行为漂移 = BLOCKED 升级用户
- VC-4 失败 = 旧入口未下线 = PARTIAL

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 旧实现 | [明确列出,如 src/legacy.py] | 其他无关文件 |
| 新实现 | [明确列出,如 src/new.ts] | 其他 |
| 路由/入口 | [如 package.json shebang / cli.sh] | 其他 |
| 文档 | [如 README.md / INSTALL.md / MIGRATION.md] | 其他 |

**强制约束**:
- 旧实现归档后才能进入切流阶段
- 旧入口下线必须含 deprecation 过渡期(除非用户显式说直接删除)

## 📚 必要知识储备

> 目的：对齐任务知识库。Phase 1 开工前逐项确认；`必读` 项无法获取 → STOP 记入 Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本） | 必读级别 | 已确认 |
|------|-----------|----------------------|---------|--------|
| 官方迁移指南 | 框架/语言官方升级文档 | URL + 版本号 | 必读 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并登记 Errors。

- **调研需求三态（Rule 75.1）**：本模板任务默认 NET-RESEARCH——涉及框架/语言迁移，需检索官方迁移指南与现成方案；调研策略 Phase 必须登记检索关键词+渠道+预期产出到计划「🔍 调研需求与检索计划」区块
- **现成方案优先（Rule 75.3）**：迁移动手前必须先检索现成迁移方案（官方文档/GitHub 同类迁移）——评估适配后落地，禁重复造轮子

## Current Phase
Phase 1

## Phases

### Phase 1: 旧实现基线锁定
- [ ] 派 `Agent(subagent_type: executor)` 扫描旧实现范围 + 依赖
- [ ] 创建 `git tag migration-baseline-<commit>`
- [ ] 旧代码归档到 `archive/legacy-<date>/`
- [ ] 记录基线行为快照(测试输出/接口签名)到 `tmp/baseline-snapshot.json`
- [ ] 知识储备必读项已确认(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 2: 新实现开发 + 双跑回归
- [ ] 派 `Agent(subagent_type: code-assistant)` 单文件改写
- [ ] 每步保持基线行为不漂移(对照 snapshot)
- [ ] 写双跑脚本 `tmp/dual-run.sh` 并行执行新旧实现
- [ ] diff ≤5% → 进入切流;否则修复新实现直到等价
- [ ] 记录新实现决策到 Decisions Made
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 3: 切流/路由切换
- [ ] 新实现主路径生效(默认调用新入口)
- [ ] 旧入口加 deprecation warning(过渡期)
- [ ] 检查 CLI 入口(若 CLI 迁移)
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 4: 文档更新 + 旧入口归档
- [ ] 更新 README.md / INSTALL.md / MIGRATION.md
- [ ] 记录迁移决策 + commit 引用
- [ ] 派 `drift-checker` 子代理偏移检查（Rule 61 载体）终验
- **Status:** pending
- **Executor:** executor（sonnet-1）
