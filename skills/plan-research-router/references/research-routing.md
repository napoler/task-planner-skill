# 调研路由 SOP（WebSearch + github 双路）

> 迁移自 task-planner SKILL.md §调研类操作（task-v095 P2-S2，2026-09-29）；以本文件为调研路由 SOP 唯一正文

**目的**：调研结果易挤压主上下文,且代码准确性需依赖上游 release/issue/源码,不允许仅靠训练知识。

### 路径 1：WebSearch（首选,英文/技术）

阶段与工具：**①WebSearch**（关键词/英文/技术，ZCode 实测可用）→ **②WebFetch**（已知 URL 纯静态页）→ **③web_reader MCP / defuddle**（需 JS 渲染）→ **④splash / Browser Use**（browser-use 插件 control-browser / mcp__node_repl__js；动态页/登录态/交互页）→ **⑤Skill("research-assistant") → bing-intl → searxng**（网络调研主通道；中文/多源交叉验证）。
**平台适配优先（ZCode 环境事实）**：网络调研优先 research-assistant 技能（子代理内调用）、网页访问优先 Browser Use（browser-use:control-browser / mcp__node_repl__js）等本平台实存工具；禁止假设 playwright/context7 等不存在的 MCP 工具。

### 路径 2：github 调研（代码准确性必备）

```bash
# Issue/PR 调研
gh issue list --repo <owner>/<repo> --search "<kw>" --state all --limit 30
gh pr list --repo <owner>/<repo> --search "<kw>" --state all
gh release list --repo <owner>/<repo> --limit 10

# 源码调研
gh api repos/<owner>/<repo>/contents/<path>          # 文件列表
gh api repos/<owner>/<repo>/contents/<path> --jq '.content' | base64 -d  # 文件内容

# WebSearch 补充
WebSearch "<library> github issues <symptom>"
```

### 强制引用格式

写到 `task_plan.md` 的「Decisions Made」表"参考依据"列：

- 上游库：`https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<line>`（必须含 Commit SHA 或 Release tag）
- Issue/PR：`https://github.com/<owner>/<repo>/issues/<n>` 或 `.../pull/<n>`
- 官方文档：`URL + 文档版本号`

### 禁止

- ❌ 只靠训练知识写代码而不查上游 release notes
- ❌ 引用"npm 包官网首页"作为唯一依据（应到源码/issue/release）
- ❌ github 调研用 WebFetch 抓 HTML（应直接 `gh api` 拿 JSON）

（其他调研类反模式见主技能 SKILL.md §子代理路由与模型分级 §反模式）
