# S1 脚本组A 检查点 · Code Assistant（1-code-assistant）

状态: done · 2026-10-07

## 修改摘要
1. resolve-plan-dir.sh:58-68 — 会话私有指针双命名空间兼容读
   - 原: `SIDE_FILE="${SIDE_DIR}/${SID}.active_plan"` 后直接 `if [ -f "$SIDE_FILE" ]`
   - 新: 剥前缀形态 miss 时回查 `sess${SID}.active_plan`（对齐 check-scope.sh 补丁语义），
     后续 TTL/slug 校验块作用在最终选定的 SIDE_FILE 上，字节不变。
   - 位置: 第 59 行后插入 7 行（注释 4 行 + fallback 3 行）
2. set-active-plan.sh:141-150 — gc 分支扩展
   - 在 *.plan_required 清扫块之后、两条原 echo 之前插入 `*.sidmap` 清扫（k 计数，TTL 同 24h/+1440min，目录 `.plan_required_side`）
   - 两条原 echo 之后追加 `echo "[active-plan] gc 清除过期 sidmap 映射: ${k} 个"`
   - 已有注释全部保留

## 验收原始输出
a) `bash -n resolve-plan-dir.sh` → 无输出（OK）；`bash -n set-active-plan.sh` → 无输出（OK）
b) `grep -nF 'sess${SID}.active_plan' resolve-plan-dir.sh` → `65:    SIDE_FILE="${SIDE_DIR}/sess${SID}.active_plan"` 命中 1 处
   （注: 裸 `grep -n 'sess${SID}...'` 正则中 `$` 语义陷阱未命中, 用 -F 固定串验证）
c) `grep -n "sidmap" set-active-plan.sh` → 命中 3 处（第 141/146/150 行, ≥3 达标）

## 负结果/风险排除
- 未触碰其他文件；gc 计数变量 k 与既有 n/m 无命名冲突（n=side 指针, m=哨兵, k=sidmap）
- resolve 侧 fallback 仅在剥前缀形态文件不存在时生效, 双形态同时存在时剥前缀优先, 行为向后兼容
- 无 git 命令执行（符合任务约束）

## 结论
done — 两文件修改完成, 验收 a/b/c 全部通过
