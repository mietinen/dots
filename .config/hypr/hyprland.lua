-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function () 
    hl.exec_cmd("runonce -k /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("runonce -k waybar")
    hl.exec_cmd("runonce -k hyprpaper")
    hl.exec_cmd("runonce -k hypridle")
    hl.exec_cmd("runonce -k mako")
    hl.exec_cmd("runonce mpd")
    hl.exec_cmd("runonce syncthing --no-browser")
    hl.exec_cmd("runonce gioautomount")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Gruvbox-Material-Dark")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme Gruvbox-Material-Dark")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'Sans 10'")
end)



-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 1,
        gaps_out = 1,
        border_size = 1,

        col = {
            active_border   = { colors = {"rgba(fe8019ee)", "rgba(d3869bee)"}, angle = 45 },
            inactive_border = "rgba(928374aa)",
        },

        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },

    decoration = {
        rounding       = 3,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = false,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "myBezier" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "slave",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.9,
        focus_fit_method = 0,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
        enable_anr_dialog = false,
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#ecosystem
hl.config({
  ecosystem = {
    no_update_news = false,
    no_donation_nag = false
  },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "no",
        kb_variant = "",
        kb_model   = "",
        kb_options = "nbsp:none",
        kb_rules   = "",

        follow_mouse = 0,
        float_switch_override_focus = 0,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        scroll_factor = 0.5,

        touchpad = {
            natural_scroll = false,
            scroll_factor = 0.5,
        },
    },
})

-- hl.gesture({
--     fingers = 3,
--     direction = "horizontal",
--     action = "workspace"
-- })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "tpps/2-elan-trackpoint",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local left = "H"
local down = "J"
local up = "K"
local right = "L"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("sensible-terminal"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.workspace.toggle_special("terminal"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("sensible-browser"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("xdg-open ~"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + Space", function()
    local layout = hl.get_active_workspace().tiled_layout
    if layout == "master" then hl.dispatch(hl.dsp.layout("swapwithmaster master"))
    elseif layout == "scrolling" then hl.dispatch(hl.dsp.layout("promote"))
    end
end)

hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + CTRL + Space", function()
    local layout = hl.get_active_workspace().tiled_layout
    if layout == "master" then hl.dispatch(hl.dsp.layout("mfact exact 0.55"))
    elseif layout == "scrolling" then hl.dispatch(hl.dsp.layout("colresize 0.9"))
    end
end)

hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("sethyprpaper"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("wl-copy -c; wl-copy -pc; notify-send 'Clipboard' 'Cleared all clipboard selections'"))

-- rofi
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show run"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun -show-icons"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("networkmanager_dmenu"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("rofi -show sink"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("rofi -show smb"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("rofi -show emoji"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("rofi -show man"))
hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("rofi -show exit"))
-- hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- XF86
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volumectl togglemic"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("rmpc togglepause"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("rmpc stop"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("rmpc prev"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("rmpc next"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))
hl.bind("Print", hl.dsp.exec_cmd("grimcopy"))
hl.bind("XF86Launch2", hl.dsp.exec_cmd("grimcopy select"))

-- MPD
hl.bind(mainMod .. " + M", hl.dsp.submap("mpd"))
hl.define_submap("mpd", function()
    hl.bind("J", hl.dsp.exec_cmd("rmpc prev"))
    hl.bind("K", hl.dsp.exec_cmd("rmpc togglepause"))
    hl.bind("L", hl.dsp.exec_cmd("rmpc next"))
    hl.bind("catchall", hl.dsp.submap("reset"))

end)

-- Move focus to next window with mainMod + TAB
hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
hl.bind(mainMod .. " + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
-- Move focus with mainMod + VIM/arrow
hl.bind(mainMod .. " + " .. left,  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + " .. right, hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + " .. up,    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + " .. down,  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
-- Move focused window with mainMod+SHIFT + VIM/arrow
hl.bind(mainMod .. " + SHIFT + " .. left,  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + " .. right, hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + " .. up,    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + " .. down,  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
-- Resize focused window with mainMod+CTRL + VIM/arrow
hl.bind(mainMod .. " + CTRL + " .. left,  hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + " .. right, hl.dsp.window.resize({ x = 40, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + " .. up,    hl.dsp.window.resize({ x = 0, y = -40, relative = true }))
hl.bind(mainMod .. " + CTRL + " .. down,  hl.dsp.window.resize({ x = 0, y = 40, relative = true }))
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -40, relative = true }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y = 40, relative = true }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({ suppress_event = "maximize", match = { class = ".*" } }) -- You'll probably like this.
hl.window_rule({ center = true, match = { float = true } }) -- center floating windows

-- Floating
hl.window_rule({ float = true, match = { class = "qalculate-gtk" } })
hl.window_rule({ float = true, match = { class = "blueman-manager" } })
hl.window_rule({ float = true, match = { class = ".*%.pavucontrol" } })
hl.window_rule({ float = true, match = { class = "nm-connection-editor" } })
hl.window_rule({ float = true, match = { class = "wev" } })
hl.window_rule({ float = true, match = { class = "xdg-desktop-portal-gtk" } })
hl.window_rule({ float = true, size = { "(monitor_w*0.5)", "(monitor_h*0.5)" }, match = { class = "firefox", title = "(Library)?" } })

-- Organizing
hl.window_rule({ workspace = 4, match = { class = "discord" } })
hl.window_rule({ workspace = 4, match = { class = "(?i:signal)" } })
hl.window_rule({ workspace = 4, match = { class = "telegram-desktop" } })
hl.window_rule({ workspace = 4, match = { class = "element" } })
hl.window_rule({ workspace = 5, match = { class = "(?i:spotify)" } })
hl.window_rule({ workspace = 5, match = { class = "plexmediaplayer" } })
hl.window_rule({ workspace = 5, match = { class = "mpv" } })
hl.window_rule({ workspace = 5, match = { class = "(?i:kodi)" } })
hl.window_rule({ workspace = 5, match = { class = "(?i:freetube)" } })
hl.window_rule({ workspace = 7, match = { class = "virt-manager" } })
hl.window_rule({ workspace = 7, match = { class = "virt-viewer" } })
hl.window_rule({ workspace = 7, match = { class = "(?i:virtualbox)" } })
hl.window_rule({ workspace = 8, match = { class = "(?i:steam)" } })
hl.window_rule({ workspace = 8, match = { class = "(?i:lutris)" } })
hl.window_rule({ workspace = 9, match = { class = "steam_app_.*" } })
hl.window_rule({ workspace = 9, match = { class = "steam_proton" } })
hl.window_rule({ workspace = 9, match = { class = "gamescope" } })
hl.window_rule({ workspace = 9, match = { class = "4telegram-desktop" } })


-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.workspace_rule({ workspace = 4, layout = "scrolling" })
hl.workspace_rule({ workspace = "special:terminal", on_created_empty = "[float]sensible-terminal" })
