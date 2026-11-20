---
name: design-panel-dashboard
description: Use when building or refactoring a multi-view HoloViz Panel dashboard with filters or selection shared across views, a Viewer mixing data transforms with layout, per-session state leaks, URL state sync, caching, or slow first render and tab loading.
---

# Designing Panel Dashboards

## Overview

Split state, derived data, and presentation into separate classes so one `DataStore` computes the filtered data once and feeds every view.

## When to Use

- Two or more views need the _same_ filtered/derived data; don't recompute it in each.
- State (filter values, selection) is read and written by several components.
- A single `Viewer` is growing past ~150 lines or mixing data transforms with layout.

If none of these hold, stay with one `Viewer`.

Once the app is served, see:

- [serving.md](serving.md): session model, scheduling, URL state sync, caching.
- [loading.md](loading.md): batching, spinners, eager init, two-phase rendering, tab-aware loading.

## The Composition Pattern

Four roles, each its own class, wired by `param.ClassSelector`:

- State (`Filters`): parameters only, plus its own widget panel. No data logic.
- DataStore: holds the raw `data` and a reference to the state; exposes derived data. No UI.
- View subclasses: presentation only; each reads from the shared `DataStore`.
- App: the shell that composes views and wraps them in `pn.ui.Page`.

Full pattern to adapt: [composition.py](composition.py).

The payoff: `DataStore.filtered()` is testable without rendering any UI, and one `DataStore` feeds every view. Add a view by appending a class to `views`, nothing else.

## Cross-Object Dependencies

`@param.depends` accepts dotted paths to a sub-object's parameter, so a `DataStore` method can depend on its `Filters`' params (`"filters.year"`). A view then depends on the store's method by name: `@param.depends("data_store.filtered")`. This is what lets state, transform, and view live in separate classes yet stay reactive. The objects must be linked via `ClassSelector` (or passed at construction) for the path to resolve.

## The `from_data` Factory

Configure `.objects`/`.bounds` from data _outside_ `__init__` with a `classmethod` (see `Filters.from_data` in [composition.py](composition.py)), so the state class stays construction-agnostic and testable. After setting `.objects`/`.bounds`, assign the value to match, otherwise the default falls outside the new options/bounds.

## Sharing Derived Data

Two ways to expose derived data from a `DataStore`:

- Method + `@param.depends` ([composition.py](composition.py)): recomputed each time a consumer calls it. Simple; fine when one or two views read it.
- Stored `param.DataFrame`: when _many_ components read the same derived frame, compute it once into a param with a `watch=True, on_init=True` watcher and have views depend on that param.

The stored variant turns `filtered` from a _method_ into a _parameter_, so every consumer changes: read `self.data_store.filtered` (no call) or bind to `self.data_store.param.filtered`.

```python
class DataStore(param.Parameterized):
    data = param.DataFrame()
    filters = param.ClassSelector(class_=Filters)
    filtered = param.DataFrame()  # cached result, shared

    @param.depends("data", "filters.year", "filters.manufacturers", watch=True, on_init=True)
    def _update_filtered(self):
        low, high = self.filters.year
        mask = self.data["year"].between(low, high)
        if self.filters.manufacturers:
            mask &= self.data["manufacturer"].isin(self.filters.manufacturers)
        self.filtered = self.data.loc[mask]


class Indicators(View):
    @param.depends("data_store.filtered")  # now a param path, not a method
    def __panel__(self):
        df = self.data_store.filtered  # attribute, no call
        return pn.ui.Number(name="Rows", value=len(df), format="{value:,.0f}")


class Table(View):
    def __panel__(self):
        return pn.ui.Tabulator(
            self.data_store.param.filtered,  # bind to the param
            pagination="remote",
            page_size=12,
            sizing_mode="stretch_width",
        )
```

## Reactive Expressions (`.rx`)

Use `.rx` to derive any component property (text, labels, `disabled`, `visible`, etc.) from other parameters, right where the component is built:

```python
export = pn.ui.Button(label="Export", disabled=filters.param.manufacturers.rx.len() == 0)
table = pn.ui.Card(title="Table", visible=filters.param.show_table.rx())
```

## Tabulator

Use `pagination="remote"` when the table has or is expected to have more than 100 rows.

## Wiring Shortcuts

- Pass a `Parameter` or widget directly as a constructor arg to bind it reactively, no callback needed:

  ```python
  card = pn.ui.Card(title=state.param.title, visible=state.param.visible)
  table = pn.ui.Tabulator(df, page_size=self.param.page_size)
  ```

- `widget.link(target, value="param_name")` for one-way sync into another object's param (cleaner than a manual `.param.watch`):

  ```python
  manufacturers_widget.link(filters, value="manufacturers")
  ```

## Imperative vs Declarative

Default to declarative (`@param.depends`, `pn.bind`, `pn.rx`) for data/UI derivations; they are easier to test and compose. Keep imperative `.param.watch` only for true side effects: logging, persisting settings, notifications.

```python
def log_filter_change(event):
    print(f"[filters] {event.name} -> {event.new}")


filters.param.watch(log_filter_change, ["year", "manufacturers"])
```

## Common Mistakes

| Mistake                                                                  | Fix                                                                                                  |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| Filtering inside each view                                               | One `DataStore` exposes the derived data; views only read it                                         |
| Setting `.objects`/`.bounds` without updating the value                  | Assign the value right after (`f.year = f.param.year.bounds`)                                        |
| Switching `filtered` to a param but still calling `filtered()` somewhere | Update every consumer: attribute access or `param.filtered`                                          |
| `.param.watch` to keep derived data or UI in sync                        | `@param.depends`, `pn.bind`, `.rx`, or pass the param to the constructor                             |
| Tabulator with hundreds of rows and no pagination                        | `pagination="remote"`                                                                                |
| Mutable data at module scope                                             | Per-session state on instances; shared read-only data in `pn.state.cache` ([serving.md](serving.md)) |
| `pn.state.location.sync(...)` without a guard                            | `if pn.state.location:` first ([serving.md](serving.md))                                             |
| `add_periodic_callback(period=5)` meaning seconds                        | `period` is milliseconds; `.stop()` the handle ([serving.md](serving.md))                            |
| Spinner never shows during a slow sync callback                          | Make the work `async` ([loading.md](loading.md))                                                     |
| Loading flag stuck after an exception                                    | Clear it in `finally` ([loading.md](loading.md))                                                     |
| Caching the bare `Viewer` for tabs                                       | Cache `pn.panel(view(...))` ([loading.md](loading.md))                                               |
