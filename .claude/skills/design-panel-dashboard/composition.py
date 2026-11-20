import panel as pn
import param

pn.extension("tabulator", throttled=True)


class Filters(pn.viewable.Viewer):
    year = param.Range(default=(2010, 2020), bounds=(2000, 2025))
    manufacturers = param.ListSelector(default=[], objects=[])

    @classmethod
    def from_data(cls, df):
        f = cls()
        f.param.year.bounds = (int(df["year"].min()), int(df["year"].max()))
        f.year = f.param.year.bounds
        f.param.manufacturers.objects = sorted(df["manufacturer"].unique().tolist())
        f.manufacturers = f.param.manufacturers.objects
        return f

    def __panel__(self):
        return pn.ui.Param(
            self,
            parameters=["year", "manufacturers"],
            widgets={"manufacturers": {"type": pn.ui.MultiChoice}},
            width=320,
        )


class DataStore(param.Parameterized):  # plain Parameterized, no UI
    data = param.DataFrame()
    filters = param.ClassSelector(class_=Filters)

    @param.depends("data", "filters.year", "filters.manufacturers")
    def filtered(self):
        low, high = self.filters.year
        mask = self.data["year"].between(low, high)
        if self.filters.manufacturers:
            mask &= self.data["manufacturer"].isin(self.filters.manufacturers)
        return self.data.loc[mask]


class View(pn.viewable.Viewer):  # shared base
    data_store = param.ClassSelector(class_=DataStore)


class Indicators(View):
    @param.depends("data_store.filtered")
    def __panel__(self):
        df = self.data_store.filtered()
        return pn.ui.Number(name="Rows", value=len(df), format="{value:,.0f}")


class Table(View):
    def __panel__(self):
        return pn.ui.Tabulator(
            self.data_store.filtered,
            pagination="remote",
            page_size=12,
            sizing_mode="stretch_width",
        )


class App(pn.viewable.Viewer):
    title = param.String(default="Wind Explorer")
    data_store = param.ClassSelector(class_=DataStore)
    views = param.List()

    def __panel__(self):
        views = [view(data_store=self.data_store) for view in self.views]
        return pn.ui.Page(title=self.title, sidebar=[self.data_store.filters], main=views)


def make_data(): ...  # DataFrame with "year" and "manufacturer" columns


if pn.state.served:
    df = make_data()
    store = DataStore(data=df, filters=Filters.from_data(df))
    App(data_store=store, views=[Indicators, Table]).servable()
