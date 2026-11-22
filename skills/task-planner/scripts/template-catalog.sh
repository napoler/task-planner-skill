#!/usr/bin/env bash
# [2026-11-22 task-template-catalog-20261122] template-catalog.sh — 模板检索/管理 CLI（用户诉求：模板匹配流程化+可克隆派生）
# WHAT: 枚举「当前项目级 + 用户级(全局 + 安装位) + 内置」计划模板，输出模板名/简介/适配场景/功能；
#       支持 add/clone/derive 固化模板沉淀流程。仅文件扫描 + 可选 JSON 清单缓存，不引入 SQL/DB（D1 决策）。
# WHY:  旧 --list(init-session.sh:21-53) 仅人读文本、单项目 scope、无场景/功能字段，匹配靠读散文与固定流程；
#       统一 template_meta 注释块(D2)提供机器可读元数据，任务初期调 list --json 即可稳定匹配模板。
# 元数据契约: 模板头 `<!-- template_meta: {"name":…,"summary":…,"scenarios":[…],"features":[…]} -->`
#             缺失时回退到注释散文启发式抽取(适用场景/触发关键词/描述)，兼容存量与自定义模板。
# Usage:
#   template-catalog.sh list [--scope all|builtin|project|user|user-global|user-install] [--json] [--query <关键词>] [--recommend <任务描述>] [--include-installs]
#   template-catalog.sh add <name> [--from <type|path>] [--scope project|user-global] [--dry-run] [--force]
#   template-catalog.sh clone --from <type|path> --to <name> [--scope project|user-global] [--dry-run] [--force]
#   template-catalog.sh derive --from <type|path> --to <name> [--prune <段名,段名>] [--scope project|user-global] [--dry-run] [--force]
#   template-catalog.sh --help | -h
# 输出契约: list 默认人读表; --json 输出稳定 JSON {"templates":[{file,type,name,summary,scenarios,features,path,scope,default,valid},…]}
#           add/clone/derive stdout 单行结果行 `CATALOG <ACTION> <OK|DRY|FAIL> <path>`；错误走 stderr。
# exit: 0=成功 1=业务失败(源不存在/同名冲突等) 2=用法错误
# 作用域优先级(去重): project > user-global > user-install > builtin
set -euo pipefail

TCAT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TCAT_SCRIPT_DIR
exec python3 - "$@" <<'PY'
import os, sys, re, json, glob, shutil, argparse, datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))
# 兼容内嵌执行: sys.argv[0] 是 '-'，改用环境变量或 cwd 不可靠 → 用 __file__ 占位由 bash 传入
# bash 调用 `python3 - "$@"` 时 sys.argv[0]='-'；真实脚本目录经 SCRIPT_DIR_ENV 传入
SCRIPT_DIR = os.environ.get("TCAT_SCRIPT_DIR", SCRIPT_DIR)
SKILL_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
REPO_ROOT = os.path.abspath(os.path.join(SKILL_DIR, "..", ".."))
BUILTIN_DIR = os.path.join(SKILL_DIR, "templates")
BUILTIN_VARIANT = os.path.join(BUILTIN_DIR, "variant")

META_RE = re.compile(r'<!--\s*template_meta:\s*(\{.*?\})\s*-->', re.S)
TYPE_RE = re.compile(r'<!--\s*template_type:\s*([A-Za-z0-9-]+)', re.M)
# [BUGFIX 2026-11-22 task-template-catalog] TYPE_FULL_RE 含尾部 `-->`：旧 TYPE_RE.sub 只替换到类型名，残留 ` -->` 产生 `<!-- template_type: X --> -->` 畸形头。
# 注意 re.sub replacement 若含反斜杠（meta JSON 的 `\"`）会被当转义序列破坏 JSON → 全部改用 lambda 作 replacement（返回字面串）。
TYPE_FULL_RE = re.compile(r'<!--\s*template_type:\s*[A-Za-z0-9-]+\s*-->', re.M)
TIER_RE = re.compile(r'(?:^<!--\s*plan_tier:\s*([A-Za-z0-9-]+)|^plan_tier:\s*([A-Za-z0-9-]+))', re.M)
LINEAGE_RE = re.compile(r'<!--\s*template-lineage:.*?-->', re.S)

def die(msg, code=1):
    print(f"[catalog] ERROR: {msg}", file=sys.stderr)
    sys.exit(code)

def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()

