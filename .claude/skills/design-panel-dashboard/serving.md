# Serving a Panel Dashboard

Runtime behavior once the app is served. This captures the gotchas and when-to-use judgment only. For full signatures and options, follow the linked Panel guides.

## The Session Model

Each browser tab that connects to a served app gets its own session backed by a separate Bokeh `Document`; the app code runs once per session.

- Module-level mutable globals are shared across all sessions. A list, dict, or DataFrame created at module scope is one object for every user; mutating it leaks state between sessions. Keep per-user state on instances (your `Viewer`/`Parameterized` objects), and use `pn.state.cache` _only_ for intentionally shared, read-mostly data.
- `pn.state` is the per-session runtime handle (`served`, `curdoc`, `session_args`, `cache`, scheduling, lifecycle). Don't stash per-user mutable state on it casually.

`panel serve app.py` (CLI) is the standard way to deploy.

## Server-Side State and Scheduling

Periodic callbacks, deferred execution (`pn.state.execute`), and session lifecycle hooks (`onload`, `on_session_created`/`on_session_destroyed`, `schedule_task`) all live on `pn.state`; see Panel's [Callbacks guide](https://panel.holoviz.org/how_to/callbacks/index.html). What agents get wrong:

- `pn.state.add_periodic_callback(fn, period=...)`: `period` is in milliseconds, and the returned handle must be `.stop()`-ed. Tie it to the session so it stops on disconnect.
- Use `pn.state.execute(fn)` to defer heavy work off a callback so the UI stays responsive instead of blocking until the handler returns. It accepts both sync and `async` callbacks.

## URL State Sync

Share or bookmark the app's exact state by syncing param values to the URL query string with `pn.state.location.sync(obj, [...])`. Pass a list to sync names as-is, or a dict mapping param name → query param name for shorter URLs:

```python
class Filters(param.Parameterized):
    year = param.Integer(default=2020)
    region = param.Selector(default="North", objects=["North", "South"])


filters = Filters()
if pn.state.location:
    pn.state.location.sync(filters, {"year": "y", "region": "r"})
```

Gotchas:

- Guard with `if pn.state.location:`. It's `None` outside a served app (a notebook cell, `python app.py` without a server context, some embeddings), and calling `.sync()` unconditionally raises at import time in those contexts.
- Only _changed_ parameters appear in the URL. A freshly loaded page at its default state shows a bare URL with no query string. If every visit needs the full state in the URL, set the query params explicitly (e.g. in an `onload` hook).
- Values are JSON-encoded going out. A synced param holding something without a JSON representation (a custom class, a DataFrame) raises when it changes. Sync only JSON-safe types and keep richer state (like a `param.DataFrame`) derived from the synced params.
- `Selector` options that look like integers can misresolve on load: restoring `?region=01` coerces to the int `1` before matching against string options and fails. Prefer non-numeric option strings for anything synced to the URL.

Call `pn.state.location.unsync(obj)` to stop syncing (e.g. when a component holding synced state is torn down). Pass the same object given to `.sync()`.

## Caching

Panel has three tiers (full API in the [Caching guide](https://panel.holoviz.org/how_to/caching/index.html)); the choice is the part worth knowing:

- `pn.state.cache`: a plain process-global dict shared across sessions. For a one-time dataset load shared by everyone.
- `pn.state.as_cached(key, fn, ttl=..., **kwargs)`: same intent, no manual `if`-check; reruns only when the hashed `kwargs` change.
- `@pn.cache`: memoize a function on its arguments; reach for it when results depend on inputs (supports `ttl`, `max_items`, `policy`, `to_disk`, `per_session`).

Warm the cache before the first visitor with `panel serve --warm` (and `--setup script.py` to populate from a separate script).
