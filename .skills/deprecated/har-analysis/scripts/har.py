#!/usr/bin/env python3
"""Query HAR (HTTP Archive) files without loading them whole into context.

Stdlib only. All subcommands print compact, line-oriented text sized for an
agent context window. Entry INDEX values are stable across subcommands: they
are the entry's position in the HAR's entries array.

Usage:
  har.py summary   FILE
  har.py list      FILE [--status 4xx|5xx|404|...] [--domain D] [--method M]
                        [--url-contains S] [--mime S] [--slower-than MS]
                        [--sort start|time|size] [--limit N]
  har.py show      FILE INDEX [--request-body] [--response-body] [--max-bytes N]
  har.py timing    FILE [--limit N]
  har.py endpoints FILE [--domain D]
"""

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from urllib.parse import urlsplit

MAX_URL = 100


def load_entries(path):
    with open(path, encoding="utf-8-sig") as f:
        har = json.load(f)
    try:
        return har["log"]["entries"]
    except (KeyError, TypeError):
        sys.exit("error: not a HAR file (missing log.entries)")


def host(entry):
    return urlsplit(entry["request"]["url"]).netloc


def short_url(url, width=MAX_URL):
    return url if len(url) <= width else url[: width - 1] + "…"


def resp_size(entry):
    r = entry["response"]
    size = r.get("_transferSize", -1)
    if size is None or size < 0:
        size = r.get("bodySize", -1) or -1
    if size < 0:
        size = r.get("content", {}).get("size", 0) or 0
    return max(size, 0)


