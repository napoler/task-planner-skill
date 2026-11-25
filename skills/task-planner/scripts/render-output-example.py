#!/usr/bin/env python3
"""render-output-example.py — CLI 传参 → JSON 模板 → 合规 output_example_item JSON 文件。

What: 读取含 {{KEY}} 占位符的 JSON 模板，用 --set / --example-file / --template-file /
      --vc-ref 注入参数，产出符合 schemas/plan-state.schema.json#/definitions/output_example_item
      的 JSON 条目（stdout 或 --out 原子写文件）。
Why: 用户 2026-11-25 要求「模板产出依赖脚本生成、通过命令行传参、产出真正符合规范的 JSON 文件」。
      Rule 113 已定义示例契约与 schema 承载位，但手写 JSON 仍有转义/结构错误；本脚本把
      「填模板 → 校验 → 落盘」变成可复现的机器流程，杜绝产出不合规示例。

CLI 约定（对齐 planctl.py）：
  退出码 0=成功 / 1=校验或业务失败 / 2=用法或输入异常；
  stdout 成功输出规范 JSON（--out 时输出单行 RENDER-OE OK <path>）；stderr 报错单行 RENDER-OE FAIL <reason>；
  --dry-run 完整渲染+校验但不落盘。
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tempfile
from pathlib import Path
from typing import Any

SKILL_DIR = Path(__file__).resolve().parent.parent
DEFAULT_TEMPLATE = SKILL_DIR / "templates" / "output-example.template.json"
SCHEMA_PATH = SKILL_DIR / "schemas" / "plan-state.schema.json"

# Rule 113.2：禁「略/同上/TBD」类占位文本充当完整示例（整串匹配，避免误伤模板正文里的「禁 TBD」说明）。
BAD_EXAMPLE_VALUES = {"略", "同上", "tbd", "示例略", "待定", "none", "n/a", ""}
ALLOWED_KEYS = {"id", "deliverable", "format", "example", "template", "vc_refs", "tags"}
REQUIRED_KEYS = {"id", "deliverable", "format", "example", "template", "vc_refs"}
PLACEHOLDER_RE = re.compile(r"\{\{([A-Za-z_][A-Za-z0-9_]*)\}\}")

BUILTIN_TEMPLATE = {
    "id": "{{ID}}",
    "deliverable": "{{DELIVERABLE}}",
    "format": "{{FORMAT}}",
    "example": "{{EXAMPLE}}",
    "template": "{{TEMPLATE}}",
    "vc_refs": [],
    "tags": [],
}


class RenderError(Exception):
    """业务/校验失败（rc 1）；输入/用法异常另走 rc 2。"""


def _fail(reason: str, code: int = 1) -> int:
    print(f"RENDER-OE FAIL {reason}", file=sys.stderr)
    return code


def _read_text(path: Path, label: str) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        raise RenderError(f"{label} 不可读: {exc}") from exc


def _load_template(path: Path | None) -> dict[str, Any]:
    """加载模板 JSON；未指定时用内置骨架。模板必须是 dict，占位符由调用方注入。"""
    if path is None:
        if not DEFAULT_TEMPLATE.is_file():
            return dict(BUILTIN_TEMPLATE)
        path = DEFAULT_TEMPLATE
    text = _read_text(path, "模板")
    try:
        data = json.loads(text)
    except json.JSONDecodeError as exc:
        # 输入异常归 rc=2（对齐 planctl 退出码约定），非业务校验失败的 rc=1。
        raise ValueError(f"模板非法 JSON: {exc}") from exc
    if not isinstance(data, dict):
        raise RenderError("模板顶层必须是 JSON object")
    return data


def _parse_set(pairs: list[str]) -> dict[str, str]:
    """--set KEY=VALUE：键统一大写以匹配 {{KEY}} 占位符；值始终按字符串处理。"""
    out: dict[str, str] = {}
    for pair in pairs:
        if "=" not in pair:
            raise RenderError(f"--set 须为 KEY=VALUE 形态: {pair!r}")
        key, value = pair.split("=", 1)
        key = key.strip().upper()
        if not key:
            raise RenderError("--set KEY 不得为空")
        out[key] = value
    return out


def _coerce_placeholder(value: Any) -> str:
    """dict 层面直接注入原值；最终 json.dumps 统一转义。

    Why: 模板已由 json.loads 解析为 dict，此处再做 json.dumps 会产生双重转义
         （产物 example 变成 '{\\"title\\"...}' 而无法被 json.loads 还原）。
    """
    return value if isinstance(value, str) else json.dumps(value, ensure_ascii=False)


def _render(template: dict[str, Any], params: dict[str, str]) -> dict[str, Any]:
    """递归替换 {{KEY}} 占位符；未提供的占位符 fail-closed 拒绝（对齐 init-session.sh 口径）。"""
    missing: set[str] = set()

    def walk(node: Any) -> Any:
        if isinstance(node, str):
            def sub(m: re.Match[str]) -> str:
                key = m.group(1).upper()
                if key not in params:
                    missing.add(key)
                    return m.group(0)
                return _coerce_placeholder(params[key])
            return PLACEHOLDER_RE.sub(sub, node)
        if isinstance(node, list):
            return [walk(x) for x in node]
        if isinstance(node, dict):
            return {k: walk(v) for k, v in node.items()}
        return node

    result = walk(template)
    if missing:
        raise RenderError("模板占位符未提供参数: " + ", ".join(sorted(missing)))
    return result


def _validate(doc: dict[str, Any], plan_dir: Path | None) -> list[str]:
    """校验 Rule 113 契约：字段集/必填/语义禁占位/VC 参照；返回告警列表。"""
    errors: list[str] = []
    unknown = sorted(set(doc) - ALLOWED_KEYS)
    if unknown:
        errors.append("未知字段: " + ", ".join(unknown))
    for key in sorted(REQUIRED_KEYS - set(doc)):
        errors.append(f"缺必填字段: {key}")
    for key in ("id", "deliverable", "format", "example", "template"):
        if key in doc and (not isinstance(doc[key], str) or not doc[key].strip()):
            errors.append(f"{key} 必须是非空字符串")
    for key in ("example", "template"):
        value = doc.get(key)
        if isinstance(value, str) and value.strip().lower() in BAD_EXAMPLE_VALUES:
            errors.append(f"{key} 是禁用的占位文本: {value!r}")
    vc_refs = doc.get("vc_refs")
    if not isinstance(vc_refs, list) or not vc_refs:
        errors.append("vc_refs 必须是非空字符串数组（Rule 113.4）")
    elif not all(isinstance(x, str) and x.strip() for x in vc_refs):
        errors.append("vc_refs 含空或非字符串元素")
    tags = doc.get("tags", [])
    if not isinstance(tags, list) or not all(isinstance(x, str) for x in tags):
        errors.append("tags 必须是字符串数组")

    # schema 叠加校验：jsonschema 可用则用 Draft7Validator，不可用不阻断（对齐 planctl.py 口径）。
    try:
        from jsonschema import Draft7Validator, RefResolver  # type: ignore
        from jsonschema.exceptions import RefResolutionError  # type: ignore
    except ImportError:
        warnings = ["jsonschema 不可用，已跳过 schema 叠加校验（手工契约为权威）"]
    else:
        if SCHEMA_PATH.is_file():
            schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
            try:
                # output_example_item 内含 $ref → tag_list，须挂 root schema 才能解析（否则 RefResolutionError）。
                validator = Draft7Validator(
                    schema["definitions"]["output_example_item"],
                    resolver=RefResolver.from_schema(schema),
                )
                schema_errors = [f"schema: {e.message}" for e in validator.iter_errors(doc)]
            except (RefResolutionError, KeyError, ValueError) as exc:
                warnings = [f"schema 叠加校验不可用，已降级为手工契约: {exc}"]
            else:
                errors.extend(schema_errors)
                warnings = []
        else:
            warnings = [f"schema 文件缺失，已跳过叠加校验: {SCHEMA_PATH}"]
    if errors:
        raise RenderError("; ".join(errors))

    if plan_dir is not None:
        state = plan_dir / "plan-state.json"
        if not state.is_file():
            raise RenderError(f"--plan-dir 下缺 plan-state.json: {state}")
        data = json.loads(_read_text(state, "plan-state.json"))
        known = {str(v.get("id")) for v in data.get("vcs", [])}
        missing_vc = [v for v in vc_refs if v not in known]
        if missing_vc:
            raise RenderError("vc_refs 引用不存在的 VC: " + ", ".join(missing_vc))
    return warnings


def _atomic_write(path: Path, text: str) -> None:
    """tmp + fsync + os.replace 原子写，失败清理临时文件。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=f".{path.name}.", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            fh.write(text)
            fh.flush()
            os.fsync(fh.fileno())
        os.replace(tmp, path)
    except OSError:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="render-output-example.py",
        description="CLI 传参填充 JSON 模板，产出符合 Rule 113 output_example_item 契约的 JSON 文件。",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=("示例（可照抄）：\n"
                "  python3 render-output-example.py --set id=OE-1 --set deliverable=article.json \\\n"
                "    --set format=JSON --example-file ./article.example.json \\\n"
                "    --template-file ./article.template.json --vc-ref VC-1 --out ./oe-1.json\n"
                "  python3 render-output-example.py --template my.template.json --set ID=OE-2 \\\n"
                "    --set DELIVERABLE=report.json --set FORMAT=Markdown --set EXAMPLE='| 项 | 值 |' \\\n"
                "    --set TEMPLATE='| <K> | <V> |' --vc-ref VC-1 --dry-run\n\n"
                "输出：默认 stdout 规范 JSON；--out 时 stdout 单行 RENDER-OE OK <path>。\n"
                "退出码：0 成功 / 1 校验失败 / 2 输入异常。"),
    )
    parser.add_argument("--template", metavar="FILE", help="JSON 模板文件（{{KEY}} 占位符）；缺省用内置骨架")
    parser.add_argument("--set", action="append", default=[], metavar="KEY=VALUE",
                        help="注入顶层字段（id/deliverable/format/example/template），值按字符串处理")
    parser.add_argument("--example-file", metavar="FILE", help="完整示例文本文件路径（优先于 --set example）")
    parser.add_argument("--template-file", metavar="FILE", help="可复用模板文本文件路径（优先于 --set template）")
    parser.add_argument("--vc-ref", action="append", default=[], metavar="VC_ID", help="对应 VC id，可重复")
    parser.add_argument("--plan-dir", metavar="DIR", help="可选：校验 vc_refs 在该计划的 vcs 中存在")
    parser.add_argument("--out", metavar="FILE", help="输出 JSON 文件路径；缺省 stdout")
    parser.add_argument("--dry-run", action="store_true", help="完整渲染+校验但不落盘")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        template = _load_template(Path(args.template) if args.template else None)
        params = _parse_set(args.set)
        if args.example_file:
            params["EXAMPLE"] = _read_text(Path(args.example_file), "示例文件")
        if args.template_file:
            params["TEMPLATE"] = _read_text(Path(args.template_file), "模板文件")
        doc = _render(template, params)
        # vc_refs 是数组字段，直接赋值（模板骨架保持 []），避免多值占位符的替换歧义。
        if args.vc_ref:
            doc["vc_refs"] = list(dict.fromkeys(args.vc_ref))
        warnings = _validate(doc, Path(args.plan_dir) if args.plan_dir else None)
        text = json.dumps(doc, ensure_ascii=False, indent=2) + "\n"
        if args.dry_run:
            sys.stdout.write(text)
            for w in warnings:
                print(f"RENDER-OE WARN {w}", file=sys.stderr)
            return 0
        if args.out:
            _atomic_write(Path(args.out), text)
            print(f"RENDER-OE OK {args.out}")
        else:
            sys.stdout.write(text)
        for w in warnings:
            print(f"RENDER-OE WARN {w}", file=sys.stderr)
        return 0
    except RenderError as exc:
        return _fail(str(exc), 1)
    except (OSError, ValueError) as exc:
        return _fail(f"输入异常: {exc}", 2)


if __name__ == "__main__":
    sys.exit(main())
