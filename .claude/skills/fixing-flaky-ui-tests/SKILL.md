---
name: fixing-flaky-ui-tests
description: >
  Use when Playwright/pytest UI tests fail intermittently in CI but pass
  locally, fail only on one OS runner (macOS, Windows), time out waiting for
  elements, websockets or scroll positions, are marked flaky/rerun, or when
  asked to make UI tests stable - including Panel/Bokeh apps.
---

# Fixing Flaky UI Tests

A flaky UI test is a race that local timing hides. Find the race and remove it: in the product when a user can hit it, in the test when it waits for the wrong thing. Reruns, sleeps and larger timeouts hide the race; they are not fixes.

## 1. Evidence before theories

- Every local run while reproducing: `--screenshot only-on-failure --full-page-screenshot --tracing retain-on-failure --output <dir>`. Each failure then leaves `<dir>/<test>/trace.zip` and `test-failed-1.png`; without the flags a flake leaves only a traceback. Read the trace with `./scripts/trace_timeline.py <dir>/<test>/trace.zip` (actions, results, console, page errors, requests on one clock) - the timeline usually names the race.
- A CI failure you cannot yet reproduce: read the full job log, and the same trace/screenshot if the job uploads the `--output` dir (`gh run download <run> -p '<artifact>*'`).
- Read the screenshot and compare the failing value with what the component shows _before_ the action (e.g. the items a list renders initially). Equal means the action never took effect; anything else means it stopped short. They are different bugs.
- List which calls in the test run from the test thread into server objects (setting a widget value, calling a method on a component): each can race the server loop and executor.
- Check main history including `RERUN` lines: a `flaky` marker hides failures, so "not failing on main" proves little.
- Note worker (`[gwN]`), time into the run and OS. One-OS-only points at timing. Failures clustered on one worker or late in the run point at resources: count what earlier tests left alive (kernels, servers, pages, subprocesses).
- Cannot reproduce it: make the next failure informative instead of guessing a fix. Add diagnostics on the failure path of the test helper (e.g. dump the websocket messages it saw) and make CI upload server logs, then fix from what the next failure shows. **REQUIRED:** read `instrumenting-ci.md` in this directory when local runs stay green.
- Before blaming your change for a new CI failure, look for the same failure signature on the base branch before your commit. Only a signature that starts at your commit is yours.
- A job cancelled at its timeout says nothing about which step hung. Read the log for the step boundaries first: the tests may have finished and printed their summary long before, and a later step (docs, examples, packaging) is the one stuck.

## 2. Reproduce by varying the cause, not the count

Looping a test hundreds of times on a fast machine rarely reproduces a CI flake. Stress the dimension the evidence points at:

| Stressor                          | How                                                                                                                                | Typically exposes                                                                                                      |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Browser network latency           | `repeat_plugin.py` `NET_LATENCY=<ms>` (CDP `Network.emulateNetworkConditions`)                                                     | resources/modules arriving late, server round trips replacing UI state                                                 |
| Late stylesheets                  | `page.route` holding matching requests, or `latency_plugin.py` `LAT_HTTP_MATCH='\.css'` (Bokeh server)                             | layout/scroll read or applied before CSS, lost scrolls                                                                 |
| Slow or reordered server messages | delay the server's websocket sends/receives; `latency_plugin.py` `LAT_OUT_MATCH` / `LAT_IN_MATCH` does this for a Bokeh server     | ordering between patches and events                                                                                    |
| CPU                               | `repeat_plugin.py` `CPU_THROTTLE=<rate>`, `taskset`/`systemd-run -p CPUQuota`, more workers than cores                             | requestAnimationFrame reads before async renders                                                                       |
| Thread interleaving               | instrumented plugin adding sleeps between server-side steps                                                                        | test thread vs server loop races                                                                                       |
| Dropped or held client messages   | `page.route_web_socket` handler that drops or holds specific frames (e.g. the first request, or everything after the first report) | lost handshakes, races that a server-side debounce normally merges away                                                |
| Stalled network read              | a black-hole TCP server (accept, never answer) as `HTTP(S)_PROXY`                                                                  | code that fetches without a timeout, hangs that only ever appear as a cancelled job                                    |
| The environment CI actually has   | install from the lock file or dependency list CI built with, run the same command with the same worker count and CPU quota         | failures that depend on a dependency version. Expect side effects: a new Playwright needs its browser downloaded again |

All helpers live in `./scripts/`; each documents its knobs at the top. `repeat_plugin.py` parametrizes every test `REPEAT` times (works with xdist, unlike `--count`); REPEAT changes test ids, so select with `-k`. `repeat.sh` runs it under a CPU/memory cap on Linux; set `RUN` and check its hardcoded pytest flags for your project. Record the failure rate under one stressor, change one thing, measure again under the same stressor. Wrap every hunt for a hang in `timeout -s SIGQUIT <limit>`, so a hung run is killed, counted and still leaves its output.

**REQUIRED:** read `root-causes.md` in this directory once you have a symptom; it maps symptoms to causes and fixes seen in practice. Its examples come from Panel/Bokeh, but most causes (styles loading after "ready", lost observer entries, test thread vs server loop, leaked resources) apply to any web UI.

## 3. Choose the fix

- User-visible race: fix the product, and show it failing before and passing after under the stressor.
- Test waits for the wrong thing: wait for the state the assertion depends on - `expect(...)` (retries) or the suite's polling helper on browser state, not on server state and not on an element that exists before the update lands.
- A `flaky` marker is a maintainer's decision, scoped as narrowly as possible (e.g. `condition=sys.platform == "darwin"`), never the fix. Pair it with an `xfail` test that reproduces the bug, strict only where the result is deterministic.
- Replaced a fixed sleep with polling and it still times out after the full wait: the event never happens, it is a bug, not slowness.

## 4. Verify

Stressor reproduction before and after, the whole UI suite under CI-like limits, then CI on every OS. A fix can shift the race: check the next CI runs for new variants of the same test and its siblings before calling it done. If a fix produces a new variant, revert it before trying another.

- Measure each part of a multi-part fix by reverting that part alone. A part with no measured effect is noise in the diff: drop it, especially in product code.
- Compare rates over enough runs to separate them: 1 failure in 30 against 2 in 30 is noise, while 0 in 100 against 5 in 100 is an answer.
- A regression test that injects a delay should slow down only the step the race needs (e.g. the first render, not every one). Delaying every step manufactures failures the fix was never meant to prevent, and you end up chasing them.
- Rare failures need many CI runs, not one; `instrumenting-ci.md` shows how to get them without pushes cancelling each other.

## Common mistakes

| Mistake                                                        | Instead                                                                              |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `page.wait_for_timeout(...)` / bigger timeout                  | wait for the condition; only raise a timeout when the trace shows genuine slowness   |
| Terminating something and waiting for it to die                | `wait(timeout=...)`, then escalate (SIGKILL), so the cleanup cannot outlive the test |
| Reading a value inside the wait's callback without guarding it | check which exceptions the polling helper retries (often only `AssertionError`)      |