def fmt_size(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return f"{n:.0f}{unit}" if unit == "B" else f"{n:.1f}{unit}"
        n /= 1024


def match_status(status, spec):
    spec = spec.lower()
    if re.fullmatch(r"[1-5]xx", spec):
        return status // 100 == int(spec[0])
    return str(status) == spec


def entry_line(i, e):
    r = e["response"]
    mime = r.get("content", {}).get("mimeType", "").split(";")[0]
    return (
        f"[{i}] {e['request']['method']:<6} {r['status']:<3} "
        f"{e.get('time', 0):>7.0f}ms {fmt_size(resp_size(e)):>8} "
        f"{mime:<24} {short_url(e['request']['url'])}"
    )


def cmd_summary(entries, args):
    if not entries:
        print("0 entries")
        return
    statuses = Counter(e["response"]["status"] for e in entries)
    methods = Counter(e["request"]["method"] for e in entries)
    domains = Counter(host(e) for e in entries)
    mimes = Counter(
        e["response"].get("content", {}).get("mimeType", "?").split(";")[0]
        for e in entries
    )
    total = sum(resp_size(e) for e in entries)
    starts = sorted(e.get("startedDateTime", "") for e in entries)
    print(f"{len(entries)} entries, {fmt_size(total)} transferred")
    print(f"capture: {starts[0]} -> {starts[-1]}")
    print("methods:", ", ".join(f"{m}={c}" for m, c in methods.most_common()))
    print("status: ", ", ".join(f"{s}={c}" for s, c in sorted(statuses.items())))
    errors = [i for i, e in enumerate(entries) if e["response"]["status"] >= 400]
    if errors:
        print(f"errors ({len(errors)}): indexes {errors[:20]}")
    print("top domains:")
    for d, c in domains.most_common(15):
        print(f"  {c:>4}  {d}")
    print("top mime types:")
    for m, c in mimes.most_common(10):
        print(f"  {c:>4}  {m}")


def cmd_list(entries, args):
    rows = list(enumerate(entries))
    if args.status:
        rows = [(i, e) for i, e in rows if match_status(e["response"]["status"], args.status)]
    if args.domain:
        rows = [(i, e) for i, e in rows if args.domain in host(e)]
    if args.method:
        rows = [(i, e) for i, e in rows if e["request"]["method"] == args.method.upper()]
    if args.url_contains:
        rows = [(i, e) for i, e in rows if args.url_contains in e["request"]["url"]]
    if args.mime:
        rows = [
            (i, e)
            for i, e in rows
            if args.mime in e["response"].get("content", {}).get("mimeType", "")
        ]
    if args.slower_than:
        rows = [(i, e) for i, e in rows if e.get("time", 0) > args.slower_than]
    if args.sort == "time":
        rows.sort(key=lambda r: r[1].get("time", 0), reverse=True)
    elif args.sort == "size":
        rows.sort(key=lambda r: resp_size(r[1]), reverse=True)
    total = len(rows)
    for i, e in rows[: args.limit]:
        print(entry_line(i, e))
    if total > args.limit:
        print(f"... {total - args.limit} more (raise --limit or filter further)")


def print_headers(label, headers):
    print(label)
    for h in headers:
        print(f"  {h['name']}: {h['value']}")


def print_body(label, text, max_bytes):
    if not text:
        print(f"{label}: <empty or not captured>")
        return
    print(f"{label} ({len(text)} chars):")
    print(text[:max_bytes])
    if len(text) > max_bytes:
        print(f"... truncated at {max_bytes} bytes (raise --max-bytes)")


def cmd_show(entries, args):
    try:
        e = entries[args.index]
    except IndexError:
        sys.exit(f"error: index {args.index} out of range (0..{len(entries) - 1})")
    req, resp = e["request"], e["response"]
    print(f"[{args.index}] {req['method']} {req['url']}")
    print(f"status: {resp['status']} {resp.get('statusText', '')}")
    print(f"started: {e.get('startedDateTime', '?')}  time: {e.get('time', 0):.0f}ms")
    t = e.get("timings", {})
    print(
        "timings: "
        + " ".join(f"{k}={t.get(k, -1):.0f}" for k in ("blocked", "dns", "connect", "ssl", "send", "wait", "receive"))
    )
    print_headers("request headers:", req.get("headers", []))
    if req.get("queryString"):
        print("query params:")
        for q in req["queryString"]:
            print(f"  {q['name']}={q['value']}")
    if args.request_body:
        post = req.get("postData", {})
        print_body("request body", post.get("text", ""), args.max_bytes)
    print_headers("response headers:", resp.get("headers", []))
    if args.response_body:
        content = resp.get("content", {})
        note = " (base64)" if content.get("encoding") == "base64" else ""
        print_body(f"response body{note}", content.get("text", ""), args.max_bytes)
    if not args.request_body and not args.response_body:
        print("(bodies omitted; pass --request-body / --response-body)")


def cmd_timing(entries, args):
    rows = sorted(enumerate(entries), key=lambda r: r[1].get("time", 0), reverse=True)
    print("slowest entries (phases in ms):")
    for i, e in rows[: args.limit]:
        t = e.get("timings", {})
        phases = " ".join(
            f"{k}={t[k]:.0f}"
            for k in ("blocked", "dns", "connect", "ssl", "send", "wait", "receive")
            if t.get(k, -1) is not None and t.get(k, -1) >= 0
        )
        print(f"[{i}] {e.get('time', 0):>7.0f}ms  {phases}")
        print(f"      {e['request']['method']} {short_url(e['request']['url'])}")


ID_SEG = re.compile(r"^(\d+|[0-9a-f]{8}-[0-9a-f-]{27,}|[0-9a-f]{16,})$", re.I)


def template(url):
    parts = urlsplit(url)
    segs = [("{id}" if ID_SEG.match(s) else s) for s in parts.path.split("/")]
    return parts.netloc + "/".join(segs)


def cmd_endpoints(entries, args):
    groups = defaultdict(list)
    for i, e in enumerate(entries):
        if args.domain and args.domain not in host(e):
            continue
        mime = e["response"].get("content", {}).get("mimeType", "")
        # focus on API-ish traffic: skip static assets unless --all
        if not args.all and not (
            "json" in mime or "xml" in mime or e["request"]["method"] != "GET"
        ):
            continue
        groups[(e["request"]["method"], template(e["request"]["url"]))].append((i, e))
    for (method, tmpl), items in sorted(groups.items(), key=lambda g: -len(g[1])):
        statuses = Counter(e["response"]["status"] for _, e in items)
        print(f"{method} {tmpl}")
        print(
            f"  calls={len(items)} indexes={[i for i, _ in items][:15]} "
            f"status={dict(statuses)}"
        )
        # per-param values across calls: varying params reveal pagination/cursors
        params = defaultdict(list)
        for _, e in items:
            for q in e["request"].get("queryString", []):
                params[q["name"]].append(q["value"])
        for name, values in sorted(params.items()):
            uniq = list(dict.fromkeys(values))
            shown = ", ".join(v[:40] for v in uniq[:6])
            more = f" (+{len(uniq) - 6} more)" if len(uniq) > 6 else ""
            tag = "varies" if len(uniq) > 1 else "fixed"
            print(f"  ?{name} [{tag}]: {shown}{more}")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("summary", help="capture overview")
    s.add_argument("file")

    s = sub.add_parser("list", help="filter and list entries")
    s.add_argument("file")
    s.add_argument("--status")
    s.add_argument("--domain")
    s.add_argument("--method")
    s.add_argument("--url-contains")
    s.add_argument("--mime")
    s.add_argument("--slower-than", type=float)
    s.add_argument("--sort", choices=["start", "time", "size"], default="start")
    s.add_argument("--limit", type=int, default=40)

    s = sub.add_parser("show", help="one entry in detail")
    s.add_argument("file")
    s.add_argument("index", type=int)
    s.add_argument("--request-body", action="store_true")
    s.add_argument("--response-body", action="store_true")
    s.add_argument("--max-bytes", type=int, default=4000)

    s = sub.add_parser("timing", help="slowest entries with phase breakdown")
    s.add_argument("file")
    s.add_argument("--limit", type=int, default=15)

    s = sub.add_parser("endpoints", help="group API calls by URL template; show query-param variance")
    s.add_argument("file")
    s.add_argument("--domain")
    s.add_argument("--all", action="store_true", help="include static assets")

    args = p.parse_args()
    entries = load_entries(args.file)
    {
        "summary": cmd_summary,
        "list": cmd_list,
        "show": cmd_show,
        "timing": cmd_timing,
        "endpoints": cmd_endpoints,
    }[args.cmd](entries, args)


if __name__ == "__main__":
    main()
