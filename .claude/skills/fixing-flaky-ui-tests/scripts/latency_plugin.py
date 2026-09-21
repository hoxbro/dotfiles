"""
Inject latency / reordering on the Bokeh websocket inside the test process.

Env vars (all ms):
  LAT_OUT, LAT_OUT_JITTER      delay for every server->client message
  LAT_OUT_FIFO=1               keep server->client order (else jitter reorders)
  LAT_OUT_MATCH, LAT_OUT_MATCH_MS  extra delay for messages whose content matches regex
  LAT_IN, LAT_IN_JITTER        delay for every client->server message
  LAT_IN_FIFO=1                keep client->server order
  LAT_IN_MATCH, LAT_IN_MATCH_MS    extra delay for incoming matching messages
  LAT_LOG=<dir>                write a message log per test
  LAT_HTTP_MATCH, LAT_HTTP_MIN, LAT_HTTP_MAX  delay HTTP requests whose path
                               matches regex by a random MIN..MAX, e.g. '\\.css'

Load with `-p latency_plugin` and its directory on PYTHONPATH. It patches the
Tornado server running inside the pytest process (threaded test servers).
"""

import asyncio
import json
import os
import random
import re
import time

import pytest


def _env_ms(name, default=0.0):
    return float(os.environ.get(name, default)) / 1000.0


OUT = _env_ms("LAT_OUT")
OUT_J = _env_ms("LAT_OUT_JITTER")
OUT_FIFO = os.environ.get("LAT_OUT_FIFO") == "1"
OUT_MATCH = re.compile(os.environ["LAT_OUT_MATCH"]) if os.environ.get("LAT_OUT_MATCH") else None
OUT_MATCH_D = _env_ms("LAT_OUT_MATCH_MS")
IN = _env_ms("LAT_IN")
IN_J = _env_ms("LAT_IN_JITTER")
IN_FIFO = os.environ.get("LAT_IN_FIFO") == "1"
IN_MATCH = re.compile(os.environ["LAT_IN_MATCH"]) if os.environ.get("LAT_IN_MATCH") else None
IN_MATCH_D = _env_ms("LAT_IN_MATCH_MS")
LOG_DIR = os.environ.get("LAT_LOG")
FRAG = _env_ms("LAT_FRAG")
INTERLEAVE = os.environ.get("LAT_INTERLEAVE") == "1"
HTTP_MATCH = re.compile(os.environ["LAT_HTTP_MATCH"]) if os.environ.get("LAT_HTTP_MATCH") else None
HTTP_MIN = _env_ms("LAT_HTTP_MIN")
HTTP_MAX = _env_ms("LAT_HTTP_MAX")

_log = []
_t0 = [time.monotonic()]


def _summ(content):
    try:
        data = json.loads(content)
    except Exception:
        return content[:120]
    out = []
    for ev in data.get("events", []) or []:
        kind = ev.get("kind")
        if kind == "ModelChanged":
            new = ev.get("new")
            if ev.get("attr") == "children" and isinstance(new, list):
                val = f"children[{len(new)}]"
            elif ev.get("attr") == "visible_children":
                val = f"visible_children[{len(new)}]"
            else:
                val = f"{ev.get('attr')}={json.dumps(new)[:40]}"
            out.append(val)
        elif kind == "MessageSent":
            msg = ev.get("msg_data", {})
            out.append(f"MessageSent:{msg.get('name', '?') if isinstance(msg, dict) else '?'}")
        else:
            out.append(str(kind))
    if "events" in data:
        return ",".join(out) or "<empty patch>"
    if isinstance(data, dict) and "event_name" in data:
        return f"event:{data['event_name']}"
    return content[:80]


def _record(direction, header, content, delay, phase):
    if LOG_DIR is None:
        return
    try:
        msgtype = json.loads(header).get("msgtype")
    except Exception:
        msgtype = "?"
    _log.append(
        f"{time.monotonic() - _t0[0]:8.3f} {direction} {phase:5s} d={delay * 1000:5.0f} "
        f"{msgtype} {_summ(content) if isinstance(content, str) else '<bin>'}"
    )


def _delay(base, jitter, match, match_d, content):
    d = base + random.uniform(0, jitter)
    if match is not None and isinstance(content, str) and match.search(content):
        d += match_d
    return d


class _Assembler:
    def __init__(self):
        self.frags = []
        self.expected = None

    def add(self, frag):
        self.frags.append(frag)
        if self.expected is None:
            try:
                header = json.loads(frag[0] if isinstance(frag, tuple) else frag)
                self.expected = 3 + 2 * int(header.get("num_buffers", 0) or 0)
            except Exception:
                self.expected = 1
        if len(self.frags) >= self.expected:
            frags = self.frags
            self.frags, self.expected = [], None
            return frags
        return None


