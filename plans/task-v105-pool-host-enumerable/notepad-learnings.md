# Task Learnings: task-v105-pool-host-enumerable

## New Requests
- 2026-10-01(用户「fix」+AskUserQuestion 三选项裁决):「池成员提升为宿主可枚举 skill」→ 相对软链挂载已交付(merge fbe2109 已 push;三宿主 11/11/10 链)

## What Worked
- 相对软链(非物理复制)=单一维护源:池升级自动同步顶层,零漂移;与 alignment-review「多副本同步 P0」制度对齐
- 冲突跳过语义(LINK-WARN)保住 opencode 独立 security-review 用户资产——「顶层已存在且非我们的链」一律不触碰
- 挂载=deploy 成功后增强段(不改 exit):SM selftest 17/17 零回归

## What Didn't Work
- **[执行偏差] 部署脚本自替换竞态**: 首跑「merge+--deploy 同一 smart-merge-back 调用」,merge 原地替换了 bash 正在执行的脚本自身→首跑按旧内容跑完部署段(LINK 无输出,挂载未执行);重放(ALREADY_MERGED 路径)才补齐挂载。防线=merge 与执行同一脚本时**两段式调用**(先 merge 完再单独跑 --deploy),或部署动作放独立 wrapper

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
-

## Files Modified
-

## Verification Results
- Verified: [specific change confirmed]
- Failed: [specific issue and resolution]

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
- 触发=merge 与执行同一脚本: 防线=两段式调用(先 merge 再 --deploy),防自替换竞态(v105 实证)
- 触发=池成员宿主可见性: 防线=相对软链挂载由 smart-merge-back deploy 自动维护(install_pool_links);新增池成员 deploy 后自动出现在宿主顶层
- 触发=宿主 available-skills 快照: 防线=新 skill 须新会话/重启刷新——验证宿主枚举须开新会话
- 触发=顶层命名冲突: 防线=冲突跳过不覆盖(LINK-WARN/独立 skill 不覆盖)——用户既有资产不可触碰