# ---- 元数据解析: template_meta 优先 → 启发式回退 ----
def parse_meta(path):
    text = read(path)
    m = META_RE.search(text)
    obj = None
    if m:
        try:
            obj = json.loads(m.group(1))
        except Exception:
            obj = None
    tm = TYPE_RE.search(text)
    ttype = tm.group(1) if tm else ""
    if not ttype:
        bn = os.path.basename(path)
        ttype = "general" if bn == "task_plan.md" else re.sub(r'-type\.md$', '', bn)
    tier_m = TIER_RE.search(text)
    tier = (tier_m.group(1) or tier_m.group(2)) if tier_m else "standard"
    if obj and isinstance(obj, dict):
        return {
            "type": str(obj.get("type") or ttype),
            "name": str(obj.get("name") or ttype),
            "summary": str(obj.get("summary") or ""),
            "scenarios": obj.get("scenarios") if isinstance(obj.get("scenarios"), list) else [],
            "features": obj.get("features") if isinstance(obj.get("features"), list) else [],
            "tier": str(obj.get("tier") or tier),
            "meta_source": "template_meta",
        }
    # 回退: 散文启发式
    name = ""
    h1 = re.search(r'^#\s+(.+)$', text, re.M)
    if h1:
        name = re.sub(r'\[.*?\]', '', h1.group(1)).strip()
    summary, scenarios, features = "", [], []
    for line in text.splitlines()[:20]:
        c = re.search(r'<!--\s*(.*?)\s*-->', line)
        if not c:
            continue
        s = c.group(1).strip()
        if re.match(r'^(适用场景|适用于|触发词|触发关键词)', s):
            val = re.sub(r'^(适用场景|适用于|触发词|触发关键词)\s*[:：]\s*', '', s)
            scenarios += [x.strip() for x in re.split(r'[/、,，]', val) if x.strip()][:6]
        elif not summary and s and not s.startswith(('template_type', 'plan_tier', 'template-lineage', 'planctl', '人工门', '渲染契约')):
            summary = s[:80]
    for line in text.splitlines():
        h = re.match(r'^##\s+(.+)$', line)
        if h:
            features.append(re.sub(r'[🔍📎🎯🧮⚙️📦🛡]', '', h.group(1)).strip())
        if len(features) >= 6:
            break
    return {
        "type": ttype, "name": name or ttype, "summary": summary,
        "scenarios": scenarios[:6], "features": features[:6],
        "tier": tier, "meta_source": "heuristic",
    }

# ---- 作用域目录发现（复用 init-session.sh:64-79 向上遍历逻辑） ----
def find_project_templates(cwd):
    d = os.path.abspath(cwd)
    while d != "/":
        for sub in (".claude/plan-templates", ".zcode/plan-templates"):
            p = os.path.join(d, sub)
            if os.path.isdir(p):
                return p
        d = os.path.dirname(d)
    return None

def collect_scope(scope, include_installs):
    """返回 [(path, scope_label)]；scope_label ∈ project|user-global|user-install|builtin"""
    out = []
    cwd = os.getcwd()
    if scope in ("all", "project"):
        pd = find_project_templates(cwd)
        if pd:
            for f in glob.glob(os.path.join(pd, "*-type.md")):
                out.append((f, "project"))
    if scope in ("all", "user", "user-global"):
        home = os.path.expanduser("~")
        for sub in (".claude/plan-templates", ".zcode/plan-templates"):
            gd = os.path.join(home, sub)
            if os.path.isdir(gd):
                for f in glob.glob(os.path.join(gd, "*-type.md")):
                    out.append((f, "user-global"))
    if scope in ("all", "builtin", "user", "user-install"):
        for f in glob.glob(os.path.join(BUILTIN_VARIANT, "*-type.md")):
            out.append((f, "builtin"))
        base = os.path.join(BUILTIN_DIR, "task_plan.md")
        if os.path.isfile(base):
            out.append((base, "builtin"))
    if include_installs and scope in ("all", "user", "user-install"):
        for plat in ("zcode", "agents", "claude", "cursor"):
            vd = os.path.expanduser(f"~/.{plat}/skills/task-planner/templates/variant")
            for f in glob.glob(os.path.join(vd, "*-type.md")):
                out.append((f, "user-install"))
    return out

SCOPE_RANK = {"project": 0, "user-global": 1, "user-install": 2, "builtin": 3}

def valid_types():
    ts = {"general"}
    for f in glob.glob(os.path.join(BUILTIN_VARIANT, "*-type.md")):
        ts.add(re.sub(r'-type\.md$', '', os.path.basename(f)))
    pd = find_project_templates(os.getcwd())
    if pd:
        for f in glob.glob(os.path.join(pd, "*-type.md")):
            ts.add(os.path.basename(f)[:-len("-type.md")])
    return ts

