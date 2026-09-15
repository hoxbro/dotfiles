#!/usr/bin/python3
import json
import subprocess
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell

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


def cursor_position() -> tuple[int, int] | None:
    try:
        out = subprocess.run(
            ["hyprctl", "cursorpos", "-j"], capture_output=True, text=True, timeout=1
        ).stdout
        pos = json.loads(out)
        return int(pos["x"]), int(pos["y"])
    except (OSError, subprocess.SubprocessError, ValueError, KeyError):
        return None


def main() -> int:
    alt_file = sys.argv[1] if len(sys.argv) > 1 else None
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

    GtkLayerShell.init_for_window(win)
    GtkLayerShell.set_namespace(win, "waybar-menu")
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
    GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.ON_DEMAND)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.TOP, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.LEFT, True)
    GtkLayerShell.set_exclusive_zone(win, -1)

    display = Gdk.Display.get_default()
    cursor = cursor_position()
    monitor = (
        display.get_monitor_at_point(*cursor) if cursor else display.get_primary_monitor()
    ) or display.get_monitor(0)
    GtkLayerShell.set_monitor(win, monitor)
    geometry = monitor.get_geometry()

    def place() -> None:
        width = win.get_preferred_width().natural_width
        height = win.get_preferred_height().natural_height
        x = cursor[0] - geometry.x if cursor else geometry.width
        y = cursor[1] - geometry.y if cursor else 0
        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.LEFT, max(0, min(x, geometry.width - width)))
        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.TOP, max(0, min(y, geometry.height - height)))

    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
    win.add(box)

    chosen: dict[str, str] = {}
    # The item right-clicked to open the alt list; None while showing names.
    alt_for: str | None = None

    def on_click(_button: Gtk.Button, value: str) -> None:
        chosen["value"] = value if alt_for is None else f"{alt_for}\n{value}"
        Gtk.main_quit()

    def fill(items: list[str]) -> None:
        for child in box.get_children():
            box.remove(child)
        for name in items:
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
            btn.connect("button-press-event", on_button_press, name)
            box.pack_start(btn, False, False, 0)
        box.show_all()
        win.resize(1, 1)
        place()

    def on_button_press(_widget: Gtk.Widget, event: Gdk.EventButton, name: str) -> bool:
        nonlocal alt_for, cursor
        if event.button != 3 or alt_file is None:
            return False
        cursor = cursor_position() or cursor
        if alt_for is not None:
            alt_for = None
            fill(names)
            return True
        try:
            with open(alt_file) as f:
                alt = [line.rstrip("\n") for line in f if line.strip()]
        except OSError:
            alt = []
        if alt:
            alt_for = name
            fill(alt)
        return True

    fill(names)

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

    if "value" in chosen:
        print(chosen["value"])
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