def _install():
    from bokeh.server.views.ws import WSHandler
    from tornado.websocket import WebSocketHandler

    orig_write = WebSocketHandler.write_message
    orig_on_message = WSHandler.on_message

    def write_message(self, message, binary=False):
        if not isinstance(self, WSHandler) or not (OUT or OUT_J or OUT_MATCH or LOG_DIR):
            return orig_write(self, message, binary)
        loop = asyncio.get_running_loop()
        asm = self.__dict__.setdefault("_lat_out_asm", _Assembler())
        done = loop.create_future()
        done.set_result(None)
        frags = asm.add((message, binary))
        if frags is None:
            return done
        header, content = frags[0][0], frags[2][0] if len(frags) > 2 else ""
        d = _delay(OUT, OUT_J, OUT_MATCH, OUT_MATCH_D, content)
        _record("S->C", header, content, d, "queue")
        prev = self.__dict__.get("_lat_out_tail") if OUT_FIFO else None

        async def send(frags=frags, d=d, prev=prev):
            await asyncio.sleep(d)
            if prev is not None:
                await prev
            if self.ws_connection is None or self.ws_connection.is_closing():
                return
            _record("S->C", header, content, d, "sent")
            # Write all fragments without yielding so messages never interleave.
            try:
                if INTERLEAVE:
                    for m, b in frags:
                        await orig_write(self, m, b)
                        await asyncio.sleep(0)
                else:
                    futs = [orig_write(self, m, b) for m, b in frags]
                    for fut in futs:
                        await fut
            except Exception:
                return

        task = loop.create_task(send())
        self.__dict__["_lat_out_tail"] = task
        return done

    async def on_message(self, message):
        if not (IN or IN_J or IN_MATCH or LOG_DIR):
            return await orig_on_message(self, message)
        asm = self.__dict__.setdefault("_lat_in_asm", _Assembler())
        frags = asm.add(message)
        if frags is None:
            return None
        header, content = frags[0], frags[2] if len(frags) > 2 else ""
        d = _delay(IN, IN_J, IN_MATCH, IN_MATCH_D, content)
        _record("C->S", header, content, d, "queue")
        loop = asyncio.get_running_loop()
        lock = self.__dict__.setdefault("_lat_in_lock", asyncio.Lock())
        prev = self.__dict__.get("_lat_in_tail") if IN_FIFO else None

        async def deliver(frags=frags, d=d, prev=prev):
            await asyncio.sleep(d)
            if prev is not None:
                await prev
            async with lock:
                _record("C->S", header, content, d, "recv")
                for f in frags:
                    await orig_on_message(self, f)

        self.__dict__["_lat_in_tail"] = loop.create_task(deliver())
        return None

    WebSocketHandler.write_message = write_message
    WSHandler.on_message = on_message

    if HTTP_MATCH is not None:
        import tornado.web

        orig_execute = tornado.web.RequestHandler._execute

        async def _execute(self, transforms, *args, **kwargs):
            path = self.request.path
            if HTTP_MATCH.search(path):
                d = random.uniform(HTTP_MIN, HTTP_MAX)
                _log.append(f"{time.monotonic() - _t0[0]:8.3f} HTTP  delay {d * 1000:5.0f} {path}")
                await asyncio.sleep(d)
            return await orig_execute(self, transforms, *args, **kwargs)

        tornado.web.RequestHandler._execute = _execute

    if FRAG:
        bk_write = WSHandler.write_message

        async def bk_write_message(self, message, binary=False, locked=True):
            # Bokeh's Message.send holds write_lock across fragments; stretch that window.
            if not locked:
                await asyncio.sleep(random.uniform(0, FRAG))
            return await bk_write(self, message, binary, locked)

        WSHandler.write_message = bk_write_message


def pytest_configure(config):
    _install()


@pytest.fixture(autouse=True)
def _latency_log(request):
    _log.clear()
    _t0[0] = time.monotonic()
    if LOG_DIR is not None and "page" in request.fixturenames:
        page = request.getfixturevalue("page")

        def on_console(msg):
            _log.append(f"{time.monotonic() - _t0[0]:8.3f} CONSOLE {msg.type}: {msg.text[:300]}")

        def on_error(err):
            _log.append(f"{time.monotonic() - _t0[0]:8.3f} PAGEERROR {err}")

        page.on("console", on_console)
        page.on("pageerror", on_error)
    yield
    if LOG_DIR is None:
        return
    rep = getattr(request.node, "rep_call", None)
    failed = rep is not None and rep.failed
    os.makedirs(LOG_DIR, exist_ok=True)
    name = re.sub(r"[^\w.-]+", "_", request.node.name)
    status = "FAIL" if failed else "pass"
    if failed or os.environ.get("LAT_LOG_ALL") == "1":
        with open(os.path.join(LOG_DIR, f"{status}_{name}.log"), "w") as f:
            f.write("\n".join(_log) + "\n")


@pytest.hookimpl(wrapper=True)
def pytest_runtest_makereport(item, call):
    rep = yield
    if rep.when == "call":
        item.rep_call = rep
    return rep
