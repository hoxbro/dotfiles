"""
Repeat tests and stress the browser. Load with `-p repeat_plugin` and this
directory on PYTHONPATH.

  REPEAT=N         parametrize every test N times (works with pytest-xdist;
                   test ids change, so select with -k instead of node ids)
  CPU_THROTTLE=R   Chromium CPU slowdown factor (CDP Emulation.setCPUThrottlingRate)
  NET_LATENCY=MS   added latency for every browser request
  NET_DOWN, NET_UP throughput in bytes/s (-1 = unlimited)
  EXPECT_TIMEOUT   default Playwright expect() timeout in ms
"""
import os

import pytest


@pytest.fixture
def _repeat():
    return None


@pytest.fixture(autouse=True)
def _browser_stress(request):
    rate = os.environ.get("CPU_THROTTLE")
    latency = os.environ.get("NET_LATENCY")
    if (rate or latency) and "page" in request.fixturenames:
        page = request.getfixturevalue("page")
        session = page.context.new_cdp_session(page)
        if rate:
            session.send("Emulation.setCPUThrottlingRate", {"rate": float(rate)})
        if latency:
            session.send("Network.enable")
            session.send("Network.emulateNetworkConditions", {
                "offline": False,
                "latency": float(latency),
                "downloadThroughput": float(os.environ.get("NET_DOWN", -1)),
                "uploadThroughput": float(os.environ.get("NET_UP", -1)),
            })
    yield


def pytest_generate_tests(metafunc):
    n = int(os.environ.get("REPEAT", "1"))
    if n > 1:
        metafunc.fixturenames.append("_repeat")
        metafunc.parametrize("_repeat", range(n), ids=lambda i: f"r{i}")


def pytest_configure(config):
    timeout = os.environ.get("EXPECT_TIMEOUT")
    if timeout:
        from playwright.sync_api import expect

        expect.set_options(timeout=int(timeout))
