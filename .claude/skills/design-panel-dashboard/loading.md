# Loading and Perceived Performance

How to keep a served Panel dashboard responsive when some work is slow.

## Batching, Loading, and Memory

- Batch updates: wrap multiple component assignments in `pn.io.hold()` so they trigger a single redraw instead of one per assignment.
- Defer heavy components: `pn.extension(defer_load=True, loading_indicator=True)` renders the page first and loads slow panes afterward with a spinner.
- Loading spinner: wrap a slow update in the component's `loading` flag. `with self._main.param.update(loading=True): ...` sets it on enter and reverts on exit. A synchronous callback won't flush the spinner until it returns; make the slow work `async` if you need it visible _during_ the load.
- Memory: cap streaming history, call `pn.state.clear_caches()` when appropriate, and schedule periodic restarts for long-running deployments.

## Eager Init

When the app has a landing page (search-first, login, etc.), move connection setup and reference-data loads into a background task so the first real action skips the cold-start cost. Schedule it with `pn.state.execute`, which runs an `async` callback on the session's event loop:

```python
import asyncio
import threading


class MyApp(pn.viewable.Viewer):
    def __init__(self, **params):
        super().__init__(**params)
        self._con = None
        self._init_lock = threading.Lock()
        pn.state.execute(self._eager_init)

    async def _eager_init(self):
        try:
            await asyncio.to_thread(self._warm_connection)
        except Exception:
            pass  # will retry on first query

    def _warm_connection(self):
        with self._init_lock:
            if self._con is None:
                self._con = self._connect()
```

The `threading.Lock` prevents a query that arrives before init finishes from creating a duplicate connection; it blocks on the lock instead. The query method calls the same `_warm_connection()`; if init is done, the lock is free and the inner check is false.

## Two-Phase Rendering

When one component is orders of magnitude heavier than the rest (a datashader map vs. a table and a small chart), show the light results first and build the heavy one in the background:

```python
async def _render(self, df):
    # Phase 1: light components appear immediately
    with pn.io.hold():
        self._table.value = df
        self._chart.object = self._chart_spec(df)
        self._table.loading = False
        self._chart.loading = False

    await asyncio.sleep(0)  # yield so phase 1 reaches the browser

    # Phase 2: heavy component, built off the event loop
    self._map.object = await asyncio.to_thread(self._build_map, df)
    self._map.loading = False
```

## Tab-Aware Loading

Use `pn.ui.TabMenu` for the tab headers, held in a `ClassSelector` so a method can depend on `menu.active` and return the content. Only the active view is in the page. Build each view on its first visit and reuse it afterward:

```python
class App(pn.viewable.Viewer):
    menu = param.ClassSelector(class_=pn.ui.TabMenu)

    def __init__(self, **params):
        super().__init__(**params)
        self._built = {}
        self._main = pn.Column(sizing_mode="stretch_width")
        self.menu = pn.ui.TabMenu(items=[view.__name__ for view in self.views], active=0)

    @param.depends("menu.active", watch=True)
    def _show(self):
        view = self.views[self.menu.active]
        if view not in self._built:
            self._built[view] = pn.panel(view(data_store=self.data_store))
        self._main[:] = [self._built[view]]

    def __panel__(self):
        return pn.ui.Page(title=self.title, main=[self.menu, self._main])
```

- Put the lightweight view first and the heavy one (e.g. a datashader map) on a later tab, so the first render is fast and the heavy view is only built if the user opens it.
- Cache `pn.panel(view(...))`, not the bare `Viewer`: Panel calls `__panel__` again every time a `Viewer` is rendered, which would rebuild the view on every switch.

## ReactComponent Params Outside `hold()`

`pn.io.hold()` batches Bokeh model syncs but may not flush `ReactComponent` param changes. Set params on custom `ReactComponent`s (e.g. an app header showing KPIs and a status line) outside the hold block:

```python
# ReactComponent params: set directly so they flush immediately
self.header.kpis = kpis
self.header.status = f"{len(df):,} rows"

# Bokeh-backed components: batched together
with pn.io.hold():
    self._table.value = df
    self._chart.object = spec
```

## Loading Flag Discipline

Loading flags must clear on every code path. Set them before the work and clear them in `finally`, which runs whether the update succeeds, raises, or returns early:

```python
async def _refresh(self, *_):
    outputs = [self._table, self._chart, self._map]
    with pn.io.hold():
        for output in outputs:
            output.loading = True
    try:
        await self._render(self.data_store.filtered())
    except Exception as exc:
        self.header.status = f"Update failed: {exc}"
    finally:
        with pn.io.hold():
            for output in outputs:
                output.loading = False
```

If `_render` already cleared some flags (as in two-phase rendering), setting `False` again is a no-op; the `finally` is a safety net, not the primary clear.
