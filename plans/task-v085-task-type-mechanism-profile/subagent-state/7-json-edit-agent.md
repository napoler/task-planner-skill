# Checkpoint: S6 json-edit-agent — config.json 新增 mechanism_profile_enforce 键

status: complete

## 改动
- 文件: /home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/config.json
- 位置: `template_gate_enforce` 键定义之后、`skill_modify_enforce` 之前（原 L310 后插入）
- 方式: Edit 工具单键插入，未用脚本重写整文件；只增 1 键，未动其他任何键与缩进
- 键结构（仿 template_gate_enforce 范式，enum 与 default 用单行数组/值写法，与该键既有风格一致）:
```json
"mechanism_profile_enforce": {
  "type": "string",
  "enum": ["enforce", "warn", "off"],
  "default": "warn",
  "description": "Rule 37 任务类型机制画像三档：warn=终验画像抽查仅提示；enforce=内容组计划声明 code_review: required 时 exit 1；off=跳过。详见 template-mapping.md §九"
}
```

## 验收实测输出
- `python3 -m json.tool skills/task-planner/config.json` → 通过（json.tool: OK）
- `jq -r '.properties.mechanism_profile_enforce.default'` → 输出 `warn`
- `grep -c "mechanism_profile_enforce"` → `1`
- `git diff --numstat skills/task-planner/config.json` → `6 0`（纯增 6 行，删除 0）
- `additionalProperties: false` 既有结构未动

## issues
- 无

## next_step
- S7: 派 code-assistant 在 check-complete.sh 末段新增画像抽查段（材料包 7-config-brief.md S7 节）
