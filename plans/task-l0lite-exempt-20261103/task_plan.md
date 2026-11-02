<!-- template_type: l0-lite -->
<!-- plan_tier: mini -->
<!-- task-l0lite-exempt-20261103 · 2026-11-03 · 用户裁决：让轻量豁免档真正可用，用极简 stub 替代死掉的关键词豁免 -->

# Task Plan: 让轻量豁免档真正可用（l0-lite 极简 stub）

## Goal
给 task-planner 建「极简豁免档」：遇轻量任务写 ≤12 行 l0-lite stub 即解除写入门并放行受管文件 ≤30 行；同时修掉死掉的「简单修复关键词豁免」误导文案。（预估 ≤15min，单模块=task-planner 技能）

## ✅ Verification Contract
| VC-1 | l0-lite 模板落盘 + 死文案已改 + L0-T 双载接线 + 计数级联 | grep/Read | 见下方 scope 各行 |

## ⚠️ 执行范围限制
| 改什么（≤N 文件，单模块） | 禁碰什么 |
| ① 新增 skills/task-planner/templates/variant/l0-lite-type.md（l0-lite 极简 stub，含 `plan_tier: mini`） | 禁碰 check-scope/check-delegation 拦截逻辑（本次零脚本改动） |
| ② 修 skills/task-planner/scripts/zcode-pretooluse.sh:21 死文案（只改提示语，不动拦截分支） | 禁合并精简 L0/L0-E/mini/mini-lite/trivial 整套体系（宽范围另裁） |
| ③ L0-T 接线 plan-template-kit/references/critical-rules-template.md:49-51 + task-discipline/references/critical-rules-discipline.md:199-201（双载） | 禁新增 allow-light.sh / 新 marker 脚本 / 新 selftest registry 行 |
| ④ 注册 template-mapping.md（29→30 类）+ template-guide.md（42→43 .md、35/39→35/40 知识储备、38.3 豁免名单）+ 对齐 selftest 计数锚 | 禁动其它无关 selftest/脚本 |
| ⑤ （可选）task-plan-init.cjs:140 注释标注关键词检测不可达 | 禁改 LIGHTWEIGHT_KW 逻辑 |

> l0-lite：写此 stub 后直接改目标文件；免 VC≥2 表 / 3-File 回填 / G-gates / 归档，可随时补跑 check-complete 兜底；≥3 文件 / 多模块 / 新脚本回落 standard。
> 边界（如实）：并行会话 mtime 抢占不修（既有已知面，要修=加 side 指针=回到「华而不实」）；l0-lite 免全套仪式但仍可补跑 check-complete。

## Progress
- [x] worktree wt/l0lite-exempt-20261103 建成（源仓 worktree，所有文件同步 master 6142424）
- [x] 根因定位完成：写入门 check-scope _lightweight_release(:152) 只放行 tmp//gitignore；关键词豁免死路=task-plan-init.cjs:25-28/108 依赖 SessionStart 无 prompt → .plan_lightweight 永不写；L0-T「待接线」critical-rules-template.md:51
- [x] 放行点确认（零新脚本）：check-scope D10 mtime(:206-222) + check-delegation ④b mini 通道(:336) + plans/* 双门白名单；resolve-plan-dir level-3 mtime fallback(:118-135)
- [x] 9 文件改动完成：新增 l0-lite-type.md(20 行)+ 修 zcode-pretooluse.sh:21 死文案 + L0-T 双载接线(template/discipline 各一处)+ 计数级联(template-mapping 29→30 / template-guide 42→43 / 35/43 例外 7→8 / selftest×2 / ARCHITECTURE)+ 源仓 commit 6f4a443 → merge --no-ff 9eadbd2，worktree+分支已清理
- [x] 验证=run-selftests 94/94 PASS（含新 l0-lite 计数锚）；功能复测=有 l0-lite stub 双门放行 rc=0 / 无 stub 拦截 rc=1（干净负对照，排除并行 mtime 干扰）
- [x] 部署 ~/.zcode/skills/ 9 文件 diff=0（l0-lite 新建 + 8 同步），live hook 死关键词文本=0 命中、l0-lite 指引在 :21、双载「L0-T 分支待接线」清零
- [x] feedback 记忆落一条：轻量豁免=极简 l0-lite stub，禁堆华而不实仪式/脚本
