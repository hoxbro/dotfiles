hl.window_rule({ match = { class = "^(?i)(hearthstone.exe)$" }, workspace = "7", fullscreen = true })
hl.window_rule({ match = { class = "^(?i)(battle.net.exe)$" }, workspace = "8 silent" })
hl.window_rule({
    match = { class = "^(?i)(hearthstonedecktracker.exe)$", title = "^(Hearthstone Deck Tracker)$" },
    workspace = "8 silent",
})
-- Wine's systray, there is no X11 tray to dock into.
hl.window_rule({ match = { class = "^(explorer.exe)$", title = "^$" }, workspace = "special:wine silent" })
-- HDT overlay covers the whole game window, with follow_mouse it steals focus and gets closed by SUPER+q.
-- Wine requests fullscreen for it when it covers the monitor, which would hide the game.
hl.window_rule({
    match = { class = "^(?i)(hearthstonedecktracker.exe)$", title = "^(HearthstoneOverlay)$" },
    suppress_event = "fullscreen maximize",
    float = true,
    no_focus = true,
    no_initial_focus = true,
    no_follow_mouse = true,
    border_size = 0,
    rounding = 0,
    no_shadow = true,
    no_blur = true,
    no_anim = true,
    decorate = false,
})

local function hdt_overlay_follow_game()
    local game = hl.get_window("class:^(hearthstone.exe)$")
    local overlay = hl.get_window("title:^(HearthstoneOverlay)$")
    if not (game and overlay and game.workspace and overlay.workspace) then return end
    if game.workspace.id ~= overlay.workspace.id then
        hl.dispatch(hl.dsp.window.move({ workspace = game.workspace.id, window = overlay, follow = false }))
    end
end
hl.on("window.open", hdt_overlay_follow_game)
hl.on("window.move_to_workspace", hdt_overlay_follow_game)