def default_type():
    pd = find_project_templates(os.getcwd())
    if pd and os.path.isfile(os.path.join(pd, "default")):
        try:
            v = read(os.path.join(pd, "default")).splitlines()[0].strip()
            if v:
                return v
        except Exception:
            pass
    return os.environ.get("TASK_TEMPLATE_DEFAULT", "") or "general"

def resolve_source(ref, scope):
    """type 名或路径 → 源文件绝对路径。
    [BUGFIX 2026-11-22 task-template-catalog] 源解析优先级改为 builtin(当前安装位,含 template_meta 权威源) > project > user-global > user-install。
    旧实现按 SCOPE_RANK(project<user-global<user-install<builtin) 升序，导致命中旧部署位无 meta 模板 → clone 元数据启发式回退(scenarios 空)。"""
    if os.path.isfile(ref):
        return os.path.abspath(ref)
    entries = collect_scope("all", True)
    # builtin 优先（当前 skill 安装位=权威源），其余按 SCOPE_RANK
    for label in ["builtin"] + [k for k in sorted(SCOPE_RANK, key=lambda x: SCOPE_RANK[x]) if k != "builtin"]:
        for path, slabel in entries:
            if slabel == label and os.path.basename(path) == f"{ref}-type.md":
                return path
    die(f"找不到源模板: {ref}")

def target_dir(scope):
    if scope == "project":
        # 项目级落位：CWD 向上最近的项目根（无 plan-templates 则用 cwd 所在项目根）
        pd = find_project_templates(os.getcwd())
        if pd:
            return pd
        d = os.path.abspath(os.getcwd())
        while d != "/":
            if os.path.isdir(os.path.join(d, ".zcode")) or os.path.isdir(os.path.join(d, ".claude")):
                return os.path.join(d, ".zcode", "plan-templates")
            d = os.path.dirname(d)
        return os.path.join(os.getcwd(), ".zcode", "plan-templates")
    if scope == "user-global":
        return os.path.join(os.path.expanduser("~"), ".zcode", "plan-templates")
    die(f"不支持的目标 scope: {scope}（仅 project/user-global）")

# ---- list ----
def cmd_list(args):
    vcs = valid_types()
    dflt = default_type()
    entries = collect_scope(args.scope, args.include_installs)
    dedup = {}
    for path, label in entries:
        meta = parse_meta(path)
        key = meta["type"]
        rec = dict(meta)
        rec.update({
            "file": os.path.basename(path),
            "path": path,
            "scope": label,
            "default": (key == dflt),
            "valid": (key in vcs),
        })
        if key not in dedup or SCOPE_RANK[label] < SCOPE_RANK[dedup[key]["scope"]]:
            dedup[key] = rec
    rows = list(dedup.values())
    # 关键词过滤/推荐排序
    if args.query or args.recommend:
        kw = (args.query or args.recommend or "").strip()
        toks = [t for t in re.split(r'[\s,，、/]+', kw) if t]
        def score(r):
            hay = " ".join([r["name"], r["summary"]] + r["scenarios"] + r["features"]).lower()
            return sum(1 for t in toks if t.lower() in hay)
        scored = [(score(r), i, r) for i, r in enumerate(rows)]
        if args.query:
            rows = [r for sc, _, r in scored if sc > 0]
        else:
            rows = [r for sc, i, r in sorted(scored, key=lambda x: (-x[0], x[1])) if sc > 0]
    if args.json:
        print(json.dumps({"templates": rows, "default": dflt, "count": len(rows)}, ensure_ascii=False, indent=2))
        return
    print(f"模板清单（scope={args.scope}，共 {len(rows)} 项；默认={dflt}）")
    print(f"{'TYPE':<24}{'SCOPE':<14}{'NAME':<20}{'SUMMARY / SCENARIOS'}")
    for r in rows:
        sc = ",".join(r["scenarios"][:3])
        print(f"{r['type']:<24}{r['scope']:<14}{r['name'][:18]:<20}{r['summary'][:40]} [{sc}]")

