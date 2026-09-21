"""
Print one timeline of a Playwright trace: actions with results and errors,
console messages, page errors and network requests.

Usage: python trace_timeline.py <trace.zip> [--all]
Repeated polling actions are collapsed unless --all is given.
"""
import io
import json
import sys
import zipfile


def lines(archive, suffix):
    for name in archive.namelist():
        if name.endswith(suffix):
            yield from io.TextIOWrapper(archive.open(name), encoding="utf-8")


def main(path, show_all=False):
    archive = zipfile.ZipFile(path)
    events, calls = [], {}
    for line in lines(archive, ".trace"):
        try:
            ev = json.loads(line)
        except ValueError:
            continue
        kind = ev.get("type")
        if kind == "before" and ev.get("method") not in ("__waitInfo__",):
            calls[ev["callId"]] = ev
        elif kind == "after":
            before = calls.get(ev.get("callId"))
            if before is None:
                continue
            method = before.get("method", "?")
            if method == "waitForTimeout" and not show_all:
                continue
            params = json.dumps(before.get("params", {}))[:100]
            outcome = json.dumps(ev.get("error"))[:200] if ev.get("error") else json.dumps(ev.get("result"))[:80]
            events.append((before.get("startTime", ev.get("endTime", 0)), "ACTION", f"{method} {params} -> {outcome}"))
        elif kind == "console":
            events.append((ev.get("time", 0), "CONSOLE", f"{ev.get('messageType')} {(ev.get('text') or '')[:180]}"))
        elif kind == "event" and ev.get("method") == "pageError":
            error = ev.get("params", {}).get("error", {}).get("error", {})
            events.append((ev.get("time", 0), "PAGEERROR", (error.get("message") or "")[:200]))
    for line in lines(archive, ".network"):
        try:
            snap = json.loads(line)["snapshot"]
        except (ValueError, KeyError):
            continue
        start = snap.get("_monotonicTime", 0) * 1000 if snap.get("_monotonicTime", 0) < 1e6 else snap.get("_monotonicTime", 0)
        url = snap["request"]["url"].split("/", 3)[-1][:120]
        status = snap.get("response", {}).get("status")
        failure = snap.get("_failureText") or ""
        events.append((start, "REQUEST", f"{status} {failure} {url} ({snap.get('time', 0):.0f} ms)"))
    events.sort(key=lambda e: e[0])
    t0 = events[0][0] if events else 0
    previous = None
    for t, kind, text in events:
        if not show_all and kind == "ACTION" and text == previous:
            continue
        previous = text
        print(f"{t - t0:9.0f} {kind:9} {text}")


if __name__ == "__main__":
    main(sys.argv[1], "--all" in sys.argv[2:])
