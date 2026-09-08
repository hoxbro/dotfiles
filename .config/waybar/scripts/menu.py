#!/usr/bin/python3
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GLib, Gtk

GLib.set_prgname("waybar-menu")

STYLE_CSS = b"""
button.worktime-item.menuitem.flat {
  min-width: 140px;
  padding: 0px 8px;
  font-family: "SF Pro Text";
  font-size: 14px;
  transition: background-color 150ms ease;
}
button.worktime-item.menuitem.flat:backdrop {
  color: #ffffff;
}
button.worktime-item.menuitem.flat:hover {
  background-color: #10509c;
  background-image: none;
  color: #ffffff;
}
window,
.background,
decoration,
.solid-csd decoration {
  background-color: @theme_base_color;
  border-color: @theme_base_color;
}
"""


def main() -> int:
    names = [line.rstrip("\n") for line in sys.stdin if line.strip()]
    if not names:
        return 1

    provider = Gtk.CssProvider()
    provider.load_from_data(STYLE_CSS)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    win = Gtk.Window(type=Gtk.WindowType.TOPLEVEL)
    win.set_decorated(False)
    win.set_resizable(False)
    win.set_skip_taskbar_hint(True)
    win.set_skip_pager_hint(True)

    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
    win.add(box)

    chosen: dict[str, str] = {}

    def on_click(_button: Gtk.Button, name: str) -> None:
        chosen["name"] = name
        Gtk.main_quit()

    for name in names:
        label = Gtk.Label(label=name)
        label.set_xalign(0.0)

        btn = Gtk.Button()
        btn.set_relief(Gtk.ReliefStyle.NONE)
        style = btn.get_style_context()
        style.add_class("menuitem")
        style.add_class("flat")
        style.add_class("worktime-item")
        btn.add(label)
        btn.connect("clicked", on_click, name)
        box.pack_start(btn, False, False, 0)

    def stop(*_args: object) -> bool:
        Gtk.main_quit()
        return False

    def on_key_press(_widget: Gtk.Widget, event: Gdk.EventKey) -> bool:
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()
        return False

    win.connect("focus-out-event", stop)
    win.connect("key-press-event", on_key_press)
    win.connect("destroy", stop)

    win.show_all()
    Gtk.main()

    if "name" in chosen:
        print(chosen["name"])
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