# ---- add/clone/derive ----
def cmd_write(args, action):
    src = resolve_source(args.from_, args.scope)
    src_text = read(src)
    meta = parse_meta(src)
    new_type = args.to
    if not re.match(r'^[A-Za-z0-9-]+$', new_type):
        die(f"目标名非法（仅字母数字连字符）: {new_type}")
    ddir = target_dir(args.scope)
    dst = os.path.join(ddir, f"{new_type}-type.md")
    exists = os.path.isfile(dst)
    if exists and not args.force:
        die(f"同名模板已存在（未 --force 拒锁）: {dst}")
    # 改写 template_type（TYPE_FULL_RE 含尾部 -->；lambda replacement 避免反斜杠转义）
    text = src_text
    if TYPE_FULL_RE.search(text):
        text = TYPE_FULL_RE.sub(lambda m: f'<!-- template_type: {new_type} -->', text, count=1)
    else:
        text = f'<!-- template_type: {new_type} -->\n' + text
    # 改写 template_meta（name/type=新，其余继承）
    mobj = {"type": new_type, "name": new_type, "summary": meta["summary"],
            "scenarios": meta["scenarios"], "features": meta["features"]}
    mline = f'<!-- template_meta: {json.dumps(mobj, ensure_ascii=False)} -->\n'
    if META_RE.search(text):
        text = META_RE.sub(lambda m: mline.rstrip('\n'), text, count=1)
    else:
        # 插入在 template_type 行之后
        lines = text.splitlines(True)
        for i, ln in enumerate(lines):
            if TYPE_RE.search(ln):
                lines.insert(i + 1, mline)
                break
        else:
            lines.insert(0, mline)
        text = "".join(lines)
    # lineage 注入（派生登记）
    parent_type = meta["type"]
    pruned = ""
    if action == "derive" and getattr(args, "prune", None):
        pruned = args.prune
    reason = "variant=克隆派生，父模板见 parent 字段" if action != "derive" else f"variant=领域裁剪派生，裁剪面={pruned or '待填'}"
    lineage = f'<!-- template-lineage: level=derived parent={parent_type}-type.md base=../task_plan.md spec_version=1 pruned="{pruned or "none"}" pruned_reason="{reason}" -->\n'
    if LINEAGE_RE.search(text):
        text = LINEAGE_RE.sub(lambda m: lineage.rstrip('\n'), text, count=1)
    else:
        lines = text.splitlines(True)
        for i, ln in enumerate(lines):
            if TYPE_RE.search(ln):
                lines.insert(i + 1, lineage)
                break
        else:
            lines.insert(0, lineage)
        text = "".join(lines)
    # derive 的 --prune：删除匹配的 `## <段名>` 段（到下一 `## ` 或文末）
    if action == "derive" and pruned:
        for seg in [s.strip() for s in pruned.split(",") if s.strip()]:
            text = re.sub(r'(?ms)^##\s*' + re.escape(seg) + r'[^\n]*\n(?:^(?!##\s).*\n?)*', '', text)
    status = "DRY" if args.dry_run else "OK"
    if not args.dry_run:
        os.makedirs(ddir, exist_ok=True)
        if exists:
            shutil.copy2(dst, dst + ".bak." + datetime.datetime.now().strftime("%Y%m%d%H%M%S"))
        with open(dst, "w", encoding="utf-8") as f:
            f.write(text)
    print(f"CATALOG {action.upper()} {status} {dst}")

def build_parser():
    p = argparse.ArgumentParser(prog="template-catalog.sh", description="模板检索/管理 CLI")
    sub = p.add_subparsers(dest="cmd", required=True)
    lp = sub.add_parser("list", help="列出模板清单")
    lp.add_argument("--scope", default="all", choices=["all", "builtin", "project", "user", "user-global", "user-install"])
    lp.add_argument("--json", action="store_true")
    lp.add_argument("--query", help="按关键词过滤（名称/简介/场景/功能）")
    lp.add_argument("--recommend", help="按任务描述关键词排序推荐")
    lp.add_argument("--include-installs", action="store_true", help="含 ~/.zcode|agents|claude|cursor 安装位模板")
    for act in ("add", "clone", "derive"):
        ap = sub.add_parser(act, help=f"{act} 模板")
        if act == "add":
            ap.add_argument("name", help="新模板类型名")
            ap.add_argument("--from", dest="from_", help="源模板 type 或路径（省略=空骨架）")
        else:
            ap.add_argument("--from", dest="from_", required=True, help="源模板 type 或路径")
            ap.add_argument("--to", required=True, help="目标模板类型名")
        ap.add_argument("--scope", default="project", choices=["project", "user-global"])
        ap.add_argument("--dry-run", action="store_true")
        ap.add_argument("--force", action="store_true")
        if act == "derive":
            ap.add_argument("--prune", help="逗号分隔的 ## 段名，派生时裁剪")
    return p

def main():
    args = build_parser().parse_args()
    if args.cmd == "list":
        cmd_list(args)
    elif args.cmd == "add":
        if getattr(args, "from_", None):
            args.to = args.name
            cmd_write(args, "clone")
        else:
            # 空骨架：从 general 派生
            args.from_ = "general"
            args.to = args.name
            args.prune = None
            cmd_write(args, "add")
    elif args.cmd in ("clone", "derive"):
        cmd_write(args, args.cmd)

if __name__ == "__main__":
    main()
PY
