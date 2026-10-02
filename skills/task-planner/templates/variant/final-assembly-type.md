# Task Plan: [终剪组装验证任务]
<!-- template_type: final-assembly -->
<!-- 成片工序：段片清点→剪辑组装→seam QC→成片判定→NAS 备份→终审登记。边界：段片生成与段级修正入 video-type/video-fix-type；配音对齐入 audio-voice-type。触发词：粗剪/组装/成片/终剪/seam/备份 -->
<!-- 五要素：①编号原子步骤+显式状态定义（段片台账×拼接清单）+合规检（seam 边界+成片判定层）+静默迭代（seam FAIL 回剪环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——剪辑与 seam 修正环静默；唯一合法人工停点=成片用户终审与 Rule 28 D6 -->

<!-- plan_tier: standard -->
## Goal
[一句话：把哪些段片组装为完整片，达成标准（seam 全过+成片判定达级+NAS 备份+终审登记）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 全片组装 | 整集段片成片 | 全六相 |
| B 修正回拼 | 替换段回拼 | P1 并入替换对照；seam 复验 |
| C 版本精修 | 时序/节奏重剪 | P1 并入节奏参数核对 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：六相顺序；段片清点与终稿台账逐笔对账（缺段/多段=STOP 回生产域） | 对账行+Phase 链 | progress.md+output 台账 |
| VC-2 | 显式状态定义：拼接清单逐接缝（前段×后段×接缝类型×时码）；段片状态（现役/废弃/带缺陷放行 ★✗⚠ 标记） | 拼接清单 grep | progress.md |
| VC-3 | 合规检：seam 合法性 5 边界逐缝核对+成片判定层（video-qc 四趟协议）达级；FAIL 缝回剪环（静默） | seam 核对行+判定 verdict | 判定报告 |
| VC-4 | 静默迭代：seam FAIL 回剪（tools/edit 截取/回拼/xfade）环静默 0 生成；结构性缺陷转段级处置路由（video-fix 域，不本域硬剪） | 回剪环计数+路由行 | progress.md |
| VC-5 | 验收判据：粗剪成品时码表+判定达级结论+成片 tmp/ 下载 Read 呈示+审查地址清单；终审=用户人工门（放行/否决登记） | 呈示记录+终审登记 | progress.md+Decisions |
| VC-6 | 登记收口：NAS 三目录备份（逐镜终态/成片/源版本）+VERSIONS.md 逐镜对照（★✗⚠ 全标记）；output 台账终稿行；废弃件归档 | NAS 对账+台账行 | NAS+output 台账 |

## Phases（六原子步骤）

### Phase 1: ① 段片清点对账
- [ ] 终稿台账逐笔对账（镜号×段片件×版本×状态）；缺段=STOP 回生产域；产出=段片清单（状态：待组装）
- **V-N:** VC-2, VC-1
- **Status:** pending
- **Executor:** 主进程（台账对账）

### Phase 2: ② 剪辑组装
- [ ] tools/edit 组装（cut/concat/xfade 按处置决策表；拼接清单先行）；产出=粗剪候选（状态：待 seam QC）
- **V-N:** VC-2, VC-4
- **Status:** pending
- **Executor:** 剪辑执行体（子代理）

### Phase 3: ③ seam QC
- [ ] 逐缝核对（5 边界+否定式措辞口径）；FAIL 缝回剪环（静默）；结构性缺陷转段级路由；产出=seam 核对行（状态：待成片判定）
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** QC 执行体+主进程亲检

### Phase 4: ④ 成片判定
- [ ] video-qc 四趟协议判定（含语言音色观感联动 audio-voice 域核查结论引用）；FAIL 路由（回剪/段级）；产出=判定报告（状态：待终审）
- **V-N:** VC-3, VC-5
- **Status:** pending
- **Executor:** 判定执行体+主进程亲检

### Phase 5: ⑤ NAS 备份与 VERSIONS
- [ ] 三目录备份（逐镜终态件/成片/源版本存档）+VERSIONS.md 逐镜对照（★推荐/✗废弃/⚠带缺陷放行全标记，缺标记=备份不完整）；替换件同步覆盖
- **V-N:** VC-6, VC-2
- **Status:** pending
- **Executor:** 备份执行体（子代理）+主进程核对

### Phase 6: ⑥ 终审与登记（人工门）
- [ ] 成片 tmp/ 呈示+审查地址清单+时码表；用户终审（放行/否决登记）；output 台账终稿行+废弃件归档
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 用户裁决（主进程 STOP 呈示）

## 🔗 隔离与静默纪律
- 剪辑（P2）/QC（P3/P4）/备份（P5）分属不同执行体；主进程亲检=判定仲裁；终审=用户
- 静默环：回剪环不呈送中间态；用户可见=成片终审呈示包
- 剪辑补救优先原则：能剪不重生成（0 生成调用路径优先）；结构性缺陷才路由段级重生成

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 剪辑食谱 | video-edit 技能（抽帧×3/截取/concat/xfade 命令逐字锁参） | 仓库技能层 .zcode/skills/videop1-video-edit/ | 必读 | ☐ |
| seam 判据 | 拼接合法性 5 边界+否定式措辞 | tools/README.md；videop1-video-fix 技能 | 必读 | ☐ |
| 成片判定 | video-qc 技能四趟协议 | 仓库技能层 .zcode/skills/videop1-video-qc/ | 必读 | ☐ |
| 备份规程 | NAS 三目录/VERSIONS 标记/替换同步 | docs/experience/nas-backup.md | 必读 | ☐ |
| 台账 | output 台账格式+命名规则 | AGENTS.md 命名规则；docs/naming-rules.md | 必读 | ☐ |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
