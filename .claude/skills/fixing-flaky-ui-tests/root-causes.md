# Root causes of flaky UI tests (Playwright, Panel/Bokeh)

Each entry: symptom -> cause -> fix. Found by reproducing CI failures locally.

## Page "ready" is not "styled"

- **Symptom:** wrong heights (`800 == 400`), borders missing, `scrollTop` not what was set, scroll-to-latest does nothing, only under latency or on slow runners.
- **Cause:** Bokeh views request their shadow-DOM stylesheets only when they render, after `networkidle`/`readyState === 'complete'`. Until the CSS loads a container is not scrollable (`overflow-y: visible`), so `scrollTo` is a no-op and layout differs.
- **Test fix:** after render, wait until every `link[rel=stylesheet]` in every shadow root has `sheet != null`. Chromium also gives a stylesheet that failed to load (HTTP or network error) an empty sheet, so a `null` sheet means still in flight.
- **Product fix:** when a scroll is requested before the element can scroll, re-apply it on the shadow root's capture-phase `load` event.

## IntersectionObserver entries lost

- **Symptom:** virtualized list (Feed) never loads more items or snaps back to the top.
- **Cause:** entries ignored while the container does not clip (before CSS) or while children are being rebuilt are never delivered again - an observer only reports a target again when its intersection changes.
- **Fix:** when you drop entries, unobserve and observe the targets again once they can be measured; observing always delivers an initial entry.

## Reported before the initial scroll landed

- **Symptom:** a list that should start at its latest item (e.g. Feed `view_latest`) ends mid-list or near the start; reproduces only when messages are delayed.
- **Cause:** the component reports what is visible before its initial scroll has landed (the scroll takes several frames). A server-side debounce usually merges that stale report with the next one; when the server handles it alone it loads the wrong range and the next report no longer matches.
- **Reproduce:** hold the browser's websocket messages for ~100 ms after the first report (`page.route_web_socket`).
- **Fix:** gate the reports until the scroll actually landed (the element can scroll and was scrolled), then re-observe so the first report comes from the right position.

## Server state changed, browser not yet

- **Symptom:** assertion right after `widget.value = ...` or `.scroll_to_latest()` sees the old value; clicking something the update will replace.
- **Fix:** `expect(locator).to_have_css/to_have_text(...)`; for data widgets compare the browser's model data with the server model (`Bokeh.documents[0].get_model_by_id(source.id).data` vs `model.source.data`). BokehJS stores `data` as a `Map`: read it with `[...data.entries()]` (`Object.entries` on a Map is empty, so the wait never passes), and compare values as strings.

## Client-first, then server replaces

- **Symptom:** Tabulator cell editor vanishes (`Locator.fill` timeout on `input[type="text"]`).
- **Cause:** header filters, sorting and paging apply in the browser first; then the server re-sends the rows and replacing the rows destroys an open editor. Row-count waits pass before the server data lands.
- **Fix:** after the filter/sort/page and after each edit, first wait until the server has processed it (e.g. `widget.filters`, `widget.current_view` or the server model data shows the change), then until the browser data equals the server data. A bare "browser equals server" check passes immediately while both still hold the old rows. Do not defer the server data while editing: edits are patched by row index and would hit the wrong row.

## Redraw right after render

- **Symptom:** `Element is not attached to the DOM`, `bounding_box()` returns `None`, baseline positions never match.
- **Cause:** Tabulator redraws once its stylesheets initialize (and after loading/data changes), replacing cells and briefly resetting the scroll.
- **Fix:** retry the interaction inside `wait_until`; record baselines only when the element is laid out _and_ inside its container; compare final positions with `wait_until`, a real rescroll still fails.

## requestAnimationFrame reads before async work

- **Symptom:** auto-scroll lands at the old bottom.
- **Cause:** a change handler schedules a rAF that reads `scrollHeight`, but children are built asynchronously (`await build_child_views()`) and may land after the frame.
- **Fix:** decide on the change, act after the async update completes (plus a frame for layout). Keep the extra frame on that path only - adding it to shared helpers changed other components' behavior.

## Test thread vs server loop

