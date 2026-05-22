local HYPR_SCALE = tonumber(os.getenv("HYPR_SCALE"))

-- Layout
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 1,
        col = { active_border = "rgba(90a0bfee)", inactive_border = "rgba(595959aa)" },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    xwayland = {
        force_zero_scaling = true,
    },
    decoration = {
        rounding = 4,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },
    animations = {
        enabled = false,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        focus_on_activate = false,
    },
    input = {
        kb_layout = "us,dk",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle,ctrl:nocaps",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Devices
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
hl.device({ name = "apple-inc.-magic-trackpad", sensitivity = 0.5 })

-- Monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = HYPR_SCALE })

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("elephant")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("mako")

    hl.exec_cmd("ghostty")
    hl.exec_cmd("librewolf", { workspace = "2 silent" })
    hl.exec_cmd("ferdium", { workspace = "3 silent" })
    hl.exec_cmd("1password")
    hl.exec_cmd("betterbird")
    hl.exec_cmd("clockify")
    hl.exec_cmd("spotify")

    hl.timer(function() hl.config({ misc = { focus_on_activate = true } }) end, { timeout = 5000, type = "oneshot" })
end)

-- Keybindings
hl.bind("SUPER + t", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + v", hl.dsp.window.float())
hl.bind("SUPER + escape", hl.dsp.exec_cmd('hyprlock && date "+%H:%M" >> /tmp/last-unlock'))
hl.bind("SUPER + f", hl.dsp.window.fullscreen())
hl.bind("SUPER + r", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next({ floating = true }))
hl.bind("SUPER + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false, floating = true }))
hl.bind("code:66", hl.dsp.exec_cmd("walker"), { locked = true })

hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind("SUPER + s", hl.dsp.workspace.toggle_special("password"))
hl.bind("SUPER + m", hl.dsp.workspace.toggle_special("music"))
hl.bind("SUPER + w", hl.dsp.workspace.toggle_special("work"))
hl.bind("SUPER + z", hl.dsp.workspace.toggle_special("zoom"))
hl.bind("SUPER + SHIFT + z", hl.dsp.window.move({ workspace = "special:zoom" }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

local bind_cmd = function(keys, cmd, opts) hl.bind(keys, hl.dsp.exec_cmd(cmd), opts or nil) end
local opts = { repeating = true, locked = true }
bind_cmd("XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", opts)
bind_cmd("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", opts)
bind_cmd("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", opts)
bind_cmd("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", opts)
bind_cmd("XF86MonBrightnessUp", "brightnessctl s 10%+", opts)
bind_cmd("XF86MonBrightnessDown", "brightnessctl s 10%-", opts)

bind_cmd("XF86AudioNext", "playerctl next", { locked = true })
bind_cmd("XF86AudioPause", "playerctl play-pause", { locked = true })
bind_cmd("XF86AudioPlay", "playerctl play-pause", { locked = true })
bind_cmd("XF86AudioPrev", "playerctl previous", { locked = true })

bind_cmd("SUPER + p", "playerctl play-pause")
bind_cmd("SUPER + SHIFT + p", "~/bin/headphone-reconnect")
bind_cmd("SUPER + SHIFT + e", "curl 10.0.1.2:8000/elgato/switch -X POST")
bind_cmd("SUPER + SEMICOLON", "walker -m clipboard")
bind_cmd("Print", '~/bin/walker/screen "Screenshot | Full"')
bind_cmd("SHIFT + Print", "~/bin/walker/screen")

-- Window rules
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_initial_focus = true,
})

hl.window_rule({ match = { class = "^(?i)(com.mitchellh.ghostty)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(?i)(librewolf)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(?i)(ferdium)$" }, workspace = "3" })
hl.window_rule({ match = { class = "^(?i)(virt-manager)$" }, workspace = "4" })
hl.window_rule({ match = { class = "^(?i)(parsecd)$" }, workspace = "5" })

hl.window_rule({ match = { class = "^(?i)(clockify|eu.betterbird.Betterbird)$" }, workspace = "special:work silent" })
hl.window_rule({ match = { class = "^(?i)(spotify)$" }, workspace = "special:music silent" })
hl.window_rule({ match = { class = "^(?i)(1password)$" }, workspace = "special:password silent" })
hl.window_rule({ match = { class = "^(?i)(zoom)$" }, workspace = "special:zoom" })

hl.on("hyprland.start", function()
    local work_width = "monitor_w*0.15*" .. HYPR_SCALE
    hl.window_rule({
        match = { class = "^(?i)(clockify)$" },
        float = true,
        size = { work_width, "monitor_h-28" },
        move = { 2, 28 },
    })
    hl.window_rule({
        match = { class = "^(?i)(eu.betterbird.Betterbird)$" },
        float = true,
        size = { "monitor_w-" .. work_width .. "-4", "monitor_h-28" },
        move = { work_width .. "+4", 28 },
    })

    -- local monitor = hl.get_monitors()[1]
    -- local monitor_w = math.floor(monitor.width / monitor.scale)
    -- local monitor_h = math.floor(monitor.height / monitor.scale)
    -- local work_width = math.floor(monitor_w * 0.15)
    -- hl.window_rule({
    --     match = { class = "^(?i)(clockify)$" },
    --     float = true,
    --     size = { work_width, monitor_h - 28 },
    --     move = { 2, 28 },
    -- })
    -- hl.window_rule({
    --     match = { class = "^(?i)(eu.betterbird.Betterbird)$" },
    --     float = true,
    --     size = { monitor_w - work_width - 4, monitor_h - 28 },
    --     move = { work_width + 4, 28 },
    -- })
    hl.exec_cmd("betterbird")
    hl.exec_cmd("clockify")
end)
