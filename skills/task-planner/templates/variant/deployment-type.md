<!-- template_type: deployment -->
<!-- 适用场景: CI/CD 配置、Docker 镜像、k8s 部署、nginx 配置、cron 任务、环境变量、基础设施即代码 -->
<!-- 触发关键词: 部署/CI/CD/Docker/k8s/nginx/cron/基础设施/terraform/ansible -->
<!-- 隔离: 涉及运行中基础设施 = §十一 P0 必 worktree(<repo-parent>/<repo>-worktrees/<task-id>) -->
<!-- 推荐 subagent: executor (sonnet-1) + code-runner-agent;无专门 devops agent 时 general-purpose -->

# Task Plan: [部署任务名称]

<!-- plan_tier: standard -->
## Goal
[一句话:部署/配置什么(应用版本/服务/中间件/配置),达成什么状态(健康/可访问/可回滚)]

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 部署前 staging 验证通过 | staging 端点 200 + 关键流程冒烟 | staging URL 输出 |
| VC-2 | 健康检查端点 200 | `curl /health` 或 `kubectl get pods` | `tmp/health-check.txt` |
| VC-3 | 回滚预案就绪(蓝绿/版本回退) | 回滚脚本 + 上一版本镜像 tag 保留 | `tmp/rollback-plan.md` |
| VC-4 | 配置变更可审计(diff 落盘) | `git diff` config 文件 + 提交记录 | `git log --stat` |
| VC-5 | 部署后无告警(日志/metric 正常) | 监控面板 + 错误率 ≤基线 | 监控截图 / alert 日志 |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2 失败 = 部署未生效 = BLOCKED 升级用户
- VC-3 缺失 = 无回滚能力 = PARTIAL(高风险)

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 配置 | [如 Dockerfile / k8s/*.yaml / nginx.conf] | 其他无关配置 |
| 脚本 | [如 deploy.sh / rollback.sh] | 其他脚本 |
| CI/CD | [如 .github/workflows/*.yml / .gitlab-ci.yml] | 其他 |
| 文档 | [如 RUNBOOK.md / DEPLOY.md] | 其他 |

**强制约束**:
- 部署脚本必须先在 staging 验证,禁止直接上生产
- 回滚脚本必须与部署脚本成对存在
- 配置变更必须经 git commit 落盘,禁止直接 SSH 改线上

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 运维 runbook/配置规范 | 部署环境基线与回滚规范 | 内部路径/URL | 必读 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

- **调研需求三态判定（Rule 75.1/75.3）**：本模板任务默认`必需`（NET-RESEARCH）——部署/配置类任务必须先查官方文档（Docker/k8s/nginx/CI 官方示例）与社区成熟方案,禁凭记忆直接写配置;检索关键词+渠道+预期产出登记到计划「🔍 调研需求与检索计划」区块

## Current Phase
Phase 1

## Phases

### Phase 1: 环境清单 + staging 准备
- [ ] 派 `Agent(subagent_type: executor)` 列环境清单(staging/prod/区域/网络/密钥)
- [ ] staging 环境预演脚本就绪
- [ ] 输出环境清单到 `tmp/env-inventory.md`
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 2: 配置变更(infra as code)
- [ ] 派 `code-assistant` 或 `executor` 改 Dockerfile / k8s yaml / nginx conf
- [ ] 配置文件全部 git 落盘(禁止 SSH 直改)
- [ ] 镜像/包版本号清晰可追溯(git tag 或 registry tag)
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 3: staging 验证
- [ ] 部署到 staging
- [ ] 派 `code-runner-agent` 跑冒烟测试 + 健康检查
- [ ] staging 通过 → 进入生产;否则修复配置直到通过
- **Status:** pending
- **Executor:** code-runner-agent（mini）

### Phase 4: 生产部署(蓝绿/灰度)
- [ ] 备份当前生产版本(镜像 tag / 配置快照)
- [ ] 灰度发布(按比例切流 1% → 10% → 100%)
- [ ] 写 rollback.sh 脚本(回退到上一版本)
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 5: 部署后监控 + 收尾
- [ ] 监控告警阈值检查(错误率/延迟/资源)
- [ ] CI/CD 流水线更新(GitHub Actions / GitLab CI)
- [ ] RUNBOOK.md 更新(部署步骤/回滚步骤/常见问题)
- [ ] 派发 `drift-checker` 子代理偏移检查（Rule 61 载体）终验
- **Status:** pending
- **Executor:** executor（sonnet-1）
