# Markdown 编辑可靠性：外部工具/协议选型调研（2026-11-16）
证据分级：**已验证**=源码/RFC/官方文档直读；**初步**=单页或部分细节缺失；**未验证**=本轮不可达/未公开。每条机制均附来源。

## 1. Aider SEARCH/REPLACE
- **块结构/多块**：`<<<<<<< SEARCH` / `=======` / `>>>>>>> REPLACE`（5-9个标记符可解析），文件路径在 fenced block 前；一条回复可含多块（“a series of search/replace blocks”）。来源：[edit-formats](https://aider.chat/docs/more/edit-formats.html)、[editblock_coder.py](https://github.com/Aider-AI/aider/blob/main/aider/coders/editblock_coder.py) `HEAD/DIVIDER/UPDATED`、`find_original_update_blocks`。
- **锚点匹配**：`replace_most_similar_chunk` 级联：精确匹配→统一去前导空白后匹配→丢弃首行空行重试→`...` 省略块（每段需在文件中计数==1，否则 ValueError）→随后直接 return（源码中 fuzzy `replace_closest_edit_distance` 位于 return 后，实际未启用）。来源：`perfect_or_whitespace`/`replace_part_with_missing_leading_whitespace`/`try_dotdotdots`/`replace_most_similar_chunk`。
- **失败与重试**：未匹配时可尝试 chat 内其他文件；仍失败抛 ValueError，附失败块、`find_similar_lines` 建议、若 REPLACE 已存在则提示、声明“SEARCH must exactly match…”；若部分块成功写盘则提示“Don't re-send them…”交由模型修复失败块（会话级重试，非自动内部重试）。来源：`apply_edits`、`find_similar_lines`；评测侧错误会回馈模型纠错（[edit leaderboard](https://aider.chat/docs/leaderboards/edit.html)）。
- **四问题**：①失配有空白归一/`...`计数保护与建议，但精确匹配为首匹配窗口（非显式唯一性校验）**初步**；②`...` 段要求唯一计数可防吞错段，普通块依赖锚文本质量；③batch 中成功块立即写入、失败块报错→可部分应用/易状态漂移，需遵循“不重发已应用块”；④无事务回滚（已写入保留）。

## 2. OpenAI Codex CLI apply_patch（源码实现，协议名“V4A”文档本轮未取到）
- **块结构**：`*** Begin Patch`(可选`*** Environment ID:`) + hunks + `*** End Patch`；hunk：`*** Add File:`/`*** Delete File:`/`*** Update File:`(可选`*** Move to:`)；chunk 含 `@@`/`@@ ctx`、` `上下文、`+`/`-` 行、可选 `*** End of File`；支持 heredoc 宽松解析。来源：[parser.rs](https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/parser.rs)、[streaming_parser.rs](https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/streaming_parser.rs)。
- **匹配/校验**：`seek_sequence` 顺序尝试 exact→rstrip→trim→Unicode 标点/空白归一化；`change_context` 定位后前进；`eof` 时优先末尾对齐；找不到上下文/期望行报 `ComputeReplacements` 错误。来源：[seek_sequence.rs](https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/seek_sequence.rs)、[file_update.rs](https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/file_update.rs)。
- **应用与回滚**：按 hunk 顺序应用，累计 `AppliedPatchDelta`(变更+`exact`)；写失败/异常可置 `exact=false`；删除/移动失败会检查副作用并返回 `ApplyPatchFailure(error, delta)`；移动为“先写目标再删源”，删源失败时目标已落盘且 delta 保留已提交部分。**无全量事务回滚**。来源：[lib.rs](https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/lib.rs)。
- **四问题**：①多级模糊匹配+上下文/EOF锚点降失配，但定位为从 line_index 向后搜索首个匹配（非全局唯一约束）**已验证(行为)/初步(安全边界)**；②按 old_lines 序列替换、保留上下文原文，范围受 chunk 限定；③chunk 内推进 line_index、hunk 顺序提交，基线漂移由前序提交决定；④部分提交可发生，但失败可携带 delta 供上层补偿/审计。

## 3. JSON Patch (RFC 6902) / JSON Merge Patch (RFC 7386) 作中间件
- **RFC 6902**：op 数组(add/remove/replace/move/copy/test)+JSON Pointer，顺序执行；任一失败则评估停止且 patch 不得视为成功（HTTP PATCH 语境具原子性）。适合结构化文档模型。来源：[RFC6902](https://www.rfc-editor.org/rfc/rfc6902.txt)。
- **RFC 7386**：对象递归合并、`null` 表示删除、非对象/数组整体替换，无法表达“设为 null”、数组不可局部编辑；语义更简单但歧义/损失信息多。来源：[RFC7386](https://www.rfc-editor.org/rfc/rfc7386.txt)。
- **适用性/局限**：对**自由文本/原始 Markdown**不直接适用；若先解析为 AST/块模型再映射 op，可作编辑中间件并获结构化校验（路径存在性、`test` 前置断言、事务语义-RFC6902）。局限：需稳定寻址与往返序列化，格式化噪音/顺序敏感场景成本高。**已验证(RFC)/初步(工程适配)**。
- **四问题**：①路径/前置条件可精确约束失配；②节点级操作不吞邻接文本（前提模型正确）；③`test`+顺序依赖可显式防漂移；④RFC6902 定义失败不生效语义（实现需保证）。

## 4. 专用 fast-apply 服务（2026-11-16 可达性探测）
- **Morph Fast Apply**：宣称“Merge LLM code edits at 10,500 tok/s, 98% accuracy”；模型 `morph-v3-fast`(7B,$0.80/$1.20/M tok)、`morph-v3-large`(14B,$0.90/$1.90/M tok)；OpenAI 兼容 API `https://api.morphllm.com/v1`。官网可达。匹配/回滚细节未公开。来源：[morphllm.com](https://morphllm.com/)、[docs](https://docs.morphllm.com/sdk/components/fast-apply)。**已验证(页面可达与公开参数)/未验证(内部机制与2026状态声明)**。
- **Relace Instant Apply**：`relace-apply-3`，`POST https://models.relace.ai/v1/code/apply`(`initial_code`,`edit_snippet`→`mergedCode`)及 OpenAI 兼容 base；宣称 10k+ tok/s、较全量重写快且便宜(>3x，未给具体价)。quickstart 可达；`/docs/models/instant-apply`、`/docs/models/relace-apply-3` 本轮 404，未见“lemur”命名与具体定价/上下文限制。来源：[relace.ai](https://www.relace.ai/)、[quickstart](https://docs.relace.ai/docs/instant-apply/quickstart)。**初步/部分未验证**。
- **四问题**：作为模型合并中间件，①②③④取决于模型与服务实现，公开资料不足以断言防吞块/批处理漂移/回滚保证，需实测契约。**未验证**。

## 5. Claude Code / Cursor 编辑契约与失败模式
- **Claude Code Edit**：参数 `file_path, old_string, new_string, replace_all`；精确字符串替换、无 regex/fuzzy；`old_string` 默认须唯一否则需更长上下文或 `replace_all`；空白/缩进单字符差异即失配；要求先 Read（部分模型/条件强制，PARTIAL view 不满足），磁盘变更后需与当前内容精确唯一匹配否则重读；非 UTF-8/二进制拒绝。来源：[Claude Code tools](https://code.claude.com/docs/en/tools)。
- **社区失败模式**：tab/space 表示与精确字节匹配冲突导致反复“not found”（三方失配：磁盘 tab、Read 显示、Edit 匹配）。来源：[anthropics/claude-code#26996](https://github.com/anthropics/claude-code/issues/26996)（open, 2026-02-19）。
- **Cursor**：官方公开文档仅见“Suggest edits to files and apply them automatically”等高层描述，apply/匹配/失败细节未公开（本轮未获可核源码/权威说明）。来源：[Cursor Agent tools](https://cursor.com/docs/agent/tools)、[Tab overview](https://cursor.com/docs/tab/overview)。**未验证(内部机制)**。
- **四问题(Claude, 已验证契约)**：①唯一性+精确匹配防歧义锚点但对空白敏感；②替换范围由锚文本限定；③需 Read/重读抑制漂移，批量多次编辑仍依赖调用序与最新状态；④未应用则无副作用，已应用无自动回滚（依赖版本控制/人工）。

## 6. 其他方案
- **git apply / unified diff**：默认原子（某 hunk 不适用则整体失败且不改工作区）；`--check` 预检；`--reject` 部分应用并产出 `.rej`；`--3way` 三方合并可留冲突标记；`-C` 上下文、`--index` 一致性校验。来源：[git-apply](https://git-scm.com/docs/git-apply)。适合 diff 工作流与回滚前置，但依赖行上下文与补丁质量。
- **Aider unified diff**：高层 hunk+灵活补丁（去行号、归一/分裂 hunk 等）显著降编辑错误（禁用灵活补丁错误升 9x，基准见文）。来源：[unified-diffs](https://aider.chat/docs/unified-diffs.html)。
- **tree-sitter/AST 查询**：可按节点/字段结构锚定编辑，减少文本歧义；但 Markdown 语法松散/恢复节点多时查询易脆。来源：[tree-sitter queries](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html)。**初步(对 Markdown 适配)**。
- **remark/mdast 结构化编辑**：Markdown→mdast→变换→序列化，节点级操作可靠、可组合；代价是往返可能重排格式/空白，需规范化策略。来源：[mdast](https://github.com/syntax-tree/mdast)、[remark](https://remark.js.org/)。

## 重点问题对照（摘要）
| 方案 | ①锚点唯一/失配 | ②防吞块 | ③batch漂移 | ④回滚 |
|---|---|---|---|---|
| Aider S/R | 精确+空白/省略块启发式，失败反馈模型 | 块边界+`...`计数约束 | 成功即写盘、需禁重发 | 无事务回滚 |
| Codex apply_patch | 多级序列匹配+上下文/EOF，失败报错+delta | chunk 序列定位 | 顺序提交推进索引 | 无全量回滚，有失败delta |
| JSON Patch(6902) | 指针/test 强约束 | 节点级精确 | 顺序+test 可控 | 失败不生效(规范) |
| Morph/Relace | 模型黑箱(未验证) | 未验证 | 未验证 | 未验证 |
| Claude Edit | 唯一性+精确+Read约束 | 锚定范围替换 | 依赖重读/最新态 | 未应用无副作用 |
| git apply | 上下文/--check/--3way | hunk边界 | 默认原子批次 | 默认不落盘; --reject部分 |

## 来源清单
Aider: https://aider.chat/docs/more/edit-formats.html , https://aider.chat/docs/unified-diffs.html , https://aider.chat/docs/leaderboards/edit.html , https://github.com/Aider-AI/aider/blob/main/aider/coders/editblock_coder.py
Codex: https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/parser.rs , https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/seek_sequence.rs , https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/file_update.rs , https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/lib.rs , https://github.com/openai/codex/blob/main/codex-rs/apply-patch/src/streaming_parser.rs （`apply_patch_tool_instructions.md` 本轮 404）
RFC: https://www.rfc-editor.org/rfc/rfc6902.txt , https://www.rfc-editor.org/rfc/rfc7386.txt
Fast-apply: https://morphllm.com/ , https://docs.morphllm.com/sdk/components/fast-apply , https://www.relace.ai/ , https://docs.relace.ai/docs/instant-apply/quickstart
编辑工具: https://code.claude.com/docs/en/tools , https://github.com/anthropics/claude-code/issues/26996 , https://cursor.com/docs/agent/tools , https://cursor.com/docs/tab/overview
其他: https://git-scm.com/docs/git-apply , https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html , https://github.com/syntax-tree/mdast , https://remark.js.org/
