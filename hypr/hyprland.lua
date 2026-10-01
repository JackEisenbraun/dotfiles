--- Hyprland config file ---

--- PROGRAMS ---
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "hyprlauncher"

--- AUTOSTART ---

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("waypaper &")
    hl.exec_cmd("awww-daemon")
    -- hl.exec_cmd("eww daemon")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- hl.exec_cmd("bash -c 'eww open bar_widget && eww update get_vol=\"$(pamixer --get-volume)\" && ~/.config/eww/scripts/getvol.sh'")
    -- hl.exec_cmd("bash -c '~/.config/eww/scripts/workspace.sh'")
end)



--- Keybinds ---

-- Hyprland
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
-- NOTE: "fullscreen" dispatcher isn't shown in the official Lua example; hl.dsp.window.fullscreen()
-- is the best-guess equivalent of the old `fullscreen,` dispatch. Verify against the wiki.
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("/home/jack/.local/share/quickshell-lockscreen/lock.sh"))

-- Sysctl
hl.bind("CTRL + up", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("CTRL + down", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind(mainMod .. " + ALT + V",
    hl.dsp.exec_cmd(
        "cliphist list | rofi -dmenu -display-columns 2 -theme ~/.config/rofi/clipboard.rasi | cliphist decode | wl-copy"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("code:232", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("code:233", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind(mainMod.. " + up", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
-- Open apps
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("kitty wlctl"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/eww/toggle.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("kitty bluetui"))

--- Workspace navigator ---
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    -- Move window to workspace
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

--- Navigation ---
hl.bind(mainMod .. " + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.window.move({ direction = "d" }))

--- Move focus window ---
hl.bind("SUPER + ALT + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + ALT + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + ALT + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + ALT + down", hl.dsp.focus({ direction = "d" }))

--- Rofi app launcher ---
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("rofi -show drun -theme ~/.config/rofi/config.rasi"))

--- Wallpaper ---
hl.bind(mainMod .. " + SHIFT + N",
    hl.dsp.exec_cmd("kitty --title wallpaper-picker ~/.config/scripts/wallpaper-picker.sh"))

--- Cliphist things ---
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("cliphist list | walker --dmenu | cliphist decode | wl-copy"))


--- HYPRMOD MANAGED CFG ---

hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 8,

        border_size      = 2,

        col              = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing    = false,

        layout           = "dwindle",
    },

    decoration = {
        rounding         = 16,
        rounding_power   = 5,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = .65,

        shadow           = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})


--- INPUT ---

hl.config({
    input = {
        kb_options = "caps:escape",
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            scroll_factor = 0.2,
        },
    },
})
