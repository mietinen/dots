-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Enable hotkeys help widget
local hotkeys_popup = require("awful.hotkeys_popup")
-- require("awful.hotkeys_popup.keys"
-- Notification library
local naughty = require("naughty")
naughty.config.defaults['icon_size'] = 100
-- Widgets
local iface_widget = require("widgets.iface")
local mem_widget = require("widgets.mem")
local cpu_widget = require("widgets.cpu")
local volume_widget = require("widgets.volume")
local battery_widget = require("widgets.battery")
local clock_widget = require("widgets.clock")

-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = tostring(err) })
        in_error = false
    end)
end

-- Debug mode
local debug = {}
debug.enable = false

debug.toggle = function()
    local text
    debug.enable = not debug.enable
    if debug.enable then text = "Enabled!"
    else text = "Disabled!" end
    naughty.notify {
        title = "Debug mode",
        text = text,
        timeout = 10
    }
end

debug.notify = function(args)
    if debug.enable then
        naughty.notify({
            title = "Debug: "..(args.title or ""),
            text = args.text or "",
            timeout = args.timeout or 10
        })
    end
end

-- Info notification
local infonotify_var
local infonotify = function(args)
    naughty.destroy(infonotify_var)
    infonotify_var = naughty.notify {
        title = "Info: "..(args.title or ""),
        text = args.text or "",
        timeout = args.timeout or 5,
    }
end

local layout_notification = function()
    infonotify {
        title = "Layout",
        text = awful.layout.getname(),
    }
end

-- Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir().."default/theme.lua")
beautiful.font                                  = "Monospace 9"
beautiful.useless_gap                           = 4
beautiful.border_width                          = 2
beautiful.taglist_spacing                       = 2
beautiful.systray_icon_spacing                  = 3
beautiful.notification_shape                    = gears.shape.rounded_rect

scheme                                          = require("gruvbox-dark-hard")
beautiful.border_normal                         = scheme.color0
beautiful.border_focus                          = scheme.color6
beautiful.border_marked                         = scheme.color1

beautiful.bg_normal                             = scheme.background
beautiful.bg_focus                              = scheme.color6
beautiful.bg_urgent                             = scheme.color1
beautiful.bg_minimize                           = scheme.color0
beautiful.bg_systray                            = scheme.background

beautiful.fg_normal                             = scheme.foreground
beautiful.fg_focus                              = scheme.color0
beautiful.fg_urgent                             = scheme.color7
beautiful.fg_minimize                           = scheme.foreground

beautiful.taglist_bg_empty                      = scheme.color0
beautiful.taglist_bg_occupied                   = scheme.color8

beautiful.tasklist_fg_normal                    = scheme.foreground
beautiful.tasklist_bg_normal                    = scheme.background
beautiful.tasklist_fg_focus                     = scheme.foreground
beautiful.tasklist_bg_focus                     = scheme.background
beautiful.tasklist_shape_border_color           = scheme.color0
beautiful.tasklist_shape_border_color_focus     = scheme.color6
beautiful.tasklist_shape_border_color_urgent    = scheme.color1

beautiful.hotkeys_modifiers_fg  = scheme.color2

-- This is used later as the default terminal and editor to run.
terminal        = os.getenv("TERMINAL") or "sensible-terminal"
editor          = os.getenv("EDITOR") or "sensible-editor"
browser         = os.getenv("BROWSER") or "firefox"
editor_cmd      = terminal.." -e "..editor

-- Default modkey.
modkey          = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.right,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.corner.nw,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 500 } }) end)
)

awful.screen.connect_for_each_screen(function(s)
    -- Tag names and layouts
    local l = awful.layout.layouts  -- Just to save some typing: use an alias.

    -- Each screen has its own tag table.
    if (s.index == 1) then
        --                term   web    dev    chat   media  docs   virt   launch games
        local icons =   { "",   "",   "",   "󰭹",   "",   "",   "",   "",   "" }
        local layouts = { l[1],  l[1],  l[1],  l[6],  l[1],  l[1],  l[1],  l[5],  l[5]  }
        local names = {}
        for k,v in pairs(icons) do
            table.insert(names, k.." "..v)
        end
        awful.tag(names, s, layouts)
    else
        root.tags()[s.index].screen = s
        root.tags()[s.index]:view_only()
    end

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style    = {
            shape_border_width = 1,
            shape  = function(c,w,h) gears.shape.rounded_rect(c,w,h,4) end,
        },
        layout   = {
            spacing = 5,
            layout  = wibox.layout.fixed.horizontal
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            spacing = 15,
            spacing_widget = wibox.widget.separator,
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            wibox.widget.textbox(""),
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            spacing = 15,
            spacing_widget = wibox.widget.separator,
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.textbox(""),

            iface_widget(),
            mem_widget(),
            cpu_widget(),
            volume_widget(),
            battery_widget(),
            clock_widget(),
            wibox.widget.systray(),
        },
    }
