
#### [sub:修复C] 遗留 MINOR 收尾检查点（2026-10-09）

**修复 1：F8 转义管道误报**（worktree scripts/check-plan-dispatch.sh）
- 表头侧：`hdr_nf=NF` → `ht=$0; gsub(/\\\|/, "", ht); hdr_nf=split(ht, htmp, "|")`（计列前剔除 `\|` 转义对）
- 数据行侧：`if (hdr_nf>0 && NF!=hdr_nf) drift=1` → `rt=$0; gsub(/\\\|/, "", rt); if (hdr_nf>0 && split(rt, rtmp, "|")!=hdr_nf) drift=1`（同口径剔除；裸管道未转义仍计入 → F8 语义保持）
- 行内其余零改动；注释含 What+Why 两层（[修复C 2026-10-09 CR二轮MINOR] 标注）

**夹具双例实测（/tmp/fixc/）**：
- 转义管道合法行（`正则 A\|B`）→ 零 F8 violation，exit=0
- 裸管道挤列行 → `Rule 68.1: 行 X2 列数漂移——数据行列数与表头列数不一致（格式漂移/裸管道，hard F8）` exit=1

**修复 2：registry 陈旧描述**（worktree scripts/selftest-registry.tsv:66）
- 两处「（硬锚未落位 SOFT 降级）」→「（硬断言 2026-10-09 收敛）」，列结构零改动

**验证全量**：bash -n exit 0；selftest-parallel Total 9/9/0；selftest-registry Total 5/5/0；真实计划 --skip-goal-check 无 68 violation exit 0；diff stat=守卫 239 插入（本任务累计）+registry 1 行（+1，行内替换）
**风险排除**：hdr_nf 与数据行同口径剔除，无新假报/漏报；split 数组 htmp/rtmp 为 awk 局部新变量，无既有命名冲突（grep 确认段内无同名）