- **Symptom:** `AttributeError: 'NoneType' object has no attribute 'advance'`, `BufferError: Existing exports of data`, server-side state briefly inconsistent, or an action called from the test (e.g. `feed.scroll_to_latest()`) that sometimes has no effect even though the browser was ready.
- **Cause:** test code runs outside the Bokeh server's IOLoop; Tornado streams are not thread-safe, and product code that temporarily mutates a parameter (set, trigger, restore) races with the server executor thread.
- **Fix:** `ws_connection.stream.io_loop.add_callback(ws_connection.close)`; in product code compute from explicit arguments instead of temporarily mutating state; map client reports against the range actually sent (`_last_synced`), not a recomputed one.

## Leaked resources across tests

- **Symptom:** timeouts that get more likely later in the run, services (kernels, servers) that start or respond ever slower, mostly on the smallest runner.
- **Cause:** something a test starts outlives it - e.g. every notebook starts a kernel that keeps running after its page closes; a dozen idle kernels with the library imported starve a 3-vCPU / 7 GB runner.
- **Find:** count what is alive after a run (e.g. `GET /api/kernels`); read the server log for starts without matching shutdowns.
- **Fix:** each test cleans up exactly what it started (e.g. delete its own notebook's session), never everything - other xdist workers share the server.

## xdist worker dies with no traceback

- **Symptom:** `[gwN] node down: Not properly terminated`, one test reported as crashed, and nothing else in the log; or the run stops dispatching work and hangs.
- **Cause:** the worker process ended without unwinding (signal, `os._exit`, or a libc `exit`), so nothing printed. Separately, pytest-xdist 3.8.0 deadlocks `--dist loadgroup` when it replaces a crashed worker (upstream PRs #1323, #1327): it requeues finished work and gives the replacement one test, which it never starts.
- **Find:** report the exit status from `pytest_testnodedown`, trace which test each worker ran, register faulthandler for catchable signals, wrap `os._exit`, and check `dmesg` for OOM kills. Knowing it exited 1 with no output rules out signals, OOM and segfaults in one step.
- **Fix:** `--max-worker-restart=0` so a crash fails the job in seconds and names the test instead of hanging until the timeout.

## Fixtures that leak loops, pools and processes

- **Symptom:** tests get slower or flakier later in the run; `cannot schedule new futures after shutdown` during teardown; threads still alive when the session ends.
- **Cause:** a fixture that creates two event loops and closes the wrong one leaks the loop the servers ran on plus its default executor threads; a fixture that shuts a shared thread pool down before the servers stop leaves the server unable to discard its sessions; a subprocess started with `--num-procs` forks children that terminating the parent leaves running.
- **Find:** print `threading.enumerate()` at session end, and `pgrep -af` the server command after a run; measure before and after, since a fixture's teardown order (requested fixtures finalize before autouse ones) is what usually decides this.
- **Fix:** one loop per fixture, stop the servers first, shut the loop's default executor down before closing it, restore the loop that was current, and terminate a served subprocess by process group with a bounded wait then SIGKILL.

## Requests in tests without timeouts

- **Symptom:** a test that polls or fetches hangs until CI cancels the job; the stack sits in `socket.readinto`.
- **Cause:** `requests`/`urllib` block forever by default, so a server that accepts and stops answering (mid-render, deadlocked, or gone) wedges the test rather than failing it.
- **Fix:** a timeout on every request in tests and helpers, including the polling loop that waits for a server to come up.

## Data applied while the widget is still building

- **Symptom:** a table keeps the rows it was built with; a later update (`value = None`, or a new frame) never appears, in either direction.
- **Cause:** the view drops data that arrives while it is initializing or rebuilding (an early `return` in its `setData`), and nothing re-applies it afterwards.
- **Fix:** record that an update was dropped and apply it when the build finishes.

## Tests that depend on the internet

- **Symptom:** one-off failures fetching sample data, images or CDN modules: connection reset, `URLError`, or a page that never reaches `networkidle` because a CDN request hangs.
- **Find:** log every request to a non-local host per test (browser: `page.on("request")`; server: wrap `socket.getaddrinfo`) to see which tests are network-bound. Bokeh's Tabler icon font and Google Fonts pull in many pages you would not expect.
- **Fix:** mark those tests with the suite's `internet` marker and give marked tests reruns centrally in `pytest_collection_modifyitems`; that also skips them when offline.
- **Notebook runs:** collected cells carry no markers, so give that run reruns on the command itself and cap the cell timeout, or the same stalled fetch either fails the job outright or hangs it.