end)
-- Focus primary screen
awful.screen.focus(1)


-- Key bindings
globalkeys = gears.table.join(
    -- XF86 binds
    awful.key({ }, "XF86AudioRaiseVolume",
        function() awful.spawn("volumectl up", false) end,
        {description = "Volume increase", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86AudioLowerVolume",
        function() awful.spawn("volumectl down", false) end,
        {description = "Volume decrease", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86AudioMute",
        function() awful.spawn("volumectl toggle", false) end,
        {description = "Volume mute toggle", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86AudioMicMute",
        function() awful.spawn("volumectl togglemic", false) end,
        {description = "Microphone mute toggle", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86MonBrightnessDown",
        function() awful.spawn("xbacklight -dec 10", false) end,
        {description = "Backlight decrease", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86MonBrightnessUp",
        function() awful.spawn("xbacklight -inc 10", false) end,
        {description = "Backlight increase", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86Display",
        function() awful.spawn("arandr") end,
        {description = "Launch ARandR", group = "XF86 keys"}
    ),

    awful.key({ }, "XF86Tools",
        function() awful.spawn("rofi -show editconfig") end,
        {description = "Config editor", group = "XF86 keys"}
    ),

    awful.key({ }, "Print",
        function() awful.spawn("scrot -e 'scrotmv $f'") end,
        {description = "Screenshot", group = "XF86 keys"}
    ),

    awful.key({ "Shift" }, "Print",
        function() awful.spawn("scrot -fs -e 'scrotmv $f'") end,
        {description = "Screenshot selected area", group = "XF86 keys"}
    ),

    awful.key({ "Mod1" }, "Print",
        function() awful.spawn("scrot -u -e 'scrotmv $f'") end,
        {description = "Screenshot focused window", group = "XF86 keys"}
    ),

    awful.key({ modkey }, "s",
        hotkeys_popup.show_help,
        {description="show help", group="awesome"}
    ),

    awful.key({ modkey }, "b",
        function() awful.spawn("bluedim") end,
        {description = "Bluedim toggle (color temperature)", group = "Miscellaneous"}
    ),

    awful.key({ modkey }, "c",
        function() awful.spawn([[ bash -c "
            xclip -selection primary -in /dev/null
            xclip -selection secondary -in /dev/null
            xclip -selection clipboard -in /dev/null
            "]])
            infonotify { title = "Clipboard", text = "Cleared all clipboard selections", }
        end,
        {description="Clear clipboard", group="Miscellaneous"}
    ),

    awful.key({ modkey }, "Escape",
        awful.tag.history.restore,
        {description = "go back", group = "tag"}
    ),

    awful.key({ modkey }, "j",
        function() awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}
    ),

    awful.key({ modkey }, "k",
        function() awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Rofi apps
    awful.key({ modkey }, "d",
        function() awful.spawn("rofi -show drun -show-icons") end,
        {description = "Rofi drun launcher", group = "Rofi apps"}
    ),

    awful.key({ modkey }, "r",
        function() awful.spawn("rofi -show run") end,
        {description = "Rofi run launcher", group = "Rofi apps"}
    ),

    awful.key({ modkey, "Shift" }, "w",
        function() awful.spawn("networkmanager_dmenu") end,
        {description = "Rofi NetworkManager", group = "Rofi apps"}
    ),

    awful.key({ modkey }, "a",
        function() awful.spawn("rofi -show sink") end,
        {description = "Rofi audio sink menu", group = "Rofi apps"}
    ),

    awful.key({ modkey }, "x",
        function() awful.spawn("rofi -show emoji") end,
        {description = "Rofi emoji menu", group = "Rofi apps"}
    ),

    awful.key({ modkey }, "m",
        function() awful.spawn("rofi -show man") end,
        {description = "Rofi manpage launcher", group = "Rofi apps"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j",
        function() awful.client.swap.byidx( 1) end,
        {description = "swap with next client by index", group = "client"}
    ),
    awful.key({ modkey, "Shift" }, "k",
        function() awful.client.swap.byidx( -1) end,
        {description = "swap with previous client by index", group = "client"}
    ),
    awful.key({ modkey, "Control" }, "j",
        function()
            local tag = awful.screen.focused().selected_tag
            local target_screen = gears.math.cycle(screen:count(), awful.screen.focused().index + 1)
            if tag then
                tag.screen = target_screen
                tag:view_only()
                awful.screen.focus(target_screen)
                local i = 1
                for t in pairs(root.tags()) do
                    if (root.tags()[t].screen.index == target_screen) then
                        screen[target_screen].tags[root.tags()[t].index].index = i
                        i = i + 1
                    end
                end
            end
        end,
        {description = "move tag to next screen", group = "screen"}
    ),
    awful.key({ modkey, "Control" }, "k",
        function()
            local tag = awful.screen.focused().selected_tag
            local target_screen = gears.math.cycle(screen:count(), awful.screen.focused().index - 1)
            if tag then
                tag.screen = target_screen
                tag:view_only()
                awful.screen.focus(target_screen)
                local i = 1
                for t in pairs(root.tags()) do
                    if (root.tags()[t].screen.index == target_screen) then
                        screen[target_screen].tags[root.tags()[t].index].index = i
                        i = i + 1
                    end
                end
            end
        end,
        {description = "move tag to previous screen", group = "screen"}
    ),
    awful.key({ modkey }, "u",
        awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}
    ),
    awful.key({ modkey }, "Tab",
        function() awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}
    ),

    -- Apps
    awful.key({ modkey }, "Return",
        function() awful.spawn(terminal) end,
        {description = "open a terminal", group = "Apps"}
    ),
    awful.key({ modkey }, "w",
        function() awful.spawn(browser) end,
        {description = "Launch web browser", group = "Apps"}
    ),
    awful.key({ modkey }, "e",
        function() awful.spawn("xdg-open "..os.getenv("HOME")) end,
        {description = "open file browser", group = "Apps"}
    ),
    awful.key({ modkey }, "n",
        function() awful.spawn("nitrogen") end,
        {description = "open nitrogen (wallpaper)", group = "Apps"}
    ),
    awful.key({ modkey,  "Shift" }, "n",
        function() awful.spawn("nitrogen --restore", false) end,
        {description = "nitrogen --restore (wallpaper)", group = "awesome"}
    ),
    awful.key({ modkey }, "v",
        function() awful.spawn(editor_cmd.." -c WikiIndex") end,
        {description = "open notes", group = "Apps"}
    ),

    -- Standard program
    awful.key({ modkey, "Control" }, "r",
        awesome.restart,
        {description = "restart awesome", group = "awesome"}
    ),
    awful.key({ modkey, "Control" }, "d",
        function() debug.toggle() end,
        {description = "toggle debug mode", group = "awesome"}
    ),
    awful.key({ modkey }, "Delete",
        function() awful.spawn("rofi -show exit") end,
        {description = "System exit menu", group = "awesome"}
    ),

    awful.key({ modkey }, "l",
        function() awful.tag.incmwfact( 0.05) end,
        {description = "increase master width factor", group = "layout"}
    ),
    awful.key({ modkey }, "h",
        function() awful.tag.incmwfact(-0.05) end,
        {description = "decrease master width factor", group = "layout"}
    ),
    awful.key({ modkey, "Shift" }, "h",
        function() awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}
    ),
    awful.key({ modkey, "Shift" }, "l",
        function() awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}
    ),
    awful.key({ modkey, "Control" }, "h",
        function() awful.tag.incncol( 1, nil, true) end,
        {description = "increase the number of columns", group = "layout"}
    ),
    awful.key({ modkey, "Control" }, "l",
        function() awful.tag.incncol(-1, nil, true) end,
        {description = "decrease the number of columns", group = "layout"}
    ),
    awful.key({ modkey }, "space",
        function() awful.layout.inc(1) layout_notification() end,
        {description = "select next layout", group = "layout"}
    ),
    awful.key({ modkey, "Shift" }, "space",
        function() awful.layout.inc(-1) layout_notification() end,
        {description = "select previous layout", group = "layout"}
    ),

    awful.key({ modkey, "Control" }, "n",
        function()
            local t = awful.screen.focused().selected_tag
            for _, cls in ipairs(t:clients()) do
                cls.minimized = false
            end
        end,
        {description = "restore all minimized", group = "client"}
    )
)
-- Window key bindings
clientkeys = gears.table.join(
    awful.key({ modkey }, "f",
        function(c)
            c.maximized = false
            c.fullscreen = not c.fullscreen
            c:raise()
            local t = c.first_tag
            for _, cls in ipairs(t:clients()) do
                if c.window ~= cls.window then
                    cls.minimized = c.fullscreen
                end
            end
        end,
        {description = "toggle fullscreen", group = "client"}
    ),
    awful.key({ modkey }, "q",
        function(c) c:kill() end,
        {description = "close", group = "client"}
    ),
    awful.key({ modkey, "Control" }, "space",
        awful.client.floating.toggle,
        {description = "toggle floating", group = "client"}
    ),
    awful.key({ modkey, "Control" }, "Return",
        function(c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}
    ),
    awful.key({ modkey }, "t",
        function(c) c.ontop = not c.ontop end,
        {description = "toggle keep on top", group = "client"}
    )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#"..i + 9,
    function()
        local tag = root.tags()[i]
        local screen = tag.screen
        if tag then
            tag:view_only()
            awful.screen.focus(screen)
        end
    end,
    {description = "view tag #"..i, group = "tag"}),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#"..i + 9,
    function()
        local tag = root.tags()[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end,
    {description = "toggle tag #"..i, group = "tag"}),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#"..i + 9,
    function()
        if client.focus then
            local tag = root.tags()[i]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end,
    {description = "move focused client to tag #"..i, group = "tag"}),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#"..i + 9,
    function()
        if client.focus then
            local tag = root.tags()[i]
            if tag then
                client.focus:toggle_tag(tag)
            end
        end
    end,
    {description = "toggle focused client on tag #"..i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)

-- Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            titlebars_enabled = false
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = { "DTA", "copyq", "pinentry", "qalculate-gtk" },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",
                "Sxiv",
                -- "Tor Browser",
                "Wpa_gui",
                "veromix",
                "xtightvncviewer"
            },
            name = { "Event Tester", "glxgears" },
            role = { "AlarmWindow", "ConfigManager" }
        },
        properties = { floating = true, ontop = true }
    },

    -- force ontop for floating windows
    {
        rule = { floating = true },
        properties = { ontop = true }
    },

    -- Specific tags
    -- Chat, tag 5
    {
        rule_any = {
            instance = { "discord", "signal", "telegram-desktop", "element" }
        },
        properties = { tag = root.tags()[4] }
    },
    -- Media players, tag 6
    {
        rule_any = {
            instance = { "spotify", "plexmediaplayer", "lbry", "mpv", ".*%.Celluloid", "[Kk]odi" },
            class = { "mpv" }
        },
        properties = { tag = root.tags()[5] }
    },
    -- Virtual machines, tag 7
    {
        rule_any = {
            instance = { "virt-manager", "virt-viewer", "[Vv]irtual[Bb]ox" }
        },
        properties = { tag = root.tags()[7] }
    },
    -- Game launchers, tag 8
    {
        rule_any = {
            instance = { "[Ss]team", "[Ll]utris" }
        },
        properties = { tag = root.tags()[8] }
    },
    -- Games, tag 9
    {
        rule_any = {
            class = { "steam_app_.*" }
        },
        properties = { tag = root.tags()[9], switchtotag = true, border_width = 0 }
    },
}


-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Prevent clients from being unreachable after screen count changes.
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
    -- Don't start programs maximized
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
    -- Fix for programs that start without proper WM_CLASS
    if c.class == nil or c.instance == nil then
        c:connect_signal("property::class", function() awful.rules.apply(c) end)
        c:connect_signal("property::instance", function() awful.rules.apply(c) end)
    end
    -- getting instance/class
    debug.notify {
        title = (c.name or "No name"),
        text = "Instance: "..(c.instance or "").."\nClass: "..(c.class or "")
    }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Autorun
awful.spawn.with_shell("${XDG_CONFIG_HOME:-$HOME/.config}/desktop/autorun")
